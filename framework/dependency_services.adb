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
-- Frank Singhoff, Lab-STICC UMR CNRS 6285, Universite de Bretagne Occidentale
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

with Tasks;             use Tasks;
with unbounded_strings; use unbounded_strings;
with Framework_Config;  use Framework_Config;
with Processors;        use Processors;
with scheduler;         use scheduler;
with scheduler_builder; use scheduler_builder;
with Doubles;           use Doubles;
with Buffers;           use Buffers;
use Buffers.Buffer_Roles_Package;
with feasibility_test.periodic_task_worst_case_response_time;
use feasibility_test.periodic_task_worst_case_response_time;
with task_dependencies; use task_dependencies;
use task_dependencies.half_dep_set;
with Dependencies; use Dependencies;

package body dependency_services is

   procedure set_parameters_according_to_chetto
     (my_dependencies    : in     tasks_dependencies_ptr;
      my_tasks           : in out tasks_set;
      compute_deadlines  : in     Boolean;
      compute_priorities : in     Boolean)
   is

      leaf, step                         : tasks_set;
      previous                           : tasks_set;
      real_left, real_right, left, right : generic_task_ptr;
      ite1, ite2                         : tasks_iterator;

   begin

      if is_precedence_cyclic (my_dependencies) then
         raise cyclic_graph_error;
      end if;

      dependencies_same_periods_control
        (my_tasks,
         my_dependencies,
         empty_string);

      -- Assume the graph is acyclic.
      -- Extract leaves of the graph and update deadline
      -- of previous node
      --
      step := get_leaf_tasks (my_dependencies);

      while not is_empty (step) loop

         reset (leaf);
         duplicate (step, leaf);
         reset (step);

         reset_iterator (leaf, ite1);
         for i in 0 .. get_number_of_elements (leaf) - 1 loop

            -- The task to be updated
            --
            current_element (leaf, right, ite1);

            -- Take previous tasks
            --
            if has_precedence_predecessor (my_dependencies, right) then

               reset (previous);
               previous := get_precedence_predecessors_list (my_dependencies, right);

               reset_iterator (previous, ite2);

               for j in 0 .. get_number_of_elements (previous) - 1 loop

                  current_element (previous, left, ite2);
                  add (step, left);

                  real_left  := search_task (my_tasks, left.name);
                  real_right := search_task (my_tasks, right.name);

                  if compute_priorities then
                     if right.priority >= 1 then
                        real_left.priority :=
                          priority_range'max
                            (real_left.priority,
                             real_right.priority + 1);
                     end if;
                  end if;

                  if compute_deadlines then

                     if
                       (Integer (real_right.deadline) -
                        Integer (real_right.capacity) <
                        0)
                     then
                        raise deadline_exhausted;
                     end if;

                     real_left.deadline :=
                       Natural'min
                         (real_left.deadline,
                          real_right.deadline - real_right.capacity);
                  end if;

                  next_element (previous, ite2);
               end loop;
            end if;

            next_element (leaf, ite1);
         end loop;

      end loop;

   end set_parameters_according_to_chetto;

   function get_response_time
     (rtn    : in response_time_table;
      a_task :    generic_task_ptr) return Double
   is
   begin
      for i in response_time_range loop
         if (rtn.entries (i).item.name = a_task.name) then
            return rtn.entries (i).data;
         end if;
      end loop;

      raise task_set.task_not_found;
   end get_response_time;

   procedure inject_response_time_into_jitter
     (my_dependencies : in     tasks_dependencies_ptr;
      my_tasks        : in out tasks_set;
      rtn             : in     response_time_table)
   is

      max_jitter       : Double := 0.0;
      ite1, ite2       : tasks_iterator;
      previous, a_task : generic_task_ptr;
      pred             : tasks_set;

   begin

      -- Scan each task. If a task has a predecessor, set its jitter
      -- to the response time of its predecessors
      --
      reset_iterator (my_tasks, ite1);
      loop
         current_element (my_tasks, a_task, ite1);

         -- Find maximum response time of predecessors
         --
         if has_precedence_predecessor (my_dependencies, a_task) then
            reset (pred);
            pred := get_precedence_predecessors_list (my_dependencies, a_task);

            if not is_empty (pred) then
               reset_iterator (pred, ite2);
               max_jitter := 0.0;
               for i in 0 .. get_number_of_elements (pred) - 1 loop

                  current_element (pred, previous, ite2);

                  max_jitter :=
                    Double'max (max_jitter, get_response_time (rtn, previous));

                  next_element (pred, ite2);
               end loop;

               -- set jitter with max_jitter
               --
               case a_task.task_type is
                  when periodic_type | poisson_type | sporadic_type =>
                     periodic_task_ptr (a_task).jitter :=
                       Natural'max
                         (periodic_task_ptr (a_task).jitter,
                          Natural (max_jitter));
                  when others =>
                     raise task_model_error;
               end case;
            end if;
         end if;

         exit when is_last_element (my_tasks, ite1);
         next_element (my_tasks, ite1);
      end loop;

   end inject_response_time_into_jitter;

   procedure compute_all_response_times
     (my_sys   : in out system;
      my_tasks : in out tasks_set;
      msg      : in out Unbounded_String;
      rtn      : in out response_time_table)
   is

      i           : Natural;
      k, j        : response_time_range;
      a_processor : generic_processor_ptr;
      my_iterator : processors_iterator;

      type rt is array (0 .. Max_Processors - 1) of response_time_table;
      rt_by_processor : rt;

   begin

      -- Compute tasks
      --
      i := 0;
      reset_iterator (my_sys.processors, my_iterator);

      loop
         current_element (my_sys.processors, a_processor, my_iterator);

         msg := empty_string;
         if get_number_of_task_from_processor (my_tasks, a_processor.name) >
           0
         then
            my_sys.tasks := my_tasks;
            compute_response_time
              (build_a_scheduler (a_processor),
               my_sys,
               a_processor.name,
               msg,
               rt_by_processor (i));
         end if;

         exit when is_last_element (my_sys.processors, my_iterator);

         next_element (my_sys.processors, my_iterator);
         i := i + 1;
      end loop;

      i := 0;
      k := 0;

      reset_iterator (my_sys.processors, my_iterator);

      loop
         j := 0;
         current_element (my_sys.processors, a_processor, my_iterator);

         for l in
           0 ..
               (get_number_of_task_from_processor
                  (my_tasks,
                   a_processor.name) -
                1)
         loop
            rtn.entries (k) := rt_by_processor (i).entries (j);
            rtn.nb_entries  := rtn.nb_entries + 1;
            k               := k + 1;
            j               := j + 1;
         end loop;

         exit when is_last_element (my_sys.processors, my_iterator);

         next_element (my_sys.processors, my_iterator);
         i := i + 1;

      end loop;

   end compute_all_response_times;

   procedure compute_end_to_end_response_time
     (my_sys           : in out system;
      one_step         : in     Boolean;
      update_tasks_set : in     Boolean;
      msg              : in out Unbounded_String;
      rt               : in out response_time_table)
   is

      rtn, rtn1 : response_time_table;
      tmp_tasks : tasks_set;

   begin

      initialize (rtn);
      initialize (rtn1);

      dependencies_same_periods_control
        (my_sys.tasks,
         my_sys.dependencies,
         empty_string);
      dependencies_task_models_control
        (my_sys.tasks,
         my_sys.dependencies,
         empty_string);

      if not update_tasks_set then
         duplicate (my_sys.tasks, tmp_tasks);
      end if;

      compute_all_response_times (my_sys, my_sys.tasks, msg, rtn);

      loop

         -- Stop when end to end response time do not change
         -- from an iteration to another
         --
         exit when is_equal (rtn, rtn1);

         -- Update jitter ....
         --
         if not update_tasks_set then
            inject_response_time_into_jitter
              (my_sys.dependencies,
               tmp_tasks,
               rtn);
         else
            inject_response_time_into_jitter
              (my_sys.dependencies,
               my_sys.tasks,
               rtn);
         end if;

         if one_step then
            exit;
         end if;

         rtn1 := rtn;
         initialize (rtn);

         if not update_tasks_set then
            compute_all_response_times (my_sys, tmp_tasks, msg, rtn);
         else
            compute_all_response_times (my_sys, my_sys.tasks, msg, rtn);
         end if;

         -- Stop when all deadlines are missed
         --
         exit when all_deadlines_missed (rtn);

      end loop;

      rt := rtn;

   end compute_end_to_end_response_time;

   function all_deadlines_missed
     (rtn : in response_time_table) return Boolean
   is
   begin

      for i in 0 .. rtn.nb_entries - 1 loop
         if rtn.entries (i).data < Double (rtn.entries (i).item.deadline) then
            return False;
         end if;
      end loop;

      return True;
   end all_deadlines_missed;

   function is_equal
     (rtn  : in response_time_table;
      rtn1 : in response_time_table) return Boolean
   is
   begin

      if rtn.nb_entries /= rtn1.nb_entries then
         return False;
      end if;

      for i in 0 .. rtn.nb_entries - 1 loop
         if rtn.entries (i).data /= rtn1.entries (i).data then
            return False;
         end if;
      end loop;

      return True;
   end is_equal;

   --
   -- Check that all task of a dependency graph have the same type
   --

   procedure dependencies_task_models_control
     (my_tasks       : in tasks_set;
      my_deps        : in tasks_dependencies_ptr;
      processor_name : in Unbounded_String)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

      real_task1, real_task2 : generic_task_ptr;

   begin

      if not is_empty (my_deps.depends) then

         reset_iterator (my_deps.depends, my_iterator1);

         loop
            current_element (my_deps.depends, a_half_dep, my_iterator1);

            if (a_half_dep.type_of_dependency = precedence_dependency) then
               real_task1 :=
                 search_task (my_tasks, a_half_dep.precedence_source.name);
               real_task2 :=
                 search_task (my_tasks, a_half_dep.precedence_sink.name);

               if (real_task1.cpu_name = processor_name) or
                 (real_task2.cpu_name = processor_name) or
                 (processor_name = empty_string)
               then
                  if real_task1.task_type /= real_task2.task_type then
                     raise task_model_error;
                  end if;
               end if;
            end if;

            exit when is_last_element (my_deps.depends, my_iterator1);

            next_element (my_deps.depends, my_iterator1);
         end loop;
      end if;

   end dependencies_task_models_control;

   procedure dependencies_same_periods_control
     (my_tasks       : in tasks_set;
      my_deps        : in tasks_dependencies_ptr;
      processor_name : in Unbounded_String)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

      real_task1, real_task2 : generic_task_ptr;
      period1, period2       : Natural;

   begin

      if not is_empty (my_deps.depends) then

         reset_iterator (my_deps.depends, my_iterator1);

         loop
            current_element (my_deps.depends, a_half_dep, my_iterator1);

            if (a_half_dep.type_of_dependency = precedence_dependency) then
               real_task1 :=
                 search_task (my_tasks, a_half_dep.precedence_source.name);
               real_task2 :=
                 search_task (my_tasks, a_half_dep.precedence_sink.name);

               if (real_task1.cpu_name = processor_name) or
                 (real_task2.cpu_name = processor_name) or
                 (processor_name = empty_string)
               then

                  if real_task1.task_type = aperiodic_type then
                     period1 := 0;
                  else
                     period1 := periodic_task_ptr (real_task1).period;
                  end if;
                  if real_task2.task_type = aperiodic_type then
                     period2 := 0;
                  else
                     period2 := periodic_task_ptr (real_task2).period;
                  end if;

                  if period1 /= period2 then
                     raise dependencies_period_error;
                  end if;

               end if;
            end if;

            exit when is_last_element (my_deps.depends, my_iterator1);

            next_element (my_deps.depends, my_iterator1);
         end loop;
      end if;

   end dependencies_same_periods_control;

   procedure dependencies_harmonic_periods_control
     (my_tasks       : in tasks_set;
      my_deps        : in tasks_dependencies_ptr;
      processor_name : in Unbounded_String)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

      real_task1, real_task2     : generic_task_ptr;
      period1, period2, harmonic : Natural;

   begin

      if not is_empty (my_deps.depends) then

         reset_iterator (my_deps.depends, my_iterator1);

         loop
            current_element (my_deps.depends, a_half_dep, my_iterator1);

            if (a_half_dep.type_of_dependency = precedence_dependency) then
               real_task1 :=
                 search_task (my_tasks, a_half_dep.precedence_source.name);
               real_task2 :=
                 search_task (my_tasks, a_half_dep.precedence_sink.name);

               if (real_task1.cpu_name = processor_name) or
                 (real_task2.cpu_name = processor_name) or
                 (processor_name = empty_string)
               then

                  if real_task1.task_type = aperiodic_type then
                     period1 := 0;
                  else
                     period1 := periodic_task_ptr (real_task1).period;
                  end if;
                  if real_task2.task_type = aperiodic_type then
                     period2 := 0;
                  else
                     period2 := periodic_task_ptr (real_task2).period;
                  end if;

                  if period1 > period2 then
                     harmonic := period1 mod period2;
                  else
                     harmonic := period2 mod period1;
                  end if;

                  if harmonic /= 0 then
                     raise dependencies_period_error;
                  end if;

               end if;
            end if;

            exit when is_last_element (my_deps.depends, my_iterator1);

            next_element (my_deps.depends, my_iterator1);
         end loop;
      end if;

   end dependencies_harmonic_periods_control;

   procedure periodic_buffer_control
     (my_tasks : in tasks_set;
      a_buffer : in buffer_ptr)
   is

      iterator1 : tasks_iterator;
      task1     : generic_task_ptr;

   begin

      for i in 0 .. a_buffer.roles.nb_entries - 1 loop

         reset_iterator (my_tasks, iterator1);

         loop
            current_element (my_tasks, task1, iterator1);

            if (task1.name = a_buffer.roles.entries (i).item) then
               if (task1.task_type /= periodic_type) then
                  raise task_must_be_periodic;
               end if;
            end if;

            exit when is_last_element (my_tasks, iterator1);
            next_element (my_tasks, iterator1);

         end loop;

      end loop;

   end periodic_buffer_control;

end dependency_services;
