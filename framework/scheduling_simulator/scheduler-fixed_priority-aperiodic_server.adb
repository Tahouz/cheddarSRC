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

with xml_tag;                use xml_tag;
with double_util;            use double_util;
with translate;              use translate;
with unbounded_strings;      use unbounded_strings;
with Text_IO;                use Text_IO;
with Ada.Exceptions;         use Ada.Exceptions;
with GNAT.Current_Exception; use GNAT.Current_Exception;

package body scheduler.fixed_priority.aperiodic_server is

   procedure check_before_scheduling
     (my_scheduler   : in aperiodic_server_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

   begin

      if my_scheduler.parameters.period <= 0 then
         Raise_Exception
           (invalid_scheduler_parameter'identity,
            "Invalid period value");
      end if;

      if my_scheduler.parameters.capacity <= 0 then
         Raise_Exception
           (invalid_scheduler_parameter'identity,
            "Invalid capacity value");
      end if;

   end check_before_scheduling;

   procedure do_election
     (my_scheduler       : in out aperiodic_server_scheduler;
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

      i : tasks_range := 0;

   begin

      my_scheduler.periodic_highest_priority  := Natural'first;
      my_scheduler.aperiodic_highest_priority := Natural'first;
      my_scheduler.periodic_elected           := 0;
      my_scheduler.aperiodic_elected          := 0;

      -- For each task, call "check_resources" to
      -- take care of priority modification (PCP and PIP)
      --
      loop

         if not si.tcbs (i).already_run_at_current_time then
            if (si.tcbs (i).tsk.cpu_name = processor_name) and
              ((address_space_name = To_Unbounded_String ("")) or
               (address_space_name = si.tcbs (i).tsk.address_space_name))
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

         i := i + 1;
         exit when si.tcbs (i) = null;
      end loop;

      --  Look for the Highest periodic/sporadic/poisson process ready
      --  priority task
      --
      i := 0;
      loop
         if
           ((si.tcbs (i).tsk.task_type = periodic_type) or
            (si.tcbs (i).tsk.task_type = sporadic_type) or
            (si.tcbs (i).tsk.task_type = poisson_type))
         then
            if (si.tcbs (i).tsk.cpu_name = processor_name) then
               if check_core_assignment (my_scheduler, si.tcbs (i)) then
                  if (si.tcbs (i).wake_up_time <= current_time) and
                    (Natural
                       (fixed_priority_tcb_ptr (si.tcbs (i))
                          .current_priority) >
                     my_scheduler.periodic_highest_priority) and
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
                              if (options.with_resources = False) or
                                fixed_priority_tcb_ptr (si.tcbs (i))
                                  .is_resource_ready
                              then

                                 my_scheduler.periodic_highest_priority :=
                                   Natural
                                     (fixed_priority_tcb_ptr (si.tcbs (i))
                                        .current_priority);
                                 my_scheduler.periodic_elected := i;
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

      -- Check if some aperiodic task exists and select the Highest priority
      -- aperiodic task
      --
      i := 0;
      loop
         if not si.tcbs (i).already_run_at_current_time then
            if (si.tcbs (i).tsk.task_type = aperiodic_type) then
               if (si.tcbs (i).tsk.cpu_name = processor_name) then
                  if check_core_assignment (my_scheduler, si.tcbs (i)) then
                     if (si.tcbs (i).wake_up_time <= current_time) and
                       (Natural
                          (fixed_priority_tcb_ptr (si.tcbs (i))
                             .current_priority) >
                        my_scheduler.aperiodic_highest_priority) and
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
                                check_precedencies
                                  (si,
                                   current_time,
                                   si.tcbs (i))
                              then
                                 if (options.with_resources = False) or
                                   fixed_priority_tcb_ptr (si.tcbs (i))
                                     .is_resource_ready
                                 then

                                    my_scheduler.aperiodic_highest_priority :=
                                      Natural
                                        (fixed_priority_tcb_ptr (si.tcbs (i))
                                           .current_priority);
                                    my_scheduler.aperiodic_elected := i;
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

   end do_election;

   procedure specific_scheduler_initialization
     (my_scheduler       : in out aperiodic_server_scheduler;
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
      specific_scheduler_initialization
        (fixed_priority_scheduler (my_scheduler),
         si,
         processor_name,
         address_space_name,
         my_tasks,
         my_schedulers,
         my_resources,
         my_buffers,
         my_messages,
         msg);

      my_scheduler.current_server_wake_time :=
        my_scheduler.parameters.start_time;
      my_scheduler.current_server_capacity := my_scheduler.parameters.capacity;

   end specific_scheduler_initialization;

end scheduler.fixed_priority.aperiodic_server;
