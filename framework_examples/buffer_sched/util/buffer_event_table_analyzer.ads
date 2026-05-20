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
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
with unbounded_strings;                 use unbounded_strings;

package buffer_event_table_analyzer is

   procedure Analyze_Buffer_Event_Table
     (Input_System 	: in Unbounded_String;
      Input_Event_Table : in Unbounded_String;
      Sched_Duration    : in Integer;
       Log_Directory    : in Unbounded_String := empty_string);

   procedure Analyze_Buffer_Event_Table
      (Sys 	        : in System;
       Sched            : in Scheduling_Table_Ptr;
       Sched_Duration   : in Integer;
       File_Name 	: in Unbounded_String;
       Log_Directory    : in Unbounded_String := empty_string);

end buffer_event_table_analyzer;
