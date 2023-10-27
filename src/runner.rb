require_relative 'screens/epics'
require_relative 'screens/epic'
require_relative 'api_client'
require 'curses'

class Runner
  def load_initial_data
    puts "Loading workflows..."
    @workflow_states = ApiClient.get_workflow_states
    puts "Loading epics..."
    # @epics = ApiClient.get_epics.select(&:started).reject(&:completed).sort_by(&:name)
    @test_stories = JSON.parse(File.read("tmp/stories.json"), object_class: OpenStruct).reject(&:completed)
  end

  def open_epic(id)
    stories = ApiClient.get_stories(id).reject(&:completed)
    Screens::Epic.new(stories, @workflow_states)
  end

  def loop
    # epics_screen = Screens::Epics.new(@epics)
    # screen = epics_screen

    screen = Screens::Epic.new(@test_stories, @workflow_states)

    while true
      command = screen.run
      case command[:action]
      when :open_epic
        screen = open_epic(command[:id])
      when :open_epics
        screen = epics_screen
      when :quit
        Curses.close_screen
        exit 0
      end
    end
  end
end
