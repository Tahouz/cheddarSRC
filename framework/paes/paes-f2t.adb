
with Ada.text_IO; use Ada.text_IO;
with Debug; use Debug;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with unbounded_strings;                 use unbounded_strings;
with Ada.strings; use Ada.strings;
with float_util; use float_util;
with architecture_factory; use architecture_factory;
with Ada.Numerics.Float_Random ; use Ada.Numerics.Float_Random ;
with paes.objective_functions; use paes.objective_functions;

package body paes.f2t is

   ------------------
   -- print_genome --
   ------------------

   procedure print_genome(s : solution_f2t) is

   begin

      for i in 1..genes loop
         Put (s.chrom_task(i)'Img & " ");
      end loop;

      New_Line;

   end print_genome;


   ------------------------
   -- print_debug_genome --
   ------------------------

   procedure print_debug_genome(s : solution_f2t) is
   begin

      for i in 1..genes loop
         Put (s.chrom_task(i)'Img & " ");
      end loop;
      New_Line;

   end print_debug_genome;

     ---------------------
   -- add_to_archive --
   ---------------------

   procedure add_to_archive(s : solution_f2t)
   is

   begin

      arclength := arclength + 1;
      arc(arclength) := s;

   end add_to_archive;

  ------------------------
   -- compare_to_archive --
   ------------------------

   --  compares a solution to every member of the archive. Returns -1 if dominated by
   --  any member, 1 if dominates any member, and 0 otherwise

   function compare_to_archive(s : solution_f2t) return integer
   is
      i : integer := 1;
      result : integer :=0;
   begin

      while((i <= arclength) and (result /= 1) and (result /= -1)) loop

         --  MINIMIZE MAXIMIZE
         if (minmax = 0) then

            result := compare_min(s.obj, arc(i).obj, objectives);
         else
            result := compare_max(s.obj, arc(i).obj, objectives);
         end if;
         i := i + 1;
      end loop;

      return result;

   end compare_to_archive;

  -----------------
   -- update_grid --
   -----------------

   --  re-compute ranges for grid in the light of a new solution s

   procedure update_grid(s : in out solution_f2t)
   is
      square  : integer;
      offset  : obj_Type;
      largest : obj_Type;
      sse     : float;
      product : float;
   begin

      --  re-compute ranges for grid in the light of a new solution s
      for a in 1..objectives loop
         offset(a)  := float(LARGE);
            largest(a) := float(-LARGE);
      end loop;
      for b in 1..objectives loop
            for a in 1..arclength loop
               if (arc(a).obj(b)) < offset(b) then
                  offset(b) := arc(a).obj(b);
               end if;
               if (arc(a).obj(b) > largest(b)) then
                  largest(b) := arc(a).obj(b);
               end if;
            end loop;
      end loop;
      for b in 1..objectives loop
            if (s.obj(b) < offset(b)) then
               offset(b) := s.obj(b);
            end if;
            if (s.obj(b) > largest(b)) then
               largest(b) := s.obj(b);
            end if;
      end loop;
      sse     := float(0);
      product := 1.0;

      for a in 1..objectives loop
            sse := sse + ((gl_offset(a) - offset(a)) * (gl_offset(a) - offset(a)));
            sse := sse + ((gl_largest(a) - largest(a)) * (gl_largest(a) - largest(a)));
            product := product * gl_range(a);
      end loop;
      if (sse > (0.1 * product * product)) then
         --  if the summed squared error (difference) between old and new
         --  minima and maxima in each of the objectives
         --  is bigger than 10 percent of the square of the size of the space
         --  then renormalise the space and recalculte grid locations
         change :=  change + 1;

         for a in 1..objectives loop
               gl_largest(a) := largest(a) + 0.2 * largest(a);
               gl_offset(a)  := offset(a) + 0.2 * offset(a);
               gl_range(a)   := gl_largest(a) - gl_offset(a);
         end loop;

         for a in 1..(2 ** (objectives*depth)) loop
            grid_pop(a) := 0;
         end loop;

         for a in 1..arclength loop
            square := find_loc(arc(a).obj);
            Put_Debug("square " & square'Img);
            arc(a).grid_loc := square;
            grid_pop(square) := grid_pop(square) + 1;
         end loop;

      end if;
      square := find_loc(s.obj);

      s.grid_loc := square;

      grid_pop(2 ** (objectives*depth)) := -5;

      grid_pop(square) := grid_pop(square) + 1;


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

   procedure archive_soln(s : solution_f2t) is

      i             : integer;
      repl          : integer;
      yes           : integer := 0;
      most          : integer;
      result        : integer;
      join          : integer := 0;
      old_arclength : integer;
      set           : integer := 0;

      tag           : array(1..MAX_ARC) of integer;

 --     tmp           : arc_type;

   begin


       for i in 1..archive loop
         tag(i) := 0;
      end loop;

      --  a) the archive is empty

      if (arclength = 0) then
         add_to_archive(s);
         return;
      end if;

      --  b) the archive is not full and s is not dominated or equal to anything currently in the archive

      i := 1;
      result := 0;

      while((i <= arclength) and (result /=-1)) loop

         result := equal(s.obj, arc(i).obj, objectives);

         exit when (result = 1) ;

         --MINIMIZE MAXIMIZE
         if (minmax = 0) then
            result := compare_min(s.obj, arc(i).obj, objectives);
         else
            result := compare_max(s.obj, arc(i).obj, objectives);
         end if;

         if (result = 1) and then (join = 0) then
            arc(i) := s;
            join   := 1;
         elsif (result = 1) then
            tag(i) := 1;
            set := 1;
         end if;
         i := i + 1;
      end loop;

      old_arclength := arclength;
      if (set=1) then

         for i in 1..arclength loop
            tmp(i) := arc(i);
         end loop;

         arclength := 0;

         for i in 1..old_arclength loop

            if (tag(i) /= 1) then
               arclength := arclength + 1;
               arc(arclength) := tmp(i);
            end if;
         end loop;
      end if;


      if (join = 0) and then (result = 0) then -- ie solution is non-dominated by the list

         if (arclength = archive) then

            most := grid_pop(s.grid_loc);
            for i in 1..arclength loop
               if (grid_pop(arc(i).grid_loc) > most) then
                  most := grid_pop(arc(i).grid_loc);
                  repl := i;
                  yes  := 1;
               end if;
            end loop;
            if yes = 1 then
               arc(repl) := s;
            end if;

         else
            add_to_archive(s);
         end if;
      end if;
   end archive_soln;



    ----------------
   -- selectNext --
   ----------------

   function selectNext return solution_f2t is

      choice : integer;
      minc : integer;
      G : Ada.Numerics.Float_Random.Generator;
      minpop : integer;
      diff, mindiff, targetval, minval, maxval : float;
   begin

      reset(G);
      targetval:=Float(0);
      minc := 1;
      --  choose randomly a criterium among "the set of objectives", "the extra crowding criterium"
      --  and "random solution from the archive"

      choice := 0;
      while (choice > (objectives + 2)) or (choice < 1) loop
         choice := integer (float(objectives+2) * random(G));
      end loop;
      if (choice = (objectives + 2)) then -- less explorated grid point
       -- compute min explorated point
         minpop := grid_pop(arc(minc).grid_loc);
         for i in 2 .. arclength loop
            --Voir avec laurent
            if (arc(i).grid_loc/=0) then
               if (grid_pop(arc(i).grid_loc) <= grid_pop(arc(minc).grid_loc)) then
                  minc := i;
                  minpop := grid_pop(arc(minc).grid_loc);
               end if;
            end if;
         end loop;
      elsif (choice = (objectives + 1)) then -- a random solution from the archive

         minc := 0;
         if arclength = 1 then
            minc := 1;
         else
            while (minc > arclength) or (minc < 1) loop
               minc := integer (float(arclength) * random(G));
            end loop;
         end if;
      else
         -- return closest point to a random point in the interval of chosen obj
         maxval := arc(1).obj(choice);
         minval := arc(1).obj(choice);
         for i in 2 .. arclength loop
            if arc(i).obj(choice) < minval then
               minval := arc(i).obj(choice);
            end if;
            if arc(i).obj(choice) > maxval then
               maxval := arc(i).obj(choice);
            end if;
         end loop;

         minc := 1;
         mindiff := targetval - arc(minc).obj(choice);

         if (mindiff < 0.0) then
            mindiff := - mindiff;
         end if;
         for i in 2 .. arclength loop
            diff := targetval - arc(i).obj(choice);
            if (diff < 0.0) then
               diff := - diff;
            end if;
            if (diff < mindiff) then
               mindiff := diff;
               minc := i;
            end if;
         end loop;
      end if;

      return arc(minc);

   end selectNext;
    -----------------------------
   -- Selection_and_Archiving --
   -----------------------------

   Procedure Selection_and_Archiving is
      result : integer;
   begin

--  MINIMIZE MAXIMIZE
      if (minmax = 0) then
         result := compare_min(c.obj, m.obj, objectives);
      else
         result := compare_max(c.obj, m.obj, objectives);
      end if;


      if A_SelectionStrategy = local then -- The PAES original

         if (result /= 1) then     --  if mutant is not dominated by current (else discard it)

            if (result = -1) then --  if mutant dominates current

               Put_Debug("m dominates c");

               update_grid(m);  --  calculate grid location of mutant solution and renormalize
               --  archive if necessary
               archive_soln(m); --  update the archive by removing all dominated individuals

               c := m;          --  replace c with m

            elsif (result = 0) then -- if mutant and current are nondominated wrt each other

               result := compare_to_archive(m);

               if (result /= -1) then --  if mutant is not dominated by archive (else discard it)

                  update_grid(m);

                  archive_soln(m);


                  if (grid_pop(m.grid_loc) <= grid_pop(c.grid_loc)) or (result = 1) then
                     -- if mutant dominates the archive or
                     -- is in less crowded grid loc than c
                     -- then replace c with m

                     c := m;

                  end if;

               end if;

            end if;

         end if;

      else -- The global selection strategy
         result := compare_to_archive(m);
         if (result /= -1) then --  if mutant is not dominated by archive (else discard it)
            update_grid(m);
            archive_soln(m);
         end if;
         c := selectNext; --  in all cases, the next current solution is selected from the archive
      end if;

   end Selection_and_Archiving;

end paes.f2t;
