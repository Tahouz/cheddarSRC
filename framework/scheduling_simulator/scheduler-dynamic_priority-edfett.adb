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
--    $Date: 2023-09-29 16:02:19 +0200 (ven. 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Tags; use Ada.Tags;
with Text_IO;  use Text_IO;
with Ada.Exceptions; use Ada.Exceptions;

with xml_tag;           use xml_tag;
with debug;             use debug;
with double_util;       use double_util;
with translate;         use translate;
with unbounded_strings; use unbounded_strings;
with random_tools;      use random_tools;

with systems; use systems;

with sets;

package body scheduler.dynamic_priority.edfett is

   procedure initialize (a_scheduler : in out edfett_scheduler) is
   begin
      reset (a_scheduler);
      a_scheduler.parameters.scheduler_type :=
        earliest_deadline_first_energy_to_time_protocol;
   end initialize;

   function copy
     (a_scheduler : in edfett_scheduler) return generic_scheduler_ptr
   is
      ptr : edfett_scheduler_ptr;

   begin

      ptr := new edfett_scheduler;

      ptr.parameters         := a_scheduler.parameters;
      ptr.previously_elected := a_scheduler.previously_elected;
      ptr.current_energy     := a_scheduler.current_energy;
      ptr.current_battery    := a_scheduler.current_battery;

      return generic_scheduler_ptr (ptr);

   end copy;

   procedure specific_scheduler_initialization
     (my_scheduler       : in out edfett_scheduler;
      si : in out scheduling_information; processor_name : in Unbounded_String;
      address_space_name : in Unbounded_String; my_tasks : in out tasks_set;
      my_schedulers : in scheduler_table; my_resources : in out resources_set;
      my_buffers         : in out buffers_set; my_messages : in messages_set;
      msg                : in out Unbounded_String)
   is

      battery_iterator : batteries_iterator;
      the_battery      : battery_ptr;

   begin
      -- Compute the energy available for the scheduling: only one battery is available
      --
      if (not is_empty (si.batteries)) then

         reset_iterator (si.batteries, battery_iterator);
         loop
            current_element (si.batteries, the_battery, battery_iterator);

            if (the_battery.cpu_name = processor_name) then
               my_scheduler.current_energy  := the_battery.initial_energy;
               my_scheduler.current_battery := the_battery;
               return;
            end if;

            exit when is_last_element (si.batteries, battery_iterator);

            next_element (si.batteries, battery_iterator);
         end loop;

       else
            Raise_Exception
                 (invalid_scheduler_parameter'identity,
                  "Define a battery for each processor");
      end if;

   end specific_scheduler_initialization;

   procedure do_election
     (my_scheduler       : in out edfett_scheduler;
      si                 : in out scheduling_information;
      result             : in out scheduling_sequence_ptr; 
      msg                : in out Unbounded_String;
      current_time       : in Natural; 
      processor_name     : in Unbounded_String;
      address_space_name : in Unbounded_String;
      core_name          : in Unbounded_String; 
      options            : in scheduling_option;
      event_to_generate  : in time_unit_event_type_boolean_table;
      elected            : in out tasks_range; 
      no_task : in out Boolean)

   is

      smallest_deadline        : Natural     := Natural'Last;
      i                        : tasks_range := 0;
      is_ready                 : Boolean     := False;
      previous_task_can_be_run : Boolean     := False;
      an_event                 : time_unit_event_ptr;

      -- Processor
      processor_is_idle  : Boolean := True;
      energy_consumption : Natural := 0;
      seed               : generator;

   begin

      put_debug ("Call Do_Election: EDF ETT" &
           " Current_Energy : " &
            my_scheduler.Current_energy'Img & " at time " & current_time'Img);

      loop

         if (si.tcbs (i).tsk.cpu_name = processor_name) then
            dynamic_priority_tcb_ptr (si.tcbs (i)).dynamic_deadline :=
              si.tcbs (i).wake_up_time + si.tcbs (i).tsk.deadline;

            if not si.tcbs (i).already_run_at_current_time then

               if check_core_assignment (my_scheduler, si.tcbs (i)) then

                  if (si.tcbs (i).wake_up_time <= current_time) and
                    (si.tcbs (i).rest_of_capacity /= 0)
                  then

                     if options.with_resources then
                        check_resource
                          (my_scheduler, si, result, current_time, si.tcbs (i),
                           is_ready, event_to_generate);
                     else
                        is_ready := True;
                     end if;

                     if is_ready then
                        check_jitter
                          (si.tcbs (i), current_time,
                           si.tcbs (i).is_jitter_ready);
                        if (options.with_jitters = False) or
                          (si.tcbs (i).is_jitter_ready)
                        then

                           if (options.with_offsets = False) or
                             check_offset (si.tcbs (i), current_time)
                           then
                              if (options.with_precedencies = False) or
                                check_precedencies
                                  (si, current_time, si.tcbs (i))
                              then

                                 if i = my_scheduler.previously_elected then
                                    previous_task_can_be_run := True;
                                 end if;

                                 -- EDF priority
                                 --
                                 if
                                   (dynamic_priority_tcb_ptr (si.tcbs (i))
                                      .dynamic_deadline <
                                    smallest_deadline)
                                 then
                                    smallest_deadline :=
                                      dynamic_priority_tcb_ptr (si.tcbs (i))
                                        .dynamic_deadline;
                                    elected := i;
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

      if smallest_deadline = Natural'Last then
         processor_is_idle := True;
      else
         processor_is_idle := False;
      end if;

      -- Produce an event on the battery level
      --
      produce_energy_event (my_scheduler, options, si, an_event);
      add (result.all, current_time, an_event);

      -- Compute the current battery level
      --

      my_scheduler.current_energy :=
        my_scheduler.current_energy +
        my_scheduler.current_battery.rechargeable_power;
      if processor_is_idle = True then
         no_task := True;
      else
         -- Random energy consumption between e_min and e_max
         -- Values are compliant with the uniform law
         -- Select seed according to ADL model (i.e. task entity properties)
         --
         if options.with_task_specific_seed then
            Reset (seed, si.tcbs (elected).task_seed);
         else
            Reset (seed, si.global_seed);
         end if;

-- Contrainte pour generer les données correctement
-- (C_i * e_min <= E_i ) et ( E_i <= C_i * e_max )

-- pour calculer l energie consommee a chaque ut
-- utiliser uunifast pour générer une conso d energie entre e_min et e_max et que la 
-- la somme des conso d'énergie fasse E_i en fin de job

-- Verification : que WCRT + temps pour revenir au niveau d'energie au début du job == WCTT   
-- 

         energy_consumption :=
           get_rand_parameter
             (my_scheduler.current_battery.e_min,
              my_scheduler.current_battery.e_max, seed);
         if (my_scheduler.current_energy < energy_consumption) then
            no_task := True;
         else
            no_task                     := False;
            my_scheduler.current_energy :=
              my_scheduler.current_energy - energy_consumption;
         end if;
      end if;

      -- Do not exceed battery capacity
      -- Capacity is needed for drawing maters
      -- Zero value for the capacity means ... unbounded capacity
      --
      if my_scheduler.current_battery.capacity>0 then
         if my_scheduler.current_energy > my_scheduler.current_battery.capacity
            then
               my_scheduler.current_energy := my_scheduler.current_battery.capacity;
         end if;
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
         if dynamic_priority_tcb_ptr
             (si.tcbs (my_scheduler.previously_elected))
             .dynamic_deadline =
           smallest_deadline
         then
            elected := my_scheduler.previously_elected;
            put_debug ("Call Do_Election: EDF ETT : Minimize preemption");
         end if;
      end if;

      put_debug
        ("Call Do_Election: EDF ETT : elected : " & elected'Img &
         " ; no_task : " & no_task'Img & "; processor_is_idle : " &
         processor_is_idle'Img);

   end do_election;

   procedure produce_energy_event
     (my_scheduler : in edfett_scheduler; options : in scheduling_option;
      si : in scheduling_information; an_event : out time_unit_event_ptr)
   is
   begin
      if options.with_energy then
         an_event                := new time_unit_event (energy);
         an_event.energy_battery := my_scheduler.current_battery;
         an_event.energy_level   := my_scheduler.current_energy;
      end if;
   end produce_energy_event;

end scheduler.dynamic_priority.edfett;
