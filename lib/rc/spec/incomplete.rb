require 'rc/spec'

module Rc
  class Spec::Incomplete < Spec
    def complete?
      false
    end
    
    def glob?
      raise "Incomplete specs must implement glob?"
    end
    
    def expand(path, map = nil)
      raise "Incomplete specs must implement expand"
    end
  end
end