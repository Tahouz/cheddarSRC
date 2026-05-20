with systems;             use systems;
with Processors;          use Processors;
with processor_set;       use processor_set;
with Processor_Interface; use Processor_Interface;
with Scheduler_Interface; use Scheduler_Interface;
with scheduler.user_defined.interpreted;
use scheduler.user_defined.interpreted;
with Scheduler_Interface; use Scheduler_Interface;
with Core_Units;          use Core_Units;
use Core_Units.Core_Units_Table_Package;
with Tasks;    use Tasks;
with task_set; use task_set;
use task_set.generic_task_set;
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
with debug;               use debug;
with scheduling_anomalies_services.offline;
use scheduling_anomalies_services.offline;


package body scheduling_anomalies_services.online is

   -- Store the architecture model before simulation
   --
   initial_model : system;

   -- Store if the initial mode is compliant with static constraints for each anomaly
   --
   static_processor_speed_increase     : Boolean := False;
   static_precedence_constraint_change : Boolean := False;
   static_task_execution_time_decrease : Boolean := False;
   static_processor_add                : Boolean := False;
   static_task_period_increase         : Boolean := False;
   static_task_late_execution          : Boolean := False;
   static_task_priority_change         : Boolean := False;

   procedure scheduling_anomaly_register (model : in system) is
   begin
      initial_model := model;

      -- Check static constraint on the architecture model
      static_task_execution_time_decrease :=
        check_static_task_execution_time_decrease (initial_model);
      static_processor_speed_increase :=
        check_static_processor_speed_increase (initial_model);
      static_processor_add := check_static_processor_add (initial_model);
      static_task_period_increase :=
        check_static_task_period_increase (initial_model);
      static_task_late_execution :=
        check_static_task_execution_time_delay (initial_model);
      static_task_priority_change :=
        check_static_task_priority_increase (initial_model);
      static_precedence_constraint_change :=
        check_static_precedence_constraint_weak (initial_model);

   end scheduling_anomaly_register;

   procedure scheduling_anomaly_handler
     (inp               : in     handler_input_parameter;
      current_scheduler : in     generic_scheduler'class;
      outp              :    out handler_output_parameter)
   is
   begin
      case inp.event.type_of_event is
         -- report the end of task capacity
         when end_of_task_capacity =>
            Put_Debug ("begin of end_of_task_capacity ");
            check_dynamic_task_execution_time_decrease (inp, outp);
            Put_Debug ("end of end_of_task_capacity ");

         -- report the start of the task execution
         when start_of_task_capacity =>
            Put_Debug ("begin of start_of_task_capacity ");
            check_dynamic_task_execution_time_decrease (inp, outp);
            check_dynamic_task_period_increase (inp, outp);
            check_dynamic_task_priority_change (inp, outp);
            check_dynamic_precedence_constraint_change (inp, outp);
            check_dynamic_processor_add (inp, outp);
            check_dynamic_task_late_execution (inp, outp);
            Put_Debug ("end of start_of_task_capacity ");

         -- report the activation of a task
         when task_activation =>
            Put_Debug ("begin of task_activation ");
            check_dynamic_task_execution_time_decrease (inp, outp);
            check_dynamic_task_period_increase (inp, outp);
            check_dynamic_task_priority_change (inp, outp);
            check_dynamic_precedence_constraint_change (inp, outp);
            check_dynamic_processor_add (inp, outp);
            check_dynamic_processor_speed_increase
              (inp,
               current_scheduler,
               outp);
            Put_Debug ("end of task_activation ");

         -- report the execution of a task during a time unit
         when running_task =>
            Put_Debug ("begin of running_task ");
            check_dynamic_task_execution_time_decrease (inp, outp);
            check_dynamic_task_period_increase (inp, outp);
            check_dynamic_task_priority_change (inp, outp);
            check_dynamic_precedence_constraint_change (inp, outp);
            check_dynamic_processor_speed_increase
              (inp,
               current_scheduler,
               outp);
           Put_Debug ("end of running_task ");

         when others =>
            null;
      end case;
   end scheduling_anomaly_handler;

---------------------------------------------------------------------------------

