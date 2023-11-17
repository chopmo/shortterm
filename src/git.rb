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
    if !working_tree_clean?
      puts "The working tree is not clean."
      return false
    end

    `git co -q main`
    `git pull -q`
    `git fetch -q`
    `git co #{branch_name}`
    true
  end

  def self.create_branch(branch_name)
    if !working_tree_clean?
      puts "The working tree is not clean."
      return false
    end

    `git co -q main`
    `git pull -q`
    `git co -b #{branch_name}`
    `git push -u`
    true
  end

  def self.with_current_dir(dir)
    old_dir = Dir.getwd
    Dir.chdir(dir)
    yield
  ensure
    Dir.chdir(old_dir)
  end
end
