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

with systems;  use systems;
with tasks;    use tasks;
with task_set; use task_set;
use task_set.generic_task_set;
with dependencies;      use dependencies;
with task_dependencies; use task_dependencies;
use task_dependencies.half_dep_set;
with processors;    use processors;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with parameters;          use parameters;
with parameters.extended; use parameters.extended;
use parameters.framework_parameters_table_package;

with framework;                use framework;
with call_framework;           use call_framework;
with call_framework_interface; use call_framework_interface;
use call_framework_interface.framework_response_package;
use call_framework_interface.framework_request_package;
with call_scheduling_framework;         use call_scheduling_framework;
with multiprocessor_services;           use multiprocessor_services;
with multiprocessor_services_interface; use multiprocessor_services_interface;
use multiprocessor_services_interface.scheduling_result_per_processor_package;

with GNAT.Command_Line;
with GNAT.OS_Lib;           use GNAT.OS_Lib;
with debug;                 use debug;
with io_tools;              use io_tools;
with Text_IO;               use Text_IO;
with version;               use version;
with Ada.Exceptions;        use Ada.Exceptions;
with Ada.Numerics.Aux;      use Ada.Numerics.Aux;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;

with feasibility_test.multiprocessor_utilization;
use feasibility_test.multiprocessor_utilization;

procedure feasibility_processor_utilization is

   sys                   : system;
   tasks                 : tasks_set;
   project_file_list     : unbounded_string_list;
   project_file_dir_list : unbounded_string_list;
   validate              : Boolean := False;
   verbose               : Boolean := False;
   input_file            : Boolean := False;
   input_file_name       : Unbounded_String;
   processor_name        : Unbounded_String;
   msg                   : Unbounded_String;
   processor1            : generic_processor_ptr;

   procedure usage is
   begin
      Put_Line
        ("feasibility_processor_utilization computes the feasiblity based on processor utilization bound for multiprocessor of a Cheddar architecture model .");
      New_Line;
      Put_Line
        ("Check Cheddar home page for details :  http://beru.univ-brest.fr/~singhoff/cheddar ");
      New_Line;
      New_Line;
      Put_Line ("Usage : feasibility_processor_utilization [switch] ");
      Put_Line ("   switch can be :");
      Put_Line ("            -u get this help");
      Put_Line ("            -v verbose mode ");
      Put_Line
        ("            -i file-name, read and print the architecture model from the XML file  file-name ");
      Put_Line
        ("            -p name, name is the name of the processor to apply the computation");
      New_Line;
   end usage;

   procedure print_task_set (my_tasks : tasks_set) is
      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;
   begin
      Put_Line
        ("Name" &
         ASCII.HT &
         "Pi" &
         ASCII.HT &
         "Ci" &
         ASCII.HT &
         "Ti" &
         ASCII.HT &
         "Di" &
         ASCII.HT &
         "Oi" &
         ASCII.HT &
         "STi");

      reset_iterator (my_tasks, my_iterator);
      loop
         current_element (my_tasks, a_task, my_iterator);

         Put_Line
           (To_String (a_task.name) &
            ASCII.HT &
            a_task.priority'img &
            ASCII.HT &
            a_task.capacity'img &
            ASCII.HT &
            periodic_task_ptr (a_task).period'img &
            ASCII.HT &
            a_task.deadline'img &
            ASCII.HT &
            a_task.offsets.entries (0).offset_value'img &
            ASCII.HT &
            a_task.start_time'img);

         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;
      Put_Line ("");
   end print_task_set;

begin
   copyright ("feasibility_processor_utilization");

   loop
      case GNAT.Command_Line.Getopt ("u v i:") is
         when ASCII.NUL =>
            exit;
         when 'p' =>
            processor_name :=
              To_Unbounded_String (GNAT.Command_Line.Parameter);
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
   initialize (sys);
   systems.read_from_xml_file (sys, project_file_dir_list, input_file_name);

   tasks := sys.tasks;
   print_task_set (tasks);

   processor1 := search_processor (sys.processors, processor_name);
   calculate_feasibility_processor_bound (sys, processor1, validate, msg);
   Put_Line (validate'img & " " & To_String (msg));

end feasibility_processor_utilization;
