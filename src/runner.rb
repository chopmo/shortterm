require_relative 'screens/epics'
require_relative 'screens/epic'
require_relative 'api_client'
require 'curses'

class Runner
  def load_initial_data
    puts "Loading epics..."
    @epics = ApiClient.get_epics.select(&:started).reject(&:completed).sort_by(&:name)
  end

  def open_epics
    Screens::Epics.new(@epics)
  end

  def open_epic(id)
    stories = ApiClient.get_stories(id)
    Screens::Epic.new(stories)
  end

  def loop
    screen = open_epics

    while true
      command = screen.run
      case command[:action]
      when :open_epic
        screen = open_epic(command[:id])
      when :open_epics
        screen = open_epics
      when :quit
        Curses.close_screen
        exit 0
      end
    end
  end
end
