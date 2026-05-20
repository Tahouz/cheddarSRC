
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

with Text_IO;                          use Text_IO;
with Scheduler_Interface;              use Scheduler_Interface;
with AADL_Parsers;                     use AADL_Parsers;
with v2_Xml_Parsers;
with Xml_generic_Parsers;
with Input_Sources.File;               use Input_Sources.File;
with Sax.Readers;                      use Sax.Readers;
with Offsets;                          use Offsets;
with integer_util;                     use integer_util;
with Tasks;                            use Tasks;
use Tasks.Generic_Task_List_Package;
with CFG_Node_Set.Atomic_Operation_Set; use CFG_Node_Set.Atomic_Operation_Set;
with Atomic_Operations;		use Atomic_Operations;
with Partitioning_Algorithm_Set;		use Partitioning_Algorithm_Set;
with Xml_generic_Parsers.Partitioning_Algorithm; use Xml_generic_Parsers.Partitioning_Algorithm;


package body Partition_Algorithms is

   procedure Delete_Partition_Algorithms (A_AO : in out Partition_Algorithm; A_Partitioning_Algorithm :  Partitioning_Algorithm_Ptr) is
   begin
      delete (A_AO.Partitioning_Algorithms, A_Partitioning_Algorithm);
   end Delete_Partition_Algorithms;

   function XML_String
     (obj   : in Partition_Algorithm;
      level : in Natural := 0)
      return  Unbounded_String
   is
      result : Unbounded_String := empty_string;
   begin
      result := result & "<cheddar>" & ASCII.LF;

      if not is_empty (obj.Partitioning_Algorithms) then
         result := result & ASCII.HT & "<Partitioning_Algorithms>" & ASCII.LF;
         result := result & XML_root_String (obj.Partitioning_Algorithms, 1) & ASCII.LF;
         result := result & ASCII.HT & "</Partitioning_Algorithms>" & ASCII.LF;
      end if;

--      if not is_empty (obj.CFG_Nodes) then
--        result := result & ASCII.HT & "<cfg_nodes>" & ASCII.LF;
--        result := result & XML_root_String (obj.CFG_Nodes, 1) & ASCII.LF;
--         result := result & ASCII.HT & "</cfg_nodes>" & ASCII.LF;
--	end if;

       result := result & "</cheddar>" & ASCII.LF;

      return result;

   end XML_String;

   function XML_String
     (obj   : in AO_Ptr;
      level : in Natural := 0)
      return  Unbounded_String
   is
   begin
      return XML_String (obj.all, level);
   end XML_String;


   procedure Put_Xml
     (A_AO                : in Partition_Algorithm)
   is
   begin

     -- Put (To_String (Export_Xml_Cheddar_Dtd (A_AO)));
      Put (To_String (XML_String (A_AO)));

   end Put_Xml;


   procedure Put (A_AO : in Partition_Algorithm) is
   begin

      Put_Line ("***** LIST OF Partitioning_Algorithms *****");
      put (A_AO.Partitioning_Algorithms);
      New_Line;
      New_Line;
      New_Line;
   end Put;

   procedure Put (A_AO : in AO_Ptr) is
   begin
      Put (A_AO.all);
   end Put;

   ------------------------------------------------

   procedure Initialize (A_AO : in out Partition_Algorithm) is
   begin

        reset (A_AO.Partitioning_Algorithms);

   end Initialize;

   procedure Initialize (A_AO : in AO_Ptr) is
   begin
      Initialize (A_AO.all);
   end Initialize;

   procedure Read_From_Xml_File
     (A_AO  : in out Partition_Algorithm;
      Dir_List  : in unbounded_string_list;
      File_Name : in String)
   is
   begin
      Read_From_Xml_File
        (A_AO,
         Dir_List,
         To_Unbounded_String (File_Name));
   end Read_From_Xml_File;

  procedure Read_From_Xml_File
     (A_AO  : in out Partition_Algorithm;
      Dir_List  : in unbounded_string_list;
      File_Name : in Unbounded_String)
   is

      use Xml_generic_Parsers;
      use Xml_generic_Parsers.Partitioning_Algorithm;
      Read       : File_Input;
      My_Reader  : Xml_Partitioning_Algorithm_Parser;
      Name_Start : Natural;
      S          : constant String := To_String (File_Name);

   begin

      --  Base file name should be used as the public Id
      --
      Name_Start := S'Last;
      while Name_Start >= S'First and then S (Name_Start) /= '/' loop
         Name_Start := Name_Start - 1;
      end loop;
      Set_Public_Id (Read, S (Name_Start + 1 .. S'Last));
      Set_Partition_Algorithm_Id (Read, S);
      Open (S, Read);

      --  xmlns:* attributes will be reported in Start_Element
      --
      Set_Feature (My_Reader, Namespace_Prefixes_Feature, False);
      Set_Feature (My_Reader, Validation_Feature, True);

      Parse (My_Reader, Read);
      A_AO := Get_Parsed_Partitioning_Algorithm (My_Reader);
      Close (Read);

   exception
      when XML_Fatal_Error =>
         Close (Read);
         raise Xml_Read_Error;

   end Read_From_Xml_File;


   procedure Write_To_Xml_File
     (A_AO                : in Partition_Algorithm;
      File_Name               : in String)
   is
   begin
      Write_To_Xml_File
        (A_AO,
         To_Unbounded_String (File_Name));
   end Write_To_Xml_File;


   procedure Write_To_Xml_File
     (A_AO                : in Partition_Algorithm;
      File_Name               : in Unbounded_String) is

      Into : File_Type;

   begin

      -- Open file and Write DTD/XML Header
      --
      Create (Into, Mode => Out_File, Name => To_String (File_Name));

      --Put (Into, To_String (export_Xml_Cheddar_Dtd (A_AO)));
      Put (Into, To_String (Xml_string (A_AO)));

      Close (Into);

   end Write_To_Xml_File;



end Partition_Algorithms;
