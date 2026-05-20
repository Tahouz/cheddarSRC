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

with Ada.Containers.Vectors; use Ada.Containers;
use Ada.Containers;
with Ada.Directories; use Ada.Directories;
with Ada.Text_IO;     use Ada.Text_IO;

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with unbounded_strings; use unbounded_strings;
with Ada.Strings;       use Ada.Strings;

with Paes.objective_functions.t2p_and_security;
use Paes.objective_functions.t2p_and_security;

with debug; use debug;

with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;

with Paes.t2p_and_security; use Paes.t2p_and_security;

with systems; use systems;

with sets;

with Dependencies;             use Dependencies;
with task_dependencies;        use task_dependencies;
with task_dependencies;        use task_dependencies.half_dep_set;
with MILS_Security;            use MILS_Security;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with Paes.chromosome_Data_Manipulation_t2p_and_security;
use Paes.chromosome_Data_Manipulation_t2p_and_security;

procedure Paes.exhaustive_general_form_t2p_and_security is

   package Solution_Container is new Vectors (Positive, solution_t2p_ptr);
   use Solution_Container;

   package Integer_Container is new Vectors (Positive, Integer);
   use Integer_Container;

   search_space_is_exhausted     : Boolean := False;
   search_space_is_exhausted_com : Boolean := False;
   non                           : Boolean := True;
   m                             : chrom_task_type;
   next_solution                 : solution_t2p_ptr;

   normalized_solution    : solution_t2p_ptr;
   all_feasible_solutions : Solution_Container.vector;
   N_feasible_solutions   : Integer := 0;

   a_table          : Integer_Container.vector;
   Cursor1, Cursor2 : Solution_Container.cursor;
   Cursor3          : Integer_Container.cursor;
   k, j, i, l       : Integer;
   nb_rejectedSol   : Integer;

   eidx : Natural := 0;
   F    : Ada.Text_IO.File_Type;

   My_iterator     : tasks_dependencies_iterator;
   Dep_Ptr         : dependency_ptr;
   My_dependencies : tasks_dependencies_ptr;

   type table is array (1 .. nb_partitions) of Integer;
   nb : table;
   F6 : Ada.Text_IO.File_Type;

begin
   next_solution       := new solution_t2p;
   normalized_solution := new solution_t2p;
   Append
     (Data3,
      "iteration" &
      "       " &
      "Missed_deadline" &
      "               " &
      "bell" &
      "                     " &
      "biba" &
      " " &
      ASCII.LF);

   init_T2P;

   for i in 1 .. genes loop
      next_solution.chrom_task (i) := 0;
      m (i)                        := 1;
   end loop;

   My_dependencies := Initial_System.dependencies;
   My_dependencies := Initial_System.dependencies;
   if is_empty (My_dependencies.depends) then
      Put_Line ("No dependencies");
   else
      j := 1;
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
               ((Dep_Ptr.precedence_sink.mils_integrity_level = medium) or
                (Dep_Ptr.precedence_sink.mils_integrity_level = high)))
            then
               -- Resolve confidentiality constraints problem
               next_solution.chrom_com (j).mode        := secure;
               next_solution.chrom_com (j).source_sink :=
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

               next_solution.chrom_com (j).mode        := undefined;
               next_solution.chrom_com (j).source_sink :=
                 suppress_space
                   (To_String (Dep_Ptr.precedence_source.name) &
                    "_" &
                    To_String (Dep_Ptr.precedence_sink.name));
            else
               next_solution.chrom_com (j).mode        := norisk;
               next_solution.chrom_com (j).source_sink :=
                 suppress_space
                   (To_String (Dep_Ptr.precedence_source.name) &
                    "_" &
                    To_String (Dep_Ptr.precedence_sink.name));
            end if;

            j := j + 1;
         end if;
         exit when is_last_element (My_dependencies.depends, My_iterator);
         next_element (My_dependencies.depends, My_iterator);
      end loop;

   end if;

-- 2) enumerate and evaluate all feasible solutions
--

   i := 1;
   j := 1;
   k := 1;
   l := 1;
   ---------------------------------------------------------------------------------------
   for i in 1 .. nb_partitions loop
      nb (i) := 0;
   end loop;

   i             := 1;
   j             := 1;
   nb_sol_Exhaus := 0;

   while (True) loop

      search_space_is_exhausted := False;
      if (i > 1) then
         if (next_solution.chrom_task (i) >= 1) and
           (next_solution.chrom_task (i) < nb_partitions + 1)
         then
            nb (next_solution.chrom_task (i)) :=
              nb (next_solution.chrom_task (i)) - 1;
            if (nb (next_solution.chrom_task (i)) = 0) then
               next_solution.chrom_task (i) := 0;
               i                            := i - 1;
               search_space_is_exhausted    := True;
            end if;
         end if;

      end if;

      if (search_space_is_exhausted = False) then

         next_solution.chrom_task (i) := next_solution.chrom_task (i) + 1;

         if (next_solution.chrom_task (i) > nb_partitions) then
            next_solution.chrom_task (i) := 0;
            i                            := i - 1;

         else

            if (next_solution.chrom_task (i) <= nb_partitions) then
               nb (next_solution.chrom_task (i)) :=
                 nb (next_solution.chrom_task (i)) + 1;
            end if;

            if (next_solution.chrom_task (i) <= i) and (i < genes) then
               i := i + 1;

            elsif (next_solution.chrom_task (i) <= i) and (i = genes) then

               j := 1;
               New_Line;

               while (search_space_is_exhausted_com = False) loop
                  --      eidx := eidx + 1;
                  if j <= Nb_NonSecure_low then

