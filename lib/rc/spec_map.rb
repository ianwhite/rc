module Rc
  # Bag of specs, which can be quickly accessed by name, or segment.
  class SpecMap
    include Enumerable
    
    # create a spec map containing keyed resources corresponding to param keys
    def self.from_params(params)
      map = new
      params.keys.each {|k| map << k.to_s[0..-4] if k.to_s[-3..-1] == '_id'}
      map
    end
    
    def initialize(*args)
      @map, @segment_map = {}, {}
      args.each {|a| self << a}
    end
    
    def <<(spec)
      spec = Spec.to_spec(spec)
      raise ArgumentError, "spec must not be incomplete" if spec.incomplete?
      @segment_map.delete(@map[spec.name].segment) if @map[spec.name]
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
    
    # return a new spec map with specs corresponding to the passed params
    # existing specs take priority over the params
    def with_params(params)
      SpecMap.from_params(params) + self
    end
    
    def to_a
      @map.values
    end
    
    def each(&block)
      @map.values.each(&block)
    end
    
    def [](name)
      @map[name.to_s]
    end
        
    # return spec matching segment.  If singelton supplied, make sure it matches that boolean
    def for_segment(segment, singleton = nil)
      spec = @segment_map[segment.to_s]
      singleton.nil? ? spec : (spec.singleton? == singleton && spec)
    end
    
    def to_s
      "{" + @map.map {|k,v| "#{k} => #{v}"}.join(", ") + "}"
    end
    
    def inspect
      "#<#{self.class.name}: #{to_s}>"
    end
  end
end