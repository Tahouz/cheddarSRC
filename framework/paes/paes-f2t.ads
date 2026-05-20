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

with Paes; use Paes;
package paes.f2t is

   -- This type used to define a chromosome of a solution (functions to tasks assignment)
   type chrom_type is array(1..MAX_GENES) of Integer;


   -- This is the main type used to define solutions
   type solution_f2t is new solution with
      record
         chrom_task : chrom_type;
      end record;

   procedure print_genome(s : solution_f2t);
   procedure print_debug_genome(s : solution_f2t);
   procedure add_to_archive(s : solution_f2t);
   function compare_to_archive(s : solution_f2t) return integer;
   procedure update_grid(s : in out solution_f2t);
   procedure archive_soln(s : solution_f2t);
   Procedure Selection_and_Archiving;
   function selectNext return solution_f2t;


    -- This type is used to define the archive of solutions
   type arc_type is array(1..MAX_ARC) of solution_f2t;

   ----------------------
   -- Global variables --
   ----------------------

   -- current solution
   c                   : solution_f2t;
   -- mutant solution
   m                   : solution_f2t;
   -- archive of solutions
   arc                 : arc_type;
   tmp           : arc_type;



end paes.f2t;
