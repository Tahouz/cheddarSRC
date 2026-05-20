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

with unbounded_strings; use unbounded_strings;

package scheduler.fixed_priority is

   type fixed_priority_scheduler is
     abstract new generic_scheduler with private;
   type fixed_priority_scheduler_ptr is
     access all fixed_priority_scheduler'class;

   type fixed_priority_tcb is new tcb with record

      -- With fixed priority, task priority may change due to resource accesses
      -- This attribute stores the current task priorities taking care of resource accesses
      current_priority : priority_range;

      -- Store if a task is allowed to run because of its resource access requirement, i.e. does
      -- the task would be blocked now due to lock resources ??
      is_resource_ready : Boolean;

   end record;

   type fixed_priority_tcb_ptr is access all fixed_priority_tcb'class;

   procedure initialize (a_tcb : in out fixed_priority_tcb);

   ----------------------------------------

   type fixed_priority_resource is new shared_resource with record
      priority_ceiling : priority_range;
   end record;

   type fixed_priority_resource_ptr is
     access all fixed_priority_resource'class;

--------------------------------------------------------------------------------------------------------------------------------------------
-- This text is a summary of the blocking and priority inheritance implemented in this package
--------------------------------------------------------------------------------------------------------------------------------------------
--   Protocol        | Conditions to allocate           | action when requesting        | action on allocate    | action on release
--                   |                                  | task is blocked on            |                       |
--                   |                                  | allocation request            |                       |
--------------------------------------------------------------------------------------------------------------------------------------------
--   no_protocol     | resource.state>0                 |                               | resource.state--      | resource.state++
--------------------------------------------------------------------------------------------------------------------------------------------
--   PIP             |                                  | task in critical section      |                       | task leaving
--                   |                                  | inherits requesting task      |                       | resource
--                   |                                  | priority                      |                       | gets its initial priority
--                   | resource.state>0                 |                               | resource.state--      | resource.state++
--------------------------------------------------------------------------------------------------------------------------------------------
--   IPCP            | resource.state>0                 |                               | resource.state--      | resource.state++
--                   |                                  |                               |                       |
--                   |                                  |                               | requestion task priority = max (static priority,
--                   |                                  |                               |   ceiling priority of all allocated resources)
--------------------------------------------------------------------------------------------------------------------------------------------
--   PCP             | resource.state>0 AND             | task in critical section      |                       | task leaving
--                   | priority of requesting task is   | inherits requesting task      |                       | resource
--                   | greater than all priority ceiling| priority                      |                       | gets its initial priority
--                   | of resource that are allocated   |                               |                       |
--                   | by other tasks                   |                               |                       |
--                   |                                  |                               | resource.state--      | resource.state++
--------------------------------------------------------------------------------------------------------------------------------------------
--   PPCP            | resource.state>0 AND             | task in critical section      |                       | task leaving
--                   | priority of requesting task is   | inherits requesting task      |                       | resource
--                   | greater than all priority ceiling| priority                      |                       | gets its initial priority
--                   | of resources that are allocated  |                               |                       |
--                   | by other tasks from the same pool|                               |                       |
--                   | (ie sharing resources either     |                               |                       |
--                   | directly or indirectly wih the   |                               |                       |
--                   | requesting task)                 |                               | resource.state--      | resource.state++
--------------------------------------------------------------------------------------------------------------------------------------------

   function build_resource
     (my_scheduler : in fixed_priority_scheduler;
      a_resource   :    generic_resource_ptr) return shared_resource_ptr;

   function build_tcb
     (my_scheduler : in fixed_priority_scheduler;
      a_task       :    generic_task_ptr) return tcb_ptr;

   procedure do_election
     (my_scheduler       : in out fixed_priority_scheduler;
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

   procedure check_resource
     (my_scheduler      : in out fixed_priority_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             : in     tcb_ptr;
      is_ready          :    out Boolean;
      event_to_generate : in     time_unit_event_type_boolean_table);

   procedure allocate_resource
     (my_scheduler      : in out fixed_priority_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             :        tcb_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table);

   procedure release_resource
     (my_scheduler      : in out fixed_priority_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             :        tcb_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table);

   procedure specific_scheduler_initialization
     (my_scheduler       : in out fixed_priority_scheduler;
      si                 : in out scheduling_information;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      my_tasks           : in out tasks_set;
      my_schedulers      : in     scheduler_table;
      my_resources       : in out resources_set;
      my_buffers         : in out buffers_set;
      my_messages        : in     messages_set;
      msg                : in out Unbounded_String);

   procedure compute_ceiling_of_resources
     (my_scheduler       : in out fixed_priority_scheduler;
      si                 : in out scheduling_information;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      my_tasks           : in out tasks_set;
      my_resources       : in out resources_set);

   procedure dispatched_change_current_priority
     (my_scheduler : in out fixed_priority_scheduler;
      a_tcb        : in     fixed_priority_tcb_ptr;
      new_priority :        priority_range);

   procedure change_current_priority
     (my_scheduler : in out fixed_priority_scheduler'class;
      a_tcb        : in     fixed_priority_tcb_ptr;
      new_priority :        priority_range);

   procedure produce_running_task_event
     (my_scheduler : in     fixed_priority_scheduler;
      a_task       : in     tcb_ptr;
      options      : in     scheduling_option;
      si           : in     scheduling_information;
      an_event     :    out time_unit_event_ptr);

   function export_xml_event_running_task
     (my_scheduler : in fixed_priority_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String;

private

   type fixed_priority_scheduler is abstract new generic_scheduler with record
      used_resource : Boolean := False;
   end record;

end scheduler.fixed_priority;
