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
--    $Rev: 5119 $
--    $Date: 2024-08-22 00:24:50 +0200 (jeu., 22 août 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with initialize_framework; use initialize_framework;
with Scheduler_Interface;  use Scheduler_Interface;
with aadl_parsers;         use aadl_parsers;
with v2_xml_parsers;
with xml_generic_parsers;
with xml_generic_parsers.architecture;
with Offsets;              use Offsets;
with integer_util;         use integer_util;
with Tasks;                use Tasks;
use Tasks.Generic_Task_List_Package;
with Buffers; use Buffers;
use Buffers.Buffer_Roles_Package;
with Resources; use Resources;
use Resources.Resource_Accesses;
with Processor_Interface;      use Processor_Interface;
with translate;                use translate;
with Framework_Config;         use Framework_Config;
with GNAT.Current_Exception;   use GNAT.Current_Exception;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with unbounded_strings;        use unbounded_strings;
with Unicode.CES;              use Unicode.CES;
with Unicode.Encodings;        use Unicode.Encodings;
with Ada.Direct_IO;
with Ada.Exceptions;           use Ada.Exceptions;
with Ada.IO_Exceptions;        use Ada.IO_Exceptions;
with Ada.Text_IO;              use Ada.Text_IO;
with Ada.Text_IO.Text_Streams; use Ada.Text_IO.Text_Streams;
with Ada.Unchecked_Deallocation;
with DOM.Core.Documents;
use DOM.Core, DOM.Core.Documents;
with DOM.Core;           use DOM.Core;
with DOM.Core.Nodes;     use DOM.Core.Nodes;
with DOM.Readers;        use DOM.Readers;
with GNAT.Command_Line;  use GNAT.Command_Line;
with GNAT.Expect;        use GNAT.Expect;
with GNAT.OS_Lib;        use GNAT.OS_Lib;
with Input_Sources.File; use Input_Sources.File;
with Input_Sources.Http; use Input_Sources.Http;
with Input_Sources;      use Input_Sources;
with Sax.Encodings;      use Sax.Encodings;
with Sax.Readers;        use Sax.Readers;
with Sax.Utils;          use Sax.Utils;
with Sax.Symbols;

package body systems is

   procedure check_hierarchical_schedulers
     (a_sys            : in system;
      a_addr_name      :    Unbounded_String;
      a_processor_name :    Unbounded_String;
      a_scheduler_type :    schedulers_type)
   is

      a_processor : generic_processor_ptr;
      a_core_unit : core_unit_ptr;

   begin

      if (a_scheduler_type /= no_scheduling_protocol) then

         -- Address spaces cannot have scheduler if processors has no
         -- hierchical scheduling policy
         --
         a_processor := search_processor (a_sys.processors, a_processor_name);
         if (a_processor.processor_type = monocore_type) then
            a_core_unit := mono_core_processor_ptr (a_processor).core;
         else
            a_core_unit :=
              multi_cores_processor_ptr (a_processor).cores.entries (0);
         end if;

         if
           (a_core_unit.scheduling.scheduler_type /=
            hierarchical_cyclic_protocol) and
           (a_core_unit.scheduling.scheduler_type /=
            hierarchical_round_robin_protocol) and
           (a_core_unit.scheduling.scheduler_type /=
            hierarchical_fixed_priority_protocol) and
           (a_core_unit.scheduling.scheduler_type /=
            hierarchical_offline_protocol)
         then
            Raise_Exception
              (invalid_parameter'identity,
               To_String
                 (a_addr_name &
                  "/" &
                  a_processor.name &
                  " : " &
                  lb_hierarchical_not_allowed (Current_Language)));
         end if;
      end if;

   end check_hierarchical_schedulers;

   procedure check_entity_location
     (a_sys            : in system;
      a_entity_name    :    Unbounded_String;
      a_processor_name :    Unbounded_String;
      a_addr_name      :    Unbounded_String)
   is

      a_processor     : generic_processor_ptr;
      a_address_space : address_space_ptr;

   begin

      -- Check that entities exist
      --
      a_processor     := search_processor (a_sys.processors, a_processor_name);
      a_address_space :=
        search_address_space (a_sys.address_spaces, a_addr_name);

      -- Check that both address space and task are located on the same cpu
      --
      if a_address_space.cpu_name /= a_processor_name then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (a_entity_name &
               " : " &
               a_addr_name &
               "/" &
               a_processor_name &
               lb_are_unconsistent (Current_Language)));
      end if;

   end check_entity_location;

