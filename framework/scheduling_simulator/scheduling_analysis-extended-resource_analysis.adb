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

with translate;  use translate;
with buffer_set; use buffer_set;
use buffer_set.generic_buffer_set;
with Resources; use Resources;
use Resources.Resource_Accesses;
with natural_util; use natural_util;
with systems;      use systems;

package body Scheduling_Analysis.extended.resource_analysis is

   procedure blocking_time_from_simulation
     (my_task      : in     generic_task_ptr;
      my_resources : in     resources_set;
      sched        : in     scheduling_sequence_ptr;
      max          : in out Natural;
      min          : in out Natural;
      average      : in out Double)
   is

      a_resource   : generic_resource_ptr;
      resource_ite : resources_iterator;

      nb_blocking_time, start_time, blocking_time : Natural;
      use_resource, has_wait                      : Boolean;

   begin

      max              := 0;
      min              := Natural'last;
      average          := 0.0;
      nb_blocking_time := 0;

      if not is_empty (my_resources) then

         reset_iterator (my_resources, resource_ite);
         loop
            current_element (my_resources, a_resource, resource_ite);

-- Compute blocking time fo a given resource
--
            use_resource := False;
            for i in 0 .. a_resource.critical_sections.nb_entries - 1 loop
               if
                 (a_resource.critical_sections.entries (i).item = my_task.name)
               then
                  use_resource := True;
               end if;
            end loop;

            -- The task use this resource ... make the analysis
            --
            has_wait := False;
            if use_resource then
               for t in 0 .. sched.nb_entries - 1 loop

                  -- we store wait_for_resource events
                  --
                  if not has_wait then
                     if
                       (sched.entries (t).data.type_of_event =
                        wait_for_resource)
                     then
                        if
                          (sched.entries (t).data.wait_for_resource_task.name =
                           my_task.name) and
                          (sched.entries (t).data.wait_for_resource.name =
                           a_resource.name)
                        then
                           start_time := sched.entries (t).item;
                           has_wait   := True;
                        end if;
                     end if;
                  end if;

            -- We look for an allocate event and then, we compute blocking time
                  --
                  if
                    (sched.entries (t).data.type_of_event = allocate_resource)
                  then
                     if
                       (sched.entries (t).data.allocate_task.name =
                        my_task.name) and
                       (sched.entries (t).data.allocate_resource.name =
                        a_resource.name)
                     then
                        if has_wait then
                        -- compute maximum, minimum and average blocking time
                           --
                           blocking_time :=
                             sched.entries (t).item - start_time;
                           max := Natural'max (max, blocking_time);
                           min := Natural'min (min, blocking_time);
                           average := average + Double (blocking_time);
                           nb_blocking_time := nb_blocking_time + 1;
                           has_wait         := False;
                        end if;
                     end if;
                  end if;
               end loop;
            end if;

            exit when is_last_element (my_resources, resource_ite);

            next_element (my_resources, resource_ite);
         end loop;
      end if;

      if min = Natural'last then
         min := 0;
      end if;
      if nb_blocking_time /= 0 then
         average := average / Double (nb_blocking_time);
      end if;

   end blocking_time_from_simulation;

-- Data for deadlock analysis
--
   deadlock_result : deadlock_list;

   function deadlock_from_simulation
     (my_tasks       : in tasks_set;
      my_resources   : in resources_set;
      processor_name : in Unbounded_String;
      sched          : in scheduling_sequence_ptr) return deadlock_list
   is

      -- Variables required to scan the task
      --
      item        : deadlock_item_ptr;
      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

      -- Store the event of the resource allocation
      --
      allocation : time_unit_event_ptr;
      at_time    : Integer := 0;
      is_waiting : Boolean;

      -- Index on the scheduling table
      --
      current_time : time_unit_range := 0;

      procedure perform_analysis_of_one_task is

      begin

         current_time := 0;
         is_waiting   := False;

         -- First, find an Allocation Event
         --
         loop
            if (current_time >= sched.nb_entries - 1) then
               if (is_waiting) then
                  item               := new deadlock_item;
                  item.time          := Natural (at_time);
                  item.task_name     := allocation.wait_for_resource_task.name;
                  item.resource_name := allocation.wait_for_resource.name;
                  add (deadlock_result, item);
               end if;
               return;
            end if;

            if
              (sched.entries (current_time).data.type_of_event =
               wait_for_resource)
            then
               if
                 (sched.entries (current_time).data.wait_for_resource_task
                    .name =
                  a_task.name)
               then
                  if (is_waiting = False) then
                     allocation := sched.entries (current_time).data;
                     is_waiting := True;
                     at_time    := sched.entries (current_time).item;
                  end if;
               end if;
            end if;

            if
              (sched.entries (current_time).data.type_of_event = running_task)
            then
               if
                 (sched.entries (current_time).data.running_task.name =
                  a_task.name)
               then
                  is_waiting := False;
               end if;
            end if;

            current_time := current_time + 1;
         end loop;

      end perform_analysis_of_one_task;

   begin

      reset_iterator (my_tasks, my_iterator);

      initialize (deadlock_result);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if (processor_name = a_task.cpu_name) then
            perform_analysis_of_one_task;
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);
      end loop;

      return deadlock_result;

   end deadlock_from_simulation;

