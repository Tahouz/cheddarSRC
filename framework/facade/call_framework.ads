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

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Parameters;            use Parameters;
use Parameters.Framework_Parameters_Table_Package;
with Parameters.extended;      use Parameters.extended;
with Framework_Config;         use Framework_Config;
with systems;                  use systems;
with tables;
with Call_Framework_Interface; use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Request_Package;
with id_generators; use id_generators;

package call_framework is

   -- All parameters of the framework are given there
   -- Those parameters are valid for any service of the framework facade
   --
   boolean_framework_parameter_name : array (1 .. 44) of Unbounded_String :=
     (To_Unbounded_String ("schedule_with_offsets"),
      To_Unbounded_String ("schedule_with_precedencies"),
      To_Unbounded_String ("schedule_with_resources"),
      To_Unbounded_String ("schedule_with_jitters"),
      To_Unbounded_String ("schedule_with_crpd"),
      To_Unbounded_String ("schedule_with_discard_missed_deadlines"),
      To_Unbounded_String ("wcrt_without_crpd"),
      To_Unbounded_String ("wcrt_with_crpd_ECB_only"),
      To_Unbounded_String ("wcrt_with_crpd_ECB_union_multiset"),
      To_Unbounded_String ("wcrt_with_crpd_UCB_union_multiset"),
      To_Unbounded_String ("wcrt_with_crpd_combined_multiset"),
      To_Unbounded_String ("wcrt_without_memory_interferences"),
      To_Unbounded_String ("wcrt_with_DRAM_single_arbiter"),
      To_Unbounded_String ("wcrt_with_kalray_multi_arbiter"),
      To_Unbounded_String ("minimize_preemption"),
      To_Unbounded_String ("predictable"),
      To_Unbounded_String ("context_switch_overhead"),
      To_Unbounded_String ("start_of_task_capacity"),
      To_Unbounded_String ("end_of_task_capacity"),
      To_Unbounded_String ("write_to_buffer"),
      To_Unbounded_String ("read_from_buffer"),
      To_Unbounded_String ("buffer_overflow"),
      To_Unbounded_String ("buffer_underflow"),
      To_Unbounded_String ("running_task"),
      To_Unbounded_String ("task_activation"),
      To_Unbounded_String ("send_message"),
      To_Unbounded_String ("receive_message"),
      To_Unbounded_String ("allocate_resource"),
      To_Unbounded_String ("release_resource"),
      To_Unbounded_String ("wait_for_resource"),
      To_Unbounded_String ("wait_for_memory"),
      To_Unbounded_String ("preemption"),
      To_Unbounded_String ("address_space_activation"),
      To_Unbounded_String ("schedule_with_task_groups"),
      To_Unbounded_String ("anomaly_detection"), To_Unbounded_String ("dvfs"),
      To_Unbounded_String ("task_specific_seed"),
      To_Unbounded_String ("worst_case"), To_Unbounded_String ("best_case"),
      To_Unbounded_String ("average_case"),
      To_Unbounded_String ("discard_missed_deadline"),
      To_Unbounded_String ("mode_change"),
      To_Unbounded_String ("tdma_slot"),
      To_Unbounded_String ("energy"));

   integer_framework_parameter_name : array (1 .. 2) of Unbounded_String :=
     (To_Unbounded_String ("period"), To_Unbounded_String ("seed_value"));

   string_framework_parameter_name : array (1 .. 2) of Unbounded_String :=
     (To_Unbounded_String ("feasibility_test_name"),
      To_Unbounded_String ("feasibility_test_name"));

   -- Exception that may be raised during service excecution
   --
   invalid_number_of_parameter : exception;
   unexpected_parameter        : exception;
   parameter_type_error        : exception;

   -- Initialize the framework. Should be called before any
   -- use of the framework
   --
   procedure initialize (aadl_labels : in Boolean);

   -- Call the framework
   -- A call may containt several requests run sequantialy or concurrently
   -- depending on the wa the service is called
   --
   procedure sequential_framework_request
     (sys      : in out system; request : in framework_request_table;
      response : in out framework_response_table; order : in perform_order;
      output   : in     output_format);

   procedure sequential_framework_request
     (sys      : in out system_ptr; request : in framework_request_table;
      response : in out framework_response_table; order : in perform_order;
      output   : in     output_format);

   procedure sequential_framework_request
     (sys      : in out system; request : in framework_request_table;
      response : in out framework_response_table);

   procedure parallel_framework_request
     (sys      : in out system; request : in framework_request_table;
      response : in out framework_response_table;
      order    : in     perform_order := total_order;
      output   : in     output_format := string_output);

   procedure distributed_framework_request
     (sys      : in out system; request : in framework_request_table;
      response : in out framework_response_table;
      order    : in     perform_order := total_order;
      output   : in     output_format := string_output);

end call_framework;
