------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Cheddar is a GNU GPL real-time scheduling analysis tool.
-- This program provides services to automatically check schedulability and
-- other performance criteria of real-time architecture models.
--
-- Copyright (C) 2002-2016, Frank Singhoff, Alain Plantec, Jerome Legrand
--
-- The Cheddar project was started in 2002 by
-- Frank Singhoff, Lab-STICC UMR 6285 laboratory, Université de Bretagne Occidentale
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
--    $Rev: 3561 $
--    $Date: 2020-11-02 08:25:02 +0100 (Mon, 02 Nov 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

with Ada.Strings;               use Ada.Strings;
with Ada.Strings.Fixed;         use Ada.Strings.Fixed;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with unbounded_strings;         use unbounded_strings;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;

with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with unbounded_strings;        use unbounded_strings;
with Ada.Strings;              use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with Ada.Directories;          use Ada.Directories;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with unbounded_strings;        use unbounded_strings;
with convert_unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
use unbounded_strings.strings_table_package;
with Ada.Strings;              use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;

with Dependencies;      use Dependencies;
with task_dependencies; use task_dependencies;
with task_dependencies; use task_dependencies.half_dep_set;
with message_set;       use message_set;
with Messages;          use Messages;

with Tasks;        use Tasks;
with task_set;     use task_set;
with Resources;    use Resources;
with resource_set; use resource_set;
with Objects;      use Objects;
with convert_unbounded_strings;
use unbounded_strings.unbounded_string_list_package;

with Scheduler_Interface; use Scheduler_Interface;
with Address_Spaces;      use Address_Spaces;
with address_space_set;   use address_space_set;

with call_framework;           use call_framework;
with Call_Framework_Interface; use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with call_scheduling_framework; use call_scheduling_framework;

with pipe_commands; use pipe_commands;
with Ada.Text_IO;   use Ada.Text_IO;

with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with Ada.Directories;          use Ada.Directories;

with GNAT.OS_Lib; use GNAT.OS_Lib;
with debug;       use debug;

with random_tools; use random_tools;

use unbounded_strings.strings_table_package;

with architecture_factory; use architecture_factory;

with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;

with task_set;            use task_set;
with systems;             use systems;
with Processors;          use Processors;
with processor_set;       use processor_set;
with Processor_Interface; use Processor_Interface;
use processor_set.generic_processor_set;

with Core_Units; use Core_Units;
use Core_Units.Core_Units_Table_Package;

with natural_util; use natural_util;
with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;

with integer_util; use integer_util;

use Resources.Resource_Accesses;
with float_util; use float_util;

with Ada.Characters.Latin_1; use Ada.Characters;
with Ada.Text_IO;            use Ada.Text_IO;
with GNAT.String_Split;      use GNAT;
with MILS_Security;          use MILS_Security;

with random_tools; use random_tools;
with Memories;     use Memories;
with Paes.objective_functions.t2p_and_security;
use Paes.objective_functions.t2p_and_security;
with Paes.security_implementation; use Paes.security_implementation;
package body Paes.chromosome_Data_Manipulation_t2p_and_security is

   --------------
   -- init_T2P --
   --------------

   procedure init_T2P is
      F           : Ada.Text_IO.File_Type;
      gene_i      : Unbounded_String;
      gene_task_i : Unbounded_String;
      gene_com_i  : Unbounded_String;
      chrom_str   : Unbounded_String;
      --  Subs is populated by the actual substrings.
      Subs : String_Split.Slice_Set;
      --  just an arbitrary simple set of whitespace.
      Seps : constant String := " " & Latin_1.HT;
      j, k, m, l, itr, part, full              : Integer;
      My_iterator                              : tasks_dependencies_iterator;
      Dep_Ptr                                  : dependency_ptr;
      My_dependencies                          : tasks_dependencies_ptr;
      A_task_i                                 : generic_task_ptr;
      Sys1, Sys2, Sys3, Sys4, Sys5, Sys6, Sys7 : systems.system;
   begin

      sol_init1 := new solution_t2p;
      sol_init2 := new solution_t2p;
      sol_init3 := new solution_t2p;
      sol_init4 := new solution_t2p;
      sol_init5 := new solution_t2p;
      sol_init6 := new solution_t2p;
      if Using_preprocessed_initial_sol then
         -- Initialize the current solution c with the preprocessed
         -- initial solution

         -- 1/ get the chromosome of the preprocessed initial solution
         -- from the file chrom_preprocessed_initial_solution.txt
         Open
           (File => F,
            Mode => Ada.Text_IO.In_File,
            Name => "chrom_preprocessed_initial_solution.txt");

         loop
            exit when Ada.Text_IO.End_Of_File (F);
            Ada.Strings.Unbounded.Append
              (chrom_str,
               To_Unbounded_String (Get_Line (File => F)));
         end loop;
         Close (F);
         put_debug ("chrom_str: " & To_String (chrom_str));
         -- 2/ extract gene values from chrom_str to initialize the
         -- initial current solution
         -- The following code is inspired from:
         -- http://wiki.ada-dk.org/gnat.string_split_basic_usage_example
         String_Split.Create
           (S          => Subs,
            From       => To_String (chrom_str),
            Separators => Seps,
            Mode       => String_Split.Multiple);
         for i in 1 .. genes loop
            solution_t2p_ptr (c).chrom_task (i) :=
              Integer'value
                (String_Split.Slice (Subs, String_Split.Slice_Number (i + 1)));
         end loop;
         Put ("The initial preprocessed solution: ");
         print_genome (solution_t2p (c.all));

      else

         for n in 1 .. 15 loop
            nb_secu_conf_choice (n) := 0;
         end loop;

         nb_InitSol        := 0;
         nb_NoFeasible_Sol := 0;

         --initialize sol_init2: split equally the tasks into nb_partitions--
         full := genes;
         l    := 1;
         m    := 0;
         itr  := 0;
         for i in 0 .. nb_partitions - 1 loop
            part := full / (nb_partitions - i);
            full := full - part;
            for m in itr + 1 .. itr + part loop
               sol_init2.chrom_task (m) := l;
            end loop;
            l   := l + 1;
            itr := itr + part;

         end loop;

         for i in 1 .. genes loop

            solution_t2p_ptr (c).chrom_task (i) :=
              1;    --All the tasks in the same partition
            sol_init1.chrom_task (i) :=
              1;  --All the tasks in the same partition

            A_task_i :=
              search_task (Initial_System.tasks, suppress_space (i'img));

            -- all tasks with the same confidentiality level should be put in the same partition
            if (A_task_i.mils_confidentiality_level = top_secret) then
               sol_init3.chrom_task (i) := 1;
               sol_init4.chrom_task (i) := 1;
            elsif (A_task_i.mils_confidentiality_level = secret) then
               sol_init3.chrom_task (i) := 2;
               sol_init4.chrom_task (i) := 2;
            elsif (A_task_i.mils_confidentiality_level = classified) then
               sol_init3.chrom_task (i) := 3;
               sol_init4.chrom_task (i) := 3;
            else
               sol_init3.chrom_task (i) := 4;
               sol_init4.chrom_task (i) := 4;
            end if;

-- all tasks with the same integrity level should be put in the same partition

            if (A_task_i.mils_integrity_level = high) then
               sol_init5.chrom_task (i) := 1;
               sol_init6.chrom_task (i) := 1;
            elsif (A_task_i.mils_integrity_level = medium) then
               sol_init5.chrom_task (i) := 2;
               sol_init6.chrom_task (i) := 2;
            else
               sol_init5.chrom_task (i) := 3;
               sol_init6.chrom_task (i) := 3;
            end if;

         end loop;

         New_Line;

         My_dependencies := Initial_System.dependencies;
         if is_empty (My_dependencies.depends) then
            put_debug ("No dependencies");
         else
            j := 1;
            k := 1;
            reset_iterator (My_dependencies.depends, My_iterator);
            loop
               current_element (My_dependencies.depends, Dep_Ptr, My_iterator);
               if (Dep_Ptr.type_of_dependency = precedence_dependency) then
                  if
                    ((Dep_Ptr.precedence_sink.mils_confidentiality_level =
                      unclassified) and
                     ((Dep_Ptr.precedence_source.mils_confidentiality_level =
                       secret) or
                      (Dep_Ptr.precedence_source.mils_confidentiality_level =
                       top_secret))) or
                    ((Dep_Ptr.precedence_source.mils_integrity_level = low) and
                     ((Dep_Ptr.precedence_sink.mils_integrity_level =
                       medium) or
                      (Dep_Ptr.precedence_sink.mils_integrity_level = high)))
                  then
                     -- Resolve confidentiality and integrity constraints problem (communications high)

                     solution_t2p_ptr (c).chrom_com (j).mode        := secure;
                     solution_t2p_ptr (c).chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init1.chrom_com (j).mode        := secure;
                     sol_init1.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init2.chrom_com (j).mode        := secure;
                     sol_init2.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init3.chrom_com (j).mode        := secure;
                     sol_init3.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init4.chrom_com (j).mode        := secure;
                     sol_init4.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init5.chrom_com (j).mode        := secure;
                     sol_init5.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init6.chrom_com (j).mode        := secure;
                     sol_init6.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                  elsif
                    (Dep_Ptr.precedence_sink.mils_confidentiality_level <
                     Dep_Ptr.precedence_source.mils_confidentiality_level) or
                    (Dep_Ptr.precedence_source.mils_integrity_level <
                     Dep_Ptr.precedence_sink.mils_integrity_level)
                  then
                     -- resolve security problems of solutions c, sol_init4, sol_init6  (communications Low)
                     k := k + 1;

                     solution_t2p_ptr (c).chrom_com (j).mode        := secure;
                     solution_t2p_ptr (c).chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init4.chrom_com (j).mode        := secure;
                     sol_init4.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init6.chrom_com (j).mode        := secure;
                     sol_init6.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     -- ignore security problems of solutions sol_init1, sol_init2, sol_init3, sol_init5   (communications Low)
                     if (intra_partition_safe = 0) then
                  -- intra partition communications consider as non attackable
                        sol_init1.chrom_com (j).mode :=
                          secure; --all tasks are in the same partition
                        if
                          (sol_init2.chrom_com
                             (Integer'value
                                (To_String (Dep_Ptr.precedence_source.name))) =
                           sol_init2.chrom_com
                             (Integer'value
                                (To_String (Dep_Ptr.precedence_sink.name))))
                        then
                           sol_init2.chrom_com (j).mode := secure;
                        else
                           sol_init2.chrom_com (j).mode := nosecure;
                        end if;
                        if
                          (sol_init2.chrom_com
                             (Integer'value
                                (To_String (Dep_Ptr.precedence_source.name))) =
                           sol_init3.chrom_com
                             (Integer'value
                                (To_String (Dep_Ptr.precedence_sink.name))))
                        then
                           sol_init3.chrom_com (j).mode := secure;
                        else
                           sol_init3.chrom_com (j).mode := nosecure;
                        end if;
                        if
                          (sol_init5.chrom_com
                             (Integer'value
                                (To_String (Dep_Ptr.precedence_source.name))) =
                           sol_init5.chrom_com
                             (Integer'value
                                (To_String (Dep_Ptr.precedence_sink.name))))
                        then
                           sol_init5.chrom_com (j).mode := secure;
                        else
                           sol_init5.chrom_com (j).mode := nosecure;
                        end if;

                     else
                        sol_init1.chrom_com (j).mode := nosecure;
                        sol_init2.chrom_com (j).mode := nosecure;
                        sol_init3.chrom_com (j).mode := nosecure;
                        sol_init5.chrom_com (j).mode := nosecure;
                     end if;

                     sol_init1.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init2.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init3.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init5.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                  else
                     -- specify communications with no security problems for all the initial solutions
                     solution_t2p_ptr (c).chrom_com (j).mode        := norisk;
                     solution_t2p_ptr (c).chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init4.chrom_com (j).mode        := norisk;
                     sol_init4.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init6.chrom_com (j).mode        := norisk;
                     sol_init6.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init1.chrom_com (j).mode        := norisk;
                     sol_init1.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init2.chrom_com (j).mode        := norisk;
                     sol_init2.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init3.chrom_com (j).mode        := norisk;
                     sol_init3.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     sol_init5.chrom_com (j).mode        := norisk;
                     sol_init5.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                  end if;
                  j := j + 1;
               end if;
               exit when is_last_element
                   (My_dependencies.depends,
                    My_iterator);
               next_element (My_dependencies.depends, My_iterator);
            end loop;

         end if;
      end if;
      -- Normalize the tasks to partitions assignment
      normalize (solution_t2p (sol_init3.all));
      normalize (solution_t2p (sol_init4.all));
      normalize (solution_t2p (sol_init5.all));
      normalize (solution_t2p (sol_init6.all));
      put_debug ("===============c================");
      --Print the chromosome of the initial solutions
      print_genome (solution_t2p (c.all));
      put_debug ("===============sol_init1================");
      print_genome (solution_t2p (sol_init1.all));
      put_debug ("===============sol_init2================");
      print_genome (solution_t2p (sol_init2.all));
      put_debug ("===============sol_init3================");
      print_genome (solution_t2p (sol_init3.all));
      put_debug ("===============sol_init4================");
      print_genome (solution_t2p (sol_init4.all));
      put_debug ("===============sol_init5================");
      print_genome (solution_t2p (sol_init5.all));
      put_debug ("===============sol_init6================");
      print_genome (solution_t2p (sol_init6.all));

      if Check_Feasibility_of_A_Solution (solution_t2p (sol_init1.all), 0) then
         Put_Line ("===============sol_init1 evaluation ================");

         evaluate_T2P (solution_t2p (sol_init1.all), 0);

         if (Float'value (sol_init1.obj (1)'img) = 0.0) and
           (Float'value (sol_init1.obj (2)'img) = 0.0) and
           (Float'value (sol_init1.obj (3)'img) = 0.0)
         then
            put_debug
              ("MissedDeadlines" &
               sol_init1.obj (1)'img &
               "          Bell    " &
               sol_init1.obj (2)'img &
               "          Biba    " &
               sol_init1.obj (3)'img);
            put_debug ("sol_init1 -- Simple design: no need for optimization");

            archive_soln (generic_solution_ptr (sol_init1));
            Create_system (Sys1, solution_t2p (sol_init1.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p (sol_init1.all));
            write_to_xml_file
              (a_system  => Sys1,
               file_name =>
                 To_String
                   (suppress_space
                      (To_Unbounded_String ("sol_init1" & ".xmlv3"))));
            OS_Exit (0);
         else
            archive_soln (generic_solution_ptr (sol_init1));
            update_grid (generic_solution_ptr (sol_init1));

            Append
              (Data3,
               " 0" &
               "              " &
               sol_init1.obj (1)'img &
               "              " &
               sol_init1.obj (2)'img &
               "              " &
               sol_init1.obj (3)'img &
               "              " &
               sol_init1.security_config'img &
               "              " &
               ASCII.LF);
            put_debug
              ("sol1" &
               "              " &
               sol_init1.obj (1)'img &
               "              " &
               sol_init1.obj (2)'img &
               "              " &
               sol_init1.obj (3)'img &
               "              " &
               ASCII.LF);
            Put_Line
              ("sol1" &
               "              " &
               sol_init1.obj (1)'img &
               "              " &
               sol_init1.obj (2)'img &
               "              " &
               sol_init1.obj (3)'img &
               "              " &
               ASCII.LF);

            nb_InitSol := nb_InitSol + 1;

            Create_system (Sys1, solution_t2p (sol_init1.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p (sol_init1.all));

            write_to_xml_file
              (a_system  => Sys1,
               file_name =>
                 To_String
                   (suppress_space
                      (To_Unbounded_String ("sol_init1" & ".xmlv3"))));
            put_debug
              ("=============== end sol_init1 evaluation ================");
         end if;
      end if;
      --Just for version 3-------
      if (exploration_version = 3) then

         if Check_Feasibility_of_A_Solution
             (solution_t2p (sol_init2.all),
              0)
         then
            Put_Line ("===============sol_init2 evaluation ================");
            put_debug ("===============sol_init2 evaluation ================");
            evaluate_T2P (solution_t2p (sol_init2.all), 0);
            if (Float'value (sol_init2.obj (1)'img) = 0.0) and
              (Float'value (sol_init2.obj (2)'img) = 0.0) and
              (Float'value (sol_init2.obj (3)'img) = 0.0)
            then
               put_debug
                 ("MissedDeadlines" &
                  sol_init2.obj (1)'img &
                  "          Bell    " &
                  sol_init2.obj (2)'img &
                  "          Biba    " &
                  sol_init2.obj (3)'img);
               put_debug
                 ("sol_init2 -- Simple design: no need for optimization");
               archive_soln (generic_solution_ptr (sol_init2));
               Create_system (Sys1, solution_t2p (sol_init2.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys1,
                  solution_t2p (sol_init2.all));
               write_to_xml_file
                 (a_system  => Sys1,
                  file_name =>
                    To_String
                      (suppress_space
                         (To_Unbounded_String ("sol_init2" & ".xmlv3"))));
               OS_Exit (0);
            else

               archive_soln (generic_solution_ptr (sol_init2));
               update_grid (generic_solution_ptr (sol_init2));
               Append
                 (Data3,
                  " 0" &
                  "              " &
                  sol_init2.obj (1)'img &
                  "              " &
                  sol_init2.obj (2)'img &
                  "              " &
                  sol_init2.obj (3)'img &
                  "              " &
                  sol_init2.security_config'img &
                  "              " &
                  ASCII.LF);
               put_debug
                 ("sol2" &
                  "              " &
                  sol_init2.obj (1)'img &
                  "              " &
                  sol_init2.obj (2)'img &
                  "              " &
                  sol_init2.obj (3)'img &
                  "              " &
                  ASCII.LF);

               nb_InitSol := nb_InitSol + 1;

               Create_system (Sys2, solution_t2p (sol_init2.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys2,
                  solution_t2p (sol_init2.all));
               write_to_xml_file
                 (a_system  => Sys2,
                  file_name =>
                    To_String
                      (suppress_space
                         (To_Unbounded_String ("sol_init2" & ".xmlv3"))));

            end if;
         end if;

         if Check_Feasibility_of_A_Solution
             (solution_t2p (sol_init3.all),
              0)
         then
            put_debug ("===============sol_init3 evaluation ================");
            evaluate_T2P (solution_t2p (sol_init3.all), 0);
            if (Float'value (sol_init3.obj (1)'img) = 0.0) and
              (Float'value (sol_init3.obj (2)'img) = 0.0) and
              (Float'value (sol_init3.obj (3)'img) = 0.0)
            then
               put_debug
                 ("MissedDeadlines" &
                  sol_init3.obj (1)'img &
                  "          Bell    " &
                  sol_init3.obj (2)'img &
                  "          Biba    " &
                  sol_init3.obj (3)'img);
               put_debug
                 ("sol_init3 -- Simple design: no need for optimization");
               archive_soln (generic_solution_ptr (sol_init3));
               Create_system (Sys1, solution_t2p (sol_init3.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys1,
                  solution_t2p (sol_init3.all));
               write_to_xml_file
                 (a_system  => Sys1,
                  file_name =>
                    To_String
                      (suppress_space
                         (To_Unbounded_String ("sol_init3" & ".xmlv3"))));
               OS_Exit (0);
            else
               archive_soln (generic_solution_ptr (sol_init3));
               update_grid (generic_solution_ptr (sol_init3));
               Append
                 (Data3,
                  " 0" &
                  "              " &
                  sol_init3.obj (1)'img &
                  "              " &
                  sol_init3.obj (2)'img &
                  "              " &
                  sol_init3.obj (3)'img &
                  "              " &
                  sol_init3.security_config'img &
                  "              " &
                  ASCII.LF);
               put_debug
                 ("sol3" &
                  "              " &
                  sol_init3.obj (1)'img &
                  "              " &
                  sol_init3.obj (2)'img &
                  "              " &
                  sol_init3.obj (3)'img &
                  "              " &
                  ASCII.LF);
               nb_InitSol := nb_InitSol + 1;

               Create_system (Sys3, solution_t2p (sol_init3.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys3,
                  solution_t2p (sol_init3.all));
               write_to_xml_file
                 (a_system  => Sys3,
                  file_name =>
                    To_String
                      (suppress_space
                         (To_Unbounded_String ("sol_init3" & ".xmlv3"))));

            end if;
         end if;

         if Check_Feasibility_of_A_Solution
             (solution_t2p (sol_init4.all),
              0)
         then
            put_debug ("===============sol_init4 evaluation ================");
            evaluate_T2P (solution_t2p (sol_init4.all), 0);
            if (Float'value (sol_init4.obj (1)'img) = 0.0) and
              (Float'value (sol_init4.obj (2)'img) = 0.0) and
              (Float'value (sol_init4.obj (3)'img) = 0.0)
            then
               put_debug
                 ("MissedDeadlines" &
                  sol_init4.obj (1)'img &
                  "          Bell    " &
                  sol_init4.obj (2)'img &
                  "          Biba    " &
                  sol_init4.obj (3)'img);
               put_debug
                 ("sol_init4 -- Simple design: no need for optimization");
               archive_soln (generic_solution_ptr (sol_init4));
               Create_system (Sys1, solution_t2p (sol_init4.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys1,
                  solution_t2p (sol_init4.all));
               write_to_xml_file
                 (a_system  => Sys1,
                  file_name =>
                    To_String
                      (suppress_space
                         (To_Unbounded_String ("sol_init4" & ".xmlv3"))));
               OS_Exit (0);
            else
               archive_soln (generic_solution_ptr (sol_init4));
               update_grid (generic_solution_ptr (sol_init4));
               Append
                 (Data3,
                  " 0" &
                  "              " &
                  sol_init4.obj (1)'img &
                  "              " &
                  sol_init4.obj (2)'img &
                  "              " &
                  sol_init4.obj (3)'img &
                  "              " &
                  sol_init4.security_config'img &
                  "              " &
                  ASCII.LF);
               put_debug
                 ("sol4" &
                  "              " &
                  sol_init4.obj (1)'img &
                  "              " &
                  sol_init4.obj (2)'img &
                  "              " &
                  sol_init4.obj (3)'img &
                  "              " &
                  ASCII.LF);

               nb_InitSol := nb_InitSol + 1;

               Create_system (Sys4, solution_t2p (sol_init4.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys4,
                  solution_t2p (sol_init4.all));
               write_to_xml_file
                 (a_system  => Sys4,
                  file_name =>
                    To_String
                      (suppress_space
                         (To_Unbounded_String ("sol_init4" & ".xmlv3"))));

            end if;
         end if;

         if Check_Feasibility_of_A_Solution
             (solution_t2p (sol_init5.all),
              0)
         then
            put_debug ("===============sol_init5 evaluation ================");
            evaluate_T2P (solution_t2p (sol_init5.all), 0);
            if (Float'value (sol_init5.obj (1)'img) = 0.0) and
              (Float'value (sol_init5.obj (2)'img) = 0.0) and
              (Float'value (sol_init5.obj (3)'img) = 0.0)
            then
               put_debug
                 ("MissedDeadlines" &
                  sol_init5.obj (1)'img &
                  "          Bell    " &
                  sol_init5.obj (2)'img &
                  "          Biba    " &
                  sol_init5.obj (3)'img);
               put_debug
                 ("sol_init5 -- Simple design: no need for optimization");
               archive_soln (generic_solution_ptr (sol_init5));
               Create_system (Sys1, solution_t2p (sol_init5.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys1,
                  solution_t2p (sol_init5.all));
               write_to_xml_file
                 (a_system  => Sys1,
                  file_name =>
                    To_String
                      (suppress_space
                         (To_Unbounded_String ("sol_init5" & ".xmlv3"))));
               OS_Exit (0);
            else
               archive_soln (generic_solution_ptr (sol_init5));
               update_grid (generic_solution_ptr (sol_init5));
               Append
                 (Data3,
                  " 0" &
                  "              " &
                  sol_init5.obj (1)'img &
                  "              " &
                  sol_init5.obj (2)'img &
                  "              " &
                  sol_init5.obj (3)'img &
                  "              " &
                  sol_init5.security_config'img &
                  "              " &
                  ASCII.LF);
               put_debug
                 ("sol5" &
                  "              " &
                  sol_init5.obj (1)'img &
                  "              " &
                  sol_init5.obj (2)'img &
                  "              " &
                  sol_init5.obj (3)'img &
                  "              " &
                  ASCII.LF);

               nb_InitSol := nb_InitSol + 1;

               Create_system (Sys5, solution_t2p (sol_init5.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys5,
                  solution_t2p (sol_init5.all));
               write_to_xml_file
                 (a_system  => Sys5,
                  file_name =>
                    To_String
                      (suppress_space
                         (To_Unbounded_String ("sol_init5" & ".xmlv3"))));

            end if;
         end if;
         if Check_Feasibility_of_A_Solution
             (solution_t2p (sol_init6.all),
              0)
         then
            put_debug ("===============sol_init6 evaluation ================");
            evaluate_T2P (solution_t2p (sol_init6.all), 0);
            if (Float'value (sol_init6.obj (1)'img) = 0.0) and
              (Float'value (sol_init6.obj (2)'img) = 0.0) and
              (Float'value (sol_init6.obj (3)'img) = 0.0)
            then
               put_debug
                 ("MissedDeadlines" &
                  sol_init6.obj (1)'img &
                  "          Bell    " &
                  sol_init6.obj (2)'img &
                  "          Biba    " &
                  sol_init6.obj (3)'img);
               put_debug
                 ("sol_init6 -- Simple design: no need for optimization");
               archive_soln (generic_solution_ptr (sol_init6));
               Create_system (Sys1, solution_t2p (sol_init6.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys1,
                  solution_t2p (sol_init6.all));
               write_to_xml_file
                 (a_system  => Sys1,
                  file_name =>
                    To_String
                      (suppress_space
                         (To_Unbounded_String ("sol_init6" & ".xmlv3"))));
               OS_Exit (0);
            else
               archive_soln (generic_solution_ptr (sol_init6));
               update_grid (generic_solution_ptr (sol_init6));
               Append
                 (Data3,
                  " 0" &
                  "              " &
                  sol_init6.obj (1)'img &
                  "              " &
                  sol_init6.obj (2)'img &
                  "              " &
                  sol_init6.obj (3)'img &
                  "              " &
                  sol_init6.security_config'img &
                  "              " &
                  ASCII.LF);
               put_debug
                 ("sol6" &
                  "              " &
                  sol_init6.obj (1)'img &
                  "              " &
                  sol_init6.obj (2)'img &
                  "              " &
                  sol_init6.obj (3)'img &
                  "              " &
                  ASCII.LF);

               nb_InitSol := nb_InitSol + 1;

               Create_system (Sys6, solution_t2p (sol_init6.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys6,
                  solution_t2p (sol_init6.all));
               write_to_xml_file
                 (a_system  => Sys6,
                  file_name =>
                    To_String
                      (suppress_space
                         (To_Unbounded_String ("sol_init6" & ".xmlv3"))));
            end if;
         end if;

      end if;
      if Check_Feasibility_of_A_Solution (solution_t2p (c.all), 0) then
         evaluate_T2P (solution_t2p (c.all), 0);

         put_debug ("===============c evaluation finish================");

         if (Float'value (c.obj (1)'img) = 0.0) and
           (Float'value (c.obj (2)'img) = 0.0) and
           (Float'value (c.obj (3)'img) = 0.0)
         then
            put_debug
              ("MissedDeadlines" &
               c.obj (1)'img &
               "          Bell    " &
               c.obj (2)'img &
               "          Biba    " &
               c.obj (3)'img);
            put_debug ("Simple design: no need for optimization");

            archive_soln (c);
            Create_system (Sys7, solution_t2p (c.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys7,
               solution_t2p (c.all));
            write_to_xml_file
              (a_system  => Sys7,
               file_name =>
                 To_String
                   (suppress_space (To_Unbounded_String ("c" & ".xmlv3"))));

            OS_Exit (0);
         else
            archive_soln (c);
            update_grid (c);
            Append
              (Data3,
               " 0" &
               "              " &
               c.obj (1)'img &
               "              " &
               c.obj (2)'img &
               "              " &
               c.obj (3)'img &
               "              " &
               solution_t2p (c.all).security_config'img &
               "              " &
               ASCII.LF);
            nb_InitSol := nb_InitSol + 1;

            Create_system (Sys7, solution_t2p (c.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys7,
               solution_t2p (c.all));
            write_to_xml_file
              (a_system  => Sys7,
               file_name =>
                 To_String
                   (suppress_space (To_Unbounded_String ("c" & ".xmlv3"))));

         end if;
      else  -- if c (that is supposed to be the first current solution) is non feasible
         if arclength > 0 then -- if the archive is not empty
            c.all :=
              arc
                (1).all; --the first element of the archive becomes the first current solution
         else
            put_debug ("All the initial solutions are non feasible");
            return;
         end if;

      end if;

   end init_T2P;

   ----------------
   -- mutate_T2P --
   ----------------

   procedure mutate_T2P
     (s    : in out generic_solution'class;
      eidx : in     Natural)
   is

      random_partition,
      random_app,
      tn,
      x,
      half_iter,
      cn,
      finish,
      sol_config               : Integer;
      l                        : Integer := 0;
      A_system                 : systems.system;
      A_Task_set, New_Task_set : tasks_set;
      counter, counter2        : Integer;

      Sol_is_mutated : Boolean;

      A_sol : solution_t2p;

      G                : Ada.Numerics.Float_Random.Generator;
      New_resource_set : resources_set;

      A_task_source : generic_task_ptr;
      A_task_sink   : generic_task_ptr;

      task_source : Integer;
      task_sink   : Integer;
   begin

      Create_system (A_system, solution_t2p (s));
      Sol_is_mutated := False;
      Reset (G); -- Initialise the float generator
      half_iter := iterations / 2;
      Put_Line ("half_iter: " & half_iter'img);

      -- We  add a counter, if this counter reach a threashold
      -- and it failed to generate a mutated solution then we stop

      counter := 1;

      while (not Sol_is_mutated) and (counter <= 100000) loop

         put_debug
           ("................................................................");
         put_debug
           ("The " & counter'img & " attempt of the mutation procedure ");
         put_debug
           ("................................................................");

         put_debug
           ("................................................................");
         put_debug
           ("The " & counter'img & " attempt of the mutation procedure ");
         put_debug
           ("................................................................");

         A_sol := solution_t2p (s);

         random_partition := 0;
         while (random_partition > nb_partitions) or (random_partition < 1)
         loop
            random_partition := Integer (Float (nb_partitions) * Random (G));
         end loop;
         Put_Line
           ("The randomly chosen partition is : " & random_partition'img);
         if (exploration_version = 1) or
           ((exploration_version = 2) and (iter < half_iter))
         then
            random_app := 0;
            while (random_app > nb_app) or (random_app < 1) loop
               random_app := Integer (Float (nb_app) * Random (G));
            end loop;
            Put_Line
              ("The randomly chosen application is : " & random_app'img);
            -- Move tasks of the random_app to the random_partition
            for l in 1 .. genes loop
               if (task_to_app (l) = random_app) then
                  A_sol.chrom_task (l) := random_partition;
               end if;
               Sol_is_mutated := True;
            end loop;
         elsif (exploration_version = 3) or
           ((exploration_version = 2) and (iter >= half_iter))
         then

            --  choose randomly an index of a task between 1 and genes
            tn := 0;
            while (tn > genes) or (tn < 1) loop
               tn := Integer (Float (genes) * Random (G));
            end loop;

            put_debug ("The randomly chosen task is : " & tn'img);
            -- the task "tn" is not intially in the partition "random_partition" then "tn" is moved
            -- to the partition "random_partition"
            if (random_partition /= A_sol.chrom_task (tn)) then
               A_sol.chrom_task (tn) := random_partition;
               Sol_is_mutated        := True;
            end if;

         end if;

         --  choose randomly the configuration to secure communications
         sol_config := 0;
         Reset (G); -- Initialise the float generator
         if (intra_partition_safe = 1) then
            -- intra partition communications are attackable
            sol_config := 1;
         else
            while (sol_config > 4) or (sol_config < 2) loop
               sol_config := Integer (4.0 * Random (G));
            end loop;
         end if;
         if (sol_config /= A_sol.security_config) then
            A_sol.security_config := sol_config;
            Sol_is_mutated        := True;
         end if;

         Put ("The chosen configuration is : " & sol_config'img);

         -- communication mutation
         -- choose randomly an index of a task between 1 and genes_com between risky communications Low
         x           := 0;
         task_source := 1;
         task_sink   := 1;
         counter2    := 0;
         if (intra_partition_safe = 0) then
            -- intra communications non attackable; so an intra communication should not be chosen
            while
              ((x > Nb_NonSecure_low) or
               (x < 1) or
               (A_sol.chrom_task (task_source) =
                A_sol.chrom_task (task_sink))) and
              (counter2 < 50)
            loop
               counter2 := counter2 + 1;
               x        := Integer (Float (Nb_NonSecure_low) * Random (G));
               if (x <= Nb_NonSecure_low) and (x >= 1) then
                  cn          := NonSecure_list (x);
                  finish      := Index (A_sol.chrom_com (cn).source_sink, "_");
                  task_source :=
                    Integer'value
                      (To_String
                         (suppress_space
                            (Unbounded_Slice
                               (solution_t2p (s).chrom_com (cn).source_sink,
                                1,
                                finish - 1))));
                  task_sink :=
                    Integer'value
                      (To_String
                         (Unbounded_Slice
                            (solution_t2p (s).chrom_com (cn).source_sink,
                             finish + 1,
                             Length
                               (solution_t2p (s).chrom_com (cn)
                                  .source_sink))));
               end if;

            end loop;
            if (counter2 >= 50) then
               New_Line;
               Put_Line
                 ("No inter partition communications choosed to be secured");
            else
               put_debug ("The randomly chosen communication is : " & cn'img);
               put_debug
                 ("This chosen communication is : " &
                  solution_t2p (s).chrom_com (cn).mode'img &
                  " " &
                  To_String (solution_t2p (s).chrom_com (cn).source_sink));
               finish := Index (A_sol.chrom_com (cn).source_sink, "_");

               A_task_source :=
                 search_task
                   (Initial_System.tasks,
                    suppress_space
                      (Unbounded_Slice
                         (solution_t2p (s).chrom_com (cn).source_sink,
                          1,
                          finish - 1)));
               A_task_sink :=
                 search_task
                   (Initial_System.tasks,
                    suppress_space
                      (Unbounded_Slice
                         (solution_t2p (s).chrom_com (cn).source_sink,
                          finish + 1,
                          Length
                            (solution_t2p (s).chrom_com (cn).source_sink))));

               if
                 (A_task_sink.mils_confidentiality_level <
                  A_task_source.mils_confidentiality_level) or
                 (A_task_source.mils_integrity_level <
                  A_task_sink.mils_integrity_level)
               then
                  if
                    ((A_task_sink.mils_task /= downgrader) and
                     (A_task_sink.mils_task /= upgrader) and
                     (A_task_source.mils_task /= downgrader) and
                     (A_task_source.mils_task /= upgrader))
                  then
                     if (A_sol.chrom_com (cn).mode = nosecure) then
                        A_sol.chrom_com (cn).mode := secure;
                        Sol_is_mutated            := True;
                     elsif (A_sol.chrom_com (cn).mode = secure) then
                        A_sol.chrom_com (cn).mode := nosecure;
                        Sol_is_mutated            := True;
                     end if;
                  end if;
               end if;
            end if;

         elsif (intra_partition_safe = 1) then
            while (x > Nb_NonSecure_low) or (x < 1) loop
               x := Integer (Float (Nb_NonSecure_low) * Random (G));
            end loop;
            cn     := NonSecure_list (x);
            finish := Index (A_sol.chrom_com (cn).source_sink, "_");
            put_debug ("The randomly chosen communication is : " & cn'img);
            put_debug
              ("This chosen communication is : " &
               solution_t2p (s).chrom_com (cn).mode'img &
               " " &
               To_String (solution_t2p (s).chrom_com (cn).source_sink));
            finish := Index (A_sol.chrom_com (cn).source_sink, "_");

            A_task_source :=
              search_task
                (Initial_System.tasks,
                 suppress_space
                   (Unbounded_Slice
                      (solution_t2p (s).chrom_com (cn).source_sink,
                       1,
                       finish - 1)));
            A_task_sink :=
              search_task
                (Initial_System.tasks,
                 suppress_space
                   (Unbounded_Slice
                      (solution_t2p (s).chrom_com (cn).source_sink,
                       finish + 1,
                       Length (solution_t2p (s).chrom_com (cn).source_sink))));

            if
              (A_task_sink.mils_confidentiality_level <
               A_task_source.mils_confidentiality_level) or
              (A_task_source.mils_integrity_level <
               A_task_sink.mils_integrity_level)
            then
               if
                 ((A_task_sink.mils_task /= downgrader) and
                  (A_task_sink.mils_task /= upgrader) and
                  (A_task_source.mils_task /= downgrader) and
                  (A_task_source.mils_task /= upgrader))
               then
                  if (A_sol.chrom_com (cn).mode = nosecure) then
                     A_sol.chrom_com (cn).mode := secure;
                     Sol_is_mutated            := True;
                  elsif (A_sol.chrom_com (cn).mode = secure) then
                     A_sol.chrom_com (cn).mode := nosecure;
                     Sol_is_mutated            := True;
                  end if;
               end if;
            end if;

         end if;

         if Sol_is_mutated then

            put_debug (" ");
            put_debug ("The mutated solution is : ");
            print_debug_genome (A_sol);
            put_debug (" ");
            -- normalize the mutate solution
            normalize (A_sol);
            put_debug (" ");
            put_debug ("After normalization the candidate solution is : ");
            Put_Line ("After normalization the candidate solution is : ");
            print_debug_genome (A_sol);
            put_debug (" ");

         -- After generating a mutate solution, we shoud verify
         -- if it is feasible else we must regenerate a new candidate solution:
            --

            if Check_Feasibility_of_A_Solution (A_sol, eidx) then

               put_debug (" The candidate solution is feasible");
               Sol_is_mutated                   := True;
               s := generic_solution'class (A_sol);
               nb_secu_conf_choice (sol_config) :=
                 nb_secu_conf_choice (sol_config) + 1;
            else

               put_debug
                 (" The candidate solution is NOt Feasible " &
                  " we should regenerate another candidate solution");
               Sol_is_mutated    := False;
               counter           := counter + 1;
               nb_NoFeasible_Sol := nb_NoFeasible_Sol + 1;

            end if;

         end if;

      end loop;

      if counter > 100000 then
         put_debug (" ");--New_Line;
         put_debug (" ");--New_Line;
         put_debug
           ("Exit the program, there is no schedulable candidate solution !");
         put_debug (" ");--New_Line;
         put_debug (" ");--New_Line;
         OS_Exit (0);
      end if;

   end mutate_T2P;

   procedure generate_next_element_T2P
     (s    : in out solution_t2p;
      i, j : in out Integer)
   is
   begin
      if (i <= genes) then
         if (s.chrom_task (i) = 0) then
            s.chrom_task (i) := 1;
         else
            s.chrom_task (i) := s.chrom_task (i) + 1;
         end if;
      end if;

      if j <= Nb_NonSecure_low then

         s.chrom_com (NonSecure_list (j)).mode := undefined;
         if (s.chrom_com (NonSecure_list (j)).mode = undefined) then
            s.chrom_com (NonSecure_list (j)).mode := nosecure;

         elsif (s.chrom_com (NonSecure_list (j)).mode = nosecure) then
            s.chrom_com (NonSecure_list (j)).mode := secure;

         elsif (s.chrom_com (NonSecure_list (j)).mode = secure) then
            s.chrom_com (NonSecure_list (j)).mode := undefined;
         end if;

      end if;

   end generate_next_element_T2P;

   --------------------------------
   -- generate_next_solution_T2P --
   --------------------------------

   procedure generate_next_solution_T2P
     (s                         : in out solution_t2p;
      space_search_is_exhausted :    out Boolean)
   is

      i, j, k : Integer;
      g       : solution_t2p;
      non     : Boolean := True;
   begin

      i := 1;
      j := 1;
      k := 1;

      space_search_is_exhausted := False;
      while (space_search_is_exhausted = False) loop

         generate_next_element_T2P (s, i, j);
         if (s.chrom_task (i) <= nb_partitions) and (i < genes) then
            i := i + 1;
         --    j := j+1;
         elsif (s.chrom_task (i) <= nb_partitions) and (i = genes) then

            nb_sol_Exhaus := nb_sol_Exhaus + 1;
            print_genome (s);
            g := s;
         elsif (s.chrom_task (i) > nb_partitions) and (i > 1) then
            s.chrom_task (i) := 0;
            i                := i - 1;
         elsif (s.chrom_task (i) > nb_partitions) and (i = 1) then
            space_search_is_exhausted := True;
         end if;

      end loop;

   end generate_next_solution_T2P;

   ---------------
   -- Normalize --
   ---------------

   procedure normalize (s : in out solution_t2p) is

      nb_partitions : Integer := 1;
      --  the vector var is used to know if a gene is normalized or not yet
      var : chrom_task_type;
   begin
      --  initialization of the vector var.
      for i in 1 .. genes loop
         var (i) := 0;
         --         var2(i) :=0;
      end loop;

      ------------------------------------------------------------
      --  if var(i) = 0   ==>  s.chrom(i) is not yet normalized
      --  if var(i) = 1   ==>  s.chrom(i) is normalized
      ------------------------------------------------------------

      for i in 1 .. genes loop

         if (var (i) = 0) then

            for j in i + 1 .. genes loop
               if (s.chrom_task (j) = s.chrom_task (i))
                 and then (var (j) = 0)
               then
                  var (j) := 1;
                  --  if s.chrom(i) is not normalized then all s.chrom(j) (which egal s.all.chrom(i))
                  --  are not normalized
                  if (s.chrom_task (i) /= nb_partitions) then
                     s.chrom_task (j) := nb_partitions;
                  end if;
               end if;
            end loop;

            -- we normalize s.chrom(i)
            if (s.chrom_task (i) /= nb_partitions) then
               s.chrom_task (i) := nb_partitions;
            end if;
            var (i)       := 1;
            nb_partitions := nb_partitions + 1;
         end if;
      end loop;

   end normalize;

   ---------------------
   -- Number_of_partitions --
   ---------------------

   function Number_of_partitions (s : in solution_t2p) return Integer is
      permutation        : Integer := 1;
      var                : chrom_task_type;
      nb_partitions, tmp : Integer;
   begin
      --  assignment of the table var with elements of s.chrom
      for i in 1 .. genes loop
         var (i) := s.chrom_task (i);
      end loop;

      --  sorting elements of var in the increasing order
      while permutation = 1 loop
         permutation := 0;
         for i in 1 .. genes - 1 loop
            if (var (i) > var (i + 1)) then
               tmp         := var (i);
               var (i)     := var (i + 1);
               var (i + 1) := tmp;
               permutation := 1;
            end if;
         end loop;
      end loop;

      nb_partitions := genes;

      for i in 1 .. genes - 1 loop
         if (var (i) = var (i + 1)) then
            nb_partitions := nb_partitions - 1;
         end if;
      end loop;

      return nb_partitions;

   end Number_of_partitions;

   ----------------------------------------------
   -- Transform_Chromosome_To_CheddarADL_Model --
   ----------------------------------------------

   procedure Transform_Chromosome_To_CheddarADL_Model
     (A_sys : in out systems.system;
      s     : in     solution_t2p)
   is

      A_Tasks_set : tasks_set;
      A_Task      : periodic_task;

      k                              : Integer;
      period_i                       : Natural;
      capacity_i                     : Natural;
      deadline_i                     : Natural;
      priority_i                     : Natural;
      criticality_i                  : Natural;
      confidentiality_i, integrity_i : Unbounded_String;

   begin

      -- 1) Generate the tasks set from the solution s
      --

      initialize (A_sys.tasks);
      initialize (A_sys.dependencies.depends);
      for i in 1 .. genes loop
         k        := s.chrom_task (i);
         period_i :=
           get
             (my_tasks   => Initial_System.tasks,
              task_name  => suppress_space (To_Unbounded_String ("" & i'img)),
              param_name => period);

         capacity_i :=
           get
             (my_tasks   => Initial_System.tasks,
              task_name  => suppress_space (To_Unbounded_String ("" & i'img)),
              param_name => capacity);

         deadline_i :=
           get
             (my_tasks   => Initial_System.tasks,
              task_name  => suppress_space (To_Unbounded_String ("" & i'img)),
              param_name => deadline);
         priority_i :=
           get
             (my_tasks   => Initial_System.tasks,
              task_name  => suppress_space (To_Unbounded_String ("" & i'img)),
              param_name => task_set.priority);
         criticality_i :=
           get
             (my_tasks   => Initial_System.tasks,
              task_name  => suppress_space (To_Unbounded_String ("" & i'img)),
              param_name => criticality);
         confidentiality_i :=
           get
             (my_tasks   => Initial_System.tasks,
              task_name  => suppress_space (To_Unbounded_String ("" & i'img)),
              param_name => mils_confidentiality_level);
         integrity_i :=
           get
             (my_tasks   => Initial_System.tasks,
              task_name  => suppress_space (To_Unbounded_String ("" & i'img)),
              param_name => mils_integrity_level);
         add_task
           (my_tasks           => A_sys.tasks,
            name => suppress_space (To_Unbounded_String ("" & i'img)),
            cpu_name => suppress_space (To_Unbounded_String ("processor1")),
            address_space_name =>
              suppress_space (To_Unbounded_String ("addr" & k'img)),
            core_name => suppress_space (To_Unbounded_String ("")),
            task_type                  => periodic_type,
            start_time                 => 0,
            capacity                   => capacity_i,
            period                     => period_i,
            deadline                   => deadline_i,
            jitter                     => 0,
            blocking_time              => 0,
            priority                   => priority_i,
            criticality                => criticality_i,
            policy                     => Sched_policy,
            mils_confidentiality_level =>
              mils_confidentiality_level_type'value
                (To_String (confidentiality_i)),
            mils_integrity_level =>
              mils_integrity_level_type'value (To_String (integrity_i)));
         --       Put_Line("task "& i'Img & " capacity_i : " & capacity_i'Img);
         New_Line;

      end loop;

      -- 2) Generate the dependencies and secure the system depending on the choosen security configuration
      --
      nb_bell_resolved := 0;
      nb_biba_resolved := 0;
      if (s.security_config = 1) then
         security_configuration1 (A_sys, s);
      elsif (s.security_config = 2) then
         security_configuration2 (A_sys, s);
      elsif (s.security_config = 3) then
         security_configuration3 (A_sys, s);
      elsif (s.security_config = 4) then
         security_configuration4 (A_sys, s);
      end if;

      -- consider inter and intra communications overheads
      com_overhead (A_sys);

      put_debug ("end_transform");
   end Transform_Chromosome_To_CheddarADL_Model;

   -------------------------------------------
   -- consider inter and intra partition --
   -------------------------------------------
   procedure com_overhead (A_sys : in out systems.system) is
      My_iterator     : tasks_dependencies_iterator;
      Dep_Ptr         : dependency_ptr;
      My_dependencies : tasks_dependencies_ptr;
      m               : Integer;
   begin
      My_dependencies := A_sys.dependencies;
      if is_empty (My_dependencies.depends) then
         Put_Line ("NO dependencies");
      else
         reset_iterator (My_dependencies.depends, My_iterator);
         loop
            current_element (My_dependencies.depends, Dep_Ptr, My_iterator);
            m := Integer'value (To_String (Dep_Ptr.precedence_source.name));
            if
              (Dep_Ptr.precedence_source.address_space_name =
               Dep_Ptr.precedence_sink.address_space_name)
            then
               Dep_Ptr.precedence_source.capacity :=
                 Dep_Ptr.precedence_source.capacity +
                 display_blackboard_time_values (task_to_app (m));
               Dep_Ptr.precedence_sink.capacity :=
                 Dep_Ptr.precedence_sink.capacity +
                 read_blackboard_time_values (task_to_app (m));
            else
               Dep_Ptr.precedence_source.capacity :=
                 Dep_Ptr.precedence_source.capacity +
                 write_sampling_port_time_values (task_to_app (m));
               Dep_Ptr.precedence_sink.capacity :=
                 Dep_Ptr.precedence_sink.capacity +
                 read_sampling_port_time_values (task_to_app (m));
            end if;
            exit when is_last_element (My_dependencies.depends, My_iterator);
            next_element (My_dependencies.depends, My_iterator);
         end loop;
      end if;
   end com_overhead;

   -- communication_cost --
   -------------------
   procedure communication_cost
     (sys      : in     systems.system;
      com_cost :    out com_cost_type)
   is
      My_iterator     : tasks_dependencies_iterator;
      Dep_Ptr         : dependency_ptr;
      My_dependencies : tasks_dependencies_ptr;
      m               : Integer;
   begin
      My_dependencies := sys.dependencies;
      if is_empty (My_dependencies.depends) then
         Put_Line ("NO dependencies");
      else
         for i in 1 .. 5 loop
            com_cost (i) := 0.0;
         end loop;
         reset_iterator (My_dependencies.depends, My_iterator);
         loop
            current_element (My_dependencies.depends, Dep_Ptr, My_iterator);
            m := Integer'value (To_String (Dep_Ptr.precedence_source.name));
            if
              (Dep_Ptr.precedence_source.address_space_name =
               Dep_Ptr.precedence_sink.address_space_name)
            then
               com_cost (1) := com_cost (1) + 1.0;
               com_cost (2) := com_cost (2) + 1.0;
               com_cost (5) :=
                 com_cost (5) +
                 Float
                   (display_blackboard_time_values (task_to_app (m)) *
                    (Hyperperiod_of_Initial_Taskset /
                     Dep_Ptr.precedence_source.deadline) +
                    read_blackboard_time_values (task_to_app (m)) *
                      (Hyperperiod_of_Initial_Taskset /
                       Dep_Ptr.precedence_sink.deadline));
            else
               com_cost (3) := com_cost (3) + 1.0;
               com_cost (4) := com_cost (4) + 1.0;
               com_cost (5) :=
                 com_cost (5) +
                 Float
                   (write_sampling_port_time_values (task_to_app (m)) *
                    (Hyperperiod_of_Initial_Taskset /
                     Dep_Ptr.precedence_source.deadline) +
                    read_sampling_port_time_values (task_to_app (m)) *
                      (Hyperperiod_of_Initial_Taskset /
                       Dep_Ptr.precedence_sink.deadline));
            end if;
            exit when is_last_element (My_dependencies.depends, My_iterator);
            next_element (My_dependencies.depends, My_iterator);
         end loop;
      end if;
   end communication_cost;

   -------------------
   -- Create_system --
   -------------------

   procedure Create_system
     (A_system : in out systems.system;
      s        : in     solution_t2p)
   is

      a_core                    : core_unit_ptr;
      a_core_unit_table         : core_units_table;
      mem                       : memories_table;
      partition_sched_file_name : Unbounded_String;
      nb_part                   : Integer;

   begin

      initialize (A_system);

      -- Generate partitions
      for i in 1 .. Number_of_partitions (s) loop
         --    for i in 1.. nb_partitions loop
         --            if (s.chrom_partition_PU(i)=j) then
         add_address_space
           (my_address_spaces => A_system.address_spaces,
            name => suppress_space (To_Unbounded_String ("addr" & i'img)),
            cpu_name => suppress_space (To_Unbounded_String ("processor1")),
            text_memory_size  => 0,
            stack_memory_size => 0,
            data_memory_size  => 0,
            heap_memory_size  => 0,
            a_scheduler       => posix_1003_highest_priority_first_protocol);
      end loop;

      if (s.security_config < 10) then
         nb_part := Number_of_partitions (s);
      else
         nb_part := Number_of_partitions (s) + 1;
      end if;
      partition_sched_file_name :=
        suppress_space
          (To_Unbounded_String
             ("partition_scheduling_paes" & nb_part'img & ".xml"));
      add_core_unit
        (my_core_units            => A_system.core_units,
         a_core_unit              => a_core,
         name => suppress_space (To_Unbounded_String ("core1")),
         is_preemptive            => preemptive,
         quantum                  => 0,
         speed                    => 1,
         capacity                 => 0,
         period                   => 0,
         priority                 => 0,
         file_name                => partition_sched_file_name,
         scheduling_protocol_name => suppress_space (To_Unbounded_String ("")),
         a_scheduler              => The_Scheduler,
         mem                      => mem);

      add (a_core_unit_table, a_core);

      add_processor
        (my_processors => A_system.processors,
         name          => suppress_space (To_Unbounded_String ("processor1")),
         a_core        => a_core);

   end Create_system;

end Paes.chromosome_Data_Manipulation_t2p_and_security;
