with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Command_Line;      use Ada.Command_Line;
with Ada.Strings.Fixed;     use Ada.Strings.Fixed;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with GNAT.OS_Lib;

with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

with Objects;  use Objects;
with Memories; use Memories;
use Memories.Memories_Table_Package;
with Memory_set;        use Memory_set;
with Tasks;             use Tasks;
with Task_Set;          use Task_Set;
with Systems;           use Systems;
with Processors;        use Processors;
with Processor_Set;     use Processor_Set;
with Address_Spaces;    use Address_Spaces;
with Address_Space_Set; use Address_Space_Set;
with Buffers;           use Buffers;
with Buffer_set;        use Buffer_set;
use Buffers.Buffer_Roles_Package;
with Queueing_Systems; use Queueing_Systems;
with Core_Units;       use Core_Units;
use Core_Units.Core_Units_Table_Package;
with batteries;           use batteries;
with battery_set;         use battery_set;
with Processor_Interface; use Processor_Interface;
with Scheduler_Interface; use Scheduler_Interface;

with Random_Tools;         use Random_Tools;
with architecture_factory; use architecture_factory;
with unbounded_strings;    use unbounded_strings;
with call_framework;       use call_framework;
with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;
with doubles;                use doubles;
with priority_assignment.rm; use priority_assignment.rm;
with Ada.Numerics;
with Ada.Numerics.Float_Random;

with Buffers;          use Buffers;
with Buffer_Set;       use Buffer_Set;
with Queueing_Systems; use Queueing_Systems;
with Buffer_Set;
use Buffers.Buffer_Roles_Package;
with Dependencies;      use Dependencies;
with task_dependencies; use task_dependencies;

with framework_config; use framework_config;

procedure Generate_amp_icq_multicore is

   sys               : System;
   a_core            : Core_Unit_Ptr;
   a_processor       : Generic_Processor_Ptr;
   a_core_unit_table : Core_Units_Table;
   my_tasks          : tasks_set;

   nb_receiver            : Integer;
   nb_sender_per_receiver : Integer;
   post_delay             : Integer;
   dispatchers_period     : Integer;

   cpu_rate : Integer;
   msg_freq : Integer;

   placement_mode  : Unbounded_String;
   cpu_frequencies : Unbounded_String;

   root_dispatcher : Generic_task_ptr;

   processor_name : Unbounded_String := To_Unbounded_String ("processor1");

   receiver_core_name : Unbounded_String := To_Unbounded_String ("core0");

   nb_cores	     : Natural := Integer'Value (Argument (6));
   locking_order     : Unbounded_String;
   sender_period     : Integer;

   type Period_array is array (1 .. 40) of Natural;
   period_tabs : Period_array :=
     (100, 150, 150, 200, 150, 200, 200, 250, 300, 250, 300, 300, 300, 300,
      400, 400, 400, 600, 600, 800, 800, 800, 800, 1_000, 800, 1_000, 1_000,
      1_000, 1_200, 1_000, 2_000, 2_000, 2_000, 2_400, 2_400, 2_400, 2_400,
      6_000, 6_000, 6_000);
      
   type Cpu_Frequencies_Array is array (0 .. nb_cores-1) of Natural;
   cpu_frequencies_tab : Cpu_Frequencies_Array;

