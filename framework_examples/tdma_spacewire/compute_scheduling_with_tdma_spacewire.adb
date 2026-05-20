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
--    $Date: 2023-09-29 16:02:19 +0200 (ven. 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Exceptions;        use Ada.Exceptions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Command_Line;      use Ada.Command_Line;
with GNAT.Command_Line;
with GNAT.OS_Lib;           use GNAT.OS_Lib;

with call_framework; use call_framework;
with framework;                         use framework;
with Objects;  use Objects;
with Tasks;    use Tasks;
with Task_Set; use Task_Set;
use task_set.generic_task_set;
with Systems;           use Systems;
with Processors;        use Processors;
with systems;             use systems;
with multiprocessor_services; use multiprocessor_services;
with unbounded_strings; use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with Random_Tools;         use Random_Tools;
with framework_config; use framework_config;
with doubles; use doubles;
with natural_util ; use natural_util ; 
with discrete_util; 
with tdma; use tdma;
use tdma.tdma_set;
with spacewire_analysis; use spacewire_analysis;



procedure compute_scheduling_with_tdma_spacewire is


   sys                   : System;

   project_file_dir_list : unbounded_string_list;
   project_file_list     : unbounded_string_list;

   Feasibility_Interval  : Integer;
   Task1_sender          : Generic_Task_Ptr;

   F 		 	 : File_Type;
   
begin

   -- Initialize the Cheddar framework
   --
   call_framework.initialize (False);

   --  Parse command line
   --
   if Argument_Count /= 1 then
      Put ("Usage: " & Command_Name & " ");
      Put_Line ("InputFilename");
      GNAT.OS_Lib.OS_Exit (1);
   end if;


   Put_Line("Argument 1/File name : " & Argument(1));

   
   -- Read the XML project file
   --
   initialize (project_file_list);
   declare 
      File_Name : String := Argument (1);
   begin
      systems.read_from_xml_file (sys, project_file_dir_list,file_name);
   end;

   -- Feasibility interval
   --
   Feasibility_Interval:=30;
   Put_Line ("Feasibility_Interval : " & Feasibility_Interval'Img);

   -- Build TDMA frame
   initialize(sys.tdma_frame);  
   Task1_sender:=search_task(sys.Tasks, 
         to_unbounded_string("Task1_sender"));

   sys.tdma_frame(1).Slot_id := 1;
   sys.tdma_frame(1).start_time := 0;
   sys.tdma_frame(1).duration := 1;

   sys.tdma_frame(2).Slot_id := 2;
   add(sys.tdma_frame(2).emitters, Task1_sender);
   sys.tdma_frame(2).start_time := 1;
   sys.tdma_frame(2).duration := 1;

   sys.tdma_frame(3).Slot_id := 3;
   sys.tdma_frame(3).start_time := 2;
   sys.tdma_frame(3).duration := 10;

   sys.tdma_frame(4).Slot_id := 4;
   add(sys.tdma_frame(4).emitters, Task1_sender);
   sys.tdma_frame(4).start_time := 12;
   sys.tdma_frame(4).duration := 2;

   sys.tdma_frame(5).Slot_id := 5;
   sys.tdma_frame(5).start_time := 14;
   sys.tdma_frame(5).duration := 14;

   sys.tdma_frame(6).Slot_id := 6;
   add(sys.tdma_frame(6).emitters, Task1_sender);
   sys.tdma_frame(6).start_time := 28;
   sys.tdma_frame(6).duration := 2;

 
   -- Compute scheduling only of both processor1 and processor2
   --
   compute_scheduling (sys, to_unbounded_string(""), feasibility_interval);
   display_scheduling(framework.sched);
  
end compute_scheduling_with_tdma_spacewire;









