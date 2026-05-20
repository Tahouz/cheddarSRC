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

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with unbounded_strings;     use unbounded_strings;
with Framework_Config;      use Framework_Config;
with resource_set;          use resource_set;
with Tasks;                 use Tasks;
with Task_Groups;           use Task_Groups;
with task_set;              use task_set;
with Parameters;            use Parameters;
with Parameters.extended;   use Parameters.extended;
use Parameters.User_Defined_Parameters_Table_Package;
with Offsets;               use Offsets;
with Offsets.extended;      use Offsets.extended;
use Offsets.Offsets_Table_Package;
with task_dependencies;     use task_dependencies;
with Doubles;               use Doubles;

with sets;

package task_group_set is
   ----------------------------------------------------------
   -- Definition of a task group set
   ----------------------------------------------------------

   package generic_task_group_set is new sets
     (max_element    => Framework_Config.Max_Task_groups,
      element        => generic_task_group_ptr,
      copy           => Copy,
      free           => Free,
      put            => Put,
      xml_string     => XML_String,
      xml_ref_string => XML_Ref_String);

   use generic_task_group_set;

   type task_groups_set is new generic_task_group_set.set with private;

   subtype task_groups_range is generic_task_group_set.element_range;
   subtype task_groups_iterator is generic_task_group_set.iterator;

   ----------------------------------------------------------
   -- Exceptions defined in the set package
   ----------------------------------------------------------

   -- Raised when a given task group is not in the task group set
   --
   task_group_not_found : exception;

   -- Raised when a task is not found in a group
   --
   task_not_present_in_group : exception;

   -- Raised when parameters provided to Add_Task_Group are wrong
   --
   invalid_parameter : exception;

   -- Raised when a task group does not contain only transaction
   --
   transaction_error : exception;

   ----------------------------------------------------------
   -- Procedure to proceed modification on a set
   ----------------------------------------------------------
   --
   procedure check_task_group
     (my_task_groups  : in task_groups_set;
      name            : in Unbounded_String;
      task_group_type : in task_groups_type;
      start_time      : in Integer;
      period          : in Integer;
      deadline        : in Integer;
      jitter          : in Integer;
      priority        : in Integer;
      criticality     : in Integer);

   procedure add_task_group
     (my_task_groups  : in out task_groups_set;
      name            : in     Unbounded_String;
      task_group_type : in     task_groups_type;
      start_time      : in     Integer := 0;
      period          : in     Integer := 0;
      deadline        : in     Integer := 0;
      jitter          : in     Integer := 0;
      priority        : in     Integer := 0;
      criticality     : in     Integer := 0);

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
      criticality     : in     Integer := 0);

   procedure add_task_group
     (my_task_groups : in out task_groups_set;
      a_task_group   : in     generic_task_group_ptr);

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
      context_switch_overhead   : in     Integer                       := 0);

   procedure add_task_to_group
     (my_tasks      : in out tasks_set;
      my_task_group : in out generic_task_group_ptr;
      name          : in     Unbounded_String);

   procedure add_task_to_group
     (my_task_group : in out generic_task_group_ptr;
      a_task        : in out generic_task_ptr);

   procedure check_task
     (a_task_group : in generic_task_group_ptr;
      a_task       : in generic_task_ptr);

   -- Search for entity referencing task groups
   --
   procedure check_entity_referencing_task
     (my_task_groups : in task_groups_set;
      a_task         : in Unbounded_String);

   ------------------------------------------------------
   -- Procedure to check task group set before analysis
   ------------------------------------------------------

   -- Enforce we have only transations
   --
   procedure transaction_control (my_task_groups : in task_groups_set);

   ------------------------------------------------------
   -- Read information from a set
   ------------------------------------------------------

   function task_group_is_present
     (my_task_groups : in task_groups_set;
      name           : in Unbounded_String) return Boolean;

   function task_is_present_in_group
     (my_task_group : in generic_task_group_ptr;
      name          : in Unbounded_String) return Boolean;

   function search_task_group_by_task
     (my_task_groups : in task_groups_set;
      name           : in Unbounded_String) return generic_task_group_ptr;

   function search_task_group_by_task
     (my_task_groups : in task_groups_set;
      my_task        : in generic_task_ptr) return generic_task_group_ptr;

   function search_task_group
     (my_task_groups : in task_groups_set;
      name           : in Unbounded_String) return generic_task_group_ptr;

   function search_task_group_by_id
     (my_task_groups : in task_groups_set;
      id             : in Unbounded_String) return generic_task_group_ptr;

   function get_multiframe_period
     (a_multiframe : in multiframe_task_group_ptr) return Integer;

   function get_no_deadlocks_precedences_number
     (my_task_groups : in task_groups_set) return Integer;

   function get_no_deadlocks_precedences_number
     (my_task_groups : in task_groups_set;
      number_groups  : in Integer) return Integer;

   ------------------------------------------------------
   -- Write information in a set
   ------------------------------------------------------

   procedure set_multiframe_period
     (a_multiframe : in out multiframe_task_group_ptr);

   procedure set_multiframe_precedences
     (my_task_groups : in     task_groups_set;
      my_precedences : in out tasks_dependencies_ptr);

   procedure set_multiframe_precedences
     (a_multiframe   : in     multiframe_task_group_ptr;
      my_precedences : in out tasks_dependencies_ptr);

   procedure set_interarrival
     (a_frame_task : in out frame_task_ptr;
      a_multiframe : in out multiframe_task_group_ptr;
      interarrival : in     Integer);

   procedure set_multiframe_start_times
     (a_multiframe : in multiframe_task_group_ptr);

private

   type task_groups_set is new generic_task_group_set.set with null record;

end task_group_set;
