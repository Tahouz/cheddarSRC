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

package body scheduling_anomalies_services.offline is

   function check_c1_mono_processor_system
     (a_system : in system) return Boolean
   is
      iterator1  : processors_iterator;
      processor1 : generic_processor_ptr;
      result     : Boolean := True;

   begin
      reset_iterator (a_system.processors, iterator1);

      loop
         current_element (a_system.processors, processor1, iterator1);

         if (processor1.processor_type /= monocore_type) then
            result := False;

         end if;

         exit when
           ((is_last_element (a_system.processors, iterator1)) or
            (result = False));
         next_element (a_system.processors, iterator1);

      end loop;
      return result;

   end check_c1_mono_processor_system;

-----------------------------------------------------------------------------------------------
   function check_c2_multiprocessor_system
     (a_system : in system) return Boolean
   is
   begin

      return not check_c1_mono_processor_system (a_system);

   end check_c2_multiprocessor_system;
-------------------------------------------------------------------
   function check_c3_partitionned_scheduling
     (a_system : in system) return Boolean
   is
      iterator1  : processors_iterator;
      processor1 : generic_processor_ptr;
      result     : Boolean := True;

   begin
      reset_iterator (a_system.processors, iterator1);

      loop
         current_element (a_system.processors, processor1, iterator1);

         if (processor1.migration_type /= no_migration_type) then
            result := False;
         end if;

         exit when is_last_element (a_system.processors, iterator1);
         next_element (a_system.processors, iterator1);

      end loop;
      return result;
   end check_c3_partitionned_scheduling;
--------------------------------------------------------------------
   function check_c4_global_scheduling (a_system : in system) return Boolean is
      iterator1  : processors_iterator;
      processor1 : generic_processor_ptr;
      result     : Boolean := True;

   begin
      reset_iterator (a_system.processors, iterator1);

      loop
         current_element (a_system.processors, processor1, iterator1);

         if (not check_c2_multiprocessor_system (a_system)) then
            result := False;
         end if;

         exit when is_last_element (a_system.processors, iterator1);
         next_element (a_system.processors, iterator1);

      end loop;
      return result;

   end check_c4_global_scheduling;
--------------------------------------------------------------------

   function check_c5_fixed_priority (a_system : in system) return Boolean is
      iterator1       : processors_iterator;
      processor1      : generic_processor_ptr;
      monoprocessor1  : mono_core_processor_ptr;
      multiprocessor1 : multi_cores_processor_ptr;
      result          : Boolean := False;
   begin
      reset_iterator (a_system.processors, iterator1);
      loop
         current_element (a_system.processors, processor1, iterator1);

         if (check_c1_mono_processor_system (a_system)) then
            monoprocessor1 := mono_core_processor_ptr (processor1);
            if(get_scheduler (monoprocessor1.core) =
               posix_1003_highest_priority_first_protocol) 
            then
               result := True;
            end if;
         else
            multiprocessor1 := multi_cores_processor_ptr (processor1);
            for i in 0 .. multiprocessor1.cores.nb_entries - 1 loop
               if
                 (get_scheduler (multiprocessor1.cores.entries (i)) =
                  posix_1003_highest_priority_first_protocol) 
               then
                  result := True;
               end if;
            end loop;
         end if;
         exit when is_last_element (a_system.processors, iterator1);
         next_element (a_system.processors, iterator1);
      end loop;
      return result;
   end check_c5_fixed_priority;
--------------------------------------------------------------------

   function check_c6_edf_algorithm (a_system : in system) return Boolean is
      iterator1       : processors_iterator;
      processor1      : generic_processor_ptr;
      monoprocessor1  : mono_core_processor_ptr;
      multiprocessor1 : multi_cores_processor_ptr;
      result          : Boolean := True;

   begin
      reset_iterator (a_system.processors, iterator1);
      loop
         current_element (a_system.processors, processor1, iterator1);

         if (check_c1_mono_processor_system (a_system)) then
            monoprocessor1 := mono_core_processor_ptr (processor1);
            if
              (get_scheduler (monoprocessor1.core) /=
               earliest_deadline_first_protocol)
            then
               result := False;
            end if;
         else
            multiprocessor1 := multi_cores_processor_ptr (processor1);
            for i in 0 .. multiprocessor1.cores.nb_entries - 1 loop
               if
                 (get_scheduler (multiprocessor1.cores.entries (i)) /=
                  earliest_deadline_first_protocol)
               then
                  result := False;
               end if;
            end loop;
         end if;

         exit when is_last_element (a_system.processors, iterator1);
         next_element (a_system.processors, iterator1);

      end loop;
      return result;
   end check_c6_edf_algorithm;
