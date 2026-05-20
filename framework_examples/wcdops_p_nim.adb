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

with Ada.Numerics.Aux;      use Ada.Numerics.Aux;
with Text_IO;               use Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO;
with framework_config;      use framework_config;
with processor_set;         use processor_set;
use processor_set.generic_processor_set;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with parameters;          use parameters;
with parameters.extended; use parameters.extended;
use parameters.framework_parameters_table_package;
with scheduling_analysis;
use scheduling_analysis.double_tasks_parameters_package;
with scheduler_interface; use scheduler_interface;
with processor_set;       use processor_set;
use processor_set.generic_processor_set;
with processors;          use processors;
with processor_interface; use processor_interface;
with caches;              use caches;
use caches.caches_table_package;
with core_units; use core_units;
use core_units.core_units_table_package;
with address_space_set; use address_space_set;
use address_space_set.generic_address_space_set;
with task_set; use task_set;
use task_set.generic_task_set;
with offsets;                  use offsets;
with systems;                  use systems;
with call_framework;           use call_framework;
with call_framework_interface; use call_framework_interface;
use call_framework_interface.framework_response_package;
use call_framework_interface.framework_request_package;
with framework;                         use framework;
with call_scheduling_framework;         use call_scheduling_framework;
with multiprocessor_services;           use multiprocessor_services;
with multiprocessor_services_interface; use multiprocessor_services_interface;
use multiprocessor_services_interface.scheduling_result_per_processor_package;
with feasibility_test.transaction_worst_case_response_time;
use feasibility_test.transaction_worst_case_response_time;
with scheduling_analysis; use scheduling_analysis;
with GNAT.Command_Line;
with GNAT.OS_Lib;         use GNAT.OS_Lib;
with version;             use version;
with Ada.Exceptions;      use Ada.Exceptions;
with GNAT.Traceback.Symbolic;

with task_groups;          use task_groups;
with task_group_set;       use task_group_set;
with tasks;                use tasks;
with task_dependencies;    use task_dependencies;
with dependencies;         use dependencies;
with architecture_factory; use architecture_factory;

with task_group_transformation; use task_group_transformation;
with comprehensive_call;

procedure wcdops_p_nim is

   procedure usage is
   begin
      Put_Line
        ("This program reads a Cheddar XML with tree-shaped transactions. It computes response time upper-bounds for tasks in the system and print them in a file.");

      New_Line;

      Put_Line ("Usage : wcdops_nim [options] <cheddar xml file>");
      Put_Line ("  [options] :");
      Put_Line ("    -h This message");
      Put_Line ("    -v Verbose mode");
      Put_Line ("    -o <output file> : String");
      New_Line;
   end usage;

   sys_transaction       : system;
   project_file_list     : unbounded_string_list;
   project_file_dir_list : unbounded_string_list;
   response_times        : response_time_table;
   msg                   : Unbounded_String;

   output_file_name : Unbounded_String := empty_string;
   input_file_name  : Unbounded_String := empty_string;
   f                : Ada.Text_IO.File_Type;

   verbose                 : Boolean := False;
   no_error                : Boolean := False;
   stop_on_deadline_missed : Boolean := False;

begin
   -- Get arguments
   loop
      case GNAT.Command_Line.Getopt ("h v s o:") is
         when ASCII.NUL =>
            no_error := True;
            exit;

         when 'o' =>
            output_file_name :=
              To_Unbounded_String (GNAT.Command_Line.Parameter);

         when 's' =>
            stop_on_deadline_missed := True;

         when 'v' =>
            verbose := True;

         when 'h' =>
            usage;
            OS_Exit (0);

         when others =>
            usage;
            OS_Exit (0);
      end case;
   end loop;

   if not no_error then
      Put_Line ("Error in provided options! Please verify their values.");
      OS_Exit (1);
   end if;

   loop
      declare
         s : constant String :=
           GNAT.Command_Line.Get_Argument (Do_Expansion => True);

      begin
         exit when s'length = 0;
         input_file_name := input_file_name & s;
      end;
   end loop;

   if input_file_name = empty_string then
      Put_Line ("XML file must be provided empty!");
      usage;
      OS_Exit (0);
   end if;

   call_framework.initialize (False);

   initialize (project_file_list);

   if verbose then
      Put_Line ("Reading XML file...");
   end if;

   systems.read_from_xml_file
     (sys_transaction,
      project_file_dir_list,
      input_file_name);

   if verbose then
      Put_Line ("Calling WCDOPS+_NIM test...");
   end if;

   wcdops_plus_nimp
     (sys_transaction,
      msg,
      response_times,
      stop_on_deadline_missed);

   if verbose then
      Put_Line ("Exporting results...");
   end if;

   if output_file_name /= empty_string then
      Create (f, Mode => Out_File, Name => To_String (output_file_name));

      for i in 0 .. response_times.nb_entries - 1 loop
         Unbounded_IO.Put_Line
           (f,
            response_times.entries (i).item.name &
            " " &
            suppress_space
              ("(" &
               periodic_task_ptr (response_times.entries (i).item).jitter'
                 img) &
            ") = " &
            Integer (response_times.entries (i).data)'img);
         Unbounded_IO.Put_Line (f, To_Unbounded_String ("============="));

         if verbose then
            Put_Line
              (To_String (response_times.entries (i).item.name) &
               " " &
               To_String
                 (suppress_space
                    ("(" &
                     periodic_task_ptr (response_times.entries (i).item)
                       .jitter'
                       img)) &
               ") = " &
               Integer (response_times.entries (i).data)'img);
            Put_Line ("=============");
         end if;
      end loop;

      Close (f);
   else
      for i in 0 .. response_times.nb_entries - 1 loop
         Put_Line
           (To_String (response_times.entries (i).item.name) &
            " " &
            To_String
              (suppress_space
                 ("(" &
                  periodic_task_ptr (response_times.entries (i).item).jitter'
                    img)) &
            ") = " &
            Integer (response_times.entries (i).data)'img);
         Put_Line ("=============");
      end loop;
   end if;

   if verbose then
      Put_Line ("All done!");
   end if;

end wcdops_p_nim;
