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

with translate; use translate;
with Text_IO;   use Text_IO;
with task_set;  use task_set;

package body scheduler.fixed_priority.hpf is

   function build_tcb
     (my_scheduler : in hpf_scheduler;
      a_task       :    generic_task_ptr) return tcb_ptr
   is
      a_tcb : hpf_tcb_ptr;
   begin
      a_tcb := new hpf_tcb;
      initialize (tcb (a_tcb.all), a_task);
      initialize (fixed_priority_tcb (a_tcb.all));
      initialize (a_tcb.all);
      return tcb_ptr (a_tcb);
   end build_tcb;

   procedure initialize (a_tcb : in out hpf_tcb) is
   begin
      a_tcb.task_quantum := 0;
   end initialize;

   procedure initialize (a_scheduler : in out hpf_scheduler) is
   begin
      reset (a_scheduler);
      a_scheduler.parameters.scheduler_type :=
        posix_1003_highest_priority_first_protocol;
   end initialize;

   function copy
     (a_scheduler : in hpf_scheduler) return generic_scheduler_ptr
   is
      ptr : hpf_scheduler_ptr;

   begin

      ptr := new hpf_scheduler;

      ptr.parameters         := a_scheduler.parameters;
      ptr.previously_elected := a_scheduler.previously_elected;
      ptr.used_resource      := a_scheduler.used_resource;
      ptr.priority_fifos     := a_scheduler.priority_fifos;

      return generic_scheduler_ptr (ptr);

   end copy;

   procedure check_before_scheduling
     (my_scheduler   : in hpf_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

   begin

      null;

   end check_before_scheduling;

   procedure put_tcb (e : hpf_tcb_ptr) is
   begin
      Put_Line ("Task = " & To_String (e.tsk.name));
   end put_tcb;

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
      msg                : in out Unbounded_String)
   is

      index : tasks_range := 0;

   begin
      for i in priority_range loop
         reset (my_scheduler.priority_fifos (i));
      end loop;

      for i in 0 .. si.number_of_tasks - 1 loop
         if (si.tcbs (i).tsk.cpu_name = processor_name) and
           ((address_space_name = To_Unbounded_String ("")) or
            (address_space_name = si.tcbs (i).tsk.address_space_name))
         then
            fixed_priority_tcb_ptr (si.tcbs (i)).current_priority :=
              si.tcbs (i).tsk.priority;
            hpf_tcb_ptr (si.tcbs (i)).task_quantum :=
              my_scheduler.parameters.quantum;
         end if;
      end loop;

      -- Insert task info fifos according to
      -- their priority level
      --
      loop
         if (si.tcbs (index).tsk.cpu_name = processor_name) and
           ((address_space_name = To_Unbounded_String ("")) or
            (address_space_name = si.tcbs (index).tsk.address_space_name))
         then
            insert
              (my_scheduler.priority_fifos
                 (hpf_tcb_ptr (si.tcbs (index)).current_priority),
               hpf_tcb_ptr (si.tcbs (index)));
         end if;

         index := index + 1;
         exit when si.tcbs (index) = null;
      end loop;

      -- Set priority ceiling of resources (only for PCP resource
      --
      compute_ceiling_of_resources
        (my_scheduler,
         si,
         processor_name,
         address_space_name,
         my_tasks,
         my_resources);

   end specific_scheduler_initialization;

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
      no_task            : in out Boolean)

   is

      ready, found      : Boolean;
      selected_priority : priority_range;
      index             : tasks_range := 0;
      current           : hpf_tcb_ptr;
      elected_task      : hpf_tcb_ptr := null;
      max_cpu_usage     : Natural     := Natural'last;

   begin

      -- For each task, call "check_resources" to
      -- take care of priority modification (PCP and PIP)
      --
      for i in 0 .. si.number_of_tasks - 1 loop

         if (si.tcbs (i).tsk.cpu_name = processor_name) and
           ((address_space_name = To_Unbounded_String ("")) or
            (address_space_name = si.tcbs (i).tsk.address_space_name))
         then
            if
              ((si.tcbs (i).tsk.core_name = To_Unbounded_String ("")) or
               (si.tcbs (i).tsk.core_name = core_name))
            then
               if (si.tcbs (i).wake_up_time <= current_time) and
                 (si.tcbs (i).rest_of_capacity /= 0)
               then
                  check_jitter
                    (si.tcbs (i),
                     current_time,
                     si.tcbs (i).is_jitter_ready);
                  if (options.with_jitters = False) or
                    (si.tcbs (i).is_jitter_ready)
                  then
                     if (options.with_offsets = False) or
                       check_offset (si.tcbs (i), current_time)
                     then
                        if (options.with_precedencies = False) or
                          check_precedencies (si, current_time, si.tcbs (i))
                        then
                           if options.with_resources then
                              check_resource
                                (my_scheduler,
                                 si,
                                 result,
                                 current_time,
                                 si.tcbs (i),
                                 fixed_priority_tcb_ptr (si.tcbs (i))
                                   .is_resource_ready,
                                 event_to_generate);
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end if;
      end loop;

      -- Scan fifos to find the highest priority level
      -- with a ready task
      -- Warning : WE DO NOT CHANGE TASK POSITION IN THE
      --        FIFOS
      --
      selected_priority := priority_range'last;
      found             := False;
      loop

         if not is_empty (my_scheduler.priority_fifos (selected_priority)) then

            -- Sort the task of the queue according to their wakeup time
            --
            if get_size (my_scheduler.priority_fifos (selected_priority)) >
              1
            then
               sort
                 (my_scheduler.priority_fifos (selected_priority),
                  increasing_wakeup_time'access);
            end if;

            for i in
              1 .. get_size (my_scheduler.priority_fifos (selected_priority))
            loop

               current :=
                 consult (my_scheduler.priority_fifos (selected_priority));

               -- is the task ready ?
               --
               ready := False;

               if
                 ((current.tsk.core_name = To_Unbounded_String ("")) or
                  (current.tsk.core_name = core_name))
               then
                  if not tcb_ptr (current).already_run_at_current_time then
                     if check_core_assignment
                         (my_scheduler,
                          tcb_ptr (current))
                     then
                        if (current.wake_up_time <= current_time) and
                          (current.rest_of_capacity /= 0)
                        then
                           if (options.with_jitters = False) or
                             (tcb_ptr (current).is_jitter_ready)
                           then
                              if (options.with_offsets = False) or
                                check_offset (tcb_ptr (current), current_time)
                              then
                                 if (options.with_precedencies = False) or
                                   check_precedencies
                                     (si,
                                      current_time,
                                      tcb_ptr (current))
                                 then
                                    if (options.with_resources = False) or
                                      fixed_priority_tcb_ptr (current)
                                        .is_resource_ready
                                    then

                     -- one ready task exists : the priority level is selected
                                       --
                                       ready := True;
                                       found := True;
                                       exit;
                                    end if;
                                 end if;
                              end if;
                           end if;
                        end if;
                     end if;
                  end if;
               end if;

               -- The current task is not ready ...
               -- put it the queue of the fifo
               -- and look for the Next element
               -- of the fifo
               --
               if (ready = False) then
                  remove (my_scheduler.priority_fifos (selected_priority));
                  insert
                    (my_scheduler.priority_fifos (selected_priority),
                     current);
               end if;

            end loop;

         end if;

         -- A fifo is already selected ...  we leave
         --
         if found then
            no_task := False;
            exit;
         end if;

         -- No task found = no task to schedule
         --
         if (selected_priority = priority_range'first) then
            no_task := True;
            return;
         end if;

         selected_priority := selected_priority - 1;

      end loop;

      -- Priority level is selected : the task
      -- in the head of the fifo is the elected
      -- task
      --

      -- Task sharing policies
      --
      if (selected_priority = 0) then
         -- Loop and looking for the less consuming
         -- task
         --
         max_cpu_usage := Natural'last;
         for i in
           1 .. get_size (my_scheduler.priority_fifos (selected_priority))
         loop

            current :=
              consult (my_scheduler.priority_fifos (selected_priority));
            remove (my_scheduler.priority_fifos (selected_priority));
            insert (my_scheduler.priority_fifos (selected_priority), current);
            if (current.wake_up_time <= current_time) and
              (current.rest_of_capacity /= 0)
            then
               if (options.with_jitters = False) or
                 (tcb_ptr (current).is_jitter_ready)
               then
                  if (options.with_offsets = False) or
                    check_offset (tcb_ptr (current), current_time)
                  then
                     if (options.with_resources = False) or
                       fixed_priority_tcb_ptr (current).is_resource_ready
                     then

                        if (current.used_cpu <= max_cpu_usage) then
                           max_cpu_usage := current.used_cpu;
                           elected_task  := current;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end loop;

      else

         -- SCHED_FIFO or SCHED_RR task
         --

         elected_task :=
           consult (my_scheduler.priority_fifos (selected_priority));

         -- is the task quantum exausted ?
         -- if so and if SCHED_RR is set
         -- the task have to be moved to
         -- the queue of the fifo
         --

         if (elected_task.tsk.policy = sched_rr) then
            if (my_scheduler.parameters.quantum > 0) then

               elected_task.task_quantum := elected_task.task_quantum - 1;

               if (elected_task.task_quantum = 0) then
                  elected_task.task_quantum := my_scheduler.parameters.quantum;
                  remove (my_scheduler.priority_fifos (selected_priority));
                  insert
                    (my_scheduler.priority_fifos (selected_priority),
                     elected_task);
               end if;
            end if;
         end if;
      end if;

      if (elected_task /= null) then

         index := 0;
         loop
            if (si.tcbs (index).tsk.name = elected_task.tsk.name) then
               elected := index;
               exit;
            end if;

            index := index + 1;
            exit when si.tcbs (index) = null;
         end loop;

      end if;

   end do_election;

   procedure dispatched_change_current_priority
     (my_scheduler : in out hpf_scheduler;
      a_tcb        : in     fixed_priority_tcb_ptr;
      new_priority :        priority_range)
   is

   begin
      remove_any_where
        (my_scheduler.priority_fifos (a_tcb.current_priority),
         hpf_tcb_ptr (a_tcb));

      a_tcb.current_priority := new_priority;

      insert
        (my_scheduler.priority_fifos (a_tcb.current_priority),
         hpf_tcb_ptr (a_tcb));
   end dispatched_change_current_priority;

   function increasing_wakeup_time
     (op1 : in hpf_tcb_ptr;
      op2 : in hpf_tcb_ptr) return Boolean
   is
   begin
      if (op1 = null) or (op2 = null) then
         return True;
      end if;
      return (op1.wake_up_time <= op2.wake_up_time);
   end increasing_wakeup_time;

end scheduler.fixed_priority.hpf;
