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
--    $Rev: 4589 $
--    $Date: 2023-09-29 16:02:19 +0200 (ven., 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;

package scheduler.hierarchical.offline is

   type hierarchical_offline_scheduler is
     new hierarchical_scheduler with private;
   type hierarchical_offline_scheduler_ptr is
     access all hierarchical_scheduler'class;

   procedure initialize (a_scheduler : in out hierarchical_offline_scheduler);

   function copy
     (a_scheduler : in hierarchical_offline_scheduler)
      return generic_scheduler_ptr;

   procedure check_before_scheduling
     (my_scheduler   : in hierarchical_offline_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String);

   function build_resource
     (my_scheduler : in hierarchical_offline_scheduler;
      a_resource   :    generic_resource_ptr) return shared_resource_ptr;

   function build_tcb
     (my_scheduler : in hierarchical_offline_scheduler;
      a_task       :    generic_task_ptr) return tcb_ptr;

   procedure specific_scheduler_initialization
     (my_scheduler       : in out hierarchical_offline_scheduler;
      si                 : in out scheduling_information;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      my_tasks           : in out tasks_set;
      my_schedulers      : in     scheduler_table;
      my_resources       : in out resources_set;
      my_buffers         : in out buffers_set;
      my_messages        : in     messages_set;
      msg                : in out Unbounded_String);

   procedure do_election
     (my_scheduler       : in out hierarchical_offline_scheduler;
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
      no_task            : in out Boolean);

   function get_event_table
     (my_scheduler : in hierarchical_offline_scheduler)
      return scheduling_table_ptr;

   procedure set_event_table
     (my_scheduler : in out hierarchical_offline_scheduler;
      a_table      : in     scheduling_table_ptr);

private

   type hierarchical_offline_scheduler is new hierarchical_scheduler with
   record

      -- Index of the address space scheduler in the address space local scheduler table
      --
      address_space_scheduler_index : scheduler_table_range := 0;

   -- Index of the running address space in the scheduling table which contains
   -- the offline address space scheduling
      --
      scheduling_table_index : time_unit_range := 0;

      -- Scheduling table which contains
      -- off line address space scheduling
      --
      address_space_scheduling_table : scheduling_table_ptr;

   end record;

end scheduler.hierarchical.offline;
