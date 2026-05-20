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
-- Frank Singhoff, Lab-STICC UMR CNRS 6285, Universite de Bretagne Occidentale
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
--    $Rev: 4720 $
--    $Date: 2023-12-19 15:31:20 +0100 (mar., 19 déc. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with translate;                         use translate;
with xml_tag;                           use xml_tag;
with unbounded_strings;                 use unbounded_strings;
with framework;                         use framework;
with call_scheduling_framework;         use call_scheduling_framework;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with Queueing_Systems;                use Queueing_Systems;
with queueing_system;                 use queueing_system;
with queueing_system.theoretical;     use queueing_system.theoretical;
with queueing_system.theoretical.mp1; use queueing_system.theoretical.mp1;
with queueing_system.theoretical.pp1; use queueing_system.theoretical.pp1;
with queueing_system.theoretical.mm1; use queueing_system.theoretical.mm1;
with queueing_system.theoretical.md1; use queueing_system.theoretical.md1;
with queueing_system.theoretical.mg1; use queueing_system.theoretical.mg1;
with doubles;                         use doubles;
with double_util;                     use double_util;
with debug;                           use debug;
with dependency_services;             use dependency_services;
with Address_Spaces;                  use Address_Spaces;
with address_space_set;               use address_space_set;
use address_space_set.generic_address_space_set;
with Buffers.extended; use Buffers.extended;
with buffer_set;       use buffer_set;
use buffer_set.generic_buffer_set;
with Resources;    use Resources;
with resource_set; use resource_set;
use resource_set.generic_resource_set;
with Tasks;    use Tasks;
with task_set; use task_set;
use task_set.generic_task_set;

use Buffers.Buffer_Roles_Package;
with Scheduling_Analysis.extended; use Scheduling_Analysis.extended;
with Scheduling_Analysis.extended.buffer_analysis;
use Scheduling_Analysis.extended.buffer_analysis;

package body call_memory_framework is

   procedure compute_buffer_scheduling_simulation
     (sys         : in system; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr;
      output      : in output_format := string_output)
   is

      a_buffer        : buffer_ptr;
      my_iterator     : buffers_iterator;
      index           : scheduling_table_range := 0;
      a_buffer_result : buffer_size_table_ptr;
      a_task          : generic_task_ptr;

      maximum_size         : Natural := 0;
      maximum_waiting_time : Double  := 0.0;
      average_size         : Double  := 0.0;
      average_waiting_time : Double  := 0.0;

      average_consumer_period : Double  := 0.0;
      sum_period              : Double  := 0.0;
      nb_consumer             : Natural := 0;

   begin

      put_debug ("Call Compute_Buffer_Scheduling_Simulation");

      -- find the processor on which we want to compute buffer utilization
      --
      for i in 0 .. sched.nb_entries - 1 loop

         if sched.entries (i).item.name = a_processor.name then
            if sched.entries (i).data.error_msg = empty_string then
               index := i;
               exit;
            end if;
         end if;
      end loop;

      -- Compute buffer utilization on all buffer of the
      -- selected processor
      --

      a_buffer_result := new buffer_size_table;

      loop
         current_element (sys.buffers, a_buffer, my_iterator);

         if a_processor.name = a_buffer.cpu_name then

            initialize (a_buffer_result.all);

            compute_buffer_size_from_simulation
              (sched.entries (index).data.result, a_buffer, a_buffer_result);

            add (buff, a_buffer, a_buffer_result.all);

            -- Compute average consumer period
            --
            average_consumer_period := 0.0;
            sum_period              := 0.0;
            nb_consumer             := 0;
            for j in 0 .. a_buffer.roles.nb_entries - 1 loop
               if (a_buffer.roles.entries (j).data.the_role = queuing_consumer)
               then

                  a_task :=
                    search_task (sys.tasks, a_buffer.roles.entries (j).item);
                  if (a_task.task_type = periodic_type) then
                     sum_period := +Double (periodic_task_ptr (a_task).period);
                     nb_consumer := nb_consumer + 1;
                  end if;

               end if;
            end loop;

            if (nb_consumer > 0) then
               average_consumer_period := sum_period / Double (nb_consumer);
            else
               average_consumer_period := 0.0;
            end if;

            -- Compute results
            --
            maximum_size :=
              compute_maximum_buffer_size_from_simulation (a_buffer_result);
            average_size :=
              compute_average_buffer_size_from_simulation (a_buffer_result);
            maximum_waiting_time :=
              compute_maximum_waiting_time_from_simulation
                (a_buffer_result, average_consumer_period);
            average_waiting_time :=
              compute_average_waiting_time_from_simulation
                (a_buffer_result, average_consumer_period);

            -- Display results
            --
            result :=
              result & unbounded_lf & unbounded_lf &
              lb_buffer (Current_Language) & " " & a_buffer.name &
              To_Unbounded_String (" => ") & unbounded_lf;

            result :=
              result & lb_tab4 & lb_minus &
              lb_maximum_buffer_size (Current_Language) & maximum_size'Img &
              unbounded_lf & lb_tab4 & lb_minus &
              lb_maximum_waiting_time (Current_Language) &
              format (maximum_waiting_time, 8) & unbounded_lf;

            result :=
              result & lb_tab4 & lb_minus &
              lb_average_buffer_size (Current_Language) &
              format (average_size, 8) & unbounded_lf & lb_tab4 & lb_minus &
              lb_average_waiting_time (Current_Language) &
              format (average_waiting_time, 8) & unbounded_lf;

         end if;

         exit when is_last_element (sys.buffers, my_iterator);
         next_element (sys.buffers, my_iterator);

      end loop;

      free (a_buffer_result);

   end compute_buffer_scheduling_simulation;

   procedure compute_buffer_feasibility_tests
     (sys         : in system; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr;
      output      : in output_format := string_output)
   is

      a_buffer : buffer_ptr;

      waiting_time : Double := 0.0;
      occupation   : Double := 0.0;

      reference, ref1, ref2 : Unbounded_String;
      my_iterator           : buffers_iterator;

      nb_arrival : Double := 0.0;
      nb_server  : Double := 0.0;

      my_consumer_task : generic_task_ptr;

      service_rate : Double := 0.0;
      arrival_rate : Double := 0.0;

      a_mm1_queueing_system : mm1_queueing_system_theoretical;
      a_md1_queueing_system : md1_queueing_system_theoretical;
      a_mg1_queueing_system : mg1_queueing_system_theoretical;
      a_mp1_queueing_system : mp1_queueing_system_theoretical;
      a_pp1_queueing_system : pp1_queueing_system_theoretical;

      no_performance_criteria : Boolean := False;

   begin

      put_debug ("Call Compute_Buffer_Feasibility_Tests");

      result := unbounded_lf & unbounded_lf;

      reset_iterator (sys.buffers, my_iterator);
      loop
         current_element (sys.buffers, a_buffer, my_iterator);
         if (a_buffer.cpu_name = a_processor.name) then
            if (Natural (a_buffer.roles.nb_entries) >= 1) then
               begin

                  result :=
                    result & unbounded_lf & unbounded_lf &
                    lb_buffer (Current_Language) & " " & a_buffer.name &
                    To_Unbounded_String (" => (") &
                    qs_to_display_string (a_buffer.queueing_system_type) &
                    To_Unbounded_String (")") & unbounded_lf;

                  ref1                    := empty_string;
                  ref2                    := empty_string;
                  reference               := empty_string;
                  nb_arrival              := 0.0;
                  nb_server               := 0.0;
                  no_performance_criteria := False;

                  -- Number of producer (arrival) and consumer (server)
                  --
                  for j in 0 .. a_buffer.roles.nb_entries - 1 loop
                     if
                       (a_buffer.roles.entries (j).data.the_role =
                        queuing_producer)
                     then
                        nb_arrival := nb_arrival + 1.0;
                     end if;
                     if
                       (a_buffer.roles.entries (j).data.the_role =
                        queuing_consumer)
                     then
                        my_consumer_task :=
                          search_task
                            (sys.tasks, a_buffer.roles.entries (j).item);

                        nb_server := nb_server + 1.0;
                     end if;
                  end loop;

                  -- Control before buffer computation
                  --
                  periodic_buffer_control (sys.tasks, a_buffer);
                  buffer_flow_control
                    (a_buffer, sys.tasks, service_rate, arrival_rate);

                  case a_buffer.queueing_system_type is

                     when qs_mm1 =>

                        -- initalization
                        --
                        reset (a_mm1_queueing_system);
                        set_qs_arrival_rate
                          (a_mm1_queueing_system, arrival_rate);
                        set_qs_service_rate
                          (a_mm1_queueing_system, service_rate);
                        set_qs_nb_arrival (a_mm1_queueing_system, nb_arrival);
                        set_qs_nb_server (a_mm1_queueing_system, nb_server);
                        set_qs_harmonic
                          (a_mm1_queueing_system,
                           is_cons_prod_harmonic (a_buffer, sys.tasks));

                        -- consumer response time
                        --
                        set_constant_consumer_response_time
                          (a_mm1_queueing_system,
                           Double (my_consumer_task.deadline));

                        if (nb_server <= 1.0) then

                           -- occupation computation
                           --
                           queueing_system.theoretical.mm1
                             .qs_average_number_customer
                             (a_mm1_queueing_system, occupation);

                           -- waiting time computation
                           --
                           queueing_system.theoretical.mm1
                             .qs_average_waiting_time
                             (a_mm1_queueing_system, waiting_time);

                           -- Update message to be displayed
                           --
                           ref1 :=
                             To_Unbounded_String (" (") &
                             lb_see (Current_Language) &
                             To_Unbounded_String ("[12], page 96, ") &
                             lb_theorem (Current_Language) &
                             To_Unbounded_String ("3.24). ");

                           ref2 :=
                             To_Unbounded_String (" (") &
                             lb_see (Current_Language) &
                             To_Unbounded_String ("[12], page 98, ") &
                             lb_theorem (Current_Language) &
                             To_Unbounded_String ("3.26). ");

                           reference :=
                             lb_tab4 & lb_minus &
                             lb_average_buffer_size (Current_Language) &
                             format (occupation, 8) & unbounded_lf & lb_tab4 &
                             ref1 & unbounded_lf & lb_tab4 & lb_minus &
                             lb_average_waiting_time (Current_Language) &
                             format (waiting_time, 8) & unbounded_lf &
                             lb_tab4 & ref2 & unbounded_lf & unbounded_lf;

                        else
                           no_performance_criteria := True;
                        end if;

                     when qs_md1 =>

                        -- initalization
                        --
                        reset (a_md1_queueing_system);
                        set_qs_arrival_rate
                          (a_md1_queueing_system, arrival_rate);
                        set_qs_service_rate
                          (a_md1_queueing_system, service_rate);
                        set_qs_nb_arrival (a_md1_queueing_system, nb_arrival);
                        set_qs_nb_server (a_md1_queueing_system, nb_server);
                        set_qs_harmonic
                          (a_md1_queueing_system,
                           is_cons_prod_harmonic (a_buffer, sys.tasks));

                        -- consumer response time
                        --
                        set_constant_consumer_response_time
                          (a_md1_queueing_system,
                           Double (my_consumer_task.deadline));

                        if (nb_server <= 1.0) then

                           -- occupation computation
                           --
                           queueing_system.theoretical.md1
                             .qs_average_number_customer
                             (a_md1_queueing_system, occupation);

                           -- waiting time computation
                           --
                           queueing_system.theoretical.md1
                             .qs_average_waiting_time
                             (a_md1_queueing_system, waiting_time);

                           -- Update message to be displayed
                           --
                           ref1 := To_Unbounded_String ("to be filled");

                           ref2 := To_Unbounded_String ("to be filled");

                           reference :=
                             lb_tab4 & lb_minus &
                             lb_average_buffer_size (Current_Language) &
                             format (occupation, 8) & unbounded_lf & lb_tab4 &
                             ref1 & unbounded_lf & lb_tab4 & lb_minus &
                             lb_average_waiting_time (Current_Language) &
                             format (waiting_time, 8) & unbounded_lf &
                             lb_tab4 & ref2 & unbounded_lf & unbounded_lf;

                        else
                           no_performance_criteria := True;
                        end if;

                     when qs_mg1 =>

                        -- initalization
                        --
                        reset (a_mg1_queueing_system);
                        set_qs_arrival_rate
                          (a_mg1_queueing_system, arrival_rate);
                        set_qs_service_rate
                          (a_mg1_queueing_system, service_rate);
                        set_qs_nb_arrival (a_mg1_queueing_system, nb_arrival);
                        set_qs_nb_server (a_mg1_queueing_system, nb_server);
                        set_qs_harmonic
                          (a_mg1_queueing_system,
                           is_cons_prod_harmonic (a_buffer, sys.tasks));

                        -- consumer response time
                        --
                        set_constant_consumer_response_time
                          (a_mg1_queueing_system,
                           Double (my_consumer_task.deadline));

                        if (nb_server <= 1.0) then

                           -- occupation computation
                           --
                           queueing_system.theoretical.mg1
                             .qs_average_number_customer
                             (a_mg1_queueing_system, occupation);

                           -- waiting time computation
                           --
                           queueing_system.theoretical.mg1
                             .qs_average_waiting_time
                             (a_mg1_queueing_system, waiting_time);

                           -- Update message to be displayed
                           --
                           ref1 := To_Unbounded_String ("to be filled");

                           ref2 := To_Unbounded_String ("to be filled");

                           reference :=
                             lb_tab4 & lb_minus &
                             lb_average_buffer_size (Current_Language) &
                             format (occupation, 8) & unbounded_lf & lb_tab4 &
                             ref1 & unbounded_lf & lb_tab4 & lb_minus &
                             lb_average_waiting_time (Current_Language) &
                             format (waiting_time, 8) & unbounded_lf &
                             lb_tab4 & ref2 & unbounded_lf & unbounded_lf;

                        else
                           no_performance_criteria := True;
                        end if;

                     when qs_mp1 =>

                        -- initalization
                        --
                        reset (a_mp1_queueing_system);
                        set_qs_arrival_rate
                          (a_mp1_queueing_system, arrival_rate);
                        set_qs_service_rate
                          (a_mp1_queueing_system, service_rate);
                        set_qs_nb_arrival (a_mp1_queueing_system, nb_arrival);
                        set_qs_nb_server (a_mp1_queueing_system, nb_server);
                        set_qs_harmonic
                          (a_mp1_queueing_system,
                           is_cons_prod_harmonic (a_buffer, sys.tasks));

                        -- consumer response time
                        --
                        set_constant_consumer_response_time
                          (a_mp1_queueing_system,
                           Double (my_consumer_task.deadline));

                        if (nb_server <= 1.0) then

                           -- occupation computation
                           --
                           queueing_system.theoretical.mp1
                             .qs_average_number_customer
                             (a_mp1_queueing_system, occupation);

                           -- waiting time computation
                           --
                           queueing_system.theoretical.mp1
                             .qs_average_waiting_time
                             (a_mp1_queueing_system, waiting_time);

                           -- Update message to be displayed
                           --
                           ref1 :=
                             To_Unbounded_String (" (") &
                             lb_see (Current_Language) &
                             To_Unbounded_String ("[10], ") &
                             lb_theorem (Current_Language) &
                             To_Unbounded_String ("6). ");

                           ref2 :=
                             To_Unbounded_String (" (") &
                             lb_see (Current_Language) &
                             To_Unbounded_String ("[10], ") &
                             lb_theorem (Current_Language) &
                             To_Unbounded_String ("6). ");

                           reference :=
                             lb_tab4 & lb_minus &
                             lb_average_buffer_size (Current_Language) &
                             format (occupation, 8) & unbounded_lf & lb_tab4 &
                             ref1 & unbounded_lf & lb_tab4 & lb_minus &
                             lb_average_waiting_time (Current_Language) &
                             format (waiting_time, 8) & unbounded_lf &
                             lb_tab4 & ref2 & unbounded_lf & unbounded_lf;

                        else
                           no_performance_criteria := True;
                        end if;

                     when qs_pp1 =>

                        -- initalization
                        --
                        reset (a_pp1_queueing_system);
                        set_qs_arrival_rate
                          (a_pp1_queueing_system, arrival_rate);
                        set_qs_service_rate
                          (a_pp1_queueing_system, service_rate);
                        set_qs_nb_arrival (a_pp1_queueing_system, nb_arrival);
                        set_qs_nb_server (a_pp1_queueing_system, nb_server);
                        set_qs_harmonic
                          (a_pp1_queueing_system,
                           is_cons_prod_harmonic (a_buffer, sys.tasks));

                        -- consumer response time
                        --
                        set_constant_consumer_response_time
                          (a_mp1_queueing_system,
                           Double (my_consumer_task.deadline));

                        if (nb_server <= 1.0) then

                           -- occupation computation
                           --
                           queueing_system.theoretical.pp1
                             .qs_maximum_number_customer
                             (a_pp1_queueing_system, occupation);

                           -- waiting time computation
                           --
                           queueing_system.theoretical.pp1
                             .qs_maximum_waiting_time
                             (a_pp1_queueing_system, waiting_time);

                           -- Update message to be displayed
                           --
                           ref1 :=
                             To_Unbounded_String (" (") &
                             lb_see (Current_Language) &
                             To_Unbounded_String ("[4,10], ") &
                             lb_theorem (Current_Language) &
                             To_Unbounded_String ("1 or 8). ");

                           ref2 :=
                             To_Unbounded_String (" (") &
                             lb_see (Current_Language) &
                             To_Unbounded_String ("[10], ") &
                             lb_theorem (Current_Language) &
                             To_Unbounded_String ("8). ");

                           reference :=
                             lb_tab4 & lb_minus &
                             lb_maximum_buffer_size (Current_Language) &
                             format (occupation, 8) & unbounded_lf & lb_tab4 &
                             ref1 & unbounded_lf & lb_tab4 & lb_minus &
                             lb_maximum_waiting_time (Current_Language) &
                             format (waiting_time, 8) & unbounded_lf &
                             lb_tab4 & ref2 & unbounded_lf & unbounded_lf;

                        else
                           no_performance_criteria := True;
                        end if;

                     when others =>
                        no_performance_criteria := True;

                  end case;

                  if no_performance_criteria then
                     result :=
                       result & lb_tab4 & lb_minus &
                       lb_compute_buffer_error_4 (Current_Language) &
                       unbounded_lf;
                  else
                     result := result & reference;
                  end if;

               exception
                  when not_implemented =>
                     result :=
                       result & lb_tab4 & lb_minus &
                       lb_compute_buffer_error_4 (Current_Language) &
                       unbounded_lf;
                  when task_set.task_model_error =>
                     result :=
                       result & lb_tab4 & lb_minus &
                       lb_compute_buffer_error_3 (Current_Language) &
                       unbounded_lf;
                  when dependency_services.task_must_be_periodic =>
                     result :=
                       result & lb_tab4 & lb_minus &
                       lb_compute_buffer_error_2 (Current_Language) &
                       unbounded_lf;
                  when flow_constraint_not_respected =>
                     result :=
                       result & lb_tab4 & lb_minus &
                       lb_compute_buffer_error_1 (Current_Language) &
                       unbounded_lf;
               end;
            else
               result :=
                 result & lb_tab4 & a_buffer.name &
                 To_Unbounded_String (" => NA");
            end if;
         end if;
         exit when is_last_element (sys.buffers, my_iterator);
         next_element (sys.buffers, my_iterator);
      end loop;

   end compute_buffer_feasibility_tests;

   procedure compute_memory_requirement_analysis
     (sys                       : in system; result : in out Unbounded_String;
      update_address_spaces_set : in Boolean;
      output                    : in output_format := string_output)
   is

      sum_text  : Natural := 0;
      sum_stack : Natural := 0;
      sum_data  : Natural := 0;

      task_ite          : tasks_iterator;
      a_task            : generic_task_ptr;
      address_space_ite : address_spaces_iterator;
      a_address_space   : address_space_ptr;
      buffer_ite        : buffers_iterator;
      a_buffer          : buffer_ptr;
      resource_ite      : resources_iterator;
      a_resource        : generic_resource_ptr;

   begin
      put_debug ("Call Compute_Memory_Requirement_Analysis");

      result := unbounded_lf;

      if (get_number_of_elements (sys.address_spaces) > 0) then

         reset_iterator (sys.address_spaces, address_space_ite);

         loop
            current_element
              (sys.address_spaces, a_address_space, address_space_ite);

            -- Sum up memory requirements of the address space
            --
            sum_text  := 0;
            sum_stack := 0;
            sum_data  := 0;

            if (get_number_of_elements (sys.tasks) > 0) then
               reset_iterator (sys.tasks, task_ite);
               loop
                  current_element (sys.tasks, a_task, task_ite);
                  if a_task.address_space_name = a_address_space.name then
                     sum_text  := sum_text + a_task.text_memory_size;
                     sum_stack := sum_stack + a_task.stack_memory_size;
                  end if;
                  exit when is_last_element (sys.tasks, task_ite);
                  next_element (sys.tasks, task_ite);
               end loop;
            end if;
            if (get_number_of_elements (sys.buffers) > 0) then
               reset_iterator (sys.buffers, buffer_ite);
               loop
                  current_element (sys.buffers, a_buffer, buffer_ite);
                  if a_buffer.address_space_name = a_address_space.name then
                     sum_data := sum_data + a_buffer.buffer_size;
                  end if;
                  exit when is_last_element (sys.buffers, buffer_ite);
                  next_element (sys.buffers, buffer_ite);
               end loop;
            end if;
            if (get_number_of_elements (sys.resources) > 0) then
               reset_iterator (sys.resources, resource_ite);
               loop
                  current_element (sys.resources, a_resource, resource_ite);
                  if a_resource.address_space_name = a_address_space.name then
                     sum_data := sum_data + a_resource.size;
                  end if;
                  exit when is_last_element (sys.resources, resource_ite);
                  next_element (sys.resources, resource_ite);
               end loop;
            end if;

            result :=
              result & "   " & a_address_space.name & " => Data = " &
              sum_data'Img & " ; Stack = " & sum_stack'Img & " Text = " &
              sum_text'Img & unbounded_lf;
            if update_address_spaces_set then
               a_address_space.text_memory_size  := sum_text;
               a_address_space.data_memory_size  := sum_data;
               a_address_space.stack_memory_size := sum_stack;
            end if;
            exit when is_last_element (sys.address_spaces, address_space_ite);
            next_element (sys.address_spaces, address_space_ite);
         end loop;

      end if;
   end compute_memory_requirement_analysis;

   procedure compute_memory_interferences_delays
     (sys    : in     system; a_processor : in generic_processor_ptr;
      result : in out Unbounded_String;
      output : in     output_format := string_output)
   is
   begin
      null;
   end compute_memory_interferences_delays;

end call_memory_framework;
