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
with Ada.Strings.Unbounded;     	use Ada.Strings.Unbounded;
with Tasks;				use Tasks;
with Task_Set;                  	use Task_Set;
with Offsets;				use Offsets;
with Offsets;				use Offsets.Offsets_Table_Package;
with Offsets.extended;			use Offsets.extended;
with Tasks; 				use Tasks;
with Systems; 				use Systems;
with CFG_Node_Set.Basic_Block_Set; 	use CFG_Node_Set.Basic_Block_Set;
with Tables;
with sets;

package scheduling_simulation_util is

   procedure compute_scheduling_of_tasks_from_ada_sys_model
     (Period 		: in Natural;
      Sys 		: in out System;
      Output_File_Name 	: in Unbounded_String;
      Export_Data 	: in Boolean := FALSE;
      Result 		: out Natural);

   -------------------------------------
   -- TEST with case study
   -------------------------------------

   procedure build_case_study_CAP
     (a_system : in out System);

   procedure test_cache_aware_scheduling_simulator_with_case_study;

   -------------------------------------
   -- TEST with randomly generated task set.
   -------------------------------------

   procedure test_cache_aware_scheduling_simulator_with_random_task_set_and_PA
     (file_name                 : in Unbounded_String;
      N                		: in Integer	:= 10;
      PU 	       		: in Float	:= 0.70;
      CU 	       		: in Float	:= 5.0;
      CS       	       		: in Integer	:= 256;
      RF	       		: in Float	:= 0.3);

   procedure Test_Cache_Aware_Scheduling_Simulator_Computation_Time
     (file_name                 : in Unbounded_String;
      N                		: in Integer	:= 10;
      PU 	       		: in Float	:= 0.70;
      CU 	       		: in Float	:= 5.0;
      CS       	       		: in Integer	:= 256;
      RF	       		: in Float	:= 0.3;
      H 			: in Integer    := 100000;
      With_Harmonic_Tasks 	: in Boolean);

   -------------------------------------
   --
   -------------------------------------

   procedure offset_to_start_time
     (my_tasks                 : in Tasks_Set);

end scheduling_simulation_util;
