module Rc
  # Collection of resources, together with their specifications
  class Path
    attr_reader :path_spec
    
    def initialize(path_spec, params)
      @path_spec = path_spec
      @params = params
    end
    
    def to_a
      ary = []
      path_spec.each_with_index do |spec, index|
        ary << spec.singleton? ? spec.name.to_sym : resources[index]
      end
    end
    
    def resources
      unless @resources
        @resources = []
        path_spec.each {|spec| @resources << spec.load(@params, @resources.last) }
      end
      @resources
    end
  end
end