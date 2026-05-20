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
--    $Rev: 5118 $
--    $Date: 2024-08-21 16:52:22 +0200 (mer., 21 août 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Framework_Config;      use Framework_Config;
with Tasks;                 use Tasks;
with task_set;              use task_set;
use task_set.generic_task_set;
with Buffers; use Buffers;
use Buffers.Buffer_Roles_Package;
with buffer_set; use buffer_set;
use buffer_set.generic_buffer_set;
with Messages;    use Messages;
with message_set; use message_set;
use message_set.generic_message_set;
with Dependencies; use Dependencies;
with Resources;    use Resources;
with sets;

package task_dependencies is

   -- Raised when a dependency accessor do not find the
   -- required dependency
   --
   dependency_not_found : exception;

   --------------------------------------------
   -- A set of half dependencies
   --------------------------------------------
   package half_dep_set is new sets
     (max_element    => Framework_Config.Max_Tasks_Dependencies,
      element        => dependency_ptr,
      free           => Free,
      copy           => Copy,
      put            => Put,
      xml_string     => XML_String,
      xml_ref_string => XML_Ref_String);
   use half_dep_set;

   type tasks_dependencies is record
      depends         : half_dep_set.set;
      dependent_tasks : tasks_set;
   end record;

   type tasks_dependencies_ptr is access all tasks_dependencies;

   function xml_string
     (obj   : in tasks_dependencies_ptr;
      level : in Natural := 0) return Unbounded_String;
   function xml_root_string
     (obj   : in tasks_dependencies_ptr;
      level : in Natural := 0) return Unbounded_String;

   subtype tasks_dependencies_range is half_dep_set.element_range;
   subtype tasks_dependencies_iterator is half_dep_set.iterator;

   ----------------------------------------------------------
   --  Basic services that are common to any dependency type
   ----------------------------------------------------------

   procedure free (my_dependencies : in out tasks_dependencies_ptr);

   function export_aadl_properties
     (my_dependencies : in tasks_dependencies_ptr;
      number_of_ht    : in Natural) return Unbounded_String;

   procedure reset
     (my_dependencies : in out tasks_dependencies_ptr;
      free_object     : in     Boolean := False);

   procedure duplicate
     (src  : in     tasks_dependencies_ptr;
      dest : in out tasks_dependencies_ptr);

   procedure put (my_dependencies : in tasks_dependencies_ptr);

   -----------------------------------------------------------------------
   --  Services below allow us to test
   --  if dependencies exist in an ADL model
   -----------------------------------------------------------------------


   -- Sub-programs to return a task which is has no source dependency
   -- (for any kind of dependency)
   --
   -- Get a task without predecessor
   --
   function get_a_root_task
     (my_dependencies : in tasks_dependencies_ptr) return generic_task_ptr;

   -- Get a task without successor
   --
   function get_a_leaf_task
     (my_dependencies : in tasks_dependencies_ptr) return generic_task_ptr;

   -- Get all tasks without predecessor
   --
   function get_root_tasks
     (my_dependencies : in tasks_dependencies_ptr) return tasks_set;

   -- Get all tasks without successor
   --
   function get_leaf_tasks
     (my_dependencies : in tasks_dependencies_ptr) return tasks_set;



   -- Sub-programs to test precedence constraints between two
   -- tasks (Precedence_Dependency dependencies only !)
   --

   function get_a_precedence_successor
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return generic_task_ptr;

   function get_a_precedence_predecessor
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return generic_task_ptr;

   function get_precedence_successors_list
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return tasks_set;

   function get_precedence_predecessors_list
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return tasks_set;

   function has_precedence_predecessor
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return Boolean;

   function has_precedence_successor
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return Boolean;

   -- Check is a task precedency is acyclic or not
   --
   function is_precedence_acyclic
     (my_dependencies : in tasks_dependencies_ptr) return Boolean;

   function is_precedence_cyclic
     (my_dependencies : in tasks_dependencies_ptr) return Boolean;

   function is_unique_precedence_dependency
     (my_dependencies : in tasks_dependencies_ptr;
      source_task     :    generic_task_ptr;
      sink_task       : in generic_task_ptr) return Boolean;

   function no_precedence_dependency_deadlock
     (my_dependencies : in tasks_dependencies_ptr;
      source_task     :    generic_task_ptr;
      sink_task       : in generic_task_ptr) return Boolean;

   ----------------------------------------------------------------------
   -- Sub-programs to test asynchronous communication dependencies 
   -- (Asyncronous communication dependencies only!)
   ----------------------------------------------------------------------

   function get_asynchronous_communication_successors_list
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return tasks_set;

   function has_asynchronous_communication_predecessor
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return Boolean;

   function get_asynchronous_communication_predecessors_list
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return tasks_set;


   ----------------------------------------------------------------------
   -- Sub-programs to test buffer dependencies.
   -- (buffer dependencies only!)
   -- Those sub-programs check if a task has buffer to read or write
   ----------------------------------------------------------------------

   function has_buffer_to_read
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return Boolean;

   function has_buffer_to_write
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return Boolean;

   ----------------------------------------------------------------------
   -- Search for dependencies referencing entities to be deleted
   ----------------------------------------------------------------------

   procedure check_entity_referencing_task
     (my_dependencies : in tasks_dependencies_ptr;
      a_task          : in Unbounded_String);
   procedure check_entity_referencing_processor
     (my_dependencies : in tasks_dependencies_ptr;
      a_processor     : in Unbounded_String);
   procedure check_entity_referencing_resource
     (my_dependencies : in tasks_dependencies_ptr;
      a_resource      : in Unbounded_String);
   procedure check_entity_referencing_buffer
     (my_dependencies : in tasks_dependencies_ptr;
      a_buffer        : in Unbounded_String);
   procedure check_entity_referencing_message
     (my_dependencies : in tasks_dependencies_ptr;
      a_message       : in Unbounded_String);

   ----------------------------------------------------------------------
   --  Services below allow you to delete
   --  dependencies.
   ----------------------------------------------------------------------

   -- Delete ALL dependencies  related to the
   -- processor "A_Processor"
   --
   procedure delete_processor_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_processor     : in     Unbounded_String);

   -- Delete ALL dependencies related to the
   -- address space "An_Address_Space"
   --
   procedure delete_address_space_all_task_dependencies
     (my_dependencies  : in out tasks_dependencies_ptr;
      an_address_space : in     Unbounded_String);

   -- Delete ALL dependencies :
   --  1) of a task (if My_Dep_Name is a Task_ptr)
   --  2) of a message  (if My_Dep_Name is a Message_ptr)
   --  3) of a buffer  (if My_Dep_Name is a Buffer_ptr)
   --  4) of a resource  (if My_Dep_Name is a Generic_Resource_ptr)
   --
   procedure delete_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_task          : in     generic_task_ptr);
   procedure delete_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_buffer        : in     buffer_ptr);
   procedure delete_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_message       : in     generic_message_ptr);
   procedure delete_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_resource      : in     generic_resource_ptr);

   -- Remove ONE dependency between two entities
   --
   procedure delete_one_task_dependency_remote_procedure_call
     (my_dependencies : in out tasks_dependencies_ptr;
      client          : in     generic_task_ptr;
      server          : in     generic_task_ptr);
   procedure delete_one_task_dependency_precedence
     (my_dependencies : in out tasks_dependencies_ptr;
      source          : in     generic_task_ptr;
      sink            : in     generic_task_ptr);
   procedure delete_one_task_dependency_time_triggered
     (my_dependencies : in out tasks_dependencies_ptr;
      source          : in     generic_task_ptr;
      sink            : in     generic_task_ptr;
      timing_type     : in time_triggered_communication_timing_property_type);
   procedure delete_one_task_dependency_queueing_buffer
     (my_dependencies : in out tasks_dependencies_ptr;
      a_task          : in     generic_task_ptr;
      a_buffer        : in     buffer_ptr;
      a_type          : in     orientation_dependency_type);
   procedure delete_one_task_dependency_black_board_buffer
     (my_dependencies : in out tasks_dependencies_ptr;
      a_task          : in     generic_task_ptr;
      a_dep           : in     buffer_ptr;
      a_type          : in     orientation_dependency_type);
   procedure delete_one_task_dependency_asynchronous_communication
     (my_dependencies : in out tasks_dependencies_ptr;
      a_task          : in     generic_task_ptr;
      a_message       : in     generic_message_ptr;
      a_type          : in     orientation_dependency_type);
   procedure delete_one_task_dependency_resource
     (my_dependencies : in out tasks_dependencies_ptr;
      a_task          : in     generic_task_ptr;
      a_resource      : in     generic_resource_ptr);

   ---------------------------------------
   --  Services below allow to update
   --  dependencies.
   ---------------------------------------

   -- Update ALL dependencies :
   --  1) of a task (if My_Dep_Name is a Task_ptr)
   --  2) of a message  (if My_Dep_Name is a Message_ptr)
   --  3) of a buffer  (if My_Dep_Name is a Buffer_ptr)
   --  4) of a resource  (if My_Dep_Name is a Generic_Resource_ptr)
   --
   procedure update_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_task          : in     generic_task_ptr);
   procedure update_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_buffer        : in     buffer_ptr);
   procedure update_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_message       : in     generic_message_ptr);
   procedure update_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_resource      : in     generic_resource_ptr);

   ---------------------------------------
   --  Services below allow to add
   --  dependencies.
   ---------------------------------------

   -- Add ALL dependencies from the definition
   -- of a given buffer
   --
   procedure add_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      my_tasks        : in     tasks_set;
      a_buffer        : in     buffer_ptr);

   -- Add ALL dependencies from the definition
   -- of a given resource
   --
   procedure add_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      my_tasks        : in     tasks_set;
      a_resource      : in     generic_resource_ptr);

   -- Add a dependency between two entities
   --
   procedure add_one_task_dependency_tdma_communication
     (my_dependencies   : in out tasks_dependencies_ptr;
      a_task            : in     generic_task_ptr;
      a_dep             : in     generic_message_ptr;
      a_type            : in     orientation_dependency_type);

   procedure add_one_task_dependency_asynchronous_communication
     (my_dependencies   : in out tasks_dependencies_ptr;
      a_task            : in     generic_task_ptr;
      a_dep             : in     generic_message_ptr;
      a_type            : in     orientation_dependency_type;
      protocol_property : in asynchronous_communication_protocol_property_type :=
        first_message);

   procedure add_one_task_dependency_resource
     (my_dependencies : in out tasks_dependencies_ptr;
      dependent_task  : in     generic_task_ptr;
      a_resource      : in     generic_resource_ptr);

   procedure add_one_task_dependency_queueing_buffer
     (my_dependencies : in out tasks_dependencies_ptr;
      a_task          : in     generic_task_ptr;
      a_dep           : in     buffer_ptr;
      a_type          : in     orientation_dependency_type);

   procedure add_one_task_dependency_black_board_buffer
     (my_dependencies : in out tasks_dependencies_ptr;
      a_task          : in     generic_task_ptr;
      a_dep           : in     buffer_ptr;
      a_type          : in     orientation_dependency_type);

   procedure add_one_task_dependency_remote_procedure_call
     (my_dependencies : in out tasks_dependencies_ptr;
      client          : in     generic_task_ptr;
      server          : in     generic_task_ptr);

   procedure add_one_task_dependency_precedence
     (my_dependencies : in out tasks_dependencies_ptr;
      source          : in     generic_task_ptr;
      sink            : in     generic_task_ptr);

   procedure add_one_task_dependency_time_triggered
     (my_dependencies : in out tasks_dependencies_ptr;
      from_task       : in     generic_task_ptr;
      to_task         : in     generic_task_ptr;
      timing_type     : in time_triggered_communication_timing_property_type);

end task_dependencies;
