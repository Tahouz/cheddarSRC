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
--    $Rev: 5452 $
--    $Date: 2025-03-19 22:39:16 +0100 (mer., 19 mars 2025) $
--    $Author: nam $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Text_IO;        use Text_IO;
with Ada.Exceptions; use Ada.Exceptions;
with GNAT.Spitbol.Patterns;

with Offsets;        use Offsets;
with Offsets;        use Offsets.Offsets_Table_Package;
with Buffers.extended;                  use Buffers.extended;
with Dependencies;   use Dependencies;
with Caches;         use Caches;
with cache_set;      use cache_set;
use cache_set.generic_cache_set;
with Caches;          use Caches.Cache_Blocks_Table_Package;
with cache_block_set; use cache_block_set;
with cache_access_profile_set;
use cache_access_profile_set.cache_access_profile_set;

with unbounded_strings;                 use unbounded_strings;
with debug;                             use debug;

with expressions;    use expressions;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
with cache_utility;                     use cache_utility;
with qs_tools;       use qs_tools;
with scheduling_anomalies_services.online;
use scheduling_anomalies_services.online;
with voltage_scaling; use voltage_scaling;
with scheduler.mixed_criticality.quality_amc;
use scheduler.mixed_criticality.quality_amc;
with scheduler.mixed_criticality.amc;
use scheduler.mixed_criticality.amc;
with scheduler.mixed_criticality;
use scheduler.mixed_criticality;
with tables;


