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

with Ada.IO_Exceptions;      use Ada.IO_Exceptions;
with GNAT.Current_Exception; use GNAT.Current_Exception;
with Text_IO;                use Text_IO;
with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;
with unbounded_strings;      use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with unbounded_strings;   use unbounded_strings;
with parameters;          use parameters;
with parameters.extended; use parameters.extended;
use parameters.framework_parameters_table_package;
with systems;                  use systems;
with call_framework;           use call_framework;
with call_framework_interface; use call_framework_interface;
use call_framework_interface.framework_response_package;
use call_framework_interface.framework_request_package;
with call_scheduling_framework;         use call_scheduling_framework;
with multiprocessor_services;           use multiprocessor_services;
with multiprocessor_services_interface; use multiprocessor_services_interface;
use multiprocessor_services_interface.scheduling_result_per_processor_package;
with GNAT.Command_Line;
with GNAT.OS_Lib;      use GNAT.OS_Lib;
with version;          use version;
with Ada.Exceptions;   use Ada.Exceptions;
with time_unit_events; use time_unit_events;

with architecture_models; use architecture_models;

procedure test_xml is

   sys, syso             : system;
   project_file_list     : unbounded_string_list;
   project_file_dir_list : unbounded_string_list;

   -- Is the command should run in verbose mode ?
   --
   verbose : Boolean := False;

   procedure usage is
   begin
      Put_Line ("test_xml is a program which print/parser XML Cheddar files");

      New_Line;
      Put_Line
        ("Check Cheddar home page for details :  http://beru.univ-brest.fr/~singhoff/cheddar ");
      New_Line;
      New_Line;
      Put_Line ("Usage : test_xml ");
      Put_Line ("   switch can be :");
      Put_Line ("            -u get this help");
      Put_Line ("            -v verbose mode ");
      New_Line;
   end usage;

begin

   copyright ("test_xml");

   -- Initialize the Cheddar framework
   --
   call_framework.initialize (False);

   -- Get arguments
   --
   loop
      case GNAT.Command_Line.Getopt ("u v ") is
         when ASCII.NUL =>
            exit;
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

   loop
      declare
         s : constant String :=
           GNAT.Command_Line.Get_Argument (Do_Expansion => True);

      begin
         exit when s'length = 0;
      end;
   end loop;

   -- Build architecture model
   --
   Put_Line ("Testing architecture test1 ...");
   test1_xml (sys);
   Put_Line ("Testing architecture test2 ...");
   test2_xml (sys);
   write_to_xml_file (sys, "test2.xmlv3");
   Put_Line ("Testing architecture test3 ...");
   test3_xml (sys);
   write_to_xml_file (sys, "test3.xmlv3");
   Put_Line ("Testing architecture test4 ...");
   test4_xml (sys);
   write_to_xml_file (sys, "test4.xmlv3");
   Put_Line ("Testing architecture test5 ...");
   test5_xml (sys);
   write_to_xml_file (sys, "test5.xmlv3");
   Put_Line ("Testing architecture test6 ...");
   test6_xml (sys);
   write_to_xml_file (sys, "test6.xmlv3");
   Put_Line ("Testing architecture test7 ...");
   test7_xml (sys);
   write_to_xml_file (sys, "test7.xmlv3");
   Put_Line ("Testing architecture test8 ...");
   test8_xml (sys);
   write_to_xml_file (sys, "test8.xmlv3");
   Put_Line ("Testing architecture test9 ...");
   test9_xml (sys);
   write_to_xml_file (sys, "test9.xmlv3");
   Put_Line ("Testing architecture test10 ...");
   test10_xml (sys);
   write_to_xml_file (sys, "test10.xmlv3");
   Put_Line ("Testing architecture test13 ...");
   test13_xml (sys);
   write_to_xml_file (sys, "test13.xmlv3");

   Put_Line ("Testing architecture test_network1_xml ...");
   test_network1_xml (sys);
   write_to_xml_file (sys, "test_network1_xml.xmlv3");

   Put_Line ("Testing architecture test_network2_xml ...");
   test_network2_xml (sys);
   write_to_xml_file (sys, "test_network2_xml.xmlv3");

   Put_Line ("Testing architecture csg ...");
   csg_xml (sys);
   write_to_xml_file (sys, "csg_smart.xmlv3");

   Put_Line ("Testing architecture csp ...");
   csg_xml (sys);
   write_to_xml_file (sys, "csp_smart.xmlv3");

   Put_Line ("Testing architecture offset_test1 ...");
   offset_test1 (syso);
   write_to_xml_file (syso, "offset_test1.xmlv3");

   Put_Line ("Testing architecture offset_test2 ...");
   offset_test2 (syso);
   write_to_xml_file (syso, "offset_test2.xmlv3");

   Put_Line ("Testing architecture offset_test3 ...");
   offset_test3 (syso);
   write_to_xml_file (syso, "offset_test3.xmlv3");

   Put_Line ("Testing large models ...");
   task100 (syso);
   write_to_xml_file (syso, "task100.xmlv3");
   task200 (syso);
   write_to_xml_file (syso, "task200.xmlv3");

exception

   when others =>
      Put_Line ("Exception name    : " & Exception_Name);
      Put_Line ("Exception message : " & Exception_Message);

end test_xml;
