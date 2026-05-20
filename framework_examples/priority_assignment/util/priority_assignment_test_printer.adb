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
with Scheduling_Analysis; 			use Scheduling_Analysis;
with Scheduling_Analysis;			use Scheduling_Analysis.Task_Release_Records_Table_Package;
with Caches;					use Caches.Cache_Blocks_Table_Package;
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
with audsley_opa_crpd_test; 			use audsley_opa_crpd_test;
with Cache_Access_Profile_Set; 			use Cache_Access_Profile_Set;
with priority_assignment.rm; 			use priority_assignment.rm;

package body Priority_Assignment_Test_Printer is

   procedure Print_Task(a_task : in Generic_Task_Ptr)
   is
   begin
      Put_Line(To_String(a_task.name)
               & ASCII.HT & a_task.priority'Img
               & ASCII.HT & a_task.capacity'Img
               & ASCII.HT & a_task.deadline'Img
               & ASCII.HT & a_task.offsets.Entries(0).offset_value'Img
               & ASCII.HT & a_task.cache_access_profile_name);
   end Print_Task;

   procedure Append_Task_Info_To_Unbounded_String
     (a_task : in Generic_Task_Ptr;
      a_ustring : in out Unbounded_String)
   is
   begin
      Append(a_ustring, To_String(a_task.name)
             & ASCII.HT & a_task.priority'Img
             & ASCII.HT & a_task.capacity'Img
             & ASCII.HT & a_task.deadline'Img
             & ASCII.HT & a_task.offsets.Entries(0).offset_value'Img
             & ASCII.HT & a_task.cache_access_profile_name
             & ASCII.LF );
   end Append_Task_Info_To_Unbounded_String;

   procedure Append_Tasks_Set_Into_To_Unbounded_String
     (my_tasks : in Tasks_Set;
      my_tasks_info : in out Unbounded_String)
   is
      a_task : Generic_Task_Ptr;
      my_iterator : Tasks_Iterator;
   begin
      Append(my_tasks_info,"==============================" & ASCII.LF);
      reset_iterator(my_set      => my_tasks,
                     my_iterator => my_iterator);
      loop
         current_element (my_tasks, a_task, my_iterator);

         Append_Task_Info_To_Unbounded_String(a_task, my_tasks_info);

         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;
   end Append_Tasks_Set_Into_To_Unbounded_String;

   procedure Display_And_Store_Tasks
     (my_tasks : in Tasks_Set;
      my_tasks_info : in out Unbounded_String)
   is
      a_task : Generic_Task_Ptr;
      my_iterator : Tasks_Iterator;
   begin
      Append(my_tasks_info,"==============================" & ASCII.LF);
      reset_iterator(my_set      => my_tasks,
                     my_iterator => my_iterator);
      loop
         current_element (my_tasks, a_task, my_iterator);

         Print_Task(a_task);
         Append_Task_Info_To_Unbounded_String(a_task, my_tasks_info);

         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;
   end Display_And_Store_Tasks;

   procedure Display_And_Store_Cache_Access_Profiles
        (my_cache_access_profiles : in Cache_Access_Profiles_Set;
         my_cache_access_profiles_info : in out Unbounded_String)
      is
      begin
         Append(my_cache_access_profiles_info,"==============================" & ASCII.LF);
         Print_Cache_Access_Profiles_Set(my_cache_access_profiles);
         Append_Cache_Access_Profiles_Info_To_Unbounded_String(my_cache_access_profiles,my_cache_access_profiles_info);
   end Display_And_Store_Cache_Access_Profiles;

   procedure Print_Task_Release_Records_Table (a_trrt : in Task_Release_Records_Table_Ptr)
   is
   begin
      for i in 0..a_trrt.Nb_Entries-1 loop
         Ada.Text_IO.Put_Line(To_String(a_trrt.Entries(i).task_name)
                              & " " & a_trrt.Entries(i).release_time'Img
                              & ASCII.HT & a_trrt.Entries(i).capacity'Img
                              & ASCII.HT & a_trrt.Entries(i).finish_time'Img);
      end loop;
      Put_Line("");
   end Print_Task_Release_Records_Table;

   procedure Print_Task_Set(my_tasks : Tasks_Set)
   is
      a_task      : Generic_Task_Ptr;
      my_iterator : Tasks_Iterator;
   begin
      Put_Line("Name"
               & ASCII.HT & "Pi"
               & ASCII.HT & "Ci"
               & ASCII.HT & "Di"
               & ASCII.HT & "Oi"
               & ASCII.HT & "STi");

      reset_iterator(my_set      => my_tasks,
                     my_iterator => my_iterator);
      loop
         current_element (my_tasks, a_task, my_iterator);

         Put_Line(To_String(a_task.name)
                  & ASCII.HT & a_task.priority'Img
                  & ASCII.HT & a_task.capacity'Img
                  & ASCII.HT & a_task.deadline'Img
                  & ASCII.HT & a_task.offsets.Entries(0).offset_value'Img
                  & ASCII.HT & a_task.start_time'Img);

         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;
      Put_Line("");
   end Print_Task_Set;

   procedure Print_Cache_Access_Profiles_Set(my_cache_access_profiles : Cache_Access_Profiles_Set)
   is
      a_cache_access_profile : Cache_Access_Profile_Ptr;
      my_iterator : Cache_Access_Profiles_Iterator;
   begin
      reset_iterator(my_set      => my_cache_access_profiles,
                     my_iterator => my_iterator);
      loop
         current_element (my_cache_access_profiles, a_cache_access_profile, my_iterator);
         Put("UCBs " & a_cache_access_profile.UCBs.Nb_Entries'Img &": ");
         for i in 0..a_cache_access_profile.UCBs.Nb_Entries-1 loop
            Put(a_cache_access_profile.UCBs.Entries(i).cache_block_number'Img & " ");
         end loop;
         Put_Line("");
         Put("ECBs " & a_cache_access_profile.ECBs.Nb_Entries'Img &": ");
         for i in 0..a_cache_access_profile.ECBs.Nb_Entries-1 loop
            Put(a_cache_access_profile.ECBs.Entries(i).cache_block_number'Img & " ");
         end loop;
         Put_Line("");
         Put_Line("---");
         exit when is_last_element (my_cache_access_profiles, my_iterator);
         next_element (my_cache_access_profiles, my_iterator);
      end loop;
      Put_Line("");
   end Print_Cache_Access_Profiles_Set;

   procedure Print_Task_UCB_ECB_Array (a_task_ucb_ecb_array : Task_UCB_ECB_Array_Ptr)
   is
   begin
      for i in 0..a_task_ucb_ecb_array'Length-1 loop
         Put_Line(To_String(a_task_ucb_ecb_array(i).Task_Name) & " - " & a_task_ucb_ecb_array(i).Task_Index'Img);
         Put("UCBs: ");
         for j in 0..a_task_ucb_ecb_array(i).UCBs.Size-1 loop
            Put(a_task_ucb_ecb_array(i).UCBs.Elements(j)'Img);
         end loop;
         New_Line;
         Put("ECBs: ");
         for j in 0..a_task_ucb_ecb_array(i).ECBs.Size-1 loop
            Put(a_task_ucb_ecb_array(i).ECBs.Elements(j)'Img);
         end loop;
         New_Line;
         Put_Line("---");
      end loop;
   end Print_Task_UCB_ECB_Array;

   procedure Append_Cache_Access_Profiles_Info_To_Unbounded_String
     (my_cache_access_profiles : in Cache_Access_Profiles_Set;
      my_cache_access_profile_info : in out Unbounded_String)
   is
      a_cache_access_profile : Cache_Access_Profile_Ptr;
      my_iterator : Cache_Access_Profiles_Iterator;
   begin
      reset_iterator(my_set      => my_cache_access_profiles,
                     my_iterator => my_iterator);
      loop
         current_element (my_cache_access_profiles, a_cache_access_profile, my_iterator);

         Append(my_cache_access_profile_info, a_cache_access_profile.name & ASCII.LF);
         Append(my_cache_access_profile_info, "UCBs: ");
         for i in 0..a_cache_access_profile.UCBs.Nb_Entries-1 loop
            Append(my_cache_access_profile_info, a_cache_access_profile.UCBs.Entries(i).cache_block_number'Img & " ");
         end loop;
         Append(my_cache_access_profile_info, ASCII.LF);
         Append(my_cache_access_profile_info, "ECBs: ");
         for i in 0..a_cache_access_profile.ECBs.Nb_Entries-1 loop
            Append(my_cache_access_profile_info, a_cache_access_profile.ECBs.Entries(i).cache_block_number'Img & " ");
         end loop;
         Append(my_cache_access_profile_info, ASCII.LF);
         Append(my_cache_access_profile_info,"---");
         Append(my_cache_access_profile_info, ASCII.LF);

         exit when is_last_element (my_cache_access_profiles, my_iterator);
         next_element (my_cache_access_profiles, my_iterator);
      end loop;
   end Append_Cache_Access_Profiles_Info_To_Unbounded_String;


end Priority_Assignment_Test_Printer;
