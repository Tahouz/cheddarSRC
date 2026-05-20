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

with xml_tag;             use xml_tag;
with double_util;         use double_util;
with translate;           use translate;
with unbounded_strings;   use unbounded_strings;
with systems;             use systems;
with Ada.Tags;            use Ada.Tags;
with Text_IO;             use Text_IO;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with systems; use systems;

package body scheduler.multiprocessor_specific.edzl is

   function build_tcb
     (my_scheduler : in multiprocessor_edzl_scheduler;
      a_task       :    generic_task_ptr) return tcb_ptr
   is
      a_tcb : edzl_tcb_ptr;
   begin
      a_tcb := new edzl_tcb;
      initialize (tcb (a_tcb.all), a_task);
      initialize (a_tcb.all);
      return tcb_ptr (a_tcb);
   end build_tcb;

   procedure initialize (a_tcb : in out edzl_tcb) is
   begin
      a_tcb.dynamic_deadline := a_tcb.tsk.deadline + a_tcb.wake_up_time;
   end initialize;

   procedure check_before_scheduling
     (my_scheduler   : in multiprocessor_edzl_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is
   begin
      null;
   end check_before_scheduling;

   procedure specific_scheduler_initialization
     (my_scheduler       : in out multiprocessor_edzl_scheduler;
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

   procedure initialize (a_scheduler : in out multiprocessor_edzl_scheduler) is
   begin
      reset (a_scheduler);
      a_scheduler.parameters.scheduler_type :=
        earliest_deadline_first_protocol;
   end initialize;

   function copy
     (a_scheduler : in multiprocessor_edzl_scheduler)
      return generic_scheduler_ptr
   is
      ptr : multiprocessor_edzl_scheduler_ptr;

   begin

      ptr := new multiprocessor_edzl_scheduler;

      ptr.parameters         := a_scheduler.parameters;
      ptr.previously_elected := a_scheduler.previously_elected;

      return generic_scheduler_ptr (ptr);

   end copy;

   procedure do_election
     (my_scheduler       : in out multiprocessor_edzl_scheduler;
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

      smallest_deadline        : Natural     := Natural'last;
      i                        : tasks_range := 0;
      is_ready                 : Boolean     := False;
      previous_task_can_be_run : Boolean     := False;
      laxity                   : Double;
      has_zero_laxity          : Boolean     := False;

   begin

      no_task := True;

      loop

         if (si.tcbs (i).tsk.cpu_name = processor_name) then

            laxity :=
              Double
                (edzl_tcb_ptr (si.tcbs (i)).tsk.deadline -
                 current_time -
                 si.tcbs (i).rest_of_capacity);

            edzl_tcb_ptr (si.tcbs (i)).dynamic_deadline :=
              si.tcbs (i).wake_up_time + si.tcbs (i).tsk.deadline;
         end if;

         if not si.tcbs (i).already_run_at_current_time then
            if (si.tcbs (i).tsk.cpu_name = processor_name) then
               if check_core_assignment (my_scheduler, si.tcbs (i)) then
                  if (si.tcbs (i).wake_up_time <= current_time) and
                    (si.tcbs (i).rest_of_capacity /= 0)
                  then
                     if options.with_resources then
                        check_resource
                          (my_scheduler,
                           si,
                           result,
                           current_time,
                           si.tcbs (i),
                           is_ready,
                           event_to_generate);
                        if is_ready then
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
                                   check_precedencies
                                     (si,
                                      current_time,
                                      si.tcbs (i))
                                 then

                                    if i = my_scheduler.previously_elected then
                                       previous_task_can_be_run := True;
                                    end if;
                                    if laxity <= 0.0 then
                                       has_zero_laxity := True;
                                       elected         := i;
                                       no_task         := False;
                                    end if;

                                    if (not has_zero_laxity) and
                                      (edzl_tcb_ptr (si.tcbs (i))
                                         .dynamic_deadline <
                                       smallest_deadline)
                                    then
                                       smallest_deadline :=
                                         edzl_tcb_ptr (si.tcbs (i))
                                           .dynamic_deadline;
                                       elected := i;
                                       no_task := False;
                                    end if;
                                 end if;
                              end if;
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end if;

         i := i + 1;
         exit when si.tcbs (i) = null;
      end loop;

      -- By default, as task are sorted in the set according to their name
      -- when we have two tasks with the same absolute deadline, we choose the first one
      -- in the task set, i.e. the task with the smallest name.
      -- This strategy can be useful has it provides a simple mean to introduce a
      -- tie break as a kind of fixed priority.
      -- However, it may introduce an extra preemption.
      -- If we want to reduce preemption number as much as possible, in this case
      -- we select the previous task ... in this task can be run again !
      --
      if options.with_minimize_preemption and previous_task_can_be_run then
         if edzl_tcb_ptr (si.tcbs (my_scheduler.previously_elected))
             .dynamic_deadline =
           smallest_deadline
         then
            elected := my_scheduler.previously_elected;
         end if;
      end if;

   end do_election;

end scheduler.multiprocessor_specific.edzl;
