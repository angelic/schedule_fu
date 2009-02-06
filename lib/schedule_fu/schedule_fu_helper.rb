require 'chronic'

module ScheduleFu
  module ScheduleFuHelper
    
    def chronic_date(*args)
      Chronic.parse(*args).to_date
    end
    
    def previous_sunday(date)
      date
      begin
        date = Date.parse(date)
      rescue
        date = Time.now
      end
      date.wday == 0 ? date : chronic_date('sunday', :now => date, :context => :past)
    end
  end
end