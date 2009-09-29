module Rc
  module Adapters
    module ActiveRecord
      # add options for class and source
      module Spec
        module Singleton
          def source
            @source ||= name
          end
      
          def class_name
            @class_name ||= source.classify
          end
      
          def klass
            @klass ||= class_name.constantize
          end
        
          def find(params = nil, parent = nil)
            parent ? parent.send(source) : klass.first
          end

        protected
          def initialize_attrs(options)
            @source = options[:source] if options[:source]
            @class_name = options[:class_name] if options[:class_name]
          end
      
          def equality_attr_names
            super + [:source, :class_name]
          end
        end
      
        module Keyed
          def source
            @source ||= name.pluralize
          end
        
          def find(params, parent = nil)
            parent ? parent.send(source).find(params[key]) : klass.find(params[key])
          end
        end
      end
    end
  end
end