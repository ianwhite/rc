require 'rc/spec'

module Rc
  class Spec::Complete < Spec
    def initialize(name, *args, &block)
      raise ArgumentError, "name is required for a #{self.class.name}" if name.blank?
      super
    end
    
    def singleton?
      raise "Complete specs must implement singleton?"
    end
    
    def complete?
      true
    end
    
    #def service(parent = nil)
    #  @service ||= service_class.new(self)
    #  @service.parent = parent
    #  @service
    #end
    #
    #def service_class
    #  @service_class ||= singleton? ? Rc::Service::Singleton : Rc::Service::Keyed
    #end

  protected
    def initialize_attrs(options)
      super
      #@service = options[:service] if options[:service]
      #@service_class = options[:service_class] if options[:service_class]
    end
  end
end