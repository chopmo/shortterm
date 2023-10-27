require_relative 'screens/epics'
require_relative 'api_client'
require 'curses'

class Runner
  attr_reader :epics

  def load_initial_data
    puts "Loading epics..."
    @epics = ApiClient.get_epics.select(&:started).reject(&:completed).sort_by(&:name)
  end

  def loop
    screen = Screens::Epics.new(epics)

    while true
      command = screen.run
      case command[:action]
      when :quit
        Curses.close_screen
        exit 0
      end
    end

    puts "hi"
  end
end
