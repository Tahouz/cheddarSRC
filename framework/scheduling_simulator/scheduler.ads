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
--    $Rev: 5538 $
--    $Date: 2025-04-09 12:58:25 +0200 (mer., 09 avril 2025) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Finalization;
with Unchecked_Deallocation;

with Tasks;                     use Tasks;
with task_set;                  use task_set;
use task_set.generic_task_set;
with Resources;                 use Resources;
use Resources.Resource_Accesses;
with resource_set; use resource_set;
use resource_set.generic_resource_set;
with Buffers;                   use Buffers;
use Buffers.Buffer_Roles_Package;
with buffer_set;                use buffer_set;
use buffer_set.generic_buffer_set;
with Messages;                  use Messages;
with message_set;               use message_set;
use message_set.generic_message_set;
with task_dependencies; use task_dependencies;
use task_dependencies.half_dep_set;
with Processors;                use Processors;
with Core_Units;                use Core_Units;
with processor_set;             use processor_set;
with Address_Spaces;            use Address_Spaces;
with address_space_set;         use address_space_set;
with battery_set;               use battery_set;
with unbounded_strings;         use unbounded_strings;
with Framework_Config;          use Framework_Config;
with time_unit_events;          use time_unit_events;
use time_unit_events.time_unit_package;
with Scheduling_Analysis;       use Scheduling_Analysis;
with primitive_xml_strings;     use primitive_xml_strings;
with Scheduler_Interface;       use Scheduler_Interface;
with Processor_Interface;       use Processor_Interface;
with integer_arrays;            use integer_arrays;
with cache_set;                 use cache_set;
with cache_block_set;           use cache_block_set;
with cache_access_profile_set;  use cache_access_profile_set;
with tdma;                      use tdma;
with scheduling_options;        use scheduling_options;
with Doubles;                   use Doubles;

with indexed_tables;
with tables;
with natural_util;
with access_lists;


