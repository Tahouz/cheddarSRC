
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

with Xml_Tag;                  use Xml_Tag;
with Parameters;               use Parameters;
with Parameters.extended;
use  Parameters.Framework_Parameters_Table_Package;
with Tasks;			use Tasks;
with Task_Set;                  use Task_Set;
with Offsets;			use Offsets;
with Offsets;			use Offsets.Offsets_Table_Package;
with Offsets.extended;		use Offsets.extended;
with Tables;
with sets;
with framework_config;          use framework_config;

with Ada.IO_Exceptions;                 use Ada.IO_Exceptions;
with GNAT.Current_Exception;            use GNAT.Current_Exception;
with Text_IO;                           use Text_IO;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with Parameters;                        use Parameters;
with Parameters.extended;               use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;
with Systems;                           use Systems;
with Framework;                    	use Framework;
with Call_Framework;                    use Call_Framework;
with Call_Framework_Interface;          use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with Call_Scheduling_Framework;         use Call_Scheduling_Framework;
with Multiprocessor_Services;           use Multiprocessor_Services;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
with Multiprocessor_Services_Interface;	use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with GNAT.Command_Line;
with GNAT.OS_Lib;                       use GNAT.OS_Lib;
with Version;                           use Version;

with Ada.Exceptions;                    use Ada.Exceptions;
with Time_Unit_Events;                  use Time_Unit_Events;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Directories; 			use Ada.Directories;
with Scheduler;				use Scheduler;

with Ada.Directories; use Ada.Directories;
with Ada.text_IO; use Ada.text_IO;
with Ada.Command_Line; use Ada.Command_Line;
with Ada.Strings; use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with feasibility_test.feasibility_interval; use feasibility_test.feasibility_interval;
with resource_set; use resource_set;

procedure Call_Cheddar is

   task_exist      : integer;
   start,finish    : integer;
   sub_str         : unbounded_string;
   command         : unbounded_String;

   
   -- A set of variables required to call the framework
   --
   Response_List   		 : Framework_Response_Table;
   Request_List    		 : Framework_Request_Table;
   A_Param             	 	 : Parameter_Ptr;
   A_Request      	 	 : Framework_Request;
   dir            	 	 : unbounded_string_list;
   str1, str2         	 	 : unbounded_string;   
   Simulation_basics_text 	 : unbounded_string;  
   Simulation_blocking_time_text : unbounded_string;

   Nb_tasks              	 : integer;
   Sum_Laxities          	 : integer;
   Sum_blocking          	 : integer;
   Nb_preemptions       	 : integer;
   Nb_context_switches 		 : integer;
   response_time        	 : integer;
   blocking_time        	 : integer;
   Deadline_i            	 : integer;

   task_set_file_name     	 : unbounded_string;
   Data,line,sched_period	 : unbounded_string;
   dir1                  	 : unbounded_string_list;
   Sys                   	 : system;

   F,F2                  	 : Ada.Text_IO.File_Type;
   Min_lax               	 : integer;
   Max_blocking              	 : integer;
   laxity_i              	 : integer;
   Data2                 	 : unbounded_string;        
   Fitness_5			 : float;
   sum_response_time		 : integer;
   max_response_time		 : integer;

