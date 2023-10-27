class WorkflowStates
  def initialize(states)
    @states = {}
    states.each do |s|
      @states[s.id] = s
    end
  end

  def self.parse(json)
    new(JSON.parse(json, object_class: OpenStruct)[0].states)
  end

  def find(id)
    @states[id]
  end
end
