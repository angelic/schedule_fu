require 'chronic'

# Some methods for parsing date expressions from strings
module ScheduleFu
  module Parser
    def parse(*args)
      raise ArgumentError unless args.length > 0
      if args.length == 1
        case args[0]
          when String then parse_dates(args[0])
          when Date then args[0]
          when Time then args[0]
          when Enumerable then args[0].map {|arg| parse(arg)}
          else raise ArgumentError, args[0].class.to_s
        end
      elsif args.length == 2
        (parse_date(args[0]) .. parse_date(args[1]))
      else
        args.map {|arg| parse(arg) }
      end
    end
  
    def parse_date(string)
      if time = Chronic.parse(string)
        time.send(:to_date)
      end
    end
  
    def parse_dates(string)
      parse_recurring_dates(string) || parse_specific_dates(string)
    end
  
    def parse_recurrence_by_type(event_type, recurrent_arr = [])
      case event_type
        when :norepeat then nil
        when :daily then {}
        when :weekdays then (1..5).collect {|d| {:weekday => d}}
        when :weekly
          recurrent_arr.each {|e| e.delete(:monthweek); e.delete(:monthday)}
        when :monthly
          recurrent_arr.each {|e| e.delete(:month)}
        when :yearly then recurrent_arr
      end
    end
    
    private
  
    def parse_specific_dates(value)
      if (parts = value.split('-')).length == 2
        first = parse_date(parts[0])
        last = parse_date(parts[1])
        if first && last
          return (first .. last)
        end
      elsif (parts = value.split(',')).length > 1
        parts = parts.map {|part| parse_date(part) }
        if parts.all? {|part| !part.nil? }
          return parts
        end
      elsif date = parse_date(value)
        return date
      end
    end
  
    # Parses the given value for repeating date strings of the form:
    #
    # * Saturdays
    # * Every Friday
    # * every 3rd tuesday
    # * 2nd and 4th Fridays of the month
    #
    # and returns a hash with keys :weekday and :monthweek, where the weekday
    # is the index of the day in the Date::DAYNAMES array (0-based) and the
    # monthweek is either nil, an integer, or an array of integers,
    # corresponding to the offset of the week(s) of the month.
    def parse_weekly_dates(value)
      # FIXME repeats data from monthweek. we should probably get a more
      # robust parser going here
      unless md = /^\s*(?:Every )?\s*(1st|2nd|3rd|4th|last|first|second|third|fourth)?(?:\s*(?:and|&)\s*(1st|2nd|3rd|4th|last|first|second|third|fourth))?\s*((?:Sun|Mon|Tues|Wednes|Thurs|Fri|Satur)day)s?\s*(?:of each month|of the month|every month)?\s*$/i.match(value)
        return nil
      end
      weekday = Date::DAYNAMES.index(md[3].downcase.capitalize)
      if md[2]
        monthweek = [monthweek(md[1]), monthweek(md[2])]
        return [{:weekday => weekday, :monthweek => md[1]}, {:weekday => weekday, :monthweek => md[2]}]
      elsif md[1]
        monthweek = monthweek(md[1])
      else
        monthweek = nil
      end
      {:weekday => weekday, :monthweek => monthweek }
    end
  
    # Returns the monthweek integer value of the given string, e.g.
    # first -> 0. It ignores case, and allows both full and abbreviated
    # ordinal number names, as well as the special name 'last'. If unable
    # to convert, it will raise an ArgumentError.
    def monthweek(value)
      case value.downcase
        when 'last' then -1
        when '1st' then 0
        when 'first' then 0
        when '2nd' then 1
        when 'second' then 1
        when '3rd' then 2
        when 'third' then 2
        when '4th' then 3
        when 'fourth' then 3
        else raise ArgumentError, value
      end
    end
  end
end

#module Icalendar
#  DAYCODES = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA']
#
#  class Calendar < Component
#    ical_property :x_wr_calname, :name
#  end
#end
