with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
with Parameters ;
use Parameters;
with Call_Framework_Interface;
use Call_Framework_Interface;
package cli_params is
type PARAMS_KEYS is(
   --parameters for scheduling_simulation_time_line 
   preemption,
   wait_for_memory,
   buffer_overflow,
   buffer_underflow,
   period,
   seed_value,
   schedule_with_offsets,
   schedule_with_precedencies,
   schedule_with_resources,
   minimize_preemption,
   schedule_with_jitters,
   predictable,
   start_of_task_capacity,
   end_of_task_capacity,
   write_to_buffer,
   read_from_buffer,
   running_task,
   task_activation,
   send_message,
   receive_message,
   allocate_resource,
   release_resource,
   wait_for_resource,
   discard_missed_deadline,
   address_space_activation,
   context_switch_overhead,
   schedule_with_task_groups,
   anomaly_detection,
   task_specific_seed,
   dvfs,
   mode_change,
   tdma_slot,
   energy,
   schedule_with_crpd,
   schedule_with_discard_missed_deadlines,
   --compute_feasibility_response_time
   wcrt_with_crpd,
   wcrt_with_memory_interferences,
   -- compute_feasibility_test_by_name
   feasibility_test_name,
   --scheduling_simulation_response_time 
   r_worst_case,
   r_best_case,
   r_average_case,
   -- scheduling_simulation_blocking_time
   b_worst_case,
   b_best_case,
   b_average_case
);
type ClI_PARAM_LIST is array(PARAMS_KEYS) of Parameter_Ptr;

subtype simulation_time_line_range is PARAMS_KEYS range 
  preemption .. schedule_with_discard_missed_deadlines;
subtype feasibility_response_time_range is PARAMS_KEYS range 
  wcrt_with_crpd .. wcrt_with_memory_interferences;
  subtype feasibility_test_by_name_range is PARAMS_KEYS range 
  feasibility_test_name .. feasibility_test_name;
  subtype simulation_response_time_range is PARAMS_KEYS range 
  r_worst_case .. r_average_case;
  subtype simulation_blocking_time_range is PARAMS_KEYS range 
  b_worst_case .. b_average_case;


cli_parameters:ClI_PARAM_LIST;

--tout initiliser à null
procedure initialize ;

--returns value of a Parameter if passed through the cli else returns null
function getValue(param_key:PARAMS_KEYS) return Parameter_Ptr;

procedure Add_Bool(Key : PARAMS_KEYS; Val : Boolean);
procedure Add_Int(Key : PARAMS_KEYS; Val : Integer);
procedure Add_Str(Key : PARAMS_KEYS; Val : Unbounded_String);


end cli_params;