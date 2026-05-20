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

with Text_IO;               use Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with parameters;          use parameters;
with parameters.extended; use parameters.extended;
use parameters.framework_parameters_table_package;
with task_set; use task_set;
use task_set.generic_task_set;
with systems;                  use systems;
with call_framework;           use call_framework;
with call_framework_interface; use call_framework_interface;
use call_framework_interface.framework_response_package;
use call_framework_interface.framework_request_package;
with call_scheduling_framework; use call_scheduling_framework;
with GNAT.Command_Line;
with GNAT.OS_Lib;               use GNAT.OS_Lib;
with version;                   use version;
with Ada.Exceptions;            use Ada.Exceptions;
with architecture_models;       use architecture_models;
with architecture_factory;      use architecture_factory;

procedure select_feasibility_test_simple_from_xml is

   -- A set of variables required to call the framework
   --
   response_list         : framework_response_table;
   request_list          : framework_request_table;
   a_request             : framework_request;
   sys                   : system;
   project_file_list     : unbounded_string_list;
   project_file_dir_list : unbounded_string_list;
   into                  : File_Type;

   -- Is the command should run in verbose mode ?
   --
   verbose : Boolean := False;

   -- The XML file to read
   --
   input_file      : Boolean := False;
   input_file_name : Unbounded_String;

   -- The XML file to write
   --compliant_time_triggered_communication (
   output_file      : Boolean := False;
   output_file_name : Unbounded_String;

   -- The defined architecture to analyze
   --
   succeed                   : Boolean := False;
   defined_architecture      : Boolean := False;
   defined_architecture_name : Natural;

   procedure usage is
   begin
      Put_Line
        ("select_feasibility_tests_from_xml is a program which select feasibility tests from an XML  Cheddar project file and save the result into a second XML file.");

      New_Line;
      Put_Line
        ("Check Cheddar home page for details :  http://beru.univ-brest.fr/~singhoff/cheddar ");
      New_Line;
      New_Line;
      Put_Line ("Usage : select_feasibility_tests_from_xml");
      Put_Line ("   switch can be :");
      Put_Line ("            -u get this help");
      Put_Line ("            -v verbose mode ");
      Put_Line
        ("            -o file-name, write the scheduling into the file  file-name ");
      Put_Line
        ("            -i file-name, read the system to analyze from the XML file  file-name ");
      Put_Line
        ("            -a architecture-name, analyze for demonstration from pre-defined example architecture-name ");
      Put_Line ("            architecture-name can be:");
      Put_Line
        ("            (1) compliant_ttc, (2)uncompliant_ttc, (3)compliant_rav, (4)uncompliant_rav, (5)compliant_unpl, (6)uncompliant_unpl, (7)uncompliant_env, (8)uncompliant_buff ");
      New_Line;
   end usage;

begin

   copyright ("select_feasibility_tests_from_xml");

   -- Get arguments
   --
   loop
      case GNAT.Command_Line.Getopt ("u v i: o: a:") is
         when ASCII.NUL =>
            exit;

         when 'i' =>
            input_file      := True;
            input_file_name :=
              To_Unbounded_String (GNAT.Command_Line.Parameter);

         when 'o' =>
            output_file      := True;
            output_file_name :=
              To_Unbounded_String (GNAT.Command_Line.Parameter);
         when 'v' =>
            verbose := True;
         when 'u' =>
            usage;
            OS_Exit (0);
         when 'a' =>
            defined_architecture := True;
            to_natural
              (To_Unbounded_String (GNAT.Command_Line.Parameter),
               defined_architecture_name,
               succeed);
         when others =>
            usage;
            OS_Exit (0);
      end case;
   end loop;

   -- Is an input file and an output file given ???
   --
   if ((not input_file) and (not defined_architecture)) or
     (not output_file) or
     (defined_architecture and input_file)
   then
      usage;
      OS_Exit (0);
   end if;

   -- Initialize the Cheddar framework
   --
   call_framework.initialize (False);

   -- Read the XML project file
   --
   initialize (project_file_list);
   if input_file then
      systems.read_from_xml_file (sys, project_file_dir_list, input_file_name);
   else
      if defined_architecture then
         Put ("valeur de defined architecture : ");
         Put (Integer'image (defined_architecture_name));
         case defined_architecture_name is
            when 1 =>
               compliant_time_triggered_communication (sys);
            when 2 =>
               uncompliant_time_triggered_communication (sys);
            when 3 =>
               compliant_ravenscar (sys);
            when 4 =>
               uncompliant_ravenscar (sys);
            when 5 =>
               compliant_unplugged (sys);
            when 6 =>
               uncompliant_unplugged (sys);
            when 7 =>
               model1 (sys);
            when 8 =>
               uncompliant_buffer (sys);
            when others =>
               usage;
               OS_Exit (0);
         end case;
      end if;
   end if;
   -- Select the feasibility tests for the system given in argument
   --
   initialize (response_list);
   initialize (request_list);
   initialize (a_request);
   a_request.statement := select_feasibility_tests_simple;
   add (request_list, a_request);
   sequential_framework_request (sys, request_list, response_list);

   if verbose then
      Put (To_String (xml_string (sys)));
      Put_Line (To_String (response_list.entries (0).title));
      for j in 0 .. response_list.nb_entries - 1 loop
         Put_Line (To_String (response_list.entries (j).text));
      end loop;
   end if;

   -- Export results into the txt file
   --

   Create (into, Mode => Out_File, Name => To_String (output_file_name));

   New_Line (into);

   Put (into, To_String (xml_string (sys)));
   Put_Line (into, To_String (response_list.entries (0).title));
   for j in 0 .. response_list.nb_entries - 1 loop
      Put_Line (into, To_String (response_list.entries (j).text));
   end loop;

   Close (into);

end select_feasibility_test_simple_from_xml;
