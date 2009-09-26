module Rc
  class Spec
    class Polymorphic < Spec
      attr_reader :as
      
      def initialize(as = nil, options = {}, &block)
        options.assert_valid_keys(:singleton, :find)
        @as = as.to_s if as.present?
        @singleton = options[:singleton] ? true : false
      end
      
      def singleton?
        @singleton
      end
      
      def incomplete?
        true
      end
      
      def expand(segments, map = nil)
        Spec.from_segments!([segments.first], singleton?, map).tap do |spec|
          spec.as = as if as
        end
      end
      
      def to_s
        "/?#{"/:?_id" unless singleton?}"
      end
      
      def inspect
        "#<#{self.class.name}: #{"as:'#{as}', " if as}#{to_s}>"
      end
    
    protected
      def equality_attrs
        [singleton?, as]
      end
    end
  end
end