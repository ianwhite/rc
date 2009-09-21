module Rc
  # collection of specs, which can be used to determine a resource_service, etc
  class PathSpec < Array
    def initialize(*args)
      replace args
    end
    
    # element setter methods need to convert the incoming element to a Spec
    [:<<, :push, :unshift, :[]=].each do |method|
      eval <<-RUBY
        def #{method}(arg)
          super Spec.to_spec(arg)
        end
      RUBY
    end
    
    # collection setter methods need to convert the incoming array to array of Specs
    [:+, :replace, :concat].each do |method|
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
    def spec_with_key(key)
      find {|s| s.respond_to?(:key) && s.key == key.to_s}
    end
    
    # return the first spec with the given segment
    def spec_with_segment(segment)
      find {|s| s.respond_to?(:segment) && s.segment == segment.to_s}
    end
    
    # true if any specs are incomplete
    def incomplete?
      find(&:incomplete?) ? true : false
    end
  end
end