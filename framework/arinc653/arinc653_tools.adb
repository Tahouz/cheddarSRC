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
--    $Rev: 4607 $
--    $Date: 2023-10-26 16:04:40 +0200 (jeu. 26 oct. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Directories; use Ada.Directories;
with Ada.Strings.Unbounded.Text_IO; use Ada.Strings.Unbounded.Text_IO;

package body arinc653_tools is
   --
   procedure Set_Arinc653_Partition_Table_Directory
     (directory : in Unbounded_String)
   is
   begin
      arinc653_partition_table_directory := directory;
   end Set_Arinc653_Partition_Table_Directory;

   --
   function Get_Arinc653_Partition_Table_Directory return Unbounded_String is
   begin
      return arinc653_partition_table_directory;
   end Get_Arinc653_Partition_Table_Directory;

   --
   function Get_Arinc653_Partition_Table_Filename
     (name : in Unbounded_String) return Unbounded_String
   is
      result_file_name : Unbounded_String := empty_string;
   begin
      result_file_name :=
        To_Unbounded_String
          (Ada.Directories.Compose
             (To_String (Get_Arinc653_Partition_Table_Directory),
              To_String (name)));

      return result_file_name;
   end Get_Arinc653_Partition_Table_Filename;
end arinc653_tools;
