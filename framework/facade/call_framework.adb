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
--    $Rev: 4968 $
--    $Date: 2024-04-13 12:54:04 +0200 (sam., 13 avril 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with time_unit_events;          use time_unit_events;
with time_unit_events.extended; use time_unit_events.extended;
with Call_Framework_Interface;  use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Request_Package;
use Call_Framework_Interface.Framework_Response_Package;
with Text_IO;           use Text_IO;
with xml_tag;           use xml_tag;
with unbounded_strings; use unbounded_strings;
with task_set;          use task_set;
use task_set.generic_task_set;
with buffer_set; use buffer_set;
use buffer_set.generic_buffer_set;
with Ada.Exceptions; use Ada.Exceptions;
with Processors;     use Processors;
with processor_set;  use processor_set;
use processor_set.generic_processor_set;
with framework;                 use framework;
with call_scheduling_framework; use call_scheduling_framework;
with call_memory_framework;     use call_memory_framework;
use call_memory_framework.buffer_result_package;
with call_resource_framework;           use call_resource_framework;
with call_dependency_framework;         use call_dependency_framework;
with call_cache_framework;              use call_cache_framework;
with call_network_framework;            use call_network_framework;
with call_security_framework;           use call_security_framework;
with call_random_framework;             use call_random_framework;
with call_design_pattern_framework;     use call_design_pattern_framework;
with Scheduler_Interface;               use Scheduler_Interface;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with translate;              use translate;
with translate.english_labels;
with translate.francais_labels;
with translate.aadl_labels;
with Text_IO;                use Text_IO;
with initialize_framework;   use initialize_framework;
with GNAT.OS_Lib;            use GNAT.OS_Lib;
with Ada.IO_Exceptions;      use Ada.IO_Exceptions;
with GNAT.Current_Exception; use GNAT.Current_Exception;
with scheduling_options;     use scheduling_options;
with xml_encoder ; use xml_encoder;
package body call_framework is

   type sub_framework_request is record
      statement : framework_statement_type;
      param     : framework_parameters_table;
      target    : generic_processor_ptr;
   end record;

   procedure initialize (aadl_labels : in Boolean) is
      s : GNAT.OS_Lib.String_Access;
   begin

      -- Initialize an object id generator
      --
      initialize (framework_id);

      -- Initialize all labels of the framework
      --
      translate.initialize;
      if Current_Language = english then
         translate.english_labels.initialize;
      else
         translate.francais_labels.initialize;
      end if;
      if (aadl_labels = True) then
         translate.aadl_labels.initialize;
      end if;

      -- Read install path
      --
      s            := Getenv ("CHEDDAR_INSTALL_PATH");
      install_path := To_Unbounded_String (s.all);
      if install_path = empty_string then
         Put_Line
           ("Warning : CHEDDAR_INSTALL_PATH is not defined : CHEDDAR_INSTALL_PATH is set with default value '.' ");
         install_path := To_Unbounded_String ("./");

      end if;

      -- Save that we have initialized the framework
      -- Now we can check that the framework is ready to use
      --
      set_initialize;

   end initialize;

   procedure sequential_framework_request
     (sys      : in out system; request : in framework_request_table;
      response : in out framework_response_table)
   is
   begin
      check_initialize;

      sequential_framework_request
        (sys, request, response, Total_Order, String_Output);
   end sequential_framework_request;

   procedure initialize (f : in out framework_request) is
   begin
      f.target := empty_string;
      initialize (f.param);
   end initialize;

   -- Do various checks on the parameters of a request
   --
   procedure check_framework_parameters (request : in sub_framework_request) is

      ok : Boolean := False;

   begin
      for i in 0 .. request.param.nb_entries - 1 loop
         ok := False;

         for k in integer_framework_parameter_name'Range loop
            if
              (request.param.entries (i).parameter_name =
               integer_framework_parameter_name (k))
            then
               ok := True;
            end if;
         end loop;

         for k in boolean_framework_parameter_name'Range loop
            if
              (request.param.entries (i).parameter_name =
               boolean_framework_parameter_name (k))
            then
               ok := True;
            end if;
         end loop;

         for k in string_framework_parameter_name'Range loop
            if
              (request.param.entries (i).parameter_name =
               string_framework_parameter_name (k))
            then
               ok := True;
            end if;
         end loop;

         if not ok then
            Raise_Exception
              (unexpected_parameter'Identity,
               To_String
                 (request.param.entries (i).parameter_name & " for " &
                  request.statement'Img));
         end if;

         for k in integer_framework_parameter_name'Range loop
            if
              (request.param.entries (i).type_of_parameter /=
               integer_parameter) and
              (request.param.entries (i).parameter_name =
               integer_framework_parameter_name (k))
            then
               Raise_Exception
                 (parameter_type_error'Identity,
                  To_String
                    (request.param.entries (i).parameter_name & " for " &
                     request.statement'Img));
            end if;
         end loop;

         for k in boolean_framework_parameter_name'Range loop
            if
              (request.param.entries (i).type_of_parameter /=
               boolean_parameter) and
              (request.param.entries (i).parameter_name =
               boolean_framework_parameter_name (k))
            then
               Raise_Exception
                 (parameter_type_error'Identity,
                  To_String
                    (request.param.entries (i).parameter_name & " for " &
                     request.statement'Img));
            end if;
         end loop;
      end loop;

   end check_framework_parameters;

   procedure call_a_request
     (sys        : in out system; request : in sub_framework_request;
      a_response : in out Unbounded_String;
      output     : in     output_format := string_output)
   is

      -- Parameters to be used for calling the "computing time line" service
      --
      event_to_generate              : time_unit_event_type_boolean_table;
      period                         : Natural := 0;
      options                        : scheduling_option;
      wcrt_with_crpd : crpd_computation_approach_type := no_crpd;
      wcrt_with_memory_interferences : memory_interference_computation_approach_type :=
        no_memory_interference;
      worst_case       : Boolean := True;
      best_case        : Boolean := True;
      average_case     : Boolean := True;
      feasibility_name : Unbounded_String;
      ok               : Boolean := False;

   begin

      case request.statement is

         -----------------------------------------------------------
         -----------------------------------------------------------
         when scheduling_simulation_time_line =>

            initialize (event_to_generate, True);

            -- Check parameters
            --
            check_framework_parameters (request);
            for i in 0 .. request.param.nb_entries - 1 loop
               if
                 ((request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("preemption")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("wait_for_memory")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("buffer_overflow")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("buffer_underflow")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("period")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("seed_value")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("schedule_with_offsets")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("schedule_with_precedencies")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("schedule_with_resources")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("minimize_preemption")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("schedule_with_jitters")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("predictable")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("start_of_task_capacity")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("end_of_task_capacity")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("write_to_buffer")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("read_from_buffer")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("running_task")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("task_activation")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("send_message")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("receive_message")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("allocate_resource")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("release_resource")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("wait_for_resource")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("discard_missed_deadline")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("address_space_activation")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("context_switch_overhead")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("schedule_with_task_groups")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("anomaly_detection")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("dvfs")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("mode_change")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("tdma_slot")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("energy")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("schedule_with_crpd")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String
                     ("schedule_with_discard_missed_deadlines")))
               then
                  Raise_Exception
                    (unexpected_parameter'Identity,
                     " " &
                     To_String (request.param.entries (i).parameter_name) &
                     " unknown " & " for Scheduling_Simulation_Time_Line");
               end if;
            end loop;

            -- Fetch parameters from the request
            --
            for i in 0 .. request.param.nb_entries - 1 loop

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("period"))
               then
                  period := request.param.entries (i).integer_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("seed_value"))
               then
                  options.global_seed_value :=
                    request.param.entries (i).integer_value;
                  options.with_task_specific_seed := False;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("schedule_with_offsets"))
               then
                  options.with_offsets :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("schedule_with_precedencies"))
               then
                  options.with_precedencies :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("schedule_with_resources"))
               then
                  options.with_resources :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("minimize_preemption"))
               then
                  options.with_minimize_preemption :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("dvfs"))
               then
                  options.with_dvfs := request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("anomaly_detection"))
               then
                  options.with_anomaly_detection :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("task_specific_seed"))
               then
                  options.with_task_specific_seed :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("schedule_with_jitters"))
               then
                  options.with_jitters :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("predictable"))
               then
                  options.predictable_global_seed :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("start_of_task_capacity"))
               then
                  event_to_generate (start_of_task_capacity) :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("end_of_task_capacity"))
               then
                  event_to_generate (end_of_task_capacity) :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("write_to_buffer"))
               then
                  event_to_generate (write_to_buffer) :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("read_from_buffer"))
               then
                  event_to_generate (read_from_buffer) :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("running_task"))
               then
                  event_to_generate (running_task) :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("task_activation"))
               then
                  event_to_generate (task_activation) :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("send_message"))
               then
                  event_to_generate (send_message) :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("receive_message"))
               then
                  event_to_generate (receive_message) :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("allocate_resource"))
               then
                  event_to_generate (receive_message) :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("release_resource"))
               then
                  event_to_generate (release_resource) :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("wait_for_resource"))
               then
                  event_to_generate (wait_for_resource) :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("address_space_activation"))
               then
                  event_to_generate (address_space_activation) :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("context_switch_overhead"))
               then
                  event_to_generate (context_switch_overhead) :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("schedule_with_task_groups"))
               then
                  options.with_task_groups :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("schedule_with_crpd"))
               then
                  options.with_crpd := request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("tdma_slot"))
               then
                  options.with_tdma_slot :=
                    request.param.entries (i).boolean_value;
                  event_to_generate (tdma_slot) :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("mode_change"))
               then
                  options.with_mode_change :=
                    request.param.entries (i).boolean_value;
                  event_to_generate (mode_change) :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("energy"))
               then
                  options.with_energy :=
                    request.param.entries (i).boolean_value;
                  event_to_generate (energy) :=
                    request.param.entries (i).boolean_value;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String
                    ("schedule_with_discard_missed_deadlines"))
               then
                  options.with_discard_missed_deadlines :=
                    request.param.entries (i).boolean_value;
                  event_to_generate (discard_missed_deadline) :=
                    request.param.entries (i).boolean_value;
               end if;

            end loop;

            -- Call framework
            --
            compute_simulation_time_line
              (sys, a_response,
            -- With period
            --
            period,
            -- With options to drive the scheduling
            --
            options,

            -- Which event we should generate
            --
            event_to_generate,
output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_simulation_basics =>

            compute_simulation_basics
              (sys, a_response, request.target, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_simulation_run_event_handler =>

            run_user_defined_event_handlers (sys, a_response, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_simulation_priority_inversion =>

            priority_inversion_detection
              (sys, a_response, request.target, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_general_task =>

            partionning_tasks (sys, a_response, general_task, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_first_fit =>

            partionning_tasks (sys, a_response, first_fit, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_next_fit =>

            partionning_tasks (sys, a_response, next_fit, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_best_fit =>

            partionning_tasks (sys, a_response, best_fit, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_small_task =>

            partionning_tasks (sys, a_response, small_task, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_simulation_deadlock =>

            deadlock_detection (sys, a_response, request.target, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_simulation_context_switch_number =>

            compute_simulation_number_of_context_switch
              (sys, a_response, request.target, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_simulation_preemption_number =>

            compute_simulation_number_of_preemption
              (sys, a_response, request.target, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_periodic_task_worst_case_response_time =>

            -- Check parameters
            --
            check_framework_parameters (request);
            for i in 0 .. request.param.nb_entries - 1 loop
               if
                 ((request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("wcrt_without_crpd")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("wcrt_with_crpd_ECB_only")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String
                     ("wcrt_with_crpd_ECB_union_multiset")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String
                     ("wcrt_with_crpd_UCB_union_multiset")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String
                     ("wcrt_with_crpd_combined_multiset")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String
                     ("wcrt_without_memory_interferences")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("wcrt_with_DRAM_single_arbiter")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("wcrt_with_kalray_multi_arbiter")))
               then
                  Raise_Exception
                    (unexpected_parameter'Identity,
                     " " &
                     To_String (request.param.entries (i).parameter_name) &
                     " unknown " & " for " & request.statement'Img);
               end if;
            end loop;

            for i in 0 .. request.param.nb_entries - 1 loop

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("wcrt_without_crpd"))
               then
                  wcrt_with_crpd := no_crpd;
               end if;
               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("wcrt_with_crpd_ECB_only"))
               then
                  wcrt_with_crpd := ecb_only;
               end if;
               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("wcrt_with_crpd_ECB_union_multiset"))
               then
                  wcrt_with_crpd := ecb_union_multiset;
               end if;
               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("wcrt_with_crpd_UCB_union_multiset"))
               then
                  wcrt_with_crpd := ucb_union_multiset;
               end if;
               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("wcrt_with_crpd_combined_multiset"))
               then
                  wcrt_with_crpd := combined_multiset;
               end if;

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("wcrt_without_memory_interferences"))
               then
                  wcrt_with_memory_interferences := no_memory_interference;
               end if;
               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("wcrt_with_DRAM_single_arbiter"))
               then
                  wcrt_with_memory_interferences := dram_single_arbiter;
               end if;
               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("wcrt_with_kalray_multi_arbiter"))
               then
                  wcrt_with_memory_interferences := kalray_multi_arbiter;
               end if;

            end loop;

            if
              (get_number_of_task_from_processor
                 (sys.tasks, request.target.name) /=
               0)
            then

               compute_feasibility_response_time
                 (sys, a_response, periodic, wcrt_with_memory_interferences,
                  wcrt_with_crpd, request.target, output);

            end if;

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_cpu_utilization =>

            if
              (get_number_of_task_from_processor
                 (sys.tasks, request.target.name) /=
               0)
            then

               compute_feasibility_processor_utilization_factor
                 (sys, a_response, request.target, output);

            end if;

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_demand_bound_function =>

            if
              (get_number_of_task_from_processor
                 (sys.tasks, request.target.name) /=
               0)
            then

               compute_feasibility_by_demand_bound_function
                 (sys, a_response, request.target, output);

            end if;

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_interval =>

            if
              (get_number_of_task_from_processor
                 (sys.tasks, request.target.name) /=
               0)
            then

               compute_feasibility_interval
                 (sys, a_response, request.target, output);

            end if;

            -----------------------------------------------------------
            -----------------------------------------------------------
         when select_feasibility_test_by_name =>

            -- Check parameters
            --
            check_framework_parameters (request);
            for i in 0 .. request.param.nb_entries - 1 loop
               if
                 ((request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("feasibility_test_name")))
               then
                  Raise_Exception
                    (unexpected_parameter'Identity,
                     " " &
                     To_String (request.param.entries (i).parameter_name) &
                     " unknown " & " for " & request.statement'Img);
               end if;
            end loop;

            for i in 0 .. request.param.nb_entries - 1 loop

               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("feasibility_test_name"))
               then
                  feasibility_name := request.param.entries (i).string_value;
               end if;
            end loop;

            compute_feasibility_test_by_name
              (sys, a_response, request.target, feasibility_name, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_simulation_response_time =>

            -- Check parameters
            --
            check_framework_parameters (request);
            for i in 0 .. request.param.nb_entries - 1 loop
               if
                 ((request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("worst_case")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("best_case")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("average_case")))
               then
                  Raise_Exception
                    (unexpected_parameter'Identity,
                     " " &
                     To_String (request.param.entries (i).parameter_name) &
                     " unknown " & " for " & request.statement'Img);
               end if;
            end loop;

            for i in 0 .. request.param.nb_entries - 1 loop
               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("worst_case"))
               then
                  worst_case := request.param.entries (i).boolean_value;
               end if;
               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("best_case"))
               then
                  best_case := request.param.entries (i).boolean_value;
               end if;
               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("average_case"))
               then
                  average_case := request.param.entries (i).boolean_value;
               end if;
            end loop;

            compute_simulation_response_time
              (sys, a_response, request.target, worst_case, best_case,
               average_case, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_simulation_blocking_time =>

            -- Check parameters
            --
            check_framework_parameters (request);
            for i in 0 .. request.param.nb_entries - 1 loop
               if
                 ((request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("worst_case")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("best_case")) and
                  (request.param.entries (i).parameter_name /=
                   To_Unbounded_String ("average_case")))
               then
                  Raise_Exception
                    (unexpected_parameter'Identity,
                     " " &
                     To_String (request.param.entries (i).parameter_name) &
                     " unknown " & " for " & request.statement'Img);
               end if;
            end loop;

            for i in 0 .. request.param.nb_entries - 1 loop
               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("worst_case"))
               then
                  worst_case := request.param.entries (i).boolean_value;
               end if;
               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("best_case"))
               then
                  best_case := request.param.entries (i).boolean_value;
               end if;
               if
                 (request.param.entries (i).parameter_name =
                  To_Unbounded_String ("average_case"))
               then
                  average_case := request.param.entries (i).boolean_value;
               end if;
            end loop;

            compute_simulation_blocking_time
              (sys, a_response, request.target, worst_case, best_case,
               average_case, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_simulation_all_response_times =>

            -- This service exits, i.e. has been implemented ... but we need to decide how to return
            -- the results to the caller

            null;

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_compute_and_set_worst_case_blocking_time =>

            compute_worst_case_blocking_time
              (sys, a_response, request.target, True, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_compute_worst_case_blocking_time =>

            compute_worst_case_blocking_time
              (sys, a_response, request.target, False, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_basics =>

            if
              (get_number_of_task_from_processor
                 (sys.tasks, request.target.name) /=
               0)
            then

               compute_feasibility_basics
                 (sys, a_response, request.target, output);

            end if;

         when scheduling_feasibility_compute_resource_ceiling_priority =>

            compute_resource_ceiling_priority
              (sys, a_response, request.target, False, output);

         when scheduling_feasibility_compute_and_set_resource_ceiling_priority =>

            compute_resource_ceiling_priority
              (sys, a_response, request.target, True, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_set_priorities_according_to_deadline_monotonic =>

            set_priorities
              (sys, a_response, request.target,
               scheduling_set_priorities_according_to_deadline_monotonic,
               output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_set_priorities_according_to_rate_monotonic =>

            set_priorities
              (sys, a_response, request.target,
               scheduling_set_priorities_according_to_rate_monotonic, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_set_priorities_according_to_audsley_opa =>

            set_priorities
              (sys, a_response, request.target,
               scheduling_set_priorities_according_to_audsley_opa, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_set_priorities_according_to_opa_crpd_pt_simplified =>

            set_priorities
              (sys, a_response, request.target,
               scheduling_set_priorities_according_to_opa_crpd_pt_simplified,
               output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_set_priorities_according_to_opa_crpd_pt =>

            set_priorities
              (sys, a_response, request.target,
               scheduling_set_priorities_according_to_opa_crpd_pt, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_set_priorities_according_to_opa_crpd_tree =>

            set_priorities
              (sys, a_response, request.target,
               scheduling_set_priorities_according_to_opa_crpd_tree, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when buffer_feasibility_tests =>

            if
              (get_number_of_buffer_from_processor
                 (sys.buffers, request.target.name) /=
               0)
            then

               compute_buffer_feasibility_tests
                 (sys, a_response, request.target, output);
            end if;

            -----------------------------------------------------------
            -----------------------------------------------------------
         when memory_compute_footprint_analysis =>
            compute_memory_requirement_analysis
              (sys, a_response, False, output);

         when memory_set_footprint_analysis =>
            compute_memory_requirement_analysis
              (sys, a_response, True, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when buffer_scheduling_simulation =>
            if
              (get_number_of_buffer_from_processor
                 (sys.buffers, request.target.name) /=
               0)
            then
               compute_buffer_scheduling_simulation
                 (sys, a_response, request.target, output);
            end if;

            -----------------------------------------------------------
            -----------------------------------------------------------
         when random_response_time_density =>

            compute_response_time_density
              (sys, a_response, request.target, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when dependency_compute_chetto_blazewicz_priority =>

            chetto_parameter_modifications
              (sys, a_response, request.target, False, True, False, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when dependency_compute_chetto_blazewicz_deadline =>

            chetto_parameter_modifications
              (sys, a_response, request.target, True, False, False, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when dependency_set_chetto_blazewicz_deadline =>

            chetto_parameter_modifications
              (sys, a_response, request.target, True, False, True, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when dependency_set_chetto_blazewicz_priority =>

            chetto_parameter_modifications
              (sys, a_response, request.target, False, True, True, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when dependency_compute_end_to_end_response_time_one_step =>

            compute_end_to_end_response_time
              (sys, a_response, False, True, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when dependency_set_end_to_end_response_time_one_step =>

            compute_end_to_end_response_time
              (sys, a_response, True, True, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when dependency_compute_end_to_end_response_time_all_steps =>

            compute_end_to_end_response_time
              (sys, a_response, False, False, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when dependency_set_end_to_end_response_time_all_steps =>

            compute_end_to_end_response_time
              (sys, a_response, True, False, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when select_feasibility_tests_simple =>

            select_feasibility_tests_simple_system (sys, a_response, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_tests_compositional =>

            select_feasibility_tests_compositional_system
              (sys, a_response, output);

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_transaction_worst_case_response_time_audsley =>

            if
              (get_number_of_task_from_processor
                 (sys.tasks, request.target.name) /=
               0)
            then

               compute_feasibility_response_time
                 (sys, a_response, audsley, no_memory_interference, no_crpd,
                  request.target, output);

            end if;

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_transaction_worst_case_response_time_tindell =>

            if
              (get_number_of_task_from_processor
                 (sys.tasks, request.target.name) /=
               0)
            then

               compute_feasibility_response_time
                 (sys, a_response, tindell, no_memory_interference, no_crpd,
                  request.target, output);

            end if;

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_transaction_worst_case_response_time_palencia =>

            if
              (get_number_of_task_from_processor
                 (sys.tasks, request.target.name) /=
               0)
            then

               compute_feasibility_response_time
                 (sys, a_response, palencia, no_memory_interference, no_crpd,
                  request.target, output);

            end if;

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_transaction_worst_case_response_time_wcdops_plus =>

            if
              (get_number_of_task_from_processor
                 (sys.tasks, request.target.name) /=
               0)
            then

               compute_feasibility_response_time
                 (sys, a_response, wcdops_plus, no_memory_interference,
                  no_crpd, request.target, output);

            end if;

            -----------------------------------------------------------
            -----------------------------------------------------------
         when scheduling_feasibility_transaction_worst_case_response_time_wcdops_plus_nim =>
            null;

            if
              (get_number_of_task_from_processor
                 (sys.tasks, request.target.name) /=
               0)
            then

               compute_feasibility_response_time
                 (sys, a_response, wcdops_plus_nim, no_memory_interference,
                  no_crpd, request.target, output);

            end if;

            -----------------------------------------------------------
            -----------------------------------------------------------

         when cache_analysis_compute_cache_access_profile =>
            compute_tasks_cache_access_profile
              (sys => sys, a_processor => request.target, result => a_response,
               output => output);
         when cache_analysis_import_cfg =>
            call_cache_framework.import_cfg
              (sys => sys, a_processor => request.target, result => a_response,
               output => output);

         when cache_analysis_import_cfg_and_compute_cache_access_profile =>
            call_cache_framework.import_cfg
              (sys => sys, a_processor => request.target, result => a_response,
               output => output);
            compute_tasks_cache_access_profile
              (sys => sys, a_processor => request.target, result => a_response,
               output => output);

            -----------------------------------------------------------
            -----------------------------------------------------------

         when memory_analysis_interferences_delays =>
            compute_memory_interferences_delays
              (sys => sys, a_processor => request.target, result => a_response,
               output => output);

            -----------------------------------------------------------
            -----------------------------------------------------------

         when network_noc_compute_communication_delay =>
            compute_noc_communication_delay
              (sys => sys, result => a_response, output => output);

         when network_noc_compute_path_delay =>
            compute_noc_path_delay
              (sys => sys, result => a_response, output => output);

         when network_noc_compute_direct_interference_delay =>
            compute_noc_direct_interference_delay
              (sys => sys, result => a_response, output => output);

         when network_noc_compute_indirect_interference_delay =>
            compute_noc_indirect_interference_delay
              (sys => sys, result => a_response, output => output);

         when network_compute_noc_transformation_ectm_saf =>
            compute_ectm_saf_transformation (sys, a_response, False, output);
         when network_set_noc_transformation_ectm_saf =>
            compute_ectm_saf_transformation (sys, a_response, True, output);

         when network_compute_noc_transformation_ectm_wormhole =>
            compute_ectm_wormhole_transformation
              (sys, a_response, False, output);
         when network_set_noc_transformation_ectm_wormhole =>
            compute_ectm_wormhole_transformation
              (sys, a_response, True, output);

         when network_compute_noc_transformation_wcctm_saf =>
            compute_wcctm_saf_transformation (sys, a_response, False, output);
         when network_set_noc_transformation_wcctm_saf =>
            compute_wcctm_saf_transformation (sys, a_response, True, output);

         when network_compute_noc_transformation_wcctm_wormhole =>
            compute_wcctm_wormhole_transformation
              (sys, a_response, False, output);
         when network_set_noc_transformation_wcctm_wormhole =>
            compute_wcctm_wormhole_transformation
              (sys, a_response, True, output);

         when network_compute_spacewire_transformation_scm =>
            compute_spacewire_scm_transformation
              (sys, a_response, False, output);
         when network_set_spacewire_transformation_scm =>
            compute_spacewire_scm_transformation
              (sys, a_response, True, output);
            -----------------------------------------------------------
            -----------------------------------------------------------

         when mils_compute_security_chinese_wall =>
            compute_mils_security_chinese_wall
              (sys => sys, result => a_response, output => output);

         when mils_compute_security_warshall =>
            compute_mils_security_warshall
              (sys => sys, result => a_response, output => output);

         when mils_compute_security_bell_lapadula =>
            compute_mils_security_bell_lapadula
              (sys => sys, result => a_response, output => output);

         when mils_compute_security_biba =>
            compute_mils_security_biba
              (sys => sys, result => a_response, output => output);

            -----------------------------------------------------------
            -----------------------------------------------------------

         when scheduling_compute_scheduling_anomalies =>
            check_scheduling_anomalies
              (sys => sys, result => a_response, output => output);

      end case;

   exception
      when others =>
         a_response :=
           To_Unbounded_String (Exception_Name) & " " &
           To_Unbounded_String (Exception_Message);
   end call_a_request;

   procedure initialize_before_request (request : in framework_request) is
   begin
      case request.statement is
         when scheduling_simulation_time_line =>
            initialize (sched.all);
         when buffer_scheduling_simulation =>
            initialize (buff);
         when others =>
            null;
      end case;
   end initialize_before_request;

   function build_a_title
     (request : in framework_request) return Unbounded_String
   is
   begin

      case request.statement is

         when scheduling_simulation_basics =>
            return unbounded_lf & lb_scheduling_simulation (Current_Language);

         when scheduling_feasibility_basics =>
            return unbounded_lf & lb_scheduling_feasibility (Current_Language);

         when scheduling_simulation_time_line =>
            return empty_string;

         when scheduling_simulation_preemption_number  |
           scheduling_simulation_context_switch_number |
           scheduling_simulation_all_response_times    |
           scheduling_simulation_priority_inversion    |
           scheduling_simulation_deadlock              |
           scheduling_simulation_response_time         |
           scheduling_compute_scheduling_anomalies     |
           scheduling_simulation_blocking_time         =>
            return unbounded_lf & lb_scheduling_simulation (Current_Language);

         when scheduling_simulation_run_event_handler =>
            return
              unbounded_lf & lb_scheduling_simulation (Current_Language) &
              lb_comma & lb_event_analyzer (Current_Language);

         when buffer_scheduling_simulation =>
            return unbounded_lf & lb_draw_buffer (Current_Language);

         when random_response_time_density =>
            return unbounded_lf & lb_response_time_density (Current_Language);

         when scheduling_feasibility_first_fit =>
            return
              unbounded_lf & lb_scheduling_feasibility (Current_Language) &
              lb_comma & lb_partition (Current_Language) &
              lb_partition_first_fit (Current_Language);

         when scheduling_feasibility_general_task =>
            return
              unbounded_lf & lb_scheduling_feasibility (Current_Language) &
              lb_comma & lb_partition (Current_Language) &
              lb_partition_general_task (Current_Language);

         when scheduling_feasibility_best_fit =>
            return
              unbounded_lf & lb_scheduling_feasibility (Current_Language) &
              lb_comma & lb_partition (Current_Language) &
              lb_partition_best_fit (Current_Language);

         when scheduling_feasibility_next_fit =>
            return
              unbounded_lf & lb_scheduling_feasibility (Current_Language) &
              lb_comma & lb_partition (Current_Language) &
              lb_partition_next_fit (Current_Language);

         when scheduling_feasibility_small_task =>
            return
              unbounded_lf & lb_scheduling_feasibility (Current_Language) &
              lb_comma & lb_partition (Current_Language) &
              lb_partition_small_task (Current_Language);

         when scheduling_feasibility_compute_and_set_worst_case_blocking_time |
           scheduling_feasibility_compute_worst_case_blocking_time =>
            return unbounded_lf & lb_scheduling_feasibility (Current_Language);

         when scheduling_feasibility_periodic_task_worst_case_response_time |
           scheduling_feasibility_transaction_worst_case_response_time_audsley |
           scheduling_feasibility_transaction_worst_case_response_time_tindell |
           scheduling_feasibility_transaction_worst_case_response_time_palencia |
           scheduling_feasibility_transaction_worst_case_response_time_wcdops_plus |
           scheduling_feasibility_transaction_worst_case_response_time_wcdops_plus_nim |
           scheduling_feasibility_compute_resource_ceiling_priority |
           scheduling_feasibility_compute_and_set_resource_ceiling_priority |
           scheduling_feasibility_demand_bound_function |
           scheduling_feasibility_interval |
           scheduling_feasibility_cpu_utilization |
           memory_analysis_interferences_delays =>
            return unbounded_lf & lb_scheduling_feasibility (Current_Language);

         when memory_set_footprint_analysis  |
           memory_compute_footprint_analysis =>
            return
              unbounded_lf & lb_memory_requirement_analysis (Current_Language);

         when buffer_feasibility_tests =>
            return unbounded_lf & lb_compute_buffer (Current_Language);

         when select_feasibility_tests_simple =>
            return lb_select_simple (Current_Language);

         when scheduling_feasibility_tests_compositional =>
            return lb_select_compositional (Current_Language);

         when select_feasibility_test_by_name =>
            return lb_feasibility_test_by_name (Current_Language);

         when scheduling_set_priorities_according_to_deadline_monotonic  |
           scheduling_set_priorities_according_to_audsley_opa            |
           scheduling_set_priorities_according_to_opa_crpd_pt_simplified |
           scheduling_set_priorities_according_to_opa_crpd_pt            |
           scheduling_set_priorities_according_to_opa_crpd_tree          |
           scheduling_set_priorities_according_to_rate_monotonic         =>
            return
              unbounded_lf & unbounded_lf &
              lb_set_priorities (Current_Language);

         when dependency_compute_end_to_end_response_time_one_step |
           dependency_set_end_to_end_response_time_one_step        |
           dependency_compute_end_to_end_response_time_all_steps   |
           dependency_set_end_to_end_response_time_all_steps       =>
            return
              unbounded_lf & lb_jitter_from_response_time (Current_Language);

         when dependency_compute_chetto_blazewicz_priority |
           dependency_compute_chetto_blazewicz_deadline    |
           dependency_set_chetto_blazewicz_priority        |
           dependency_set_chetto_blazewicz_deadline        =>
            return lb_chetto (Current_Language);

         when cache_analysis_compute_cache_access_profile =>
            return lb_compute_cache_access_profile (Current_Language);

         when cache_analysis_import_cfg =>
            return lb_import_cfg (Current_Language);

         when cache_analysis_import_cfg_and_compute_cache_access_profile =>
            return
              lb_import_cfg_and_compute_cache_access_profile
                (Current_Language);

         when network_noc_compute_communication_delay        |
           network_noc_compute_path_delay                    |
           network_noc_compute_direct_interference_delay     |
           network_noc_compute_indirect_interference_delay   |
           network_set_noc_transformation_ectm_saf           |
           network_set_noc_transformation_ectm_wormhole      |
           network_set_noc_transformation_wcctm_saf          |
           network_set_noc_transformation_wcctm_wormhole     |
           network_compute_noc_transformation_ectm_saf       |
           network_compute_noc_transformation_ectm_wormhole  |
           network_compute_noc_transformation_wcctm_saf      |
           network_compute_noc_transformation_wcctm_wormhole =>
            return lb_noc_analysis (Current_Language);

         when network_compute_spacewire_transformation_scm |
           network_set_spacewire_transformation_scm        =>
            return lb_spacewire_analysis (Current_Language);

         when mils_compute_security_warshall |
           mils_compute_security_bell_lapadula | mils_compute_security_biba |
           mils_compute_security_chinese_wall =>
            return lb_mils_analysis (Current_Language);
      end case;

   end build_a_title;

   procedure sequential_framework_request
     (sys      : in out system_ptr; request : in framework_request_table;
      response : in out framework_response_table; order : in perform_order;
      output   : in     output_format)
   is
   begin
      check_initialize;

      sequential_framework_request (sys.all, request, response, order, output);
   end sequential_framework_request;

   procedure sequential_framework_request
     (sys      : in out system; request : in framework_request_table;
      response : in out framework_response_table; order : in perform_order;
      output   : in     output_format)
   is

      a_response  : framework_response;
      a_processor : generic_processor_ptr;
      my_iterator : processors_iterator;
      a_request   : sub_framework_request;

   begin
      check_initialize;

      for i in 0 .. request.nb_entries - 1 loop

         initialize_before_request (request.entries (i));

         -- Here, we should take care of two cases :
         -- case 1 : the called service should be run for
         --          each processor (that's the most of services)
         -- case 2 : the called service is global to all processor and
         --          should be called one time only
         --
         --
         if
           (request.entries (i).statement =
            scheduling_simulation_run_event_handler) or
           (request.entries (i).statement = memory_set_footprint_analysis) or
           (request.entries (i).statement =
            memory_compute_footprint_analysis) or
           (request.entries (i).statement = scheduling_simulation_time_line) or
           (request.entries (i).statement =
            scheduling_feasibility_small_task) or
           (request.entries (i).statement = scheduling_feasibility_best_fit) or
           (request.entries (i).statement = scheduling_feasibility_next_fit) or
           (request.entries (i).statement =
            scheduling_feasibility_first_fit) or
           (request.entries (i).statement =
            scheduling_feasibility_general_task) or
           (request.entries (i).statement =
            dependency_compute_end_to_end_response_time_one_step) or
           (request.entries (i).statement =
            dependency_set_end_to_end_response_time_one_step) or
           (request.entries (i).statement =
            dependency_compute_end_to_end_response_time_all_steps) or
           (request.entries (i).statement =
            dependency_set_end_to_end_response_time_all_steps) or
           (request.entries (i).statement =
            dependency_set_chetto_blazewicz_deadline) or
           (request.entries (i).statement =
            dependency_compute_chetto_blazewicz_priority) or
           (request.entries (i).statement =
            dependency_compute_chetto_blazewicz_deadline) or
           (request.entries (i).statement =
            dependency_set_chetto_blazewicz_priority) or
           (request.entries (i).statement =
            mils_compute_security_chinese_wall) or
           (request.entries (i).statement = mils_compute_security_warshall) or
           (request.entries (i).statement =
            mils_compute_security_bell_lapadula) or
           (request.entries (i).statement = mils_compute_security_biba) or
           (request.entries (i).statement =
            network_compute_spacewire_transformation_scm) or
           (request.entries (i).statement =
            network_set_spacewire_transformation_scm) or
           (request.entries (i).statement =
            network_noc_compute_communication_delay) or
           (request.entries (i).statement = network_noc_compute_path_delay) or
           (request.entries (i).statement =
            network_noc_compute_direct_interference_delay) or
           (request.entries (i).statement =
            network_noc_compute_indirect_interference_delay) or
           (request.entries (i).statement =
            network_compute_noc_transformation_ectm_saf) or
           (request.entries (i).statement =
            network_set_noc_transformation_ectm_saf) or
           (request.entries (i).statement =
            network_compute_noc_transformation_ectm_wormhole) or
           (request.entries (i).statement =
            network_set_noc_transformation_ectm_wormhole) or
           (request.entries (i).statement =
            network_compute_noc_transformation_wcctm_saf) or
           (request.entries (i).statement =
            network_set_noc_transformation_wcctm_saf) or
           (request.entries (i).statement =
            network_compute_noc_transformation_wcctm_wormhole) or
           (request.entries (i).statement =
            network_set_noc_transformation_wcctm_wormhole)
         then

            -- Only one call for all processors
            --
            Initialize (a_response);
            a_request.param     := request.entries (i).param;
            a_request.statement := request.entries (i).statement;

            call_a_request (sys, a_request, a_response.text, output);

            if a_response.text /= empty_string then

               if output /= xml_output then
                  a_response.title := build_a_title (request.entries (i));
                  if a_response.title /= empty_string then
                     a_response.title :=
                       unbounded_lf & unbounded_lf & a_response.title &
                       lb_colon & unbounded_lf;
                  end if;
               else 
                  xml_encoder.wrap_response (a_response.text, a_request.statement);
               end if;

               add (response, a_response);
            end if;

         else
            -- A call for each processor
            --
            reset_iterator (sys.processors, my_iterator);
            Initialize (a_response);
            a_request.param     := request.entries (i).param;
            a_request.statement := request.entries (i).statement;
            loop
            declare
            intermediate_response: Unbounded_String:= empty_string;
            begin
               current_element (sys.processors, a_processor, my_iterator);

               -- Do a request
               --
               if (a_processor.name = request.entries (i).target) or
                 (request.entries (i).target = empty_string)
               then
                  a_request.target    := a_processor;
                  call_a_request (sys, a_request, intermediate_response, output);

                  if intermediate_response /= empty_string then
                     if output /= xml_output then
                        a_response.text:=intermediate_response;
                        a_response.title :=
                          build_a_title (request.entries (i));
                        if a_response.title /= empty_string then
                           a_response.title :=
                             unbounded_lf & a_response.title & lb_comma &
                             lb_processor (Current_Language) &
                             a_processor.name & lb_colon & unbounded_lf;
                        end if;
                        add (response, a_response);
                        Initialize (a_response);
                        a_request.param     := request.entries (i).param;
                        a_request.statement := request.entries (i).statement;
                     else 
                        xml_encoder.wrap_processor (intermediate_response, a_processor);
                        a_response.text:= a_response.text & intermediate_response;
                     end if;
                  end if;

               end if;

               exit when is_last_element (sys.processors, my_iterator);

               next_element (sys.processors, my_iterator);
               end;
            end loop;
            if output = Call_Framework_Interface.Xml_Output then
               xml_encoder.wrap_response(a_response.text,a_request.statement);
               add (response, a_response);
            end if;
         end if;
      end loop;
   end sequential_framework_request;

   procedure parallel_framework_request
     (sys      : in out system; request : in framework_request_table;
      response : in out framework_response_table;
      order    : in     perform_order := total_order;
      output   : in     output_format := string_output)
   is
   begin
      check_initialize;
   end parallel_framework_request;

   procedure distributed_framework_request
     (sys      : in out system; request : in framework_request_table;
      response : in out framework_response_table;
      order    : in     perform_order := total_order;
      output   : in     output_format := string_output)
   is
   begin
      check_initialize;
   end distributed_framework_request;

end call_framework;
