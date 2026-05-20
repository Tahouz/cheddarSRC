
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

------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.IO_Exceptions;                 use Ada.IO_Exceptions;
with GNAT.Current_Exception;            use GNAT.Current_Exception;
with Text_IO;                           use Text_IO;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with unbounded_strings;                 use unbounded_strings;
with Parameters;                        use Parameters;
with Parameters.extended;               use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;
with Call_Framework;                    use Call_Framework;
with Call_Framework_Interface;          use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with Call_Scheduling_Framework;         use Call_Scheduling_Framework;
with Multiprocessor_Services;           use Multiprocessor_Services;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with GNAT.Command_Line;
with GNAT.OS_Lib;                       use GNAT.OS_Lib;
with Version;                           use Version;
with Ada.Exceptions;                    use Ada.Exceptions;
with Atomic_Operation_models;		use Atomic_Operation_models;

with Partition_Algorithms; use Partition_Algorithms;


procedure write_part_algo is

   -- A set of variables to build a model
   --
   part_algo                   	: Partition_Algorithm;
   Project_File_List     	: unbounded_string_list;
   Project_File_Dir_List 	: unbounded_string_list;

   -- Is the command should run in verbose mode ?
   --
   Verbose : Boolean := False;

   procedure Usage is
   begin
      Put_Line ("write_part_algo is a program that generates a XML Cheddar file");

      New_Line;
      Put_Line(
"Check Cheddar home page for details :  http://beru.univ-brest.fr/~singhoff/cheddar "
);
      New_Line;
      New_Line;
      Put_Line ("Usage : write_part_algo ");
      Put_Line ("   switch can be :");
      Put_Line ("            -u get this help");
      Put_Line ("            -v verbose mode ");
      New_Line;
   end Usage;

begin

   Copyright ("write_part_algo");

   -- Get arguments
   --
   loop
      case GNAT.Command_Line.Getopt ("u v ") is
         when ASCII.NUL =>
            exit;
         when 'v' =>
            Verbose := True;
         when 'u' =>
            Usage;
            OS_Exit (0);
         when others =>
            Usage;
            OS_Exit (0);
      end case;
   end loop;

   -- Build architecture model
   --
   model0 (part_algo);

   -- Write the corresponding Cheddar model
   --
   Write_To_Xml_File (part_algo, To_Unbounded_String ("part_algo_cheddar.xml"));

exception

   when others =>
      Put_Line ("Exception name    : " & Exception_Name);
      Put_Line ("Exception message : " & Exception_Message);

end write_part_algo;
