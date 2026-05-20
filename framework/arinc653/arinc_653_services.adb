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

with Ada.Exceptions;   use Ada.Exceptions;

with Framework_Config;    use Framework_Config;
with Doubles;             use Doubles;
with translate;           use translate;
with Tasks;               use Tasks;
with task_set;            use task_set;
use task_set.generic_task_set;
with Address_Spaces;      use Address_Spaces;
with address_space_set;   use address_space_set;
use address_space_set.generic_address_space_set;
with Scheduler_Interface; use Scheduler_Interface;
with time_unit_events;    use time_unit_events;
use time_unit_events.time_unit_package;
with ARINC_653_Schema;    use ARINC_653_Schema;
use ARINC_653_Schema.PartitionType_List_Package;
use ARINC_653_Schema.ProcessType_List_Package;
use ARINC_653_Schema.Partition_Schedule_Element_List_Package;
use ARINC_653_Schema.Window_Schedule_Element_List_Package;
with framework;           use framework;
with Scheduling_Analysis; use Scheduling_Analysis;

package body arinc_653_services is

   procedure check_arinc_653 (sys : in system) is

      ad_iterator       : address_spaces_iterator;
      ta_iterator       : tasks_iterator;
      current_scheduler : schedulers_type;
      a_address_space   : address_space_ptr;

   begin

      if (get_number_of_elements (sys.address_spaces) > 0) then
         reset_iterator (sys.address_spaces, ad_iterator);
         current_element (sys.address_spaces, a_address_space, ad_iterator);
         current_scheduler := a_address_space.scheduling.scheduler_type;
         if (current_scheduler /= hierarchical_cyclic_protocol) and
           (current_scheduler /= hierarchical_round_robin_protocol)
         then
            Raise_Exception
              (invalid_scheduler'identity,
               To_String (lb_invalid_scheduler (Current_Language)));
         end if;

         reset_iterator (sys.address_spaces, ad_iterator);
         loop
            current_element (sys.address_spaces, a_address_space, ad_iterator);

            if
              (current_scheduler /= a_address_space.scheduling.scheduler_type)
            then
               Raise_Exception
                 (invalid_scheduler'identity,
                  To_String
                    (lb_require_same_scheduler_on_all_address_space
                       (Current_Language)));
            end if;

            exit when is_last_element (sys.address_spaces, ad_iterator);
            next_element (sys.address_spaces, ad_iterator);
         end loop;
      end if;

   end check_arinc_653;

   function build_arinc653_module
     (sched          : in scheduling_table_ptr;
      sys            : in system;
      majortimeframe : in Natural) return arinc_653_module_ptr
   is

      a_sched : scheduling_sequence_ptr;

      a_mod                        : arinc_653_module_ptr;
      a_partition                  : partitiontype_ptr;
      a_process                    : processtype_ptr;
      a_partition_schedule_element : partition_schedule_element_ptr;
      a_window_schedule_element    : window_schedule_element_ptr;

      ad_iterator  : address_spaces_iterator;
      ta_iterator  : tasks_iterator;
      par_iterator : partition_schedule_element_iterator;

      a_task          : generic_task_ptr;
      a_address_space : address_space_ptr;

   begin

-- Create the module
--
      a_mod            := new arinc_653_module;
      a_mod.ModuleName := To_Unbounded_String ("cheddar");

-- Add processes and partitions
--
      if (get_number_of_elements (sys.address_spaces) > 0) then
         reset_iterator (sys.address_spaces, ad_iterator);
         loop
            current_element (sys.address_spaces, a_address_space, ad_iterator);

            a_partition               := new partitiontype;
            a_partition.PartitionName := a_address_space.name;
            add (a_mod.Partition, a_partition);

            if (get_number_of_elements (sys.tasks) > 0) then

               reset_iterator (sys.tasks, ta_iterator);

               loop
                  current_element (sys.tasks, a_task, ta_iterator);

                  a_process      := new processtype;
                  a_process.Name := a_task.name;
                  add (a_partition.Process, a_process);

                  exit when is_last_element (sys.tasks, ta_iterator);
                  next_element (sys.tasks, ta_iterator);
               end loop;
            end if;

            exit when is_last_element (sys.address_spaces, ad_iterator);
            next_element (sys.address_spaces, ad_iterator);
         end loop;
      end if;

-- Export partition scheduling
--
      a_mod.Module_Schedule                   := new module_schedule_type;
      a_mod.Module_Schedule.MajorFrameSeconds := Double (majortimeframe);

-- Create a Partition_Schedule_Element for each partition
--
      if (get_number_of_elements (sys.address_spaces) > 0) then
         reset_iterator (sys.address_spaces, ad_iterator);
         loop
            current_element (sys.address_spaces, a_address_space, ad_iterator);

            a_partition_schedule_element := new partition_schedule_element;
            a_partition_schedule_element.PartitionName := a_address_space.name;
            a_partition_schedule_element.PeriodSeconds :=
              Double (a_address_space.scheduling.period);
            a_partition_schedule_element.PeriodDurationSeconds :=
              Double (a_address_space.scheduling.capacity);
            add
              (a_mod.Module_Schedule.Partition_Schedule,
               a_partition_schedule_element);

            exit when is_last_element (sys.address_spaces, ad_iterator);
            next_element (sys.address_spaces, ad_iterator);
         end loop;

      end if;

-- Fill each Partition_Schedule_Element with schedule table computed
-- by cheddar
--

      for k in 0 .. sched.nb_entries - 1 loop
         a_sched := sched.entries (k).data.result;
         for i in 0 .. a_sched.nb_entries - 1 loop
            if
              (a_sched.entries (i).data.type_of_event =
               address_space_activation)
            then

               -- Look for the corresponding partition
               --
               reset_head_iterator
                 (a_mod.Module_Schedule.Partition_Schedule,
                  par_iterator);
               loop
                  current_element
                    (a_mod.Module_Schedule.Partition_Schedule,
                     a_partition_schedule_element,
                     par_iterator);

-- Store the event in the PST table
--
                  if
                    (a_partition_schedule_element.PartitionName =
                     a_sched.entries (i).data.activation_address_space)
                  then
                     a_window_schedule_element := new window_schedule_element;
                     a_window_schedule_element.WindowStartSeconds :=
                       Double (a_sched.entries (i).item);
                     a_window_schedule_element.WindowDurationSeconds :=
                       Double (a_sched.entries (i).data.duration);
                     a_window_schedule_element.PartitionPeriodStart := False;
                     if
                       (Natural (a_partition_schedule_element.PeriodSeconds) /=
                        0)
                     then
                        if
                          (a_sched.entries (i).item mod
                           Natural
                             (a_partition_schedule_element.PeriodSeconds) =
                           0)
                        then
                           a_window_schedule_element.PartitionPeriodStart :=
                             True;
                        end if;
                     end if;
                     add
                       (a_partition_schedule_element.Window_Schedule,
                        a_window_schedule_element);
                  end if;

                  exit when is_tail_element
                      (a_mod.Module_Schedule.Partition_Schedule,
                       par_iterator);
                  next_element
                    (a_mod.Module_Schedule.Partition_Schedule,
                     par_iterator);
               end loop;

            end if;
         end loop;
      end loop;

      return a_mod;

   end build_arinc653_module;

end arinc_653_services;
