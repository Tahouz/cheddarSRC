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
--    $Rev: 4589 $
--    $Date: 2023-09-29 16:02:19 +0200 (ven., 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Text_IO;               use Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Bounded;   use Ada.Strings.Bounded;
with unbounded_strings;     use unbounded_strings;
with Framework_Config;      use Framework_Config;
with Tasks;                 use Tasks;
with Offsets;               use Offsets.Offsets_Table_Package;
with Scheduling_Analysis;
use Scheduling_Analysis.Task_Release_Records_Table_Package;
with Scheduling_Analysis;         use Scheduling_Analysis;
with sets;
with priority_assignment;         use priority_assignment;
with priority_assignment.utility; use priority_assignment.utility;
with integer_util;                use integer_util;
with systems;                     use systems;
with cache_set;                   use cache_set;
with priority_assignment.audsley_opa_crpd_pt;
use priority_assignment.audsley_opa_crpd_pt;
with priority_assignment.audsley_opa_crpd_tree;
use priority_assignment.audsley_opa_crpd_tree;
with Caches; use Caches;
with debug;  use debug;
package body priority_assignment.audsley_opa is

   procedure check_input_data (my_tasks : in tasks_set) is
      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;
   begin
      reset_iterator (my_tasks, my_iterator);
      loop
         current_element (my_tasks, a_task, my_iterator);

         if (a_task.task_type /= periodic_type) then
            raise task_must_be_periodic;
         end if;

         -- TODO: check START_TIME
         --           if(a_task.offsets.Nb_Entries <= 0) then
         --              raise Offset_Must_Be_Defined;
         --           end if;

         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;
   end check_input_data;

   procedure remaining_interference
     (t_start  : in     Integer;
      t        : in     Integer;
      l_tti_i  : in     Integer;
      a_task   : in out generic_task_ptr;
      my_tasks : in out tasks_set;
      r_t_i    :    out Integer)
   is
      time     : Integer := 0;
      t_i      : Integer := 0;
      d_i      : Integer := 0;
      t_r      : Integer := 0;
      c        : Integer := 0;
      beta_set : task_release_records_table;
   begin
      t_i := periodic_task_ptr (a_task).period;
      d_i := a_task.deadline;
      -----------------------------------------
      time  := t - t_i + d_i;
      r_t_i := l_tti_i;
      -----------------------------------------
      initialize (beta_set);
      calculate_task_release_records_table
        (t_start                      => t_start,
         t_end                        => t,
         a_task                       => a_task,
         my_tasks                     => my_tasks,
         a_task_release_records_table => beta_set);
      -----------------------------------------
      for i in 0 .. beta_set.nb_entries - 1 loop
         c   := beta_set.entries (i).capacity;
         t_r := beta_set.entries (i).release_time;

         if (t_r > time + r_t_i) then
            r_t_i := 0;
         end if;

         if (t_r > time and r_t_i /= 0) then
            r_t_i := r_t_i + c - (t_r - time);
         else
            r_t_i := r_t_i + c;
         end if;

         time := t_r;
      end loop;
      -----------------------------------------
      r_t_i := r_t_i - (t - t_r);
      if (r_t_i < 0) then
         r_t_i := 0;
      end if;
   end remaining_interference;

   procedure created_interference
     (t        : in     Integer;
      r_t_i    : in     Integer;
      a_task   : in out generic_task_ptr;
      my_tasks : in out tasks_set;
      k_t_i    :    out Integer;
      l_tti_i  :    out Integer)
   is
      t_i           : Integer := 0;
      d_i           : Integer := 0;
      t_r           : Integer := 0;
      c             : Integer := 0;
      next_free     : Integer;
      total_created : Integer;
      eta_set       : task_release_records_table;
   begin
      t_i := periodic_task_ptr (a_task).period;
      d_i := a_task.deadline;
      -----------------------------------------
      next_free     := r_t_i + t;
      k_t_i         := 0;
      total_created := r_t_i;
      -----------------------------------------
      initialize (eta_set);
      calculate_task_release_records_table
        (t_start                      => t,
         t_end                        => t + d_i,
         a_task                       => a_task,
         my_tasks                     => my_tasks,
         a_task_release_records_table => eta_set);
      -----------------------------------------
      for i in 0 .. eta_set.nb_entries - 1 loop
         c   := eta_set.entries (i).capacity;
         t_r := eta_set.entries (i).release_time;

         total_created := total_created + c;
         if (next_free < t_r) then
            next_free := t_r;
         end if;

         k_t_i     := k_t_i + Integer'min (t + d_i - next_free, c);
         next_free := Integer'min (next_free + c, t + d_i);
      end loop;

      --This is an implementation which was not explained in the paper
      --In the next release, the remaining interference will be computed
      --with the time variable start from: time := t - T_i + D_i;
      --so, we substract the Integer'Max(D_i, R_t_i);
      l_tti_i := total_created - k_t_i - Integer'max (d_i, r_t_i);

      if (l_tti_i < 0) then
         l_tti_i := 0;
      end if;
   end created_interference;

   procedure opa_feasibility_test
     (priority_level : in     Integer;
      i_task         : in out generic_task_ptr;
      my_tasks       : in out tasks_set;
      is_schedulable :    out Boolean)
   is
      my_iterator_2 : tasks_iterator;
      j_task        : generic_task_ptr;

      t : Integer;

      refined_tasks : tasks_set;

      r_t_i : Integer := 0;
      k_t_i : Integer := 0;

      c_i : Integer;
      t_i : Integer;
      d_i : Integer;
      s_i : Integer;
      p_i : Integer;

      o_max : Integer := 0;

      l_tti_i : Integer := 0;
      t_start : Integer := 0;
   begin

      refine_offset
        (a_task        => i_task,
         my_tasks      => my_tasks,
         refined_tasks => refined_tasks);

      --Assign priority to tasks, the checking task has lowest priority level.
      --Also find the O_max
      i_task.priority := priority_range (priority_level);

      reset_iterator (refined_tasks, my_iterator_2);
      loop
         current_element (refined_tasks, j_task, my_iterator_2);
         if (j_task.name /= i_task.name) then
            j_task.priority := priority_range'last;
         else
            j_task.priority := priority_range (priority_level);
         end if;

         if (j_task.start_time > o_max) then
            o_max := Integer (j_task.start_time);
         end if;

         exit when is_last_element (refined_tasks, my_iterator_2);
         next_element (refined_tasks, my_iterator_2);
      end loop;
      ------------------------------------------------------------------------
      is_schedulable := True;
      c_i            := i_task.capacity;
      t_i            := periodic_task_ptr (i_task).period;
      d_i            := i_task.deadline;
      s_i := Integer (Float'ceiling (Float (o_max) / Float (t_i))) * (t_i);
      p_i            :=
        calculate_pi
          (priority_level => priority_level,
           my_tasks       => refined_tasks);
      t := s_i;

      while (t < s_i + p_i) loop
         r_t_i := 0;
         k_t_i := 0;
         remaining_interference
           (t_start  => t_start,
            t        => t,
            l_tti_i  => l_tti_i,
            a_task   => i_task,
            my_tasks => refined_tasks,
            r_t_i    => r_t_i);
         created_interference
           (t        => t,
            r_t_i    => r_t_i,
            a_task   => i_task,
            my_tasks => refined_tasks,
            k_t_i    => k_t_i,
            l_tti_i  => l_tti_i);
         put_debug
           ("Remaining I:" &
            r_t_i'img &
            " - Created I:" &
            k_t_i'img &
            " - Capacity:" &
            i_task.capacity'img &
            " - Deadline:" &
            i_task.deadline'img &
            " - P_i:" &
            p_i'img);
         if (c_i + r_t_i + k_t_i > d_i) then
            put_debug
              (To_String (i_task.name) &
               " Unschedulable with priority level: " &
               priority_level'img);
            is_schedulable := False;
            exit;
         end if;
         t_start := t;
         t       := t + t_i;
      end loop;
   end opa_feasibility_test;

   procedure opa (my_tasks : in out tasks_set) is
      delta_set      : tasks_set;
      my_iterator    : tasks_iterator;
      a_task         : generic_task_ptr;
      temp_task      : generic_task_ptr;
      n              : Integer := 1;
      unassigned     : Boolean;
      is_schedulable : Boolean;
   begin
      duplicate (src => my_tasks, dest => delta_set);

      n := Integer (delta_set.get_number_of_elements);

      for j in 1 .. n loop
         unassigned := True;
         sort (delta_set, decreasing_period_deadline'access);

         reset_iterator (delta_set, my_iterator);
         loop
            current_element (delta_set, a_task, my_iterator);

            opa_feasibility_test
              (priority_level => j,
               i_task         => a_task,
               my_tasks       => delta_set,
               is_schedulable => is_schedulable);

            if (is_schedulable) then
               put_debug
                 ("Assign priority level:" &
                  j'img &
                  " to task: " &
                  To_String (a_task.name) &
                  ASCII.LF &
                  "---");
               delete (delta_set, a_task);
               temp_task :=
                 search_task (my_tasks => my_tasks, name => a_task.name);
               temp_task.priority := priority_range (j);
               unassigned         := False;
               exit;
            end if;

            exit when is_last_element (delta_set, my_iterator);
            next_element (delta_set, my_iterator);
         end loop;

         if (unassigned) then
            raise no_feasible_priority_assignment_exception;
         end if;
      end loop;

   end opa;

   ---------------------------------------
   --
   ---------------------------------------
   procedure set_priority_according_to_audsley_opa
     (my_tasks       : in out tasks_set;
      processor_name : in     Unbounded_String := empty_string)
   is

      iterator1    : tasks_iterator;
      task1        : generic_task_ptr;
      iterator2    : tasks_iterator;
      task2        : generic_task_ptr;
      current_prio : priority_range := 1;
      tmp          : tasks_set;

   begin
      if processor_name = empty_string then
         duplicate (my_tasks, tmp);
      else
         current_processor_name := processor_name;
         select_and_copy (my_tasks, tmp, select_cpu'access);
      end if;

      periodic_control (tmp, processor_name);

      check_input_data (tmp);

      -- Assign priorities
      --
      opa (tmp);

      -- Copy resulting task objects in My_Tasks
      --
      reset_iterator (tmp, iterator1);
      loop
         current_element (tmp, task1, iterator1);

         reset_iterator (my_tasks, iterator2);
         loop
            current_element (my_tasks, task2, iterator2);

            if (task2.name = task1.name) then
               task2.priority := task1.priority;
            end if;

            exit when task2.name = task1.name;
            exit when is_last_element (my_tasks, iterator2);
            next_element (my_tasks, iterator2);
         end loop;

         exit when is_last_element (tmp, iterator1);
         next_element (tmp, iterator1);
      end loop;

      free (tmp);

   end set_priority_according_to_audsley_opa;

end priority_assignment.audsley_opa;
