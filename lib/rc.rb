require 'rc/spec'
require 'rc/spec/singleton'
require 'rc/spec/keyed'
require 'rc/spec/glob'
require 'rc/spec/polymorphic'
require 'rc/path_spec'
require 'rc/spec_map'

module Rc
  class << self
    def path_spec(*args)
      PathSpec.new(*args)
    end
    
    def spec(arg)
      Spec.to_spec(arg)
    end
  end
end