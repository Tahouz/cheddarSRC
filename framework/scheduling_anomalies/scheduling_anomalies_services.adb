with Scheduler_Interface; use Scheduler_Interface;
with scheduler.user_defined.interpreted;
use scheduler.user_defined.interpreted;
with Tasks;    use Tasks;
with task_set; use task_set;
use task_set.generic_task_set;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with Text_IO;           use Text_IO;
with Dependencies;      use Dependencies;
with task_dependencies; use task_dependencies;
with Framework_Config;  use Framework_Config;
use task_dependencies.half_dep_set;
with Ada.Exceptions;      use Ada.Exceptions;
with Ada.Real_Time;       use Ada.Real_Time;
with Ada.Calendar;
with Ada.Calendar.Formatting;
with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with scheduling_anomalies_services.offline;
use scheduling_anomalies_services.offline;

package body scheduling_anomalies_services is
---------------------------------------------------------------------------------

   function get_scheduler (a_core : core_unit_ptr) return schedulers_type is
      a_sched : schedulers_type := no_scheduling_protocol;
      ok      : Boolean         := True;
   begin
      if
        (a_core.scheduling.scheduler_type = pipeline_user_defined_protocol)
      then
         To_Schedulers_Type
           (a_core.scheduling.user_defined_scheduler_protocol_name,
            a_sched,
            ok);
         if not ok then
            Raise_Exception
              (processor_set.invalid_parameter'identity,
               " invalid value for user_defined_scheduler_protocol_name");
         end if;
         return a_sched;

      else
         return a_core.scheduling.scheduler_type;
      end if;
   end get_scheduler;

end scheduling_anomalies_services;
