module Screens
  class Epic
    def initialize(all_stories, workflow_states)
      @all_stories = all_stories
      @stories = all_stories.reject(&:archived)
      @workflow_states = workflow_states

      @show_unscheduled = true
      @show_completed = false
    end

    def run
      Curses.init_screen
      Curses.start_color
      Curses.init_pair(1, 1, 0) # red
      Curses.init_pair(2, 2, 0) # green
      Curses.init_pair(3, 4, 0) # blue
      Curses.init_pair(4, 0, 7) # black on white

      Curses.curs_set(0)
      Curses.noecho

      @win = Curses::Window.new(0, 0, 1, 2)

      story_idx = 0
      scroll_pos = 0
      story_pane_height = @win.maxy / 2 - 1

      loop do
        story = @stories[story_idx]

        lines = story_lines(@stories, story_idx)
        scroll_pos = update_scroll_pos(scroll_pos, lines, story_pane_height)
        render_lines(0, lines.drop(scroll_pos))
        render_lines(story_pane_height + 1, summary_lines(story))
        print_help

        @win.refresh

        str = @win.getch.to_s
        case str
        when 'j'
          story_idx += 1
        when 'J'
          story_idx += 10
        when 'k'
          story_idx -= 1
        when 'K'
          story_idx -= 10
        when '10'
          if story
            return { action: :start_or_switch_to_story, id: story.id }
          end
        when 'q'
          return { action: :open_epics }
        end

        story_idx = [story_idx, @stories.size - 1].min
        story_idx = [0, story_idx].max
      end
    end

    def story_lines(stories, current_index)
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

    def summary_lines(story)
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

    def print_help
      split_line = @win.maxy - 1
      @win.setpos(split_line, 0)
      help_text = " j/J: Move down, k/K: Move up, RET: Start or switch to story branch, q: back to epics"
      @win.attron(Curses.color_pair(4)) {
        @win << help_text
        @win << " " * (@win.maxx - help_text.size)
        @win << "\n"
      }
    end

    def get_state(story)
      @workflow_states.find(story.workflow_state_id).name
    end

    def update_scroll_pos(current_pos, lines, height)
      active_line_idx = lines.find_index { |_, _, active| active }
      if active_line_idx < current_pos
        active_line_idx
      elsif active_line_idx > (current_pos + height)
        active_line_idx - height
      else
        current_pos
      end
    end
  end
end
