require_relative 'screens/epics'
require_relative 'screens/epic'
require_relative 'api_client'
require_relative 'workflow_states'
require 'curses'

class Runner
  def load_initial_data
    workflow_cache = "tmp/workflows.json"
    if File.exists?(workflow_cache)
      puts "Using cached workflows"
      @workflow_states = WorkflowStates.parse(File.read(workflow_cache))
    else
      puts "Loading workflows..."
      json = ApiClient.get_workflows
      @workflow_states = WorkflowStates.parse(json)
      File.write(workflow_cache, json)
    end

    epics_cache = "tmp/epics.json"
    if File.exists?(epics_cache)
      puts "Using cached epics"
      json = File.read(epics_cache)
    else
      puts "Loading epics..."
      json = ApiClient.get_epics
      File.write(epics_cache, json)
    end
    @epics = JSON.parse(json, object_class: OpenStruct).select(&:started).reject(&:completed).sort_by(&:name)
    # @test_stories = JSON.parse(File.read("tmp/stories.json"), object_class: OpenStruct).reject(&:completed)
  end

  def open_epic(id)
    stories = ApiClient.get_stories(id).reject(&:completed)
    Screens::Epic.new(stories, @workflow_states)
  end

  def loop
    epics_screen = Screens::Epics.new(@epics)
    screen = epics_screen

    # screen = Screens::Epic.new(@test_stories, @workflow_states)

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
