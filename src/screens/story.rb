require_relative "base"

module Screens
  class Story < Base
    def initialize(story_id)
      super()
      @story_id = story_id
      @selected_line = nil
      load_story
    end

    def load_story(bypass_cache: false)
      json = Cache.read_through("story-#{@story_id}", bypass_cache: bypass_cache) {
        ApiClient.get_story(@story_id)
      }
      @story = JSON.parse(json, object_class: OpenStruct)
    end


    def handle_command(command)
      case command[:action]
      when :select_branch
        Curses.close_screen
        Git.switch_to_branch(command[:name])
      when :create_branch
        Curses.close_screen
        Git.create_branch(command[:name])
      end
    end

    def run
      loop do
        set_current_line(0)
        lines = get_lines
        @selected_line ||= first_selectable_line(lines)
        render_lines(lines, @selected_line)
        render_help_line(
          "j: Move down, k: Move up, g: Reload, RET: Perform action, q: Back to epic"
        )

        @win.refresh
        str = @win.getch.to_s
        case str
        when 'g'
          Curses.close_screen
          puts "Reloading..."
          load_story(bypass_cache: true)
        when 'j'
          @selected_line += 1
        when 'k'
          @selected_line -= 1
        when '10'
          handle_command(lines[@selected_line][2])
        when 'q'
          return { action: :pop_screen }
        end
      end
    end

    def get_lines
      lines = []
      lines << [2, @story.name]
      lines << [0, "URL: #{@story.app_url}"]
      lines << [3, "State: #{get_story_state(@story)}"]
      lines << [0, ""]
      lines << [0, @story.description]
      lines << [0, ""]
      lines << [2, "Branches:"]
      @story.branches.each do |b|
        lines << [0, "Check out #{b.name}", { action: :select_branch, name: b.name }]
      end
      new_branch_name = Git.branch_name(@story)
      lines << [0,
                "Create new branch '#{new_branch_name}'",
                { action: :create_branch, name: new_branch_name }]
      lines
    end

    def first_selectable_line(lines)
      lines.find_index { |_col, _text, command| !!command }
    end
  end
end
