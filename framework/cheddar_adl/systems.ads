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
--    $Rev: 5117 $
--    $Date: 2024-08-21 15:27:57 +0200 (mer., 21 août 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
with Messages;    use Messages;
with message_set; use message_set;
use message_set.generic_message_set;
with Buffers;    use Buffers;
with buffer_set; use buffer_set;
use buffer_set.generic_buffer_set;
with Memories;   use Memories;
with memory_set; use memory_set;
use memory_set.generic_memory_set;
with Tasks;       use Tasks;
with Task_Groups; use Task_Groups;
with task_set;    use task_set;
use task_set.generic_task_set;
with task_group_set; use task_group_set;
use task_group_set.generic_task_group_set;
with task_dependencies; use task_dependencies;
use task_dependencies.half_dep_set;
with Core_Units;    use Core_Units;
with processor_set; use processor_set;
with Processors;    use Processors;
use processor_set.generic_processor_set;
use processor_set.generic_core_unit_set;
with Scheduler_Interface;      use Scheduler_Interface;
with Caches;                   use Caches;
with Batteries;                use Batteries;
with battery_set;              use battery_set;
with cache_set;                use cache_set;
with cache_block_set;          use cache_block_set;
with cache_access_profile_set; use cache_access_profile_set;
with Networks;                 use Networks;
with Address_Spaces;           use Address_Spaces;
with address_space_set;        use address_space_set;
use address_space_set.generic_address_space_set;
with resource_set; use resource_set;
use resource_set.generic_resource_set;
with Resources;   use Resources;
with network_set; use network_set;
use network_set.generic_network_set;
with event_analyzer_set; use event_analyzer_set;
use event_analyzer_set.generic_event_analyzer_set;
with cfg_node_set.basic_block_set; use cfg_node_set.basic_block_set;
with cfg_node_set;                 use cfg_node_set;
with cfg_set;                      use cfg_set;
with cfg_edges;                    use cfg_edges;
with cfg_edge_set;                 use cfg_edge_set;
with Scheduling_Errors;            use Scheduling_Errors;
with scheduling_error_set;         use scheduling_error_set;
with Objects;                      use Objects;
with tdma; use tdma;


package systems is

   -------------------------------------------------------------------
   --   Top level entity of a Cheddar ADL model
   -------------------------------------------------------------------

   type system is tagged record

      -- Hardware parts of the architecture
      --
      core_units            : core_units_set;
      processors            : processors_set;
      caches                : caches_set;
      cache_blocks          : cache_blocks_set;
      networks              : networks_set;
      memories              : memories_set;
      batteries             : batteries_set;

      -- Software parts of the architecture
      --
      tasks                 : tasks_set;
      task_groups           : task_groups_set;
      resources             : resources_set;
      messages              : messages_set;
      buffers               : buffers_set;
      address_spaces        : address_spaces_set;
      scheduling_errors     : scheduling_errors_set;

      -- Relation between entities
      --
      dependencies          : tasks_dependencies_ptr;
      cfgs                  : cfgs_set;
      cfg_nodes             : cfg_nodes_set;
      cfg_edges             : cfg_edges_set;
      event_analyzers       : event_analyzers_set;
      cache_access_profiles : cache_access_profiles_set;
      tdma_frame            : tdma_frame_type;

   end record;

   type system_ptr is access system;

   procedure initialize (a_system : in out system);
   procedure initialize (a_system : in system_ptr);

   procedure duplicate (src : in system; dest : in out system);

   -------------------------------------------------------------------
   -- When a Cheddar ADL entity 'foo' has to be deleted, it may imply to remove
   -- many other entities that make reference to 'foo' before
   --
   -- The subprograms bellow check if some entities that make reference
   -- a entity that user wants to delete.
   -- Those subprograms are calling one or several subprograms from
   -- the sets that actually store referencing entities
   -- If the entiti is referenced, they raise an exception to forbid entity removing
   --
   -- When 'foo' has to be removed, the following entities must be checked :
   --   If 'foo' is a core : check 'foo' in not referenced in processor.
   --   If 'foo' is a processor : check 'foo' in not referenced in task,  buffer, task_group, resource,
   --                    address space, dependencies
   --   If 'foo' is a task : check 'foo' in not referenced in buffer, task_group, resources, dependencies
   --   If 'foo' is a dependency : check 'foo' in not referenced in buffer, resources
   --   If 'foo' is a network : check 'foo' in not referenced in processor
   --   If 'foo' is a cache : check 'foo' in not referenced in processor, core
   --   If 'foo' is a address space : check 'foo' in not referenced in task, buffer, resource, task_group
   --   If 'foo' is a message : check 'foo' in not referenced in dependencies
   --   If 'foo' is a buffer : check 'foo' in not referenced in dependencies
   --   If 'foo' is a task group :  nothing to check
   --
   --
   -------------------------------------------------------------------

   procedure check_entity_referencing_a_core_unit
     (a_sys       : in system;
      a_core_unit :    core_unit_ptr);
   procedure check_entity_referencing_a_processor
     (a_sys       : in system;
      a_processor :    generic_processor_ptr);
   procedure check_entity_referencing_a_buffer
     (a_sys    : in system;
      a_buffer :    buffer_ptr);
   procedure check_entity_referencing_a_resource
     (a_sys      : in system;
      a_resource :    generic_resource_ptr);
   procedure check_entity_referencing_a_message
     (a_sys     : in system;
      a_message :    generic_message_ptr);
   procedure check_entity_referencing_a_task
     (a_sys  : in system;
      a_task :    generic_task_ptr);
   procedure check_entity_referencing_a_task_group
     (a_sys        : in system;
      a_task_group :    generic_task_group_ptr);
   procedure check_entity_referencing_an_address_space
     (a_sys            : in system;
      an_address_space :    address_space_ptr);
   procedure check_entity_referencing_a_cache
     (a_sys   : in system;
      a_cache :    generic_cache_ptr);
   procedure check_entity_referencing_a_network
     (a_sys     : in system;
      a_network :    generic_network_ptr);



   procedure delete_task (a_sys : in out system; a_task : generic_task_ptr);
   procedure delete_task_group
     (a_sys               : in out system;
      a_task_group        :        generic_task_group_ptr;
      delete_all_entities :        Boolean := True);

   -------------------------------------------------------------------
   -- Run Integrity checks between entities of a system
   -- The subprograms bellow implement verification between several
   -- component of several types
   -------------------------------------------------------------------

   invalid_parameter : exception;

   ----------------------------------------------------------
   -- Integrity checks related to location of entities
   -- we check that both processor and address space location
   -- are consistent
   -- This verification must be performed for both task, resource and buffer
   ----------------------------------------------------------

   procedure check_entity_location
     (a_sys            : in system;
      a_entity_name    :    Unbounded_String;
      a_processor_name :    Unbounded_String;
      a_addr_name      :    Unbounded_String);

   ----------------------------------------------------------
   -- Integrety checks related to task affinity
   -- Check that if a core affinity is specified for a given
   -- task, migration is forbiden for the processor
   ----------------------------------------------------------

   procedure check_task_affinity
     (a_sys            : in system;
      a_task_name      :    Unbounded_String;
      a_processor_name :    Unbounded_String;
      a_core_name      :    Unbounded_String);

   -------------------------------------------------------------------
   -- Integrity checks related to hierarchichal scheduling policy
   -- we check that an address space scheduler with a hierarchical scheduling
   -- policy is allowed
   -------------------------------------------------------------------

   procedure check_hierarchical_schedulers
     (a_sys            : in system;
      a_addr_name      :    Unbounded_String;
      a_processor_name :    Unbounded_String;
      a_scheduler_type :    schedulers_type);

   ----------------------------------------------------------
   -- Integrity checks related to resource and tasks
   -- about critical sections
   ----------------------------------------------------------

   -- check critical sections when editing or parsing a resource
   --
   procedure check_task_critical_sections
     (a_sys             : in system;
      a_resource_name    : in Unbounded_String;
      a_resource_cpu_name : in Unbounded_String;
      a_resource_protocol: in Resources_Type;
      critical_sections : in resource_accesses_table);

   procedure check_task_critical_sections
     (a_sys         : in system;
      a_task        : in generic_task_ptr);

   -- check critical sections when editing a existing task
   --
   procedure check_task_critical_sections
     (a_sys         : in system;
      task_name     : in Unbounded_String;
      task_capacity : in Integer;
      task_cpu_name : in Unbounded_String);

   procedure check_task_one_critical_section
      (task_name         : in Unbounded_String;
      task_capacity      : in Integer;
      task_cpu_name      : in Unbounded_String;
      a_resource_name    : in Unbounded_String;
      a_resource_cpuname : in Unbounded_String;
      a_resource_protocol: in Resources_Type;
      a_critical_section : in critical_section);

   --------------------------------------------------------
   -- Functions to check if a task has a critical section
   -- in a given resource
   --------------------------------------------------------

   function has_a_critical_section
     (cs_task     : in generic_task_ptr;
      cs_resource : in generic_resource_ptr) return Boolean;

   ----------------------------------------------------------
   -- Integrity checks related to buffer and tasks
   -- about buffer roles
   ----------------------------------------------------------

   procedure check_task_buffer_roles
     (my_tasks    : in tasks_set;
      buffer_name : in Unbounded_String;
      roles       : in buffer_roles_table);
   procedure check_task_buffer_roles
     (a_sys         : in system;
      task_name     : in Unbounded_String;
      task_capacity : in Integer);

   -------------------------------------------------------------------
   -- Search an object in any of the set of an architecture model
   -------------------------------------------------------------------

   function search_by_name
     (a_system : in system;
      name     : in Unbounded_String) return generic_object_ptr;

   -------------------------------------------------------------------
   -- Sub program to sort any kind of data managed by schedulers
   -------------------------------------------------------------------

   current_processor_name : Unbounded_String;
   current_core_name      : Unbounded_String;

   function select_core (op1 : in generic_task_ptr) return Boolean;
   function select_cpu (op1 : in generic_task_ptr) return Boolean;
   function select_cpu (op1 : in generic_resource_ptr) return Boolean;
   function select_cpu (op1 : in buffer_ptr) return Boolean;

   -------------------------------------------------------------------
   -- Export to XML a system
   -------------------------------------------------------------------

   function xml_string
     (obj   : in system;
      level : in Natural := 0) return Unbounded_String;
   function xml_string
     (obj   : in system_ptr;
      level : in Natural := 0) return Unbounded_String;

   -------------------------------------------------------------------
   -- Display a system to the screen in different languages
   -------------------------------------------------------------------

   procedure put_xml (a_system : in system);
   procedure put_aadl (a_system : in system);
   procedure put (a_system : in system_ptr);

   -------------------------------------------------------------------
   -- I/O sub-programs : read/write a system in different languages
   -------------------------------------------------------------------

   procedure read_from_aadl_file
     (a_system          : in out system;
      dir_list          : in     unbounded_string_list;
      project_file_list : in     unbounded_string_list);
   procedure read_from_xml_file
     (a_system   : in out system;
      dir_list   : in     unbounded_string_list;
      file_name  : in     Unbounded_String;
      validation : in     boolean := true);
   procedure read_from_xml_file
     (a_system   : in out system;
      dir_list   : in     unbounded_string_list;
      file_name  : in     String;
      validation : in     boolean := true);
   procedure read_from_xml_file
     (a_system   : in out system;
      file_name  : in     String;
      validation : in     boolean := true);
   procedure read_from_v2_xml_file
     (a_system   : in out system;
      dir_list   : in     unbounded_string_list;
      file_name  : in     Unbounded_String;
      validation : in     boolean := true);
   procedure read_from_v2_xml_file
     (a_system   : in out system;
      dir_list   : in     unbounded_string_list;
      file_name  : in     String;
      validation : in     boolean := true);

   procedure write_to_xml_file
     (a_system  : in system;
      file_name : in Unbounded_String);
   procedure write_to_xml_file (a_system : in system; file_name : in String);

   procedure write_to_aadl_file
     (a_system  : in system;
      file_name : in Unbounded_String);
   procedure write_aadl_standard_properties_set_to_file (a_system : in system);
   procedure write_cheddar_property_sets_to_file (a_system : in system);

   function export_aadl_project_properties
     (a_system : in system) return Unbounded_String;
   function export_aadl_cheddar_properties
     (a_system : in system) return Unbounded_String;
   function export_aadl_user_defined_cheddar_properties
     (a_system : in system) return Unbounded_String;
   function export_aadl_standard_properties
     (a_system : in system) return Unbounded_String;
   function export_aadl_implementations
     (a_system : in system) return Unbounded_String;
   function export_aadl_declarations
     (a_system     : in system;
      number_of_ht : in Natural) return Unbounded_String;

end systems;
