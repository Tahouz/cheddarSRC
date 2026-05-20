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

package scheduling_anomalies_services.online is

-----------------------------------------
--       Runtime verification
-----------------------------------------

-- This data stucture is returned after runtime analysis
-- with the detected anomaly and the associated data
--
   type handler_output_parameter is record

      -- The type of the potential anomalie we found
      --
      detected_anomaly : potential_anomaly_type;

      -- Give the name of the Cheddar object that create the anomaly
      --
      object_name : Unbounded_String;

   end record;

-- This data structure contains the data provided by the
-- Cheddar scheduling simulator or the RTOS to perform
-- the runtime verification
--
   type handler_input_parameter is record
      -- Event produced by the RTOS or the Cheddar simulator
      -- that requires runtime verification
      --
      event : time_unit_event_ptr;

      -- Simulation or RTOS data
      --
      runtime_data : scheduling_information;

      -- Time at which the event is generated
      --
      current_time : Natural;

   end record;

   -- Subprogram called before scheduling simulation
   -- to provide the architecture model before simulation
   --
   procedure scheduling_anomaly_register (model : in system);

-- This subprogram is called by the OS or Cheddar to verify
-- at any time if an anomaly will occur
--
   procedure scheduling_anomaly_handler
     (inp               : in     handler_input_parameter;
      current_scheduler : in     generic_scheduler'class;
      outp              :    out handler_output_parameter);

-- Subprograms constituting the implementation
-- of the handler
--
   procedure check_dynamic_processor_speed_increase
     (inp               : in     handler_input_parameter;
      current_scheduler : in     generic_scheduler'class;
      outp              :    out handler_output_parameter);

   procedure check_dynamic_processor_add
     (inp  : in     handler_input_parameter;
      outp :    out handler_output_parameter);

   procedure check_dynamic_task_execution_time_decrease
     (inp  : in     handler_input_parameter;
      outp :    out handler_output_parameter);

   procedure check_dynamic_task_period_increase
     (inp  : in     handler_input_parameter;
      outp :    out handler_output_parameter);

   procedure check_dynamic_task_late_execution
     (inp  : in     handler_input_parameter;
      outp :    out handler_output_parameter);

   procedure check_dynamic_task_priority_change
     (inp  : in     handler_input_parameter;
      outp :    out handler_output_parameter);

   procedure check_dynamic_precedence_constraint_change
     (inp  : in     handler_input_parameter;
      outp :    out handler_output_parameter);

end scheduling_anomalies_services.online;