--------------------------------------------------------------------
   function check_c7_rm_algorithm (a_system : in system) return Boolean is
      iterator1       : processors_iterator;
      processor1      : generic_processor_ptr;
      monoprocessor1  : mono_core_processor_ptr;
      multiprocessor1 : multi_cores_processor_ptr;
      result          : Boolean := False;

   begin
      reset_iterator (a_system.processors, iterator1);
      loop
         current_element (a_system.processors, processor1, iterator1);

         if (check_c1_mono_processor_system (a_system)) then
            monoprocessor1 := mono_core_processor_ptr (processor1);
            if
              (get_scheduler (monoprocessor1.core) =
               rate_monotonic_protocol)
            then
               result := True;
            end if;
         else
            multiprocessor1 := multi_cores_processor_ptr (processor1);
            for i in 0 .. multiprocessor1.cores.nb_entries - 1 loop
               if
                 (get_scheduler (multiprocessor1.cores.entries (i)) =
                  rate_monotonic_protocol)
               then
                  result := True;
               end if;
            end loop;
         end if;

         exit when is_last_element (a_system.processors, iterator1);
         next_element (a_system.processors, iterator1);

      end loop;
      return result;
   end check_c7_rm_algorithm;
--------------------------------------------------------------------

   function check_c8_dm_algorithm (a_system : in system) return Boolean is
      iterator1       : processors_iterator;
      processor1      : generic_processor_ptr;
      monoprocessor1  : mono_core_processor_ptr;
      multiprocessor1 : multi_cores_processor_ptr;
      result          : Boolean := False;

   begin
      reset_iterator (a_system.processors, iterator1);
      loop
         current_element (a_system.processors, processor1, iterator1);

         if (check_c1_mono_processor_system (a_system)) then
            monoprocessor1 := mono_core_processor_ptr (processor1);
            if
              (get_scheduler (monoprocessor1.core) =
               deadline_monotonic_protocol)
            then
               result := True;
            end if;
         else
            multiprocessor1 := multi_cores_processor_ptr (processor1);
            for i in 0 .. multiprocessor1.cores.nb_entries - 1 loop
               if
                 (get_scheduler (multiprocessor1.cores.entries (i)) =
                  deadline_monotonic_protocol)
               then
                  result := True;
               end if;
            end loop;
         end if;

         exit when is_last_element (a_system.processors, iterator1);
         next_element (a_system.processors, iterator1);

      end loop;
      return result;
   end check_c8_dm_algorithm;
--------------------------------------------------------------------

   function check_c9_preemptive_processor
     (a_system : in system) return Boolean
   is
      iterator1       : processors_iterator;
      processor1      : generic_processor_ptr;
      monoprocessor1  : mono_core_processor_ptr;
      multiprocessor1 : multi_cores_processor_ptr;
      result          : Boolean := True;

   begin

      reset_iterator (a_system.processors, iterator1);
      loop
         current_element (a_system.processors, processor1, iterator1);

         if (check_c1_mono_processor_system (a_system)) then
            monoprocessor1 := mono_core_processor_ptr (processor1);
            if
              (monoprocessor1.core.scheduling.preemptive_type /= preemptive)
            then
               result := False;
            end if;
         else
            multiprocessor1 := multi_cores_processor_ptr (processor1);
            for i in 0 .. multiprocessor1.cores.nb_entries - 1 loop
               if
                 (multiprocessor1.cores.entries (i).scheduling
                    .preemptive_type /=
                  preemptive)
               then
                  result := False;
               end if;
            end loop;
         end if;

         exit when is_last_element (a_system.processors, iterator1);
         next_element (a_system.processors, iterator1);

      end loop;
      return result;
   end check_c9_preemptive_processor;
