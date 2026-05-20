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
--    $Rev: 3520 $
--    $Date: 2020-07-23 12:44:45 +0200 (Thu, 23 Jul 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with scheduler;           use scheduler;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with scheduler.fixed_priority;     use scheduler.fixed_priority;
with scheduler.fixed_priority.hpf; use scheduler.fixed_priority.hpf;
with Text_IO;                      use Text_IO;
with debug;                        use debug;
with xml_tag;                      use xml_tag;
with double_util;                  use double_util;
with translate;                    use translate;
with unbounded_strings;            use unbounded_strings;
with systems;                      use systems;
with Ada.Tags;                     use Ada.Tags;

package body scheduler.mixed_criticality.edf_vd is

   procedure initialize
     (a_scheduler : in out mixed_criticality_edf_vd_scheduler)
   is
   begin
      reset (a_scheduler);
      a_scheduler.parameters.scheduler_type :=
        mixed_criticality_edf_vd_protocol;
   end initialize;

   function copy
     (a_scheduler : in mixed_criticality_edf_vd_scheduler)
      return generic_scheduler_ptr
   is
      ptr : mixed_criticality_edf_vd_scheduler_ptr;

   begin

      ptr := new mixed_criticality_edf_vd_scheduler;

      ptr.parameters         := a_scheduler.parameters;
      ptr.previously_elected := a_scheduler.previously_elected;

      return generic_scheduler_ptr (ptr);

   end copy;

   procedure check_before_scheduling
     (my_scheduler   : in mixed_criticality_edf_vd_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

   begin
      null;
   end check_before_scheduling;

   procedure specific_scheduler_initialization
     (my_scheduler       : in out mixed_criticality_edf_vd_scheduler;
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

   procedure do_election
     (my_scheduler       : in out mixed_criticality_edf_vd_scheduler;
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
      is_critical              : Boolean     := False;
   begin
      put_debug ("Call Do_Election: EDF_VD");
      loop
         if (si.tcbs (i).tsk.cpu_name = processor_name) then
            mixed_criticality_tcb_ptr (si.tcbs (i)).dynamic_deadline :=
              si.tcbs (i).wake_up_time + si.tcbs (i).tsk.deadline;
         end if;
-- We check if a low WCET of a task exceed its time
         if
           ((si.tcbs (i).tsk.capacities.entries(0).values_eu + si.tcbs (i).wake_up_time) <
            current_time)
         then
            is_critical                 := True;
            si.tcbs (i).tsk.criticality := 2;
         end if;
         if not si.tcbs (i).already_run_at_current_time then
            if (si.tcbs (i).tsk.cpu_name = processor_name) then
-- We check if there is a task in critical mode
               if (is_critical) then
-- We check if the task we are looking is critical
                  if (si.tcbs (i).tsk.criticality = 2) then
                     if (si.tcbs (i).wake_up_time <= current_time) and
                       (si.tcbs (i).rest_of_capacity /= 0)
                     then
-- We calculate the smallest deadline between critical tasks
                        if
                          (mixed_criticality_tcb_ptr (si.tcbs (i))
                             .dynamic_deadline <
                           smallest_deadline)
                        then
-- We elect the task with the smallest deadline
                           smallest_deadline           := 0;
                           elected                     := i;
                           si.tcbs (i).tsk.criticality := 1;
                        end if;
                     end if;
                  end if;
               else
-- Same thing as above but there is no critical task
                  if (si.tcbs (i).wake_up_time <= current_time) and
                    (si.tcbs (i).rest_of_capacity /= 0)
                  then

                     if (options.with_offsets = False) or
                       check_offset (si.tcbs (i), current_time)
                     then

                        if (options.with_precedencies = False) or
                          check_precedencies (si, current_time, si.tcbs (i))
                        then

                           if i = my_scheduler.previously_elected then
                              previous_task_can_be_run := True;
                           end if;

-- We calculate the smallest deadline between critical tasks
                           if
                             (mixed_criticality_tcb_ptr (si.tcbs (i))
                                .dynamic_deadline <
                              smallest_deadline)
                           then
-- We elect the task with the smallest deadline
                              smallest_deadline :=
                                mixed_criticality_tcb_ptr (si.tcbs (i))
                                  .dynamic_deadline;
                              elected                     := i;
                              si.tcbs (i).tsk.criticality := 1;
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end if;

         i := i + 1;
         --is_critical := False;
         exit when si.tcbs (i) = null;
      end loop;

      if smallest_deadline = Natural'last then
         no_task := True;
      else
         no_task := False;
      end if;

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
         if mixed_criticality_tcb_ptr
             (si.tcbs (my_scheduler.previously_elected))
             .dynamic_deadline =
           smallest_deadline
         then
            elected := my_scheduler.previously_elected;
            put_debug ("Call Do_Election: EDF : Minimize preemption");
         end if;
      end if;

      put_debug ("Call Do_Election: EDF : Elected : " & elected'img);
   end do_election;

end scheduler.mixed_criticality.edf_vd;
