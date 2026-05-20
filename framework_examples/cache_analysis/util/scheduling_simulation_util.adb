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

with Text_IO;                   	    use Text_IO;
with Ada.Text_IO, Ada.Integer_Text_IO;	use Ada.Text_IO, Ada.Integer_Text_IO;
with Ada.Float_Text_IO;			        use Ada.Float_Text_IO;
with Ada.Text_IO.Unbounded_IO; 		    use Ada.Text_IO.Unbounded_IO;
with Ada.Strings.Unbounded; 		    use Ada.Strings.Unbounded;
with Systems;               		    use Systems;
with Caches;                		    use Caches;
with Cache_Set;             		    use Cache_Set;
with CFG_Nodes; 			            use CFG_Nodes.CFG_Nodes_Table_Package;
with CFG_Nodes;				            use CFG_Nodes;
with CFG_Nodes_Builder; 		        use CFG_Nodes_Builder;
with initialize_framework; 		        use initialize_framework;
with CFG_Set;				            use CFG_Set;
with CFG_Edges; 			            use CFG_Edges;
with CFG_Node_Set; 			            use CFG_Node_Set;
with CFG_Edge_Set;			            use CFG_Edge_Set;
with unbounded_strings; 		        use unbounded_strings;
with unbounded_strings; 		        use unbounded_strings.strings_table_package;
with unbounded_strings;			        use unbounded_strings.unbounded_string_list_package;
with Call_Framework; 			        use Call_Framework;
with Integer_Arrays; 			        use Integer_Arrays;
with Basic_Block_Analysis; 		        use Basic_Block_Analysis;
with CFGs; 				                use CFGs;
with CFG_Node_Set.Basic_Block_Set;	    use CFG_Node_Set.Basic_Block_Set;
with Basic_Blocks; 			            use Basic_Blocks;
with CFG_Nodes.Extended; 		        use CFG_Nodes.Extended;
with Ada.Integer_Text_IO;       	    use Ada.Integer_Text_IO;
with Call_Cache_Framework; 		        use Call_Cache_Framework;
with Processor_Set; 			        use Processor_Set;
with Scheduler_Interface; 		        use Scheduler_Interface;
with Core_Units; 			            use Core_Units;
with Address_Space_Set; 		        use Address_Space_Set;
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
with Framework;                    	    use Framework;
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
with Ada.Text_IO.Unbounded_IO; 		    use Ada.Text_IO.Unbounded_IO;
with Ada.Directories; 			        use Ada.Directories;
with Scheduler;				            use Scheduler;
with architecture_factory;              use architecture_factory;
with Debug;				                use Debug;
with Scheduler.Fixed_Priority.Rm; 	    use Scheduler.Fixed_Priority.Rm;
with Scheduler.Dynamic_Priority.Edf;	use Scheduler.Dynamic_Priority.Edf;
with Scheduler.Fixed_Priority.Hpf; 	    use Scheduler.Fixed_Priority.Hpf;
with Framework_Config; 			        use Framework_Config;
with Ada.Calendar; 			            use Ada.Calendar;
with Ada.Calendar.Formatting;		    use Ada.Calendar.Formatting;
with Cache_Utility; 			        use Cache_Utility;
with Offsets;               		    use Offsets;
with Offsets.extended;      		    use Offsets.extended;
with Offsets;  				            use Offsets.Offsets_Table_Package;
with Caches;				            use Caches.Cache_Blocks_Table_Package;
with Cache_Block_Set;			        use Cache_Block_Set;
with Scheduling_Analysis; 		        use Scheduling_Analysis;
with Cache_Access_Profile_Set; 		    use Cache_Access_Profile_Set;
with Time_Unit_Events;			        use Time_Unit_Events.Time_Unit_Package;
with test_case_generator; 		        use test_case_generator;
with Memories;                          use Memories;
with Tables;
with Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
with Ada.Numerics.Float_Random;