--------------------------------------------------------------------
   function check_c10_non_preemptive_processor
     (a_system : in system) return Boolean
   is
   begin

      return not check_c9_preemptive_processor (a_system);
   end check_c10_non_preemptive_processor;
--------------------------------------------------------------------
   function check_c11_preemptive_with_preemption_delay
     (a_system : in system) return Boolean
   is
       result : Boolean := False;
   begin
      null;
      return result;
   end check_c11_preemptive_with_preemption_delay;
--------------------------------------------------------------------
   function check_c12_synchronous_release
     (a_system : in system) return Boolean
   is
      iterator1    : tasks_iterator;
      task1, task0 : generic_task_ptr;
      result       : Boolean := True;
   begin

      reset_iterator (a_system.tasks, iterator1);
      current_element (a_system.tasks, task0, iterator1);

      loop
         current_element (a_system.tasks, task1, iterator1);

         if (task1.start_time /= task0.start_time) then
            result := False;
         end if;

         exit when is_last_element (a_system.tasks, iterator1);
         next_element (a_system.tasks, iterator1);

      end loop;
      return result;
   end check_c12_synchronous_release;
--------------------------------------------------------------------
   function check_c13_asynchronous_release
     (a_system : in system) return Boolean
   is
   begin
      return not check_c12_synchronous_release (a_system);
   end check_c13_asynchronous_release;
--------------------------------------------------------------------
   function check_c14_tasks_are_periodic
     (a_system : in system) return Boolean
   is
      iterator1 : tasks_iterator;
      task1     : generic_task_ptr;
      result    : Boolean := True;
   begin

      reset_iterator (a_system.tasks, iterator1);
      loop
         current_element (a_system.tasks, task1, iterator1);
         if (task1.task_type /= periodic_type) then
            result := False;
         end if;

         exit when is_last_element (a_system.tasks, iterator1);
         next_element (a_system.tasks, iterator1);

      end loop;
      return result;
   end check_c14_tasks_are_periodic;
--------------------------------------------------------------------
   function check_c15_tasks_are_sporadic
     (a_system : in system) return Boolean
   is
      iterator1 : tasks_iterator;
      task1     : generic_task_ptr;
      result    : Boolean := True;
   begin

      reset_iterator (a_system.tasks, iterator1);
      loop
         current_element (a_system.tasks, task1, iterator1);
         if (task1.task_type /= sporadic_type) then
            result := False;
         end if;

         exit when is_last_element (a_system.tasks, iterator1);
         next_element (a_system.tasks, iterator1);

      end loop;
      return result;
   end check_c15_tasks_are_sporadic;
--------------------------------------------------------------------
   function check_c16_tasks_are_independent
     (a_system : in system) return Boolean
   is

      my_dependencies : tasks_dependencies_ptr;

      result : Boolean := True;

   begin

      my_dependencies := a_system.dependencies;
      if not is_empty (my_dependencies.depends) then
         result := False;
      end if;

      return result;

   end check_c16_tasks_are_independent;
--------------------------------------------------------------------
   function check_c17_tasks_have_precedence_constraint
     (a_system : in system) return Boolean
   is

      my_dependencies : tasks_dependencies_ptr;
      my_iterator1    : tasks_dependencies_iterator;
      a_half_dep      : dependency_ptr;
      result          : Boolean := True;

   begin

      my_dependencies := a_system.dependencies;
      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);
         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);
            if (a_half_dep.type_of_dependency /= precedence_dependency) then
               result := False;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;

      else
         result := False;
      end if;

      return result;

   end check_c17_tasks_have_precedence_constraint;
