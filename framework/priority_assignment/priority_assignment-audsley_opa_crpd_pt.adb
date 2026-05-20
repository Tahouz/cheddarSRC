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
with Tasks;                 use Tasks;
with Framework_Config;      use Framework_Config;
with Scheduling_Analysis;
use Scheduling_Analysis.Task_Release_Records_Table_Package;
with integer_util;                    use integer_util;
with tables;
with priority_assignment.utility;     use priority_assignment.utility;
with priority_assignment.audsley_opa; use priority_assignment.audsley_opa;
with Tasks.extended;                  use Tasks.extended;
with debug;                           use debug;
with integer_arrays;                  use integer_arrays;
with cache_set;                       use cache_set;

package body priority_assignment.audsley_opa_crpd_pt is

   procedure compute_potential_crpd
     (i                        : in     task_release_records_range;
      a_task                   : in     generic_task_ptr;
      a_task_ucb_ecb_array_ptr : in     task_ucb_ecb_array_ptr;
      be_complexity            : in     Boolean := False;
      arr_utility              : in out integer_array;
      beta_set                 : in out task_release_records_table_ptr;
      crpd_total               : in out Integer;
      crpd                     :    out Integer)
   is
      size      : Integer;
      npt       : Integer;
      arr_crpds : integer_array;
      arr_eucb  : integer_array;

      max_completion : Integer := 0;
      max_release    : Integer;
      k              : Integer;
      tmp            : Integer;
      tmp_crpd       : Integer := 0;
      crpd_ecb       : Integer := 0;
      ia_sets        : ias_ptr;

      max_finish_time : Integer := 0;

   begin
      --Put_debug("---");
      --Put_debug("Task: " & To_String(beta_set.Entries(i).task_name));
      --Put_debug("release time: " & beta_set.Entries(i).release_time'Img);
      --Put_debug("finish time: " & beta_set.Entries(i).finish_time'Img);

      size := arr_utility.size;
      npt  := 0;
      crpd := 0;
      initialize (arr_crpds);

      for j in 0 .. i - 1 loop
         if
           (beta_set.entries (j).finish_time <
            beta_set.entries (i).release_time)
         then
            beta_set.entries (j).completed := True;
         end if;
      end loop;

      max_finish_time := beta_set.entries (i).finish_time;
      for j in 0 .. i - 1 loop
         if (beta_set.entries (j).task_name /= a_task.name) then
            max_finish_time :=
              Integer'max (beta_set.entries (j).finish_time, max_finish_time);
         end if;
      end loop;

      ----------------------------------------------------------
      -- Compute the maximum number of preempted tasks
      ----------------------------------------------------------
      for j in reverse 0 .. arr_utility.size - 1 loop
         if
           (beta_set.entries (i).release_time < arr_utility.elements (j) and
            beta_set.entries (i).release_time >= arr_utility.elements (0))
         then
            npt := npt + 1;
         end if;
      end loop;

      --Print(arr_utility);
      -- Put_Line(ASCII.HT & "Task: " & To_String(beta_set.Entries(i).task_name) & " - Release time: " & beta_set.Entries(i).release_time'Img & " - NPT:" & npt'Img);

      if (npt > 5) then
         npt := 5;
      end if;

      ----------------------------------------------------------
      -- Compute the maximum CRPD
      ----------------------------------------------------------
      if (be_complexity) then
         initialize (ia_sets);
         --Computation with Binomial Coefficient Complexity

         --Put_Line(ASCII.HT & ASCII.HT & "- Not completed tasks:");

         for j in 0 .. i - 1 loop
            if (not beta_set.entries (j).completed) then
               get_eucbs
                 (a_task_ucb_ecb_array => a_task_ucb_ecb_array_ptr,
                  preempting_task      => beta_set.entries (i).task_name,
                  preempted_task       => beta_set.entries (j).task_name,
                  arr_eucbs            => arr_eucb);
               add (ia_sets, arr_eucb);

   --Put_Line(ASCII.HT & ASCII.HT & To_String(beta_set.Entries(j).task_name));
            end if;
         end loop;

         crpd :=
           compute_crpd_potential_preempted
             (sets => ia_sets,
              k    => npt,
              n    => ia_sets'length);

         for j in 0 .. ia_sets'length - 1 loop
            free (ia_sets (j));
         end loop;
         free (ia_sets);

   --------------------------------------------------------------------------
      else

         --Put_Line(ASCII.HT & ASCII.HT & "- Not completed tasks:");

         for j in 0 .. i - 1 loop
            if (not beta_set.entries (j).completed) then
               check_ccb
                 (a_task_ucb_ecb_array => a_task_ucb_ecb_array_ptr,
                  preempting_task      => beta_set.entries (i).task_name,
                  preempted_task       => beta_set.entries (j).task_name,
                  n_ccb                => tmp_crpd);
               if (tmp_crpd >= 0) then
                  add (arr_crpds, tmp_crpd);
               end if;

   --Put_Line(ASCII.HT & ASCII.HT & To_String(beta_set.Entries(j).task_name));
            end if;
         end loop;
         sort_asc (arr_crpds);

         for j in 0 .. npt - 1 loop
            if (arr_crpds.size - 1 - j >= 0) then
               crpd := crpd + arr_crpds.elements (arr_crpds.size - 1 - j);
            end if;
         end loop;
      end if;

      for j in 0 .. a_task_ucb_ecb_array_ptr'length - 1 loop
         if
           (a_task_ucb_ecb_array_ptr (j).task_name =
            beta_set.entries (i).task_name)
         then
            crpd_ecb := a_task_ucb_ecb_array_ptr (j).crpd_ecb;
         end if;
      end loop;

      if (crpd > crpd_ecb) then
         crpd := crpd_ecb;
      end if;

      crpd_total := crpd_total + crpd;

      for j in 0 .. i - 1 loop
         if (not beta_set.entries (j).completed) then
            beta_set.entries (j).finish_time :=
              beta_set.entries (j).finish_time +
              crpd +
              beta_set.entries (i).capacity;
         end if;
      end loop;
      ----------------------------------------------------------
      -- Compute the array
      ----------------------------------------------------------
      max_release :=
        beta_set.entries (i)
          .release_time;                          --The table is sorted by release time, as a result, it is always the release time of the J_i;
      max_completion :=
        Integer'max (max_finish_time + crpd, beta_set.entries (i).finish_time);

      beta_set.entries (i).finish_time :=
        max_finish_time + beta_set.entries (i).capacity;

      arr_utility.elements (0) :=
        max_release;                                   --The first element

      k :=
        1;                                                                   --Remove element smaller than release time of J_i
      while (k < size) loop
         if (arr_utility.elements (k) < max_release) then
            remove (arr_utility, k);
            size := arr_utility.size;
         else
            k := k + 1;
         end if;
      end loop;

      --Print(arr_utility);

      for j in 0 .. i - 1 loop
         if
           (beta_set.entries (j).finish_time < max_release or
            beta_set.entries (j).deadline < max_release)
         then
            beta_set.entries (j).completed := True;
         end if;
      end loop;

      size := arr_utility.size;
      tmp  :=
        arr_utility.elements (size - 1) +
        beta_set.entries (i).capacity;       --The last element
      add (arr_utility, tmp);

      --Print(arr_utility);

      for j in reverse 2 .. size - 1
      loop                                                   --Other element of the array
         arr_utility.elements (j) :=
           arr_utility.elements (j - 1) + beta_set.entries (i).capacity;
      end loop;

      --Print(arr_utility);

      for j in 2 .. arr_utility.size - 1 loop
         arr_utility.elements (j) := arr_utility.elements (j) + crpd;
      end loop;

      arr_utility.elements (1) :=
        max_completion;                                --The second element

      --Print(arr_utility);

      --Put_Line(ASCII.HT & ASCII.HT & "- CRPD:" & crpd'Img);
   end compute_potential_crpd;

   procedure remaining_interference_crpd_upperbound
     (t_start                  : in     Integer;
      t                        : in     Integer;
      l_tti_i                  : in     Integer;
      a_task_ucb_ecb_array_ptr : in     task_ucb_ecb_array_ptr;
      be_complexity            : in     Boolean := False;
      a_task                   : in     generic_task_ptr;
      my_tasks                 : in out tasks_set;
      r_t_i                    :    out Integer;
      r_releases               :    out task_release_records_table_ptr;
      r_arr_utility            :    out integer_array)
   is
      ----------------------------------------------------------
      -- Variables of original Remaining Interference computation
      ----------------------------------------------------------
      time     : Integer := 0;
      t_i      : Integer := 0;
      d_i      : Integer := 0;
      t_r      : Integer := 0;
      c        : Integer := 0;
      beta_set : task_release_records_table_ptr;

      ----------------------------------------------------------
      -- Variables of CRPD computation
      ----------------------------------------------------------
      arr_utility : integer_array;
      crpd        : Integer := 0;
      crpd_total  : Integer := 0;
   begin
      t_i := periodic_task_ptr (a_task).period;
      d_i := a_task.deadline;
      -----------------------------------------
      time  := t - t_i + d_i;
      r_t_i := l_tti_i;
      -----------------------------------------
      calculate_task_release_records_table
        (t_start  => t_start,
         t_end    => t,
         a_task   => a_task,
         my_tasks => my_tasks,
         a_tuea   => a_task_ucb_ecb_array_ptr,
         a_trrt   => beta_set);

      --Put_Line("===Remaining Interference: TTR:");
      --Print_Task_Release_Records_Table(beta_set);

      -----------------------------------------
      if (beta_set.nb_entries > 0) then
         initialize (arr_utility);
         add
           (arr_utility,
            beta_set.entries (0)
              .release_time);                    --Initilize the array
         add (arr_utility, beta_set.entries (0).finish_time);
         -----------------------------------------
         for i in 0 .. beta_set.nb_entries - 1 loop
            ----------------------------------------------------------
            -- CRPD
            ----------------------------------------------------------
            if (i > 0) then
               compute_potential_crpd
                 (i                        => i,
                  a_task                   => a_task,
                  a_task_ucb_ecb_array_ptr => a_task_ucb_ecb_array_ptr,
                  arr_utility              => arr_utility,
                  beta_set                 => beta_set,
                  crpd_total               => crpd_total,
                  crpd                     => crpd,
                  be_complexity            => be_complexity);
            end if;

            ----------------------------------------------------------
            -- Remaining Inteference Computation
            ----------------------------------------------------------
            c   := beta_set.entries (i).capacity + crpd;
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
      end if;
      -----------------------------------------
      r_t_i := r_t_i - (t - t_r);
      if (r_t_i < 0) then
         r_t_i := 0;
      end if;

      ----------------------------------------------------------
      -- Pass the remaining release and crpd_utility to Created_Interference
      ----------------------------------------------------------
      for j in 0 .. beta_set.nb_entries - 1 loop
         if (beta_set.entries (j).finish_time < t_start + d_i) then
            beta_set.entries (j).completed := True;
         end if;
      end loop;

      r_releases := new task_release_records_table;

      for j in 0 .. beta_set.nb_entries - 1 loop
         if (not beta_set.entries (j).completed) then
            add (r_releases.all, beta_set.entries (j));
         end if;
      end loop;

      r_arr_utility := arr_utility;
   end remaining_interference_crpd_upperbound;

   procedure created_interference_crpd_upperbound
     (t                        : in     Integer;
      r_t_i                    : in     Integer;
      a_task_ucb_ecb_array_ptr : in     task_ucb_ecb_array_ptr;
      r_releases               : in     task_release_records_table_ptr;
      r_arr_utility            : in     integer_array;
      be_complexity            : in     Boolean := False;
      a_task                   : in     generic_task_ptr;
      my_tasks                 : in out tasks_set;
      k_t_i                    :    out Integer;
      l_tti_i                  :    out Integer)
   is
      ----------------------------------------------------------
      -- Variables of original Created Interference computation
      ----------------------------------------------------------
      t_i           : Integer := 0;
      d_i           : Integer := 0;
      t_r           : Integer := 0;
      c             : Integer := 0;
      next_free     : Integer;
      total_created : Integer;
      eta_set       : task_release_records_table_ptr;

      a_task_release_record : task_release_record_ptr;
      finished              : Boolean;
      ----------------------------------------------------------
      -- Variables of CRPD computation
      ----------------------------------------------------------
      arr_utility : integer_array;
      crpd        : Integer := 0;
      crpd_total  : Integer := 0;
   begin
      t_i           := periodic_task_ptr (a_task).period;
      d_i           := a_task.deadline;
      next_free     := r_t_i + t;
      k_t_i         := 0;
      total_created := r_t_i;
      calculate_task_release_records_table
        (t_start  => t,
         t_end    => t + d_i,
         a_task   => a_task,
         my_tasks => my_tasks,
         a_tuea   => a_task_ucb_ecb_array_ptr,
         a_trrt   => eta_set);

      ----------------------------------------------------------
   --Ghost release, used to compute the CRPD caused to the release of the task
      ----------------------------------------------------------
      a_task_release_record              := new task_release_record;
      a_task_release_record.task_name    := a_task.name;
      a_task_release_record.capacity     := 0;
      a_task_release_record.release_time := t;
      a_task_release_record.finish_time  := t + a_task.capacity + r_t_i;
      a_task_release_record.deadline     := t + a_task.deadline;
      add (eta_set.all, a_task_release_record);

      loop
         finished := True;
         for j in 0 .. eta_set.nb_entries - 2 loop
            if
              (eta_set.entries (j + 1).release_time <
               eta_set.entries (j).release_time)
            then
               finished                := False;
               a_task_release_record   := eta_set.entries (j + 1);
               eta_set.entries (j + 1) := eta_set.entries (j);
               eta_set.entries (j)     := a_task_release_record;
            end if;
         end loop;
         exit when finished;
      end loop;

      --Implement to fix a bug: a release has the same release time with release of the assessing task
      --if job of assessing task share the same release time with another job, it must have a lower index
      --2 blocks of this code are needed.
      for j in 0 .. eta_set.nb_entries - 2 loop
         if
           (eta_set.entries (j).release_time =
            eta_set.entries (j + 1).release_time and
            eta_set.entries (j + 1).task_name = a_task.name)
         then
            a_task_release_record   := eta_set.entries (j + 1);
            eta_set.entries (j + 1) := eta_set.entries (j);
            eta_set.entries (j)     := a_task_release_record;
         end if;
      end loop;

      -----------------------------------------
      if (eta_set.nb_entries > 0) then
         initialize (arr_utility);
         add
           (arr_utility,
            eta_set.entries (0)
              .release_time);                     --Initilize the array
         add (arr_utility, eta_set.entries (0).finish_time);

         --Print(arr_utility);

         ----------------------------------------------------------
         -- Merge the two array
         ----------------------------------------------------------
         for j in 0 .. r_arr_utility.size - 1 loop
            if
              (r_arr_utility.elements (j) > eta_set.entries (0).release_time)
            then
               add (arr_utility, r_arr_utility.elements (j));
            end if;
         end loop;
         sort_asc (arr_utility);
         ----------------------------------------------------------
         -- Merge the two set
         ----------------------------------------------------------
         for j in 0 .. r_releases.nb_entries - 1 loop
            if (not r_releases.entries (j).completed) then
               add (eta_set.all, r_releases.entries (j));
            end if;
         end loop;

         loop
            finished := True;
            for j in 0 .. eta_set.nb_entries - 2 loop
               if
                 (eta_set.entries (j + 1).release_time <
                  eta_set.entries (j).release_time)
               then
                  finished                := False;
                  a_task_release_record   := eta_set.entries (j + 1);
                  eta_set.entries (j + 1) := eta_set.entries (j);
                  eta_set.entries (j)     := a_task_release_record;
               end if;
            end loop;
            exit when finished;
         end loop;

         --Implement to fix a bug: a release has the same release time with release of the assessing task
         --if job of assessing task share the same release time with another job, it must have a lower index
         for j in 0 .. eta_set.nb_entries - 2 loop
            if
              (eta_set.entries (j).release_time =
               eta_set.entries (j + 1).release_time and
               eta_set.entries (j + 1).task_name = a_task.name)
            then
               a_task_release_record   := eta_set.entries (j + 1);
               eta_set.entries (j + 1) := eta_set.entries (j);
               eta_set.entries (j)     := a_task_release_record;
            end if;
         end loop;

         --Put_Line("===Created Interference: TTR:");
         --Print_Task_Release_Records_Table(eta_set);

         -----------------------------------------
         for i in r_releases.nb_entries + 1 .. eta_set.nb_entries - 1
         loop            --We added one ghost release, so it is r_releases.Nb_Entries -1 + 1
            ----------------------------------------------------------
            -- CRPD
            ----------------------------------------------------------
            compute_potential_crpd
              (i                        => i,
               a_task                   => a_task,
               a_task_ucb_ecb_array_ptr => a_task_ucb_ecb_array_ptr,
               arr_utility              => arr_utility,
               beta_set                 => eta_set,
               crpd_total               => crpd_total,
               crpd                     => crpd,
               be_complexity            => be_complexity);
            ----------------------------------------------------------
            -- K_t_i = CRPD
            ----------------------------------------------------------
            c :=
              eta_set.entries (i).capacity +
              crpd;                            --Add the CRPD to the capacity of job
            t_r := eta_set.entries (i).release_time;

            total_created := total_created + c;
            if (next_free < t_r) then
               next_free := t_r;
            end if;

            k_t_i     := k_t_i + Integer'min (t + d_i - next_free, c);
            next_free := Integer'min (next_free + c, t + d_i);
         end loop;
      end if;
      -----------------------------------------
      l_tti_i := total_created - k_t_i - Integer'max (d_i, r_t_i);
      if (l_tti_i < 0) then
         l_tti_i := 0;
      end if;
      -----------------------------------------
      --Put_Line("crpd_Total:" & crpd_Total'Img);
      --Put_Line("");

   end created_interference_crpd_upperbound;

   procedure opa_feasibility_test_crpd_upperbound
     (priority_level           : in     Integer;
      a_task_ucb_ecb_array_ptr : in     task_ucb_ecb_array_ptr;
      be_complexity            : in     Boolean := False;
      i_task                   : in out generic_task_ptr;
      my_tasks                 : in out tasks_set;
      is_schedulable           :    out Boolean)
   is
      my_iterator_2 : tasks_iterator;
      j_task        : generic_task_ptr;

      t             : Integer;
      refined_tasks : tasks_set;
      r_t_i         : Integer := 0;
      k_t_i         : Integer := 0;

      c_i : Integer;
      t_i : Integer;
      d_i : Integer;
      s_i : Integer;
      p_i : Integer;

      o_max : Integer := 0;

      l_tti_i : Integer := 0;
      t_start : Integer := 0;

      index : Integer := 0;

      r_releases    : task_release_records_table_ptr;
      r_arr_utility : integer_array;
   begin

      refine_offset
        (a_task        => i_task,
         my_tasks      => my_tasks,
         refined_tasks => refined_tasks);

      --Put_Line("===REFINED TASK SETS:");
      --Print_Task_Set(refined_tasks);

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

      t := 0;

      while (t < s_i + p_i) loop

         index := index + 1;

         remaining_interference_crpd_upperbound
           (t_start                  => t_start,
            t                        => t,
            l_tti_i                  => l_tti_i,
            a_task                   => i_task,
            my_tasks                 => refined_tasks,
            r_t_i                    => r_t_i,
            a_task_ucb_ecb_array_ptr => a_task_ucb_ecb_array_ptr,
            r_releases               => r_releases,
            r_arr_utility            => r_arr_utility,
            be_complexity            => be_complexity);

         created_interference_crpd_upperbound
           (t                        => t,
            r_t_i                    => r_t_i,
            a_task                   => i_task,
            my_tasks                 => refined_tasks,
            k_t_i                    => k_t_i,
            l_tti_i                  => l_tti_i,
            a_task_ucb_ecb_array_ptr => a_task_ucb_ecb_array_ptr,
            r_releases               => r_releases,
            r_arr_utility            => r_arr_utility,
            be_complexity            => be_complexity);

         --Put_Line(index'Img & ":Remaining I:" & R_t_i'Img & " - Created I:" & K_t_i'Img & " - Capacity:" & i_task.capacity'Img & " - L_tTi_i:" & L_tTi_i'Img & " - Deadline:" & i_task.deadline'Img & " - S_i:" & S_i'Img & " - P_i:" & P_i'Img);
         if (c_i + r_t_i + k_t_i > d_i) then
            --Put_Line(To_String(i_task.name) & " Unschedulable with priority level: "& priority_level'Img);
            is_schedulable := False;
            exit;
         end if;

         t_start := t;
         t       := t + t_i;
      end loop;
   end opa_feasibility_test_crpd_upperbound;

end priority_assignment.audsley_opa_crpd_pt;
