with systems;               use systems;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
with task_set;              use task_set;
with object_set;            use object_set;
with time_unit_events;      use time_unit_events;
with scheduler;             use scheduler;
with Ada.Real_Time;         use Ada.Real_Time;
with Ada.Calendar;
with Ada.Calendar.Formatting;
with Ada.Text_IO;           use Ada.Text_IO;

package scheduling_anomalies_services.offline is

----------------------------------------
-- Design time verification
----------------------------------------

   ----- Entry point of the static verification
   --
   procedure scheduling_anomalies_analyzer
     (a_system : in     system;
      msg      :    out Unbounded_String);

   ----- Subprograms to statically verify each constraint
   --
   function check_c1_mono_processor_system 
		(a_system : in system) return Boolean;
   function check_c2_multiprocessor_system 
		(a_system : in system) return Boolean;
   function check_c3_partitionned_scheduling  
		(a_system : in system) return Boolean;
   function check_c4_global_scheduling 
		(a_system : in system) return Boolean;
   function check_c5_fixed_priority 
		(a_system : in system) return Boolean;
   function check_c6_edf_algorithm 
		(a_system : in system) return Boolean;
   function check_c7_rm_algorithm 
		(a_system : in system) return Boolean;
   function check_c8_dm_algorithm 
		(a_system : in system) return Boolean;
   function check_c9_preemptive_processor
		(a_system : in system) return Boolean;
   function check_c10_non_preemptive_processor
		(a_system : in system) return Boolean;
   function check_c11_preemptive_with_preemption_delay
		(a_system : in system) return Boolean;
   function check_c12_synchronous_release
		(a_system : in system) return Boolean;
   function check_c13_asynchronous_release
		(a_system : in system) return Boolean;
   function check_c14_tasks_are_periodic 
		(a_system : in system) return Boolean;
   function check_c15_tasks_are_sporadic 
		(a_system : in system) return Boolean;
   function check_c16_tasks_are_independent
		(a_system : in system) return Boolean;
   function check_c17_tasks_have_precedence_constraint
		(a_system : in system) return Boolean;
   function check_c18_tasks_have_shared_resources
		(a_system : in system) return Boolean;
   function check_c19_tasks_have_selfsuspension
		(a_system : in system) return Boolean;
   function check_c20_tasks_without_selfsuspension
		(a_system : in system) return Boolean;
   function check_c21_deadline_equal_period
        (a_system : in system) return Boolean;
   function check_c22_deadline_smaller_period
		(a_system : in system) return Boolean;
   function check_c23_deadline_greater_period
		(a_system : in system) return Boolean;
		
   ---------- Subprograms to statically verify each anomaly
   
   function check_static_task_execution_time_decrease
     (a_system : in system) return Boolean;
   function check_static_precedence_constraint_weak
     (a_system : in system) return Boolean;
   function check_static_processor_speed_increase
     (a_system : in system) return Boolean;
   function check_static_task_execution_time_delay
     (a_system : in system) return Boolean;	 
   function check_static_task_priority_increase
     (a_system : in system) return Boolean;
   function check_static_preemption_delay_decrease
     (a_system : in system) return Boolean;
   function check_static_task_deadline_increase
     (a_system : in system) return Boolean;
   function check_static_task_period_increase
     (a_system : in system) return Boolean;
   function check_static_processor_add 
	 (a_system : in system) return Boolean;
   function check_static_selfsuspension_decrease
     (a_system : in system) return Boolean;

   -- To measure execution time of the analysis
   --
   function print_duration_time_exec return String;

end scheduling_anomalies_services.offline;
