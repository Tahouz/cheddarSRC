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
with Paes.objective_functions.multicore_t2p_and_security;
use Paes.objective_functions.multicore_t2p_and_security;
with Paes.security_implementation; use Paes.security_implementation;
package body Paes.chromosome_Data_Manipulation_multicore_t2p_and_security is

   ------------------------
   -- init_multicore_T2P --
   ------------------------

   procedure init_multicore_T2P is
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

      sol_init1 := new solution_t2p_t2c;
      sol_init2 := new solution_t2p_t2c;
      sol_init3 := new solution_t2p_t2c;
      sol_init4 := new solution_t2p_t2c;
      sol_init5 := new solution_t2p_t2c;
      sol_init6 := new solution_t2p_t2c;
      sol_init7 :=
        new solution_t2p_t2c; -- core per app no security problems resolved
      sol_init8 :=
        new solution_t2p_t2c;        -- core per app with security problems resolved (6 cores)
      sol_init9 :=
        new solution_t2p_t2c;   -- core per app with security problems resolved (2 cores)
      sol_init10 := new solution_t2p_t2c;   -- (3 cores)
      sol_init11 := new solution_t2p_t2c;   -- (4 cores)
      sol_init12 := new solution_t2p_t2c;   -- (5 cores)
      sol_init13 := new solution_t2p_t2c;   -- (core per task)

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
            solution_t2p_t2c_ptr (c).chrom_t2p (i) :=
              Integer'value
                (String_Split.Slice (Subs, String_Split.Slice_Number (i + 1)));
         end loop;
         Put ("The initial preprocessed solution: ");
         print_genome (solution_t2p_t2c (c.all));

      else

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
               sol_init2.chrom_t2p (m) := l;
            end loop;
            l   := l + 1;
            itr := itr + part;

         end loop;

         for i in 1 .. genes loop
            solution_t2p_t2c_ptr (c).chrom_t2c (i)         := 1;
            solution_t2p_t2c_ptr (sol_init1).chrom_t2c (i) := 1;
            solution_t2p_t2c_ptr (sol_init2).chrom_t2c (i) := 1;
            solution_t2p_t2c_ptr (sol_init3).chrom_t2c (i) := 1;
            solution_t2p_t2c_ptr (sol_init4).chrom_t2c (i) := 1;
            solution_t2p_t2c_ptr (sol_init5).chrom_t2c (i) := 1;
            solution_t2p_t2c_ptr (sol_init6).chrom_t2c (i) := 1;
         end loop;
         --Each app on a different core
         k := 1;
         for j in 1 .. nb_app loop
            for i in k .. k + nb_task_per_app (j) loop
               solution_t2p_t2c_ptr (sol_init7).chrom_t2c (i) := j;
               solution_t2p_t2c_ptr (sol_init8).chrom_t2c (i) := j;
            end loop;
            k := k + nb_task_per_app (j);
         end loop;

         for i in 1 .. genes loop
            solution_t2p_t2c_ptr (sol_init13).chrom_t2c (i) := i;
            if (i >= 1) and (i <= genes / 5) then
               solution_t2p_t2c_ptr (sol_init9).chrom_t2c (i)  := 1;
               solution_t2p_t2c_ptr (sol_init10).chrom_t2c (i) := 1;
               solution_t2p_t2c_ptr (sol_init11).chrom_t2c (i) := 1;
               solution_t2p_t2c_ptr (sol_init12).chrom_t2c (i) := 1;
            elsif (i > genes / 5) and (i <= genes / 4) then
               solution_t2p_t2c_ptr (sol_init9).chrom_t2c (i)  := 1;
               solution_t2p_t2c_ptr (sol_init10).chrom_t2c (i) := 1;
               solution_t2p_t2c_ptr (sol_init11).chrom_t2c (i) := 1;
               solution_t2p_t2c_ptr (sol_init12).chrom_t2c (i) := 2;
            elsif (i > genes / 4) and (i <= genes / 3) then
               solution_t2p_t2c_ptr (sol_init9).chrom_t2c (i)  := 1;
               solution_t2p_t2c_ptr (sol_init10).chrom_t2c (i) := 1;
               solution_t2p_t2c_ptr (sol_init11).chrom_t2c (i) := 2;
               solution_t2p_t2c_ptr (sol_init12).chrom_t2c (i) := 2;
            elsif (i > genes / 3) and (i <= 2 * genes / 5) then
               solution_t2p_t2c_ptr (sol_init9).chrom_t2c (i)  := 1;
               solution_t2p_t2c_ptr (sol_init10).chrom_t2c (i) := 2;
               solution_t2p_t2c_ptr (sol_init11).chrom_t2c (i) := 2;
               solution_t2p_t2c_ptr (sol_init12).chrom_t2c (i) := 2;
            elsif (i > 2 * genes / 5) and (i <= genes / 2) then
               solution_t2p_t2c_ptr (sol_init9).chrom_t2c (i)  := 1;
               solution_t2p_t2c_ptr (sol_init10).chrom_t2c (i) := 2;
               solution_t2p_t2c_ptr (sol_init11).chrom_t2c (i) := 2;
               solution_t2p_t2c_ptr (sol_init12).chrom_t2c (i) := 3;
            elsif (i > genes / 2) and (i <= 2 * genes / 3) then
               solution_t2p_t2c_ptr (sol_init9).chrom_t2c (i)  := 2;
               solution_t2p_t2c_ptr (sol_init10).chrom_t2c (i) := 2;
               solution_t2p_t2c_ptr (sol_init11).chrom_t2c (i) := 3;
               solution_t2p_t2c_ptr (sol_init12).chrom_t2c (i) := 3;
            elsif (i > 2 * genes / 3) and (i <= 3 * genes / 5) then
               solution_t2p_t2c_ptr (sol_init9).chrom_t2c (i)  := 2;
               solution_t2p_t2c_ptr (sol_init10).chrom_t2c (i) := 3;
               solution_t2p_t2c_ptr (sol_init11).chrom_t2c (i) := 3;
               solution_t2p_t2c_ptr (sol_init12).chrom_t2c (i) := 3;
            elsif (i > 3 * genes / 5) and (i <= 3 * genes / 4) then
               solution_t2p_t2c_ptr (sol_init9).chrom_t2c (i)  := 2;
               solution_t2p_t2c_ptr (sol_init10).chrom_t2c (i) := 3;
               solution_t2p_t2c_ptr (sol_init11).chrom_t2c (i) := 3;
               solution_t2p_t2c_ptr (sol_init12).chrom_t2c (i) := 4;
            elsif (i > 3 * genes / 4) and (i <= 4 * genes / 5) then
               solution_t2p_t2c_ptr (sol_init9).chrom_t2c (i)  := 2;
               solution_t2p_t2c_ptr (sol_init10).chrom_t2c (i) := 3;
               solution_t2p_t2c_ptr (sol_init11).chrom_t2c (i) := 4;
               solution_t2p_t2c_ptr (sol_init12).chrom_t2c (i) := 4;
            elsif (i > 4 * genes / 5) and (i <= genes) then
               solution_t2p_t2c_ptr (sol_init9).chrom_t2c (i)  := 2;
               solution_t2p_t2c_ptr (sol_init10).chrom_t2c (i) := 3;
               solution_t2p_t2c_ptr (sol_init11).chrom_t2c (i) := 4;
               solution_t2p_t2c_ptr (sol_init12).chrom_t2c (i) := 5;

            end if;

         end loop;

         for i in 1 .. genes loop
            A_task_i :=
              search_task (Initial_System.tasks, suppress_space (i'img));
            if (i <= genes / 3) then
               solution_t2p_t2c_ptr (c).chrom_t2p (i) :=
                 1;    --All the tasks in the same partition
               sol_init1.chrom_t2p (i)  := 1;
               sol_init7.chrom_t2p (i)  := 1;
               sol_init8.chrom_t2p (i)  := 1;
               sol_init9.chrom_t2p (i)  := 1;
               sol_init10.chrom_t2p (i) := 1;
               sol_init11.chrom_t2p (i) := 1;
               sol_init12.chrom_t2p (i) := 1;
               sol_init13.chrom_t2p (i) := 1;

               if (A_task_i.mils_confidentiality_level = top_secret) then
                  sol_init3.chrom_t2p (i) := 1;
                  sol_init4.chrom_t2p (i) := 1;
               elsif (A_task_i.mils_confidentiality_level = secret) then
                  sol_init3.chrom_t2p (i) := 2;
                  sol_init4.chrom_t2p (i) := 2;
               elsif (A_task_i.mils_confidentiality_level = classified) then
                  sol_init3.chrom_t2p (i) := 3;
                  sol_init4.chrom_t2p (i) := 3;
               else
                  sol_init3.chrom_t2p (i) := 4;
                  sol_init4.chrom_t2p (i) := 4;
               end if;
-- all tasks with the same integrity level should be put in the same partition

               if (A_task_i.mils_integrity_level = high) then
                  sol_init5.chrom_t2p (i) := 1;
                  sol_init6.chrom_t2p (i) := 1;
               elsif (A_task_i.mils_integrity_level = medium) then
                  sol_init5.chrom_t2p (i) := 2;
                  sol_init6.chrom_t2p (i) := 2;
               else
                  sol_init5.chrom_t2p (i) := 3;
                  sol_init6.chrom_t2p (i) := 3;
               end if;

            elsif (genes / 3 < i) and (i <= 2 * genes / 3) then
               solution_t2p_t2c_ptr (c).chrom_t2p (i) :=
                 2;    --All the tasks in the same partition
               sol_init1.chrom_t2p (i)  := 2;
               sol_init7.chrom_t2p (i)  := 2;
               sol_init8.chrom_t2p (i)  := 2;
               sol_init9.chrom_t2p (i)  := 2;
               sol_init10.chrom_t2p (i) := 2;
               sol_init11.chrom_t2p (i) := 2;
               sol_init12.chrom_t2p (i) := 2;
               sol_init13.chrom_t2p (i) := 2;
               if (A_task_i.mils_confidentiality_level = top_secret) then
                  sol_init3.chrom_t2p (i) := 5;
                  sol_init4.chrom_t2p (i) := 5;
               elsif (A_task_i.mils_confidentiality_level = secret) then
                  sol_init3.chrom_t2p (i) := 6;
                  sol_init4.chrom_t2p (i) := 6;
               elsif (A_task_i.mils_confidentiality_level = classified) then
                  sol_init3.chrom_t2p (i) := 7;
                  sol_init4.chrom_t2p (i) := 7;
               else
                  sol_init3.chrom_t2p (i) := 8;
                  sol_init4.chrom_t2p (i) := 8;
               end if;

-- all tasks with the same integrity level should be put in the same partition

               if (A_task_i.mils_integrity_level = high) then
                  sol_init5.chrom_t2p (i) := 4;
                  sol_init6.chrom_t2p (i) := 4;
               elsif (A_task_i.mils_integrity_level = medium) then
                  sol_init5.chrom_t2p (i) := 5;
                  sol_init6.chrom_t2p (i) := 5;
               else
                  sol_init5.chrom_t2p (i) := 6;
                  sol_init6.chrom_t2p (i) := 6;
               end if;

            elsif (2 * genes / 3 < i) and (i <= genes) then
               solution_t2p_t2c_ptr (c).chrom_t2p (i) :=
                 3;    --All the tasks in the same partition
               sol_init1.chrom_t2p (i)  := 3;
               sol_init7.chrom_t2p (i)  := 3;
               sol_init8.chrom_t2p (i)  := 3;
               sol_init9.chrom_t2p (i)  := 3;
               sol_init10.chrom_t2p (i) := 3;
               sol_init11.chrom_t2p (i) := 3;
               sol_init12.chrom_t2p (i) := 3;
               sol_init13.chrom_t2p (i) := 3;
               if (A_task_i.mils_confidentiality_level = top_secret) then
                  sol_init3.chrom_t2p (i) := 9;
                  sol_init4.chrom_t2p (i) := 9;
               elsif (A_task_i.mils_confidentiality_level = secret) then
                  sol_init3.chrom_t2p (i) := 10;
                  sol_init4.chrom_t2p (i) := 10;
               elsif (A_task_i.mils_confidentiality_level = classified) then
                  sol_init3.chrom_t2p (i) := 11;
                  sol_init4.chrom_t2p (i) := 11;
               else
                  sol_init3.chrom_t2p (i) := 12;
                  sol_init4.chrom_t2p (i) := 12;
               end if;

-- all tasks with the same integrity level should be put in the same partition

               if (A_task_i.mils_integrity_level = high) then
                  sol_init5.chrom_t2p (i) := 7;
                  sol_init6.chrom_t2p (i) := 7;
               elsif (A_task_i.mils_integrity_level = medium) then
                  sol_init5.chrom_t2p (i) := 8;
                  sol_init6.chrom_t2p (i) := 8;
               else
                  sol_init5.chrom_t2p (i) := 9;
                  sol_init6.chrom_t2p (i) := 9;
               end if;

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

                     solution_t2p_t2c_ptr (c).chrom_com (j).mode := secure;
                     solution_t2p_t2c_ptr (c).chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init8).chrom_com (j).mode :=
                       secure;
                     solution_t2p_t2c_ptr (sol_init8).chrom_com (j)
                       .source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init9).chrom_com (j).mode :=
                       secure;
                     solution_t2p_t2c_ptr (sol_init9).chrom_com (j)
                       .source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init10).chrom_com (j).mode :=
                       secure;
                     solution_t2p_t2c_ptr (sol_init10).chrom_com (j)
                       .source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init11).chrom_com (j).mode :=
                       secure;
                     solution_t2p_t2c_ptr (sol_init11).chrom_com (j)
                       .source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init12).chrom_com (j).mode :=
                       secure;
                     solution_t2p_t2c_ptr (sol_init12).chrom_com (j)
                       .source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init13).chrom_com (j).mode :=
                       secure;
                     solution_t2p_t2c_ptr (sol_init13).chrom_com (j)
                       .source_sink :=
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

                     sol_init7.chrom_com (j).mode        := secure;
                     sol_init7.chrom_com (j).source_sink :=
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
                     -- resolve security problems of solutions c, sol_init4, sol_init6, sol_init8 (communications Low)
                     k := k + 1;

                     solution_t2p_t2c_ptr (c).chrom_com (j).mode := secure;
                     solution_t2p_t2c_ptr (c).chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init8).chrom_com (j).mode :=
                       secure;
                     solution_t2p_t2c_ptr (sol_init8).chrom_com (j)
                       .source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init9).chrom_com (j).mode :=
                       secure;
                     solution_t2p_t2c_ptr (sol_init9).chrom_com (j)
                       .source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init10).chrom_com (j).mode :=
                       secure;
                     solution_t2p_t2c_ptr (sol_init10).chrom_com (j)
                       .source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init11).chrom_com (j).mode :=
                       secure;
                     solution_t2p_t2c_ptr (sol_init11).chrom_com (j)
                       .source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init12).chrom_com (j).mode :=
                       secure;
                     solution_t2p_t2c_ptr (sol_init12).chrom_com (j)
                       .source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init13).chrom_com (j).mode :=
                       secure;
                     solution_t2p_t2c_ptr (sol_init13).chrom_com (j)
                       .source_sink :=
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
                        sol_init7.chrom_com (j).mode :=
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
                        sol_init7.chrom_com (j).mode := nosecure;
                        sol_init2.chrom_com (j).mode := nosecure;
                        sol_init3.chrom_com (j).mode := nosecure;
                        sol_init5.chrom_com (j).mode := nosecure;
                     end if;

                     sol_init1.chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));
                     sol_init7.chrom_com (j).source_sink :=
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
                     solution_t2p_t2c_ptr (c).chrom_com (j).mode := norisk;
                     solution_t2p_t2c_ptr (c).chrom_com (j).source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init8).chrom_com (j).mode :=
                       norisk;
                     solution_t2p_t2c_ptr (sol_init8).chrom_com (j)
                       .source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init9).chrom_com (j).mode :=
                       norisk;
                     solution_t2p_t2c_ptr (sol_init9).chrom_com (j)
                       .source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init10).chrom_com (j).mode :=
                       norisk;
                     solution_t2p_t2c_ptr (sol_init10).chrom_com (j)
                       .source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init11).chrom_com (j).mode :=
                       norisk;
                     solution_t2p_t2c_ptr (sol_init11).chrom_com (j)
                       .source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init12).chrom_com (j).mode :=
                       norisk;
                     solution_t2p_t2c_ptr (sol_init12).chrom_com (j)
                       .source_sink :=
                       suppress_space
                         (To_String (Dep_Ptr.precedence_source.name) &
                          "_" &
                          To_String (Dep_Ptr.precedence_sink.name));

                     solution_t2p_t2c_ptr (sol_init13).chrom_com (j).mode :=
                       norisk;
                     solution_t2p_t2c_ptr (sol_init13).chrom_com (j)
                       .source_sink :=
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

                     sol_init7.chrom_com (j).mode        := norisk;
                     sol_init7.chrom_com (j).source_sink :=
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
      normalize (solution_t2p_t2c (sol_init3.all));
      normalize (solution_t2p_t2c (sol_init4.all));
      normalize (solution_t2p_t2c (sol_init5.all));
      normalize (solution_t2p_t2c (sol_init6.all));

      put_debug ("===============c================");
      --Print the chromosome of the initial solutions
      print_genome (solution_t2p_t2c (c.all));
      put_debug ("===============sol_init1================");
      print_genome (solution_t2p_t2c (sol_init1.all));
      put_debug ("===============sol_init2================");
      print_genome (solution_t2p_t2c (sol_init2.all));
      put_debug ("===============sol_init3================");
      print_genome (solution_t2p_t2c (sol_init3.all));
      put_debug ("===============sol_init4================");
      print_genome (solution_t2p_t2c (sol_init4.all));
      put_debug ("===============sol_init5================");
      print_genome (solution_t2p_t2c (sol_init5.all));
      put_debug ("===============sol_init6================");
      print_genome (solution_t2p_t2c (sol_init6.all));
      put_debug ("===============sol_init7================");
      print_genome (solution_t2p_t2c (sol_init7.all));
      put_debug ("===============sol_init8================");
      print_genome (solution_t2p_t2c (sol_init8.all));
      put_debug ("===============sol_init9================");
      print_genome (solution_t2p_t2c (sol_init9.all));
      put_debug ("===============sol_init10================");
      print_genome (solution_t2p_t2c (sol_init10.all));
      put_debug ("===============sol_init11================");
      print_genome (solution_t2p_t2c (sol_init11.all));
      put_debug ("===============sol_init12================");
      print_genome (solution_t2p_t2c (sol_init12.all));
      put_debug ("===============sol_init13================");
      print_genome (solution_t2p_t2c (sol_init13.all));

      if Check_Feasibility_of_A_Solution
          (solution_t2p_t2c (sol_init1.all),
           0)
      then
         Put_Line ("===============sol_init1 evaluation ================");

         evaluate_multicore_T2P (solution_t2p_t2c (sol_init1.all), 0);

         if (Float'value (sol_init1.obj (1)'img) = 0.0) and
           (Float'value (sol_init1.obj (2)'img) = 0.0) and
           (Float'value (sol_init1.obj (3)'img) = 0.0)
         then
            put_debug
              ("MissedDeadlines" &
               sol_init1.obj (1)'img &
               "          Bell    " &
               sol_init1.obj (2)'img &
               "          nb_cores    " &
               sol_init1.obj (3)'img);
            put_debug ("sol_init1 -- Simple design: no need for optimization");

            archive_soln (generic_solution_ptr (sol_init1));
            Create_system (Sys1, solution_t2p_t2c (sol_init1.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p_t2c (sol_init1.all));
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

            Create_system (Sys1, solution_t2p_t2c (sol_init1.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p_t2c (sol_init1.all));

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
      if Check_Feasibility_of_A_Solution
          (solution_t2p_t2c (sol_init7.all),
           0)
      then
         Put_Line ("===============sol_init7 evaluation ================");

         evaluate_multicore_T2P (solution_t2p_t2c (sol_init7.all), 0);

         if (Float'value (sol_init7.obj (1)'img) = 0.0) and
           (Float'value (sol_init7.obj (2)'img) = 0.0) and
           (Float'value (sol_init7.obj (3)'img) = 0.0)
         then
            put_debug
              ("MissedDeadlines" &
               sol_init7.obj (1)'img &
               "          Bell    " &
               sol_init7.obj (2)'img &
               "          nb_cores    " &
               sol_init7.obj (3)'img);
            put_debug ("sol_init7 -- Simple design: no need for optimization");

            archive_soln (generic_solution_ptr (sol_init7));
            Create_system (Sys1, solution_t2p_t2c (sol_init7.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p_t2c (sol_init7.all));
            write_to_xml_file
              (a_system  => Sys1,
               file_name =>
                 To_String
                   (suppress_space
                      (To_Unbounded_String ("sol_init7" & ".xmlv3"))));
            OS_Exit (0);
         else
            archive_soln (generic_solution_ptr (sol_init7));
            update_grid (generic_solution_ptr (sol_init7));

            Append
              (Data3,
               " 0" &
               "              " &
               sol_init7.obj (1)'img &
               "              " &
               sol_init7.obj (2)'img &
               "              " &
               sol_init7.obj (3)'img &
               "              " &
               ASCII.LF);
            put_debug
              ("sol7" &
               "              " &
               sol_init7.obj (1)'img &
               "              " &
               sol_init7.obj (2)'img &
               "              " &
               sol_init7.obj (3)'img &
               "              " &
               ASCII.LF);
            Put_Line
              ("sol7" &
               "              " &
               sol_init7.obj (1)'img &
               "              " &
               sol_init7.obj (2)'img &
               "              " &
               sol_init7.obj (3)'img &
               "              " &
               ASCII.LF);

            nb_InitSol := nb_InitSol + 1;

            Create_system (Sys1, solution_t2p_t2c (sol_init7.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p_t2c (sol_init7.all));

            write_to_xml_file
              (a_system  => Sys1,
               file_name =>
                 To_String
                   (suppress_space
                      (To_Unbounded_String ("sol_init7" & ".xmlv3"))));
            put_debug
              ("=============== end sol_init7 evaluation ================");
         end if;
      end if;
      if Check_Feasibility_of_A_Solution
          (solution_t2p_t2c (sol_init8.all),
           0)
      then
         Put_Line ("===============sol_init8 evaluation ================");

         evaluate_multicore_T2P (solution_t2p_t2c (sol_init8.all), 0);

         if (Float'value (sol_init8.obj (1)'img) = 0.0) and
           (Float'value (sol_init8.obj (2)'img) = 0.0) and
           (Float'value (sol_init8.obj (3)'img) = 0.0)
         then
            put_debug
              ("MissedDeadlines" &
               sol_init8.obj (1)'img &
               "          Bell    " &
               sol_init8.obj (2)'img &
               "          nb_cores    " &
               sol_init8.obj (3)'img);
            put_debug ("sol_init8 -- Simple design: no need for optimization");

            archive_soln (generic_solution_ptr (sol_init8));
            Create_system (Sys1, solution_t2p_t2c (sol_init8.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p_t2c (sol_init8.all));
            write_to_xml_file
              (a_system  => Sys1,
               file_name =>
                 To_String
                   (suppress_space
                      (To_Unbounded_String ("sol_init8" & ".xmlv3"))));
            OS_Exit (0);
         else
            archive_soln (generic_solution_ptr (sol_init8));
            update_grid (generic_solution_ptr (sol_init8));

            Append
              (Data3,
               " 0" &
               "              " &
               sol_init8.obj (1)'img &
               "              " &
               sol_init8.obj (2)'img &
               "              " &
               sol_init8.obj (3)'img &
               "              " &
               ASCII.LF);
            put_debug
              ("sol8" &
               "              " &
               sol_init8.obj (1)'img &
               "              " &
               sol_init8.obj (2)'img &
               "              " &
               sol_init8.obj (3)'img &
               "              " &
               ASCII.LF);
            Put_Line
              ("sol8" &
               "              " &
               sol_init8.obj (1)'img &
               "              " &
               sol_init8.obj (2)'img &
               "              " &
               sol_init8.obj (3)'img &
               "              " &
               ASCII.LF);

            nb_InitSol := nb_InitSol + 1;

            Create_system (Sys1, solution_t2p_t2c (sol_init8.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p_t2c (sol_init8.all));

            write_to_xml_file
              (a_system  => Sys1,
               file_name =>
                 To_String
                   (suppress_space
                      (To_Unbounded_String ("sol_init8" & ".xmlv3"))));
            put_debug
              ("=============== end sol_init8 evaluation ================");
         end if;
      end if;
      ----
      if Check_Feasibility_of_A_Solution
          (solution_t2p_t2c (sol_init9.all),
           0)
      then
         Put_Line ("===============sol_init9 evaluation ================");

         evaluate_multicore_T2P (solution_t2p_t2c (sol_init9.all), 0);

         if (Float'value (sol_init9.obj (1)'img) = 0.0) and
           (Float'value (sol_init9.obj (2)'img) = 0.0) and
           (Float'value (sol_init9.obj (3)'img) = 0.0)
         then
            put_debug
              ("MissedDeadlines" &
               sol_init9.obj (1)'img &
               "          Bell    " &
               sol_init9.obj (2)'img &
               "          nb_cores    " &
               sol_init9.obj (3)'img);
            put_debug ("sol_init9 -- Simple design: no need for optimization");

            archive_soln (generic_solution_ptr (sol_init9));
            Create_system (Sys1, solution_t2p_t2c (sol_init9.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p_t2c (sol_init9.all));
            write_to_xml_file
              (a_system  => Sys1,
               file_name =>
                 To_String
                   (suppress_space
                      (To_Unbounded_String ("sol_init9" & ".xmlv3"))));
            OS_Exit (0);
         else
            archive_soln (generic_solution_ptr (sol_init9));
            update_grid (generic_solution_ptr (sol_init9));

            Append
              (Data3,
               " 0" &
               "              " &
               sol_init9.obj (1)'img &
               "              " &
               sol_init9.obj (2)'img &
               "              " &
               sol_init9.obj (3)'img &
               "              " &
               ASCII.LF);
            put_debug
              ("sol9" &
               "              " &
               sol_init9.obj (1)'img &
               "              " &
               sol_init9.obj (2)'img &
               "              " &
               sol_init9.obj (3)'img &
               "              " &
               ASCII.LF);
            Put_Line
              ("sol9" &
               "              " &
               sol_init9.obj (1)'img &
               "              " &
               sol_init9.obj (2)'img &
               "              " &
               sol_init9.obj (3)'img &
               "              " &
               ASCII.LF);

            nb_InitSol := nb_InitSol + 1;

            Create_system (Sys1, solution_t2p_t2c (sol_init9.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p_t2c (sol_init9.all));

            write_to_xml_file
              (a_system  => Sys1,
               file_name =>
                 To_String
                   (suppress_space
                      (To_Unbounded_String ("sol_init9" & ".xmlv3"))));
            put_debug
              ("=============== end sol_init9 evaluation ================");
         end if;
      end if;
      --
      if Check_Feasibility_of_A_Solution
          (solution_t2p_t2c (sol_init10.all),
           0)
      then
         Put_Line ("===============sol_init10 evaluation ================");

         evaluate_multicore_T2P (solution_t2p_t2c (sol_init10.all), 0);

         if (Float'value (sol_init10.obj (1)'img) = 0.0) and
           (Float'value (sol_init10.obj (2)'img) = 0.0) and
           (Float'value (sol_init10.obj (3)'img) = 0.0)
         then
            put_debug
              ("MissedDeadlines" &
               sol_init10.obj (1)'img &
               "          Bell    " &
               sol_init10.obj (2)'img &
               "          nb_cores    " &
               sol_init10.obj (3)'img);
            put_debug
              ("sol_init10 -- Simple design: no need for optimization");

            archive_soln (generic_solution_ptr (sol_init10));
            Create_system (Sys1, solution_t2p_t2c (sol_init10.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p_t2c (sol_init10.all));
            write_to_xml_file
              (a_system  => Sys1,
               file_name =>
                 To_String
                   (suppress_space
                      (To_Unbounded_String ("sol_init10" & ".xmlv3"))));
            OS_Exit (0);
         else
            archive_soln (generic_solution_ptr (sol_init10));
            update_grid (generic_solution_ptr (sol_init10));

            Append
              (Data3,
               " 0" &
               "              " &
               sol_init10.obj (1)'img &
               "              " &
               sol_init10.obj (2)'img &
               "              " &
               sol_init10.obj (3)'img &
               "              " &
               ASCII.LF);
            put_debug
              ("sol10" &
               "              " &
               sol_init10.obj (1)'img &
               "              " &
               sol_init10.obj (2)'img &
               "              " &
               sol_init10.obj (3)'img &
               "              " &
               ASCII.LF);
            Put_Line
              ("sol10" &
               "              " &
               sol_init10.obj (1)'img &
               "              " &
               sol_init10.obj (2)'img &
               "              " &
               sol_init10.obj (3)'img &
               "              " &
               ASCII.LF);

            nb_InitSol := nb_InitSol + 1;

            Create_system (Sys1, solution_t2p_t2c (sol_init10.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p_t2c (sol_init10.all));

            write_to_xml_file
              (a_system  => Sys1,
               file_name =>
                 To_String
                   (suppress_space
                      (To_Unbounded_String ("sol_init10" & ".xmlv3"))));
            put_debug
              ("=============== end sol_init10 evaluation ================");
         end if;
      end if;
      --
      if Check_Feasibility_of_A_Solution
          (solution_t2p_t2c (sol_init11.all),
           0)
      then
         Put_Line ("===============sol_init11 evaluation ================");

         evaluate_multicore_T2P (solution_t2p_t2c (sol_init11.all), 0);

         if (Float'value (sol_init11.obj (1)'img) = 0.0) and
           (Float'value (sol_init11.obj (2)'img) = 0.0) and
           (Float'value (sol_init11.obj (3)'img) = 0.0)
         then
            put_debug
              ("MissedDeadlines" &
               sol_init11.obj (1)'img &
               "          Bell    " &
               sol_init11.obj (2)'img &
               "          nb_cores    " &
               sol_init11.obj (3)'img);
            put_debug
              ("sol_init11 -- Simple design: no need for optimization");

            archive_soln (generic_solution_ptr (sol_init11));
            Create_system (Sys1, solution_t2p_t2c (sol_init11.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p_t2c (sol_init11.all));
            write_to_xml_file
              (a_system  => Sys1,
               file_name =>
                 To_String
                   (suppress_space
                      (To_Unbounded_String ("sol_init11" & ".xmlv3"))));
            OS_Exit (0);
         else
            archive_soln (generic_solution_ptr (sol_init11));
            update_grid (generic_solution_ptr (sol_init11));

            Append
              (Data3,
               " 0" &
               "              " &
               sol_init11.obj (1)'img &
               "              " &
               sol_init11.obj (2)'img &
               "              " &
               sol_init11.obj (3)'img &
               "              " &
               ASCII.LF);
            put_debug
              ("sol11" &
               "              " &
               sol_init11.obj (1)'img &
               "              " &
               sol_init11.obj (2)'img &
               "              " &
               sol_init11.obj (3)'img &
               "              " &
               ASCII.LF);
            Put_Line
              ("sol11" &
               "              " &
               sol_init11.obj (1)'img &
               "              " &
               sol_init11.obj (2)'img &
               "              " &
               sol_init11.obj (3)'img &
               "              " &
               ASCII.LF);

            nb_InitSol := nb_InitSol + 1;

            Create_system (Sys1, solution_t2p_t2c (sol_init11.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p_t2c (sol_init11.all));

            write_to_xml_file
              (a_system  => Sys1,
               file_name =>
                 To_String
                   (suppress_space
                      (To_Unbounded_String ("sol_init11" & ".xmlv3"))));
            put_debug
              ("=============== end sol_init11 evaluation ================");
         end if;
      end if;

      if Check_Feasibility_of_A_Solution
          (solution_t2p_t2c (sol_init12.all),
           0)
      then
         Put_Line ("===============sol_init12 evaluation ================");
         evaluate_multicore_T2P (solution_t2p_t2c (sol_init12.all), 0);

         if (Float'value (sol_init12.obj (1)'img) = 0.0) and
           (Float'value (sol_init12.obj (2)'img) = 0.0) and
           (Float'value (sol_init12.obj (3)'img) = 0.0)
         then
            put_debug
              ("MissedDeadlines" &
               sol_init12.obj (1)'img &
               "          Bell    " &
               sol_init12.obj (2)'img &
               "          nb_cores    " &
               sol_init12.obj (3)'img);
            put_debug
              ("sol_init12 -- Simple design: no need for optimization");

            archive_soln (generic_solution_ptr (sol_init12));
            Create_system (Sys1, solution_t2p_t2c (sol_init12.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p_t2c (sol_init12.all));
            write_to_xml_file
              (a_system  => Sys1,
               file_name =>
                 To_String
                   (suppress_space
                      (To_Unbounded_String ("sol_init12" & ".xmlv3"))));
            OS_Exit (0);
         else
            archive_soln (generic_solution_ptr (sol_init12));
            update_grid (generic_solution_ptr (sol_init12));

            Append
              (Data3,
               " 0" &
               "              " &
               sol_init12.obj (1)'img &
               "              " &
               sol_init12.obj (2)'img &
               "              " &
               sol_init12.obj (3)'img &
               "              " &
               ASCII.LF);
            put_debug
              ("sol12" &
               "              " &
               sol_init12.obj (1)'img &
               "              " &
               sol_init12.obj (2)'img &
               "              " &
               sol_init12.obj (3)'img &
               "              " &
               ASCII.LF);
            Put_Line
              ("sol12" &
               "              " &
               sol_init12.obj (1)'img &
               "              " &
               sol_init12.obj (2)'img &
               "              " &
               sol_init12.obj (3)'img &
               "              " &
               ASCII.LF);

            nb_InitSol := nb_InitSol + 1;

            Create_system (Sys1, solution_t2p_t2c (sol_init12.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p_t2c (sol_init12.all));

            write_to_xml_file
              (a_system  => Sys1,
               file_name =>
                 To_String
                   (suppress_space
                      (To_Unbounded_String ("sol_init12" & ".xmlv3"))));
            put_debug
              ("=============== end sol_init12 evaluation ================");
         end if;
      end if;

      if Check_Feasibility_of_A_Solution
          (solution_t2p_t2c (sol_init13.all),
           0)
      then
         evaluate_multicore_T2P (solution_t2p_t2c (sol_init13.all), 0);
         Put_Line ("===============sol_init13 evaluation ================");

         if (Float'value (sol_init13.obj (1)'img) = 0.0) and
           (Float'value (sol_init13.obj (2)'img) = 0.0) and
           (Float'value (sol_init13.obj (3)'img) = 0.0)
         then
            put_debug
              ("MissedDeadlines" &
               sol_init13.obj (1)'img &
               "          Bell    " &
               sol_init13.obj (2)'img &
               "          nb_cores    " &
               sol_init13.obj (3)'img);
            put_debug
              ("sol_init13 -- Simple design: no need for optimization");

            archive_soln (generic_solution_ptr (sol_init13));
            Create_system (Sys1, solution_t2p_t2c (sol_init13.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p_t2c (sol_init13.all));
            write_to_xml_file
              (a_system  => Sys1,
               file_name =>
                 To_String
                   (suppress_space
                      (To_Unbounded_String ("sol_init13" & ".xmlv3"))));
            OS_Exit (0);
         else
            archive_soln (generic_solution_ptr (sol_init13));
            update_grid (generic_solution_ptr (sol_init13));

            Append
              (Data3,
               " 0" &
               "              " &
               sol_init13.obj (1)'img &
               "              " &
               sol_init13.obj (2)'img &
               "              " &
               sol_init13.obj (3)'img &
               "              " &
               ASCII.LF);
            put_debug
              ("sol13" &
               "              " &
               sol_init13.obj (1)'img &
               "              " &
               sol_init13.obj (2)'img &
               "              " &
               sol_init13.obj (3)'img &
               "              " &
               ASCII.LF);
            Put_Line
              ("sol13" &
               "              " &
               sol_init13.obj (1)'img &
               "              " &
               sol_init13.obj (2)'img &
               "              " &
               sol_init13.obj (3)'img &
               "              " &
               ASCII.LF);

            nb_InitSol := nb_InitSol + 1;

            Create_system (Sys1, solution_t2p_t2c (sol_init13.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys1,
               solution_t2p_t2c (sol_init13.all));

            write_to_xml_file
              (a_system  => Sys1,
               file_name =>
                 To_String
                   (suppress_space
                      (To_Unbounded_String ("sol_init13" & ".xmlv3"))));
            put_debug
              ("=============== end sol_init13 evaluation ================");
         end if;
         --
      end if;

      --Just for version 3-------
      if (t2p_exploration_version = 3) then

         if Check_Feasibility_of_A_Solution
             (solution_t2p_t2c (sol_init2.all),
              0)
         then
            Put_Line ("===============sol_init2 evaluation ================");
            put_debug ("===============sol_init2 evaluation ================");
            evaluate_multicore_T2P (solution_t2p_t2c (sol_init2.all), 0);
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
                  sol_init2.obj (3)'img &
                  "          nb_cores    " &
                  sol_init2.obj (4)'img);
               put_debug
                 ("sol_init2 -- Simple design: no need for optimization");
               archive_soln (generic_solution_ptr (sol_init2));
               Create_system (Sys1, solution_t2p_t2c (sol_init2.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys1,
                  solution_t2p_t2c (sol_init2.all));
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
                  sol_init2.obj (4)'img &
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
                  sol_init2.obj (4)'img &
                  "              " &
                  ASCII.LF);

               nb_InitSol := nb_InitSol + 1;

               Create_system (Sys2, solution_t2p_t2c (sol_init2.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys2,
                  solution_t2p_t2c (sol_init2.all));
               write_to_xml_file
                 (a_system  => Sys2,
                  file_name =>
                    To_String
                      (suppress_space
                         (To_Unbounded_String ("sol_init2" & ".xmlv3"))));

            end if;
         end if;

         if Check_Feasibility_of_A_Solution
             (solution_t2p_t2c (sol_init3.all),
              0)
         then
            put_debug ("===============sol_init3 evaluation ================");
            evaluate_multicore_T2P (solution_t2p_t2c (sol_init3.all), 0);
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
                  sol_init3.obj (3)'img &
                  "          nb_cores    " &
                  sol_init3.obj (4)'img);
               put_debug
                 ("sol_init3 -- Simple design: no need for optimization");
               archive_soln (generic_solution_ptr (sol_init3));
               Create_system (Sys1, solution_t2p_t2c (sol_init3.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys1,
                  solution_t2p_t2c (sol_init3.all));
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
                  sol_init3.obj (4)'img &
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
                  sol_init3.obj (4)'img &
                  "              " &
                  ASCII.LF);
               nb_InitSol := nb_InitSol + 1;

               Create_system (Sys3, solution_t2p_t2c (sol_init3.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys3,
                  solution_t2p_t2c (sol_init3.all));
               write_to_xml_file
                 (a_system  => Sys3,
                  file_name =>
                    To_String
                      (suppress_space
                         (To_Unbounded_String ("sol_init3" & ".xmlv3"))));

            end if;
         end if;

         if Check_Feasibility_of_A_Solution
             (solution_t2p_t2c (sol_init4.all),
              0)
         then
            put_debug ("===============sol_init4 evaluation ================");
            evaluate_multicore_T2P (solution_t2p_t2c (sol_init4.all), 0);
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
                  sol_init4.obj (3)'img &
                  "          nb_cores    " &
                  sol_init4.obj (4)'img);
               put_debug
                 ("sol_init4 -- Simple design: no need for optimization");
               archive_soln (generic_solution_ptr (sol_init4));
               Create_system (Sys1, solution_t2p_t2c (sol_init4.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys1,
                  solution_t2p_t2c (sol_init4.all));
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
                  sol_init4.obj (4)'img &
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
                  sol_init4.obj (4)'img &
                  "              " &
                  ASCII.LF);

               nb_InitSol := nb_InitSol + 1;

               Create_system (Sys4, solution_t2p_t2c (sol_init4.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys4,
                  solution_t2p_t2c (sol_init4.all));
               write_to_xml_file
                 (a_system  => Sys4,
                  file_name =>
                    To_String
                      (suppress_space
                         (To_Unbounded_String ("sol_init4" & ".xmlv3"))));

            end if;
         end if;

         --
         if Check_Feasibility_of_A_Solution
             (solution_t2p_t2c (sol_init5.all),
              0)
         then
            put_debug ("===============sol_init5 evaluation ================");
            evaluate_multicore_T2P (solution_t2p_t2c (sol_init5.all), 0);
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
                  sol_init5.obj (3)'img &
                  "          nb_cores    " &
                  sol_init5.obj (4)'img);
               put_debug
                 ("sol_init5 -- Simple design: no need for optimization");
               archive_soln (generic_solution_ptr (sol_init5));
               Create_system (Sys1, solution_t2p_t2c (sol_init5.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys1,
                  solution_t2p_t2c (sol_init5.all));
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
                  sol_init5.obj (4)'img &
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
                  sol_init5.obj (4)'img &
                  "              " &
                  ASCII.LF);

               nb_InitSol := nb_InitSol + 1;

               Create_system (Sys5, solution_t2p_t2c (sol_init5.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys5,
                  solution_t2p_t2c (sol_init5.all));
               write_to_xml_file
                 (a_system  => Sys5,
                  file_name =>
                    To_String
                      (suppress_space
                         (To_Unbounded_String ("sol_init5" & ".xmlv3"))));

            end if;
         end if;

         if Check_Feasibility_of_A_Solution
             (solution_t2p_t2c (sol_init6.all),
              0)
         then
            put_debug ("===============sol_init6 evaluation ================");
            evaluate_multicore_T2P (solution_t2p_t2c (sol_init6.all), 0);
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
                  sol_init6.obj (3)'img &
                  "          nb_cores    " &
                  sol_init6.obj (4)'img);
               put_debug
                 ("sol_init6 -- Simple design: no need for optimization");
               archive_soln (generic_solution_ptr (sol_init6));
               Create_system (Sys1, solution_t2p_t2c (sol_init6.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys1,
                  solution_t2p_t2c (sol_init6.all));
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
                  sol_init6.obj (4)'img &
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
                  sol_init6.obj (4)'img &
                  "              " &
                  ASCII.LF);

               nb_InitSol := nb_InitSol + 1;

               Create_system (Sys6, solution_t2p_t2c (sol_init6.all));
               Transform_Chromosome_To_CheddarADL_Model
                 (Sys6,
                  solution_t2p_t2c (sol_init6.all));
               write_to_xml_file
                 (a_system  => Sys6,
                  file_name =>
                    To_String
                      (suppress_space
                         (To_Unbounded_String ("sol_init6" & ".xmlv3"))));
            end if;
         end if;

      end if;
      if Check_Feasibility_of_A_Solution (solution_t2p_t2c (c.all), 0) then
         evaluate_multicore_T2P (solution_t2p_t2c (c.all), 0);

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
               "          nb_cores    " &
               c.obj (3)'img);
            put_debug ("Simple design: no need for optimization");

            archive_soln (c);
            Create_system (Sys7, solution_t2p_t2c (c.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys7,
               solution_t2p_t2c (c.all));
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
               ASCII.LF);
            nb_InitSol := nb_InitSol + 1;

            Create_system (Sys7, solution_t2p_t2c (c.all));
            Transform_Chromosome_To_CheddarADL_Model
              (Sys7,
               solution_t2p_t2c (c.all));
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
   end init_multicore_T2P;

   ----------------
   -- mutate_multicore_T2P --
   ----------------

   procedure mutate_multicore_T2P
     (s    : in out generic_solution'class;
      eidx : in     Natural)
   is

      random_partition,
      random_app,
      random_core,
      tn,
      x,
      step_t2p_half_iter,
      step_t2c_half_iter,
      step_t2p,
      cn,
      finish                   : Integer;
      l, e                     : Integer := 0;
      A_system                 : systems.system;
      A_Task_set, New_Task_set : tasks_set;
      counter, sft             : Integer := 0;

      Sol_is_mutated : Boolean;

      A_sol : solution_t2p_t2c;

      New_resource_set : resources_set;

      A_task_source : generic_task_ptr;
      A_task_sink   : generic_task_ptr;

      task_source : Integer := 0;
      task_sink   : Integer := 0;
   begin

      Create_system (A_system, solution_t2p_t2c (s));
      Sol_is_mutated     := False;
      step_t2p_half_iter := iterations / 4;
      Put_Line ("step_t2p_half_iter: " & step_t2p_half_iter'img);
      step_t2c_half_iter := 3 * iterations / 4;
      Put_Line ("step_t2c_half_iter: " & step_t2c_half_iter'img);
      step_t2p := iterations / 2;
      Put_Line ("step_t2p: " & step_t2p'img);

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

         A_sol := solution_t2p_t2c (s);
         if (iter <= step_t2p) then
            random_partition := 0;

            while (random_partition > nb_partitions) or (random_partition <= 3)
            loop
               random_partition :=
                 Integer (Float (nb_partitions) * Random (G));
            end loop;
            put_debug
              ("The randomly chosen partition is : " & random_partition'img);
            Put_Line
              ("The randomly chosen partition is : " & random_partition'img);
            Put_Line ("iterrrrrrrrrrr :" & iter'img);

            if (t2p_exploration_version = 1) or
              ((t2p_exploration_version = 2) and (iter <= step_t2p_half_iter))
            then

               random_app := 0;
               while (random_app > nb_app) or (random_app < 1) loop
                  random_app := Integer (Float (nb_app) * Random (G));
               end loop;
               put_debug
                 ("The randomly chosen application is : " & random_app'img);
               Put_Line
                 ("The randomly chosen application is : " & random_app'img);
               -- Move tasks of the random_app to the random_partition
               for l in 1 .. genes loop
                  if (task_to_app (l) = random_app) then
                     A_sol.chrom_t2p (l) := random_partition;
                  end if;
                  Sol_is_mutated := True;
               end loop;
            ---
            elsif (t2p_exploration_version = 3) or
              ((t2p_exploration_version = 2) and (iter > step_t2p_half_iter))
            then

               --  choose randomly an index of a task between 1 and genes
               tn := 0;
               while (tn > genes) or (tn < 1) loop
                  tn := Integer (Float (genes) * Random (G));
               end loop;

               put_debug ("The randomly chosen task is : " & tn'img);
               Put_Line ("The randomly chosen task is : " & tn'img);
               -- the task "tn" is not intially in the partition "random_partition" then "tn" is moved
               -- to the partition "random_partition"
               if (random_partition /= A_sol.chrom_t2p (tn)) then
                  A_sol.chrom_t2p (tn) := random_partition;
                  Sol_is_mutated       := True;
               end if;

            end if;
         else
            random_core := 0;

            while (random_core > nb_cores) or (random_core < 1) loop
               random_core := Integer (Float (nb_cores) * Random (G));
            end loop;
            put_debug ("The randomly chosen core is : " & random_core'img);
            Put_Line ("The randomly chosen core is : " & random_core'img);
            Put_Line ("iterrrrrrrrrrr :" & iter'img);
            if (t2c_exploration_version = 1) or
              ((t2c_exploration_version = 2) and (iter <= step_t2c_half_iter))
            then
               random_app := 0;
               while (random_app > nb_app) or (random_app < 1) loop
                  random_app := Integer (Float (nb_app) * Random (G));
               end loop;
               put_debug
                 ("The randomly chosen application is : " & random_app'img);
               Put_Line
                 ("The randomly chosen application is : " & random_app'img);
               -- Move tasks of the random_app to the random_core
               for l in 1 .. genes loop
                  if (task_to_app (l) = random_app) then
                     A_sol.chrom_t2c (l) := random_core;
                  end if;
                  Sol_is_mutated := True;
               end loop;
            elsif (t2c_exploration_version = 3) or
              ((t2c_exploration_version = 2) and (iter > step_t2c_half_iter))
            then
               --  choose randomly an index of a task between 1 and genes
               tn := 0;
               while (tn > genes) or (tn < 1) loop
                  tn := Integer (Float (genes) * Random (G));
               end loop;
               put_debug ("The randomly chosen task is : " & tn'img);
               Put_Line ("The randomly chosen task is : " & tn'img);
               -- the task "tn" is not intially in the partition "random_partition" then "tn" is moved
               -- to the partition "random_core"
               if (random_partition /= A_sol.chrom_t2c (tn)) then
                  A_sol.chrom_t2c (tn) := random_core;
                  Sol_is_mutated       := True;
               end if;

            end if;

         end if;

         -- communication mutation
         -- choose randomly an index of a communication between 1 and genes_com for risky communications Low
         x := 0;

         while (x > Nb_NonSecure_low) or (x < 1) loop
            x := Integer (Float (Nb_NonSecure_low) * Random (G));
         end loop;
         cn     := NonSecure_list (x);
         finish := Index (A_sol.chrom_com (cn).source_sink, "_");
         put_debug ("The randomly chosen communication is : " & cn'img);
         put_debug
           ("This chosen communication is : " &
            solution_t2p_t2c (s).chrom_com (cn).mode'img &
            " " &
            To_String (solution_t2p_t2c (s).chrom_com (cn).source_sink));
         finish := Index (A_sol.chrom_com (cn).source_sink, "_");

         A_task_source :=
           search_task
             (Initial_System.tasks,
              suppress_space
                (Unbounded_Slice
                   (solution_t2p_t2c (s).chrom_com (cn).source_sink,
                    1,
                    finish - 1)));
         A_task_sink :=
           search_task
             (Initial_System.tasks,
              suppress_space
                (Unbounded_Slice
                   (solution_t2p_t2c (s).chrom_com (cn).source_sink,
                    finish + 1,
                    Length
                      (solution_t2p_t2c (s).chrom_com (cn).source_sink))));

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
               Sol_is_mutated := True;
               s              := generic_solution'class (A_sol);
            --               nb_secu_conf_choice(sol_config):=nb_secu_conf_choice(sol_config)+1;
            else

               put_debug
                 (" The candidate solution is NOt Feasible " &
                  " we should regenerate another candidate solution");
               Put_Line
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

   end mutate_multicore_T2P;

   ---------------
   -- normalize --
   ---------------

   procedure normalize (s : in out solution_t2p_t2c) is

      nb_partitions, nb_cores : Integer := 1;
      --  the vector var is used to know if a gene is normalized or not yet
      var_t2p : chrom_task_type;
      var_t2c : chrom_task_type;
   begin
      --  initialization of the vector var.
      for i in 1 .. genes loop
         var_t2p (i) := 0;
         var_t2c (i) := 0;
      end loop;

      ------------------------------------------------------------
      --  if var_t2p(i) = 0   ==>  s.chrom_t2p(i) is not yet normalized
      --  if var_t2p(i) = 1   ==>  s.chrom_t2p(i) is normalized
      ------------------------------------------------------------

      for i in 1 .. genes loop

         if (var_t2p (i) = 0) then

            for j in i + 1 .. genes loop
               if (s.chrom_t2p (j) = s.chrom_t2p (i))
                 and then (var_t2p (j) = 0)
               then
                  var_t2p (j) := 1;
                  --  if s.chrom_t2p(i) is not normalized then all s.chrom_t2p(j) (which egal s.all.chrom_t2p(i))
                  --  are not normalized
                  if (s.chrom_t2p (i) /= nb_partitions) then
                     s.chrom_t2p (j) := nb_partitions;
                  end if;
               end if;
            end loop;

            -- we normalize s.chrom_t2p(i)
            if (s.chrom_t2p (i) /= nb_partitions) then
               s.chrom_t2p (i) := nb_partitions;
            end if;
            var_t2p (i)   := 1;
            nb_partitions := nb_partitions + 1;
         end if;
         --
         if (var_t2c (i) = 0) then
            for j in i + 1 .. genes loop
               if (s.chrom_t2c (j) = s.chrom_t2c (i))
                 and then (var_t2c (j) = 0)
               then
                  var_t2c (j) := 1;
                  --  if s.chrom_t2c(i) is not normalized then all s.chrom_t2c(j) (which egal s.all.chrom_t2c(i))
                  --  are not normalized
                  if (s.chrom_t2c (i) /= nb_cores) then
                     s.chrom_t2c (j) := nb_cores;
                  end if;
               end if;
            end loop;

            -- we normalize s.chrom_t2c(i)
            if (s.chrom_t2c (i) /= nb_cores) then
               s.chrom_t2c (i) := nb_cores;
            end if;
            var_t2c (i) := 1;
            nb_cores    := nb_cores + 1;
         end if;

      end loop;

   end normalize;

   ---------------------
   -- Number_of_partitions --
   ---------------------

   function Number_of_partitions (s : in solution_t2p_t2c) return Integer is
      permutation        : Integer := 1;
      var                : chrom_task_type;
      nb_partitions, tmp : Integer;
   begin
      --  assignment of the table var with elements of s.chrom
      for i in 1 .. genes loop
         var (i) := s.chrom_t2p (i);
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

   ---------------------
   -- Number_of_cores --
   ---------------------

   function Number_of_cores (s : in solution_t2p_t2c) return Integer is
      permutation   : Integer := 1;
      var           : chrom_task_type;
      nb_cores, tmp : Integer;
   begin
      --  assignment of the table var with elements of s.chrom
      for i in 1 .. genes loop
         var (i) := s.chrom_t2c (i);
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

      nb_cores := genes;

      for i in 1 .. genes - 1 loop
         if (var (i) = var (i + 1)) then
            nb_cores := nb_cores - 1;
         end if;
      end loop;

      return nb_cores;

   end Number_of_cores;

   ----------------------------------------------
   -- Transform_Chromosome_To_CheddarADL_Model --
   ----------------------------------------------

   procedure Transform_Chromosome_To_CheddarADL_Model
     (A_sys : in out systems.system;
      s     : in     solution_t2p_t2c)
   is

      A_Tasks_set : tasks_set;
      A_Task      : periodic_task;

      period_i                       : Natural;
      capacity_i                     : Natural;
      deadline_i                     : Natural;
      priority_i                     : Natural;
      criticality_i                  : Natural;
      confidentiality_i, integrity_i : Unbounded_String;

      encrypt_addr, decrypt_addr                            : Unbounded_String;
      capacity_encrypter, capacity_decrypter, capacity_hash : Natural;
      y, j, m, finish                                       : Integer;

      A_task_name : Unbounded_String;

      A_task_source : generic_task_ptr;
      A_task_sink   : generic_task_ptr;

   begin

      -- 1) Generate the tasks set from the solution s
      --
      --     nb_tasks := number_of_tasks(s);

      initialize (A_sys.tasks);
      initialize (A_sys.dependencies.depends);
      for i in 1 .. genes loop
         --         k := s.chrom_t2p(i);
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
         if (Number_of_cores (s) = 1) then
            add_task
              (my_tasks           => A_sys.tasks,
               name => suppress_space (To_Unbounded_String ("" & i'img)),
               cpu_name => suppress_space (To_Unbounded_String ("processor1")),
               address_space_name =>
                 suppress_space
                   (To_Unbounded_String ("addr" & s.chrom_t2p (i)'img)),
               core_name =>
                 suppress_space
                   (To_Unbounded_String
                      ("")), --Monocore-->no task/core affinity
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
         else
            add_task
              (my_tasks           => A_sys.tasks,
               name => suppress_space (To_Unbounded_String ("" & i'img)),
               cpu_name => suppress_space (To_Unbounded_String ("processor1")),
               address_space_name =>
                 suppress_space
                   (To_Unbounded_String ("addr" & s.chrom_t2p (i)'img)),
               core_name =>
                 suppress_space
                   (To_Unbounded_String ("core" & s.chrom_t2c (i)'img)),
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
         end if;
         New_Line;

      end loop;

      -- 2) Generate the dependencies and secure the system depending on the choosen security configuration
      --
      nb_bell_resolved := 0;
      nb_biba_resolved := 0;
      --  PARTIE A GENERALISER avec security_configuration1(A_sys, s);
      j := 1;

      y :=
        Integer
          (get_number_of_task_from_processor
             (A_sys.tasks,
              To_Unbounded_String ("processor1")));
      while (j <= genes_com) loop
         finish        := Index (s.chrom_com (j).source_sink, "_");
         A_task_source :=
           search_task
             (A_sys.tasks,
              suppress_space
                (Unbounded_Slice
                   (s.chrom_com (j).source_sink,
                    1,
                    finish - 1)));
         A_task_sink :=
           search_task
             (A_sys.tasks,
              suppress_space
                (Unbounded_Slice
                   (s.chrom_com (j).source_sink,
                    finish + 1,
                    Length (s.chrom_com (j).source_sink))));
         m                  := Integer'value (To_String (A_task_source.name));
         capacity_encrypter := encrypter_values (task_to_app (m));
         capacity_decrypter :=
           decrypter_values
             (task_to_app
                (m));   -- assumption capacity_encrypter=capacity_decrypter
         capacity_hash := Hash_values (task_to_app (m));
         -- add dependencies between tasks
         add_one_task_dependency_precedence
           (my_dependencies => A_sys.dependencies,
            source          => A_task_source,
            sink            => A_task_sink);
         if (s.chrom_com (j).mode = secure) then
            if
              (A_task_sink.mils_confidentiality_level <
               A_task_source.mils_confidentiality_level)
            then
               y := y + 1;
               put_debug
                 ("Downgrader (Encrypter & Decrypter): " &
                  y'img &
                  " is added");
               A_task_source.capacity :=
                 A_task_source.capacity + capacity_encrypter + Key_value;
               A_task_sink.capacity :=
                 A_task_sink.capacity + capacity_decrypter + Key_value;
               nb_bell_resolved := nb_bell_resolved + 1;
            end if;
            if
              (A_task_source.mils_integrity_level <
               A_task_sink.mils_integrity_level)
            then
               y := y + 1;
               put_debug ("Upgrader : " & y'img & " is added");
               A_task_source.capacity :=
                 A_task_source.capacity + capacity_hash;
               A_task_sink.capacity := A_task_sink.capacity + capacity_hash;
               nb_biba_resolved     := nb_biba_resolved + 1;

            end if;

         end if;
         j := j + 1;
      end loop;
      --

      -- consider inter and intra communications overheads
      com_overhead (A_sys, s);
      put_debug ("end_transform");
   end Transform_Chromosome_To_CheddarADL_Model;

   -------------------------------------------
   -- consider inter and intra partition --
   -------------------------------------------
   procedure com_overhead
     (A_sys : in out systems.system;
      s     : in     solution_t2p_t2c)
   is
      My_iterator     : tasks_dependencies_iterator;
      Dep_Ptr         : dependency_ptr;
      My_dependencies : tasks_dependencies_ptr;
      My_iterator1    : tasks_iterator;
      tasks_ptr       : generic_task_ptr;
      m, nb_cores_sol : Integer;

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
              (Dep_Ptr.precedence_source.core_name /=
               Dep_Ptr.precedence_sink.core_name)
            then
               --intercore communication overheads
               Dep_Ptr.precedence_source.capacity :=
                 Dep_Ptr.precedence_source.capacity +
                 write_intercore_overhead_values (task_to_app (m));
               Dep_Ptr.precedence_sink.capacity :=
                 Dep_Ptr.precedence_sink.capacity +
                 read_intercore_overhead_values (task_to_app (m));
            elsif
              (Dep_Ptr.precedence_source.address_space_name =
               Dep_Ptr.precedence_sink.address_space_name)
            then
               --intra partition communication overheads
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
         for i in 1 .. 7 loop
            com_cost (i) := 0.0;
         end loop;
         reset_iterator (My_dependencies.depends, My_iterator);
         loop
            current_element (My_dependencies.depends, Dep_Ptr, My_iterator);
            m := Integer'value (To_String (Dep_Ptr.precedence_source.name));
            if
              (Dep_Ptr.precedence_source.core_name /=
               Dep_Ptr.precedence_sink.core_name)
            then
               com_cost (6) := com_cost (6) + 1.0;
               com_cost (7) := com_cost (7) + 1.0;
               com_cost (5) :=
                 com_cost (5) +
                 Float
                   (write_intercore_overhead_values (task_to_app (m)) *
                    (Hyperperiod_of_Initial_Taskset /
                     Dep_Ptr.precedence_source.deadline) +
                    read_intercore_overhead_values (task_to_app (m)) *
                      (Hyperperiod_of_Initial_Taskset /
                       Dep_Ptr.precedence_sink.deadline));

            elsif
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
   ----- Safety-------
   -------------------

   procedure Safety (A_sys : in out systems.system; s : in solution_t2p_t2c) is
      G                              : Ada.Numerics.Float_Random.Generator;
      y, j                           : Integer;
      addr                           : Integer;
      period_i                       : Natural;
      capacity_i                     : Natural;
      deadline_i                     : Natural;
      priority_i                     : Natural;
      criticality_i                  : Natural;
      confidentiality_i, integrity_i : Unbounded_String;
      my_iterator                    : tasks_dependencies_iterator;
      my_iterator2                   : tasks_dependencies_iterator;
      dep_ptr                        : dependency_ptr;
      dep_ptr2                       : dependency_ptr;
      my_dependencies                : tasks_dependencies_ptr;
      my_dependencies2               : tasks_dependencies_ptr;
      A_task_source                  : Integer;
      A_task_sink                    : Integer;

   begin
      y                := genes;
      j                := 0;
      my_dependencies  := A_sys.dependencies;
      my_dependencies2 := new tasks_dependencies;

      for i in genes + 1 .. 3 * genes loop

         if (i = genes + 1) or (i = 2 * genes + 1) then
            j := 1;
         else
            j := j + 1;
         end if;

         period_i :=
           get
             (my_tasks   => Initial_System.tasks,
              task_name  => suppress_space (To_Unbounded_String ("" & j'img)),
              param_name => period);

         capacity_i :=
           get
             (my_tasks   => Initial_System.tasks,
              task_name  => suppress_space (To_Unbounded_String ("" & j'img)),
              param_name => capacity);
         deadline_i :=
           get
             (my_tasks   => Initial_System.tasks,
              task_name  => suppress_space (To_Unbounded_String ("" & j'img)),
              param_name => deadline);
         priority_i :=
           get
             (my_tasks   => Initial_System.tasks,
              task_name  => suppress_space (To_Unbounded_String ("" & j'img)),
              param_name => task_set.priority);
         criticality_i :=
           get
             (my_tasks   => Initial_System.tasks,
              task_name  => suppress_space (To_Unbounded_String ("" & j'img)),
              param_name => criticality);
         confidentiality_i :=
           get
             (my_tasks   => Initial_System.tasks,
              task_name  => suppress_space (To_Unbounded_String ("" & j'img)),
              param_name => mils_confidentiality_level);
         integrity_i :=
           get
             (my_tasks   => Initial_System.tasks,
              task_name  => suppress_space (To_Unbounded_String ("" & j'img)),
              param_name => mils_integrity_level);

         if (genes < i) and (i <= 2 * genes) then
            addr                  := 2;
            Task_instances (1, j) := i;
         elsif (2 * genes < i) and (i <= 3 * genes) then
            addr                  := 3;
            Task_instances (2, j) := i;
         end if;

         if (Number_of_cores (s) = 1) then
            add_task
              (my_tasks           => A_sys.tasks,
               name => suppress_space (To_Unbounded_String ("" & i'img)),
               cpu_name => suppress_space (To_Unbounded_String ("processor1")),
               address_space_name =>
                 suppress_space (To_Unbounded_String ("addr" & addr'img)),
               core_name =>
                 suppress_space
                   (To_Unbounded_String
                      ("")), --Monocore-->no task/core affinity
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
         else

            add_task
              (my_tasks           => A_sys.tasks,
               name => suppress_space (To_Unbounded_String ("" & i'img)),
               cpu_name => suppress_space (To_Unbounded_String ("processor1")),
               address_space_name =>
                 suppress_space (To_Unbounded_String ("addr" & addr'img)),
               core_name => suppress_space (To_Unbounded_String ("core1")),
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
         end if;

         New_Line;

      end loop;
      if is_empty (my_dependencies.depends) then
         Put_Line ("NO dependencies");
      else
         reset_iterator (my_dependencies.depends, my_iterator);
         loop
            current_element (my_dependencies.depends, dep_ptr, my_iterator);

            A_task_source :=
              Integer'value (To_String (dep_ptr.precedence_source.name)) +
              genes;
            A_task_sink :=
              Integer'value (To_String (dep_ptr.precedence_sink.name));

            add_one_task_dependency_precedence
              (my_dependencies => my_dependencies2,
               source          =>
                 search_task
                   (A_sys.tasks,
                    suppress_space (To_Unbounded_String (A_task_source'img))),
               sink =>
                 search_task
                   (A_sys.tasks,
                    suppress_space (To_Unbounded_String (A_task_sink'img))));
            --
            A_task_source :=
              Integer'value (To_String (dep_ptr.precedence_source.name)) +
              2 * genes;
            A_task_sink :=
              Integer'value (To_String (dep_ptr.precedence_sink.name));

            add_one_task_dependency_precedence
              (my_dependencies => my_dependencies2,
               source          =>
                 search_task
                   (A_sys.tasks,
                    suppress_space (To_Unbounded_String (A_task_source'img))),
               sink =>
                 search_task
                   (A_sys.tasks,
                    suppress_space (To_Unbounded_String (A_task_sink'img))));

            -- duplicate the communication
            --
            A_task_source :=
              Integer'value (To_String (dep_ptr.precedence_source.name));
            A_task_sink :=
              Integer'value (To_String (dep_ptr.precedence_sink.name)) + genes;

            add_one_task_dependency_precedence
              (my_dependencies => my_dependencies2,
               source          =>
                 search_task
                   (A_sys.tasks,
                    suppress_space (To_Unbounded_String (A_task_source'img))),
               sink =>
                 search_task
                   (A_sys.tasks,
                    suppress_space (To_Unbounded_String (A_task_sink'img))));

            --
            A_task_source :=
              Integer'value (To_String (dep_ptr.precedence_source.name)) +
              genes;
            A_task_sink :=
              Integer'value (To_String (dep_ptr.precedence_sink.name)) + genes;

            add_one_task_dependency_precedence
              (my_dependencies => my_dependencies2,
               source          =>
                 search_task
                   (A_sys.tasks,
                    suppress_space (To_Unbounded_String (A_task_source'img))),
               sink =>
                 search_task
                   (A_sys.tasks,
                    suppress_space (To_Unbounded_String (A_task_sink'img))));

            A_task_source :=
              Integer'value (To_String (dep_ptr.precedence_source.name)) +
              2 * genes;
            A_task_sink :=
              Integer'value (To_String (dep_ptr.precedence_sink.name)) + genes;

            add_one_task_dependency_precedence
              (my_dependencies => my_dependencies2,
               source          =>
                 search_task
                   (A_sys.tasks,
                    suppress_space (To_Unbounded_String (A_task_source'img))),
               sink =>
                 search_task
                   (A_sys.tasks,
                    suppress_space (To_Unbounded_String (A_task_sink'img))));
--
            --
            -- triplicate the communication

            A_task_source :=
              Integer'value (To_String (dep_ptr.precedence_source.name));
            A_task_sink :=
              Integer'value (To_String (dep_ptr.precedence_sink.name)) +
              2 * genes;

            add_one_task_dependency_precedence
              (my_dependencies => my_dependencies2,
               source          =>
                 search_task
                   (A_sys.tasks,
                    suppress_space (To_Unbounded_String (A_task_source'img))),
               sink =>
                 search_task
                   (A_sys.tasks,
                    suppress_space (To_Unbounded_String (A_task_sink'img))));

            --
            A_task_source :=
              Integer'value (To_String (dep_ptr.precedence_source.name)) +
              genes;
            A_task_sink :=
              Integer'value (To_String (dep_ptr.precedence_sink.name)) +
              2 * genes;

            add_one_task_dependency_precedence
              (my_dependencies => my_dependencies2,
               source          =>
                 search_task
                   (A_sys.tasks,
                    suppress_space (To_Unbounded_String (A_task_source'img))),
               sink =>
                 search_task
                   (A_sys.tasks,
                    suppress_space (To_Unbounded_String (A_task_sink'img))));

            --
            A_task_source :=
              Integer'value (To_String (dep_ptr.precedence_source.name)) +
              2 * genes;
            A_task_sink :=
              Integer'value (To_String (dep_ptr.precedence_sink.name)) +
              2 * genes;

            add_one_task_dependency_precedence
              (my_dependencies => my_dependencies2,
               source          =>
                 search_task
                   (A_sys.tasks,
                    suppress_space (To_Unbounded_String (A_task_source'img))),
               sink =>
                 search_task
                   (A_sys.tasks,
                    suppress_space (To_Unbounded_String (A_task_sink'img))));

            exit when is_last_element (my_dependencies.depends, my_iterator);
            next_element (my_dependencies.depends, my_iterator);
         end loop;

         reset_iterator (my_dependencies2.depends, my_iterator2);
         loop
            current_element (my_dependencies2.depends, dep_ptr2, my_iterator2);
            add_one_task_dependency_precedence
              (my_dependencies => Initial_System.dependencies,
               source          => dep_ptr2.precedence_source,
               sink            => dep_ptr2.precedence_sink);

            exit when is_last_element (my_dependencies2.depends, my_iterator2);
            next_element (my_dependencies2.depends, my_iterator2);
         end loop;
      end if;

      genes  := 3 * genes;
      nb_app := 3 * nb_app;
      Put_Line ("safety --> system triplicated");
      Put_Line ("genes : " & genes'img);

   end Safety;

   -- Create_system --
   -------------------

   procedure Create_system
     (A_system : in out systems.system;
      s        : in     solution_t2p_t2c)
   is

      a_core_array              : array (1 .. MAX_GENES) of core_unit_ptr;
      a_core_unit_table         : core_units_table;
      mem                       : memories_table;
      partition_sched_file_name : Unbounded_String;
      nb_part                   : Integer;

   begin

      initialize (A_system);

      -- Generate partitions
      for i in 1 .. Number_of_partitions (s) loop
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

      nb_part := Number_of_partitions (s);

      partition_sched_file_name :=
        suppress_space
          (To_Unbounded_String
             ("partition_scheduling_paes" & nb_part'img & ".xml"));

      for i in 1 .. Number_of_cores (s) loop
         add_core_unit
           (my_core_units            => A_system.core_units,
            a_core_unit              => a_core_array (i),
            name => suppress_space (To_Unbounded_String ("core" & i'img)),
            is_preemptive            => preemptive,
            quantum                  => 0,
            speed                    => 1,
            capacity                 => 0,
            period                   => 0,
            priority                 => 0,
            file_name                => partition_sched_file_name,
            scheduling_protocol_name =>
              suppress_space (To_Unbounded_String ("")),
            a_scheduler => The_Scheduler,
            mem         => mem);

         add (a_core_unit_table, a_core_array (i));

      end loop;

      if (Number_of_cores (s) = 1) then
         add_processor
           (my_processors => A_system.processors,
            name => suppress_space (To_Unbounded_String ("processor1")),
            a_core        => a_core_array (1));

      else

         add_processor
           (my_processors    => A_system.processors,
            name => suppress_space (To_Unbounded_String ("processor1")),
            cores            => a_core_unit_table,
            a_migration      => no_migration_type,
            a_processor_type => identical_multicores_type);
      end if;

   end Create_system;

end Paes.chromosome_Data_Manipulation_multicore_t2p_and_security;
