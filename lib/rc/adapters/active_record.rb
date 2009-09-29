require 'rc'
require 'rc/adapters/active_record/spec'

Rc::Spec::Singleton.send :include, Rc::Adapters::ActiveRecord::Spec::Singleton
Rc::Spec::Keyed.send :include, Rc::Adapters::ActiveRecord::Spec::Keyed