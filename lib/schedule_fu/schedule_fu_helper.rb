require 'chronic'

module ScheduleFu
  module ScheduleFuHelper
    
    def chronic_date(*args)
      Chronic.parse(*args).to_date
    end
    
    def previous_sunday(date)
      date = parse_date_or_now(date)
      date.wday == 0 ? date : chronic_date('sunday', :now => date, :context => :past)
    end
    
    def parse_date_or_now(date)
      begin
        Date.parse(date)
      rescue
        Time.now
      end
    end
  end
end