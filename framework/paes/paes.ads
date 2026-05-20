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

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- This program is the Ada implementation of (1+1)-PAES.
-- The original code of (1+1)-PAES is implemented in C
-- available from: http://www.cs.man.ac.uk/~jknowles/multi/
--
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with System;                    use System;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

package Paes is

   ---------------------
   --    Constants    --
   ---------------------

   MAX_GENES      : constant Integer := 1000;  -- change as necessary
   MAX_GENES_TASK : constant Integer := 1000;  -- change as necessary
   MAX_OBJ        : constant Integer := 16;    -- change as necessary
   MAX_ARC        : constant Integer := 11000;   -- change as necessary
   MAX_LOC        : constant Integer :=
     1000000;--32768; -- number of locations in grid (set for a three-objective problem using depth 5)

   MAX_SLAVES : constant Integer := 40;--for the parallel algorithm
   LARGE      : constant Integer :=
     2000000000; -- should be about the maximum size of an integer for your compiler

   ---------------------
   --      Types      --
   ---------------------

   -- This type used to define objectives of a solution
   type obj_type is array (1 .. MAX_OBJ) of Float;

   type string_type is new String (1 .. 50);

   -- This is the main type used to define solutions
   type generic_solution is abstract tagged record
      obj         : obj_type;
      grid_loc    : Integer;
      hyperperiod : Integer;
   end record;
   type generic_solution_ptr is access all generic_solution'class;

   -- This type is used to define the archive of solutions
   type arc_type is array (1 .. MAX_ARC) of generic_solution_ptr;

   -- current solution
   c : generic_solution_ptr;
   -- mutant solution
   m : generic_solution_ptr;

   -- archive of solutions
   arc : arc_type;
   tmp : arc_type;

   procedure print_eval (s : generic_solution_ptr);
   procedure Selection_and_Archiving;
   procedure add_to_archive (s : generic_solution_ptr);
   function compare_to_archive (s : generic_solution_ptr) return Integer;
   procedure update_grid (s : in out generic_solution_ptr);
   procedure archive_soln (s : generic_solution_ptr);
   procedure copy_solution
     (first  : generic_solution_ptr;
      second : generic_solution_ptr) is abstract;
   function selectNext return generic_solution_ptr;
   procedure print_debug_eval (s : generic_solution_ptr);

   -- The selection strategy is either :
   --  *) Local strategy : the PAES original one, rule
   --     for admitting the matuted solution as current solution
   --     or to keep current solution for the next iteration
   --  *) Global strategy : that picks a new current
   --     individual from the archive at each iteration (NextSelect function).
   --
   type selectionstrategy is (local, global);

   ----------------------
   -- Global variables --
   ----------------------

   -- The selection strategy is
   -- by default set to the original selection strategy of PAES
   A_SelectionStrategy : selectionstrategy := local;
   -- slaves correspond to the number of process that can be run in parallel
   -- it depends on the parallel machine capacity
   -- the number of slaves, By default is set to 0 (i.e. sequantial run)
   slaves : Natural := 0;
   -- set to 0 (zero) for minimization problems, 1 for maximization problems.
   -- By default is set to a minimization problem
   minmax : Integer := 0;

   ------------------------------------------------------------------------------------------------------
   -- depth: this is the number of recursive subdivisions of the objective space carried out in order to
   --        divide the objective space into a grid for the purposes of diversity maintenance. Values of
   --        between 3 and 6 are useful, depending on number of objectives.
   -- objectives: the number of objectives
   -- genes: the number of genes in the chromosome of tasks. (Only integer genes can be accepted).
   -- alleles: the number of values that each gene can take.
   -- archive: the maximum number of solutions to be held in the nondominated solutions archive.
   -- iterations: the program terminates after this number of iterations.
   -- nb_InitSol: number of initial solutions
   -- nb_sol_Exhaus: number of solutions generated by the exhaustive search
   -- nb_NoFeasible_Sol : number of non feasible solutions generate during the mutation

   ------------------------------------------------------------------------------------------------------
   depth,
   objectives,
   genes,
   genes_init,
   archive,
   iterations,
   iter,
   nb_InitSol,
   nb_NoFeasible_Sol,
   last_nondominated_sol,
   arc_random_sol : Integer;

   arclength : Integer := 0; -- current length of the archive

   gl_offset  : obj_type;   -- the range, offset etc of the grid
   gl_range   : obj_type;
   gl_largest : obj_type;
   grid_pop   : array
   (1 ..
        MAX_LOC) of Integer;  -- the array holding the population residing in each grid location

   change : Integer := 0;

   nb_sol_Exhaus : Integer := 0;
   Data3         : Unbounded_String;

   G : Ada.Numerics.Float_Random.Generator;

end Paes;
