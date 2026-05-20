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

with Systems;           use Systems;
with unbounded_strings; use unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
with call_framework; use call_framework;
with framework_config; use framework_config;

with ipc_analysis; use ipc_analysis;

procedure icq is


   sys        : System;

   project_file_dir_list : unbounded_string_list;
   project_file_list     : unbounded_string_list;

   
begin

   -- Initialize the Cheddar framework
   --
   call_framework.initialize (False);

   --  Parse command line
   --
   if Argument_Count /= 1 then
      Put ("Usage: " & Command_Name & " ");
      Put_Line ("InputFilename ");
      GNAT.OS_Lib.OS_Exit (1);
   end if;

   Put_Line("Argument 1/File name       : " & Argument(1));
   
   -- Read the XML project file
   --
   initialize (project_file_list);
   declare 
      File_Name : String := Argument (1);
   begin
      systems.read_from_xml_file (sys, project_file_dir_list,file_name);
   end;

   --Put_Line(compute_tasks_max_latency_intercore_communication (sys,"r1")'Image);


end icq;
