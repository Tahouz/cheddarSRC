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
--    $Rev: 4967 $
--    $Date: 2024-04-13 10:27:12 +0200 (sam., 13 avril 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

------------------------------------------------------------------------------
with Ada.Text_IO;             use Ada.Text_IO;
with Ada.Strings.Maps;        use Ada.Strings.Maps;
with Ada.Strings.Unbounded;   use Ada.Strings.Unbounded;

with Sax.Readers;             use Sax.Readers;
with Sax.Exceptions;          use Sax.Exceptions;
with Sax.Locators;            use Sax.Locators;
with Sax.Attributes;          use Sax.Attributes;
with Unicode.CES;             use Unicode.CES;
with Unicode;                 use Unicode;

with Offsets;                 use Offsets;
use Offsets.Offsets_Table_Package;
with Parameters;              use Parameters;
use Parameters.User_Defined_Parameters_Table_Package;
with strings;                 use strings;
with unbounded_strings;       use unbounded_strings;
with Dependencies;            use Dependencies;
with Resources;               use Resources;
use Resources.Resource_Accesses;
with resource_set;            use resource_set;
use resource_set.generic_resource_set;
with Messages;                use Messages;
with message_set;             use message_set;
use message_set.generic_message_set;
with event_analyzer_set;      use event_analyzer_set;
use event_analyzer_set.generic_event_analyzer_set;
with Tasks;                   use Tasks;
with task_set;                use task_set;
use task_set.generic_task_set;
with Caches;                  use Caches;
with cache_set;               use cache_set;
with Address_Spaces;          use Address_Spaces;
with address_space_set;       use address_space_set;
use address_space_set.generic_address_space_set;
with Buffers;                 use Buffers;
use Buffers.Buffer_Roles_Package;
with buffer_set;              use buffer_set;
use buffer_set.generic_buffer_set;
with Processors;              use Processors;
with Queueing_Systems;        use Queueing_Systems;
with time_unit_events;        use time_unit_events;
use time_unit_events.time_unit_package;
with Scheduling_Analysis;     use Scheduling_Analysis;
with Scheduler_Interface;     use Scheduler_Interface;
with task_dependencies;       use task_dependencies;
with network_set;             use network_set;
with Networks;                use Networks;
with xml_architecture_io;     use xml_architecture_io;
with multiprocessor_services; use multiprocessor_services;
with Framework_Config;        use Framework_Config;
with doubles;                 use doubles;


package body xml_generic_parsers.event_table is

   tue1   : time_unit_event_io;
   sched1 : scheduling_result_io;

   -- Variable to store indexes of indexed_table entities
   --
   index_value : Natural;

   new_table : scheduling_result_ptr;
   new_event : time_unit_event_ptr;

   a_buffer    : buffer_ptr;
   a_message   : generic_message_ptr;
   a_task      : generic_task_ptr;
   a_cache     : generic_cache_ptr;
   a_resource  : generic_resource_ptr;
   a_processor : generic_processor_ptr;

   function get_parsed_event_table
     (handler : in xml_event_table_parser) return scheduling_table_ptr
   is
   begin
      return handler.parsed_event_table;
   end get_parsed_event_table;

   procedure set_scheduled_system
     (handler          : in out xml_event_table_parser;
      scheduled_system : in     system)
   is
   begin
      handler.scheduled_system := scheduled_system;
   end set_scheduled_system;

   procedure initialize_event_table_parser
     (handler : in out xml_event_table_parser)
   is
   begin
      Initialize (tue1);
      Initialize (sched1);
      handler.current_parameter := 1;
   end initialize_event_table_parser;

   procedure start_document (handler : in out xml_event_table_parser) is
   begin
      initialize_event_table_parser (handler);
      handler.parsed_event_table := new scheduling_table;
   end start_document;

   procedure start_element
     (handler       : in out xml_event_table_parser;
      namespace_uri :        Unicode.CES.byte_sequence := "";
      local_name    :        Unicode.CES.byte_sequence := "";
      qname         :        Unicode.CES.byte_sequence := "";
      atts          :        Sax.Attributes.attributes'class)
   is
   begin
      handler.current_parameter := 1;

      Start_Element
        (xml_generic_parser (handler),
         tue1,
         namespace_uri,
         local_name,
         qname,
         atts);
      Start_Element
        (xml_generic_parser (handler),
         sched1,
         namespace_uri,
         local_name,
         qname,
         atts);

      -- Start to parse a scheduling sequence
      --
      -- IMPORTANT: NEED TO VERIFY THE PROBLEM WITH SCHEDULING_RESULT
      -- IN THE NEW VERSION OF WRITE TO XML !!!
      if qname = "event_table" or qname = "scheduling_result" then
         new_table                := new scheduling_result;
         new_table.has_error      := False;
         new_table.scheduling_msg := empty_string;
         new_table.error_msg      := empty_string;
         new_table.result         := new scheduling_sequence;
         add (handler.parsed_event_table.all, a_processor, new_table.all);
      end if;

   end start_element;

   procedure end_element
     (handler       : in out xml_event_table_parser;
      namespace_uri :        Unicode.CES.byte_sequence := "";
      local_name    :        Unicode.CES.byte_sequence := "";
      qname         :        Unicode.CES.byte_sequence := "")
   is

   begin

      end_element
        (xml_generic_parser (handler),
         index_value,
         namespace_uri,
         local_name,
         qname);
      End_Element
        (xml_generic_parser (handler),
         tue1,
         namespace_uri,
         local_name,
         qname);
      End_Element
        (xml_generic_parser (handler),
         sched1,
         namespace_uri,
         local_name,
         qname);

      -- Name of the processor related to the scheduling sequence
      --
      if qname = "name" then
         a_processor :=
           search_processor
             (handler.scheduled_system.processors,
              handler.parameter_list (1));
      end if;

      if qname = "scheduling_result" then
         initialize_event_table_parser (handler);
      end if;

      -- TODO: IMPORTANT: NEED TO VERIFY THE PROBLEM WITH SCHEDULING_RESULT
      -- IN THE NEW VERSION OF WRITE TO XML !!!
      if qname = "event_table" then
         initialize_event_table_parser (handler);
      end if;

      if qname = "time_unit_event" then
         case tue1.type_of_event is

            when start_of_task_capacity =>
               a_task :=
                 search_task_by_id
                   (handler.scheduled_system.tasks,
                    tue1.start_task);
               new_event := new time_unit_event (start_of_task_capacity);
               new_event.start_task := a_task;
               add (new_table.result.all, index_value, new_event);

            when end_of_task_capacity =>
               a_task :=
                 search_task_by_id
                   (handler.scheduled_system.tasks,
                    tue1.end_task);
               new_event := new time_unit_event (end_of_task_capacity);
               new_event.end_task := a_task;
               add (new_table.result.all, index_value, new_event);

            when write_to_buffer =>
               a_task :=
                 search_task_by_id
                   (handler.scheduled_system.tasks,
                    tue1.write_task);
               a_buffer :=
                 search_buffer_by_id
                   (handler.scheduled_system.buffers,
                    tue1.write_buffer);

               new_event := new time_unit_event (write_to_buffer);
               new_event.write_buffer                   := a_buffer;
               new_event.write_task                     := a_task;
               new_event.write_size                     := tue1.write_size;
               new_event.write_buffer_current_data_size :=
                 tue1.write_buffer_current_data_size;
               add (new_table.result.all, index_value, new_event);

            when read_from_buffer =>
               a_task :=
                 search_task_by_id
                   (handler.scheduled_system.tasks,
                    tue1.read_task);
               a_buffer :=
                 search_buffer_by_id
                   (handler.scheduled_system.buffers,
                    tue1.read_buffer);

               new_event := new time_unit_event (read_from_buffer);
               new_event.read_buffer                   := a_buffer;
               new_event.read_task                     := a_task;
               new_event.read_size                     := tue1.read_size;
               new_event.read_buffer_current_data_size :=
                 tue1.read_buffer_current_data_size;
               add (new_table.result.all, index_value, new_event);

            when buffer_overflow =>
               -- TODO
               null;

            when buffer_underflow =>
               -- TODO
               null;

            when energy =>
               -- TODO
               null;

            when mode_change =>
               -- TODO
               null;

            when context_switch_overhead =>
               a_task :=
                 search_task_by_id
                   (handler.scheduled_system.tasks,
                    tue1.switched_task);
               new_event := new time_unit_event (context_switch_overhead);
               new_event.switched_task := a_task;
               add (new_table.result.all, index_value, new_event);

            when running_task =>
               a_task :=
                 search_task_by_id
                   (handler.scheduled_system.tasks,
                    tue1.running_task);
               new_event := new time_unit_event (running_task);
               new_event.running_task     := a_task;
               new_event.current_priority :=
                 priority_range (tue1.current_priority);
               new_event.crpd        := tue1.CRPD;
               new_event.cache_state := tue1.cache_state;
               add (new_table.result.all, index_value, new_event);

            when task_activation =>
               a_task :=
                 search_task_by_id
                   (handler.scheduled_system.tasks,
                    tue1.activation_task);
               new_event := new time_unit_event (task_activation);
               new_event.activation_task := a_task;
               add (new_table.result.all, index_value, new_event);

            when allocate_resource =>
               a_resource :=
                 search_resource_by_id
                   (handler.scheduled_system.resources,
                    tue1.allocate_resource);
               a_task :=
                 search_task_by_id
                   (handler.scheduled_system.tasks,
                    tue1.allocate_task);
               new_event := new time_unit_event (allocate_resource);
               new_event.allocate_task     := a_task;
               new_event.allocate_resource := a_resource;
               add (new_table.result.all, index_value, new_event);

            when release_resource =>
               a_resource :=
                 search_resource_by_id
                   (handler.scheduled_system.resources,
                    tue1.release_resource);
               a_task :=
                 search_task_by_id
                   (handler.scheduled_system.tasks,
                    tue1.release_task);
               new_event := new time_unit_event (release_resource);
               new_event.release_task     := a_task;
               new_event.release_resource := a_resource;
               add (new_table.result.all, index_value, new_event);

            when wait_for_resource =>
               a_resource :=
                 search_resource_by_id
                   (handler.scheduled_system.resources,
                    tue1.wait_for_resource);
               a_task :=
                 search_task_by_id
                   (handler.scheduled_system.tasks,
                    tue1.wait_for_resource_task);
               new_event := new time_unit_event (wait_for_resource);
               new_event.wait_for_resource_task := a_task;
               new_event.wait_for_resource      := a_resource;
               add (new_table.result.all, index_value, new_event);

            when send_message =>
               a_message :=
                 search_message_by_id
                   (handler.scheduled_system.messages,
                    tue1.send_message);
               a_task :=
                 search_task_by_id
                   (handler.scheduled_system.tasks,
                    tue1.send_task);
               new_event              := new time_unit_event (send_message);
               new_event.send_task    := a_task;
               new_event.send_message := a_message;
               add (new_table.result.all, index_value, new_event);

            when receive_message =>
               a_message :=
                 search_message_by_id
                   (handler.scheduled_system.messages,
                    tue1.receive_message);
               a_task :=
                 search_task_by_id
                   (handler.scheduled_system.tasks,
                    tue1.receive_task);
               new_event := new time_unit_event (receive_message);
               new_event.receive_task    := a_task;
               new_event.receive_message := a_message;
               add (new_table.result.all, index_value, new_event);

            when wait_for_memory =>
               a_cache :=
                 search_cache_by_id
                   (handler.scheduled_system.caches,
                    tue1.wait_for_cache);
               a_task :=
                 search_task_by_id
                   (handler.scheduled_system.tasks,
                    tue1.wait_for_memory_task);
               new_event := new time_unit_event (wait_for_memory);
               new_event.wait_for_memory_task := a_task;
               new_event.wait_for_cache       := a_cache;
               add (new_table.result.all, index_value, new_event);

            when address_space_activation =>
               new_event := new time_unit_event (address_space_activation);
               new_event.activation_address_space :=
                 tue1.activation_address_space;
               new_event.duration := tue1.duration;
               add (new_table.result.all, index_value, new_event);

            when preemption =>
               new_event := new time_unit_event (preemption);
               a_task    :=
                 search_task_by_id
                   (handler.scheduled_system.tasks,
                    tue1.preempted_task);

               new_event.preempted_task := a_task;
               a_task                   :=
                 search_task_by_id
                   (handler.scheduled_system.tasks,
                    tue1.preempting_task);
               new_event.preempting_task := a_task;
               -- TODO: Update the method to find the list of evicted UCB
               new_event.evicted_ucbs := 0;
               add (new_table.result.all, index_value, new_event);

            when discard_missed_deadline =>
               a_task :=
                 search_task_by_id
                   (handler.scheduled_system.tasks,
                    tue1.missed_deadline_task);
               new_event := new time_unit_event (discard_missed_deadline);
               new_event.missed_deadline_task := a_task;
               add (new_table.result.all, index_value, new_event);

            when tdma_slot=>
               a_message :=
                 search_message_by_id
                   (handler.scheduled_system.messages,
                    tue1.receive_message);
               new_event := new time_unit_event (tdma_slot);
               new_event.slot_message:= a_message;
               new_event.slot_duration:= tue1.slot_duration;

         end case;
         initialize_event_table_parser (handler);
      end if;

   end end_element;

end xml_generic_parsers.event_table;
