module Rc
  # This class holds the info that is required to identify a resource based on path segments
  class Spec
    class MismatchError < RuntimeError; end
    
    class << self
      # convert the arg to a spec, or if it is one, return it
      def to_spec(arg)
        case arg
        when Spec then arg
        when Hash then new(arg[:name], arg.except(:name))
        when String, Symbol then new(arg)
        else raise ArgumentError, "can't figure out how to trun #{arg} into a #{name}"
        end
      end

      # factory that creates a different kind of spec based on args
      def new(name = nil, options = {}, &block)
        if self == Spec
          name = name.to_s
          if name == '*'
            Glob.new
          elsif options.delete(:polymorphic) || name[0..0] == '?'
            Polymorphic.new(name.sub(/^\?/,''), options, &block)
          elsif options.delete(:singleton)
            Singleton.new(name, options, &block)
          else
            Keyed.new(name, options, &block)
          end
        else
          super
        end
      end
      
      # creates a single spec from the head of a segments array, and consumes the segment(s).
      # If singleton is not set, autodetect based on next segment
      # If a map is passed, then use any specs that match
      def from_segments!(segments, singleton = nil, map = nil)
        segment = segments.shift
        
        # use mapped spec if it can be found
        spec = map ? map.for_segment(segment, singleton) : nil
        
        # otherwise create a spec using the segment
        unless spec
          singleton.nil? && singleton = (segments[0] !~ /^\d/)
          segment = segment.singularize unless singleton
          spec = new segment, :singleton => singleton
        end
        
        segments.shift unless spec.singleton? # swallow key segment
        
        spec
      end
    end
    
    def inspect
      "#<#{self.class.name}: #{to_s}>"
    end
    
    def ==(other)
      self.class == other.class && self.equality_attrs == other.equality_attrs
    end
    
    def complete?
      true
    end
    
    def incomplete?
      !complete?
    end
    
    def glob?
      false
    end
    
    # consumes matching segments and returns self, raises MismatchError on a false result
    def match!(segments)
      raise "match!(segments) must be implemented in sublcass"
    end
    
  protected
    # return an ordered array of attribuets meaningful for equality
    def equality_attrs
      raise "implement me to enable equality checks"
    end
  end
end
