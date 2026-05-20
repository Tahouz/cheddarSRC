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
--    $Rev: 3477 $
--    $Date: 2020-07-13 11:43:48 +0200 (Mon, 13 Jul 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with random_tools; use random_tools;
with Ada.Float_Text_IO;

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
with convert_unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
use unbounded_strings.strings_table_package;
with Ada.Strings;              use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;

with architecture_factory; use architecture_factory;

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;

with task_set;            use task_set;
with tasks;               use tasks;
with systems;             use systems;
with processors;          use processors;
with processor_set;       use processor_set;
with processor_interface; use processor_interface;

with core_units; use core_units;
use core_units.core_units_table_package;
with scheduler_interface; use scheduler_interface;

with address_spaces;    use address_spaces;
with address_space_set; use address_space_set;

with call_framework;           use call_framework;
with call_framework_interface; use call_framework_interface;
use call_framework_interface.framework_response_package;
use call_framework_interface.framework_request_package;
with call_scheduling_framework; use call_scheduling_framework;

with natural_util; use natural_util;
with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;

with pipe_commands;            use pipe_commands;
with Ada.Text_IO;              use Ada.Text_IO;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with unbounded_strings;        use unbounded_strings;
with convert_unbounded_strings;
with Ada.Directories;          use Ada.Directories;

with debug; use debug;

with integer_util; use integer_util;

with resources; use resources;
use resources.resource_accesses;
with float_util; use float_util;
with Dependencies; 		use Dependencies;
with Task_Dependencies; 	use Task_Dependencies;
with Task_Dependencies; 	use Task_Dependencies.Half_Dep_Set;

with MILS_Security;		use MILS_Security;
with result_parser; use result_parser;
with mils_analysis; use mils_analysis;
package body objective_functions_and_feasibility_checks is

   procedure initialize_fitnessfunctions is

   begin
      -- Initialize the list of all possible fitness functions
      --
      for i in 1 .. max_fitness loop
         fitnessfunctions (i).is_selected := 0;
      end loop;

      fitnessfunctions (1).name :=
        To_Unbounded_String ("f1 = preemptions");       -- To Min
      fitnessfunctions (2).name :=
        To_Unbounded_String ("f2 = contextSwitches");   -- To Min
      fitnessfunctions (3).name :=
        To_Unbounded_String ("f3 = tasks");             -- To Min
      fitnessfunctions (4).name :=
        To_Unbounded_String ("f4 = sum(Li) = sum(Di-Ri)");-- To Max --
      fitnessfunctions (5).name :=
        To_Unbounded_String ("f5 = sum(Ri/Di)");        -- To Min
      fitnessfunctions (6).name :=
        To_Unbounded_String ("f6 = min(Li)");           -- To Max --
      fitnessfunctions (7).name :=
        To_Unbounded_String ("f7 = sum(Ri)");           -- To Min
      fitnessfunctions (8).name :=
        To_Unbounded_String ("f8 = max(Ri)");           -- To Min
      fitnessfunctions (9).name :=
        To_Unbounded_String ("f9 = sum(Bi)");           -- To Min
      fitnessfunctions (10).name :=
        To_Unbounded_String ("f10 = max(Bi)");                 -- To Min
      fitnessfunctions (11).name :=
        To_Unbounded_String ("f11 = sharedResources");         -- To Min

      FitnessFunctions(12).Name := To_Unbounded_String("f1 = missedDeadlines");	 -- To Min
      FitnessFunctions(13).Name := To_Unbounded_String("f2 = bellViolations"); 	 -- To Min
      FitnessFunctions(14).Name := To_Unbounded_String("f3 = bibaViolations");	 -- To Min
   end initialize_fitnessfunctions;

   -------------------------------------
   -- Check_Feasibility_of_A_Solution --
   -------------------------------------

   function check_feasibility_of_a_solution
     (s    : in solution;
      eidx : in Natural) return Boolean
   is

      is_feasible                      : Boolean;
      min_periods                      : Integer;
      nb_tasks                         : Integer;
      gcd_periods                      : Integer;
      i                                : Integer;
      nb_functions_in_task_i           : Integer;
      periods_array                    : array (1 .. genes) of Integer;
      initial_taskset                  : tasks_set := initial_system.tasks;
      capacity_i, deadline_i, period_i : Integer;
      total_processor_utilization      : Float;
      a_system                         : system;
      filestream                       : stream;
      command                          : Unbounded_String;
      f                                : Ada.Text_IO.File_Type;
      line                             : Unbounded_String;
      buffer                           : Unbounded_String;

   begin

      is_feasible := True;

      if slaves > 0 then
         if eidx /= 0 then
            create_system (a_system);
            transform_chromosome_to_cheddaradl_model (a_system, s);
         else
            a_system := initial_system;
         end if;
      else
         create_system (a_system);
         transform_chromosome_to_cheddaradl_model (a_system, s);
      end if;

      nb_tasks :=
        Integer
          (get_number_of_task_from_processor
             (a_system.tasks,
              To_Unbounded_String ("processor1")));

      -- 1) Check for each task of the candidate solution that Ci <= Di
      -- 2) Check that the total processor Utilization <= 1
      i                           := 1;
      total_processor_utilization := 0.0;

      while (i <= nb_tasks) and is_feasible loop

         capacity_i :=
           get
             (my_tasks  => a_system.tasks,
              task_name =>
                suppress_space (To_Unbounded_String ("Task" & i'img)),
              param_name => capacity);

         deadline_i :=
           get
             (my_tasks  => a_system.tasks,
              task_name =>
                suppress_space (To_Unbounded_String ("Task" & i'img)),
              param_name => deadline);

         period_i :=
           get
             (my_tasks  => a_system.tasks,
              task_name =>
                suppress_space (To_Unbounded_String ("Task" & i'img)),
              param_name => period);

         if capacity_i > deadline_i then
            is_feasible := False;
         end if;

         total_processor_utilization :=
           total_processor_utilization + Float (capacity_i) / Float (period_i);
         i := i + 1;
      end loop;

      if is_feasible then
         if (total_processor_utilization > 1.0) then
            is_feasible := False;
         end if;
      end if;

      -- 3) check if there are two non-harmonic functions which are
      -- grouped alone in the same task.
      --
      -- this constraint is checked only on candidate solutions
      -- generated by mutation
      -- i.e. if the solution to be checked is the initial design
      -- then we don't verify this constraint and we pass directly
      -- to the scheduling simulation
      if (eidx /= 0) and is_feasible then

         i := 1;

         while (i <= nb_tasks) and is_feasible loop

            nb_functions_in_task_i := 0;

            for j in 1 .. genes loop

               if (s.chrom_task (j) = i) then
                  nb_functions_in_task_i := nb_functions_in_task_i + 1;
                  periods_array (nb_functions_in_task_i) :=
                    get
                      (my_tasks  => initial_taskset,
                       task_name =>
                         suppress_space (To_Unbounded_String ("Task" & j'img)),
                       param_name => period);

               end if;

            end loop;

            if (nb_functions_in_task_i = 2) then

               if (periods_array (1) < periods_array (2)) then
                  min_periods := periods_array (1);
               else
                  min_periods := periods_array (2);
               end if;

               gcd_periods :=
                 integer_util.gcd (periods_array (1), periods_array (2));

               if (min_periods /= gcd_periods) then
                  is_feasible := False;
               end if;

            elsif (nb_functions_in_task_i > 2) then

               min_periods := periods_array (1);

               gcd_periods :=
                 integer_util.gcd (periods_array (1), periods_array (2));

               for j in 2 .. nb_functions_in_task_i loop

                  if (periods_array (j) < min_periods) then

                     min_periods := periods_array (j);

                  end if;

                  if (j < nb_functions_in_task_i) then

                     gcd_periods :=
                       integer_util.gcd (gcd_periods, periods_array (j + 1));

                  end if;

               end loop;

               if (min_periods /= gcd_periods) then
                  is_feasible := False;
               end if;

            else
               is_feasible := True;
            end if;

            i := i + 1;

         end loop;

      end if;

      -- 4) Check the schedulability through scheduling simulation
      if is_feasible then

         write_to_xml_file
           (a_system  => a_system,
            file_name => "candidate_solution" & eidx'img & ".xmlv3");

         command :=
           To_Unbounded_String
             ("~/call_cheddar " &
              hyperperiod_of_initial_taskset'img &
              " candidate_solution\" &
              eidx'img &
              ".xmlv3");

         filestream := execute (To_String (command), read_file);

         loop
            begin
               buffer := read_next (filestream);
            exception
               when pipe_commands.end_of_file =>
                  exit;
            end;
         end loop;

         close (filestream);

         Open (f, Ada.Text_IO.In_File, "Output" & eidx'img & ".txt");
         line := To_Unbounded_String (Get_Line (f));

         if line = "schedulability : true" then
            is_feasible := True;
         else
            is_feasible := False;
         end if;

         Close (f);

      end if;

      return is_feasible;

   end check_feasibility_of_a_solution;



   ------------------
   -- evaluate_F2T --
   ------------------

   procedure evaluate_f2t (s : in out solution; eidx : in Natural) is

      f                              : Ada.Text_IO.File_Type;
      line                           : Unbounded_String;
      buffer                         : Unbounded_String;
      j                              : Integer;
      my_system                      : system;
      hyperperiod_candidate_solution : Integer;

   begin
      j := 0;
      for i in 1 .. max_fitness loop
         if fitnessfunctions (i).is_selected = 1 then
            j := j + 1;
            -- open the file output_eidx.txt
            -- then read the line corresponding to the selected FitnessFunction
            Open
              (File => f,
               Mode => Ada.Text_IO.In_File,
               Name => "Output" & eidx'img & ".txt");

            Ada.Text_IO.Set_Line (File => f, To => Ada.Text_IO.Count (i + 1));
            line := To_Unbounded_String (Get_Line (File => f));
            -- We distinguish the fitness to maximize i.e. (f4 and f6)
            -- in order to make all abjectives for minimization
            -- So, we transforme f4 and f6 as follow :
            -- f4 = Hyperperiod_of_Initial_Taskset - f4
            -- f6 = Hyperperiod_of_Initial_Taskset - f6
            if (i = 4) or (i = 6) then
               s.obj (j) :=
                 Float (hyperperiod_of_initial_taskset) -
                 Float'value
                   (To_String
                      (Unbounded_Slice
                         (line,
                          Length (fitnessfunctions (i).name & " = "),
                          Length (line))));

            else
               s.obj (j) :=
                 Float'value
                   (To_String
                      (Unbounded_Slice
                         (line,
                          Length (fitnessfunctions (i).name & " = "),
                          Length (line))));
            end if;

            Close (File => f);

         end if;

      end loop;

      -- Deleting the file "Output eidx.txt"

      Open
        (File => f,
         Mode => Ada.Text_IO.In_File,
         Name => "Output" & eidx'img & ".txt");
      Ada.Text_IO.Delete (File => f);

      -- Update the Max_hyperperiod taking into account the hyperperiod
      -- of the evaluated candidate solution "s"
      --
      create_system (my_system);
      transform_chromosome_to_cheddaradl_model (my_system, s);
      hyperperiod_candidate_solution :=
        scheduling_period
          (my_system.tasks,
           To_Unbounded_String ("processor1"));
      if max_hyperperiod < hyperperiod_candidate_solution then
         max_hyperperiod := hyperperiod_candidate_solution;
      end if;

   end evaluate_f2t;

end objective_functions_and_feasibility_checks;
