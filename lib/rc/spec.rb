module Rc
  # This class holds all the info that is required to identify a resource, or determine a name prefix, based on a route segment
  # or segment pair (e.g. /blog or /users/3).
  class Spec
    class << self
      # convert the arg to a spec, or if it is one, return it
      def to_spec(arg)
        if arg.is_a?(self)
          arg
        elsif arg.is_a?(Hash)
          new arg[:name], arg.except(:name)
        elsif arg.is_a?(String) || arg.is_a?(Symbol)
          new arg
        else
          raise ArgumentError, "can't figure out how to trun #{arg} into a #{name}"
        end
      end

      # factory that creates a different kind of spec based on args
      def new(name = nil, options = {}, &block)
        if self == Spec
          name = name.to_s
          if name == '*'
            Glob.new
          elsif options.delete(:polymorphic) || name[0..0] == '?'
            Polymorphic.new(name.sub(/^\?/,''), options, &block)
          elsif options.delete(:singleton)
            Resource.new(name, options, &block)
          else
            Resources.new(name, options, &block)
          end
        else
          super
        end
      end
    end
    
    def inspect
      "#<#{self.class.name}: #{to_s}>"
    end
    
    def ==(other)
      self.class == other.class && self.ivars == other.ivars
    end
      
  protected
    def ivars
      instance_variables.map{|i| instance_variable_get(i)}
    end
    
    def incomplete?
      true
    end
    
    class Glob < Spec
      def initialize(*args)
      end
      
      def to_s
        "/*"
      end
    end
    
    class Polymorphic < Spec
      attr_reader :as, :find
      
      def initialize(as = nil, options = {}, &block)
        options.assert_valid_keys(:singleton, :find)
        @as = as if as.present?
        @find = block || options[:find]
        @singleton = options[:singleton] ? true : false
      end
      
      def singleton?
        @singleton
      end
      
      def to_s
        "/?#{"(as => #{as})" if as}#{"/:?_id" unless singleton?}"
      end
    end
    
    class Resource < Spec
      attr_reader :name, :find, :as, :source, :class_name, :name_prefix, :segment, :key

      def initialize(name, options = {}, &block)
        raise ArgumentError, "requires a name" unless name.present?
        options.assert_valid_keys(:find, :as, :class_name, :source, :find, :name_prefix, :segment, :key)
        @name = name.to_s
        @find = block || options[:find]
        @as = options[:as]
        @name_prefix = options[:name_prefix] || (options[:name_prefix] == false ? '' : "#{name}_")
        initialize_attrs(options)
      end
    
      def to_s
        "/#{segment}#{"(as => #{as})" if as}"
      end
      
      def singleton?
        true
      end
      
      def incomplete?
        false
      end
      
    private
      def initialize_attrs(options)
        @segment = (options[:segment] || name).to_s
        @source = (options[:source] || name).to_s
        @class_name = options[:class_name] || source.singularize.classify
      end
    end
    
    class Resources < Resource
      def to_s
        "#{super}/:#{key}"
      end
      
      def singleton?
        false
      end
      
    private
      def initialize_attrs(options)
        @segment = (options[:segment] || name.pluralize).to_s
        @source = (options[:source] || name.pluralize).to_s
        @class_name = options[:class_name] || source.classify
        @key = (options[:key] || source.singularize.foreign_key).to_s
      end
    end
  end
end
