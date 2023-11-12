class Repositories
  def initialize(repositories)
    @repositories = {}
    repositories.each do |s|
      @repositories[s.id] = s
    end
  end

  def self.parse(json)
    new(JSON.parse(json, object_class: OpenStruct))
  end

  def find(id)
    @repositories[id]
  end
end
