module Rc
  # This class holds all the info that is required to identify a resource, or determine a name prefix, based on a route segment
  # or segment pair (e.g. /blog or /users/3).
  class Spec
    attr_reader :name, :source, :class_name, :key, :name_prefix, :segment, :find
    attr_accessor :as

    # factory that creates a SingletonSpec if :singleton => true
    def self.new(spec_name, options = {}, &block)
      options.delete(:singleton) ? SingletonSpec.new(spec_name, options, &block) : super
    end

    # Example Usage
    #
    #  Specifcation.new <name>, <options hash>, <&block>
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
    def initialize(spec_name, options = {}, &block)
      options.assert_valid_keys(:class_name, :source, :key, :find, :name_prefix, :segment, :as)
      @name = spec_name.to_s
      @find = block || options[:find]
      @as = options[:as]
      @name_prefix = options[:name_prefix] || (options[:name_prefix] == false ? '' : "#{name}_")
      initialize_attrs(options)
    end

    def singleton?
      false
    end
    
  protected
    def initialize_attrs(options)
      @segment = (options[:segment] || name.pluralize).to_s
      @source = (options[:source] || name.pluralize).to_s
      @class_name = options[:class_name] || source.classify
      @key = (options[:key] || source.singularize.foreign_key).to_s
    end
  end

  # A Singleton Specification
  class SingletonSpec < Spec
    def singleton?
      true
    end
    
  protected
    def initialize_attrs(options)
      @segment = (options[:segment] || name).to_s
      @source = (options[:source] || name).to_s
      @class_name = options[:class_name] || source.singularize.classify
    end
  end
end
