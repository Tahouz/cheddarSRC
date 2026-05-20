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


with Text_IO;                       use Text_IO;
with Ada.Strings.Unbounded;         use Ada.Strings.Unbounded;
with Tasks;			    use Tasks;
with Task_Set;                      use Task_Set;
with Offsets;			    use Offsets;
with Offsets;			    use Offsets.Offsets_Table_Package;
with Offsets.extended;		    use Offsets.extended;
with Tables;
with sets;
with Tasks; 			    use Tasks;
with Systems; 			    use Systems;
with Cache_Access_Profile_Set;      use Cache_Access_Profile_Set;
with Scheduling_Analysis; 	    use Scheduling_Analysis;
with Scheduling_Analysis;	    use Scheduling_Analysis.Task_Release_Records_Table_Package;
with Priority_Assignment.Utility;   use Priority_Assignment.Utility;


package Priority_Assignment_Test_Printer is

   procedure Print_Task
     (a_task : in Generic_Task_Ptr);

   procedure Append_Task_Info_To_Unbounded_String
     (a_task : in Generic_Task_Ptr;
      a_ustring : in out Unbounded_String);

   procedure Append_Tasks_Set_Into_To_Unbounded_String
     (my_tasks : in Tasks_Set;
      my_tasks_info : in out Unbounded_String);

   procedure Append_Cache_Access_Profiles_Info_To_Unbounded_String
     (my_cache_access_profiles : in Cache_Access_Profiles_Set;
      my_cache_access_profile_info : in out Unbounded_String);

   procedure Display_And_Store_Tasks
     (my_tasks : in Tasks_Set;
      my_tasks_info : in out Unbounded_String);

   procedure Display_And_Store_Cache_Access_Profiles
     (my_cache_access_profiles : in Cache_Access_Profiles_Set;
      my_cache_access_profiles_info : in out Unbounded_String);

   procedure Print_Task_Release_Records_Table
     (a_trrt : in Task_Release_Records_Table_Ptr);

   procedure Print_Task_Set
     (my_tasks : Tasks_Set);

   procedure Print_Cache_Access_Profiles_Set
     (my_cache_access_profiles : Cache_Access_Profiles_Set);

   procedure Print_Task_UCB_ECB_Array
     (a_task_ucb_ecb_array : Task_UCB_ECB_Array_Ptr);


end Priority_Assignment_Test_Printer;
