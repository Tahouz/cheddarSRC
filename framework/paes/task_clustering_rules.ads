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

with tasks;                 use tasks;
with task_set;              use task_set;
with resources;             use resources;
with resource_set;          use resource_set;
with systems;               use systems;
with paes;                  use paes;
with scheduler;             use scheduler;
with scheduler_interface;   use scheduler_interface;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
with framework_config;      use framework_config;

package task_clustering_rules is

   -- Global variables
   --
   initial_system                 : system;
   hyperperiod_of_initial_taskset : Integer;
   the_scheduler                  : schedulers_type;
   task_priority                  : Integer;
   sched_policy                   : policies;

   --------------------------------------------------------------------------
   -- Declaration of the **Anti-Ideal point** (which represent the "worst"
   -- value of each objective, explored in the search space) In our case
   -- we deal with a minimization problem, so "worst" means the maximum value
   -- can be taken by each objective.
   -- these values shoult be determined among all iterations
   ---------------------------------------------------------------------------
   z1_anti_ideal, z2_anti_ideal : Float;

   ---------------------------------------------------------------------------
   -- and the **Ideal point** which is defined by
   -- the "better" value of each objective,
   -- explored in the search space (i.e. the min value of each objective)
   -- These values are determined from the final archive
   ---------------------------------------------------------------------------
   z1_ideal, z2_ideal : Float;

   -- Generate a schedulable task set using the UUnifast
   -- method to generate utilizations of tasks
   -- from a given cpu utilization.
   --
   procedure generate_initial_schedulable_system
     (my_system      : in out system;
      n              : in     Integer;
      u              : in     Float;
      n_diff_periods : in     Integer;
      n_resources    : in     Integer;
      rsf            : in     Float;
      csr            : in     Float);

   -- Compute the number of tasks from a given solution
   --
   function number_of_tasks (s : in solution) return Integer;

   -- Applying clustering rules on a given solution
   -- to generate the corresponding architecture system
   --
   procedure appling_clustering_rules (a_sys : in out system; s : in solution);

   -- Create a system i.e a system with a core_unit, a processor
   -- and an address_Space
   --
   procedure create_system (a_system : in out system);

   -- This function checks if a solution is consistent or not :
   -- 1) Check for each task of the candidate solution that Ci <= Di
   -- 2) Check that the total processor Utilization <= 1
   -- 3) check if there are two non-harmonic functions which are
   -- grouped alone in the same task.
   --
   function check_consistency_of_a_solution (s : in solution) return Boolean;

end task_clustering_rules;