-- verify if an anomaly occur when a task is activate

   procedure check_dynamic_processor_speed_increase
     (inp               : in     handler_input_parameter;
      current_scheduler : in     generic_scheduler'class;
      outp              :    out handler_output_parameter)
   is
      a_core_unit           : core_unit_ptr;
      my_core_iterator      : core_units_iterator;
      my_processor_iterator : processors_iterator;
      my_processor          : generic_processor_ptr;
      result                : Boolean := False;

   begin
   -- check if the static constraint is verify before looking for the anomaly

      if (static_processor_speed_increase) then

         reset_iterator (initial_model.processors, my_processor_iterator);
         reset_iterator (initial_model.core_units, my_core_iterator);

         loop
            current_element
              (initial_model.processors,
               my_processor,
               my_processor_iterator);
            current_element
              (initial_model.core_units,
               a_core_unit,
               my_core_iterator);
-- check if the system is a monoprocessor or not
            if (my_processor.processor_type = monocore_type) then
               result := True;
               -- check if the speed of the core have been increase
               if
                 (a_core_unit.speed <
                  current_scheduler.corresponding_core_unit.speed)
               then
                  Put_Debug ("the speed of the processor have been increase");
                  outp.detected_anomaly := processor_speed_increase;
               end if;
            else
               if
                 (a_core_unit.name =
                  current_scheduler.corresponding_core_unit.name) and
                 (a_core_unit.speed <
                  current_scheduler.corresponding_core_unit.speed)
               then
                  Put_Debug ("the speed of the processor have been increase");
                  outp.detected_anomaly := processor_speed_increase;
                  exit;
               end if;

            end if;

            exit when
              ((is_last_element
                  (initial_model.processors,
                   my_processor_iterator)) or
               (is_last_element
                  (initial_model.core_units,
                   my_core_iterator)) or
               (result = True));
            next_element (initial_model.processors, my_processor_iterator);
            next_element (initial_model.core_units, my_core_iterator);

         end loop;
      else
         outp.detected_anomaly := no_potential_anomaly;
      end if;

   end check_dynamic_processor_speed_increase;

   procedure check_dynamic_processor_add
     (inp  : in     handler_input_parameter;
      outp :    out handler_output_parameter)
   is
      my_processor_iterator : processors_iterator;
      my_processor          : generic_processor_ptr;

   begin

      if (static_processor_add) then

         reset_iterator (initial_model.processors, my_processor_iterator);

         loop
            current_element
              (initial_model.processors,
               my_processor,
               my_processor_iterator);
