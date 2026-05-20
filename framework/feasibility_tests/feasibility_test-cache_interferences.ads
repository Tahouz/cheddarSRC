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

with xml_tag;     use xml_tag;
with double_util; use double_util;
with feasibility_test.processor_utilization;
use feasibility_test.processor_utilization;
with Text_IO;                  use Text_IO;
with translate;                use translate;
with unbounded_strings;        use unbounded_strings;
with scheduler;                use scheduler;
with Scheduling_Analysis;      use Scheduling_Analysis;
with Call_Framework_Interface; use Call_Framework_Interface;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with priority_assignment.rm;       use priority_assignment.rm;
with priority_assignment.dm;       use priority_assignment.dm;
with systems;                      use systems;
with scheduler.fixed_priority;     use scheduler.fixed_priority;
with scheduler.fixed_priority.dm;  use scheduler.fixed_priority.dm;
with scheduler.fixed_priority.rm;  use scheduler.fixed_priority.rm;
with scheduler.fixed_priority.hpf; use scheduler.fixed_priority.hpf;
with cache_set;                    use cache_set;
with Caches;                       use Caches;
with cache_block_set;              use cache_block_set;
with cache_access_profile_set;     use cache_access_profile_set;

package feasibility_test.cache_interferences is

   function compute_gamma_ucb_union_multiset
     (my_tasks                  : in tasks_set;
      task_i                    : in generic_task_ptr;
      task_j                    : in generic_task_ptr;
      response_time             : in response_time_table;
      wiq                       : in Double;
      q                         : in Natural;
      crpd_computation_approach : in crpd_computation_approach_type :=
        ecb_only;
      block_reload_time        : in Natural                   := 0;
      my_cache_access_profiles : in cache_access_profiles_set :=
        no_cache_access_profile)
      return Natural;

   function compute_gamma_ecb_union_multiset
     (my_tasks                  : in tasks_set;
      task_i                    : in generic_task_ptr;
      task_j                    : in generic_task_ptr;
      response_time             : in response_time_table;
      wiq                       : in Double;
      q                         : in Natural;
      crpd_computation_approach : in crpd_computation_approach_type :=
        ecb_only;
      block_reload_time        : in Natural                   := 0;
      my_cache_access_profiles : in cache_access_profiles_set :=
        no_cache_access_profile)
      return Natural;

end feasibility_test.cache_interferences;
