with systems; use systems;

package mosar_transformation is

-- Remove processor with have channel address space
-- Add dummy processors
--
   procedure produce_processors (in_model : in system; out_model : out system);

-- Add spacewire network
--
   procedure produce_networks (in_model : in system; out_model : out system);

-- Remove address space with channel
--
   procedure produce_address_spaces
     (in_model  : in     system;
      out_model :    out system);

-- Remove tasks with channel
-- Remove tasks on ground processor
--
   procedure produce_tasks (in_model : in system; out_model : out system);

-- Create messages from buffer. Do not use buffer on a ground/channel processor
-- or that have a task on a ground/channel processor
-- Messages parameters are computed from the emitter task
--
   procedure produce_messages (in_model : in system; out_model : out system);

-- Keep only precedence dependencies not on "channel"
-- entities
--
   procedure produce_dependencies
     (in_model  : in     system;
      out_model : in out system);

-- Remove tasks with channel
--
   procedure produce_resources (in_model : in system; out_model : out system);

-- Do not produce buffer entities
--
   procedure produce_buffers (in_model : in system; out_model : out system);

end mosar_transformation;
