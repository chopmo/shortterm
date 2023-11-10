module Screens
  class Story
    def initialize(story, workflow_states)
      @story = story
      @workflow_states = workflow_states
    end

    def run
      @win = Curses::Window.new(0, 0, 1, 2)

      loop do
        @win.setpos(0,0)

        render_lines(0, get_summary_lines(@story))
        @win.refresh

        str = @win.getch.to_s
        case str
        when '10'
          return { action: :start_or_switch_to_story, id: @story.id }
        when 'q'
          return { action: :open_epic, id: @story.epic_id }
        end
      end
    end

    def get_summary_lines(story)
      lines = []
      lines << [2, story.name]
      lines << [0, "URL: #{story.app_url}"]
      lines << [3, "State: #{get_state(story)}"]
      lines << [0, ""]
      lines << [0, story.description]
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

    def get_state(story)
      @workflow_states.find(story.workflow_state_id).name
    end
  end
end
