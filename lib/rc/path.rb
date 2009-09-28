module Rc
  # Collection of resources, together with their specifications
  class Path
    attr_reader :path_spec, :exec
    
    def initialize(path_spec, params, exec = nil)
      self.path_spec = path_spec
      self.params = Rc.key_params(params)
      self.exec = exec
    end
    
    # return array suitable for polymorphic_url
    def member
      ary = []
      path_spec.each_with_index {|spec, i| ary << (spec.singleton? ? spec.segment.to_sym : resources[i])}
      ary
    end
    
    # return array suitable for polymorphic_url
    def collection
      up.member << path_spec[-1].segment.to_sym
    end
    
    def resource
      @resources.compact.last
    end
    
    def up
      self[0..-2]
    end
    
    def resources
      unless @resources
        @resources = []
        path_spec.each {|spec| @resources << spec.load(params, resource, exec) }
      end
      @resources
    end
    
    def [](range)
      range = [0..range] if range.is_a?(Numeric)
      dup.tap do |path|
        path.path_spec = path.path_spec[range]
        path.resources = path.resources[range]
      end
    end
  
  protected
    attr_reader :params
    attr_writer :path_spec, :resources, :params, :exec
  
    def initialize_copy(other)
      other.params = params
      other.exec = exec
      other.path_spec = path_spec.dup
      other.resources = resources.dup
    end
  end
end