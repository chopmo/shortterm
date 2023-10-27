module Screens
  class Epics
    def initialize(epics)
      @epics = epics
      @index = 0
      @max_index = @epics.size - 1
      @min_index = 0
    end

    def run
      Curses.init_screen
      Curses.start_color
      Curses.init_pair(1, 1, 0)
      Curses.init_pair(2, 0, 7)
      Curses.curs_set(0)
      Curses.noecho

      win = Curses::Window.new(0, 0, 1, 2)


      loop do
        win.setpos(0,0)

        @epics.each.with_index(0) do |e, i|
          str = "#{e.id}: #{e.name}"

          if i == @index
            win.attron(Curses.color_pair(2)) { win << str }
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
          @index = [@max_index, @index + 1].min
        when 'k'
          @index = [@min_index, @index - 1].max
        when '10'
          return { action: :open_epic, id: @epics[@index].id }
        when 'q'
          return { action: :quit }
        end
      end
    end
  end
end
