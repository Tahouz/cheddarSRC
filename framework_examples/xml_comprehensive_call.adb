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

with Text_IO;                  use Text_IO;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with systems;                  use systems;
with xml_tag;                  use xml_tag;
with call_framework;           use call_framework;
with call_framework_interface; use call_framework_interface;
use call_framework_interface.framework_response_package;
use call_framework_interface.framework_request_package;
with call_memory_framework; use call_memory_framework;
use call_memory_framework.buffer_result_package;
with parameters; use parameters;
with parameters.extended;
use parameters.framework_parameters_table_package;
with unbounded_strings; use unbounded_strings;
use unbounded_strings.unbounded_string_list_package;

procedure xml_comprehensive_call is

   sys : system;

   response_list : framework_response_table;
   request_list  : framework_request_table;
   a_request     : framework_request;
   a_param       : parameter_ptr;
   dir           : unbounded_string_list;

begin

   call_framework.initialize (False);

   Put_Line ("<results>");

   -- Test on periodic tasks
   --
   read_from_xml_file (sys, dir, To_Unbounded_String ("jitter.xml"));

   initialize (response_list);
   initialize (request_list);
   initialize (a_request);
   a_request.statement := scheduling_feasibility_basics;
   add (request_list, a_request);
   sequential_framework_request
     (sys,
      request_list,
      response_list,
      total_order,
      xml_output);
   put (response_list);
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
   a_param.parameter_name := To_Unbounded_String ("schedule_with_resources");
   a_param.boolean_value  := True;
   add (a_request.param, a_param);
   a_param                := new parameter (integer_parameter);
   a_param.parameter_name := To_Unbounded_String ("seed_value");
   a_param.integer_value  := 0;
   add (a_request.param, a_param);
   add (request_list, a_request);
   sequential_framework_request
     (sys,
      request_list,
      response_list,
      total_order,
      xml_output);
   put (response_list);
   initialize (request_list);
   initialize (response_list);
   initialize (a_request);
   a_request.statement := scheduling_simulation_basics;
   add (request_list, a_request);
   sequential_framework_request
     (sys,
      request_list,
      response_list,
      total_order,
      xml_output);
   put (response_list);

   Put_Line ("</results>");

end xml_comprehensive_call;
