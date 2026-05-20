
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
--    $Author: nam $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Strings.Unbounded;
use  Ada.Strings.Unbounded;
with Generic_Graph; use Generic_Graph;
with Tasks; use Tasks;
with Task_Set; use Task_Set;
with Task_Groups; use Task_Groups;
with Task_Group_Set; use Task_Group_Set;
with Messages; use Messages;
with Dependencies; use Dependencies;
with Systems; use Systems;
with Processors;          use Processors;
with Processor_Set;       use Processor_Set;
with Address_Spaces;      use Address_Spaces;
with Address_Space_Set;   use Address_Space_Set;
with Message_Set;         use Message_Set;
with Task_Dependencies;   use Task_Dependencies;
with Task_Dependencies;   use Task_Dependencies.Half_Dep_Set;
with convert_strings;
with unbounded_strings; use unbounded_strings;
with convert_unbounded_strings;
with Text_IO; use Text_IO;
with Systems; use Systems;
with Objects; use Objects;
with Parameters.extended; use Parameters.extended;
with Scheduler_Interface; use Scheduler_Interface;
with Ada.Finalization;
with unbounded_strings; use unbounded_strings;
with architecture_factory; use architecture_factory;
use unbounded_strings.unbounded_string_list_package;
with Unchecked_Deallocation;
with sets;
with Framework_Config; use Framework_Config;
with Ada.Float_Text_IO;
with Offsets; 		use Offsets;
with Offsets; 		use Offsets.Offsets_Table_Package;
with Random_Tools; 	use Random_Tools;
with initialize_framework; use initialize_framework;
with Random_Tools; use Random_Tools;
with Ada.Numerics.Float_Random;
with Core_Units ; use Core_Units ;
with Networks ; use Networks ;
use networks.Positions_Table_Package;
with Ada.Numerics.Float_Random ; use Ada.Numerics.Float_Random ;
with MILS_Security; use MILS_Security;
with mils_analysis; use mils_analysis;
with GNAT.Command_Line;
with GNAT.OS_Lib;                       use GNAT.OS_Lib;
with Memories; use Memories;

procedure generator_model_v2 is
   -- Security level
   confidentiality_config      : String (1 .. 19) := "0000000000000000000";
   integrity_config            : String (1 .. 19) := "0000000000000000000";
   confidentiality_config_int  : Integer;
   integrity_config_int        : Integer;
   filename                    : Integer;
   mem : Memories_Table;

    task_confidentiality_config : array (1 .. 19) of MILS_Confidentiality_Level_Type;
    task_integrity_config       : array (1 .. 19) of MILS_Integrity_Level_Type;
    binary_base                 : Number_Base := 2;
    algorithm                   : Unbounded_String;
    prefix                      : Unbounded_String;
    folder                      : Unbounded_String;
    -- System model
    a_system                    : System;
    a_core                      : Core_Unit_Ptr;
    a_cpu_name 	                : Unbounded_String;
    a_address_Space             : Unbounded_String;
    a_task                      : Generic_Task_Ptr;
    A_task_source               : Generic_Task_Ptr;
    A_task_sink                 : Generic_Task_Ptr;