--                     next_solution.chrom_com(NonSecure_list(j)).mode:= emission;
                     if
                       (next_solution.chrom_com (NonSecure_list (j)).mode =
                        undefined)
                     then
                        next_solution.chrom_com (NonSecure_list (j)).mode :=
                          nosecure;

                     elsif
                       (next_solution.chrom_com (NonSecure_list (j)).mode =
                        nosecure)
                     then
                        next_solution.chrom_com (NonSecure_list (j)).mode :=
                          secure;

                     elsif
                       (next_solution.chrom_com (NonSecure_list (j)).mode =
                        secure)
                     then
                        next_solution.chrom_com (NonSecure_list (j)).mode :=
                          undefined;

                     end if;
                  end if;

                  if
                    (next_solution.chrom_com (NonSecure_list (j)).mode /=
                     undefined) and
                    (j < Nb_NonSecure_low)
                  then
                     j := j + 1;
                  elsif
                    (next_solution.chrom_com (NonSecure_list (j)).mode /=
                     undefined) and
                    (j = Nb_NonSecure_low)
                  then
                     if (intra_partition_safe = 1) then
                        nb_sol_Exhaus := nb_sol_Exhaus + 1;
                        Put_Line ("iteration: " & nb_sol_Exhaus'img);
                        Put_Line ("security config: 1");
                        next_solution.security_config := 1;
                        print_genome (next_solution.all);
                        normalized_solution := next_solution;
                        normalize (normalized_solution.all);
                        if check_feasibility
                            (normalized_solution.all,
                             eidx)
                        then

                           evaluate (normalized_solution.all, eidx);
                           all_feasible_solutions.Append (normalized_solution);
                           N_feasible_solutions := N_feasible_solutions + 1;

                           archive_soln
                             (generic_solution_ptr (normalized_solution));
                           Append
                             (Data3,
                              N_feasible_solutions'img &
                              "              " &
                              normalized_solution.obj (1)'img &
                              "              " &
                              normalized_solution.obj (2)'img &
                              "              " &
                              normalized_solution.obj (3)'img &
                              "              " &
                              ASCII.LF);

                        end if;
                     else
                        for l in 2 .. 4 loop
                           nb_sol_Exhaus := nb_sol_Exhaus + 1;
                           Put_Line ("iteration: " & nb_sol_Exhaus'img);
                           Put_Line ("security config" & l'img);
                           next_solution.security_config := l;
                           print_genome (next_solution.all);
                           normalized_solution := next_solution;
                           normalize (normalized_solution.all);

                           if check_feasibility
                               (normalized_solution.all,
                                eidx)
                           then

                              evaluate (normalized_solution.all, eidx);
                              all_feasible_solutions.Append
                              (normalized_solution);
                              N_feasible_solutions := N_feasible_solutions + 1;

                              archive_soln
                                (generic_solution_ptr (normalized_solution));
                              Append
                                (Data3,
                                 N_feasible_solutions'img &
                                 "              " &
                                 normalized_solution.obj (1)'img &
                                 "              " &
                                 normalized_solution.obj (2)'img &
                                 "              " &
                                 normalized_solution.obj (3)'img &
                                 "              " &
                                 ASCII.LF);

                           end if;
                        end loop;

                     end if;

                  elsif
                    (next_solution.chrom_com (NonSecure_list (j)).mode =
                     undefined) and
                    (j > 1)
                  then
                     j := j - 1;
                  elsif
                    (next_solution.chrom_com (NonSecure_list (j)).mode =
                     undefined) and
                    (j = 1)
                  then
                     search_space_is_exhausted_com := True;
                  end if;
               end loop;
               search_space_is_exhausted_com := False;

            elsif (next_solution.chrom_task (i) > i) and (i > 1) then
               next_solution.chrom_task (i) := 0;
               i                            := i - 1;
            else
               exit;
            end if;
         end if;

      end if;

   end loop;
   nb_rejectedSol :=
     nb_InitSol +
     N_feasible_solutions -
     arclength; -- solutions add in the archive during the init process + N_feasible_solutions+iterations+ arclength
   Append (Data3, " " & ASCII.LF);
   Append (Data3, " " & ASCII.LF);
   Append
     (Data3,
      "Number of rejected solution during the archiving process : " &
      nb_rejectedSol'img &
      ASCII.LF);
   Append
     (Data3,
      "Number of solutions generate during the exhaustive research : " &
      nb_sol_Exhaus'img &
      ASCII.LF);
   Create (F6, Ada.Text_IO.Out_File, "Exhaustive_Execution_iter.dat");
   Unbounded_IO.Put_Line (F6, Data3);
   Close (F6);
end Paes.exhaustive_general_form_t2p_and_security;
