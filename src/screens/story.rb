require_relative "base"

module Screens
  class Story < Base
    def initialize(story, workflow_states)
      super()
      @story = story
      @workflow_states = workflow_states
    end

    def run
      loop do
        set_current_line(0)
        render_lines(get_summary_lines(@story))
        @win.refresh
        str = @win.getch.to_s
        case str
        when '10'
          return { action: :start_or_switch_to_story, id: @story.id }
        when 'q'
          return { action: :open_epic, id: @story.epic_id }
        end
      end
    end

    def get_summary_lines(story)
      lines = []
      lines << [2, story.name]
      lines << [0, "URL: #{story.app_url}"]
      lines << [3, "State: #{get_state(story)}"]
      lines << [0, ""]
      lines << [0, story.description]
      lines
    end

    def get_state(story)
      @workflow_states.find(story.workflow_state_id).name
    end
  end
end
