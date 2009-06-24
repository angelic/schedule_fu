# ScheduleFu

ScheduleFu allows scheduling events with dates and times. It includes both the 
model and view portions of a calendar. See 
[RSchedule](http://github.com/angelic/rschedule) for an example application using it.

To generate the ScheduleFu migrations, run:

    rake db:migrate:schedule_fu

Below is a diagram of the models.  The database diagram can be found in docs/database.png along with the original Dia file.

Calendar_recurrences is used for specific information on
particular recurring dates. Calendar_event_mods stores any modification to a particular 
calendar_event. Calendar_event_types stores the different kinds of events. 
Calendar_dates has a row for every day and will automatically generate rows for a 
year before or after any date used in an event. 

Calendar_event_dates is a view that has a row for each date included in the event, plus some additional informational columns.

* added: True if this date was added as a mod and not in the original event. 
* modified: For dates that are included in the original event but have been modified (time, description, etc). Any modified columns will have the modified data rather than the original in this view. 
* removed: true if this particular date was removed. There are named scopes in calendar_event_dates for :removed and :not_removed.

![database.png](http://angelic.github.com/schedule_fu/database.png)

This plugin borrows a lot from [acts_as_calendar](http://github.com/dball/acts_as_calendar)
and [calendar_helper](http://github.com/topfunky/calendar_helper).
