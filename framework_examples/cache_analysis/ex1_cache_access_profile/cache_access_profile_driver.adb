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
with Cache_Access_Profile_Set;          use Cache_Access_Profile_Set;
with Cache_Access_Profile_Util;         use Cache_Access_Profile_Util;
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

procedure cache_access_profile_driver
is
   Sys                          : System;
   Project_File_List            : unbounded_string_list;
   Project_File_Dir_List        : unbounded_string_list;
   result                       : Unbounded_String;
   A_Cache_Access_Profile       : Cache_Access_Profile_Ptr;
   A_Task                       : Generic_Task_Ptr;
   My_Iterator                  : Tasks_Iterator;

begin
   -- Initialize the Cheddar framework
   --
   Call_Framework.initialize (False);

   -- Read the XML project file
   --

   initialize (Project_File_List);

   Systems.Read_From_Xml_File (Sys,
                               Project_File_Dir_List,
                               "input.xml");

   reset_iterator (Sys.Tasks, My_Iterator);
   loop
      A_Cache_Access_Profile := new Cache_Access_Profile;
      current_element (Sys.Tasks, A_Task, My_Iterator);

      if (A_Task.cfg_name /= empty_string) then
         Basic_Block_Analysis.Compute_Cache_Access_Profile(Sys                    => Sys,
                                                           Task_Name              => A_Task.name,
                                                           A_Cache_Access_Profile => A_Cache_Access_Profile);
      end if;

      exit when is_last_element (Sys.Tasks, My_Iterator);
      next_element (Sys.Tasks, My_Iterator);
   end loop;

   Systems.Write_To_Xml_File(A_System  => Sys,
                             File_Name => "output.xml");
   Put_line("=============================================");
   Put_line("Finish write the system model with computed cache access profiles (UCBs/ECBs) to output.xml");
   Put_line("");

end cache_access_profile_driver;
