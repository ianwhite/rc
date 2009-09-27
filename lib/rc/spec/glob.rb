require 'rc/spec/incomplete'

module Rc
  class Spec::Glob < Spec::Incomplete
    def initialize(*args)
    end
    
    def glob?
      true
    end
    
    def to_s
      "/*"
    end
    
    def regexp
      "(/[^/]+)*"
    end
    
    # given segments, an optional map, and optional remaining specs, returns an array of complete specs
    def expand(path, map = nil, remaining_specs = nil)
      path = unmatched_path(path, remaining_specs) if remaining_specs
      expanded = []
      while path.any? do
        expanded << Spec.from_path!(path, map)
      end
      expanded
    end
    
  protected
    def equality_attr_names
      super + [:glob?]
    end
    
  private
    # given path and specs, return the path up to the point where the specs start to match
    def unmatched_path(path, specs)
      segments = path[1..-1].split('/')
      
      if complete_spec = specs.find(&:complete?)
        complete_idx = specs.index(complete_spec)
        
        unless unmatched_length = segments.index(complete_spec.segment)
          raise MismatchError, "Could not find #{complete_spec} after #{self} in '#{segments.join('/')}'"
        end
        incomplete_specs = complete_idx > 0 ? specs[0..complete_idx-1] : []
      else
        unmatched_length = segments.length
        incomplete_specs = specs
      end
      
      # reverse back for any incomple specs
      incomplete_specs.each {|s| unmatched_length -= s.singleton? ? 1 : 2 }
      
      unmatched_length > 0 ? "/" + segments[0..unmatched_length-1].join('/') : ''
    end
  end
end