module Rc
  class Spec
    class Keyed < Singleton
      def singleton?
        false
      end
      
      def segment
        @segment ||= name.pluralize
      end
      
      def key
        @key ||= segment.singularize.foreign_key
      end
    
      def to_s
        "/#{segment}/[^/]+"
      end
      
      def inspect
        "#<#{self.class.name}: #{to_s} {name:#{name},key:#{key}#{",as:#{as}" if as}}>"
      end
    
    protected
      def equality_attrs
        [name, segment, key, as]
      end
    end
  end
end