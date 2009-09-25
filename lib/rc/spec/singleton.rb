module Rc
  class Spec
    class Singleton < Spec
      attr_reader :name, :find, :source, :class_name, :name_prefix, :segment, :key
      attr_accessor :as

      def initialize(name, options = {}, &block)
        raise ArgumentError, "requires a name" unless name.present?
        options.assert_valid_keys(:find, :as, :class_name, :source, :find, :name_prefix, :segment, :key)
        @name = name.to_s
        @find = block || options[:find]
        @as = options[:as] && options[:as].to_s 
        @name_prefix = options[:name_prefix] || (options[:name_prefix] == false ? '' : "#{name}_")
        initialize_attrs(options)
      end
    
      def to_s
        "/#{segment}#{"(as => #{as})" if as}"
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
        
    private
      def initialize_attrs(options)
        @segment = (options[:segment] || name).to_s
        @source = (options[:source] || name).to_s
        @class_name = options[:class_name] || source.singularize.classify
      end
    end
  end
end