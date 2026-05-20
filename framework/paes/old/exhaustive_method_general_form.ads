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

with paes_utilities;         use paes_utilities;
with Ada.Containers.Vectors; use Ada.Containers;
use Ada.Containers;

generic
   -------------------------
   -- Generic subprograms --
   -------------------------

   -- User should define these generic subprograms
   -- according to the MOO problem solved with
   -- the exhaustive method
   --

   -- This procedure allow to enumerate all the solutions in the
   -- search space
   --
   with procedure generate_next_solution
     (s                         : in out solution;
      m                         : in out chrom_type;
      space_search_is_exhausted :    out Boolean);

   -- This function is dedicated to check the feasibility of each
   -- explored solution
   --
   with function check_feasibility
     (s    : in solution;
      eidx : in Natural) return Boolean;

   -- This procedure allows to evaluate each solution according
   -- the set of objectives
   --
   with procedure evaluate (s : in out solution; eidx : in Natural);

   -- This procedure normalizes the chromosome representation
   -- of a solution to avoid redondant chromosome representation
   --
   with procedure normalize (s : in out solution);

procedure exhaustive_method_general_form;
