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
--    $Rev: 4969 $
--    $Date: 2024-04-14 01:43:01 +0200 (dim., 14 avril 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Exceptions;                    use Ada.Exceptions;
with Resources;                         use Resources;
with Resources;                         use Resources.Resource_Accesses;
with Buffers;                           use Buffers;
with Buffers;                           use Buffers.Buffer_Roles_Package;
with time_unit_events;                  use time_unit_events;
with time_unit_events;                  use time_unit_events.time_unit_package;
with natural_util;                      use natural_util;
with double_util;                       use double_util;
with integer_util;                      use integer_util;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Objects;                           use Objects;
with Objects.extended;                  use Objects.extended;
with translate;                         use translate;
with initialize_framework;              use initialize_framework;
with Parameters.extended;               use Parameters.extended;
with cache_access_profile_set;          use cache_access_profile_set;
with Caches;                            use Caches.Cache_Blocks_Table_Package;
with Caches;                            use Caches;
with debug;                             use debug;

package body task_set is

   procedure add_task
     (my_tasks                   : in out tasks_set;
      name                       : in Unbounded_String;
      cpu_name                   : in Unbounded_String;
      address_space_name         : in Unbounded_String;
      core_name                  : in Unbounded_String;
      task_type                  : in tasks_type;
      start_time                 : in Integer;
      capacity                   : in Integer;
      period                     : in Integer;
      deadline                   : in Integer;
      jitter                     : in Integer;
      blocking_time              : in Integer;
      priority                   : in Integer;
      criticality                : in Integer;
      policy                     : in policies;
      offset                     : in offsets_table         := no_offset;
      stack_memory_size          : in Integer               := 0;
      text_memory_size           : in Integer               := 0;
      param                      : in user_defined_parameters_table := 
        no_user_defined_parameter;
      parametric_rule_name       : in Unbounded_String      := empty_string;
      seed_value                 : in Integer               := 0;
      predictable                : in Boolean               := True;
      context_switch_overhead    : in Integer               := 0;
      every                      : in Integer               := 0;
      energy_consumption         : in Integer               := 0;
      cache_access_profile_name  : in Unbounded_String := empty_string;
      cfg_name                   : in Unbounded_String := empty_string;
      mils_confidentiality_level : in mils_confidentiality_level_type :=
        top_secret;
      mils_integrity_level       : in mils_integrity_level_type := high;
      mils_component             : in mils_component_type       := sls;
      mils_task                  : in mils_task_type            := application;
      mils_compliant             : in Boolean                   := True;
      text_memory_start_address  : in Integer                   := 0;
      cfg_relocatable            : in Boolean                   := False;
      capacity_model             : in Execution_Unit_Model_Type :=
        LiuLayland_Execution_Unit;
      capacities                : in execution_units_table     := no_values;
      qualities                 : in execution_units_table     := no_values;
      completion_time            : in Integer                   := 0;
      outer_period               : in Integer                   := 0;
      outer_duration             : in Integer                   := 0)

   is

      dummy : generic_task_ptr;

   begin
      add_task
        (my_tasks                  => my_tasks,
         a_task                    => dummy,
         name                      => name,
         cpu_name                  => cpu_name,
         address_space_name        => address_space_name,
         core_name                 => core_name,
         task_type                 => task_type,
         start_time                => start_time,
         capacity                  => capacity,
         period                    => period,
         deadline                  => deadline,
         jitter                    => jitter,
         blocking_time             => blocking_time,
         priority                  => priority,
         criticality               => criticality,
         policy                    => policy,
         offset                    => offset,
         stack_memory_size         => stack_memory_size,
         text_memory_size          => text_memory_size,
         param                     => param,
         parametric_rule_name      => parametric_rule_name,
         seed_value                => seed_value,
         predictable               => predictable,
         context_switch_overhead   => context_switch_overhead,
         every                     => every,
         energy_consumption        => energy_consumption,
         cache_access_profile_name => cache_access_profile_name,
         cfg_name                  => cfg_name,
         mils_confidentiality_level => mils_confidentiality_level,
         mils_integrity_level       => mils_integrity_level,
         mils_component             => mils_component,
         mils_task                  => mils_task,
         mils_compliant             => mils_compliant,
         text_memory_start_address  => text_memory_start_address,
         cfg_relocatable            => cfg_relocatable,
         capacity_model             => capacity_model,
         capacities                 => capacities,
         qualities                  => qualities,
         completion_time            => completion_time,
         outer_period               => outer_period,
         outer_duration             => outer_duration);
   end add_task;

   procedure check_task
     (my_tasks                   : in tasks_set;
      name                       : in Unbounded_String;
      cpu_name                   : in Unbounded_String;
      address_space_name         : in Unbounded_String;
      core_name                  : in Unbounded_String;
      task_type                  : in tasks_type;
      start_time                 : in Integer;
      capacity                   : in Integer;
      period                     : in Integer;
      deadline                   : in Integer;
      jitter                     : in Integer;
      blocking_time              : in Integer;
      priority                   : in Integer;
      criticality                : in Integer;
      policy                     : in policies;
      offset                     : in offsets_table := no_offset;
      stack_memory_size          : in Integer                         := 0;
      text_memory_size           : in Integer                         := 0;
      param : in user_defined_parameters_table   := no_user_defined_parameter;
      parametric_rule_name       : in Unbounded_String := empty_string;
      seed_value                 : in Integer                         := 0;
      predictable                : in Boolean                         := True;
      context_switch_overhead    : in Integer                         := 0;
      every                      : in Integer                         := 0;
      energy_consumption         : in Integer                         := 0;
      cache_access_profile_name  : in Unbounded_String := empty_string;
      cfg_name                   : in Unbounded_String := empty_string;
      mils_confidentiality_level : in mils_confidentiality_level_type :=
        top_secret;
      mils_integrity_level      : in mils_integrity_level_type := high;
      mils_component            : in mils_component_type       := sls;
      mils_task                 : in mils_task_type            := application;
      mils_compliant            : in Boolean                   := True;
      text_memory_start_address : in Integer                   := 0;
      cfg_relocatable           : in Boolean                   := False;
      capacity_model             : in Execution_Unit_Model_Type :=
        LiuLayland_Execution_Unit;
      capacities                : in execution_units_table     := no_values;
      qualities                 : in execution_units_table     := no_values;
      completion_time           : in Integer                   := 0;
      outer_period              : in Integer                   := 0;
      outer_duration            : in Integer                   := 0)
   is
   begin
      if name = "" then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_task_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if not is_a_valid_identifier (parametric_rule_name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_activation_rule (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if (cpu_name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_processor_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if (address_space_name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_address_space_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (cpu_name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               name &
               " : " &
               lb_processor_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if not is_a_valid_identifier (address_space_name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               name &
               " : " &
               lb_address_space_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if not is_a_valid_identifier (core_name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               name &
               " : " &
               lb_core_unit_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if (capacity <= 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_capacity (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_than (Current_Language) &
               "0"));
      end if;

      if (every < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_every (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (energy_consumption < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_energy_consumption (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (context_switch_overhead < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_context_switch_overhead (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (jitter < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_jitter (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (criticality < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_criticality (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (period < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_period (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      case task_type is

         when scheduling_task_type =>
            null;

         when aperiodic_type =>
            if period /= 0 then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_task (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_aperiodic (Current_Language) &
                     lb_no_period (Current_Language)));
            end if;

         when parametric_type =>
            if parametric_rule_name = empty_string then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_task (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_parametric_task (Current_Language) &
                     lb_require_activation_rule (Current_Language)));
            end if;

         when timed_type                |
           periodic_type                |
           poisson_type                 |
           sporadic_type                |
           frame_task_type              |
           sporadic_inner_periodic_type |
           periodic_inner_periodic_type =>
            if period <= 0 then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_task (Current_Language) &
                     " " &
                     name &
                     " " &
                     lb_require_period (Current_Language)));
            end if;

      end case;

      if (task_type = sporadic_inner_periodic_type) or
        (task_type = periodic_inner_periodic_type)
      then

         if (outer_period <= 0) then
            Raise_Exception
              (invalid_parameter'identity,
               To_String
                 (lb_task (Current_Language) &
                  " " &
                  name &
                  " : " &
                  lb_outer_period (Current_Language) &
                  lb_must_be (Current_Language) &
                  lb_greater_than (Current_Language) &
                  "0"));
         end if;

         if (outer_duration <= 0) then
            Raise_Exception
              (invalid_parameter'identity,
               To_String
                 (lb_task (Current_Language) &
                  " " &
                  name &
                  " : " &
                  lb_outer_duration (Current_Language) &
                  lb_must_be (Current_Language) &
                  lb_greater_than (Current_Language) &
                  "0"));
         end if;

         if (period > outer_period) then
            Raise_Exception
              (invalid_parameter'identity,
               To_String
                 (lb_task (Current_Language) &
                  " " &
                  name &
                  " : " &
                  lb_outer_period (Current_Language) &
                  lb_must_be (Current_Language) &
                  lb_greater_than (Current_Language) &
                  lb_period (Current_Language)));
         end if;

         if (outer_duration > outer_period) then
            Raise_Exception
              (invalid_parameter'identity,
               To_String
                 (lb_task (Current_Language) &
                  " " &
                  name &
                  " : " &
                  lb_outer_period (Current_Language) &
                  lb_must_be (Current_Language) &
                  lb_greater_than (Current_Language) &
                  lb_outer_duration (Current_Language)));
         end if;
      end if;

      if (deadline < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_deadline (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (deadline < jitter) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_deadline (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_than (Current_Language) &
               lb_jitter (Current_Language)));
      end if;

      if (completion_time < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_completion_time (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (start_time < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_start_time (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (blocking_time < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_blocking_time (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (text_memory_size < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_text_memory_size (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (stack_memory_size < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_stack_memory_size (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (priority < Integer (priority_range'first)) or
        (priority > Integer (priority_range'last))
      then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_invalid_priority (Current_Language) &
               " : " &
               priority'img));
      end if;

      if (priority /= 0) and (policy = sched_others) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_policy_control (Current_Language)));
      end if;

      if (priority = 0) and (policy /= sched_others) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_policy_control (Current_Language)));
      end if;

      if
        (To_String (parametric_rule_name) /= "" and
         task_type /= parametric_type)
      then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_rule_for_parametric_only (Current_Language)));
      end if;

      -- User defined integrity checks
      --
      check_parameters (param, lb_task (Current_Language) & " " & name);

      -- Offset integrity checks
      --

      for i in 0 .. offset.nb_entries - 1 loop

         if offset.entries (i).offset_value < 0 then
            Raise_Exception
              (invalid_parameter'identity,
               To_String
                 (lb_task (Current_Language) &
                  " " &
                  name &
                  " : " &
                  To_Unbounded_String ("Offset/val.") &
                  lb_must_be (Current_Language) &
                  lb_greater_or_equal_than (Current_Language) &
                  To_Unbounded_String ("0")));
         end if;

         if offset.entries (i).activation < 0 then
            Raise_Exception
              (invalid_parameter'identity,
               To_String
                 (lb_task (Current_Language) &
                  " " &
                  name &
                  " : " &
                  To_Unbounded_String ("Offset/activation") &
                  lb_must_be (Current_Language) &
                  lb_greater_or_equal_than (Current_Language) &
                  To_Unbounded_String ("0")));

         end if;

      end loop;

      if not is_a_valid_identifier (cache_access_profile_name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_cache_access_profile_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if not is_a_valid_identifier (cfg_name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               name &
               " : " &
               lb_cfg_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

   end check_task;

   procedure add_task
     (my_tasks                   : in out tasks_set;
      a_task                     : in out generic_task_ptr;
      name                       : in     Unbounded_String;
      cpu_name                   : in     Unbounded_String;
      address_space_name         : in     Unbounded_String;
      core_name                  : in     Unbounded_String;
      task_type                  : in     tasks_type;
      start_time                 : in     Integer;
      capacity                   : in     Integer;
      period                     : in     Integer;
      deadline                   : in     Integer;
      jitter                     : in     Integer;
      blocking_time              : in     Integer;
      priority                   : in     Integer;
      criticality                : in     Integer;
      policy                     : in     policies;
      offset                     : in     offsets_table := no_offset;
      stack_memory_size          : in     Integer                         := 0;
      text_memory_size           : in     Integer                         := 0;
      param : in user_defined_parameters_table   := no_user_defined_parameter;
      parametric_rule_name       : in     Unbounded_String := empty_string;
      seed_value                 : in     Integer                         := 0;
      predictable                : in     Boolean := True;
      context_switch_overhead    : in     Integer                         := 0;
      every                      : in     Integer                         := 0;
      energy_consumption         : in     Integer                         := 0;
      cache_access_profile_name  : in     Unbounded_String := empty_string;
      cfg_name                   : in     Unbounded_String := empty_string;
      mils_confidentiality_level : in     mils_confidentiality_level_type :=
        top_secret;
      mils_integrity_level      : in mils_integrity_level_type := high;
      mils_component            : in mils_component_type       := sls;
      mils_task                 : in mils_task_type            := application;
      mils_compliant            : in Boolean                   := True;
      text_memory_start_address : in Integer                   := 0;
      cfg_relocatable           : in Boolean                   := False;
      capacity_model             : in Execution_Unit_Model_Type :=
        LiuLayland_Execution_Unit;
      capacities                : in execution_units_table     := no_values;
      qualities                 : in execution_units_table     := no_values;
      completion_time           : in Integer                   := 0;
      outer_period              : in Integer                   := 0;
      outer_duration            : in Integer                   := 0)
   is
      new_periodic_task                : periodic_task_ptr;
      new_timed_task                   : timed_task_ptr;
      new_aperiodic_task               : aperiodic_task_ptr;
      new_poisson_task                 : poisson_task_ptr;
      new_parametric_task              : parametric_task_ptr;
      new_sporadic_task                : sporadic_task_ptr;
      new_scheduling_task              : scheduling_task_ptr;
      new_frame_task                   : frame_task_ptr;
      new_sporadic_inner_periodic_task : sporadic_inner_periodic_task_ptr;
      new_periodic_inner_periodic_task : periodic_inner_periodic_task_ptr;

      my_iterator : tasks_iterator;

   begin

      check_initialize;

      check_task
        (my_tasks,
         name,
         cpu_name,
         address_space_name,
         core_name,
         task_type,
         start_time,
         capacity,
         period,
         deadline,
         jitter,
         blocking_time,
         priority,
         criticality,
         policy,
         offset,
         stack_memory_size,
         text_memory_size,
         param,
         parametric_rule_name,
         seed_value,
         predictable,
         context_switch_overhead,
         every,
         energy_consumption,
         cache_access_profile_name,
         cfg_name,
         mils_confidentiality_level,
         mils_integrity_level,
         mils_component,
         mils_task,
         mils_compliant,
         text_memory_start_address,
         cfg_relocatable,
         capacity_model,
         capacities,
	 qualities,
         completion_time,
         outer_period,
         outer_duration);

      if (get_number_of_elements (my_tasks) > 0) then

         reset_iterator (my_tasks, my_iterator);

         loop
            current_element (my_tasks, a_task, my_iterator);
            if (name = a_task.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_task (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_task_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;
            exit when is_last_element (my_tasks, my_iterator);
            next_element (my_tasks, my_iterator);
         end loop;
      end if;

      case task_type is
         when periodic_type =>
            new_periodic_task                 := new periodic_task;
            new_periodic_task.jitter          := Natural (jitter);
            new_periodic_task.period          := Natural (period);
            new_periodic_task.every           := Natural (every);
            new_periodic_task.seed            := seed_value;
            new_periodic_task.completion_time := completion_time;
            a_task := generic_task_ptr (new_periodic_task);
         when timed_type =>
            new_timed_task                 := new timed_task;
            new_timed_task.jitter          := Natural (jitter);
            new_timed_task.period          := Natural (period);
            new_timed_task.every           := Natural (every);
            new_timed_task.completion_time := completion_time;
            a_task := generic_task_ptr (new_timed_task);
         when scheduling_task_type =>
            new_scheduling_task                 := new scheduling_task;
            a_task := generic_task_ptr (new_scheduling_task);
            new_scheduling_task.jitter          := Natural (jitter);
            new_scheduling_task.period          := Natural (period);
            new_scheduling_task.every           := Natural (every);
            new_scheduling_task.completion_time := completion_time;
            new_scheduling_task.seed            := seed_value;
            new_scheduling_task.predictable     := predictable;
         when aperiodic_type =>
            new_aperiodic_task := new aperiodic_task;
            a_task             := generic_task_ptr (new_aperiodic_task);
         when poisson_type =>
            new_poisson_task                 := new poisson_task;
            new_poisson_task.jitter          := Natural (jitter);
            new_poisson_task.period          := Natural (period);
            new_poisson_task.every           := Natural (every);
            new_poisson_task.completion_time := completion_time;
            new_poisson_task.seed            := seed_value;
            new_poisson_task.predictable     := predictable;
            a_task := generic_task_ptr (new_poisson_task);
         when sporadic_type =>
            new_sporadic_task                 := new sporadic_task;
            new_sporadic_task.jitter          := Natural (jitter);
            new_sporadic_task.period          := Natural (period);
            new_sporadic_task.every           := Natural (every);
            new_sporadic_task.completion_time := completion_time;
            new_sporadic_task.seed            := seed_value;
            new_sporadic_task.predictable     := predictable;
            a_task := generic_task_ptr (new_sporadic_task);
         when parametric_type =>
            new_parametric_task                 := new parametric_task;
            new_parametric_task.jitter          := Natural (jitter);
            new_parametric_task.period          := Natural (period);
            new_parametric_task.completion_time := completion_time;
            new_parametric_task.every           := Natural (every);
            new_parametric_task.seed            := seed_value;
            new_parametric_task.predictable     := predictable;
            new_parametric_task.activation_rule := parametric_rule_name;
            a_task := generic_task_ptr (new_parametric_task);
         when frame_task_type =>
            new_frame_task              := new frame_task;
            new_frame_task.interarrival := Natural (period);
            a_task                      := generic_task_ptr (new_frame_task);
         when sporadic_inner_periodic_type =>
            new_sporadic_inner_periodic_task :=
              new sporadic_inner_periodic_task;
            new_sporadic_inner_periodic_task.jitter := Natural (jitter);
            new_sporadic_inner_periodic_task.period := Natural (period);
            new_sporadic_inner_periodic_task.every := Natural (every);
            new_sporadic_inner_periodic_task.completion_time :=
              completion_time;
            new_sporadic_inner_periodic_task.seed           := seed_value;
            new_sporadic_inner_periodic_task.predictable    := predictable;
            new_sporadic_inner_periodic_task.outer_period   := outer_period;
            new_sporadic_inner_periodic_task.outer_duration := outer_duration;
            a_task := generic_task_ptr (new_sporadic_inner_periodic_task);
         when periodic_inner_periodic_type =>
            new_periodic_inner_periodic_task :=
              new periodic_inner_periodic_task;
            new_periodic_inner_periodic_task.jitter := Natural (jitter);
            new_periodic_inner_periodic_task.period := Natural (period);
            new_periodic_inner_periodic_task.every := Natural (every);
            new_periodic_inner_periodic_task.completion_time :=
              completion_time;
            new_periodic_inner_periodic_task.seed           := seed_value;
            new_periodic_inner_periodic_task.predictable    := predictable;
            new_periodic_inner_periodic_task.outer_period   := outer_period;
            new_periodic_inner_periodic_task.outer_duration := outer_duration;
            a_task := generic_task_ptr (new_periodic_inner_periodic_task);
      end case;

      a_task.context_switch_overhead    := context_switch_overhead;
      a_task.offsets                    := offset;
      a_task.deadline                   := Natural (deadline);
      a_task.name                       := name;
      a_task.capacity                   := Natural (capacity);
      a_task.start_time                 := Natural (start_time);
      a_task.cpu_name                   := cpu_name;
      a_task.core_name                  := core_name;
      a_task.address_space_name         := address_space_name;
      a_task.priority                   := priority_range (priority);
      a_task.energy_consumption         := Natural (energy_consumption);
      a_task.criticality                := Natural (criticality);
      a_task.policy                     := policy;
      a_task.task_type                  := task_type;
      a_task.blocking_time              := Natural (blocking_time);
      a_task.stack_memory_size          := Natural (stack_memory_size);
      a_task.text_memory_size           := Natural (text_memory_size);
      a_task.text_memory_start_address  := text_memory_start_address;
      a_task.parameters                 := param;
      a_task.cfg_name                   := cfg_name;
      a_task.cfg_relocatable            := cfg_relocatable;
      a_task.cache_access_profile_name  := cache_access_profile_name;
      a_task.mils_confidentiality_level := mils_confidentiality_level;
      a_task.mils_integrity_level       := mils_integrity_level;
      a_task.mils_component             := mils_component;
      a_task.mils_task                  := mils_task;
      a_task.mils_compliant             := mils_compliant;
      a_task.capacity_model             := capacity_model;
      a_task.capacities                 := capacities;
      a_task.qualities			:= qualities;
      add (my_tasks, a_task);

   exception
      when generic_task_set.full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_tasks (Current_Language)));

   end add_task;

   function task_is_present
     (my_tasks : in tasks_set;
      name     : in Unbounded_String) return Boolean
   is
      my_iterator : tasks_iterator;
      a_task      : generic_task_ptr;

      found : Boolean := False;

   begin

      if is_empty (my_tasks) then
         return False;
      else
         reset_iterator (my_tasks, my_iterator);

         loop
            current_element (my_tasks, a_task, my_iterator);

            if (a_task.name = name) then
               found := True;
            end if;

            exit when is_last_element (my_tasks, my_iterator);

            next_element (my_tasks, my_iterator);

         end loop;

         return found;
      end if;

   end task_is_present;

   function search_task_by_id
     (my_tasks : in tasks_set;
      id       : in Unbounded_String) return generic_task_ptr
   is
      my_iterator : tasks_iterator;
      a_task      : generic_task_ptr;
      result      : generic_task_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_tasks) then

         reset_iterator (my_tasks, my_iterator);

         loop
            current_element (my_tasks, a_task, my_iterator);

            if (a_task.cheddar_private_id = id) then
               found  := True;
               result := a_task;
            end if;

            exit when is_last_element (my_tasks, my_iterator);

            next_element (my_tasks, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (task_not_found'identity,
            To_String (lb_task_id (Current_Language) & "=" & id));
      end if;

      return result;
   end search_task_by_id;

   function search_task
     (my_tasks : in tasks_set;
      name     : in Unbounded_String) return generic_task_ptr
   is
      my_iterator : tasks_iterator;
      a_task      : generic_task_ptr;
      result      : generic_task_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_tasks) then

         reset_iterator (my_tasks, my_iterator);

         loop
            current_element (my_tasks, a_task, my_iterator);

            if (a_task.name = name) then
               found  := True;
               result := a_task;
            end if;

            exit when is_last_element (my_tasks, my_iterator);

            next_element (my_tasks, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (task_not_found'identity,
            To_String (lb_task_name (Current_Language) & "=" & name));
      end if;

      return result;
   end search_task;

   function increasing_ucb
     (caps :    cache_access_profiles_set;
      op1  : in generic_task_ptr;
      op2  : in generic_task_ptr) return Boolean
   is
      a_cap1 : cache_access_profile_ptr;
      a_cap2 : cache_access_profile_ptr;
   begin
      a_cap1 :=
        search_cache_access_profile (caps, op1.cache_access_profile_name);
      a_cap2 :=
        search_cache_access_profile (caps, op2.cache_access_profile_name);
      return (a_cap1.UCBs.nb_entries <= a_cap2.UCBs.nb_entries);
   end increasing_ucb;

   function increasing_si
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean
   is
      si1, si2 : Float;
   begin
      si1 :=
        Log (Float (periodic_task_ptr (op1).period), 2.0) -
        Float'floor (Log (Float (periodic_task_ptr (op1).period), 2.0));
      si2 :=
        Float (Log (Float (periodic_task_ptr (op2).period), 2.0)) -
        Float'floor
          (Float (Log (Float (periodic_task_ptr (op2).period), 2.0)));
      return (si1 <= si2);
   end increasing_si;

   function increasing_utilization
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean
   is
      u1, u2 : Float;
   begin
      u1 := Float (op1.capacity) / Float (periodic_task_ptr (op1).period);
      u2 := Float (op2.capacity) / Float (periodic_task_ptr (op2).period);
      return (u1 <= u2);
   end increasing_utilization;

   function increasing_period_deadline
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean
   is
   begin
      if (periodic_task_ptr (op1).period < periodic_task_ptr (op2).period) then
         return True;
      elsif
        (periodic_task_ptr (op1).period = periodic_task_ptr (op2).period)
      then
         return (op1.deadline <= op2.deadline);
      else
         return False;
      end if;

   end increasing_period_deadline;

   function decreasing_period_deadline
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean
   is
   begin
      if (periodic_task_ptr (op1).period > periodic_task_ptr (op2).period) then
         return True;
      elsif
        (periodic_task_ptr (op1).period = periodic_task_ptr (op2).period)
      then
         return (op1.deadline >= op2.deadline);
      else
         return False;
      end if;

   end decreasing_period_deadline;

   function increasing_start_time
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean
   is
   begin
      return (op1.start_time <= op2.start_time);
   end increasing_start_time;

   function increasing_priority
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean
   is
   begin
      return (op1.priority <= op2.priority);
   end increasing_priority;

   function decreasing_priority
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean
   is
   begin
      return (op1.priority >= op2.priority);
   end decreasing_priority;

   function increasing_period
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean
   is
   begin
      case op1.task_type is
         when periodic_type =>
            return
              (periodic_task_ptr (op1).period <=
               periodic_task_ptr (op2).period);
         when poisson_type =>
            return
              (poisson_task_ptr (op1).period <= poisson_task_ptr (op2).period);
         when sporadic_type =>
            return
              (sporadic_task_ptr (op1).period <=
               sporadic_task_ptr (op2).period);
         when others =>
            return True;
      end case;

   end increasing_period;

   function decreasing_period
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean
   is
   begin

      case op1.task_type is
         when periodic_type =>
            return
              (periodic_task_ptr (op1).period >=
               periodic_task_ptr (op2).period);
         when poisson_type =>
            return
              (poisson_task_ptr (op1).period >= poisson_task_ptr (op2).period);
         when sporadic_type =>
            return
              (sporadic_task_ptr (op1).period >=
               sporadic_task_ptr (op2).period);
         when others =>
            return True;
      end case;

   end decreasing_period;

   function increasing_deadline
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean
   is
   begin
      return (op1.deadline <= op2.deadline);
   end increasing_deadline;

   function decreasing_deadline
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean
   is
   begin
      return (op1.deadline >= op2.deadline);
   end decreasing_deadline;

   function increasing_name
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean
   is
   begin
      return (op1.name <= op2.name);
   end increasing_name;

   function increasing_offset
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean
   is
      o1 : Integer;
      o2 : Integer;
   begin
      o1 := 0;
      if (op1.offsets.nb_entries > 0) then
         o1 := op1.offsets.entries (0).offset_value;
      end if;

      o2 := 0;
      if (op2.offsets.nb_entries > 0) then
         o2 := op2.offsets.entries (0).offset_value;
      end if;

      return (o1 <= o2);
   end increasing_offset;

   function increasing_text_memory_start_address
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean
   is
   begin

      if op1.text_memory_start_address = -1 and
        op2.text_memory_start_address = -1
      then
         return True;
      end if;
      if op1.text_memory_start_address = -1 and
        op2.text_memory_start_address /= -1
      then
         return False;
      end if;
      if op1.text_memory_start_address /= -1 and
        op2.text_memory_start_address = -1
      then
         return True;
      end if;
      return (op1.text_memory_start_address <= op2.text_memory_start_address);

   end increasing_text_memory_start_address;

   --------------------------------------------------------------
   function get
     (my_tasks   : in tasks_set;
      task_name  : in Unbounded_String;
      param_name : in task_parameters) return Unbounded_String
   is
      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

   begin

      if (param_name /= cpu_name) and
        (param_name /= address_space_name) and
	(param_name /= core_name) and
        (param_name /= mils_confidentiality_level) and
        (param_name /= mils_integrity_level)
      then
         raise invalid_parameter;
      end if;

      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if (a_task.name = task_name) then
            exit;
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);

      end loop;

      if (param_name = cpu_name) then
         return a_task.cpu_name;
      elsif (param_name = address_space_name) then
         return a_task.address_space_name;
      elsif (param_name = core_name) then
         return a_task.core_name;
      elsif (param_name = mils_confidentiality_level) then
         return To_Unbounded_String (a_task.mils_confidentiality_level'img);
      elsif (param_name = mils_integrity_level) then
         return To_Unbounded_String (a_task.mils_integrity_level'img);
      else
         raise invalid_parameter;
      end if;

   end get;

   function get
     (my_tasks   : in tasks_set;
      task_name  : in Unbounded_String;
      param_name : in task_parameters) return Boolean
   is
      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

   begin

      if (param_name /= predictable) then
         raise invalid_parameter;
      end if;

      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if (a_task.name = task_name) then
            exit;
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);

      end loop;

      if (a_task.task_type /= poisson_type) and
        (a_task.task_type /= parametric_type)
      then
         raise invalid_parameter;
      end if;

      return poisson_task_ptr (a_task).predictable;

   end get;

   function get
     (my_tasks   : in tasks_set;
      task_name  : in Unbounded_String;
      param_name : in task_parameters) return priority_range
   is
      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

   begin

      if (param_name /= priority) then
         raise invalid_parameter;
      end if;

      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if (a_task.name = task_name) then
            exit;
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);

      end loop;

      return a_task.priority;

   end get;

   function get
     (my_tasks   : in tasks_set;
      task_name  : in Unbounded_String;
      param_name : in task_parameters) return Natural
   is
      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

   begin

      if
        ((param_name /= start_time) and
         (param_name /= blocking_time) and
         (param_name /= capacity) and
         (param_name /= period) and
         (param_name /= deadline) and
         (param_name /= jitter) and
         (param_name /= priority) and
         (param_name /= criticality))
      then
         raise invalid_parameter;
      end if;

      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if (a_task.name = task_name) then
            exit;
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);

      end loop;

      if (param_name = start_time) then
         return a_task.start_time;
      elsif (param_name = deadline) then
         return a_task.deadline;
      elsif (param_name = period) then
         return periodic_task_ptr (a_task).period;
      elsif (param_name = jitter) then
         return periodic_task_ptr (a_task).jitter;
      elsif (param_name = capacity) then
         return a_task.capacity;
      elsif (param_name = priority) then
         return Natural (a_task.priority);
      elsif (param_name = blocking_time) then
         return a_task.blocking_time;
      elsif (param_name = criticality) then
         return a_task.criticality;
      else
         raise invalid_parameter;
      end if;

   end get;

   procedure set
     (my_tasks    : in out tasks_set;
      task_name   : in     Unbounded_String;
      param_name  : in     task_parameters;
      param_value : in     Unbounded_String)
   is

      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

   begin

      if (param_name /= cpu_name) 
	and (param_name /= address_space_name) 
	and (param_name /= core_name)
      then
         raise invalid_parameter;
      end if;

      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if (a_task.name = task_name) then
            if (param_name = cpu_name) then
               a_task.cpu_name := param_value;
            elsif (param_name = address_space_name) then 
	       a_task.address_space_name := param_value;
	    else 
               a_task.core_name := param_value;
            end if;
            exit;
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);

      end loop;

   end set;

   procedure set
     (my_tasks    : in out tasks_set;
      task_name   : in     Unbounded_String;
      param_name  : in     task_parameters;
      param_value : in     priority_range)
   is

      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

   begin

      if (param_name /= priority) then
         raise invalid_parameter;
      end if;

      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if (a_task.name = task_name) then
            a_task.priority := param_value;
            exit;
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);

      end loop;
   end set;

   procedure set
     (my_tasks    : in out tasks_set;
      task_name   : in     Unbounded_String;
      param_name  : in     task_parameters;
      param_value : in     Boolean)
   is

      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

   begin

      if (param_name /= predictable) then
         raise invalid_parameter;
      end if;

      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if (a_task.name = task_name) then
            if (a_task.task_type /= poisson_type) and
              (a_task.task_type /= parametric_type)
            then
               raise invalid_parameter;
            end if;
            poisson_task_ptr (a_task).predictable := param_value;
            exit;
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);

      end loop;
   end set;

   procedure set
     (my_tasks    : in out tasks_set;
      task_name   : in     Unbounded_String;
      param_name  : in     task_parameters;
      param_value : in     Natural)
   is
      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

   begin

      if
        ((param_name /= start_time) and
         (param_name /= blocking_time) and
         (param_name /= capacity) and
         (param_name /= period) and
         (param_name /= deadline) and
         (param_name /= jitter))
      then
         raise invalid_parameter;
      end if;

      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if (a_task.name = task_name) then
            if (param_name = start_time) then
               a_task.start_time := param_value;
               exit;
            end if;
            if (param_name = deadline) then
               a_task.deadline := param_value;
            end if;
            if (param_name = period and a_task.task_type = periodic_type) then
               periodic_task_ptr (a_task).period := param_value;
               exit;
            end if;
            if (param_name = jitter and a_task.task_type = periodic_type) then
               periodic_task_ptr (a_task).jitter := param_value;
               exit;
            end if;
            if (param_name = period and a_task.task_type = poisson_type) then
               poisson_task_ptr (a_task).period := param_value;
               exit;
            end if;
            if (param_name = jitter and a_task.task_type = poisson_type) then
               poisson_task_ptr (a_task).jitter := param_value;
               exit;
            end if;
            if (param_name = capacity) then
               a_task.capacity := param_value;
               exit;
            end if;
            if (param_name = blocking_time) then
               a_task.blocking_time := param_value;
               exit;
            end if;
         end if;
         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);

      end loop;
   end set;

   function get_number_of_task_from_processor
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return tasks_range
   is
      number      : tasks_range := 0;
      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

   begin

      if is_empty (my_tasks) then
         return 0;
      end if;

      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if (a_task.cpu_name = processor_name) then
            number := number + 1;
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);

      end loop;

      return number;
   end get_number_of_task_from_processor;

   procedure periodic_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

      iterator1 : tasks_iterator;
      task1     : generic_task_ptr;

   begin

      reset_iterator (my_tasks, iterator1);

      loop
         current_element (my_tasks, task1, iterator1);

         if (task1.cpu_name = processor_name) or
           (processor_name = empty_string)
         then
            if (task1.task_type /= periodic_type) then
               raise task_must_be_periodic;
            end if;
         end if;

         exit when is_last_element (my_tasks, iterator1);
         next_element (my_tasks, iterator1);

      end loop;

   end periodic_control;

   --------------------------------------------------------------------------------
   -- Sporadic_Or_Periodic_Control
   --
   procedure sporadic_or_periodic_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

      iterator1 : tasks_iterator;
      task1     : generic_task_ptr;

   begin

      reset_iterator (my_tasks, iterator1);

      loop
         current_element (my_tasks, task1, iterator1);

         if (task1.cpu_name = processor_name) or
           (processor_name = empty_string)
         then
            if
              (task1.task_type /= sporadic_type and
               task1.task_type /= periodic_type)
            then
               raise task_must_be_sporadic_or_periodic;
            end if;
         end if;

         exit when is_last_element (my_tasks, iterator1);
         next_element (my_tasks, iterator1);

      end loop;

   end sporadic_or_periodic_control;

   procedure priority_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

      iterator1 : tasks_iterator;
      task1     : generic_task_ptr;
      iterator2 : tasks_iterator;
      task2     : generic_task_ptr;

   begin
      -- No duplicate priority
      --

      reset_iterator (my_tasks, iterator1);

      loop
         current_element (my_tasks, task1, iterator1);

         if (task1.cpu_name = processor_name) or
           (processor_name = empty_string)
         then
            reset_iterator (my_tasks, iterator2);

            loop
               current_element (my_tasks, task2, iterator2);

               if (task2.cpu_name = task1.cpu_name) and
                 (task1.name /= task2.name) and
                 (task1.priority = task2.priority)
               then
                  raise priority_error;
               end if;

               exit when is_last_element (my_tasks, iterator2);
               next_element (my_tasks, iterator2);

            end loop;

         end if;

         exit when is_last_element (my_tasks, iterator1);
         next_element (my_tasks, iterator1);

      end loop;
   end priority_control;

   -- Check start time
   --
   procedure start_time_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

      iterator1 : tasks_iterator;
      task1     : generic_task_ptr;

   begin

      reset_iterator (my_tasks, iterator1);

      loop
         current_element (my_tasks, task1, iterator1);

         if
           ((task1.cpu_name = processor_name) or
            (processor_name = empty_string)) and
           (task1.start_time /= 0)
         then
            raise start_time_error;
         end if;

         exit when is_last_element (my_tasks, iterator1);
         next_element (my_tasks, iterator1);

      end loop;
   end start_time_control;

   -- Check offset
   --
   procedure offset_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

      iterator1 : tasks_iterator;
      task1     : generic_task_ptr;

   begin

      reset_iterator (my_tasks, iterator1);

      loop
         current_element (my_tasks, task1, iterator1);

         if (task1.cpu_name = processor_name) or
           (processor_name = empty_string)
         then
            for i in 0 .. task1.offsets.nb_entries - 1 loop
               if (task1.offsets.entries (i).activation /= 0) then
                  raise offset_error;
               end if;
            end loop;
         end if;

         exit when is_last_element (my_tasks, iterator1);
         next_element (my_tasks, iterator1);

      end loop;
   end offset_control;

   procedure have_deadlines_equal_than_periods_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

   begin

      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if
           (not
            ((a_task.task_type = periodic_type) or
             (a_task.task_type = poisson_type)) and
            (a_task.cpu_name = processor_name))
         then
            raise task_must_be_periodic;
         end if;

         if (a_task.cpu_name = processor_name) or
           (processor_name = empty_string)
         then
            if a_task.task_type = periodic_type then
               if (a_task.deadline /= periodic_task_ptr (a_task).period) then
                  raise task_must_have_period_equal_to_deadline;
               end if;
            end if;

            if a_task.task_type = poisson_type then  -- check this
               if (a_task.deadline /= poisson_task_ptr (a_task).period) then
                  raise task_must_have_period_equal_to_deadline;
               end if;
            end if;
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);

      end loop;

   end have_deadlines_equal_than_periods_control;

   procedure deadline_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

      iterator1 : tasks_iterator;
      task1     : generic_task_ptr;

   begin

      reset_iterator (my_tasks, iterator1);

      loop
         current_element (my_tasks, task1, iterator1);

         if (task1.cpu_name = processor_name) or
           (processor_name = empty_string)
         then
            if task1.deadline = 0 then
               raise deadline_error;
            end if;
         end if;

         exit when is_last_element (my_tasks, iterator1);
         next_element (my_tasks, iterator1);

      end loop;

   end deadline_control;

   procedure have_same_period_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

      iterator1    : tasks_iterator;
      task1        : generic_task_ptr;
      period_value : Natural := 0;
      first        : Boolean := True;

   begin

      reset_iterator (my_tasks, iterator1);

      loop
         current_element (my_tasks, task1, iterator1);

         if not
           ((task1.task_type = periodic_type) or
            (task1.task_type = aperiodic_type))
         then
            raise task_model_error;
         end if;

         if (task1.cpu_name = processor_name) or
           (processor_name = empty_string)
         then
            if first then
               first := False;
               if task1.task_type = periodic_type then
                  period_value := periodic_task_ptr (task1).period;
               end if;
            else
               if task1.task_type = aperiodic_type and period_value /= 0 then
                  raise task_must_have_the_same_period_value;
               end if;
               if task1.task_type = periodic_type and
                 period_value /= periodic_task_ptr (task1).period
               then
                  raise task_must_have_the_same_period_value;
               end if;
            end if;
         end if;

         exit when is_last_element (my_tasks, iterator1);
         next_element (my_tasks, iterator1);

      end loop;

   end have_same_period_control;

   function deadline_inferior_to_period
     (my_tasks : in tasks_set) return Boolean
   is
      my_iterator : tasks_iterator;
      a_task      : generic_task_ptr;
      result      : Boolean := True;

   begin
      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if a_task.task_type = periodic_type then
            if (periodic_task_ptr (a_task).period < a_task.deadline) then
               result := False;
            end if;
         end if;

         if a_task.task_type = poisson_type then
            if (poisson_task_ptr (a_task).period < a_task.deadline) then
               result := False;
            end if;
         end if;

         -- Next task
         --
         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;

      return result;

   end deadline_inferior_to_period;

   function is_harmonic
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Boolean
   is
      my_iterator1, my_iterator2 : tasks_iterator;
      a_task1, a_task2           : generic_task_ptr;
      result                     : Boolean := True;
      tmp_mod                    : Natural;

   begin
      -- First loop
      --
      reset_iterator (my_tasks, my_iterator1);

      loop
         current_element (my_tasks, a_task1, my_iterator1);

         if (a_task1.cpu_name = processor_name) or
           (processor_name = empty_string)
         then

            -- Second loop
            --
            reset_iterator (my_tasks, my_iterator2);

            loop
               current_element (my_tasks, a_task2, my_iterator2);

               if (a_task2.cpu_name = processor_name) or
                 (processor_name = empty_string)
               then

                  if a_task1.task_type = periodic_type then
                     if
                       (periodic_task_ptr (a_task1).period >
                        periodic_task_ptr (a_task2).period)
                     then
                        tmp_mod :=
                          periodic_task_ptr (a_task1).period mod
                          periodic_task_ptr (a_task2).period;
                     else
                        tmp_mod :=
                          periodic_task_ptr (a_task2).period mod
                          periodic_task_ptr (a_task1).period;
                     end if;

                     if (a_task1.name /= a_task2.name and tmp_mod /= 0) then
                        result := False;
                     end if;
                  end if;

                  if a_task1.task_type = poisson_type then
                     if
                       (poisson_task_ptr (a_task1).period >
                        poisson_task_ptr (a_task2).period)
                     then
                        tmp_mod :=
                          poisson_task_ptr (a_task1).period mod
                          poisson_task_ptr (a_task2).period;
                     else
                        tmp_mod :=
                          poisson_task_ptr (a_task2).period mod
                          poisson_task_ptr (a_task1).period;
                     end if;

                     if (a_task1.name /= a_task2.name and tmp_mod /= 0) then
                        result := False;
                     end if;
                  end if;

               end if;

               -- next task
               --
               exit when is_last_element (my_tasks, my_iterator2);
               next_element (my_tasks, my_iterator2);

            end loop;

         end if;

         -- next task
         --
         exit when is_last_element (my_tasks, my_iterator1);
         next_element (my_tasks, my_iterator1);
      end loop;

      return result;
   end is_harmonic;

   -- Compute_Hyperperiod
   --
   function compute_hyperperiod
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String := empty_string) return Integer
   is
      iterator1   : tasks_iterator;
      task1       : generic_task_ptr;
      hyperperiod : Integer := 1;
   begin
      periodic_control (my_tasks, processor_name);

      reset_iterator (my_tasks, iterator1);
      loop
         current_element (my_tasks, task1, iterator1);

         if (task1.cpu_name = processor_name) or
           (processor_name = empty_string)
         then
            put_debug
              ("Task: " &
               To_String (task1.name) &
               " | Task Period: " &
               periodic_task_ptr (task1).period'img);
            hyperperiod :=
              natural_util.lcm (hyperperiod, periodic_task_ptr (task1).period);
         end if;

         exit when is_last_element (my_tasks, iterator1);
         next_element (my_tasks, iterator1);
      end loop;

      return hyperperiod;
   end compute_hyperperiod;

   -- Get_Max_Offset
   --
   function get_max_offset
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String := empty_string) return Integer
   is
      iterator1  : tasks_iterator;
      task1      : generic_task_ptr;
      max_offset : Integer := 0;
   begin
      periodic_control (my_tasks, processor_name);

      reset_iterator (my_tasks, iterator1);
      loop
         current_element (my_tasks, task1, iterator1);

         if (task1.cpu_name = processor_name) or
           (processor_name = empty_string)
         then
            if (task1.offsets.nb_entries > 0) then
               if max_offset < task1.offsets.entries (0).offset_value then
                  max_offset := task1.offsets.entries (0).offset_value;
               end if;
            end if;
         end if;

         exit when is_last_element (my_tasks, iterator1);
         next_element (my_tasks, iterator1);
      end loop;

      return max_offset;
   end get_max_offset;

   -- Get_Max_Start_Time
   --
   function get_max_start_time
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String := empty_string) return Integer
   is
      iterator1      : tasks_iterator;
      task1          : generic_task_ptr;
      max_start_time : Integer := 0;
   begin
      periodic_control (my_tasks, processor_name);

      reset_iterator (my_tasks, iterator1);
      loop
         current_element (my_tasks, task1, iterator1);

         if (task1.cpu_name = processor_name) or
           (processor_name = empty_string)
         then
            if max_start_time < task1.start_time then
               max_start_time := task1.start_time;
            end if;
         end if;

         exit when is_last_element (my_tasks, iterator1);
         next_element (my_tasks, iterator1);
      end loop;

      return max_start_time;
   end get_max_start_time;

   procedure check_entity_referencing_processor
     (my_tasks    : in tasks_set;
      a_processor : in Unbounded_String)
   is

      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

   begin
      if (get_number_of_elements (my_tasks) > 0) then

         reset_iterator (my_tasks, my_iterator);
         loop
            current_element (my_tasks, a_task, my_iterator);

            if (a_task.cpu_name = a_processor) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_processor (Current_Language) &
                     " " &
                     a_processor &
                     " : " &
                     lb_task (Current_Language) &
                     " " &
                     a_task.name &
                     " : " &
                     lb_entity_referenced_elsewhere (Current_Language)));
            end if;

            exit when is_last_element (my_tasks, my_iterator);
            next_element (my_tasks, my_iterator);
         end loop;

      end if;
   end check_entity_referencing_processor;

   procedure check_entity_referencing_address_space
     (my_tasks : in tasks_set;
      a_addr   : in Unbounded_String)
   is

      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

   begin
      if (get_number_of_elements (my_tasks) > 0) then

         reset_iterator (my_tasks, my_iterator);
         loop
            current_element (my_tasks, a_task, my_iterator);

            if (a_task.address_space_name = a_addr) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_address_space (Current_Language) &
                     " " &
                     a_addr &
                     " : " &
                     lb_task (Current_Language) &
                     " " &
                     a_task.name &
                     " : " &
                     lb_entity_referenced_elsewhere (Current_Language)));
            end if;

            exit when is_last_element (my_tasks, my_iterator);
            next_element (my_tasks, my_iterator);
         end loop;

      end if;
   end check_entity_referencing_address_space;

   procedure delete_address_space
     (my_tasks : in out tasks_set;
      a_addr   : in     Unbounded_String)
   is

      tmp         : tasks_set;
      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

   begin

      if (get_number_of_elements (my_tasks) > 0) then

         reset_iterator (my_tasks, my_iterator);
         loop
            current_element (my_tasks, a_task, my_iterator);

            if (a_task.address_space_name = a_addr) then
               add (tmp, a_task);
            end if;

            exit when is_last_element (my_tasks, my_iterator);
            next_element (my_tasks, my_iterator);
         end loop;

         if not is_empty (tmp) then
            reset_iterator (tmp, my_iterator);
            loop
               current_element (tmp, a_task, my_iterator);

               delete (my_tasks, a_task);

               exit when is_last_element (tmp, my_iterator);
               next_element (tmp, my_iterator);
            end loop;

            reset (tmp, False);
         end if;

      end if;

   end delete_address_space;

   procedure delete_processor
     (my_tasks    : in out tasks_set;
      a_processor : in     Unbounded_String)
   is

      tmp         : tasks_set;
      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

   begin

      if (get_number_of_elements (my_tasks) > 0) then

         reset_iterator (my_tasks, my_iterator);
         loop
            current_element (my_tasks, a_task, my_iterator);

            if (a_task.cpu_name = a_processor) then
               add (tmp, a_task);
            end if;

            exit when is_last_element (my_tasks, my_iterator);
            next_element (my_tasks, my_iterator);
         end loop;

         if not is_empty (tmp) then
            reset_iterator (tmp, my_iterator);
            loop
               current_element (tmp, a_task, my_iterator);

               delete (my_tasks, a_task);

               exit when is_last_element (tmp, my_iterator);
               next_element (tmp, my_iterator);
            end loop;

            reset (tmp, False);
         end if;
      end if;

   end delete_processor;

   function export_aadl_implementations
     (my_tasks     : in tasks_set;
      my_resources : in resources_set) return Unbounded_String
   is
      my_iterator          : tasks_iterator;
      a_task               : generic_task_ptr;
      my_resource_iterator : resources_iterator;
      a_resource           : generic_resource_ptr;

      print_feature_header : Boolean;

      result : Unbounded_String := empty_string;

   begin

      if not is_empty (my_tasks) then

         reset_iterator (my_tasks, my_iterator);

         loop
            current_element (my_tasks, a_task, my_iterator);

            result :=
              result &
              To_Unbounded_String ("thread " & To_String (a_task.name)) &
              unbounded_lf;
            print_feature_header := True;

            -- Look for shared resource access
            --
            if not is_empty (my_resources) then

               reset_iterator (my_resources, my_resource_iterator);

               loop
                  current_element
                    (my_resources,
                     a_resource,
                     my_resource_iterator);

                  if a_resource.critical_sections.nb_entries /= 0 then
                     for i in 0 .. a_resource.critical_sections.nb_entries - 1
                     loop
                        if a_resource.critical_sections.entries (i).item =
                          a_task.name
                        then
                           if print_feature_header then
                              result :=
                                result &
                                To_Unbounded_String (ASCII.HT & "features") &
                                unbounded_lf;
                              print_feature_header := False;
                           end if;
                           result :=
                             result &
                             To_Unbounded_String
                               (ASCII.HT &
                                ASCII.HT &
                                To_String (a_resource.name) &
                                "_features" &
                                " : requires data access " &
                                To_String (a_resource.name) &
                                ".Impl;") &
                             unbounded_lf;
                           exit;
                        end if;
                     end loop;
                  end if;

                  exit when is_last_element
                      (my_resources,
                       my_resource_iterator);

                  next_element (my_resources, my_resource_iterator);

               end loop;
            end if;

            result :=
              result &
              To_Unbounded_String ("end " & To_String (a_task.name) & ";") &
              unbounded_lf &
              unbounded_lf;

            result :=
              result &
              To_Unbounded_String
                ("thread implementation " &
                 To_String (a_task.name) &
                 ".Impl") &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String (ASCII.HT & "properties") &
              unbounded_lf;

            case a_task.task_type is
               when aperiodic_type =>
                  result :=
                    result &
                    To_Unbounded_String
                      (ASCII.HT &
                       ASCII.HT &
                       "Dispatch_Protocol => Background;") &
                    unbounded_lf;
               when periodic_type =>
                  result :=
                    result &
                    To_Unbounded_String
                      (ASCII.HT &
                       ASCII.HT &
                       "Dispatch_Protocol => Periodic;") &
                    unbounded_lf;
               when poisson_type =>
                  result :=
                    result &
                    To_Unbounded_String
                      (ASCII.HT &
                       ASCII.HT &
                       "Dispatch_Protocol => Poisson_Process;") &
                    unbounded_lf;
               when sporadic_type =>
                  result :=
                    result &
                    To_Unbounded_String
                      (ASCII.HT &
                       ASCII.HT &
                       "Dispatch_Protocol => Sporadic;") &
                    unbounded_lf;
               when scheduling_task_type =>
                  result :=
                    result &
                    To_Unbounded_String
                      (ASCII.HT &
                       ASCII.HT &
                       "Dispatch_Protocol => Scheduling_Task;") &
                    unbounded_lf;
               when parametric_type =>
                  result :=
                    result &
                    To_Unbounded_String
                      (ASCII.HT &
                       ASCII.HT &
                       "Dispatch_Protocol => User_Defined;") &
                    unbounded_lf;
                  result :=
                    result &
                    To_Unbounded_String
                      (ASCII.HT &
                       ASCII.HT &
                       "Cheddar_Properties::Source_Text => " &
                       """" &
                       To_String
                         (parametric_task_ptr (a_task).activation_rule) &
                       """" &
                       ";") &
                    unbounded_lf;
               when others =>
                  null;
            end case;

            if a_task.parameters.nb_entries > 0 then

               for i in 0 .. a_task.parameters.nb_entries - 1 loop

                  result :=
                    result &
                    To_Unbounded_String
                      (ASCII.HT &
                       ASCII.HT &
                       "User_Defined_Cheddar_Properties::" &
                       To_String
                         (a_task.parameters.entries (i).parameter_name) &
                       " => ");
                  if a_task.parameters.entries (i).type_of_parameter =
                    boolean_parameter
                  then
                     result :=
                       result &
                       To_Unbounded_String
                         (a_task.parameters.entries (i).boolean_value'img);
                  else
                     if a_task.parameters.entries (i).type_of_parameter =
                       integer_parameter
                     then
                        result :=
                          result &
                          To_Unbounded_String
                            (a_task.parameters.entries (i).integer_value'img);
                     else
                        if a_task.parameters.entries (i).type_of_parameter =
                          double_parameter
                        then
                           result :=
                             result &
                             To_Unbounded_String
                               (To_String
                                  (format
                                     (a_task.parameters.entries (i)
                                        .double_value)));
                        else
                           result :=
                             result &
                             To_Unbounded_String
                               ("""" &
                                To_String
                                  (a_task.parameters.entries (i)
                                     .string_value) &
                                """");
                        end if;
                     end if;
                  end if;
                  result := result & To_Unbounded_String (";") & unbounded_lf;
               end loop;
            end if;

            if a_task.offsets.nb_entries > 0 then
               for i in 0 .. a_task.offsets.nb_entries - 1 loop
                  result :=
                    result &
                    To_Unbounded_String
                      (ASCII.HT &
                       ASCII.HT &
                       "Cheddar_Properties::Dispatch_Offset_Value_" &
                       To_String (integer_util.format (Integer (i))) &
                       " => " &
                       a_task.offsets.entries (i).offset_value'img &
                       ";");
                  result :=
                    result &
                    To_Unbounded_String
                      (ASCII.HT &
                       ASCII.HT &
                       "Cheddar_Properties::Dispatch_Offset_Time_" &
                       To_String (integer_util.format (Integer (i))) &
                       " => " &
                       a_task.offsets.entries (i).activation'img &
                       " ms ;") &
                    unbounded_lf;
               end loop;
            end if;

            result :=
              result &
              To_Unbounded_String
                (ASCII.HT &
                 ASCII.HT &
                 "Cheddar_Properties::Context_Switch_Overhead => " &
                 a_task.text_memory_size'img &
                 " ms ;") &
              unbounded_lf;

            result :=
              result &
              To_Unbounded_String
                (ASCII.HT &
                 ASCII.HT &
                 "Source_Code_Size => " &
                 a_task.text_memory_size'img &
                 " kb ;") &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String
                (ASCII.HT &
                 ASCII.HT &
                 "Source_Stack_Size => " &
                 a_task.stack_memory_size'img &
                 " kb ;") &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String
                (ASCII.HT &
                 ASCII.HT &
                 "Compute_Execution_Time => " &
                 a_task.capacity'img &
                 " ms .. " &
                 a_task.capacity'img &
                 " ms;") &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String
                (ASCII.HT &
                 ASCII.HT &
                 "Cheddar_Properties::Dispatch_Absolute_Time => " &
                 a_task.start_time'img &
                 " ms ;") &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String
                (ASCII.HT &
                 ASCII.HT &
                 "Cheddar_Properties::POSIX_Scheduling_Policy => " &
                 a_task.policy'img &
                 ";") &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String
                (ASCII.HT &
                 ASCII.HT &
                 "Cheddar_Properties::Fixed_Priority => " &
                 a_task.priority'img &
                 ";") &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String
                (ASCII.HT &
                 ASCII.HT &
                 "Cheddar_Properties::Bound_On_Data_Blocking_Time => " &
                 a_task.blocking_time'img &
                 " ms ;") &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String
                (ASCII.HT &
                 ASCII.HT &
                 "Deadline  => " &
                 a_task.deadline'img &
                 " ms ;") &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String
                (ASCII.HT &
                 ASCII.HT &
                 "Cheddar_Properties::Criticality  => " &
                 a_task.criticality'img &
                 ";") &
              unbounded_lf;

            if (a_task.task_type /= aperiodic_type) then
               result :=
                 result &
                 To_Unbounded_String
                   (ASCII.HT &
                    ASCII.HT &
                    "Period => " &
                    periodic_task_ptr (a_task).period'img &
                    " ms ;") &
                 unbounded_lf;
               result :=
                 result &
                 To_Unbounded_String
                   (ASCII.HT &
                    ASCII.HT &
                    "Cheddar_Properties::Dispatch_Jitter => " &
                    periodic_task_ptr (a_task).jitter'img &
                    " ms ;") &
                 unbounded_lf;
            end if;

            if (a_task.task_type = poisson_type) or
              (a_task.task_type = sporadic_type) or
              (a_task.task_type = parametric_type)
            then
               result :=
                 result &
                 To_Unbounded_String
                   (ASCII.HT &
                    ASCII.HT &
                    "Cheddar_Properties::Dispatch_Seed_Value => " &
                    poisson_task_ptr (a_task).seed'img &
                    ";") &
                 unbounded_lf;
               result :=
                 result &
                 To_Unbounded_String
                   (ASCII.HT &
                    ASCII.HT &
                    "Cheddar_Properties::Dispatch_Seed_is_Predictable => " &
                    poisson_task_ptr (a_task).predictable'img &
                    ";") &
                 unbounded_lf;
            end if;

            result :=
              result &
              To_Unbounded_String
                ("end " & To_String (a_task.name) & ".Impl;") &
              unbounded_lf &
              unbounded_lf;

            exit when is_last_element (my_tasks, my_iterator);

            next_element (my_tasks, my_iterator);

         end loop;

      end if;

      return result;

   end export_aadl_implementations;

   function export_aadl_user_defined_properties
     (my_tasks : in tasks_set) return Unbounded_String
   is
      my_iterator : tasks_iterator;
      a_task      : generic_task_ptr;

      find            : Boolean := False;
      properties_list : unbounded_string_list;
      list_ite        : unbounded_string_iterator;
      str             : unbounded_string_ptr;
      use unbounded_strings.unbounded_string_list_package;

      result : Unbounded_String := empty_string;

   begin

      if not is_empty (my_tasks) then

         reset_iterator (my_tasks, my_iterator);

         loop
            current_element (my_tasks, a_task, my_iterator);

            if a_task.parameters.nb_entries > 0 then
               for i in 0 .. a_task.parameters.nb_entries - 1 loop

                  -- Check that the property does not exist
                  --
                  find := False;
                  if not is_empty (properties_list) then

                     reset_head_iterator (properties_list, list_ite);
                     loop
                        current_element (properties_list, str, list_ite);

                        if str.all =
                          a_task.parameters.entries (i).parameter_name
                        then
                           find := True;
                           exit;
                        end if;
                        if is_tail_element (properties_list, list_ite) then
                           exit;
                        end if;
                        next_element (properties_list, list_ite);
                     end loop;

                  end if;

                  if not find then
                     str     := new Unbounded_String;
                     str.all := a_task.parameters.entries (i).parameter_name;
                     add (properties_list, str);

                     result :=
                       result &
                       To_Unbounded_String
                         (ASCII.HT &
                          To_String
                            (a_task.parameters.entries (i).parameter_name) &
                          " : ");
                     if a_task.parameters.entries (i).type_of_parameter =
                       boolean_parameter
                     then
                        result :=
                          result &
                          To_Unbounded_String ("aadlboolean") &
                          unbounded_lf;
                     else
                        if a_task.parameters.entries (i).type_of_parameter =
                          integer_parameter
                        then
                           result :=
                             result &
                             To_Unbounded_String ("aadlinteger") &
                             unbounded_lf;
                        else
                           if a_task.parameters.entries (i).type_of_parameter =
                             double_parameter
                           then
                              result :=
                                result &
                                To_Unbounded_String ("aadlreal") &
                                unbounded_lf;
                           else
                              result :=
                                result &
                                To_Unbounded_String ("aadlstring") &
                                unbounded_lf;
                           end if;
                        end if;
                     end if;

                     result :=
                       result &
                       To_Unbounded_String
                         (ASCII.HT &
                          ASCII.HT &
                          "applies to (thread, thread group);") &
                       unbounded_lf;
                  end if;

               end loop;

            end if;

            exit when is_last_element (my_tasks, my_iterator);

            next_element (my_tasks, my_iterator);

         end loop;

      end if;

      return result;

   end export_aadl_user_defined_properties;

   function export_aadl_declarations
     (my_tasks           : in tasks_set;
      address_space_name : in Unbounded_String;
      number_of_ht       : in Natural) return Unbounded_String
   is
      my_iterator : tasks_iterator;
      a_task      : generic_task_ptr;

      result : Unbounded_String := empty_string;

   begin

      if not is_empty (my_tasks) then

         reset_iterator (my_tasks, my_iterator);

         loop
            current_element (my_tasks, a_task, my_iterator);

            if a_task.address_space_name = address_space_name then
               for i in 1 .. number_of_ht loop
                  result := result & ASCII.HT;
               end loop;
               result :=
                 result &
                 To_Unbounded_String
                   ("instancied_" &
                    To_String (a_task.name) &
                    " : thread " &
                    To_String (a_task.name) &
                    ".Impl;") &
                 unbounded_lf;
            end if;

            exit when is_last_element (my_tasks, my_iterator);

            next_element (my_tasks, my_iterator);

         end loop;

      end if;

      return result;

   end export_aadl_declarations;

end task_set;