package scheduler is

   -------------------------------------------------------------
   -------------------------------------------------------------
   --   Basic type definitions
   -------------------------------------------------------------
   -------------------------------------------------------------

   -- Constant to be used when no resource or no dependency are
   -- present in a project
   --
   no_resource_set       : resources_set;
   no_tasks_dependencies : tasks_dependencies;

   -------------------------------------------------------------
   -------------------------------------------------------------
   -- The type definitions below are used by schedulers to store
   -- required information on task/processor/buffers/... in order to
   -- compute the scheduling
   -------------------------------------------------------------
   -------------------------------------------------------------


   type tcb is tagged record

      -- Cheddar ADL properties of the task
      --
      tsk : generic_task_ptr;

      -- Current release time of the task
      --
      wake_up_time : Natural;

      -- Number of unit of time a task has to run to complete its activation
      --
      rest_of_capacity : Natural;

      -- Total unit of time that is ran for the current activation
      --
      used_capacity : Natural;

      -- Current activation/release number
      --
      activation : Natural;

      -- Completion time of the current release
      --
      activation_end_time : Natural;

      -- Total amount of used CPU for the task (for all activation)
      --
      used_cpu : Natural;

      -- Save the specific seed of the task (for any random data related to the task)
      --
      task_seed : State;

      -- Suspended is only used by user-defined scheduler
      -- a use-defined scheduler may suspend a given task ... and then, the task cannot
      -- be selected to be run
      -- A task can be suspended by a user-defined scheduler by simply putting "false"
      -- to the suspended attribute of the tcb
      --
      suspended : Boolean;

      -- When a task is blocked due to a resource that is not available
      -- the following attibutes is set to the resource blocking the task
      -- Having a non null wait_for_a_resource does not mean that the corresponding
      -- event will be generated : to generate this event, the task should be the
      -- and the event has to be
      --
      wait_for_a_resource : generic_resource_ptr;

      -- Give the core unit name on which the task is run
      -- This is required when a use a multiprocessor scheduler which does
      -- not allow migration of a job between several cores
      --
      assigned_core_unit : core_unit_ptr;

      -- Is true if the task is already run on a core unit for the
      -- current time unit
      --
      already_run_at_current_time : Boolean;

      -- Store if the task is allowed to run due to its jitter
      --
      is_jitter_ready : Boolean;

      -- wake up time of the outer period
      -- for inner task models
      --
      outer_wake_up_time : Natural;

      ------------------------------
      -- Paramters of CRPD analysis
      ------------------------------

      -- UCBs of task
      --
      ucbs : integer_array;

      -- ECBs of task
      --
      ecbs : integer_array;

      -- UCBs, which were in the cache, of a task.
      --
      ucbs_in_cache : integer_array;

      -- CRPD needs to be handle before program continues execution
      --
      crpd_capacity : Natural;

      -- UCB loaded into the cache
      --
      ucbs_loaded : Float;

      -- BRT
      --
      block_reload_time : Natural;

   end record;

   type tcb_ptr is access all tcb'class;
   type tcb_table is array (tasks_range) of tcb_ptr;

   procedure initialize (a_tcb : in out tcb; a_task : generic_task_ptr);


   -- Information related to the processors
   --
   type pcb is tagged record

      -- Cheddar ADL properties of the processor
      --
      cpu : generic_processor_ptr;

      -- If true when no task are running on any core of 
      -- processor
      --
      is_idle : boolean;

   end record;

   type pcb_ptr is access all pcb'class;
   type pcb_table is array (processors_range) of pcb_ptr;

   procedure initialize (a_pcb : in out pcb; a_processor : generic_processor_ptr);

   -- Information related to the access on shared resources
   --
   type allocation_table is
     array (Natural range 0 .. Max_Tasks_For_A_Resource) of Unbounded_String;

   type shared_resource is tagged record
      shared       : generic_resource_ptr;
      allocated_by : allocation_table;
      nb_allocated : Natural := 0;
   end record;

   type shared_resource_ptr is access all shared_resource'class;
   type shared_resource_table is
     array (resources_range) of shared_resource_ptr;

   -- Information related to messages exchanges
   -- This data set stores messages that are on the way, 
   --   i.e. sent and waiting to be read
   --        or waiting for a condition before beeing sent
   --
   type message_scheduling_information is record
      status            : message_status_type;
      exchanged_message : generic_message_ptr;
      time              : Natural := 0;
   end record;

   type message_scheduling_information_ptr is
     access all message_scheduling_information;

   procedure free is new Unchecked_Deallocation
     (message_scheduling_information,
      message_scheduling_information_ptr);

   procedure put (m : in message_scheduling_information_ptr);

   function copy
     (obj : message_scheduling_information_ptr)
      return message_scheduling_information_ptr;

   function xml_string
     (obj : in message_scheduling_information_ptr) return Unbounded_String;

   package message_scheduling_information_list_package is new access_lists
     (message_scheduling_information,
      message_scheduling_information_ptr,
      put,
      free,
      copy,
      xml_string);
   use message_scheduling_information_list_package;
   subtype message_scheduling_information_list is
     message_scheduling_information_list_package.list;
   subtype message_scheduling_information_iterator is
     message_scheduling_information_list_package.iterator;

   -- Information related to buffer read/write
   -- Messages are data shared between tasks running on the same processor
   --

   type buffer_scheduling_information is record
      written_buffer : buffer_ptr;
      current_size   : Natural := 0;
   end record;

   type buffer_scheduling_information_ptr is
     access all buffer_scheduling_information;

   procedure free is new Unchecked_Deallocation
     (buffer_scheduling_information,
      buffer_scheduling_information_ptr);

   procedure put (m : in buffer_scheduling_information_ptr);

   function copy
     (obj : buffer_scheduling_information_ptr)
      return buffer_scheduling_information_ptr;

   function xml_string
     (obj : in buffer_scheduling_information_ptr) return Unbounded_String;

   package buffer_scheduling_information_list_package is new access_lists
     (buffer_scheduling_information,
      buffer_scheduling_information_ptr,
      put,
      free,
      copy,
      xml_string);
   use buffer_scheduling_information_list_package;
   subtype buffer_scheduling_information_list is
     buffer_scheduling_information_list_package.list;
   subtype buffer_scheduling_information_iterator is
     buffer_scheduling_information_list_package.iterator;

   -- Finally, the type which merge all the information declared
   -- Above (task, Resources, Buffers, Messages)
   --

   type scheduling_information is record

      simulation_length : Natural := 0;

      number_of_processors     : processors_range     := 0;
      number_of_address_spaces : address_spaces_range := 0;
      number_of_tasks          : tasks_range          := 0;
      number_of_resources      : resources_range      := 0;

      tcbs            	 	: tcb_table;
      pcbs             	: pcb_table;
      shared_resources 	: shared_resource_table;
      exchanged_messages	: message_scheduling_information_list;
      written_buffers  	: buffer_scheduling_information_list;

      batteries    : batteries_set;
      processors   : processors_set;
      dependencies : tasks_dependencies_ptr;

      empty_tdma_frame      : Boolean := True;
      current_tdma_slot     : slot_id_type;
      current_tdma_duration : Natural;
      tdma_frame            : tdma_frame_type;

      global_seed : State;

      number_of_preemption  : Natural := 0;
      total_preemption_cost : Natural := 0;
      
      -- variables for mixed criticality
      nb_HI_tasks				: Natural := 0;
      highest_priority_HItask			: tasks_range := 0;
      nb_LO_jobs_stopped			: Natural := 0;
      
      
      --FTP
      ftp_launch				: Boolean := False;
      ftp_completion_time_of_current_task	: Natural := 0;
      
      --BAILOUT
      bp_fund					: Integer := 0;
      bp_elected_task				: tasks_range := 0;
      bp_jk_job				: tasks_range := 0;
      bp_bailout_mode				: Boolean := False;
      bp_recovery_mode				: Boolean := False;
      bp_time_recovery				: Natural := 0;
      bp_time_mode_change			: Natural := 0;
      
      --IDLE
      idle_launch				: Boolean := False;
      
      hi_time_spend				: Natural := 0;
      lo_time_spend				: Natural := 0;
      state					: mode_range := Low_Criticality;
      launch_recovery_mode			: Boolean := False;
      nb_mode_change				: Natural := 0;
      nb_quality_improvement			: Natural := 0;
      nb_hi_finished_execution		: Natural := 0;
      nb_lo_finished_execution		: Natural := 0;
   end record;

   procedure initialize (s : in out scheduling_information);

   -------------------------------------------------------------
   -------------------------------------------------------------
   -- Abstract scheduler declaration : main entry point
   -- for scheduling source code
   -------------------------------------------------------------
   -------------------------------------------------------------
   type generic_scheduler;
   type generic_scheduler_ptr is access all generic_scheduler'class;

   type generic_scheduler is abstract new Ada.Finalization.Controlled with
   record

      -- Scheduler parameters : period, priority, capacity, preemptivity,
      -- quantum, ...
      --
      parameters : scheduling_parameters;

      -- Core unit, processor and address space  corresponding to this scheduler
      -- (used to forbid a task capacity to be run on several core unit)
      --
      corresponding_core_unit     : core_unit_ptr;
      corresponding_processor     : generic_processor_ptr;
      corresponding_address_space : address_space_ptr;

      -- Allow the scheduler to know if the previous task is completed
      -- or not ... and then, could be re-elected later
      -- (for non preemptive scheduling protocols)
      --
      previous_running_task_is_not_completed : Boolean := False;

      -- Last scheduled task, i.e. task run the previous time unit
      --
      previously_elected : tasks_range := tasks_range'first;

   end record;

   -------------------------------------------------------------
   -- Sub programs to display a scheduler
   -------------------------------------------------------------

   procedure put (my_scheduler : in generic_scheduler);

   procedure put (my_scheduler : in generic_scheduler_ptr);

   -------------------------------------------------------------
   -------------------------------------------------------------
   -- sub-program which can be used in order to access
   -- scheduler data
   -------------------------------------------------------------
   -------------------------------------------------------------

   procedure set_preemptive
     (my_scheduler : in out generic_scheduler'class;
      preempt      : in     preemptives_type);

   function get_preemptive
     (my_scheduler : in generic_scheduler'class) return preemptives_type;

   function get_preemptive
     (my_scheduler : in generic_scheduler'class) return String;

   function get_name
     (my_scheduler : in generic_scheduler'class) return schedulers_type;

   function get_name
     (my_scheduler : in generic_scheduler'class) return Unbounded_String;

   function get_name
     (my_scheduler : in generic_scheduler_ptr) return schedulers_type;

   function get_name
     (my_scheduler : in generic_scheduler_ptr) return Unbounded_String;

   procedure set_quantum
     (my_scheduler : in out generic_scheduler'class;
      q            : in     Natural);

   function get_quantum
     (my_scheduler : in generic_scheduler'class) return Natural;

   function get_quantum
     (my_scheduler : in generic_scheduler'class) return String;

   function get_quantum
     (my_scheduler : in generic_scheduler'class) return Unbounded_String;

   function copy
     (a_scheduler : in generic_scheduler)
      return generic_scheduler_ptr is abstract;

   -------------------------------------------------------------
   -------------------------------------------------------------
   -- Exception raised during feasibility test or simulation
   -------------------------------------------------------------
   -------------------------------------------------------------

   -- The required computation can not be done with such scheduler
   --
   invalid_scheduler : exception;

   -- Raised if during a bound blocking time computation
   -- resources with different protocols are met
   --
   other_resources_protocol_found : exception;

   -- Raised if an invalid resource protocol is found
   --
   invalid_protocol : exception;

   -- Raised if a scheduler parameter has an invalid value
   --
   invalid_scheduler_parameter : exception;

   ----------------------------------------------------------
   ----------------------------------------------------------
   -- Table of schedulers :
   -- This table type can be used to implement algorithms
   -- that require several schedulers, between several
   -- entities. For example: the scheduling simulator needs
   -- the types bellow
   --
   ----------------------------------------------------------
   ----------------------------------------------------------

   type entity_scheduler is new Ada.Finalization.Controlled with record
      scheduler : generic_scheduler_ptr;
   end record;
   type entity_scheduler_ptr is access all entity_scheduler'class;

   procedure put (obj : in entity_scheduler);
   procedure put (obj : in entity_scheduler_ptr);
   function xml_string (obj : in entity_scheduler) return Unbounded_String;
   function xml_string (obj : in entity_scheduler_ptr) return Unbounded_String;

   type address_space_scheduler is new entity_scheduler with record
      -- Address space entity related to the scheduler
      --
      corresponding_address_space : address_space_ptr;
   end record;
   type address_space_scheduler_ptr is
     access all address_space_scheduler'class;

   type core_scheduler is new entity_scheduler with record
      entity : core_unit_ptr;
   end record;
   type core_scheduler_ptr is access all core_scheduler'class;

   package schedulers_table_package is new tables
     (entity_scheduler_ptr,
      Max_Schedulers,
      put,
      xml_string,
      xml_string);
   use schedulers_table_package;
   subtype scheduler_table_range is schedulers_table_package.table_range;
   subtype scheduler_table_range_ptr is
     schedulers_table_package.table_range_ptr;
   subtype scheduler_table is schedulers_table_package.table;
   subtype scheduler_table_ptr is schedulers_table_package.table_ptr;

   -------------------------------------------------------------
   -------------------------------------------------------------
   --  Procedure and functions to run a scheduling simulation
   -------------------------------------------------------------
   -------------------------------------------------------------

   -- Compute the next time on which the task will be ready to run (task
   -- wakeup time)
   -- May be overidden by specific scheduler (ie parametric scheduler)
   --
   procedure compute_activation_time
     (my_scheduler : in     generic_scheduler;
      si           : in out scheduling_information;
      elected      : in     tasks_range;
      value        : in out Natural);

   ----------------------------------------------------------------------------
   ------ Subprograms named update_ update simulation data when scheduling
   ------ decisions are taken
   ----------------------------------------------------------------------------

   -- Update data simulation and produce simulation events
   -- whenever a task is run or not after scheduling decision
   -- are taken for the core
   --
   procedure update_after_core_scheduling
     (my_scheduler      : in out generic_scheduler'class;
      processor_name    : in     Unbounded_String;
      si                : in out scheduling_information;
      my_dependencies   : in     tasks_dependencies_ptr;
      elected           : in     tasks_range;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      last_time         : in     Natural;
      options           : in     scheduling_option;
      event_to_generate : in     time_unit_event_type_boolean_table);

   -- Update data simulation and produce simulation events
   -- whenever a task is run or not after scheduling decision
   -- are taken for the processor
   --
   procedure update_after_processor_scheduling
     (my_scheduler      : in out generic_scheduler'class;
      processor_name    : in     Unbounded_String;
      si                : in out scheduling_information;
      my_dependencies   : in     tasks_dependencies_ptr;
      elected           : in     tasks_range;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      last_time         : in     Natural;
      options           : in     scheduling_option;
      event_to_generate : in     time_unit_event_type_boolean_table);

   -- Update data simulation and produce simulation events
   -- only when a task is run after scheduling decision
   -- are taken for the processor
   --
   procedure update_after_processor_scheduling_when_task_is_run
     (my_scheduler      : in out generic_scheduler'class;
      processor_name    : in     Unbounded_String;
      si                : in out scheduling_information;
      my_dependencies   : in     tasks_dependencies_ptr;
      elected           : in     tasks_range;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      last_time         : in     Natural;
      options           : in     scheduling_option;
      event_to_generate : in     time_unit_event_type_boolean_table);

   ----------------------------------------------------------------------------
   ------

   procedure compute_next_task_activation
     (my_scheduler : in out generic_scheduler'class;
      a_tcb        : in     tcb_ptr;
      si           : in out scheduling_information;
      options      : in     scheduling_option;
      elected      : in     tasks_range);

   -- At scheduling simulation starting time, check that the simulation
   -- can be done according to the selected scheduler and the task set
   --
   procedure check_before_scheduling
     (my_scheduler   : in generic_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) is abstract;

   ----------------------------------------------------------------------------
   ------

   -- The following sub-programs initialize the data simulation

   -- Initialization made by each scheduler (initializations which
   -- depend on the type of scheduler)
   --
   procedure specific_scheduler_initialization
     (my_scheduler       : in out generic_scheduler;
      si                 : in out scheduling_information;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      my_tasks           : in out tasks_set;
      my_schedulers      : in     scheduler_table;
      my_resources       : in out resources_set;
      my_buffers         : in out buffers_set;
      my_messages        : in     messages_set;
      msg                : in out Unbounded_String) is abstract;

   -- Initialization made for each processor
   --
   procedure processor_initialization
     (my_scheduler             : in out generic_scheduler'class;
      si                       : in out scheduling_information;
      processor_name           : in     Unbounded_String;
      my_tasks                 : in out tasks_set;
      my_resources             : in out resources_set;
      my_buffers               : in out buffers_set;
      result                   : in out scheduling_sequence_ptr;
      options                  : in     scheduling_option;
      given_last_time          : in     Natural;
      event_to_generate        : in     time_unit_event_type_boolean_table;
      my_cache_access_profiles : in     cache_access_profiles_set;
      my_caches                : in     caches_set);

   -- Initialization made for each core unit
   --
   procedure core_unit_initialization
     (my_scheduler      : in out generic_scheduler'class;
      si                : in out scheduling_information;
      processor_name    : in     Unbounded_String;
      my_tasks          : in out tasks_set;
      my_resources      : in out resources_set;
      my_buffers        : in out buffers_set;
      result            : in out scheduling_sequence_ptr;
      options           : in     scheduling_option;
      given_last_time   : in     Natural;
      event_to_generate : in     time_unit_event_type_boolean_table);

   ----------------------------------------------------------------------------
   ------

   -- Choose the task to be run at a given time
   --
   procedure do_election
     (my_scheduler       : in out generic_scheduler;
      si                 : in out scheduling_information;
      result             : in out scheduling_sequence_ptr;
      msg                : in out Unbounded_String;
      current_time       : in     Natural;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      core_name          : in     Unbounded_String;
      options            : in     scheduling_option;
      event_to_generate  : in     time_unit_event_type_boolean_table;
      elected            : in out tasks_range;
      no_task            : in out Boolean) is abstract;

   ----------------------------------------------------------------------------
   ------

   -- Sub-programs used to build the scheduling information
   --
   function build_tcb
     (my_scheduler : in generic_scheduler;
      a_task       :    generic_task_ptr) return tcb_ptr;

   function build_resource
     (my_scheduler : in generic_scheduler;
      a_resource   :    generic_resource_ptr) return shared_resource_ptr;

   -- Perform treatements when we simulation shared resources access :
   -- allocation of the shared resource, releasing the shared resource
   -- and checking that the resource can be taken
   --
   procedure allocate_resource
     (my_scheduler      : in out generic_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             :        tcb_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table);

   procedure release_resource
     (my_scheduler      : in out generic_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             :        tcb_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table);

   procedure check_resource
     (my_scheduler      : in out generic_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             : in     tcb_ptr;
      is_ready          :    out Boolean;
      event_to_generate : in     time_unit_event_type_boolean_table);

   -- Check that the task can be run according to its wake up time offset
   --
   function check_offset (a_tcb : tcb_ptr; at_time : Natural) return Boolean;

   -- Return true is the task "a_tcb" can be schedule now
   -- according its jitter
   --
   procedure check_jitter
     (a_tcb    : in     tcb_ptr;
      at_time  : in     Natural;
      is_ready :    out Boolean);

   -- Check that the task can be run to the current core
   -- according to core migration properties
   --
   function check_core_assignment
     (a_scheduler : in generic_scheduler;
      a_tcb       : in tcb_ptr) return Boolean;

   -- Check that a task can be run according to its
   -- task dependencies
   -- With such subprogram, we check all release contraints
   -- due to any dependency (precedence, tdma_communications, asynchronous_communication)
   -- This sub program verifies that precedencies are met, i.e. that a task
   -- can be released because another had made an action
   --
   function check_precedencies
     (si           : in scheduling_information;
      current_time : in Natural;
      a_tcb        :    tcb_ptr) return Boolean;

   -- Perform treatements when we simulation messages exchanges  :
   -- send a message to a task, and receive a message from a task
   --
   procedure send_message
     (my_scheduler      : in out generic_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             :        tcb_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table);

   procedure receive_message
     (my_scheduler      : in out generic_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             :        tcb_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table);


   -- Perform treatements when we simulate buffer access  :
   -- write bytes into a buffer of read bytes from a buffer
   --
   procedure buffer_read
     (my_scheduler      : in out generic_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             :        tcb_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table);

   procedure buffer_write
     (my_scheduler      : in out generic_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             :        tcb_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table);

   -------------------------------------------------------------
   -------------------------------------------------------------
   -- I/O operations
   -------------------------------------------------------------
   -------------------------------------------------------------

   -- XML export of the event table
   -- These sub-programs can be overidden by specific scheduler
   -- if events must provide specific information. This information
   -- is carried on by XML attributes
   --

   -- Produce event of the scheduling sequence
   --
   procedure produce_running_task_event
     (my_scheduler : in     generic_scheduler;
      a_task       : in     tcb_ptr;
      options      : in     scheduling_option;
      si           : in     scheduling_information;
      an_event     :    out time_unit_event_ptr);
   procedure produce_task_activation_event
     (my_scheduler : in     generic_scheduler;
      a_task       : in     tcb_ptr;
      options      : in     scheduling_option;
      si           : in     scheduling_information;
      an_event     :    out time_unit_event_ptr);
   procedure produce_end_of_task_capacity_event
     (my_scheduler : in     generic_scheduler;
      a_task       : in     tcb_ptr;
      options      : in     scheduling_option;
      si           : in     scheduling_information;
      an_event     :    out time_unit_event_ptr);
   procedure produce_start_of_task_capacity_event
     (my_scheduler : in     generic_scheduler;
      a_task       : in     tcb_ptr;
      options      : in     scheduling_option;
      si           : in     scheduling_information;
      an_event     :    out time_unit_event_ptr);
   procedure produce_discard_missed_deadline_event
     (my_scheduler : in     generic_scheduler;
      a_task       : in     tcb_ptr;
      options      : in     scheduling_option;
      si           : in     scheduling_information;
      an_event     :    out time_unit_event_ptr);

   -- Export XML event table
   --
   function export_xml_event_write_to_buffer
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String;
   function export_xml_event_read_from_buffer
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String;
   function export_xml_event_context_switch_overhead
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String;
   function export_xml_event_running_task
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String;
   function export_xml_event_address_space_activation
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String;
   function export_xml_event_task_activation
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String;
   function export_xml_event_start_of_task_capacity
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String;
   function export_xml_event_end_of_task_capacity
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String;
   function export_xml_event_send_message
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String;
   function export_xml_event_receive_message
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String;
   function export_xml_event_allocate_resource
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String;
   function export_xml_event_release_resource
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String;
   function export_xml_event_wait_for_resource
     (my_scheduler : in generic_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String;

   function xml_string
     (obj : in generic_scheduler_ptr) return Unbounded_String;

   procedure build_attributes_xml_string
     (obj    : in     generic_scheduler_ptr;
      result : in out Unbounded_String);

   procedure free is new Unchecked_Deallocation
     (generic_scheduler'class,
      generic_scheduler_ptr);

   procedure reset (a_scheduler : in out generic_scheduler'class);
end scheduler;
