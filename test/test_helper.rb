# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require 'rubygems'
require 'bundler'
Bundler.setup
require 'rails'
require 'active_support/time'
require "rails/test_help"
require 'test/unit' 
require 'shoulda'
require 'schedule_fu'
require 'factory_girl_rails'
FactoryGirl.find_definitions
require File.expand_path("../dummy/config/environment.rb",  __FILE__)

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
