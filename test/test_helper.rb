require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'shoulda'
require 'test/unit' 

ENV['RAILS_ENV'] = 'test' 
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..' 
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb')) 
require 'test_help'

class Test::Unit::TestCase
  Factory.definition_file_paths = [File.join(File.dirname(__FILE__), 'factories')]
  Factory.find_definitions
end
