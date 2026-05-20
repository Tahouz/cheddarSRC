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
--    $Rev: 5272 $
--    $Date: 2024-11-29 15:41:18 +0100 (ven., 29 nov. 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Exceptions;         use Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;

with scheduler.user_defined; use scheduler.user_defined;
with scheduler.user_defined.interpreted.pipeline;
use scheduler.user_defined.interpreted.pipeline;
with scheduler.user_defined.interpreted.automata;
use scheduler.user_defined.interpreted.automata;
with scheduler.user_defined.generated.compiled;
use scheduler.user_defined.generated.compiled;
with scheduler.fixed_priority.dm;    use scheduler.fixed_priority.dm;
with scheduler.fixed_priority.rm;    use scheduler.fixed_priority.rm;
with scheduler.fixed_priority.hpf;   use scheduler.fixed_priority.hpf;
with scheduler.dynamic_priority.edf; use scheduler.dynamic_priority.edf;
with scheduler.dynamic_priority.edfett; use scheduler.dynamic_priority.edfett;
with scheduler.dynamic_priority.edh; use scheduler.dynamic_priority.edh;
with scheduler.dynamic_priority.llf; use scheduler.dynamic_priority.llf;
with scheduler.dynamic_priority.llf.runtime_based;
use scheduler.dynamic_priority.llf.runtime_based;
with scheduler.dynamic_priority.muf.deadline_based;
use scheduler.dynamic_priority.muf.deadline_based;
with scheduler.dynamic_priority.muf.laxity_based;
use scheduler.dynamic_priority.muf.laxity_based;
with scheduler.dynamic_priority.d_over; use scheduler.dynamic_priority.d_over;
with scheduler.time_sharing_based_on_wait_time;
use scheduler.time_sharing_based_on_wait_time;
with scheduler.time_sharing_based_on_cpu_usage;
use scheduler.time_sharing_based_on_cpu_usage;
with scheduler.round_robin;  use scheduler.round_robin;
with scheduler.hierarchical; use scheduler.hierarchical;
with scheduler.hierarchical.round_robin; use scheduler.hierarchical.round_robin;
with scheduler.hierarchical.cyclic;  use scheduler.hierarchical.cyclic;
with scheduler.hierarchical.offline; use scheduler.hierarchical.offline;
with scheduler.hierarchical.fixed_priority; use scheduler.hierarchical.fixed_priority;
with scheduler.fixed_priority.aperiodic_server;
use scheduler.fixed_priority.aperiodic_server;
with scheduler.fixed_priority.aperiodic_server.polling;
use scheduler.fixed_priority.aperiodic_server.polling;
with scheduler.fixed_priority.aperiodic_server.priority_exchange;
use scheduler.fixed_priority.aperiodic_server.priority_exchange;
with scheduler.fixed_priority.aperiodic_server.deferrable;
use scheduler.fixed_priority.aperiodic_server.deferrable;
with scheduler.fixed_priority.aperiodic_server.sporadic;
use scheduler.fixed_priority.aperiodic_server.sporadic;
with scheduler.multiprocessor_specific; use scheduler.multiprocessor_specific;
with scheduler.multiprocessor_specific.pfair;
use scheduler.multiprocessor_specific.pfair;
with scheduler.multiprocessor_specific.pfair.pf;
use scheduler.multiprocessor_specific.pfair.pf;
with scheduler.multiprocessor_specific.edzl;
use scheduler.multiprocessor_specific.edzl;
with scheduler.multiprocessor_specific.run;
use scheduler.multiprocessor_specific.run;
with scheduler.multiprocessor_specific.llref;
use scheduler.multiprocessor_specific.llref;
with scheduler.dag.highest_level_first_estimated_times;
use scheduler.dag.highest_level_first_estimated_times;
with scheduler.mixed_criticality.edf_vd;
use scheduler.mixed_criticality.edf_vd;
with scheduler.mixed_criticality.amc; use scheduler.mixed_criticality.amc;
with scheduler.mixed_criticality.smc; use scheduler.mixed_criticality.smc;
with scheduler.mixed_criticality.quality_amc; use scheduler.mixed_criticality.quality_amc;
with scheduler.mixed_criticality.recurrent_quality_amc; 
use scheduler.mixed_criticality.recurrent_quality_amc;
with scheduler.nothing;               use scheduler.nothing;

with Processors;                      use Processors;
with processor_set;                   use processor_set;
with Address_Spaces;                  use Address_Spaces;
with Core_Units;                      use Core_Units;
use Core_Units.Core_Units_Table_Package;
with task_set;                     use task_set;
with translate;                    use translate;
with Objects;                      use Objects;
with Objects.extended;             use Objects.extended;
with initialize_framework;         use initialize_framework;
with Scheduler_Interface.extended; use Scheduler_Interface.extended;


package body scheduler_builder is

   -- build a scheduler from its Cheddar ADL specification
   --
   function build_a_scheduler
     (a_processor : generic_processor_ptr) return generic_scheduler_ptr
   is

      a_core_unit : core_unit_ptr;

   begin
      if a_processor.processor_type = monocore_type then
         a_core_unit := mono_core_processor_ptr (a_processor).core;
      else
         a_core_unit :=
           multi_cores_processor_ptr (a_processor).cores.entries (0);
      end if;

      return build_a_scheduler (a_core_unit, a_processor);
   end build_a_scheduler;

   function build_a_scheduler
     (a_core_unit : core_unit_ptr;
      a_processor : generic_processor_ptr) return generic_scheduler_ptr
   is

      a_scheduler : generic_scheduler_ptr;

   begin

      case a_core_unit.scheduling.scheduler_type is

         when rate_monotonic_protocol =>
            a_scheduler := new rm_scheduler;
         when deadline_monotonic_protocol =>
            a_scheduler := new dm_scheduler;
         when posix_1003_highest_priority_first_protocol =>
            a_scheduler := new hpf_scheduler;
         when earliest_deadline_first_protocol =>
            a_scheduler := new edf_scheduler;
         when earliest_deadline_first_energy_to_time_protocol =>
            a_scheduler := new edfett_scheduler;
         when earliest_deadline_first_energy_harvesting_protocol =>
            a_scheduler := new edh_scheduler;
         when least_laxity_first_protocol =>
            a_scheduler := new llf_scheduler;
         when least_runtime_laxity_first_protocol =>
            a_scheduler := new llf_runtime_based_scheduler;
         when round_robin_protocol =>
            a_scheduler := new round_robin_scheduler;
         when maximum_urgency_first_based_on_deadline_protocol =>
            a_scheduler := new deadline_muf_scheduler;
         when maximum_urgency_first_based_on_laxity_protocol =>
            a_scheduler := new laxity_muf_scheduler;
         when time_sharing_based_on_wait_time_protocol =>
            a_scheduler := new time_sharing_based_on_wait_time_scheduler;
         when time_sharing_based_on_cpu_usage_protocol =>
            a_scheduler := new time_sharing_based_on_cpu_usage_scheduler;
         when d_over_protocol =>
            a_scheduler := new d_over_scheduler;
         when pipeline_user_defined_protocol =>
            a_scheduler := new pipeline_user_defined_scheduler;
         when automata_user_defined_protocol =>
            a_scheduler := new automata_user_defined_scheduler;
         when compiled_user_defined_protocol =>
            a_scheduler := new compiled_user_defined_scheduler;

         when hierarchical_cyclic_protocol =>
            a_scheduler := new hierarchical_cyclic_scheduler;
         when hierarchical_offline_protocol =>
            a_scheduler := new hierarchical_offline_scheduler;
         when hierarchical_round_robin_protocol =>
            a_scheduler := new hierarchical_round_robin_scheduler;
         when hierarchical_fixed_priority_protocol =>
            a_scheduler := new hierarchical_fixed_priority_scheduler;

         when dag_highest_level_first_estimated_times_protocol =>
            a_scheduler :=
              new dag_highest_level_first_estimated_times_scheduler;

         when mixed_criticality_smc_protocol =>
            a_scheduler := new mixed_criticality_smc_scheduler;
         when mixed_criticality_amc_protocol =>
            a_scheduler := new mixed_criticality_amc_scheduler;
         when mixed_criticality_recurrent_quality_amc_protocol =>
            a_scheduler := new mixed_criticality_recurrent_quality_amc_scheduler;
         when mixed_criticality_quality_amc_protocol =>
            a_scheduler := new mixed_criticality_quality_amc_scheduler;
         when mixed_criticality_edf_vd_protocol =>
            a_scheduler := new mixed_criticality_edf_vd_scheduler;

         when hierarchical_polling_aperiodic_server_protocol =>
            a_scheduler := new polling_aperiodic_server_scheduler;
         when hierarchical_deferrable_aperiodic_server_protocol =>
            a_scheduler := new deferrable_aperiodic_server_scheduler;
         when hierarchical_priority_exchange_aperiodic_server_protocol =>
            a_scheduler := new priority_exchange_aperiodic_server_scheduler;
         when hierarchical_sporadic_aperiodic_server_protocol =>
            a_scheduler := new sporadic_aperiodic_server_scheduler;

         when proportionate_fair_pf_protocol |
           proportionate_fair_pd_protocol    |
           proportionate_fair_pd2_protocol   =>
            a_scheduler := new multiprocessor_pfair_pf_scheduler;
         when reduction_to_uniprocessor_protocol =>
            a_scheduler := new multiprocessor_run_scheduler;
         when earliest_deadline_zero_laxity_protocol =>
            a_scheduler := new multiprocessor_edzl_scheduler;
         when largest_local_remaining_execution_first_protocol =>
            a_scheduler := new multiprocessor_llref_scheduler;

         when user_defined_protocol | no_scheduling_protocol =>
            Raise_Exception
              (processor_set.invalid_parameter'identity,
               To_String
                 (lb_core_unit (Current_Language) &
                  " " &
                  a_core_unit.name &
                  " : " &
                  lb_invalid_scheduler (Current_Language)));

      end case;

      -- Set scheduling parameters
      --
      a_scheduler.parameters := a_core_unit.scheduling;

      if
        (a_core_unit.scheduling.scheduler_type =
         automata_user_defined_protocol)
      then
         set_behavior_file_name
           (automata_user_defined_scheduler (a_scheduler.all),
            a_core_unit.scheduling.user_defined_scheduler_source_file_name);
         set_automaton_name
           (automata_user_defined_scheduler (a_scheduler.all),
            a_core_unit.scheduling.automaton_name);
      end if;
      if
        (a_core_unit.scheduling.scheduler_type =
         pipeline_user_defined_protocol)
      then
         set_behavior_file_name
           (pipeline_user_defined_scheduler (a_scheduler.all),
            a_core_unit.scheduling.user_defined_scheduler_source_file_name);
      end if;
      set_quantum (a_scheduler.all, a_core_unit.scheduling.quantum);
      set_preemptive (a_scheduler.all, a_core_unit.scheduling.preemptive_type);

      -- Core unit and processor corresponding to this scheduler
      -- (used to drive task migration for example)
      --
      a_scheduler.corresponding_core_unit := a_core_unit;
      a_scheduler.corresponding_processor := a_processor;

      -- Allow the scheduler to know if the previous task is completed
      -- or not ... and then, could be re-elected later
      -- (for non preemptive scheduling protocols)
      --
      a_scheduler.previous_running_task_is_not_completed := False;

      -- Last scheduled task
      --
      a_scheduler.previously_elected := tasks_range'first;

      return a_scheduler;
   end build_a_scheduler;

   function build_a_scheduler
     (a_addr      : address_space_ptr;
      a_processor : generic_processor_ptr) return generic_scheduler_ptr
   is
      sched       : generic_scheduler_ptr;
      a_core_unit : core_unit_ptr;

   begin

      case a_addr.scheduling.scheduler_type is
         when rate_monotonic_protocol =>
            sched := new rm_scheduler;
         when deadline_monotonic_protocol =>
            sched := new dm_scheduler;
         when posix_1003_highest_priority_first_protocol =>
            sched := new hpf_scheduler;
         when earliest_deadline_first_protocol =>
            sched := new edf_scheduler;
         when least_laxity_first_protocol =>
            sched := new llf_scheduler;
         when round_robin_protocol =>
            sched := new round_robin_scheduler;
         when maximum_urgency_first_based_on_deadline_protocol =>
            sched := new deadline_muf_scheduler;
         when maximum_urgency_first_based_on_laxity_protocol =>
            sched := new laxity_muf_scheduler;
         when time_sharing_based_on_wait_time_protocol =>
            sched := new time_sharing_based_on_wait_time_scheduler;
         when time_sharing_based_on_cpu_usage_protocol =>
            sched := new time_sharing_based_on_cpu_usage_scheduler;
         when d_over_protocol =>
            sched := new d_over_scheduler;
         when automata_user_defined_protocol =>
            sched := new automata_user_defined_scheduler;
         when compiled_user_defined_protocol =>
            sched := new compiled_user_defined_scheduler;
         when dag_highest_level_first_estimated_times_protocol =>
            sched := new dag_highest_level_first_estimated_times_scheduler;
         when mixed_criticality_amc_protocol =>
            sched := new mixed_criticality_amc_scheduler;
         when mixed_criticality_quality_amc_protocol =>
            sched := new mixed_criticality_quality_amc_scheduler;
         when mixed_criticality_edf_vd_protocol =>
            sched := new mixed_criticality_edf_vd_scheduler;
         when no_scheduling_protocol =>
            sched := new no_scheduler;
         when others =>
            null;
      end case;

      if
        (a_addr.scheduling.scheduler_type = automata_user_defined_protocol)
      then
         set_behavior_file_name
           (automata_user_defined_scheduler (sched.all),
            a_addr.scheduling.user_defined_scheduler_source_file_name);
         set_automaton_name
           (automata_user_defined_scheduler (sched.all),
            a_addr.scheduling.automaton_name);
      end if;

      set_quantum (sched.all, a_addr.scheduling.quantum);
      set_preemptive (sched.all, a_addr.scheduling.preemptive_type);

      -- Core unit and processor corresponding to this scheduler
      -- (used to drive task migration for example)
      --
      if a_processor.processor_type = monocore_type then
         a_core_unit := mono_core_processor_ptr (a_processor).core;
      else
         a_core_unit :=
           multi_cores_processor_ptr (a_processor).cores.entries (0);
      end if;

      sched.corresponding_address_space := a_addr;
      sched.corresponding_core_unit     := a_core_unit;
      sched.corresponding_processor     := a_processor;

      return sched;
   end build_a_scheduler;


end scheduler_builder;
