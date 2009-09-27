require 'rc/spec/singleton'

module Rc
  class Spec::Keyed < Spec::Singleton
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
      "/#{segment}/:#{key}"
    end

    def regexp
      "/#{segment}/[^/]+"
    end
    
  protected
    def initialize_attrs(options)
      super
      @key = options[:key].to_s if options[:key]
    end
      
    def equality_attr_names
      super + [:key]
    end
  end
end