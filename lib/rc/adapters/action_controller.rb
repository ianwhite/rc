require 'rc'

module Rc
  module Adapters
    module ActionController
      def self.included(base)
        base.class_eval do
          extend ClassMethods
        end
      end
      
      module ClassMethods
        def resource_map
          @resource_map ||= (superclass.resource_map.dup rescue nil) || Rc.resource_map
        end
        
        def path_spec
          @path_spec ||= Rc.path_spec
        end
      end
      
    protected
      def load_parent_resources
        if self.class.path_spec.complete?
          @parent_spec = self.class.path_spec[0..-2]
        else
          @parent_spec
        end
          
        @parent_path_spec = path_spec[0..-2].expand!(request.path, resource_map.with_params(params)
      end
    end
  end
end