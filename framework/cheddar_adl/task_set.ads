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
--    $Rev: 4961 $
--    $Date: 2024-04-11 19:02:15 +0200 (jeu., 11 avril 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Doubles;                  use Doubles;
with unbounded_strings;        use unbounded_strings;
with Framework_Config;         use Framework_Config;
with Tasks;                    use Tasks;
with Task_Groups;              use Task_Groups;
with Parameters;               use Parameters;
with Parameters.extended;      use Parameters.extended;
use Parameters.User_Defined_Parameters_Table_Package;
with Offsets;                  use Offsets;
with Offsets.extended;         use Offsets.extended;
use Offsets.Offsets_Table_Package;
with resource_set;             use resource_set;
with execution_units;          use execution_units;
with execution_units.extended; use execution_units.extended;
with cache_access_profile_set; use cache_access_profile_set;
with MILS_Security;            use MILS_Security;

with sets;

package task_set is

   ----------------------------------------------------------
   -- Definition of a set
   ----------------------------------------------------------

   package generic_task_set is new sets
     (max_element    => Framework_Config.Max_Tasks,
      element        => generic_task_ptr,
      copy           => Copy,
      free           => Free,
      put            => Put,
      xml_string     => XML_String,
      xml_ref_string => XML_Ref_String);

   use generic_task_set;

   type tasks_set is new generic_task_set.set with private;

   subtype tasks_range is generic_task_set.element_range;
   subtype tasks_iterator is generic_task_set.iterator;

   ----------------------------------------------------------
   -- Exceptions defined in the set package
   ----------------------------------------------------------

   -- Raised if periodic tasks are expected
   --
   task_must_be_periodic : exception;

   -- Raised if sporadic or periodic tasks are expected
   -- SR 11/2018
   task_must_be_sporadic_or_periodic : exception;

   -- Raised if tasks are not periodic and poisson process
   --
   task_must_be_periodic_or_poisson_process : exception;

   -- Raised if a task has a wrong type
   --
   task_model_error : exception;

   -- Raised when a given task is not in a task set
   --
   task_not_found : exception;

   -- Raised when parameters provided to Add_Task are wrong
   --
   invalid_parameter : exception;

   -- Raised when a treatement required that the processor
   -- utilization is less than a given value for a given task set
   --
   processor_utilization_exceeded : exception;

   -- Tasks must have deadline equals to period
   --
   task_must_have_period_equal_to_deadline : exception;

   -- All tasks must have different priority values
   --
   priority_error : exception;

   -- Start times have to be null
   --
   start_time_error : exception;

   -- Offsets have to be null
   --
   offset_error : exception;

   -- Offsets must be defined
   --
   offset_must_be_defined : exception;

   -- Tasks must have the same period value
   --
   task_must_have_the_same_period_value : exception;

   -- Tasks must have deadline > 0
   --
   deadline_error : exception;

   ----------------------------------------------------------
   -- I/O operations
   ----------------------------------------------------------

   function export_aadl_implementations
     (my_tasks     : in tasks_set;
      my_resources : in resources_set) return Unbounded_String;

   function export_aadl_declarations
     (my_tasks           : in tasks_set;
      address_space_name : in Unbounded_String;
      number_of_ht       : in Natural) return Unbounded_String;

   function export_aadl_user_defined_properties
     (my_tasks : in tasks_set) return Unbounded_String;

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
      capacity_model            : in Execution_Unit_Model_Type :=
      LiuLayland_Execution_Unit;
      capacities                : in execution_units_table     := no_values;
      qualities                 : in execution_units_table     := no_values;
      completion_time           : in Integer                   := 0;
      outer_period              : in Integer                   := 0;
      outer_duration            : in Integer                   := 0);

   ----------------------------------------------------------
   -- Procedure to proceed modification on a set
   ----------------------------------------------------------

   procedure add_task
     (my_tasks                   : in out tasks_set;
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
      capacity_model            : in Execution_Unit_Model_Type :=
      LiuLayland_Execution_Unit;
      capacities                : in execution_units_table     := no_values;
      qualities                 : in execution_units_table     := no_values;
      completion_time           : in Integer                   := 0;
      outer_period              : in Integer                   := 0;
      outer_duration            : in Integer                   := 0);

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
      param 			 : in 	  user_defined_parameters_table   := no_user_defined_parameter;
      parametric_rule_name       : in     Unbounded_String 		  := empty_string;
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
      capacity_model            : in Execution_Unit_Model_Type :=
      LiuLayland_Execution_Unit;
      capacities                : in execution_units_table     := no_values;
      qualities                 : in execution_units_table     := no_values;
      completion_time           : in Integer                   := 0;
      outer_period              : in Integer                   := 0;
      outer_duration            : in Integer                   := 0);

   -- Search for tasks referencing an address space
   --
   procedure check_entity_referencing_address_space
     (my_tasks : in tasks_set;
      a_addr   : in Unbounded_String);
   procedure check_entity_referencing_processor
     (my_tasks    : in tasks_set;
      a_processor : in Unbounded_String);

   -- Delete all tasks located on the address space 'a_addr'
   --
   procedure delete_address_space
     (my_tasks : in out tasks_set;
      a_addr   : in     Unbounded_String);

   -- Delete all tasks located on the processor 'a_processor'
   --
   procedure delete_processor
     (my_tasks    : in out tasks_set;
      a_processor : in     Unbounded_String);

   ------------------------------------------------------
   -- Read information from a set
   ------------------------------------------------------

   -- Get the number of tasks hosted by the
   -- processor "Processor_Name"
   --
   function get_number_of_task_from_processor
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return tasks_range;

   -- Get the task pointer of the task named "Name"
   --
   function search_task
     (my_tasks : in tasks_set;
      name     : in Unbounded_String) return generic_task_ptr;

   function search_task_by_id
     (my_tasks : in tasks_set;
      id       : in Unbounded_String) return generic_task_ptr;

   -- Check if a given task is stored in the task set
   --
   function task_is_present
     (my_tasks : in tasks_set;
      name     : in Unbounded_String) return Boolean;

   ----------------------------------------------------------
   -- List of parameters the user can set of get directly
   -- throught the set
   ----------------------------------------------------------

   type task_parameters is
     (cpu_name,
      address_space_name,
      core_name,
      capacity,
      start_time,
      priority,
      period,
      blocking_time,
      deadline,
      jitter,
      seed,
      predictable,
      criticality,
      mils_confidentiality_level,
      mils_integrity_level);

   -- Set the value of a parameter of a given task
   --
   procedure set
     (my_tasks    : in out tasks_set;
      task_name   : in     Unbounded_String;
      param_name  : in     task_parameters;
      param_value : in     Unbounded_String);

   procedure set
     (my_tasks    : in out tasks_set;
      task_name   : in     Unbounded_String;
      param_name  : in     task_parameters;
      param_value : in     priority_range);

   procedure set
     (my_tasks    : in out tasks_set;
      task_name   : in     Unbounded_String;
      param_name  : in     task_parameters;
      param_value : in     Natural);

   procedure set
     (my_tasks    : in out tasks_set;
      task_name   : in     Unbounded_String;
      param_name  : in     task_parameters;
      param_value : in     Boolean);

   -- Get the value of a parameter of a given task
   --
   function get
     (my_tasks   : in tasks_set;
      task_name  : in Unbounded_String;
      param_name : in task_parameters) return Unbounded_String;

   function get
     (my_tasks   : in tasks_set;
      task_name  : in Unbounded_String;
      param_name : in task_parameters) return priority_range;

   function get
     (my_tasks   : in tasks_set;
      task_name  : in Unbounded_String;
      param_name : in task_parameters) return Natural;

   function get
     (my_tasks   : in tasks_set;
      task_name  : in Unbounded_String;
      param_name : in task_parameters) return Boolean;

   --------------------------------------------------------
   -- Functions to proceed sort on a set
   --------------------------------------------------------
   function increasing_ucb
     (caps :    cache_access_profiles_set;
      op1  : in generic_task_ptr;
      op2  : in generic_task_ptr) return Boolean;

   function increasing_si
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean;

   function increasing_utilization
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean;

   function increasing_name
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean;

   function increasing_deadline
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean;

   function decreasing_deadline
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean;

   function increasing_period
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean;

   function decreasing_period
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean;

   function increasing_priority
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean;

   function decreasing_priority
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean;

   function increasing_offset
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean;

   function decreasing_period_deadline
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean;

   function increasing_period_deadline
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean;

   function increasing_text_memory_start_address
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean;

   function increasing_start_time
     (op1 : in generic_task_ptr;
      op2 : in generic_task_ptr) return Boolean;

   ----------------------------------------------------
   -- Control sub-programs
   ----------------------------------------------------

   -- These functions test and return TRUE if all the
   -- tasks of a task set have a common property
   --
   function deadline_inferior_to_period
     (my_tasks : in tasks_set) return Boolean;

   -- These function tests if all the
   -- tasks of a task set are harmonic
   --
   -- If "Processor_Name" is a null string, the control
   -- is done on all the task of the set. In the other
   -- case, the control is done on tasks located on the
   -- processor "Processor_Name"
   --

   function is_harmonic
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Boolean;

   -- These subprogram test  if all the
   -- tasks of a task set have a common property
   --
   -- If "Processor_Name" is a null string, the control
   -- is done on all the task of the set. In the other
   -- case, the control is done on tasks located on the
   -- processor "Processor_Name"
   --

   procedure have_deadlines_equal_than_periods_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String);

   procedure have_same_period_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String);

   procedure periodic_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String);

   procedure sporadic_or_periodic_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String);

   procedure priority_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String);

   procedure start_time_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String);

   procedure offset_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String);

   procedure deadline_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String);

   function compute_hyperperiod
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String := empty_string) return Integer;

   function get_max_offset
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String := empty_string) return Integer;

   function get_max_start_time
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String := empty_string) return Integer;

private

   type tasks_set is new generic_task_set.set with null record;

end task_set;
