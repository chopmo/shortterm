require_relative "base"
require_relative "../config"

module Screens
  class Story < Base
    def initialize(story_id)
      super()
      @story_id = story_id
      @selected_line = nil
      @pending_branch_command = nil
      load_story
    end

    def load_story(bypass_cache: false)
      json = Cache.read_through("story-#{@story_id}", bypass_cache: bypass_cache) {
        ApiClient.get_story(@story_id)
      }
      @story = JSON.parse(json, object_class: OpenStruct)
    end


    def handle_command(command)
      if command[:action] == :project_dir_selected
        Git.with_current_dir(command[:dir]) do
          Curses.close_screen
          case @pending_branch_command[:action]
          when :select_branch
            Git.switch_to_branch(@pending_branch_command[:name])
          when :create_branch
            Git.create_branch(@pending_branch_command[:name])
          end
          puts "Press any key..."
          @win.getch
        end
      else
        @pending_branch_command = command
        @selected_line = nil
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
          if @pending_branch_command
            @pending_branch_command = nil
            @selected_line = nil
          else
            return { action: :pop_screen }
          end
        end
      end
    end

    def branch_commands
      result = []

      @story.branches.each do |b|
        result << ["[#{get_repository(b)}] #{b.name}", { action: :select_branch, name: b.name }]
      end

      new_branch_name = Git.branch_name(@story)
      result << ["Create new branch '#{new_branch_name}'", { action: :create_branch, name: new_branch_name }]

      result
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

      branch_commands.each do |label, cmd|
        lines << [cmd == @pending_branch_command ? 1 : 0,
                  label,
                  @pending_branch_command ? nil : cmd]
      end

      if @pending_branch_command
        lines << [0, ""]
        lines << [2, "Project dirs:"]
        Config.project_dirs.each do |d|
          lines << [0, d, { action: :project_dir_selected, dir: d }]
        end
      end

      lines
    end

    def first_selectable_line(lines)
      lines.find_index { |_col, _text, command| !!command }
    end
  end
end
