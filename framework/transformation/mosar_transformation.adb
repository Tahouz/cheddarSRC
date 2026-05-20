with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
with Processors;            use Processors;
with processor_set;         use processor_set;
with Core_Units;            use Core_Units;
with Address_Spaces;        use Address_Spaces;
with address_space_set;     use address_space_set;
with Tasks;                 use Tasks;
with task_set;              use task_set;
with Memories;              use Memories;
use Memories.Memories_Table_Package;
with Networks;    use Networks;
with Networks;    use Networks.Positions_Table_Package;
with Networks;
with network_set; use network_set;
with Messages;    use Messages;
with message_set; use message_set;
with Buffers;     use Buffers;
use Buffers.Buffer_Roles_Package;
with buffer_set;        use buffer_set;
with Dependencies;      use Dependencies;
with task_dependencies; use task_dependencies;
use task_dependencies.half_dep_set;
with Parameters;          use Parameters;
with Parameters.extended; use Parameters.extended;
with Resources;           use Resources;
use Resources.Resource_Accesses;
with resource_set;        use resource_set;
with Scheduler_Interface; use Scheduler_Interface;
with debug;               use debug;

package body mosar_transformation is

   function compute_worst_case_link_delay
     (in_model : in system) return Integer
   is

      link_delay       : Integer := 0;
      my_task_iterator : tasks_iterator;
      my_task          : generic_task_ptr;

   begin
      put_debug ("compute_worst_case_link_delay");

      reset_iterator (in_model.tasks, my_task_iterator);
      loop
         current_element (in_model.tasks, my_task, my_task_iterator);

         if (Count (my_task.name, "channel") > 0) then
            link_delay := Integer'max (link_delay, my_task.capacity);
         end if;

         exit when is_last_element (in_model.tasks, my_task_iterator);

         next_element (in_model.tasks, my_task_iterator);

      end loop;

      return link_delay;
   end compute_worst_case_link_delay;

   function has_channel_address_space
     (in_model       : in system;
      processor_name :    Unbounded_String) return Boolean
   is

      my_address_space_iterator : address_spaces_iterator;
      my_address_space          : address_space_ptr;

   begin
      put_debug ("has_channel_address_space");
      reset_iterator (in_model.address_spaces, my_address_space_iterator);
      loop
         current_element
           (in_model.address_spaces,
            my_address_space,
            my_address_space_iterator);
         if (processor_name = my_address_space.cpu_name) and
           (Count (my_address_space.name, "channel") > 0)
         then
            return True;
         end if;

         exit when is_last_element
             (in_model.address_spaces,
              my_address_space_iterator);
         next_element (in_model.address_spaces, my_address_space_iterator);

      end loop;
      return False;
   end has_channel_address_space;

   procedure produce_processors
     (in_model  : in     system;
      out_model :    out system)
   is

      my_processor_iterator : processors_iterator;
      my_processor          : generic_processor_ptr;
      mem0                  : memories_table;
      my_core               : core_unit_ptr;

   begin
      put_debug ("produce_processors");

      -- Core and processors for the network modeling
      --
      initialize (mem0);
      add_core_unit
        (out_model.core_units,
         my_core,
         To_Unbounded_String ("dummy_core"),
         preemptive,
         0,
         1,
         0,
         0,
         0,
         empty_string,
         empty_string,
         posix_1003_highest_priority_first_protocol,
         mem0);
      add_processor
        (out_model.processors,
         To_Unbounded_String ("dummy1"),
         my_core);
      add_processor
        (out_model.processors,
         To_Unbounded_String ("dummy2"),
         my_core);
      add_processor
        (out_model.processors,
         To_Unbounded_String ("dummy3"),
         my_core);
      add_processor
        (out_model.processors,
         To_Unbounded_String ("dummy4"),
         my_core);

      -- Cores from the model
      --
      reset_iterator (in_model.processors, my_processor_iterator);
      loop
         current_element
           (in_model.processors,
            my_processor,
            my_processor_iterator);
         if not has_channel_address_space (in_model, my_processor.name) and
           (Count (my_processor.name, "ground") = 0)
         then
            add (out_model.processors, my_processor);
         end if;

         exit when is_last_element
             (in_model.processors,
              my_processor_iterator);

         next_element (in_model.processors, my_processor_iterator);

      end loop;

   end produce_processors;

   procedure produce_networks (in_model : in system; out_model : out system) is

      link_delay : Integer := 1;
      positions  : positions_table;
      item       : position;

   begin
      put_debug ("produce_networks");

      item.X := 0;
      item.Y := 0;
      add (positions, To_Unbounded_String ("dummy1"), item);

      item.X := 0;
      item.Y := 1;
      add (positions, To_Unbounded_String ("root.obc_x86_linux"), item);

      item.X := 0;
      item.Y := 2;
      add (positions, To_Unbounded_String ("dummy2"), item);

      item.X := 1;
      item.Y := 0;
      add (positions, To_Unbounded_String ("root.bat_x86_linux"), item);

      item.X := 1;
      item.Y := 1;
      add (positions, To_Unbounded_String ("root.r_icu_x86_linux"), item);

      item.X := 1;
      item.Y := 2;
      add (positions, To_Unbounded_String ("root.osp1_x86_linux"), item);

      item.X := 2;
      item.Y := 0;
      add (positions, To_Unbounded_String ("dummy3"), item);

      item.X := 2;
      item.Y := 1;
      add (positions, To_Unbounded_String ("root.osp2_x86_linux"), item);

      item.X := 2;
      item.Y := 2;
      add (positions, To_Unbounded_String ("dummy4"), item);

      link_delay := compute_worst_case_link_delay (in_model);

      add_network
        (out_model.networks,
         To_Unbounded_String ("spacewire1"),
         spacewire,
         mesh_topology,
         link_delay,
         9,
         3,
         3,
         3,
         0,
         bounded_delay,
         wormwole,
         xy,
         positions);

   end produce_networks;

   procedure produce_address_spaces
     (in_model  : in     system;
      out_model :    out system)
   is
      my_address_space_iterator : address_spaces_iterator;
      my_address_space          : address_space_ptr;

   begin
      put_debug ("produce_address_spaces");
      reset_iterator (in_model.address_spaces, my_address_space_iterator);
      loop
         current_element
           (in_model.address_spaces,
            my_address_space,
            my_address_space_iterator);
         if (Count (my_address_space.name, "channel") = 0) and
           (Count (my_address_space.name, "ground") = 0)
         then
            add (out_model.address_spaces, my_address_space);
         end if;

         exit when is_last_element
             (in_model.address_spaces,
              my_address_space_iterator);

         next_element (in_model.address_spaces, my_address_space_iterator);

      end loop;

   end produce_address_spaces;

   procedure produce_tasks (in_model : in system; out_model : out system) is
      my_task_iterator : tasks_iterator;
      my_task          : generic_task_ptr;

   begin
      put_debug ("produce_tasks");
      reset_iterator (in_model.tasks, my_task_iterator);
      loop
         current_element (in_model.tasks, my_task, my_task_iterator);
         if (Count (my_task.cpu_name, "channel") = 0) and
           (Count (my_task.name, "channel") = 0) and
           (Count (my_task.cpu_name, "ground") = 0) and
           (Count (my_task.name, "ground") = 0)
         then
            add (out_model.tasks, my_task);
         end if;

         exit when is_last_element (in_model.tasks, my_task_iterator);

         next_element (in_model.tasks, my_task_iterator);

      end loop;

   end produce_tasks;

   procedure produce_messages (in_model : in system; out_model : out system) is

      my_iterator : buffers_iterator;
      a_buffer    : buffer_ptr;
      a_message   : generic_message_ptr;
      emitter     : generic_task_ptr;
      receiver    : generic_task_ptr;
      a_task      : generic_task_ptr;
      to_add      : Boolean := False;

   begin

      put_debug ("produce_messages");
      if not is_empty (in_model.buffers) then
         reset_iterator (in_model.buffers, my_iterator);
         loop
            current_element (in_model.buffers, a_buffer, my_iterator);

            -- Do not produce if ground or channel buffer
            --
            to_add := True;

            if (Count (a_buffer.cpu_name, "ground") > 0) then
               to_add := False;
            end if;
            if (Count (a_buffer.address_space_name, "channel") > 0) then
               to_add := False;
            end if;

            for i in 0 .. a_buffer.roles.nb_entries - 1 loop
               a_task :=
                 search_task (in_model.tasks, a_buffer.roles.entries (i).item);
               if (Count (a_task.cpu_name, "ground") > 0) then
                  to_add := False;
               end if;
               if (Count (a_task.cpu_name, "channel") > 0) then
                  to_add := False;
               end if;
            end loop;

            if to_add then
               -- Look for the consumer
               --
               for i in 0 .. a_buffer.roles.nb_entries - 1 loop
                  if a_buffer.roles.entries (i).data.the_role =
                    queuing_consumer
                  then
                     receiver :=
                       search_task
                         (in_model.tasks,
                          a_buffer.roles.entries (i).item);
                  end if;
               end loop;

               -- For each producer, generate a message and its dependencies
               --
               for i in 0 .. a_buffer.roles.nb_entries - 1 loop
                  if a_buffer.roles.entries (i).data.the_role =
                    queuing_producer
                  then

                     emitter :=
                       search_task
                         (in_model.tasks,
                          a_buffer.roles.entries (i).item);

                     -- Create message
                     --
                     add_message
                       (out_model.messages,
                        a_message,
                        emitter.name & "_to_" & receiver.name,
                        a_buffer.roles.entries (i).data.size,
                        periodic_task_ptr (emitter).period,
                        periodic_task_ptr (emitter).period,
                        0,
                        no_user_defined_parameter,
                        0,
                        0);

                     add_one_task_dependency_asynchronous_communication
                       (my_dependencies   => out_model.dependencies,
                        a_task            => emitter,
                        a_dep             => a_message,
                        a_type            => from_task_to_object,
                        protocol_property => first_message);

                     add_one_task_dependency_asynchronous_communication
                       (my_dependencies   => out_model.dependencies,
                        a_task            => receiver,
                        a_dep             => a_message,
                        a_type            => from_object_to_task,
                        protocol_property => first_message);

                  end if;
               end loop;
            end if;

            exit when is_last_element (in_model.buffers, my_iterator);

            next_element (in_model.buffers, my_iterator);

         end loop;

      end if;

   end produce_messages;

   procedure produce_dependencies
     (in_model  : in     system;
      out_model : in out system)
   is

      my_iterator    : tasks_dependencies_iterator;
      a_half_dep_ptr : dependency_ptr;
      to_add         : Boolean := False;
      task_source    : generic_task_ptr;
      task_sink      : generic_task_ptr;

   begin
      put_debug ("produce_dependencies");
   end produce_dependencies;

   procedure produce_resources
     (in_model  : in     system;
      out_model :    out system)
   is

      my_resource_iterator : resources_iterator;
      my_resource          : generic_resource_ptr;
      to_add               : Boolean := True;
      a_task               : generic_task_ptr;

   begin

      put_debug ("produce_resources");
      reset_iterator (in_model.resources, my_resource_iterator);
      loop
         current_element
           (in_model.resources,
            my_resource,
            my_resource_iterator);

         to_add := True;

         if (Count (my_resource.address_space_name, "channel") > 0) then
            to_add := False;
         end if;
         if (Count (my_resource.address_space_name, "ground") > 0) then
            to_add := False;
         end if;

         for i in 0 .. my_resource.critical_sections.nb_entries - 1 loop
            a_task :=
              search_task
                (in_model.tasks,
                 my_resource.critical_sections.entries (i).item);
            if (Count (a_task.address_space_name, "channel") > 0) then
               to_add := False;
            end if;
            if (Count (a_task.address_space_name, "ground") > 0) then
               to_add := False;
            end if;
         end loop;

         if to_add then
            add (out_model.resources, my_resource);
         end if;

         exit when is_last_element (in_model.resources, my_resource_iterator);

         next_element (in_model.resources, my_resource_iterator);

      end loop;

   end produce_resources;

   procedure produce_buffers (in_model : in system; out_model : out system) is
   begin
      put_debug ("produce_buffers");
   end produce_buffers;

end mosar_transformation;
