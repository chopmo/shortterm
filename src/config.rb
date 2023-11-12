require 'json'

class Config
  def self.projects
    JSON.parse(File.read("config/projects.json"), object_class: OpenStruct)
  end
end
