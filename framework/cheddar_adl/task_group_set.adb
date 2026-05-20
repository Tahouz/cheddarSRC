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

with Text_IO;        use Text_IO;
with Ada.Exceptions; use Ada.Exceptions;
with Resources;      use Resources;
use Resources.Resource_Accesses;
with time_unit_events; use time_unit_events;
use time_unit_events.time_unit_package;
with natural_util;                      use natural_util;
with double_util;                       use double_util;
with integer_util;                      use integer_util;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Objects;                           use Objects;
with Objects.extended;                  use Objects.extended;
with translate;                         use translate;
with Task_Groups;                       use Task_Groups;
with Tasks;                             use Tasks;
use Tasks.Generic_Task_List_Package;
with task_set;             use task_set;
with task_dependencies;    use task_dependencies;
with initialize_framework; use initialize_framework;

package body task_group_set is

   procedure check_task_group
     (my_task_groups  : in task_groups_set;
      name            : in Unbounded_String;
      task_group_type : in task_groups_type;
      start_time      : in Integer;
      period          : in Integer;
      deadline        : in Integer;
      jitter          : in Integer;
      priority        : in Integer;
      criticality     : in Integer)
   is

   begin
      if name = "" then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task_group_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task_group (Current_Language) &
               " " &
               name &
               " : " &
               lb_task_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if (jitter < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task_group (Current_Language) &
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
              (lb_task_group (Current_Language) &
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
              (lb_task_group (Current_Language) &
               " " &
               name &
               " : " &
               lb_period (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (deadline < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task_group (Current_Language) &
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
              (lb_task_group (Current_Language) &
               " " &
               name &
               " : " &
               lb_deadline (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_than (Current_Language) &
               lb_jitter (Current_Language)));
      end if;

      if (start_time < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_task_group (Current_Language) &
               " " &
               name &
               " : " &
               lb_start_time (Current_Language) &
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
              (lb_task_group (Current_Language) &
               " " &
               name &
               " : " &
               lb_invalid_priority (Current_Language)));
      end if;

   end check_task_group;

   procedure add_task_group
     (my_task_groups  : in out task_groups_set;
      name            : in     Unbounded_String;
      task_group_type : in     task_groups_type;
      start_time      : in     Integer := 0;
      period          : in     Integer := 0;
      deadline        : in     Integer := 0;
      jitter          : in     Integer := 0;
      priority        : in     Integer := 0;
      criticality     : in     Integer := 0)
   is

      dummy : generic_task_group_ptr;
   begin
      add_task_group
        (my_task_groups,
         dummy,
         name,
         task_group_type,
         start_time,
         period,
         deadline,
         jitter,
         priority,
         criticality);
   end add_task_group;

   procedure add_task_group
     (my_task_groups  : in out task_groups_set;
      a_task_group    : in out generic_task_group_ptr;
      name            : in     Unbounded_String;
      task_group_type : in     task_groups_type;
      start_time      : in     Integer := 0;
      period          : in     Integer := 0;
      deadline        : in     Integer := 0;
      jitter          : in     Integer := 0;
      priority        : in     Integer := 0;
      criticality     : in     Integer := 0)
   is

      new_multiframe_task_group  : multiframe_task_group_ptr;
      new_transaction_task_group : transaction_task_group_ptr;

      my_iterator : task_groups_iterator;

   begin

      check_initialize;

      check_task_group
        (my_task_groups,
         name,
         task_group_type,
         start_time,
         period,
         deadline,
         jitter,
         priority,
         criticality);

      if (get_number_of_elements (my_task_groups) > 0) then

         reset_iterator (my_task_groups, my_iterator);

         loop
            current_element (my_task_groups, a_task_group, my_iterator);
            if (name = a_task_group.name) then
               Raise_Exception
                 (task_set.invalid_parameter'identity,
                  To_String
                    (lb_task_group (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_task_group_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;
            exit when is_last_element (my_task_groups, my_iterator);
            next_element (my_task_groups, my_iterator);
         end loop;
      end if;

      case task_group_type is
         when multiframe_type =>
            new_multiframe_task_group := new multiframe_task_group;
            a_task_group := generic_task_group_ptr (new_multiframe_task_group);
         when transaction_type =>
            new_transaction_task_group := new transaction_task_group;
            a_task_group               :=
              generic_task_group_ptr (new_transaction_task_group);
      end case;

      a_task_group.name            := name;
      a_task_group.period          := period;
      a_task_group.jitter          := jitter;
      a_task_group.deadline        := deadline;
      a_task_group.start_time      := start_time;
      a_task_group.priority        := priority_range (priority);
      a_task_group.criticality     := criticality;
      a_task_group.task_group_type := task_group_type;

      add_task_group (my_task_groups, a_task_group);

   exception
      when generic_task_group_set.full_set =>
         Raise_Exception
           (task_set.invalid_parameter'identity,
            To_String (lb_can_not_define_more_task_groups (Current_Language)));
   end add_task_group;

   procedure add_task_group
     (my_task_groups : in out task_groups_set;
      a_task_group   : in     generic_task_group_ptr)
   is
   begin

      check_initialize;

      add (my_task_groups, a_task_group);
   end add_task_group;

   procedure add_task
     (my_tasks                  : in out tasks_set;
      my_task_groups            : in out task_groups_set;
      task_group_name           : in     Unbounded_String;
      name                      : in     Unbounded_String;
      cpu_name                  : in     Unbounded_String;
      address_space_name        : in     Unbounded_String;
      task_type                 : in     tasks_type;
      start_time                : in     Integer;
      capacity                  : in     Integer;
      period                    : in     Integer;
      deadline                  : in     Integer;
      jitter                    : in     Integer;
      blocking_time             : in     Integer;
      priority                  : in     Integer;
      criticality               : in     Integer;
      policy                    : in     policies;
      offset                    : in     offsets_table := no_offset;
      stack_memory_size         : in     Integer                       := 0;
      text_memory_size          : in     Integer                       := 0;
      text_memory_start_address : in     Integer                       := -1;
      param : in user_defined_parameters_table := no_user_defined_parameter;
      parametric_rule_name      : in     Unbounded_String := empty_string;
      seed_value                : in     Integer                       := 0;
      predictable               : in     Boolean                       := True;
      context_switch_overhead   : in     Integer                       := 0)
   is
      a_task_group : generic_task_group_ptr;
      found        : Boolean := False;
   begin

      check_initialize;

      -- Get the task_group pointer
      a_task_group := search_task_group (my_task_groups, task_group_name);

      -- Task_Set.Add_Task
      task_set.add_task
        (my_tasks,
         name                    => name,
         cpu_name                => cpu_name,
         core_name               => empty_string,
         address_space_name      => address_space_name,
         task_type               => task_type,
         start_time              => start_time,
         capacity                => capacity,
         period                  => period,
         deadline                => deadline,
         jitter                  => jitter,
         blocking_time           => blocking_time,
         priority                => priority,
         criticality             => criticality,
         policy                  => policy,
         offset                  => offset,
         stack_memory_size       => stack_memory_size,
         text_memory_size        => text_memory_size,
         param                   => param,
         parametric_rule_name    => parametric_rule_name,
         seed_value              => seed_value,
         predictable             => predictable,
         context_switch_overhead => context_switch_overhead);

      -- Add created task to task_group
      add_task_to_group (my_tasks, a_task_group, name);

   end add_task;

   procedure add_task_to_group
     (my_tasks      : in out tasks_set;
      my_task_group : in out generic_task_group_ptr;
      name          : in     Unbounded_String)
   is
      a_task : generic_task_ptr;
   begin
      -- Get task pointer according to name in task set
      a_task := search_task (my_tasks, name);

      add_task_to_group (my_task_group, a_task);
   end add_task_to_group;

   procedure add_task_to_group
     (my_task_group : in out generic_task_group_ptr;
      a_task        : in out generic_task_ptr)
   is
      tail_task       : generic_task_ptr;
      tail_frame_task : frame_task_ptr;
      a_multiframe    : multiframe_task_group_ptr;
   begin

      check_initialize;

      if task_is_present_in_group (my_task_group, a_task.name) then
         Raise_Exception
           (task_set.invalid_parameter'identity,
            To_String
              (lb_task (Current_Language) &
               " " &
               a_task.name &
               " : " &
               lb_task_name (Current_Language) &
               lb_already_defined (Current_Language)));
      end if;

      -- Check if task is of correct task_type according to task_group_type
      --
      check_task (my_task_group, a_task);

      -- Modify A_Task's start time in Multiframe case
      --
      if (not is_empty (my_task_group.task_list)) and
        (my_task_group.task_group_type = multiframe_type)
      then
         tail_task       := get_tail (my_task_group.task_list);
         tail_frame_task := frame_task_ptr (tail_task);

         -- Start_Time
         --
         a_task.start_time :=
           tail_frame_task.start_time + tail_frame_task.interarrival;
      end if;

      -- Add task to task list tail
      --
      add_tail (my_task_group.task_list, a_task);

      -- Update Multiframe period
      --
      if (my_task_group.task_group_type = multiframe_type) then
         a_multiframe := multiframe_task_group_ptr (my_task_group);
         set_multiframe_period (a_multiframe);
      end if;
   end add_task_to_group;

   procedure check_task
     (a_task_group : in generic_task_group_ptr;
      a_task       : in generic_task_ptr)
   is

   begin
      case a_task_group.task_group_type is
         when multiframe_type =>
            if (a_task.task_type /= frame_task_type) then
               Raise_Exception
                 (task_set.invalid_parameter'identity,
                  To_String
                    (lb_task (Current_Language) &
                     " " &
                     a_task.name &
                     " : " &
                     lb_task_type (Current_Language) &
                     lb_must_be (Current_Language) &
                     lb_frame (Current_Language)));
            end if;
         when transaction_type =>
            if (a_task.task_type /= periodic_type) then
               Raise_Exception
                 (task_set.invalid_parameter'identity,
                  To_String
                    (lb_task (Current_Language) &
                     " " &
                     a_task.name &
                     " : " &
                     lb_task_type (Current_Language) &
                     lb_must_be (Current_Language) &
                     lb_periodic (Current_Language)));
            end if;
         when others =>
            null;
      end case;
   end check_task;

   function task_is_present_in_group
     (my_task_group : in generic_task_group_ptr;
      name          : in Unbounded_String) return Boolean
   is

      my_iterator : generic_task_iterator;
      a_task      : generic_task_ptr;

   begin

      if not is_empty (my_task_group.task_list) then
         reset_head_iterator (my_task_group.task_list, my_iterator);

         loop
            current_element (my_task_group.task_list, a_task, my_iterator);

            if (a_task.name = name) then
               return True;
            end if;

            exit when is_tail_element (my_task_group.task_list, my_iterator);

            next_element (my_task_group.task_list, my_iterator);

         end loop;
      else
         return False;
      end if;

      return False;

   end task_is_present_in_group;

   function search_task_group
     (my_task_groups : in task_groups_set;
      name           : in Unbounded_String) return generic_task_group_ptr
   is

      my_iterator  : task_groups_iterator;
      a_task_group : generic_task_group_ptr;
      result       : generic_task_group_ptr;
      found        : Boolean := False;

   begin
      if not is_empty (my_task_groups) then
         reset_iterator (my_task_groups, my_iterator);
         loop
            current_element (my_task_groups, a_task_group, my_iterator);

            if (a_task_group.name = name) then
               found  := True;
               result := a_task_group;
            end if;

            exit when is_last_element (my_task_groups, my_iterator);
            next_element (my_task_groups, my_iterator);
         end loop;
      end if;

      if not found then
         Raise_Exception
           (task_group_not_found'identity,
            To_String (lb_task_group_name (Current_Language) & "=" & name));
      end if;

      return result;
   end search_task_group;

   function search_task_group_by_id
     (my_task_groups : in task_groups_set;
      id             : in Unbounded_String) return generic_task_group_ptr
   is
      my_iterator  : task_groups_iterator;
      a_task_group : generic_task_group_ptr;
      result       : generic_task_group_ptr;
      found        : Boolean := False;
   begin

      if not is_empty (my_task_groups) then
         reset_iterator (my_task_groups, my_iterator);
         loop
            current_element (my_task_groups, a_task_group, my_iterator);

            if (a_task_group.cheddar_private_id = id) then
               found  := True;
               result := a_task_group;
            end if;

            exit when is_last_element (my_task_groups, my_iterator);
            next_element (my_task_groups, my_iterator);
         end loop;
      end if;

      if not found then
         Raise_Exception
           (task_group_not_found'identity,
            To_String (lb_task_group_name (Current_Language) & "=" & id));
      end if;

      return result;
   end search_task_group_by_id;

   function task_group_is_present
     (my_task_groups : in task_groups_set;
      name           : in Unbounded_String) return Boolean
   is
      my_iterator  : task_groups_iterator;
      a_task_group : generic_task_group_ptr;
   begin

      if is_empty (my_task_groups) then
         return False;
      else
         reset_iterator (my_task_groups, my_iterator);
         loop
            current_element (my_task_groups, a_task_group, my_iterator);

            if (a_task_group.name = name) then
               return True;
            end if;

            exit when is_last_element (my_task_groups, my_iterator);
            next_element (my_task_groups, my_iterator);
         end loop;

         return False;
      end if;

   end task_group_is_present;

   function search_task_group_by_task
     (my_task_groups : in task_groups_set;
      name           : in Unbounded_String) return generic_task_group_ptr
   is
      my_iterator  : task_groups_iterator;
      a_task_group : generic_task_group_ptr;
      result       : generic_task_group_ptr;
      found        : Boolean := False;
   begin
      if not is_empty (my_task_groups) then
         reset_iterator (my_task_groups, my_iterator);

         loop
            current_element (my_task_groups, a_task_group, my_iterator);

            if (task_is_present_in_group (a_task_group, name)) then
               found  := True;
               result := a_task_group;
            end if;

            exit when is_last_element (my_task_groups, my_iterator);
            next_element (my_task_groups, my_iterator);
         end loop;
      end if;

      if not found then
         Raise_Exception
           (task_not_found'identity,
            To_String (lb_task_name (Current_Language) & "=" & name));
      end if;

      return result;

   end search_task_group_by_task;

   function search_task_group_by_task
     (my_task_groups : in task_groups_set;
      my_task        : in generic_task_ptr) return generic_task_group_ptr
   is
   begin
      return search_task_group_by_task (my_task_groups, my_task.name);
   end search_task_group_by_task;

   function get_multiframe_period
     (a_multiframe : in multiframe_task_group_ptr) return Integer
   is
      mf_period : Integer;

      my_iterator  : generic_task_iterator;
      a_task       : generic_task_ptr;
      a_frame_task : frame_task_ptr;
   begin
      mf_period := 0;

      if (not is_empty (a_multiframe.task_list)) then
         -- Compute MF_Period by summing Frame.interarrivals
         reset_head_iterator (a_multiframe.task_list, my_iterator);
         loop
            current_element (a_multiframe.task_list, a_task, my_iterator);

            a_frame_task := frame_task_ptr (a_task);
            mf_period    := mf_period + a_frame_task.interarrival;

            exit when is_tail_element (a_multiframe.task_list, my_iterator);
            next_element (a_multiframe.task_list, my_iterator);
         end loop;
      end if;

      return mf_period;
   end get_multiframe_period;

   function get_no_deadlocks_precedences_number
     (my_task_groups : in task_groups_set) return Integer
   is
   begin
      return get_no_deadlocks_precedences_number
          (my_task_groups,
           Integer (get_number_of_elements (my_task_groups)));
   end get_no_deadlocks_precedences_number;

   function get_no_deadlocks_precedences_number
     (my_task_groups : in task_groups_set;
      number_groups  : in Integer) return Integer
   is
      result          : Integer;
      a_task_group    : generic_task_group_ptr;
      next_task_group : generic_task_group_ptr;
   begin
      result := 0;

      for i in 0 .. (number_groups - 2) loop
         get_element_number
           (my_task_groups,
            a_task_group,
            (task_groups_range (i)));

         for j in (i + 1) .. (number_groups - 1) loop
            get_element_number
              (my_task_groups,
               next_task_group,
               (task_groups_range (j)));
            result :=
              result +
              Integer
                (get_number_of_elements (a_task_group.task_list) *
                 get_number_of_elements (next_task_group.task_list));
         end loop;
      end loop;

      return result;
   end get_no_deadlocks_precedences_number;

   procedure set_multiframe_period
     (a_multiframe : in out multiframe_task_group_ptr)
   is
      mf_period : Integer;

      my_iterator  : generic_task_iterator;
      a_task       : generic_task_ptr;
      a_frame_task : frame_task_ptr;
   begin
      if (not is_empty (a_multiframe.task_list)) then
         mf_period := get_multiframe_period (a_multiframe);

         -- Set MF_Period for all tasks
         reset_head_iterator (a_multiframe.task_list, my_iterator);
         loop
            current_element (a_multiframe.task_list, a_task, my_iterator);

            a_frame_task        := frame_task_ptr (a_task);
            a_frame_task.period := mf_period;
            -- TODO Set MF_Period to A_Multiframe

            exit when is_tail_element (a_multiframe.task_list, my_iterator);
            next_element (a_multiframe.task_list, my_iterator);
         end loop;
      end if;
   end set_multiframe_period;

   procedure set_multiframe_precedences
     (my_task_groups : in     task_groups_set;
      my_precedences : in out tasks_dependencies_ptr)
   is
      my_iterator  : task_groups_iterator;
      a_task_group : generic_task_group_ptr;
      a_multiframe : multiframe_task_group_ptr;
   begin
      if (not is_empty (my_task_groups)) then
         reset_iterator (my_task_groups, my_iterator);
         loop
            current_element (my_task_groups, a_task_group, my_iterator);

            if (a_task_group.task_group_type = multiframe_type) then
               a_multiframe := multiframe_task_group_ptr (a_task_group);
               set_multiframe_precedences (a_multiframe, my_precedences);
            end if;

            exit when is_last_element (my_task_groups, my_iterator);
            next_element (my_task_groups, my_iterator);
         end loop;
      end if;
   end set_multiframe_precedences;

   procedure set_multiframe_precedences
     (a_multiframe   : in     multiframe_task_group_ptr;
      my_precedences : in out tasks_dependencies_ptr)
   is
      my_iterator      : generic_task_iterator;
      my_next_iterator : generic_task_iterator;
      a_task           : generic_task_ptr;
      next_task        : generic_task_ptr;
   begin
      if (not is_empty (a_multiframe.task_list)) then
         reset_head_iterator (a_multiframe.task_list, my_iterator);
         reset_head_iterator (a_multiframe.task_list, my_next_iterator);
         loop
            current_element (a_multiframe.task_list, a_task, my_iterator);

            if
              (not is_tail_element (a_multiframe.task_list, my_next_iterator))
            then
               next_element (a_multiframe.task_list, my_next_iterator);
               current_element
                 (a_multiframe.task_list,
                  next_task,
                  my_next_iterator);
            end if;

            if (not is_tail_element (a_multiframe.task_list, my_iterator)) then
               add_one_task_dependency_precedence
                 (my_precedences,
                  a_task,
                  next_task);
            end if;

            exit when is_tail_element (a_multiframe.task_list, my_iterator);
            next_element (a_multiframe.task_list, my_iterator);
         end loop;
      end if;
   end set_multiframe_precedences;

   procedure set_interarrival
     (a_frame_task : in out frame_task_ptr;
      a_multiframe : in out multiframe_task_group_ptr;
      interarrival : in     Integer)
   is
      dummy_task_group : generic_task_group_ptr;
   begin
      dummy_task_group := generic_task_group_ptr (a_multiframe);
      if
        (not task_is_present_in_group (dummy_task_group, a_frame_task.name))
      then
         -- TODO Add better exception message
         Raise_Exception
           (task_not_present_in_group'identity,
            "Task is not present in group");
      end if;

      a_frame_task.interarrival := interarrival;
      set_multiframe_period (a_multiframe);
      set_multiframe_start_times (a_multiframe);
   end set_interarrival;

   procedure set_multiframe_start_times
     (a_multiframe : in multiframe_task_group_ptr)
   is
      my_iterator      : generic_task_iterator;
      my_next_iterator : generic_task_iterator;
      a_task           : generic_task_ptr;
      a_frame_task     : frame_task_ptr;
      next_task        : generic_task_ptr;
   begin
      if (not is_empty (a_multiframe.task_list)) then
         reset_head_iterator (a_multiframe.task_list, my_iterator);
         reset_head_iterator (a_multiframe.task_list, my_next_iterator);
         loop
            current_element (a_multiframe.task_list, a_task, my_iterator);

            if
              (not is_tail_element (a_multiframe.task_list, my_next_iterator))
            then
               next_element (a_multiframe.task_list, my_next_iterator);
               current_element
                 (a_multiframe.task_list,
                  next_task,
                  my_next_iterator);
            end if;

            if (not is_tail_element (a_multiframe.task_list, my_iterator)) then
               a_frame_task         := frame_task_ptr (a_task);
               next_task.start_time :=
                 a_frame_task.start_time + a_frame_task.interarrival;
            end if;

            exit when is_tail_element (a_multiframe.task_list, my_iterator);
            next_element (a_multiframe.task_list, my_iterator);
         end loop;
      end if;
   end set_multiframe_start_times;

   procedure check_entity_referencing_task
     (my_task_groups : in task_groups_set;
      a_task         : in Unbounded_String)
   is

      a_task_group : generic_task_group_ptr;
      my_iterator  : task_groups_iterator;

   begin

      if (get_number_of_elements (my_task_groups) > 0) then

         reset_iterator (my_task_groups, my_iterator);
         loop
            current_element (my_task_groups, a_task_group, my_iterator);

-- Look for the task in the task list
--
            declare
               my_next_iterator : generic_task_iterator;
               a_generic_task   : generic_task_ptr;
            begin
               if (not is_empty (a_task_group.task_list)) then
                  reset_head_iterator
                    (a_task_group.task_list,
                     my_next_iterator);
                  loop
                     current_element
                       (a_task_group.task_list,
                        a_generic_task,
                        my_next_iterator);

                     if
                       (not is_tail_element
                          (a_task_group.task_list,
                           my_next_iterator))
                     then
                        if (a_generic_task.name = a_task) then
                           Raise_Exception
                             (invalid_parameter'identity,
                              To_String
                                (lb_task (Current_Language) &
                                 " " &
                                 a_task &
                                 " : " &
                                 lb_task_group (Current_Language) &
                                 " " &
                                 a_task_group.name &
                                 " : " &
                                 lb_entity_referenced_elsewhere
                                   (Current_Language)));
                        end if;
                     end if;

                     exit when is_tail_element
                         (a_task_group.task_list,
                          my_next_iterator);
                     next_element (a_task_group.task_list, my_next_iterator);
                  end loop;
               end if;
            end;

            exit when is_last_element (my_task_groups, my_iterator);
            next_element (my_task_groups, my_iterator);
         end loop;

      end if;

   end check_entity_referencing_task;

   procedure transaction_control (my_task_groups : in task_groups_set) is

      iterator1   : task_groups_iterator;
      task_group1 : generic_task_group_ptr;

   begin

      reset_iterator (my_task_groups, iterator1);

      loop
         current_element (my_task_groups, task_group1, iterator1);

         if task_group1.task_group_type /= transaction_type then
            raise transaction_error;
         end if;

         exit when is_last_element (my_task_groups, iterator1);
         next_element (my_task_groups, iterator1);

      end loop;

   end transaction_control;

end task_group_set;
