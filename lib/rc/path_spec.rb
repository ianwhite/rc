module Rc
  # Ordered collection of specs, which is used to specify a resource path
  class PathSpec
    include Enumerable
    
    attr_reader :specs
    
    def initialize(*args)
      @specs = []
      args.each {|a| self << a}
    end
    
    def each(&block)
      @specs.each(&block)
    end
    
    def to_a
      @specs
    end
    
    def <<(spec)
      spec = Spec.to_spec(spec)
      raise ArgumentError, "adding #{spec} will make this path spec indeterminate" unless determinate_with?(spec)
      specs << spec
      self
    end
    
    def concat(specs)
      specs.to_a.each {|s| self << s}
      self
    end
    
    def +(specs)
      dup.concat(specs)
    end
    
    def ==(other)
      other.is_a?(self.class) && specs == other.specs
    end
    
    # true if any specs are incomplete
    def incomplete?
      specs.find(&:incomplete?) ? true : false
    end
    
    # return true if the path matches the spec
    def match?(path)
      return false if incomplete?
      segments = path_to_segments(path)
      specs.each {|spec| spec.match!(segments)}
      segments.empty?
    rescue Spec::MismatchError
      false
    end
    
    # Expand an incomplete pathspec, given a path, and optional spec map.
    # Returns a completed path, or raises Spec::MismatchError
    def expand!(path, map = nil)
      return self unless incomplete?
      segments = path_to_segments(path)
      expanded = PathSpec.new
      specs.each_with_index do |spec, idx|
        if spec.glob?
          glob_specs = spec.expand(segments, map, specs[idx+1..-1])
          glob_specs.each {|spec| expanded << spec.match!(segments)}
        else
          spec = spec.expand(segments, map) if spec.incomplete?
          expanded << spec.match!(segments)
        end
      end
      segments.empty? or raise Spec::MismatchError, "left over segments #{segments}"
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
        @specs.reverse.each do |spec|
          return false if spec.is_a?(Spec::Glob)
          return true if !spec.incomplete?
        end
      end
      true
    end
    
    def to_s
      @specs.join
    end
    
    def inspect
      "#<#{self.class.name}: #{to_s}>"
    end

  protected
    def path_to_segments(path)
      path[1..-1].split('/')
    end
  end
end