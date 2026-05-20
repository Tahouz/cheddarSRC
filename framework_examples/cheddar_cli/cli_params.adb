
with Parameters;
use Parameters;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
package body cli_params is



--tout initiliser à null
procedure initialize is 
begin 

   for K in PARAMS_KEYS loop
      cli_parameters(K):=null;
   end loop;

end initialize;

--returns value of a Parameter if passed through the cli else returns null
function getValue(param_key:PARAMS_KEYS) return Parameter_Ptr
is 
begin
   return cli_parameters(param_key);
end getValue;

function To_Unbounded (Key : PARAMS_KEYS) return Unbounded_String is
begin
   case Key is

      when preemption =>
         return To_Unbounded_String("preemption");

      when wait_for_memory =>
         return To_Unbounded_String("wait_for_memory");

      when buffer_overflow =>
         return To_Unbounded_String("buffer_overflow");

      when buffer_underflow =>
         return To_Unbounded_String("buffer_underflow");

      when period =>
         return To_Unbounded_String("period");

      when seed_value =>
         return To_Unbounded_String("seed_value");

      when schedule_with_offsets =>
         return To_Unbounded_String("schedule_with_offsets");

      when schedule_with_precedencies =>
         return To_Unbounded_String("schedule_with_precedencies");

      when schedule_with_resources =>
         return To_Unbounded_String("schedule_with_resources");

      when minimize_preemption =>
         return To_Unbounded_String ("minimize_preemption");

      when schedule_with_jitters =>
         return To_Unbounded_String("schedule_with_jitters");

      when predictable =>
         return To_Unbounded_String("predictable");

      when start_of_task_capacity =>
         return To_Unbounded_String("start_of_task_capacity");

      when end_of_task_capacity =>
         return To_Unbounded_String("end_of_task_capacity");

      when write_to_buffer =>
         return To_Unbounded_String("write_to_buffer");

      when read_from_buffer =>
         return To_Unbounded_String("read_from_buffer");

      when running_task =>
         return To_Unbounded_String("running_task");

      when task_activation =>
         return To_Unbounded_String("task_activation");

      when send_message =>
         return To_Unbounded_String("send_message");

      when receive_message =>
         return To_Unbounded_String("receive_message");

      when allocate_resource =>
         return To_Unbounded_String("allocate_resource");

      when release_resource =>
         return To_Unbounded_String("release_resource");

      when wait_for_resource =>
         return To_Unbounded_String("wait_for_resource");

      when discard_missed_deadline =>
         return To_Unbounded_String("discard_missed_deadline");

      when address_space_activation =>
         return To_Unbounded_String("address_space_activation");

      when context_switch_overhead =>
         return To_Unbounded_String("context_switch_overhead");

      when schedule_with_task_groups =>
         return To_Unbounded_String("schedule_with_task_groups");

      when anomaly_detection =>
         return To_Unbounded_String("anomaly_detection");
      when task_specific_seed =>
         return To_Unbounded_String("task_specific_seed");
      when dvfs =>
         return To_Unbounded_String("dvfs");

      when mode_change =>
         return To_Unbounded_String("mode_change");

      when tdma_slot =>
         return To_Unbounded_String("tdma_slot");

      when energy =>
         return To_Unbounded_String("energy");

      when schedule_with_crpd =>
         return To_Unbounded_String("schedule_with_crpd");

      when schedule_with_discard_missed_deadlines =>
         return To_Unbounded_String("schedule_with_discard_missed_deadlines");

      when wcrt_with_crpd =>
         return To_Unbounded_String("wcrt_with_crpd");

      when wcrt_with_memory_interferences =>
         return To_Unbounded_String("wcrt_with_memory_interferences");

      when feasibility_test_name =>
         return To_Unbounded_String("feasibility_test_name");

      when r_worst_case | b_worst_case =>
         return To_Unbounded_String("worst_case");

      when r_best_case | b_best_case =>
         return To_Unbounded_String("best_case");

      when r_average_case | b_average_case =>
         return To_Unbounded_String("average_case");

   end case;
end To_Unbounded;

procedure Add_Bool(Key : PARAMS_KEYS; Val : Boolean)
is 
A_Param:Parameter_Ptr:=new Parameter(Boolean_Parameter);
begin 
A_Param.boolean_value:=Val;
A_Param.parameter_name:=To_Unbounded(Key);
cli_parameters(Key) := A_Param;
end Add_Bool;



procedure Add_Int(Key : PARAMS_KEYS; Val : Integer)is 
A_Param:Parameter_Ptr:=new Parameter(integer_parameter);
begin 
A_Param.integer_value:=Val;
A_Param.parameter_name:=To_Unbounded(Key);
cli_parameters(Key) := A_Param;
end Add_Int;



procedure Add_Str(Key : PARAMS_KEYS; Val : unbounded_string)is 
A_Param:Parameter_Ptr:=new Parameter(string_Parameter);
begin 
A_Param.string_value:=Val;
A_Param.parameter_name:=To_Unbounded(Key);
cli_parameters(Key) := A_Param;
end Add_Str;







end cli_params;