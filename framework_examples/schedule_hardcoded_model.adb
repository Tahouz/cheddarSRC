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

with Ada.IO_Exceptions;      use Ada.IO_Exceptions;
with GNAT.Current_Exception; use GNAT.Current_Exception;
with Text_IO;                use Text_IO;
with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;
with unbounded_strings;      use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with unbounded_strings;   use unbounded_strings;
with parameters;          use parameters;
with parameters.extended; use parameters.extended;
use parameters.framework_parameters_table_package;
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
with GNAT.Command_Line;
with GNAT.OS_Lib;      use GNAT.OS_Lib;
with version;          use version;
with Ada.Exceptions;   use Ada.Exceptions;
with time_unit_events; use time_unit_events;

with architecture_models; use architecture_models;

procedure schedule_hardcoded_model is

   -- A set of variables required to call the framework
   --
   response_list         : framework_response_table;
   request_list          : framework_request_table;
   a_request             : framework_request;
   a_param               : parameter_ptr;
   sys                   : system;
   project_file_list     : unbounded_string_list;
   project_file_dir_list : unbounded_string_list;

   -- Is the command should run in verbose mode ?
   --
   verbose : Boolean := False;

   -- The duration on which we must compute the scheduling
   --
   period_string : Unbounded_String;
   period        : Natural;
   ok            : Boolean;

   procedure usage is
   begin
      Put_Line
        ("schedule_hardcoded_model is a program which computes a scheduling ");

      New_Line;
      Put_Line
        ("Check Cheddar home page for details :  http://beru.univ-brest.fr/~singhoff/cheddar ");
      New_Line;
      New_Line;
      Put_Line ("Usage : schedule_hardcoded_model  period");
      Put_Line ("   switch can be :");
      Put_Line ("            -u get this help");
      Put_Line ("            -v verbose mode ");
      New_Line;
   end usage;

begin

   copyright ("schedule_hardcoded_model");

   -- Get arguments
   --
   loop
      case GNAT.Command_Line.Getopt ("u v ") is
         when ASCII.NUL =>
            exit;
         when 'v' =>
            verbose := True;
         when 'u' =>
            usage;
            OS_Exit (0);
         when others =>
            usage;
            OS_Exit (0);
      end case;
   end loop;

   loop
      declare
         s : constant String :=
           GNAT.Command_Line.Get_Argument (Do_Expansion => True);

      begin
         exit when s'length = 0;
         period_string := period_string & s;
      end;
   end loop;

   -- Check the period on which we will compute the scheduling
   --
   to_natural (period_string, period, ok);
   if not ok then
      Raise_Exception
        (Constraint_Error'identity,
         "The period to compute the scheduling must be a numeric value");
   end if;

   -- Initialize the Cheddar framework
   --
   call_framework.initialize (False);

   -- Build architecture model
   --
   test1_xml (sys);

   -- Compute the scheduling on the period given by the argument
   --
   initialize (response_list);
   initialize (request_list);
   initialize (a_request);
   a_request.statement    := scheduling_simulation_time_line;
   a_param                := new parameter (integer_parameter);
   a_param.parameter_name := To_Unbounded_String ("period");
   a_param.integer_value  := period;
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

   for i in time_unit_event_type'range loop
      a_param                := new parameter (boolean_parameter);
      a_param.parameter_name := to_lower (i'img);
      a_param.boolean_value  := True;
      add (a_request.param, a_param);
   end loop;

   add (request_list, a_request);
   sequential_framework_request (sys, request_list, response_list);

   for j in 0 .. response_list.nb_entries - 1 loop
      Put_Line (To_String (response_list.entries (j).title));
      Put_Line (To_String (response_list.entries (j).text));
   end loop;

   for i in 0 .. sched.nb_entries - 1 loop
      if sched.entries (i).data.error_msg /= empty_string then
         Put_Line
           ("Error_Msg for processor " &
            To_String (sched.entries (i).item.name) &
            " : " &
            To_String (sched.entries (i).data.error_msg));
      end if;
   end loop;

   write_to_xml_file
     (framework.sched,
      sys,
      To_Unbounded_String ("schedule_hardcoded_result.xml"));

exception

   when others =>
      Put_Line ("Exception name    : " & Exception_Name);
      Put_Line ("Exception message : " & Exception_Message);

end schedule_hardcoded_model;
