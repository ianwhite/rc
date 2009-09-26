module Rc
  # This class holds the info that is required to identify a resource based on path segments.
  # Instantiated by sublcasses
  class Spec
    class MismatchError < RuntimeError; end
    
    class << self
      # convert the arg to a spec, or if it is one, return it
      def to_spec(arg)
        case arg
        when Spec then arg
        when Hash then new(arg[:name], arg.except(:name))
        when String, Symbol then new(arg)
        else raise ArgumentError, "can't figure out how to turn #{arg.inspect} into a #{name}"
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
          elsif options.delete(:singleton) || name[0..0] == '!'
            Singleton.new(name.sub(/^\!/,''), options, &block)
          else
            Keyed.new(name, options, &block)
          end
        else
          super
        end
      end
      
      # creates a single spec from the head of a path, and consumes the segment(s).
      # If a map is passed, the any mapped spec matching the head of the path is returned
      #
      # Options may be passed that constrain the creation of the spec, for example :singleton
      def from_path!(path, *args)
        options = args.extract_options!
        map = args.first
        _, segment, key = path.match(%r(^/([^/]+)(?:/([^/]+))?)).to_a
        segment.blank? and raise MismatchError, "could not find a segment in '#{path}'"
        
        # use mapped spec if it can be found
        spec = map ? map[segment, options[:singleton]] : nil
        
        # otherwise create a spec using the segment and passed options
        unless spec
          options[:singleton].nil? && options[:singleton] = (key !~ /^\d/)
          name = options[:singleton] ? segment : segment.singularize
          spec = new(name, options.reverse_merge(:segment => segment))
        end
        
        spec.match!(path)
      end
    end
    
    def to_s
      raise "implement to_s to return a Regexp string that would match this segment"
    end
    
    def inspect
      "#<#{self.class.name}: #{to_s}>"
    end
    
    def to_regexp
      %r(^#{to_s})
    end
    
    def ==(other)
      other.is_a?(self.class) && equality_attrs == other.equality_attrs
    end
    
    def incomplete?
      false
    end
    
    def glob?
      false
    end
    
    # consume the first segment(s) of given path, and returns self if it matches this spec
    # raise MismatchError if no match.
    def match!(path)
      if path =~ to_regexp
        path.sub!(to_regexp,'')
        self
      else
        raise MismatchError, "'#{path}' doesn't match #{self.inspect}"
      end
    end
    
  protected
    # return an ordered array of attribuets meaningful for equality
    def equality_attrs
      [incomplete?]
    end
  end
end
