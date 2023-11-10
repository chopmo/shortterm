require_relative 'base'

module Screens
  class Epics < Base
    def initialize(epics)
      super()
      @epics = epics
      @index = 0
      @max_index = @epics.size - 1
      @min_index = 0
    end

    def run
      loop do
        set_current_line(0)
        render_lines(get_epic_lines(@epics, @index))

        @win.refresh
        str = @win.getch.to_s
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

    def get_epic_lines(epics, current_index)
      lines = []
      epics.each.with_index(0) do |e, i|
        active = i == current_index
        lines << [active ? 4 : 0, "#{e.id}: #{e.name}"]
      end
      lines
    end
  end
end
