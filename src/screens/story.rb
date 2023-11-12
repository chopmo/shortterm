require_relative "base"
require_relative "../config"

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
          lines[@selected_line][2]&.call
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
        label = "[#{get_repository(b).name}] #{b.name}"
        command = Proc.new do
          Curses.close_screen
          project = get_project(b)
          Git.with_current_dir(project.path) do
            Git.switch_to_branch(b.name)
          end
          puts "Press any key..."
          @win.getch
        end
        lines << [0, label, command]
      end

      new_branch_name = Git.branch_name(@story)
      Config.projects.each do |p|
        existing_branch = @story.branches.find { |b|
          get_repository(b).name == p.repository && b.name == new_branch_name
        }

        if existing_branch
          next
        end

        label = "Create new branch [#{p.repository}] #{new_branch_name}"
        command = Proc.new do
          Curses.close_screen
          Git.with_current_dir(p.path) do
            Git.create_branch(new_branch_name)
          end
          puts "Press any key..."
          @win.getch
        end
        lines << [0, label, command]
      end

      lines
    end

    def first_selectable_line(lines)
      lines.find_index { |_col, _text, command| !!command }
    end
  end
end
