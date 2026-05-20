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
--    $Rev: 3546 $
--    $Date: 2020-10-19 08:01:15 +0200 (lun. 19 oct. 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with xml_tag;    use xml_tag;
with Parameters; use Parameters;
with Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;
with Tasks;            use Tasks;
with task_set;         use task_set;
with Offsets;          use Offsets;
with Offsets;          use Offsets.Offsets_Table_Package;
with Offsets.extended; use Offsets.extended;
with tables;
with sets;
with Framework_Config; use Framework_Config;

with Ada.IO_Exceptions;      use Ada.IO_Exceptions;
with GNAT.Current_Exception; use GNAT.Current_Exception;
with Text_IO;                use Text_IO;
with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;
with unbounded_strings;      use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with Parameters;          use Parameters;
with Parameters.extended; use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;

with systems;                  use systems;
with framework;                use framework;
with call_framework;           use call_framework;
with Call_Framework_Interface; use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;

with call_scheduling_framework;         use call_scheduling_framework;
with multiprocessor_services;           use multiprocessor_services;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
with Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with GNAT.Command_Line;
with GNAT.OS_Lib; use GNAT.OS_Lib;
with version;     use version;

with Ada.Exceptions;           use Ada.Exceptions;
with time_unit_events;         use time_unit_events;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with Ada.Directories;          use Ada.Directories;
with scheduler;                use scheduler;

with Ada.Directories;          use Ada.Directories;
with Ada.Text_IO;              use Ada.Text_IO;
with debug;                    use debug;
with Ada.Command_Line;         use Ada.Command_Line;
with Ada.Strings;              use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;
with resource_set;  use resource_set;
with tables;
with mils_analysis; use mils_analysis;
with MILS_Security; use MILS_Security;

with result_parser; use result_parser;
with Paes;          use Paes;

procedure sched_security_analysis is

   -- task_exist      : integer;
   start, finish : Integer;
   sub_str       : Unbounded_String;
   command       : Unbounded_String;

   -- A set of variables required to call the framework
   --
   Response_List                 : framework_response_table;
   Request_List                  : framework_request_table;
   A_Param                       : parameter_ptr;
   A_Request                     : framework_request;
   dir                           : unbounded_string_list;
   str1, str2                    : Unbounded_String;
   Simulation_basics_text        : Unbounded_String;
   Simulation_blocking_time_text : Unbounded_String;

   --     Nb_tasks                       : integer;
   --     Sum_Laxities                   : integer;
   --     Sum_blocking                   : integer;
   --     Nb_preemptions         : integer;
   --     Nb_context_switches            : integer;
   missedDeadlines : Integer := 0;
   --     response_time          : integer;
   --     blocking_time          : integer;
   --     Deadline_i                     : integer;
   security   : Integer;
   Data, line : Unbounded_String;
   dir1       : unbounded_string_list;
   Sys        : system;

   F, F2 : Ada.Text_IO.File_Type;
   --     Min_lax                        : integer;
   --     Max_blocking                   : integer;
   --     laxity_i                       : integer;
   Data2 : Unbounded_String;
   --     Fitness_5                      : float;
   --     sum_response_time              : integer;
   --     max_response_time              : integer;
   Sched_period, task_set_file_name : Unbounded_String;
--nb_processors,j: Integer;

begin

   call_framework.initialize (False);

   -- nb_processors:=Integer'Value(Argument(1));
   Sched_period       := To_Unbounded_String (Argument (1));
   task_set_file_name := To_Unbounded_String (Argument (2));

   initialize (Sys);
   read_from_xml_file (Sys, dir1, task_set_file_name);

   initialize (Response_List);
   initialize (Request_List);
   Initialize (A_Request);
   A_Request.statement    := scheduling_simulation_time_line;
   A_Param                := new parameter (integer_parameter);
   A_Param.parameter_name := To_Unbounded_String ("period");

   A_Param.integer_value := Natural'value (To_String (Sched_period));
   add (A_Request.param, A_Param);
   A_Param                := new parameter (boolean_parameter);
   A_Param.parameter_name := To_Unbounded_String ("schedule_with_offsets");
   A_Param.boolean_value  := True;
   add (A_Request.param, A_Param);
   A_Param                := new parameter (boolean_parameter);
   A_Param.parameter_name :=
     To_Unbounded_String ("schedule_with_precedencies");
   A_Param.boolean_value := False;
   add (A_Request.param, A_Param);
   A_Param                := new parameter (boolean_parameter);
   A_Param.parameter_name := To_Unbounded_String ("schedule_with_resources");
   A_Param.boolean_value  := True;
   add (A_Request.param, A_Param);

--        A_Param               := new Parameter (Boolean_Parameter);
--        A_Param.parameter_name          := To_Unbounded_String ("draw_address_space_time_line");
--        A_Param.boolean_value := False;
--        add (A_Request.param, A_Param);

   A_Param                := new parameter (integer_parameter);
   A_Param.parameter_name := To_Unbounded_String ("seed_value");
   A_Param.integer_value  := 0;
   add (A_Request.param, A_Param);
   add (Request_List, A_Request);
   sequential_framework_request (Sys, Request_List, Response_List);

   initialize (Request_List);
   initialize (Response_List);
   Initialize (A_Request);
   A_Request.statement := scheduling_simulation_basics;
   add (Request_List, A_Request);
   sequential_framework_request (Sys, Request_List, Response_List);
   sequential_framework_request (Sys, Request_List, Response_List);

   Simulation_basics_text := Response_List.entries (1).text;
   --  Extracting  the decision about the schedulability From the simulation

   str1 := Simulation_basics_text;
   put_debug ("=================SCHEDULING RESULTS===================");
--   Put_Debug(To_String(str1));
   put_debug ("======================================================");
   Append (Data2, To_String (Simulation_basics_text));

   if (Index (str1, "- No deadline missed ") /= 0) then
      Append (Data, "schedulability : true" & ASCII.LF);

   else
      Append (Data, "schedulability : false" & ASCII.LF);

   end if;

   --     j:=0;
   --     for i in 1..nb_processors loop
   --         j:=j+1;
   --        Append(Simulation_basics_text, "Scheduling simulation, Processor " & To_String(Suppress_Space(To_Unbounded_String("processor"& j'Img)))& ASCII.LF);
   --        Append(Simulation_basics_text, To_String (Response_List.entries (Framework_Response_Package.table_range(nb_processors-i+1)).text)& ASCII.LF);
   --
   --        Put_Line("table_range: " & Framework_Response_Package.table_range(nb_processors-i+1)'Img);
   --        missedDeadlines := missedDeadlines+parse_task_response_time( sys, Suppress_Space(To_Unbounded_String("processor"& j'Img)), Response_List.entries (Framework_Response_Package.table_range(nb_processors-i+1)).text);
   --
   --     end loop;
   --     str1 := Simulation_basics_text;
   -- Put(Simulation_basics_text);

   missedDeadlines :=
     parse_task_response_time
       (Sys,
        suppress_space (To_Unbounded_String ("processor1")),
        str1);
   Append (Data, "f12 = missedDeadlines " & missedDeadlines'img & ASCII.LF);
   Put_Line ("missedDeadlines " & missedDeadlines'img);
   security := bell_lapadula (Sys);
   Put_Line ("bell_lapadula " & security'img);
   Append (Data, "f13 = bellViolations" & security'img & ASCII.LF);
   security := biba (Sys);
   Put_Line ("biba " & security'img);
   Append (Data, "f14 = bibaViolations" & security'img & ASCII.LF);

   put_debug ("================Data=============");
   put_debug (To_String (Data));
   put_debug ("=================================");
   -- Laurent //
   start :=
     Index (task_set_file_name, "candidate_solution") +
     Length (To_Unbounded_String ("candidate_solution"));
   finish  := Index (task_set_file_name, ".xmlv3") - 1;
   sub_str :=
     Unbounded_Slice (task_set_file_name, start, finish); -- the eidx string

   -- This file contains, the result of the schedulability and security
   -- of the candidate solution as well as values of
   -- potential fitness functions

   command := "Output" & sub_str & ".txt";
   Create (F, Ada.Text_IO.Out_File, To_String (command));
   Unbounded_IO.Put_Line (F, Data);
   Close (F);

   ---- This file contains the result of scheduling
   ---- simulation of the candidate solution

   command := To_Unbounded_String ("Output2" & To_String (sub_str) & ".txt");
   Create (F2, Ada.Text_IO.Out_File, To_String (command));
   Unbounded_IO.Put_Line (F2, Data2);
   Close (F2);

   -- Deleting the file "candidate_solution eidx.xmlv3"
   --
   --     Open (File => F2,
   --           Mode => Ada.Text_IO.In_File,
   --           Name => To_string(task_set_file_name));
   --     Ada.text_IO.Delete(File => F2);

end sched_security_analysis;