package body scheduler is

   procedure put (my_scheduler : in generic_scheduler_ptr) is
   begin
      put (my_scheduler.all);
   end put;

   function export_aadl_properties
     (my_scheduler : in generic_scheduler;
      number_of_ht : in Natural) return Unbounded_String
   is
      result : Unbounded_String := empty_string;

   begin

      for i in 1 .. number_of_ht loop
         result := result & ASCII.HT;
      end loop;

      result :=
        result &
        To_Unbounded_String
          ("Scheduling_Protocol => " &
           To_String (get_name (my_scheduler)) &
           ";") &
        unbounded_lf;

      for i in 1 .. number_of_ht loop
         result := result & ASCII.HT;
      end loop;

      result :=
        result &
        To_Unbounded_String
          ("Cheddar_Properties::Scheduler_Quantum => " &
           get_quantum (my_scheduler) &
           " ms ;") &
        unbounded_lf;

      for i in 1 .. number_of_ht loop
         result := result & ASCII.HT;
      end loop;

      if get_preemptive (my_scheduler) = preemptive then
         result :=
           result &
           To_Unbounded_String
             ("Cheddar_Properties::Preemptive_Scheduler => True;") &
           unbounded_lf;
      else
         result :=
           result &
           To_Unbounded_String
             ("Cheddar_Properties::Preemptive_Scheduler => False;") &
           unbounded_lf;
      end if;

      return result;

   end export_aadl_properties;

   procedure set_preemptive
     (my_scheduler : in out generic_scheduler'class;
      preempt      : in     preemptives_type)
   is
   begin
      my_scheduler.parameters.preemptive_type := preempt;
   end set_preemptive;

   function get_preemptive
     (my_scheduler : in generic_scheduler'class) return preemptives_type
   is
   begin
      return my_scheduler.parameters.preemptive_type;
   end get_preemptive;

   function get_preemptive
     (my_scheduler : in generic_scheduler'class) return String
   is
   begin
      return my_scheduler.parameters.preemptive_type'img;
   end get_preemptive;

   procedure put (my_scheduler : in generic_scheduler) is
   begin
      Put (my_scheduler.parameters);
   end put;

   procedure reset (a_scheduler : in out generic_scheduler'class) is
   begin
      Initialize (a_scheduler.parameters);
   end reset;

   function get_name
     (my_scheduler : in generic_scheduler'class) return Unbounded_String
   is
   begin
      return To_Unbounded_String (my_scheduler.parameters.scheduler_type'img);
   end get_name;

   function get_name
     (my_scheduler : in generic_scheduler_ptr) return Unbounded_String
   is
   begin
      return get_name (my_scheduler.all);
   end get_name;

   function get_name
     (my_scheduler : in generic_scheduler'class) return schedulers_type
   is
   begin
      return my_scheduler.parameters.scheduler_type;
   end get_name;

   function get_name
     (my_scheduler : in generic_scheduler_ptr) return schedulers_type
   is
   begin
      return get_name (my_scheduler.all);
   end get_name;

   function build_tcb
     (my_scheduler : in generic_scheduler;
      a_task       :    generic_task_ptr) return tcb_ptr
   is
      a_tcb : tcb_ptr;
   begin
      a_tcb := new tcb;
      initialize (a_tcb.all, a_task);
      return a_tcb;
   end build_tcb;

   procedure initialize (a_pcb : in out pcb; a_processor : generic_processor_ptr) is 
begin
      a_pcb.cpu := a_processor;
      a_pcb.is_idle:=false;
end initialize;


   procedure initialize (a_tcb : in out tcb; a_task : generic_task_ptr) is
      seed : Generator;
   begin
      a_tcb.tsk                 := a_task;
      a_tcb.activation          := 1;
      a_tcb.activation_end_time := 0;
      a_tcb.used_cpu            := 0;
      a_tcb.wake_up_time        := a_tcb.tsk.start_time;
      a_tcb.outer_wake_up_time  := a_tcb.tsk.start_time;
      a_tcb.rest_of_capacity    := a_tcb.tsk.capacity;
      a_tcb.used_capacity       := 0;
      a_tcb.suspended           := False;
      a_tcb.crpd_capacity       := 0;
      a_tcb.ucbs_loaded         := 0.0;
      a_tcb.block_reload_time   := 1;

      if (a_tcb.tsk.task_type = poisson_type) or
        (a_tcb.tsk.task_type = parametric_type)
      then
         if (poisson_task_ptr (a_tcb.tsk).predictable) then
            Reset (seed, poisson_task_ptr (a_tcb.tsk).seed);
         else
            Reset (seed);
         end if;

         Save (seed, a_tcb.task_seed);
      end if;
   end initialize;

   procedure processor_initialization
     (my_scheduler             : in out generic_scheduler'class;
      si                       : in out scheduling_information;
      processor_name           : in     Unbounded_String;
      my_tasks                 : in out tasks_set;
      my_resources             : in out resources_set;
      my_buffers               : in out buffers_set;
      result                   : in out scheduling_sequence_ptr;
      options                  : in     scheduling_option;
      given_last_time          : in     Natural;
      event_to_generate        : in     time_unit_event_type_boolean_table;
      my_cache_access_profiles : in     cache_access_profiles_set;
      my_caches                : in     caches_set)
   is

      iterator1     : tasks_iterator;
      iterator2     : resources_iterator;
      a_buffer_size : buffer_scheduling_information_ptr;
      iterator3     : buffers_iterator;
      a_buffer      : buffer_ptr;
      a_task        : generic_task_ptr;
      a_resource    : generic_resource_ptr;
      seed          : Generator;
      a_item        : time_unit_event_ptr;
      a_cache       : generic_cache_ptr;
      a_cap         : cache_access_profile_ptr;

      -- Parameter to take into account voltage scaling analysis
      --
      speed : Integer := 1;

   begin

      if (options.predictable_global_seed) then
         Reset (seed, options.global_seed_value);
      else
         Reset (seed);
      end if;

      Save (seed, si.global_seed);

      -- Build Task Control Blocks
      --
      reset_iterator (my_tasks, iterator1);

      loop
         current_element (my_tasks, a_task, iterator1);

         si.tcbs (si.number_of_tasks) := build_tcb (my_scheduler, a_task);

         si.number_of_tasks := si.number_of_tasks + 1;

         exit when is_last_element (my_tasks, iterator1);
         next_element (my_tasks, iterator1);
      end loop;

      -- Build of buffer list with their current size
      -- (in order to generate Write/Read buffer events
      --
      if (options.with_precedencies) then
         if (get_number_of_elements (my_buffers) > 0) then

            reset_iterator (my_buffers, iterator3);
            loop

               current_element (my_buffers, a_buffer, iterator3);

               a_buffer_size := new buffer_scheduling_information;
               a_buffer_size.written_buffer := a_buffer;
               a_buffer_size.current_size := a_buffer.buffer_initial_data_size;
               add (si.written_buffers, a_buffer_size);

               exit when is_last_element (my_buffers, iterator3);
               next_element (my_buffers, iterator3);

            end loop;
         end if;
      end if;

      if (options.with_resources) then
         if (get_number_of_elements (my_resources) > 0) then

            reset_iterator (my_resources, iterator2);
            loop

               current_element (my_resources, a_resource, iterator2);

               si.shared_resources (si.number_of_resources) :=
                 build_resource (my_scheduler, a_resource);

               si.number_of_resources := si.number_of_resources + 1;

               exit when is_last_element (my_resources, iterator2);
               next_element (my_resources, iterator2);

            end loop;
         end if;
      end if;

      -- Initialize event table (store the computed scheduling)
      --
      initialize (result.all);

      -- First activation for all tasks
      --
      for i in 0 .. si.number_of_tasks - 1 loop

         if si.tcbs (i).tsk.cpu_name = processor_name then

            if event_to_generate (task_activation) then
               produce_task_activation_event
                 (my_scheduler,
                  si.tcbs (i),
                  options,
                  si,
                  a_item);
               if (options.with_dvfs) then
                  dvfs_upon_task_release
                    (a_item,
                     si.tcbs (i).tsk.start_time,
                     speed);
                  my_scheduler.corresponding_core_unit.speed := speed;
               end if;
               add (result.all, si.tcbs (i).tsk.start_time, a_item);
            end if;

         end if;

      end loop;

      if (options.with_crpd) then
         if (get_number_of_elements (my_caches) > 0) then
            if (get_number_of_elements (my_cache_access_profiles) <= 0) then
               raise cache_access_profile_must_be_defined;
            elsif
              (Integer (get_number_of_elements (my_cache_access_profiles)) <
               Integer (si.number_of_tasks))
            then
               raise cache_access_profile_must_be_defined_for_all_tasks;
            end if;

            for i in 0 .. si.number_of_tasks - 1 loop
               initialize (si.tcbs (tasks_range (i)).ucbs);
               initialize (si.tcbs (tasks_range (i)).ecbs);
               initialize (si.tcbs (tasks_range (i)).ucbs_in_cache);
               si.tcbs (tasks_range (i)).crpd_capacity := 0;

               -- Block reload time is associated to a Tcb in scheduling simulation
               -- We do not take into account task migration in CRPD-Aware scheduling simulation
               --
               a_cache :=
                 search_cache
                   (my_caches => my_caches,
                    name      =>
                      my_scheduler.corresponding_core_unit
                        .l1_cache_system_name);
               si.tcbs (tasks_range (i)).block_reload_time :=
                 a_cache.block_reload_time;

               a_cap :=
                 search_cache_access_profile
                   (my_cache_access_profiles,
                    si.tcbs (tasks_range (i)).tsk.cache_access_profile_name);

               for j in 0 .. a_cap.UCBs.nb_entries - 1 loop
                  add
                    (si.tcbs (tasks_range (i)).ucbs,
                     a_cap.UCBs.entries (j).cache_block_number);
                  add
                    (si.tcbs (tasks_range (i)).ucbs_in_cache,
                     a_cap.UCBs.entries (j).cache_block_number);
               end loop;

               put_debug
                 ("Cache Access Profile: " & a_cap.ECBs.nb_entries'img);

               for j in 0 .. a_cap.ECBs.nb_entries - 1 loop
                  add
                    (si.tcbs (tasks_range (i)).ecbs,
                     a_cap.ECBs.entries (j).cache_block_number);
               end loop;
            end loop;
         end if;
      end if;

   end processor_initialization;

   procedure core_unit_initialization
     (my_scheduler      : in out generic_scheduler'class;
      si                : in out scheduling_information;
      processor_name    : in     Unbounded_String;
      my_tasks          : in out tasks_set;
      my_resources      : in out resources_set;
      my_buffers        : in out buffers_set;
      result            : in out scheduling_sequence_ptr;
      options           : in     scheduling_option;
      given_last_time   : in     Natural;
      event_to_generate : in     time_unit_event_type_boolean_table)
   is

   begin

      my_scheduler.previously_elected                     := tasks_range'first;
      my_scheduler.previous_running_task_is_not_completed := False;

   end core_unit_initialization;

   procedure update_after_core_scheduling
     (my_scheduler      : in out generic_scheduler'class;
      processor_name    : in     Unbounded_String;
      si                : in out scheduling_information;
      my_dependencies   : in     tasks_dependencies_ptr;
      elected           : in     tasks_range;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      last_time         : in     Natural;
      options           : in     scheduling_option;
      event_to_generate : in     time_unit_event_type_boolean_table)

   is
   begin
      ------------------------------------------------------
      -- Update variables for multi core scheduling
      ------------------------------------------------------

      -- Assign the task to the current core unit and put it
      -- in the already run state
      --
      si.tcbs (elected).assigned_core_unit :=
        my_scheduler.corresponding_core_unit;
      si.tcbs (elected).already_run_at_current_time := True;

      if options.with_resources then
         allocate_resource
           (my_scheduler,
            si,
            result,
            current_time,
            si.tcbs (elected),
            event_to_generate);
      end if;

   end update_after_core_scheduling;

   procedure update_after_processor_scheduling
     (my_scheduler      : in out generic_scheduler'class;
      processor_name    : in     Unbounded_String;
      si                : in out scheduling_information;
      my_dependencies   : in     tasks_dependencies_ptr;
      elected           : in     tasks_range;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      last_time         : in     Natural;
      options           : in     scheduling_option;
      event_to_generate : in     time_unit_event_type_boolean_table)

   is
      a_item : time_unit_event_ptr;
   begin

      put_debug
        ("Call Update_Task_Simulation_Data_And_Produce_Events ",
         very_verbose);

      if options.with_resources then
      -- We may notice that some runnable tasks were blocked due to
      -- shared resource ... in this case, we generate the corresponding event
         --
         for i in 0 .. si.number_of_tasks - 1 loop
            if (si.tcbs (i).wait_for_a_resource /= null) then
               put_debug
                 (To_String (si.tcbs (i).tsk.name) &
                  " : generate wait_for_event_resource " &
                  To_String (si.tcbs (i).wait_for_a_resource.name));
               if event_to_generate (wait_for_resource) then
                  a_item := new time_unit_event (wait_for_resource);
                  a_item.wait_for_resource := si.tcbs (i).wait_for_a_resource;
                  a_item.wait_for_resource_task := si.tcbs (i).tsk;
                  add (result.all, current_time, a_item);
               end if;
            end if;
         end loop;
      end if;

   end update_after_processor_scheduling;

   procedure update_after_processor_scheduling_when_task_is_run
     (my_scheduler      : in out generic_scheduler'class;
      processor_name    : in     Unbounded_String;
      si                : in out scheduling_information;
      my_dependencies   : in     tasks_dependencies_ptr;
      elected           : in     tasks_range;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      last_time         : in     Natural;
      options           : in     scheduling_option;
      event_to_generate : in     time_unit_event_type_boolean_table)

   is
      a_item : time_unit_event_ptr;

      -- CRPD analysis
      --
      crpd         : Integer                := 0;
      crpd_u       : Integer                := 0;
      crpd_ecb     : Integer                := 0;
      evicted_ucbs : Integer                := 0;
      flag         : Boolean;
      comp_model   : crpd_computation_model := c_ue;

      -- Parameter for scheduling anomaly analysis
      --
      inp  : handler_input_parameter;
      outp : handler_output_parameter;

      -- Parameter to take into account voltage scaling analysis
      --
      speed : Integer := 1;

   begin

      put_debug
        ("Call Update_Task_Simulation_Data_And_Produce_Events_when_task_is_run ",
         very_verbose);

      ------------------------------------------------------
      -- Allocate/release shared resources
      -- and produce associated events
      ------------------------------------------------------

      if options.with_resources then
         release_resource
           (my_scheduler,
            si,
            result,
            current_time,
            si.tcbs (elected),
            event_to_generate);

      end if;

      ------------------------------------------------------
      -- Send/Receive Messages
      -- write/read on buffers
      -- and produce associated events
      ------------------------------------------------------

      if options.with_precedencies then
         send_message
           (my_scheduler,
            si,
            result,
            current_time,
            si.tcbs (elected),
            event_to_generate);

         receive_message
           (my_scheduler,
            si,
            result,
            current_time,
            si.tcbs (elected),
            event_to_generate);

         buffer_write
           (my_scheduler,
            si,
            result,
            current_time,
            si.tcbs (elected),
            event_to_generate);

         buffer_read
           (my_scheduler,
            si,
            result,
            current_time,
            si.tcbs (elected),
            event_to_generate);

      end if;

      ------------------------------------------------------
      -- CRPD
      --
      ------------------------------------------------------
      if (options.with_crpd) then
         crpd         := 0;
         evicted_ucbs := 0;
         flag         := False;

      -----------------------------------------------------------------------
         --Handling event START OF TASK CAPACITY
      -----------------------------------------------------------------------
         if
           (si.tcbs (elected).rest_of_capacity =
            si.tcbs (elected).tsk.capacity and
            si.tcbs (elected).used_capacity = 0)
         then

            cache_utility.fill_tasks_ucbs_in_cache (si.tcbs (elected));
            si.tcbs (elected).ucbs_loaded := 0.0;

            put_debug
              (current_time'img &
               ": Start of task capacity:" &
               To_String (si.tcbs (elected).tsk.name));
            for i in 0 .. si.number_of_tasks - 1 loop
               if
                 (si.tcbs (i).rest_of_capacity > 0 and
                  si.tcbs (i).wake_up_time +
                      si.tcbs (i).tsk.offsets.entries (0).offset_value <
                    current_time and
                  i /= elected)
               then
                  put_debug
                    ("Incompleted tasks: " &
                     To_String (si.tcbs (i).tsk.name) &
                     ", ");
               end if;
            end loop;
            --
         end if;

      -----------------------------------------------------------------------
         --Handling event RUNNING TASK
         --    + The number of actual UCB in cache is tracked
         --    by Si.Tcbs(Elected).UCBs_Loaded
         --
      -----------------------------------------------------------------------
         if (comp_model = c_ue) then
            crpd := cache_utility.compute_crpd (si.tcbs (elected));

         elsif (comp_model = c_ue_lim) then
            crpd := cache_utility.compute_crpd (si.tcbs (elected));
            if (crpd > Integer (si.tcbs (elected).ucbs_loaded)) then
               crpd := Integer (si.tcbs (elected).ucbs_loaded);
               si.tcbs (elected).ucbs_loaded := 0.0;
            else
               si.tcbs (elected).ucbs_loaded :=
                 si.tcbs (elected).ucbs_loaded - Float (crpd);
            end if;
         end if;

         -- Block Reload Time is taken into account when we have identified all the UCB evicted;
         --
         crpd := crpd * si.tcbs (elected).block_reload_time;

         if (crpd > 0) then
            put_debug
              (current_time'img &
               ": Preemption cost:" &
               To_String (si.tcbs (elected).tsk.name & " -" & crpd'img));
            si.total_preemption_cost := si.total_preemption_cost + crpd;
            si.tcbs (elected).rest_of_capacity :=
              si.tcbs (elected).rest_of_capacity + crpd;
            si.tcbs (elected).crpd_capacity :=
              si.tcbs (elected).crpd_capacity + crpd;
         end if;

         cache_utility.fill_tasks_ucbs_in_cache (si.tcbs (elected));

         if
           (si.tcbs (elected).ucbs_loaded <
            Float (si.tcbs (elected).ucbs.size))
         then
            -- Supress the warning
            -- (for more convenient when coding in gnatstudio)
            pragma warnings (Off, "*universal_fixed*");
            si.tcbs (elected).ucbs_loaded :=
              si.tcbs (elected).ucbs_loaded +
              Float (1.0 / si.tcbs (elected).block_reload_time);
            pragma warnings (On, "*universal_fixed*");
         end if;

      -----------------------------------------------------------------------
         --Handling event PREEMPTION
         --    + When perform scheduling simulation with CRPD,
         --    A PREEMPTION event is generated for EACH preempted task !
         --
      -----------------------------------------------------------------------
         if (my_scheduler.previously_elected /= elected) then

            for i in 0 .. si.number_of_tasks - 1 loop
               if
                 (tasks_range (i) /= elected and
                  si.tcbs (tasks_range (i)).tsk.cpu_name =
                    si.tcbs (elected).tsk.cpu_name and
                  si.tcbs (tasks_range (i)).rest_of_capacity > 0 and
                  si.tcbs (tasks_range (i)).used_capacity > 0 and
                  si.tcbs (tasks_range (i)).wake_up_time < current_time)
               then

                  for j in 0 .. si.tcbs (elected).ecbs.size - 1 loop
                     if
                       (remove_by_value
                          (si.tcbs (tasks_range (i)).ucbs_in_cache,
                           si.tcbs (elected).ecbs.elements (j)))
                     then
                        evicted_ucbs := evicted_ucbs + 1;
                     end if;
                  end loop;

                  if (event_to_generate (preemption)) then
                     a_item := new time_unit_event (preemption);
                     a_item.preempting_task := si.tcbs (elected).tsk;
                     a_item.preempted_task  := si.tcbs (tasks_range (i)).tsk;
                     a_item.evicted_ucbs    := evicted_ucbs;
                     add (result.all, current_time, a_item);
                  end if;

                  flag := True;
               end if;
            end loop;

            if (flag) then
               si.number_of_preemption := si.number_of_preemption + 1;
            end if;
         end if;
      end if;

      ---------------------------------------------------------
      -- Update task properties and produce associated events
      ---------------------------------------------------------
      --
      -- Produce events
      --
      if event_to_generate (start_of_task_capacity) then
         if si.tcbs (elected).rest_of_capacity =
           si.tcbs (elected).tsk.capacity
         then
            produce_start_of_task_capacity_event
              (my_scheduler,
               si.tcbs (elected),
               options,
               si,
               a_item);
            if (options.with_anomaly_detection) then
               inp.event        := a_item;
               inp.runtime_data := si;
               inp.current_time := current_time;
               scheduling_anomaly_handler (inp, my_scheduler, outp);
            end if;
            add (result.all, current_time, a_item);
         end if;
      end if;

      if event_to_generate (running_task) then
         produce_running_task_event
           (my_scheduler,
            si.tcbs (elected),
            options,
            si,
            a_item);
         if (options.with_anomaly_detection) then
            inp.event        := a_item;
            inp.runtime_data := si;
            inp.current_time := current_time;
            scheduling_anomaly_handler (inp, my_scheduler, outp);
         end if;
         if (options.with_dvfs) then
            dvfs_upon_running_task (a_item, current_time, speed);
            my_scheduler.corresponding_core_unit.speed := speed;
         end if;
         add (result.all, current_time, a_item);
      end if;

      if event_to_generate (end_of_task_capacity) then
         if si.tcbs (elected).rest_of_capacity - 1 = 0 then
            produce_end_of_task_capacity_event
              (my_scheduler,
               si.tcbs (elected),
               options,
               si,
               a_item);
            if (options.with_anomaly_detection) then
               inp.event        := a_item;
               inp.runtime_data := si;
               inp.current_time := current_time;
               scheduling_anomaly_handler (inp, my_scheduler, outp);
            end if;
            if (options.with_dvfs) then
               dvfs_upon_task_completion (a_item, current_time, speed);
               my_scheduler.corresponding_core_unit.speed := speed;
            end if;
            add (result.all, current_time + 1, a_item);
         end if;
      end if;

      if (event_to_generate (preemption) and (not options.with_crpd)) then
         if (my_scheduler.previously_elected /= elected) then

            for i in 0 .. si.number_of_tasks - 1 loop
               if
                 (tasks_range (i) /= elected and
                  si.tcbs (tasks_range (i)).tsk.cpu_name =
                    si.tcbs (elected).tsk.cpu_name and
                  si.tcbs (tasks_range (i)).rest_of_capacity > 0 and
                  si.tcbs (tasks_range (i)).used_capacity > 0 and
                  si.tcbs (tasks_range (i)).wake_up_time < current_time)
               then

                  a_item                 := new time_unit_event (preemption);
                  a_item.preempting_task := si.tcbs (elected).tsk;
                  a_item.preempted_task  := si.tcbs (tasks_range (i)).tsk;
                  a_item.evicted_ucbs    := 0;
                  if (options.with_anomaly_detection) then
                     inp.event        := a_item;
                     inp.runtime_data := si;
                     inp.current_time := current_time;
                     scheduling_anomaly_handler (inp, my_scheduler, outp);
                  end if;
                  add (result.all, current_time, a_item);

                  flag := True;
               end if;

               exit when flag = True;
            end loop;

            if (flag) then
               si.number_of_preemption := si.number_of_preemption + 1;
            end if;
         end if;
      end if;

      -- Update task properties
      --

      -- update of various simulation times related to capacities
      --
      si.tcbs (elected).used_capacity :=
        si.tcbs (elected).used_capacity +
        my_scheduler.corresponding_core_unit.speed;

      if
        (si.tcbs (elected).rest_of_capacity -
         my_scheduler.corresponding_core_unit.speed <
         0)
      then
         si.tcbs (elected).rest_of_capacity := 0;
      else
         si.tcbs (elected).rest_of_capacity :=
           si.tcbs (elected).rest_of_capacity -
           my_scheduler.corresponding_core_unit.speed;
      end if;

      si.tcbs (elected).used_cpu :=
        si.tcbs (elected).used_cpu +
        my_scheduler.corresponding_core_unit.speed;

   -- crpd_capacity is used to draw the CRPD portion in the scheduling diagram
   -- We assume that a tasks must "pay" its CRPD first.
   -- CRPD is also added to the remaining capacity.
   -- (detailed in Tran et al., 2021 article)
      --
      if (si.tcbs (elected).crpd_capacity > 0) then
         if
           (si.tcbs (elected).crpd_capacity -
            my_scheduler.corresponding_core_unit.speed <
            0)
         then
            si.tcbs (elected).crpd_capacity := 0;
         else
            si.tcbs (elected).crpd_capacity :=
              si.tcbs (elected).crpd_capacity -
              my_scheduler.corresponding_core_unit.speed;
         end if;
      end if;

      -- The task is not assigned anymore to a core unit
      --
      my_scheduler.previous_running_task_is_not_completed := True;
      if (si.tcbs (elected).rest_of_capacity = 0) then
         si.tcbs (elected).assigned_core_unit                := null;
         my_scheduler.previous_running_task_is_not_completed := False;
      end if;

      --
      -- Compute the next task activations
      --
      if (si.tcbs (elected).rest_of_capacity = 0) then

         si.tcbs (elected).activation_end_time := current_time + 1;

         if (si.tcbs (elected).tsk.task_type /= aperiodic_type) then

            if
              (periodic_task_ptr (si.tcbs (elected).tsk).completion_time =
               0) or
              (periodic_task_ptr (si.tcbs (elected).tsk).completion_time >
               si.tcbs (elected).wake_up_time +
                 periodic_task_ptr (si.tcbs (elected).tsk).period)
            then
               compute_next_task_activation
                 (my_scheduler,
                  si.tcbs (elected),
                  si,
                  options,
                  elected);

               -- Add to the scheduling table the next activation time
               --
               if event_to_generate (task_activation) then

                  if
                    (si.tcbs (elected).tsk.task_type /= aperiodic_type and
                     si.tcbs (elected).wake_up_time <= last_time)
                  then
                     produce_task_activation_event
                       (my_scheduler,
                        si.tcbs (elected),
                        options,
                        si,
                        a_item);
                     if (options.with_dvfs) then
                        dvfs_upon_task_release
                          (a_item,
                           si.tcbs (elected).wake_up_time,
                           speed);
                        my_scheduler.corresponding_core_unit.speed := speed;
                     end if;
                     add (result.all, si.tcbs (elected).wake_up_time, a_item);
                  end if;
               end if;
            end if;
         end if;

      end if;

      -- Store the previous ran task
      --
      my_scheduler.previously_elected := elected;

   end update_after_processor_scheduling_when_task_is_run;

   procedure compute_next_task_activation
     (my_scheduler : in out generic_scheduler'class;
      a_tcb        : in     tcb_ptr;
      si           : in out scheduling_information;
      options      : in     scheduling_option;
      elected      : in     tasks_range)
   is
   	
      -- For Poisson Process task
      --
      seed : Generator;
      temp : Natural;

      -- For Parametric task
      --
      parametric_delay : Natural := 0;
      
      -- For Mixed criticality task
      --
      temp_capacity 		: Natural;
      is_mixed_criticality 	: Boolean := False;
      state 			: mode_range;
      Ci_HI    		: Natural;
      dc			: Natural;

   begin
      a_tcb.used_capacity := 0;
      a_tcb.activation    := a_tcb.activation + 1;
      if get_name(my_scheduler) = mixed_criticality_quality_amc_protocol
      then
      	state := mixed_criticality_quality_amc_scheduler(my_scheduler).state;
      	is_mixed_criticality := True;
      elsif get_name(my_scheduler) = mixed_criticality_amc_protocol
      then
      	state := mixed_criticality_amc_scheduler(my_scheduler).state;
      	is_mixed_criticality := True;
      end if;
      
     
      
      if is_mixed_criticality
      then
	-- reset completion time
	mixed_criticality_tcb_ptr (a_tcb).completion_time := 0;
	mixed_criticality_tcb_ptr (a_tcb).is_execution_continue := False;
	
	
	Reset (seed, a_tcb.task_seed);
	
	-- variables
	dc := mixed_criticality_tcb_ptr(a_tcb).current_dc_value;
	Ci_HI := mixed_criticality_tcb_ptr(a_tcb).current_capacities.entries(2).values_eu;
		 	
	-- Random draw of a number between DC and C(HI)
	--
	temp_capacity := Box_Muller_Normal2(dc,Ci_HI,seed);
	
	--put_debug("[Release] task"&elected'img&", nb release:"&a_tcb.activation'img&" Valeur simulée entre DC :"&dc'img&" et C(HI) :"&Ci_HI'img&" = "&temp_capacity'img & " avec C(LO) :"&mixed_criticality_tcb_ptr(a_tcb).current_capacities.entries(0).values_eu'img,Minimal);
	Save (seed, a_tcb.task_seed);
	
	--if mixed_criticality_tcb_ptr (a_tcb).tsk.priority = 2 then
      	--	temp_capacity := 12;
      	--end if; 
      else
      		temp_capacity := a_tcb.tsk.capacity;
      		
      end if;
      
      case a_tcb.tsk.task_type is

         when periodic_type =>
            a_tcb.rest_of_capacity := temp_capacity;
            a_tcb.wake_up_time     :=
              a_tcb.wake_up_time + periodic_task_ptr (a_tcb.tsk).period;

         when timed_type =>
            a_tcb.rest_of_capacity := a_tcb.tsk.capacity;
            a_tcb.wake_up_time     :=
              a_tcb.wake_up_time + timed_task_ptr (a_tcb.tsk).period;

         when poisson_type =>
            a_tcb.rest_of_capacity := a_tcb.tsk.capacity;

            if options.with_task_specific_seed then
               Reset (seed, a_tcb.task_seed);
            else
               Reset (seed, si.global_seed);
            end if;

            temp :=
              Natural
                (get_exponential_time
                   (Double (poisson_task_ptr (a_tcb.tsk).period),
                    seed));

            a_tcb.wake_up_time := a_tcb.wake_up_time + temp;

            if options.with_task_specific_seed then
               Save (seed, a_tcb.task_seed);
            else
               Save (seed, si.global_seed);
            end if;

         when sporadic_type =>
            a_tcb.rest_of_capacity := temp_capacity;

            if options.with_task_specific_seed then
               Reset (seed, a_tcb.task_seed);
            else
               Reset (seed, si.global_seed);
            end if;

            temp :=
              Natural
                (get_exponential_time
                   (Double (poisson_task_ptr (a_tcb.tsk).period),
                    seed));

            a_tcb.wake_up_time :=
              a_tcb.wake_up_time +
              Natural'max (temp, periodic_task_ptr (a_tcb.tsk).period);

            if options.with_task_specific_seed then
               Save (seed, a_tcb.task_seed);
            else
               Save (seed, si.global_seed);
            end if;

         when periodic_inner_periodic_type =>
            a_tcb.rest_of_capacity := a_tcb.tsk.capacity;
            if (a_tcb.wake_up_time + periodic_task_ptr (a_tcb.tsk).period) >=
              a_tcb.outer_wake_up_time +
                periodic_inner_periodic_task_ptr (a_tcb.tsk).outer_duration
            then
               a_tcb.outer_wake_up_time :=
                 a_tcb.outer_wake_up_time +
                 periodic_inner_periodic_task_ptr (a_tcb.tsk).outer_period;
               a_tcb.wake_up_time := a_tcb.outer_wake_up_time;
            else
               a_tcb.wake_up_time :=
                 a_tcb.wake_up_time + periodic_task_ptr (a_tcb.tsk).period;
            end if;

         when sporadic_inner_periodic_type =>
            a_tcb.rest_of_capacity := a_tcb.tsk.capacity;

            if options.with_task_specific_seed then
               Reset (seed, a_tcb.task_seed);
            else
               Reset (seed, si.global_seed);
            end if;

            temp :=
              Natural
                (get_exponential_time
                   (Double
                      (sporadic_inner_periodic_task_ptr (a_tcb.tsk)
                         .outer_period),
                    seed));
            temp :=
              Natural'max
                (temp,
                 sporadic_inner_periodic_task_ptr (a_tcb.tsk).outer_period);

            if (a_tcb.wake_up_time + periodic_task_ptr (a_tcb.tsk).period) >=
              a_tcb.outer_wake_up_time +
                sporadic_inner_periodic_task_ptr (a_tcb.tsk).outer_duration
            then
               a_tcb.outer_wake_up_time := a_tcb.outer_wake_up_time + temp;
               a_tcb.wake_up_time       := a_tcb.outer_wake_up_time;
            else
               a_tcb.wake_up_time :=
                 a_tcb.wake_up_time + periodic_task_ptr (a_tcb.tsk).period;
            end if;

            if options.with_task_specific_seed then
               Save (seed, a_tcb.task_seed);
            else
               Save (seed, si.global_seed);
            end if;

         when aperiodic_type =>
            null;

         when scheduling_task_type =>
            null;

         when parametric_type =>
            a_tcb.rest_of_capacity := a_tcb.tsk.capacity;

            -- The scheduler has to be a parametric one !!!
            --
            if
              (my_scheduler.parameters.scheduler_type /=
               pipeline_user_defined_protocol) and
              (my_scheduler.parameters.scheduler_type /=
               compiled_user_defined_protocol) and
              (my_scheduler.parameters.scheduler_type /=
               automata_user_defined_protocol)
            then
               Raise_Exception
                 (statement_error'identity,
                  "User-defined task only permitted with user-defined schedulers");
            end if;

            compute_activation_time
              (my_scheduler,
               si,
               elected,
               parametric_delay);

            a_tcb.wake_up_time := a_tcb.wake_up_time + parametric_delay;
         when frame_task_type =>
            a_tcb.rest_of_capacity := a_tcb.tsk.capacity;
            a_tcb.wake_up_time     :=
              a_tcb.wake_up_time + frame_task_ptr (a_tcb.tsk).period;

      end case;

   end compute_next_task_activation;

   -- Return true is the task "a_tcb" can be schedule now
   -- according its jitter
   --
   procedure check_jitter
     (a_tcb    : in     tcb_ptr;
      at_time  : in     Natural;
      is_ready :    out Boolean)

   is

      seed : Generator;
      temp : Natural;

   begin

      is_ready := True;

      if (a_tcb.tsk.task_type = sporadic_type) or
        (a_tcb.tsk.task_type = periodic_type) or
        (a_tcb.tsk.task_type = poisson_type)
      then
         if periodic_task_ptr (a_tcb.tsk).jitter /= 0 then
            if (a_tcb.tsk.capacity = a_tcb.rest_of_capacity) then

               Reset (seed, a_tcb.task_seed);
               temp :=
                 Natural'min
                   (periodic_task_ptr (a_tcb.tsk).jitter,
                    Natural
                      (get_exponential_time
                         (Double (periodic_task_ptr (a_tcb.tsk).jitter),
                          seed)));
               if a_tcb.wake_up_time + temp > at_time then
                  is_ready := False;
               else
                  is_ready := True;
               end if;
               Save (seed, a_tcb.task_seed);

            end if;
         end if;
      end if;

   end check_jitter;

   -- Return true is the task "a_tcb" can be schedule now
   -- according its offsets
   --
   function check_offset (a_tcb : tcb_ptr; at_time : Natural) return Boolean is
      target_time : Integer := 0;
   begin

      for k in 0 .. a_tcb.tsk.offsets.nb_entries - 1 loop
         if (a_tcb.tsk.offsets.entries (k).activation = a_tcb.activation) or
           (a_tcb.tsk.offsets.entries (k).activation = 0)
         then
            target_time :=
              a_tcb.wake_up_time + a_tcb.tsk.offsets.entries (k).offset_value;
            if at_time < target_time then
               return False;
            end if;
         end if;
      end loop;

      return True;
   end check_offset;




   procedure send_message
     (my_scheduler      : in out generic_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             :        tcb_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table)
   is

      a_item                           : time_unit_event_ptr;
      my_iterator                      : tasks_dependencies_iterator;
      a_half_dep_ptr                   : dependency_ptr;
      a_message                        : generic_message_ptr;
      a_message_scheduling_information : message_scheduling_information_ptr;

   begin

      -- is the time to send message ?
      --
      if (a_tcb.rest_of_capacity = 1) then

         -- Check if the task has a message to send
         --
         if not is_empty (si.dependencies.depends) then
            reset_iterator (si.dependencies.depends, my_iterator);
            loop
               current_element
                 (si.dependencies.depends,
                  a_half_dep_ptr,
                  my_iterator);

               -- Is the task concerned ?
               -- Is it a TDMA or asynchronous communication dependency ?
               -- Is it a sending operation ?
               --
               if
                 (a_half_dep_ptr.type_of_dependency =
                  asynchronous_communication_dependency)
               then
                  if
                    (a_half_dep_ptr.asynchronous_communication_dependent_task
                       .name =
                     a_tcb.tsk.name) and
                    (a_half_dep_ptr.asynchronous_communication_orientation =
                     from_task_to_object)
                  then
                     a_message :=
                       Copy
                         (a_half_dep_ptr
                            .asynchronous_communication_dependency_object);

                     a_message_scheduling_information :=
                       new message_scheduling_information;
                     a_message_scheduling_information.status := message_is_sent;
                     a_message_scheduling_information.time :=
                       current_time + 1;
                     a_message_scheduling_information.exchanged_message :=
                       a_message;
                     add
                       (si.exchanged_messages,
                        a_message_scheduling_information);
                     if event_to_generate (send_message) then
                        a_item := new time_unit_event (send_message);
                        a_item.send_message := a_message;
                        a_item.send_task    := a_tcb.tsk;
                        add
                          (result.all,
                           a_message_scheduling_information.time,
                           a_item);
                     end if;
                  end if;
               end if;


               if
                 (a_half_dep_ptr.type_of_dependency =
                  tdma_communication_dependency)
               then
                  if
                    (a_half_dep_ptr.tdma_communication_dependent_task
                       .name =
                     a_tcb.tsk.name) and
                    (a_half_dep_ptr.tdma_communication_orientation =
                     from_task_to_object)
                  then
                     a_message :=
                       Copy
                         (a_half_dep_ptr
                            .tdma_communication_dependency_object);

                     a_message_scheduling_information :=
                       new message_scheduling_information;

 if not si.empty_tdma_frame then
                      if is_emitter_present(si.tdma_frame, si.current_tdma_slot, a_tcb.tsk.name) 
then a_message_scheduling_information.status := message_is_sent;
else a_message_scheduling_information.status := message_is_waiting_for_arbitration;
end if;
end if;

                     a_message_scheduling_information.time :=
                       current_time + 1;
                     a_message_scheduling_information.exchanged_message :=
                       a_message;
                     add
                       (si.exchanged_messages,
                        a_message_scheduling_information);
                     if event_to_generate (send_message) then
                        a_item := new time_unit_event (send_message);
                        a_item.send_message := a_message;
                        a_item.send_task    := a_tcb.tsk;
                        a_item.send_status    := a_message_scheduling_information.status;
                        add
                          (result.all,
                           a_message_scheduling_information.time,
                           a_item);
                     end if;
               end if;
               end if;

               exit when is_last_element
                   (si.dependencies.depends,
                    my_iterator);

               next_element (si.dependencies.depends, my_iterator);

            end loop;
         end if;
      end if;
   end send_message;

   procedure receive_message
     (my_scheduler      : in out generic_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             :        tcb_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table)
   is

      a_item         : time_unit_event_ptr;
      my_iterator    : tasks_dependencies_iterator;
      a_half_dep_ptr : dependency_ptr;
      a_message      : generic_message_ptr;
      list_ite       : message_scheduling_information_iterator;
      msg            : message_scheduling_information_ptr;
      to_receive     : boolean :=false;

      procedure check_sent_messages(the_dep : in Dependency_Type) is 
      begin
          -- Check the exchanged_messages to see if this
          -- messages was already sent
          --
          -- Is it the right message ?
          -- Is the message arrived at the receiving processor ?
          --
          if not is_empty (si.exchanged_messages) then
               reset_head_iterator (si.exchanged_messages, list_ite);
               loop
                   current_element (si.exchanged_messages, msg, list_ite);

                    if (msg.status=message_is_sent) then
                     if (msg.exchanged_message.name = a_message.name) then

			to_receive:=false;
		        case the_dep is 
                          when asynchronous_communication_dependency =>
				if (current_time >= (msg.time + a_message.response_time - 1)) then to_receive:=true;
				end if;
 
                          when tdma_communication_dependency => 
                    	     if not si.empty_tdma_frame then
                      		if is_emitter_present(si.tdma_frame, si.current_tdma_slot, a_tcb.tsk.name) 
				   and (current_time > msg.time) then to_receive:=true;
                                end if; 
                             end if; 
			  when others => null;
		       end case;


                       if to_receive
                              then

                                 if event_to_generate (receive_message) then
                                    a_item :=
                                      new time_unit_event (receive_message);
                                    a_item.receive_message := a_message;
                                    a_item.receive_task    := a_tcb.tsk;
                                    add (result.all, current_time, a_item);
                                 end if;

                                 -- Delete received message
                                 --
                                 delete (si.exchanged_messages, msg);
                                 exit;
                              end if;
                           end if;

                       end if;
                           if is_tail_element
                               (si.exchanged_messages,
                                list_ite)
                           then
                              exit;
                           end if;
                           next_element (si.exchanged_messages, list_ite);
                        end loop;
        end if;
      end check_sent_messages;



   begin

      -- Is The time to receive a message ?
      --
      if (a_tcb.rest_of_capacity = a_tcb.tsk.capacity) then

         -- Check the exchanged_messages to see if this
         -- messages was already sent
         --
         if not is_empty (si.exchanged_messages) then

            reset_iterator (si.dependencies.depends, my_iterator);
            loop
               current_element
                 (si.dependencies.depends,
                  a_half_dep_ptr,
                  my_iterator);

               -- Is the task concerned ?
               -- Is it a TDMA or an asynchronous communication dependency ?
               -- Is it a receiving operation ?
               --
               if
                 (a_half_dep_ptr.type_of_dependency =
                  tdma_communication_dependency)
               then
                  if
                    (a_half_dep_ptr.tdma_communication_dependent_task
                       .name =
                     a_tcb.tsk.name) and
                    (a_half_dep_ptr.tdma_communication_orientation =
                     from_object_to_task)
                  then
                     a_message :=
                       a_half_dep_ptr
                         .tdma_communication_dependency_object;
		     check_sent_messages(a_half_dep_ptr.type_of_dependency);
                  end if;
               end if;

               if
                 (a_half_dep_ptr.type_of_dependency =
                  asynchronous_communication_dependency)
               then
                  if
                    (a_half_dep_ptr.asynchronous_communication_dependent_task
                       .name =
                     a_tcb.tsk.name) and
                    (a_half_dep_ptr.asynchronous_communication_orientation =
                     from_object_to_task)
                  then
                     a_message :=
                       a_half_dep_ptr
                         .asynchronous_communication_dependency_object;
		     check_sent_messages(a_half_dep_ptr.type_of_dependency);
                  end if;
               end if;

               exit when is_last_element
                   (si.dependencies.depends,
                    my_iterator);

               next_element (si.dependencies.depends, my_iterator);

            end loop;

         end if;
      end if;

   end receive_message;

   procedure buffer_read
     (my_scheduler      : in out generic_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             :        tcb_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table)
   is

      a_item         : time_unit_event_ptr;
      my_iterator    : tasks_dependencies_iterator;
      a_half_dep_ptr : dependency_ptr;
      a_buffer       : buffer_ptr;
      a_buffer_size  : buffer_scheduling_information_ptr;
      list_ite       : buffer_scheduling_information_iterator;
      read_size      : Integer := 0;
   begin

      -- Check if the task has a buffer to write
      --
      if (has_buffer_to_read (si.dependencies, a_tcb.tsk)) then

         -- for all tasks which have a precedency with the current task
         --
         loop

            current_element
              (si.dependencies.depends,
               a_half_dep_ptr,
               my_iterator);
            if
              (a_half_dep_ptr.type_of_dependency = queueing_buffer_dependency)
            then

               if
                 (a_half_dep_ptr.buffer_dependent_task.name =
                  a_tcb.tsk.name) and
                 (a_half_dep_ptr.buffer_orientation = from_object_to_task)
               then

                  a_buffer := a_half_dep_ptr.buffer_dependency_object;
                  -- Must we generate Read event ?
                  --
                  if event_to_generate (read_from_buffer) then

                     for i in 0 .. a_buffer.roles.nb_entries - 1 loop
                        -- Is the right task ?
                        --
                        if
                          (a_buffer.roles.entries (i).item = a_tcb.tsk.name)
                        then

                           -- Is it time to read ?
                           --
                           if
                             (a_buffer.roles.entries (i).data.time =
                              (a_tcb.tsk.capacity +
                               1 -
                               a_tcb.rest_of_capacity))
                           then

                              -- Does the task is consumer ?
                              --
                              if
                                (a_buffer.roles.entries (i).data.the_role =
                                 queuing_consumer or
                                 a_buffer.roles.entries (i).data.the_role =
                                   ucsdf_consumer)
                              then

                                 -- Can we find some information to read ?
                                 --
                                 if not is_empty (si.written_buffers) then

                                    reset_head_iterator
                                      (si.written_buffers,
                                       list_ite);
                                    loop
                                       current_element
                                         (si.written_buffers,
                                          a_buffer_size,
                                          list_ite);

                                       if
                                         (a_buffer_size.written_buffer.name =
                                          a_buffer.name)
                                       then
                                          -- Compute the read data size
                                          --
                                          if
                                            (a_buffer.roles.entries (i).data
                                               .the_role =
                                             queuing_consumer)
                                          then
                                             read_size :=
                                               a_buffer.roles.entries (i).data
                                                 .size;
                                          elsif
                                            (a_buffer.roles.entries (i).data
                                               .the_role =
                                             ucsdf_consumer)
                                          then
                                             read_size :=
                                               get_data_size
                                                 (To_String
                                                    (a_buffer.roles.entries (i)
                                                       .data
                                                       .amplitude_function),
                                                  a_tcb.activation);
                                          end if;

                                          -- Do we have enough data to read
                                          --
                                          if
                                            (a_buffer_size.current_size >=
                                             read_size)
                                          then
                                             -- If yes, produce a read event
                                             a_item :=
                                               new time_unit_event
                                               (read_from_buffer);
                                             a_item.read_buffer := a_buffer;
                                             a_item.read_task   := a_tcb.tsk;
                                             a_item.read_size   := read_size;
                                             a_item
                                               .read_buffer_current_data_size :=
                                               a_buffer_size.current_size;
                                             add
                                               (result.all,
                                                current_time,
                                                a_item);

                                             -- Update buffer current data size
                                             a_buffer_size.current_size :=
                                               a_buffer_size.current_size -
                                               read_size;
                                             exit;
                                          else
                              -- If not, produce an underflow event
                              -- No update is done on buffer current data size
                                             a_item :=
                                               new time_unit_event
                                               (buffer_underflow);
                                             a_item.underflow_buffer :=
                                               a_buffer;
                                             a_item.underflow_task :=
                                               a_tcb.tsk;
                                             a_item.underflow_read_size :=
                                               read_size;
                                             a_item
                                               .underflow_buffer_current_data_size :=
                                               a_buffer_size.current_size;
                                             add
                                               (result.all,
                                                current_time,
                                                a_item);
                                             exit;
                                          end if;
                                       end if;

                                       if is_tail_element
                                           (si.written_buffers,
                                            list_ite)
                                       then
                                          exit;
                                       end if;
                                       next_element
                                         (si.written_buffers,
                                          list_ite);
                                    end loop;
                                 end if;
                              end if;
                           end if;
                        end if;
                     end loop;
                  end if;
               end if;
            end if;

            exit when is_last_element (si.dependencies.depends, my_iterator);

            next_element (si.dependencies.depends, my_iterator);

         end loop;

      end if;

   end buffer_read;

   procedure buffer_write
     (my_scheduler      : in out generic_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             :        tcb_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table)
   is

      a_item         : time_unit_event_ptr;
      my_iterator    : tasks_dependencies_iterator;
      a_half_dep_ptr : dependency_ptr;
      a_buffer       : buffer_ptr;
      a_buffer_size  : buffer_scheduling_information_ptr;
      list_ite       : buffer_scheduling_information_iterator;
      write_size     : Integer := 0;
   begin

      -- Check if the task has a buffer to write
      --
      if (has_buffer_to_write (si.dependencies, a_tcb.tsk)) then

         -- for all tasks which have a precedency with the current task
         --
         loop
            current_element
              (si.dependencies.depends,
               a_half_dep_ptr,
               my_iterator);

            if
              (a_half_dep_ptr.type_of_dependency = queueing_buffer_dependency)
            then

               if
                 (a_half_dep_ptr.buffer_dependent_task.name =
                  a_tcb.tsk.name) and
                 (a_half_dep_ptr.buffer_orientation = from_task_to_object)
               then

                  a_buffer := a_half_dep_ptr.buffer_dependency_object;

                  -- Must we generate Write event ?
                  --
                  if event_to_generate (write_to_buffer) then

                     for i in 0 .. a_buffer.roles.nb_entries - 1 loop

                        -- Is the right task ?
                        --
                        if
                          (a_buffer.roles.entries (i).item = a_tcb.tsk.name)
                        then
                           -- Does the task is producer ?
                           --
                           if
                             (a_buffer.roles.entries (i).data.the_role =
                              queuing_producer or
                              a_buffer.roles.entries (i).data.the_role =
                                ucsdf_producer)
                           then

                              -- Is it time to write ?
                              --
                              if
                                (a_buffer.roles.entries (i).data.time =
                                 (a_tcb.tsk.capacity +
                                  1 -
                                  a_tcb.rest_of_capacity))
                              then

                                 -- Add the size write event to the buffer list
                                 --
                                 if not is_empty (si.written_buffers) then

                                    reset_head_iterator
                                      (si.written_buffers,
                                       list_ite);
                                    loop

                                       current_element
                                         (si.written_buffers,
                                          a_buffer_size,
                                          list_ite);

                                       if a_buffer_size.written_buffer.name =
                                         a_buffer.name
                                       then
                                          -- Compute the write data size
                                          --
                                          if
                                            (a_buffer.roles.entries (i).data
                                               .the_role =
                                             queuing_producer)
                                          then
                                             write_size :=
                                               a_buffer.roles.entries (i).data
                                                 .size;
                                             put_debug
                                               ("Task name :" &
                                                a_tcb.tsk.name &
                                                " | Write size: " &
                                                write_size'img);
                                          elsif
                                            (a_buffer.roles.entries (i).data
                                               .the_role =
                                             ucsdf_producer)
                                          then
                                             put_debug
                                               ("Amp Function: " &
                                                To_String
                                                  (a_buffer.roles.entries (i)
                                                     .data
                                                     .amplitude_function));
                                             write_size :=
                                               get_data_size
                                                 (To_String
                                                    (a_buffer.roles.entries (i)
                                                       .data
                                                       .amplitude_function),
                                                  a_tcb.activation);
                                          end if;

                                       -- Check if we can write to the buffer
                                          --
                                          if
                                            (a_buffer_size.written_buffer
                                               .buffer_size >=
                                             a_buffer_size.current_size +
                                               write_size)
                                          then
               -- If yes, produce a write event and update buffer current size
                                             a_item :=
                                               new time_unit_event
                                               (write_to_buffer);
                                             a_item.write_buffer := a_buffer;
                                             a_item.write_task   := a_tcb.tsk;
                                             a_item.write_size   := write_size;
                                             a_item
                                               .write_buffer_current_data_size :=
                                               a_buffer_size.current_size;
                                             add
                                               (result.all,
                                                current_time,
                                                a_item);

                                             a_buffer_size.current_size :=
                                               a_buffer_size.current_size +
                                               write_size;
                                             exit;
                                          else
                                          -- If no, produce an overflow event
                                             a_item :=
                                               new time_unit_event
                                               (buffer_overflow);
                                             a_item.overflow_buffer :=
                                               a_buffer;
                                             a_item.overflow_task := a_tcb.tsk;
                                             a_item.overflow_write_size :=
                                               write_size;
                                             a_item
                                               .overflow_buffer_current_data_size :=
                                               a_buffer_size.current_size;
                                             add
                                               (result.all,
                                                current_time,
                                                a_item);
                                             exit;
                                          end if;
                                       end if;

                                       if is_tail_element
                                           (si.written_buffers,
                                            list_ite)
                                       then
                                          exit;
                                       end if;
                                       next_element
                                         (si.written_buffers,
                                          list_ite);

                                    end loop;
                                 end if;
                              end if;
                           end if;
                        end if;
                     end loop;
                  end if;

               end if;
            end if;

            exit when is_last_element (si.dependencies.depends, my_iterator);

            next_element (si.dependencies.depends, my_iterator);

         end loop;

      end if;

      -- Free objects
      --
   end buffer_write;

   procedure release_resource
     (my_scheduler      : in out generic_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             :        tcb_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table)
   is

      current_capacity : Natural := 0;
      a_item           : time_unit_event_ptr;

   begin

      if (si.number_of_resources > 0) then
         current_capacity := a_tcb.tsk.capacity - a_tcb.rest_of_capacity + 1;

         for index1 in 0 .. si.number_of_resources - 1 loop

            -- For each resource, check if the task hold resources
            -- and then release them
            --
            for index2 in
              0 ..
                  si.shared_resources (index1).shared.critical_sections
                    .nb_entries -
                  1
            loop

              
            -- Must be a Wait of a Mutex critical section
            --
            if (si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .data
                    .task_synchronization = mutex) 
             or
               (si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .data
                    .task_synchronization = wait)  then


            -- Must be at a critical section end and for the right task name
            --
               if
                 (current_capacity =
                  si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .data
                    .task_end) and
                 (si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .item =
                  a_tcb.tsk.name)
               then

                  si.shared_resources (index1).shared.state :=
                    si.shared_resources (index1).shared.state + 1;
                  for i in 0 .. si.shared_resources (index1).nb_allocated - 1
                  loop
                     if si.shared_resources (index1).allocated_by (i) =
                       a_tcb.tsk.name
                     then

                        si.shared_resources (index1).allocated_by (i) :=
                          si.shared_resources (index1).allocated_by
                            (si.shared_resources (index1).nb_allocated - 1);
                        si.shared_resources (index1).nb_allocated :=
                          si.shared_resources (index1).nb_allocated - 1;

                        if event_to_generate (release_resource) then
                           a_item := new time_unit_event (release_resource);
                           a_item.release_resource :=
                             si.shared_resources (index1).shared;
                           a_item.release_task := a_tcb.tsk;
                           add (result.all, current_time, a_item);
                        end if;

                        exit;
                     end if;
                  end loop;
		end if;
               end if;

            end loop;

         end loop;
      end if;
   end release_resource;

   procedure allocate_resource
     (my_scheduler      : in out generic_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             :        tcb_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table)
   is

      current_capacity : Natural := 0;
      a_item           : time_unit_event_ptr;

   begin

      if (si.number_of_resources > 0) then
         current_capacity := a_tcb.tsk.capacity - a_tcb.rest_of_capacity + 1;

         for index1 in 0 .. si.number_of_resources - 1 loop

            -- For each resource, check if the task request the resource
            -- and if the resource is free
            -- otherwise, block the task
            --
            for index2 in
              0 ..
                  si.shared_resources (index1).shared.critical_sections
                    .nb_entries -
                  1
            loop


            -- Must be a Wait of a Mutex critical section
            --
            if (si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .data
                    .task_synchronization = mutex)
             or
               (si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .data
                    .task_synchronization = wait)  then

            -- Must be at a critical section begin and for the right task name
            --
               if
                 (current_capacity =
                  si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .data
                    .task_begin) and
                 (si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .item =
                  a_tcb.tsk.name)
               then

                  si.shared_resources (index1).shared.state :=
                    si.shared_resources (index1).shared.state - 1;

                  si.shared_resources (index1).allocated_by
                    (si.shared_resources (index1).nb_allocated) :=
                    a_tcb.tsk.name;
                  si.shared_resources (index1).nb_allocated :=
                    si.shared_resources (index1).nb_allocated + 1;

                  if event_to_generate (allocate_resource) then
                     a_item := new time_unit_event (allocate_resource);
                     a_item.allocate_resource :=
                       si.shared_resources (index1).shared;
                     a_item.allocate_task := a_tcb.tsk;
                     add (result.all, current_time, a_item);
                  end if;

               end if;
		end if;
            end loop;

         end loop;
      end if;
   end allocate_resource;

   procedure check_resource
     (my_scheduler      : in out generic_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             : in     tcb_ptr;
      is_ready          :    out Boolean;
      event_to_generate : in     time_unit_event_type_boolean_table)
   is
      current_capacity : Natural := 0;
   begin

      is_ready := True;

      if (si.number_of_resources > 0) then

         current_capacity := a_tcb.tsk.capacity - a_tcb.rest_of_capacity + 1;

         for index1 in 0 .. si.number_of_resources - 1 loop

            -- For each resource, check if the task request the resource
            -- and if the resource is free
            --
            for index2 in
              0 ..
                  si.shared_resources (index1).shared.critical_sections
                    .nb_entries -
                  1
            loop

            -- Must be a Wait of a Mutex critical section
            --
            if (si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .data
                    .task_synchronization = mutex) 
             or
               (si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .data
                    .task_synchronization = wait)  then

            -- Must be at a critical section begin  and for the right task name
            --
               if
                 (current_capacity =
                  si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .data
                    .task_begin) and
                 (si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .item =
                  a_tcb.tsk.name)
               then

                -- Resource status must be equal to 0
                --
                  if (si.shared_resources (index1).shared.state = 0) then
                     is_ready := False;
               -- If the task is blocked due to a resource, we store this data
               -- in its Tcb
                     --
                     put_debug
                       (To_String (a_tcb.tsk.name) &
                        " is waiting for " &
                        To_String (si.shared_resources (index1).shared.name));
                     a_tcb.wait_for_a_resource :=
                       si.shared_resources (index1).shared;
                  end if;
               end if;
	     end if;
            end loop;
         end loop;
      end if;

   end check_resource;

   procedure set_quantum
     (my_scheduler : in out generic_scheduler'class;
      q            : in     Natural)
   is
   begin
      my_scheduler.parameters.quantum := q;
   end set_quantum;

   function get_quantum
     (my_scheduler : in generic_scheduler'class) return Natural
   is
   begin
      return my_scheduler.parameters.quantum;
   end get_quantum;

   function get_quantum
     (my_scheduler : in generic_scheduler'class) return Unbounded_String
   is
   begin
      return To_Unbounded_String (my_scheduler.parameters.quantum'img);
   end get_quantum;

   function get_quantum
     (my_scheduler : in generic_scheduler'class) return String
   is
   begin
      return my_scheduler.parameters.quantum'img;
   end get_quantum;

   function build_resource
     (my_scheduler : in generic_scheduler;
      a_resource   :    generic_resource_ptr) return shared_resource_ptr
   is
      new_a_resource : shared_resource_ptr;

   begin

      new_a_resource        := new shared_resource;
      new_a_resource.shared := a_resource;

      return new_a_resource;

   end build_resource;

   procedure initialize (s : in out scheduling_information) is
   begin
      s.number_of_tasks     := 0;
      s.number_of_resources := 0;
   end initialize;

   -- If this function return True, it means that
   -- the task A_Tcb can be run because all its
   -- task dependencies have met
   --
   function check_precedencies
     (si           : in scheduling_information;
      current_time : in Natural;
      a_tcb        :    tcb_ptr) return Boolean
   is

      -- This set of boolean decide if the task has to 
      -- be blocked or not
      
      -- If True, the expected message is arrived/ready to be read 
      has_message_to_receive : Boolean := False;

      -- If True, the task is ready to read the message
      wait_message           : Boolean := False;

      -- If True, the task is waiting of 1 message only
      -- (option of the asynchronous communication protocol)
      firstmessage : Boolean := False;

      -- If True, the task is waiting for a bunch of messages
      -- (option of the asynchronous communication protocol)
      allmessages  : Boolean := False;

      -- Variables to check that the number of received messages
      -- is compliant with the protocol
      nbr_message          : Integer := 0;
      nbr_received_message : Integer := 0;


      -- Local variables to check dependencies
      --
      factor, period_right, period_left : Integer;
      previous : tasks_set;
      left     : generic_task_ptr;
      ite1     : tasks_iterator;
      a_half_dep_ptr : dependency_ptr;
      a_message      : generic_message_ptr;
      my_iterator : tasks_dependencies_iterator;
      list_ite    : message_scheduling_information_iterator;
      msg         : message_scheduling_information_ptr;
      Wakeup_Task : Boolean;

   begin

      -------------------------------------------------
      -- Check if the task has precedence dependency 
      -- constraints to met to be released/run
      -------------------------------------------------

      if has_precedence_predecessor (si.dependencies, a_tcb.tsk) then

         reset (previous);
         previous := get_precedence_predecessors_list (si.dependencies, a_tcb.tsk);

         reset_iterator (previous, ite1);

         for j in 0 .. get_number_of_elements (previous) - 1 loop

            current_element (previous, left, ite1);

            for i in 0 .. si.number_of_tasks - 1 loop
               if si.tcbs (i).tsk.name = left.name then

                  if a_tcb.tsk.task_type = aperiodic_type then
                     period_right := 0;
                  else
                     period_right := periodic_task_ptr (a_tcb.tsk).period;
                  end if;
                  if si.tcbs (i).tsk.task_type = aperiodic_type then
                     period_left := 0;
                  else
                     period_left := periodic_task_ptr (si.tcbs (i).tsk).period;
                  end if;

                  factor := 1;
                  if (period_left > period_right) then
                     factor := period_left / period_right;
                  else
                     factor := period_right / period_left;
                  end if;

		  -- block a_tcb/the right task is the left is not run as
                  -- expected by the precedency constraint
                  -- 

                  if (period_left = period_right) then
                     if (si.tcbs (i).activation <= a_tcb.activation) then
                        return False;
                     end if;
                  end if;


                  if (period_left < period_right) then
                        if
                          (si.tcbs (i).activation <= a_tcb.activation * factor)
                        then
                           return False;
                        end if;
                  end if;
                   
                  if (period_left > period_right) then
                        if 
(si.tcbs (i).activation_end_time < a_tcb.activation_end_time  ) 

                        then
                           return False;
                        end if;
                  end if;

               end if;
            end loop;

            next_element (previous, ite1);
         end loop;
      end if;

      -----------------------------------------------------
      -- Check if the task has asynchronous communication
      -- constraints to meet before beeing released/run
      -----------------------------------------------------

      if not is_empty (si.dependencies.depends) then

         reset_iterator (si.dependencies.depends, my_iterator);
         loop
            current_element
              (si.dependencies.depends,
               a_half_dep_ptr,
               my_iterator);

            -- Is the task concerned ?
            -- Is it a communication dependency ?
            -- Is it a receiving operation ?
            --
            if
              (a_half_dep_ptr.type_of_dependency =
               asynchronous_communication_dependency)
            then

               ------------------------------
               --  First Message     ----
               ------------------------------

               if
                 (a_half_dep_ptr.asynchronous_communication_dependent_task
                    .name =
                  a_tcb.tsk.name) and
                 (a_half_dep_ptr.asynchronous_communication_orientation =
                  from_object_to_task) and
                 (a_half_dep_ptr.asynchronous_communication_protocol_property =
                  first_message)
               then
                  firstmessage := True;
                  a_message    :=
                    a_half_dep_ptr
                      .asynchronous_communication_dependency_object;

                  -- Is The task waiting for a message ?
                  --
                  if (a_tcb.rest_of_capacity = a_tcb.tsk.capacity) then
                     wait_message := True;
                  end if;

                  -- Check the exchanged_messages to see if this
                  -- messages is just arrived
                  --
                  if not is_empty (si.exchanged_messages) then
                     reset_head_iterator (si.exchanged_messages, list_ite);
                     loop
                        current_element (si.exchanged_messages, msg, list_ite);

                        -- Is it the right message ?
                        -- Is the message arrived at the receiving processor ?
                        --
                        if wait_message then
                           if (msg.exchanged_message.name = a_message.name) then
                              if
                                (current_time >=
                                 (msg.time + a_message.response_time))
                              then
                                 has_message_to_receive := True;
                              end if;
                           end if;
                        end if;

                        if is_tail_element (si.exchanged_messages, list_ite) then
                           exit;
                        end if;

                        next_element (si.exchanged_messages, list_ite);
                     end loop;
                  end if;

               end if;

               ------------------------------
               --  All Message           ----
               ------------------------------

               if
                 (a_half_dep_ptr.asynchronous_communication_dependent_task
                    .name =
                  a_tcb.tsk.name) and
                 (a_half_dep_ptr.asynchronous_communication_orientation =
                  from_object_to_task) and
                 (a_half_dep_ptr.asynchronous_communication_protocol_property =
                  all_messages)
               then
                  allmessages := True;
                  nbr_message := nbr_message + 1;
                  a_message   :=
                    a_half_dep_ptr
                      .asynchronous_communication_dependency_object;

                  -- Is The task waiting for a message ?
                  --
                  if (a_tcb.rest_of_capacity = a_tcb.tsk.capacity) then
                     wait_message := True;
                  end if;

                  -- Check the exchanged_messages to see if this
                  -- messages is just arrived
                  --
                  if not is_empty (si.exchanged_messages) then
                     reset_head_iterator (si.exchanged_messages, list_ite);
                     loop
                        current_element (si.exchanged_messages, msg, list_ite);

                        -- Is it the right message ?
                        -- Is the message arrived at the receiving processor ?
                        --
                        if wait_message then
                           if (msg.exchanged_message.name = a_message.name) then
                              if
                                (current_time >=
                                 (msg.time + a_message.response_time))
                              then
                                 has_message_to_receive := True;
                                 nbr_received_message   :=
                                   nbr_received_message + 1;
                              end if;
                           end if;
                        end if;

                        if is_tail_element (si.exchanged_messages, list_ite) then
                           exit;
                        end if;

                        next_element (si.exchanged_messages, list_ite);
                     end loop;
                  end if;

               end if;

            end if;

            exit when is_last_element (si.dependencies.depends, my_iterator);

            next_element (si.dependencies.depends, my_iterator);

         end loop;

      -- If the task wait for a message which is not
      -- arrived, do not wake up it
      --

      if wait_message and (not has_message_to_receive) and firstmessage then
         return False;
      end if;

      if wait_message and
        (nbr_received_message < nbr_message) and
        allmessages
      then
         return False;
      end if;

      end if;

      -----------------------------------------------------
      -- Check if the task has TDMA communication
      -- constraints to meet before beeing released/run
      -----------------------------------------------------

      
      if not is_empty (si.dependencies.depends) then


	Wakeup_Task:=True;

         reset_iterator (si.dependencies.depends, my_iterator);
         loop
            current_element
              (si.dependencies.depends,
               a_half_dep_ptr,
               my_iterator);

            -- Is it a TDMA dependency?
            --
            if
              (a_half_dep_ptr.type_of_dependency =
               tdma_communication_dependency)
            then

            -- Is the task concerned?
            -- Is it a receiving operation?
            --
               if
                 (a_half_dep_ptr.tdma_communication_dependent_task
                    .name =
                  a_tcb.tsk.name) and
                 (a_half_dep_ptr.tdma_communication_orientation =
                  from_object_to_task) and 
                   (a_tcb.rest_of_capacity = a_tcb.tsk.capacity)
               then

                  a_message    :=
                    a_half_dep_ptr
                      .tdma_communication_dependency_object;


                  -- Check the exchanged_messages to see if this
                  -- messages is just arrived
                  --
                  if not is_empty (si.exchanged_messages) then
                     reset_head_iterator (si.exchanged_messages, list_ite);
                     loop
                        current_element (si.exchanged_messages, msg, list_ite);

                        -- Is it the right message ?
                        -- Is the message arrived at the receiving processor ?
                        -- Right now, any TDMA message takes only 1 unit of time to be transmeted
                        --
                        if (msg.exchanged_message.name = a_message.name) then
                          if  (msg.status/=message_is_sent) or
                           (current_time <= msg.time)
                              then
                                 Wakeup_Task:= False;
                              end if;
                        end if;

                        if is_tail_element (si.exchanged_messages, list_ite) then
                           exit;
                        end if;

                        next_element (si.exchanged_messages, list_ite);
                     end loop;
                    end if;
                  end if;
                  end if;


            if not Wakeup_Task then
		return false;
            end if;

            exit when is_last_element (si.dependencies.depends, my_iterator);

            next_element (si.dependencies.depends, my_iterator);

         end loop;
      end if;

 
      -- Free resources
      --
      free (previous);
      free_container (previous);


      -- All dependency constraints are met ... the task can be run
      --
      return True;

   end check_precedencies;

   procedure compute_activation_time
     (my_scheduler : in     generic_scheduler;
      si           : in out scheduling_information;
      elected      : in     tasks_range;
      value        : in out Natural)
   is

   begin
      value := 0;
   end compute_activation_time;

   procedure put (m : in message_scheduling_information_ptr) is
   begin
      Put ("Message " & To_String (m.exchanged_message.name));
      Put_Line (" ; time = " & m.time'img);
   end put;

   procedure put (m : in buffer_scheduling_information_ptr) is
   begin
      Put ("Buffer " & To_String (m.written_buffer.name));
      Put_Line (" ; current_size = " & m.current_size'img);
   end put;

   procedure produce_running_task_event
     (my_scheduler : in     generic_scheduler;
      a_task       : in     tcb_ptr;
      options      : in     scheduling_option;
      si           : in     scheduling_information;
      an_event     :    out time_unit_event_ptr)
   is

      cache_state : Unbounded_String := empty_string;

   begin
      an_event                  := new time_unit_event (running_task);
      an_event.running_task     := a_task.tsk;
      an_event.running_core     := my_scheduler.corresponding_core_unit.name;
      an_event.current_priority := 0;
      an_event.crpd             := a_task.crpd_capacity;
      for i in 0 .. a_task.ucbs_in_cache.size - 1 loop
         Append
           (cache_state,
            To_Unbounded_String (" " & a_task.ucbs_in_cache.elements (i)'img));
      end loop;
      an_event.cache_state := cache_state;
   end produce_running_task_event;

   procedure produce_task_activation_event
     (my_scheduler : in     generic_scheduler;
      a_task       : in     tcb_ptr;
      options      : in     scheduling_option;
      si           : in     scheduling_information;
      an_event     :    out time_unit_event_ptr)
   is

   begin
      an_event                 := new time_unit_event (task_activation);
      an_event.activation_task := a_task.tsk;
   end produce_task_activation_event;

   procedure produce_end_of_task_capacity_event
     (my_scheduler : in     generic_scheduler;
      a_task       : in     tcb_ptr;
      options      : in     scheduling_option;
      si           : in     scheduling_information;
      an_event     :    out time_unit_event_ptr)
   is

   begin
      an_event          := new time_unit_event (end_of_task_capacity);
      an_event.end_task := a_task.tsk;
   end produce_end_of_task_capacity_event;

   procedure produce_start_of_task_capacity_event
     (my_scheduler : in     generic_scheduler;
      a_task       : in     tcb_ptr;
      options      : in     scheduling_option;
      si           : in     scheduling_information;
      an_event     :    out time_unit_event_ptr)
   is

   begin
      an_event            := new time_unit_event (start_of_task_capacity);
      an_event.start_task := a_task.tsk;
   end produce_start_of_task_capacity_event;

   procedure produce_discard_missed_deadline_event
     (my_scheduler : in     generic_scheduler;
      a_task       : in     tcb_ptr;
      options      : in     scheduling_option;
      si           : in     scheduling_information;
      an_event     :    out time_unit_event_ptr)
   is
   begin
      an_event := new time_unit_event (discard_missed_deadline);
      an_event.missed_deadline_task := a_task.tsk;
   end produce_discard_missed_deadline_event;




   function export_xml_event_write_to_buffer
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
   begin
      result :=
        " " &
        an_event.write_buffer.name &
        " " &
        an_event.write_task.name &
        " " &
        an_event.write_size'img;
      return result;
   end export_xml_event_write_to_buffer;

   function export_xml_event_read_from_buffer
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
   begin
      result :=
        " " &
        an_event.read_buffer.name &
        " " &
        an_event.read_task.name &
        " " &
        an_event.read_size'img;
      return result;
   end export_xml_event_read_from_buffer;

   function export_xml_event_running_task
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
   begin
      result := " " & an_event.running_task.name & " " & an_event.running_core;
      return result;
   end export_xml_event_running_task;

   function export_xml_event_context_switch_overhead
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
   begin
      result := " " & an_event.switched_task.name;
      return result;
   end export_xml_event_context_switch_overhead;

   function export_xml_event_address_space_activation
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
   begin
      result := " " & an_event.activation_address_space;
      return result;
   end export_xml_event_address_space_activation;

   function export_xml_event_task_activation
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
   begin
      result := " " & an_event.activation_task.name;
      return result;
   end export_xml_event_task_activation;

   function export_xml_event_start_of_task_capacity
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
   begin
      result := " " & an_event.start_task.name;
      return result;
   end export_xml_event_start_of_task_capacity;

   function export_xml_event_end_of_task_capacity
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
   begin
      result := " " & an_event.end_task.name;
      return result;
   end export_xml_event_end_of_task_capacity;

   function export_xml_event_send_message
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
   begin
      result :=
        " " & an_event.send_message.name & " " & an_event.send_task.name;
      return result;
   end export_xml_event_send_message;

   function export_xml_event_receive_message
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
   begin
      result :=
        " " & an_event.receive_message.name & " " & an_event.receive_task.name;
      return result;
   end export_xml_event_receive_message;

   function export_xml_event_allocate_resource
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
   begin
      result :=
        " " &
        an_event.allocate_resource.name &
        " " &
        an_event.allocate_task.name;
      return result;
   end export_xml_event_allocate_resource;

   function export_xml_event_release_resource
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
   begin
      result :=
        " " &
        an_event.release_resource.name &
        " " &
        an_event.release_task.name;
      return result;
   end export_xml_event_release_resource;

   function export_xml_event_wait_for_resource
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
   begin
      result :=
        " " &
        an_event.wait_for_resource.name &
        " " &
        an_event.wait_for_resource_task.name;
      return result;
   end export_xml_event_wait_for_resource;

   function xml_string
     (obj : in generic_scheduler_ptr) return Unbounded_String
   is
   begin
      return XML_String (obj.parameters);
   end xml_string;

   function copy
     (obj : buffer_scheduling_information_ptr)
      return buffer_scheduling_information_ptr
   is
      ret : buffer_scheduling_information_ptr;
   begin
      ret     := new buffer_scheduling_information;
      ret.all := obj.all;
      return ret;
   end copy;

   function copy
     (obj : message_scheduling_information_ptr)
      return message_scheduling_information_ptr
   is
      ret : message_scheduling_information_ptr;
   begin
      ret     := new message_scheduling_information;
      ret.all := obj.all;
      return ret;
   end copy;

   function check_core_assignment
     (a_scheduler : in generic_scheduler;
      a_tcb       : in tcb_ptr) return Boolean
   is
   begin

      -- monocore processeur : return always true
      --
      if
        (a_scheduler.corresponding_processor.processor_type = monocore_type)
      then
         return True;
      end if;

      -- The task never migrates => it can be run on only one core
      --
      if
        (a_scheduler.corresponding_processor.migration_type =
         no_migration_type)
      then
         return True;
      end if;

   -- The scheduler is not preemptive and the task has started to run :
   -- the task cannot migrate
   -- during one of its activation : it works as a job level migration policy
      --
      if (a_tcb.assigned_core_unit /= null) and
        (a_scheduler.parameters.preemptive_type = not_preemptive)
      then
         return False;
      end if;

      -- The task does not started yet to run ... it can migrate
      --
      if (a_tcb.assigned_core_unit = null) then
         return True;
      end if;

      -- The task has already run on a core (on the A_Tcb.assigned_core_unit core)
-- and is not allowed to migrate due to its migration policy before the end of
-- its current job/activation
      --
      if
        (a_tcb.assigned_core_unit.name /=
         a_scheduler.corresponding_core_unit.name) and
        (a_scheduler.corresponding_processor.migration_type =
         job_level_migration_type)
      then
         return False;
      end if;

      return True;

   end check_core_assignment;

   procedure build_attributes_xml_string
     (obj    : in     generic_scheduler_ptr;
      result : in out Unbounded_String)
   is
   begin
      Build_Attributes_XML_String (obj.parameters, result);
   end build_attributes_xml_string;

   function xml_string
     (obj : in buffer_scheduling_information_ptr) return Unbounded_String
   is
   begin
      return empty_string;
   end xml_string;

   function xml_string
     (obj : in message_scheduling_information_ptr) return Unbounded_String
   is
   begin
      return empty_string;
   end xml_string;

   procedure put (obj : in entity_scheduler) is
   begin
      null;
   end put;

   procedure put (obj : in entity_scheduler_ptr) is
   begin
      null;
   end put;

   function xml_string (obj : in entity_scheduler) return Unbounded_String is
   begin
      return empty_string;
   end xml_string;

   function xml_string
     (obj : in entity_scheduler_ptr) return Unbounded_String
   is
   begin
      return empty_string;
   end xml_string;

end scheduler;
