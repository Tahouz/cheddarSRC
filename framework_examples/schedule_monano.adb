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

with call_framework;           use call_framework;
with call_framework_interface; use call_framework_interface;
use call_framework_interface.framework_response_package;
use call_framework_interface.framework_request_package;
with framework;                         use framework;
with call_scheduling_framework;         use call_scheduling_framework;
with multiprocessor_services;           use multiprocessor_services;
with multiprocessor_services_interface; use multiprocessor_services_interface;
use multiprocessor_services_interface.scheduling_result_per_processor_package;
with Objects;  use Objects;
with Tasks;    use Tasks;
with Task_Set; use Task_Set;
use task_set.generic_task_set;
with Systems;           use Systems;
with Processors;        use Processors;
with Processor_Set;     use Processor_Set;
with Address_Spaces;    use Address_Spaces;
with Address_Space_Set; use Address_Space_Set;
with Core_Units;        use Core_Units;
use Core_Units.Core_Units_Table_Package;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with parameters;          use parameters;
with parameters.extended; use parameters.extended;
use parameters.framework_parameters_table_package;
with systems;             use systems;
with Processor_Interface; use Processor_Interface;
with Scheduler_Interface; use Scheduler_Interface;

with version;           use version;
with unbounded_strings; use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with Random_Tools;         use Random_Tools;
with architecture_factory; use architecture_factory;
with unbounded_strings;    use unbounded_strings;
with call_framework;       use call_framework;
with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;
with doubles; use doubles;

with scheduling_analysis;          use scheduling_analysis;
with scheduling_analysis.extended; use scheduling_analysis.extended;
with scheduling_analysis.extended.task_analysis;
use scheduling_analysis.extended.task_analysis;
use scheduling_analysis.extended.task_occurence_table_package;

with time_unit_events; use time_unit_events;
use time_unit_events.time_unit_lists_package;
use time_unit_events.time_unit_package;

procedure schedule_monano is

   procedure preemption_delay_from_simulation
     (my_task :        generic_task_ptr; sched : in scheduling_sequence_ptr;
      msg     : in out Unbounded_String; max : in out Natural;
      min     : in out Natural; average : in out Double)
   is

      my_task_occurence_table : task_occurence_table_ptr;
      preemption_delay        : Natural := 0;

   begin
      min     := Natural'Last;
      max     := Natural'First;
      average := 0.0;

      -- Compute all the response times of the task i
      --
      my_task_occurence_table := new task_occurence_table;
      all_response_times_by_simulation
        (my_task, sched, my_task_occurence_table);

      -- We have all response, remove the capacity and you have
      -- the preemption delay
      for i in 0 .. my_task_occurence_table.nb_entries - 1 loop

         preemption_delay :=
           my_task_occurence_table.entries (i).response_time -
           my_task.capacity;

         min     := Natural'Min (preemption_delay, min);
         max     := Natural'Max (preemption_delay, max);
         average := average + double (preemption_delay);

      end loop;
      average := average / double (my_task_occurence_table.nb_entries);

      free (my_task_occurence_table);

   end preemption_delay_from_simulation;

   -- A set of variables required to call the framework
   --
   response_list : framework_response_table;
   request_list  : framework_request_table;
   a_request     : framework_request;
   a_param       : parameter_ptr;

   sys : System;

   project_file_dir_list : unbounded_string_list;
   project_file_list     : unbounded_string_list;

   msg                  : Unbounded_String;
   Feasibility_Interval : Double;
   validate             : Boolean;
   a_processor          : Generic_Processor_Ptr;

   RT : Boolean := False;

   a_task           : generic_task_ptr;
   my_task_iterator : tasks_iterator;
   min              : Natural := 0;
   max              : Natural := 0;
   average          : Double  := 0.0;

