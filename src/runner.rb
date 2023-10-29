require_relative 'screens/epics'
require_relative 'screens/epic'
require_relative 'api_client'
require_relative 'git'
require_relative 'cache'
require_relative 'workflow_states'
require 'curses'

class Runner
  def load_initial_data
    json = Cache.read_through("tmp/workflows.json") { ApiClient.get_workflows }
    @workflow_states = WorkflowStates.parse(json)

    json = Cache.read_through("tmp/epics.json") { ApiClient.get_epics }
    @epics = JSON.parse(json, object_class: OpenStruct).select(&:started).reject(&:completed).sort_by(&:name)
  end

  def open_epic(id)
    json = ApiClient.get_stories(id)
    stories = JSON.parse(json, object_class: OpenStruct)
    Screens::Epic.new(stories, @workflow_states)
  end

  def init_curses
    Curses.init_screen
    Curses.start_color
    Curses.init_pair(1, 1, 0) # red
    Curses.init_pair(2, 2, 0) # green
    Curses.init_pair(3, 4, 0) # blue
    Curses.init_pair(4, 0, 7) # black on white
    Curses.curs_set(0)
    Curses.noecho
  end

  def loop
    epics_screen = Screens::Epics.new(@epics)
    screen = epics_screen
    while true
      command = screen.run
      case command[:action]
      when :open_epic
        screen = open_epic(command[:id])
      when :open_epics
        screen = epics_screen
      when :start_or_switch_to_story
        Curses.close_screen
        story = JSON.parse(ApiClient.get_story(command[:id]),
                           object_class: OpenStruct)
        if Git.start_or_switch_to_story(story)
          exit 0
        end
      when :quit
        Curses.close_screen
        exit 0
      end
    end
  end
end
