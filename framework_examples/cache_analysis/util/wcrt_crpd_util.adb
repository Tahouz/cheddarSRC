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
--    $Rev: 4589 $
--    $Date: 2023-09-29 16:02:19 +0200 (ven., 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Text_IO;                   	use Text_IO;
with Ada.Text_IO, Ada.Integer_Text_IO;	use Ada.Text_IO, Ada.Integer_Text_IO;
with Ada.Float_Text_IO;			use Ada.Float_Text_IO;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Strings.Unbounded; 		use Ada.Strings.Unbounded;
with Systems;               		use Systems;
with Caches;                		use Caches;
with Cache_Set;             		use Cache_Set;
with CFG_Nodes; 			use CFG_Nodes.CFG_Nodes_Table_Package;
with CFG_Nodes;				use CFG_Nodes;
with CFG_Nodes_Builder; 		use CFG_Nodes_Builder;
with initialize_framework; 		use initialize_framework;
with CFG_Set;				use CFG_Set;
with CFG_Edges; 			use CFG_Edges;
with CFG_Node_Set; 			use CFG_Node_Set;
with CFG_Edge_Set;			use CFG_Edge_Set;
with unbounded_strings; 		use unbounded_strings;
with unbounded_strings; 		use unbounded_strings.strings_table_package;
with unbounded_strings;			use unbounded_strings.unbounded_string_list_package;
with Call_Framework; 			use Call_Framework;
with Integer_Arrays; 			use Integer_Arrays;
with Basic_Block_Analysis; 		use Basic_Block_Analysis;
with CFGs; 				use CFGs;
with CFG_Node_Set.Basic_Block_Set;	use CFG_Node_Set.Basic_Block_Set;
with Basic_Blocks; 			use Basic_Blocks;
with CFG_Nodes.Extended; 		use CFG_Nodes.Extended;
with Ada.Integer_Text_IO;       	use Ada.Integer_Text_IO;
with Call_Cache_Framework; 		use Call_Cache_Framework;
with Processor_Set; 			use Processor_Set;
with Scheduler_Interface; 		use Scheduler_Interface;
with Core_Units; 			use Core_Units;
with Address_Space_Set; 		use Address_Space_Set;
with Ada.IO_Exceptions;                 use Ada.IO_Exceptions;
with GNAT.Current_Exception;            use GNAT.Current_Exception;
with Text_IO;                           use Text_IO;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with unbounded_strings;                 use unbounded_strings;
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
with architecture_models; 		use architecture_models;
with Ada.Directories; 			use Ada.Directories;
with Scheduler;				use Scheduler;
with architecture_factory;              use architecture_factory;
with Debug;				use Debug;
with Scheduler.Fixed_Priority.Rm; 	use Scheduler.Fixed_Priority.Rm;
with Scheduler.Dynamic_Priority.Edf;	use Scheduler.Dynamic_Priority.Edf;
with Scheduler.Fixed_Priority.Hpf; 	use Scheduler.Fixed_Priority.Hpf;
with Framework_Config; 			use Framework_Config;
with Ada.Calendar; 			use Ada.Calendar;
with Ada.Calendar.Formatting;		use Ada.Calendar.Formatting;
with Cache_Utility; 			use Cache_Utility;
with Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
with Ada.Numerics.Float_Random;
with Caches;				use Caches.Cache_Blocks_Table_Package;
with Cache_Block_Set;			use Cache_Block_Set;
with Scheduling_Analysis; 		use Scheduling_Analysis;
with Cache_Access_Profile_Set; 		use Cache_Access_Profile_Set;
with Time_Unit_Events;			use Time_Unit_Events.Time_Unit_Package;
with test_case_generator;		use test_case_generator;
with scheduling_simulation_util;	use scheduling_simulation_util;
with Message_Set; 			use Message_Set;
with Feasibility_Test; 			use Feasibility_Test;
with feasibility_test.periodic_task_worst_case_response_time_fixed_priority;
use feasibility_test.periodic_task_worst_case_response_time_fixed_priority;
with Scheduling_Analysis;		use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with GNAT.String_Split; 		use GNAT.String_Split;

package body wcrt_crpd_util is

   procedure Test_WCRT_CRPD
   is
      my_scheduler 		: Hpf_Scheduler;
      my_tasks			: Tasks_Set;
      processor_name 		: Unbounded_String;
      msg 			: Unbounded_String;
      --response_time 		: Response_Time_Table;
      CRPD_Computation_Approach : CRPD_Computation_Approach_Type := ECB_Union_Multiset;
      Block_Reload_Time 	: Natural := 1;
      My_CAPs 			: Cache_Access_Profiles_Set;

      cap_1 			: Cache_Access_Profile_Ptr;
      cap_2 			: Cache_Access_Profile_Ptr;
      cap_3 			: Cache_Access_Profile_Ptr;

      a_cache_block	 	: Cache_Block_Ptr;
      a_cache_block_tbl	 	: Cache_Blocks_Table;

      response_time		: Response_Time_Table;
   begin
      Set_Initialize;

      for i in 0..3 loop
         a_cache_block := new Cache_Block;
         a_cache_block.cache_block_number := i+1;
         Add(a_cache_block_tbl,a_cache_block);
      end loop;

      cap_1 := new Cache_Access_Profile;
      cap_1.name := To_Unbounded_String("CAP_1");
      Add(cap_1.ECBs, a_cache_block_tbl.Entries(0));
      Add(cap_1.ECBs, a_cache_block_tbl.Entries(1));
      Add(cap_1.ECBs, a_cache_block_tbl.Entries(2));

      cap_2 := new Cache_Access_Profile;
      cap_2.name := To_Unbounded_String("CAP_2");
      Add(cap_2.UCBs, a_cache_block_tbl.Entries(2));
      --
      Add(cap_2.ECBs, a_cache_block_tbl.Entries(2));
      Add(cap_2.ECBs, a_cache_block_tbl.Entries(3));

      cap_3 := new Cache_Access_Profile;
      cap_3.name := To_Unbounded_String("CAP_3");
      Add(cap_3.UCBs, a_cache_block_tbl.Entries(0));
      Add(cap_3.UCBs, a_cache_block_tbl.Entries(1));
      Add(cap_3.UCBs, a_cache_block_tbl.Entries(2));
      Add(cap_3.UCBs, a_cache_block_tbl.Entries(3));
      --
      Add(cap_3.ECBs, a_cache_block_tbl.Entries(0));
      Add(cap_3.ECBs, a_cache_block_tbl.Entries(1));
      Add(cap_3.ECBs, a_cache_block_tbl.Entries(2));
      Add(cap_3.ECBs, a_cache_block_tbl.Entries(3));

      Add(My_CAPs,cap_1);
      Add(My_CAPs,cap_2);
      Add(My_CAPs,cap_3);

      Add_Task(My_Tasks                  => my_tasks,
               Name                      => To_Unbounded_String("Task_1"),
               Cpu_Name                  => To_Unbounded_String("CPU_A"),
               Address_Space_Name        => To_Unbounded_String("ADDR_A"),
               Task_Type                 => Periodic_Type,
               Start_Time                => 0,
               Capacity                  => 1,
               Period                    => 40,
               Deadline                  => 40,
               Jitter                    => 0,
               Blocking_Time             => 0,
               Priority                  => 3,
               Criticality               => 0,
               Policy                    => Sched_Fifo,
               Cache_Access_Profile_Name => To_Unbounded_String("CAP_1"));

      Add_Task(My_Tasks                  => my_tasks,
               Name                      => To_Unbounded_String("Task_2"),
               Cpu_Name                  => To_Unbounded_String("CPU_A"),
               Address_Space_Name        => To_Unbounded_String("ADDR_A"),
               Task_Type                 => Periodic_Type,
               Start_Time                => 0,
               Capacity                  => 2,
               Period                    => 40,
               Deadline                  => 40,
               Jitter                    => 0,
               Blocking_Time             => 0,
               Priority                  => 2,
               Criticality               => 0,
               Policy                    => Sched_Fifo,
               Cache_Access_Profile_Name => To_Unbounded_String("CAP_2"));

      Add_Task(My_Tasks                  => my_tasks,
               Name                      => To_Unbounded_String("Task_3"),
               Cpu_Name                  => To_Unbounded_String("CPU_A"),
               Address_Space_Name        => To_Unbounded_String("ADDR_A"),
               Task_Type                 => Periodic_Type,
               Start_Time                => 0,
               Capacity                  => 2,
               Period                    => 40,
               Deadline                  => 40,
               Jitter                    => 0,
               Blocking_Time             => 0,
               Priority                  => 1,
               Criticality               => 0,
               Policy                    => Sched_Fifo,
               Cache_Access_Profile_Name => To_Unbounded_String("CAP_3"));

      periodic_task_worst_case_response_time_fixed_priority.Compute_Response_Time
        (My_Scheduler              => my_scheduler,
         My_Tasks                  => my_tasks,
         Processor_Name            => To_Unbounded_String("CPU_A"),
         Msg                       => msg,
         Response_Time             => response_time,
         With_CRPD                 => True,
         CRPD_Computation_Approach => CRPD_Computation_Approach,
         Block_Reload_Time         => Block_Reload_Time,
         My_Cache_Access_Profiles  => My_CAPs);

      for i in 0..Response_Time.nb_entries-1 loop
         Put_Line(Integer(Response_Time.entries(i).data)'Img);
      end loop;

   end Test_WCRT_CRPD;

   procedure Test_Feasibility_Test_Computation_Time
     (file_name                 : in Unbounded_String;
      N                		: in Integer	:= 10;
      PU 	       		: in Float	:= 0.70;
      CU 	       		: in Float	:= 5.0;
      CS       	       		: in Integer	:= 256;
      RF	       		: in Float	:= 0.3;
      H 			: in Integer    := 100000;
      With_Harmonic_Tasks 	: in Boolean)
   is
      sys 		      : System;
      a_Sys                   : System;
      Project_File_Dir_List   : unbounded_string_list;

      a_core : Core_Unit_Ptr;

      Result : Unbounded_String := empty_string;
      F: Ada.Text_IO.File_Type;

      i_iterator : Tasks_Iterator;
      j_iterator : Tasks_Iterator;
      j1_iterator : Tasks_Iterator;
      ipriority : Natural := 0;

      Year,Month,Day : INTEGER;
      Start,Ends,Duration  : DAY_DURATION;
      Time_And_Date  : TIME;

      my_scheduler 		: Rm_Scheduler;
      msg 			: Unbounded_String;
      response_time 		: Response_Time_Table;
      CRPD_Computation_Approach : CRPD_Computation_Approach_Type := ECB_Union_Multiset;
      Block_Reload_Time 	: Natural := 1;

      --sched_result : Natural;
      --hyper_period : Natural;
   begin
      Set_Initialize;

      --This function can generate and return a system.
      --In this test, we do not use the sys returned because
      --we are testing the XML_Parser.
      if(With_Harmonic_Tasks) then
         generate_system_with_harmonic_tasks_and_CAP(file_name => file_name,
                                                     N         => N,
                                                     PU        => PU,
                                                     CU        => CU,
                                                     CS        => CS,
                                                     RF        => RF,
                                                     a_system  => sys);
      else
         generate_system_with_periodic_tasks_and_CAP(file_name 	=> file_name,
                                                     Min_Period => 10,
                                                     Max_Period => 5000,
                                                     N         	=> N,
                                                     PU        	=> PU,
                                                     CU       	=> CU,
                                                     CS        	=> CS,
                                                     RF        	=> RF,
                                                     a_system  	=> sys);
      end if;

      --Initilize the string
      Result := Result & file_name & ",";


      -----------------------------------------
      --
      -----------------------------------------
      Initialize(a_Sys);
      Systems.Read_From_Xml_File (a_Sys,
                                  Project_File_Dir_List,
                                  file_name);

      a_core := Search_core_unit(a_Sys.Core_units,To_Unbounded_String("Core_01"));
      a_core.scheduling.scheduler_type := Rate_Monotonic_Protocol;

      Put_Line(Get_Standard_Line);
      Time_And_Date := Clock;
      Split(Time_And_Date, Year, Month, Day, Start);

      periodic_task_worst_case_response_time_fixed_priority.Compute_Response_Time
        (My_Scheduler              => my_scheduler,
         My_Tasks                  => a_Sys.Tasks,
         Processor_Name            => To_Unbounded_String("CPU_01"),
         Msg                       => msg,
         Response_Time             => response_time,
         With_CRPD                 => True,
         CRPD_Computation_Approach => CRPD_Computation_Approach,
         Block_Reload_Time         => Block_Reload_Time,
         My_Cache_Access_Profiles  => a_Sys.Cache_Access_Profiles);

      for i in 0..Response_Time.nb_entries-1 loop
         Put_Line(Integer(Response_Time.entries(i).data)'Img);
      end loop;
      --compute_scheduling_of_tasks_from_ada_sys_model(hyper_period,a_Sys, To_Unbounded_String("RM1.xml"),TRUE,sched_result);
      -----------------------------------------
      -- WRITE FILE
      -----------------------------------------
      Time_And_Date := Clock;
      Split(Time_And_Date, Year, Month, Day, Ends);
      Duration:= Ends - Start;
      Put_Line("Scheduling Simulation: " & Duration'Img);
      Put_Line(Get_Standard_Line);

      Result := Result & Duration'Img;

      begin
         Open(F,Ada.Text_IO.Append_File,"result.txt");
      exception
         when Ada.IO_Exceptions.Name_Error =>
            Create(F,Ada.Text_IO.Out_File,"result.txt");
      end;

      Unbounded_IO.Put(F, result);
   end Test_Feasibility_Test_Computation_Time;

   procedure Process_Data
     (Exp_Dir                 : in String;
      PU_String 	      : in String)
   is
      Line : Unbounded_String;
      F: Ada.Text_IO.File_Type;
      Tokens :  GNAT.String_Split.Slice_Set;
      Count : Natural := 0;

      Line_Result : Unbounded_String := empty_string;
      Max : Float;
      Float_String : String(1..15);
      Temp : Float;

   begin
      Set_Directory(Exp_Dir);
      for i in 5..100 loop

         Append(Line_Result,To_String(suppress_space(i'Img)));

         Open(F,Ada.Text_IO.In_File, Exp_Dir & To_String(suppress_space(i'Img)) & "/" & PU_String & "/result.txt");


         Max := 0.0;

         while not End_Of_File (F) loop
            Line := Get_Line (F);
            GNAT.String_Split.Create(s => Tokens,
                                     From => To_String(Line),
                                     Separators => ",",
                                     Mode =>  GNAT.String_Split.Single);
            Temp := Float'Value(GNAT.String_Split.Slice(Tokens,2));
            if (Temp > Max) then
               max := temp;
            end if;
         end loop;

         Put(Float_String,max,10,0);
         Append(Line_Result,",");
         Append(Line_Result,Float_String);
         Append(Line_Result,ASCII.LF);

         Close (F);
      end loop;

      Put_Line(Line_Result);

      begin
         Create(F,Ada.Text_IO.Out_File,"FS_result.txt");
      exception
         when Ada.IO_Exceptions.Name_Error =>
            Create(F,Ada.Text_IO.Out_File,"FS_result.txt");
      end;

      Unbounded_IO.Put(F, Line_Result);
      Close(F);

   end Process_Data;


   procedure Test_Multiset_Intersection
   is
      arr_a : Integer_Array;
      arr_b : Integer_Array;
      arr_c : Integer_Array;
   begin
      Initialize(arr_a,"1,2,1,2,1,2,2,3,4",",");
      Initialize(arr_b,"1,2,3,4,1,2,3,4,1,2,3,4",",");
      Print(arr_a);
      Print(arr_b);
      arr_c := Multiset_Intersection(arr_a,arr_b);
      Print(arr_c);
   end Test_Multiset_Intersection;

end wcrt_crpd_util;
