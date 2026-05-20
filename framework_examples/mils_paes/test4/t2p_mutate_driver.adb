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
with Paes_Utilities;                    use Paes_Utilities;
with Chromosome_Data_Manipulation; use Chromosome_Data_Manipulation;

with Dependencies; 		use Dependencies; 
with Task_Dependencies; 	use Task_Dependencies; 
with Task_Dependencies; 	use Task_Dependencies.Half_Dep_Set;

with Scheduler_Interface; use Scheduler_Interface;

with feasibility_test.feasibility_interval; use feasibility_test.feasibility_interval;
  
procedure t2p_mutate_driver
is
   Sys, Sys1                          : System;
   Project_File_List            : unbounded_string_list;
   Project_File_Dir_List        : unbounded_string_list;
   result                       : Unbounded_String;
--   j                            : Integer;
   
--   sol                          : solution;
   
   My_iterator: Tasks_Dependencies_Iterator;
--   Dep_Ptr: Dependency_Ptr;
--   My_dependencies: Tasks_Dependencies_Ptr;

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
   Initial_System:= Sys;
      genes := 8;
--     for i in 1.. genes loop
--        sol.chrom_task(i):=1;
--     end loop;
--     My_dependencies:= Initial_System.Dependencies;
--     if is_empty( My_dependencies.Depends) then
--        Put_Line("No dependencies");
--     else 
--        j:=1;
--        reset_iterator(My_dependencies.Depends, My_iterator);
--        loop
--           current_element(My_dependencies.Depends, Dep_Ptr, My_iterator);
--           if(Dep_Ptr.type_of_dependency=precedence_dependency)then
--              sol.chrom_com(j).elemt1 := noDW;
--              sol.chrom_com(j).elemt2 := noDW;
--              sol.chrom_com(j).elemt3 := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
--  --            Put_Line("sol.chrom_com(j).elemt3"& To_String(sol.chrom_com(j).elemt3));
--              j := j+1;
--              
--           end if;
--           exit when is_last_element (My_Dependencies.Depends, My_Iterator);
--           next_element (My_Dependencies.Depends, My_Iterator);
--        end loop;
--        genes_com:=j-1;
--     end if;
   Using_preprocessed_initial_sol := False;
   nb_partitions:=2;
   Hyperperiod_of_Initial_Taskset := 4250;
   The_Scheduler:= Hierarchical_Offline_Protocol;
   init_F2T;
   Put_line("=============================================");
   Put_line("mutation");
   Put_line("");
   mutate_F2T(c, 0);
   
   -- Systems.Write_To_Xml_File(A_System  => Sys,
   --                          File_Name => "output.xml");
   Put_line("=============================================");
   Put_line("Finish write the system model to output.xml");
   Put_line("");

end t2p_mutate_driver;
