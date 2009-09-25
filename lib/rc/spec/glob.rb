module Rc
  class Spec
    class Glob < Spec
      def initialize(*args)
      end
      
      def glob?
        true
      end
      
      def complete?
        false
      end
      
      def to_s
        "/*"
      end
      
      # given segments, an optional map, and optional remaining specs, returns an array of complete specs
      def expand(segments, map = nil, remaining_specs = nil)
        
        if remaining_specs
          if next_complete_spec = remaining_specs.find(&:complete?)
            # find segment to glob to
            unless glob_to = segments.index(next_complete_spec.segment)
              raise MismatchError, "Could not find #{next_complete_spec} after #{self} in '#{segments.join('/')}'"
            end
            next_complete_spec_idx = remaining_specs.index(next_complete_spec)
            incomplete_specs = next_complete_spec_idx > 0 ? remaining_specs[0..next_complete_spec_idx-1] : []
          else
            glob_to = segments.length
            incomplete_specs = remaining_specs
          end
          
          # reverse back for any incomple specs
          incomplete_specs.each {|s| glob_to -= s.singleton? ? 1 : 2 }
          
          segments = glob_to > 0 ? segments[0..glob_to-1] : []
        end
        
        expanded = []
        
        while segments.any? do
          expanded << Spec.from_segments!(segments, nil, map)
        end
        
        expanded
      end
    end
  end
end