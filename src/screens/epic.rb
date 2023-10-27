module Screens
  class Epic
    def initialize(stories)
      @stories = stories
    end

    def run
      Curses.init_screen
      Curses.start_color
      Curses.init_pair(1, 1, 0)
      Curses.curs_set(0)
      Curses.noecho

      win = Curses::Window.new(0, 0, 1, 2)

      index = 0
      max_index = @stories.size - 1
      min_index = 0

      loop do
        win.setpos(0,0)

        @stories.each.with_index(0) do |s, i|
          str = "#{s.id}: #{s.name}"

          if i == index
            win.attron(Curses.color_pair(1)) { win << str }
          else
            win << str
          end
          Curses.clrtoeol
          win << "\n"
        end
        (win.maxy - win.cury).times {win.deleteln()}
        win.refresh

        str = win.getch.to_s
        case str
        when 'j'
          index = [max_index, index + 1].min
        when 'k'
          index = [min_index, index - 1].max
        when 'q'
          return { action: :open_epics }
        end
      end
    end
  end
end
