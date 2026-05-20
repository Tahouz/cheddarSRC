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
-- Frank Singhoff, Lab-STICC UMR CNRS 6285, Universite de Bretagne Occidentale
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

with xml_tag;     use xml_tag;
with double_util; use double_util;
with feasibility_test.processor_utilization;
use feasibility_test.processor_utilization;
with Text_IO;                  use Text_IO;
with translate;                use translate;
with unbounded_strings;        use unbounded_strings;
with scheduler;                use scheduler;
with Scheduling_Analysis;      use Scheduling_Analysis;
with Call_Framework_Interface; use Call_Framework_Interface;
with Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with priority_assignment.rm; use priority_assignment.rm;
with priority_assignment.dm; use priority_assignment.dm;
with systems;                use systems;
with cache_set;              use cache_set;
with Caches;                 use Caches;
with Caches;                 use Caches.Cache_Blocks_Table_Package;
with cache_access_profile_set;
use cache_access_profile_set.cache_access_profile_set;
with integer_arrays; use integer_arrays;
with sets;
with feasibility_test.memory_interferences;
use feasibility_test.memory_interferences;
with feasibility_test.cache_interferences;
use feasibility_test.cache_interferences;

with processor_set; use processor_set;
with Processors;    use Processors;
with Core_Units;    use Core_Units;
use Core_Units.Core_Units_Table_Package;

