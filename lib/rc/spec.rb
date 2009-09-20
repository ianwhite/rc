module Rc
  # This class holds all the info that is required to identify a resource, or determine a name prefix, based on a route segment
  # or segment pair (e.g. /blog or /users/3).
  class Spec
    class << self
      # convert the arg to a spec, or if it is one, return it
      def to_spec(spec)
        if spec.is_a?(Spec)
          spec
        elsif spec.is_a?(Hash)
          new(spec[:name], spec.except(:name))
        elsif spec.is_a?(String) || spec.is_a?(Symbol)
          new(spec)
        else
          raise ArgumentError, "can't figure out how to trun #{spec} into an Rc::Spec"
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
          else
            Resource.new(name, options, &block)
          end
        else
          super
        end
      end
    end
    
    attr_reader :name, :singleton, :find, :as, :source, :class_name, :key, :name_prefix, :segment
    
    def initialize(name, options = {}, &block)
      options.assert_valid_keys :singleton, :find, :as
      @name = name.to_s
      @find = block || options[:find]
      @singleton = options[:singleton] ? true : false
      @as = options[:as]
    end
    
    def singleton?
      @singleton
    end
    
    def inspect
      "#<#{self.class.name}: #{to_s}>"
    end
    
    def ==(other)
      self.class == other.class && self.ivars == other.ivars
    end
      
  protected
    def ivars
      instance_variables.map{|i| instance_variable_get(i) }
    end
    
    class Glob < Spec
      def initialize(*args)
      end
      
      def to_s
        "/*"
      end
    end
    
    class Polymorphic < Spec
      def initialize(name, options = {}, &block)
        options[:as] = name if name.present?
        super('', options, &block)
      end
      
      def to_s
        "/?#{"(as => #{as})" if as}#{"/:?_id" unless singleton?}"
      end
    end
    
    class Resource < Spec
      # Example Usage
      #
      #  Spec.new <name>, <options hash>, <&block>
      #
      # _name_ should always be singular.
      #
      # Options:
      #
      # * <tt>:singleton:</tt> (default false) set this to true if the resource is a Singleton
      # * <tt>:find:</tt> (default null) set this to a symbol or Proc to specify how to find the resource.
      #   Use this if the resource is found in an unconventional way
      #
      # Options for unconvential use (otherwise these are all inferred from the _name_)
      # * <tt>:source:</tt> a plural string or symbol (e.g. :users).  This is used to find the class or association name
      # * <tt>:class:</tt> a Class.  This is the class of the resource (if it can't be inferred from _name_ or :source)
      # * <tt>:key:</tt> (e.g. :user_id) used to find the resource id in params
      # * <tt>:name_prefix:</tt> (e.g. 'user_') (set this to false if you want to specify that there is none)
      # * <tt>:segment:</tt> (e.g. 'users') the segment name in the route that is matched
      #
      # Passing a block is the same as passing :find => Proc
      def initialize(name, options = {}, &block)
        super(name, options.slice(:singleton, :find, :as), &block)
        
        options = options.except(:singleton, :find, :as)
        options.assert_valid_keys(:class_name, :source, :key, :find, :name_prefix, :segment)
        raise ArgumentError, "requires a name" unless name.present?
        
        singleton? ? initialize_singleton_attrs(options) : initialize_attrs(options)
        @name_prefix = options[:name_prefix] || (options[:name_prefix] == false ? '' : "#{name}_")
      end
    
      def to_s
        "/#{segment}#{"(as => #{as})" if as}#{"/:#{key}" unless singleton?}"
      end
        
    private
      def initialize_singleton_attrs(options)
        @segment = (options[:segment] || name).to_s
        @source = (options[:source] || name).to_s
        @class_name = options[:class_name] || source.singularize.classify
      end
    
      def initialize_attrs(options)
        @segment = (options[:segment] || name.pluralize).to_s
        @source = (options[:source] || name.pluralize).to_s
        @class_name = options[:class_name] || source.classify
        @key = (options[:key] || source.singularize.foreign_key).to_s
      end
    end
  end
end
