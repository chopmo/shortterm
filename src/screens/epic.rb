module Screens
  class Epic
    def initialize(stories)
      @stories = stories
    end

    def run
      Curses.init_screen
      Curses.start_color
      Curses.init_pair(1, 1, 0) # red
      Curses.init_pair(2, 2, 0) # green
      Curses.curs_set(0)
      Curses.noecho

      @win = Curses::Window.new(0, 0, 1, 2)

      index = 0
      max_index = @stories.size - 1
      min_index = 0

      loop do
        print_stories(@stories, index)
        print_summary_pane(@stories[index])

        @win.refresh

        str = @win.getch.to_s
        case str
        when 'j'
          index += 1
        when 'J'
          index += 10
        when 'k'
          index -= 1
        when 'K'
          index -= 10
        when 'q'
          return { action: :open_epics }
        end

        index = [index, max_index].min
        index = [min_index, index].max
      end
    end

    def print_stories(stories, current_index)
      @win.setpos(0,0)
      stories.each.with_index(0) do |s, i|
        str = "#{s.id}: #{s.name}"

        if i == current_index
          @win.attron(Curses.color_pair(1)) { @win << str }
        else
          @win << str
        end
        Curses.clrtoeol
        @win << "\n"
      end
      (@win.maxy - @win.cury).times {@win.deleteln()}
    end

    def print_summary_pane(story)
      split_line = @win.maxy / 2
      @win.setpos(split_line, 0)
      divider = "-" * (@win.maxx - 1)
      @win << divider
      @win << "\n"
      @win.attron(Curses.color_pair(2)) { @win << story[:name] }
      @win.clrtoeol
      @win << "\n"
      @win << "URL: " << story[:app_url]
      @win.clrtoeol
      @win << "\n"
      @win << "\n"
      @win << story[:description]
      @win.clrtoeol
      @win << "\n"
      (@win.maxy - @win.cury).times {@win.deleteln()}
    end
  end
end
