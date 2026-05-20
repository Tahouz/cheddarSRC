
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
--    $Date: 2023-09-29 16:02:19 +0200 (ven., 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Messages;              use Messages;
with Message_Set;           use Message_Set;
use Message_Set.Generic_Message_Set;
with Buffers;               use Buffers;
with Buffer_Set;            use Buffer_Set;
use Buffer_Set.Generic_Buffer_Set;
with Resource_Set;          use Resource_Set;
use Resource_Set.Generic_Resource_Set;
with Network_Set;           use Network_Set;
use Network_Set.Generic_Network_Set;
with Event_Analyzer_Set;    use Event_Analyzer_Set;
use Event_Analyzer_Set.Generic_Event_Analyzer_Set;
with deployment_Set;          use deployment_Set;
with unbounded_strings;     use unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
with CFG_Node_Set.Atomic_Operation_Set; use CFG_Node_Set.Atomic_Operation_Set;
with Atomic_Operations; 		use Atomic_Operations;
with Partitioning_Algorithm_Set;		use Partitioning_Algorithm_Set;



package Partition_Algorithms  is

   type Partition_Algorithm is tagged record
      CFG_Nodes       	: CFG_Nodes_Set;
      Partitioning_Algorithms : Partitioning_Algorithms_Set;
      Atomic_Operations	      : Atomic_Operations_Set;
      Partitioning_Algorithm :Partitioning_Algorithm_Ptr;
   end record;

   type AO_Ptr is access Partition_Algorithm;

   procedure Initialize (A_AO : in out Partition_Algorithm);

   procedure Initialize (A_AO : in AO_Ptr);

   procedure Delete_Partition_Algorithms
     (A_AO : in out Partition_Algorithm;
      A_Partitioning_Algorithm : Partitioning_Algorithm_Ptr);

   function XML_String
     (obj   : in Partition_Algorithm;
      level : in Natural := 0)
      return  Unbounded_String;
   function XML_String
     (obj   : in AO_Ptr;
      level : in Natural := 0)
      return  Unbounded_String;

   -- Display a system to the screen in different languages
   --
   procedure Put_Xml
     (A_AO               : in Partition_Algorithm);


   -- I/O sub-programs : read/write a system in different languages
   --


   procedure Read_From_Xml_File
     (A_AO  : in out Partition_Algorithm;
      Dir_List  : in unbounded_string_list;
      File_Name : in Unbounded_String);
   procedure Read_From_Xml_File
     (A_AO  : in out Partition_Algorithm;
      Dir_List  : in unbounded_string_list;
      File_Name : in String);

   procedure Write_To_Xml_File
     (A_AO                : in Partition_Algorithm;
      File_Name               : in Unbounded_String);
   procedure Write_To_Xml_File
     (A_AO                : in Partition_Algorithm;
      File_Name               : in String);

end Partition_Algorithms ;
