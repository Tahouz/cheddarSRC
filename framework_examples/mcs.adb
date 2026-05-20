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
--    $Rev: 4643 $
--    $Date: 2023-11-27 14:47:11 +0100 (lun., 27 nov. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------


with systems;  use systems;
with tasks;    use tasks;
with task_set; use task_set;
use task_set.generic_task_set;
with dependencies;      use dependencies;
with task_dependencies; use task_dependencies;
use task_dependencies.half_dep_set;
with resources; use resources;
with resource_set; use resource_set;
with processors;    use processors;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with parameters;          use parameters;
with parameters.extended; use parameters.extended;
use parameters.framework_parameters_table_package;
with networks; use networks;
with network_set; use network_set;

with framework;                use framework;
with call_framework;           use call_framework;
with call_framework_interface; use call_framework_interface;
use call_framework_interface.framework_response_package;
use call_framework_interface.framework_request_package;
with call_scheduling_framework;         use call_scheduling_framework;
with spacewire_flow_transformation; use spacewire_flow_transformation;


with GNAT.Command_Line;
with GNAT.OS_Lib;           use GNAT.OS_Lib;
with debug;                 use debug;
with io_tools;              use io_tools;
with Text_IO;               use Text_IO;
with version;               use version;
with Ada.Exceptions;        use Ada.Exceptions;
with doubles;      use doubles;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;



procedure mcs is

   input_sys                   : system;

   project_file_list           : unbounded_string_list;
   project_file_dir_list       : unbounded_string_list;


   verbose : Boolean := False;

   input_file      : Boolean := False;
   input_file_name : Unbounded_String;

   procedure usage is
   begin
      Put_Line
        ("mcs : anytime AMC evaluation tool ");
      New_Line;
      Put_Line
        ("Check Cheddar home page for details :  http://beru.univ-brest.fr/~singhoff/cheddar ");
      New_Line;
      New_Line;
      Put_Line ("Usage : mcs  [switch] ");
      Put_Line ("   switch can be :");
      Put_Line ("            -u get this help");
      Put_Line ("            -v verbose mode ");
      Put_Line
        ("            -i file-name, read the architecture model file-name ");
      New_Line;
   end usage;


begin
   copyright ("mcs ");

   loop
      case GNAT.Command_Line.Getopt ("u v i: ") is
         when ASCII.NUL =>
            exit;
         when 'i' =>
            input_file      := True;
            input_file_name :=
              To_Unbounded_String (GNAT.Command_Line.Parameter);
         when 'v' =>
            verbose := True;
         when 'u' =>
            usage;
            OS_Exit (0);
         when others =>
            usage;
            OS_Exit (0);
      end case;
   end loop;

   if (not input_file) then
      usage;
      OS_Exit (0);
   end if;

   call_framework.initialize (False);
   initialize (input_sys);

   systems.read_from_xml_file (input_sys, project_file_dir_list, input_file_name);

   put_xml(input_sys);


end mcs;
