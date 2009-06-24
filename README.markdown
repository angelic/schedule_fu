# ScheduleFu

ScheduleFu allows scheduling events with dates and times. It includes both the 
model and view portions of a calendar. See 
[RSchedule](http://github.com/angelic/rschedule) for an example application using it.

To generate the ScheduleFu migrations, run:

  rake db:migrate:schedule_fu

This is a diagram of the models

![database.png](database.png)

The original Dia file can be found in the docs directory.

This plugin borrows a lot from [acts_as_calendar](http://github.com/dball/acts_as_calendar)
and [calendar_helper](http://github.com/topfunky/calendar_helper).
