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

with Text_IO;                   		use Text_IO;
with Ada.Text_IO, Ada.Integer_Text_IO;		use Ada.Text_IO, Ada.Integer_Text_IO;
with Ada.Float_Text_IO;				use Ada.Float_Text_IO;
with Ada.Strings.Unbounded;     		use Ada.Strings.Unbounded;
with Tasks;					use Tasks;
with Tasks;					use Tasks.Generic_Task_List_Package;
with Task_Set;                  		use Task_Set;
with Task_Group_Set;            		use Task_Group_Set;
with Task_Groups; 				use Task_Groups;
with Offsets;					use Offsets;
with Offsets;					use Offsets.Offsets_Table_Package;
with Offsets.extended;				use Offsets.extended;
with Tasks; 					use Tasks;
with Address_Space_Set; 			use Address_Space_Set;
with Address_Space_Set; 			use Address_space_Set.Generic_address_space_Set;
with Scheduler_Interface; 			use Scheduler_Interface;
with processor_interface; 			use processor_interface;
with Priority_Assignment.Audsley_OPA; 		use Priority_Assignment.Audsley_OPA;
with Priority_Assignment.Audsley_OPA_CRPD;	use Priority_Assignment.Audsley_OPA_CRPD;
with Priority_Assignment.Utility;		use Priority_Assignment.Utility;
with architecture_factory; 			use architecture_factory;
with Ada.Calendar; 				use Ada.Calendar;
with Ada.Calendar.Formatting;			use Ada.Calendar.Formatting;
with Random_Tools;				use Random_Tools;
with Framework_Config; 				use Framework_Config;
with Ada.Text_IO.Unbounded_IO; 			use Ada.Text_IO.Unbounded_IO;
with Processors; 				use Processors;
with Systems; 					use Systems;
with Processor_Set; 				use Processor_Set;
with unbounded_strings; 			use unbounded_strings;
with Ada.Directories; 				use Ada.Directories;
with Cache_Set; 				use Cache_Set;
with Caches; 					use Caches;
with Scheduler; 				use Scheduler;
with Core_Units; 				use Core_Units;
with initialize_framework; 			use initialize_framework;
with Priority_Assignment; 			use Priority_Assignment;
with Tasks.Extended; 				use Tasks.Extended;
with Integer_Arrays; 				use Integer_Arrays;
with Debug;					use Debug;
with Ada.IO_Exceptions; 			use Ada.IO_Exceptions;
with Ada.Exceptions;
with Ada.Strings;
with Tables;
with lists;
with sets;
with Ada.Finalization;
with indexed_tables;
with natural_util;
with access_lists;
with binary_trees;
with scheduling_simulation_util; 		use scheduling_simulation_util;
with test_case_generator; 				use test_case_generator;
with audsley_opa_crpd_test; 			use audsley_opa_crpd_test;
with Cache_Access_Profile_Set; 			use Cache_Access_Profile_Set;
with priority_assignment.rm; 			use priority_assignment.rm;
with Priority_Assignment_Test_Printer;  use Priority_Assignment_Test_Printer;

