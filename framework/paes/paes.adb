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

with Ada.Text_IO;           use Ada.Text_IO;
with debug;                 use debug;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with unbounded_strings;         use unbounded_strings;
with Ada.Strings;               use Ada.Strings;
with float_util;                use float_util;
with architecture_factory;      use architecture_factory;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Paes.objective_functions;  use Paes.objective_functions;
with systems;                   use systems;

package body Paes is

   ---------------------
   -- add_to_archive --
   ---------------------

   procedure add_to_archive (s : generic_solution_ptr) is

   begin

      arclength           := arclength + 1;
      arc (arclength).all := s.all;

   end add_to_archive;

   -----------------
   -- compare_min --
   -----------------

   --  compares two n-dimensional vectors of objective values for minimization problems
   --  returns 1 if first dominates second,
   --  -1 if second dominates first, and 0 otherwise (aucune ne domine l'autre)

   function compare_min
     (first  : obj_type;
      second : obj_type;
      n      : Integer) return Integer
   is
      i, deflt, current : Integer;
   begin

      i     := 1;
      deflt := 0;

      while i <= n loop

         if (first (i) < second (i)) then
            current := 1;
         elsif (second (i) < first (i)) then
            current := -1;
         else
            current := 0;
         end if;

         if (current /= 0) and then (current = -deflt) then
            return 0;
         end if;

         if (current /= 0) then
            deflt := current;
         end if;

         i := i + 1;

      end loop;

      return deflt;

   end compare_min;

   -----------------
   -- compare_max --
   -----------------

   --  as for compare_min but for maximization problems

   function compare_max
     (first  : obj_type;
      second : obj_type;
      n      : Integer) return Integer
   is
      i, deflt, current : Integer;
   begin

      i     := 1;
      deflt := 0;

      while i <= n loop

         if (first (i) > second (i)) then
            current := 1;
         elsif (second (i) > first (i)) then
            current := -1;
         else
            current := 0;
         end if;

         if (current /= 0) and then (current = -deflt) then
            return 0;
         end if;

         if (current /= 0) then
            deflt := current;
         end if;

         i := i + 1;

      end loop;

      return deflt;

   end compare_max;

   -----------
   -- equal --
   -----------
--  checks to n-dimensional vectors of objectives to see if they are identical
--  returns 1 if they are, 0 otherwise

   function equal
     (first  : obj_type;
      second : obj_type;
      n      : Integer) return Integer
   is
      i : Integer := 1;
   begin

      while i <= n loop
         if (first (i) /= second (i)) then
            return 0;
         end if;
         i := i + 1;
      end loop;

      return 1;

   end equal;

   ----------------
   -- print_eval --
   ----------------

   procedure print_eval (s : generic_solution_ptr) is
   begin

      for i in 1 .. objectives loop
         Put (To_String (format (s.obj (i))) & "   ");
      end loop;

   end print_eval;

   ----------------------
   -- print_debug_eval --
   ----------------------

   procedure print_debug_eval (s : generic_solution_ptr) is
   begin

      for i in 1 .. objectives loop
         put_debug (To_String (format (s.obj (i))) & "   ");
      end loop;

   end print_debug_eval;

   ------------------------
   -- compare_to_archive --
   ------------------------

   --  compares a solution to every member of the archive. Returns -1 if dominated by
   --  any member, 1 if dominates any member, and 0 otherwise

   function compare_to_archive (s : generic_solution_ptr) return Integer is
      i      : Integer := 1;
      result : Integer := 0;
   begin

      while ((i <= arclength) and (result /= 1) and (result /= -1)) loop

         --  MINIMIZE MAXIMIZE
         if (minmax = 0) then

            result := compare_min (s.obj, arc (i).obj, objectives);
         else
            result := compare_max (s.obj, arc (i).obj, objectives);
         end if;
         i := i + 1;
      end loop;

      return result;

   end compare_to_archive;

   ----------------
   -- selectNext --
   ----------------

   function selectNext return generic_solution_ptr is

      choice                                   : Integer;
      minc                                     : Integer;
      G : Ada.Numerics.Float_Random.Generator;
      minpop                                   : Integer;
      diff, mindiff, targetval, minval, maxval : Float;
   begin
      Reset (G);
      minc := 1;
      --  choose randomly a criterium among "the set of objectives", "the extra crowding criterium"
      --  and "random solution from the archive"

      choice := 0;
      while (choice > (objectives + 2)) or (choice < 1) loop
         choice := Integer (Float (objectives + 2) * Random (G));
      end loop;

      if (choice = (objectives + 2)) then -- less explorated grid point
         -- compute min explorated point
         minpop := grid_pop (arc (minc).grid_loc);
         for i in 2 .. arclength loop
            if grid_pop (arc (i).grid_loc) <=
              grid_pop (arc (minc).grid_loc)
            then
               minc   := i;
               minpop := grid_pop (arc (minc).grid_loc);
            end if;
         end loop;

      elsif
        (choice = (objectives + 1))
      then -- a random solution from the archive

         minc := 0;
         if arclength = 1 then
            minc := 1;
         else
            while (minc > arclength) or (minc < 1) loop
               minc := Integer (Float (arclength) * Random (G));
            end loop;
         end if;
      else
      -- return closest point to a random point in the interval of chosen obj
         maxval := arc (1).obj (choice);
         minval := arc (1).obj (choice);
         for i in 2 .. arclength loop
            if arc (i).obj (choice) < minval then
               minval := arc (i).obj (choice);
            end if;
            if arc (i).obj (choice) > maxval then
               maxval := arc (i).obj (choice);
            end if;
         end loop;

         minc    := 1;
         mindiff := targetval - arc (minc).obj (choice);

         if (mindiff < 0.0) then
            mindiff := -mindiff;
         end if;
         for i in 2 .. arclength loop
            diff := targetval - arc (i).obj (choice);
            if (diff < 0.0) then
               diff := -diff;
            end if;
            if (diff < mindiff) then
               mindiff := diff;
               minc    := i;
            end if;
         end loop;
      end if;

      return arc (minc);

   end selectNext;

   --------------
   -- find_loc --
   --------------

--  find the grid location of a solution given a vector of its objective values

   function find_loc (eval : obj_type) return Integer is

      loc   : Integer := 0;
      n     : Integer := 1;
      inc   : array (1 .. MAX_OBJ) of Integer;
      width : obj_type;

   begin

      --  if the solution is out of range on any objective, return 1 more than the maximum possible grid location number
      for i in 1 .. objectives loop
         if (eval (i) < gl_offset (i)) or
           (eval (i) > gl_offset (i) + gl_range (i))
         then
            return Integer (2**(objectives * depth));
         end if;
      end loop;

      for i in 1 .. objectives loop
         inc (i)   := n;
         n         := n * 2;
         width (i) := gl_range (i);
      end loop;

      for d in 1 .. depth loop

         for i in 1 .. objectives loop

            if (eval (i) < (width (i) / 2.0 + gl_offset (i))) then
               loc := loc + inc (i);
            else
               gl_offset (i) := gl_offset (i) + width (i) / 2.0;
            end if;
         end loop;

         for i in 1 .. objectives loop
            inc (i)   := inc (i) * (objectives * 2);
            width (i) := width (i) / 2.0;
         end loop;

      end loop;
      return loc;

   end find_loc;

   -----------------
   -- update_grid --
   -----------------

   --  re-compute ranges for grid in the light of a new solution s

   procedure update_grid (s : in out generic_solution_ptr) is
      square  : Integer;
      offset  : obj_type;
      largest : obj_type;
      sse     : Float;
      product : Float;
   begin

      --  re-compute ranges for grid in the light of a new solution s

      for a in 1 .. objectives loop
         offset (a)  := Float (LARGE);
         largest (a) := Float (-LARGE);
      end loop;

      for b in 1 .. objectives loop
         for a in 1 .. arclength loop
            if (arc (a).obj (b)) < offset (b) then
               offset (b) := arc (a).obj (b);
            end if;
            if (arc (a).obj (b) > largest (b)) then
               largest (b) := arc (a).obj (b);
            end if;
         end loop;
      end loop;

      for b in 1 .. objectives loop
         if (s.obj (b) < offset (b)) then
            offset (b) := s.obj (b);
         end if;
         if (s.obj (b) > largest (b)) then
            largest (b) := s.obj (b);
         end if;
      end loop;

      sse     := Float (0);
      product := 1.0;

      for a in 1 .. objectives loop
         sse :=
           sse + ((gl_offset (a) - offset (a)) * (gl_offset (a) - offset (a)));
         sse :=
           sse +
           ((gl_largest (a) - largest (a)) * (gl_largest (a) - largest (a)));
         product := product * gl_range (a);
      end loop;

      if (sse > (0.1 * product * product)) then
         --  if the summed squared error (difference) between old and new
         --  minima and maxima in each of the objectives
         --  is bigger than 10 percent of the square of the size of the space
         --  then renormalise the space and recalculte grid locations
         change := change + 1;

         for a in 1 .. objectives loop
            gl_largest (a) := largest (a) + 0.2 * largest (a);
            gl_offset (a)  := offset (a) + 0.2 * offset (a);
            gl_range (a)   := gl_largest (a) - gl_offset (a);
         end loop;

         for a in 1 .. (2**(objectives * depth)) loop
            grid_pop (a) := 0;
         end loop;
         Put_Line ("arclength : " & arclength'img);
         for a in 1 .. arclength loop
            square            := find_loc (arc (a).obj);
            arc (a).grid_loc  := square;
            grid_pop (square) := grid_pop (square) + 1;
         end loop;
      end if;
      square                             := find_loc (s.obj);
      s.grid_loc                         := square;
      grid_pop (2**(objectives * depth)) := -5;
      grid_pop (square)                  := grid_pop (square) + 1;

   end update_grid;

   -------------------
   -- archieve_soln --
   -------------------

   --  given a solution s, add it to the archive if
   --  a) the archive is empty
   --  b) the archive is not full and s is not dominated or equal to anything currently in the archive
   --  c) s dominates anything in the archive
   --  d) the archive is full but s is nondominated and is in a no more crowded square than at least one solution
   --  in addition, maintain the archive such that all solutions are nondominated.

   procedure archive_soln (s : generic_solution_ptr) is
      i             : Integer;
      repl          : Integer;
      yes           : Integer := 0;
      most          : Integer;
      result        : Integer;
      join          : Integer := 0;
      old_arclength : Integer;
      set           : Integer := 0;
      tag           : array (1 .. MAX_ARC) of Integer;
