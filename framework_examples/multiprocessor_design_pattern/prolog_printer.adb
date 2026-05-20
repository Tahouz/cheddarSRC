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

with io_tools;                          use io_tools;
with Text_IO;                           use Text_IO;
with Processor_Set;                     use Processor_Set;
use Processor_Set.Generic_Processor_Set;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with Task_Set;                          use Task_Set;
use Task_Set.Generic_Task_Set;
with tasks;                             use tasks;
with Systems;                           use Systems;
with debug; use debug;
with GNAT.Command_Line;
with GNAT.OS_Lib;                       use GNAT.OS_Lib;
with Version;                           use Version;
with Ada.Exceptions;                    use Ada.Exceptions;
with Ada.Command_Line;                  use Ada.Command_Line;
with Ada.Text_IO.Unbounded_IO;          use Ada.Text_IO.Unbounded_IO;
with Ada.Directories;                   use Ada.Directories;
with prolog_architecture_printer; use  prolog_architecture_printer;
with call_framework;                    use call_framework;


procedure prolog_printer is
   Sys          : System;
   Result	: Unbounded_String;


   -- To read the Cheddar architecture model

   Project_File_List     : unbounded_string_list;
   Project_File_Dir_List : unbounded_string_list;

   -- Should the command run in verbose mode ?
   --
   Verbose : Boolean := False;

   -- The XML file to read
   --
   Input_File      : Boolean := False;
   Input_File_Name : Unbounded_String;

    procedure Usage is
    begin
      Put_Line(
"prolog_printer produces prolog representation of a Cheddar ADL model.");

      New_Line;
      Put_Line(
"Check Cheddar home page for details :  http://beru.univ-brest.fr/~singhoff/cheddar "
);
      New_Line;
      New_Line;
      Put_Line ("Usage : prolog_printer [switch] ");
      Put_Line ("   switch can be :");
      Put_Line ("            -u get this help");
      Put_Line ("            -v verbose mode ");
      Put_Line ("            -i file-name, read and print the architecture model from the XML file  file-name ");
      New_Line;
   end Usage;



begin

   Copyright ("prolog_printer");

   -- Get arguments
   --
   loop
      case GNAT.Command_Line.Getopt ("u v i:") is
         when ASCII.NUL =>
            exit;

         when 'i' =>
            Input_File      := True;
            Input_File_Name :=
              To_Unbounded_String (GNAT.Command_Line.Parameter);

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


   -- Is an input file given ???
   --
   if (not Input_File) then
      Usage;
      OS_Exit (0);
   end if;


   -- Initialize the Cheddar framework
   --
   Call_Framework.initialize (False);

   initialize(Sys);
   Systems.Read_From_Xml_File (Sys, Project_File_Dir_List, Input_File_Name);

   Result:=produce_system(Sys,Input_File_Name);
   Put_Debug("Result in prolog : ");
   Put_Line (To_String(Result));

end prolog_printer;



