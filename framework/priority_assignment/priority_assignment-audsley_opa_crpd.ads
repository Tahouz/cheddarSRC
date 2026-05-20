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
-- Frank Singhoff, Lab-STICC UMR CNRS 6285, Universite de Bretagne Occidentale
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

with Ada.Strings.Unbounded;           use Ada.Strings.Unbounded;
with Text_IO;                         use Text_IO;
with unbounded_strings;               use unbounded_strings;
with Scheduling_Analysis;             use Scheduling_Analysis;
with priority_assignment.audsley_opa; use priority_assignment.audsley_opa;
with task_set;                        use task_set;
with Tasks;                           use Tasks;
with Tasks.extended;                  use Tasks.extended;
with integer_arrays;                  use integer_arrays;
with priority_assignment.utility;     use priority_assignment.utility;
with cache_set;                       use cache_set;
with cache_block_set;                 use cache_block_set;
with cache_access_profile_set;        use cache_access_profile_set;

package priority_assignment.audsley_opa_crpd is

   procedure check_input_data
     (my_tasks                 : in tasks_set;
      my_cache_access_profiles : in cache_access_profiles_set);

   type crpd_inteference_computation_complexity is
     (ecb_only, pt_simplified, pt_binomial_coefficient, tree);
   --------------------------------
   --Perform the Audsley's optimal priority assignment with CRPD taken into account
   --Return the task set with assigned task priorities
   --------------------------------

   -- High level call to Audsley OPA CRPD
   --
   procedure set_priority_according_to_cpa
     (my_tasks                 : in out tasks_set;
      my_cache_access_profiles : in     cache_access_profiles_set;
      computation_complexity   : in crpd_inteference_computation_complexity :=
        pt_simplified;
      processor_name : in Unbounded_String := empty_string);

   -- Lower level call to Audsley OPA CRPD
   -- Perform computation and assign priorities to task
   --
   procedure cpa
     (my_tasks                 : in out tasks_set;
      my_cache_access_profiles : in     cache_access_profiles_set;
      complexity               : in crpd_inteference_computation_complexity :=
        pt_simplified);

end priority_assignment.audsley_opa_crpd;