--      tmp           : arc_type;

   begin

      for i in 1 .. archive loop
         tag (i) := 0;
      end loop;

      --  a) the archive is empty

      if (arclength = 0) then
         Put_Line ("archive is empty");
         add_to_archive (s);
         return;
      end if;

      --  b) the archive is not full and s is not dominated or equal to anything currently in the archive

      i      := 1;
      result := 0;

      while ((i <= arclength) and (result /= -1)) loop

         result := equal (s.obj, arc (i).obj, objectives);
         exit when (result = 1);

         --MINIMIZE MAXIMIZE
         if (minmax = 0) then
            result := compare_min (s.obj, arc (i).obj, objectives);
         else
            result := compare_max (s.obj, arc (i).obj, objectives);
         end if;

         if (result = 1) and then (join = 0) then
            arc (i).all := s.all;
            join        := 1;
            Put_Line ("s dominate first time");
         elsif (result = 1) then
            Put_Line ("s dominate multiple time");
            tag (i) := 1;
            set     := 1;
         end if;
         i := i + 1;
      end loop;

      old_arclength := arclength;
      if (set = 1) then
         Put_Line ("s dominate multiple time");
         for i in 1 .. arclength loop
            tmp (i).all := arc (i).all;
         end loop;

         arclength := 0;

         for i in 1 .. old_arclength loop
            if (tag (i) /= 1) then
               arclength           := arclength + 1;
               arc (arclength).all := tmp (i).all;

            end if;
         end loop;

      end if;

      if (join = 0)
        and then (result = 0)
      then -- ie solution is non-dominated by the list
         Put_Line ("s dominate non-dominated by the list");
         if (arclength = archive) then
            Put_Line ("archive is full");
            most := grid_pop (s.grid_loc);
            for i in 1 .. arclength loop
               if (grid_pop (arc (i).grid_loc) > most) then
                  most := grid_pop (arc (i).grid_loc);
                  repl := i;
                  yes  := 1;
               end if;
            end loop;
            if yes = 1 then
               arc (repl).all := s.all;
            end if;

         else
            Put_Line ("s dominate non-dominated by the list: add element");

            add_to_archive (s);

         end if;
      end if;

   end archive_soln;

   -----------------------------
   -- Selection_and_Archiving --
   -----------------------------

   procedure Selection_and_Archiving is
      result : Integer;
   begin

      --  MINIMIZE MAXIMIZE
      if (minmax = 0) then
         result := compare_min (c.obj, m.obj, objectives);
      else
         result := compare_max (c.obj, m.obj, objectives);
      end if;

      if A_SelectionStrategy = local then -- The PAES original

         if
           (result /= 1)
         then     --  if mutant is not dominated by current (else discard it)

            if (result = -1) then --  if mutant dominates current

               put_debug ("m dominates c");

               update_grid
                 (m);  --  calculate grid location of mutant solution and renormalize
               --  archive if necessary
               archive_soln
                 (m); --  update the archive by removing all dominated individuals

               c.all := m.all;          --  replace c with m

            elsif
              (result = 0)
            then -- if mutant and current are nondominated wrt each other
               result := compare_to_archive (m);

               if
                 (result /= -1)
               then --  if mutant is not dominated by archive (else discard it)
                  put_debug (" mutant is not dominated by archive");

                  update_grid (m);
                  archive_soln (m);
                  if (grid_pop (m.grid_loc) <= grid_pop (c.grid_loc)) or
                    (result = 1)
                  then
                     -- if mutant dominates the archive or
                     -- is in less crowded grid loc than c
                     -- then replace c with m

                     c.all := m.all;

                  end if;

                  last_nondominated_sol := iter;
               end if;

            end if;

         end if;

      else -- The global selection strategy

         result := compare_to_archive (m);

         if
           (result /= -1)
         then --  if mutant is not dominated by archive (else discard it)
            update_grid (m);
            archive_soln (m);
         end if;
         c.all :=
           selectNext.all; --  in all cases, the next current solution is selected from the archive

      end if;

   end Selection_and_Archiving;

end Paes;
