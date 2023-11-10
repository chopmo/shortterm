require_relative '../workflow_states'

module Screens
  class Base
    def initialize
      @win = Curses::Window.new(0, 0, 1, 2)

      json = Cache.read_through("workflows") { ApiClient.get_workflows }
      @workflow_states = WorkflowStates.parse(json)
    end

    def set_current_line(y)
      @win.setpos(y, 0)
    end

    def render_lines(lines, selected_line = nil)
      index = 0
      lines.each do |col, str|
        if index == selected_line
          col = 4
        end
        @win.attron(Curses.color_pair(col)) {
          @win << str
          Curses.clrtoeol
          @win << "\n"
        }
        index += 1
      end

      (@win.maxy - @win.cury).times {@win.deleteln()}
    end

    def get_story_state(story)
      @workflow_states.find(story.workflow_state_id).name
    end
  end
end
