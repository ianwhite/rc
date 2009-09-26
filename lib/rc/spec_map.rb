module Rc
  # Bag of specs, accessed by segment
  class SpecMap
    include Enumerable
    
    # create a spec map containing keyed resources corresponding to param keys
    def self.from_params(params)
      new.tap do |map|
        params.keys.each do |k|
          map << k.to_s[0..-4] if k.to_s[-3..-1] == '_id'
        end
      end
    end
    
    def initialize(*args)
      self.map = {}
      args.each {|a| self << a}
    end
    
    def <<(spec)
      spec = Spec.to_spec(spec)
      raise ArgumentError, "spec must be complete" unless spec.complete?
      map[spec.segment] = spec
      self
    end
    
    def concat(specs)
      specs.is_a?(SpecMap) ? map.merge!(specs.map) : specs.to_a.each {|s| self << s}
      self
    end
    
    def +(specs)
      dup.concat(specs)
    end
    
    # return a new spec map with specs corresponding to the passed params
    # existing specs take priority over the params
    def with_params(params)
      SpecMap.from_params(params).concat(self)
    end
    
    def ==(other)
      self.class == other.class && map == other.map
    end
    
    def to_a
      map.values
    end
    
    def each(&block)
      to_a.each(&block)
    end
    
    def [](segment, singleton = nil)
      if spec = map[segment.to_s]
        singleton.nil? ? spec : (spec.singleton? == singleton && spec)
      end
    end
        
    # return spec matching name
    def named(name)
      to_a.find {|s| s.name == name.to_s}
    end
    
    def to_s
      "{#{to_a.join(", ")}}"
    end
    
    def inspect
      "#<#{self.class.name}: #{to_a.inspect}>"
    end
  
  protected
    attr_accessor :map
    
    def initialize_copy(other)
      other.map = map.dup
      super
    end
  end
end