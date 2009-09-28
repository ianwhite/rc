ENV["RAILS_ENV"] ||= "test"
__DIR__ = File.dirname(__FILE__)

# if we're in a rails env, use that, otherwise use rubygems to create a spec env
begin
  require "#{__DIR__}/../../../../config/environment"
rescue LoadError
  require 'rubygems'
  require 'active_support'
  $LOAD_PATH << "#{__DIR__}/../lib"
  require "rc"
end

require 'spec'

# this is so that we can test for a result acting as true
module Kernel
  def truthy?
    self ? true : false
  end
end