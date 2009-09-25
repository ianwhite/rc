module Rc
  class Spec
    class Keyed < Singleton
      def singleton?
        false
      end
      
      def match!(segments)
        if segment == segments[0] && segments[1]
          segments.shift
          segments.shift
          self
        else
          raise MismatchError, "#{segments.first}/#{segments.second} in '#{segments.join('/')}' doesn't match #{self.inspect}"
        end
      end
      
      def segment
        @segment ||= name.pluralize
      end
      
      def key
        @key ||= segment.singularize.foreign_key
      end
    
      def to_s
        "/#{segment}/:#{key}"
      end
    
    
    protected
      def equality_attrs
        [name, segment, key, as]
      end
    end
  end
end