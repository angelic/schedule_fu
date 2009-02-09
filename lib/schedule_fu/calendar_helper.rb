require 'date'

# CalendarHelper allows you to draw a databound calendar with fine-grained CSS formatting
module ScheduleFu
  module CalendarHelper
  
    # Returns an HTML calendar. In its simplest form, this method generates a plain
    # calendar (which can then be customized using CSS) for a given month and year.
    # However, this may be customized in a variety of ways -- changing the default CSS
    # classes, generating the individual day entries yourself, and so on.
    # 
    # The following options are required:
    #  :year  # The  year number to show the calendar for.
    #  :month # The month number to show the calendar for.
    # 
    # The following are optional, available for customizing the default behaviour:
    #   :table_class       => "calendar"        # The class for the <table> tag.
    #   :month_name_class  => "monthName"       # The class for the name of the month, at the top of the table.
    #   :other_month_class => "otherMonth" # Not implemented yet.
    #   :day_name_class    => "dayName"         # The class is for the names of the weekdays, at the top.
    #   :day_class         => "day"             # The class for the individual day number cells.
    #                                             This may or may not be used if you specify a block (see below).
    #   :abbrev            => (0..2)            # This option specifies how the day names should be abbreviated.
    #                                             Use (0..2) for the first three letters, (0..0) for the first, and
    #                                             (0..-1) for the entire name.
    #   :first_day_of_week => 0                 # Renders calendar starting on Sunday. Use 1 for Monday, and so on.
    #   :accessible        => true              # Turns on accessibility mode. This suffixes dates within the
    #                                           # calendar that are outside the range defined in the <caption> with 
    #                                           # <span class="hidden"> MonthName</span>
    #                                           # Defaults to false.
    #                                           # You'll need to define an appropriate style in order to make this disappear. 
    #                                           # Choose your own method of hiding content appropriately.
    #
    #   :show_today        => false             # Highlights today on the calendar using the CSS class 'today'. 
    #                                           # Defaults to true.
    #   :previous_month_text   => nil           # Displayed left of the month name if set
    #   :next_month_text   => nil               # Displayed right of the month name if set
    #   :month_name_array => Date::MONTHNAMES   # Array of months
    #   :display_year => options[:year]         # Year to display
    #
    # For more customization, you can pass a code block to this method, that will get one argument, a Date object,
    # and return a values for the individual table cells. The block can return an array, [cell_text, cell_attrs],
    # cell_text being the text that is displayed and cell_attrs a hash containing the attributes for the <td> tag
    # (this can be used to change the <td>'s class for customization with CSS).
    # This block can also return the cell_text only, in which case the <td>'s class defaults to the value given in
    # +:day_class+. If the block returns nil, the default options are used.
    # 
    # Example usage:
    #   calendar(:year => 2005, :month => 6) # This generates the simplest possible calendar.
    #   calendar({:year => 2005, :month => 6, :table_class => "calendar_helper"}) # This generates a calendar, as
    #                                                                             # before, but the <table>'s class
    #                                                                             # is set to "calendar_helper".
    #   calendar(:year => 2005, :month => 6, :abbrev => (0..-1)) # This generates a simple calendar but shows the
    #                                                            # entire day name ("Sunday", "Monday", etc.) instead
    #                                                            # of only the first three letters.
    #   calendar(:year => 2005, :month => 5) do |d| # This generates a simple calendar, but gives special days
    #     if listOfSpecialDays.include?(d)          # (days that are in the array listOfSpecialDays) one CSS class,
    #       [d.mday, {:class => "specialDay"}]      # "specialDay", and gives the rest of the days another CSS class,
    #     else                                      # "normalDay". You can also use this highlight today differently
    #       [d.mday, {:class => "normalDay"}]       # from the rest of the days, etc.
    #     end
    #   end
    #
    # An additional 'weekend' class is applied to weekend days. 
    #
    # For consistency with the themes provided in the calendar_styles generator, use "specialDay" as the CSS class for marked days.
    # 
    def calendar(options = {}, &block)
      raise(ArgumentError, "No year given")  unless options.has_key?(:year)
      raise(ArgumentError, "No month given") unless options.has_key?(:month)
  
      block ||= Proc.new {|d| nil}
  
      options = defaults(options).merge(options)
      vars = setup_variables(options)
      
      content_tag(:table, :class => options[:table_class], :border => 0, 
          :cellspacing => 0, :cellpadding => 0) do
        calendar_head(options, vars) + calendar_body(options, vars, &block)
      end
    end
    
    private
    
    def first_day_of_week(day)
      day
    end
    
    def last_day_of_week(day)
      if day > 0
        day - 1
      else
        6
      end
    end
    
    def days_between(first, second)
      if first > second
        second + (7 - first)
      else
        second - first
      end
    end
    
    def beginning_of_week(date, start = 1)
      days_to_beg = days_between(start, date.wday)
      date - days_to_beg
    end
    
    def weekend?(date)
      [0, 6].include?(date.wday)
    end
    
    def defaults(options)
      { 
        :table_class => 'calendar',
        :month_name_class => 'monthName',
        :other_month_class => 'otherMonth',
        :day_name_class => 'dayName',
        :day_class => 'day',
        :abbrev => (0..2),
        :first_day_of_week => 0,
        :accessible => false,
        :show_today => true,
        :previous_month_text => nil,
        :next_month_text => nil,
        :month_name_array => Date::MONTHNAMES,
        :display_year => options[:year]
      }
    end
    
    def setup_variables(options)
      vars = {}
      vars[:first] = Date.civil(options[:year], options[:month], 1)
      vars[:last] = Date.civil(options[:year], options[:month], -1)
  
      vars[:first_weekday] = first_day_of_week(options[:first_day_of_week])
      vars[:last_weekday] = last_day_of_week(options[:first_day_of_week])
      vars
    end
    
    def calendar_head(options, vars)
      content_tag(:thead) do
        contents = content_tag(:tr) do
          text = ""
          text << content_tag(:th, :colspan => determine_colspan(text, options), 
              :class => options[:month_name_class]) do
            "#{options[:month_name_array][options[:month]]} #{options[:display_year]}"
          end
          text << content_tag(:th, options[:next_month_text], :colspan => 2) if options[:next_month_text]
          text
      end
        contents << content_tag(:tr, :class => options[:day_name_class]) do
          add_day_names(options, vars)
        end
      end
    end
    
    def add_day_names(options, vars)
      text = ""
      day_names(vars[:first_weekday]).each do |d|
        text << content_tag(:th, :scope => 'col') do
          unless d[options[:abbrev]].eql? d
            content_tag(:abbr, d[options[:abbrev]], :title => d)
          else
            d[options[:abbrev]]
          end
        end
      end
      text
    end
    
    def day_names(first_weekday)
      day_names = Date::DAYNAMES.dup
      first_weekday.times do
        day_names.push(day_names.shift)
      end
      day_names
    end
    
    def determine_colspan(contents, options)
      if options[:previous_month_text] || options[:next_month_text]
        contents << content_tag(:th, :colspan => 2) do
          options[:previous_month_text]
        end
        3
      else
        7
      end
    end
    
    def calendar_body(options, vars, &block)
      content_tag(:tbody) do
        content_tag(:tr) do
          text = fill_days_last_month(options, vars[:first], vars[:first_weekday], &block)
          text << fill_days_this_month(options, vars[:first], vars[:last], vars[:last_weekday], &block)
          text << fill_days_next_month(options, vars[:last], vars[:first_weekday], vars[:last_weekday], &block)
        end
      end
    end
    
    def fill_days_last_month(options, first, first_weekday, &block)
      text = ""
      beginning_of_week(first, first_weekday).upto(first - 1) do |d|
        text << fill_day(d, options, false, &block)
      end unless first.wday == first_weekday
      text
    end
    
    def fill_days_this_month(options, first, last, last_weekday, &block)
      text = ""
      first.upto(last) do |d|
        text << fill_day(d, options, true, &block)
        text << "</tr><tr>" if d.wday == last_weekday
      end
      text
    end
    
    def fill_days_next_month(options, last, first_weekday, last_weekday, &block)
      text = ""
      (last + 1).upto(beginning_of_week(last + 7, first_weekday) - 1)  do |d|
        text << fill_day(d, options, false, &block)
      end unless last.wday == last_weekday
      text
    end
    
    def fill_day(d, options = nil, current = false, &block)
      cell_text, cell_attrs = block.call(d)
      cell_text  ||= d.mday
      cell_attrs ||= {}
      cell_attrs[:class] ||= options[:day_class]
      cell_attrs[:class] += " weekendDay" if weekend?(d) 
      cell_attrs[:class] += " today" if (d == Date.today) && options[:show_today]
      content_tag(:td, cell_attrs) do
        text = cell_text
        text << accessible_text(options) if current
        text
      end
    end
    
    def accessible_text(options)
      options[:accessible] ? 
          "<span class='hidden'> #{options[:month_name_array][d.mon]}</span>" : ""
    end
  end
end
