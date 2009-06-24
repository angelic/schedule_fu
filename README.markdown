# ScheduleFu

ScheduleFu allows scheduling events with dates and times. It includes both the 
model and view portions of a calendar. See 
[RSchedule](http://github.com/angelic/rschedule) for an example application using it.

To generate the ScheduleFu migrations, run:

    rake db:migrate:schedule_fu

### Tables

* calendars: distinct calendar that can be associated with your own models
* calendar_recurrences: specific information on particular recurring dates
* calendar_event_mods: modification to a particular calendar_event
* calendar_event_types: different types of events
* calendar_dates: has a row for every day and will automatically generate rows for a 
year before or after any date used in an event. 
* calendar_event_dates: a view that has a row for each date included in the event, original or modified information if a column was modified (time, description, etc), plus some additional informational columns

### Informational columns in calendar_event_dates

* added: true if this date was added as a mod and not in the original event 
* modified: for dates that are included in the original event but have been modified (time, description, etc)
* removed: true if this particular date was removed. There are named scopes in calendar_event_dates for :removed and :not_removed

### Database diagram
The database diagram can also be found in docs/database.png along with the original Dia file.

![database.png](http://angelic.github.com/schedule_fu/database.png)

This plugin borrows a lot from [acts_as_calendar](http://github.com/dball/acts_as_calendar)
and [calendar_helper](http://github.com/topfunky/calendar_helper).