package body Efficiency_Test is

   package Fix_IO is new Ada.Text_IO.Fixed_IO(DAY_DURATION); use Fix_IO;

   procedure generate_test_cases
     (filename  : in Unbounded_String;
      N	        : in Integer;
      PU        : in Float;
      CU        : in Float;
      CS        : in Integer;
      RF        : in Float;
      PU_String : in String)
   is
      sys		: System;
      my_tasks 	  	: Tasks_Set;
      Data : Unbounded_String;
   begin
      Set_Initialize;
      Initialize(my_tasks);
      generate_system_with_periodic_tasks_and_CAP(file_name => filename,
                                         N         => N,
                                         PU        => PU,
                                         CU        => CU,
                                         CS        => CS,
                                         RF        => RF,
                                         a_system  => sys);
      Print_Task_Set(sys.Tasks);

   end generate_test_cases;

   procedure assign_priority
     (Filename  : in String;
      PU_String : in String;
      PA_String : in String;
      Dir_String : in String)
   is
      counter 		: Integer := 1;
      Project_File_Dir_List 	: unbounded_string_list;
      sys 			: System;
      a_core 			: Core_Unit_Ptr;
      Result_PA : Integer := 0;
      Result_SS : Integer := 0;
      default_Period, H : Integer;
      F: Ada.Text_IO.File_Type;
      my_iterator : Tasks_Iterator;
   begin
      -----------------------------------
      -- Start parsing the system
      -----------------------------------
      --Put_Line("============We start here===============");
      Set_Initialize;
      Initialize(sys);
      Systems.Read_From_Xml_File (sys,
                                  Project_File_Dir_List,
                                  Filename);
      Print_Task_Set(sys.Tasks);

      begin
         if(PA_String = "OPA") then
            OPA(sys.Tasks);
         elsif(PA_String = "OPA_CRPD_ECB_Only") then
            CPA(my_tasks                 => sys.Tasks,
                my_cache_access_profiles => sys.Cache_Access_Profiles,
                complexity               => ECB_Only);
         elsif(PA_String = "OPA_CRPD_PT_Simplified") then
            CPA(my_tasks                 => sys.Tasks,
                my_cache_access_profiles => sys.Cache_Access_Profiles,
                complexity               => PT_Simplified);
         elsif(PA_String = "OPA_CRPD_PT_Binomial_Coefficient") then
            CPA(my_tasks                 => sys.Tasks,
                my_cache_access_profiles => sys.Cache_Access_Profiles,
                complexity               => PT_Binomial_Coefficient);
         elsif(PA_String = "OPA_CRPD_Tree") then
            CPA(my_tasks                 => sys.Tasks,
                my_cache_access_profiles => sys.Cache_Access_Profiles,
                complexity               => Tree);
         elsif (PA_String = "RM") then
            Set_Priority_According_To_Rm(sys.Tasks);
         else
            Put_Line("PLEASE CHOOSE A VALID PRIORITY ASSIGNMENT ALGORITHM");
            return;
         end if;

         Result_PA := 1;

         H := Calculate_H(my_tasks => sys.Tasks);
         default_Period := H*2;

         Print_Task_Set(sys.Tasks);

         --SET SCHEDULER TO HPF
         a_core := Search_core_unit(sys.Core_units,To_Unbounded_String("Core_01"));
         a_core.scheduling.scheduler_type := Posix_1003_Highest_Priority_First_Protocol;

         --Put_Line("============Priority Assignment: OK ===============");
         --New_Line;
         compute_scheduling_of_tasks_from_ada_sys_model(default_Period,sys,To_Unbounded_String("PA_TEST"),FALSE,Result_SS);

         Put_Line(Result_PA'Img & " - " & Result_SS'Img);
      exception
         when NO_FEASIBLE_PRIORITY_ASSIGNMENT_EXCEPTION =>
            Result_PA := 0;
            Result_SS := 0;
      end;

      Set_Directory(Dir_String & PU_String & "/");
      begin
         Open(F,Ada.Text_IO.Append_File,PU_String & "_" & PA_String & "_Result.txt");
      exception
         when Ada.IO_Exceptions.Name_Error =>
            Create(F,Ada.Text_IO.Out_File,PU_String & "_" & PA_String & "_Result.txt");
      end;

      Unbounded_IO.Put(F, To_Unbounded_String(Filename & ","));
      Unbounded_IO.Put(F, To_Unbounded_String(Result_PA'Img & ","));
      Unbounded_IO.Put(F, To_Unbounded_String(Result_SS'Img));
      Close(F);
   end assign_priority;

   procedure error_checker
     (Filename  : in String;
      PA_String : in String)
   is
      counter 		: Integer := 1;
      Project_File_Dir_List 	: unbounded_string_list;
      sys 			: System;
      a_core 			: Core_Unit_Ptr;
      Result_PA : Integer := 0;
      Result_SS : Integer := 0;
      default_Period, H : Integer;
      F: Ada.Text_IO.File_Type;
      my_iterator : Tasks_Iterator;
   begin
      -----------------------------------
      -- Start parsing the system
      -----------------------------------
      Set_Initialize;
      Initialize(sys);
      Systems.Read_From_Xml_File (sys,
                                  Project_File_Dir_List,
                                  Filename);
      Print_Task_Set(sys.Tasks);

      begin
         if(PA_String = "OPA") then
            OPA(sys.Tasks);
         elsif(PA_String = "OPA_CRPD_ECB_Only") then
            CPA(my_tasks                 => sys.Tasks,
                my_cache_access_profiles => sys.Cache_Access_Profiles,
                complexity               => ECB_Only);
         elsif(PA_String = "OPA_CRPD_PT_Simplified") then
            CPA(my_tasks                 => sys.Tasks,
                my_cache_access_profiles => sys.Cache_Access_Profiles,
                complexity               => PT_Simplified);
         elsif(PA_String = "OPA_CRPD_PT_Binomial_Coefficient") then
            CPA(my_tasks                 => sys.Tasks,
                my_cache_access_profiles => sys.Cache_Access_Profiles,
                complexity               => PT_Binomial_Coefficient);
         elsif(PA_String = "OPA_CRPD_Tree") then
            CPA(my_tasks                 => sys.Tasks,
                my_cache_access_profiles => sys.Cache_Access_Profiles,
                complexity               => Tree);
         elsif (PA_String = "RM") then
            Set_Priority_According_To_Rm(sys.Tasks);
         else
            Put_Debug("PLEASE CHOOSE A VALID PRIORITY ASSIGNMENT ALGORITHM");
            return;
         end if;

         Result_PA := 1;

         H := Calculate_H(my_tasks => sys.Tasks);
         default_Period := H*2;

         Print_Task_Set(sys.Tasks);

         --SET SCHEDULER TO HPF
         a_core := Search_core_unit(sys.Core_units,To_Unbounded_String("Core_01"));
         a_core.scheduling.scheduler_type := Posix_1003_Highest_Priority_First_Protocol;

         compute_scheduling_of_tasks_from_ada_sys_model(default_Period,sys,To_Unbounded_String("PA_TEST"),FALSE,Result_SS);

         Put_Line(Result_PA'Img & " - " & Result_SS'Img);
      exception
         when NO_FEASIBLE_PRIORITY_ASSIGNMENT_EXCEPTION =>
            Result_PA := 0;
            Result_SS := 0;
            Put_Line(Result_PA'Img & " - " & Result_SS'Img);
      end;

      begin
         Open(F,Ada.Text_IO.Append_File,"Result.txt");
      exception
         when Ada.IO_Exceptions.Name_Error =>
            Create(F,Ada.Text_IO.Out_File,"Result.txt");
      end;

      Unbounded_IO.Put(F, To_Unbounded_String(Filename & ","));
      Unbounded_IO.Put(F, To_Unbounded_String(Result_PA'Img & ","));
      Unbounded_IO.Put(F, To_Unbounded_String(Result_SS'Img));
      Close(F);

      sys.Write_To_Xml_File("write_sys/" & Filename);
   end error_checker;

end Efficiency_Test;

