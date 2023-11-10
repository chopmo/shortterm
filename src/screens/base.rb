module Screens
  class Base
    def initialize
      @win = Curses::Window.new(0, 0, 1, 2)
    end

    def set_current_line(y)
      @win.setpos(y, 0)
    end

    def render_lines(lines)
      lines.each do |col, str|
        @win.attron(Curses.color_pair(col)) {
          @win << str
          Curses.clrtoeol
          @win << "\n"
        }
      end

      (@win.maxy - @win.cury).times {@win.deleteln()}
    end
  end
end
