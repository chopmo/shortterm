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
    with_current_dir(ARGV[0]) do
      if !working_tree_clean?
        puts "The working tree is not clean."
      elsif story.branches.empty?
        branch = branch_name(story)
        `git co main`
        `git pull`
        `git co -b #{branch}`
        `git push -u`
        puts "Done. Created and pushed new branch #{branch}"
      elsif story.branches.size == 1
        branch = story.branches[0].name
        `git co main`
        `git pull`
        `git fetch`
        `git co #{branch}`
        puts "Done. Switched to existing branch #{branch}"
      else
        puts "The story already has branches."
      end
      puts "Press any key..."
      STDIN.getch
    end
  end

  def self.with_current_dir(dir)
    old_dir = Dir.getwd
    Dir.chdir(dir)
    yield
  rescue
    Dir.chdir(old_dir)
  end
end
