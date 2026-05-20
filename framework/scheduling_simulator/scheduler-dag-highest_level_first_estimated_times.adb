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
--    $Rev: 5118 $
--    $Date: 2024-08-21 16:52:22 +0200 (mer., 21 août 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with unbounded_strings;     use unbounded_strings;
with translate;             use translate;
with Text_IO;               use Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;

package body scheduler.dag.highest_level_first_estimated_times is

   procedure initialize
     (a_scheduler : in out dag_highest_level_first_estimated_times_scheduler)
   is
   begin
      reset (a_scheduler);
      a_scheduler.parameters.scheduler_type :=
        dag_highest_level_first_estimated_times_protocol;
   end initialize;

   function copy
     (a_scheduler : in dag_highest_level_first_estimated_times_scheduler)
      return generic_scheduler_ptr
   is
      ptr : dag_highest_level_first_estimated_times_scheduler_ptr;

   begin

      ptr := new dag_highest_level_first_estimated_times_scheduler;

      ptr.parameters         := a_scheduler.parameters;
      ptr.previously_elected := a_scheduler.previously_elected;

      return generic_scheduler_ptr (ptr);

   end copy;

   procedure check_before_scheduling
     (my_scheduler   : in dag_highest_level_first_estimated_times_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

   begin
      null;
   end check_before_scheduling;

   procedure do_election
     (my_scheduler : in out dag_highest_level_first_estimated_times_scheduler;
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

      highiest_priority : Natural     := Natural'first;
      i, j, k                                        : tasks_range := 0;
      a_task, right, left, successor_task, real_task : generic_task_ptr;
      my_successors                                  : tasks_set;
      my_iterator1, ite0, ite1, ite2, ite3           : tasks_iterator;
      maxi                                           : Natural;
      my_tasks                                       : tasks_set;
      step, leaf, previous                           : tasks_set;

   begin

      -----------------------
      --   compute b_level --
      --   for each task  ---
      -----------------------

      ------------------------------
      -- construction de My_tasks --
      ------------------------------

      reset (my_tasks);
      j := 0;
      loop
         add (my_tasks, si.tcbs (j).tsk);
         j := j + 1;
         exit when si.tcbs (j) = null;
      end loop;

      -- Compute b_level for each task;  b_level is stored in task.criticality
      -- Parcourir My_tasks de bas vers le haut de droite vers gauche  ...
      -- a chaque fois, on calcule b_level qui est egale : b-level = capacity + max (blevel des successeurs)

      step :=
        get_leaf_tasks
          (si
             .dependencies);                   -- Extract leaves of the graph and update

      reset_iterator (step, ite0);
      loop
         current_element (step, a_task, ite0);
         real_task             := search_task (my_tasks, a_task.name);
         real_task.criticality := real_task.capacity;

         exit when is_last_element (step, ite0);
         next_element (step, ite0);
      end loop;                                                 -- update b-level value for leaves of the graph

      while not is_empty (step) loop

         reset (leaf);
         duplicate (step, leaf);
         reset (step);

         reset_iterator (leaf, ite1);

         for i in 0 .. get_number_of_elements (leaf) - 1 loop

            current_element (leaf, right, ite1);

            if has_asynchronous_communication_predecessor (si.dependencies, right) then
               reset (previous);
               previous :=
                 get_asynchronous_communication_predecessors_list
                   (si.dependencies,
                    right);  -- Take previous tasks

               reset_iterator (previous, ite2);
               for j in 0 .. get_number_of_elements (previous) - 1 loop

                  maxi := 0;
                  current_element (previous, left, ite2);
                  add
                    (step,
                     left);                                                      -- update Step

                  reset (my_successors);
                  my_successors :=
                    get_asynchronous_communication_successors_list(si.dependencies, left);

                  k := 0;
                  reset_iterator (my_successors, ite3);
                  loop
                     current_element (my_successors, successor_task, ite3);

                     real_task := search_task (my_tasks, successor_task.name);

                     if real_task.criticality > maxi then
                        maxi := real_task.criticality;
                     end if;

                     k := k + 1;
                     exit when is_last_element (my_successors, ite3);
                     next_element (my_successors, ite3);

                  end loop;                                                             -- find max (b-level of succesor task)

                  real_task             := search_task (my_tasks, left.name);
                  real_task.criticality := real_task.capacity + maxi;

                  next_element (previous, ite2);

               end loop;

            end if;

            next_element (leaf, ite1);

         end loop;

      end loop;

      -- update Si
      k := 0;
      loop
         real_task := search_task (my_tasks, si.tcbs (k).tsk.name);
         si.tcbs (k).tsk.criticality := real_task.criticality;
         k                           := k + 1;
         exit when si.tcbs (k) = null;
      end loop;

      -----------------------------
      --  selection of ready  -----
      --  task with highest   -----
      --   b_level            -----
      -----------------------------

      i := 0;
      loop

         --       Tcbs     is a  Tcb_Table  where Tcb_Table is array (Tasks_Range) of Tcb_Ptr
         --       Tcb presents information related to the tasks

         if not si.tcbs (i).already_run_at_current_time then
            -- Is true if the task is already run on a core unit for the
            -- current time unit  (boolean)

            if (si.tcbs (i).tsk.cpu_name = processor_name) and
              ((address_space_name = To_Unbounded_String ("")) or
               (address_space_name = si.tcbs (i).tsk.address_space_name))
            then
               -- Si.Tcbs (I).Tsk = Cheddar ADL properties of the task

               if check_core_assignment (my_scheduler, si.tcbs (i)) then
                  -- Check that the task can be run to the current core
                  -- according to core migration properties

                  -- Wake_Up_Time = Current release time of the task
                  if (si.tcbs (i).wake_up_time <= current_time) and
                    (si.tcbs (i).tsk.criticality >= highiest_priority) and
                    (si.tcbs (i).rest_of_capacity /= 0)
                  then

                     if (options.with_jitters = False) or
                       (si.tcbs (i).is_jitter_ready)
                     then

                        if (options.with_offsets = False) or
                          check_offset (si.tcbs (i), current_time)
                        then

                           if (options.with_precedencies = False) or
                             check_precedencies(si, current_time, si.tcbs (i))
                           then

                           ----------------------------------------------------
                           ----------------------------------------------------

                              highiest_priority := si.tcbs (i).tsk.criticality;
                              elected           := i;

                        -----------------------------------------------------
                        -----------------------------------------------------

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

      if highiest_priority = Natural'first then
         no_task := True;
      else
         no_task := False;
      end if;

   end do_election;

   procedure specific_scheduler_initialization
     (my_scheduler : in out dag_highest_level_first_estimated_times_scheduler;
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

end scheduler.dag.highest_level_first_estimated_times;
