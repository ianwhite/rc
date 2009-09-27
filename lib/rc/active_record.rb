require 'rc'
require 'rc/active_record/spec'

Rc::Spec::Singleton.send :include, Rc::ActiveRecord::Spec::Singleton
Rc::Spec::Keyed.send :include, Rc::ActiveRecord::Spec::Keyed