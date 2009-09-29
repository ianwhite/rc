require 'rc/spec/singleton'
require 'rc/spec/keyed'
require 'rc/spec/glob'
require 'rc/spec/polymorphic'
require 'rc/path_spec'
require 'rc/spec_map'
require 'rc/path'

module Rc
  class << self
    def path_spec(*args)
      PathSpec.new(*args)
    end
    
    def spec(arg, opts = {}, &block)
      Spec.to_spec(arg, opts, &block)
    end
    
    def spec_map(*args)
      SpecMap.new(*args)
    end
    
    def key_params(params)
      keys = HashWithIndifferentAccess.new
      params.each {|k,v| keys[k.to_s] = v if k.to_s[-3..-1] == '_id'}
      keys
    end
  end
end