-- For a task who has an affinity on a core, verify that migration
-- are forbidden on the associated processor
--
   procedure check_task_affinity
     (a_sys            : in system;
      a_task_name      :    Unbounded_String;
      a_processor_name :    Unbounded_String;
      a_core_name      :    Unbounded_String)
   is

      a_processor : generic_processor_ptr;

   begin
      a_processor := search_processor (a_sys.processors, a_processor_name);

      if (a_core_name /= empty_string) and
        (a_processor.processor_type = monocore_type)
      then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (a_task_name &
               "/" &
               a_processor_name &
               " : Task/core affinity cannot be used with monoprocessor"));
      end if;

      if (a_core_name /= empty_string) and
        (a_processor.migration_type /= no_migration_type)
      then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (a_task_name &
               "/" &
               a_processor_name &
               " : Task/core affinity cannot be used when processor can do migration"));
      end if;

      if (a_core_name = empty_string) and
        (a_processor.migration_type = no_migration_type) and
        (a_processor.processor_type /= monocore_type)
      then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (a_task_name &
               "/" &
               a_processor_name &
               " : Task/core affinity mandatory with this processor (multiprocessor without migration)"));
      end if;

   end check_task_affinity;

   procedure check_entity_referencing_a_task
     (a_sys  : in system;
      a_task :    generic_task_ptr)
   is
   begin
      check_entity_referencing_task (a_sys.resources, a_task.name);
      check_entity_referencing_task (a_sys.buffers, a_task.name);
      check_entity_referencing_task (a_sys.task_groups, a_task.name);
      check_entity_referencing_task (a_sys.dependencies, a_task.name);
   end check_entity_referencing_a_task;

   procedure check_entity_referencing_a_buffer
     (a_sys    : in system;
      a_buffer :    buffer_ptr)
   is
   begin
      check_entity_referencing_buffer (a_sys.dependencies, a_buffer.name);
   end check_entity_referencing_a_buffer;

   procedure check_entity_referencing_a_resource
     (a_sys      : in system;
      a_resource :    generic_resource_ptr)
   is
   begin
      check_entity_referencing_resource (a_sys.dependencies, a_resource.name);
   end check_entity_referencing_a_resource;

   procedure check_entity_referencing_a_message
     (a_sys     : in system;
      a_message :    generic_message_ptr)
   is
   begin
      check_entity_referencing_message (a_sys.dependencies, a_message.name);
   end check_entity_referencing_a_message;

   procedure check_entity_referencing_a_processor
     (a_sys       : in system;
      a_processor :    generic_processor_ptr)
   is
   begin
      check_entity_referencing_processor
        (a_sys.dependencies,
         a_processor.name);
      check_entity_referencing_processor (a_sys.resources, a_processor.name);
      check_entity_referencing_processor (a_sys.buffers, a_processor.name);
      check_entity_referencing_processor (a_sys.tasks, a_processor.name);
      check_entity_referencing_processor
        (a_sys.address_spaces,
         a_processor.name);
   end check_entity_referencing_a_processor;

   procedure check_entity_referencing_a_core_unit
     (a_sys       : in system;
      a_core_unit :    core_unit_ptr)
   is
   begin
      check_entity_referencing_core_unit (a_sys.processors, a_core_unit);
   end check_entity_referencing_a_core_unit;

   procedure check_entity_referencing_a_network
     (a_sys     : in system;
      a_network :    generic_network_ptr)
   is
   begin
      null;
   end check_entity_referencing_a_network;

   procedure check_entity_referencing_an_address_space
     (a_sys            : in system;
      an_address_space :    address_space_ptr)
   is
   begin
      check_entity_referencing_address_space
        (a_sys.resources,
         an_address_space.name);
      check_entity_referencing_address_space
        (a_sys.buffers,
         an_address_space.name);
      check_entity_referencing_address_space
        (a_sys.tasks,
         an_address_space.name);
   end check_entity_referencing_an_address_space;

   procedure check_entity_referencing_a_cache
     (a_sys   : in system;
      a_cache :    generic_cache_ptr)
   is
   begin
      check_entity_referencing_cache (a_sys.processors, a_cache);
   end check_entity_referencing_a_cache;

   procedure check_entity_referencing_a_task_group
     (a_sys        : in system;
      a_task_group :    generic_task_group_ptr)
   is
   begin
      null;
   end check_entity_referencing_a_task_group;

   procedure delete_task (a_sys : in out system; a_task : generic_task_ptr) is
   begin
      delete_task (a_sys.resources, a_task.name);
      delete_task (a_sys.buffers, a_task.name);
      delete_all_task_dependencies (a_sys.dependencies, a_task);
      delete (a_sys.tasks, a_task);
   end delete_task;

   procedure delete_task_group
     (a_sys               : in out system;
      a_task_group        :        generic_task_group_ptr;
      delete_all_entities :        Boolean := True)
   is
      a_task             : generic_task_ptr;
      searched_task      : generic_task_ptr;
      task_list_iterator : generic_task_iterator;
   begin
      if (not is_empty (a_task_group.task_list)) then
         reset_head_iterator (a_task_group.task_list, task_list_iterator);
         loop
            current_element
              (a_task_group.task_list,
               a_task,
               task_list_iterator);

            -- Remove this and replace below parameters with A_Task, when deep_copy is implemented
            searched_task := search_task (a_sys.tasks, a_task.name);

            if (delete_all_entities) then
               delete_task (a_sys, searched_task);
            else
               delete (a_sys.tasks, searched_task);
            end if;

            if is_tail_element
                (a_task_group.task_list,
                 task_list_iterator)
            then
               exit;
            end if;

            next_element (a_task_group.task_list, task_list_iterator);
         end loop;
      end if;

      delete (a_sys.task_groups, a_task_group);
   end delete_task_group;

   procedure duplicate (src : in system; dest : in out system) is
   begin

      duplicate (src.tasks, dest.tasks);
      duplicate (src.task_groups, dest.task_groups);
      duplicate (src.resources, dest.resources);
      duplicate (src.messages, dest.messages);
      duplicate (src.dependencies, dest.dependencies);
      duplicate (src.core_units, dest.core_units);
      duplicate (src.processors, dest.processors);
      duplicate (src.buffers, dest.buffers);
      duplicate (src.networks, dest.networks);
      duplicate (src.event_analyzers, dest.event_analyzers);
      duplicate (src.address_spaces, dest.address_spaces);
      duplicate (src.cache_blocks, dest.cache_blocks);
      duplicate (src.caches, dest.caches);
      duplicate (src.cfgs, dest.cfgs);
      duplicate (src.cfg_nodes, dest.cfg_nodes);
      duplicate (src.cfg_edges, dest.cfg_edges);
      duplicate (src.cache_access_profiles, dest.cache_access_profiles);
      duplicate (src.memories, dest.memories);
   end duplicate;

   function xml_string
     (obj   : in system;
      level : in Natural := 0) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
   begin
      result := result & "<cheddar>";

      if not is_empty (obj.cache_blocks) then
         result := result & "<cache_blocks>";
         result := result & xml_root_string (obj.cache_blocks);
         result := result & "</cache_blocks>";
      end if;

      if not is_empty (obj.caches) then
         result := result & "<caches>";
         result := result & xml_root_string (obj.caches);
         result := result & "</caches>";
      end if;

      if not is_empty (obj.cfg_nodes) then
         result := result & "<cfg_nodes>";
         result := result & xml_root_string (obj.cfg_nodes);
         result := result & "</cfg_nodes>";
      end if;

      if not is_empty (obj.cfg_edges) then
         result := result & "<cfg_edges>";
         result := result & xml_root_string (obj.cfg_edges);
         result := result & "</cfg_edges>";
      end if;

      if not is_empty (obj.cfgs) then
         result := result & "<cfgs>";
         result := result & xml_root_string (obj.cfgs);
         result := result & "</cfgs>";
      end if;

      if not is_empty (obj.cache_access_profiles) then
         result := result & "<cache_access_profiles>";
         result := result & xml_root_string (obj.cache_access_profiles);
         result := result & "</cache_access_profiles>";
      end if;

      if not is_empty (obj.memories) then
         result := result & "<memories>";
         result := result & xml_root_string (obj.memories);
         result := result & "</memories>";
      end if;

      if not is_empty (obj.core_units) then
         result := result & "<core_units>";
         result := result & xml_root_string (obj.core_units);
         result := result & "</core_units>";
      end if;

      if not is_empty (obj.processors) then
         result := result & "<processors>";
         result := result & xml_root_string (obj.processors);
         result := result & "</processors>";
      end if;

      if not is_empty (obj.networks) then
         result := result & "<networks>";
         result := result & xml_root_string (obj.networks);
         result := result & "</networks>";
      end if;

      if not is_empty (obj.address_spaces) then
         result := result & "<address_spaces>";
         result := result & xml_root_string (obj.address_spaces);
         result := result & "</address_spaces>";
      end if;

      if not is_empty (obj.tasks) then
         result := result & "<tasks>";
         result := result & xml_root_string (obj.tasks);
         result := result & "</tasks>";
      end if;

      if not is_empty (obj.task_groups) then
         result := result & "<task_groups>";
         result := result & xml_root_string (obj.task_groups);
         result := result & "</task_groups>";
      end if;

      if not is_empty (obj.resources) then
         result := result & "<resources>";
         result := result & xml_root_string (obj.resources);
         result := result & "</resources>";
      end if;

      if not is_empty (obj.messages) then
         result := result & "<messages>";
         result := result & xml_root_string (obj.messages);
         result := result & "</messages>";
      end if;

      if not is_empty (obj.buffers) then
         result := result & "<buffers>";
         result := result & xml_root_string (obj.buffers);
         result := result & "</buffers>";
      end if;

      if not is_empty (obj.event_analyzers) then
         result := result & "<event_analyzers>";
         result := result & xml_root_string (obj.event_analyzers);
         result := result & "</event_analyzers>";
      end if;

      if not is_empty (obj.batteries) then
         result := result & "<batteries>";
         result := result & xml_root_string (obj.batteries);
         result := result & "</batteries>";
      end if;

      if obj.dependencies /= null then
         if not is_empty (obj.dependencies.depends) then
            result := result & "<dependencies>";
            result := result & xml_root_string (obj.dependencies);
            result := result & "</dependencies>";
         end if;
      end if;


      if not is_empty (obj.scheduling_errors) then
         result := result & "<scheduling_errors>";
         result := result & xml_root_string (obj.scheduling_errors);
         result := result & "</scheduling_errors>";
      end if;

      result := result & "</cheddar>";

      return result;

   end xml_string;

   function xml_string
     (obj   : in system_ptr;
      level : in Natural := 0) return Unbounded_String
   is
   begin
      return xml_string (obj.all, level);
   end xml_string;

   procedure put_xml (a_system : in system) is
   begin
      Put (To_String (xml_string (a_system)));
   end put_xml;

   procedure put_aadl (a_system : in system) is
   begin
      New_Line;

      -- Export AADL standard properties and Cheddar's properties
      --
      --   Put_Line(To_String(Export_Aadl_Standard_Properties(A_System)));
      --   Put_Line(To_String(Export_Aadl_Project_Properties(A_System)));
      --   Put_Line(To_String(Export_Aadl_Cheddar_Properties(A_System)));

      -- Export the system itself
      --
      Put_Line (To_String (export_aadl_implementations (a_system)));

      New_Line;

   end put_aadl;

   procedure put (a_system : in system) is
   begin

      Put_Line ("***** LIST OF PROCESSORS *****");
      put (a_system.processors);
      New_Line;
      New_Line;
      New_Line;
      Put_Line ("***** LIST OF TASKS *****");
      put (a_system.tasks);
      New_Line;
      New_Line;
      New_Line;
      Put_Line ("***** LIST OF TASK GROUPS *****");
      put (a_system.task_groups);
      New_Line;
      New_Line;
      New_Line;
      Put_Line ("***** LIST OF RESSOURCES *****");
      put (a_system.resources);
      New_Line;
      New_Line;
      New_Line;
      Put_Line ("***** LIST OF BUFFERS *****");
      put (a_system.buffers);
      New_Line;
      New_Line;
      New_Line;
      Put_Line ("***** LIST OF MESSAGES *****");
      put (a_system.messages);
      New_Line;
      New_Line;
      New_Line;
      Put_Line ("***** LIST OF DEPENCENCIES *****");
      put (a_system.dependencies);
      New_Line;
      New_Line;
      New_Line;
      Put_Line ("***** LIST OF NETWORKS *****");
      put (a_system.networks);
      New_Line;
      New_Line;
      New_Line;
      Put_Line ("***** LIST OF EVENTS ANALYZERS *****");
      put (a_system.event_analyzers);
      New_Line;
      New_Line;
      New_Line;
      Put_Line ("***** LIST OF ADDRESS SPACES *****");
      put (a_system.address_spaces);
      New_Line;
      New_Line;
      New_Line;
      Put_Line ("***** LIST OF CACHE BLOCKS *****");
      put (a_system.cache_blocks);
      New_Line;
      New_Line;
      New_Line;
      Put_Line ("***** LIST OF CACHES *****");
      put (a_system.caches);
      New_Line;
      New_Line;
      New_Line;
      Put_Line ("***** LIST OF CFGs *****");
      put (a_system.cfgs);
      New_Line;
      New_Line;
      New_Line;
      Put_Line ("***** LIST OF CFG_Nodes *****");
      put (a_system.cfg_nodes);
      New_Line;
      New_Line;
      New_Line;
      Put_Line ("***** LIST OF CFG_Edges *****");
      put (a_system.cfg_edges);
      New_Line;
      New_Line;
      New_Line;
      Put_Line ("***** LIST OF Cache_Access_Profiles *****");
      put (a_system.cache_access_profiles);
      New_Line;
      New_Line;
      New_Line;
      Put_Line ("***** LIST OF Memories *****");
      put (a_system.memories);
      New_Line;
      New_Line;
      New_Line;
   end put;

   procedure put (a_system : in system_ptr) is
   begin
      put (a_system.all);
   end put;

   ------------------------------------------------

   procedure initialize (a_system : in out system) is
   begin

      check_initialize;

      reset (a_system.networks);
      reset (a_system.tasks);
      reset (a_system.task_groups);
      reset (a_system.messages);
      reset (a_system.resources);
      if a_system.dependencies /= null then
         free (a_system.dependencies);
      end if;
      a_system.dependencies := new tasks_dependencies;
      reset (a_system.dependencies);
      reset (a_system.buffers);
      reset (a_system.processors);
      reset (a_system.memories);
      reset (a_system.core_units);
      reset (a_system.event_analyzers);
      reset (a_system.address_spaces);
      reset (a_system.caches); -- TODO JLE : necessary?
      reset (a_system.cache_blocks);
      reset (a_system.caches);
      reset (a_system.cfgs);
      reset (a_system.cfg_nodes);
      reset (a_system.cfg_edges);

      initialize(a_system.tdma_frame);
   end initialize;

   procedure initialize (a_system : in system_ptr) is
   begin
      initialize (a_system.all);
   end initialize;

   procedure read_from_xml_file
     (a_system   : in out system;
      file_name  : in     String;
      validation : in     boolean := True)
   is
      dir_list : unbounded_string_list;
   begin
      initialize (dir_list);
      read_from_xml_file (a_system, dir_list, To_Unbounded_String (file_name), validation);
   end read_from_xml_file;

   procedure read_from_xml_file
     (a_system   : in out system;
      dir_list   : in     unbounded_string_list;
      file_name  : in     String;
      validation : in     boolean := True)
   is
   begin
      read_from_xml_file (a_system, dir_list, To_Unbounded_String (file_name), validation);
   end read_from_xml_file;

   procedure read_from_v2_xml_file
     (a_system   : in out system;
      dir_list   : in     unbounded_string_list;
      file_name  : in     String;
      validation : in     boolean := True)
   is
   begin
      read_from_v2_xml_file
        (a_system,
         dir_list,
         To_Unbounded_String (file_name),
         validation);
   end read_from_v2_xml_file;

   procedure read_from_v2_xml_file
     (a_system   : in out system;
      dir_list   : in     unbounded_string_list;
      file_name  : in     Unbounded_String;
      validation : in     boolean := True)
   is

      use v2_xml_parsers;
      read       : file_input;
      my_reader  : v2_xml_parsers.xml_project_parser;
      name_start : Natural;
      s          : constant String := To_String (file_name);

   begin

      --  Base file name should be used as the public Id
      --
      name_start := s'last;
      while name_start >= s'first and then s (name_start) /= '/' loop
         name_start := name_start - 1;
      end loop;
      Set_Public_Id (read, s (name_start + 1 .. s'last));
      Set_System_Id (read, s);
      Open (s, read);

      --  xmlns:* attributes will be reported in Start_Element
      --
      Set_Feature (my_reader, Namespace_Prefixes_Feature, False);
      Set_Feature (my_reader, Validation_Feature, validation);

      Parse (my_reader, read);
      a_system := get_parsed_system (my_reader);
      Close (read);

   exception
      when XML_Fatal_Error =>
         Close (read);
         raise xml_read_error;

   end read_from_v2_xml_file;

   procedure read_from_xml_file
     (a_system   : in out system;
      dir_list   : in     unbounded_string_list;
      file_name  : in     Unbounded_String;
      validation : in     boolean := True)
   is

      use xml_generic_parsers;
      use xml_generic_parsers.architecture;
      read       : file_input;
      my_reader  : xml_architecture_parser;
      name_start : Natural;
      s          : constant String := To_String (file_name);

   begin

      --  Base file name should be used as the public Id
      --
      name_start := s'last;
      while name_start >= s'first and then s (name_start) /= '/' loop
         name_start := name_start - 1;
      end loop;
      Set_Public_Id (read, s (name_start + 1 .. s'last));
      Set_System_Id (read, s);
      Open (s, read);

      --  xmlns:* attributes will be reported in Start_Element
      --
      Set_Feature (my_reader, Namespace_Prefixes_Feature, False);
      Set_Feature (my_reader, Validation_Feature, validation);

      Parse (my_reader, read);
      a_system := get_parsed_system (my_reader);
      Close (read);

   exception
      when XML_Fatal_Error =>
         Close (read);
         raise xml_read_error;

   end read_from_xml_file;

   procedure write_to_xml_file (a_system : in system; file_name : in String) is
   begin
      write_to_xml_file (a_system, To_Unbounded_String (file_name));
   end write_to_xml_file;

   procedure write_to_xml_file
     (a_system  : in system;
      file_name : in Unbounded_String)
   is

      input  : file_input;
      reader : tree_reader;
      d      : document;
      into   : File_Type;

   begin

      -- Open file and Write XML Header
      --
      Create (into, Mode => Out_File, Name => To_String (file_name));

      Put_Line (into, "<?xml version=""1.0"" standalone=""no""?>  ");
--      Put_Line (Into, "<!DOCTYPE Cheddar_ADL SYSTEM ""cheddar_adl.dtd"">");
      --      Put_Line (Into, "<?xml-stylesheet type=""text/xsl"" href=""cheddar_adl.xsl""?>");
      New_Line (into, 2);

      Put (into, To_String (xml_string (a_system)));

      Close (into);

      Open (To_String (file_name), input);
      Parse (reader, input);
      d := Get_Tree (reader);
      Close (input);

      Create (into, Mode => Out_File, Name => To_String (file_name));
      Write
        (Stream                => Stream (into),
         N                     => d,
         Print_Comments        => False,
         Print_XML_Declaration => True,
         With_URI              => False,
         EOL_Sequence          => "" & ASCII.LF,
         Pretty_Print          => True,
         Encoding              => Unicode.Encodings.Get_By_Name ("utf-8"),
         Collapse_Empty_Nodes  => False);

      Free (reader);
      Close (into);

   end write_to_xml_file;

   procedure read_from_aadl_file
     (a_system          : in out system;
      dir_list          : in     unbounded_string_list;
      project_file_list : in     unbounded_string_list)
   is

      my_reader : aadl_project_parser;

   begin

      parse (my_reader, dir_list, project_file_list);
      a_system := get_parsed_system (my_reader);

   end read_from_aadl_file;

   procedure write_to_aadl_file
     (a_system  : in system;
      file_name : in Unbounded_String)
   is

      into : File_Type;

   begin

      -- Open file and Write aadl specification
      --
      Create (into, Mode => Out_File, Name => To_String (file_name));

      New_Line (into);

      -- Export AADL standard customized properties
      --
      -- Put_Line(Into, To_String(Export_Aadl_Standard_Properties(A_System)));
      -- Put_Line(Into, To_String(Export_Aadl_Project_Properties(A_System)));
      -- Put_Line(Into, To_String(Export_Aadl_Cheddar_Properties(A_System)));

      -- Export the system itself
      --
      Put_Line (into, To_String (export_aadl_implementations (a_system)));

      New_Line (into);

      Close (into);

   end write_to_aadl_file;

   procedure write_aadl_standard_properties_set_to_file
     (a_system : in system)
   is

      into : File_Type;

   begin

      -- Open file and Write aadl specification
      --
      Create (into, Mode => Out_File, Name => "AADL_Properties.aadl");

      New_Line (into);
      Put_Line (into, To_String (export_aadl_standard_properties (a_system)));
      New_Line (into);

      Close (into);
   end write_aadl_standard_properties_set_to_file;

   procedure write_cheddar_property_sets_to_file (a_system : in system) is

      into : File_Type;

   begin

      -- Open file and Write aadl specification
      --
      Create (into, Mode => Out_File, Name => "AADL_Project.aadl");
      New_Line (into);
      Put_Line (into, To_String (export_aadl_project_properties (a_system)));
      New_Line (into);
      Close (into);

      Create (into, Mode => Out_File, Name => "Cheddar_Properties.aadl");
      New_Line (into);
      Put_Line (into, To_String (export_aadl_cheddar_properties (a_system)));
      New_Line (into);
      Close (into);

      Create
        (into,
         Mode => Out_File,
         Name => "User_Defined_Cheddar_Properties.aadl");
      New_Line (into);
      Put_Line
        (into,
         To_String (export_aadl_user_defined_cheddar_properties (a_system)));
      New_Line (into);
      Close (into);

   end write_cheddar_property_sets_to_file;

   ------------------------------------------------

   function export_aadl_user_defined_cheddar_properties
     (a_system : in system) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
      tmp    : Unbounded_String := empty_string;

   begin

      -- Export user's defined properties
      --
      tmp := export_aadl_user_defined_properties (a_system.tasks);
      tmp := tmp & export_aadl_user_defined_properties (a_system.messages);

      result :=
        result &
        To_Unbounded_String
          ("property set User_Defined_Cheddar_Properties is") &
        unbounded_lf &
        unbounded_lf;

      if tmp = empty_string then
         result :=
           result &
           "Dummy_User_Defined_Cheddar_Properties : aadlboolean" &
           unbounded_lf &
           "applies to (thread, thread group);";
      else
         result := result & tmp;
      end if;

      result :=
        result &
        unbounded_lf &
        To_Unbounded_String ("end User_Defined_Cheddar_Properties;") &
        unbounded_lf &
        unbounded_lf;

      return result;

   end export_aadl_user_defined_cheddar_properties;

   function export_aadl_standard_properties
     (a_system : in system) return Unbounded_String
   is
      result : Unbounded_String := empty_string;

   begin

      result :=
        result &
        ASCII.LF &
        To_Unbounded_String
          (" --****************************************************** ");

      result :=
        result &
        ASCII.LF &
        To_Unbounded_String (" --  AADL Standard AADL_V1.0 ");

      result :=
        result &
        ASCII.LF &
        To_Unbounded_String (" --  Appendix A (normative) ");

      result :=
        result &
        ASCII.LF &
        To_Unbounded_String (" --  Predeclared Property Sets ");

      result := result & ASCII.LF & To_Unbounded_String (" --  03Nov04 ");

      result :=
        result &
        ASCII.LF &
        To_Unbounded_String
          (" --  Update to reflect current standard on 28Mar06 ");

      result :=
        result &
        ASCII.LF &
        To_Unbounded_String
          (" --****************************************************** ");

      result :=
        result &
        ASCII.LF &
        To_Unbounded_String (" property set AADL_Properties is ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String (" Activate_Deadline: Time applies to (thread); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Activate_Execution_Time: Time_Range applies to (thread); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Activate_Entrypoint: aadlstring applies to (thread); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Active_Thread_Handling_Protocol: inherit Supported_Active_Thread_Handling_Protocols => value(Default_Active_Thread_Handling_Protocol) applies to (thread, thread group, process, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Active_Thread_Queue_Handling_Protocol: inherit enumeration (flush, hold) => flush applies to (thread, thread group, process, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Actual_Connection_binding: inherit list of reference (bus, processor, device) applies to (port connections, thread, thread group, process, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String (" Actual_Latency: Time applies to (flow); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Actual_Memory_binding: inherit reference (memory) applies to (thread, thread group, process, system, processor, data port, event data port, subprogram); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Actual_Processor_binding: inherit reference (processor) applies to (thread, thread group, process, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Actual_Subprogram_Call: reference (server subprogram) applies to (subprogram); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Actual_Subprogram_Call_binding: inherit list of reference (bus, processor, memory, device) applies to (subprogram); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Actual_Throughput: Data_Volume applies to (flow); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Aggregate_Data_Port: aadlboolean => false applies to (port group); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Allowed_Access_Protocol: list of enumeration (Memory_Access, Device_Access) applies to (bus); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Allowed_Connection_binding: inherit list of reference (bus, processor, device) applies to (port connections, thread group, process, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Allowed_Connection_binding_Class: inherit list of classifier (processor, bus, device) applies to (port connections, thread, thread group, process, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Allowed_Connection_Protocol: list of enumeration (Data_Connection, Event_Connection, Event_Data_Connection, Data_Access_Connection, Server_Subprogram_Call) applies to (bus, device); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Allowed_Dispatch_Protocol: list of Supported_Dispatch_Protocols applies to (processor); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Allowed_Memory_binding: inherit list of reference (memory, system, processor) applies to (thread, thread group, process, system, device, data port, event data port, subprogram, processor); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Allowed_Memory_binding_Class: inherit list of classifier (memory, system, processor) applies to (thread, thread group, process, system, device, data port, event data port, subprogram, processor); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Allowed_Message_Size: Size_Range applies to (bus); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Allowed_Period: list of Time_Range applies to (processor, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Allowed_Processor_binding: inherit list of reference (processor, system) applies to (thread, thread group, process, system, device); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Allowed_Processor_binding_Class: inherit list of classifier (processor, system) applies to (thread, thread group, process, system, device); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Allowed_Subprogram_Call: list of reference (server subprogram) applies to (subprogram); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Allowed_Subprogram_Call_binding: inherit list of reference (bus, processor, device) applies to (subprogram, thread, thread group, process, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Assign_Time: Time applies to (processor, bus); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Assign_Byte_Time: Time applies to (processor, bus); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Assign_Fixed_Time: Time applies to (processor, bus); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Available_Memory_binding: inherit list of reference (memory, system) applies to (system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Available_Processor_binding: inherit list of reference (processor, system) applies to (system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Base_Address: access aadlinteger 0 .. value(Max_Base_Address) applies to (memory); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Client_Subprogram_Execution_Time: Time applies to (subprogram); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Clock_Jitter: Time applies to (processor, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Clock_Period: Time applies to (processor, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Clock_Period_Range: Time_Range applies to (processor, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Compute_Deadline: Time applies to (thread, device, subprogram, event port, event data port); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Compute_Entrypoint: aadlstring applies to (thread, subprogram, event port, event data port); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Compute_Execution_Time: Time_Range applies to (thread, device, subprogram, event port, event data port); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Concurrency_Control_Protocol: Supported_Concurrency_Control_Protocols => NoneSpecified applies to (data); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Connection_Protocol: Supported_Connection_Protocols applies to (connections); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Data_Volume: type aadlinteger 0 bitsps .. value(Max_Aadlinteger) units (bitsps, Bps    => bitsps * 8, Kbps   => Bps    * 1000, Mbps   => Kbps   * 1000, Gbps   => Mbps   * 1000 ); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Deactivate_Deadline: Time applies to (thread); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Deactivate_Execution_Time: Time_Range applies to (thread); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Deactivate_Entrypoint: aadlstring applies to (thread); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Deadline: inherit Time => value(Period) applies to (thread, thread group, process, system, device); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Dequeue_Protocol: enumeration (OneItem, AllItems) => OneItem applies to (event port, event data port); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Device_Dispatch_Protocol: Supported_Dispatch_Protocols => Aperiodic applies to (device); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Device_Register_Address: aadlinteger applies to (port, port group); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Dispatch_Protocol: Supported_Dispatch_Protocols applies to (thread); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String (" Expected_Latency: Time applies to (flow); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Expected_Throughput: Data_Volume applies to (flow); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String (" Finalize_Deadline: Time applies to (thread); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Finalize_Execution_Time: Time_Range applies to (thread); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Finalize_Entrypoint: aadlstring applies to (thread); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Hardware_Description_Source_Text: inherit list of aadlstring applies to (memory, bus, device, processor, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Hardware_Source_Language: Supported_Hardware_Source_Languages applies to (memory, bus, device, processor, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Initialize_Deadline: Time applies to (thread); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Initialize_Execution_Time: Time_Range applies to (thread); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Initialize_Entrypoint: aadlstring applies to (thread); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Latency: Time applies to (flow, connections); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Load_Deadline: Time applies to (process, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Load_Time: Time_Range applies to (process, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Memory_Protocol: enumeration (read_only, write_only, read_write) => read_write applies to (memory); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Not_Collocated: list of reference (data, thread, process, system, connections) applies to (data, thread, process, system, connections); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Overflow_Handling_Protocol: enumeration (DropOldest, DropNewest, Error) => DropOldest applies to (event port, event data port, subprogram); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Period: inherit Time applies to (thread, thread group, process, system, device); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Process_Swap_Execution_Time: Time_Range applies to (processor); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Propagation_Delay: Time_Range applies to (bus); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Provided_Access : access enumeration (read_only, write_only, read_write, by_method) => read_write applies to (data, bus); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Queue_Processing_Protocol: Supported_Queue_Processing_Protocols => FIFO applies to (event port, event data port, subprogram); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Queue_Size: aadlinteger 0 .. value(Max_Queue_Size) => 0 applies to (event port, event data port, subprogram); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Read_Time: list of Time_Range applies to (memory); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Recover_Deadline: Time applies to (thread, server subprogram); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Recover_Execution_Time: Time_Range applies to (thread, server subprogram); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Recover_Entrypoint: aadlstring applies to (thread); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Required_Access : access enumeration (read_only, write_only, read_write, by_method) => read_write applies to (data, bus); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Required_Connection : aadlboolean => true applies to (port); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Runtime_Protection : inherit aadlboolean => true applies to (process, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Scheduling_Protocol: list of Supported_Scheduling_Protocols applies to (processor); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Server_Subprogram_Call_binding: inherit list of reference (thread, processor) applies to (subprogram, thread, thread group, process, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Size: type aadlinteger 0 B .. value (Max_Memory_Size) units Size_Units; ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String (" Size_Range: type range of Size; ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Source_Code_Size: Size applies to (data, thread, thread group, process, system, subprogram, processor, device); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Source_Data_Size: Size applies to (data, subprogram, thread, thread group, process, system, processor, device); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Source_Heap_Size: Size applies to (thread, subprogram); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Source_Language: inherit Supported_Source_Languages applies to (subprogram, data, thread, thread group, process, bus, device, processor, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Source_Name: aadlstring applies to (data, port, subprogram, parameter); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Source_Stack_Size: Size applies to (thread, subprogram, processor, device); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Source_Text: inherit list of aadlstring applies to (data, port, subprogram, thread, thread group, process, system, memory, bus, device, processor, parameter, port group); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Startup_Deadline: inherit Time applies to (processor, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Subprogram_Execution_Time: Time_Range applies to (subprogram); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Supported_Source_Language: list of Supported_Source_Languages applies to (processor, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Synchronized_Component: inherit aadlboolean => true applies to (thread, thread group, process, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Thread_Limit: aadlinteger 0 .. value(Max_Thread_Limit) => value(Max_Thread_Limit) applies to (processor); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Thread_Swap_Execution_Time: Time_Range applies to (processor, system); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Throughput: Data_Volume applies to (flow, connections); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Time: type aadlinteger 0 ps .. value(Max_Time) units Time_Units; ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String (" Time_Range: type range of Time; ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Transmission_Time: list of Time_Range applies to (bus); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Type_Source_Name: aadlstring applies to (data, port, subprogram); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Urgency: aadlinteger 0 .. value(Max_Urgency) applies to (port); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Word_Count: aadlinteger 0 .. value(Max_Word_Count) applies to (memory); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Word_Size: Size => 8 bits applies to (memory); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Word_Space: aadlinteger 1 .. value(Max_Word_Space) => 1 applies to (memory); ");

      result :=
        result &
        ASCII.LF &
        ASCII.HT &
        To_Unbounded_String
          (" Write_Time: list of Time_Range applies to (memory); ");

      result :=
        result & ASCII.LF & To_Unbounded_String (" end AADL_Properties;");

      result := result & unbounded_lf & unbounded_lf & unbounded_lf;

      return result;

   end export_aadl_standard_properties;

   function export_aadl_project_properties
     (a_system : in system) return Unbounded_String
   is
      result : Unbounded_String := empty_string;

   begin
      result :=
        result &
        To_Unbounded_String ("property set AADL_Project is") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT &
           "Default_Active_Thread_Handling_Protocol : constant Supported_Active_Thread_Handling_Protocols => abort;") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & "Max_Aadlinteger : constant aadlinteger => 2#1#e32;") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT &
           "Max_Memory_Size : constant aadlinteger Size_Units => 2#1#e32 B;") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & "Max_Queue_Size : constant aadlinteger => 512;") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & "Max_Base_Address : constant aadlinteger => 512;") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & "Max_Urgency : constant aadlinteger => 12;") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT &
           "Max_Time : constant aadlinteger Time_Units => 1000 Hr;") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & "Max_Thread_Limit : constant aadlinteger => 32;") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & "Max_Word_Count : constant aadlinteger => 64000;") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & "Max_Word_Space : constant aadlinteger => 64;") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT &
           "Supported_Active_Thread_Handling_Protocols : type enumeration (abort, complete_one_flush_queue, complete_one_transfer_queue, complete_one_preserve_queue, complete_all);") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT &
           "Supported_Connection_Protocols : type enumeration (UDP, TCP);") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT &
           "Supported_Dispatch_Protocols : type enumeration (Periodic, Background, Poisson_Process, Sporadic, User_Defined);") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT &
           "Supported_Concurrency_Control_Protocols : type enumeration (No_Protocol, Priority_Ceiling_Protocol, Immediate_Priority_Ceiling_Protocol, Priority_Inheritance_Protocol);") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT &
           "Supported_Hardware_Source_Languages : type enumeration (VHDL);") &
        unbounded_lf;

      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & "Supported_Scheduling_Protocols : type enumeration (");
      for i in schedulers_type'first .. schedulers_type'last loop
         result := result & To_Unbounded_String (schedulers_type'image (i));
         if i /= schedulers_type'last then
            result := result & To_Unbounded_String (", ");
         else
            result := result & To_Unbounded_String (");") & unbounded_lf;
         end if;
      end loop;

      result :=
        result &
        To_Unbounded_String
          (ASCII.HT &
           "Supported_Queue_Processing_Protocols : type enumeration (FIFO);") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT &
           "Supported_Source_Languages : type enumeration (Ada95, C);") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT &
           "Time_Units : type units (ps, Ns => ps * 1000, Us => Ns * 1000, Ms => Us * 1000, Sec => Ms * 1000, Min => Sec * 60, Hr => Min * 60);") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT &
           "Size_Units : type units (Bits, B => Bits * 8, KB => B * 1000, MB => KB * 1000, GB => MB * 1000);") &
        unbounded_lf;
      result :=
        result & To_Unbounded_String ("end AADL_Project;") & unbounded_lf;

      return result;

   end export_aadl_project_properties;

   -- Export cheddar's specific properties
   --
   function export_aadl_cheddar_properties
     (a_system : in system) return Unbounded_String
   is
      result : Unbounded_String;

   begin

      result :=
        result &
        unbounded_lf &
        To_Unbounded_String ("property set Cheddar_Properties is") &
        unbounded_lf;

      -- Thread and thread group properties
      --
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & "Dispatch_Seed_is_Predictable : aadlboolean") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & ASCII.HT & "applies to (thread, thread group);") &
        unbounded_lf;

      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & "Context_Switch_Overhead : inherit Time") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & ASCII.HT & "applies to (thread, thread group);") &
        unbounded_lf;

      result :=
        result &
        ASCII.HT &
        To_Unbounded_String
          ("Source_Text : inherit list of aadlstring  applies to (process, processor, thread, system);") &
        unbounded_lf &
        To_Unbounded_String
          (ASCII.HT &
           "-- Source_Text specifies the name of .sc files. This property can contains several .sc file names." &
           ASCII.LF &
           ASCII.HT &
           "-- In this case, the file names are separeted by a comma. " &
           ASCII.LF &
           ASCII.HT &
           "-- The .sc files contain pieces of code which can be interpreted by the " &
           ASCII.LF &
           ASCII.HT &
           "-- scheduling engine of Cheddar. These part of code are part of user-defined schedulers. With such .sc files, " &
           ASCII.LF &
           ASCII.HT &
           "-- one can design and perform simulations with specific thread dispatching protocols or specific scheduling protocols." &
           ASCII.LF &
           ASCII.HT &
           "--  " &
           ASCII.LF);

      result :=
        result &
        ASCII.HT &
        To_Unbounded_String
          ("Automaton_Name : inherit list of aadlstring  applies to (process, processor, thread);") &
        unbounded_lf;

      result :=
        result &
        To_Unbounded_String (ASCII.HT & "Dispatch_Seed_Value : aadlinteger") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & ASCII.HT & "applies to (thread, thread group);") &
        unbounded_lf;

      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & "Dispatch_Absolute_Time :  inherit Time ") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & ASCII.HT & "applies to (thread, thread group);") &
        unbounded_lf;

      result :=
        result &
        To_Unbounded_String (ASCII.HT & "Criticality : aadlinteger") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & ASCII.HT & "applies to (thread, thread group);") &
        unbounded_lf;

      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & "Bound_On_Data_Blocking_Time :  inherit Time ") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & ASCII.HT & "applies to (thread, thread group);") &
        unbounded_lf;

      result :=
        result &
        To_Unbounded_String (ASCII.HT & "Dispatch_Jitter :  inherit Time ") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & ASCII.HT & "applies to (thread, thread group);") &
        unbounded_lf;

      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & "Fixed_Priority : aadlinteger 0..255") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & ASCII.HT & "applies to (thread, thread group);") &
        unbounded_lf;

      result :=
        result &
        To_Unbounded_String
          (ASCII.HT &
           "POSIX_Scheduling_Policy : enumeration (SCHED_FIFO, SCHED_RR, SCHED_OTHERS)") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & ASCII.HT & "applies to (thread, thread group);") &
        unbounded_lf;
      for i in offsets_range'range loop
         result :=
           result &
           To_Unbounded_String
             (ASCII.HT &
              "Dispatch_Offset_Value_" &
              To_String (integer_util.format (Integer (i))) &
              " : aadlinteger") &
           unbounded_lf;
         result :=
           result &
           To_Unbounded_String
             (ASCII.HT & ASCII.HT & "applies to (thread, thread group);") &
           unbounded_lf;
         result :=
           result &
           To_Unbounded_String
             (ASCII.HT &
              "Dispatch_Offset_Time_" &
              To_String (integer_util.format (Integer (i))) &
              " :  inherit Time ") &
           unbounded_lf;
         result :=
           result &
           To_Unbounded_String
             (ASCII.HT & ASCII.HT & "applies to (thread, thread group);") &
           unbounded_lf;
      end loop;

      -- System properties
      --
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & "Task_Precedencies : list of aadlstring") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String (ASCII.HT & ASCII.HT & "applies to (system);") &
        unbounded_lf;

      -- Processor properties
      --
      result :=
        result &
        unbounded_lf &
        To_Unbounded_String (ASCII.HT & "Scheduler_Quantum :  inherit Time ") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & ASCII.HT & "applies to (processor, process);") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String (ASCII.HT & "Preemptive_Scheduler : aadlboolean") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & ASCII.HT & "applies to (processor, process);") &
        unbounded_lf &
        unbounded_lf;
      result :=
        result &
        unbounded_lf &
        To_Unbounded_String
          (ASCII.HT &
           "Scheduling_Protocol : list of Supported_Scheduling_Protocols ") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & ASCII.HT & "applies to (processor, process);") &
        unbounded_lf;

      -- Data properties
      --
      result :=
        result &
        unbounded_lf &
        To_Unbounded_String
          (ASCII.HT & "Data_Concurrency_State : aadlinteger") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String (ASCII.HT & ASCII.HT & "applies to (data);") &
        unbounded_lf &
        unbounded_lf;

      -- Process properties
      --
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & "Critical_Section : list of aadlstring") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String
          (ASCII.HT & ASCII.HT & "applies to (process, thread, data);") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String (ASCII.HT & "Source_Global_Heap_Size : Size ") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String (ASCII.HT & ASCII.HT & "applies to (process);") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String (ASCII.HT & "Source_Global_Stack_Size : Size ") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String (ASCII.HT & ASCII.HT & "applies to (process);") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String (ASCII.HT & "Source_Global_Text_Size : Size ") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String (ASCII.HT & ASCII.HT & "applies to (process);") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String (ASCII.HT & "Source_Global_Data_Size : Size ") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String (ASCII.HT & ASCII.HT & "applies to (process);") &
        unbounded_lf &
        unbounded_lf;

      result :=
        result &
        To_Unbounded_String ("end Cheddar_Properties;") &
        unbounded_lf &
        unbounded_lf;

      return result;

   end export_aadl_cheddar_properties;

   function export_aadl_implementations
     (a_system : in system) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
      tmp    : Unbounded_String := empty_string;

   begin

      -- Export all sub-components of the system
      --
      result := result & export_aadl_implementations (a_system.resources);
      result :=
        result &
        export_aadl_implementations (a_system.tasks, a_system.resources);
      result :=
        result &
        export_aadl_implementations
          (a_system.address_spaces,
           a_system.tasks,
           a_system.resources);
      result := result & export_aadl_implementations (a_system.buffers);
      result := result & export_aadl_implementations (a_system.messages);
      result := result & export_aadl_implementations (a_system.networks);
      result := result & export_aadl_implementations (a_system.processors);

      -- Export the system composition
      --
      result :=
        result &
        unbounded_lf &
        To_Unbounded_String ("system Cheddar") &
        unbounded_lf;
      result := result & To_Unbounded_String ("end Cheddar;") & unbounded_lf;
      result := result & unbounded_lf;

      result :=
        result &
        To_Unbounded_String ("system implementation Cheddar.Impl") &
        unbounded_lf;
      result :=
        result &
        To_Unbounded_String (ASCII.HT & "subcomponents") &
        unbounded_lf;

      -- List all processors, processes and networks
      --
      result := result & export_aadl_declarations (a_system.networks, 2);
      result := result & export_aadl_declarations (a_system.processors, 2);
      result := result & export_aadl_declarations (a_system.address_spaces, 2);

      -- Properties related to the global system : processor and bus
      --connections, event
      -- analyzers, task precedencies
      --
      tmp := export_aadl_properties (a_system.address_spaces, 2);
      tmp := tmp & export_aadl_properties (a_system.event_analyzers, 2);
      tmp := tmp & export_aadl_properties (a_system.dependencies, 2);
      if tmp /= empty_string then
         result :=
           result &
           To_Unbounded_String (ASCII.HT & "properties") &
           unbounded_lf &
           tmp;
      end if;

      result :=
        result &
        To_Unbounded_String ("end Cheddar.Impl;") &
        unbounded_lf &
        unbounded_lf;

      return result;

   end export_aadl_implementations;

   function export_aadl_declarations
     (a_system     : in system;
      number_of_ht : in Natural) return Unbounded_String
   is
      result : Unbounded_String := empty_string;

   begin
      return result;
   end export_aadl_declarations;

   function select_core (op1 : in generic_task_ptr) return Boolean is
   begin
      return
        (op1.core_name = current_core_name and
         op1.cpu_name = current_processor_name);
   end select_core;

   function select_cpu (op1 : in generic_task_ptr) return Boolean is
   begin
      return (op1.cpu_name = current_processor_name);
   end select_cpu;

   function select_cpu (op1 : in generic_resource_ptr) return Boolean is
   begin
      return (op1.cpu_name = current_processor_name);
   end select_cpu;

   function select_cpu (op1 : in buffer_ptr) return Boolean is
   begin
      return (op1.cpu_name = current_processor_name);
   end select_cpu;


   procedure check_task_one_critical_section
      (task_name         : in Unbounded_String;
      task_capacity      : in Integer;
      task_cpu_name      : in Unbounded_String;
      a_resource_name    : in Unbounded_String;
      a_resource_cpuname : in Unbounded_String;
      a_resource_protocol: in Resources_Type;
      a_critical_section : in critical_section)
   is

   begin

      --
      -- Check if begin and end time are consistent
      --
      if (a_critical_section.task_begin <= 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (a_resource_name &
               " ; " &
               task_name &
               " ; " &
               a_critical_section.task_synchronization'img &
               " ; " &
               lb_task_begin (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_than (Current_Language) &
               "0"));
      end if;

      if (a_critical_section.task_end <= 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (a_resource_name &
               " ; " &
               task_name &
               " ; " &
               a_critical_section.task_synchronization'img &
               " ; " &
               lb_task_end (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_than (Current_Language) &
               "0"));
      end if;

      if a_critical_section.task_begin > a_critical_section.task_end then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (a_resource_name &
               " ; " &
               task_name &
               " ; " &
               a_critical_section.task_synchronization'img &
               " ; " &
               lb_task_begin (Current_Language) &
               lb_must_be (Current_Language) &
               lb_less_or_equal_than (Current_Language) &
               lb_task_end (Current_Language)));
      end if;

      if (a_critical_section.task_begin /= a_critical_section.task_end)
         and (a_critical_section.task_synchronization /= mutex) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (a_resource_name &
               " ; " &
               task_name &
               " ; " &
               a_critical_section.task_synchronization'img &
               " ; " &
               lb_task_begin (Current_Language) &
               lb_must_be (Current_Language) &
               " = " &
               lb_task_end (Current_Language)));
      end if;

      -- Check that the critical section is consistent according to
      -- the task definition
      --
      if (Natural (a_critical_section.task_end) > task_capacity) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (a_resource_name &
               " ; " &
               task_name &
               " ; " &
               a_critical_section.task_synchronization'img &
               " ; " &
               lb_task_end (Current_Language) &
               lb_must_be (Current_Language) &
               lb_less_or_equal_than (Current_Language) &
               lb_capacity (Current_Language)));
      end if;

      if (Natural (a_critical_section.task_begin) > task_capacity) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (a_resource_name &
               " ; " &
               task_name &
               " ; " &
               a_critical_section.task_synchronization'img &
               " ; " &
               lb_task_begin (Current_Language) &
               lb_must_be (Current_Language) &
               lb_less_or_equal_than (Current_Language) &
               lb_capacity (Current_Language)));
      end if;

      -- Check that the task is on the same processor that the
      -- resource
      --
      if task_cpu_name /= a_resource_cpuname then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (a_resource_name &
               " ; " &
               task_name &
               " ; " &
               lb_have_to_be_on_the_same_processor (Current_Language)));
      end if;


      -- Wait and Post synchronization can only use No_Protocol
      -- 
      if (a_critical_section.task_synchronization=Wait)
         or (a_critical_section.task_synchronization=Post)
           then
      if (a_resource_protocol /= No_protocol) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (a_resource_name &
               " ; " &
               task_name &
               " ; Only apply No_Protocol when Wait/Post synchronization are used"));
        end if;
      end if;


   end check_task_one_critical_section;


   procedure check_task_critical_sections
     (a_sys             : in system;
      a_resource_name    : in Unbounded_String;
      a_resource_cpu_name : in Unbounded_String;
      a_resource_protocol: in Resources_Type;
      critical_sections : in resource_accesses_table) is 

      a_task : generic_task_ptr;

   begin

      -- Check each critical section
      --
      for i in 0 .. critical_sections.nb_entries - 1 loop
         a_task := search_task (a_sys.tasks, critical_sections.entries (i).item);

         check_task_one_critical_section
           (a_task.name, a_task.capacity, a_task.cpu_name,
            a_resource_name, a_resource_cpu_name, a_resource_protocol,
            critical_sections.entries (i).data);

      end loop;

      -- Check that we have no duplicated critical section
      --
      for i in 0 .. critical_sections.nb_entries - 1 loop
         for j in 0 .. critical_sections.nb_entries - 1 loop
            if
              (critical_sections.entries (i) =
               critical_sections.entries (j)) and
              (i /= j)
            then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (critical_sections.entries (i).item &
                     " ; " &
                     a_resource_name &
                     " ; " &
                     lb_duplicated_critical_section (Current_Language)));
            end if;
         end loop;
      end loop;

   end check_task_critical_sections;


   procedure check_task_critical_sections
     (a_sys         : in system;
      task_name     : in Unbounded_String;
      task_capacity : in Integer;
      task_cpu_name : in Unbounded_String)
   is

      a_resource  : generic_resource_ptr;
      my_iterator : resources_iterator;

   begin
      if not is_empty (a_sys.resources) then
         reset_iterator (a_sys.resources, my_iterator);
         loop
            current_element (a_sys.resources, a_resource, my_iterator);

            for i in 0 .. a_resource.critical_sections.nb_entries - 1 loop
               if
                 (task_name = a_resource.critical_sections.entries (i).item)
               then
                  check_task_one_critical_section
                    (task_name,
                     task_capacity,
                     task_cpu_name,
                     a_resource.name, a_resource.cpu_name, a_resource.protocol,
                     a_resource.critical_sections.entries (i).data);
               end if;
            end loop;
            exit when is_last_element (a_sys.resources, my_iterator);
            next_element (a_sys.resources, my_iterator);
         end loop;
      end if;

   end check_task_critical_sections;

   --------------------------------------------------------
   -- Functions to check if a task has a critical section
   -- in a given resource
   --------------------------------------------------------

   function has_a_critical_section
     (cs_task     : in generic_task_ptr;
      cs_resource : in generic_resource_ptr) return Boolean
   is

      result : Boolean := False;
   begin
      -- Check each critical section
      --
      for i in 0 .. cs_resource.critical_sections.nb_entries - 1 loop
         if
           (cs_task.name = cs_resource.critical_sections.entries (i).item)
         then
            result := True;
         end if;
      end loop;

      return result;
   end has_a_critical_section;

   procedure check_task_critical_sections
     (a_sys         : in system;
      a_task     : in generic_task_ptr)
   is

      a_resource  : generic_resource_ptr;
      my_iterator : resources_iterator;

   begin
      if not is_empty (a_sys.resources) then
         reset_iterator (a_sys.resources, my_iterator);
         loop
            current_element (a_sys.resources, a_resource, my_iterator);

            for i in 0 .. a_resource.critical_sections.nb_entries - 1 loop
               if
                 (a_task.name = a_resource.critical_sections.entries (i).item)
               then
                  check_task_one_critical_section
                    (a_task.name, a_task.capacity, a_task.cpu_name,
                     a_resource.name, a_resource.cpu_name, a_resource.protocol,
                     a_resource.critical_sections.entries (i).data);
               end if;
            end loop;
            exit when is_last_element (a_sys.resources, my_iterator);
            next_element (a_sys.resources, my_iterator);
         end loop;
      end if;

   end check_task_critical_sections;

   procedure check_task_one_buffer_role
     (task_name     : in Unbounded_String;
      task_capacity :    Integer;
      buffer_name   : in Unbounded_String;
      a_buffer_role :    buffer_role)
   is

   begin

      if (a_buffer_role.size <= 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (buffer_name &
               " ; " &
               task_name &
               " ; " &
               lb_size (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_than (Current_Language) &
               To_Unbounded_String ("0")));
      end if;

      if (a_buffer_role.time <= 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (buffer_name &
               " ; " &
               task_name &
               " ; " &
               lb_time (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_than (Current_Language) &
               To_Unbounded_String ("0")));
      end if;

      -- Check that capacity is <= time
      --
      if task_capacity < a_buffer_role.time then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (buffer_name &
               " ; " &
               task_name &
               " ; " &
               lb_time (Current_Language) &
               lb_must_be (Current_Language) &
               lb_less_or_equal_than (Current_Language) &
               lb_capacity (Current_Language)));
      end if;

   end check_task_one_buffer_role;

   procedure check_task_buffer_roles
     (my_tasks    : in tasks_set;
      buffer_name : in Unbounded_String;
      roles       : in buffer_roles_table)
   is

      a_task : generic_task_ptr;

   begin

      -- Check each buffer role
      --
      for i in 0 .. roles.nb_entries - 1 loop
         a_task := search_task (my_tasks, roles.entries (i).item);
         check_task_one_buffer_role
           (a_task.name,
            a_task.capacity,
            buffer_name,
            roles.entries (i).data);
      end loop;

      -- Check that we have no duplicated buffer role
      --
      for i in 0 .. roles.nb_entries - 1 loop
         for j in 0 .. roles.nb_entries - 1 loop
            if (roles.entries (i) = roles.entries (j)) and (i /= j) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (roles.entries (i).item &
                     " ; " &
                     buffer_name &
                     " ; " &
                     lb_duplicated_buffer_role (Current_Language)));
            end if;
         end loop;
      end loop;

   end check_task_buffer_roles;

   procedure check_task_buffer_roles
     (a_sys         : in system;
      task_name     : in Unbounded_String;
      task_capacity : in Integer)
   is

      a_buffer    : buffer_ptr;
      my_iterator : buffers_iterator;

   begin

      if not is_empty (a_sys.buffers) then
         reset_iterator (a_sys.buffers, my_iterator);
         loop
            current_element (a_sys.buffers, a_buffer, my_iterator);

            for i in 0 .. a_buffer.roles.nb_entries - 1 loop
               if (task_name = a_buffer.roles.entries (i).item) then
                  check_task_one_buffer_role
                    (task_name,
                     task_capacity,
                     a_buffer.name,
                     a_buffer.roles.entries (i).data);
               end if;
            end loop;
            exit when is_last_element (a_sys.buffers, my_iterator);
            next_element (a_sys.buffers, my_iterator);
         end loop;
      end if;

   end check_task_buffer_roles;

   function search_by_name
     (a_system : in system;
      name     : in Unbounded_String) return generic_object_ptr
   is
      obj : generic_object_ptr;
   begin

      if task_is_present (a_system.tasks, name) then
         obj := generic_object_ptr (search_task (a_system.tasks, name));
      end if;
      if processor_is_present (a_system.processors, name) then
         obj :=
           generic_object_ptr (search_processor (a_system.processors, name));
      end if;
      if core_is_present (a_system.core_units, name) then
         obj :=
           generic_object_ptr (search_core_unit (a_system.core_units, name));
      end if;
      if address_space_is_present (a_system.address_spaces, name) then
         obj :=
           generic_object_ptr
             (search_address_space (a_system.address_spaces, name));
      end if;
      if resource_is_present (a_system.resources, name) then
         obj :=
           generic_object_ptr (search_resource (a_system.resources, name));
      end if;

      return obj;
   end search_by_name;

end systems;
