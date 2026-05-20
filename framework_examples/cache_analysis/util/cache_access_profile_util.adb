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
with test_case_generator;		use test_case_generator;
with scheduling_simulation_util;	use scheduling_simulation_util;

package body cache_access_profile_util is
    package Fix_IO is new Ada.Text_IO.Fixed_IO(DAY_DURATION); use Fix_IO;
    ------------------------------------------------------
    -- Procedure for printing results
    ------------------------------------------------------
    procedure Print_GEN 
      (my_basic_blocks : in Basic_Blocks_Set;
       number_cache_block : in Integer)
    is
        my_iterator : Basic_Blocks_Iterator;
        a_basic_block : Basic_Block_Ptr;
    begin
        Put_Line("");
        Put_Line("======GenCBR");
        reset_iterator(my_basic_blocks,my_iterator);
        loop
            current_element (my_basic_blocks, a_basic_block, my_iterator);
            for i in 0 .. number_cache_block-1 loop
                Put(Basic_Block_UCB_Ptr (a_basic_block).GenCBR.Elements(i),3);
            end loop;
            Put_Line("");
            exit when is_last_element (my_basic_blocks,my_iterator);
            next_element (my_basic_blocks,my_iterator);
        end loop;

        Put_Line("======GenCBL");
        reset_iterator(my_basic_blocks,my_iterator);
        loop
            current_element (my_basic_blocks, a_basic_block, my_iterator);
            for i in 0 .. number_cache_block-1 loop
                Put(Basic_Block_UCB_Ptr (a_basic_block).GenCBL.Elements (i),3);
            end loop;
            Put_Line("");
            exit when is_last_element (my_basic_blocks,my_iterator);
            next_element (my_basic_blocks,my_iterator);
        end loop;

    end Print_GEN;

    procedure Print_RMB
      (my_basic_blocks : in Basic_Blocks_Set;
       number_cache_block : in Integer)
    is
        my_iterator : Basic_Blocks_Iterator;
        a_basic_block : Basic_Block_Ptr;
    begin

        Put_Line("======RMBIn");
        reset_iterator(my_basic_blocks,my_iterator);
        loop
            current_element (my_basic_blocks, a_basic_block, my_iterator);
            Put_Line("Block "& To_String(a_basic_block.name));
            for i in 0 .. number_cache_block-1 loop
                for j in 0 .. Basic_Block_UCB_Ptr (a_basic_block).RMBIn(i).Size-1 loop
                    if(Basic_Block_UCB_Ptr (a_basic_block).RMBIn(i).Elements(j) > -1) then
                        Put(Basic_Block_UCB_Ptr (a_basic_block).RMBIn(i).Elements(j),5);
                    end if;
                end loop;
            end loop;
            Put_Line("");
            exit when is_last_element (my_basic_blocks,my_iterator);
            next_element (my_basic_blocks,my_iterator);
        end loop;

        Put_Line("======RMBOut");
        reset_iterator(my_basic_blocks,my_iterator);
        loop
            current_element (my_basic_blocks, a_basic_block, my_iterator);
            Put_Line("Block "& To_String(a_basic_block.name));
            for i in 0 .. number_cache_block-1 loop
                for j in 0 .. Basic_Block_UCB_Ptr (a_basic_block).RMBOut(i).Size-1 loop
                    if(Basic_Block_UCB_Ptr (a_basic_block).RMBOut(i).Elements(j) > -1) then
                        Put(Basic_Block_UCB_Ptr (a_basic_block).RMBOut(i).Elements(j),5);
                    end if;
                end loop;

            end loop;
            Put_Line("");
            exit when is_last_element (my_basic_blocks,my_iterator);
            next_element (my_basic_blocks,my_iterator);
        end loop;



    end Print_RMB;

    procedure Print_LMB
      (my_basic_blocks : in Basic_Blocks_Set;
       number_cache_block : in Integer)
    is
        my_iterator : Basic_Blocks_Iterator;
        a_basic_block : Basic_Block_Ptr;
    begin
        Put_Line("======LMBIn");
        reset_iterator(my_basic_blocks,my_iterator);
        loop
            current_element (my_basic_blocks, a_basic_block, my_iterator);
            Put_Line("Block "& To_String(a_basic_block.name));
            for i in 0 .. number_cache_block-1 loop
                for j in 0 .. Basic_Block_UCB_Ptr (a_basic_block).LMBIn(i).Size-1 loop
                    if(Basic_Block_UCB_Ptr (a_basic_block).LMBIn(i).Elements(j) > -1)then
                        Put(Basic_Block_UCB_Ptr (a_basic_block).LMBIn(i).Elements(j),5);
                    end if;
                end loop;
                --Put_Line("");
            end loop;
            Put_Line("");
            exit when is_last_element (my_basic_blocks,my_iterator);
            next_element (my_basic_blocks,my_iterator);
        end loop;

        Put_Line("======LMBOut");
        reset_iterator(my_basic_blocks,my_iterator);
        loop
            current_element (my_basic_blocks, a_basic_block, my_iterator);
            Put_Line("Block "& To_String(a_basic_block.name));
            for i in 0 .. number_cache_block-1 loop
                for j in 0 .. Basic_Block_UCB_Ptr (a_basic_block).LMBOut(i).Size-1 loop
                    if(Basic_Block_UCB_Ptr (a_basic_block).LMBOut(i).Elements(j) > -1) then
                        Put(Basic_Block_UCB_Ptr (a_basic_block).LMBOut(i).Elements(j),5);
                    end if;
                end loop;
                --Put_Line("");
            end loop;
            Put_Line("");
            exit when is_last_element (my_basic_blocks,my_iterator);
            next_element (my_basic_blocks,my_iterator);
        end loop;

    end Print_LMB;

    procedure Print_NumberUsefulBlock
      (my_basic_blocks : in Basic_Blocks_Set)
    is
        my_iterator : Basic_Blocks_Iterator;
        a_basic_block : Basic_Block_Ptr;
    begin
        Put_Line("");
        Put_Line("======Number of Useful Block");
        reset_iterator(my_basic_blocks,my_iterator);
        loop
            current_element (my_basic_blocks, a_basic_block, my_iterator);
            Put("Number of useful block -("&To_String(a_basic_block.name)&"): ");
            Put(Basic_Block_UCB_Ptr (a_basic_block).NumberOfUsefulBlock,3);
            Put_Line("");
            exit when is_last_element (my_basic_blocks,my_iterator);
            next_element (my_basic_blocks,my_iterator);
        end loop;

    end Print_NumberUsefulBlock;
       
    procedure Print_CAP      
      (a_cap : in Cache_Access_Profile_Ptr)
    is
    begin
        Put("UCB : ");
        for i in 0 .. a_cap.UCBs.nb_entries-1 loop
            Put(a_cap.UCBs.entries(i).cache_block_number'Img & " ");
        end loop;
        Put_Line("");
        Put("ECB : ");
        for i in 0 .. a_cap.ECBs.nb_entries-1 loop
            Put(a_cap.ECBs.entries(i).cache_block_number'Img & " ");
        end loop;
        Put_Line("");
    end Print_CAP;
    
    procedure Print_Task_CAP
      (a_task : Generic_Task_Ptr;
       a_system : System)
    is
        a_cap : Cache_Access_Profile_Ptr;
    begin
        a_cap := search_cache_access_profile(a_system.cache_access_profiles, a_task.cache_access_profile_name);
        Put_Line(To_String(a_task.name));
        Print_CAP(a_cap);
    end Print_Task_CAP;
    
    ------------------------------------------------------
    --
    ------------------------------------------------------

    procedure compute_cache_access_profile
    is
        Sys                     : System;
        Project_File_List       : unbounded_string_list;
        Project_File_Dir_List   : unbounded_string_list;
        cost_arr                : Integer_Array;
        result 		            : Unbounded_String;
        A_Cache_Access_Profile  : Cache_Access_Profile_Ptr;
        A_Task                  : Generic_Task_Ptr;
        My_Iterator             : Tasks_Iterator;

    begin
        -- Initialize the Cheddar framework
        --
        Call_Framework.initialize (False);

        -- Read the XML project file
        --
        initialize (Project_File_List);

        Systems.Read_From_Xml_File (Sys,
                                    Project_File_Dir_List,
                                    "input.xml");

        reset_iterator (Sys.Tasks, My_Iterator);
        loop
            A_Cache_Access_Profile := new Cache_Access_Profile;
            current_element (Sys.Tasks, A_Task, My_Iterator);

            if (A_Task.cfg_name /= empty_string) then
                Compute_Cache_Access_Profile(Sys                    => Sys,
                                             Task_Name              => A_Task.name,
                                             A_Cache_Access_Profile => A_Cache_Access_Profile);
            end if;

            exit when is_last_element (Sys.Tasks, My_Iterator);
            next_element (Sys.Tasks, My_Iterator);
        end loop;

        Systems.Write_To_Xml_File(A_System  => Sys,
                                  File_Name => "output.xml");
        Put_line("=============================================");
        Put_line("Finish write to output.xml");
        Put_line("");
    end compute_cache_access_profile;

    procedure test_sort_task_set_by_cap
      (file_name         : in Unbounded_String   := To_Unbounded_String("Test");
       N                 : in Integer            := 10;
       PU 	       		: in Float	            := 0.70;
       CU 	       		: in Float	            := 5.0;
       CS                : in Integer            := 256;
       RF                : in Float	            := 0.3)
    is
        sys : System;
        c_Sys : System;
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

        a_cap : Cache_Access_Profile_Ptr;

        sched_result : Natural;
    begin
        Set_Initialize;
        generate_system_with_harmonic_tasks_and_CAP(file_name => file_name,
                                                    N         => N,
                                                    PU        => PU,
                                                    CU        => CU,
                                                    CS        => CS,
                                                    RF        => RF,
                                                    a_system  => sys);
        -----------------------------------------
        --
        -----------------------------------------
        Systems.Read_From_Xml_File (c_Sys,
                                    Project_File_Dir_List,
                                    file_name);

        a_core := Search_core_unit(c_Sys.Core_units,To_Unbounded_String("Core_01"));
        a_core.scheduling.scheduler_type := Posix_1003_Highest_Priority_First_Protocol;
        compute_scheduling_of_tasks_from_ada_sys_model(62500,c_Sys, To_Unbounded_String("HPF.xml"),FALSE,sched_result);


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
            a_task_1.priority := Framework_Config.Priority_Range(ipriority);
            ipriority := ipriority - 1;

            --------------------------------------
            exit when is_last_element (c_Sys.Tasks, i_iterator);
            next_element (c_Sys.Tasks, i_iterator);
        end loop;

        reset_iterator (c_Sys.Tasks, i_iterator);
        loop
            current_element (c_Sys.Tasks, a_task_1, i_iterator);
            --------------------------------------
            Put(a_task_1.name & " " & a_task_1.priority'Img & " ");
            a_cap := Search_Cache_Access_Profile(c_Sys.Cache_Access_Profiles,a_task_1.cache_access_profile_name);
            Put(a_cap.UCBs.Nb_Entries'Img);
            New_Line;
            --------------------------------------
            exit when is_last_element (c_Sys.Tasks, i_iterator);
            next_element (c_Sys.Tasks, i_iterator);
        end loop;

    end test_sort_task_set_by_cap;

    procedure test_simulated_annealing
      (file_name   : in Unbounded_String;
       N           : in Integer	 := 10;
       PU          : in Float	    := 0.70;
       CU          : in Float	    := 5.0;
       CS          : in Integer	 := 256;
       RF          : in Float	    := 0.3;
       H           : in Integer    := 100000)
    is
        sys 			: System;
        a_Sys                   	: System;
        Project_File_Dir_List 	: unbounded_string_list;

        a_core : Core_Unit_Ptr;

        Result : Unbounded_String := empty_string;
        F: Ada.Text_IO.File_Type;

        i_iterator : Tasks_Iterator;
        j_iterator : Tasks_Iterator;
        j1_iterator : Tasks_Iterator;
        ipriority : Natural := 0;

        T,T_min,alpha : Float;

        old_cost, new_cost, i : Integer := 0;

        a : Integer := 0;
        b : Integer := 0;
        ap : Float;

        a_cache : Generic_Cache_Ptr;

        function acceptance_probability(old_cost: in Integer; new_cost: in Integer; T: in Float) return Float
        is
            a : Float;
        begin
            a := Ada.Numerics.Elementary_Functions.Exp(Float((new_cost-old_cost))/T);
            return a;
        end acceptance_probability;

        G		: Ada.Numerics.Float_Random.Generator;

        sched_result : Natural;
    begin
        Set_Initialize;
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
        --extended_core_unit_ptr(a_core).scheduler := new Rm_Scheduler;

        a_cache := Search_Cache(a_Sys.Caches,To_Unbounded_String("Cache_01"));


        compute_scheduling_of_tasks_from_ada_sys_model(H,a_Sys, To_Unbounded_String("RM1.xml"),FALSE,sched_result);
        --TODO: Integrate module Total CRPD computation
        --old_cost := a_Sys.Total_CRPD;
        --Result := Result & To_Unbounded_String(old_cost'Img);

        T := 1.0;
        T_min := 0.05;
        alpha := 0.5;

        --Simulated Annealing
        --
        while (T > T_min) loop
            i := 0;
            while i <= 10 loop
                --Generate new solution
                while (a = b) loop
                    a := Random_Integer(0,9);
                    b := Random_Integer(0,9);
                end loop;
                --TODO: Integrate module Total CRPD computation
                --a_Sys.Total_CRPD := 0;
                swap_tasks_cache_location(a_task       => Search_Task(a_Sys.Tasks,Suppress_Space(To_Unbounded_String("Task" & a'Img))),
                                          b_task       => Search_Task(a_Sys.Tasks,Suppress_Space(To_Unbounded_String("Task" & b'Img))),
                                          CAPs         => a_Sys.Cache_Access_Profiles,
                                          cache_blocks => a_cache.cache_blocks,
                                          CS           => 256);
                compute_scheduling_of_tasks_from_ada_sys_model(H,a_Sys, To_Unbounded_String("RM1.xml"),FALSE, sched_result);

                --Evaluate new solution
                --TODO: Integrate module Total CRPD computation
                --new_cost := a_Sys.Total_CRPD;
                ap := acceptance_probability(old_cost => old_cost,
                                             new_cost => new_cost,
                                             T        => T);

                if ap > Ada.Numerics.Float_Random.Random(G) then
                    old_cost := new_cost;
                else
                    swap_tasks_cache_location(a_task       => Search_Task(a_Sys.Tasks,Suppress_Space(To_Unbounded_String("Task" & b'Img))),
                                              b_task       => Search_Task(a_Sys.Tasks,Suppress_Space(To_Unbounded_String("Task" & a'Img))),
                                              CAPs         => a_Sys.Cache_Access_Profiles,
                                              cache_blocks => a_cache.cache_blocks,
                                              CS           => 256);
                end if;

                i := i + 1;
                T := T*alpha;
            end loop;
        end loop;

        --------------------------------------------------
        Result := Result & To_Unbounded_String(',' & old_cost'Img);

        begin
            Open(F,Ada.Text_IO.Append_File,"result.txt");
        exception
            when Ada.IO_Exceptions.Name_Error =>
                Create(F,Ada.Text_IO.Out_File,"result.txt");
        end;

        Unbounded_IO.Put(F, result);
    end test_simulated_annealing;

end  cache_access_profile_util;
