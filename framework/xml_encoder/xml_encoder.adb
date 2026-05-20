with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
with Processors;
use Processors;
with Call_Framework_Interface;
use Call_Framework_Interface;
with Systems;
use Systems;
with Tasks;
use Tasks;
with task_set;
use task_set;
with unbounded_strings;
use unbounded_strings;
with processor_set;
with processor_interface;
use processor_interface;
use processor_set;
with translate;                       
use translate;
package body  xml_encoder is


procedure wrap_responses (Content :in out Unbounded_String) is
begin
   Responses_Wrapper.wrapContent(Content);
end wrap_responses;

procedure wrap_processor (Content : in out Unbounded_String ; a_processor : generic_processor_ptr) is
begin
   Processor_Wrapper.wrapContent_withID(Content,a_processor.name);
end;


procedure wrap_response(Content : in out Unbounded_String ; a_statement : Framework_Statement_Type) is 

begin
   Response_Wrapper.wrapContent_withID(Content,To_Unbounded_String(a_statement'Image));
end wrap_response;

function priority_xml(sys : in Systems.system ;a_processor : in generic_processor_ptr) return Unbounded_String is
result : Unbounded_String:= To_Unbounded_String("");
my_task_iterator      : tasks_iterator;
intermediate_priority : Unbounded_String := To_Unbounded_String ("");
begin
         reset_iterator (sys.tasks, my_task_iterator);
         loop
         declare 
         a_task                : generic_task_ptr; 
         
         begin
         current_element (sys.tasks, a_task, my_task_iterator);
         if (a_task.cpu_name = a_processor.name) then
            intermediate_priority :=To_Unbounded_String(a_task.priority'Image);
            Priority_Wrapper.wrapContent_withID(intermediate_priority,a_task.name);
            result :=
              result &
              lb_tab4 &
               intermediate_priority
               &
              unbounded_lf;
         end if;
         exit when is_last_element (sys.tasks, my_task_iterator);
         next_element (sys.tasks, my_task_iterator);
         end;
         end loop;
   return result;
end priority_xml;


function partioning_xml(sys : in Systems.system) return Unbounded_String is
result : Unbounded_String := empty_string;
my_task_iterator      : tasks_iterator;
begin
   reset_iterator (sys.tasks, my_task_iterator);
      loop
      declare
      intermediate_placement : Unbounded_String := To_Unbounded_String ("");
      a_processor			: generic_processor_ptr;
      a_task                : generic_task_ptr; 
      begin
         current_element (sys.tasks, a_task, my_task_iterator);

            -- use to match aadl inspector parsing (a core field can be added)
            a_processor := search_processor(sys.processors, a_task.cpu_name);
            if a_processor.processor_type = monocore_type then
               intermediate_placement := a_task.cpu_name;
            else
               intermediate_placement := a_task.core_name;
            end if;
            Placement_Wrapper.wrapContent_withID(intermediate_placement,a_task.name);
            
            result :=
              result &
              lb_tab4 &
               intermediate_placement
               &
              unbounded_lf;

         exit when is_last_element (sys.tasks, my_task_iterator);
         next_element (sys.tasks, my_task_iterator);
         end;
      end loop;

   return result;
end partioning_xml;


procedure wrap_scheduling_period (Content : in out Unbounded_String)
is
begin
scheduling_period_wrapper.wrapContent(Content);
end wrap_scheduling_period;
procedure wrap_unused_period (Content : in out Unbounded_String)
is
begin 
unused_period_wrapper.wrapContent(Content);
end wrap_unused_period;


procedure wrap_utilization_over_deadline(Content : in out Unbounded_String)
is
begin 
utilization_over_deadline_wrapper.wrapContent(Content);
end wrap_utilization_over_deadline;

procedure wrap_cores(Content :in out Unbounded_String)
is
begin
cores_wrapper.wrapContent(Content);
end wrap_cores;



procedure wrap_utilization_over_period(Content : in out Unbounded_String)
is
begin 
utilization_over_period_wrapper.wrapContent(Content);
end wrap_utilization_over_period;



procedure wrap_wcrt(Content : in out Unbounded_String ; task_name : Unbounded_String  )
is
begin

wcrt_Wrapper.wrapContent_withID(Content,task_name);

end wrap_wcrt;


procedure wrap_wcrts(Content : in out Unbounded_String  )
is
begin

wcrts_wrapper.wrapContent(Content);

end wrap_wcrts;


end xml_encoder;