with systems;               use systems;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
with task_set;              use task_set;
with object_set;            use object_set;
with time_unit_events;      use time_unit_events;
with scheduler;             use scheduler;
with Core_Units;            use Core_Units;
use Core_Units.Core_Units_Table_Package;
with Scheduler_Interface; use Scheduler_Interface;
with Ada.Real_Time;       use Ada.Real_Time;
with Ada.Calendar;
with Ada.Calendar.Formatting;
with Ada.Text_IO;         use Ada.Text_IO;

package scheduling_anomalies_services is

----------------------------------------
-- Type defining the kind of anomaly
----------------------------------------

   type potential_anomaly_type is
     (no_potential_anomaly,
      processor_speed_increase,
      processor_add,
      task_execution_time_decrease,
      task_period_increase,
      task_priority_change,
      precedence_constraint_change,
	  task_execution_time_delay,
	  preemption_delay_decrease,
	  task_deadline_increase,
	  selfsuspension_decrease);

   function get_scheduler (a_core : core_unit_ptr) return schedulers_type;

end scheduling_anomalies_services;
