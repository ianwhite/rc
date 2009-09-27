module Rc
  class Spec::Polymorphic < Spec::Incomplete
    def singleton?
      @singleton
    end
    
    def glob?
      false
    end
    
    def expand(path, map = nil)
      Spec.from_path!(path.dup, map, :singleton => singleton?, :as => name)
    end
    
    def to_s
      "/?#{"/:?_id" unless singleton?}"
    end
    
    def regexp
      "/[^/]+#{"/[^/]+" unless singleton?}"
    end
    
    def inspect
      "#<#{self.class.name}: #{to_s}#{" {as:#{name}}" if name}>"
    end
  
  protected
    def initialize_attrs(options)
      @singleton = options[:singleton] ? true : false
    end
    
    def equality_attr_names
      super + [:singleton?]
    end
  end
end