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
with Ada.Text_IO, Ada.Integer_Text_IO; 	use Ada.Text_IO, Ada.Integer_Text_IO;
with Ada.Float_Text_IO; 			use Ada.Float_Text_IO;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Strings.Unbounded; 		use Ada.Strings.Unbounded;
with Systems;               		use Systems;
with Caches;                		use Caches;
with Cache_Set;             		use Cache_Set;
with CFG_Nodes; 			use CFG_Nodes.CFG_Nodes_Table_Package;
with CFG_Nodes; 				use CFG_Nodes;
with CFG_Nodes_Builder; 		use CFG_Nodes_Builder;
with initialize_framework; 		use initialize_framework;
with CFG_Set; 				use CFG_Set;
with CFG_Edges; 			use CFG_Edges;
with CFG_Node_Set; 			use CFG_Node_Set;
with CFG_Edge_Set; 			use CFG_Edge_Set;
with unbounded_strings; 		use unbounded_strings;
with unbounded_strings; 		use unbounded_strings.strings_table_package;
with unbounded_strings; 			use unbounded_strings.unbounded_string_list_package;
with Call_Framework; 			use Call_Framework;
with Integer_Arrays; 			use Integer_Arrays;
with Basic_Block_Analysis; 		use Basic_Block_Analysis;
with CFGs; 				use CFGs;
with CFG_Node_Set.Basic_Block_Set; 	use CFG_Node_Set.Basic_Block_Set;
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
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with GNAT.Command_Line;
with GNAT.OS_Lib;                       use GNAT.OS_Lib;
with Version;                           use Version;
with Ada.Exceptions;                    use Ada.Exceptions;
with Time_Unit_Events;                  use Time_Unit_Events;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Directories; 			use Ada.Directories;
with Scheduler; 			use Scheduler;
with architecture_factory;              use architecture_factory;
with Debug; 				use Debug;
with Scheduler.Fixed_Priority.Rm; 	use Scheduler.Fixed_Priority.Rm;
with Scheduler.Dynamic_Priority.Edf; 	use Scheduler.Dynamic_Priority.Edf;
with Scheduler.Fixed_Priority.Hpf; 	use Scheduler.Fixed_Priority.Hpf;
with Framework_Config; 			use Framework_Config;
with Ada.Calendar; 			use Ada.Calendar;
with Ada.Calendar.Formatting; 		use Ada.Calendar.Formatting;
with Cache_Utility; 			use Cache_Utility;
with Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
with Ada.Numerics.Float_Random;
with Caches; 				use Caches.Cache_Blocks_Table_Package;
with Cache_Block_Set; 			use Cache_Block_Set;
with Scheduling_Analysis; 		use Scheduling_Analysis;
with Cache_Access_Profile_Set; 		use Cache_Access_Profile_Set;
with Time_Unit_Events; 			use Time_Unit_Events.Time_Unit_Package;
with test_case_generator; 		use test_case_generator;
with scheduling_simulation_util; 	use scheduling_simulation_util;

package body Feasibility_Interval_Util is

    procedure test_feasibility_interval
      (file_name : in Unbounded_String;
       N         : in Integer	:= 5;
       PU        : in Float	:= 0.70;
       CU        : in Float	:= 2.0;
       CS        : in Integer	:= 8;
       RF        : in Float	:= 0.3)
    is
        sys                   : System;
        a_Sys                 : System;
        b_Sys                 : System;
        c_Sys                 : System;
        Project_File_Dir_List : unbounded_string_list;
        a_core                : Core_Unit_Ptr;
        Result                : Unbounded_String := empty_string;
        F                     : Ada.Text_IO.File_Type;
        i_iterator            : Tasks_Iterator;
        j_iterator            : Tasks_Iterator;
        j1_iterator           : Tasks_Iterator;
        ipriority             : Natural := 0;
        Sched                 : Scheduling_Table_Ptr;
        ETable                : Scheduling_Sequence_Ptr;
        index_P               : Natural := 0;
        sched_result          : Natural;
        H                     : Integer := 0;
        flag                  : Boolean := True;
    begin
        Set_Initialize;
        generate_system_with_harmonic_tasks_and_CAP (file_name => file_name,
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
        Initialize (a_Sys);
        Systems.Read_From_Xml_File (a_Sys,
                                    Project_File_Dir_List,
                                    file_name);

        a_core := Search_core_unit (a_Sys.Core_units, To_Unbounded_String ("Core_01"));
        a_core.scheduling.scheduler_type := Rate_Monotonic_Protocol;


        H := Compute_Hyperperiod(My_Tasks       => a_Sys.Tasks,
                                Processor_Name => To_Unbounded_String ("CPU_01"));

        compute_scheduling_of_tasks_from_ada_sys_model (4*H, a_Sys, To_Unbounded_String ("output.xml"), TRUE, sched_result);

        Put_Line ("===Simulation Complete===");

        --TODO: Integrate module Total CRPD computation + Number of preemption counter
        --Result := Result & a_Sys.Number_Of_Preemption'Img & "," & a_Sys.Total_CRPD'Img & ",";

        Read_From_Xml_File (Sched     => Sched,
                            Sys       => a_Sys,
                            File_Name => "output.xml");

        Put_Line ("===Event Table Complete===");

        ETable := Sched.entries (0).data.result;

        --CHECK if the index is used to store the time unit or not.
        Put_Line (ETable.entries (0).item'Img);
        --CHECK ok :)

        --TODO: Consider to export cache state in event table as an option
        for i in 0 .. ETable.nb_entries - 1 loop
            if (ETable.entries (i).item >= H
                AND ETable.entries (i).item <= 2*H
                AND ETable.entries (i).data.type_of_event = Running_Task) then
                Put_line (ETable.entries (i).item'Img & " - " & ETable.entries (i).data.running_task.name);

                index_P := ETable.entries (i).item + H;

                for j in 0 .. ETable.nb_entries - 1 loop
                    if (ETable.entries (j).item = index_P AND ETable.entries (j).data.type_of_event = Running_Task) then
                        if (ETable.entries (i).data.running_task.name /= ETable.entries (j).data.running_task.name OR
                              ETable.entries (i).data.cache_state /= ETable.entries (j).data.cache_state) then
                            Put_Line ("Different in cache state!");
                            flag := False;
                            exit;
                        else
                            Put_Line ("No different in cache state");
                        end if;
                    end if;
                end loop;
            end if;
        end loop;

        If (flag) then
            Put_Line("2*H is the feasibility interval");
        else
            Put_Line("Different in cache state. 2*H is NOT the feasibility interval");
        end if;

        -----------------------------------------
        -- WRITE FILE
        -----------------------------------------
        --        begin
        --           Open(F,Ada.Text_IO.Append_File,"result.txt");
        --        exception
        --           when Ada.IO_Exceptions.Name_Error =>
        --              Create(F,Ada.Text_IO.Out_File,"result.txt");
        --        end;
        -- Unbounded_IO.Put(F, result);
    end test_feasibility_interval;

end Feasibility_Interval_Util;
