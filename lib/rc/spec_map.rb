module Rc
  # Bag of specs, which can be quickly accessed by name, segment, or key (specs are unique by name).
  class SpecMap
    include Enumerable
    
    def initialize(*args)
      @map, @segment_map, @key_map = (1..3).map { HashWithIndifferentAccess.new }
      args.each {|a| self << a}
    end
    
    def <<(spec)
      spec = Spec.to_spec(spec)
      raise ArgumentError, "spec must not be incomplete" if spec.incomplete?
      
      if old = @map[spec.name]
        @segment_map.delete(old.segment)
        @key_map.delete(old.key) if old.respond_to?(:key)
      end
      
      @key_map[spec.key] = spec if spec.respond_to?(:key)
      @segment_map[spec.segment] = spec
      @map[spec.name] = spec
    end
    
    def concat(specs)
      specs.to_a.each {|s| self << s }
      self
    end
    
    def +(specs)
      dup.concat(specs)
    end
    
    def to_a
      @map.values
    end
    
    def each(&block)
      @map.values.each(&block)
    end
    
    # return spec matching segment.  If singelton supplied, make sure it matches that boolean
    def for_segment(segment, singleton = nil)
      spec = by_segment[segment]
      singleton.nil? ? spec : (spec.singleton? == singleton && spec)
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
      @map.map {|k,v| "#{k}:'#{v}'"}.join(", ")
    end
    
    def inspect
      "#<#{self.class.name}: #{to_s}>"
    end
  end
end