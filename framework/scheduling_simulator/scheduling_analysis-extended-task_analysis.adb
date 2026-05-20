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
with Resources;    use Resources;
with resource_set; use resource_set;
use resource_set.generic_resource_set;
with natural_util;   use natural_util;
with Tasks.extended; use Tasks.extended;
with task_set;       use task_set;
use task_set.generic_task_set;
with time_unit_events; use time_unit_events;
use time_unit_events.time_unit_lists_package;
use time_unit_events.time_unit_package;
with event_analyzer_set; use event_analyzer_set;
use event_analyzer_set.generic_event_analyzer_set;
with natural_util; use natural_util;
with tables;
with indexed_tables;
with Unchecked_Deallocation;
with translate;    use translate;
with natural_util; use natural_util;

package body Scheduling_Analysis.extended.task_analysis is

   procedure consumer_response_time
     (sched              : in     scheduling_sequence_ptr;
      consumer_resp_time : in out resp_time_consumer_table_ptr;
      my_consumer_task   : in     generic_task_ptr)
   is

      my_consumer_task_occurence_table : task_occurence_table_ptr;
      index                            : resp_time_consumer_range := 0;

   begin

      -- initialize and compute all response times
      --
      my_consumer_task_occurence_table := new task_occurence_table;
      all_response_times_by_simulation
        (my_consumer_task,
         sched,
         my_consumer_task_occurence_table);

      -- affect response time value
      --
      for i_occurence in task_occurence_range loop
         if
           (my_consumer_task_occurence_table.entries (i_occurence)
              .response_time /=
            0)
         then

            consumer_resp_time.entries (index).data :=
              Double
                (my_consumer_task_occurence_table.entries (i_occurence)
                   .response_time);
            index := index + 1;

         end if;
      end loop;
      consumer_resp_time.nb_entries := index;

      free (my_consumer_task_occurence_table);
   end consumer_response_time;

   procedure cyclic_response_time_by_simulation
     (my_task : in     generic_task_ptr;
      sched   : in     scheduling_sequence_ptr;
      msg     : in out Unbounded_String;
      max     : in out Natural;
      min     : in out Natural;
      average : in out Double)
   is

      current_date            : Natural := 0;
      my_task_occurence_table : task_occurence_table_ptr;
      task_occurence_number   : task_occurence_range;

   begin

      -- Initialize all occurences
      -- dates are taken from scheduling table
      --
      my_task_occurence_table := new task_occurence_table;
      min                     := Natural'last;
      max                     := Natural'first;
      average                 := 0.0;
      msg                     := empty_string;

      -- Initialize activation time of the task
      --
      task_occurence_number := 0;

      for j in 0 .. sched.nb_entries - 1 loop

         if sched.entries (j).data.type_of_event = task_activation then
            if sched.entries (j).data.activation_task.name = my_task.name then
               initialize
                 (my_task_occurence_table.entries (task_occurence_number),
                  my_task,
                  sched.entries (j).item);
               task_occurence_number := task_occurence_number + 1;
            end if;
         end if;
      end loop;

      -- Find completion time of task
      -- compute response time
      --
      task_occurence_number := 0;
      for t in 0 .. sched.nb_entries - 1 loop

         -- the current date
         --
         current_date := sched.entries (t).item;

         if sched.entries (t).data.type_of_event = end_of_task_capacity then

            if sched.entries (t).data.end_task.name = my_task.name then
               my_task_occurence_table.entries (task_occurence_number)
                 .completion_time :=
                 current_date;
               my_task_occurence_table.entries (task_occurence_number)
                 .response_time :=
                 current_date -
                 my_task_occurence_table.entries (task_occurence_number)
                   .arrival_time;

               -- Check deadline missed and update its message
               --
               if
                 (my_task_occurence_table.entries (task_occurence_number)
                    .response_time >
                  my_task.deadline)
               then
                  msg :=
                    msg &
                    lb_comma &
                    lb_check_absolute_deadline (Current_Language) &
                    my_task_occurence_table.entries (task_occurence_number)
                      .absolute_deadline'
                      img &
                    lb_completion_time (Current_Language) &
                    my_task_occurence_table.entries (task_occurence_number)
                      .completion_time'
                      img &
                    To_Unbounded_String (")");
               end if;

               task_occurence_number := task_occurence_number + 1;
               -- JLE correction for ticket 146 http://beru.univ-brest.fr/WIKI-CHEDDAR/ticket/146
               my_task_occurence_table.nb_entries :=
                 my_task_occurence_table.nb_entries + 1;

            end if;
         end if;
      end loop;

      -- Compute min/max/average
      --
      for t in 0 .. my_task_occurence_table.nb_entries - 1 loop
         if (my_task_occurence_table.entries (t).response_time < min) then
            min := my_task_occurence_table.entries (t).response_time;
         end if;
         if (my_task_occurence_table.entries (t).response_time > max) then
            max := my_task_occurence_table.entries (t).response_time;
         end if;
         average :=
           average +
           Double (my_task_occurence_table.entries (t).response_time);
      end loop;

      if my_task_occurence_table.nb_entries > 0 then
         average := average / Double (my_task_occurence_table.nb_entries);
      end if;
      if min = Natural'last then
         min := 0;
      end if;

      free (my_task_occurence_table);

   end cyclic_response_time_by_simulation;

   procedure acyclic_response_time_by_simulation
     (my_task : in     aperiodic_task_ptr;
      sched   : in     scheduling_sequence_ptr;
      msg     : in out Unbounded_String;
      max     : in out Natural;
      min     : in out Natural;
      average : in out Double)
   is

      my_task_occurence : task_occurence;
      effective_end     : Natural := 0;
      current_date      : Natural := 0;

   begin

      initialize (my_task_occurence, generic_task_ptr (my_task));
      msg := To_Unbounded_String ("");

      for t in 0 .. sched.nb_entries - 1 loop
         -- the current date
         --
         current_date := sched.entries (t).item;

         -- Look for task completion and task starting time
         --
         case sched.entries (t).data.type_of_event is
            when task_activation =>
               if sched.entries (t).data.activation_task.name =
                 my_task.name
               then
                  my_task_occurence.arrival_time      := current_date;
                  my_task_occurence.absolute_deadline :=
                    sched.entries (t).data.activation_task.start_time +
                    sched.entries (t).data.activation_task.deadline;
               end if;
            when end_of_task_capacity =>
               if sched.entries (t).data.end_task.name = my_task.name then
                  effective_end := current_date;
                  if (effective_end > my_task_occurence.absolute_deadline) then
                     msg :=
                       msg &
                       lb_comma &
                       lb_check_absolute_deadline (Current_Language) &
                       my_task_occurence.absolute_deadline'img &
                       lb_completion_time (Current_Language) &
                       effective_end'img &
                       To_Unbounded_String (")");
                  end if;
               end if;
            when others =>
               null;
         end case;
      end loop;
      if effective_end > 0 then
         average := Double (effective_end - my_task_occurence.arrival_time);
         min     := effective_end - my_task_occurence.arrival_time;
         max     := min;
      else
         average := 0.0;
         min     := 0;
         max     := 0;
      end if;

   end acyclic_response_time_by_simulation;

   procedure response_time_by_simulation
     (my_task :        generic_task_ptr;
      sched   : in     scheduling_sequence_ptr;
      msg     : in out Unbounded_String;
      max     : in out Natural;
      min     : in out Natural;
      average : in out Double)
   is

   begin

      case my_task.task_type is
         when aperiodic_type =>
            acyclic_response_time_by_simulation
              (aperiodic_task_ptr (my_task),
               sched,
               msg,
               max,
               min,
               average);
         when others =>
            cyclic_response_time_by_simulation
              (my_task,
               sched,
               msg,
               max,
               min,
               average);
      end case;
   end response_time_by_simulation;

   function number_of_preemption_from_simulation
     (sched    : in scheduling_sequence_ptr;
      my_tasks : in tasks_set) return Natural
   is
      nb         : Natural := 0;
      a_task     : generic_task_ptr;
      usage_time : Natural;

   begin

      for i in 0 .. sched.nb_entries - 1 loop
         if (sched.entries (i).data.type_of_event = running_task) then

            for k in reverse 0 .. i - 1 loop
               if (sched.entries (k).data.type_of_event = running_task) then
                  if
                    ((sched.entries (k).data.running_task.name /=
                      sched.entries (i).data.running_task.name) and
                     (sched.entries (k).item + 1 = sched.entries (i).item))
                  then

                     -- We know that the previous unit of time, another
                     -- task was running. Check now that is was a preeemption
                     --

                     -- look for the previously elected task and its state
                     --
                     a_task :=
                       search_task
                         (my_tasks,
                          sched.entries (i).data.running_task.name);

                     -- Compute the running time of the task until its wake up
                     -- time
                     --
                     usage_time := 0;
                     for z in reverse 0 .. k - 1 loop
                        if
                          (sched.entries (z).data.type_of_event = running_task)
                        then
                           if a_task.name =
                             sched.entries (z).data.running_task.name
                           then
                              usage_time := usage_time + 1;
                           end if;
                        end if;
                        if
                          (sched.entries (z).data.type_of_event =
                           task_activation)
                        then
                           if a_task.name =
                             sched.entries (z).data.activation_task.name
                           then
                              if (usage_time /= a_task.capacity) and
                                (usage_time /= 0)
                              then
                                 nb := nb + 1;
                              end if;
                              exit;
                           end if;
                        end if;
                     end loop;
                     exit;
                  end if;
               end if;
            end loop;

         end if;
      end loop;

      return nb;

   end number_of_preemption_from_simulation;

   function number_of_switch_context_from_simulation
     (sched : in scheduling_sequence_ptr) return Natural
   is
      nb : Natural := 0;

   begin

      for i in 0 .. sched.nb_entries - 1 loop
         if (sched.entries (i).data.type_of_event = running_task) then

            for k in reverse 0 .. i - 1 loop
               if (sched.entries (k).data.type_of_event = running_task) then

                  if
                    (sched.entries (k).data.running_task.name /=
                     sched.entries (i).data.running_task.name)
                  then
                     nb := nb + 1;
                  end if;

                  exit;
               end if;
            end loop;
         end if;
      end loop;

      return nb;
   end number_of_switch_context_from_simulation;

   function number_of_overflow_from_simulation
     (sched : in scheduling_sequence_ptr) return Natural
   is
      nb : Natural := 0;

   begin

      for i in 0 .. sched.nb_entries - 1 loop
         if (sched.entries (i).data.type_of_event = buffer_overflow) then
            nb := nb + 1;
         end if;
      end loop;

      return nb;
   end number_of_overflow_from_simulation;

   function number_of_underflow_from_simulation
     (sched : in scheduling_sequence_ptr) return Natural
   is
      nb : Natural := 0;

   begin

      for i in 0 .. sched.nb_entries - 1 loop
         if (sched.entries (i).data.type_of_event = buffer_underflow) then
            nb := nb + 1;
         end if;
      end loop;

      return nb;
   end number_of_underflow_from_simulation;

   procedure cyclic_all_response_times_by_simulation
     (my_task : in     generic_task_ptr;
      sched   : in     scheduling_sequence_ptr;
      result  : in out task_occurence_table_ptr)
   is

      current_date          : Natural              := 0;
      task_occurence_number : task_occurence_range := 0;

   begin

      -- Look for task release time
      --
      task_occurence_number := 0;

      for j in 0 .. sched.nb_entries - 1 loop
         if sched.entries (j).data.type_of_event = task_activation then
            if sched.entries (j).data.activation_task.name = my_task.name then
               initialize
                 (result.entries (task_occurence_number),
                  my_task,
                  sched.entries (j).item);
               task_occurence_number := task_occurence_number + 1;
            end if;
         end if;
      end loop;

      -- Look for completion time
      -- and compute response time
      --
      task_occurence_number := 0;

      for j in 0 .. sched.nb_entries - 1 loop
         if sched.entries (j).data.type_of_event = end_of_task_capacity then

            current_date := sched.entries (j).item;

            if sched.entries (j).data.end_task.name = my_task.name then
               result.entries (task_occurence_number).completion_time :=
                 current_date;
               result.entries (task_occurence_number).response_time :=
                 current_date -
                 result.entries (task_occurence_number).arrival_time;

               task_occurence_number := task_occurence_number + 1;
               result.nb_entries     := result.nb_entries + 1;

            end if;
         end if;
      end loop;

   end cyclic_all_response_times_by_simulation;

   procedure acyclic_all_response_times_by_simulation
     (my_task : in     aperiodic_task_ptr;
      sched   : in     scheduling_sequence_ptr;
      result  : in out task_occurence_table_ptr)
   is

      current_date : Natural := 0;

   begin

      initialize (result.entries (0), generic_task_ptr (my_task));

      for t in 0 .. sched.nb_entries - 1 loop
         -- the current date
         --
         current_date := sched.entries (t).item;

         -- Look for task completion and task starting time
         --
         case sched.entries (t).data.type_of_event is
            when task_activation =>
               if sched.entries (t).data.activation_task.name =
                 my_task.name
               then
                  result.entries (0).arrival_time := current_date;
               end if;
            when end_of_task_capacity =>
               if sched.entries (t).data.end_task.name = my_task.name then
                  result.entries (0).completion_time := current_date;
                  result.nb_entries                  := 1;
               end if;
            when others =>
               null;
         end case;
      end loop;
   end acyclic_all_response_times_by_simulation;

   procedure all_response_times_by_simulation
     (my_task : in     generic_task_ptr;
      sched   : in     scheduling_sequence_ptr;
      result  : in out task_occurence_table_ptr)
   is

   begin

      case my_task.task_type is
         when aperiodic_type =>
            acyclic_all_response_times_by_simulation
              (aperiodic_task_ptr (my_task),
               sched,
               result);
         when others =>
            cyclic_all_response_times_by_simulation (my_task, sched, result);
      end case;

   end all_response_times_by_simulation;

   procedure compute_response_time_distribution
     (my_task : in     generic_task_ptr;
      sched   : in     scheduling_sequence_ptr;
      result  : in out density_table)
   is

      found                   : Boolean := False;
      a_density               : density_item;
      number_of_response_time : Double;

      my_task_occurence_table : task_occurence_table_ptr;

   begin

      -- Compute all the response times of the task  i
      --
      my_task_occurence_table := new task_occurence_table;
      all_response_times_by_simulation
        (my_task,
         sched,
         my_task_occurence_table);

      -- We have the response times. We look for the
      -- density table
      -- If so, increment the frequency, if
      -- not, add it to the table
      --
      for i in 0 .. my_task_occurence_table.nb_entries - 1 loop

         -- Check if this response is already known
         --
         found := False;
         for k in 0 .. result.nb_entries - 1 loop
            if result.entries (k).response_time =
              my_task_occurence_table.entries (i).response_time
            then
               result.entries (k).probability :=
                 result.entries (k).probability + 1.0;
               found := True;
            end if;
         end loop;
         if not found then
            a_density.response_time :=
              my_task_occurence_table.entries (i).response_time;
            a_density.probability := 1.0;
            add (result, a_density);
         end if;
      end loop;

      -- Now, compute density :
      -- divide all entries of the table by the found number of response time
      --
      number_of_response_time := 0.0;
      for k in 0 .. result.nb_entries - 1 loop
         number_of_response_time :=
           number_of_response_time + result.entries (k).probability;
      end loop;

      for k in 0 .. result.nb_entries - 1 loop
         result.entries (k).probability :=
           result.entries (k).probability / number_of_response_time;
      end loop;

      free (my_task_occurence_table);

   end compute_response_time_distribution;

   procedure compute_response_time_distribution
     (my_tasks       : in     tasks_set;
      sched          : in     scheduling_sequence_ptr;
      processor_name :        Unbounded_String;
      result         : in out densities_table)
   is

      a_task          : generic_task_ptr;
      my_iterator     : tasks_iterator;
      working_density : density_table;

   begin

      initialize (result);

      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if (processor_name = a_task.cpu_name) then
            initialize (working_density);
            compute_response_time_distribution
              (a_task,
               sched,
               working_density);
            add (result, a_task, working_density);

         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);

      end loop;

   end compute_response_time_distribution;

end Scheduling_Analysis.extended.task_analysis;
