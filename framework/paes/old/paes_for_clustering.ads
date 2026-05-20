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

with paes;                      use paes;
with task_clustering_rules;     use task_clustering_rules;
with systems;                   use systems;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with unbounded_strings;         use unbounded_strings;

-- This package defines all subprograms needed
-- to formulate PAES for the task clustering problem
package paes_for_clustering is

   -- FitnessFunctions is an array of all possible fitness functions
   -- that could be combined in order to drive the design space exploration
   --
   type fitnessfunction is record
      name        : Unbounded_String;
      is_selected : Integer; -- 0 ==> is NOT selected | 1 ==> is selected
   end record;

   max_fitness      : constant Integer := 11;
   fitnessfunctions : array (1 .. max_fitness) of fitnessfunction;

   -- These subprograms are the specific implementation
   -- of PAES generic subprograms
   procedure init_for_clustering;
   procedure evaluate_for_clustering (s : in out solution; eidx : in Natural);
   procedure mutate_for_clustering (s : in out solution; eidx : in Natural);

   -- "normalize" used to normalize a mutated solution
   -- exemple to normalize a solution:
   -- [5 2 5 3 4 5 2] => After normalization [1 2 1 3 4 1 2]
   procedure normalize (s : in out solution);

   -- return true if the task t is isolated i.e it is alone in the cluster to which it belongs
   -- false otherwise
   function is_isolated (t : Integer; s : solution) return Boolean;

end paes_for_clustering;