-- check if the system is a monoprocessor or not
            if (my_processor.processor_type = monocore_type) then
               outp.detected_anomaly := no_potential_anomaly;
               exit;

            else
               outp.detected_anomaly := processor_add;
               exit;
            end if;

           exit when
              (is_last_element
                 (initial_model.processors,
                  my_processor_iterator));

            next_element (initial_model.processors, my_processor_iterator);

         end loop;
      else
         outp.detected_anomaly := no_potential_anomaly;
      end if;
   end check_dynamic_processor_add;

   procedure check_dynamic_task_execution_time_decrease
     (inp  : in     handler_input_parameter;
      outp :    out handler_output_parameter)
   is
      position  : tasks_range;
      iterator1 : tasks_iterator;
      my_task   : generic_task_ptr;
   begin
      Put_Debug
        ("static_task_execution_time_decrease :" &
         static_task_execution_time_decrease'img);
      Put_Debug ("");

      if (static_task_execution_time_decrease) then

         case inp.event.type_of_event is
            -- save the current task at the end of its execution
            when end_of_task_capacity =>
               for i in 0 .. inp.runtime_data.number_of_tasks - 1 loop
                  if
                    (inp.event.end_task.name =
                     inp.runtime_data.tcbs (i).tsk.name)
                  then
                     position := i;
                  end if;
               end loop;

            -- save the current task at the start of its execution
            when start_of_task_capacity =>

               for i in 0 .. inp.runtime_data.number_of_tasks - 1 loop
                  if
                    (inp.event.start_task.name =
                     inp.runtime_data.tcbs (i).tsk.name)
                  then
                     position := i;
                  end if;
               end loop;

            -- save the current task at its activation
            when task_activation =>

               for i in 0 .. inp.runtime_data.number_of_tasks - 1 loop
                  if
                    (inp.event.activation_task.name =
                     inp.runtime_data.tcbs (i).tsk.name)
                  then
                     position := i;
                  end if;
               end loop;

            -- save the current task during its execution
            when running_task =>

               for i in 0 .. inp.runtime_data.number_of_tasks - 1 loop
                  if
                    (inp.event.running_task.name =
                     inp.runtime_data.tcbs (i).tsk.name)
                  then
                     position := i;
                  end if;
               end loop;

            when others =>
               null;
         end case;

         -- recover the initial system
         reset_iterator (initial_model.tasks, iterator1);

         -- find the active task of the system

         loop
            current_element (initial_model.tasks, my_task, iterator1);
            if (my_task.name = inp.runtime_data.tcbs (position).tsk.name) then
               exit;
            end if;
            exit when is_last_element (initial_model.tasks, iterator1);
            next_element (initial_model.tasks, iterator1);
         end loop;

         if
           (my_task.capacity > inp.runtime_data.tcbs (position).tsk.capacity)
         then
            outp.detected_anomaly := task_execution_time_decrease;
            Put_Debug ("");
            Put_Debug
              ("THE CAPACITY OF TASK " &
               To_String (inp.runtime_data.tcbs (position).tsk.name) &
               " HAVE BEEN REDUCE AND CAN MAKE THE SYSTEM NOT SCHEDULABLE");
            Put_Debug ("");

         end if;
      else
         outp.detected_anomaly := no_potential_anomaly;
      end if;

   end check_dynamic_task_execution_time_decrease;

   procedure check_dynamic_task_period_increase
     (inp  : in     handler_input_parameter;
      outp :    out handler_output_parameter)
   is
      position  : tasks_range;
      iterator1 : tasks_iterator;
      my_task   : generic_task_ptr;

   begin
      if (static_task_period_increase) then

         case inp.event.type_of_event is
            -- save the current task at the end of its execution
            when end_of_task_capacity =>
               for i in 0 .. inp.runtime_data.number_of_tasks - 1 loop
                  if
                    (inp.event.end_task.name =
                     inp.runtime_data.tcbs (i).tsk.name)
                  then
                     position := i;
                  end if;
               end loop;

            -- save the current task at the start of its execution
            when start_of_task_capacity =>
               for i in 0 .. inp.runtime_data.number_of_tasks - 1 loop
                  if
                    (inp.event.start_task.name =
                     inp.runtime_data.tcbs (i).tsk.name)
                  then
                     position := i;
                  end if;
               end loop;

            -- save the current task at its activation
            when task_activation =>
               for i in 0 .. inp.runtime_data.number_of_tasks - 1 loop
                  if
                    (inp.event.activation_task.name =
                     inp.runtime_data.tcbs (i).tsk.name)
                  then
                     position := i;
                  end if;
               end loop;

            -- save the current task during its execution
            when running_task =>
               for i in 0 .. inp.runtime_data.number_of_tasks - 1 loop
                  if
                    (inp.event.running_task.name =
                     inp.runtime_data.tcbs (i).tsk.name)
                  then
                     position := i;
                  end if;
               end loop;

            when others =>
               null;
         end case;

         -- recover the initial system
         reset_iterator (initial_model.tasks, iterator1);

         -- find the active task of the system
         loop
            current_element (initial_model.tasks, my_task, iterator1);
            if (my_task.name = inp.runtime_data.tcbs (position).tsk.name) then
               exit;
            end if;
            exit when is_last_element (initial_model.tasks, iterator1);
            next_element (initial_model.tasks, iterator1);
         end loop;

         -- check if the task period has been increased

         if
           (periodic_task_ptr (my_task).period <
            periodic_task_ptr (inp.runtime_data.tcbs (position).tsk).period)
         then
            Put_Debug ("Period task have been increase");
            Put_Debug ("");
            outp.detected_anomaly := task_period_increase;
         end if;
      else
         outp.detected_anomaly := no_potential_anomaly;
      end if;

   end check_dynamic_task_period_increase;

   procedure check_dynamic_task_late_execution
     (inp  : in     handler_input_parameter;
      outp :    out handler_output_parameter)
   is
   begin
      null;
   end check_dynamic_task_late_execution;

   procedure check_dynamic_task_priority_change
     (inp  : in     handler_input_parameter;
      outp :    out handler_output_parameter)
   is
      position  : tasks_range;
      iterator1 : tasks_iterator;
      my_task   : generic_task_ptr;
   begin
      if (static_task_priority_change) then

         case inp.event.type_of_event is
            -- save the current task at the end of its execution
            when end_of_task_capacity =>
               for i in 0 .. inp.runtime_data.number_of_tasks - 1 loop
                  if
                    (inp.event.end_task.name =
                     inp.runtime_data.tcbs (i).tsk.name)
                  then
                     position := i;
                  end if;
               end loop;

            -- save the current task at the start of its execution
            when start_of_task_capacity =>
               for i in 0 .. inp.runtime_data.number_of_tasks - 1 loop
                  if
                    (inp.event.start_task.name =
                     inp.runtime_data.tcbs (i).tsk.name)
                  then
                     position := i;
                  end if;
               end loop;

            -- save the current task at its activation
            when task_activation =>
               for i in 0 .. inp.runtime_data.number_of_tasks - 1 loop
                  if
                    (inp.event.activation_task.name =
                     inp.runtime_data.tcbs (i).tsk.name)
                  then
                     position := i;
                  end if;
               end loop;

            -- save the current task during its execution
            when running_task =>
               for i in 0 .. inp.runtime_data.number_of_tasks - 1 loop
                  if
                    (inp.event.running_task.name =
                     inp.runtime_data.tcbs (i).tsk.name)
                  then
                     position := i;
                  end if;
               end loop;

            when others =>
               null;
         end case;

         -- recover the initial system
         reset_iterator (initial_model.tasks, iterator1);

         -- find the active task of the system
         loop
            current_element (initial_model.tasks, my_task, iterator1);
            if (my_task.name = inp.runtime_data.tcbs (position).tsk.name) then
               exit;
            end if;
            exit when is_last_element (initial_model.tasks, iterator1);
            next_element (initial_model.tasks, iterator1);
         end loop;

         -- check if the priority of the task have been changed
         Put_Debug
           ("the current task priority : " &
            inp.runtime_data.tcbs (position).tsk.priority'img);
         Put_Debug ("initial system task priority : " & my_task.priority'img);

         if
           (my_task.priority /= inp.runtime_data.tcbs (position).tsk.priority)
         then
            outp.detected_anomaly := task_priority_change;
            Put_Debug ("");
            Put_Debug
              ("THE PRIORITY OF " &
               To_String (inp.runtime_data.tcbs (position).tsk.name) &
               " HAVE BEEN CHANGE AND CAN MAKE THE SYSTEM NOT SCHEDULABLE");
            Put_Debug ("");

         end if;
      else
         outp.detected_anomaly := no_potential_anomaly;
      end if;

   end check_dynamic_task_priority_change;

   procedure check_dynamic_precedence_constraint_change
     (inp  : in     handler_input_parameter;
      outp :    out handler_output_parameter)
   is

      my_dependencies, my_dependencies_initial : tasks_dependencies_ptr;
      my_iterator_initial, my_iterator         : tasks_dependencies_iterator;
      a_half_dep, a_half_dep_initial           : dependency_ptr;

   begin
      -- check if some precedence constraint have been delete
      Put_Debug
        ("static_precedence_constraint_change : " &
         static_precedence_constraint_change'img);

      if (static_precedence_constraint_change) then

         my_dependencies_initial := initial_model.dependencies;
         my_dependencies         := inp.runtime_data.dependencies;
         if is_empty (my_dependencies_initial.depends) then
            outp.detected_anomaly := no_potential_anomaly;

         else
            Put_Debug ("there is a precedence constraint in the inital system");

            if is_empty (my_dependencies.depends) then
               outp.detected_anomaly := precedence_constraint_change;
               Put_Debug ("");
               Put_Debug
                 ("the precedence constraint have been delete and that can make the systeme not schedulable");
               Put_Debug ("");

            else
               reset_iterator
                 (my_dependencies_initial.depends,
                  my_iterator_initial);
               reset_iterator (my_dependencies.depends, my_iterator);

               loop
                  current_element
                    (my_dependencies_initial.depends,
                     a_half_dep_initial,
                     my_iterator_initial);
                  current_element
                    (my_dependencies.depends,
                     a_half_dep,
                     my_iterator);
                  if
                    (a_half_dep_initial.type_of_dependency /=
                     a_half_dep.type_of_dependency)
                  then
                     outp.detected_anomaly := precedence_constraint_change;
                  end if;
                  exit when
                    (is_last_element (my_dependencies.depends, my_iterator)) or
                    (is_last_element
                       (my_dependencies_initial.depends,
                        my_iterator_initial));
                  next_element (my_dependencies.depends, my_iterator);
                  next_element
                    (my_dependencies_initial.depends,
                     my_iterator_initial);
               end loop;
            end if;
         end if;
      else
         outp.detected_anomaly := no_potential_anomaly;
      end if;

   end check_dynamic_precedence_constraint_change;

end scheduling_anomalies_services.online;
