with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
with Processors;
use Processors;
with task_set;
with xml_tags;
with xml_tag_with_id;
with Call_Framework_Interface;
use Call_Framework_Interface;
with systems;
use systems;
with tasks ;
use tasks;
package xml_encoder is
package Responses_Wrapper is new xml_tags(Tag_Name => To_Unbounded_String("responses"));
package Response_Wrapper is new xml_tag_with_id(Tag_Name => To_Unbounded_String("response") ,    Id_Name => To_Unbounded_String("statement"));
package Processor_Wrapper is new xml_tag_with_id(Tag_Name => To_Unbounded_String("processor") ,Id_Name => To_Unbounded_String("name"));
package Priority_Wrapper is new xml_tag_with_id(Tag_Name => To_Unbounded_String("priority" ), Id_Name => To_Unbounded_String("task"));
package Placement_Wrapper is new xml_tag_with_id(Tag_Name => To_Unbounded_String("placement" ), Id_Name => To_Unbounded_String("task"));
package scheduling_period_wrapper is new xml_tags(Tag_Name => To_Unbounded_String("scheduling_period"));
package unused_period_wrapper is new xml_tags(Tag_Name => To_Unbounded_String("unused"));
package utilization_over_deadline_wrapper is new xml_tags(Tag_Name => To_Unbounded_String("utilization_over_deadline"));

package utilization_over_period_wrapper is new xml_tags(Tag_Name => To_Unbounded_String("utilization_over_period"));

package cores_wrapper is new xml_tags(Tag_Name => To_Unbounded_String("cores"));

package core_Wrapper is new xml_tag_with_id(Tag_Name => To_Unbounded_String("core") ,Id_Name => To_Unbounded_String("name"));

package wcrts_wrapper is new xml_tags(Tag_Name => To_Unbounded_String("wcrts"));
package wcrt_Wrapper is new xml_tag_with_id(Tag_Name => To_Unbounded_String("wcrt" ), Id_Name => To_Unbounded_String("task"));

procedure wrap_cores(Content :in out Unbounded_String) ;

procedure wrap_wcrt(Content : in out Unbounded_String ; task_name : Unbounded_String  );
procedure wrap_wcrts(Content : in out Unbounded_String  );

procedure wrap_responses (Content :in out Unbounded_String) ;

procedure wrap_processor (Content : in out Unbounded_String ; a_processor : generic_processor_ptr) ;

procedure wrap_scheduling_period (Content : in out Unbounded_String);

procedure wrap_unused_period (Content : in out Unbounded_String);

procedure wrap_utilization_over_deadline(Content : in out Unbounded_String);

procedure wrap_utilization_over_period(Content : in out Unbounded_String);

procedure wrap_response(Content : in out Unbounded_String ; a_statement : Call_Framework_Interface.Framework_Statement_Type);

function priority_xml(sys : in Systems.system ;a_processor : in generic_processor_ptr) return Unbounded_String ;

function partioning_xml(sys : in Systems.system) return Unbounded_String ;


end xml_encoder;