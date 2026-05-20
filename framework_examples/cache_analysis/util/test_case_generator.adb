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
with Memories;                          use Memories;

package body test_case_generator is

    ------------------------------------------------------
    -- Procedure for generating systems, examples
    ------------------------------------------------------
    procedure generate_system_with_cache_and_cfg
    is
        my_caches                : Caches_Set;
        cache_replacement        : Cache_Replacement_Policy_Type;
        cache_coherence_protocol : Cache_Coherence_Protocol_Type;
        cache_category           : Cache_Type;

        a_task 		: Generic_Task_Ptr;
        a_system    	: System;
        a_core		: Core_Unit_Ptr;
        a_cache		: Generic_Cache_Ptr;

        my_cfg_nodes_bs : CFG_Nodes_Table;
        my_cfg_edges_bs : CFG_Edges_Table;
        my_cfg_nodes_fac : CFG_Nodes_Table;
        my_cfg_edges_fac : CFG_Edges_Table;
        my_cfg_nodes_fibcall : CFG_Nodes_Table;
        my_cfg_edges_fibcall : CFG_Edges_Table;
        my_cfg_nodes_insertsort : CFG_Nodes_Table;
        my_cfg_edges_insertsort : CFG_Edges_Table;

        cfg_nodes_s : CFG_Nodes_Set;
        cfg_edges_s : CFG_Edges_Set;

        offset : Integer := 0;

        a_offset : Offset_Type;
        b_offset : Offset_Type;
        c_offset : Offset_Type;
        d_offset : Offset_Type;
        e_offset : Offset_Type;
        f_offset : Offset_Type;

        offset_t_a: Offsets_Table;
        offset_t_b: Offsets_Table;
        offset_t_c: Offsets_Table;
        offset_t_d: Offsets_Table;
        offset_t_e: Offsets_Table;
        offset_t_f: Offsets_Table;

        mem_t: Memories_Table;
    begin
        Set_Initialize;

        a_offset.offset_value := 100;
        b_offset.offset_value := 500;
        c_offset.offset_value := 0;
        d_offset.offset_value := 200;
        e_offset.offset_value := 270;
        f_offset.offset_value := 0;

        a_offset.activation := 0;
        b_offset.activation := 0;
        c_offset.activation := 0;
        d_offset.activation := 0;
        e_offset.activation := 0;
        f_offset.activation := 0;

        Add(offset_t_a,a_offset);
        Add(offset_t_b,b_offset);
        Add(offset_t_c,c_offset);
        Add(offset_t_d,d_offset);
        Add(offset_t_e,e_offset);
        Add(offset_t_f,f_offset);

        Initialize (A_System => a_system);

        cache_replacement        := Cache_Replacement_Policy_Type'Val (0);
        cache_coherence_protocol := Cache_Coherence_Protocol_Type'Val (0);
        cache_category           := Cache_Type'Val (1);


        Add_Cache(my_caches                => a_system.Caches,
                  a_cache 		   => a_cache,
                  name                     => To_Unbounded_String ("Cache_01"),
                  cache_size         	   => 1024,
                  line_size                => 16,
                  associativity            => 1,
                  block_reload_time        => 1,
                  coherence_protocol 	   => cache_coherence_protocol,
                  replacement_policy       => cache_replacement,
                  cache_category           => cache_category);

        for i in 0..a_cache.cache_blocks.Nb_Entries-1 loop
            Add(a_system.Cache_Blocks, a_cache.cache_blocks.Entries(i));
        end loop;

        Add_core_unit(My_core_units  => a_system.Core_units,
                      A_core_unit    => a_core,
                      Name           => To_Unbounded_String("Core_1"),
                      Is_Preemptive  => preemptive,
                      Quantum        => 0,
                      speed          => 1,
                      capacity       => 1,
                      period         => 1,
                      priority       => 1,
                      File_Name      => empty_string,
                      scheduling_protocol_name => empty_string,
                      A_Scheduler    => Rate_Monotonic_Protocol,
                      Mem            => mem_t,
                      automaton_name => empty_string,
                      l1_cache       => To_Unbounded_String ("Cache_01"),
                      start_time     => 0);

        Add_Processor(My_Processors => a_system.Processors,
                      Name          => To_Unbounded_String("CPU_01"),
                      a_Core        => a_core);

        Add_CFG_Nodes_Bs_To_System(sys          => a_system,
                                   my_cfg_nodes => my_cfg_nodes_bs,
                                   my_cfg_edges => my_cfg_edges_bs,
                                   offset       => offset);

        Add_CFG(my_cfgs       => a_system.CFGs,
                name          => To_Unbounded_String ("CFG_Bs"),
                cfg_nodes_tbl => my_cfg_nodes_bs,
                cfg_edges_tbl => my_cfg_edges_bs);

        Add_CFG_Nodes_Fac_To_System(sys          => a_system,
                                    my_cfg_nodes => my_cfg_nodes_fac,
                                    my_cfg_edges => my_cfg_edges_fac,
                                    offset       => offset);

        Add_CFG(my_cfgs       => a_system.CFGs,
                name          => To_Unbounded_String ("CFG_Fac"),
                cfg_nodes_tbl => my_cfg_nodes_fac,
                cfg_edges_tbl => my_cfg_edges_fac);

        Add_CFG_Nodes_Fibcall_To_System(sys          => a_system,
                                        my_cfg_nodes => my_cfg_nodes_fibcall,
                                        my_cfg_edges => my_cfg_edges_fibcall,
                                        offset       => offset);

        Add_CFG(my_cfgs       => a_system.CFGs,
                name          => To_Unbounded_String ("CFG_Fibcall"),
                cfg_nodes_tbl => my_cfg_nodes_fibcall,
                cfg_edges_tbl => my_cfg_edges_fibcall);

        Add_CFG_Nodes_InsertSort_To_System(sys          => a_system,
                                           my_cfg_nodes => my_cfg_nodes_insertsort,
                                           my_cfg_edges => my_cfg_edges_insertsort,
                                           offset       => offset);

        Add_CFG(my_cfgs       => a_system.CFGs,
                name          => To_Unbounded_String ("CFG_InsertSort"),
                cfg_nodes_tbl => my_cfg_nodes_insertsort,
                cfg_edges_tbl => my_cfg_edges_insertsort);


        Add_Address_Space(My_Address_Spaces => a_system.Address_Spaces,
                          Name              => To_Unbounded_String("Address_Space_01"),
                          Cpu_Name          => To_Unbounded_String("CPU_01"),
                          Text_Memory_Size  => 1024,
                          Stack_Memory_Size => 1024,
                          Data_Memory_Size  => 1024,
                          Heap_Memory_Size  => 1024);

        Add_Task(My_Tasks                  => a_system.Tasks,
                 A_Task			   => a_task,
                 Name                      => To_Unbounded_String("Task_Bs"),
                 Cpu_Name                  => To_Unbounded_String("CPU_01"),
                 Address_Space_Name        => To_Unbounded_String("Address_Space_01"),
                 core_name                 => To_Unbounded_String("Core_01"),
                 Task_Type                 => Periodic_Type,
                 Start_Time                => 0,
                 Capacity                  => 76,
                 Period                    => 1000,
                 Deadline                  => 1000,
                 Jitter                    => 0,
                 Blocking_Time             => 0,
                 Priority                  => 1,
                 Criticality               => 0,
                 Policy                    => Sched_Fifo,
                 Cache_Access_Profile_Name => empty_string,
                 CFG_Name                  => To_Unbounded_String("CFG_Bs"),
                 Offset                    => offset_t_a);

        Add_Task(My_Tasks                  => a_system.Tasks,
                 A_Task			             => a_task,
                 Name                      => To_Unbounded_String("Task_Fac"),
                 Cpu_Name                  => To_Unbounded_String("CPU_01"),
                 Address_Space_Name        => To_Unbounded_String("Address_Space_01"),
                 core_name                 => To_Unbounded_String("Core_01"),
                 Task_Type                 => Periodic_Type,
                 Start_Time                => 0,
                 Capacity                  => 125,
                 Period                    => 1500,
                 Deadline                  => 1500,
                 Jitter                    => 0,
                 Blocking_Time             => 0,
                 Priority                  => 2,
                 Criticality               => 0,
                 Policy                    => Sched_Fifo,
                 Cache_Access_Profile_Name => empty_string,
                 CFG_Name                  => To_Unbounded_String("CFG_Fac"),
                 Offset                    => offset_t_b);

        Add_Task(My_Tasks                  => a_system.Tasks,
                 A_Task			   => a_task,
                 Name                      => To_Unbounded_String("Task_Fibcall"),
                 Cpu_Name                  => To_Unbounded_String("CPU_01"),
                 Address_Space_Name        => To_Unbounded_String("Address_Space_01"),
                 core_name                 => To_Unbounded_String("Core_01"),
                 Task_Type                 => Periodic_Type,
                 Start_Time                => 0,
                 Capacity                  => 300,
                 Period                    => 1500,
                 Deadline                  => 1500,
                 Jitter                    => 0,
                 Blocking_Time             => 0,
                 Priority                  => 2,
                 Criticality               => 0,
                 Policy                    => Sched_Fifo,
                 Cache_Access_Profile_Name => empty_string,
                 CFG_Name                  => To_Unbounded_String("CFG_Fibcall"),
                 Offset                    => offset_t_c);

        Add_Task(My_Tasks                  => a_system.Tasks,
                 A_Task			   => a_task,
                 Name                      => To_Unbounded_String("Task_InsertSort"),
                 Cpu_Name                  => To_Unbounded_String("CPU_01"),
                 Address_Space_Name        => To_Unbounded_String("Address_Space_01"),
                 core_name                 => To_Unbounded_String("Core_01"),
                 Task_Type                 => Periodic_Type,
                 Start_Time                => 0,
                 Capacity                  => 450,
                 Period                    => 2000,
                 Deadline                  => 2000,
                 Jitter                    => 0,
                 Blocking_Time             => 0,
                 Priority                  => 2,
                 Criticality               => 0,
                 Policy                    => Sched_Fifo,
                 Cache_Access_Profile_Name => empty_string,
                 CFG_Name                  => To_Unbounded_String("CFG_InsertSort"),
                 Offset                    => offset_t_d);

        Put_Line ("------------------------");
        Put_Line ("Write system to xml file");
        Write_To_Xml_File
          (A_System  => a_system,
           File_Name => "framework_examples/cache_analysis_examples/xml/generated_system.xml");
        Put_Line ("Finish write");
        Put_Line ("------------------------");

    end generate_system_with_cache_and_cfg;

    procedure read_system_with_cache_and_cfg
    is
        Sys                   : System;
        Project_File_List     : unbounded_string_list;
        Project_File_Dir_List : unbounded_string_list;
    begin
        -- Initialize the Cheddar framework
        --
        Call_Framework.initialize (False);

        -- Read the XML project file
        --
        initialize (Project_File_List);

        Systems.Read_From_Xml_File (Sys,
                                    Project_File_Dir_List,
                                    "framework_examples/cache_analysis_examples/xml/generated_system.xml");

        Systems.Write_To_Xml_File(A_System  => Sys,
                                  File_Name => "framework_examples/cache_analysis_examples/xml/parsed_system.xml");

        Put_line("");
        Put_line ("=============================================");
        Put_line ("Finish write to framework_examples/cache_analysis_examples/xml/parsed_system.xml");
        Put_line("");

    end read_system_with_cache_and_cfg;

    procedure generate_system_with_harmonic_tasks_and_CAP
      (file_name                 : in Unbounded_String;
       N                		: in Integer	:= 10;
       PU 	       		: in Float	:= 0.70;
       CU 	       		: in Float	:= 5.0;
       CS       	       		: in Integer	:= 256;
       RF	       		: in Float	:= 0.3;
       a_system 			: out System)
    is
        my_tasks         		: Tasks_Set;
        my_cache_access_profiles  : Cache_Access_Profiles_Set;
        -----------------------------------------------------
        my_caches                : Caches_Set;
        cache_replacement        : Cache_Replacement_Policy_Type;
        cache_coherence_protocol : Cache_Coherence_Protocol_Type;
        cache_category           : Cache_Type;

        a_core		  : Core_Unit_Ptr;
        a_cache           : Generic_Cache_Ptr;
        mem_t             : Memories_Table;
    begin
        Set_Initialize;
        Initialize (A_System => a_system);
        cache_replacement        := Cache_Replacement_Policy_Type'Val (0);
        cache_coherence_protocol := Cache_Coherence_Protocol_Type'Val (0);
        cache_category           := Cache_Type'Val (1);


        Add_Cache(my_caches                => a_system.Caches,
                  a_cache                  => a_cache,
                  name                     => To_Unbounded_String ("Cache_01"),
                  cache_size         	   => CS,
                  line_size                => 1,
                  associativity            => 1,
                  block_reload_time        => 1,
                  coherence_protocol 	   => cache_coherence_protocol,
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
                      A_Scheduler    => Rate_Monotonic_Protocol,
                      scheduling_protocol_name => empty_string,
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

        Add_Multiple_Periodic_Tasks_Harmonic_With_Direct_Mapped_Instruction_Cache_Utilization_To_Set_UUniFast
          (my_tasks                 => my_tasks,
           N                        => N,
           PU                       => PU,
           CU                       => CU,
           CS                       => CS,
           RF                       => RF,
           my_cache_access_profiles => my_cache_access_profiles,
           my_instruction_cache     => Instruction_Cache_Ptr(a_cache));

        a_system.Tasks := my_tasks;
        a_system.Cache_Access_Profiles := my_cache_access_profiles;

        Systems.Write_To_Xml_File(A_System  => a_system,
                                  File_Name => file_name);

        Put_line ("=============================================");
        Put_line ("Finish write to:" & To_String(file_name));
        Put_line ("");

    end generate_system_with_harmonic_tasks_and_CAP;

    procedure generate_system_with_periodic_tasks_and_CAP
      (file_name                : in Unbounded_String;
       Min_Period		: in Integer 	:= 10;
       Max_Period		: in Integer    := 500;
       N                	: in Integer	:= 10;
       PU 	       		: in Float	:= 0.70;
       CU 	       		: in Float	:= 5.0;
       CS       	       	: in Integer	:= 256;
       RF	       		: in Float	:= 0.3;
       a_system 		: out System)
    is
        my_tasks         	  : Tasks_Set;
        my_cache_access_profiles  : Cache_Access_Profiles_Set;
        -----------------------------------------------------
        my_caches                : Caches_Set;
        cache_replacement        : Cache_Replacement_Policy_Type;
        cache_coherence_protocol : Cache_Coherence_Protocol_Type;
        cache_category           : Cache_Type;

        a_core		: Core_Unit_Ptr;
        a_cache         : Generic_Cache_Ptr;
        mem_t           : Memories_Table;
    begin
        Set_Initialize;
        Initialize (A_System => a_system);
        cache_replacement        := Cache_Replacement_Policy_Type'Val (0);
        cache_coherence_protocol := Cache_Coherence_Protocol_Type'Val (0);
        cache_category           := Cache_Type'Val (1);


        Add_Cache(my_caches                => a_system.Caches,
                  a_cache                  => a_cache,
                  name                     => To_Unbounded_String ("Cache_01"),
                  cache_size         	   => CS,
                  line_size                => 1,
                  associativity            => 1,
                  block_reload_time        => 1,
                  coherence_protocol 	   => cache_coherence_protocol,
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
                      A_Scheduler    => Rate_Monotonic_Protocol,
                      scheduling_protocol_name => empty_string,
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

        Add_Multiple_Periodic_Tasks_No_Offset_With_Direct_Mapped_Instruction_Cache_Utilization_To_Set_UUniFast
          (my_tasks                 => my_tasks,
           Min_Period 		  => Min_Period,
           Max_Period		  => Max_Period,
           N                        => N,
           PU                       => PU,
           CU                       => CU,
           CS                       => CS,
           RF                       => RF,
           my_cache_access_profiles => my_cache_access_profiles,
           my_instruction_cache     => Instruction_Cache_Ptr(a_cache));

        a_system.Tasks := my_tasks;
        a_system.Cache_Access_Profiles := my_cache_access_profiles;

        Systems.Write_To_Xml_File(A_System  => a_system,
                                  File_Name => file_name);

        Put_line ("=============================================");
        Put_line ("Finish write to:" & To_String(file_name));
        Put_line ("");

    end generate_system_with_periodic_tasks_and_CAP;

end  test_case_generator;
