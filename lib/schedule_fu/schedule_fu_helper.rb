module ScheduleFu
  module ScheduleFuHelper
    
    def previous_sunday(date)
      date = parse_date_or_now(date)
      date.wday.ago date
    end
    
    def parse_date_or_now(date)
      begin
        Date.parse(date)
      rescue
        Time.now.to_date
      end
    end
  end
end