module Rc
  class Spec
    class Keyed < Singleton
      def to_s
        "#{super}/:#{key}"
      end
      
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
      
    private
      def initialize_attrs(options)
        @segment = (options[:segment] || name.pluralize).to_s
        @source = (options[:source] || name.pluralize).to_s
        @class_name = options[:class_name] || source.classify
        @key = (options[:key] || source.singularize.foreign_key).to_s
      end
    end
  end
end