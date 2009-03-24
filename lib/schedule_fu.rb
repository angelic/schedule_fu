# require 'icalendar'
 
module ScheduleFu
  Dir.glob(File.dirname(__FILE__) + '/../app/*') do |path|
    $LOAD_PATH << path
    ActiveSupport::Dependencies.load_paths << path
    ActiveSupport::Dependencies.load_once_paths.delete(path) 
  end
end
