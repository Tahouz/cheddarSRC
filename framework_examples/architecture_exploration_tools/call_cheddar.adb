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
with Ada.Command_Line;         use Ada.Command_Line;
with Ada.Strings;              use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;
with resource_set; use resource_set;

procedure Call_Cheddar is

   task_exist    : Integer;
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

   Nb_tasks            : Integer;
   Sum_Laxities        : Integer;
   Sum_blocking        : Integer;
   Nb_preemptions      : Integer;
   Nb_context_switches : Integer;
   response_time       : Integer;
   blocking_time       : Integer;
   Deadline_i          : Integer;

   task_set_file_name       : Unbounded_String;
   Data, line, sched_period : Unbounded_String;
   dir1                     : unbounded_string_list;
   Sys                      : system;

   F, F2             : Ada.Text_IO.File_Type;
   Min_lax           : Integer;
   Max_blocking      : Integer;
   laxity_i          : Integer;
   Data2             : Unbounded_String;
   Fitness_5         : Float;
   sum_response_time : Integer;
   max_response_time : Integer;

begin

   call_framework.initialize (False);

   sched_period       := To_Unbounded_String (Argument (1));
   task_set_file_name := To_Unbounded_String (Argument (2));

   initialize (Sys);
   read_from_xml_file (Sys, dir1, task_set_file_name);

   initialize (Response_List);
   initialize (Request_List);
   Initialize (A_Request);
   A_Request.statement    := scheduling_simulation_time_line;
   A_Param                := new parameter (integer_parameter);
   A_Param.parameter_name := To_Unbounded_String ("period");

   A_Param.integer_value := Integer'value (To_String (sched_period));
   add (A_Request.param, A_Param);
   A_Param                := new parameter (boolean_parameter);
   A_Param.parameter_name := To_Unbounded_String ("schedule_with_offsets");
   A_Param.boolean_value  := True;
   add (A_Request.param, A_Param);
   A_Param                := new parameter (boolean_parameter);
   A_Param.parameter_name :=
     To_Unbounded_String ("schedule_with_precedencies");
   A_Param.boolean_value := True;
   add (A_Request.param, A_Param);
   A_Param                := new parameter (boolean_parameter);
   A_Param.parameter_name := To_Unbounded_String ("schedule_with_resources");
   A_Param.boolean_value  := True;
   add (A_Request.param, A_Param);
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

   -- Compute the blocking-time of tasks
   -- from simulation
   initialize (Request_List);
   initialize (A_Request.param);
   initialize (Response_List);
   Initialize (A_Request);

   A_Param                := new parameter (boolean_parameter);
   A_Param.parameter_name := To_Unbounded_String ("worst_case");
   A_Param.boolean_value  := True;
   add (A_Request.param, A_Param);

   A_Param                := new parameter (boolean_parameter);
   A_Param.parameter_name := To_Unbounded_String ("best_case");
   A_Param.boolean_value  := False;
   add (A_Request.param, A_Param);

   A_Param                := new parameter (boolean_parameter);
   A_Param.parameter_name := To_Unbounded_String ("average_case");
   A_Param.boolean_value  := False;
   add (A_Request.param, A_Param);

   A_Request.statement := scheduling_simulation_blocking_time;
   add (Request_List, A_Request);

   sequential_framework_request (Sys, Request_List, Response_List);

   Simulation_basics_text        := Response_List.entries (1).text;
   Simulation_blocking_time_text := Response_List.entries (0).text;

   -- Extracting the decision about the schedulability
   -- From the simulation

   str1 := Simulation_basics_text;
   Put_Line
     ("=================SCHEDULING SIMULATION TEXT========================");
   Put (str1);
   Put_Line ("=============================================");

   Append (Data2, To_String (Simulation_basics_text));

   task_exist := Index (str1, "/worst");

   while task_exist /= 0 loop
      Put_Line ("task_exist" & task_exist'img);

      str1 :=
        Unbounded_Slice
          (str1,
           Index (str1, "/worst") + Length (To_Unbounded_String ("/worst")),
           Length (str1));

      task_exist := Index (str1, "/worst");

   end loop;

   sub_str := Unbounded_Slice (str1, Index (str1, "-"), 8);

   Append (Data2, To_String (sub_str) & ASCII.LF);

   if sub_str = To_Unbounded_String ("- No d") then

      -- In this case, the task set is schedulable
      -- Then we exctract from the results of the simulation,
      -- values of fitness functions of the candidate solution
      -- i.e : context switches, number of preemptions, laxity of tasks
      -- and blocking-time of tasks

      start :=
        Index (Simulation_basics_text, "- Number of context switches :  ") +
        Length (To_Unbounded_String ("- Number of context switches :  "));

      finish :=
        start +
        Index
          (Unbounded_Slice
             (Simulation_basics_text,
              start,
              Length (Simulation_basics_text)),
           ASCII.LF & "") -
        2;

      Nb_context_switches :=
        Integer'value
          (To_String
             (Unbounded_Slice (Simulation_basics_text, start, finish)));

      start :=
        Index (Simulation_basics_text, "- Number of preemptions :  ") +
        Length (To_Unbounded_String ("- Number of preemptions :  "));

      finish :=
        start +
        Index
          (Unbounded_Slice
             (Simulation_basics_text,
              start,
              Length (Simulation_basics_text)),
           ASCII.LF & "") -
        2;

      Nb_preemptions :=
        Integer'value
          (To_String
             (Unbounded_Slice (Simulation_basics_text, start, finish)));

      Nb_tasks :=
        Integer
          (get_number_of_task_from_processor
             (Sys.tasks,
              To_Unbounded_String ("processor1")));

      Sum_Laxities      := 0;
      Sum_blocking      := 0;
      Fitness_5         := 0.0;
      sum_response_time := 0;
      str1              := Simulation_basics_text;
      str2              := Simulation_blocking_time_text;

      for i in 1 .. Nb_tasks loop

         start := Index (str1, "=> ") + Length (To_Unbounded_String ("=> "));

         finish := Index (str1, "/worst") - 1;

         response_time :=
           Integer'value (To_String (Unbounded_Slice (str1, start, finish)));

         start := Index (str2, "=> ") + Length (To_Unbounded_String ("=> "));

         finish := Index (str2, "/worst") - 1;

         blocking_time :=
           Integer'value (To_String (Unbounded_Slice (str2, start, finish)));

         Deadline_i :=
           get
             (my_tasks  => Sys.tasks,
              task_name =>
                suppress_space (To_Unbounded_String ("Task" & i'img)),
              param_name => deadline);

         laxity_i := Deadline_i - response_time;

         if i = 1 then
            Min_lax           := laxity_i;
            Max_blocking      := blocking_time;
            max_response_time := response_time;
         else
            if laxity_i < Min_lax then
               Min_lax := laxity_i;
            end if;

            if blocking_time > Max_blocking then
               Max_blocking := blocking_time;
            end if;

            if response_time > max_response_time then
               max_response_time := response_time;
            end if;
         end if;

         Sum_Laxities      := Sum_Laxities + (Deadline_i - response_time);
         Sum_blocking      := Sum_blocking + blocking_time;
         Fitness_5 := Fitness_5 + Float (response_time) / Float (Deadline_i);
         sum_response_time := sum_response_time + response_time;

         str1 :=
           Unbounded_Slice
             (str1,
              Index (str1, "/worst") + Length (To_Unbounded_String ("/worst")),
              Length (str1));
         str2 :=
           Unbounded_Slice
             (str2,
              Index (str2, "/worst") + Length (To_Unbounded_String ("/worst")),
              Length (str2));
      end loop;

      Append (Data, "schedulability : true" & ASCII.LF);
      Append (Data, "f1 = preemptions = " & Nb_preemptions'img & ASCII.LF);
      Append
        (Data,
         "f2 = contextSwitches = " & Nb_context_switches'img & ASCII.LF);
      Append (Data, "f3 = tasks = " & Nb_tasks'img & ASCII.LF);
      Append
        (Data,
         "f4 = sum(Li) = sum(Di-Ri) = " & Sum_Laxities'img & ASCII.LF);
      Append (Data, "f5 = sum(Ri/Di) = " & Fitness_5'img & ASCII.LF);
      Append (Data, "f6 = min(Li) = " & Min_lax'img & ASCII.LF);
      Append (Data, "f7 = sum(Ri) = " & sum_response_time'img & ASCII.LF);
      Append (Data, "f8 = max(Ri) = " & max_response_time'img & ASCII.LF);
      Append (Data, "f9 = sum(Bi) = " & Sum_blocking'img & ASCII.LF);
      Append (Data, "f10 = max(Bi) = " & Max_blocking'img & ASCII.LF);
      Append
        (Data,
         "f11 = sharedResources = " &
         get_number_of_resource_from_processor
           (Sys.resources,
            To_Unbounded_String ("processor1"))'
           img &
         ASCII.LF);
   else
      Append (Data, "schedulability : false" & ASCII.LF);

   end if;

   -- Laurent //
   start :=
     Index (task_set_file_name, "candidate_solution") +
     Length (To_Unbounded_String ("candidate_solution"));
   finish  := Index (task_set_file_name, ".xmlv3") - 1;
   sub_str :=
     Unbounded_Slice (task_set_file_name, start, finish); -- the eidx string

   -- This file contains, the result of the schedulability
   -- of the candidate solution as well as values of
   -- potential fitness functions

   command := "Output" & sub_str & ".txt";
   Create (F, Ada.Text_IO.Out_File, To_String (command));
   Unbounded_IO.Put_Line (F, Data);
   Close (F);

   ---- This file contains the result of scheduling
   ---- simulation of the candidate solution

   --command := To_Unbounded_String("Output2" & To_String(sub_str) & ".txt");
   --Create(F2,Ada.Text_IO.Out_File,To_String(command));
   --Unbounded_IO.Put_Line(F2, Data2);
   --Close(F2);

   -- Deleting the file "candidate_solution eidx.xmlv3"
   --
   Open
     (File => F2,
      Mode => Ada.Text_IO.In_File,
      Name => To_String (task_set_file_name));
   Ada.Text_IO.Delete (File => F2);

end Call_Cheddar;