begin
    -------------------------
    --Security Configuration
    -------------------------

    loop
        case GNAT.Command_Line.Getopt ("i: c: a:") is
            when ASCII.NUL =>
                exit;
                when 'i' =>
                integrity_config := GNAT.Command_Line.Parameter;
            when 'c' =>
                confidentiality_config := GNAT.Command_Line.Parameter;
            when 'a' =>
                algorithm := To_Unbounded_String (GNAT.Command_Line.Parameter);
            when others =>
                OS_Exit (0);
        end case;
    end loop;

    confidentiality_config_int := Integer'Value ("2#" & confidentiality_config &'#');
    integrity_config_int := Integer'Value ("2#" & integrity_config &'#');

    Put_Line ("Confidentiality config: " & confidentiality_config_int'Img & " (" & confidentiality_config & ") ");
    Put_Line ("Integrity config: " & integrity_config_int'Img & " (" & integrity_config & ")");

    for i in 1 .. 19 loop
        if (confidentiality_config (i) = '0') then
            task_confidentiality_config (i) := Top_Secret;
        else
            task_confidentiality_config (i) := Secret;
        end if;

        if (integrity_config (i) = '0') then
            task_integrity_config (i) := High;
        else
            task_integrity_config (i) := Medium;
        end if;
    end loop;

    Put_Line ("---CONFIDENTIALITY-------------");
    for i in 1 .. 19 loop
        Put_Line (task_confidentiality_config (i)'Img);
    end loop;

    Put_Line ("---INTEGRITY-------------");
    for i in 1 .. 19 loop
        Put_Line (task_integrity_config (i)'Img);
    end loop;

    Put_Line ("---ALGO-------------");
    if (To_String (algorithm) = "biba") then
        filename := integrity_config_int;
        prefix := To_Unbounded_String ("NS-BB");
        confidentiality_config := "0000000000000000000";
        Put_Line ("ALGO: Biba, reset confidentiality config -> 0000000000000000000");
    elsif (To_String (algorithm) = "bell") then
        filename := confidentiality_config_int;
        prefix := To_Unbounded_String ("NS-BL");
        integrity_config := "0000000000000000000";
        Put_Line ("ALGO: Bell Lapadula, reset integrity config -> 0000000000000000000");
    end if;

    Set_Initialize;
    Initialize (A_System => a_system);

    -------------------------
    --Generate Core_unit-----
    -------------------------

    Add_core_unit (My_core_units  => a_system.Core_units		,
                   A_core_unit	  	   => a_core				,
                   Name           	   => Suppress_Space (To_Unbounded_String ("Core")),
                   Is_Preemptive  	   => preemptive			,
                   Quantum        	   => 0					,
                   speed          	   => 1				,
                   capacity        	   => 1					,
                   period         	   => 1					,
                   priority       	   => 1					,
                   File_Name      	   => empty_string			,
                   A_Scheduler            => Posix_1003_Highest_Priority_First_Protocol,
                   automaton_name 	   => empty_string			,
                   start_time     	   => 0					,
                   mem                  => mem);



    --------------------------
    --Generate Processor-----
    --------------------------

    Add_Processor (My_Processors => a_system.Processors,
                   Name	    => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
                   a_Core        => a_core);

    ----------------------------
    --Generate Address_space----
    ----------------------------

    Add_Address_Space (My_Address_Spaces 	 => a_system.Address_Spaces,
                       Name	                 => Suppress_Space (To_Unbounded_String ("Address_Space")),
                       Cpu_Name     	         => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
                       Text_Memory_Size  	 => 1024,
                       Stack_Memory_Size 	 => 1024,
                       Data_Memory_Size  	 => 1024,
                       Heap_Memory_Size  	 => 1024);

    -------------------------------
    ------   Generate tasks  ------
    -------------------------------
    Initialize (a_system.Tasks);


    Add_Task (My_Tasks                	 => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("1")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0,
              Capacity                	 => 9,
              Period                   	 => 1000,
              Deadline                 	 => 1000,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 37,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (1),
              mils_confidentiality_level => task_confidentiality_config (1));

    Add_Task (My_Tasks                 	 => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("2")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0 ,
              Capacity                	 => 5,
              Period                   	 => 1000,
              Deadline                 	 => 1000,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 35,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (2),
              mils_confidentiality_level => task_confidentiality_config (2));

    Add_Task (My_Tasks                	 => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("3")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0 ,
              Capacity                	 => 34,
              Period                   	 => 1000,
              Deadline                 	 => 1000,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 33,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (3),
              mils_confidentiality_level => task_confidentiality_config (3));

    Add_Task (My_Tasks                   => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("4")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type                  => Periodic_Type,
              Start_Time              	 => 0,
              Capacity                	 => 3,
              Period                   	 => 1000,
              Deadline                 	 => 1000,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 31,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level         => task_integrity_config (4),
              mils_confidentiality_level => task_confidentiality_config (4));

    Add_Task (My_Tasks                   => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("5")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0,
              Capacity                	 => 20,
              Period                   	 => 500,
              Deadline                 	 => 500,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 29,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (5),
              mils_confidentiality_level => task_confidentiality_config (5));

    Add_Task (My_Tasks                   => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("6")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0,
              Capacity                	 => 10,
              Period                   	 => 1000,
              Deadline                 	 => 1000,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 27,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (6),
              mils_confidentiality_level => task_confidentiality_config (6));

    Add_Task (My_Tasks                   => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("7")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0 ,
              Capacity                	 => 10,
              Period                   	 => 1000,
              Deadline                 	 => 1000,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 25,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (7),
              mils_confidentiality_level => task_confidentiality_config (7));

    Add_Task (My_Tasks                   => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("8")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0,
              Capacity                	 => 10,
              Period                   	 => 1000,
              Deadline                 	 => 1000,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 23,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (8),
              mils_confidentiality_level => task_confidentiality_config (8));


    Add_Task (My_Tasks                   => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("9")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0,
              Capacity                	 => 10,
              Period                   	 => 1000,
              Deadline                 	 => 1000,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 21,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (9),
              mils_confidentiality_level => task_confidentiality_config (9));

    Add_Task (My_Tasks                   => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("10")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0,
              Capacity                	 => 10,
              Period                   	 => 1000,
              Deadline                 	 => 1000,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 19,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (10),
              mils_confidentiality_level => task_confidentiality_config (10));

    Add_Task (My_Tasks                   => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("11")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0 ,
              Capacity                	 => 10,
              Period                   	 => 2000,
              Deadline                 	 => 2000,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 17,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (11),
              mils_confidentiality_level => task_confidentiality_config (11));

    Add_Task (My_Tasks                   => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("12")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0 ,
              Capacity                	 => 10,
              Period                   	 => 1000,
              Deadline                 	 => 1000,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 15,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (12),
              mils_confidentiality_level => task_confidentiality_config (12));

    Add_Task (My_Tasks                   => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("13")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0,
              Capacity                	 => 10,
              Period                   	 => 1000,
              Deadline                 	 => 1000,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 13,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (13),
              mils_confidentiality_level => task_confidentiality_config (13));

    Add_Task (My_Tasks                   => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("14")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0,
              Capacity                	 => 50,
              Period                   	 => 2000,
              Deadline                 	 => 2000,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 11,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (14),
              mils_confidentiality_level => task_confidentiality_config (14));

    Add_Task (My_Tasks                   => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("15")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0,
              Capacity                	 => 50,
              Period                   	 => 1000,
              Deadline                 	 => 1000,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 9,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (15),
              mils_confidentiality_level => task_confidentiality_config (15));

    Add_Task (My_Tasks                   => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("16")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0 ,
              Capacity                	 => 50,
              Period                   	 => 2000,
              Deadline                 	 => 2000,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 7,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (16),
              mils_confidentiality_level => task_confidentiality_config (16));

    Add_Task (My_Tasks                   => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("17")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0 ,
              Capacity                	 => 50,
              Period                   	 => 1000,
              Deadline                 	 => 1000,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 5,
              Criticality              	 => 0,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (17),
              mils_confidentiality_level => task_confidentiality_config (17));

    Add_Task (My_Tasks                   => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("18")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time              	 => 0,
              Capacity                	 => 10,
              Period                   	 => 500,
              Deadline                 	 => 500,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 27,
              Criticality              	 => 3,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (18),
              mils_confidentiality_level => task_confidentiality_config (18));

    Add_Task (My_Tasks                   => a_system.Tasks,
              A_Task			 => a_task,
              Name                       => Suppress_Space (To_Unbounded_String ("19")),
              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string ("Processor"))) ,
              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
              Task_Type               	 => Periodic_Type,
              Start_Time                 => 0 ,
              Capacity                	 => 10,
              Period                   	 => 500,
              Deadline                 	 => 500,
              Jitter                   	 => 0,
              Blocking_Time            	 => 0,
              Priority                 	 => 27,
              Criticality              	 => 3,
              Policy                   	 => Sched_Fifo,
              mils_integrity_level       => task_integrity_config (19),
              mils_confidentiality_level => task_confidentiality_config (19));

    ------------------------------
    ---    produce dependency  ---
    ------------------------------

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("1"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("2")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("2"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("3")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("3"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("4")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("5"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("6")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("5"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("7")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("5"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("8")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("5"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("9")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("5"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("10")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink           => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("6"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("11")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("7"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("12")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);


    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("8"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("12")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("8"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("13")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("9"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("12")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("10"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("13")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("11"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("12")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink           => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("11"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("14")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("12"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("15")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("13"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("16")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("13"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("17")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("15"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("18")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("17"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("19")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("18"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("5")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);

    A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("19"))) ;
    A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("5")));
    Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                        Source          => A_task_source,
                                        Sink            => A_task_sink);


    Write_To_Xml_File
      (A_System  => a_system,
--       File_Name => Suppress_Space (To_Unbounded_String ( "framework_examples/mils/xml_generated_result/"
         File_Name => Suppress_Space (To_Unbounded_String ( "framework_examples/mils/xml/exp1/models/"
         & To_String (prefix)
         & "/"
         & To_String (prefix)
         & "-"
         & To_String (suppress_space (filename'Img)) & ".xmlv3")));
    Put_Line ("framework_examples/mils/xml/exp1/models/"
              & To_String (prefix)
              & "/"
              & To_String (prefix)
              & "-"
              & To_String (suppress_space (filename'Img)) & ".xmlv3");
    Put_Line ("----------Not secured file------------");
end  generator_model_v2;
