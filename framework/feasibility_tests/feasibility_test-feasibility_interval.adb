------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Cheddar is a GNU GPL real-time scheduling analysis tool.
-- This program provides services to automatically check schedulability and
-- other performance criteria of real-time architecture models.
--
-- Copyright (C) 2002-2023, Frank Singhoff, Alain Plantec, Jerome Legrand,
--                          Hai Nam Tran, Stephane Rubini
--
-- The Cheddar project was started in 2002 by
-- Frank Singhoff, Lab-STICC UMR 6285, Université de Bretagne Occidentale
--
-- Cheddar has been published in the "Agence de Protection des Programmes/France" in 2008.
-- Since 2008, Ellidiss technologies also contributes to the development of
-- Cheddar and provides industrial support.
--
-- The full list of contributors and sponsors can be found in README.md
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
--
--
-- Contact : cheddar@listes.univ-brest.fr
--
------------------------------------------------------------------------------
-- Last update :
--    $Rev: 4589 $
--    $Date: 2023-09-29 16:02:19 +0200 (ven., 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Text_IO;                       use Ada.Text_IO;
with Ada.Exceptions;                    use Ada.Exceptions;
with sets;
with double_util;                       use double_util;
with integer_util;                      use integer_util;
with natural_util;                      use natural_util;
with double_util;                       use double_util;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with debug;                             use debug;
with initialize_framework;              use initialize_framework;
with translate;                         use translate;
with Objects;                           use Objects;
with Objects.extended;                  use Objects.extended;
with systems;                           use systems;
with task_set;                          use task_set;
with Resources;                         use Resources;
with Core_Units;                        use Core_Units;
with time_unit_events;                  use time_unit_events;
with Processor_Interface;               use Processor_Interface;
with Processors;                        use Processors;
with processor_set;                     use processor_set;
with task_dependencies;                 use task_dependencies;
with Scheduler_Interface;               use Scheduler_Interface;

------------------------------------------------------------------------
-- This package implements multiples algorithms in order to provide a
-- feasibility interval for a given system as well as a validation of
-- the calculation result. It uses a package multi_precision_integers in a
-- way to manipulate big integers during calculation without loss of precision.

-- To do:
-- - Add precise tests on dependencies as well as preemptivity
-- - Add verifications/exceptions on range violations etc.
-- - Move utility functions in their proper packages
--   (cf: Max_Start_Time_Of_TaskSet in task_set package)
-- - Add others algorithms to proper Is_XX_Scheduler functions.
---------------------------------------------------------
------------------------------------------------------------------------
package body feasibility_test.feasibility_interval is

   function is_fixed_job_scheduler
     (scheduler_type : in schedulers_type) return Boolean
   is
   begin
      if scheduler_type = earliest_deadline_first_protocol then
         return True;
      else
         return False;
      end if;
   end is_fixed_job_scheduler;

   function is_fixed_task_scheduler
     (scheduler_type : in schedulers_type) return Boolean
   is
   begin
      case scheduler_type is
         when rate_monotonic_protocol =>
            return True;
         when deadline_monotonic_protocol =>
            return True;
         when posix_1003_highest_priority_first_protocol =>
            return True;
         when others =>
            return False;
      end case;
   end is_fixed_task_scheduler;

   function is_work_conserving_scheduler
     (scheduler_type : in schedulers_type) return Boolean
   is
   begin
      if is_fixed_job_scheduler (scheduler_type)
        or else is_fixed_task_scheduler (scheduler_type)
      then
         return True;
      else
         return False;
      end if;
   end is_work_conserving_scheduler;

   function max_start_time_of_taskset
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Natural
   is
      max_start_time : Natural := 0;
      my_iterator    : tasks_iterator;
      a_task         : generic_task_ptr;
   begin
      reset_iterator (my_tasks, my_iterator);
      loop
         current_element (my_tasks, a_task, my_iterator);
         if (processor_name = a_task.cpu_name) then
            max_start_time := Natural'max (max_start_time, a_task.start_time);
         end if;
         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);
      end loop;

      return max_start_time;
   end max_start_time_of_taskset;

   ---------------------------------------------------------------------
   -- Calculate_Feasibility_Interval
   -- Implementation Notes:
   -- - This routine calls the function needed for the feasibility
   --   interval calculation based on the characteristics of the provided
   --   system. A boolean was added in order to know if the procedure
   --   finded a corresponding algorithms for the calculation or not and
   --   so if the interval is valid for the user or not.
   ---------------------------------------------------------------------
   procedure calculate_feasibility_interval
     (sys         : in     system;
      a_processor : in     generic_processor_ptr;
      validate    :    out Boolean;
      interval    :    out Double;
      msg         :    out Unbounded_String)
   is
      independent_tasks     : Boolean;
      constrained_deadlines : Boolean;
      processor_type        : processors_type;
      scheduler_type        : schedulers_type;
      a_core                : core_unit_ptr;
   begin
      independent_tasks :=
        is_empty (sys.resources) and is_empty (sys.dependencies.depends);
      constrained_deadlines := deadline_inferior_to_period (sys.tasks);

      -- Get Scheduler Type
      --
      processor_type := a_processor.processor_type;
      if (processor_type = monocore_type) then
         a_core := mono_core_processor_ptr (a_processor).core;
      else
         a_core := multi_cores_processor_ptr (a_processor).cores.entries (0);
      end if;

      validate       := True;
      scheduler_type := a_core.scheduling.scheduler_type;

      ------------------------------------------------------------------
      -- Scheduling Interval Dispatch : select which method according to
      -- architecture property
      --

      if (scheduler_type = reduction_to_uniprocessor_protocol) then
         msg :=
           To_Unbounded_String (", see Leung and Merill (1980) from [21].");
         interval :=
           scheduling_period_with_offset (sys.tasks, a_processor.name);
         return;
      end if;

      -- Partitionned (monoprocessor or multiprocessor)
      --
      if (processor_type = monocore_type) or
        (a_processor.migration_type = no_migration_type)
      then
         put_debug ("monoprocessor or partitionned multicore");
         if constrained_deadlines and
           independent_tasks and
           is_fixed_task_scheduler (scheduler_type)
         then
            put_debug ("constraint and independent and fixed_task_scheduler");
            msg :=
              To_Unbounded_String (", see Leung and Merill (1980) from [21].");
            interval :=
              scheduling_period_with_offset (sys.tasks, a_processor.name);
            return;
         end if;
         if constrained_deadlines and
           independent_tasks and
           is_fixed_job_scheduler (scheduler_type)
         then
            put_debug ("constraint and independent and fixed_job_scheduler");
            msg :=
              To_Unbounded_String
                (", see Goossens and Devillers (1997) from [21].");
            interval :=
              scheduling_period_1997 (sys.tasks, a_processor.name, False);
            return;
         end if;
         if constrained_deadlines and
           (not independent_tasks) and
           is_work_conserving_scheduler (scheduler_type)
         then
            put_debug
              ("constraint and dependent and work_conserving_scheduler");
            msg :=
              To_Unbounded_String
                (", see Choquet-Geniet and Grolleau (2004), Bado et al. (2012) from [21].");
            interval :=
              scheduling_period_with_offset (sys.tasks, a_processor.name);
            return;
         end if;

         if (not constrained_deadlines) and
           is_fixed_job_scheduler (scheduler_type)
         then
            put_debug ("not constraint and fixed_job_scheduler");
            msg :=
              To_Unbounded_String
                (", see Goossens and Devillers (1999) from [21].");
            interval :=
              scheduling_period_with_offset (sys.tasks, a_processor.name);
            return;
         end if;

         -- No corresponding feasibility interval algorithm, use of classical Omax + 2H interval,
         -- Invalidated interval.
         --
         validate := False;
         msg      :=
           To_Unbounded_String (", see Leung and Merrill (1980) from [21].");
         interval :=
           scheduling_period_with_offset (sys.tasks, a_processor.name);
         return;

      end if;

      -- Multiprocessor cases only
      --

      if (processor_type = uniform_multicores_type) then
         put_debug ("Uniform");
         if independent_tasks and
           constrained_deadlines and
           is_fixed_task_scheduler (scheduler_type)
         then
            msg :=
              To_Unbounded_String
                (", see Cucu and Goossens (2006) from [21].");
            interval :=
              scheduling_period_1997 (sys.tasks, a_processor.name, False);
            return;
         end if;
      end if;

      if (processor_type = unrelated_multicores_type) then
         put_debug ("Unrelated");
         if independent_tasks and
           constrained_deadlines and
           is_fixed_task_scheduler (scheduler_type)
         then
            msg :=
              To_Unbounded_String
                (", see Cucu-Grosjean and Goossens (2011) from [21].");
            interval :=
              scheduling_period_1997 (sys.tasks, a_processor.name, False);
            return;
         end if;
      end if;

      if (processor_type = identical_multicores_type) then
         put_debug ("Identical");
         if constrained_deadlines then
            msg :=
              To_Unbounded_String
                (", see Baro et al. (2012), Nelis et al. (2013) from [21].");
            interval :=
              scheduling_period_2012_2013 (sys.tasks, a_processor.name);
            return;
         else
            if independent_tasks and
              is_fixed_task_scheduler (scheduler_type)
            then
               msg :=
                 To_Unbounded_String
                   (", see Cucu and Goossens (2007) from [21].");
               interval :=
                 scheduling_period_1997 (sys.tasks, a_processor.name, True);
               return;
            end if;
            msg := To_Unbounded_String (", see Goossens-Cucu-Grolleau (2016)");
            interval := scheduling_period_2016 (sys.tasks, a_processor.name);
            return;
         end if;
      end if;

      -- No corresponding feasibility interval algorithm, use of classical Omax + 2H interval,
      -- Invalidated interval.
      --
      validate := False;
      msg := To_Unbounded_String (", see Leung and Merrill (1980) from [21].");
      interval := scheduling_period_with_offset (sys.tasks, a_processor.name);
   end calculate_feasibility_interval;

   ---------------------------------------------------------------------
   -- Scheduling_Period_1997
   -- @param AddPeriod Switch between interval types
   -- Implementation Notes:
   -- -
   ---------------------------------------------------------------------
   function scheduling_period_1997
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String;
      addperiod      : in Boolean) return Double
   is
      h               : Double  := 0.0;
      sn              : Double  := 0.0;
      op1             : Double  := 0.0;
      op2             : Double  := 0.0;
      op3             : Double  := 0.0;
      period          : Double  := 0.0;
      start_time      : Double  := 0.0;
      tmp_tasks       : tasks_set;
      my_iterator     : tasks_iterator;
      a_task          : generic_task_ptr;
      first_task_used : Boolean := True;
   begin
      current_processor_name := processor_name;
      h                      := 1.0;

      select_and_copy (my_tasks, tmp_tasks, select_cpu'access);
      sort (tmp_tasks, decreasing_priority'access);

      periodic_control (tmp_tasks, processor_name);

      reset_iterator (tmp_tasks, my_iterator);

      loop
         current_element (tmp_tasks, a_task, my_iterator);

         if a_task.cpu_name = processor_name and
           a_task.task_type = periodic_type
         then
            start_time := Double (a_task.start_time);
            h          := lcm (h, Double (periodic_task_ptr (a_task).period));
            period     := Double (periodic_task_ptr (a_task).period);

            if first_task_used then
               sn              := start_time;
               first_task_used := False;
            else
               op1 := sn - start_time;
               op2 := Double'ceiling (op1 / period);
               op1 := op2 * period + start_time;

               if start_time > op1 then
                  sn := start_time;
               else
                  sn := op1;
               end if;

               if addperiod then
                  op3 := sn;
                  sn  := op3 + h;
               end if;
            end if;
         end if;

         exit when is_last_element (tmp_tasks, my_iterator);

         next_element (tmp_tasks, my_iterator);
      end loop;

      return sn + h;
   end scheduling_period_1997;

   ---------------------------------------------------------------------
   -- Scheduling_Period_2012_2013
   ---------------------------------------------------------------------
   function scheduling_period_2012_2013
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Double
   is
      h                  : Double;
      op1                : Double;
      period             : Double;
      capacity           : Double;
      maximum_start_time : Double;
      my_iterator        : tasks_iterator;
      a_task             : generic_task_ptr;
   begin
      periodic_control (my_tasks, processor_name);

      h   := 1.0;
      op1 := 1.0;

      reset_iterator (my_tasks, my_iterator);
      maximum_start_time :=
        Double (max_start_time_of_taskset (my_tasks, processor_name));

      loop
         current_element (my_tasks, a_task, my_iterator);

         if a_task.cpu_name = processor_name and
           a_task.task_type = periodic_type
         then
            period   := Double (periodic_task_ptr (a_task).period);
            capacity := Double (a_task.capacity);

            h   := lcm (h, period);
            op1 := op1 * (capacity + 1.0);
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);
      end loop;

      return maximum_start_time + h * op1;
   end scheduling_period_2012_2013;

   ---------------------------------------------------------------------
   -- Scheduling_Period_2016
   -- Implementation Notes:
   -- -
   ---------------------------------------------------------------------
   function scheduling_period_2016
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Double
   is
      h           : Double;
      op1         : Double;
      op2         : Double;
      op3         : Double;
      op4         : Double;
      period      : Double;
      deadline    : Double;
      start_time  : Double;
      my_iterator : tasks_iterator;
      a_task      : generic_task_ptr;
   begin
      periodic_control (my_tasks, processor_name);

      h   := 1.0;
      op1 := 1.0;
      op2 := 1.0;

      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if a_task.cpu_name = processor_name and
           a_task.task_type = periodic_type
         then
            period     := Double (periodic_task_ptr (a_task).period);
            deadline   := Double (a_task.deadline);
            start_time := Double (a_task.start_time);

            h   := lcm (h, period);
            op3 := start_time + deadline - period + op2;
            op4 := op1;
            op1 := op4 * op3;
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);
      end loop;

      return op1 * h;
   end scheduling_period_2016;

   function scheduling_period_with_offset
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Double
   is
   begin
      return scheduling_period (my_tasks, processor_name);
   end scheduling_period_with_offset;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

   function scheduling_period
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Double
   is
      start_time : Integer := 0;

      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

      res : Double;

   begin

      -- Check if Tasks Are Periodic
      --
      periodic_control (my_tasks, processor_name);

      res := 1.0;

      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if
           (a_task.cpu_name = processor_name and
            a_task.task_type = periodic_type)
         then
            start_time := Natural'max (start_time, a_task.start_time);
            res := lcm (res, Double (periodic_task_ptr (a_task).period));
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);
      end loop;

      if start_time /= 0 then
         res := (res * 2.0) + Double (start_time);
      end if;

      return res;

   end scheduling_period;

   function scheduling_period
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Natural
   is
      period     : Natural := 1;
      start_time : Natural := 0;

      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

   begin

      -- Check if tasks are periodic
      --
      periodic_control (my_tasks, processor_name);

      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if
           (a_task.cpu_name = processor_name and
            a_task.task_type = periodic_type)
         then
            start_time := Natural'max (start_time, a_task.start_time);
            period     :=
              natural_util.lcm (period, periodic_task_ptr (a_task).period);
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);
      end loop;

      if start_time /= 0 then
         period := (period * 2) + start_time;
      end if;

      return period;

   end scheduling_period;

end feasibility_test.feasibility_interval;