begin

   -- Vérifie qu'un argument a été passé
   if Argument_Count < 9 then
      Put ("Usage: " & Command_Name & " ");
      Put_Line
        ("file_path nb_receiver nb_sender_per_receiver post_delay dispatchers_period core_available_number locking_order_protocol emitter_same_priority placement_mode system_cheddar_file(optionnal)");
      GNAT.OS_Lib.OS_Exit (1);
   end if;

   nb_receiver            := Integer'Value (Argument (2));
   nb_sender_per_receiver := Integer'Value (Argument (3));
   post_delay             := Integer'Value (Argument (4));
   dispatchers_period     := Integer'Value (Argument (5));
   nb_cores		   := Integer'Value (Argument (6));
   locking_order          := To_Unbounded_String (Argument (7));
   sender_period          := Integer'Value (Argument (8));
   msg_freq               := Integer'Value (Argument (9));
   cpu_rate               := Integer'Value (Argument (10));
   
   declare
   	j,i : Integer := 0;
   	cpu_frequencies : String := Argument (11);
   	
   	current_start : Integer := cpu_frequencies'First;
   	separator_ind : Natural;
   begin 
   	
   	
   	
      for i in 1 .. cpu_frequencies'Length loop

         if cpu_frequencies(i) = ',' then
         
         	separator_ind := i - current_start;

         	cpu_frequencies_tab(j) := Integer'Value(cpu_frequencies (current_start .. current_start + separator_ind - 1));
         	
         	current_start := current_start + separator_ind + 1;
         
         	j := j + 1;
         end if;
         
      end loop;

      cpu_frequencies_tab(j) := Integer'Value(cpu_frequencies (current_start .. cpu_frequencies'Length));
   end;

   placement_mode := To_Unbounded_String (Argument (12));

   Call_Framework.initialize (False);

   if Argument_Count = 13 then
      read_from_xml_file (sys, Argument (13));

   else
      Initialize (sys);

      for i in 0 .. nb_cores - 1 loop
         Add_core_unit
           (sys.Core_units, a_core,
            To_Unbounded_String ("core") & Trim (i'Image, Ada.Strings.Left),
            preemptive, 0, cpu_frequencies_tab(i), 0, 0, 0, To_Unbounded_String (""),
            To_Unbounded_String (""),
            Posix_1003_Highest_Priority_First_Protocol, no_memories,
            empty_string, empty_string, 0, 0);
         Add (a_core_unit_table, a_core);
      end loop;

      Add_Processor
        (my_processors    => sys.Processors, a_processor => a_processor,
         name             => processor_name, cores => A_Core_Unit_Table,
         a_migration      => No_Migration_Type,
         a_processor_type => IDENTICAL_MULTICORES_TYPE);

      Add_Address_Space
        (sys.Address_Spaces, processor_name & To_Unbounded_String ("_addr"),
         processor_name, 0, 0, 0, 0);

   end if;

   declare

      receiver_name     : Unbounded_String;
      receiver_capacity : Natural;
      dispatcher_name   : Unbounded_String;

      the_core_name : Unbounded_String;

      u_values : random_tools.float_array (0 .. nb_receiver - 1);

      cpu_rate_targeted : Natural := 1;
   begin

      -- Generate U values
      u_values :=
        gen_uunifast_with_limited_utilization
          (nb_receiver, Float (cpu_rate_targeted));

      for i in 0 .. nb_receiver - 1 loop

         receiver_name :=
           To_Unbounded_String ("r") & Trim (i'Image, Ada.Strings.Left);
         dispatcher_name :=
           To_Unbounded_String ("disp") & receiver_core_name & receiver_name;

         if sender_period < 0 then
            receiver_capacity := Integer (u_values (i));
         else
            receiver_capacity := 1;
         end if;

         if receiver_capacity < 1 then
            receiver_capacity := 1;
         end if;

         if not task_is_present
             (sys.tasks,
              To_Unbounded_String ("r") & Trim (i'Image, Ada.Strings.Left))
         then

            the_core_name := receiver_core_name;

            Add_Task
              (my_tasks           => sys.Tasks, name => receiver_name,
               cpu_name           => processor_name,
               address_space_name =>
                 processor_name & To_Unbounded_String ("_addr"),
               core_name   => the_core_name, task_type => Sporadic_Type,
               start_time  => 0, capacity => receiver_capacity,
               period => dispatchers_period, deadline => dispatchers_period,
               jitter      => 0, blocking_time => 0, priority => 5 + i,
               criticality => 0, policy => sched_fifo);

            if not task_is_present (sys.tasks, dispatcher_name) then

               declare

                  dispatcher_task : Generic_task_ptr;

                  my_tasks_leaf    : Tasks_set;
                  a_task_leaf      : Generic_task_ptr;
                  my_iterator_leaf : Tasks_iterator;

                  dispatcher_task_leaf : Generic_task_ptr;

               begin
                  Add_Task
                    (my_tasks => sys.Tasks, a_task => dispatcher_task,
                     name => dispatcher_name, cpu_name => processor_name,
                     address_space_name =>
                       processor_name & To_Unbounded_String ("_addr"),
                     core_name  => the_core_name, task_type => Periodic_Type,
                     start_time => 0,
                     capacity   =>
                       1,                                                --A préciser
                     period        => dispatchers_period,
                     deadline      => dispatchers_period, jitter => 0,
                     blocking_time => 0, priority => 1, criticality => 0,
                     policy        => sched_fifo);

                  my_tasks_leaf := get_leaf_tasks (sys.Dependencies);

                  if not is_empty (my_tasks_leaf) then

                     reset_iterator (my_tasks_leaf, my_iterator_leaf);
                     loop
                        current_element
                          (my_tasks_leaf, a_task_leaf, my_iterator_leaf);

                        if (To_String (a_task_leaf.name)'Length >= 4) then

                           if
                             (To_String (a_task_leaf.name) (1 .. 4) =
                              "disp" and
                              get
                                  (my_tasks_leaf, a_task_leaf.name,
                                   core_name) =
                                the_core_name)
                           then
                              dispatcher_task_leaf := a_task_leaf;
                           end if;

                        end if;

                        exit when is_last_element
                            (my_tasks_leaf, my_iterator_leaf);
                        next_element (my_tasks_leaf, my_iterator_leaf);
                     end loop;

                     add_one_task_dependency_precedence
                       (my_dependencies => sys.Dependencies,
                        source          => dispatcher_task_leaf,
                        sink            => dispatcher_task);

                  elsif root_dispatcher /= null then

                     add_one_task_dependency_precedence
                       (my_dependencies => sys.Dependencies,
                        source => root_dispatcher, sink => dispatcher_task);

                  else

                     root_dispatcher := dispatcher_task;

                  end if;
               end;
            end if;
         else

            set
              (my_tasks   => sys.Tasks, task_name => dispatcher_name,
               param_name => period, param_value => dispatchers_period);

            set
              (my_tasks   => sys.Tasks, task_name => dispatcher_name,
               param_name => deadline, param_value => dispatchers_period);

         end if;
      end loop;
   end;

   declare

      nb_task_core1 : Integer := 0;
      nb_task_core2 : Integer := 0;
      nb_task_core3 : Integer := 0;

      nb_task_core123 : Integer := 0;
      
      nb_emitter_cores : Natural := nb_cores-1;

   begin

      if placement_mode = "AllOnOne" or nb_emitter_cores = 1 then
         nb_task_core1 :=
           Integer
             (Float'Ceiling
                (Float (nb_receiver) * Float (nb_sender_per_receiver)));
         nb_task_core2 := 0;
         nb_task_core3 := 0;
      elsif placement_mode = "Uniform" then
         nb_task_core1 :=
           Integer
             (Float'Ceiling
                (Float (nb_receiver) * Float (nb_sender_per_receiver) /
                 Float (nb_emitter_cores)));
         nb_task_core2 :=
           Integer
             (Float'Ceiling
                (Float (nb_receiver) * Float (nb_sender_per_receiver) /
                 Float (nb_emitter_cores)));
         nb_task_core3 :=
           Integer
             (Float'Ceiling
                (Float (nb_receiver) * Float (nb_sender_per_receiver) /
                 Float (nb_emitter_cores)));
      elsif placement_mode = "NonUniformPartition" then
         nb_task_core1 :=
           Integer
             (Float'Ceiling
                (Float (nb_receiver) * Float (nb_sender_per_receiver) /
                 Float (nb_emitter_cores)) *
              2.0);
         nb_task_core2 :=
           Integer
             (Float'Ceiling
                (Float (nb_receiver) * Float (nb_sender_per_receiver) /
                 Float (nb_emitter_cores)));
         nb_task_core3 := 0;
      else
         --reset(seed);
         --core_placement := get_rand_parameter(1, 3, seed);
         Put_Line ("Core Placement not defined");
         GNAT.OS_Lib.OS_Exit (1);
      end if;

      nb_task_core123 := nb_task_core1 + nb_task_core2 + nb_task_core3;

      declare
         core_placement : Natural;
         seed           : Ada.Numerics.Float_Random.Generator;

         u_values_core1       : random_tools.float_array (1 .. nb_task_core1);
         u_values_core1_index : Natural := 0;
         u_values_core2       : random_tools.float_array (1 .. nb_task_core2);
         u_values_core2_index : Natural := 0;
         u_values_core3       : random_tools.float_array (1 .. nb_task_core3);
         u_values_core3_index : Natural := 0;

         task_id         : Natural;
         task_name       : Unbounded_String;
         task_capacity   : Natural;
         task_priority   : Natural;
         task_period     : Natural;
         receiver_name   : Unbounded_String;
         dispatcher_name : Unbounded_String;

         ID : Natural := 0;

         cpu_rate_targeted : Natural := cpu_rate;

      begin

         if placement_mode = "AllOnOne" or nb_emitter_cores = 1 then
            u_values_core1 :=
              gen_uunifast_with_limited_utilization
                (nb_task_core1, Float (cpu_rate_targeted));
         elsif placement_mode = "Uniform" then
            u_values_core1 :=
              gen_uunifast_with_limited_utilization
                (nb_task_core1, Float (cpu_rate_targeted));
            u_values_core2 :=
              gen_uunifast_with_limited_utilization
                (nb_task_core2, Float (cpu_rate_targeted));
            u_values_core3 :=
              gen_uunifast_with_limited_utilization
                (nb_task_core3, Float (cpu_rate_targeted));
         elsif placement_mode = "NonUniformPartition" then
            u_values_core1 :=
              gen_uunifast_with_limited_utilization
                (nb_task_core1, Float (cpu_rate_targeted));
            u_values_core2 :=
              gen_uunifast_with_limited_utilization
                (nb_task_core2, Float (cpu_rate_targeted));
         else
            --reset(seed);
            --core_placement := get_rand_parameter(1, 3, seed);
            Put_Line ("Core Placement not defined");
            GNAT.OS_Lib.OS_Exit (1);
         end if;

         for j in 0 .. nb_sender_per_receiver - 1 loop
            for i in 0 .. nb_receiver - 1 loop
               if placement_mode = "AllOnOne" or nb_emitter_cores = 1 then
                  core_placement := 1;
               elsif placement_mode = "Uniform" then
                  core_placement :=
                    ((j + (i * nb_sender_per_receiver)) mod
                     nb_emitter_cores) +
                    1;
               elsif placement_mode = "NonUniformPartition" then
                  if (j + 1 + (i * nb_sender_per_receiver)) mod
                    nb_emitter_cores =
                    0 and
                    nb_emitter_cores > 1
                  then
                     core_placement := 2;
                  else
                     core_placement := 1;
                  end if;

               else
                  Put_Line ("Core Placement mode not defined");
               end if;

               if locking_order = "HPF" then

                  if core_placement = 1 then
                     u_values_core1_index := u_values_core1_index + 1;
                     task_period          :=
                       period_tabs
                         ((u_values_core1_index + u_values_core2_index +
                           u_values_core3_index) *
                          (40 / nb_task_core123));
                     task_capacity :=
                       Integer
                         ((Integer (u_values_core1 (u_values_core1_index)) *
                           task_period) /
                          100);
                  elsif core_placement = 2 then
                     u_values_core2_index := u_values_core2_index + 1;
                     task_period          :=
                       period_tabs
                         ((u_values_core1_index + u_values_core2_index +
                           u_values_core3_index) *
                          (40 / nb_task_core123));
                     task_capacity :=
                       Integer
                         ((Integer (u_values_core2 (u_values_core2_index)) *
                           task_period) /
                          100);
                  elsif core_placement = 3 then
                     u_values_core3_index := u_values_core3_index + 1;
                     task_period          :=
                       period_tabs
                         ((u_values_core1_index + u_values_core2_index +
                           u_values_core3_index) *
                          (40 / nb_task_core123));
                     task_capacity :=
                       Integer
                         ((Integer (u_values_core3 (u_values_core3_index)) *
                           task_period) /
                          100);
                  end if;

                  if task_capacity < post_delay then
                     task_capacity := task_capacity + post_delay;
                  end if;

                  task_id       := ID + 1;
                  task_priority := ID + 5;
                  ID            := ID + 1;

               elsif locking_order = "LPF" then

                  if core_placement = 1 then
                     u_values_core1_index := u_values_core1_index + 1;
                     task_period          :=
                       period_tabs
                         (41 -
                          ((u_values_core1_index + u_values_core2_index +
                            u_values_core3_index) *
                           (40 / nb_task_core123)));
                     task_capacity :=
                       Integer
                         ((Integer (u_values_core1 (u_values_core1_index)) *
                           task_period) /
                          100);
                  elsif core_placement = 2 then
                     u_values_core2_index := u_values_core2_index + 1;
                     task_period          :=
                       period_tabs
                         (41 -
                          ((u_values_core1_index + u_values_core2_index +
                            u_values_core3_index) *
                           (40 / nb_task_core123)));
                     task_capacity :=
                       Integer
                         ((Integer (u_values_core2 (u_values_core2_index)) *
                           task_period) /
                          100);
                  elsif core_placement = 3 then
                     u_values_core3_index := u_values_core3_index + 1;
                     task_period          :=
                       period_tabs
                         (41 -
                          ((u_values_core1_index + u_values_core2_index +
                            u_values_core3_index) *
                           (40 / nb_task_core123)));
                     task_capacity :=
                       Integer
                         ((Integer (u_values_core3 (u_values_core3_index)) *
                           task_period) /
                          100);
                  end if;

                  if task_capacity < post_delay then
                     task_capacity := task_capacity + post_delay;
                  end if;

                  task_id       := (nb_sender_per_receiver * nb_receiver) - ID;
                  task_priority := 100 - (ID + 5);
                  ID            := ID + 1;

               end if;

               task_name :=
                 To_Unbounded_String ("e") &
                 Trim (task_id'Image, Ada.Strings.Left);
               receiver_name :=
                 To_Unbounded_String ("r") & Trim (i'Image, Ada.Strings.Left);
               dispatcher_name :=
                 To_Unbounded_String ("disp") & receiver_core_name &
                 receiver_name;

               if sender_period > 0 then
                  task_period   := sender_period;
                  task_capacity := 1 + post_delay;
               end if;

               if not task_is_present (sys.tasks, task_name) then

                  Add_Task
                    (my_tasks           => sys.Tasks, name => task_name,
                     cpu_name           => processor_name,
                     address_space_name =>
                       processor_name & To_Unbounded_String ("_addr"),
                     core_name =>
                       To_Unbounded_String ("core") &
                       Trim (core_placement'Image, Ada.Strings.Left),
                     task_type => Periodic_Type, start_time => 0,
                     capacity  => task_capacity, period => task_period,
                     deadline  => task_period, jitter => 0, blocking_time => 0,
                     priority  => task_priority, criticality => 0,
                     policy    => sched_fifo);

                  declare
                     a_buffer_table : Buffer_Roles_Table;
                     a_buffer_role  : Buffer_Role;
                  begin

                     a_buffer_role.the_role := ICQ_Producer;
                     a_buffer_role.size     := post_delay;
                     a_buffer_role.time     := 1;
                     a_buffer_role.timeout  := 1;
                     add (a_buffer_table, task_name, a_buffer_role);

                     a_buffer_role.the_role := ICQ_Consumer;
                     a_buffer_role.size     := post_delay;
                     a_buffer_role.time     := 1;
                     a_buffer_role.timeout  := 1;
                     add (a_buffer_table, dispatcher_name, a_buffer_role);

                     Add_Buffer
                       (sys.Buffers,
                        task_name & to_Unbounded_String ("B") & receiver_name,
                        100, processor_name,
                        processor_name & To_Unbounded_String ("_addr"), Qs_Pp1,
                        a_buffer_table, 0);
                  end;
               else
                  declare

                     my_buffer_iterator : buffers_iterator;
                     a_buffer           : buffer_ptr;
                     a_buffer_roles     : buffer_roles_table;
                     a_new_buffer_roles : buffer_roles_table;
                     a_buffer_role      : Buffer_Role;

                     sender_task_capacity : Natural;

                  begin

                     set
                       (sys.Tasks, task_name, core_name,
                        To_Unbounded_String ("core") &
                        Trim (core_placement'Image, Ada.Strings.Left));

                     set
                       (sys.Tasks, task_name, priority,
                        priority_range (task_priority));

                     if sender_period > 0 then
                        set (sys.Tasks, task_name, period, sender_period);
                        set (sys.Tasks, task_name, deadline, sender_period);
                     end if;

                     loop
                        current_element
                          (sys.Buffers, a_buffer, my_buffer_iterator);

                        a_buffer_roles := a_buffer.roles;

                        for i in 0 .. a_buffer_roles.nb_entries - 1 loop
                           if To_String (a_buffer_roles.entries (i).item) =
                             task_name
                           then

                              a_buffer_role.the_role := ICQ_Producer;
                              a_buffer_role.size     := post_delay;
                              a_buffer_role.time     := 1;
                              a_buffer_role.timeout  := 1;
                              add
                                (a_new_buffer_roles, task_name, a_buffer_role);

                              a_buffer_role.the_role := ICQ_Consumer;
                              a_buffer_role.size     := post_delay;
                              a_buffer_role.time     := 1;
                              a_buffer_role.timeout  := 1;
                              add
                                (a_new_buffer_roles, dispatcher_name,
                                 a_buffer_role);

                              update_buffer
                                (sys.Buffers, a_buffer.name, a_buffer.name,
                                 100, a_buffer.cpu_name,
                                 a_buffer.address_space_name,
                                 a_new_buffer_roles, 0);

                           end if;
                        end loop;

                        exit when is_last_element
                            (sys.Buffers, my_buffer_iterator);
                        next_element (sys.Buffers, my_buffer_iterator);
                     end loop;

                     sender_task_capacity :=
                       get (sys.Tasks, task_name, capacity);

                     if sender_task_capacity < post_delay and sender_period < 0
                     then
                        set (sys.Tasks, task_name, capacity, post_delay);
                     end if;

                  end;
               end if;
            end loop;
         end loop;
      end;

   end;

   write_to_xml_file (sys, Argument (1));

   Put_Line ("CHEDDAR xmlv3 file generated");

end Generate_amp_icq_multicore;
