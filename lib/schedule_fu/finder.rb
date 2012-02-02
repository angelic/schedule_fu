module ScheduleFu
  module Finder
    include ScheduleFu::Parser
    
    def conditions_for_date_finders(*args)
      dates = parse(*args)
      case dates
        when Date then ['value = ?', dates]
        when Range then ['value BETWEEN ? AND ?', dates.first, dates.last]
        when Enumerable then ['value IN (?)', dates]
        else
          raise ArgumentError
      end
    end
  end
end
