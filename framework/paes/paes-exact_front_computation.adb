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

with Ada.Text_IO;                       use Ada.Text_IO;
with Ada.Integer_Text_IO;               use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;                 use Ada.Float_Text_IO;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

with Ada.Strings;               use Ada.Strings;
with Ada.Strings.Fixed;         use Ada.Strings.Fixed;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with unbounded_strings;         use unbounded_strings;

with tasks;                 use tasks;
with task_set;              use task_set;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
with convert_unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;

with core_units; use core_units;
use core_units.core_units_table_package;
with scheduler_interface; use scheduler_interface;
with address_spaces;      use address_spaces;
with address_space_set;   use address_space_set;
with processors;          use processors;
with processor_set;       use processor_set;
with processor_interface; use processor_interface;

with systems; use systems;

with call_framework;           use call_framework;
with call_framework_interface; use call_framework_interface;
use call_framework_interface.framework_response_package;
use call_framework_interface.framework_request_package;
with call_scheduling_framework; use call_scheduling_framework;

with pipe_commands;            use pipe_commands;
with Ada.Text_IO;              use Ada.Text_IO;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with Ada.Directories;          use Ada.Directories;

with GNAT.OS_Lib;           use GNAT.OS_Lib;
with paes_for_clustering;   use paes_for_clustering;
with task_clustering_rules; use task_clustering_rules;
with integer_util;          use integer_util;
with debug;                 use debug;

package body paes.exact_front_computation is

   -------------------
   -- enumerate_sol --
   -------------------

   procedure enumerate_sol is

      a_sol, a_sol_norm : solution;
      m                 : chrom_type;

      b                                 : Boolean;
      nb_consistent_solutions           : Integer := 0;
      nb_consistent_and_sched_solutions : Integer := 0;

      new_task_set : tasks_set;
      new_nb_tasks : Integer;

      filestream : stream;
      command    : Unbounded_String;
      f          : Ada.Text_IO.File_Type;
      line       : Unbounded_String;
      buffer     : Unbounded_String;

      iter     : Integer;
      a_system : system;
      eidx     : Integer := 0;

   begin

      call_framework.initialize (False);

      create_system (a_system);

      iter := 1;
      for i in 1 .. genes loop
         a_sol.chrom (i) := 1;
         m (i)           := 1;
      end loop;

      put_debug (" ------------------ ");
      put_debug ("  iteration = " & iter'img);
      put_debug (" ------------------ ");

      put_debug (" ");--New_Line;
      put_debug ("The candidate solution is : ");
      print_debug_genome (a_sol);
      put_debug (" ");--New_Line;
      New_Line;
      -- normalize the candidate solution
      a_sol_norm := a_sol;
      normalize (a_sol_norm);
      put_debug (" ");--New_Line;
      put_debug ("After normalization the candidate solution is : ");
      print_debug_genome (a_sol_norm);
      put_debug (" ");--New_Line;

      ----------------------------------------------------------------------------------------
      -- After generating a candidate solution, we shoud verify :
      -- 1) If it is consistent or not i.e two non-harmonic functions
      --    which are grouped alone in the same task.