--------------------------------------------------------------------
   function check_c18_tasks_have_shared_resources
     (a_system : in system) return Boolean
   is
      my_dependencies : tasks_dependencies_ptr;
      my_iterator1    : tasks_dependencies_iterator;
      a_half_dep      : dependency_ptr;
      result          : Boolean := True;

   begin

      my_dependencies := a_system.dependencies;
      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);
         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);
            if (a_half_dep.type_of_dependency /= resource_dependency) then
               result := False;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;

      else
         result := False;
      end if;

      return result;

   end check_c18_tasks_have_shared_resources;
--------------------------------------------------------------------
   function check_c19_tasks_have_selfsuspension
     (a_system : in system) return Boolean
   is
      result : Boolean := False;
   begin
      null;
      return result;
   end check_c19_tasks_have_selfsuspension;
--------------------------------------------------------------------
   function check_c20_tasks_without_selfsuspension
     (a_system : in system) return Boolean
   is
      result : Boolean := False;
   begin
      null;
      return result;
   end check_c20_tasks_without_selfsuspension;  
--------------------------------------------------------------------
   function check_c21_deadline_equal_period
     (a_system : in system) return Boolean
   is
      iterator1    : tasks_iterator;
      task0 : generic_task_ptr;
      result       : Boolean := True;
   begin

      reset_iterator (a_system.tasks, iterator1);
     
      loop
         current_element (a_system.tasks, task0, iterator1);

         if (task0.deadline /= Periodic_Task_Ptr(task0).period) then
            result := False;
         end if;

         exit when is_last_element (a_system.tasks, iterator1);
         next_element (a_system.tasks, iterator1);

      end loop;
      return result;
   end check_c21_deadline_equal_period;
--------------------------------------------------------------------
   function check_c22_deadline_smaller_period
     (a_system : in system) return Boolean
   is
      iterator1    : tasks_iterator;
      task0 : generic_task_ptr;
      result       : Boolean := True;
   begin

      reset_iterator (a_system.tasks, iterator1);
      
      loop
         current_element (a_system.tasks, task0, iterator1);

         if (task0.deadline >= Periodic_Task_Ptr(task0).period) then
            result := False;
         end if;

         exit when is_last_element (a_system.tasks, iterator1);
         next_element (a_system.tasks, iterator1);

      end loop;
      return result;
   end check_c22_deadline_smaller_period;
--------------------------------------------------------------------
   function check_c23_deadline_greater_period
     (a_system : in system) return Boolean
   is
      iterator1    : tasks_iterator;
      task0 : generic_task_ptr;
      result       : Boolean := True;
   begin

      reset_iterator (a_system.tasks, iterator1);
      
      loop
         current_element (a_system.tasks, task0, iterator1);

         if (task0.deadline <= Periodic_Task_Ptr(task0).period) then
            result := False;
         end if;

         exit when is_last_element (a_system.tasks, iterator1);
         next_element (a_system.tasks, iterator1);

      end loop;
      return result;
   end check_c23_deadline_greater_period;

--------------------------------------------------------------------------------
   function check_static_task_execution_time_decrease
     (a_system : in system) return Boolean
   is
---- S1, S2, S3, S4, S5, S6, S7, S8, S9, S10

