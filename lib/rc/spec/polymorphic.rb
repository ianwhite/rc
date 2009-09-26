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
      
      def expand(path, map = nil)
        Spec.from_path!(path.dup, map, :singleton => singleton?, :as => as)
      end
      
      def to_s
        "/[^/]+#{"/[^/]+" unless singleton?}"
      end
      
      def inspect
        "#<#{self.class.name}: #{to_s}#{" {as:#{as}}" if as}>"
      end
    
    protected
      def equality_attrs
        [singleton?, as]
      end
    end
  end
end