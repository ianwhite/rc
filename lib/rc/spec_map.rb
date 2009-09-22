module Rc
  class SpecMap
    def initialize(*args)
      @map, @segment_map, @key_map = (1..3).map { HashWithIndifferentAccess.new }
      args.each {|a| store(a)}
    end
    
    def store(spec)
      spec = Spec.to_spec(spec)
      raise ArgumentError, "spec must not be incomplete (ie '*' or '?')" if spec.incomplete?
      if old = @map[spec.name]
        @segment_map.delete(old.segment)
        @key_map.delete(old.key)
      end
      @map[spec.name] = spec
      @segment_map[spec.segment] = spec
      @key_map[spec.key] = spec
    end
    
    def [](name)
      @map[name]
    end
    
    def by_name
      @map
    end
    
    def by_key
      @key_map
    end
    
    def by_segment
      @segment_map
    end
    
    def to_s
      @map.map {|k,v| "#{k}: '#{v}'"}.join(",")
    end
    
    def inspect
      "#<#{self.class.name}: #{to_s}>"
    end
  end
end