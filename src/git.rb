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

  def self.switch_to_branch(branch_name)
    with_current_dir(ARGV[0]) do
      if !working_tree_clean?
        puts "The working tree is not clean."
        return
      end

      `git co main`
      `git pull`
      `git fetch`
      `git co #{branch_name}`
    end
  end

  def self.create_branch(branch_name)
    with_current_dir(ARGV[0]) do
      if !working_tree_clean?
        puts "The working tree is not clean."
        return
      end

      `git co main`
      `git pull`
      `git co -b #{branch_name}`
      `git push -u`
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
