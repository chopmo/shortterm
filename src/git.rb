require 'io/console'

class Git
  def self.branch_name(story)
    username = ENV["USER"]
    safe_name = story.name.gsub(/[^a-zA-Z0-9 -]/, '')[0..40].split(/ /).join("-").downcase
    "#{username}/sc-#{story.id}/#{safe_name}"
  end

  def self.working_tree_clean?
    system("git diff --exit-code > /dev/null") &&
      system("git diff --cached --exit-code > /dev/null")
  end

  def self.start_or_switch_to_story(story)
    if !working_tree_clean?
      puts "The working tree is not clean."
      wait_for_key
      return false
    end

    if story.branches.empty?
      branch = branch_name(story)
      `git co main`
      `git pull`
      `git co -b #{branch}`
      `git push -u`
      puts "Done. Created and pushed new branch #{branch}"
      return true
    elsif story.branches.size == 1
      branch = story.branches[0].name
      `git co main`
      `git pull`
      `git fetch`
      `git co #{branch}`
      puts "Done. Switched to existing branch #{branch}"
      return true
    else
      puts "The story already has branches."
      wait_for_key
      return false
    end
  end

  def self.wait_for_key
    puts "Press any key..."
    STDIN.getch
  end
end
