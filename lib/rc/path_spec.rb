module Rc
  # collection of specs, which can be used to determine a resource_service, etc
  class PathSpec < Array
    # element methods need to convert the incoming to a Spec
    [:<<, :push, :unshift].each do |method|
      eval <<-RUBY
        def #{method}(arg)
          super Spec.to_spec(arg)
        end
      RUBY
    end
    
    # collection methods need to convert the incoming array to array of Specs
    [:+, :replace].each do |method|
      eval <<-RUBY
        def #{method}(arg)
          super arg.map{|e| Spec.to_spec(e)}
        end
      RUBY
    end
    
    def to_s
      join
    end
    
    def inspect
      "#<#{self.class.name}: #{to_s}>"
    end
    
    # return the first spec with the given key
    def with_key(key)
      key = key.to_s
      find {|s| s.key == key}
    end
  end
end