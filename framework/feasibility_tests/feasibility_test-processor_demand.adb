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

with Ada.Exceptions; use Ada.Exceptions;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

with Resources;                         use Resources;
use Resources.Resource_Accesses;
with time_unit_events;                  use time_unit_events;
use time_unit_events.time_unit_package;
with natural_util;                      use natural_util;
with double_util;                       use double_util;
with integer_util;                      use integer_util;
with Objects;                           use Objects;
with Objects.extended;                  use Objects.extended;
with initialize_framework;              use initialize_framework;
with Text_IO;                           use Text_IO;
with translate;                         use translate;
with unbounded_strings;                 use unbounded_strings;
with scheduler;                         use scheduler;
with Scheduling_Analysis;               use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with priority_assignment.rm;            use priority_assignment.rm;
with priority_assignment.dm;            use priority_assignment.dm;
with systems;                           use systems;
with xml_tag;                           use xml_tag;
with translate;                         use translate;
with scheduler.dynamic_priority;        use scheduler.dynamic_priority;
with feasibility_test.processor_utilization;
use feasibility_test.processor_utilization;
with debug;                             use debug;

package body feasibility_test.processor_demand is

   ---------------------------------------------------------------------
   -- Max_Deadlirnbe_Of_TaskSet
   -- Implementation Notes:
   -- S. Rubini
   -- should already exist somewhere ?
   ---------------------------------------------------------------------
   function max_deadline_of_taskset
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Natural
   is
      max_deadline : Natural := 0;
      my_iterator  : tasks_iterator;
      a_task       : generic_task_ptr;
   begin
      reset_iterator (my_tasks, my_iterator);
      loop
         current_element (my_tasks, a_task, my_iterator);
         if (a_task.cpu_name = processor_name) then
            max_deadline := Natural'max (max_deadline, a_task.deadline);
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);
      end loop;

      return max_deadline;
   end max_deadline_of_taskset;

   ---------------------------------------------------------------------
   -- Has_A_Deadline_Less_Than_Period
   -- Implementation Notes:
   --  S. Rubini 11/2018
   --  Check whether a task has a deadline after its period time
   ---------------------------------------------------------------------
   function has_a_deadline_less_than_period
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Boolean
   is
      my_iterator               : tasks_iterator;
      a_task                    : generic_task_ptr;
      deadline_less_than_period : Boolean;

   begin

      deadline_less_than_period := False;
      reset_iterator (my_tasks, my_iterator);
      loop
         current_element (my_tasks, a_task, my_iterator);
         if
           (a_task.cpu_name = processor_name and
            a_task.task_type /= aperiodic_type)
         then
            if (periodic_task_ptr (a_task).period > a_task.deadline) then
               deadline_less_than_period := True;
            end if;
         end if;
         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;

      return deadline_less_than_period;

   end has_a_deadline_less_than_period;

   ------------------------------------------------------------------
   -- Processor_Utilization_Over_Period applies on periodic tasks only.
   --
   function processor_utilization_over_period_without_periodic_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Double
   is
      utilization : Double := 0.0;

      my_iterator : tasks_iterator;
      a_task      : generic_task_ptr;

   begin

      -- Check if tasks are periodics
      --
      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if (a_task.cpu_name = processor_name) then
            if a_task.task_type /= aperiodic_type then
               utilization :=
                 utilization +
                 (Double (a_task.capacity) /
                  Double (periodic_task_ptr (a_task).period));
            end if;

         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);

      end loop;

      return utilization;

   end processor_utilization_over_period_without_periodic_control;

   ------------------------------------------------------------------
   -- Processor_Utilization_Over_Period applies on periodic tasks only.
   --
   function compute_hyperperiod_without_periodic_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String := empty_string) return Integer
   is
      iterator1   : tasks_iterator;
      task1       : generic_task_ptr;
      hyperperiod : Integer := 1;
   begin

      reset_iterator (my_tasks, iterator1);
      loop
         current_element (my_tasks, task1, iterator1);

         if (task1.cpu_name = processor_name) or
           (processor_name = empty_string)
         then
            hyperperiod :=
              natural_util.lcm (hyperperiod, periodic_task_ptr (task1).period);
         end if;

         exit when is_last_element (my_tasks, iterator1);
         next_element (my_tasks, iterator1);
      end loop;

      return hyperperiod;
   end compute_hyperperiod_without_periodic_control;

   ---------------------------------------------------------------------
   -- Sporadic_Periodic_Task_Set_Feasibility_Test
   -- Implementation Notes:
   --  S. Rubini 11/2018
   ---------------------------------------------------------------------

   procedure sporadic_periodic_task_set_feasibility_test
     (my_scheduler   : in     generic_scheduler_ptr;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out feasibility_test_report)
   is

      bound                   : Double           := 0.0;
      utilpi                  : Double           := 0.0;
      check_time_interval     : Integer          := 0;     -- T in the algo
      tighten_deadline        : Integer          := 0;
      dbf                     : Integer          := 0;
      m                       : Integer          := 0;     -- M in the algo
      msg                     : Unbounded_String := empty_string;
      my_iterator             : tasks_iterator;
      a_task                  : generic_task_ptr;
      over_cpu_demand         : Boolean          := False;
      over_cpu_demand_instant : Natural;

   begin
      -- TODO Hyp C < P and C < D

      -- offsets and start must be 0
      start_time_control (my_tasks, processor_name);
      offset_control (my_tasks, processor_name);

      -- sporadic or periodic tasks
      sporadic_or_periodic_control (my_tasks, processor_name);

      -- report init
      result.feasible              := False;
      result.motivation            := unknown;
      result.processor_utilization := 0.0; -- unknown
      result.check_interval        := 0;  -- unknown
      result.overrun_time          := 0;  -- unknown

      -- for EDF preeemptive schedule
      if my_scheduler.parameters.scheduler_type /=
        earliest_deadline_first_protocol or
        get_preemptive (my_scheduler.all) /= preemptive
      then
         raise invalid_scheduler;
      end if;

      -- classical test based on processor utilization <= 1
      bound_on_processor_utilization
        (dynamic_priority_scheduler (my_scheduler.all),
         my_tasks,
         processor_name,
         bound,
         msg);
      utilpi :=
        processor_utilization_over_period_without_periodic_control
          (my_tasks,
           processor_name);

      if utilpi > bound then -- Bound value should be one for EDF scheduler
         result.feasible                    := False;
         result.motivation                  := by_processor_utilization_factor;
         result.processor_utilization       := utilpi;
         result.processor_utilization_bound := bound;
      else
         -- check if all the deadlines are after interarrival time or period
         if has_a_deadline_less_than_period (my_tasks, processor_name) =
           False
         then
            result.feasible                    := True;
            result.motivation := by_processor_utilization_factor;
            result.processor_utilization       := utilpi;
            result.processor_utilization_bound := bound;
         else
            -- No constraints on deadlines versus period
            -- compute check interval T
            --   P=  lcm+max deadline
            m :=
              compute_hyperperiod_without_periodic_control
                (my_tasks,
                 processor_name) +
              max_deadline_of_taskset (my_tasks, processor_name);

            -- We have tested before that Uilpi <=1
            -- avoid 0 divisor later,
            if utilpi = 1.0 then
               check_time_interval := m;
            else
               tighten_deadline := 0;
               reset_iterator (my_tasks, my_iterator);
               loop
                  current_element (my_tasks, a_task, my_iterator);
                  if a_task.cpu_name = processor_name then
                     tighten_deadline :=
                       Natural'max
                         (tighten_deadline,
                          periodic_task_ptr (a_task).period - a_task.deadline);
                  end if;

                  exit when is_last_element (my_tasks, my_iterator);
                  next_element (my_tasks, my_iterator);
               end loop;
               check_time_interval :=
                 Natural'min
                   (m,
                    Natural
                      (utilpi / (1.0 - utilpi) * Double (tighten_deadline)));
            end if;

            -- compute the dbf at all instant of the check_time_interval
            dbf             := 0;
            over_cpu_demand := False;
            for t in 1 .. check_time_interval loop
               update_demand_bound_function (my_tasks, processor_name, t, dbf);
               if dbf > t then
                  over_cpu_demand         := True;
                  over_cpu_demand_instant := t;
               end if;
               exit when over_cpu_demand;   -- too much CPU demand
            end loop;
            if over_cpu_demand then
               result.feasible                    := False;
               result.motivation                  := by_dbf;
               result.processor_utilization       := utilpi;
               result.processor_utilization_bound := bound;
               result.overrun_time                := over_cpu_demand_instant;
               result.check_interval              := check_time_interval;
            else
               result.feasible                    := True;
               result.motivation                  := by_dbf;
               result.processor_utilization       := utilpi;
               result.processor_utilization_bound := bound;
               result.check_interval              := check_time_interval;
            end if;
         end if;
      end if;

   end sporadic_periodic_task_set_feasibility_test;

   procedure update_demand_bound_function
     (my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      t              : in     Natural;
      dbf            : in out Natural)
   is
      my_iterator           : tasks_iterator;
      a_task                : generic_task_ptr;
      release_relative_time : Natural;

   begin

      reset_iterator (my_tasks, my_iterator);
      loop
         current_element (my_tasks, a_task, my_iterator);
         if a_task.cpu_name = processor_name then
            release_relative_time := t mod periodic_task_ptr (a_task).period;
            if t >= a_task.deadline and
              t mod periodic_task_ptr (a_task).period =
                a_task.deadline mod periodic_task_ptr (a_task).period
            then
               dbf := dbf + a_task.capacity;
               put_debug ("Dbf at t" & t'img & " is " & dbf'img);
            end if;
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);
      end loop;

   end update_demand_bound_function;

end feasibility_test.processor_demand;
