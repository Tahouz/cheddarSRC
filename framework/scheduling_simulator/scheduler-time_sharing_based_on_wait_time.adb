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
with translate;         use translate;

package body scheduler.time_sharing_based_on_wait_time is

   procedure initialize (a_tcb : in out time_sharing_based_on_wait_time_tcb) is
   begin
      a_tcb.last_time_the_task_was_ready := 0;
      a_tcb.is_ready                     := False;
   end initialize;

   function build_tcb
     (my_scheduler : in time_sharing_based_on_wait_time_scheduler;
      a_task       :    generic_task_ptr) return tcb_ptr
   is
      a_tcb : time_sharing_based_on_wait_time_tcb_ptr;
   begin
      a_tcb := new time_sharing_based_on_wait_time_tcb;
      initialize (tcb (a_tcb.all), a_task);
      initialize (a_tcb.all);
      return tcb_ptr (a_tcb);
   end build_tcb;

   procedure initialize
     (a_scheduler : in out time_sharing_based_on_wait_time_scheduler)
   is
   begin
      reset (a_scheduler);
      a_scheduler.parameters.scheduler_type :=
        time_sharing_based_on_wait_time_protocol;
   end initialize;

   function copy
     (a_scheduler : in time_sharing_based_on_wait_time_scheduler)
      return generic_scheduler_ptr
   is
      ptr : time_sharing_based_on_wait_time_scheduler_ptr;

   begin

      ptr := new time_sharing_based_on_wait_time_scheduler;

      ptr.parameters         := a_scheduler.parameters;
      ptr.previously_elected := a_scheduler.previously_elected;

      return generic_scheduler_ptr (ptr);

   end copy;

   procedure put
     (my_scheduler : in time_sharing_based_on_wait_time_scheduler)
   is
   begin
      put (generic_scheduler (my_scheduler));
   end put;

   procedure check_before_scheduling
     (my_scheduler   : in time_sharing_based_on_wait_time_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

   begin
      null;
   end check_before_scheduling;

   procedure do_election
     (my_scheduler       : in out time_sharing_based_on_wait_time_scheduler;
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
      no_task            : in out Boolean)
   is

      oldest_ready_task : Natural     := Natural'last;
      i                 : tasks_range := 0;

   begin

      -- For the previously executed task, the waiting time should be updated
      -- to the current_time (except for the very first unit of time
      --
      if (current_time > 0) then
         time_sharing_based_on_wait_time_tcb_ptr
           (si.tcbs (my_scheduler.previously_elected))
           .last_time_the_task_was_ready :=
           current_time;
      end if;

      -- Check is the task is ready
      -- if a task is already known to be ready, do not change any thing
      --
      i := 0;
      loop
         if not si.tcbs (i).already_run_at_current_time then
            if (si.tcbs (i).tsk.cpu_name = processor_name) then
               if check_core_assignment (my_scheduler, si.tcbs (i)) then
                  if (si.tcbs (i).wake_up_time <= current_time) and
                    (si.tcbs (i).rest_of_capacity /= 0) and
                    ((options.with_offsets = False) or
                     check_offset (si.tcbs (i), current_time)) and
                    ((options.with_precedencies = False) or
                     check_precedencies (si, current_time, si.tcbs (i)))
                  then
                     if not time_sharing_based_on_wait_time_tcb_ptr
                         (si.tcbs (i))
                         .is_ready
                     then
                        time_sharing_based_on_wait_time_tcb_ptr (si.tcbs (i))
                          .is_ready :=
                          True;
                        time_sharing_based_on_wait_time_tcb_ptr (si.tcbs (i))
                          .last_time_the_task_was_ready :=
                          current_time;
                     end if;
                  else
                     time_sharing_based_on_wait_time_tcb_ptr (si.tcbs (i))
                       .is_ready :=
                       False;
                  end if;
               end if;
            end if;
         end if;

         i := i + 1;
         exit when si.tcbs (i) = null;
      end loop;

      -- When last task waiting time are updated, find the task to run
      --
      i := 0;
      loop
         if (si.tcbs (i).tsk.cpu_name = processor_name) then
            if time_sharing_based_on_wait_time_tcb_ptr (si.tcbs (i))
                .is_ready
            then
               if time_sharing_based_on_wait_time_tcb_ptr (si.tcbs (i))
                   .last_time_the_task_was_ready <
                 oldest_ready_task
               then
                  oldest_ready_task :=
                    time_sharing_based_on_wait_time_tcb_ptr (si.tcbs (i))
                      .last_time_the_task_was_ready;
                  elected := i;
               end if;
            end if;
         end if;

         i := i + 1;
         exit when si.tcbs (i) = null;
      end loop;

      if oldest_ready_task = Natural'last then
         no_task := True;
      else
         no_task := False;
      end if;

   end do_election;

   procedure specific_scheduler_initialization
     (my_scheduler       : in out time_sharing_based_on_wait_time_scheduler;
      si                 : in out scheduling_information;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      my_tasks           : in out tasks_set;
      my_schedulers      : in     scheduler_table;
      my_resources       : in out resources_set;
      my_buffers         : in out buffers_set;
      my_messages        : in     messages_set;
      msg                : in out Unbounded_String)
   is

   begin
      null;
   end specific_scheduler_initialization;

   procedure compute_activation_time
     (my_scheduler : in     time_sharing_based_on_wait_time_scheduler;
      si           : in out scheduling_information;
      elected      : in     tasks_range;
      value        : in out Natural)
   is

   begin
      raise invalid_scheduler;
   end compute_activation_time;

end scheduler.time_sharing_based_on_wait_time;