begin

   Call_Framework.initialize (False);

   
   Sched_period  := To_Unbounded_String(Argument(1));
   task_set_file_name := To_Unbounded_String(Argument(2));

   initialize(Sys);
   Read_From_Xml_File (Sys, dir1, task_set_file_name);

   
   initialize (Response_List);
   initialize (Request_List);
   Initialize (A_Request);
   A_Request.statement   := Scheduling_Simulation_Time_Line;
   A_Param               := new Parameter (Integer_Parameter);
   A_Param.parameter_name          := To_Unbounded_String ("period");

   A_Param.integer_value := Integer'Value(To_String(Sched_period));
   add (A_Request.param, A_Param);
   A_Param               := new Parameter (Boolean_Parameter);
   A_Param.parameter_name          := To_Unbounded_String ("schedule_with_offsets");
   A_Param.boolean_value := True;
   add (A_Request.param, A_Param);
   A_Param               := new Parameter (Boolean_Parameter);
   A_Param.parameter_name          :=
      To_Unbounded_String ("schedule_with_precedencies");
   A_Param.boolean_value := True;
   add (A_Request.param, A_Param);
   A_Param               := new Parameter (Boolean_Parameter);
   A_Param.parameter_name          := To_Unbounded_String ("schedule_with_resources");
   A_Param.boolean_value := True;
   add (A_Request.param, A_Param);
   A_Param               := new Parameter (Integer_Parameter);
   A_Param.parameter_name          := To_Unbounded_String ("seed_value");
   A_Param.integer_value := 0;
   add (A_Request.param, A_Param);
   add (Request_List, A_Request);
   Sequential_Framework_Request (Sys, Request_List, Response_List);
      
   initialize (Request_List);
   initialize (Response_List);
   Initialize (A_Request);
   A_Request.statement := Scheduling_Simulation_Basics;
   add (Request_List, A_Request);
   Sequential_Framework_Request (Sys, Request_List, Response_List);
   Sequential_Framework_Request (Sys, Request_List, Response_List);

   -- Compute the blocking-time of tasks 
   -- from simulation 
   initialize (Request_List);
   Initialize (A_Request.param);
   initialize (Response_List);
   Initialize (A_Request);

   A_Param      := new Parameter (Boolean_Parameter);
   A_Param.parameter_name := To_Unbounded_String ("worst_case");
   A_Param.boolean_value := True;
   add (A_Request.param, A_Param);

   A_Param      := new Parameter (Boolean_Parameter);
   A_Param.parameter_name := To_Unbounded_String ("best_case");
   A_Param.boolean_value := False;
   add (A_Request.param, A_Param);

   A_Param      := new Parameter (Boolean_Parameter);
   A_Param.parameter_name := To_Unbounded_String ("average_case");
   A_Param.boolean_value := False;
   add (A_Request.param, A_Param);

   A_Request.statement := Scheduling_Simulation_Blocking_Time;
   add (Request_List, A_Request);

   Sequential_Framework_Request (Sys, Request_List, Response_List);
  
   
   Simulation_basics_text := Response_List.entries (1).text;
   Simulation_blocking_time_text := Response_List.entries (0).text;

   -- Extracting the decision about the schedulability
   -- From the simulation

   str1 := Simulation_basics_text;
   
   Append (Data2, To_String(Simulation_basics_text) & To_String(Simulation_blocking_time_text));
   
   
   task_exist := index (str1, "/worst");    

   while task_exist /= 0 loop

     str1 := Unbounded_Slice(
             str1,
             index (str1, "/worst") + length(To_Unbounded_String("/worst")),
             length(str1));

     task_exist := index (str1, "/worst");
   
   end loop;

  
   sub_str := Unbounded_Slice(str1, index (str1, "-"), 8);
  
   Append (Data2, To_String(sub_str) & ASCII.LF);

   if sub_str = To_Unbounded_String("- No d") then

      -- In this case, the task set is schedulable
      -- Then we exctract from the results of the simulation,
      -- values of fitness functions of the candidate solution
      -- i.e : context switches, number of preemptions, laxity of tasks
      -- and blocking-time of tasks

      start := index (Simulation_basics_text, "- Number of context switches :  ") 
                + length(To_Unbounded_String("- Number of context switches :  "));

      finish := start + index (Unbounded_Slice(Simulation_basics_text, start, length(Simulation_basics_text)), ASCII.LF&"") - 2;

      Nb_context_switches := integer'Value
                              (to_string(Unbounded_Slice(Simulation_basics_text,start,finish)));

      

      start := index (Simulation_basics_text, "- Number of preemptions :  ") 
                + length(To_Unbounded_String("- Number of preemptions :  "));

      finish := start + index (Unbounded_Slice(Simulation_basics_text, start, length(Simulation_basics_text)), ASCII.LF&"") - 2;
    

      Nb_preemptions := integer'Value
                              (to_string(Unbounded_Slice(Simulation_basics_text,start,finish)));

      Nb_tasks  := Integer (Get_Number_Of_Task_From_Processor (sys.Tasks, To_Unbounded_String("processor1")));
      
      Sum_Laxities := 0;
      Sum_blocking := 0;
      Fitness_5 := 0.0;
      sum_response_time := 0;
      str1 := Simulation_basics_text;
      str2 := Simulation_blocking_time_text;

      for i in 1..Nb_tasks loop

          start := index (str1, "=> ") + length(To_Unbounded_String("=> "));
     
          finish := index (str1, "/worst") - 1;

          response_time := integer'Value (to_string(Unbounded_Slice(str1,start,finish)));

          start := index (str2, "=> ") + length(To_Unbounded_String("=> "));
     
          finish := index (str2, "/worst") - 1;

          blocking_time := integer'Value (to_string(Unbounded_Slice(str2,start,finish)));
 
          Deadline_i := Get(My_Tasks     => sys.Tasks, 
                            Task_Name    => Suppress_Space (To_Unbounded_String ("Task" & i'Img)),
                            Param_Name   => Deadline);

          laxity_i := Deadline_i - response_time; 

          if i = 1 then
               Min_lax := laxity_i;
               Max_blocking := blocking_time;
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

          Sum_Laxities := Sum_Laxities + (Deadline_i - response_time);
          Sum_blocking := Sum_blocking + blocking_time;
          Fitness_5 := Fitness_5 + float(response_time) / Float(Deadline_i);
          sum_response_time := sum_response_time + response_time;

          str1 := Unbounded_Slice(str1,
                                  index (str1, "/worst") + length(To_Unbounded_String("/worst")),
                                  length(str1));
          str2 := Unbounded_Slice(str2,
                                  index (str2, "/worst") + length(To_Unbounded_String("/worst")),
                                  length(str2));
      end loop;
     
      Append (Data, "schedulability : true" & ASCII.LF);
      Append (Data, "f1 = preemptions = " & Nb_preemptions'Img & ASCII.LF);
      Append (Data, "f2 = contextSwitches = " & Nb_context_switches'Img & ASCII.LF);
      Append (Data, "f3 = tasks = " & Nb_tasks'Img & ASCII.LF);
      Append (Data, "f4 = sum(Li) = sum(Di-Ri) = " & Sum_laxities'Img & ASCII.LF);
      Append (Data, "f5 = sum(Ri/Di) = " & fitness_5'Img & ASCII.LF);
      Append (Data, "f6 = min(Li) = " & Min_lax'Img & ASCII.LF);
      Append (Data, "f7 = sum(Ri) = " & Sum_response_time'Img & ASCII.LF);
      Append (Data, "f8 = max(Ri) = " & max_response_time'Img & ASCII.LF);
      Append (Data, "f9 = sum(Bi) = " & Sum_blocking'Img & ASCII.LF);
      Append (Data, "f10 = max(Bi) = " &  Max_blocking'Img & ASCII.LF);
      Append (Data, "f11 = sharedResources = " & Get_Number_Of_Resource_From_Processor (sys.Resources, To_Unbounded_String("processor1"))'Img
                    & ASCII.LF);
   else

      Append (Data, "schedulability : false" & ASCII.LF);
   
   end if;


   start := index(task_set_file_name, "candidate_solution") + length(To_Unbounded_String("candidate_solution"));
   finish := index (task_set_file_name, ".xmlv3") - 1;
   sub_str := Unbounded_Slice(task_set_file_name,start,finish); -- the eidx string

   -- This file contains, the result of the schedulability
   -- of the candidate solution as well as values of 
   -- potential fitness functions

   command := "Output" & sub_str & ".txt";
   Create(F, Ada.Text_IO.Out_File, To_String(command));
   Unbounded_IO.Put_Line(F, Data);
   Close(F);

   ---- This file contains the result of scheduling
   ---- simulation of the candidate solution

   -- Deleting the file "candidate_solution eidx.xmlv3"
   -- 
   Open (File => F2,
         Mode => Ada.Text_IO.In_File,
         Name => To_string(task_set_file_name));
   Ada.text_IO.Delete(File => F2);

end Call_Cheddar;


