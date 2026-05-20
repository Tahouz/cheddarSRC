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
with Scheduling_Analysis; 			use Scheduling_Analysis;
with Scheduling_Analysis;			use Scheduling_Analysis.Task_Release_Records_Table_Package;
with Scheduling_Analysis;			use Scheduling_Analysis.Relative_Priority_Records_Table_Package;
with Priority_Assignment.Audsley_OPA; 		use Priority_Assignment.Audsley_OPA;
with Priority_Assignment.Audsley_OPA_CRPD_Tree;	use Priority_Assignment.Audsley_OPA_CRPD_Tree;
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
with architecture_factory;			use architecture_factory;
with Priority_Assignment.Audsley_OPA_CRPD_PT;	use Priority_Assignment.Audsley_OPA_CRPD_PT;
with Priority_Assignment.Audsley_OPA_CRPD; 	use Priority_Assignment.Audsley_OPA_CRPD;
with Caches;					use Caches.Cache_Blocks_Table_Package;
with Priority_Assignment_Test_Printer;          use Priority_Assignment_Test_Printer;
with Ada.Exceptions;
with binary_trees;
with Tables;
with lists;
with sets;
with Ada.Finalization;
with indexed_tables;
with natural_util;
with access_lists;

package body audsley_opa_crpd_test is

   procedure generate_task_set
   is
      my_tasks         		: Tasks_Set;
      N                		: Integer	:= 5;
      PU 	       		: Float		:= 0.70;
      CU 	       		: Float		:= 5.0;
      CS       	       		: Integer	:= 256;
      RF	       		: Float		:= 0.3;
      my_cache_access_profiles  : Cache_Access_Profiles_Set;
      my_instruction_cache	: Instruction_Cache_Ptr;
      -----------------------------------------------------
   begin
      my_instruction_cache := new Instruction_Cache;

      Add_Multiple_Periodic_Tasks_Harmonic_With_Direct_Mapped_Instruction_Cache_Utilization_To_Set_UUniFast
        (my_tasks                 => my_tasks,
         N                        => N,
         PU                       => PU,
         CU                       => CU,
         CS                       => CS,
         RF                       => RF,
         my_cache_access_profiles => my_cache_access_profiles,
         my_instruction_cache     => my_instruction_cache);

      Print_Task_Set(my_tasks);
      Print_Cache_Access_Profiles_Set(my_cache_access_profiles);

      CPA(my_tasks                 => my_tasks,
          my_cache_access_profiles => my_cache_access_profiles,
          complexity               => PT_Simplified);

      Print_Task_Set(my_tasks);

   end generate_task_set;

end audsley_opa_crpd_test;
