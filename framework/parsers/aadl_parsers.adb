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
--    $Rev: 4589 $
--    $Date: 2023-09-29 16:02:19 +0200 (ven., 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with GNAT.OS_Lib;            use GNAT.OS_Lib;
with Ada.Exceptions;         use Ada.Exceptions;
with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;
with Ada.Strings;            use Ada.Strings;
with Ada.Strings.Maps;       use Ada.Strings.Maps;
with Ada.Text_IO;            use Ada.Text_IO;

with Ocarina.Analyzer.Queries; use Ocarina.Analyzer.Queries;
with Ocarina.Configuration;
with Ocarina.AADL.Parser;
with Ocarina.AADL.Printer;
with Ocarina.Analyzer;       use Ocarina.Analyzer;
with Ocarina.AADL;           use Ocarina.AADL;
with Types;                  use Types;
with Ocarina.Debug;          use Ocarina.Debug;
with Ocarina.Entities;       use Ocarina.Entities;
with Ocarina.Entities.Components; use Ocarina.Entities.Components;
with Ocarina.Entities.Properties; use Ocarina.Entities.Properties;
with Ocarina.Entities.Components.Connections;
use Ocarina.Entities.Components.Connections;
with Ocarina.Nutils;         use Ocarina.Nutils;
with Ocarina.Nodes;          use Ocarina.Nodes;
with Ocarina.AADL_Values;    use Ocarina.AADL_Values;
with Ocarina.AADL.Printer.Properties; use Ocarina.AADL.Printer.Properties;
with Ocarina.AADL.Printer.Components.Connections;
use Ocarina.AADL.Printer.Components.Connections;
with Ocarina.AADL.Printer.Components; use Ocarina.AADL.Printer.Components;
with Ocarina.Parser;
with Ocarina.Printer;        use Ocarina.Printer;

with Framework_Config;       use Framework_Config;
with Offsets;                use Offsets;
use Offsets.Offsets_Table_Package;
with Parameters;             use Parameters;
use Parameters.User_Defined_Parameters_Table_Package;
with debug;                  use debug;
with AADL_Config;            use AADL_Config;
with Resources;              use Resources;
use Resources.Resource_Accesses;
with resource_set;           use resource_set;
use resource_set.generic_resource_set;
with message_set;            use message_set;
use message_set.generic_message_set;
with event_analyzer_set;     use event_analyzer_set;
use event_analyzer_set.generic_event_analyzer_set;
with Tasks;                  use Tasks;
with task_set;               use task_set;
use task_set.generic_task_set;
with Address_Spaces;         use Address_Spaces;
with address_space_set;      use address_space_set;
use address_space_set.generic_address_space_set;
with Buffers;                use Buffers;
use Buffers.Buffer_Roles_Package;
with buffer_set;             use buffer_set;
use buffer_set.generic_buffer_set;
with task_dependencies;      use task_dependencies;
with time_unit_events;       use time_unit_events;
use time_unit_events.time_unit_package;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with Queueing_Systems;       use Queueing_Systems;
with GNAT.Current_Exception; use GNAT.Current_Exception;
with Scheduler_Interface;    use Scheduler_Interface;
with io_tools;               use io_tools;
with translate;              use translate;
with AADL_Parser_Interface;  use AADL_Parser_Interface;
use AADL_Parser_Interface.Processor_Binding_Package;
with Processors;             use Processors;
with unbounded_strings;      use unbounded_strings;
with Core_Units;             use Core_Units;
use Core_Units.Core_Units_Table_Package;
with Memories;               use Memories;
use Memories.Memories_Table_Package;
with doubles;                use Doubles;


package body aadl_parsers is

   --  Set to False means we have to reset Ocarina before
   --  re-initialize it.
   --
   first_aadl_parsing : Boolean := True;

   type pass_number_type is new Integer range 1 .. 3;

   critical_section_list : unbounded_string_list;

   --  Look for an AADL file from a set of directory and load it into
   --  Ocarina.
   --
   function load_aadl_file_from_directory
     (root      : node_id;
      file_name : Unbounded_String;
      dir_list  : unbounded_string_list) return node_id
   is
      a_dir    : unbounded_string_ptr;
      list_ite : unbounded_string_iterator;

   begin
      if not is_empty (dir_list) then
         reset_head_iterator (dir_list, list_ite);
         loop
            current_element (dir_list, a_dir, list_ite);
            put_debug
              ("Try to load AADL file " &
               a_dir.all &
               GNAT.OS_Lib.Directory_Separator &
               file_name);
            if can_be_read (a_dir.all & Directory_Separator & file_name) then
               put_debug
                 ("Load AADL file " &
                  a_dir.all &
                  Directory_Separator &
                  file_name);
               return Ocarina.AADL.Parser.Process
                   (To_String (a_dir.all & Directory_Separator & file_name),
                    root);
            end if;

            if is_tail_element (dir_list, list_ite) then
               exit;
            end if;
            next_element (dir_list, list_ite);
         end loop;
      end if;

      if can_be_read (file_name) then
         put_debug ("Load AADL file " & file_name);
         return Ocarina.AADL.Parser.Process (To_String (file_name), root);
      else
         put_debug ("CAN NOT Load AADL file " & file_name);
      end if;

      return root;
   end load_aadl_file_from_directory;

   function load_aadl_file_from_directory
     (root      : node_id;
      file_name : String;
      dir_list  : unbounded_string_list) return node_id
   is
   begin
      return load_aadl_file_from_directory
          (root,
           To_Unbounded_String (file_name),
           dir_list);
   end load_aadl_file_from_directory;

   -- Information retrieved from the AADL parser
   --
   dummy_identifier : Unbounded_String :=
     To_Unbounded_String ("__missing_cheddar_aadl_cpu_identifier__");

   name                      : Unbounded_String;
   deadline                  : Integer;
   start_time                : Integer;
   blocking_time             : Integer;
   criticality               : Integer;
   state                     : Integer;
   address                   : Integer;
   size                      : Integer;
   period                    : Integer;
   capacity                  : Integer;
   context_switch_overhead   : Integer;
   cpu_name                  : Unbounded_String;
   address_space_name        : Unbounded_String;
   jitter                    : Integer;
   policy                    : policies;
   task_type                 : tasks_type;
   seed                      : Integer;
   predictable               : Boolean;
   quantum                   : Integer;
   priority                  : Integer;
   priority_assignment       : priority_assignment_type;
   a_scheduler               : schedulers_type;
   a_network                 : Unbounded_String;
   protocol                  : resources_type;
   is_preemptive             : preemptives_type;
   text_memory_size          : Integer;
   text_memory_address_start : Integer;
   heap_memory_size          : Integer;
   data_memory_size          : Integer;
   stack_memory_size         : Integer;
   parametric_file_name      : Unbounded_String;
   automaton_name            : Unbounded_String;

   roles             : buffer_roles_table;
   a_role            : buffer_role;
   offset            : offsets_table;
   a_task_list_entry : critical_section;
   a_task_list       : resource_accesses_table;
   param             : user_defined_parameters_table;
   task1             : generic_task_ptr;

   ok : Boolean;

   cpu_bindings : processor_binding_table;

   procedure initialize_parsed_data is
   begin
      state                     := 0;
      size                      := 0;
      address                   := 0;
      task_type                 := aperiodic_type;
      policy                    := sched_fifo;
      is_preemptive             := preemptive;
      seed                      := 0;
      predictable               := True;
      priority                  := 1;
      priority_assignment       := automatic_assignment;
      name                      := To_Unbounded_String ("");
      deadline                  := 0;
      period                    := 0;
      start_time                := 0;
      criticality               := 0;
      blocking_time             := 0;
      capacity                  := 0;
      context_switch_overhead   := 0;
      jitter                    := 0;
      quantum                   := 0;
      a_scheduler               := no_scheduling_protocol;
      text_memory_size          := 0;
      text_memory_address_start := -1;
      heap_memory_size          := 0;
      data_memory_size          := 0;
      stack_memory_size         := 0;
      protocol                  := no_protocol;
      state                     := 1;

      a_network            := To_Unbounded_String ("");
      parametric_file_name := To_Unbounded_String ("");
      cpu_name             := To_Unbounded_String ("");
      address_space_name   := To_Unbounded_String ("");
      parametric_file_name := To_Unbounded_String ("");
      automaton_name       := To_Unbounded_String ("");

      Initialize (a_task_list_entry);
      initialize (a_task_list);
      initialize (offset);
      initialize (param);
      initialize (roles);
      Initialize (a_role);
      initialize (cpu_bindings);
   end initialize_parsed_data;

   procedure initialize_project_parser
     (handler : in out aadl_project_parser)
   is
   begin
      initialize (handler.parsed_system);
      initialize_parsed_data;
   end initialize_project_parser;

   function get_parsed_system (handler : aadl_project_parser) return system is
   begin
      return handler.parsed_system;
   end get_parsed_system;

   procedure initialize (handler : in out aadl_project_parser) is
   begin
      initialize (handler.parsed_system);
      initialize_parsed_data;
   end initialize;

   ------------------------------------------------------------------------
   -- Parse AADL properties
   ------------------------------------------------------------------------

   procedure read_property_associations
     (handler                 : in out aadl_project_parser;
      component_type          :        node_id;
      component_instance_name :        Unbounded_String;
      path                    :        Unbounded_String;
      pass                    :        pass_number_type)
   is

      -- Display a property (debug only)
      --
      procedure display_property (a_property_node : node_id) is
      begin
         if Aadl_Debug then
            if pass = 1 then
               Put ("First");
            elsif pass = 2 then
               Put ("Second");
            else
               Put ("Third");
            end if;
            Put (" pass ; ");
            Print_Property_Association
              (a_property_node,
               Default_Output_Options);
         end if;
      end display_property;

      -- AADL enumeration properties
      --
      procedure read_concurrency_control_protocol_property
        (a_property_value : node_id)
      is
         protocol_string : Unbounded_String;
      begin
         protocol_string :=
           to_lower
             (To_Unbounded_String
                (Get_Enumeration_Of_Property_Value (a_property_value)));

         To_Resources_Type (to_upper (protocol_string), protocol, ok);
         if not ok then
            Raise_Exception
              (aadl_read_error'identity,
               "Property Concurrency_Control_Protocol should store a valid" &
               " protocol name");
         end if;
      end read_concurrency_control_protocol_property;

      procedure read_scheduling_protocol_property
        (a_property_value : node_id)
      is
         scheduler_name : Unbounded_String;
      begin
         scheduler_name :=
           To_Unbounded_String
             (Get_Enumeration_Of_Property_Value (a_property_value));

         To_Schedulers_Type (to_upper (scheduler_name), a_scheduler, ok);

         if not ok then
            Raise_Exception
              (aadl_read_error'identity,
               "Property Scheduling_Protocol should store a valid" &
               " scheduler name");
         end if;
      end read_scheduling_protocol_property;

      procedure read_dispatch_protocol_property (a_property_value : node_id) is
         activation : Unbounded_String;
      begin
         activation :=
           to_lower
             (To_Unbounded_String
                (Get_Enumeration_Of_Property_Value (a_property_value)));

         if activation = "periodic" then
            task_type := periodic_type;

         elsif activation = "user_defined" then
            task_type := parametric_type;

         elsif activation = "poisson_process" then
            task_type := poisson_type;

         elsif activation = "sporadic" then
            task_type := sporadic_type;

         elsif activation = "background" then
            task_type := aperiodic_type;

         else
            Raise_Exception
              (aadl_read_error'identity,
               "Property Dispatch_Protocol should store" &
               " Periodic, Sporadic, Background, Poisson_Process" &
               " or User_Defined");
         end if;
      end read_dispatch_protocol_property;

      procedure read_posix_scheduling_policy_property
        (a_property_value : node_id)
      is
         policy_string : Unbounded_String;
      begin
         policy_string :=
           (To_Unbounded_String
              (Get_Enumeration_Of_Property_Value (a_property_value)));

         To_Policies (to_upper (policy_string), policy, ok);

         if not ok then
            Raise_Exception
              (aadl_read_error'identity,
               "Property POSIX_Scheduling_Policy should store " &
               "SCHED_FifO, SCHED_OTHERS or SCHED_RR");
         end if;
      end read_posix_scheduling_policy_property;

      --  AADLinteger/AADLfloat properties
      --
      procedure read_compute_execution_time_property
        (a_property_value : node_id)
      is
      begin
         capacity :=
           Integer'value
             (Ocarina.AADL_Values.Image
                (Value (Number_Value (Upper_Bound (a_property_value)))));
      end read_compute_execution_time_property;

      procedure read_period_property (a_property_value : node_id) is
      begin
         period :=
           Integer'value
             (Ocarina.AADL_Values.Image
                (Value (Number_Value (a_property_value))));
      end read_period_property;

      procedure read_context_switch_overhead_property
        (a_property_value : node_id)
      is
      begin
         context_switch_overhead :=
           Integer'value
             (Ocarina.AADL_Values.Image
                (Value (Number_Value (a_property_value))));
      end read_context_switch_overhead_property;

      procedure read_deadline_property (a_property_value : node_id) is
      begin
         deadline :=
           Integer'value
             (Ocarina.AADL_Values.Image
                (Value (Number_Value (a_property_value))));
      end read_deadline_property;

      procedure read_data_concurrency_state_property
        (a_property_value : node_id)
      is
      begin
         state :=
           Integer'value
             (Ocarina.AADL_Values.Image
                (Value (Number_Value (a_property_value))));
      end read_data_concurrency_state_property;

      procedure read_source_code_size_property (a_property_value : node_id) is
      begin
         text_memory_size :=
           Integer'value
             (Ocarina.AADL_Values.Image
                (Value (Number_Value (a_property_value))));
      end read_source_code_size_property;

      procedure read_source_data_size_property (a_property_value : node_id) is
      begin
         data_memory_size :=
           Integer'value
             (Ocarina.AADL_Values.Image
                (Value (Number_Value (a_property_value))));
      end read_source_data_size_property;

      procedure read_source_heap_size_property (a_property_value : node_id) is
      begin
         heap_memory_size :=
           Integer'value
             (Ocarina.AADL_Values.Image
                (Value (Number_Value (a_property_value))));
      end read_source_heap_size_property;

      procedure read_source_stack_size_property (a_property_value : node_id) is
      begin
         stack_memory_size :=
           Integer'value
             (Ocarina.AADL_Values.Image
                (Value (Number_Value (a_property_value))));
      end read_source_stack_size_property;

      procedure read_criticality_property (a_property_value : node_id) is
      begin
         criticality :=
           Integer'value
             (Ocarina.AADL_Values.Image
                (Value (Number_Value (a_property_value))));
      end read_criticality_property;

      procedure read_scheduler_quantum_property (a_property_value : node_id) is
      begin
         quantum :=
           Integer'value
             (Ocarina.AADL_Values.Image
                (Value (Number_Value (a_property_value))));
      end read_scheduler_quantum_property;

      procedure read_fixed_priority_property (a_property_value : node_id) is
      begin
         priority :=
           Integer'value
             (Ocarina.AADL_Values.Image
                (Value (Number_Value (a_property_value))));
      end read_fixed_priority_property;

      procedure read_dispatch_jitter_property (a_property_value : node_id) is
      begin
         jitter :=
           Integer'value
             (Ocarina.AADL_Values.Image
                (Value (Number_Value (a_property_value))));
      end read_dispatch_jitter_property;

      procedure read_bound_on_data_blocking_time_property
        (a_property_value : node_id)
      is
      begin
         blocking_time :=
           Integer'value
             (Ocarina.AADL_Values.Image
                (Value (Number_Value (a_property_value))));
      end read_bound_on_data_blocking_time_property;

      procedure read_dispatch_absolute_time_property
        (a_property_value : node_id)
      is
      begin
         start_time :=
           Integer'value
             (Ocarina.AADL_Values.Image
                (Value (Number_Value (a_property_value))));
      end read_dispatch_absolute_time_property;

      procedure read_dispatch_seed_value_property
        (a_property_value : node_id)
      is
      begin
         seed :=
           Integer'value
             (Ocarina.AADL_Values.Image
                (Value (Number_Value (a_property_value))));
      end read_dispatch_seed_value_property;

      -- AADL list properties
      --
      procedure read_task_precedencies_property
        (a_property_node  : node_id;
         a_property_value : node_id)
      is
         a_thread1 : generic_task_ptr;
         a_thread2 : generic_task_ptr;

         list_head : list_id;
         list_node : node_id;

         thread2_name : Unbounded_String;
         thread1_name : Unbounded_String;

      begin

         if not Is_Defined_List_Property
             (a_property_node,
              "cheddar_properties::task_precedencies")
         then
            Raise_Exception
              (aadl_read_error'identity,
               "Cheddar_Properties::Task_Precedencies property can not be found");
         end if;
         list_head :=
           Ocarina.Analyzer.Queries.Get_List_Property
             (a_property_node,
              "cheddar_properties::task_precedencies");
         list_node := First_Node (list_head);

         -- Parse task precedencies now
         --
         while Present (list_node) loop

            -- Get the two thread names
            --
            if Present (list_node) then
               thread1_name :=
                 to_lower
                   (To_Unbounded_String
                      (Ocarina.AADL_Values.Image (Value (list_node))));
               thread1_name :=
                 To_Unbounded_String
                   (Slice (thread1_name, 2, Length (thread1_name) - 1));
            else
               Raise_Exception
                 (aadl_read_error'identity,
                  "Cheddar_Properties::Task_Precedencies layout error (1)");
            end if;

            list_node := Next_Node (list_node);

            if Present (list_node) then
               thread2_name :=
                 to_lower
                   (To_Unbounded_String
                      (Ocarina.AADL_Values.Image (Value (list_node))));
               thread2_name :=
                 To_Unbounded_String
                   (Slice (thread2_name, 2, Length (thread2_name) - 1));
            else
               Raise_Exception
                 (aadl_read_error'identity,
                  "Cheddar_Properties::Task_Precedencies layout error (2)");
            end if;
            list_node := Next_Node (list_node);

            -- Full path thread name
            --
            thread1_name := path & thread1_name;
            thread2_name := path & thread2_name;

            begin
               a_thread1 :=
                 search_task (handler.parsed_system.tasks, thread1_name);
            exception
               when task_not_found =>
                  Raise_Exception
                    (aadl_read_error'identity,
                     "Cheddar_Properties::Task_Precedencies ; thread " &
                     To_String (thread1_name) &
                     " not found");

               when task_set.generic_task_set.empty_set =>
                  Raise_Exception
                    (aadl_read_error'identity,
                     "Cheddar_Properties::Task_Precedencies ; thread " &
                     To_String (thread1_name) &
                     " not found in empty set");
            end;

            begin
               a_thread2 :=
                 search_task (handler.parsed_system.tasks, thread2_name);
            exception
               when task_not_found =>
                  Raise_Exception
                    (aadl_read_error'identity,
                     "Cheddar_Properties::Task_Precedencies ; thread " &
                     To_String (thread2_name) &
                     " not found");

               when task_set.generic_task_set.empty_set =>
                  Raise_Exception
                    (aadl_read_error'identity,
                     "Cheddar_Properties::Task_Precedencies ; thread " &
                     To_String (thread2_name) &
                     " not found in empty set");
            end;

            -- Add the new task precedency
            --
            add_one_task_dependency_precedence
              (handler.parsed_system.dependencies,
               a_thread1,
               a_thread2);
         end loop;

      end read_task_precedencies_property;

      procedure read_critical_section_property
        (a_property_node  : node_id;
         a_property_value : node_id)
      is

         a_resource                                   : generic_resource_ptr;
         list_node                                    : node_id;
         list_head                                    : list_id;
         cs_start, cs_end, resource_name, thread_name : Unbounded_String;
         integer_ok                                   : Boolean;
         integer_cs_start, integer_cs_end             : Integer;
         resource_str_ptr                             : unbounded_string_ptr;

      begin

         if not Is_Defined_List_Property
             (a_property_node,
              "cheddar_properties::critical_section")
         then
            Raise_Exception
              (aadl_read_error'identity,
               "Cheddar_Properties::Critical_Section property can not be found");
         end if;
         list_head :=
           Ocarina.Analyzer.Queries.Get_List_Property
             (a_property_node,
              "cheddar_properties::critical_section");
         list_node := First_Node (list_head);

         -- Parse critical sections now
         --
         while Present (list_node) loop

            -- Resource name
            --
            if Present (list_node) then

               resource_name :=
                 to_lower
                   (To_Unbounded_String
                      (Ocarina.AADL_Values.Image (Value (list_node))));

               resource_name :=
                 To_Unbounded_String
                   (Slice (resource_name, 2, Length (resource_name) - 1));

            else
               Raise_Exception
                 (aadl_read_error'identity,
                  "Cheddar_Properties::Critical_Section value list " &
                  "should start with a resource name");
            end if;

            -- Thread name
            --
            list_node := Next_Node (list_node);
            if Present (list_node) then
               thread_name :=
                 to_lower
                   (To_Unbounded_String
                      (Ocarina.AADL_Values.Image (Value (list_node))));
               thread_name :=
                 To_Unbounded_String
                   (Slice (thread_name, 2, Length (thread_name) - 1));

            else
               Raise_Exception
                 (aadl_read_error'identity,
                  "Cheddar_Properties::Critical_Section, Thread name " &
                  "of critical section is missing");
            end if;

            -- Start of the critical section
            --
            list_node := Next_Node (list_node);
            if Present (list_node) then
               cs_start :=
                 To_Unbounded_String
                   (Ocarina.AADL_Values.Image (Value (list_node)));
               cs_start :=
                 To_Unbounded_String
                   (Slice (cs_start, 2, Length (cs_start) - 1));
            else
               Raise_Exception
                 (aadl_read_error'identity,
                  "Cheddar_Properties::Critical_Section, Start of critical " &
                  "section is missing");
            end if;

            -- End of the critical section
            --
            list_node := Next_Node (list_node);
            if Present (list_node) then
               cs_end :=
                 To_Unbounded_String
                   (Ocarina.AADL_Values.Image (Value (list_node)));
               cs_end :=
                 To_Unbounded_String (Slice (cs_end, 2, Length (cs_end) - 1));
            else
               Raise_Exception
                 (aadl_read_error'identity,
                  "Cheddar_Properties::Critical_Section, End of critical " &
                  "section is missing");
            end if;

            put_debug
              ("Critical section : " &
               To_String (resource_name & thread_name & cs_start & cs_end));

            list_node := Next_Node (list_node);

            -- Parser/add the critical sections
            --
            -- Full path resource name
            --
            resource_name :=
              path & component_instance_name & "." & resource_name;
            a_resource :=
              search_resource (handler.parsed_system.resources, resource_name);

            -- Full path thread name
            --
            thread_name := path & component_instance_name & "." & thread_name;

            to_integer (cs_start, integer_cs_start, integer_ok);
            if not ok then
               Raise_Exception
                 (aadl_read_error'identity,
                  To_String
                    (lb_task_begin (Current_Language) &
                     lb_must_be_numeric (Current_Language)));
            end if;

            to_integer (cs_end, integer_cs_end, integer_ok);
            if not integer_ok then
               Raise_Exception
                 (aadl_read_error'identity,
                  To_String
                    (lb_task_end (Current_Language) &
                     lb_must_be_numeric (Current_Language)));
            end if;

            -- Add the new critical section
            --
            a_resource.critical_sections.entries
              (a_resource.critical_sections.nb_entries)
              .item :=
              thread_name;
            a_resource.critical_sections.entries
              (a_resource.critical_sections.nb_entries)
              .data
              .task_begin :=
              integer_cs_start;
            a_resource.critical_sections.entries
              (a_resource.critical_sections.nb_entries)
              .data
              .task_end :=
              integer_cs_end;
            a_resource.critical_sections.nb_entries :=
              a_resource.critical_sections.nb_entries + 1;
            resource_str_ptr     := new Unbounded_String;
            resource_str_ptr.all := a_resource.name;
            add (critical_section_list, resource_str_ptr);

         end loop;

      end read_critical_section_property;

      procedure read_source_text_property (a_property_value : node_id) is
      begin
         parametric_file_name :=
           To_Unbounded_String
             (Ocarina.AADL_Values.Image (Value (a_property_value)));
         parametric_file_name :=
           To_Unbounded_String
             (Slice
                (parametric_file_name,
                 2,
                 Length (parametric_file_name) - 1));
      end read_source_text_property;

      procedure read_automaton_name_property (a_property_value : node_id) is
      begin
         automaton_name :=
           To_Unbounded_String
             (Ocarina.AADL_Values.Image (Value (a_property_value)));
         automaton_name :=
           To_Unbounded_String
             (Slice (automaton_name, 2, Length (automaton_name) - 1));
      end read_automaton_name_property;

      procedure read_actual_processor_binding_property
        (list_node       : node_id;
         a_property_node : node_id)
      is

         a_binding  : binding_record_type;
         applies_to : constant list_id := Applies_To_Prop (list_node);
         it_node    : node_id;

      begin
         it_node := First_Node (applies_to);

         while Present (it_node) loop
            address_space_name :=
              to_lower (To_Unbounded_String (Image (Display_Name (it_node))));
            it_node := Next_Node (it_node);
         end loop;

         cpu_name :=
           to_lower
             (To_Unbounded_String
                (Get_Name_Of_Entity_Reference (a_property_node)));

         a_binding.cpu_name           := path & cpu_name;
         a_binding.address_space_name := path & address_space_name;
         add (cpu_bindings, a_binding);

         if Aadl_Debug then
            Put_Line
              ("Process/processor binding =  " &
               To_String (a_binding.address_space_name) &
               "/" &
               To_String (a_binding.cpu_name));
         end if;
      end read_actual_processor_binding_property;

      -- AADL boolean properties
      --
      procedure read_dispatch_seed_is_predictable_property
        (a_property_value : node_id)
      is
      begin
         predictable := Get_Boolean_Of_Property_Value (a_property_value);
      end read_dispatch_seed_is_predictable_property;

      procedure read_preemptive_scheduler_property
        (a_property_value : node_id)
      is
      begin
         if Get_Boolean_Of_Property_Value (a_property_value) then
            is_preemptive := preemptive;
         else
            is_preemptive := not_preemptive;
         end if;
      end read_preemptive_scheduler_property;

      -- Main Read property subprogram
      --
      list_node               : node_id;
      property_name           : Unbounded_String;
      user_defined_properties : Unbounded_String;

      a_property_value : node_id;
      val              : node_id;
      a_param          : parameter_ptr;

   begin
      if not Is_Empty (Ocarina.Nodes.Properties (component_type)) then
         list_node := First_Node (Ocarina.Nodes.Properties (component_type));

         while Present (list_node) loop

            -- The property name
            --
            property_name :=
              to_lower
                (To_Unbounded_String
                   (Image (Display_Name (Identifier (list_node)))));

            a_property_value :=
              Compute_Property_Value (Property_Association_Value (list_node));

            display_property (list_node);
            if pass = 1 then
               --  Scan AADL default properties
               --
               if property_name =
                 To_Unbounded_String ("compute_execution_time")
               then
                  read_compute_execution_time_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String ("concurrency_control_protocol")
               then
                  read_concurrency_control_protocol_property
                    (a_property_value);
               end if;

               if property_name = To_Unbounded_String ("deadline") then
                  read_deadline_property (a_property_value);
               end if;

               if property_name = To_Unbounded_String ("period") then
                  read_period_property (a_property_value);
               end if;

               if
                 (property_name =
                  To_Unbounded_String ("scheduling_protocol")) or
                 (property_name =
                  To_Unbounded_String
                    ("cheddar_properties::scheduling_protocol"))
               then
                  read_scheduling_protocol_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String ("cheddar_properties::source_text") or
                 property_name = To_Unbounded_String ("source_text")
               then
                  read_source_text_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String
                   ("cheddar_properties::context_switch_overhead")
               then
                  read_context_switch_overhead_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String ("cheddar_properties::automaton_name")
               then
                  read_automaton_name_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String ("dispatch_protocol")
               then
                  read_dispatch_protocol_property (a_property_value);
               end if;

               if property_name = To_Unbounded_String ("source_code_size") then
                  read_source_code_size_property (a_property_value);
               end if;

               if property_name = To_Unbounded_String ("source_data_size") then
                  read_source_data_size_property (a_property_value);
               end if;

               if property_name = To_Unbounded_String ("source_heap_size") then
                  read_source_heap_size_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String ("cheddar_properties::criticality")
               then
                  read_criticality_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String ("source_stack_size")
               then
                  read_source_stack_size_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String
                   ("cheddar_properties::source_global_text_size")
               then
                  read_source_code_size_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String
                   ("cheddar_properties::source_global_data_size")
               then
                  read_source_data_size_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String
                   ("cheddar_properties::source_global_heap_size")
               then
                  read_source_heap_size_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String
                   ("cheddar_properties::source_global_stack_size")
               then
                  read_source_stack_size_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String ("cheddar_properties::scheduler_quantum")
               then
                  read_scheduler_quantum_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String
                   ("cheddar_properties::posix_scheduling_policy")
               then
                  read_posix_scheduling_policy_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String ("cheddar_properties::fixed_priority")
               then
                  read_fixed_priority_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String ("cheddar_properties::dispatch_jitter")
               then
                  read_dispatch_jitter_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String
                   ("cheddar_properties::bound_on_data_blocking_time")
               then
                  read_bound_on_data_blocking_time_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String
                   ("cheddar_properties::dispatch_absolute_time")
               then
                  read_dispatch_absolute_time_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String
                   ("cheddar_properties::dispatch_seed_value")
               then
                  read_dispatch_seed_value_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String
                   ("cheddar_properties::dispatch_seed_is_predictable")
               then
                  read_dispatch_seed_is_predictable_property
                    (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String
                   ("cheddar_properties::preemptive_scheduler")
               then
                  read_preemptive_scheduler_property (a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String
                   ("cheddar_properties::data_concurrency_state")
               then
                  read_data_concurrency_state_property (a_property_value);
               end if;

               -- Scan task user defined properties
               --
               if Length (property_name) > 33 then
                  user_defined_properties :=
                    To_Unbounded_String (Slice (property_name, 1, 33));
               else
                  user_defined_properties := empty_string;
               end if;

               if user_defined_properties =
                 "user_defined_cheddar_properties::"
               then

                  val :=
                    Ocarina.Analyzer.Queries.Get_Value_Of_Property_Association
                      (component_type,
                       Image (Display_Name (Identifier (list_node))));
                  user_defined_properties :=
                    To_Unbounded_String
                      (Slice (property_name, 34, Length (property_name)));

                  -- Find the property value type
                  --
                  case Get_Type_Of_Property_Value (val, True) is

                     -- AADL float value of a float user defined parameter
                     --
                     when pt_float | pt_unsigned_float =>
                        a_param := new parameter (double_parameter);
                        a_param.double_value :=
                          Doubles.Double
                            (Get_Float_Of_Property_Value (a_property_value));
                        a_param.parameter_name := user_defined_properties;
                        add (param, a_param);

                     -- AADL integer value of an integer user defined parameter
                     --
                     when pt_integer | pt_unsigned_integer =>
                        a_param := new parameter (integer_parameter);
                        a_param.integer_value :=
                          Integer
                            (Get_Integer_Of_Property_Value (a_property_value));
                        a_param.parameter_name := user_defined_properties;
                        add (param, a_param);

                     -- AADL boolean value of a boolean user defined parameter
                     --
                     when pt_boolean =>
                        a_param := new parameter (boolean_parameter);
                        a_param.boolean_value :=
                          Get_Boolean_Of_Property_Value (a_property_value);
                        a_param.parameter_name := user_defined_properties;
                        add (param, a_param);

                     when others =>
                        Raise_Exception
                          (aadl_read_error'identity,
                           "Can not find task user defined parameter type");
                  end case;
               end if;
            end if;

            if pass = 2 then
               if property_name =
                 To_Unbounded_String ("actual_processor_binding")
               then
                  read_actual_processor_binding_property
                    (list_node,
                     a_property_value);
               end if;
            end if;

            if pass = 3 then
               if property_name =
                 To_Unbounded_String ("cheddar_properties::task_precedencies")
               then
                  read_task_precedencies_property
                    (component_type,
                     a_property_value);
               end if;

               if property_name =
                 To_Unbounded_String ("cheddar_properties::critical_section")
               then
                  read_critical_section_property
                    (component_type,
                     a_property_value);
               end if;
            end if;

            list_node := Next_Node (list_node);
         end loop;
      end if;
   end read_property_associations;

   -------------------------------------------
   --   AADL syntax tree reading sub-programs
   -------------------------------------------

   procedure first_pass
     (handler : in out aadl_project_parser;
      root    :        node_id)
   is

      procedure add_data_component
        (list_node             : node_id;
         identifier_path       : Unbounded_String;
         parent_component_name : Unbounded_String)
      is
      begin
         name :=
           to_lower (To_Unbounded_String (Get_Name_Of_Entity (list_node)));
         add_resource
           (handler.parsed_system.resources,
            identifier_path & parent_component_name & "." & name,
            state,
            size,
            address,
            dummy_identifier,
            identifier_path & parent_component_name,
            protocol,
            a_task_list,
            priority,
            priority_assignment);
      end add_data_component;

      procedure add_thread_component
        (list_node             : node_id;
         identifier_path       : Unbounded_String;
         parent_component_name : Unbounded_String)
      is
      begin
         name :=
           to_lower (To_Unbounded_String (Get_Name_Of_Entity (list_node)));
         add_task
           (my_tasks                => handler.parsed_system.tasks,
            a_task                  => task1,
            name => identifier_path & parent_component_name & "." & name,
            cpu_name                => dummy_identifier,
            core_name               => dummy_identifier,
            address_space_name      => identifier_path & parent_component_name,
            task_type               => task_type,
            start_time              => start_time,
            capacity                => capacity,
            period                  => period,
            deadline                => deadline,
            jitter                  => jitter,
            blocking_time           => blocking_time,
            priority                => priority,
            criticality             => criticality,
            policy                  => policy,
            offset                  => offset,
            stack_memory_size       => stack_memory_size,
            text_memory_size        => text_memory_size,
            param                   => param,
            parametric_rule_name    => parametric_file_name,
            seed_value              => seed,
            predictable             => predictable,
            context_switch_overhead => context_switch_overhead);
      end add_thread_component;

      procedure add_process_component
        (list_node       : node_id;
         identifier_path : Unbounded_String)
      is
      begin
         name :=
           to_lower (To_Unbounded_String (Get_Name_Of_Entity (list_node)));
         add_address_space
           (handler.parsed_system.address_spaces,
            identifier_path & name,
            dummy_identifier,
            text_memory_size,
            stack_memory_size,
            data_memory_size,
            heap_memory_size,
            is_preemptive,
            quantum,
            parametric_file_name,
            a_scheduler,
            automaton_name);
      end add_process_component;

      procedure add_processor_component
        (list_node       : node_id;
         identifier_path : Unbounded_String)
      is
         a_core    : core_unit_ptr;
         empty_mem : memories_table;
      begin
         name :=
           to_lower (To_Unbounded_String (Get_Name_Of_Entity (list_node)));
         add_core_unit
           (handler.parsed_system.core_units,
            a_core,
            To_Unbounded_String ("core_unit_") & identifier_path & name,
            is_preemptive,
            quantum,
            0,
            capacity,
            period,
            priority,
            parametric_file_name,
            empty_string,
            a_scheduler,
            empty_mem,
            automaton_name);

         add_processor
           (handler.parsed_system.processors,
            identifier_path & name,
            a_core);

      end add_processor_component;

      procedure add_event_analyzers (name : Unbounded_String) is

         -- A pair of index objects to keep track of the beginning and
         -- ending of the tokens isolated from the string:
         --
         first : Natural;
         last  : Positive;

         -- A character set consisting of the "whitespace" characters
         -- that separate the tokens:
         --
         comma : constant Ada.Strings.Maps.Character_Set :=
           Ada.Strings.Maps.To_Set (",");
         subname, token : Unbounded_String;
      begin
         subname := name;
         loop
            Find_Token
              (subname,
               Set   => comma,
               Test  => Ada.Strings.Outside,
               First => first,
               Last  => last);

            token   := To_Unbounded_String (Slice (subname, first, last));
            subname :=
              To_Unbounded_String
                (Slice (subname, last + 1, Length (subname)));

            check_event_analyzer
              (handler.parsed_system.event_analyzers,
               token,
               token);
            add_event_analyzer
              (handler.parsed_system.event_analyzers,
               token,
               token);
            exit when Length (subname) = 0;
         end loop;

      exception
         when others =>
            Raise_Exception (aadl_read_error'identity, Exception_Message);
      end add_event_analyzers;

      function find_subcomponents
        (parent_component     : node_id;
         current_process_name : Unbounded_String;
         identifier_path      : Unbounded_String;
         level                : Integer := 0) return Integer
      is
         list_node        : node_id;
         component_number : Integer          := 0;
         cat              : byte;
         cat2             : byte;
         path             : Unbounded_String := identifier_path;
         a_process_name   : Unbounded_String := empty_string;

      begin
         if (parent_component /= No_Node) and
           (Kind (parent_component) = k_component_implementation)
         then

            if Subcomponents (parent_component) /= No_List then

               list_node := First_Node (Subcomponents (parent_component));

               while list_node /= No_Node loop
                  component_number := component_number + 1;

                  --  We look for the component type
                  --
                  if Entity_Ref (list_node) /= No_Node then
                     --  Get the type of the component
                     --
                     cat := Category (list_node);

                     if Aadl_Debug then
                        Put_Line
                          ("First pass ; Component name =  " &
                           Get_Name_Of_Entity (list_node));
                        Put_Line
                          ("First pass ; Component type = " &
                           Get_Name_Of_Entity_Reference
                             (Entity_Ref (list_node)));
                     end if;

                     if component_category'val (cat) = cc_data then
                        --  We do not take into account data declared
                        --  into another data (nested data).
                        --  Get the type of the parent component
                        --
                        cat2 := Category (parent_component);
                        if component_category'val (cat2) = cc_process then
                           put_debug
                             ("Parsing an AADL data : " &
                              Get_Name_Of_Entity (list_node));
                           initialize_parsed_data;
                           read_property_associations
                             (handler,
                              Get_Referenced_Entity (Entity_Ref (list_node)),
                              to_lower
                                (To_Unbounded_String
                                   (Get_Name_Of_Entity (list_node))),
                              identifier_path,
                              1);
                           add_data_component
                             (list_node,
                              identifier_path,
                              current_process_name);
                        end if;
                     end if;

                     if component_category'val (cat) = cc_thread then
                        put_debug
                          ("Parsing an AADL thread : " &
                           Get_Name_Of_Entity (list_node));
                        initialize_parsed_data;
                        read_property_associations
                          (handler,
                           Get_Referenced_Entity (Entity_Ref (list_node)),
                           to_lower
                             (To_Unbounded_String
                                (Get_Name_Of_Entity (list_node))),
                           identifier_path,
                           1);
                        add_thread_component
                          (list_node,
                           identifier_path,
                           current_process_name);
                     end if;

                     if component_category'val (cat) = cc_process then
                        put_debug
                          ("Parsing an AADL process : " &
                           Get_Name_Of_Entity (list_node));
                        initialize_parsed_data;
                        a_process_name :=
                          to_lower
                            (To_Unbounded_String
                               (Get_Name_Of_Entity (list_node)));
                        read_property_associations
                          (handler,
                           Get_Referenced_Entity (Entity_Ref (list_node)),
                           to_lower
                             (To_Unbounded_String
                                (Get_Name_Of_Entity (list_node))),
                           identifier_path,
                           1);
                        add_process_component (list_node, identifier_path);
                     end if;

                     if component_category'val (cat) = cc_processor then
                        put_debug
                          ("Parsing an AADL processor : " &
                           Get_Name_Of_Entity (list_node));
                        initialize_parsed_data;
                        read_property_associations
                          (handler,
                           Get_Referenced_Entity (Entity_Ref (list_node)),
                           to_lower
                             (To_Unbounded_String
                                (Get_Name_Of_Entity (list_node))),
                           identifier_path,
                           1);
                        add_processor_component (list_node, identifier_path);
                     end if;

                     if component_category'val (cat) = cc_system then
                        put_debug
                          ("Parsing an AADL system : " &
                           Get_Name_Of_Entity (list_node));
                        if Aadl_Import_With_System_Name then
                           path :=
                             to_lower
                               (identifier_path &
                                Get_Name_Of_Entity (list_node) &
                                "");
                        else
                           path := empty_string;
                        end if;
                        initialize_parsed_data;
                        read_property_associations
                          (handler,
                           Get_Referenced_Entity (Entity_Ref (list_node)),
                           to_lower
                             (To_Unbounded_String
                                (Get_Name_Of_Entity (list_node))),
                           path,
                           1);

                        if parametric_file_name /= empty_string then
                           add_event_analyzers (parametric_file_name);
                        end if;
                     end if;

                     component_number :=
                       component_number +
                       find_subcomponents
                         (Get_Referenced_Entity (Entity_Ref (list_node)),
                          a_process_name,
                          path,
                          level + 1);

                  else

                     -- The component has no type ...currently, this
                     --  is not supported.
                     --
                     Raise_Exception
                       (aadl_read_error'identity,
                        "Find_Processor_Component, AADL component must have " &
                        "a type");
                  end if;
                  list_node := Next_Node (list_node);
               end loop;
            end if;
         end if;

         return component_number;
      end find_subcomponents;

      list_node               : node_id := No_Node;
      global_component_number : Integer := 0;
      path                    : Unbounded_String;

   begin
      -- Find and create all Cheddar's object sets
      --
      if Ocarina.Nodes.Declarations (root) /= No_List then

         list_node := First_Node (Ocarina.Nodes.Declarations (root));
         while list_node /= No_Node loop

            if Kind (list_node) = k_component_implementation
              and then
                component_category'val (Category (list_node)) =
                cc_system
            then
               put_debug
                 ("Parsing a root AADL system component : " &
                  Get_Name_Of_Entity (list_node));

               -- Read main system properties
               --
               if Aadl_Import_With_System_Name then
                  path :=
                    to_lower
                      (To_Unbounded_String (Get_Name_Of_Entity (list_node)) &
                       ".");
               else
                  path := empty_string;
               end if;

               read_property_associations
                 (handler,
                  list_node,
                  to_lower
                    (To_Unbounded_String (Get_Name_Of_Entity (list_node))),
                  path,
                  1);

               if parametric_file_name /= empty_string then
                  add_event_analyzers (parametric_file_name);
               end if;

               -- Find AADL sub components
               --
               global_component_number :=
                 find_subcomponents
                   (list_node,
                    empty_string,
                    to_lower
                      (To_Unbounded_String (Get_Name_Of_Entity (list_node)) &
                       "."));

            end if;

            list_node := Next_Node (list_node);
         end loop;
      end if;

   end first_pass;

   procedure second_pass
     (handler : in out aadl_project_parser;
      root    :        node_id)
   is
      function find_subcomponents
        (parent_component : node_id;
         identifier_path  : Unbounded_String;
         level            : Integer := 0) return Integer
      is
         list_node        : node_id;
         component_number : Integer          := 0;
         cat              : byte;
         path             : Unbounded_String := identifier_path;

      begin
         if Subcomponents (parent_component) /= No_List then
            list_node := First_Node (Subcomponents (parent_component));

            while list_node /= No_Node loop
               component_number := component_number + 1;

               -- We look for the component type
               --
               if (Entity_Ref (list_node) /= No_Node) then

                  -- Get the type of the component
                  --
                  cat := Category (list_node);

                  if Aadl_Debug then
                     Put_Line
                       ("Second pass ; Component name =  " &
                        Get_Name_Of_Entity (list_node));
                     Put_Line
                       ("Second pass ; Component type = " &
                        Get_Name_Of_Entity_Reference (Entity_Ref (list_node)));
                  end if;

                  if component_category'val (cat) = cc_process then
                     read_property_associations
                       (handler,
                        Get_Referenced_Entity (Entity_Ref (list_node)),
                        to_lower
                          (To_Unbounded_String
                             (Get_Name_Of_Entity (list_node))),
                        identifier_path,
                        2);
                  end if;

                  if component_category'val (cat) = cc_system then
                     if Aadl_Import_With_System_Name then
                        path :=
                          to_lower
                            (identifier_path &
                             Get_Name_Of_Entity (list_node) &
                             "");
                     else
                        path := empty_string;
                     end if;
                     read_property_associations
                       (handler,
                        Get_Referenced_Entity (Entity (list_node)),
                        to_lower
                          (To_Unbounded_String
                             (Get_Name_Of_Entity (list_node))),
                        identifier_path,
                        2);
                  end if;

                  if (component_category'val (cat) = cc_system) or
                    (component_category'val (cat) = cc_process)
                  then

                     component_number :=
                       component_number +
                       find_subcomponents
                         (Get_Referenced_Entity (Entity_Ref (list_node)),
                          path,
                          level + 1);
                  end if;

               else

                  -- The component has no type ...
                  -- Currently, this is not supported
                  --
                  Raise_Exception
                    (aadl_read_error'identity,
                     "Find_Processor_Component, AADL component must have a type");
               end if;
               list_node := Next_Node (list_node);
            end loop;
         end if;

         return component_number;
      end find_subcomponents;

      a_buffer             : buffer_ptr;
      my_buffer_iterator   : buffers_iterator;
      a_resource           : generic_resource_ptr;
      my_resource_iterator : resources_iterator;
      a_task               : generic_task_ptr;
      my_task_iterator     : tasks_iterator;

      an_address_space : address_space_ptr;
      my_iterator      : address_spaces_iterator;

      list_node               : node_id := No_Node;
      global_component_number : Integer := 0;
      path                    : Unbounded_String;

   begin
      initialize_parsed_data;

      -- Find and perform analysis on all global systems
      --
      if Ocarina.Nodes.Declarations (root) /= No_List then
         list_node := First_Node (Ocarina.Nodes.Declarations (root));

         while list_node /= No_Node loop
            if Kind (list_node) = k_component_implementation
              and then
                component_category'val (Category (list_node)) =
                cc_system
            then

               -- Read main system properties
               --
               if Aadl_Import_With_System_Name then
                  path :=
                    to_lower
                      (To_Unbounded_String (Get_Name_Of_Entity (list_node)) &
                       ".");
               else
                  path := empty_string;
               end if;

               read_property_associations
                 (handler,
                  list_node,
                  to_lower
                    (To_Unbounded_String (Get_Name_Of_Entity (list_node))),
                  path,
                  2);

               -- Find AADL sub components
               --
               global_component_number :=
                 find_subcomponents
                   (list_node,
                    to_lower
                      (To_Unbounded_String (Get_Name_Of_Entity (list_node)) &
                       "."));
            end if;

            list_node := Next_Node (list_node);
         end loop;
      end if;

      -- Now, update processor bindings of address spaces
      --
      if not is_empty (handler.parsed_system.address_spaces) then
         reset_iterator (handler.parsed_system.address_spaces, my_iterator);

         loop
            current_element
              (handler.parsed_system.address_spaces,
               an_address_space,
               my_iterator);

            -- Find the process name in the table and assign  processor
            --
            for i in 0 .. cpu_bindings.nb_entries - 1 loop
               if cpu_bindings.entries (i).address_space_name =
                 an_address_space.name
               then
                  an_address_space.cpu_name :=
                    cpu_bindings.entries (i).cpu_name;
               end if;
            end loop;

            exit when is_last_element
                (handler.parsed_system.address_spaces,
                 my_iterator);

            next_element (handler.parsed_system.address_spaces, my_iterator);

         end loop;
      end if;

      -- Check that no address space stays unbinded
      -- Bind threads, buffers and shared_resources
      --
      if not is_empty (handler.parsed_system.address_spaces) then
         reset_iterator (handler.parsed_system.address_spaces, my_iterator);
         loop

            current_element
              (handler.parsed_system.address_spaces,
               an_address_space,
               my_iterator);

            -- Check and bind
            --
            if an_address_space.cpu_name = dummy_identifier then
               Raise_Exception
                 (aadl_read_error'identity,
                  "Process " &
                  To_String (an_address_space.name) &
                  " is not binded to a processor");
            end if;

            if not is_empty (handler.parsed_system.tasks) then
               reset_iterator (handler.parsed_system.tasks, my_task_iterator);

               loop
                  current_element
                    (handler.parsed_system.tasks,
                     a_task,
                     my_task_iterator);

                  if a_task.address_space_name = an_address_space.name then
                     a_task.cpu_name := an_address_space.cpu_name;
                  end if;

                  exit when is_last_element
                      (handler.parsed_system.tasks,
                       my_task_iterator);

                  next_element (handler.parsed_system.tasks, my_task_iterator);

               end loop;
            end if;

            if not is_empty (handler.parsed_system.resources) then
               reset_iterator
                 (handler.parsed_system.resources,
                  my_resource_iterator);
               loop

                  current_element
                    (handler.parsed_system.resources,
                     a_resource,
                     my_resource_iterator);

                  if a_resource.address_space_name = an_address_space.name then
                     a_resource.cpu_name := an_address_space.cpu_name;
                  end if;

                  exit when is_last_element
                      (handler.parsed_system.resources,
                       my_resource_iterator);

                  next_element
                    (handler.parsed_system.resources,
                     my_resource_iterator);

               end loop;
            end if;

            if not is_empty (handler.parsed_system.buffers) then
               reset_iterator
                 (handler.parsed_system.buffers,
                  my_buffer_iterator);
               loop

                  current_element
                    (handler.parsed_system.buffers,
                     a_buffer,
                     my_buffer_iterator);

                  if a_buffer.address_space_name = an_address_space.name then
                     a_buffer.cpu_name := an_address_space.cpu_name;
                  end if;

                  exit when is_last_element
                      (handler.parsed_system.buffers,
                       my_buffer_iterator);

                  next_element
                    (handler.parsed_system.buffers,
                     my_buffer_iterator);

               end loop;
            end if;

            exit when is_last_element
                (handler.parsed_system.address_spaces,
                 my_iterator);

            next_element (handler.parsed_system.address_spaces, my_iterator);

         end loop;
      end if;

      -- Now, check that no task/resource/buffer stays unbinded
      --
      if not is_empty (handler.parsed_system.tasks) then
         reset_iterator (handler.parsed_system.tasks, my_task_iterator);
         loop

            current_element
              (handler.parsed_system.tasks,
               a_task,
               my_task_iterator);

            if (a_task.cpu_name = dummy_identifier) then
               Raise_Exception
                 (aadl_read_error'identity,
                  "Task " &
                  To_String (a_task.name) &
                  " is not binded to a processor");
            end if;

            exit when is_last_element
                (handler.parsed_system.tasks,
                 my_task_iterator);

            next_element (handler.parsed_system.tasks, my_task_iterator);

         end loop;
      end if;

      if not is_empty (handler.parsed_system.resources) then
         reset_iterator
           (handler.parsed_system.resources,
            my_resource_iterator);
         loop

            current_element
              (handler.parsed_system.resources,
               a_resource,
               my_resource_iterator);

            if (a_resource.cpu_name = dummy_identifier) then
               Raise_Exception
                 (aadl_read_error'identity,
                  "Data " &
                  To_String (a_resource.name) &
                  " is not binded to a processor");
            end if;

            exit when is_last_element
                (handler.parsed_system.resources,
                 my_resource_iterator);

            next_element
              (handler.parsed_system.resources,
               my_resource_iterator);

         end loop;
      end if;

      if not is_empty (handler.parsed_system.buffers) then
         reset_iterator (handler.parsed_system.buffers, my_buffer_iterator);
         loop

            current_element
              (handler.parsed_system.buffers,
               a_buffer,
               my_buffer_iterator);

            if (a_buffer.cpu_name = dummy_identifier) then
               Raise_Exception
                 (aadl_read_error'identity,
                  "Buffer " &
                  To_String (a_buffer.name) &
                  " is not binded to a processor");
            end if;

            exit when is_last_element
                (handler.parsed_system.buffers,
                 my_buffer_iterator);

            next_element (handler.parsed_system.buffers, my_buffer_iterator);

         end loop;
      end if;
   end second_pass;

   -------------------------------------------
   ---   Read AADL connections
   -------------------------------------------

   procedure read_connections
     (handler                  : in out aadl_project_parser;
      component_implementation :        node_id;
      component_instance_name  :        Unbounded_String;
      path                     :        Unbounded_String)
   is
      procedure precedency_connections (a_connection : node_id) is

         consumer_thread_name : Unbounded_String;
         producer_thread_name : Unbounded_String;

         a_consumer_thread : generic_task_ptr;
         a_producer_thread : generic_task_ptr;

         -- A pair of index objects to keep track of the beginning and
         -- ending of the tokens isolated from the string:
         --
         first : Natural;
         last  : Positive;

         -- A character set consisting of the "whitespace" characters
         -- that separate the tokens:
         --
         dot : constant Ada.Strings.Maps.Character_Set :=
           Ada.Strings.Maps.To_Set (".");
         subname : Unbounded_String;

      begin
         -- Get thread names
         --
         producer_thread_name :=
           to_lower
             (To_Unbounded_String
                (Image (Display_Name (Identifier (Source (a_connection))))));
         consumer_thread_name :=
           to_lower
             (To_Unbounded_String
                (Image
                   (Display_Name (Identifier (Destination (a_connection))))));

         subname := producer_thread_name;
         Find_Token
           (subname,
            Set   => dot,
            Test  => Ada.Strings.Outside,
            First => first,
            Last  => last);

         producer_thread_name :=
           To_Unbounded_String (Slice (subname, first, last));
         producer_thread_name :=
           path & component_instance_name & "." & producer_thread_name;

         subname := consumer_thread_name;
         Find_Token
           (subname,
            Set   => dot,
            Test  => Ada.Strings.Outside,
            First => first,
            Last  => last);

         consumer_thread_name :=
           To_Unbounded_String (Slice (subname, first, last));
         consumer_thread_name :=
           path & component_instance_name & "." & consumer_thread_name;

         a_consumer_thread :=
           search_task (handler.parsed_system.tasks, consumer_thread_name);
         a_producer_thread :=
           search_task (handler.parsed_system.tasks, producer_thread_name);

         add_one_task_dependency_precedence
           (handler.parsed_system.dependencies,
            a_consumer_thread,
            a_producer_thread);
      end precedency_connections;

      procedure buffer_connections (a_connection : node_id) is
         buffer_name          : Unbounded_String;
         consumer_thread_name : Unbounded_String;
         producer_thread_name : Unbounded_String;

         a_buffer          : buffer_ptr;
         a_consumer_thread : generic_task_ptr;

         already_exist : Boolean;
         a_role        : buffer_role;
         roles         : buffer_roles_table;

         -- A pair of index objects to keep track of the beginning and
         -- ending of the tokens isolated from the string:
         --
         first : Natural;
         last  : Positive;

         -- A character set consisting of the "whitespace" characters
         -- that separate the tokens:
         --
         dot : constant Ada.Strings.Maps.Character_Set :=
           Ada.Strings.Maps.To_Set (".");
         subname : Unbounded_String;

      begin
         -- Get thread names
         --
         producer_thread_name :=
           to_lower
             (To_Unbounded_String
                (Image (Display_Name (Identifier (Source (a_connection))))));
         consumer_thread_name :=
           to_lower
             (To_Unbounded_String
                (Image
                   (Display_Name (Identifier (Destination (a_connection))))));

         subname := producer_thread_name;
         Find_Token
           (subname,
            Set   => dot,
            Test  => Ada.Strings.Outside,
            First => first,
            Last  => last);

         producer_thread_name :=
           To_Unbounded_String (Slice (subname, first, last));
         producer_thread_name :=
           path & component_instance_name & "." & producer_thread_name;

         subname := consumer_thread_name;
         Find_Token
           (subname,
            Set   => dot,
            Test  => Ada.Strings.Outside,
            First => first,
            Last  => last);

         consumer_thread_name :=
           To_Unbounded_String (Slice (subname, first, last));
         consumer_thread_name :=
           path & component_instance_name & "." & consumer_thread_name;

         a_consumer_thread :=
           search_task (handler.parsed_system.tasks, consumer_thread_name);

         -- Is the buffer already exists ?
         -- if not, create it. If it already exist, add the new
         -- producer
         --
         buffer_name := consumer_thread_name & To_Unbounded_String ("_buffer");

         begin
            already_exist := True;
            a_buffer      :=
              search_buffer (handler.parsed_system.buffers, buffer_name);
         exception
            when others =>
               already_exist := False;
         end;

         if not already_exist then
            -- Create the buffer
            --
            initialize (roles);
            Initialize (a_role);
            a_role.the_role := queuing_consumer;
            a_role.size     := 1;
            a_role.time     := 1;
            add (roles, consumer_thread_name, a_role);

            add_buffer
              (handler.parsed_system.buffers,
               a_buffer,
               buffer_name,
               1,
               a_consumer_thread.cpu_name,
               a_consumer_thread.address_space_name,
               qs_pp1,
               roles);
         end if;

         -- Add the new role (producer)
         --
         Initialize (a_role);
         a_role.the_role := queuing_producer;
         a_role.size     := 1;
         a_role.time     := 1;
         add (a_buffer.roles, producer_thread_name, a_role);

      end buffer_connections;

      procedure shared_resource_connections (a_connection : node_id) is
         resource_name : Unbounded_String;
         thread_name   : Unbounded_String;

         already_exist    : Boolean;
         resource_str_ptr : unbounded_string_ptr;
         list_ite         : unbounded_string_iterator;

         a_resource : generic_resource_ptr;
         a_thread   : generic_task_ptr;

      begin
         -- Check that no critical section are already memorized
         -- If we found no critical section, build a new one from
         -- the data access connection
         --
         resource_name :=
           to_lower
             (To_Unbounded_String
                (Image (Display_Name (Identifier (Source (a_connection))))));
         resource_name := path & component_instance_name & "." & resource_name;

         -- Get resource and thread information
         --
         a_resource :=
           search_resource (handler.parsed_system.resources, resource_name);

         thread_name :=
           to_lower
             (To_Unbounded_String
                (Image
                   (Display_Name (Identifier (Destination (a_connection))))));

         declare
            -- A pair of index objects to keep track of the beginning and
            -- ending of the tokens isolated from the string:
            --
            first : Natural;
            last  : Positive;

            -- A character set consisting of the "whitespace" characters
            -- that separate the tokens:
            --
            dot : constant Ada.Strings.Maps.Character_Set :=
              Ada.Strings.Maps.To_Set (".");
            subname : Unbounded_String;
         begin
            subname := thread_name;

            Find_Token
              (subname,
               Set   => dot,
               Test  => Ada.Strings.Outside,
               First => first,
               Last  => last);

            thread_name := To_Unbounded_String (Slice (subname, first, last));
            thread_name := path & component_instance_name & "." & thread_name;
         end;

         a_thread := search_task (handler.parsed_system.tasks, thread_name);

         -- Check is some critical section exists
         --
         already_exist := False;
         if not is_empty (critical_section_list) then

            reset_head_iterator (critical_section_list, list_ite);
            loop
               current_element
                 (critical_section_list,
                  resource_str_ptr,
                  list_ite);

               if resource_str_ptr.all = resource_name then
                  already_exist := True;
                  exit;
               end if;

               if is_tail_element (critical_section_list, list_ite) then
                  exit;
               end if;
               next_element (critical_section_list, list_ite);
            end loop;

         end if;

         -- Add the critical section if the critical_section_list
         -- does not contain it
         --
         if not already_exist then
            a_resource.critical_sections.entries
              (a_resource.critical_sections.nb_entries)
              .item :=
              thread_name;
            a_resource.critical_sections.entries
              (a_resource.critical_sections.nb_entries)
              .data
              .task_begin :=
              1;
            a_resource.critical_sections.entries
              (a_resource.critical_sections.nb_entries)
              .data
              .task_end :=
              a_thread.capacity;
            a_resource.critical_sections.nb_entries :=
              a_resource.critical_sections.nb_entries + 1;
         end if;

      end shared_resource_connections;

      list_node : node_id;
      cat       : connection_type;

   begin
      if not Is_Empty
          (Ocarina.Nodes.Connections (component_implementation))
      then
         list_node :=
           First_Node (Ocarina.Nodes.Connections (component_implementation));

         while Present (list_node) loop
            if Aadl_Debug then
               Print_Connection (list_node, Default_Output_Options);
            end if;

            cat := Get_Category_Of_Connection (list_node);

            begin
               case cat is
                  when ct_data | ct_data_delayed | ct_access_subprogram =>
                     null;
                  when ct_event =>
                     if Aadl_Import_Event_To_Buffers_Messages then
                        buffer_connections (list_node);
                     end if;
                     if Aadl_Import_Event_To_Precedencies then
                        precedency_connections (list_node);
                     end if;
                  when ct_event_data =>
                     if Aadl_Import_Event_Data_To_Buffers_Messages then
                        buffer_connections (list_node);
                     end if;
                     if Aadl_Import_Event_Data_To_Precedencies then
                        precedency_connections (list_node);
                     end if;
                  when ct_port_group =>
                     null;
                  when ct_parameter =>
                     null;
                  when ct_access_bus =>
                     null;
                  when ct_access_data =>
                     shared_resource_connections (list_node);
               end case;

               -- Sometimes, the parsing of a connection may fail.
               -- Most of the time, it means that the AADL component were not
               -- translated towards Cheddar's component (for several reasons)
               -- Then, we do not stop the parser : the AADL translation
               -- should continue ...
               --
            exception
               when others =>
                  put_debug ("Warning : failed to parse an AADL connection");
                  put_debug (Exception_Name & " : " & Exception_Message);
            end;
            list_node := Next_Node (list_node);
         end loop;
      end if;

   end read_connections;

   procedure third_pass
     (handler : in out aadl_project_parser;
      root    :        node_id)
   is
      function find_subcomponents
        (parent_component : node_id;
         identifier_path  : Unbounded_String;
         level            : Integer := 0) return Integer
      is
         list_node        : node_id;
         component_number : Integer          := 0;
         cat              : byte;
         path             : Unbounded_String := identifier_path;

      begin
         if Subcomponents (parent_component) /= No_List then
            list_node := First_Node (Subcomponents (parent_component));

            while list_node /= No_Node loop
               component_number := component_number + 1;

               -- We look for the component type
               --
               if Entity_Ref (list_node) /= No_Node then
                  -- Get the type of the component
                  --
                  cat := Category (list_node);

                  if Aadl_Debug then
                     Put_Line
                       ("Third pass ; Component name =  " &
                        To_String (identifier_path) &
                        Get_Name_Of_Entity (list_node));
                     Put_Line
                       ("Third pass ; Component type = " &
                        Get_Name_Of_Entity_Reference (Entity_Ref (list_node)));
                  end if;

                  if component_category'val (cat) = cc_process then
                     read_property_associations
                       (handler,
                        Get_Referenced_Entity (Entity_Ref (list_node)),
                        to_lower
                          (To_Unbounded_String
                             (Get_Name_Of_Entity (list_node))),
                        identifier_path,
                        3);
                     read_connections
                       (handler,
                        Get_Referenced_Entity (Entity_Ref (list_node)),
                        to_lower
                          (To_Unbounded_String
                             (Get_Name_Of_Entity (list_node))),
                        identifier_path);
                  end if;

                  if component_category'val (cat) = cc_system then
                     if Aadl_Import_With_System_Name then
                        path :=
                          to_lower
                            (identifier_path &
                             Get_Name_Of_Entity (list_node) &
                             "");
                     else
                        path := empty_string;
                     end if;

                     read_property_associations
                       (handler,
                        list_node,
                        to_lower
                          (To_Unbounded_String
                             (Get_Name_Of_Entity (list_node))),
                        identifier_path,
                        3);
                  end if;

                  if component_category'val (cat) = cc_system
                    or else component_category'val (cat) = cc_process
                  then
                     component_number :=
                       component_number +
                       find_subcomponents
                         (Get_Referenced_Entity (Entity_Ref (list_node)),
                          path,
                          level + 1);
                  end if;

               else

                  -- The component has no type ...
                  -- Currently, this is not supported
                  --
                  Raise_Exception
                    (aadl_read_error'identity,
                     "AADL component must have a type");
               end if;
               list_node := Next_Node (list_node);
            end loop;
         end if;

         return component_number;
      end find_subcomponents;

      list_node               : node_id := No_Node;
      global_component_number : Integer := 0;
      path                    : Unbounded_String;

   begin
      initialize_parsed_data;

      -- Find and perform analysis on all global systems
      --
      if Ocarina.Nodes.Declarations (root) /= No_List then
         list_node := First_Node (Ocarina.Nodes.Declarations (root));

         while list_node /= No_Node loop
            if Kind (list_node) = k_component_implementation
              and then
                component_category'val (Category (list_node)) =
                cc_system
            then
               -- Read main system properties
               --
               if Aadl_Import_With_System_Name then
                  path :=
                    to_lower
                      (To_Unbounded_String (Get_Name_Of_Entity (list_node)) &
                       ".");
               else
                  path := empty_string;
               end if;

               read_property_associations
                 (handler,
                  list_node,
                  to_lower
                    (To_Unbounded_String (Get_Name_Of_Entity (list_node))),
                  path,
                  3);

               -- Find AADL sub components
               --
               global_component_number :=
                 find_subcomponents
                   (list_node,
                    to_lower
                      (To_Unbounded_String (Get_Name_Of_Entity (list_node)) &
                       "."));
            end if;

            list_node := Next_Node (list_node);
         end loop;
      end if;
   end third_pass;

   -----------
   -- Parse --
   -----------

   procedure parse
     (handler           : in out aadl_project_parser;
      dir_list          :        unbounded_string_list;
      project_file_list :        unbounded_string_list)
   is
      root    : node_id;
      success : Boolean := False;

      a_buff               : buffer_ptr;
      my_iterator_buffer   : buffers_iterator;
      a_resource           : generic_resource_ptr;
      my_iterator_resource : resources_iterator;
   begin
      --  Ocarina Initialization
      --
      root := No_Node;

      if not first_aadl_parsing then
         Ocarina.Configuration.Reset_Modules;
         Ocarina.Reset;
      else
         first_aadl_parsing := False;
      end if;

      Ocarina.Initialize;
      Ocarina.Configuration.Init_Modules;

      --  Parse AADL property files
      --
      root :=
        load_aadl_file_from_directory (root, "AADL_Properties.aadl", dir_list);

      root :=
        load_aadl_file_from_directory (root, "AADL_Project.aadl", dir_list);

      --  If the two files above have not been found, use those of
      --  Ocarina.
      --
      root := Ocarina.Parser.Parse_Standard_Property_Sets (root);

      if No (root) then
         Raise_Exception
           (aadl_read_error'identity,
            "Cannot parse standard property sets");
      end if;

      root :=
        load_aadl_file_from_directory
          (root,
           "Cheddar_Properties.aadl",
           dir_list);

      root :=
        load_aadl_file_from_directory
          (root,
           "User_Defined_Cheddar_Properties.aadl",
           dir_list);

      -- Read and Parse user files from Project_File_List
      --
      declare
         a_file_name : unbounded_string_ptr;
         list_ite    : unbounded_string_iterator;

      begin
         if not is_empty (project_file_list) then
            reset_head_iterator (project_file_list, list_ite);
            loop
               current_element (project_file_list, a_file_name, list_ite);

               root :=
                 load_aadl_file_from_directory
                   (root,
                    a_file_name.all,
                    dir_list);

               if is_tail_element (project_file_list, list_ite) then
                  exit;
               end if;

               next_element (project_file_list, list_ite);
            end loop;
         end if;
      end;

      --  Run AADL AST analysis
      --
      if root /= No_Node then
         success :=
           Ocarina.Analyzer.Analyze_Tree (root, Default_Analyzer_Options);

         if not success then
            root := No_Node;
         end if;
      end if;

      --  Check that the AADL specification is OK
      --
      if root = No_Node then
         Raise_Exception
           (aadl_read_error'identity,
            "Syntax error in the AADL specification");
      else

         --  First pass : store subcomponents (systems, processor,
         --  thread and data components)
         --
         initialize (critical_section_list);

         first_pass (handler, root);
         if Aadl_Debug then
            Put_Line ("End of First pass");
         end if;

         -- Second pass : perform processor and bus bindings
         --
         if Aadl_Process_Second_Import_Pass then
            second_pass (handler, root);
            if Aadl_Debug then
               Put_Line ("End of Second pass");
            end if;
         end if;

         --  Third pass : build components relationships (component
         --  connections)
         --
         if Aadl_Process_Third_Import_Pass then

            --  Set shared resources critical section and  task dependencies
            --
            third_pass (handler, root);

            --  Build buffer's dependencies
            --
            if not is_empty (handler.parsed_system.buffers) then
               reset_iterator
                 (handler.parsed_system.buffers,
                  my_iterator_buffer);
               loop
                  current_element
                    (handler.parsed_system.buffers,
                     a_buff,
                     my_iterator_buffer);

                  begin
                     add_all_task_dependencies
                       (handler.parsed_system.dependencies,
                        handler.parsed_system.tasks,
                        a_buff);

                     --  Sometimes, the parsing of a connection may fail.
                     --  Most of the time, it means that the AADL
                     --  components were not translated towards
                     --  Cheddar's components (for several reasons).
                     --  Then, we do not stop the parser : the AADL
                     --  translation -- should continue ...
                     --
                  exception
                     when others =>
                        put_debug
                          ("Warning : fail to translate an AADL " &
                           "connection to a task dependency");
                        put_debug (Exception_Name & " : " & Exception_Message);
                  end;

                  exit when is_last_element
                      (handler.parsed_system.buffers,
                       my_iterator_buffer);
                  next_element
                    (handler.parsed_system.buffers,
                     my_iterator_buffer);
               end loop;

               -- Check critical sections of shared resources
               -- and buffer roles
               --
               if not is_empty (handler.parsed_system.buffers) then
                  reset_iterator
                    (handler.parsed_system.buffers,
                     my_iterator_buffer);
                  loop
                     current_element
                       (handler.parsed_system.buffers,
                        a_buff,
                        my_iterator_buffer);

                     begin
                        check_task_buffer_roles
                          (handler.parsed_system.tasks,
                           a_buff.name,
                           a_buff.roles);

                        --  Sometimes, the parsing of a connection may fail.
                        --  Most of the time, it means that the AADL
                        --  components were not translated towards
                        --  Cheddar's components (for several reasons).
                        --  Then, we do not stop the parser : the AADL
                        --  translation -- should continue ...
                        --
                     exception
                        when others =>
                           put_debug
                             ("Warning : fail to translate an AADL " &
                              "connection to a buffer role ");
                           put_debug
                             (Exception_Name & " : " & Exception_Message);
                     end;

                     exit when is_last_element
                         (handler.parsed_system.buffers,
                          my_iterator_buffer);
                     next_element
                       (handler.parsed_system.buffers,
                        my_iterator_buffer);
                  end loop;
               end if;
               if not is_empty (handler.parsed_system.resources) then
                  reset_iterator
                    (handler.parsed_system.resources,
                     my_iterator_resource);
                  loop

                     current_element
                       (handler.parsed_system.resources,
                        a_resource,
                        my_iterator_resource);

                     begin

                        check_task_critical_sections
                          (handler.parsed_system,
                           a_resource.name, a_resource.cpu_name, a_resource.protocol,
                           a_resource.critical_sections);

                        --  Sometimes, the parsing of a connection may fail.
                        --  Most of the time, it means that the AADL
                        --  components were not translated towards
                        --  Cheddar's components (for several reasons).
                        --  Then, we do not stop the parser : the AADL
                        --  translation -- should continue ...
                        --
                     exception
                        when others =>
                           put_debug
                             ("Warning : fail to translate an AADL " &
                              "connection to a critical section ");
                           put_debug
                             (Exception_Name & " : " & Exception_Message);
                     end;

                     exit when is_last_element
                         (handler.parsed_system.resources,
                          my_iterator_resource);

                     next_element
                       (handler.parsed_system.resources,
                        my_iterator_resource);

                  end loop;
               end if;

            end if;

            -- Free memory
            --
            -- Delete(Critical_Section_List);

            if Aadl_Debug then
               Put_Line ("End of Third pass");
            end if;
         end if;
      end if;
   end parse;

end aadl_parsers;