package body scheduling_simulation_util is
   package Fix_IO is new Ada.Text_IO.Fixed_IO(DAY_DURATION); use Fix_IO;

   procedure compute_scheduling_of_tasks_from_ada_sys_model
     (Period 		: in Natural;
      Sys 		: in out System;
      Output_File_Name  : in Unbounded_String;
      Export_Data 	: in Boolean := FALSE;
      Result 		: out Natural)
   is
      -- A set of variables required to call the framework
      --
      Response_List         : Framework_Response_Table;
      Request_List          : Framework_Request_Table;
      A_Request             : Framework_Request;
      A_Param               : Parameter_Ptr;
      Project_File_List     : unbounded_string_list;
      Project_File_Dir_List : unbounded_string_list;

      -- Is the command should run in verbose mode ?
      --
      Verbose : Boolean := False;
      Input_File_Name : Unbounded_String;
      -- The duration on which we must compute the scheduling
      --

      flag : Boolean := True;
      F: Ada.Text_IO.File_Type;
      Data: Unbounded_String;
   begin
      -- Initialize the Cheddar framework
      --
      Call_Framework.initialize (False);
      -- Read the XML project file
      --
      initialize (Project_File_List);
      -- Compute the scheduling on the period given by the argument
      --
      initialize (Response_List);
      initialize (Request_List);
      Initialize (A_Request);
      A_Request.statement           := Scheduling_Simulation_Time_Line;
      A_Param                       := new Parameter (Integer_Parameter);
      A_Param.parameter_name        := To_Unbounded_String ("period");
      A_Param.integer_value         := Period;
      add (A_Request.param, A_Param);

      A_Param                       := new Parameter (Boolean_Parameter);
      A_Param.parameter_name        := To_Unbounded_String ("schedule_with_offsets");
      A_Param.boolean_value := True;
      add (A_Request.param, A_Param);

      A_Param                       := new Parameter (Boolean_Parameter);
      A_Param.parameter_name        := To_Unbounded_String ("schedule_with_crpd");
      A_Param.boolean_value         := True;
      add (A_Request.param, A_Param);

      A_Param                       := new Parameter (Boolean_Parameter);
      A_Param.parameter_name        := To_Unbounded_String ("running_task");
      A_Param.boolean_value         := True;
      add (A_Request.param, A_Param);

      A_Param                       := new Parameter (Boolean_Parameter);
      A_Param.parameter_name        := To_Unbounded_String ("schedule_with_precedencies");
      A_Param.boolean_value := False;
      add (A_Request.param, A_Param);

      A_Param                       := new Parameter (Boolean_Parameter);
      A_Param.parameter_name        := To_Unbounded_String ("schedule_with_resources");
      A_Param.boolean_value         := False;
      add (A_Request.param, A_Param);

      A_Param                       := new Parameter (Boolean_Parameter);
      A_Param.parameter_name        := To_Unbounded_String ("end_of_task_capacity");
      A_Param.boolean_value         := False;
      add (A_Request.param, A_Param);

      A_Param                       := new Parameter (Boolean_Parameter);
      A_Param.parameter_name        := To_Unbounded_String ("start_of_task_capacity");
      A_Param.boolean_value         := False;
      add (A_Request.param, A_Param);

      A_Param                       := new Parameter (Boolean_Parameter);
      A_Param.parameter_name        := To_Unbounded_String ("task_activation");
      A_Param.boolean_value         := True;
      add (A_Request.param, A_Param);

      A_Param                       := new Parameter (Boolean_Parameter);
      A_Param.parameter_name        := To_Unbounded_String ("preemption");
      A_Param.boolean_value         := True;
      add (A_Request.param, A_Param);

      A_Param                       := new Parameter (Integer_Parameter);
      A_Param.parameter_name        := To_Unbounded_String ("seed_value");
      A_Param.integer_value         := 0;
      add (A_Request.param, A_Param);
      add (Request_List, A_Request);

      Put_Line("START: SCHED SIMULATION");
      --TODO: Raise an exeception when task missed deadline or choose another solution to return a code
      --        begin
      Sequential_Framework_Request (Sys, Request_List, Response_List);
      --        exception
      --           when INFEASIBLE_TASK_EXCEPTION =>
      --              flag := False;
      --              --Put_Line("FLAG = FALSE");
      --        end;
      Put(Response_List);

      Put_Line("END: SCHED SIMULATION");

      if(flag)then
         Result := 1;
         --Put_Line("RESULT = 1");
      else
         Result := 0;
         --Put_Line("RESULT = 0");
      end if;

      if(Export_Data) then
         Write_To_Xml_File (framework.Sched, Sys, Output_File_Name);
      end if;

   end compute_scheduling_of_tasks_from_ada_sys_model;

   -------------------------------------
   -- TEST with case study
   -------------------------------------

   procedure build_case_study_CAP
     (a_system : in out System)
   is
      my_tasks                    : Tasks_Set;
      my_cache_access_profiles    : Cache_Access_Profiles_Set;
      -----------------------------------------------------
      my_caches                : Caches_Set;
      cache_replacement        : Cache_Replacement_Policy_Type;
      cache_coherence_protocol : Cache_Coherence_Protocol_Type;
      cache_category           : Cache_Type;
      a_core                   : Core_Unit_Ptr;
      a_cache                  : Generic_Cache_Ptr;

      cap1, cap2, cap3 : Cache_Access_Profile_Ptr;
      cap1_ucb, cap1_ecb,
      cap2_ucb, cap2_ecb,
      cap3_ucb, cap3_ecb : Cache_Blocks_Table;

      task1_capacity, task1_period, task1_start_time,
      task2_capacity, task2_period, task2_start_time,
      task3_capacity, task3_period, task3_start_time : Integer;

      a_task : Generic_Task_Ptr;

      mem_t : Memories_Table;
   begin
      Set_Initialize;
      Initialize (A_System => a_system);
      cache_replacement        := Cache_Replacement_Policy_Type'Val (0);
      cache_coherence_protocol := Cache_Coherence_Protocol_Type'Val (0);
      cache_category           := Cache_Type'Val (1);

      Add_Cache(my_caches                => a_system.Caches,
                a_cache                  => a_cache,
                name                     => To_Unbounded_String ("Cache_01"),
                cache_size         	     => 8,
                line_size                => 1,
                associativity            => 1,
                block_reload_time        => 1,
                coherence_protocol 	     => cache_coherence_protocol,
                replacement_policy       => cache_replacement,
                cache_category           => cache_category);

      for i in 0..a_cache.cache_blocks.Nb_Entries-1 loop
         Add(a_system.Cache_Blocks, a_cache.cache_blocks.Entries(i));
      end loop;

      Add_core_unit(My_core_units  => a_system.Core_units,
                    A_core_unit    => a_core,
                    Name           => To_Unbounded_String("Core_01"),
                    Is_Preemptive  => preemptive,
                    Quantum        => 0,
                    speed          => 1,
                    capacity       => 1,
                    period         => 1,
                    priority       => 1,
                    File_Name      => empty_string,
                    scheduling_protocol_name => empty_string,
                    A_Scheduler    => Posix_1003_Highest_Priority_First_Protocol,
                    Mem            => mem_t,
                    automaton_name => empty_string,
                    l1_cache       => To_Unbounded_String ("Cache_01"),
                    start_time     => 0);

      Add_Processor(My_Processors => a_system.Processors,
                    Name          => To_Unbounded_String("CPU_01"),
                    a_Core        => a_core);

      Add_Address_Space(My_Address_Spaces => a_system.Address_Spaces,
                        Name              => To_Unbounded_String("Address_Space_01"),
                        Cpu_Name          => To_Unbounded_String("CPU_01"),
                        Text_Memory_Size  => 1024,
                        Stack_Memory_Size => 1024,
                        Data_Memory_Size  => 1024,
                        Heap_Memory_Size  => 1024);

      -- CAP 1
      for i in 0..2 loop
         Add(cap1_ucb,a_cache.cache_blocks.Entries(Caches.Cache_Blocks_Range(i)));
      end loop;

      for i in 0..7 loop
         Add(cap1_ecb,a_cache.cache_blocks.Entries(Caches.Cache_Blocks_Range(i)));
      end loop;

      Add_Cache_Access_Profile(my_cache_access_profiles => a_system.Cache_Access_Profiles,
                               a_cache_access_profile   => cap1,
                               name                     => To_Unbounded_String("CAP_1"),
                               ucbs                     => cap1_ucb,
                               ecbs                     => cap1_ecb);

      -- CAP 2
      for i in 0..1 loop
         Add(cap2_ucb,a_cache.cache_blocks.Entries(Caches.Cache_Blocks_Range(i)));
      end loop;

      for i in 0..3 loop
         Add(cap2_ecb,a_cache.cache_blocks.Entries(Caches.Cache_Blocks_Range(i)));
      end loop;

      Add_Cache_Access_Profile(my_cache_access_profiles => a_system.Cache_Access_Profiles,
                               a_cache_access_profile   => cap2,
                               name                     => To_Unbounded_String("CAP_2"),
                               ucbs                     => cap2_ucb,
                               ecbs                     => cap2_ecb);

      -- CAP 3
      for i in 4..4 loop
         Add(cap3_ucb,a_cache.cache_blocks.Entries(Caches.Cache_Blocks_Range(i)));
      end loop;

      for i in 4..7 loop
         Add(cap3_ecb,a_cache.cache_blocks.Entries(Caches.Cache_Blocks_Range(i)));
      end loop;

      Add_Cache_Access_Profile(my_cache_access_profiles => a_system.Cache_Access_Profiles,
                               a_cache_access_profile   => cap3,
                               name                     => To_Unbounded_String("CAP_3"),
                               ucbs                     => cap3_ucb,
                               ecbs                     => cap3_ecb);

      -- TASKS
      task1_capacity := 1;
      task1_period := 20;
      task1_start_time := 3;

      task2_capacity := 4;
      task2_period := 30;
      task2_start_time := 0;

      task3_capacity := 4;
      task3_period := 30;
      task3_start_time := 10;

      Add_Task(My_Tasks                  => a_system.Tasks,
               A_Task                    => a_task,
               Name                      => Suppress_Space (To_Unbounded_String ("Task_1")),
               Cpu_Name                  => To_Unbounded_String("CPU_01"),
               Address_Space_Name        => To_Unbounded_String("Address_Space_01"),
               core_name                 => To_Unbounded_String("Core_01"),
               Task_Type                 => Periodic_Type,
               Start_Time                => task1_start_time,
               Capacity                  => task1_capacity,
               Period                    => task1_period,
               Deadline                  => task1_period,
               Jitter                    => 0,
               Blocking_Time             => 0,
               Priority                  => 3,
               Criticality               => 0,
               Policy                    => SCHED_FIFO,
               Cache_Access_Profile_Name => cap1.name);

      Add_Task(My_Tasks                  => a_system.Tasks,
               A_Task                    => a_task,
               Name                      => Suppress_Space (To_Unbounded_String ("Task_2")),
               Cpu_Name                  => To_Unbounded_String("CPU_01"),
               Address_Space_Name        => To_Unbounded_String("Address_Space_01"),
               core_name                 => To_Unbounded_String("Core_01"),
               Task_Type                 => Periodic_Type,
               Start_Time                => task2_start_time,
               Capacity                  => task2_capacity,
               Period                    => task2_period,
               Deadline                  => task2_period,
               Jitter                    => 0,
               Blocking_Time             => 0,
               Priority                  => 2,
               Criticality               => 0,
               Policy                    => SCHED_FIFO,
               Cache_Access_Profile_Name => cap2.name);

      Add_Task(My_Tasks                  => a_system.Tasks,
               A_Task                    => a_task,
               Name                      => Suppress_Space (To_Unbounded_String ("Task_3")),
               Cpu_Name                  => To_Unbounded_String("CPU_01"),
               Address_Space_Name        => To_Unbounded_String("Address_Space_01"),
               core_name                 => To_Unbounded_String("Core_01"),
               Task_Type                 => Periodic_Type,
               Start_Time                => task3_start_time,
               Capacity                  => task3_capacity,
               Period                    => task3_period,
               Deadline                  => task3_period,
               Jitter                    => 0,
               Blocking_Time             => 0,
               Priority                  => 1,
               Criticality               => 0,
               Policy                    => SCHED_FIFO,
               Cache_Access_Profile_Name => cap3.name);

      a_system.Write_To_Xml_File("case_study.xmlv3");

   end build_case_study_CAP;

   procedure test_cache_aware_scheduling_simulator_with_case_study
   is
      a_system : System;
      result : Natural;
   begin
      build_case_study_CAP(a_system);
      compute_scheduling_of_tasks_from_ada_sys_model(60,a_system,To_Unbounded_String("case_study.xmlv3.ev.xml"),true,result);
   end test_cache_aware_scheduling_simulator_with_case_study;

   -------------------------------------
   -- TEST with randomly generated task set.
   -------------------------------------

   procedure test_cache_aware_scheduling_simulator_with_random_task_set_and_PA
     (file_name        : in Unbounded_String;
      N                : in Integer	:= 10;
      PU 	       		: in Float	:= 0.70;
      CU 	       		: in Float	:= 5.0;
      CS       	    : in Integer	:= 256;
      RF	       		: in Float	:= 0.3)
   is
      sys : System;

      a_Sys             : System;
      b_Sys		      : System;
      c_Sys                   : System;
      Project_File_Dir_List : unbounded_string_list;

      a_core : Core_Unit_Ptr;

      Result : Unbounded_String := empty_string;
      F: Ada.Text_IO.File_Type;

      i_iterator : Tasks_Iterator;
      j_iterator : Tasks_Iterator;
      j1_iterator : Tasks_Iterator;
      a_task_1 : Generic_Task_Ptr;
      a_task_2 : Generic_Task_Ptr;

      ipriority : Natural := 0;
      sched_result : Natural;
   begin
      Set_Initialize;

      --This function can generate and return a system.
      --In this test, we do not use the sys returned because
      --we are testing the XML_Parser.
      generate_system_with_harmonic_tasks_and_CAP(file_name => file_name,
                                                  N         => N,
                                                  PU        => PU,
                                                  CU        => CU,
                                                  CS        => CS,
                                                  RF        => RF,
                                                  a_system  => sys);

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

      compute_scheduling_of_tasks_from_ada_sys_model(1000,a_Sys, To_Unbounded_String("RM1.xml"),FALSE,sched_result);

      --Result := Result & a_Sys.Number_Of_Preemption'Img & "," & a_Sys.Total_CRPD'Img & ",";

      -----------------------------------------
      --
      -----------------------------------------
      Initialize(b_Sys);
      Systems.Read_From_Xml_File (b_Sys,
                                  Project_File_Dir_List,
                                  file_name);
      a_core := Search_core_unit(b_Sys.Core_units,To_Unbounded_String("Core_01"));
      a_core.scheduling.scheduler_type := Earliest_Deadline_First_Protocol;

      compute_scheduling_of_tasks_from_ada_sys_model(10000,b_Sys, To_Unbounded_String("EDF.xml"),FALSE,sched_result);

      --Result := Result & b_Sys.Number_Of_Preemption'Img & "," & b_Sys.Total_CRPD'Img & ",";

      -----------------------------------------
      --
      -----------------------------------------
      Systems.Read_From_Xml_File (c_Sys,
                                  Project_File_Dir_List,
                                  file_name);

      a_core := Search_core_unit(c_Sys.Core_units,To_Unbounded_String("Core_01"));
      a_core.scheduling.scheduler_type := Posix_1003_Highest_Priority_First_Protocol;
      --extended_core_unit_ptr(a_core).scheduler := new Hpf_Scheduler;

      reset_iterator (c_Sys.Tasks, i_iterator);
      loop
         --------------------------------------

         reset_iterator (c_Sys.Tasks, j_iterator);
         loop
            current_element (c_Sys.Tasks, a_task_2, j_iterator);
            j1_iterator := j_iterator;
            next_element (c_Sys.Tasks, j1_iterator);
            current_element (c_Sys.Tasks, a_task_1, j1_iterator);

            if(a_task_1.name /= a_task_2.name) then

               if not Increasing_UCB(c_Sys.Cache_Access_Profiles,a_task_1,a_task_2)
               then
                  swap(c_Sys.Tasks,j_iterator,j1_iterator);
               end if;
            end if;

            exit when is_last_element (c_Sys.Tasks, j1_iterator);
            next_element (c_Sys.Tasks, j_iterator);
         end loop;

         --------------------------------------
         exit when is_last_element (c_Sys.Tasks, i_iterator);
         next_element (c_Sys.Tasks, i_iterator);
      end loop;

      ipriority := N;
      reset_iterator (c_Sys.Tasks, i_iterator);
      loop
         current_element (c_Sys.Tasks, a_task_1, i_iterator);
         --------------------------------------
         a_task_1.priority := Priority_Range(ipriority);
         ipriority := ipriority - 1;

         --------------------------------------
         exit when is_last_element (c_Sys.Tasks, i_iterator);
         next_element (c_Sys.Tasks, i_iterator);
      end loop;

      compute_scheduling_of_tasks_from_ada_sys_model(10000,c_Sys, To_Unbounded_String("HPF.xml"),FALSE,sched_result);

      --Result := Result & c_Sys.Number_Of_Preemption'Img & "," & c_Sys.Total_CRPD'Img & ",";

      -----------------------------------------
      -- WRITE FILE
      -----------------------------------------
      begin
         Open(F,Ada.Text_IO.Append_File,"result.txt");
      exception
         when Ada.IO_Exceptions.Name_Error =>
            Create(F,Ada.Text_IO.Out_File,"result.txt");
      end;

      Unbounded_IO.Put(F, result);
   end test_cache_aware_scheduling_simulator_with_random_task_set_and_PA;

   procedure Test_Cache_Aware_Scheduling_Simulator_Computation_Time
     (file_name            : in Unbounded_String;
      N                    : in Integer	:= 10;
      PU 	       		    : in Float	    := 0.70;
      CU 	       		    : in Float	    := 5.0;
      CS       	        : in Integer	:= 256;
      RF	       		    : in Float	    := 0.3;
      H 			        : in Integer    := 100000;
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

      sched_result : Natural;
      hyper_period : Natural;
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
                                                     Max_Period => 500,
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

      Put_Line("=============================");
      Time_And_Date := Clock;
      Split(Time_And_Date, Year, Month, Day, Start);

      begin
         if (H = 0) then
            hyper_period := Compute_Hyperperiod(My_Tasks => a_Sys.Tasks);
         else
            hyper_period := H;
         end if;
      exception
         when CONSTRAINT_ERROR =>
            hyper_period := Integer'Last;
      end;

      Put_Line("Hyperperiod: " & hyper_period'Img);

      compute_scheduling_of_tasks_from_ada_sys_model(hyper_period,a_Sys, To_Unbounded_String("RM1.xml"),TRUE,sched_result);
      -----------------------------------------
      -- WRITE FILE
      -----------------------------------------
      Time_And_Date := Clock;
      Split(Time_And_Date, Year, Month, Day, Ends);
      Duration:= Ends - Start;
      Put_Line("Scheduling Simulation: " & Duration'Img);
      Put_Line("=============================");

      Result := Result & Duration'Img;

      begin
         Open(F,Ada.Text_IO.Append_File,"result.txt");
      exception
         when Ada.IO_Exceptions.Name_Error =>
            Create(F,Ada.Text_IO.Out_File,"result.txt");
      end;

      Unbounded_IO.Put(F, result);
   end Test_Cache_Aware_Scheduling_Simulator_Computation_Time;


   -------------------------------------
   --
   -------------------------------------

   procedure offset_to_start_time
     (my_tasks         : in Tasks_Set)
   is
      my_iterator 	: Tasks_Iterator;
      a_task 		    : Generic_Task_Ptr;
   begin
      reset_iterator (my_tasks, my_iterator);
      loop
         current_element (my_tasks, a_task, my_iterator);

         if(a_task.offsets.Entries(0).activation = 0)then
            a_task.start_time := a_task.offsets.Entries(0).offset_value;
            a_task.offsets.Entries(0).offset_value := 0;
         end if;

         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;

   end offset_to_start_time;

end  scheduling_simulation_util;
