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
--    $Rev: 5537 $
--    $Date: 2025-04-09 08:57:25 +0200 (mer., 09 avril 2025) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with Text_IO;                  use Text_IO;

with Generic_Graph;            use Generic_Graph;
with Tasks;                    use Tasks;
with Task_Groups;              use Task_Groups;
with Buffers;                  use Buffers;
with Messages;                 use Messages;
with Dependencies;             use Dependencies;
with Resources;                use Resources;
with systems;                  use systems;
with Processors;               use Processors;
with processor_set;            use processor_set;
with Processor_Interface;      use Processor_Interface;
with Core_Units;               use Core_Units;
use Core_Units.Core_Units_Table_Package;
with task_set;                 use task_set;
with Scheduler_Interface;      use Scheduler_Interface;
with systems;                  use systems;
with unbounded_strings;        use unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
with Unchecked_Deallocation;
with cache_set;                use cache_set;
with Caches;                   use Caches;
with cache_block_set;          use cache_block_set;
with cache_access_profile_set; use cache_access_profile_set;
with random_tools;             use random_tools;
with Doubles;                  use Doubles;

with Ada.Numerics.Discrete_Random;
with Ada.Finalization;
with convert_strings;
with convert_unbounded_strings;

package architecture_factory is

   -------------------------------------------------------
   -- This package contains procedures to build a system architecture with Cheddar architecture language.
   -- Procedure are grouped by the type of entity they add to the system.

   -- There are three types of procedures :
   -- (1) procedures building a complete system (group n°0)
   -- (2) procedures adding an entity or a group of entities to a system
   -- Those groups of procedures are numbered from 1 to 12,
   -- according to the order in which they need to be added
   -- (3) functions returning ramdomly picked entity types (with a normal law).
   -------------------------------------------------------

   type int_range is range 0 .. 99999;
   package rand_int is new Ada.Numerics.Discrete_Random (int_range);
   g_int : rand_int.generator;

   type resource_range is range 0 .. 2;
   package rand_res is new Ada.Numerics.Discrete_Random (resource_range);
   g_res : rand_res.generator;
   
   -- coefficient 
   subtype coefficient is Natural range 0 .. 100 ;

   building_architecture_exception : exception;

   procedure initialize_cpt;

   -------------------------------------------------------
   -- (1) procedures building a complete system (group n°0)
   -------------------------------------------------------

   -- 0 --------= System =--------

   procedure create_time_triggered_communication_system
     (s                     : in out system;
      number_tasks          : in     Integer;
      number_resources      : in     Integer;
      number_messages       : in     Integer;
      number_dependencies   : in     Integer;
      number_core_units     : in     Integer;
      number_processors     : in     Integer;
      number_buffers        : in     Integer;
      number_address_spaces : in     Integer);

   procedure create_ravenscar_system
     (s                     : in out system;
      number_tasks          : in     Integer;
      number_resources      : in     Integer;
      number_messages       : in     Integer;
      number_dependencies   : in     Integer;
      number_core_units     : in     Integer;
      number_processors     : in     Integer;
      number_buffers        : in     Integer;
      number_address_spaces : in     Integer);

   procedure create_mf_system
     (s                               : in out system;
      number_groups                   : in     Integer;
      number_frames                   : in     Integer;
      number_resources                : in     Integer;
      number_resource_usages          : in     Integer;
      number_core_units_per_processor : in     Integer;
      number_processors               : in     Integer;
      number_address_spaces           : in     Integer;
      sched                           : in     schedulers_type;
      mf_period                       : in     Integer := 0;
      sync_ratio                      : in     Double  := 0.0;
      number_precedences              : in     Integer := 0);

   -- Generate randomly a schedulable system
   -- from a set of given arguments:
   --
   procedure generate_a_customized_ravenscar_system
     (my_system               : in out system;
      n                       : in     Integer; -- number of tasks
      target_cpu_utilization  : in     Float; -- desired cpu utilization
      current_cpu_utilization : out Float; -- cpu utilization of the generated system
      n_diff_periods : in     Integer; -- number of maximum different periods
      n_resources             : in     Integer; -- number of resources
      rsf                     : in     Float; -- resource sharing factor
      csr                     : in     Float; -- critical section ratio
      a_sched_policy          : in     policies);

   -- Task set Generation based on :
   -- Goossens, J., & Macq, C. (2001) And Bertout (2014).
   -- The method is as follow :
   --
   -- • Ui : each task utilization (Ci/Ti) is computed following
   -- the classic UUnifast method [BINI and BUTTAZZO'2005]  from the overall
   -- utilization factor of the processor cpu_utilization.
   --
   -- • Ti : each task period is uniformly distributed between
   -- a set of a maximum of N_Different_Periods different periods by task set
   -- using method of [Goosens'2001], ensuring that the simulation can
   -- be limited to a reasonable hyper-period.
   --
   -- • Ci = Ti × Ui : the task capacity is computed as
   -- the product of its period and its utilization factor
   --
   -- • Di = Round((Ti − Ci ) * Random(D_Min, D_Max)) + Ci
   -- with 0 ≤ d1 ≤ d2.
   -- This computation comes from [Goosens'2001] and use
   -- the following functions: rand(D_Min, D_Max) which
   -- returns a pseudo-random real number uniformly
   -- distributed in the interval [D_Min, D_Max] and round(x) which
   -- returns the closest integer to x.
   -- We notice that :
   -- D_Min = D_Max = 1 corresponds to implicit deadlines and
   -- D_Min ≤ D_Max = 1 to constrained deadlines.
   --
   procedure create_independant_periodic_taskset_system
     (s                       : in out system;
      current_cpu_utilization : in out Float;
      n_tasks                 : in     Integer;
      target_cpu_utilization  : in     Float;
      d_min                   : in     Float   := 1.0;
      d_max                   : in     Float   := 1.0;
      is_synchronous          : in     Boolean := True;
      n_different_periods     : in     Integer;
      a_sched_policy          : in     policies);
      
   ------------------------------------------------
   -- Create_Independant_Periodic_TaskSet_System by generating only capacity--
   -- Periods are given by the t_values parameter !
   ------------------------------------------------

   procedure create_independant_periodic_taskset_system
     (s                       : in out system;
      current_cpu_utilization : in out Float;
      n_tasks                 : in     Integer;
      target_cpu_utilization  : in     Float;
      t_values                : in     integer_array;
      priority_values         : in     integer_array);

   procedure compute_criticality_by_CPU_Utilization
   (n_tasks : in Integer;
    t_values : in random_tools.integer_array; 
    u_values :  in out random_tools.float_array; 
    criticality_tab : in out integer_array;
    cpu_used	: in float);

   procedure create_Mixedcriticality_independant_periodic_taskset_system
     (s                       	: in out system;
      current_cpu_utilization 	: in out Float;
      n_tasks                 	: in     Integer;
      target_cpu_utilization  	: in     Float;
      d_min                   	: in     Float   := 1.0;
      d_max                   	: in     Float   := 1.0;
      is_synchronous          	: in     Boolean := True;
      n_different_periods     	: in     Integer;
      p_high_tasks	      	: in     Natural;
      p_medium_tasks	      	: in     Natural;
      coef			: in  	 coefficient;
      a_sched_policy          	: in     policies);
      
   procedure create_Mixedcriticality_independant_periodic_taskset_system
     (s                       	: in out system;
      current_cpu_utilization 	: in out Float;
      n_tasks                 	: in     Integer;
      target_cpu_utilization  	: in  out   Float;
      d_min                   	: in     Float   := 1.0;
      d_max                   	: in     Float   := 1.0;
      is_synchronous          	: in     Boolean := True;
      n_different_periods     	: in     Integer;
      p_high_tasks	      	: in     Natural;
      p_medium_tasks	      	: in     Natural;
      coef			: in  	 coefficient;
      a_sched_policy          	: in     policies;
      first_time		: in	 Boolean;
      u_values			: in out random_tools.float_array;
      tab_criticality		: in out random_tools.integer_array;
      tab_period		: in out random_tools.integer_array;
      cpu_used_factor		: in 	 Float;
      multicore			: in Boolean;
      protocol_recovery	: in Natural;
      protocol_improvement_quality : in Natural;
      a_seed			: in out Natural);

   -------------------------------------------------------------
   -- (2) procedures adding an entity or a group of entities to a system
   -------------------------------------------------------------

   -- 8 --------= Tasks_Set =--------

   procedure add_task_deadline_equals_period_to_system
     (s                  : in out system;
      name               : in     Unbounded_String;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      task_type          : in     tasks_type);

   procedure add_task_deadline_larger_than_period_to_system
     (s                  : in out system;
      name               : in     Unbounded_String;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      task_type          : in     tasks_type);

   procedure add_task_deadline_smaller_than_period_to_system
     (s                  : in out system;
      name               : in     Unbounded_String;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      task_type          : in     tasks_type);

   procedure add_aperiodic_task_to_system
     (s                  : in out system;
      name               : in     Unbounded_String;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String);

   procedure add_periodic_task_to_system
     (s                  : in out system;
      name               : in     Unbounded_String;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String);

   procedure add_frame_task_to_system
     (s                  : in out system;
      name               : in     Unbounded_String;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String);

   procedure add_multiple_tasks_to_system
     (s         : in out system;
      n         :        Integer;
      task_type : in     tasks_type);

   procedure add_multiple_frame_tasks_to_system
     (s             : in out system;
      number_frames : in     Integer;
      mf_period     : in     Integer;
      sync_ratio    : in     Double);

   procedure add_multiple_periodic_tasks_to_set_uunifast
     (my_tasks : in out tasks_set;
      n        : in     Integer;
      u        : in     Float);

   procedure add_multiple_periodic_tasks_harmonic_with_direct_mapped_instruction_cache_utilization_to_set_uunifast
     (my_tasks                 : in out tasks_set;
      n                        : in     Integer;
      pu                       : in     Float;
      cu                       : in     Float;
      cs                       : in     Integer;
      rf                       : in     Float;
      my_instruction_cache     : in     instruction_cache_ptr;
      my_cache_access_profiles :    out cache_access_profiles_set);

   procedure add_multiple_periodic_tasks_no_offset_with_direct_mapped_instruction_cache_utilization_to_set_uunifast
     (my_tasks                 : in out tasks_set;
      min_period               : in     Integer;
      max_period               : in     Integer;
      n                        : in     Integer;
      pu                       : in     Float;
      cu                       : in     Float;
      cs                       : in     Integer;
      rf                       : in     Float;
      my_instruction_cache     : in     instruction_cache_ptr;
      my_cache_access_profiles :    out cache_access_profiles_set);

   -- 9 --------= Resources_Set =--------

   procedure add_resource_to_system
     (s                 : in out system;
      n_dependent_tasks :        Integer);

   procedure add_resource_to_system
     (s                 : in out system;
      name              : in     Unbounded_String;
      n_dependent_tasks :        Integer);

   procedure add_multiple_resources_to_system (s : in out system; n : Integer);

   -- Add_Resource_Set_To_System is a procedure that allows to generate a set of resources
   -- (and their critical section) shared betweew the tasks
   -- of the system given in parameter.
   -- The resource set generator works as follows:
   -- 1) The number of resources is given in parameter
   --
   -- 2) Each resource Rj is accessed by a number of different functions
   --    randomly chosen from the set of functions.
   --    This number is randomly chosen in the range [2 , Resource_sharing_factor * #fcts ]
   --
   -- 3) Each Task Task_i that accesses a given resource Rj,
   --    issues only a single request of Rj per a job
   --    with a critical section Length:
   --       • The length of each critical section CS executed by a Task Task_j , is set as follows:
   --              Length(CS) = Integer(Float'Ceiling(critical_section_ratio * float(capacity(Task_j)))
   --         If the critical section ratio = 0.0 then
   --              it will be chosen randomly from the set {0.1, 0.3, 0.5}
   --         else (i.e the critical section ratio is given by user)
   --              we use the given value
   --
   --       • CS.task_begin : randomly generated in the range [1, capacity(Task_j) – Length(CS) + 1 ]
   --       • CS.task_end = CS.task_begin + Length(CS) – 1
   --
   procedure add_resource_set_to_system
     (s                       : in out system;
      n_resources             : in     Integer;
      resource_sharing_factor : in     Float;
      critical_section_ratio  : in     Float := 0.0);

   -- 3 --------= Messages_Set =--------

   procedure add_message_to_system (s : in out system);

   procedure add_message_to_system
     (s    : in out system;
      name : in     Unbounded_String);

   procedure add_multiple_messages_to_system (s : in out system; n : Integer);

   -- 10 --------= Dependecies =--------

   procedure add_time_triggered_communication_dependency_to_system
     (s : in out system);

   procedure add_dependency_to_system
     (s    : in out system;
      name : in     Unbounded_String);

   procedure add_multiple_dependencies_to_system
     (s : in out system;
      n :        Integer);

   procedure add_multiple_mf_precedence_dependencies_to_system
     (s                  : in out system;
      number_precedences : in     Integer;
      number_groups      : in     Integer;
      sync_ratio         : in     Double);

   -- 11 --------= Task_Groups_Set =--------

   procedure add_task_group_to_system
     (s               : in out system;
      task_group_type : in     task_groups_type);

   procedure add_task_group_to_system
     (s               : in out system;
      name            : in     Unbounded_String;
      task_group_type : in     task_groups_type);

   procedure add_multiple_task_groups_to_system
     (s               : in out system;
      n               :        Integer;
      task_group_type : in     task_groups_type);

   -- 12 --------= Deployments =--------

   -- 1 --------= Core_Units_Set =--------

   procedure add_core_unit_to_system (s : in out system);

   procedure add_core_unit_to_system
     (s     : in out system;
      sched : in     schedulers_type);

   procedure add_core_unit_to_system
     (s    : in out system;
      name : in     Unbounded_String);

   procedure add_core_unit_to_system
     (s                       : in out system;
      a_multi_cores_processor : in     multi_cores_processor_ptr;
      sched                   : in     schedulers_type;
      preempt                 : in     preemptives_type);

   -- 2 --------= Processors_Set =--------

   procedure add_mono_core_processor_to_system
     (s            : in out system;
      preemptivity : in     preemptives_type;
      sched        : in     schedulers_type);

   procedure add_mono_core_processor_to_system
     (s            : in out system;
      preemptivity : in     preemptives_type;
      sched        : in     schedulers_type;
      core         :        core_unit_ptr);

   procedure add_mono_core_processor_to_system
     (s            : in out system;
      name         : in     Unbounded_String;
      preemptivity : in     preemptives_type;
      sched        : in     schedulers_type);

   procedure add_multiple_mono_core_processors_to_system
     (s : in out system;
      n :        Integer);

   procedure add_multi_cores_processor_to_system
     (s                 : in out system;
      number_core_units : in     Integer;
      preemptivity      : in     preemptives_type;
      sched             : in     schedulers_type);

   procedure add_multiple_processors_to_system
     (s                               : in out system;
      number_processors               : in     Integer;
      number_core_units_per_processor : in     Integer;
      sched                           : in     schedulers_type;
      preempt                         : in     preemptives_type);

   -- 7 --------= Buffers_Set =--------

   procedure add_buffer_to_system (s : in out system);

   procedure add_buffer_to_system
     (s                  : in out system;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String);

   procedure add_buffer_to_system
     (s                  : in out system;
      name               : in     Unbounded_String;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String);

   procedure add_multiple_buffers_to_system (s : in out system; n : Integer);

   -- 4 --------= Networks_Set =--------

   -- 5 --------= Event_Analyzers_Set =--------

   -- 6 --------= Address_Spaces_Set =--------

   procedure add_address_space_to_system
     (s        : in out system;
      cpu_name :        Unbounded_String);

   procedure add_address_space_to_system
     (s        : in out system;
      name     : in     Unbounded_String;
      cpu_name :        Unbounded_String);

   procedure add_multiple_address_spaces_to_system
     (s : in out system;
      n :        Integer);

   procedure add_multiple_address_spaces_consistently_to_system
     (s                     : in out system;
      number_processors     : in     Integer;
      number_address_spaces : in     Integer);

   -- Added Functions for DP Prototype Demonstration
   --

   procedure compliant_time_triggered_communication (sys : out system);
   procedure uncompliant_time_triggered_communication (sys : out system);
   procedure compliant_ravenscar (sys : out system);
   procedure uncompliant_ravenscar (sys : out system);
   procedure compliant_unplugged (sys : out system);
   procedure uncompliant_unplugged (sys : out system);
   procedure uncompliant_buffer (sys : out system);

   ---------------------------------------------------------
   -- (3) functions returning ramdomly picked entity types (with a normal law).
   ---------------------------------------------------------

   -- Functions returning ramdomly choosen entity types
   --

   function random_preemptivity return preemptives_type;
   function random_scheduler return schedulers_type;
   function restrained_random_scheduler return schedulers_type;
   function random_dependency_type return dependency_type;
   function random_resource_type return resources_type;
   function restrained_random_resource_type return resources_type;
   function random_task_type return tasks_type;
-- Random_Integer (n : Integer) returns a random integer in the range [0 , n[
   function random_integer (n : Integer) return Integer;
   -- Random_Integer (n1 : Integer; n2 : Integer) returns a random integer in the range [n1 , n2]
   function random_integer (n1 : Integer; n2 : Integer) return Integer;

end architecture_factory;
