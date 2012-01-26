$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "schedule_fu/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "schedule_fu"
  s.version     = ScheduleFu::VERSION
  s.authors     = ["Angel N. Sciortino"]
  s.email       = ["contact@angeliccomputing.com"]
  s.homepage    = "http://github.com/angelic/schedule_fu"
  s.summary     = %q{ScheduleFu allows scheduling events with dates and times.}
  s.description = %q{ScheduleFu allows scheduling events with dates and
times. It includes both the model and view portions of a calendar. It
borrow heavily from acts_as_calendar (http://github.com/dball/acts_as_calendar)
and calendar_helper (http://github.com/topfunky/calendar_helper).}

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2.0"
  s.add_dependency "mysql2"

  s.add_development_dependency "jquery-rails"
  s.add_development_dependency "factory_girl", "~> 2.5.0"
  s.add_development_dependency "factory_girl_rails", "~> 1.6.0"
  s.add_development_dependency "shoulda", "~> 2.11.3"
end
