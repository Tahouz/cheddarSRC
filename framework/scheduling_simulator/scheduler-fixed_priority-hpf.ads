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

with fifos;

package scheduler.fixed_priority.hpf is

   type hpf_scheduler is new fixed_priority_scheduler with private;
   type hpf_scheduler_ptr is access all hpf_scheduler'class;

   type hpf_tcb is new fixed_priority_tcb with record
      task_quantum : Natural := 0;
   end record;

   type hpf_tcb_ptr is access all hpf_tcb'class;

   procedure initialize (a_tcb : in out hpf_tcb);

   procedure initialize (a_scheduler : in out hpf_scheduler);

   function copy (a_scheduler : in hpf_scheduler) return generic_scheduler_ptr;

   procedure check_before_scheduling
     (my_scheduler   : in hpf_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String);

   function build_tcb
     (my_scheduler : in hpf_scheduler;
      a_task       :    generic_task_ptr) return tcb_ptr;

   procedure do_election
     (my_scheduler       : in out hpf_scheduler;
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

   procedure specific_scheduler_initialization
     (my_scheduler       : in out hpf_scheduler;
      si                 : in out scheduling_information;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      my_tasks           : in out tasks_set;
      my_schedulers      : in     scheduler_table;
      my_resources       : in out resources_set;
      my_buffers         : in out buffers_set;
      my_messages        : in     messages_set;
      msg                : in out Unbounded_String);

   procedure dispatched_change_current_priority
     (my_scheduler : in out hpf_scheduler;
      a_tcb        : in     fixed_priority_tcb_ptr;
      new_priority :        priority_range);

private

   procedure put_tcb (e : hpf_tcb_ptr);

   function increasing_wakeup_time
     (op1 : in hpf_tcb_ptr;
      op2 : in hpf_tcb_ptr) return Boolean;

   package tcb_fifos is new fifos
     (Framework_Config.Max_Tasks,
      hpf_tcb_ptr,
      put_tcb);
   use tcb_fifos;

   type fifo_table is array (priority_range) of fifo;

   type hpf_scheduler is new fixed_priority_scheduler with record
      priority_fifos : fifo_table;
   end record;

end scheduler.fixed_priority.hpf;