package body feasibility_test
  .periodic_task_worst_case_response_time_fixed_priority
  is

   procedure compute_response_time
     (my_scheduler              : in     rm_scheduler;
      my_sys                    : in     system;
      processor_name            : in     Unbounded_String;
      msg                       : in out Unbounded_String;
      response_time             :    out response_time_table;
      with_memory_interferences : in memory_interference_computation_approach_type :=
        no_memory_interference;
      with_crpd                : in crpd_computation_approach_type := no_crpd;
      block_reload_time        : in Natural                        := 0;
      my_cache_access_profiles : in cache_access_profiles_set      :=
        no_cache_access_profile)
   is
      the_cores       : core_units_table;
      a_processor     : generic_processor_ptr;
      processor_bound : Double := 1.0;
   begin

      -- check if tasks are periodic
      --
      periodic_control (my_sys.tasks, processor_name);

      -- check start time
      --
      start_time_control (my_sys.tasks, processor_name);

      -- check offset
      --
      offset_control (my_sys.tasks, processor_name);

      -- check if deadlines are equal  than period
      --
      have_deadlines_equal_than_periods_control (my_sys.tasks, processor_name);

      -- Check processor utilization first
      --
      a_processor     := search_processor (my_sys.processors, processor_name);
      the_cores       := build_core_table (a_processor);
      processor_bound := processor_bound * Double (the_cores.nb_entries);

      if
        (processor_utilization_over_period (my_sys.tasks, processor_name) >
         processor_bound)
      then
         raise processor_utilization_exceeded;
      end if;

      -- Compute response time
      --

      compute_response_time
        (fixed_priority_scheduler (my_scheduler),
         my_sys,
         processor_name,
         msg,
         response_time,
         with_memory_interferences,
         with_crpd,
         block_reload_time,
         my_cache_access_profiles);
   end compute_response_time;

   procedure compute_response_time
     (my_scheduler              : in     dm_scheduler;
      my_sys                    : in     system;
      processor_name            : in     Unbounded_String;
      msg                       : in out Unbounded_String;
      response_time             :    out response_time_table;
      with_memory_interferences : in memory_interference_computation_approach_type :=
        no_memory_interference;
      with_crpd                : in crpd_computation_approach_type := no_crpd;
      block_reload_time        : in Natural                        := 0;
      my_cache_access_profiles : in cache_access_profiles_set      :=
        no_cache_access_profile)
   is
      the_cores       : core_units_table;
      a_processor     : generic_processor_ptr;
      processor_bound : Double := 1.0;
   begin

      -- check if tasks are periodics
      --
      periodic_control (my_sys.tasks, processor_name);

      -- Check processor utilization first
      --
      a_processor := search_processor (my_sys.processors, processor_name);
      the_cores   := build_core_table (a_processor);

      processor_bound := processor_bound * Double (the_cores.nb_entries);

      if
        (processor_utilization_over_period (my_sys.tasks, processor_name) >
         processor_bound)
      then
         raise processor_utilization_exceeded;
      end if;

      -- check start time
      --
      start_time_control (my_sys.tasks, processor_name);

      -- check offset
      --
      offset_control (my_sys.tasks, processor_name);

      -- Compute response time
      --
      compute_response_time
        (fixed_priority_scheduler (my_scheduler),
         my_sys,
         processor_name,
         msg,
         response_time,
         with_memory_interferences,
         with_crpd,
         block_reload_time,
         my_cache_access_profiles);

   end compute_response_time;

   procedure compute_response_time
     (my_scheduler              : in     hpf_scheduler;
      my_sys                    : in     system;
      processor_name            : in     Unbounded_String;
      msg                       : in out Unbounded_String;
      response_time             :    out response_time_table;
      with_memory_interferences : in memory_interference_computation_approach_type :=
        no_memory_interference;
      with_crpd                : in crpd_computation_approach_type := no_crpd;
      block_reload_time        : in Natural                        := 0;
      my_cache_access_profiles : in cache_access_profiles_set      :=
        no_cache_access_profile)
   is
      the_cores       : core_units_table;
      a_processor     : generic_processor_ptr;
      processor_bound : Double := 1.0;
   begin

      -- Check if tasks are periodics
      --      Periodic_Control(My_sys.Tasks, Processor_Name);

      -- Check processor utilization first
      --
      a_processor := search_processor (my_sys.processors, processor_name);
      the_cores   := build_core_table (a_processor);

      processor_bound := processor_bound * Double (the_cores.nb_entries);

      if
        (processor_utilization_over_period (my_sys.tasks, processor_name) >
         processor_bound)
      then
         raise processor_utilization_exceeded;
      end if;

      -- Check start time
      --
      start_time_control (my_sys.tasks, processor_name);

      -- Check offset
      --
      offset_control (my_sys.tasks, processor_name);

      -- Compute response time
      --
      compute_response_time
        (fixed_priority_scheduler (my_scheduler),
         my_sys,
         processor_name,
         msg,
         response_time,
         with_memory_interferences,
         with_crpd,
         block_reload_time,
         my_cache_access_profiles);

   end compute_response_time;

   -- compute the value of level-i busy period
   --
   function compute_l
     (my_tasks     : in tasks_set;
      current_task : in generic_task_ptr) return Double
   is
      iterator2 : tasks_iterator;
      taskj2    : generic_task_ptr;
      ln, ln1   : Double;
   begin
      ln  := -0.1;
      ln1 := 1.0;
      while ln1 /= ln loop
         reset_iterator (my_tasks, iterator2);
         ln  := ln1;
         ln1 := 0.0;
         loop
            current_element (my_tasks, taskj2, iterator2);
            if (taskj2.priority >= current_task.priority) then
               ln1 :=
                 ln1 +
                 Double'ceiling
                     (ln / Double (periodic_task_ptr (taskj2).period)) *
                   Double (taskj2.capacity);
            end if;
            exit when is_last_element (my_tasks, iterator2);
            next_element (my_tasks, iterator2);
         end loop;
      end loop;
      return ln1;
   end compute_l;

   function compute_wiq_non_preemptive
     (my_tasks     : in tasks_set;        --all the task
      current_task : in generic_task_ptr; --the task examine
      q            : in Integer) return Double
   is
      iterator2                 : tasks_iterator;
      iterator3                 : tasks_iterator;
      taskk, taskj              : generic_task_ptr;
      ck, ck_tmp, wiq_k, wiq_k1 : Double;
   begin

      --initialization
      --
      wiq_k  := -0.1;
      wiq_k1 := 1.0;
      ck     := 0.0;
      ck_tmp := 0.0;

      -- approximations for Wiq
      -- exit loop when approximations converge
      --
      while wiq_k1 /= wiq_k loop
         reset_iterator (my_tasks, iterator2);
         wiq_k  := wiq_k1;
         wiq_k1 := Double (q * current_task.capacity);

         -- Iterate on all tasks
         --
         loop
            current_element (my_tasks, taskj, iterator2);

            -- If Taskj is in hp(Taski)
            --
            if (taskj.priority > current_task.priority) then
               wiq_k1 :=
                 wiq_k1 +
                 (Double'floor
                      (wiq_k / Double (periodic_task_ptr (taskj).period)) +
                    1.0) *
                   Double (taskj.capacity);
            end if;

            -- exit loop when there is no more task
            --
            exit when is_last_element (my_tasks, iterator2);
            next_element (my_tasks, iterator2);
         end loop;

         -- Compute the max{Ck-1}
         --
         loop
            current_element (my_tasks, taskk, iterator3);
            if (taskk.priority < current_task.priority) then
               ck_tmp := Double (taskk.capacity) - 1.0;
               if (ck_tmp > ck) then
                  ck := ck_tmp;
               end if;
            end if;
            exit when is_last_element (my_tasks, iterator3);
            next_element (my_tasks, iterator3);
         end loop;
         wiq_k1 := wiq_k1 + ck;

      end loop;
      return wiq_k1;
   end compute_wiq_non_preemptive;

   function compute_wiq_preemptive
     (my_tasks : in tasks_set;                         --all the task
      current_task : in generic_task_ptr;                  --the task examine
      q                        : in Integer;
      response_time : in response_time_table;               -- Response Time of higher priority task will be always computed
      with_crpd                : in crpd_computation_approach_type := no_crpd;
      block_reload_time        : in Natural                        := 0;
      my_cache_access_profiles : in cache_access_profiles_set      :=
        no_cache_access_profile)
      return Double
   is
      iterator2     : tasks_iterator;
      taskj         : generic_task_ptr;
      wiq_k, wiq_k1 : Double;

      a_cap       : cache_access_profile_ptr;
      gamma_ij    : Natural := 0;
      gamma_ucbum : Natural := 0;
      gamma_ecbum : Natural := 0;
   begin
      wiq_k  := -0.1;
      wiq_k1 := 0.0;

      -- approximations for Wiq
      -- exit loop when approximations converge
      while wiq_k1 /= wiq_k loop
         reset_iterator (my_tasks, iterator2);
         wiq_k  := wiq_k1;
         wiq_k1 :=
           Double
             ((q + 1) * current_task.capacity + current_task.blocking_time);
         -- Iterate on all tasks
         loop
            current_element (my_tasks, taskj, iterator2);
            -- If Taskj is in hp(Taski)
            if (taskj.priority > current_task.priority) then

               --
               -- CRPD Computation
               --
               if (with_crpd /= no_crpd) then
                  a_cap :=
                    search_cache_access_profile
                      (my_cache_access_profiles,
                       taskj.cache_access_profile_name);
                  -- Compute CRPD if task j preempting
                  if (with_crpd = ecb_only) then
                     gamma_ij :=
                       Natural (a_cap.ECBs.nb_entries) * block_reload_time;
                  elsif (with_crpd = ecb_union_multiset) then
                     gamma_ij :=
                       compute_gamma_ecb_union_multiset
                         (my_tasks                  => my_tasks,
                          task_i                    => current_task,
                          task_j                    => taskj,
                          response_time             => response_time,
                          wiq                       => wiq_k,
                          q                         => q,
                          crpd_computation_approach => with_crpd,
                          block_reload_time         => block_reload_time,
                          my_cache_access_profiles  =>
                            my_cache_access_profiles);
                  elsif (with_crpd = ucb_union_multiset) then
                     gamma_ij :=
                       compute_gamma_ucb_union_multiset
                         (my_tasks                  => my_tasks,
                          task_i                    => current_task,
                          task_j                    => taskj,
                          response_time             => response_time,
                          wiq                       => wiq_k,
                          q                         => q,
                          crpd_computation_approach => with_crpd,
                          block_reload_time         => block_reload_time,
                          my_cache_access_profiles  =>
                            my_cache_access_profiles);
                  elsif (with_crpd = combined_multiset) then
                     gamma_ucbum :=
                       compute_gamma_ucb_union_multiset
                         (my_tasks                  => my_tasks,
                          task_i                    => current_task,
                          task_j                    => taskj,
                          response_time             => response_time,
                          wiq                       => wiq_k,
                          q                         => q,
                          crpd_computation_approach => with_crpd,
                          block_reload_time         => block_reload_time,
                          my_cache_access_profiles  =>
                            my_cache_access_profiles);

                     gamma_ecbum :=
                       compute_gamma_ecb_union_multiset
                         (my_tasks                  => my_tasks,
                          task_i                    => current_task,
                          task_j                    => taskj,
                          response_time             => response_time,
                          wiq                       => wiq_k,
                          q                         => q,
                          crpd_computation_approach => with_crpd,
                          block_reload_time         => block_reload_time,
                          my_cache_access_profiles  =>
                            my_cache_access_profiles);
                     if (gamma_ecbum > gamma_ucbum) then
                        gamma_ij := gamma_ucbum;
                     else
                        gamma_ij := gamma_ecbum;
                     end if;
                  end if;
               end if;

               --
               --
               --
               wiq_k1 :=
                 wiq_k1 +
                 Double'ceiling
                     ((wiq_k + Double (periodic_task_ptr (taskj).jitter)) /
                      Double (periodic_task_ptr (taskj).period)) *
                   (Double (taskj.capacity) + Double (gamma_ij));

            end if;
            -- exit loop when there is no more task
            exit when is_last_element (my_tasks, iterator2);
            next_element (my_tasks, iterator2);
         end loop;
      end loop;
      return wiq_k1;
   end compute_wiq_preemptive;

   procedure compute_response_time
     (my_scheduler              : in     fixed_priority_scheduler;
      my_sys                    : in     system;
      processor_name            : in     Unbounded_String;
      msg                       : in out Unbounded_String;
      response_time             :    out response_time_table;
      with_memory_interferences : in memory_interference_computation_approach_type :=
        no_memory_interference;
      with_crpd                : in crpd_computation_approach_type := no_crpd;
      block_reload_time        : in Natural                        := 0;
      my_cache_access_profiles : in cache_access_profiles_set      :=
        no_cache_access_profile)
   is

      tmp                   : tasks_set;
      iterator1             : tasks_iterator;
      taski                 : generic_task_ptr;
      i                     : response_time_range := 0;
      li, q_double, wiq, ri : Double              := 0.0;
      min_delay             : Double              := 0.0;
      q_arrete, q           : Integer;

      the_cores   : core_units_table;
      a_processor : generic_processor_ptr;
   begin

      initialize (response_time);

      -- Verify cache access profiles
      --
      if (with_crpd /= no_crpd) then
         if (get_number_of_elements (my_cache_access_profiles) <= 0) then
            raise cache_access_profile_must_be_defined;
         elsif
           (Integer (get_number_of_elements (my_cache_access_profiles)) <
            Integer (get_number_of_elements (my_sys.tasks)))
         then
            raise cache_access_profile_must_be_defined_for_all_tasks;
         end if;
      end if;

      -- Bibliographical references
      --
      if (my_scheduler.parameters.preemptive_type = not_preemptive) then
         -- Non preemptive case
         --
         msg :=
           To_Unbounded_String (" (") &
           lb_see (Current_Language) &
           To_Unbounded_String ("[1], page 36, ") &
           lb_equation (Current_Language);
         msg := msg & To_Unbounded_String ("13). ");
      else
         -- Preemptive case
         --
         msg :=
           To_Unbounded_String (" (") &
           lb_see (Current_Language) &
           To_Unbounded_String ("[2], page 3, ") &
           lb_equation (Current_Language);
         msg := msg & To_Unbounded_String ("4). ");
      end if;

      current_processor_name := processor_name;

      a_processor := search_processor (my_sys.processors, processor_name);
      the_cores   := build_core_table (a_processor);

      -- get the task set of the processor processor_name in the monoproc case
      if a_processor.processor_type = monocore_type or
        a_processor.migration_type /= no_migration_type
      then
         select_and_copy (my_sys.tasks, tmp, select_cpu'access);
      end if;

      for core_index in 0 .. the_cores.nb_entries - 1 loop
         -- get the task set of the core core_index in the multiproc case
         if a_processor.processor_type /= monocore_type and
           a_processor.migration_type = no_migration_type
         then
            current_core_name := the_cores.entries (core_index).name;

            reset (tmp);
            select_and_copy (my_sys.tasks, tmp, select_core'access);
         end if;

         -- Set priority according to the scheduler
         --
         if
           (my_scheduler.parameters.scheduler_type =
            deadline_monotonic_protocol)
         then
            set_priority_according_to_dm (tmp);
         else
            if
              (my_scheduler.parameters.scheduler_type =
               rate_monotonic_protocol)
            then
               set_priority_according_to_rm (tmp);
            end if;
         end if;

         -- JLE : does not seem to be needed
         --sort (tmp, increasing_priority'access);

         -- Sort the task in decreasing priority
         -- Compute Response Time of the higher priority task first
         --
         sort (tmp, decreasing_priority'access);

         -- compute response time for each tasks
         --
         reset_iterator (tmp, iterator1);

         loop
            -- Selection of the current task
            --
            current_element (tmp, taski, iterator1);

            -- Initialize response time for current task
            --
            response_time.entries (i).data := 0.0;
            response_time.entries (i).item := taski;
            response_time.nb_entries       := response_time.nb_entries + 1;

            if (my_scheduler.parameters.preemptive_type = not_preemptive) then
               -- Find the maximum for Ri in [0..Q]
               --
               q  := 0;
               li := compute_l (tmp, taski);

               loop
                  q_double :=
                    Double'floor
                      (li / Double (periodic_task_ptr (taski).period));
                  q_arrete := Integer (q_double);
                  wiq      := compute_wiq_non_preemptive (tmp, taski, q);

                  --Ri = Wiq + Ci - qTi
                  --
                  ri :=
                    wiq +
                    Double (periodic_task_ptr (taski).capacity) -
                    Double (q) * Double (periodic_task_ptr (taski).period);

                  -- Is Ri greater than current maximum for Ri ?
                  --
                  if (ri > response_time.entries (i).data) then
                     response_time.entries (i).data := ri;
                  end if;

                  exit when q = q_arrete;
                  q := q + 1;
               end loop;
            else
               q := 0;
               loop
                  wiq :=
                    compute_wiq_preemptive
                      (tmp,
                       taski,
                       q,
                       response_time,
                       with_crpd,
                       block_reload_time,
                       my_cache_access_profiles);
                  case taski.task_type is
                     when periodic_type =>
                        ri :=
                          wiq +
                          Double (periodic_task_ptr (taski).jitter) -
                          Double (q) *
                            Double (periodic_task_ptr (taski).period);
                     when others =>
                        raise Constraint_Error;
                  end case;

                  if (with_memory_interferences /= no_memory_interference) then
                     min_delay := 0.0;
                     memory_interferences_delay
                       (min_delay,
                        ri,
                        taski,
                        my_sys,
                        processor_name);
                     ri := ri + min_delay;
                  end if;

                  -- Is Ri greater than current maximum for Ri ?
                  --
                  if (ri > response_time.entries (i).data) then
                     response_time.entries (i).data := ri;
                  end if;
                  exit when wiq <=
                    Double (q + 1) * Double (periodic_task_ptr (taski).period);
                  q := q + 1;
               end loop;
            end if;

            i := i + 1;
            exit when is_last_element (tmp, iterator1);

            next_element (tmp, iterator1);

         end loop;
      end loop;

   end compute_response_time;

end feasibility_test.periodic_task_worst_case_response_time_fixed_priority;