begin

   -- Initialize the Cheddar framework
   --
   call_framework.initialize (False);

   --  Parse command line
   --
   if Argument_Count /= 2 then
      Put ("Usage: " & Command_Name & " ");
      Put_Line ("RT Filename");
      GNAT.OS_Lib.OS_Exit (1);
   else
      RT := Boolean'Value (Argument (1));
   end if;

   -- Read the XML project file
   --
   initialize (project_file_list);
   declare
      File_Name : String := Argument (2);
   begin
      systems.read_from_xml_file (sys, project_file_dir_list, file_name);
   end;

   a_processor :=
     search_processor (sys.processors, to_unbounded_string ("processor1"));
   Calculate_feasibility_interval
     (sys, a_processor, validate, Feasibility_Interval, msg);

   Put_Line ("RT= " & RT'Img);
   Put_Line ("Feasibility_Interval : " & Feasibility_Interval'Img);
   Put_Line ("");

   -- Compute the scheduling on the period given by the argument
   --
   initialize (response_list);
   initialize (request_list);
   initialize (a_request);
   a_request.statement    := scheduling_simulation_time_line;
   a_param                := new parameter (integer_parameter);
   a_param.parameter_name := To_Unbounded_String ("period");
   a_param.integer_value  := integer (feasibility_interval);
   add (a_request.param, a_param);
   a_param                := new parameter (boolean_parameter);
   a_param.parameter_name := To_Unbounded_String ("schedule_with_offsets");
   a_param.boolean_value  := True;
   add (a_request.param, a_param);
   a_param                := new parameter (boolean_parameter);
   a_param.parameter_name :=
     To_Unbounded_String ("schedule_with_precedencies");
   a_param.boolean_value := True;
   add (a_request.param, a_param);
   a_param                := new parameter (boolean_parameter);
   a_param.parameter_name := To_Unbounded_String ("schedule_with_resources");
   a_param.boolean_value  := True;
   add (a_request.param, a_param);
   a_param                := new parameter (integer_parameter);
   a_param.parameter_name := To_Unbounded_String ("seed_value");
   a_param.integer_value  := 0;
   add (a_request.param, a_param);
   add (request_list, a_request);
   sequential_framework_request (sys, request_list, response_list);

   if (RT) then
      Put_Line (To_String (response_list.entries (0).title));
      for j in 0 .. response_list.nb_entries - 1 loop
         Put_Line (To_String (response_list.entries (j).text));
      end loop;
   end if;

   initialize (a_request);
   initialize (a_request.param);
   initialize (response_list);
   initialize (request_list);

   a_param                := new parameter (boolean_parameter);
   a_param.parameter_name := To_Unbounded_String ("worst_case");
   a_param.boolean_value  := True;
   add (a_request.param, a_param);

   a_param                := new parameter (boolean_parameter);
   a_param.parameter_name := To_Unbounded_String ("best_case");
   a_param.boolean_value  := True;
   add (a_request.param, a_param);

   a_param                := new parameter (boolean_parameter);
   a_param.parameter_name := To_Unbounded_String ("average_case");
   a_param.boolean_value  := True;
   add (a_request.param, a_param);

   a_request.target    := a_processor.name;
   a_request.statement := scheduling_simulation_response_time;
   add (request_list, a_request);
   sequential_framework_request (sys, request_list, response_list);

   if (RT) then
      for j in 0 .. response_list.nb_entries - 1 loop
         Put_Line (To_String (response_list.entries (j).title));
         Put_Line (To_String (response_list.entries (j).text));
      end loop;
   end if;

   -- Analyze the scheduling to compute preemption delay
   --
   for j in 0 .. sched.nb_entries - 1 loop
      if sched.entries (j).item.name = a_processor.name then

         if
           (get_number_of_task_from_processor (sys.tasks, a_processor.name) >
            0)
         then

            reset_iterator (sys.tasks, my_task_iterator);
            loop
               current_element (sys.tasks, a_task, my_task_iterator);

               preemption_delay_from_simulation
                 (a_task, sched.entries (j).data.result, msg, max, min,
                  average);
               put_line
                 ("PREEMPTION DELAY " & to_string (a_task.name) & max'Img & " " & min'Img & " " &
                  average'Img);

               exit when is_last_element (sys.tasks, my_task_iterator);
               next_element (sys.tasks, my_task_iterator);
            end loop;

         end if;
      end if;
   end loop;

end schedule_monano;
