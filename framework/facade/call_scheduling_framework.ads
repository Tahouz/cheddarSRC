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
--    $Rev: 4714 $
--    $Date: 2023-12-18 00:07:26 +0100 (lun., 18 déc. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with time_unit_events;         use time_unit_events;
with systems;                  use systems;
with Call_Framework_Interface; use Call_Framework_Interface;
with Processors;               use Processors;
with processor_set;            use processor_set;
use processor_set.generic_processor_set;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with Scheduler_Interface;               use Scheduler_Interface;
with scheduler;                         use scheduler;
with scheduler_builder;                 use scheduler_builder;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with task_set; use task_set;
use task_set.generic_task_set;
with scheduling_options; use scheduling_options;

package call_scheduling_framework is

   procedure compute_simulation_time_line
     (sys               : in out System; result : in out Unbounded_String;
      period            : in     Natural; options : in scheduling_option;
      event_to_generate : in     time_unit_event_type_boolean_table;
      output            : in     Output_Format := String_Output);

   procedure compute_simulation_basics
     (sys         : in System; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr;
      output      : in Output_Format := String_Output);

   procedure compute_simulation_number_of_preemption
     (sys         : in System; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr;
      output      : in Output_Format := String_Output);

   procedure compute_simulation_number_of_context_switch
     (sys         : in System; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr;
      output      : in Output_Format := String_Output);

   procedure compute_simulation_number_of_overflow
     (sys         : in System; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr;
      output      : in Output_Format := String_Output);

   procedure compute_simulation_number_of_underflow
     (sys         : in System; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr;
      output      : in Output_Format := String_Output);

   procedure compute_simulation_response_time
     (sys         : in System; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr; worst_case : Boolean;
      best_case   :    Boolean; average_case : Boolean;
      output      : in Output_Format := String_Output);

   procedure compute_feasibility_test_by_name
     (sys         : in System; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr; test_name : Unbounded_String;
      output      : in Output_Format := String_Output);

   procedure run_user_defined_event_handlers
     (sys    : in System; result : in out Unbounded_String;
      output : in Output_Format := String_Output);

   procedure compute_feasibility_basics
     (sys         : in out System; result : in out Unbounded_String;
      a_processor : in     generic_processor_ptr;
      output      : in     Output_Format := String_Output);

   procedure compute_feasibility_interval
     (sys         : in System; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr;
      output      : in Output_Format := String_Output);

   procedure compute_feasibility_processor_utilization_factor
     (sys         : in System; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr;
      output      : in Output_Format := String_Output);

   procedure compute_feasibility_by_demand_bound_function
     (sys         : in System; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr;
      output      : in Output_Format := String_Output);

   procedure compute_feasibility_response_time
     (sys : in out System; result : in out Unbounded_String;
      a_transaction                  : in     Transaction_Wcrt_Type;
      wcrt_with_memory_interferences : in memory_interference_computation_approach_type :=
        No_Memory_Interference;
      with_crpd   : in crpd_computation_approach_type := No_CRPD;
      a_processor : in generic_processor_ptr;
      output      : in Output_Format                  := String_Output);

   procedure set_priorities
     (sys         : in out System; result : in out Unbounded_String;
      a_processor : in     generic_processor_ptr;
      a_scheduler : in     Framework_Statement_Type;
      output      : in     Output_Format := String_Output);

   procedure partionning_tasks
     (sys             : in out System; result : in out Unbounded_String;
      a_parition_rule : in     Partioning_Type;
      output          : in     Output_Format := String_Output);

end call_scheduling_framework;
