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

with paes_utilities;            use paes_utilities;
with systems;                   use systems;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with unbounded_strings;         use unbounded_strings;
with tasks;                     use tasks;
with task_set;                  use task_set;
with resources;                 use resources;
with resource_set;              use resource_set;
with scheduler;                 use scheduler;
with scheduler_interface;       use scheduler_interface;
with framework_config;          use framework_config;

-- This package defines subprograms needed
-- to instanciate PAES for the Functions-to-Tasks (F2T)
-- architecture exploration problem
--
package chromosome_data_manipulation is

   -- Global variables
   --
   -- Initial_System is the Cheddar-ADL model
   -- of the initial design
   initial_system : system;

   -- Hyperperiod_of_Initial_Taskset is the hyperperiod
   -- of the initial design
   --
   hyperperiod_of_initial_taskset : Integer;

   -- The_Scheduler is the priority assignment
   -- policy used in the scheduling simulation
   the_scheduler : schedulers_type;

   -- values of Task_priority and Sched_policy varaibles
   -- depend of the The_Scheduler value
   -- for example:
   -- *) The_Scheduler = Rate_Monotonic_Protocol
   --    =>> Task_priority = 1  || Sched_policy = SCHED_FIFO
   -- *) The_Scheduler = Earliest_Deadline_First_Protocol
   --    =>> Task_priority = 0  || Sched_policy = SCHED_OTHERS
   --
   task_priority : Integer;
   sched_policy  : policies;

   -- This variable represents the maximum hyperperiod
   -- of the explored solutions
   --
   max_hyperperiod : Integer;

   -- This variable is used to differentiate the cases:
   -- when Using_preprocessed_initial_sol = false; i.e. the initial
   -- solution is 1-1 fcts-tasks mapping
   -- otherwise, we use the preprocessed initial solution
   --
   using_preprocessed_initial_sol : Boolean := False;

   one_to_one_mapping_solution : solution;

   -- These subprograms are the specific implementation
   -- of PAES generic subprograms, that will be used
   -- in order to instanciate PAES_method/Exhaustive_method
   -- for the F2T architecture exploration problem
   --
   procedure init_f2t;

   procedure mutate_f2t (s : in out solution; eidx : in Natural);

   procedure generate_next_solution_f2t
     (s                         : in out solution;
      m                         : in out chrom_type;
      space_search_is_exhausted :    out Boolean);

   -- This procedure is used to normalize a mutated solution (functions to tasks assignment)
   -- exemple to normalize a solution:
   -- [5 2 5 3 4 5 2] => after normalization [1 2 1 3 4 1 2]
   --
   procedure normalize (s : in out solution);



   -- This function returns true if the function with "function_index"
   -- index is the only function assigned to the task that it belongs
   -- according the solution "s"
   --


   function is_isolated
     (function_index : Integer;
      s              : solution) return Boolean;

   -- This function returns the number of tasks from a given
   -- candidate solution "s"
   --
   function number_of_tasks (s : in solution) return Integer;


   -- This procedure applies F2T rules on a given candidate solution "S"
   -- in order to generate the corresponding CheddarADL model
   --
   --Procedure Appling_clustering_rules (A_sys : in out System;
   --                                    s     : in solution);
   procedure transform_chromosome_to_cheddaradl_model
     (a_sys : in out system;
      s     : in     solution);



   -- This procedure creates a CheddarADL model a core_unit, a processor
   -- and an address_Space
   --
   procedure create_system (a_system : in out system);


end chromosome_data_manipulation;