-- Data for priority inversion
--
   inv_prio_result          : priority_inversion_list;
   inv_prio_wait_events     : array (time_unit_range) of time_unit_event_ptr;
   inv_prio_wait_event_time : array (time_unit_range) of Natural;

   function priority_inversion_from_simulation
     (my_tasks       : in tasks_set;
      my_resources   : in resources_set;
      processor_name : in Unbounded_String;
      sched : in scheduling_sequence_ptr) return priority_inversion_list
   is

      -- Variables required to scan the resource set
      --
      item        : priority_inversion_item_ptr;
      a_resource  : generic_resource_ptr;
      my_iterator : resources_iterator;

      -- Store the event of the resource allocation
      --
      allocation : time_unit_event_ptr;

      -- Index on  Wait_Events and Indexes  tables
      --
      index : time_unit_range := 0;

      -- Index on the scheduling table
      --
      current_time : time_unit_range := 0;

      procedure perform_analysis_of_one_resource is

      begin

         current_time := 0;

         -- First, find an Allocation Event
         --
         loop
            if (current_time >= sched.nb_entries - 1) then
               return;
            end if;

            if
              (sched.entries (current_time).data.type_of_event =
               allocate_resource)
            then
               if
                 (sched.entries (current_time).data.allocate_resource.name =
                  a_resource.name)
               then
                  allocation := sched.entries (current_time).data;
                  exit;
               end if;
            end if;

            current_time := current_time + 1;
         end loop;

         loop

            current_time := current_time + 1;

            -- Search all Wait_For_Resource events upto the next allocation
            --
            if (current_time >= sched.nb_entries - 1) then
               return;
            end if;

            if
              (sched.entries (current_time).data.type_of_event =
               allocate_resource)
            then
               if
                 (sched.entries (current_time).data.allocate_resource.name =
                  a_resource.name)
               then

                  -- The next Allocate event is found, stop collecting data
                  -- and do analysis
                  --

                  -- Check that between the two "Allocate" events when
                  -- the priority of the first allocating task
                  -- is less than
                  -- second one.
                  --
                  if
                    (allocation.allocate_task.priority <
                     sched.entries (current_time).data.allocate_task.priority)
                  then

                     declare

                        -- Start time of the priority inversion
                        --
                        start_time : Natural :=
                          sched.entries (current_time).item;

                     begin
                        -- look for the start time of the priority inversion
                        --
                        for z in reverse 0 .. index - 1 loop
                           if inv_prio_wait_events (z).wait_for_resource_task
                               .name =
                             sched.entries (current_time).data.allocate_task
                               .name
                           then
                              start_time := inv_prio_wait_event_time (z);
                           end if;
                        end loop;

                        -- Store the detected priority inversion
                        --
                        if start_time < sched.entries (current_time).item then
                           item := new priority_inversion_item;

                           item.start_time := start_time;
                           item.end_time := sched.entries (current_time).item;
                           item.task_name  :=
                             sched.entries (current_time).data.allocate_task
                               .name;
                           item.resource_name :=
                             sched.entries (current_time).data
                               .allocate_resource
                               .name;

                           add (inv_prio_result, item);
                        end if;
                     end;

                  end if;

                  -- Ready for the next priority inversion analysis
                  --
                  index      := 0;
                  allocation := sched.entries (current_time).data;

               end if;
            end if;

            if
              (sched.entries (current_time).data.type_of_event =
               wait_for_resource)
            then
               if
                 (sched.entries (current_time).data.wait_for_resource.name =
                  a_resource.name)
               then

                  inv_prio_wait_events (index) :=
                    sched.entries (current_time).data;
                  inv_prio_wait_event_time (index) :=
                    sched.entries (current_time).item;
                  index := index + 1;
               end if;
            end if;
         end loop;

      end perform_analysis_of_one_resource;

   begin

      reset_iterator (my_resources, my_iterator);

      initialize (inv_prio_result);

      loop
         current_element (my_resources, a_resource, my_iterator);

         if (processor_name = a_resource.cpu_name) then
            perform_analysis_of_one_resource;
         end if;

         exit when is_last_element (my_resources, my_iterator);

         next_element (my_resources, my_iterator);
      end loop;

      return inv_prio_result;

   end priority_inversion_from_simulation;

end Scheduling_Analysis.extended.resource_analysis;
