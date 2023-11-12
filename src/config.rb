require 'json'

class Config
  def self.project_dirs
    JSON.parse(File.read("config/project_dirs.json"))
  end
end
