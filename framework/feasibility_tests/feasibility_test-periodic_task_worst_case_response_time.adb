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

with translate;           use translate;
with unbounded_strings;   use unbounded_strings;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with feasibility_test.processor_utilization;
use feasibility_test.processor_utilization;
with Scheduler_Interface; use Scheduler_Interface;
with systems;             use systems;
with feasibility_test.periodic_task_worst_case_response_time_dynamic_priority;
use feasibility_test.periodic_task_worst_case_response_time_dynamic_priority;
with feasibility_test.periodic_task_worst_case_response_time_fixed_priority;
use feasibility_test.periodic_task_worst_case_response_time_fixed_priority;
with scheduler.dynamic_priority;   use scheduler.dynamic_priority;
with scheduler.fixed_priority.dm;  use scheduler.fixed_priority.dm;
with scheduler.fixed_priority.rm;  use scheduler.fixed_priority.rm;
with scheduler.fixed_priority.hpf; use scheduler.fixed_priority.hpf;
with cache_set;                    use cache_set;
with Caches;                       use Caches;
with Call_Framework_Interface;     use Call_Framework_Interface;
with scheduler.fixed_priority;     use scheduler.fixed_priority;

package body feasibility_test.periodic_task_worst_case_response_time is

   procedure compute_response_time
     (my_scheduler              : in     generic_scheduler_ptr;
      my_sys                    : in     system;
      processor_name            : in     Unbounded_String;
      msg                       : in out Unbounded_String;
      response_time             :    out response_time_table;
      with_memory_interferences : in memory_interference_computation_approach_type :=
        no_memory_interference;
      with_crpd                : in crpd_computation_approach_type := no_crpd;
      block_reload_time        : in Natural                        := 0;
      my_cache_access_profiles : in cache_access_profiles_set      :=
        no_cache_access_profile)
   is
   begin
      case my_scheduler.parameters.scheduler_type is
         when rate_monotonic_protocol =>
            compute_response_time
              (rm_scheduler (my_scheduler.all),
               my_sys,
               processor_name,
               msg,
               response_time,
               with_memory_interferences,
               with_crpd,
               block_reload_time,
               my_cache_access_profiles);
         when deadline_monotonic_protocol =>
            compute_response_time
              (dm_scheduler (my_scheduler.all),
               my_sys,
               processor_name,
               msg,
               response_time,
               with_memory_interferences,
               with_crpd,
               block_reload_time,
               my_cache_access_profiles);
         when posix_1003_highest_priority_first_protocol =>
            compute_response_time
              (hpf_scheduler (my_scheduler.all),
               my_sys,
               processor_name,
               msg,
               response_time,
               with_memory_interferences,
               with_crpd,
               block_reload_time,
               my_cache_access_profiles);
         when earliest_deadline_first_protocol              |
           least_laxity_first_protocol                      |
           d_over_protocol                                  |
           maximum_urgency_first_based_on_laxity_protocol   |
           maximum_urgency_first_based_on_deadline_protocol =>
            compute_response_time
              (dynamic_priority_scheduler (my_scheduler.all),
               my_sys,
               processor_name,
               msg,
               response_time);
         when others =>
            raise invalid_scheduler;
      end case;
   end compute_response_time;

end feasibility_test.periodic_task_worst_case_response_time;
