module Screens
  class Epic
    def initialize(all_stories, workflow_states)
      @all_stories = all_stories
      @workflow_states = workflow_states
      @shown_states = Set["Ready for Development", "In Development", "Ready for Review"]
    end

    def filter_stories
      @stories = @all_stories.reject(&:archived)
      @stories = @stories.reject { |s| !@shown_states.include?(get_state(s)) }
    end

    def run
      @win = Curses::Window.new(0, 0, 1, 2)

      @story_idx = 0
      scroll_pos = 0
      story_pane_height = @win.maxy / 2 - 1

      loop do
        filter_stories
        story = @stories[@story_idx]

        story_lines = get_story_lines(@stories, @story_idx)
        scroll_pos = update_scroll_pos(scroll_pos, story_lines, story_pane_height)
        render_lines(0, story_lines.drop(scroll_pos))

        render_lines(story_pane_height + 1, get_summary_lines(story))

        help_lines = get_help_lines
        render_lines(@win.maxy - help_lines.size - 1, help_lines)

        @win.refresh

        str = @win.getch.to_s
        case str
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
            return { action: :start_or_switch_to_story, id: story.id }
          end
        when 'q'
          return { action: :open_epics }
        end

        @story_idx = [@story_idx, @stories.size - 1].min
        @story_idx = [0, @story_idx].max
      end
    end

    def get_story_lines(stories, current_index)
      lines = []
      i = 0
      stories.group_by { |s| get_state(s) }.each do |state, stories|
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

    def render_lines(y, lines)
      @win.setpos(y, 0)

      lines.each do |col, str|
        @win.attron(Curses.color_pair(col)) {
          @win << str
          Curses.clrtoeol
          @win << "\n"
        }
      end

      (@win.maxy - @win.cury).times {@win.deleteln()}
    end

    def get_summary_lines(story)
      return [] if !story

      lines = []

      lines << [0, "-" * (@win.maxx - 1)]
      lines << [2, story.name]
      lines << [0, "URL: #{story.app_url}"]
      lines << [3, "State: #{get_state(story)}"]
      lines << [0, ""]
      lines << [0, story.description]

      lines
    end

    def get_help_lines
      width = @win.maxx
      help_text =
        " j/J: Move down, k/K: Move up, u: Toggle unscheduled, c: Toggle completed, RET: Start or switch to story branch, q: back to epics"
      [[4,  "%-#{width}.#{width}s" % help_text]]
    end

    def get_state(story)
      @workflow_states.find(story.workflow_state_id).name
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
