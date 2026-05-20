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
-- Frank Singhoff, Lab-STICC UMR 6285, Université de Bretagne Occidentale
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
--    $Rev: 5285 $
--    $Date: 2024-12-03 00:14:26 +0100 (mar., 03 déc. 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------
with Ada.Tags;                          use Ada.Tags;
with Ada.Numerics;                      use Ada.Numerics;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with scheduler_io;                      use scheduler_io;
with Statements;                        use Statements;
with expressions;                       use expressions;
use expressions.variables_type_package;
with Processor_Interface;           use Processor_Interface;
with Tasks;                         use Tasks;
with Ada.Strings.Unbounded.Text_IO; use Ada.Strings.Unbounded.Text_IO;
with unbounded_strings;             use unbounded_strings;
with scheduler;                     use scheduler;
use scheduler.schedulers_table_package;
use scheduler.message_scheduling_information_list_package;
with scheduler_builder;               use scheduler_builder;
with scheduler.user_defined;          use scheduler.user_defined;
with Scheduler_Interface;             use Scheduler_Interface;
with Interpreter.extended;            use Interpreter.extended;
with dependency_services;             use dependency_services;
with translate;                       use translate;
with io_tools;                        use io_tools;
with Ada.IO_Exceptions;               use Ada.IO_Exceptions;
with Ada.Exceptions;                  use Ada.Exceptions;
with xml_generic_parsers;             use xml_generic_parsers;
with xml_generic_parsers.event_table; use xml_generic_parsers.event_table;
with Input_Sources.File;              use Input_Sources.File;
with Sax.Readers;                     use Sax.Readers;
with Text_IO;                         use Text_IO;
with Ada.Text_IO.Text_Streams;        use Ada.Text_IO.Text_Streams;
with Parser;                          use Parser;
with Sections;                        use Sections;
with section_set;                     use section_set;
with Address_Spaces;                  use Address_Spaces;
with debug;                           use debug;
with scheduler.hierarchical.offline;  use scheduler.hierarchical.offline;
with event_analyzers.extended;        use event_analyzers.extended;
with Core_Units;                      use Core_Units;
use Core_Units.Core_Units_Table_Package;
with buffer_set; use buffer_set;
use buffer_set.generic_buffer_set;
with resource_set; use resource_set;
use resource_set.generic_resource_set;
with battery_set; use battery_set;
with processor_set; use processor_set;
with tdma; use tdma;
with DOM.Core.Documents;
use DOM.Core, DOM.Core.Documents;
with DOM.Core;              use DOM.Core;
with DOM.Core.Nodes;        use DOM.Core.Nodes;
with DOM.Readers;           use DOM.Readers;
with GNAT.Command_Line;     use GNAT.Command_Line;
with GNAT.Expect;           use GNAT.Expect;
with GNAT.OS_Lib;           use GNAT.OS_Lib;
with Input_Sources.File;    use Input_Sources.File;
with Input_Sources.Http;    use Input_Sources.Http;
with Input_Sources;         use Input_Sources;
with Sax.Readers;           use Sax.Readers;
with Sax.Symbols;
with Sax.Utils;             use Sax.Utils;
with Sax.Encodings;         use Sax.Encodings;
with Unicode.CES;           use Unicode.CES;
with Unicode.Encodings;     use Unicode.Encodings;
with Ada.Direct_IO;
with primitive_write_xml;   use primitive_write_xml;
with primitive_xml_strings; use primitive_xml_strings;
with scheduling_anomalies_services.online;
use scheduling_anomalies_services.online;
with voltage_scaling; use voltage_scaling;
with arinc653_tools;  use arinc653_tools;

package body multiprocessor_services is
   -------------------------------------
   -- Internal data of the simulator
   -------------------------------------

   -- Data simulation
   --
   tmp_buffers   : array (scheduling_table_range) of buffers_set;
   tmp_tasks     : array (scheduling_table_range) of tasks_set;
   tmp_resources : array (scheduling_table_range) of resources_set;
   si            : scheduling_information;

   -- Tables of scheduler instances that are used to compute the
   -- scheduling
   --
   table_of_address_space_scheduler : array
   (scheduling_table_range) of scheduler_table;
   table_of_core_scheduler : array (scheduling_table_range) of scheduler_table;

   -- Various pointers and iterators
   --
   a_address_space_scheduler : address_space_scheduler_ptr;
   a_core_scheduler          : core_scheduler_ptr;
   iterator1                 : processors_iterator;
   iterator2                 : address_spaces_iterator;
   iterator3                 : core_units_iterator;
   a_addr                    : address_space_ptr;
   a_processor               : generic_processor_ptr;
   pcb_id                    : processors_range;

   -- Variables to drive the main loop of the simulation
   --
   last_current_time     : Natural                                   := 0;
   current_time : array (scheduling_table_range) of Natural := (others => 0);
   elected               : tasks_range := tasks_range'first;
   no_task               : Boolean                                   := True;
   must_perform_election : Boolean                                   := True;

   -- Variable to store an event table (to be used by a scheduler)
   --
   partition_sched : scheduling_table_ptr;

   -- Variable to store .sc file of .XML file content
   --
   file_content : Unbounded_String;

   -----------------------------------------------------
   --  The two following subprograms are the main entry
   --  point of the cheddar scheduling simulator
   -----------------------------------------------------

   procedure initialize_multiprocessor_scheduling
     (sys               : in     system;
      result            : in out scheduling_table_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table;
      last_time         : in     Natural;
      options           : in     scheduling_option)
   is
      partition_filename : unbounded_string := empty_string;
   begin
      put_debug
        ("initialize_Multiprocessor_Scheduling : initialize internal simulator variables ",
         very_verbose);

      for i in scheduling_table_range loop
         current_time (i) := 0;
         reset (tmp_buffers (i));
         reset (tmp_tasks (i));
         reset (tmp_resources (i));
         initialize (table_of_address_space_scheduler (i));
         initialize (table_of_core_scheduler (i));
      end loop;

      initialize (si);

      last_current_time     := 0;
      elected               := tasks_range'first;
      no_task               := True;
      must_perform_election := True;

      si.tdma_frame := sys.tdma_frame;
      si.empty_tdma_frame:=is_empty(sys.tdma_frame);
   
      if not si.empty_tdma_frame then
         si.current_tdma_slot:=1;
         si.current_tdma_duration:=si.tdma_frame(1).duration;
      end if;

      put_debug("Initial TDMA trame/duration are " & si.current_tdma_slot'img & " " & si.current_tdma_duration'img);

      -------------------------------------------------------------------------
      -- Before initialization, check if the tasks can be
      -- scheduled with the selected scheduler
      --
      -- If so, we prepar the scheduling result (i.e. table of
      -- scheduling_sequence, with one scheduling_sequence per processor)
      -- otherwise, a error message is prepared instead
      ---------------------------------------------------------
      put_debug
        ("initialize_Multiprocessor_Scheduling : check scheduler compliancy of tasks",
         very_verbose);

      reset_iterator (sys.processors, iterator1);

      loop
         current_element (sys.processors, a_processor, iterator1);
         begin
            result.entries (result.nb_entries).item := a_processor;
            result.entries (result.nb_entries).data.scheduling_msg :=
              empty_string;
            result.entries (result.nb_entries).data.error_msg := empty_string;

            if
              (get_number_of_task_from_processor
                 (sys.tasks,
                  a_processor.name) /=
               0)
            then
               -- Build core scheduler table
               --
               initialize (table_of_core_scheduler (result.nb_entries));

               a_processor :=
                 search_processor (sys.processors, a_processor.name);
               if a_processor.processor_type = monocore_type then
                  a_core_scheduler           := new core_scheduler;
                  a_core_scheduler.scheduler :=
                    build_a_scheduler
                      (mono_core_processor_ptr (a_processor).core,
                       a_processor);
                  a_core_scheduler.entity :=
                    mono_core_processor_ptr (a_processor).core;
                  add
                    (table_of_core_scheduler (result.nb_entries),
                     entity_scheduler_ptr (a_core_scheduler));

               else
                  for k in
                    0 ..
                        multi_cores_processor_ptr (a_processor).cores
                          .nb_entries -
                        1
                  loop
                     a_core_scheduler           := new core_scheduler;
                     a_core_scheduler.scheduler :=
                       build_a_scheduler
                         (multi_cores_processor_ptr (a_processor).cores.entries
                            (k),
                          a_processor);
                     a_core_scheduler.entity :=
                       multi_cores_processor_ptr (a_processor).cores.entries
                         (k);
                     add
                       (table_of_core_scheduler (result.nb_entries),
                        entity_scheduler_ptr (a_core_scheduler));
                  end loop;
               end if;

            -- Check that the scheduler can be run  on the architecture model
               --
               for core_id in
                 0 ..
                     table_of_core_scheduler (result.nb_entries).nb_entries - 1
               loop
                  check_before_scheduling
                    (table_of_core_scheduler (result.nb_entries).entries
                       (core_id)
                       .scheduler.all,
                     sys.tasks,
                     a_processor.name);
               end loop;

               if options.with_precedencies then
                  dependencies_harmonic_periods_control
                    (sys.tasks,
                     sys.dependencies,
                     a_processor.name);
               end if;

            else
               result.entries (result.nb_entries).data.error_msg :=
                 lb_minus & lb_define_tasks_before (Current_Language);

            end if;

         exception
            when dependency_services.dependencies_period_error =>
               result.entries (result.nb_entries).data.error_msg :=
                 lb_minus &
                 lb_precedencies_period_error (Current_Language) &
                 unbounded_lf;
            when task_set.task_must_be_periodic =>
               result.entries (result.nb_entries).data.error_msg :=
                 lb_minus &
                 lb_compute_scheduling_error_15 (Current_Language) &
                 unbounded_lf;
            when task_set.task_must_have_period_equal_to_deadline =>
               result.entries (result.nb_entries).data.error_msg :=
                 lb_minus &
                 lb_compute_scheduling_error_14 (Current_Language) &
                 unbounded_lf;
            when task_set.task_model_error =>
               result.entries (result.nb_entries).data.error_msg :=
                 lb_minus &
                 lb_compute_scheduling_error_1 (Current_Language) &
                 unbounded_lf;
            when task_set.priority_error =>
               result.entries (result.nb_entries).data.error_msg :=
                 lb_minus &
                 lb_compute_scheduling_error_11 (Current_Language) &
                 unbounded_lf;

         end;

         result.nb_entries := result.nb_entries + 1;

         exit when is_last_element (sys.processors, iterator1);
         next_element (sys.processors, iterator1);

      end loop;

      ---------------------------------------------------------
      -- Now, perform scheduling simulation initialization
      -- This initialization is made in 5 steps :
      --   1) initialization of variables to all processors and core units
      --   2) gather all the data that will be handled by the simulateur
      --   3) initialization of each processor
      --   4) initialization of each core unit
      --   5) Loading of all text file that may be uses by the simulator
      --      e.g. user defined scheduler, offline scheduling, ...
      --        by the schedulers
      --   6) basic initialization that are specific for each scheduler
      ---------------------------------------------------------

      ------------------------------------------------
      -- Step 1 : initialization of variables to all processors and core units
      --
      put_debug
        ("initialize_Multiprocessor_Scheduling : initialization of processor and core units variables",
         very_verbose);

      -- Variables to store architecture model to simulate
      --

      si.number_of_tasks          := 0;
      si.number_of_resources      := 0;
      si.number_of_processors     := get_number_of_elements (sys.processors);
      si.number_of_address_spaces :=
        get_number_of_elements (sys.address_spaces);
      si.simulation_length := last_time;

      for z in tasks_range loop
         si.tcbs (z) := null;
      end loop;

     for z in processors_range loop
         si.pcbs (z) := null;
     end loop;
     pcb_id:=processors_range'first;
     if not is_empty (sys.processors) then
        reset_iterator (sys.processors, iterator1);
        loop
            current_element (sys.processors, a_processor, iterator1);
            si.pcbs(pcb_id):= new pcb;
            si.pcbs(pcb_id).cpu:=a_processor;
            si.pcbs(pcb_id).is_idle:=true;

            exit when is_last_element (sys.processors, iterator1);
            next_element (sys.processors, iterator1);
            pcb_id:=pcb_id+1;
        end loop;
      end if;

      duplicate (sys.batteries, si.batteries);
      duplicate (sys.processors, si.processors);
      si.dependencies := new tasks_dependencies;
      duplicate (sys.dependencies, si.dependencies);

      for z in resources_range loop
         si.shared_resources (z) := null;
      end loop;

      for j in 0 .. result.nb_entries - 1 loop
         if result.entries (j).data.error_msg = empty_string then

            current_processor_name := result.entries (j).item.name;

            put_debug
              ("initialize_Multiprocessor_Scheduling : initialization of processor " &
               current_processor_name,
               very_verbose);

            ------------------------------------------------
            -- Step 2 :  gather all the data that will be handled by the
            -- simulateur
            --

            -- Select tasks/resources/buffers for processor j
            --
            select_and_copy (sys.tasks, tmp_tasks (j), select_cpu'access);

            if (not is_empty (tmp_tasks (j))) then
               select_and_copy
                 (sys.resources,
                  tmp_resources (j),
                  select_cpu'access);
               select_and_copy
                 (sys.buffers,
                  tmp_buffers (j),
                  select_cpu'access);

               -- Build address spaces scheduler table for processor j
               --
               initialize (table_of_address_space_scheduler (j));
               if not is_empty (sys.address_spaces) then
                  reset_iterator (sys.address_spaces, iterator2);
                  loop
                     current_element (sys.address_spaces, a_addr, iterator2);

                     if (a_addr.cpu_name = current_processor_name) and
                       (a_addr.scheduling.scheduler_type /=
                        no_scheduling_protocol)
                     then
                        a_address_space_scheduler :=
                          new address_space_scheduler;
                        a_processor :=
                          search_processor
                            (sys.processors,
                             current_processor_name);
                        a_address_space_scheduler.scheduler :=
                          build_a_scheduler (a_addr, a_processor);
                        a_address_space_scheduler
                          .corresponding_address_space :=
                          a_addr;
                        add
                          (table_of_address_space_scheduler (j),
                           entity_scheduler_ptr (a_address_space_scheduler));
                     end if;
                     exit when is_last_element (sys.address_spaces, iterator2);
                     next_element (sys.address_spaces, iterator2);
                  end loop;
               end if;

               ------------------------------------------------
               --   Step 3 : initialization of each j processor
               --

               if options.with_dvfs then
                  dvfs_init_voltage_scaling (result.entries (j).item);
               end if;

               processor_initialization
                 (table_of_core_scheduler (j).entries (0).scheduler.all,
                  si,
                  result.entries (j).item.name,
                  tmp_tasks (j),
                  tmp_resources (j),
                  tmp_buffers (j),
                  result.entries (j).data.result,
                  options,
                  last_time,
                  event_to_generate,
                  sys.cache_access_profiles,
                  sys.caches);

               ----------------------------------------------------------------
               --   Step 4 :  initialization of each core unit of processor j
               --

               for core_id in 0 .. table_of_core_scheduler (j).nb_entries - 1
               loop
                  core_unit_initialization
                    (table_of_core_scheduler (j).entries (core_id)
                       .scheduler.all,
                     si,
                     result.entries (j).item.name,
                     tmp_tasks (j),
                     tmp_resources (j),
                     tmp_buffers (j),
                     result.entries (j).data.result,
                     options,
                     last_time,
                     event_to_generate);
               end loop;

               -------------------------------------------------------------------------------------
               --   Step 5 : Loading of all text file that may be used by schedulers of processor j
               --     e.g. user defined scheduler, offline scheduling, ...
               --

               for core_id in 0 .. table_of_core_scheduler (j).nb_entries - 1
               loop
                  begin
                     if get_name
                         (table_of_core_scheduler (j).entries (core_id)
                            .scheduler.all) =
                       hierarchical_offline_protocol
                     then
                        -- the base directory of the arinc653 partition table can be set with Set_Arinc653_Partition_Table_Directory
                        partition_filename :=
                          get_arinc653_partition_table_filename
                            (table_of_core_scheduler (j).entries (core_id)
                               .scheduler
                               .parameters
                               .user_defined_scheduler_source_file_name);

                        read_from_xml_file
                          (partition_sched,
                           sys,
                           partition_filename);
                        set_event_table
                          (hierarchical_offline_scheduler
                             (table_of_core_scheduler (j).entries (core_id)
                                .scheduler.all),
                           partition_sched);
                     end if;

                     if get_name
                         (table_of_core_scheduler (j).entries (core_id)
                            .scheduler.all) =
                       automata_user_defined_protocol or
                       get_name
                           (table_of_core_scheduler (j).entries (core_id)
                              .scheduler.all) =
                         pipeline_user_defined_protocol
                     then
                        file_content :=
                          read_sequential_file
                            (table_of_core_scheduler (j).entries (core_id)
                               .scheduler
                               .parameters
                               .user_defined_scheduler_source_file_name);
                        set_string_behavior
                          (user_defined_scheduler
                             (table_of_core_scheduler (j).entries (core_id)
                                .scheduler.all),
                           file_content);
                     end if;

                  exception
                     when Ada.IO_Exceptions.Name_Error =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              table_of_core_scheduler (j).entries (core_id)
                                .scheduler
                                .parameters
                                .user_defined_scheduler_source_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)) &
                           ", Name_Error");
                     when Ada.IO_Exceptions.Status_Error =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              table_of_core_scheduler (j).entries (core_id)
                                .scheduler
                                .parameters
                                .user_defined_scheduler_source_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)) &
                           ", Status_Error");
                     when Ada.IO_Exceptions.Mode_Error =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              table_of_core_scheduler (j).entries (core_id)
                                .scheduler
                                .parameters
                                .user_defined_scheduler_source_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)) &
                           ", Mode_Error");
                     when Ada.IO_Exceptions.Use_Error =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              table_of_core_scheduler (j).entries (core_id)
                                .scheduler
                                .parameters
                                .user_defined_scheduler_source_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)) &
                           ", Use_Error");
                     when Ada.IO_Exceptions.Device_Error =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              table_of_core_scheduler (j).entries (core_id)
                                .scheduler
                                .parameters
                                .user_defined_scheduler_source_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)) &
                           ", Device_Error");
                     when Ada.IO_Exceptions.End_Error =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              table_of_core_scheduler (j).entries (core_id)
                                .scheduler
                                .parameters
                                .user_defined_scheduler_source_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)) &
                           ", End_Error");
                     when Ada.IO_Exceptions.Data_Error =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              table_of_core_scheduler (j).entries (core_id)
                                .scheduler
                                .parameters
                                .user_defined_scheduler_source_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)) &
                           ", Data_Error");
                     when Ada.IO_Exceptions.Layout_Error =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              table_of_core_scheduler (j).entries (core_id)
                                .scheduler
                                .parameters
                                .user_defined_scheduler_source_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)) &
                           ", Layout_Error");
                     when others =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              table_of_core_scheduler (j).entries (core_id)
                                .scheduler
                                .parameters
                                .user_defined_scheduler_source_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)));
                  end;
               end loop;

      ------------------------------------------------------------------------
      --   Step 6 : basic initializations that are specific for each scheduler
               --
               for core_id in 0 .. table_of_core_scheduler (j).nb_entries - 1
               loop
                  specific_scheduler_initialization
                    (table_of_core_scheduler (j).entries (core_id)
                       .scheduler.all,
                     si,
                     result.entries (j).item.name,
                     To_Unbounded_String (""),
                     tmp_tasks (j),
                     table_of_address_space_scheduler (j),
                     tmp_resources (j),
                     tmp_buffers (j),
                     sys.messages,
                     result.entries (j).data.scheduling_msg);
               end loop;
            end if;
         end if;
      end loop;
   end initialize_multiprocessor_scheduling;

   procedure build_multiprocessor_scheduling
     (sys               : in     system;
      result            : in out scheduling_table_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table;
      last_time         : in     Natural;
      options           : in     scheduling_option)
   is
	
      procedure do_election
        (j       :    scheduling_table_range;
         core_id : in scheduler_table_range)
      is
      begin
         -- Preemptive case : if a task has been previously
         -- elected and if
         -- it has not ended its work => re-elect it !
         --
         must_perform_election := True;
         if
           (get_preemptive
              (table_of_core_scheduler (j).entries (core_id).scheduler.all) =
            not_preemptive)
         then

            if
              (table_of_core_scheduler (j).entries (core_id).scheduler
                 .previous_running_task_is_not_completed)
            then
               put_debug
                 ("Preemption management : task is not ended ",
                  very_verbose);
               elected :=
                 table_of_core_scheduler (j).entries (core_id).scheduler
                   .previously_elected;
               no_task               := False;
               must_perform_election := False;
            end if;
         end if;

         -- speed=0, then the processor is switched off ... no task to run
         --
         if table_of_core_scheduler (j).entries (core_id).scheduler
             .corresponding_core_unit
             .speed =
           0
         then
            no_task               := False;
            must_perform_election := False;
         end if;

         if must_perform_election then
            put_debug ("Call Do_Election ", very_verbose);
            do_election
              (table_of_core_scheduler (j).entries (core_id).scheduler.all,
               si,
               result.entries (j).data.result,
               result.entries (j).data.scheduling_msg,
               current_time (j),
               result.entries (j).item.name,
               To_Unbounded_String (""),
               table_of_core_scheduler (j).entries (core_id).scheduler
                 .corresponding_core_unit
                 .name,
               options,
               event_to_generate,
               elected,
               no_task);
         end if;
      end do_election;

      -- DISCARD missed deadline of jobs
      -- that are on the core core_id
      -- COMPUTE the next activation of those tasks's jobs
      --
      procedure discard_missed_deadline_tasks
        (j       : in scheduling_table_range;
         core_id : in scheduler_table_range)
      is
         abs_deadline           : Integer := 0;
         task_core_name         : Unbounded_String;
         task_processor_name    : Unbounded_String;
         coresponding_core      : Unbounded_String;
         coresponding_processor : Unbounded_String;
         is_on_core             : Boolean := False;
         speed                  : Integer := 1;
         a_item                 : time_unit_event_ptr;
      begin
         for i in 0 .. si.number_of_tasks - 1 loop
            -- Get the job's deadline
            abs_deadline :=
              si.tcbs (i).wake_up_time + si.tcbs (i).tsk.deadline;

            -- Get the core and cpu that tasks are assigned to
            --
            task_core_name      := si.tcbs (i).tsk.core_name;
            task_processor_name := si.tcbs (i).tsk.cpu_name;

            --Get the core and cpu name corresponding to core_id in processor j
            --
            coresponding_core :=
              table_of_core_scheduler (j).entries (core_id).scheduler
                .corresponding_core_unit
                .name;
            coresponding_processor :=
              table_of_core_scheduler (j).entries (core_id).scheduler
                .corresponding_processor
                .name;

            --Check only tasks that are on the core_id
            --2 possiblities:
            -- +1. A task is explicitly assigned to a core
            -- OR
            -- +2. A task is assigned to a single core processor and the task's core name is empty
            --
            if
              (task_core_name = coresponding_core or
               (coresponding_processor = task_processor_name and
                task_core_name = unbounded_strings.empty_string))
            then
               is_on_core := True;
               --  put_debug(task_core_name & " - "
               --            & task_processor_name & " / "
               --            & coresponding_core & " - "
               --            & coresponding_processor);
            end if;

            -- Check if the task's deadline is missed
            -- 3 conditions: (1) task is on the core, (2) time > abs_deadline, (3) still not finish
            --
            if
              (is_on_core and
               current_time (j) >= abs_deadline and
               si.tcbs (i).rest_of_capacity > 0)
            then
               put_debug
                 ("DISCARD task" &
                  si.tcbs (i).tsk.name &
                  " missed deadline " &
                  abs_deadline'img &
                  " at time" &
                  current_time (j)'img);
               -- When a deadline is missed, the current release of a task is suspended
               -- the scheduler moves to the next release of the task
               -- by updating the wake_up_time attribute
               --
               compute_next_task_activation
                 (table_of_core_scheduler (j).entries (core_id).scheduler.all,
                  si.tcbs (i),
                  si,
                  options,
                  i);

               if event_to_generate (discard_missed_deadline) then
                  produce_discard_missed_deadline_event
                    (table_of_core_scheduler (j).entries (core_id)
                       .scheduler.all,
                     si.tcbs (i),
                     options,
                     si,
                     a_item);
                  add
                    (result.entries (j).data.result.all,
                     current_time (j),
                     a_item);
                  put_debug ("GENERATE task discard missed deadline event");
               end if;

               if event_to_generate (task_activation) then
                  if
                    (si.tcbs (i).tsk.task_type /= aperiodic_type and
                     si.tcbs (i).wake_up_time <= last_time)
                  then
                     produce_task_activation_event
                       (table_of_core_scheduler (j).entries (core_id)
                          .scheduler.all,
                        si.tcbs (i),
                        options,
                        si,
                        a_item);
                     if (options.with_dvfs) then
                        dvfs_upon_task_release
                          (a_item,
                           si.tcbs (i).wake_up_time,
                           speed);
                        table_of_core_scheduler (j).entries (core_id)
                          .scheduler.all
                          .corresponding_core_unit
                          .speed :=
                          speed;
                     end if;
                     add
                       (result.entries (j).data.result.all,
                        si.tcbs (i).wake_up_time,
                        a_item);
                  end if;
               end if;

            end if;
         end loop;
      end discard_missed_deadline_tasks;

      elected_per_core : array
      (schedulers_table_package.table_range) of tasks_range;
      no_task_per_core : array
      (schedulers_table_package.table_range) of Boolean;

      i : tasks_range := 0;

   begin
      put_debug ("Call Build_Multiprocessor_Scheduling", very_verbose);

      initialize_multiprocessor_scheduling
        (sys,
         result,
         event_to_generate,
         last_time,
         options);

      if (options.with_anomaly_detection) then
         scheduling_anomalies_services.online.scheduling_anomaly_register
           (sys);
      end if;

      --------------------------------------------------------------
      -- Now, we compute the scheduling of the overall architecture
      --------------------------------------------------------------

      while (last_current_time < last_time) loop

         last_current_time := Natural'last;

         -- Initialized TCB variables that have to be initiliazed
         -- for each unit of time
         --
         for i in 0 .. si.number_of_tasks - 1 loop
            si.tcbs (i).already_run_at_current_time := False;
            si.tcbs (i).wait_for_a_resource         := null;
         end loop;
  



         -- J is the processor 
         --
         for j in 0 .. result.nb_entries - 1 loop

            if (result.entries (j).data.error_msg = empty_string) then

               if (current_time (j) < last_time) then

		  si.pcbs(processors_range(j)).is_idle:=true; 
                  for core_id in
                    0 .. table_of_core_scheduler (j).nb_entries - 1
                  loop

                     put_debug
                       ("Build_Multiprocessor_Scheduling : compute scheduling of time " &
                        To_Unbounded_String
                          (Natural'image (current_time (j))) &
                        " for core " &
                        core_id'img,
                        very_verbose);

                     ------------------------------------------------------
                     -- DISCARD missed deadline of jobs
                     -- that are on the core core_id
                     -- COMPUTE the next activation of those tasks's jobs
                     --
                     if (options.with_discard_missed_deadlines) then
                        discard_missed_deadline_tasks (j, core_id);
                     end if;

                     ------------------------------------------------------
                     -- Elect a task to run
                     --
                     do_election (j, core_id);

                     elected_per_core (core_id) := elected;
                     no_task_per_core (core_id) := no_task;

                     if not no_task_per_core (core_id) then
                        update_after_core_scheduling
                          (table_of_core_scheduler (j).entries (core_id)
                             .scheduler.all,
                           result.entries (j).item.name,
                           si,
                           sys.dependencies,
                           elected_per_core (core_id),
                           result.entries (j).data.result,
                           current_time (j),
                           last_time,
                           options,
                           event_to_generate);

		        -- Check if the processor is idle
                        --
		        si.pcbs(processors_range(j)).is_idle:=false; 
                     end if;

                  end loop;

                  -- Update task properties and produce events
                  --

                  for k in 0 .. table_of_core_scheduler (j).nb_entries - 1 loop

                     update_after_processor_scheduling
                       (table_of_core_scheduler (j).entries (k).scheduler.all,
                        result.entries (j).item.name,
                        si,
                        sys.dependencies,
                        elected_per_core (k),
                        result.entries (j).data.result,
                        current_time (j),
                        last_time,
                        options,
                        event_to_generate);

                     if not no_task_per_core (k) then
                        update_after_processor_scheduling_when_task_is_run
                          (table_of_core_scheduler (j).entries (k)
                             .scheduler.all,
                           result.entries (j).item.name,
                           si,
                           sys.dependencies,
                           elected_per_core (k),
                           result.entries (j).data.result,
                           current_time (j),
                           last_time,
                           options,
                           event_to_generate);
                     end if;

                  end loop;


                   -- Management of messages that are in the network entities
                   -- Update message status
                   --
  declare

      a_item         : time_unit_event_ptr;
      my_iterator    : tasks_dependencies_iterator;
      a_half_dep_ptr : dependency_ptr;
      list_ite       : message_scheduling_information_iterator;
      msg            : message_scheduling_information_ptr;

   begin

      if not is_empty (si.exchanged_messages) then


               reset_head_iterator (si.exchanged_messages, list_ite);
               loop
                   current_element (si.exchanged_messages, msg, list_ite);

                    if (msg.status=message_is_waiting_for_arbitration) then


            reset_iterator (si.dependencies.depends, my_iterator);
            loop
               current_element
                 (si.dependencies.depends,
                  a_half_dep_ptr,
                  my_iterator);

               if
                 (a_half_dep_ptr.type_of_dependency = tdma_communication_dependency)
                and (a_half_dep_ptr.tdma_communication_dependency_object.name = msg.exchanged_message.name)
                and (a_half_dep_ptr.tdma_communication_orientation = from_task_to_object)
               then
 if not si.empty_tdma_frame then
                      if is_emitter_present(si.tdma_frame, si.current_tdma_slot, a_half_dep_ptr.tdma_communication_dependent_task.name)   then

	             msg.status := message_is_sent;
                     msg.time := current_time(j);


                     if event_to_generate (send_message) then
                        a_item := new time_unit_event (send_message);
                        a_item.send_message := msg.exchanged_message;
                        a_item.send_task    := a_half_dep_ptr.tdma_communication_dependent_task;
                        a_item.send_status  := msg.status;
                        add
                          (result.entries (j).data.result.all,
                           msg.time,
                           a_item);
                     end if;
                   end if;
                  end if;
               end if;

               exit when is_last_element
                   (si.dependencies.depends,
                    my_iterator);

               next_element (si.dependencies.depends, my_iterator);

         end loop;
        end if;

                           if is_tail_element
                               (si.exchanged_messages,
                                list_ite)
                           then
                              exit;
                           end if;
                           next_element (si.exchanged_messages, list_ite);
      end loop;
        end if;
   end;


-- Move to the next simulation time
--
                  current_time (j) := current_time (j) + 1;

                  last_current_time :=
                    Natural'min (last_current_time, current_time (j));

               end if;
            end if;


end loop;

                  -- Management of TDMA slots
                  --
                  -- If the current slot is completed then move to the 
                  -- next slot, either decrement slot duration
                  --
      		  if not si.empty_tdma_frame then
                    if (si.current_tdma_duration=1) 
                    then
                       -- Move to the next frame slot
                       --
                       if (si.current_tdma_slot=slot_id_type(maximum_slot_number))
			  then si.current_tdma_slot:=1;
			  else si.current_tdma_slot:=si.current_tdma_slot+1;
                       end if;
                       -- Check achieve an empty slot ... move back to the first slot
                       if (si.tdma_frame(si.current_tdma_slot).duration=0)
                          then si.current_tdma_slot:=1;
                       end if;
      		       si.current_tdma_duration:=si.tdma_frame(si.current_tdma_slot).duration;
                    else 
		       si.current_tdma_duration:=si.current_tdma_duration-1;
                    end if;
		    put_debug("TDMA trame/duration are " & si.current_tdma_slot'img & " " & si.current_tdma_duration'img);
                  end if;
                          


end loop;

   end build_multiprocessor_scheduling;


   procedure display_scheduling (sched : in scheduling_table_ptr) is
   begin
      Put_Line ("<event_table>");

      for i in 0 .. sched.nb_entries - 1 loop
         for j in 0 .. sched.entries (i).data.result.nb_entries - 1 loop
            Put ("  <time_unit>");
            Put (xml_string (sched.entries (i).data.result.entries (j).item));
            Put (xml_string (sched.entries (i).data.result.entries (j).data));
            Put_Line ("  </time_unit>");
         end loop;
      end loop;

      Put_Line ("</event_table>");
      New_Line;
      New_Line;
   end display_scheduling;

   procedure run_an_event_analyzer
     (sys               : in     system;
      sched             : in     scheduling_table_ptr;
      an_event_analyzer : in     event_analyzer_ptr;
      result            : in out Unbounded_String)
   is

      current : generic_statement_ptr;

      var,
      var_time,
      var_type,
      var_processor,
      var_message,
      var_resource,
      var_task,
      var_buffer : variables_range;

      global_sched : array (scheduling_table_range) of scheduling_sequence_ptr;

      global_sched_index : array (scheduling_table_range) of time_unit_range :=
        (others => 0);
      global_processor_name : array
      (scheduling_table_range) of Unbounded_String;

      global_sched_number        : scheduling_table_range      := 0;
      min_time                   : Natural                     := 0;
      current_min_time_processor : scheduling_table_range;
      ext_event_analyzer         : extended_event_analyzer_ptr :=
        extended_event_analyzer_ptr (an_event_analyzer);

      a_section : computation_section_ptr;

   begin

      begin
         ext_event_analyzer.string_behavior :=
           read_sequential_file
             (ext_event_analyzer.event_analyzer_source_file_name);

      exception
         when Ada.IO_Exceptions.Name_Error =>
            Raise_Exception
              (parametric_file_error'identity,
               To_String
                 (lb_file (Current_Language) &
                  lb_colon &
                  ext_event_analyzer.event_analyzer_source_file_name &
                  lb_comma &
                  lb_can_not_open_file (Current_Language)) &
               ", Name_Error");
         when Ada.IO_Exceptions.Status_Error =>
            Raise_Exception
              (parametric_file_error'identity,
               To_String
                 (lb_file (Current_Language) &
                  lb_colon &
                  ext_event_analyzer.event_analyzer_source_file_name &
                  lb_comma &
                  lb_can_not_open_file (Current_Language)) &
               ", Status_Error");
         when Ada.IO_Exceptions.Mode_Error =>
            Raise_Exception
              (parametric_file_error'identity,
               To_String
                 (lb_file (Current_Language) &
                  lb_colon &
                  ext_event_analyzer.event_analyzer_source_file_name &
                  lb_comma &
                  lb_can_not_open_file (Current_Language)) &
               ", Mode_Error");
         when Ada.IO_Exceptions.Use_Error =>
            Raise_Exception
              (parametric_file_error'identity,
               To_String
                 (lb_file (Current_Language) &
                  lb_colon &
                  ext_event_analyzer.event_analyzer_source_file_name &
                  lb_comma &
                  lb_can_not_open_file (Current_Language)) &
               ", Use_Error");
         when Ada.IO_Exceptions.Device_Error =>
            Raise_Exception
              (parametric_file_error'identity,
               To_String
                 (lb_file (Current_Language) &
                  lb_colon &
                  ext_event_analyzer.event_analyzer_source_file_name &
                  lb_comma &
                  lb_can_not_open_file (Current_Language)) &
               ", Device_Error");
         when Ada.IO_Exceptions.End_Error =>
            Raise_Exception
              (parametric_file_error'identity,
               To_String
                 (lb_file (Current_Language) &
                  lb_colon &
                  ext_event_analyzer.event_analyzer_source_file_name &
                  lb_comma &
                  lb_can_not_open_file (Current_Language)) &
               ", End_Error");
         when Ada.IO_Exceptions.Data_Error =>
            Raise_Exception
              (parametric_file_error'identity,
               To_String
                 (lb_file (Current_Language) &
                  lb_colon &
                  ext_event_analyzer.event_analyzer_source_file_name &
                  lb_comma &
                  lb_can_not_open_file (Current_Language)) &
               ", Data_Error");
         when Ada.IO_Exceptions.Layout_Error =>
            Raise_Exception
              (parametric_file_error'identity,
               To_String
                 (lb_file (Current_Language) &
                  lb_colon &
                  ext_event_analyzer.event_analyzer_source_file_name &
                  lb_comma &
                  lb_can_not_open_file (Current_Language)) &
               ", Layout_Error");
         when others =>
            Raise_Exception
              (parametric_file_error'identity,
               To_String
                 (lb_file (Current_Language) &
                  lb_colon &
                  ext_event_analyzer.event_analyzer_source_file_name &
                  lb_comma &
                  lb_can_not_open_file (Current_Language)));
      end;

      -- We should check the scheduler behavior syntax ...
      --
      Open_Input (ext_event_analyzer.string_behavior);
      Parser.First_File (ext_event_analyzer.event_analyzer_source_file_name);
      create_parametric_variables (Parser.Variables_Table, sys.tasks);
      Parser.Yyparse;

      -- Store syntax tree and compiling information
      --
      begin
         a_section :=
           computation_section_ptr
             (search_section
                (Parser.Root_Statement_Pointer,
                 Sections.start_type));
         ext_event_analyzer.root_statement_pointer (Sections.start_type) :=
           a_section.first_statement;
      exception
         when others =>
            ext_event_analyzer.root_statement_pointer (Sections.start_type) :=
              null;
      end;

      begin
         a_section :=
           computation_section_ptr
             (search_section
                (Parser.Root_Statement_Pointer,
                 Sections.gather_event_analyzer_type));
         ext_event_analyzer.root_statement_pointer
           (Sections.gather_event_analyzer_type) :=
           a_section.first_statement;
      exception
         when others =>
            ext_event_analyzer.root_statement_pointer
              (Sections.gather_event_analyzer_type) :=
              null;
      end;

      begin
         a_section :=
           computation_section_ptr
             (search_section
                (Parser.Root_Statement_Pointer,
                 Sections.display_event_analyzer_type));
         ext_event_analyzer.root_statement_pointer
           (Sections.display_event_analyzer_type) :=
           a_section.first_statement;
      exception
         when others =>
            ext_event_analyzer.root_statement_pointer
              (Sections.display_event_analyzer_type) :=
              null;
      end;

      ext_event_analyzer.variables_table := Parser.Variables_Table;

      ext_event_analyzer.sets_table := Parser.Sets_Table;

      -- Initialize parametric variables which are constant
      --
      initialize_parametric_variables
        (ext_event_analyzer.variables_table,
         sys.messages,
         sys.buffers,
         sys.resources,
         sys.tasks);

      -- "nb_processors"
      --
      var :=
        find_variable
          (ext_event_analyzer.variables_table,
           To_Unbounded_String ("nb_processors"));
      ext_event_analyzer.variables_table.entries (var).simulation
        .integer_value :=
        Integer (get_number_of_elements (sys.processors));

      -- "nb_address_spaces"
      --
      var :=
        find_variable
          (ext_event_analyzer.variables_table,
           To_Unbounded_String ("nb_address_spaces"));
      ext_event_analyzer.variables_table.entries (var).simulation
        .integer_value :=
        Integer (get_number_of_elements (sys.address_spaces));

      -- Now : run "start" statements
      --
      current :=
        ext_event_analyzer.root_statement_pointer (Sections.start_type);
      dispatch
        (current,
         Sections.start_type,
         To_Unbounded_String ("none"),
         si,
         ext_event_analyzer.variables_table,
         result);

      -- Now : run "event analyzer" statements
      --
      current :=
        ext_event_analyzer.root_statement_pointer
          (Sections.gather_event_analyzer_type);

      -- Find variables before running the simulation
      --
      var_time :=
        find_variable
          (ext_event_analyzer.variables_table,
           To_Unbounded_String ("events.time"));
      var_type :=
        find_variable
          (ext_event_analyzer.variables_table,
           To_Unbounded_String ("events.type"));
      var_processor :=
        find_variable
          (ext_event_analyzer.variables_table,
           To_Unbounded_String ("events.processor_name"));
      var_message :=
        find_variable
          (ext_event_analyzer.variables_table,
           To_Unbounded_String ("events.message_name"));
      var_resource :=
        find_variable
          (ext_event_analyzer.variables_table,
           To_Unbounded_String ("events.resource_name"));
      var_task :=
        find_variable
          (ext_event_analyzer.variables_table,
           To_Unbounded_String ("events.task_name"));
      var_buffer :=
        find_variable
          (ext_event_analyzer.variables_table,
           To_Unbounded_String ("events.buffer_name"));

      -- how many processors scheduling should we run analysis ?
      --
      for i in 0 .. sched.nb_entries - 1 loop
         if (sched.entries (i).data.error_msg = empty_string) then
            global_sched (global_sched_number) :=
              sched.entries (i).data.result;
            global_processor_name (global_sched_number) :=
              sched.entries (i).item.name;
            global_sched_number := global_sched_number + 1;
         end if;
      end loop;

      -- Now, scan each time unit
      --
      while min_time /= Natural'last loop

         -- find the smallest time unit
         --
         min_time := Natural'last;
         for i in 0 .. global_sched_number - 1 loop
            if global_sched_index (i) < global_sched (i).nb_entries then
               if global_sched (i).entries (global_sched_index (i)).item <
                 min_time
               then
                  min_time :=
                    global_sched (i).entries (global_sched_index (i)).item;
                  current_min_time_processor := i;
               end if;
            end if;
         end loop;

         if min_time /= Natural'last then

            -- "events.time"
            --
            ext_event_analyzer.variables_table.entries (var_time).simulation
              .integer_value :=
              Integer
                (global_sched (current_min_time_processor).entries
                   (global_sched_index (current_min_time_processor))
                   .item);

            -- "events.type"
            --
            ext_event_analyzer.variables_table.entries (var_type).simulation
              .string_value :=
              to_lower
                (global_sched (current_min_time_processor).entries
                   (global_sched_index (current_min_time_processor))
                   .data
                   .type_of_event'
                   img);

            -- "events.processor_name"
            --
            ext_event_analyzer.variables_table.entries (var_processor)
              .simulation
              .string_value :=
              global_processor_name (current_min_time_processor);

            -- "events.buffer_name"
            --
            ext_event_analyzer.variables_table.entries (var_buffer).simulation
              .string_value :=
              empty_string;

            -- "events.resource_name"
            --
            ext_event_analyzer.variables_table.entries (var_resource)
              .simulation
              .string_value :=
              empty_string;

            -- "events.message_name"
            --
            ext_event_analyzer.variables_table.entries (var_message).simulation
              .string_value :=
              empty_string;

            case global_sched (current_min_time_processor).entries
              (global_sched_index (current_min_time_processor))
              .data
              .type_of_event
            is

               when start_of_task_capacity =>
                  ext_event_analyzer.variables_table.entries (var_task)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .start_task
                      .name;

               when end_of_task_capacity =>
                  ext_event_analyzer.variables_table.entries (var_task)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .end_task
                      .name;

               when write_to_buffer =>
                  ext_event_analyzer.variables_table.entries (var_task)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .write_task
                      .name;
                  ext_event_analyzer.variables_table.entries (var_buffer)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .write_buffer
                      .name;

               when read_from_buffer =>

                  ext_event_analyzer.variables_table.entries (var_task)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .read_task
                      .name;

                  ext_event_analyzer.variables_table.entries (var_buffer)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .read_buffer
                      .name;

               when buffer_overflow =>
                  null;

               when buffer_underflow =>
                  null;

               when running_task =>
                  ext_event_analyzer.variables_table.entries (var_task)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .running_task
                      .name;

               when context_switch_overhead =>
                  ext_event_analyzer.variables_table.entries (var_task)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .switched_task
                      .name;

               when task_activation =>
                  ext_event_analyzer.variables_table.entries (var_task)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .activation_task
                      .name;

               when allocate_resource =>
                  ext_event_analyzer.variables_table.entries (var_task)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .allocate_task
                      .name;
                  ext_event_analyzer.variables_table.entries (var_resource)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .allocate_resource
                      .name;

               when release_resource =>
                  ext_event_analyzer.variables_table.entries (var_task)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .release_task
                      .name;
                  ext_event_analyzer.variables_table.entries (var_resource)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .release_resource
                      .name;

               when wait_for_resource =>
                  ext_event_analyzer.variables_table.entries (var_task)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .wait_for_resource_task
                      .name;
                  ext_event_analyzer.variables_table.entries (var_resource)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .wait_for_resource
                      .name;

               when send_message =>
                  ext_event_analyzer.variables_table.entries (var_task)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .send_task
                      .name;
                  ext_event_analyzer.variables_table.entries (var_message)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .send_message
                      .name;

               when receive_message =>
                  ext_event_analyzer.variables_table.entries (var_task)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .receive_task
                      .name;
                  ext_event_analyzer.variables_table.entries (var_message)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .receive_message
                      .name;

               when wait_for_memory =>
                  null;

               when address_space_activation =>
                  ext_event_analyzer.variables_table.entries (var_task)
                    .simulation
                    .string_value :=
                    global_sched (current_min_time_processor).entries
                      (global_sched_index (current_min_time_processor))
                      .data
                      .activation_address_space;

               when preemption =>
                  null;

               when discard_missed_deadline =>
                  null;

               when mode_change =>
                  null;

               when tdma_slot =>
                  null;

               when energy =>
                  null;
            end case;

            -- Do analysis on the current time : run "event_analyzer"
            --section/statements
            --
            dispatch
              (current,
               Sections.gather_event_analyzer_type,
               To_Unbounded_String ("none"),
               si,
               ext_event_analyzer.variables_table,
               result);

            global_sched_index (current_min_time_processor) :=
              global_sched_index (current_min_time_processor) + 1;

         end if;

      end loop;

      -- The end of the line : run "display_event" section/statements
      --
      current :=
        ext_event_analyzer.root_statement_pointer
          (Sections.display_event_analyzer_type);
      dispatch
        (current,
         Sections.display_event_analyzer_type,
         To_Unbounded_String ("none"),
         si,
         ext_event_analyzer.variables_table,
         result);

   end run_an_event_analyzer;

   procedure write_to_xml_file
     (sched     : in scheduling_table_ptr;
      sys       : in system;
      file_name : in String)
   is
   begin
      write_to_xml_file (sched, sys, To_Unbounded_String (file_name));
   end write_to_xml_file;

   procedure write_to_xml_file
     (sched     : in scheduling_table_ptr;
      sys       : in system;
      file_name : in Unbounded_String)
   is

      into   : File_Type;
      input  : file_input;
      reader : tree_reader;
      d      : document;
      result : Unbounded_String := To_unbounded_String("");

   begin

      -- Open file and Write XML Header
      --
      Create (into, Mode => Out_File, Name => To_String (file_name));

      get_xml_event_table(sched, sys, result);
      Put (into, result);

      Close (into);

      Open (To_String (file_name), input);
      Parse (reader, input);
      d := Get_Tree (reader);
      Close (input);

      Create (into, Mode => Out_File, Name => To_String (file_name));
      Write
        (Stream                => Stream (into),
         N                     => d,
         Print_Comments        => False,
         Print_XML_Declaration => True,
         With_URI              => False,
         EOL_Sequence          => "" & ASCII.LF,
         Pretty_Print          => True,
         Encoding              => Unicode.Encodings.Get_By_Name ("utf-8"),
         Collapse_Empty_Nodes  => False);

      Free (reader);
      Close (into);

   end write_to_xml_file;

   procedure get_xml_event_table
     (sched     : in scheduling_table_ptr;
      sys       : in system;
      result : in out Unbounded_String)
   is
   begin

      result := To_unbounded_String("<?xml version=""1.0"" standalone=""no""?>  ");
      --      Result := Result & "<!DOCTYPE Cheddar_Event_Table SYSTEM ""event_table.dtd"">";
      --      Result := Result &  "<?xml-stylesheet type=""text/xsl"" href=""event_table.xsl""?>";
      result := result & unbounded_lf & unbounded_lf; 

      result := result & "<event_table>" & unbounded_lf;

      for i in 0 .. sched.nb_entries - 1 loop
         for j in 0 .. sched.entries (i).data.result.nb_entries - 1 loop
            result := result & "<time_unit>";
            result := result &  xml_string (sched.entries (i).data.result.entries (j).item);
            result := result & "</time_unit>" & unbounded_lf;
            get_xml (result, sched.entries (i).data.result.entries (j).data);
         end loop;
      end loop;

      result := result &  "</event_table>" & unbounded_lf;
      result := result & unbounded_lf & unbounded_lf;
   end get_xml_event_table;

   procedure read_from_xml_file
     (sched     : in out scheduling_table_ptr;
      sys       : in     system;
      file_name : in     Unbounded_String)
   is

      read       : file_input;
      my_reader  : xml_event_table_parser;
      name_start : Natural;
      s          : constant String := To_String (file_name);

   begin

      --  Base file name should be used as the public Id
      --
      name_start := s'last;
      while name_start >= s'first and then s (name_start) /= '/' loop
         name_start := name_start - 1;
      end loop;
      Set_Public_Id (read, s (name_start + 1 .. s'last));
      Set_System_Id (read, s);
      Open (s, read);

      --  xmlns:* attributes will be reported in Start_Element
      --
      Set_Feature (my_reader, Namespace_Prefixes_Feature, False);
      Set_Feature (my_reader, Validation_Feature, True);

      set_scheduled_system (my_reader, sys);
      Parse (my_reader, read);
      sched := get_parsed_event_table (my_reader);
      Close (read);

   exception
      when XML_Fatal_Error =>
         Close (read);
         raise xml_read_error;

   end read_from_xml_file;

   procedure read_from_xml_file
     (sched     : in out scheduling_table_ptr;
      sys       : in     system;
      file_name : in     String)
   is
   begin
      read_from_xml_file (sched, sys, To_Unbounded_String (file_name));
   end read_from_xml_file;

   procedure free (sched : in out scheduling_table_ptr) is
      procedure free_pointer is new Unchecked_Deallocation
        (scheduling_table,
         scheduling_table_ptr);
   begin
      if sched /= null then
         for i in scheduling_table_range loop
            if sched.entries (i).data.result /= null then
               free (sched.entries (i).data.result);
            end if;
         end loop;
         free_pointer (sched);
      end if;
   end free;

end multiprocessor_services;
