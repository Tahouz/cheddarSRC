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

with paes_utilities;               use paes_utilities;
with chromosome_data_manipulation; use chromosome_data_manipulation;
with systems;                      use systems;
with Ada.Numerics.Float_Random;    use Ada.Numerics.Float_Random;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;
with unbounded_strings;            use unbounded_strings;
with Paes_Utilities;                  use Paes_Utilities;
--with Chromosome_Data_Manipulation_mils; use Chromosome_Data_Manipulation_mils;
-- This package defines a set of objective functions
-- and implements the feasibility checks on candidate
-- solutions of the F2T architecture exploration problem
--
package objective_functions_and_feasibility_checks is

   -- FitnessFunctions is an array of possible objective functions
   -- that could be combined in order to drive
   -- the design space exploration
   --
   type fitnessfunction is record
      name        : Unbounded_String;
      is_selected : Integer; -- 0 ==> is NOT selected | 1 ==> is selected
   end record;

   max_fitness      : constant Integer := 14;
   fitnessfunctions : array (1 .. max_fitness) of fitnessfunction;

   procedure initialize_fitnessfunctions;

   -- This function checks if a solution is consistent or not :
   -- 1) Check for each task of the candidate solution that Ci <= Di
   -- 2) Check that the total processor Utilization <= 1
   -- 3) check if there are two non-harmonic functions which are
   -- grouped alone in the same task.
   --
   function check_feasibility_of_a_solution
     (s    : in solution;
      eidx : in Natural) return Boolean;


   -- This procedure update a solution "s" with its objective values
   -- by retrieving some informations from its scheduling simulation
   -- results that was done to check its schedulability (throughout
   -- the feasibility checks procedure)
   --
   procedure evaluate_f2t (s : in out solution; eidx : in Natural);

end objective_functions_and_feasibility_checks;
