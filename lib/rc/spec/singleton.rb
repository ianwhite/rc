module Rc
  class Spec
    class Singleton < Spec
      attr_accessor :name, :segment, :as

      def initialize(name, options = {}, &block)
        raise ArgumentError, "requires a name" unless name.present?
        @name = name.to_s
        @as = options[:as].to_s if options[:as]
        @segment = options[:segment].to_s if options[:segment]
      end
    
      def to_s
        "/#{segment}"
      end
      
      def inspect
        "#<#{self.class.name}: name: #{name}#{", as: #{as}" if as} #{to_s}>"
      end
      
      def singleton?
        true
      end
      
      # consume the first element of given segments, and returns self if it matches this spec
      # raise MismatchError if no match.
      def match!(segments)
        if segment == segments.first
          segments.shift
          self
        else
          raise MismatchError, "#{segments.first} in '#{segments.join('/')}' doesn't match #{self.inspect}"
        end
      end
      
      def segment
        @segment ||= name
      end
    
    protected
      def equality_attrs
        [name, segment, as]
      end
    end
  end
end