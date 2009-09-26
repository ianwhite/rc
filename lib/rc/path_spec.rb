module Rc
  # Ordered collection of specs, which is used to specify a resource path
  class PathSpec
    include Enumerable
    
    def initialize(*args)
      self.specs = []
      args.each {|a| self << a}
    end
    
    def each(&block)
      specs.each(&block)
    end
    
    def to_a
      specs.dup
    end
    
    # concat a single spec to the end of the path (calls Spec.to_spec with the argument).
    def <<(spec)
      spec = Spec.to_spec(spec)
      raise ArgumentError, "adding #{spec} will make this path spec indeterminate" unless determinate_with?(spec)
      specs << spec
      self
    end
    
    # conact an array-like of specs, or another path spec to the end of the path.
    def concat(specs)
      specs.is_a?(PathSpec) ? self.specs.concat(specs.specs) : specs.to_a.each {|s| self << s}
      self
    end
    
    # return a new path spec which is the argument concated to this path spec.
    def +(specs)
      dup.concat(specs)
    end
    
    # true if the argument is a path spec, and both have the same specs in order
    def ==(other)
      other.is_a?(self.class) && specs == other.specs
    end
    
    def each(&block)
      specs.each(&block)
    end
    
    # accepts an integer or range argument.  If a range a path spec is returned
    def [](idx)
      result = specs[idx]
      result.is_a?(Array) ? PathSpec.new.tap {|p| p.specs = result} : result
    end
    
    # true if any specs are incomplete
    def incomplete?
      specs.find(&:incomplete?) ? true : false
    end
    
    # loads resources using path, params, and map
    def load(path, params = nil, map = nil)
      
    end
    
    # return true if the path matches the spec
    def match?(path)
      path =~ to_regexp
    end
    
    # Expand an incomplete pathspec, given a path, and optional spec map.
    # Returns a completed path, or raises Spec::MismatchError
    def expand!(path, map = nil)
      return self unless incomplete?
      expanded, path = PathSpec.new, path.dup
      specs.each_with_index do |spec, idx|
        if spec.glob?
          glob_specs = spec.expand(path, map, specs[idx+1..-1])
          glob_specs.each {|spec| expanded << spec.match!(path)}
        else
          spec = spec.expand(path, map) if spec.incomplete?
          expanded << spec.match!(path)
        end
      end
      path.empty? or raise Spec::MismatchError, "left over path #{path}"
      expanded
    end
    
    # Returns a complete path, or false if there is a mismatch
    def expand(path, map = nil)
      expand!(path, map)
    rescue Spec::MismatchError
      false
    end
    
    # A pathspec is determinate if it can be expanded given a path.
    # This means that only one glob may exist between complete specs.
    def determinate_with?(new_spec)
      if new_spec.is_a?(Spec::Glob)
        specs.reverse.each do |spec|
          return false if spec.is_a?(Spec::Glob)
          return true if !spec.incomplete?
        end
      end
      true
    end
    
    def to_s
      specs.join
    end
    
    def regexp
      specs.map(&:regexp).join
    end
    
    def to_regexp
      %r(^#{regexp}$)
    end
    
    def inspect
      "#<#{self.class.name}: #{specs.inspect}>"
    end

  protected
    attr_accessor :specs
    
    def initialize_copy(other)
      other.specs = specs.dup
      super
    end
  end
end