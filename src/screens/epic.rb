module Screens
  class Epic
    def initialize(stories, workflow_states)
      @stories = stories
      @workflow_states = workflow_states
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

      index = 0
      max_index = @stories.size - 1
      min_index = 0

      loop do
        story = @stories[index]
        print_stories(@stories, index)
        print_summary_pane(story)
        print_help

        @win.refresh

        str = @win.getch.to_s
        case str
        when 'j'
          index += 1
        when 'J'
          index += 10
        when 'k'
          index -= 1
        when 'K'
          index -= 10
        when '10'
          if story
            return { action: :start_or_switch_to_story, id: story.id }
          end
        when 'q'
          return { action: :open_epics }
        end

        index = [index, max_index].min
        index = [min_index, index].max
      end
    end

    def print_stories(stories, current_index)
      @win.setpos(0,0)

      i = 0
      stories.group_by { |s| get_state(s) }.each do |state, stories|
        @win.attron(Curses.color_pair(2)) { @win << state << ":\n" }

        stories.each do |s|
          str = "#{s.id}: #{s.name}"
          if i == current_index
            @win.attron(Curses.color_pair(4)) { @win << str }
          else
            @win << str
          end
          Curses.clrtoeol
          @win << "\n"

          i += 1
        end

        @win << "\n"
      end
      (@win.maxy - @win.cury).times {@win.deleteln()}
    end

    def print_summary_pane(story)
      return if !story

      split_line = @win.maxy / 2
      @win.setpos(split_line, 0)
      divider = "-" * (@win.maxx - 1)
      @win << divider
      @win << "\n"
      @win.attron(Curses.color_pair(2)) { @win << story.name }
      @win.clrtoeol
      @win << "\n"
      @win << "URL: " << story.app_url
      @win.clrtoeol
      @win << "\n"
      @win.attron(Curses.color_pair(3)) {
        @win << "State: " << get_state(story)
      }
      @win.clrtoeol
      @win << "\n"
      @win << "\n"
      @win << story.description
      @win.clrtoeol
      @win << "\n"
      (@win.maxy - @win.cury).times {@win.deleteln()}
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
  end
end
