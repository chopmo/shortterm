require_relative 'screens/epics'
require_relative 'screens/epic'
require_relative 'api_client'
require_relative 'workflow_states'
require 'curses'

class Runner
  def load_initial_data
    workflow_cache = "tmp/workflows.json"
    if File.exists?(workflow_cache)
      puts "Using cached workflows"
      @workflow_states = WorkflowStates.parse(File.read(workflow_cache))
    else
      puts "Loading workflows..."
      json = ApiClient.get_workflows
      @workflow_states = WorkflowStates.parse(json)
      File.write(workflow_cache, json)
    end

    epics_cache = "tmp/epics.json"
    if File.exists?(epics_cache)
      puts "Using cached epics"
      json = File.read(epics_cache)
    else
      puts "Loading epics..."
      json = ApiClient.get_epics
      File.write(epics_cache, json)
    end
    @epics = JSON.parse(json, object_class: OpenStruct).select(&:started).reject(&:completed).sort_by(&:name)
  end

  def open_epic(id)
    json = ApiClient.get_stories(id)
    stories = JSON.parse(json, object_class: OpenStruct).
                reject(&:completed).
                reject(&:archived)
    Screens::Epic.new(stories, @workflow_states)
  end

  def branch_name(story)
    story_part = story.name.gsub(/[^a-zA-Z0-9 -]/, '')[0..40].split(/ /).join("-").downcase
    "chopmo/sc-#{story.id}/#{story_part}"
  end

  def start_or_switch_to_story(id)
    Curses.close_screen
    story = JSON.parse(ApiClient.get_story(id), object_class: OpenStruct)

    if story.branches.empty?
      branch = branch_name(story)
      `git co main`
      `git pull`
      `git co -b #{branch}`
      `git push -u`
      puts "Done. Created and pushed new branch #{branch}"
      true
    else
      false
    end
  end

  def loop
    epics_screen = Screens::Epics.new(@epics)
    screen = epics_screen
    while true
      command = screen.run
      case command[:action]
      when :open_epic
        screen = open_epic(command[:id])
      when :open_epics
        screen = epics_screen
      when :start_or_switch_to_story
        if start_or_switch_to_story(command[:id])
          exit 0
        end
      when :quit
        Curses.close_screen
        exit 0
      end
    end
  end
end
