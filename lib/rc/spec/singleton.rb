module Rc
  class Spec
    class Singleton < Spec
      attr_reader :name, :segment, :as

      def initialize(name, options = {}, &block)
        raise ArgumentError, "#{self.class.name}.new requires a name" unless name.present?
        @name = name.to_s
        @as = options[:as].to_s if options[:as]
        @segment = options[:segment].to_s if options[:segment]
      end
    
      def to_s
        "/#{segment}"
      end
      
      def inspect
        "#<#{self.class.name}: #{to_s} {name:#{name}#{",as:#{as}" if as}}>"
      end
      
      def singleton?
        true
      end
      
      def segment
        @segment ||= name
      end
    
    protected
      def equality_attrs
        super + [name, segment, as]
      end
    end
  end
end