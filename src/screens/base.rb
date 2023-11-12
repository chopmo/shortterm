require_relative '../workflow_states'
require_relative '../repositories'

module Screens
  class Base
    def initialize
      @win = Curses::Window.new(0, 0, 1, 2)

      json = Cache.read_through("workflows") { ApiClient.get_workflows }
      @workflow_states = WorkflowStates.parse(json)

      json = Cache.read_through("repositories") { ApiClient.get_repositories }
      @repositories = Repositories.parse(json)
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

    def render_help_line(s)
      set_current_line(@win.maxy - 2)
      width = @win.maxx
      render_lines([[4,  " %-#{width}.#{width}s" % s]])
    end

    def get_story_state(story)
      @workflow_states.find(story.workflow_state_id).name
    end

    def get_repository(branch)
      @repositories.find(branch.repository_id).name
    end

    def get_project(branch)
      Config.project_dirs.find { |pd| pd.repository == get_repository(branch) }
    end
  end
end