--C1, C3,  C5,   C9,   C12,   C14,   C17,   C20,   C21
-- or
--C1,   C3,   C5,   C10,   C12,   C14,   C16 ,   C20,   C21
-- or
--C1,   C3,   C7,   C10,   C12,   C14,   C18 ,   C20,   C22 
-- or
--C1,   C3,   C6,   C10,   C13,   C14,   C16,   C19 ,   C22 
-- or
--C1,   C3,   C6,   C11,   C12,   C14,   C16 ,   C20,   C21
-- or
--C1,   C3,   C7,   C11,   C12,   C14,   C16 ,   C20,   C21
-- or
--C1,   C3,   C8,   C11,   C12,   C14,   C16 ,   C20,   C21
-- or
--C2,   C4,   C5,   C9,   C12,   C14,   C16 ,   C20,   C22
-- or
-- C2,   C4,   C5,   C10,   C12,   C14,   C17 ,   C20,   C22
-- or
-- C2,   C3,   C5,   C10,   C12,   C14,   C18 ,   C20,   C22
 
   begin
      return
        (check_c1_mono_processor_system (a_system) and check_c3_partitionned_scheduling (a_system) and check_c5_fixed_priority (a_system) and 
		 check_c9_preemptive_processor (a_system) and check_c12_synchronous_release (a_system) and 	check_c14_tasks_are_periodic (a_system) and
		check_c17_tasks_have_precedence_constraint (a_system) and check_c20_tasks_without_selfsuspension (a_system) and check_c21_deadline_equal_period (a_system)) 
		or
		(check_c1_mono_processor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and check_c5_fixed_priority  (a_system) and
		check_c10_non_preemptive_processor (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and check_c21_deadline_equal_period  (a_system)) 
		or
		(check_c1_mono_processor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and	check_c7_rm_algorithm  (a_system) and
		check_c10_non_preemptive_processor (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c18_tasks_have_shared_resources (a_system) and check_c20_tasks_without_selfsuspension (a_system) and	check_c22_deadline_smaller_period  (a_system)) 
		or
		(check_c1_mono_processor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and	check_c6_edf_algorithm (a_system) and
		check_c10_non_preemptive_processor (a_system) and check_c13_asynchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c19_tasks_have_selfsuspension (a_system) and	check_c22_deadline_smaller_period  (a_system)) 
		or
		(check_c1_mono_processor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and	check_c6_edf_algorithm (a_system) and
		check_c11_preemptive_with_preemption_delay (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c21_deadline_equal_period  (a_system)) 
		or
		(check_c1_mono_processor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and	check_c7_rm_algorithm (a_system) and
		check_c11_preemptive_with_preemption_delay (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c21_deadline_equal_period  (a_system)) 
		or
		(check_c1_mono_processor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and	check_c8_dm_algorithm (a_system) and
		check_c11_preemptive_with_preemption_delay (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c21_deadline_equal_period  (a_system)) 
		or
		(check_c2_multiprocessor_system  (a_system) and check_c4_global_scheduling (a_system) and check_c5_fixed_priority (a_system) and
		check_c9_preemptive_processor (a_system) and check_c12_synchronous_release (a_system) and check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and check_c22_deadline_smaller_period  (a_system)) 
		or
		(check_c2_multiprocessor_system  (a_system) and check_c4_global_scheduling (a_system) and check_c5_fixed_priority (a_system) and
		check_c10_non_preemptive_processor (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c17_tasks_have_precedence_constraint (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and check_c22_deadline_smaller_period  (a_system))	
		or
		(check_c2_multiprocessor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and	check_c5_fixed_priority (a_system) and
		check_c10_non_preemptive_processor (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c18_tasks_have_shared_resources (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c22_deadline_smaller_period  (a_system));
   end check_static_task_execution_time_decrease;
---------------------------------------------------------------------------
   function check_static_precedence_constraint_weak
     (a_system : in system) return Boolean
   is
   -- S9, S12
   --S9 & C2,   C4,   C5,   C10,   C12,   C14,   C17 ,   C20,   C22 
-- or
--S12 & C1,   C3,   C5,   C10,   C12,   C14,   C17 ,   C20,   C22

   begin
      return
        (check_c2_multiprocessor_system  (a_system) and check_c4_global_scheduling (a_system) and	check_c5_fixed_priority (a_system) and
		check_c10_non_preemptive_processor (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c17_tasks_have_precedence_constraint (a_system) and check_c20_tasks_without_selfsuspension (a_system) and	check_c22_deadline_smaller_period  (a_system))	
		or
		(check_c1_mono_processor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and	check_c5_fixed_priority (a_system) and
		check_c10_non_preemptive_processor (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c17_tasks_have_precedence_constraint (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c22_deadline_smaller_period  (a_system));

   end check_static_precedence_constraint_weak;

-----------------------------------------------------------------------

   function check_static_processor_speed_increase
     (a_system : in system) return Boolean
   is
-- A3  & S11, S17 
--S11 & C1,   C3,   C5,   C9,   C12,   C14,   C18 ,   C20,   C22
-- or
--S17 & C1,   C3,   C5,   C10,   C13,   C14,   C16,   C20,   C22

   begin
      return
        (check_c1_mono_processor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and	check_c5_fixed_priority (a_system) and
		check_c9_preemptive_processor (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c18_tasks_have_shared_resources (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c22_deadline_smaller_period  (a_system)) 
		or
		(check_c1_mono_processor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and	check_c5_fixed_priority (a_system) and
		check_c10_non_preemptive_processor (a_system) and 	check_c13_asynchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c22_deadline_smaller_period  (a_system));

   end check_static_processor_speed_increase;

--------------------------------------------------------------------------
   function check_static_task_execution_time_delay
     (a_system : in system) return Boolean
   is
-- A4  & S11, S13 \\
--S11 & C1,   C3,   C5,   C9,   C12,   C14,   C18 ,   C20,   C22
-- or
--S13 & C1,   C3,   C5,   C9,   C12,   C14,   C16,   C20,   C21

   begin
      return
        (check_c1_mono_processor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and	check_c5_fixed_priority (a_system) and
		check_c9_preemptive_processor (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c18_tasks_have_shared_resources (a_system) and check_c20_tasks_without_selfsuspension (a_system) and	check_c22_deadline_smaller_period  (a_system)) 
		or
		(check_c1_mono_processor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and	check_c5_fixed_priority (a_system) and
		check_c9_preemptive_processor (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c21_deadline_equal_period (a_system));

   end check_static_task_execution_time_delay;

--------------------------------------------------------------------------
   function check_static_task_priority_increase
     (a_system : in system) return Boolean
   is
-- A5  & S9 
--S9 & C2,   C4,   C5,   C10,   C12,   C14,   C17 ,   C20,   C22

   begin
      return
        (check_c2_multiprocessor_system  (a_system) and check_c4_global_scheduling (a_system) and	check_c5_fixed_priority (a_system) and
		check_c10_non_preemptive_processor (a_system) and 	check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c17_tasks_have_precedence_constraint (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c22_deadline_smaller_period  (a_system));
   end check_static_task_priority_increase;   

--------------------------------------------------------------------------
   function check_static_preemption_delay_decrease
     (a_system : in system) return Boolean
   is
-- A6  & S5, S6, S7  \\
--C1,   C3,   C6,   C11,   C12,   C14,   C16 ,   C20,   C21
-- or
--C1,   C3,   C7,   C11,   C12,   C14,   C16 ,   C20,   C21
-- or
--C1,   C3,   C8,   C11,   C12,   C14,   C16 ,   C20,   C21

   begin
      return
        (check_c1_mono_processor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and check_c6_edf_algorithm (a_system) and
		check_c11_preemptive_with_preemption_delay (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c21_deadline_equal_period  (a_system)) 
		or
		(check_c1_mono_processor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and	check_c7_rm_algorithm (a_system) and
		check_c11_preemptive_with_preemption_delay (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c21_deadline_equal_period  (a_system)) 
		or
		(check_c1_mono_processor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and	check_c8_dm_algorithm (a_system) and
		check_c11_preemptive_with_preemption_delay (a_system) and 	check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c21_deadline_equal_period  (a_system));
   end check_static_preemption_delay_decrease;   

--------------------------------------------------------------------------
   function check_static_task_deadline_increase
     (a_system : in system) return Boolean
   is
--A7  & S18 \\
--S18 & C1,   C3,   C6,   C11,   C12,   C14,   C16,   C20,   C22 

   begin
      return
        (check_c1_mono_processor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and	check_c6_edf_algorithm (a_system) and
		check_c11_preemptive_with_preemption_delay (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c22_deadline_smaller_period  (a_system));
   end check_static_task_deadline_increase;

--------------------------------------------------------------------------
 function check_static_task_period_increase
     (a_system : in system) return Boolean
   is
   -- A8  & S8, S14, S15, S16, S19, S20 \\
--S8 & C2,   C4,   C5,   C9,   C12,   C14,   C16 ,   C20,   C22 
-- or
--S14 & C2,   C4,   C7,   C9,   C12,   C14,   C16,   C20,   C22
-- or
--S15 & C2,   C3,   C5,   C9,   C12,   C14,   C16,   C20,   C21 
-- or
--S16 & C2,   C4,   C6,   C9,   C13,   C14,   C16,   C20,   C21
-- or
--S19 & C2,   C4,   C5,   C9,   C12,   C14,   C16,   C20,   C21
-- or 
-- S20 & C2,   C4,   C8,   C9,   C13,   C14,   C16,   C20,   C21

   begin
      return
        (check_c2_multiprocessor_system  (a_system) and check_c4_global_scheduling (a_system) and check_c5_fixed_priority (a_system) and
		check_c9_preemptive_processor (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c22_deadline_smaller_period  (a_system)) 
		or
		(check_c2_multiprocessor_system  (a_system) and check_c4_global_scheduling (a_system) and	check_c7_rm_algorithm  (a_system) and
		check_c9_preemptive_processor (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c22_deadline_smaller_period  (a_system)) 
		or
		(check_c2_multiprocessor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and	check_c5_fixed_priority (a_system) and
		check_c9_preemptive_processor (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c21_deadline_equal_period  (a_system)) 
		or
		(check_c2_multiprocessor_system  (a_system) and check_c4_global_scheduling (a_system) and	check_c6_edf_algorithm (a_system) and
		check_c9_preemptive_processor (a_system) and check_c13_asynchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c21_deadline_equal_period  (a_system)) 
		or 
		(check_c2_multiprocessor_system  (a_system) and check_c4_global_scheduling (a_system) and	check_c5_fixed_priority (a_system) and
		check_c9_preemptive_processor (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c21_deadline_equal_period  (a_system)) 
		or 
		(check_c2_multiprocessor_system  (a_system) and check_c4_global_scheduling (a_system) and	check_c8_dm_algorithm (a_system) and
		check_c9_preemptive_processor (a_system) and check_c13_asynchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c21_deadline_equal_period  (a_system));

   end check_static_task_period_increase;
--------------------------------------------------------------------------
   
function check_static_processor_add 
	(a_system : in system) return Boolean 
is
-- A9  & S9 \\
-- S9 & C2,   C4,   C5,   C10,   C12,   C14,   C17 ,   C20,   C22

   begin
      return
        (check_c2_multiprocessor_system  (a_system) and check_c4_global_scheduling (a_system) and	check_c5_fixed_priority (a_system) and
		check_c10_non_preemptive_processor (a_system) and check_c12_synchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c17_tasks_have_precedence_constraint (a_system) and	check_c20_tasks_without_selfsuspension (a_system) and	check_c22_deadline_smaller_period  (a_system));
   end check_static_processor_add;

--------------------------------------------------------------------------

function check_static_selfsuspension_decrease
	(a_system : in system) return Boolean 
is
-- A10  & S4 \\
-- S4 & C1,   C3,   C6,   C10,   C13,   C14,   C16,   C19 ,   C22

   begin
      return
        (check_c1_mono_processor_system  (a_system) and check_c3_partitionned_scheduling (a_system) and	check_c6_edf_algorithm (a_system) and
		check_c10_non_preemptive_processor (a_system) and check_c13_asynchronous_release (a_system) and	check_c14_tasks_are_periodic (a_system) and
		check_c16_tasks_are_independent (a_system) and	check_c19_tasks_have_selfsuspension (a_system) and	check_c22_deadline_smaller_period  (a_system));
   end check_static_selfsuspension_decrease;

--------------------------------------------------------------------------
   function print_duration_time_exec return String is

      the_clock : constant Ada.Real_Time.Time := Ada.Real_Time.Clock;
      -- Convert to Time_Span
      as_time_span : Ada.Real_Time.Time_Span;
      dur          : Duration;
   begin

      as_time_span := Ada.Real_Time.Clock - the_clock;
      dur          := Ada.Real_Time.To_Duration (as_time_span);
      return Duration'image (dur);

   end print_duration_time_exec;

---------------------------------------------------------------------

   procedure scheduling_anomalies_analyzer
     (a_system : in     system;
      msg      :    out Unbounded_String)
   is

      result    : Boolean;
      the_clock : constant Ada.Real_Time.Time := Ada.Real_Time.Clock;
      -- Convert to Time_Span
      as_time_span : Ada.Real_Time.Time_Span;

      dur, dur1 : Duration;
      msg1      : Unbounded_String;

   begin

      as_time_span := Ada.Real_Time.Clock - the_clock;
      dur          := Ada.Real_Time.To_Duration (as_time_span);
      msg1         :=
        To_Unbounded_String
          ("begin of the procedure scheduling_anomalies:" &
           Duration'image (dur));

      result := check_c1_mono_processor_system (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String ("Condition C1_uniprocessor =" & result'img);
		
      result := check_c2_multiprocessor_system (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String ("Condition C2_MultiProcessor =" & result'img);
      
	  result := check_c3_partitionned_scheduling (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String
          ("Condition C3:Partitionned Scheduling =" & result'img);
      
	  result := check_c4_global_scheduling (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String
          ("Condition C4:Multiprocessor with global scheduling =" &
           result'img);
      
	  result := check_c5_fixed_priority (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String ("Condition C5:fixed priority =" & result'img);
      
	  result := check_c6_edf_algorithm (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String ("Condition C6:Algorithm EDF =" & result'img);
      
	  result := check_c7_rm_algorithm (a_system);      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String ("Condition C7:Algorithm RM =" & result'img);
      
	  result := check_c8_dm_algorithm (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String ("Condition C8:Algorithm DM =" & result'img);
      
	  result := check_c9_preemptive_processor (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String ("Condition C9:Preemptive system =" & result'img);
      
	  --result := check_c10_non_preemptive (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String
          ("Condition C10:Non preemptive system =" & result'img);
      
	  result := check_c11_preemptive_with_preemption_delay (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String
          ("Condition C11:preemptive with preemption delay = " & result'img);
      
	  result := check_c12_synchronous_release (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String
          ("Condition C12: synchronous release = " & result'img);
      
	  result := check_c13_asynchronous_release (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String ("Condition C13: asynchronous release = " & result'img);
      
	  result := check_c14_tasks_are_periodic (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String
          ("Condition C14:Periodic Tasks = " & result'img);
		 
      result := check_c15_tasks_are_sporadic (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String
          ("Condition C15:tasks are sporadic = " & result'img);
		  
	  result := check_c16_tasks_are_independent (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String
          (" Condition C16:tasks are independent = " & result'img);
		 
      result := check_c17_tasks_have_precedence_constraint (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String
          ("Condition C17:tasks have precedence constraint = " & result'img);
      
	  result := check_c18_tasks_have_shared_resources (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String ("Condition C18:Shared resources = " & result'img);
      
	  result := check_c19_tasks_have_selfsuspension (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String ("Condition C19:tasks have selfsuspension = " & result'img);

	  result := check_c20_tasks_without_selfsuspension (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String ("Condition C20:tasks without selfsuspension = " & result'img);

	  result := check_c21_deadline_equal_period (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String ("Condition C21:deadline is equal to period = " & result'img);
	  
	  result := check_c22_deadline_smaller_period (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String ("Condition C22:deadline is smaller than period = " & result'img);

	  result := check_c23_deadline_greater_period (a_system);
      msg    :=
        msg &
        ASCII.LF &
        To_Unbounded_String ("Condition C23:deadline is greater than period = " & result'img);


      as_time_span := Ada.Real_Time.Clock - the_clock;
      dur1         := Ada.Real_Time.To_Duration (as_time_span);
      dur          := dur1 - dur;
      msg1         :=
        To_Unbounded_String
          ("end of the procedure scheduling_anomalies:" &
           Duration'image (dur1));
      msg1 :=
        To_Unbounded_String
          ("execution time of the procedure scheduling_anomalies:" &
           Duration'image (dur));

   end scheduling_anomalies_analyzer;

end scheduling_anomalies_services.offline;
