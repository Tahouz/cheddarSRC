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

with Ada.Text_IO;                       use Ada.Text_IO;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with Systems;                           use Systems;
with Initialize_Framework;              use Initialize_Framework;
with Call_Cache_Framework;              use Call_Cache_Framework;
with Unbounded_Strings;                 use Unbounded_strings;
with Unbounded_Strings;                 use Unbounded_Strings.Strings_Table_Package;
with Unbounded_Strings;                 use Unbounded_Strings.Unbounded_String_List_Package;
with Tasks;                             use Tasks;
with Task_Set;                          use Task_Set;
with Caches;                            use Caches;
with Caches;                            use Caches.Cache_Blocks_Table_Package;
with Cache_Block_Set;                   use Cache_Block_Set;
with Call_Framework;                    use Call_Framework;
with Call_Framework_Interface;          use Call_Framework_Interface;
with Call_Scheduling_Framework;         use Call_Scheduling_Framework;
with Basic_Block_Analysis;                       
with Sets;

with Pipe_Commands; use Pipe_Commands;



with Scheduling_Analysis;               use Scheduling_Analysis;
with Time_Unit_Events;                  use Time_Unit_Events;
use Time_Unit_Events.Time_Unit_Package;
use Time_Unit_Events.Time_Unit_Lists_Package;

with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;

with indexed_tables;  
with Multiprocessor_Services; use Multiprocessor_Services;


procedure event
is
   Sys                          : System;
   Project_File_List            : unbounded_string_list;
   Project_File_Dir_List        : unbounded_string_list;
  
   command                      : unbounded_String;
                    
   nb_partitions            : Natural :=2;
   Sched     :  Scheduling_Table_Ptr;
   A_Item  : Time_Unit_Event_ptr;
   result  : Scheduling_Sequence_Ptr;

 

begin
      -- Initialize the Cheddar framework
      --
      Call_Framework.initialize (False);

      -- Read the XML project file
      --

      initialize (Project_File_List);
  
      Systems.Read_From_Xml_File (Sys,
                                  Project_File_Dir_List,
                                  "input.xmlv3");
   
   Sched := new Scheduling_Table;
   Initialize(Sched.all);
      
   Sched.nb_entries:=1;
   Sched.entries(0).data.result.nb_entries := Time_Unit_Events.Time_Unit_Package.indexed_table_range(nb_partitions);
   for i in 1 .. nb_partitions loop
      
      
      A_Item                 := new Time_Unit_Event (address_space_activation);
      A_Item.activation_address_space := To_Unbounded_String("addr"&i'Img);
      A_Item.duration:= 10;
      Time_Unit_Events.Time_Unit_Package.add (Sched.entries(0).data.result.all, i, a_item);
   end loop;
   
   Multiprocessor_Services.Write_To_Xml_File
     (Sched     => Sched,
      Sys       => Sys,
      File_Name => "partition_scheduling.xml");
     

end event;