-- 2) If it was a consistent solution then we should verify its schedulability
      --    by calling the Cheddar tool to simulate the scheduling of the candidate task set
      --    Else, we do not check the schedulability of this candidate solution
      -----------------------------------------------------------------------------------------

      if check_consistency_of_a_solution (a_sol_norm) then

         put_debug
           (" The candidate solution is consistent and then we check the schedulability");

         nb_consistent_solutions := nb_consistent_solutions + 1;

         -- check the schedulability
         appling_clustering_rules (a_system, a_sol_norm);

         new_nb_tasks := number_of_tasks (a_sol_norm);

         command :=
           To_Unbounded_String ("candidate_solution" & eidx'img & ".xmlv3");

         write_to_xml_file
           (a_system  => a_system,
            file_name => To_String (command));

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
         Close (f);

         if line = "schedulability : true" then

            put_debug ("**The candidate task set is schedulable**");
            evaluate_for_clustering (a_sol_norm, 0);
            nb_consistent_and_sched_solutions :=
              nb_consistent_and_sched_solutions + 1;
            all_consistent_valid_solutions.Append (a_sol_norm);

         else
            put_debug ("**The candidate task set is NOT schedulable**");

         end if;

      else
         put_debug
           (" The candidate solution is NOt consistent and then " &
            " we do not check the schedulabily");
      end if;

      -- Generate the next candidate
      next (a_sol, m, genes, b);

      while b loop

         iter := iter + 1;
         put_debug (" ------------------ ");
         put_debug ("  iteration = " & iter'img);
         put_debug (" ------------------ ");

         put_debug (" ");--New_Line;
         put_debug ("The candidate solution is : ");
         print_debug_genome (a_sol);
         put_debug (" ");--New_Line;
         -- normalize the candidate solution
         a_sol_norm := a_sol;
         normalize (a_sol_norm);
         put_debug (" ");--New_Line;
         put_debug ("After normalization of the candidate solution is : ");
         print_debug_genome (a_sol_norm);
         put_debug (" ");--New_Line;

         ----------------------------------------------------------------------------------------
         -- After generating a candidate solution, we shoud verify :
         -- 1) If it is consistent or not i.e two non-harmonic functions
         --    which are grouped alone in the same task.
-- 2) If it was a consistent solution then we should verify its schedulability
         --    by calling the Cheddar tool to simulate the scheduling of the candidate task set
      --    Else, we do not check the schedulability of this candidate solution
         -----------------------------------------------------------------------------------------

         if check_consistency_of_a_solution (a_sol_norm) then

            put_debug
              (" The candidate solution is consistent and then we check the schedulability");
            nb_consistent_solutions := nb_consistent_solutions + 1;

            -- check the schedulability
            appling_clustering_rules (a_system, a_sol_norm);

            new_nb_tasks := number_of_tasks (a_sol_norm);

            command :=
              To_Unbounded_String ("candidate_solution" & eidx'img & ".xmlv3");

            write_to_xml_file
              (a_system  => a_system,
               file_name => To_String (command));

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
            Close (f);

            if line = "schedulability : true" then

               put_debug ("**The candidate task set is schedulable**");

               evaluate_for_clustering (a_sol_norm, 0);
               nb_consistent_and_sched_solutions :=
                 nb_consistent_and_sched_solutions + 1;
               all_consistent_valid_solutions.Append (a_sol_norm);

            else
               put_debug ("**The candidate task set is NOT schedulable**");

            end if;

         else
            put_debug
              (" The candidate solution is NOt consistent and then " &
               " we do not check the schedulabily");

         end if;

         next (a_sol, m, genes, b);

      end loop;

      nb_consistent       := nb_consistent_solutions;
      nb_consistent_sched := nb_consistent_and_sched_solutions;

   end enumerate_sol;

   ----------
   -- next --
   ----------

   procedure next
     (s : in out solution;
      m : in out chrom_type;
      n :        Integer;
      b :    out Boolean)
   is
      i, max : Integer;

   begin

      i           := 1;
      s.chrom (i) := s.chrom (i) + 1;
      while ((i < n) and (s.chrom (i) > m (i) + 1)) loop
         s.chrom (i) := 1;
         i           := i + 1;
         s.chrom (i) := s.chrom (i) + 1;
      end loop;

      -- If i is has reached n-1 th element, then the last unique partitiong
      -- has been found
      if (i = n) then
         b := False;
      else
         -- Because all the first i elements are now 1, s[i] (i + 1 th element)
         -- is the largest. So we update max by copying it to all the first i
         -- positions in m.
         max := s.chrom (i);
         if (m (i) > max) then
            max := m (i);
         end if;
         for j in 1 .. i - 1 loop
            m (j) := max;
         end loop;

         b := True;
      end if;

   end next;

end paes.exact_front_computation;
