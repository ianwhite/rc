require 'rc/spec'

module Rc
  class Spec::Complete < Spec
    def initialize(name, options = {}, &block)
      raise ArgumentError, "name is required for a #{self.class.name}" if name.blank?
      options[:load] ||= block
      super
    end
    
    def singleton?
      raise "Complete specs must implement singleton?"
    end
    
    def complete?
      true
    end

    def load(params = {}, parent = nil, exec = nil)
      if @load
        case @load
        when Symbol, String
          raise "Execution context required if :load is a symbol or string" unless exec
          exec.send(@load)
        when Proc
          case @load.arity
          when 0 then exec ? exec.instance_eval(&@load) : @load.call
          when 1 then exec ? exec.instance_exec(params, &@load) : @load.call(params)
          else exec ? exec.instance_exec(params, parent, &@load) : @load.call(params, parent)
          end
        end
      else
        find(params, parent)
      end
    end
      
  protected
    def initialize_attrs(options)
      if @load = options[:load]
        raise ArgumentError, ":load should be either a lambda, or a symbol" unless [Proc, String, Symbol].find{|c| @load.is_a?(c)}
      end
    end
  end
end