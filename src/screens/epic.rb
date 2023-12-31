require_relative 'base'

module Screens
  class Epic < Base
    def initialize(epic_id)
      super()
      @epic_id = epic_id
      @shown_states = Set["Unscheduled",
                          "Ready for Development",
                          "In Development",
                          "Ready for Review",
                          "Completed"]
      load_stories
    end

    def load_stories(bypass_cache: false)
      json = Cache.read_through("epic-#{@epic_id}", bypass_cache: bypass_cache) {
        ApiClient.get_stories(@epic_id)
      }
      @all_stories = JSON.parse(json, object_class: OpenStruct)
      @story_idx = 0
    end

    def filter_stories
      @stories = @all_stories.reject(&:archived)
      @stories = @stories.reject { |s| !@shown_states.include?(get_story_state(s)) }
    end

    def run
      scroll_pos = 0
      story_pane_height = @win.maxy / 2 - 1

      loop do
        filter_stories
        story = @stories[@story_idx]

        story_lines = get_story_lines(@stories, @story_idx)
        scroll_pos = update_scroll_pos(scroll_pos, story_lines, story_pane_height)
        set_current_line(0)
        render_lines(story_lines.drop(scroll_pos))

        set_current_line(story_pane_height + 1)
        render_lines(get_summary_lines(story))

        render_help_line(
          "j/J: Move down, k/K: Move up, g: Reload, u: Toggle unscheduled, c: Toggle completed, RET: Start or switch to story branch, q: back to epics"
        )

        @win.refresh

        str = @win.getch.to_s
        case str
        when 'g'
          Curses.close_screen
          puts "Reloading..."
          load_stories(bypass_cache: true)
        when 'j'
          @story_idx += 1
        when 'J'
          @story_idx += 10
        when 'k'
          @story_idx -= 1
        when 'K'
          @story_idx -= 10
        when 'u'
          toggle_shown_state("Unscheduled")
        when 'c'
          toggle_shown_state("Completed")
        when '10'
          if story
            return { action: :open_story, id: story.id }
          end
        when 'q'
          return { action: :pop_screen }
        end

        @story_idx = [@story_idx, @stories.size - 1].min
        @story_idx = [0, @story_idx].max
      end
    end

    def get_story_lines(stories, current_index)
      lines = []
      i = 0
      stories.group_by { |s| get_story_state(s) }.each do |state, stories|
        lines << [2, "#{state}:"]

        stories.each do |s|
          active = i == current_index
          lines << [active ? 4 : 0, "#{s.id}: #{s.name}", active]
          i += 1
        end

        lines << [0, ""]
      end

      lines
    end

    def get_summary_lines(story)
      return [] if !story

      lines = []

      lines << [0, "-" * (@win.maxx - 1)]
      lines << [2, story.name]
      lines << [0, "URL: #{story.app_url}"]
      lines << [3, "State: #{get_story_state(story)}"]
      lines << [0, ""]
      lines << [0, story.description]

      lines
    end

    def update_scroll_pos(current_pos, lines, height)
      return current_pos if lines.empty?

      active_line_idx = lines.find_index { |_, _, active| active }
      if active_line_idx < current_pos
        active_line_idx
      elsif active_line_idx > (current_pos + height)
        active_line_idx - height
      else
        current_pos
      end
    end

    def toggle_shown_state(s)
      if @shown_states.include?(s)
        @shown_states.delete(s)
      else
        @shown_states.add(s)
      end
      @story_idx = 0
    end
  end
end
