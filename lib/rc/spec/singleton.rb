require 'rc/spec/complete'

module Rc
  class Spec::Singleton < Spec::Complete
    attr_reader :segment, :as
    
    def to_s
      "/#{segment}"
    end
    
    def regexp
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
    def initialize_attrs(options)
      super(options)
      @as = options[:as].to_s if options[:as]
      @segment = options[:segment].to_s if options[:segment]
    end

    def equality_attr_names
      super + [:singleton?, :segment, :as]
    end
  end
end