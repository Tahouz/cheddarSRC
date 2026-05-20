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
--    $Rev: 4589 $
--    $Date: 2023-09-29 16:02:19 +0200 (ven., 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Text_IO;       use Text_IO;
with processors;    use processors;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with parameters;          use parameters;
with parameters.extended; use parameters.extended;
use parameters.framework_parameters_table_package;
with task_set; use task_set;
use task_set.generic_task_set;
with systems;                  use systems;
with framework;                use framework;
with call_framework;           use call_framework;
with call_framework_interface; use call_framework_interface;
use call_framework_interface.framework_response_package;
use call_framework_interface.framework_request_package;
with call_scheduling_framework;         use call_scheduling_framework;
with multiprocessor_services;           use multiprocessor_services;
with multiprocessor_services_interface; use multiprocessor_services_interface;
use multiprocessor_services_interface.scheduling_result_per_processor_package;

procedure comprehensive_call is

   procedure call_processor_analysis
     (a_sys : in out system;
      name  : in     Unbounded_String)
   is

      response_list : framework_response_table;
      request_list  : framework_request_table;
      a_request     : framework_request;
      a_param       : parameter_ptr;

   begin
      initialize (response_list);
      initialize (request_list);

      initialize (a_request);
      a_request.target    := name;
      a_request.statement := scheduling_simulation_preemption_number;
      add (request_list, a_request);

      initialize (a_request);
      a_request.target    := name;
      a_request.statement := scheduling_simulation_context_switch_number;
      add (request_list, a_request);

      initialize (a_request);
      a_param                := new parameter (boolean_parameter);
      a_param.parameter_name := To_Unbounded_String ("worst_case");
      a_param.boolean_value  := True;
      add (a_request.param, a_param);

      a_param                := new parameter (boolean_parameter);
      a_param.parameter_name := To_Unbounded_String ("best_case");
      a_param.boolean_value  := True;
      add (a_request.param, a_param);

      a_param                := new parameter (boolean_parameter);
      a_param.parameter_name := To_Unbounded_String ("average_case");
      a_param.boolean_value  := True;
      add (a_request.param, a_param);

      a_request.target    := name;
      a_request.statement := scheduling_simulation_response_time;
      add (request_list, a_request);

      sequential_framework_request (a_sys, request_list, response_list);

      Put_Line (To_String (response_list.entries (0).title));
      for j in 0 .. response_list.nb_entries - 1 loop
         Put_Line (To_String (response_list.entries (j).text));
      end loop;

   end call_processor_analysis;

   procedure run_event_analyzer (a_sys : in out system) is

      response_list : framework_response_table;
      request_list  : framework_request_table;
      a_request     : framework_request;

   begin
      initialize (response_list);
      initialize (request_list);

      initialize (a_request);
      a_request.statement := scheduling_simulation_run_event_handler;
      add (request_list, a_request);

      sequential_framework_request (a_sys, request_list, response_list);

      Put_Line (To_String (response_list.entries (0).title));
      for j in 0 .. response_list.nb_entries - 1 loop
         Put_Line (To_String (response_list.entries (j).text));
      end loop;

   end run_event_analyzer;

   procedure compute_scheduling (a_sys : in out system) is

      response_list : framework_response_table;
      request_list  : framework_request_table;
      a_request     : framework_request;
      a_param       : parameter_ptr;

   begin

      initialize (response_list);
      initialize (request_list);
      initialize (a_request);
      a_request.statement    := scheduling_simulation_time_line;
      a_param                := new parameter (integer_parameter);
      a_param.parameter_name := To_Unbounded_String ("period");
      a_param.integer_value  := 100;
      add (a_request.param, a_param);
      a_param                := new parameter (boolean_parameter);
      a_param.parameter_name := To_Unbounded_String ("schedule_with_offsets");
      a_param.boolean_value  := True;
      add (a_request.param, a_param);
      a_param                := new parameter (boolean_parameter);
      a_param.parameter_name :=
        To_Unbounded_String ("schedule_with_precedencies");
      a_param.boolean_value := True;
      add (a_request.param, a_param);
      a_param                := new parameter (boolean_parameter);
      a_param.parameter_name :=
        To_Unbounded_String ("schedule_with_resources");
      a_param.boolean_value := True;
      add (a_request.param, a_param);
      a_param                := new parameter (integer_parameter);
      a_param.parameter_name := To_Unbounded_String ("seed_value");
      a_param.integer_value  := 0;
      add (a_request.param, a_param);
      add (request_list, a_request);
      sequential_framework_request (a_sys, request_list, response_list);

      Put_Line (To_String (response_list.entries (0).title));
      for j in 0 .. response_list.nb_entries - 1 loop
         Put_Line (To_String (response_list.entries (j).text));
      end loop;

   end compute_scheduling;

   procedure run_basic_feasibility_tests (a_sys : in out system) is

      response_list : framework_response_table;
      request_list  : framework_request_table;
      a_request     : framework_request;

   begin

      initialize (response_list);
      initialize (request_list);
      initialize (a_request);
      a_request.statement := scheduling_feasibility_basics;
      add (request_list, a_request);

      sequential_framework_request (a_sys, request_list, response_list);

      Put_Line (To_String (response_list.entries (0).title));
      for j in 0 .. response_list.nb_entries - 1 loop
         Put_Line (To_String (response_list.entries (j).text));
      end loop;

   end run_basic_feasibility_tests;

   sys : system;

   project_file_list     : unbounded_string_list;
   a_processor           : generic_processor_ptr;
   my_processor_iterator : processors_iterator;
   project_file_dir_list : unbounded_string_list;

begin

   -- Initialize the Cheddar framework
   --
   call_framework.initialize (False);

   -- Read project file
   --
   initialize (project_file_list);
   systems.read_from_xml_file
     (sys,
      project_file_dir_list,
      To_Unbounded_String ("arinc653.xml"));

   -- Compute basic feasibility tests
   --
   run_basic_feasibility_tests (sys);

   -- Compute the scheduling
   --
   compute_scheduling (sys);

   -- Perform analysis on the computed scheduling for each processor
   --
   reset_iterator (sys.processors, my_processor_iterator);
   loop
      current_element (sys.processors, a_processor, my_processor_iterator);

      call_processor_analysis (sys, a_processor.name);

      exit when is_last_element (sys.processors, my_processor_iterator);
      next_element (sys.processors, my_processor_iterator);
   end loop;

   -- Run event analyzer
   --
   run_event_analyzer (sys);

   -- Export Event table into the event_table.xml file
   --
   write_to_xml_file
     (framework.sched,
      sys,
      To_Unbounded_String ("event_table.xml"));

end comprehensive_call;
