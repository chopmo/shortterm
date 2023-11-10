require_relative 'screens/epics'
require_relative 'screens/epic'
require_relative 'screens/story'
require_relative 'api_client'
require_relative 'git'
require_relative 'cache'
require 'curses'

class Runner
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
    screen = Screens::Epics.new
    while true
      command = screen.run
      case command[:action]
      when :open_epic
        screen = Screens::Epic.new(command[:id])
      when :open_epics
        screen = Screens::Epics.new
      when :open_story
        screen = Screens::Story.new(command[:id])
      when :start_or_switch_to_story
        Curses.close_screen
        story = JSON.parse(ApiClient.get_story(command[:id]),
                           object_class: OpenStruct)
        Git.start_or_switch_to_story(story)
      when :quit
        Curses.close_screen
        exit 0
      end
    end
  end
end
