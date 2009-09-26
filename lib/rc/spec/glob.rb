module Rc
  class Spec
    class Glob < Spec
      def initialize(*args)
      end
      
      def glob?
        true
      end
      
      def incomplete?
        true
      end
      
      def to_s
        "/*"
      end
      
      # given segments, an optional map, and optional remaining specs, returns an array of complete specs
      def expand(segments, map = nil, remaining_specs = nil)
        segments = unmatching_segments(segments, remaining_specs) if remaining_specs
        
        expanded = []
        while segments.any? do
          expanded << Spec.from_segments!(segments, nil, map)
        end
        expanded
      end
      
    protected
      def equality_attrs
        []
      end
      
    private
      # given segments and specs, return the segments up to the point where the specs start to match
      def unmatching_segments(segments, specs)
        if complete_spec = specs.find {|s| !s.incomplete?}
          complete_idx = specs.index(complete_spec)
          
          unless unmatching_length = segments.index(complete_spec.segment)
            raise MismatchError, "Could not find #{complete_spec} after #{self} in '#{segments.join('/')}'"
          end
          incomplete_specs = complete_idx > 0 ? specs[0..complete_idx-1] : []
        else
          unmatching_length = segments.length
          incomplete_specs = specs
        end
        
        # reverse back for any incomple specs
        incomplete_specs.each {|s| unmatching_length -= s.singleton? ? 1 : 2 }
        
        unmatching_length > 0 ? segments[0..unmatching_length-1] : []
      end
    end
  end
end