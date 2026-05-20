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

with dependencies;           use dependencies;
with Ada.IO_Exceptions;      use Ada.IO_Exceptions;
with GNAT.Current_Exception; use GNAT.Current_Exception;
with unbounded_strings;      use unbounded_strings;
with GNAT.Command_Line;      use GNAT.Command_Line;
with GNAT.OS_Lib;            use GNAT.OS_Lib;
with Text_IO;                use Text_IO;
with version;                use version;
with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;
with systems;                use systems;
with task_set;               use task_set;
with task_dependencies;      use task_dependencies;
use task_dependencies.half_dep_set;
with processor_set;      use processor_set;
with address_space_set;  use address_space_set;
with resource_set;       use resource_set;
with buffer_set;         use buffer_set;
with network_set;        use network_set;
with event_analyzer_set; use event_analyzer_set;
with message_set;        use message_set;
with call_framework;     use call_framework;
with tasks;              use tasks;
use task_set.generic_task_set;
with debug;         use debug;
with generic_graph; use generic_graph;
use generic_graph.edge_lists_package;
use generic_graph.node_lists_package;
with dp_graph;      use dp_graph;
with dp_graph_view; use dp_graph_view;
use dp_graph_view.graph_list_package;
with architecture_factory;  use architecture_factory;
with architecture_analyzer; use architecture_analyzer;

procedure dp is

   sys : system;

begin

   call_framework.initialize (False);

   initialize (sys);

exception
   when GNAT.Command_Line.Invalid_Switch =>
      begin
         Put_Line ("dp.adb : invalid Switch " & Full_Switch);
      end;
   when GNAT.Command_Line.Invalid_Parameter =>
      Put_Line ("dp.adb : missing parameter for switch " & Full_Switch);

   when task_set.invalid_parameter =>
      Put_Line ("dp.adb : invalid task argument ; " & Exception_Message);
   when address_space_set.invalid_parameter =>
      Put_Line
        ("dp.adb : invalid addresss space argument ; " & Exception_Message);
   when processor_set.invalid_parameter =>
      Put_Line ("dp.adb : invalid processor argument ; " & Exception_Message);
   when buffer_set.invalid_parameter =>
      Put_Line ("dp.adb : invalid buffer argument ; " & Exception_Message);
   when resource_set.invalid_parameter =>
      Put_Line ("dp.adb : invalid resource argument ; " & Exception_Message);

   when Ada.IO_Exceptions.Name_Error =>
      Put_Line ("dp.adb : Can not open project files, Name_Error");
   when Ada.IO_Exceptions.Status_Error =>
      Put_Line ("dp.adb : Can not open project files, Status_Error");
   when Ada.IO_Exceptions.Mode_Error =>
      Put_Line ("dp.adb : Can not open project files, Mode_Error");
   when Ada.IO_Exceptions.Use_Error =>
      Put_Line ("dp.adb : Can not open project files, Use_Error");
   when Ada.IO_Exceptions.Device_Error =>
      Put_Line ("dp.adb : Can not open project files, Device_Error");
   when Ada.IO_Exceptions.End_Error =>
      Put_Line ("dp.adb : Can not open project files, End_Error");
   when Ada.IO_Exceptions.Data_Error =>
      Put_Line ("dp.adb : Can not open project files, Data_Error");
   when Ada.IO_Exceptions.Layout_Error =>
      Put_Line ("dp.adb : Can not open project files, Layout_Error");

   when others =>
      Put_Line ("This is an internal dp bug ... sorry");
      Put_Line ("Exception name : " & Exception_Name);
      Put_Line ("Exception message : " & Exception_Message);
      Put_Line ("Please, send a bug report to cheddar@listes.univ-brest.fr");
      Put_Line
        ("Do not forget to join the XML Cheddar project files with your bug report");

end dp;
