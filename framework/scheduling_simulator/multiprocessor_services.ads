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
--    $Rev: 5144 $
--    $Date: 2024-08-30 12:53:28 +0200 (ven., 30 août 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Interpreter; use Interpreter;
use Interpreter.Sets_Type_Package;
with systems;    use systems;
with Processors; use Processors;
with buffer_set; use buffer_set;
use buffer_set.generic_buffer_set;
with messages; use messages;
with message_set; use message_set;
use message_set.generic_message_set;
with event_analyzers;              use event_analyzers;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;
with Framework_Config;             use Framework_Config;
with Scheduling_Analysis;          use Scheduling_Analysis;
with Scheduling_Analysis.extended; use Scheduling_Analysis.extended;
with dependencies; use dependencies;
with task_dependencies; use task_dependencies;
use task_dependencies.half_dep_set;
with indexed_tables;
with Unchecked_Deallocation;
with processor_set;                use processor_set;
use processor_set.generic_processor_set;
with address_space_set; use address_space_set;
use address_space_set.generic_address_space_set;
with time_unit_events; use time_unit_events;
use time_unit_events.time_unit_package;
with task_set; use task_set;
use task_set.generic_task_set;
with Resources; use Resources;
use Resources.Resource_Accesses;
with resource_set; use resource_set;
use resource_set.generic_resource_set;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with scheduling_options; use scheduling_options;

package multiprocessor_services is

   procedure free (sched : in out scheduling_table_ptr);

   procedure display_scheduling (sched : in scheduling_table_ptr);

   ------------------------------------------------------
   -- Write/read the event table into/from a XML file
   ------------------------------------------------------

   procedure write_to_xml_file
     (sched     : in scheduling_table_ptr;
      sys       : in system;
      file_name : in String);

   procedure write_to_xml_file
     (sched     : in scheduling_table_ptr;
      sys       : in system;
      file_name : in Unbounded_String);
      
   procedure get_xml_event_table
     (sched     : in scheduling_table_ptr;
      sys       : in system;
      Result    : in out Unbounded_String);

   procedure read_from_xml_file
     (sched     : in out scheduling_table_ptr;
      sys       : in     system;
      file_name : in     String);

   procedure read_from_xml_file
     (sched     : in out scheduling_table_ptr;
      sys       : in     system;
      file_name : in     Unbounded_String);

   -----------------------------------------------------------------
   --  This function is the major entry point of the scheduling simulator
   -----------------------------------------------------------------

   --
   -- LastTime <=> Period
   --
   procedure build_multiprocessor_scheduling
     (sys               : in     system;
      result            : in out scheduling_table_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table;
      last_time         : in     Natural;
      options           : in     scheduling_option);

   procedure initialize_multiprocessor_scheduling
     (sys               : in     system;
      result            : in out scheduling_table_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table;
      last_time         : in     Natural;
      options           : in     scheduling_option);

   --------------------------------------------------------------
   -- User's defined event anayser
   -- From a scheduling table, this function do an
   -- user's defined analysis (computed with "event analyzers"
   --------------------------------------------------------------

   procedure run_an_event_analyzer
     (sys               : in     system;
      sched             : in     scheduling_table_ptr;
      an_event_analyzer : in     event_analyzer_ptr;
      result            : in out Unbounded_String);

end multiprocessor_services;
