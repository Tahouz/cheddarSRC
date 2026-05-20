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

with Text_IO;             use Text_IO;
with translate;           use translate;
with unbounded_strings;   use unbounded_strings;
with scheduler;           use scheduler;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with Tasks; use Tasks;
use Tasks.Generic_Task_List_Package;
with task_set;          use task_set;
with Offsets;           use Offsets;
with Offsets.extended;  use Offsets.extended;
with task_dependencies; use task_dependencies;
with Dependencies;      use Dependencies;

package body feasibility_test.transaction_worst_case_response_time is
   type tasks_set_ptr is new generic_task_set.set_ptr;

   -- Compute the significant S for a i-j task pair
   --
   function audsley_compute_s
     (current_group : in generic_task_group_ptr;
      taski         : in generic_task_ptr;
      taskj         : in generic_task_ptr;
      q             : in Natural) return Double
   is
      s, kj, tj, oj, jj, oi, ji : Double;
   begin

      tj := Double (transaction_task_group_ptr (current_group).period);
      oj := Double (taskj.offsets.entries (0).offset_value);
      jj := Double (periodic_task_ptr (taskj).jitter);
      oi := Double (taski.offsets.entries (0).offset_value);
      ji := Double (periodic_task_ptr (taski).jitter);

      kj := Double'ceiling ((jj + oj - oi - ji) / tj);

      s := (Double (q) + kj) * tj - oj - jj + oi + ji;

      return s;
   end audsley_compute_s;

   function audsley_compute_wis_preemptive       --Audsley's tasks are premptive
     (my_task_groups : in task_groups_set;        --all the task
      current_group  : in generic_task_group_ptr;
      current_task   : in generic_task_ptr;       --the task examine
      s              : in Double) return Double
   is
      iterator_taskj, iterator_taskk : generic_task_iterator;
      iterator_group : task_groups_iterator;
      taskj, taskk : generic_task_ptr;
      transt : generic_task_group_ptr;
      wis, wisn, ci, bi, ai, ij, ht, hta, max_wis, wt, oi, ji : Double;
      oj, jj, tj, cj, aj, ok, jk, ck, tk, tmp_wis, tmp_wisa   : Double;
   begin
      ci := Double (current_task.capacity);
      bi := Double (current_task.blocking_time);
      ai :=
        Double'floor
          (s / Double (transaction_task_group_ptr (current_group).period));
      oi  := Double (current_task.offsets.entries (0).offset_value);
      ji  := Double (periodic_task_ptr (current_task).jitter);
      wis := ci + ai * ci + bi;
      --WiS := Ci;

      loop

         wisn := ci + ai * ci + bi;

         --Compute Sum Ij
         --
         reset_head_iterator (current_group.task_list, iterator_taskj);

         loop

            -- Selection of the task j
            --
            current_element (current_group.task_list, taskj, iterator_taskj);

            -- Only process task with higher priority
            --
            if (taskj.priority < current_task.priority) then
               oj := Double (taskj.offsets.entries (0).offset_value);
               jj := Double (periodic_task_ptr (taskj).jitter);
               tj :=
                 Double (transaction_task_group_ptr (current_group).period);
               cj := Double (taskj.capacity);

               aj := Double'floor ((s - oi - ji + oj + jj) / tj);

               ij :=
                 Double'ceiling ((wis - s + oi - oj + ji + aj * tj) / tj) * cj;

               wisn := wisn + ij;
            end if;

            exit when is_tail_element
                (current_group.task_list,
                 iterator_taskj);

            next_element (current_group.task_list, iterator_taskj);
         end loop;

         -- Compute Sum Ht
         --

         max_wis := wisn;
         reset_iterator (my_task_groups, iterator_group);

         loop
            -- Selection of a task group
            --
            current_element (my_task_groups, transt, iterator_group);

            -- Don't process the group task i belong to
            -- It is already taken care of with Ij
            if (transt /= current_group) then

               reset_head_iterator (transt.task_list, iterator_taskj);

               loop
                  -- Selection of task j
                  --
                  current_element (transt.task_list, taskj, iterator_taskj);

                  ht       := 0.0;
                  tmp_wis  := wisn;
                  tmp_wisa := wisn;

                  -- Only process tasks with higher priority
                  --
                  if (taskj.priority < current_task.priority) then
                     oj := Double (taskj.offsets.entries (0).offset_value);
                     jj := Double (periodic_task_ptr (taskj).jitter);
                     wt := oj + jj;

                     reset_head_iterator (transt.task_list, iterator_taskk);
                     loop
                        -- Selection of task k
                        --
                        current_element
                          (transt.task_list,
                           taskk,
                           iterator_taskk);

                        ok := Double (taskk.offsets.entries (0).offset_value);
                        jk := Double (periodic_task_ptr (taskk).jitter);
                        ck := Double (taskk.capacity);
                        tk :=
                          Double (transaction_task_group_ptr (transt).period);

                        if (ok + jk >= wt) then
                           ht  := Double'ceiling ((wis + wt - ok) / tk) * ck;
                           hta := 0.0;
                        else
                           hta :=
                             Double'ceiling ((wis + wt - ok - tk) / tk) * ck;
                           ht := 0.0;
                        end if;

                        tmp_wis  := tmp_wis + ht;
                        tmp_wisa := tmp_wisa + hta;

                        exit when is_tail_element
                            (transt.task_list,
                             iterator_taskk);
                        next_element (transt.task_list, iterator_taskk);
                     end loop;

                     if (tmp_wis > max_wis) then
                        max_wis := tmp_wis;
                     end if;

                     if (tmp_wisa > max_wis) then
                        max_wis := tmp_wisa;
                     end if;

                  end if;

                  exit when is_tail_element (transt.task_list, iterator_taskj);
                  next_element (transt.task_list, iterator_taskj);
               end loop;

               wisn := max_wis;

            end if;

            exit when is_last_element (my_task_groups, iterator_group);
            next_element (my_task_groups, iterator_group);
         end loop;

         exit when wis = wisn or wis > max_response_time;

         wis := wisn;

      end loop;

      return wis;
   end audsley_compute_wis_preemptive;

   procedure audsley_compute_offset_response_time
     (my_task_groups : in     task_groups_set;
      processor_name : in     Unbounded_String;
      msg            : in out Unbounded_String;
      response_time  :    out response_time_table)
   is

      tmp                            : generic_task_group;
      iterator_group                 : task_groups_iterator;
      groupi                         : generic_task_group_ptr;
      iterator_taski, iterator_taskj : generic_task_iterator;
      taski, taskj                   : generic_task_ptr;
      i                              : response_time_range := 0;
      ri, wis, s, ji, ti             : Double              := 0.0;
      q                              : Integer;
      q_stop                         : Boolean             := False;

   begin

      initialize (response_time);

      current_processor_name := processor_name;

      -- Set priority according to the scheduler
      -- But there is no scheduler (bottom-up)? Assume the tasks already have
      -- priority assigned to it

      reset_iterator (my_task_groups, iterator_group);

      loop
         current_element (my_task_groups, groupi, iterator_group);

         sort (groupi.task_list, decreasing_priority'access);

         exit when is_last_element (my_task_groups, iterator_group);

         next_element (my_task_groups, iterator_group);

      end loop;

      -- Bibliographical references
      -- Nothing for now

      -- compute response time for each tasks
      --
      reset_iterator (my_task_groups, iterator_group);

      loop

         -- Selection of the current group
         --
         current_element (my_task_groups, groupi, iterator_group);

         reset_head_iterator (groupi.task_list, iterator_taski);

         loop

            -- Selection of the current task (i)
            --
            current_element (groupi.task_list, taski, iterator_taski);

            -- Initialize response time for task i
            --
            response_time.entries (i).data := 0.0;
            response_time.entries (i).item := taski;
            response_time.nb_entries       := response_time.nb_entries + 1;

            --
            ji := Double (periodic_task_ptr (taski).jitter);
            ti := Double (transaction_task_group_ptr (groupi).period);

            -- Find the maximum for Ri in [0..Q]
            --
            q := 0;

            loop
               q_stop := True;

               -- Calculate the significant S
               --
               reset_head_iterator (groupi.task_list, iterator_taskj);

               loop
                  -- Selection of task j
                  --
                  current_element (groupi.task_list, taskj, iterator_taskj);

                  -- only process tasks with higher priority
                  if (taskj.priority <= taski.priority) then

                     -- Compute response time
                     --
                     s := audsley_compute_s (groupi, taski, taskj, q);

                     wis :=
                       audsley_compute_wis_preemptive
                         (my_task_groups,
                          groupi,
                          taski,
                          s);
                     ri := wis + ji - s;

                     if (ri > response_time.entries (i).data) then
                        response_time.entries (i).data := ri;
                     end if;

                     if (ri > ti) then
                        q_stop := False;
                     end if;
                  end if;

                  exit when is_tail_element (groupi.task_list, iterator_taskj);
                  next_element (groupi.task_list, iterator_taskj);
               end loop;

               exit when q_stop;
               q := q + 1;
            end loop;

            i := i + 1;

            exit when is_tail_element (groupi.task_list, iterator_taski);

            next_element (groupi.task_list, iterator_taski);

         end loop;

         exit when is_last_element (my_task_groups, iterator_group);

         next_element (my_task_groups, iterator_group);

      end loop;

   end audsley_compute_offset_response_time;

   function tindell_compute_wiq_preemptive
     (my_task_groups : in task_groups_set;
      current_group  : in generic_task_group_ptr;
      current_task   : in generic_task_ptr;
      q              : in Natural;
      wtg            : in Double) return Double
   is
      wiq, wiqn : Double := 0.0;
      cc,
      bc,
      oc,
      jc,
      oj,
      jj,
      jk,
      ok,
      iit,
      tmp_iit,
      kjt,
      vjt,
      ej,
      cj,
      tj,
      wt,
      tmp_wt                                         : Double;
      iterator_group                                 : task_groups_iterator;
      iterator_taski, iterator_taskj, iterator_taskk : generic_task_iterator;
      transt                                         : generic_task_group_ptr;
      taskj, taskk                                   : generic_task_ptr;
   begin
      cc  := Double (current_task.capacity);
      bc  := Double (current_task.blocking_time);
      oc  := Double (current_task.offsets.entries (0).offset_value);
      jc  := Double (periodic_task_ptr (current_task).jitter);
      wiq := cc;

      loop

         wiqn := bc + Double (q + 1) * cc; -- equation 13

         -- Compute Sum Iit
         --
         reset_iterator (my_task_groups, iterator_group);

         loop
            -- Selection of a task group
            --
            current_element (my_task_groups, transt, iterator_group);

            reset_head_iterator (transt.task_list, iterator_taskj);

            iit := 0.0;

            if (current_group /= transt) then
               tmp_iit := 0.0;

               -- Find Wt that maximalize Iit
               -- See equation 18

               reset_head_iterator (transt.task_list, iterator_taskk);
               loop
                  -- Selection of task k
                  --
                  current_element (transt.task_list, taskk, iterator_taskk);

                  ok := Double (taskk.offsets.entries (0).offset_value);
                  jk := Double (periodic_task_ptr (taskk).jitter);

                  tmp_wt  := ok + jk;
                  tmp_iit := 0.0;

                  --calculate Iit, see equation 8

                  reset_head_iterator (transt.task_list, iterator_taskj);
                  loop
                     -- Selection of task j
                     --
                     current_element (transt.task_list, taskj, iterator_taskj);

                     -- only process task with higher priority
                     if (current_task.priority >= taskj.priority) then

                        oj := Double (taskj.offsets.entries (0).offset_value);
                        jj := Double (periodic_task_ptr (taskj).jitter);
                        cj := Double (taskj.capacity);
                        tj :=
                          Double (transaction_task_group_ptr (transt).period);
                        ej := Double (periodic_task_ptr (taskj).every);

                        vjt := Double'ceiling ((tmp_wt - oj - jj) / tj);

                        kjt :=
                          Double'ceiling
                            ((tmp_wt + wiq - oj - vjt * tj) / (ej * tj));

                        tmp_iit := tmp_iit + kjt * cj;

                     end if;

                     exit when is_tail_element
                         (transt.task_list,
                          iterator_taskj);
                     next_element (transt.task_list, iterator_taskj);
                  end loop;

                  if (tmp_iit > iit) then
                     iit := tmp_iit;
                     wt  := tmp_wt;
                  end if;

                  exit when is_tail_element (transt.task_list, iterator_taskk);
                  next_element (transt.task_list, iterator_taskk);
               end loop;

            else
               wt := wtg;
               loop
                  -- Selection of task j
                  --
                  current_element (transt.task_list, taskj, iterator_taskj);

                  -- Only process tasks with higher priority
                  --
                  if (taskj.priority < current_task.priority) then

                     --calculate Iit, see equation 8

                     oj := Double (taskj.offsets.entries (0).offset_value);
                     jj := Double (periodic_task_ptr (taskj).jitter);
                     cj := Double (taskj.capacity);
                     tj := Double (transaction_task_group_ptr (transt).period);
                     ej := Double (periodic_task_ptr (taskj).every);

                     vjt := Double'ceiling ((wt - oj - jj) / tj);

                     kjt :=
                       Double'ceiling ((wt + wiq - oj - vjt * tj) / (ej * tj));

                     iit := iit + kjt * cj;

                  end if;

                  exit when is_tail_element (transt.task_list, iterator_taskj);
                  next_element (transt.task_list, iterator_taskj);
               end loop;
            end if;

            wiqn := wiqn + iit;

            exit when is_last_element (my_task_groups, iterator_group);
            next_element (my_task_groups, iterator_group);
         end loop;

         exit when wiq = wiqn or wiqn > max_response_time;
         wiq := wiqn;
      end loop;

      if (wiqn > max_response_time) then
         wiq := max_response_time;
      end if;

      return wiq;
   end tindell_compute_wiq_preemptive;

   procedure tindell_compute_offset_response_time --tractable
     (my_task_groups : in     task_groups_set;
      processor_name : in     Unbounded_String;
      msg            : in out Unbounded_String;
      response_time  :    out response_time_table)
   is
      iterator_group                                 : task_groups_iterator;
      groupi                                         : generic_task_group_ptr;
      iterator_taski, iterator_taskj                 : generic_task_iterator;
      taski, taskj                                   : generic_task_ptr;
      i : response_time_range := 0;
      ri, wiq, viti, ji, tti, oi, oj, jj, ei, wt, kj : Double := 0.0;
      q                                              : Integer;
      q_stop                                         : Boolean := False;
   begin

      initialize (response_time);

      current_processor_name := processor_name;

      -- Set priority according to the scheduler
      -- But there is no scheduler (bottom-up)? Assume the tasks already have
      -- priority assigned to it

      reset_iterator (my_task_groups, iterator_group);

      loop
         current_element (my_task_groups, groupi, iterator_group);

         sort (groupi.task_list, decreasing_priority'access);

         exit when is_last_element (my_task_groups, iterator_group);

         next_element (my_task_groups, iterator_group);

      end loop;

      -- Bibliographical references
      -- Nothing for now

      -- compute response time for each tasks
      --
      reset_iterator (my_task_groups, iterator_group);

      loop

         -- Selection of the current group
         --
         current_element (my_task_groups, groupi, iterator_group);

         reset_head_iterator (groupi.task_list, iterator_taski);

         loop

            -- Selection of the current task (i)
            --
            current_element (groupi.task_list, taski, iterator_taski);

            -- Initialize response time for task i
            --
            response_time.entries (i).data := 0.0;
            response_time.entries (i).item := taski;
            response_time.nb_entries       := response_time.nb_entries + 1;

            --
            ji  := Double (periodic_task_ptr (taski).jitter);
            oi  := Double (taski.offsets.entries (0).offset_value);
            ei  := Double (periodic_task_ptr (taski).every);
            tti := Double (transaction_task_group_ptr (groupi).period);

            -- Tractable analysis: find the maximum for Ri in [0..Q]
            --
            q := 0;

            loop
               q_stop := True;

               reset_head_iterator (groupi.task_list, iterator_taskj);

               loop
                  -- Selection of task j
                  --
                  current_element (groupi.task_list, taskj, iterator_taskj);

                  -- Compute response time
                  --
                  wt :=
                    Double
                      (taskj.offsets.entries (0).offset_value +
                       periodic_task_ptr (taskj).jitter);
                  viti := Double'ceiling ((wt - oi - ji) / tti);

                  wiq :=
                    tindell_compute_wiq_preemptive
                      (my_task_groups,
                       groupi,
                       taski,
                       q,
                       wt);
                  ri := wiq + wt - tti * (Double (q) * ei + viti) - oi;

                  if (wiq = max_response_time) then
                     Put ("The task");
                     Put (Natural'image (Natural (taski.priority)));
                     Put
                       (" can't be scheduled: Wiq exceeded Max_Response_time value");
                     exit;
                  end if;

                  if (ri > response_time.entries (i).data) then
                     response_time.entries (i).data := ri;
                  end if;

                  -- stop condition - see equation (20)
                  if (wiq + wt > tti * (Double (q + 1) * ei + viti) + oi) then
                     q_stop := False;
                  end if;

                  exit when is_tail_element (groupi.task_list, iterator_taskj);
                  next_element (groupi.task_list, iterator_taskj);
               end loop;

               exit when q_stop;
               q := q + 1;
            end loop;

            i := i + 1;

            exit when is_tail_element (groupi.task_list, iterator_taski);

            next_element (groupi.task_list, iterator_taski);

         end loop;

         exit when is_last_element (my_task_groups, iterator_group);

         next_element (my_task_groups, iterator_group);

      end loop;
   end tindell_compute_offset_response_time;

   function palencia_phi
     (groupi  : generic_task_group_ptr;
      task_ab : generic_task_ptr;
      task_ac : generic_task_ptr) return Double
   is
      ta, sphi_ab, sphi_ac, jac : Natural;
   begin
      ta      := transaction_task_group_ptr (groupi).period;
      sphi_ab := task_ab.offsets.entries (0).offset_value mod ta;
      sphi_ac := task_ac.offsets.entries (0).offset_value mod ta;
      jac     := periodic_task_ptr (task_ac).jitter;

      return Double (ta - (sphi_ac + jac - sphi_ab) mod ta);
   end palencia_phi;

   function palencia_w_ik
     (group_i : generic_task_group_ptr;
      task_ab : generic_task_ptr;
      task_ik : generic_task_ptr;
      t       : Double) return Double
   is
      iterator_task_ij            : generic_task_iterator;
      task_ij                     : generic_task_ptr;
      w_ik, jij, ti, phi_ijk, cij : Double := 0.0;
   begin

      -- Loop & evaluate all task ij of higher priority than task ab
      --
      reset_head_iterator (group_i.task_list, iterator_task_ij);

      loop

         -- Selection of task ij
         current_element (group_i.task_list, task_ij, iterator_task_ij);

         cij := Double (task_ij.capacity);
         jij := Double (periodic_task_ptr (task_ij).jitter);
         ti  := Double (transaction_task_group_ptr (group_i).period);

         if (task_ij.priority > task_ab.priority) then

            phi_ijk := palencia_phi (group_i, task_ij, task_ik);

            w_ik :=
              w_ik +
              (Double'floor ((jij + phi_ijk) / ti) +
                 Double'ceiling ((t - phi_ijk) / ti)) *
                cij;

         end if;

         exit when is_tail_element (group_i.task_list, iterator_task_ij);

         next_element (group_i.task_list, iterator_task_ij);

      end loop;

      return w_ik;
   end palencia_w_ik;

   function palencia_labc
     (my_task_groups : task_groups_set;
      group_a        : generic_task_group_ptr;
      task_ab        : generic_task_ptr;
      task_ac        : generic_task_ptr;
      p0             : Double;
      phi_abc        : Double) return Double
   is
      l_abc, l_abcn, w_ac, w_i, w_ik, bab, cab, sum_wi, ta : Double := 0.0;
      iterator_group : task_groups_iterator;
      group_i : generic_task_group_ptr;
      iterator_task_ik : generic_task_iterator;
      task_ik                                              : generic_task_ptr;
      c                                                    : Character;
   begin
      bab   := Double (task_ab.blocking_time);
      cab   := Double (task_ab.capacity);
      ta    := Double (transaction_task_group_ptr (group_a).period);
      l_abc := 0.0;

      loop
         w_ik := palencia_w_ik (group_a, task_ab, task_ac, l_abc);
         Put_Line ("");
         Put ("W_ac");
         Put (Double'image (w_ik));
         l_abcn :=
           bab +
           (Double'ceiling ((l_abc - phi_abc) / ta) - p0 + 1.0) * cab +
           palencia_w_ik (group_a, task_ab, task_ac, l_abc);

         -- Loop & calculate  Wi* for all group i <> group a
         --
         reset_iterator (my_task_groups, iterator_group);
         loop
            current_element (my_task_groups, group_i, iterator_group);

            if (group_i /= group_a) then
            -- Find all task k of higher priority than task ab & calculate W_ik
               reset_head_iterator (group_i.task_list, iterator_task_ik);
               w_i := 0.0;

               loop
                  current_element
                    (group_i.task_list,
                     task_ik,
                     iterator_task_ik);

                  if (task_ik.priority <= task_ab.priority) then

                     w_ik := palencia_w_ik (group_i, task_ab, task_ik, l_abc);

                     if (w_ik > w_i) then

                        w_i := w_ik;

                     end if;

                  end if;

                  exit when is_tail_element
                      (group_i.task_list,
                       iterator_task_ik);

                  next_element (group_i.task_list, iterator_task_ik);

               end loop;

               l_abcn := l_abcn + w_i;

            end if;

            exit when is_last_element (my_task_groups, iterator_group);

            next_element (my_task_groups, iterator_group);

         end loop;

         exit when l_abcn = l_abc or l_abcn > max_response_time;

         Put ("vai ca sida L_abc:");
         Put (Double'image (l_abc));
         Put ("L_abcn:");
         Put (Double'image (l_abcn));
         Get_Immediate (c);
         l_abc := l_abcn;

      end loop;

      return l_abc;

   end palencia_labc;

   function palencia_w_abc
     (my_task_groups : task_groups_set;
      group_a        : generic_task_group_ptr;
      task_ab        : generic_task_ptr;
      task_ac        : generic_task_ptr;
      p              : Double;
      p0             : Double) return Double
   is
      iterator_group                          : task_groups_iterator;
      iterator_task_ik                        : generic_task_iterator;
      task_ik                                 : generic_task_ptr;
      group_i                                 : generic_task_group_ptr;
      bab, cab, w_abc, w_abcn, wac, w_ik, w_i : Double := 0.0;
   begin
      bab := Double (task_ab.blocking_time);
      cab := Double (task_ab.capacity);

      w_abc := 0.0;

      loop

         w_abcn :=
           bab +
           (p - p0 + 1.0) * cab +
           palencia_w_ik (group_a, task_ab, task_ac, w_abc);

         -- Iterate & calculate W_i* - see equation 27
         reset_iterator (my_task_groups, iterator_group);
         loop
            -- Selection of group i
            --
            current_element (my_task_groups, group_i, iterator_group);

            -- Only process group different from Group a

            if (group_i /= group_a) then

               -- Calculate W_i* by selecting the maximum W_ik
               -- See equation 27
               --
               w_i := 0.0;
               reset_head_iterator (group_i.task_list, iterator_task_ik);

               loop

                  current_element
                    (group_i.task_list,
                     task_ik,
                     iterator_task_ik);

                  -- Only process tasks with higher priority than task ab
                  --
                  if (task_ik.priority <= task_ab.priority) then

                     w_ik := palencia_w_ik (group_i, task_ab, task_ik, w_abc);

                     if (w_ik > w_i) then

                        w_i := w_ik;

                     end if;

                  end if;

                  exit when is_tail_element
                      (group_i.task_list,
                       iterator_task_ik);

                  next_element (group_i.task_list, iterator_task_ik);

               end loop;

               w_abcn := w_abcn + w_i;

            end if;

            exit when is_last_element (my_task_groups, iterator_group);

            next_element (my_task_groups, iterator_group);

         end loop;

         exit when w_abc = w_abcn or w_abcn > max_response_time;

         w_abc := w_abcn;

      end loop;

      return w_abc;
   end palencia_w_abc;

   procedure palencia_compute_offset_response_time --exact first, tractable later?
     (my_task_groups : in     task_groups_set;
      processor_name : in     Unbounded_String;
      msg            : in out Unbounded_String;
      response_time  :    out response_time_table)
   is
      iterator_group                     : task_groups_iterator;
      group_a                            : generic_task_group_ptr;
      iterator_task_ab, iterator_task_ac : generic_task_iterator;
      task_ab, task_ac                   : generic_task_ptr;
      i                                  : response_time_range := 0;
      rab,
      labc,
      p0abc,
      plabc,
      phi_abc,
      jab,
      ta,
      oab,
      oac,
      jac,
      p : Double :=
        0.0;
   begin
      initialize (response_time);

      current_processor_name := processor_name;

      --task model in Palencia is a little different:
      --T_ab = a task in transaction a, which is indexed with b while ordered by increasing offset
      --should the tasks be sorted in increasing offset value?
      reset_iterator (my_task_groups, iterator_group);

      loop
         current_element (my_task_groups, group_a, iterator_group);

         sort (group_a.task_list, decreasing_priority'access);

         exit when is_last_element (my_task_groups, iterator_group);

         next_element (my_task_groups, iterator_group);

      end loop;

      -- compute response time for each tasks
      --
      reset_iterator (my_task_groups, iterator_group);

      loop

         -- Selection of the current group
         --
         current_element (my_task_groups, group_a, iterator_group);

         reset_head_iterator (group_a.task_list, iterator_task_ab);

         loop

            -- Selection of the current task (T_ab)
            --
            current_element (group_a.task_list, task_ab, iterator_task_ab);

            -- Initialize response time for task ab
            --
            response_time.entries (i).data := 0.0;
            response_time.entries (i).item := task_ab;
            response_time.nb_entries       := response_time.nb_entries + 1;

            jab := Double (periodic_task_ptr (task_ab).jitter);
            oab := Double (task_ab.offsets.entries (0).offset_value);
            ta  := Double (transaction_task_group_ptr (group_a).period);

            reset_head_iterator (group_a.task_list, iterator_task_ac);

            loop
               -- Selection of Task_ac
               --
               current_element (group_a.task_list, task_ac, iterator_task_ac);

               if (task_ac.priority <= task_ab.priority) then

                  -- The first activation #
                  -- Note that it can be a negative value!
                  -- See equation 29
                  p0abc := -Double'floor ((jab + phi_abc) / ta) + 1.0;

                  phi_abc := palencia_phi (group_a, task_ab, task_ac);

         -- Calculation of the length of the busy period started with Task_ac
         -- See equation 30
                  Put_Line ("");
                  Put ("sida...");
                  Put (Natural'image (Natural (task_ac.priority)));
                  Put ("  phi_abc=");
                  Put (Double'image (phi_abc));
                  Put (" P0abc=");
                  Put_Line (Double'image (p0abc));
                  labc :=
                    palencia_labc
                      (my_task_groups,
                       group_a,
                       task_ab,
                       task_ac,
                       p0abc,
                       phi_abc);

                  Put (" Labc = ");
                  Put_Line (Double'image (labc));

      -- From the Labc, calculate the maximum number of jobs need to be checked
      -- See equation 31
                  plabc := Double'ceiling ((labc - phi_abc / ta));

                  -- Find the maximum Rabc from all jobs p
                  p := p0abc;

                  plabc := plabc + p; --for counting

                  loop

                     -- Find the maximum of all Rabc(p)
                     -- see equation 32 - 33
                     rab :=
                       palencia_w_abc
                         (my_task_groups,
                          group_a,
                          task_ab,
                          task_ac,
                          p,
                          p0abc) -
                       phi_abc -
                       p -
                       1.0 * ta +
                       oab;

                     if (rab > response_time.entries (i).data) then
                        response_time.entries (i).data := rab;
                     end if;

                     exit when p >= plabc;
                     p := p + 1.0;
                  end loop;

               end if;

               exit when is_tail_element (group_a.task_list, iterator_task_ac);

               next_element (group_a.task_list, iterator_task_ac);
            end loop;

            exit when is_tail_element (group_a.task_list, iterator_task_ab);

            next_element (group_a.task_list, iterator_task_ab);

            i := i + 1;

         end loop;

         exit when is_last_element (my_task_groups, iterator_group);

         next_element (my_task_groups, iterator_group);

      end loop;
   end palencia_compute_offset_response_time;

   procedure wcdops_plus
     (my_system               : in out system;
      msg                     : in out Unbounded_String;
      response_times          : in out response_time_table;
      stop_on_deadline_missed : in     Boolean := False)
   is
      -- Local exceptions --
      generic_wcdops_plus_exception : exception;
      deadline_missed_exception : exception;

      -- Local functions --

      function max (x, y : Integer) return Integer is
      begin
         if x < y then
            return y;
         else
            return x;
         end if;
      end max;

      function min (x, y : Integer) return Integer is
      begin
         if x < y then
            return x;
         else
            return y;
         end if;
      end min;

      function modulus (x, y : Integer) return Integer is
      begin
         return x - Integer (Double'floor (Double (x) / Double (y))) * y;
      end modulus;

      function ceil0 (x : Double) return Integer is
      begin
         if x < 0.0 then
            return 0;
         else
            return Integer (Double'ceiling (x));
         end if;
      end ceil0;

      function get_offset (tau : generic_task_ptr) return Integer is
         new_offset : offset_type_ptr;

         use Offsets.Offsets_Table_Package;
      begin
         if tau.offsets.nb_entries > 0 then
            for i in 0 .. tau.offsets.nb_entries - 1 loop
               if tau.offsets.entries (i).activation = 0 then
                  return tau.offsets.entries (i).offset_value;
               end if;
            end loop;
         end if;

         new_offset              := new offset_type;
         new_offset.offset_value := 0;
         new_offset.activation   := 0;
         add (tau.offsets, new_offset.all);

         return 0;
      end get_offset;

      function get_global_deadline (tau : generic_task_ptr) return Integer is
      begin
         return tau.deadline + get_offset (tau);
      end get_global_deadline;

      procedure init_response_times
        (response_times : out response_time_table)
      is
         gamma_iterator : task_groups_iterator;
         gamma          : generic_task_group_ptr;
         tau_iterator   : generic_task_iterator;
         tau            : generic_task_ptr;

         i : Integer := 0;
      begin

         if not is_empty (my_system.task_groups) then
            initialize (response_times);

            reset_iterator (my_system.task_groups, gamma_iterator);
            loop
               current_element (my_system.task_groups, gamma, gamma_iterator);

               if not is_empty (gamma.task_list) then
                  reset_head_iterator (gamma.task_list, tau_iterator);
                  loop
                     current_element (gamma.task_list, tau, tau_iterator);

                     response_times.entries (response_times.nb_entries).data :=
                       Double (get_offset (tau) + tau.capacity);
                     response_times.entries (response_times.nb_entries).item :=
                       tau;
                     response_times.nb_entries :=
                       response_times.nb_entries + 1;

                     exit when is_tail_element (gamma.task_list, tau_iterator);
                     next_element (gamma.task_list, tau_iterator);
                  end loop;
               end if;

               exit when is_last_element
                   (my_system.task_groups,
                    gamma_iterator);
               next_element (my_system.task_groups, gamma_iterator);
            end loop;
         end if;
      end init_response_times;

      procedure set_response (tau : generic_task_ptr; time : Integer) is
      begin
         if response_times.nb_entries > 0 then
            for i in 0 .. response_times.nb_entries - 1 loop
               if response_times.entries (i).item.name = tau.name then
                  response_times.entries (i).data := Double (time) + 0.0;
                  return;
               end if;
            end loop;
         end if;
      end set_response;

      function get_response (tau : generic_task_ptr) return Integer is
      begin
         if response_times.nb_entries > 0 then
            for i in 0 .. response_times.nb_entries - 1 loop
               if response_times.entries (i).item.name = tau.name then
                  return Integer (response_times.entries (i).data);
               end if;
            end loop;
         end if;

         raise generic_wcdops_plus_exception;

         return 0;
      end get_response;

-- No multi-predecessor version; Otherwise should return a set of predecessors
      function pred (tau_ij : generic_task_ptr) return generic_task_ptr is
         pred_ij : generic_task_ptr;

         a_task_dependencies_iterator : tasks_dependencies_iterator;
         a_half_dep                   : dependency_ptr;
      begin
         if not is_empty (my_system.dependencies.depends) then
            reset_iterator
              (my_system.dependencies.depends,
               a_task_dependencies_iterator);
            loop
               current_element
                 (my_system.dependencies.depends,
                  a_half_dep,
                  a_task_dependencies_iterator);

               if a_half_dep.type_of_dependency = precedence_dependency then
                  if a_half_dep.precedence_sink.name = tau_ij.name then
                     pred_ij := a_half_dep.precedence_source;
                     return pred_ij;
                  end if;
               end if;

               exit when is_last_element
                   (my_system.dependencies.depends,
                    a_task_dependencies_iterator);
               next_element
                 (my_system.dependencies.depends,
                  a_task_dependencies_iterator);
            end loop;
         end if;

         return null;
      end pred;

      function get_root_task
        (gamma_i : generic_task_group_ptr) return generic_task_ptr
      is
         tau_ij_iterator : generic_task_iterator;
         tau_ij          : generic_task_ptr;
         pred_ij         : generic_task_ptr;
      begin
         if not is_empty (gamma_i.task_list) then
            reset_head_iterator (gamma_i.task_list, tau_ij_iterator);
            loop
               current_element (gamma_i.task_list, tau_ij, tau_ij_iterator);

               pred_ij := pred (tau_ij);

               if pred_ij = null then
                  return tau_ij;
               end if;

               exit when is_tail_element (gamma_i.task_list, tau_ij_iterator);
               next_element (gamma_i.task_list, tau_ij_iterator);
            end loop;
         end if;

         raise generic_wcdops_plus_exception;

         -- Should never reach
         return null;
      end get_root_task;

      -- Returns true if tau_ip precedes tau_ij (not necessarily immediately)
      function precedes
        (tau_ip : generic_task_ptr;
         tau_ij : generic_task_ptr) return Boolean
      is
         pred_ij : generic_task_ptr;
      begin
         pred_ij := pred (tau_ij);

         if pred_ij = null then
            return False;
         elsif pred_ij.name = tau_ip.name then
            return True;
         else
            return precedes (tau_ip, pred_ij);
         end if;
      end precedes;

      function succ (tau_ij : generic_task_ptr) return tasks_set_ptr is
         succ_ij : tasks_set_ptr;

         a_task_dependencies_iterator : tasks_dependencies_iterator;
         a_half_dep                   : dependency_ptr;
      begin
         succ_ij := new tasks_set;

         if not is_empty (my_system.dependencies.depends) then
            reset_iterator
              (my_system.dependencies.depends,
               a_task_dependencies_iterator);
            loop
               current_element
                 (my_system.dependencies.depends,
                  a_half_dep,
                  a_task_dependencies_iterator);

               if a_half_dep.type_of_dependency = precedence_dependency then
                  if a_half_dep.precedence_source.name = tau_ij.name then
                     add (succ_ij.all, a_half_dep.precedence_sink);
                  end if;
               end if;

               exit when is_last_element
                   (my_system.dependencies.depends,
                    a_task_dependencies_iterator);
               next_element
                 (my_system.dependencies.depends,
                  a_task_dependencies_iterator);
            end loop;
         end if;

         return succ_ij;
      end succ;

      -- Returns true if tau_ij in hpi(tau_ab) (tasks in Gamma_i of higher priority than tau_ab and on same cpu)
      function in_hpi
        (tau_ij : generic_task_ptr;
         tau_ab : generic_task_ptr) return Boolean
      is
      begin
         if tau_ij = null then
            raise generic_wcdops_plus_exception;
         end if;

         return tau_ij.priority >= tau_ab.priority and
           tau_ij.cpu_name = tau_ab.cpu_name;
      end in_hpi;

      -- Returns true if tau_ij in lpi(tau_ab) (tasks in Gamma_i of lower priority than tau_ab and on same cpu)
      function in_lpi
        (tau_ij : generic_task_ptr;
         tau_ab : generic_task_ptr) return Boolean
      is
      begin
         if tau_ij = null then
            raise generic_wcdops_plus_exception;
         end if;

         return tau_ij.priority < tau_ab.priority and
           tau_ij.cpu_name = tau_ab.cpu_name;
      end in_lpi;

      function has_pred_in_lpi
        (tau_ij : generic_task_ptr;
         tau_ab : generic_task_ptr) return Boolean
      is
         pred_ij : generic_task_ptr;
      begin
         pred_ij := pred (tau_ij);

         if pred_ij = null then
            return False;
         elsif in_lpi (pred_ij, tau_ab) then
            return True;
         else
            return has_pred_in_lpi (pred_ij, tau_ab);
         end if;
      end has_pred_in_lpi;

      -- Returns true if tau_ij in hpi(tau_ab) (tasks in Gamma_i of higher priority than tau_ab and on same cpu)
      function in_mpi
        (tau_ij : generic_task_ptr;
         tau_ab : generic_task_ptr) return Boolean
      is
      begin
         if (not in_hpi (tau_ij, tau_ab))
           or else (has_pred_in_lpi (tau_ij, tau_ab))
         then
            return False;
         end if;

         return True;
      end in_mpi;

      -- Returns set of tasks in Gamma_i that are in hpi(tau_ab) but for which the predecessor is not in hpi(tau_ab)
      function xp
        (gamma_i : generic_task_group_ptr;
         tau_ab  : generic_task_ptr) return tasks_set_ptr
      is
         xp_i : tasks_set_ptr;

         tau_if_iterator : generic_task_iterator;
         tau_if          : generic_task_ptr;
         pred_if         : generic_task_ptr;
      begin
         xp_i := new tasks_set;

         -- For each task in Gamma_i, if task in hpi(tau_ab) and pred(task) not in hpi then add to XP_i
         if not is_empty (gamma_i.task_list) then
            reset_head_iterator (gamma_i.task_list, tau_if_iterator);
            loop
               current_element (gamma_i.task_list, tau_if, tau_if_iterator);

               if in_hpi (tau_if, tau_ab) then
                  pred_if := pred (tau_if);

                  if pred_if = null or else not in_hpi (pred_if, tau_ab) then
                     add (xp_i.all, tau_if);
                  end if;
               end if;

               exit when is_tail_element (gamma_i.task_list, tau_if_iterator);
               next_element (gamma_i.task_list, tau_if_iterator);
            end loop;
         end if;

         return xp_i;
      end xp;

      -- Returns the first task tau_if in tau_ij's segment accroding to tau_ab's priority and cpu
      -- Recursive function that does not work in multiple predecessors case (like Pred function)
      function first_task_in_hseg
        (tau_ij : generic_task_ptr;
         tau_ab : generic_task_ptr) return generic_task_ptr
      is
         pred_ij : generic_task_ptr;
      begin
         if not in_hpi (tau_ij, tau_ab) then
            raise generic_wcdops_plus_exception;
         end if;

         pred_ij := pred (tau_ij);

         -- First condition should never be true if we add a ghost root task
         if pred_ij = null or else not in_hpi (pred_ij, tau_ab) then
            return tau_ij;
         else
            return first_task_in_hseg (pred_ij, tau_ab);
         end if;
      end first_task_in_hseg;

      function get_first_task_in_hseg_n
        (gamma_i : generic_task_group_ptr;
         tau_ab  : generic_task_ptr) return generic_task_ptr
      is
         xp_i : tasks_set_ptr;

         tau_if_iterator : tasks_iterator;
         tau_if          : generic_task_ptr;
         h_seg_in        : generic_task_ptr;
         o_if            : Integer;
         j_if            : Integer;
         max_oj          : Integer := 0;
      begin
         -- Get XPi set (first tasks in their respective segment) and loop through to find the one with the greatest O + J
         -- If several have the same O + J, it doesn't matter because it's the "O + J" value that interest us in fact (after this function returns), not the task.
         xp_i := xp (gamma_i, tau_ab);

         if not is_empty (xp_i.all) then
            reset_iterator (xp_i.all, tau_if_iterator);
            loop
               current_element (xp_i.all, tau_if, tau_if_iterator);

               if tau_if.task_type /= periodic_type then
                  raise generic_wcdops_plus_exception;
               end if;

               o_if := get_offset (tau_if);
               j_if := periodic_task_ptr (tau_if).jitter;

               if o_if + j_if >= max_oj then
                  h_seg_in := tau_if;
                  max_oj   := o_if + j_if;
               end if;

               exit when is_last_element (xp_i.all, tau_if_iterator);
               next_element (xp_i.all, tau_if_iterator);
            end loop;
         end if;

         free_container (xp_i.all);
         free (xp_i, False);

         return h_seg_in;
      end get_first_task_in_hseg_n;

      function same_hsec
        (task1  : generic_task_ptr;
         task2  : generic_task_ptr;
         tau_ab : generic_task_ptr) return Boolean
      is
         pred1 : generic_task_ptr;
         pred2 : generic_task_ptr;
      begin
         pred1 := pred (task1);
         while pred1 /= null and then not in_lpi (pred1, tau_ab) loop
            pred1 := pred (pred1);
         end loop;

         pred2 := pred (task2);
         while pred2 /= null and then not in_lpi (pred2, tau_ab) loop
            pred2 := pred (pred2);
         end loop;

         if pred1 /= null and pred2 /= null then
            if pred1.name = pred2.name then
               return True;
            end if;
         elsif pred1 = null and pred2 = null then
            return True;
         end if;

         return False;
      end same_hsec;

      function same_hseg
        (task1  : generic_task_ptr;
         task2  : generic_task_ptr;
         tau_ab : generic_task_ptr) return Boolean
      is
         h_seg_task1      : generic_task_ptr;
         h_seg_task2      : generic_task_ptr;
         pred_h_seg_task1 : generic_task_ptr;
         pred_h_seg_task2 : generic_task_ptr;
      begin
         h_seg_task1      := first_task_in_hseg (task1, tau_ab);
         pred_h_seg_task1 := pred (h_seg_task1);

         h_seg_task2      := first_task_in_hseg (task2, tau_ab);
         pred_h_seg_task2 := pred (h_seg_task2);

         if pred_h_seg_task1 /= null and pred_h_seg_task2 /= null then
            return pred_h_seg_task1.name = pred_h_seg_task2.name;
         elsif pred_h_seg_task1 = null and pred_h_seg_task2 = null then
            return True;
         end if;

         return False;
      end same_hseg;

      -- Returns true if H_seg_ip precedes tau_ij
      function seg_precedes
        (tau_ip : generic_task_ptr;
         tau_ij : generic_task_ptr;
         tau_ab : generic_task_ptr) return Boolean
      is
         h_seg_ip      : generic_task_ptr;
         pred_h_seg_ip : generic_task_ptr;
      begin
         h_seg_ip      := first_task_in_hseg (tau_ip, tau_ab);
         pred_h_seg_ip := pred (h_seg_ip);

         return not same_hseg (tau_ip, tau_ij, tau_ab)
           and then
           (pred_h_seg_ip = null or else precedes (pred_h_seg_ip, tau_ij));
      end seg_precedes;

      -- varphi_ijk
      function varphi
        (tau_ij : generic_task_ptr;
         tau_ik : generic_task_ptr) return Integer
      is
         t_i  : Integer;
         o_ij : Integer;
         o_ik : Integer;
         j_ik : Integer;
      begin
         if tau_ij.task_type /= periodic_type or
           tau_ik.task_type /= periodic_type
         then
            raise generic_wcdops_plus_exception;
         end if;

         t_i  := periodic_task_ptr (tau_ik).period;
         o_ij := get_offset (tau_ij);
         o_ik := get_offset (tau_ik);
         j_ik := periodic_task_ptr (tau_ik).jitter;

         return t_i + o_ij - modulus (o_ik + j_ik, t_i);
      end varphi;

      function varphi_seg
        (tau_ij : generic_task_ptr;
         tau_ik : generic_task_ptr;
         tau_ab : generic_task_ptr) return Integer
      is
      begin
         if not in_hpi (tau_ij, tau_ab) then
            raise generic_wcdops_plus_exception;
         end if;

         return varphi (first_task_in_hseg (tau_ij, tau_ab), tau_ik);
      end varphi_seg;

      function p0
        (tau_ij : generic_task_ptr;
         tau_ik : generic_task_ptr) return Integer
      is
         varphi_ijk : Integer;
         j_ij       : Integer;
         t_i        : Integer;
      begin
         if tau_ij.task_type /= periodic_type or
           tau_ik.task_type /= periodic_type
         then
            raise generic_wcdops_plus_exception;
         end if;

         j_ij       := periodic_task_ptr (tau_ij).jitter;
         t_i        := periodic_task_ptr (tau_ik).period;
         varphi_ijk := varphi (tau_ij, tau_ik);

         return Integer
             (1.0 - Double'floor (Double (j_ij + varphi_ijk) / Double (t_i)));
      end p0;

      -- p0 of first task in tau_ij's segment when tau_ik starts the BP
      function p0_seg
        (tau_ij : generic_task_ptr;
         tau_ik : generic_task_ptr;
         tau_ab : generic_task_ptr) return Integer
      is
      begin
         return p0 (first_task_in_hseg (tau_ij, tau_ab), tau_ik);
      end p0_seg;

      function taskinterference
        (tau_ab : generic_task_ptr;
         tau_ik : generic_task_ptr;
         tau_ij : generic_task_ptr;
         w      : Integer;
         p      : Integer;
         tau_ac : generic_task_ptr) return Integer
      is
         taski : Integer := 0;

         p_seg_0ijk     : Integer;
         p_seg_0ikk     : Integer;
         varphi_seg_ijk : Integer;
         t_i            : Integer;
         c_ij           : Integer;

         h_seg_ik      : generic_task_ptr;
         h_seg_ij      : generic_task_ptr;
         h_seg_ab      : generic_task_ptr;
         h_seg_ac      : generic_task_ptr;
         pred_h_seg_ik : generic_task_ptr;
         pred_h_seg_ij : generic_task_ptr;
         pred_h_seg_ab : generic_task_ptr;
         pred_h_seg_ac : generic_task_ptr;
      begin
         if tau_ij.task_type /= periodic_type then
            raise generic_wcdops_plus_exception;
         end if;

         p_seg_0ijk     := p0_seg (tau_ij, tau_ik, tau_ab);
         varphi_seg_ijk :=
           varphi_seg
             (tau_ij,
              tau_ik,
              tau_ab);-- XP_a shouldn't be empty because at least tau_ab is in XP_a(tau_ab)
         t_i  := periodic_task_ptr (tau_ij).period;
         c_ij := tau_ij.capacity;

         if p >= p_seg_0ijk and w > varphi_seg_ijk + (p - 1) * t_i then
            taski := c_ij;

            p_seg_0ikk    := p0_seg (tau_ik, tau_ik, tau_ab);
            h_seg_ik      := first_task_in_hseg (tau_ik, tau_ab);
            h_seg_ij      := first_task_in_hseg (tau_ij, tau_ab);
            h_seg_ab      := first_task_in_hseg (tau_ab, tau_ab);
            h_seg_ac      := first_task_in_hseg (tau_ac, tau_ab);
            pred_h_seg_ik := pred (h_seg_ik);
            pred_h_seg_ij := pred (h_seg_ij);
            pred_h_seg_ab := pred (h_seg_ab);
            pred_h_seg_ac := pred (h_seg_ac);

            -- Note: Verifying H_segs are not null is important since tau_i0 ghost is added only to Gamma_a
            -- and this function is also called on Gamma_i transactions
            if
              (p >= p_seg_0ikk
               and then seg_precedes (tau_ik, tau_ij, tau_ab)
               and then not same_hsec (tau_ik, tau_ij, tau_ab)) -- Rule 1a
              or else
              (pred_h_seg_ik /= null
               and then in_lpi (pred_h_seg_ik, tau_ab)
               and then pred_h_seg_ij /= null
               and then in_lpi (pred_h_seg_ij, tau_ab)
               and then
               (p /= p_seg_0ikk
                or else not same_hseg (h_seg_ik, h_seg_ij, tau_ab))) -- Rule 2a
              or else
              (pred_h_seg_ab /= null
               and then in_lpi (pred_h_seg_ab, tau_ab)
               and then pred_h_seg_ij /= null
               and then in_lpi (pred_h_seg_ij, tau_ab)) -- Rule 3a
              or else
              (pred_h_seg_ac /= null
               and then in_lpi (pred_h_seg_ac, tau_ab)
               and then pred_h_seg_ij /= null
               and then in_lpi (pred_h_seg_ij, tau_ab))
            then -- Rule 4a
               taski := 0;
            end if;
         end if;

         return taski;
      end taskinterference;

      procedure compute_sb
        (root   : in     generic_task_ptr;
         tau_im : in     generic_task_ptr;
         tau_ab : in     generic_task_ptr;
         sb     :    out tasks_set)
      is
         pred_im       : generic_task_ptr;
         h_seg_pred_im : generic_task_ptr;
      begin
         pred_im := pred (tau_im);

         if in_hpi (pred_im, tau_ab) then
            h_seg_pred_im := first_task_in_hseg (pred_im, tau_ab);
            pred_im       := pred (h_seg_pred_im);
         end if;

         if pred_im.name = root.name then
            add (sb, tau_im);
         end if;
      end compute_sb;

-- TODO: Comment this because it's different from Redell and a bit complicated.
      procedure compute_sb_sectioni
        (tau_ib   : in     generic_task_ptr;
         root     : in     generic_task_ptr;
         tau_ab   : in     generic_task_ptr;
         tau_ik   : in     generic_task_ptr;
         w        : in     Integer;
         p        : in     Integer;
         tau_ac   : in     generic_task_ptr;
         sb       :    out tasks_set;
         sectioni : in out Integer)
      is
         succ_ib              : tasks_set_ptr;
         tau_im_iterator      : tasks_iterator;
         tau_im               : generic_task_ptr;
         root_preceeds_a_hseg : Boolean := False;
      begin
         succ_ib := succ (tau_ib);

         if not is_empty (succ_ib.all) then

            -- Check that tau_iB actually preceeds a segment
            reset_iterator (succ_ib.all, tau_im_iterator);
            loop
               current_element (succ_ib.all, tau_im, tau_im_iterator);

               if tau_ib.name /= root.name or else in_hpi (tau_im, tau_ab) then
                  root_preceeds_a_hseg := True;
               end if;

               exit when is_last_element (succ_ib.all, tau_im_iterator)
                 or else root_preceeds_a_hseg;
               next_element (succ_ib.all, tau_im_iterator);
            end loop;

            -- Update sectionI and add tasks to SB
            reset_iterator (succ_ib.all, tau_im_iterator);
            loop
               current_element (succ_ib.all, tau_im, tau_im_iterator);

               if in_hpi (tau_im, tau_ab) then
                  sectioni :=
                    sectioni +
                    taskinterference (tau_ab, tau_ik, tau_im, w, p, tau_ac);
                  compute_sb_sectioni
                    (tau_im,
                     root,
                     tau_ab,
                     tau_ik,
                     w,
                     p,
                     tau_ac,
                     sb,
                     sectioni);
               elsif in_lpi (tau_im, tau_ab) then
                  compute_sb (root, tau_im, tau_ab, sb);
               else
                  compute_sb (root, tau_im, tau_ab, sb);

                  -- The recursive algorithm continues on to a branch created with a X tau_im only if tau_iB preceeds a Hseg.
                  -- Otherwise we don't want to add anything after the X tau_im to sectionI, nor any sub-branche starters to SB
                  if root_preceeds_a_hseg then
                     compute_sb_sectioni
                       (tau_im,
                        root,
                        tau_ab,
                        tau_ik,
                        w,
                        p,
                        tau_ac,
                        sb,
                        sectioni);
                  end if;
               end if;

               exit when is_last_element (succ_ib.all, tau_im_iterator);
               next_element (succ_ib.all, tau_im_iterator);
            end loop;
         end if;

         free_container (succ_ib.all);
         free (succ_ib, False);
      end compute_sb_sectioni;

      procedure branchinterference
        (tau_ab      : in     generic_task_ptr;
         tau_ik      : in     generic_task_ptr;
         tau_ib      : in     generic_task_ptr;
         w           : in     Integer;
         p           : in     Integer;
         tau_ac      : in     generic_task_ptr;
         branchi     : in out Integer;
         branchdelta : in out Integer)
      is
         sb       : tasks_set;
         sectioni : Integer := 0;

         tau_is_iterator : tasks_iterator;
         tau_is          : generic_task_ptr;

         bi           : Integer := 0;
         bd           : Integer := 0;
         subbranchesi : Integer := 0;
         subbdelta    : Integer := 0;
      begin
         -- This differs a bit from the way Redell computes sectionI.
         -- We don't use a magical "S set" (i.e. H_im(tau_ab)), but a recursive algorithm.
         -- The recursive algorithm is more optimized for Cheddar ADL than computing H_im(tau_ab).
         compute_sb_sectioni
           (tau_ib,
            tau_ib,
            tau_ab,
            tau_ik,
            w,
            p,
            tau_ac,
            sb,
            sectioni);
         if not is_empty (sb) then
            reset_iterator (sb, tau_is_iterator);
            loop
               current_element (sb, tau_is, tau_is_iterator);

               branchinterference
                 (tau_ab,
                  tau_ik,
                  tau_is,
                  w,
                  p,
                  tau_ac,
                  bi,
                  bd);

               subbranchesi := subbranchesi + bi;
               subbdelta    := max (subbdelta, bd);
               exit when is_last_element (sb, tau_is_iterator);
               next_element (sb, tau_is_iterator);
            end loop;
         end if;

         if in_lpi (tau_ib, tau_ab) then
            branchi     := subbranchesi;
            branchdelta := max (sectioni - subbranchesi, subbdelta);
         else -- X, delta and ghost root cases
            branchi     := max (sectioni, subbranchesi);
            branchdelta := max (subbranchesi + subbdelta - branchi, 0);
         end if;

         -- Free(SB, False);
      end branchinterference;

      procedure transactioninterference
        (tau_ab     : in     generic_task_ptr;
         tau_ik     : in     generic_task_ptr;
         w          : in     Integer;
         tau_ac     : in     generic_task_ptr;
         transi_nob : in out Integer;
         transi_b   : in out Integer)
      is
         p_seg_0ink : Integer;
         jobi       : Integer := 0;
         jobdelta   : Integer := 0;
         transdelta : Integer := 0;

         gamma_i  : generic_task_group_ptr;
         tau_i1   : generic_task_ptr;
         tau_i0   : generic_task_ptr;
         h_seg_in : generic_task_ptr;
      begin
         transi_b   := 0;
         transi_nob := 0;

-- Add ghost root task: placed here for understanding.
-- Can be moved to somewhere earlier for optimization (e.g. Max_WWB function)
         gamma_i := search_task_group_by_task (my_system.task_groups, tau_ik);
         tau_i1  := get_root_task (gamma_i);

         tau_i0          := new generic_task; -- Scheduling_Task?
         tau_i0.name     := To_Unbounded_String ("wcdops+_ghost_root");
         tau_i0.cpu_name := To_Unbounded_String ("wcdops+_ghost_cpu");
         tau_i0.priority := 0;

         --Add(My_System.Tasks, tau_i0);
         add_one_task_dependency_precedence
           (my_system.dependencies,
            tau_i0,
            tau_i1);

         -- Last segment of Gamma_i
         h_seg_in := get_first_task_in_hseg_n (gamma_i, tau_ab);

         if h_seg_in /= null then
            p_seg_0ink := p0_seg (h_seg_in, tau_ik, tau_ab);

            -- Compute transI_NoB, transDelta and transI_B
            for p in p_seg_0ink .. 0 loop
               branchinterference
                 (tau_ab,
                  tau_ik,
                  tau_i0,
                  w,
                  p,
                  tau_ac,
                  jobi,
                  jobdelta);
               transi_nob := transi_nob + jobi;
               transdelta := max (transdelta, jobdelta);
            end loop;

            transi_b := transi_nob + transdelta;
         end if;

         -- Free tau_i0
         delete_one_task_dependency_precedence
           (my_system.dependencies,
            tau_i0,
            tau_i1);
         Free (tau_i0);
      end transactioninterference;

      function w_mp
        (tau_ik : generic_task_ptr;
         tau_ab : generic_task_ptr;
         w      : Integer) return Integer
      is
         gamma_i         : generic_task_group_ptr;
         tau_ij_iterator : generic_task_iterator;
         tau_ij          : generic_task_ptr;

         c_ij           : Integer;
         t_i            : Integer;
         w_ik_p         : Integer := 0;
         varphi_seg_ijk : Integer;
      begin
         gamma_i := search_task_group_by_task (my_system.task_groups, tau_ik);

         if not is_empty (gamma_i.task_list) then
            reset_head_iterator (gamma_i.task_list, tau_ij_iterator);
            loop
               current_element (gamma_i.task_list, tau_ij, tau_ij_iterator);

               if in_mpi (tau_ij, tau_ab) then
                  if tau_ij.task_type /= periodic_type then
                     raise generic_wcdops_plus_exception;
                  end if;

                  c_ij           := tau_ij.capacity;
                  t_i            := periodic_task_ptr (tau_ij).period;
                  varphi_seg_ijk := varphi_seg (tau_ij, tau_ik, tau_ab);

                  -- Equation (19)
                  w_ik_p :=
                    w_ik_p +
                    ceil0 (Double (w - varphi_seg_ijk) / Double (t_i)) * c_ij;
               end if;

               exit when is_tail_element (gamma_i.task_list, tau_ij_iterator);
               next_element (gamma_i.task_list, tau_ij_iterator);
            end loop;
         end if;

         return w_ik_p;
      end w_mp;

      -- [Wik(tau_ab, w, tau_ac), WBik(tau_ab, w, tau_ac)] => Equation (20)
      procedure wwb
        (tau_ik : in     generic_task_ptr;
         tau_ab : in     generic_task_ptr;
         w      : in     Integer;
         tau_ac : in     generic_task_ptr;
         w_ik   :    out Integer;
         wb_ik  :    out Integer)
      is
         transi_nob : Integer := 0;
         transi_b   : Integer := 0;
         w_ik_p     : Integer; -- W_ik for p > 0
      begin
         transactioninterference
           (tau_ab,
            tau_ik,
            w,
            tau_ac,
            transi_nob,
            transi_b);

         w_ik_p := w_mp (tau_ik, tau_ab, w);

         -- Second part of Equation (20)
         w_ik  := transi_nob + w_ik_p;
         wb_ik := transi_b + w_ik_p;
      end wwb;

      -- [W_i*, WB_i*] => Equations (21) and (22) in one function
      procedure max_wwb
        (gamma_i : in     generic_task_group_ptr;
         tau_ab  : in     generic_task_ptr;
         w       : in     Integer;
         tau_ac  : in     generic_task_ptr;
         w_i     :    out Integer;
         wb_i    :    out Integer)
      is
         tau_ik_iterator : tasks_iterator;
         tau_ik          : generic_task_ptr;

         w_ik  : Integer;
         wb_ik : Integer;

         xp_i : tasks_set_ptr;
      begin
         w_i  := 0;
         wb_i := 0;

         xp_i := xp (gamma_i, tau_ab);

         if not is_empty (xp_i.all) then
            reset_iterator (xp_i.all, tau_ik_iterator);
            loop
               current_element (xp_i.all, tau_ik, tau_ik_iterator);

               wwb (tau_ik, tau_ab, w, tau_ac, w_ik, wb_ik);

               w_i  := max (w_i, w_ik);
               wb_i := max (wb_i, wb_ik);

               exit when is_last_element (xp_i.all, tau_ik_iterator);
               next_element (xp_i.all, tau_ik_iterator);
            end loop;
         end if;

         free_container (xp_i.all);
         free (xp_i, False);
      end max_wwb;

      -- Busy period estimation
      function l
        (tau_ab : in generic_task_ptr;
         tau_ac : in generic_task_ptr) return Integer
      is
         l   : Integer;
         l_w : Integer;

         c_ab       : Integer;
         b_ab       : Integer;
         w_l_ac     : Integer;
         wb_l_ac    : Integer;
         dw_l_ac    : Integer;
         dw_i       : Integer;
         sum_max_wi : Integer := 0;
         max_dw_i   : Integer := 0;
         w_i        : Integer;
         wb_i       : Integer;

         convergence : Boolean := False;

         gamma_iterator : task_groups_iterator;
         gamma_i        : generic_task_group_ptr;
         gamma_a        : generic_task_group_ptr;
      begin
         gamma_a := search_task_group_by_task (my_system.task_groups, tau_ab);

         c_ab := tau_ab.capacity;
         b_ab := tau_ab.blocking_time;

         l := c_ab + b_ab;

         loop
            -- Compute W_ac' and WB_ac' with equation (20)
            --  tau_ik  tau_ab  w  tau_ac  Wik    WBik
            wwb (tau_ac, tau_ab, l, tau_ac, w_l_ac, wb_l_ac);
            dw_l_ac := wb_l_ac - w_l_ac;

            sum_max_wi := 0;
            max_dw_i   := 0;
            reset_iterator (my_system.task_groups, gamma_iterator);
            loop
               current_element
                 (my_system.task_groups,
                  gamma_i,
                  gamma_iterator);

               if gamma_i.name /= gamma_a.name then
                  w_i  := 0;
                  wb_i := 0;

                  -- Equation (21) and (22) all in one function
                  --      i        tau_ab  w  tau_ac -> for reduction rules
                  max_wwb
                    (gamma_i,
                     tau_ab,
                     l,
                     tau_ac,
                     w_i,
                     wb_i); -- Gives W_i := max(W_ik) and WB_i := max(WB_ik) for all tau_ik
                  dw_i := wb_i - w_i;

                  -- To compute term 3 and 4 of equation (34)
                  sum_max_wi :=
                    sum_max_wi + w_i; -- W_i is summed for all Gamma_i
                  max_dw_i :=
                    max (max_dw_i, dw_i); -- DW_i is compared for all Gamma_i
               end if;

               exit when is_last_element
                   (my_system.task_groups,
                    gamma_iterator);
               next_element (my_system.task_groups, gamma_iterator);
            end loop;

            -- Equation (34)
            l_w := b_ab + w_l_ac + sum_max_wi + max (dw_l_ac, max_dw_i);

            if l = l_w then
               convergence := True;
            end if;

            l := l_w;

            -- Warning: inifinity loop possible here, if no convergence. No convergence when CPU utilization > 100%
            -- TODO: Before starting the analysis, check that CPU utilization <= 100%
            exit when convergence;
         end loop;

         return l;
      end l;

      function pl_seg
        (tau_ab : generic_task_ptr;
         tau_ac : generic_task_ptr) return Integer
      is
         varphi_seg_0abc : Integer;
         l_abc           : Integer;
         t_a             : Integer;
      begin
         if tau_ac.task_type /= periodic_type then
            raise generic_wcdops_plus_exception;
         end if;

         l_abc           := l (tau_ab, tau_ac);
         varphi_seg_0abc := varphi_seg (tau_ab, tau_ac, tau_ab);
         t_a             := periodic_task_ptr (tau_ac).period;

         if in_mpi (tau_ab, tau_ab) then
            return ceil0 (Double (l_abc - varphi_seg_0abc) / Double (t_a));
         end if;
         -- Note: Case where C < B and not same_h(A, B, C) is not needed because different segments is already handled in Redell (to verify).

         return 0;
      end pl_seg;

      function taskinterference_gamma_a
        (tau_ab : generic_task_ptr;
         tau_ac : generic_task_ptr;
         tau_aj : generic_task_ptr;
         w      : Integer;
         p      : Integer;
         p_ab   : Integer) return Integer
      is
         taski : Integer := 0;

         p_seg_0ajc     : Integer;
         p_seg_0acc     : Integer;
         varphi_seg_ajc : Integer;
         t_a            : Integer;
         c_aj           : Integer;

         h_seg_ac      : generic_task_ptr;
         h_seg_aj      : generic_task_ptr;
         h_seg_ab      : generic_task_ptr;
         pred_h_seg_ac : generic_task_ptr;
         pred_h_seg_aj : generic_task_ptr;
         pred_h_seg_ab : generic_task_ptr;
      begin
         if tau_aj.task_type /= periodic_type then
            raise generic_wcdops_plus_exception;
         end if;

         p_seg_0ajc     := p0_seg (tau_aj, tau_ac, tau_ab);
         varphi_seg_ajc := varphi_seg (tau_aj, tau_ac, tau_ab);
         t_a            := periodic_task_ptr (tau_aj).period;
         c_aj           := tau_aj.capacity;

         if p >= p_seg_0ajc and w > varphi_seg_ajc + (p - 1) * t_a then
            taski := c_aj;

            p_seg_0acc := p0_seg (tau_ac, tau_ac, tau_ab);
            h_seg_ac   := first_task_in_hseg (tau_ac, tau_ab);
            h_seg_aj   := first_task_in_hseg (tau_aj, tau_ab);
            h_seg_ab   := first_task_in_hseg (tau_ab, tau_ab);

            pred_h_seg_ac := pred (h_seg_ac);
            pred_h_seg_aj := pred (h_seg_aj);
            pred_h_seg_ab := pred (h_seg_ab);

-- Note: a pred of a Hseg cannot be null
-- beacuse First_Task_In_Hseg never returns null if we add a ghost root task.
-- So condition "pred /= null" is not needed.
            if
              (p >= p_seg_0acc
               and then seg_precedes (tau_ac, tau_aj, tau_ab)
               and then not same_hsec (tau_ac, tau_aj, tau_ab)) -- Rule 1b
              or else
              (pred_h_seg_ac /= null
               and then in_lpi (pred_h_seg_ac, tau_ab)
               and then pred_h_seg_aj /= null
               and then in_lpi (pred_h_seg_aj, tau_ab)
               and then
               (p /= p_seg_0acc
                or else not same_hseg (h_seg_ac, h_seg_aj, tau_ab))) -- Rule 2b
              or else
              (pred_h_seg_ab /= null
               and then in_lpi (pred_h_seg_ab, tau_ab)
               and then pred_h_seg_aj /= null
               and then in_lpi (pred_h_seg_aj, tau_ab)
               and then
               (p /= p_ab
                or else not same_hseg (h_seg_ab, h_seg_aj, tau_ab))) -- Rule 3b
              or else
              (p <= p_ab
               and then seg_precedes (tau_aj, tau_ab, tau_ab)
               and then not same_hsec (tau_ab, tau_aj, tau_ab)) -- Rule 4b
              or else
              ((p >= p_ab and then precedes (tau_ab, tau_aj)) -- Rule 5b
               or else
               (p >= p_ab
                and then seg_precedes (tau_ab, tau_aj, tau_ab)
                and then not same_hsec (tau_ac, tau_ab, tau_ab))
               or else (p > p_ab and tau_ab.name = tau_aj.name))
            then
               taski := 0;
            end if;
         end if;

         return taski;
      end taskinterference_gamma_a;

      procedure compute_sb_sectioni_gamma_a
        (tau_abr  : in     generic_task_ptr;
         root     : in     generic_task_ptr;
         tau_ab   : in     generic_task_ptr;
         tau_ac   : in     generic_task_ptr;
         w        : in     Integer;
         p        : in     Integer;
         p_ab     : in     Integer;
         sb       :    out tasks_set;
         sectioni : in out Integer)
      is
         succ_abr             : tasks_set_ptr;
         tau_am_iterator      : tasks_iterator;
         tau_am               : generic_task_ptr;
         root_preceeds_a_hseg : Boolean;
      begin
         succ_abr := succ (tau_abr);

         if not is_empty (succ_abr.all) then
            -- Check that tau_aBr actually preceeds a segment
            reset_iterator (succ_abr.all, tau_am_iterator);
            loop
               current_element (succ_abr.all, tau_am, tau_am_iterator);

               if tau_abr.name /= root.name
                 or else in_hpi (tau_am, tau_ab)
               then
                  root_preceeds_a_hseg := True;
               end if;

               exit when is_last_element (succ_abr.all, tau_am_iterator)
                 or else root_preceeds_a_hseg;
               next_element (succ_abr.all, tau_am_iterator);
            end loop;

            reset_iterator (succ_abr.all, tau_am_iterator);
            loop
               current_element (succ_abr.all, tau_am, tau_am_iterator);

               if in_hpi (tau_am, tau_ab) then
                  sectioni :=
                    sectioni +
                    taskinterference_gamma_a
                      (tau_ab,
                       tau_ac,
                       tau_am,
                       w,
                       p,
                       p_ab);
                  compute_sb_sectioni_gamma_a
                    (tau_am,
                     root,
                     tau_ab,
                     tau_ac,
                     w,
                     p,
                     p_ab,
                     sb,
                     sectioni);
               elsif in_lpi (tau_am, tau_ab) then
                  compute_sb (root, tau_am, tau_ab, sb);
               else
                  compute_sb (root, tau_am, tau_ab, sb);

                  if root_preceeds_a_hseg then
                     compute_sb_sectioni_gamma_a
                       (tau_am,
                        root,
                        tau_ab,
                        tau_ac,
                        w,
                        p,
                        p_ab,
                        sb,
                        sectioni);
                  end if;
               end if;

               exit when is_last_element (succ_abr.all, tau_am_iterator);
               next_element (succ_abr.all, tau_am_iterator);
            end loop;
         end if;

         free_container (succ_abr.all);
         free (succ_abr, False);
      end compute_sb_sectioni_gamma_a;

      procedure branchinterference_gamma_a
        (tau_ab      : in     generic_task_ptr;
         tau_ac      : in     generic_task_ptr;
         tau_abr     : in     generic_task_ptr;
         w           : in     Integer;
         p           : in     Integer;
         p_ab        : in     Integer;
         branchi     : in out Integer;
         branchdelta : in out Integer)
      is
         sb       : tasks_set;
         sectioni : Integer := 0;

         tau_as_iterator : tasks_iterator;
         tau_as          : generic_task_ptr;

         bi           : Integer := 0;
         bd           : Integer := 0;
         subbranchesi : Integer := 0;
         subbdelta    : Integer := 0;
      begin
         compute_sb_sectioni_gamma_a
           (tau_abr,
            tau_abr,
            tau_ab,
            tau_ac,
            w,
            p,
            p_ab,
            sb,
            sectioni);
         if not is_empty (sb) then
            reset_iterator (sb, tau_as_iterator);
            loop
               current_element (sb, tau_as, tau_as_iterator);

               branchinterference_gamma_a
                 (tau_ab,
                  tau_ac,
                  tau_as,
                  w,
                  p,
                  p_ab,
                  bi,
                  bd);

               subbranchesi := subbranchesi + bi;
               subbdelta    := max (subbdelta, bd);
               exit when is_last_element (sb, tau_as_iterator);
               next_element (sb, tau_as_iterator);
            end loop;
         end if;

         if in_lpi (tau_abr, tau_ab) then
            branchi     := subbranchesi;
            branchdelta := max (sectioni - subbranchesi, subbdelta);
         else -- X, delta and ghost root cases
            branchi     := max (sectioni, subbranchesi);
            branchdelta := max (subbranchesi + subbdelta - branchi, 0);
         end if;

         --Free(SB, False);
      end branchinterference_gamma_a;

      procedure transactioninterference_gamma_a
        (tau_ac     : in     generic_task_ptr;
         tau_ab     : in     generic_task_ptr;
         w          : in     Integer;
         p_ab       : in     Integer;
         transi_nob : in out Integer;
         transi_b   : in out Integer)
      is
         p_seg_0ank : Integer;
         jobi       : Integer := 0;
         jobdelta   : Integer := 0;
         transdelta : Integer := 0;

         gamma_a  : generic_task_group_ptr;
         tau_a1   : generic_task_ptr;
         tau_a0   : generic_task_ptr;
         h_seg_an : generic_task_ptr;
      begin
         transi_nob := 0;
         transi_b   := 0;

-- Add ghost root task: placed here for understanding.
-- Can be moved to somewhere earlier for optimization (e.g. Max_WWB function)
         gamma_a := search_task_group_by_task (my_system.task_groups, tau_ac);
         tau_a1  := get_root_task (gamma_a);

         tau_a0          := new generic_task; -- Scheduling_Task?
         tau_a0.name     := To_Unbounded_String ("wcdops+_ghost_root");
         tau_a0.cpu_name := To_Unbounded_String ("wcdops+_ghost_cpu");
         tau_a0.priority := 0;

         --Add(My_System.Tasks, tau_a0);
         add_one_task_dependency_precedence
           (my_system.dependencies,
            tau_a0,
            tau_a1);

         h_seg_an := get_first_task_in_hseg_n (gamma_a, tau_ab);

         if h_seg_an /= null then
            p_seg_0ank := p0_seg (h_seg_an, tau_ac, tau_ab);

            -- Compute transI_NoB, transDelta and transI_B
            for p in p_seg_0ank .. 0 loop
               branchinterference_gamma_a
                 (tau_ab,
                  tau_ac,
                  tau_a0,
                  w,
                  p,
                  p_ab,
                  jobi,
                  jobdelta);
               transi_nob := transi_nob + jobi;
               transdelta := max (transdelta, jobdelta);
            end loop;

            transi_b := transi_nob + transdelta;
         end if;

         -- Free tau_a0
         delete_one_task_dependency_precedence
           (my_system.dependencies,
            tau_a0,
            tau_a1);
         Free (tau_a0);
      end transactioninterference_gamma_a;

      function w_mp_gamma_a
        (tau_ac : generic_task_ptr;
         tau_ab : generic_task_ptr;
         w      : Integer;
         p_ab   : Integer) return Integer
      is
         gamma_a         : generic_task_group_ptr;
         tau_aj_iterator : generic_task_iterator;
         tau_aj          : generic_task_ptr;

         c_aj           : Integer;
         t_a            : Integer;
         varphi_seg_ajc : Integer;
         c_ab           : Integer;

         w_ac_p_1 : Integer := 0;
         w_ac_p_2 : Integer := 0;
         w_ac_p   : Integer := 0;
      begin
         gamma_a := search_task_group_by_task (my_system.task_groups, tau_ac);

         if not is_empty (gamma_a.task_list) then
            reset_head_iterator (gamma_a.task_list, tau_aj_iterator);
            loop
               current_element (gamma_a.task_list, tau_aj, tau_aj_iterator);

               if in_mpi (tau_aj, tau_ab) and tau_aj.name /= tau_ab.name then
                  if tau_aj.task_type /= periodic_type then
                     raise generic_wcdops_plus_exception;
                  end if;

                  c_aj           := tau_aj.capacity;
                  t_a            := periodic_task_ptr (tau_aj).period;
                  varphi_seg_ajc := varphi_seg (tau_aj, tau_ac, tau_ab);

                  if not precedes (tau_ab, tau_aj) then
                     -- Equation (26)
                     w_ac_p_1 :=
                       w_ac_p_1 +
                       ceil0 (Double (w - varphi_seg_ajc) / Double (t_a)) *
                         c_aj;
                  else
                     -- Equation (27)
                     w_ac_p_2 :=
                       w_ac_p_2 +
                       min
                         (p_ab - 1,
                          ceil0 (Double (w - varphi_seg_ajc) / Double (t_a)) *
                          c_aj);
                  end if;
               end if;

               exit when is_tail_element (gamma_a.task_list, tau_aj_iterator);
               next_element (gamma_a.task_list, tau_aj_iterator);
            end loop;

            c_ab := tau_ab.capacity;

            w_ac_p := w_ac_p_1 + max (0, p_ab * c_ab + w_ac_p_2);
         end if;

         return w_ac_p;
      end w_mp_gamma_a;

      -- [Wac(tau_ab, w, p_ab), WBac(tau_ab, w, p_ab)] => Equation (29)
      procedure wwb_gamma_a
        (tau_ac : in     generic_task_ptr;
         tau_ab : in     generic_task_ptr;
         w      : in     Integer;
         p_ab   :        Integer;
         w_ac   :    out Integer;
         wb_ac  :    out Integer)
      is
         transi_nob : Integer := 0;
         transi_b   : Integer := 0;
         w_ac_p     : Integer; -- W_ac for p > 0
      begin
         transactioninterference_gamma_a
           (tau_ac,
            tau_ab,
            w,
            p_ab,
            transi_nob,
            transi_b);

         w_ac_p := w_mp_gamma_a (tau_ac, tau_ab, w, p_ab);

         -- Second part of Equation (29)
         w_ac  := transi_nob + w_ac_p;
         wb_ac := transi_b + w_ac_p;
      end wwb_gamma_a;

      function w
        (tau_ab : generic_task_ptr;
         tau_ac : generic_task_ptr;
         p_ab   : Integer) return Integer
      is
         w   : Integer;
         w_w : Integer; -- Smiley variable is not amused...

         c_ab   : Integer; -- For initial w
         b_ab   : Integer; -- 1st element
         w_ac   : Integer; -- 2nd element
         p_0abc : Integer;

         w_i        : Integer;
         wb_i       : Integer;
         sum_max_wi : Integer; -- 3rd element
         dw_i       : Integer; -- To compute 2nd part of 4th element
         max_dw_i   : Integer := 0; -- 2nd part of 4th element
         wb_ac      : Integer; -- To compute 1st part of 4th element
         dw_ac      : Integer; -- 1st part of 4th element

         gamma_iterator : task_groups_iterator;
         gamma_i        : generic_task_group_ptr;
         gamma_a        : generic_task_group_ptr;

         convergence : Boolean := False;
      begin
         gamma_a := search_task_group_by_task (my_system.task_groups, tau_ab);

         c_ab := tau_ab.capacity;
         b_ab := tau_ab.blocking_time;

         p_0abc := p0 (tau_ab, tau_ac); -- Note: not p_seg_0abc but p_0abc
         w      := (p_ab - p_0abc + 1) * c_ab + b_ab;

         loop
         -- Compute W_ac and DW_ac of Equation (32) and part 1 of Equation (31)
            wwb_gamma_a (tau_ac, tau_ab, w, p_ab, w_ac, wb_ac);
            dw_ac := wb_ac - w_ac;

            -- Compute Equation (32)'s part 3 and Equation (31)'s part 2
            sum_max_wi := 0;
            max_dw_i   := 0;
            reset_iterator (my_system.task_groups, gamma_iterator);
            loop
               current_element
                 (my_system.task_groups,
                  gamma_i,
                  gamma_iterator);

               if gamma_i.name /= gamma_a.name then
                  w_i  := 0;
                  wb_i := 0;

                  -- Equation (21) and (22) all in one function
                  --      i        tau_ab  w  tau_ac -> for reduction rules
                  max_wwb
                    (gamma_i,
                     tau_ab,
                     w,
                     tau_ac,
                     w_i,
                     wb_i); -- Gives W_i* := max(W_ik) and WB_i* := max(WB_ik) for all tau_ik
                  dw_i := wb_i - w_i;

                  sum_max_wi :=
                    sum_max_wi + w_i; -- W_i is summed for all Gamma_i
                  max_dw_i :=
                    max (max_dw_i, dw_i); -- DW_i is compared for all Gamma_i
               end if;

               exit when is_last_element
                   (my_system.task_groups,
                    gamma_iterator);
               next_element (my_system.task_groups, gamma_iterator);
            end loop;

            -- Equation (32)
            w_w := b_ab + w_ac + sum_max_wi + max (dw_ac, max_dw_i);

            if w = w_w then
               convergence := True;
            end if;

            w := w_w;

            -- Warning: inifinity loop possible here, if no convergence. No convergence when CPU utilization > 100%
            -- TODO: Before starting the analysis, check that CPU utilization <= 100%
            exit when convergence;
         end loop;

         return w;
      end w;

      procedure estimate_successors_response_time
        (tau_ij : in generic_task_ptr)
      is
         succ_ij       : tasks_set_ptr;
         succ_iterator : tasks_iterator;
         succ_task     : generic_task_ptr;

         r_tau_ij : Integer;
         r_succ   : Integer;
         c_ij     : Integer;
      begin
         succ_ij := succ (tau_ij);

         if not is_empty (succ_ij.all) then
            reset_iterator (succ_ij.all, succ_iterator);
            loop
               current_element (succ_ij.all, succ_task, succ_iterator);

               r_tau_ij := get_response (tau_ij);
               r_succ   := get_response (succ_task);
               c_ij     := tau_ij.capacity;

               if r_succ < r_tau_ij then
                  set_response (succ_task, r_tau_ij + c_ij);
               end if;

               estimate_successors_response_time (succ_task);

               exit when is_last_element (succ_ij.all, succ_iterator);
               next_element (succ_ij.all, succ_iterator);
            end loop;
         end if;

         free_container (succ_ij.all);
         free (succ_ij, False);
      end estimate_successors_response_time;

      procedure estimate_predecessor_response_time
        (tau_ij : in generic_task_ptr)
      is
         pred_ij   : generic_task_ptr;
         r_tau_ij  : Integer;
         r_pred_ij : Integer;
         c_ij      : Integer;
      begin
         pred_ij := pred (tau_ij);

         if pred_ij /= null then
            r_tau_ij  := get_response (tau_ij);
            r_pred_ij := get_response (pred_ij);
            c_ij      := tau_ij.capacity;

            if r_tau_ij > r_pred_ij then
               set_response (pred_ij, r_tau_ij - c_ij);
            end if;

            estimate_predecessor_response_time (pred_ij);
         end if;
      end estimate_predecessor_response_time;

      procedure update_successors_jitter (tau_ij : in generic_task_ptr) is
         succ_ij       : tasks_set_ptr;
         succ_iterator : tasks_iterator;
         succ_task     : generic_task_ptr;
      begin
         succ_ij := succ (tau_ij);

         if not is_empty (succ_ij.all) then
            reset_iterator (succ_ij.all, succ_iterator);
            loop
               current_element (succ_ij.all, succ_task, succ_iterator);

               if succ_task.task_type /= periodic_type then
                  raise generic_wcdops_plus_exception;
               end if;

               periodic_task_ptr (succ_task).jitter :=
                 max (get_offset (succ_task), get_response (tau_ij)) -
                 get_offset (succ_task);

               update_successors_jitter (succ_task);

               exit when is_last_element (succ_ij.all, succ_iterator);
               next_element (succ_ij.all, succ_iterator);
            end loop;
         end if;

         free_container (succ_ij.all);
         free (succ_ij, False);
      end update_successors_jitter;

      -- Local variables --

      gamma_iterator : task_groups_iterator;
      gamma_a        : generic_task_group_ptr;

      tau_ab_iterator : generic_task_iterator;
      tau_ab          : generic_task_ptr;

      tau_ac_iterator : tasks_iterator;
      tau_ac          : generic_task_ptr;

      xp_a : tasks_set_ptr;

      r_w_ab  : Integer; -- Worst response of tau_ab
      r_w_abc : Integer; -- Worst response among reponses that depend on a tau_ab starting the BP and the analyzed p_ab
      r_ab    : Integer; -- To compare and store current and last response

      p_seg_0abc : Integer;
      p_seg_labc : Integer;

      w_abc      : Integer;
      varphi_abc : Integer;
      t_a        : Integer;
      o_ab       : Integer;

      convergence : Boolean;

   --X : Integer := 0;
   begin
      ---------------------------
      -- PROCEDURE BEGINS HERE --
      ---------------------------

      -- TODO a function to verify that the transaction is correct
      -- i.e. tree-shaped, offset values correct, no initial jitter...

      init_response_times (response_times);

      loop -- Convergence loop
         --put_line("***** X = " & X'Img & " *****");

         convergence := True;

         reset_iterator (my_system.task_groups, gamma_iterator);
         loop -- Transactions loop
            current_element (my_system.task_groups, gamma_a, gamma_iterator);

            if not is_empty (gamma_a.task_list) then
               reset_head_iterator (gamma_a.task_list, tau_ab_iterator);
               loop -- Analyzed tasks loop (tau_ab)
                  current_element (gamma_a.task_list, tau_ab, tau_ab_iterator);

                  r_ab   := get_response (tau_ab);
                  r_w_ab := 0;

                  xp_a := xp (gamma_a, tau_ab);
                  if not is_empty
                      (xp_a.all)
                  then -- Note: XP_a shouldn't be empty because at least tau_ab is in XP_a(tau_ab)
                     reset_iterator (xp_a.all, tau_ac_iterator);
                     loop -- BP starting tasks loop (tau_ac)
                        current_element (xp_a.all, tau_ac, tau_ac_iterator);

            -- Compute p0 and pL for tau_ab's segment when tau_c starts the BP
                        p_seg_0abc := p0_seg (tau_ab, tau_ac, tau_ab);
                        p_seg_labc := pl_seg (tau_ab, tau_ac);

                        -- For all p_ab in p0 to pL, take max R_w_ab
                        for p_ab in p_seg_0abc .. p_seg_labc loop

                           w_abc      := w (tau_ab, tau_ac, p_ab);
                           varphi_abc := varphi (tau_ab, tau_ac);
                           t_a        := periodic_task_ptr (tau_ab).period;
                           o_ab       := get_offset (tau_ab);

                           r_w_abc :=
                             w_abc - varphi_abc - (p_ab - 1) * t_a + o_ab;

                           -- Store maximum value of R_abc^w in R_ab^w
                           if r_w_abc > r_w_ab then
                              r_w_ab := r_w_abc;
                           end if;

               -- Determine if R_w_abc is higher than deadline and stop if so
                           if stop_on_deadline_missed and
                             r_w_ab > get_global_deadline (tau_ab)
                           then
                              raise deadline_missed_exception;
                           end if;
                        end loop;

                        exit when is_last_element (xp_a.all, tau_ac_iterator);
                        next_element (xp_a.all, tau_ac_iterator);
                     end loop;
                  end if;

                  free_container (xp_a.all);
                  free (xp_a, False);

                  -- Update tau_ab's response time
                  if r_w_ab > r_ab then
                     r_ab := r_w_ab;
                     set_response (tau_ab, r_ab);
                     convergence := False;
                  end if;

      -- Estimate tau_ab's successors responses so they are not less than R_ab
                  --Estimate_Successors_Response_Time(tau_ab);
                  -- This gives wrong results and it wasn't mentioned in [Redell04] nor in [Palencia99]

                  -- Estimate tau_ab's predecessor response because R_ab may be less than R_a{b-1} due to application of tau_ac in XP_a
                  --Estimate_Predecessor_Response_Time(tau_ab);
                  -- This gives wrong results and it wasn't mentioned in [Redell04] nor in [Palencia99]

                  -- Jitter re-evaluation
                  update_successors_jitter (get_root_task (gamma_a));

                  exit when is_tail_element
                      (gamma_a.task_list,
                       tau_ab_iterator);
                  next_element (gamma_a.task_list, tau_ab_iterator);
               end loop;
            end if;

            exit when is_last_element (my_system.task_groups, gamma_iterator);
            next_element (my_system.task_groups, gamma_iterator);
         end loop;

         --X := X + 1;

         -- Warning: inifinity loop possible here, if no convergence. No convergence when CPU utilization > 100%
         -- TODO: Before starting the analysis, check that CPU utilization <= 100%
         exit when convergence;
      end loop;
   end wcdops_plus;

   procedure wcdops_plus_nimp
     (my_system               : in out system;
      msg                     : in out Unbounded_String;
      response_times          : in out response_time_table;
      stop_on_deadline_missed : in     Boolean := False)
   is
      -- Local exceptions --
      generic_wcdops_plus_exception : exception;
      deadline_missed_exception : exception;

      -- Global variables --
      -- DELTA
      forced_immediate_tasks_set : tasks_set;

      -- Local functions --

      function max (x, y : Integer) return Integer is
      begin
         if x < y then
            return y;
         else
            return x;
         end if;
      end max;

      function min (x, y : Integer) return Integer is
      begin
         if x < y then
            return x;
         else
            return y;
         end if;
      end min;

      function modulus (x, y : Integer) return Integer is
      begin
         return x - Integer (Double'floor (Double (x) / Double (y))) * y;
      end modulus;

      function ceil0 (x : Double) return Integer is
      begin
         if x < 0.0 then
            return 0;
         else
            return Integer (Double'ceiling (x));
         end if;
      end ceil0;

      function get_offset (tau : generic_task_ptr) return Integer is
         new_offset : offset_type_ptr;

         use Offsets.Offsets_Table_Package;
      begin
         if tau.offsets.nb_entries > 0 then
            for i in 0 .. tau.offsets.nb_entries - 1 loop
               if tau.offsets.entries (i).activation = 0 then
                  return tau.offsets.entries (i).offset_value;
               end if;
            end loop;
         end if;

         new_offset              := new offset_type;
         new_offset.offset_value := 0;
         new_offset.activation   := 0;
         add (tau.offsets, new_offset.all);

         return 0;
      end get_offset;

      function get_global_deadline (tau : generic_task_ptr) return Integer is
      begin
         return tau.deadline + get_offset (tau);
      end get_global_deadline;

      procedure init_response_times
        (response_times : out response_time_table)
      is
         gamma_iterator : task_groups_iterator;
         gamma          : generic_task_group_ptr;
         tau_iterator   : generic_task_iterator;
         tau            : generic_task_ptr;

         i : Integer := 0;
      begin

         if not is_empty (my_system.task_groups) then
            initialize (response_times);

            reset_iterator (my_system.task_groups, gamma_iterator);
            loop
               current_element (my_system.task_groups, gamma, gamma_iterator);

               if not is_empty (gamma.task_list) then
                  reset_head_iterator (gamma.task_list, tau_iterator);
                  loop
                     current_element (gamma.task_list, tau, tau_iterator);

                     response_times.entries (response_times.nb_entries).data :=
                       Double (get_offset (tau) + tau.capacity);
                     response_times.entries (response_times.nb_entries).item :=
                       tau;
                     response_times.nb_entries :=
                       response_times.nb_entries + 1;

                     exit when is_tail_element (gamma.task_list, tau_iterator);
                     next_element (gamma.task_list, tau_iterator);
                  end loop;
               end if;

               exit when is_last_element
                   (my_system.task_groups,
                    gamma_iterator);
               next_element (my_system.task_groups, gamma_iterator);
            end loop;
         end if;
      end init_response_times;

      procedure set_response (tau : generic_task_ptr; time : Integer) is
      begin
         if response_times.nb_entries > 0 then
            for i in 0 .. response_times.nb_entries - 1 loop
               if response_times.entries (i).item.name = tau.name then
                  response_times.entries (i).data := Double (time) + 0.0;
                  return;
               end if;
            end loop;
         end if;
      end set_response;

      function get_response (tau : generic_task_ptr) return Integer is
      begin
         if response_times.nb_entries > 0 then
            for i in 0 .. response_times.nb_entries - 1 loop
               if response_times.entries (i).item.name = tau.name then
                  return Integer (response_times.entries (i).data);
               end if;
            end loop;
         end if;

         raise generic_wcdops_plus_exception;

         return 0;
      end get_response;

      -- DELTA procedures and functions in capital
      procedure force_immediate_task (tau : generic_task_ptr) is
         tau_ij_iterator : tasks_iterator;
         tau_ij          : generic_task_ptr;
      begin
         if not is_empty (forced_immediate_tasks_set) then
            reset_iterator (forced_immediate_tasks_set, tau_ij_iterator);
            loop
               current_element
                 (forced_immediate_tasks_set,
                  tau_ij,
                  tau_ij_iterator);

               if tau_ij.name = tau.name then
                  return;
               end if;

               exit when is_last_element
                   (forced_immediate_tasks_set,
                    tau_ij_iterator);
               next_element (forced_immediate_tasks_set, tau_ij_iterator);
            end loop;
         end if;

         add (forced_immediate_tasks_set, tau);
      end force_immediate_task;

      procedure unforce_immediate_task (tau : generic_task_ptr) is
         tau_ij_iterator : tasks_iterator;
         tau_ij          : generic_task_ptr;
      begin
         if not is_empty (forced_immediate_tasks_set) then
            reset_iterator (forced_immediate_tasks_set, tau_ij_iterator);
            loop
               current_element
                 (forced_immediate_tasks_set,
                  tau_ij,
                  tau_ij_iterator);

               if tau_ij.name = tau.name then
                  delete (forced_immediate_tasks_set, tau_ij, False);
                  return;
               end if;

               exit when is_last_element
                   (forced_immediate_tasks_set,
                    tau_ij_iterator);
               next_element (forced_immediate_tasks_set, tau_ij_iterator);
            end loop;
         end if;
      end unforce_immediate_task;

      function is_forced_immediate_task
        (tau : generic_task_ptr) return Boolean
      is
         tau_ij_iterator : tasks_iterator;
         tau_ij          : generic_task_ptr;
      begin
         if not is_empty (forced_immediate_tasks_set) then
            reset_iterator (forced_immediate_tasks_set, tau_ij_iterator);
            loop
               current_element
                 (forced_immediate_tasks_set,
                  tau_ij,
                  tau_ij_iterator);

               if tau_ij.name = tau.name then
                  return True;
               end if;

               exit when is_last_element
                   (forced_immediate_tasks_set,
                    tau_ij_iterator);
               next_element (forced_immediate_tasks_set, tau_ij_iterator);
            end loop;
         end if;

         return False;
      end is_forced_immediate_task;

      procedure clear_forced_immediate_tasks_set is
         tau_ij_iterator : tasks_iterator;
         tau_ij          : generic_task_ptr;
      begin
         while not is_empty (forced_immediate_tasks_set) loop
            reset_iterator (forced_immediate_tasks_set, tau_ij_iterator);
            current_element
              (forced_immediate_tasks_set,
               tau_ij,
               tau_ij_iterator);
            delete (forced_immediate_tasks_set, tau_ij, False);
         end loop;
      end clear_forced_immediate_tasks_set;

-- No multi-predecessor version; Otherwise should return a set of predecessors
      function pred (tau_ij : generic_task_ptr) return generic_task_ptr is
         pred_ij : generic_task_ptr;

         a_task_dependencies_iterator : tasks_dependencies_iterator;
         a_half_dep                   : dependency_ptr;
      begin
         if not is_empty (my_system.dependencies.depends) then
            reset_iterator
              (my_system.dependencies.depends,
               a_task_dependencies_iterator);
            loop
               current_element
                 (my_system.dependencies.depends,
                  a_half_dep,
                  a_task_dependencies_iterator);

               if a_half_dep.type_of_dependency = precedence_dependency then
                  if a_half_dep.precedence_sink.name = tau_ij.name then
                     pred_ij := a_half_dep.precedence_source;
                     return pred_ij;
                  end if;
               end if;

               exit when is_last_element
                   (my_system.dependencies.depends,
                    a_task_dependencies_iterator);
               next_element
                 (my_system.dependencies.depends,
                  a_task_dependencies_iterator);
            end loop;
         end if;

         return null;
      end pred;

      function get_root_task
        (gamma_i : generic_task_group_ptr) return generic_task_ptr
      is
         tau_ij_iterator : generic_task_iterator;
         tau_ij          : generic_task_ptr;
         pred_ij         : generic_task_ptr;
      begin
         if not is_empty (gamma_i.task_list) then
            reset_head_iterator (gamma_i.task_list, tau_ij_iterator);
            loop
               current_element (gamma_i.task_list, tau_ij, tau_ij_iterator);

               pred_ij := pred (tau_ij);

               if pred_ij = null then
                  return tau_ij;
               end if;

               exit when is_tail_element (gamma_i.task_list, tau_ij_iterator);
               next_element (gamma_i.task_list, tau_ij_iterator);
            end loop;
         end if;

         raise generic_wcdops_plus_exception;

         -- Should never reach
         return null;
      end get_root_task;

      -- DELTA: New function
      function is_immediate
        (pred : generic_task_ptr;
         succ : generic_task_ptr) return Boolean
      is
         o_pred : Integer;
         c_pred : Integer;
         o_succ : Integer;
      begin
         -- DELTA: In case of non-immediate successors, we sometimes need to see what values are computed when their predecessor
         -- go over their offset, thus making them immediate successors.
         if is_forced_immediate_task (succ) then
            return True;
         end if;

         o_pred := get_offset (pred);
         c_pred := pred.capacity;

         o_succ := get_offset (succ);

         if o_succ > o_pred + c_pred then
            return False;
         end if;

         return True;
      end is_immediate;

      -- DELTA: New function
      function is_immediate_successor
        (tau_ij : generic_task_ptr) return Boolean
      is
         pred_ij : generic_task_ptr;
      begin
         pred_ij := pred (tau_ij);

         if pred_ij /= null then
            return is_immediate (pred_ij, tau_ij);
         end if;

         return True;
      end is_immediate_successor;

      -- Returns true if tau_ip precedes tau_ij (not necessarily immediately)
      function precedes
        (tau_ip : generic_task_ptr;
         tau_ij : generic_task_ptr) return Boolean
      is
         pred_ij : generic_task_ptr;
      begin
         pred_ij := pred (tau_ij);

         if pred_ij = null then
            return False;
         elsif pred_ij.name = tau_ip.name then
            return True;
         else
            return precedes (tau_ip, pred_ij);
         end if;
      end precedes;

      function succ (tau_ij : generic_task_ptr) return tasks_set_ptr is
         succ_ij : tasks_set_ptr;

         a_task_dependencies_iterator : tasks_dependencies_iterator;
         a_half_dep                   : dependency_ptr;
      begin
         succ_ij := new tasks_set;

         if not is_empty (my_system.dependencies.depends) then
            reset_iterator
              (my_system.dependencies.depends,
               a_task_dependencies_iterator);
            loop
               current_element
                 (my_system.dependencies.depends,
                  a_half_dep,
                  a_task_dependencies_iterator);

               if a_half_dep.type_of_dependency = precedence_dependency then
                  if a_half_dep.precedence_source.name = tau_ij.name then
                     add (succ_ij.all, a_half_dep.precedence_sink);
                  end if;
               end if;

               exit when is_last_element
                   (my_system.dependencies.depends,
                    a_task_dependencies_iterator);
               next_element
                 (my_system.dependencies.depends,
                  a_task_dependencies_iterator);
            end loop;
         end if;

         return succ_ij;
      end succ;

      -- Returns true if tau_ij in hpi(tau_ab) (tasks in Gamma_i of higher priority than tau_ab and on same cpu)
      function in_hpi
        (tau_ij : generic_task_ptr;
         tau_ab : generic_task_ptr) return Boolean
      is
      begin
         if tau_ij = null then
            raise generic_wcdops_plus_exception;
         end if;

         return tau_ij.priority >= tau_ab.priority and
           tau_ij.cpu_name = tau_ab.cpu_name;
      end in_hpi;

      -- Returns true if tau_ij in lpi(tau_ab) (tasks in Gamma_i of lower priority than tau_ab and on same cpu)
      function in_lpi
        (tau_ij : generic_task_ptr;
         tau_ab : generic_task_ptr) return Boolean
      is
      begin
         if tau_ij = null then
            raise generic_wcdops_plus_exception;
         end if;

         return tau_ij.priority < tau_ab.priority and
           tau_ij.cpu_name = tau_ab.cpu_name;
      end in_lpi;

      function has_pred_in_lpi
        (tau_ij : generic_task_ptr;
         tau_ab : generic_task_ptr) return Boolean
      is
         pred_ij : generic_task_ptr;
      begin
         pred_ij := pred (tau_ij);

         if pred_ij = null then
            return False;
         elsif in_lpi (pred_ij, tau_ab) then
            return True;
         else
            return has_pred_in_lpi (pred_ij, tau_ab);
         end if;
      end has_pred_in_lpi;

      -- Returns true if tau_ij in hpi(tau_ab) and does not have any predecessor (not only the immediate one) in lpi(tau_ab)
      function in_mpi
        (tau_ij : generic_task_ptr;
         tau_ab : generic_task_ptr) return Boolean
      is
      begin
         if (not in_hpi (tau_ij, tau_ab))
           or else (has_pred_in_lpi (tau_ij, tau_ab))
         then
            return False;
         end if;

         return True;
      end in_mpi;

      -- Returns set of tasks in Gamma_i that are in hpi(tau_ab) but for which the predecessor is not in hpi(tau_ab)
      function xp
        (gamma_i : generic_task_group_ptr;
         tau_ab  : generic_task_ptr) return tasks_set_ptr
      is
         xp_i : tasks_set_ptr;

         tau_if_iterator : generic_task_iterator;
         tau_if          : generic_task_ptr;
         pred_if         : generic_task_ptr;
      begin
         xp_i := new tasks_set;

         -- For each task in Gamma_i, if task in hpi(tau_ab) and pred(task) not in hpi then add to XP_i
         if not is_empty (gamma_i.task_list) then
            reset_head_iterator (gamma_i.task_list, tau_if_iterator);
            loop
               current_element (gamma_i.task_list, tau_if, tau_if_iterator);

               if in_hpi (tau_if, tau_ab) then
                  pred_if := pred (tau_if);

                  -- DELTA: 'or else not Is_Immediate(pred_if, tau_if)'
                  if pred_if = null
                    or else not in_hpi (pred_if, tau_ab)
                    or else not is_immediate (pred_if, tau_if)
                  then
                     add (xp_i.all, tau_if);
                  end if;
               end if;

               exit when is_tail_element (gamma_i.task_list, tau_if_iterator);
               next_element (gamma_i.task_list, tau_if_iterator);
            end loop;
         end if;

         return xp_i;
      end xp;

      -- Returns the first task tau_if in tau_ij's segment accroding to tau_ab's priority and cpu
      -- Recursive function that does not work in multiple predecessors case (like Pred function)
      function first_task_in_hseg
        (tau_ij : generic_task_ptr;
         tau_ab : generic_task_ptr) return generic_task_ptr
      is
         pred_ij : generic_task_ptr;
      begin
         if not in_hpi (tau_ij, tau_ab) then
            raise generic_wcdops_plus_exception;
         end if;

         pred_ij := pred (tau_ij);

         -- First condition should never be true if we add a ghost root task
         -- DELTA: 'or else not Is_Immediate(pred_ij, tau_ij)'
         if pred_ij = null
           or else not in_hpi (pred_ij, tau_ab)
           or else not is_immediate (pred_ij, tau_ij)
         then
            return tau_ij;
         else
            return first_task_in_hseg (pred_ij, tau_ab);
         end if;
      end first_task_in_hseg;

      function get_first_task_in_hseg_n
        (gamma_i : generic_task_group_ptr;
         tau_ab  : generic_task_ptr) return generic_task_ptr
      is
         xp_i : tasks_set_ptr;

         tau_if_iterator : tasks_iterator;
         tau_if          : generic_task_ptr;
         h_seg_in        : generic_task_ptr;
         o_if            : Integer;
         j_if            : Integer;
         max_oj          : Integer := 0;
      begin
         -- Get XPi set (first tasks in their respective segment) and loop through to find the one with the greatest O + J
         -- If several have the same O + J, it doesn't matter because it's the "O + J" value that interest us in fact (after this function returns), not the task.
         xp_i := xp (gamma_i, tau_ab);

         if not is_empty (xp_i.all) then
            reset_iterator (xp_i.all, tau_if_iterator);
            loop
               current_element (xp_i.all, tau_if, tau_if_iterator);

               if tau_if.task_type /= periodic_type then
                  raise generic_wcdops_plus_exception;
               end if;

               o_if := get_offset (tau_if);
               j_if := periodic_task_ptr (tau_if).jitter;

               if o_if + j_if >= max_oj then
                  h_seg_in := tau_if;
                  max_oj   := o_if + j_if;
               end if;

               exit when is_last_element (xp_i.all, tau_if_iterator);
               next_element (xp_i.all, tau_if_iterator);
            end loop;
         end if;

         free_container (xp_i.all);
         free (xp_i, False);

         return h_seg_in;
      end get_first_task_in_hseg_n;

      function same_hsec
        (task1  : generic_task_ptr;
         task2  : generic_task_ptr;
         tau_ab : generic_task_ptr) return Boolean
      is
         pred1 : generic_task_ptr;
         pred2 : generic_task_ptr;
      begin
         pred1 := pred (task1);
         while pred1 /= null and then not in_lpi (pred1, tau_ab) loop
            pred1 := pred (pred1);
         end loop;

         pred2 := pred (task2);
         while pred2 /= null and then not in_lpi (pred2, tau_ab) loop
            pred2 := pred (pred2);
         end loop;

         if pred1 /= null and pred2 /= null then
            if pred1.name = pred2.name then
               return True;
            end if;
         elsif pred1 = null and pred2 = null then
            return True;
         end if;

         return False;
      end same_hsec;

      function same_hseg
        (task1  : generic_task_ptr;
         task2  : generic_task_ptr;
         tau_ab : generic_task_ptr) return Boolean
      is
         h_seg_task1      : generic_task_ptr;
         h_seg_task2      : generic_task_ptr;
         pred_h_seg_task1 : generic_task_ptr;
         pred_h_seg_task2 : generic_task_ptr;
      begin
         h_seg_task1      := first_task_in_hseg (task1, tau_ab);
         pred_h_seg_task1 := pred (h_seg_task1);

         h_seg_task2      := first_task_in_hseg (task2, tau_ab);
         pred_h_seg_task2 := pred (h_seg_task2);

         -- DELTA: 'if H_seg_task1.name = H_seg_task2.name'
         if h_seg_task1.name = h_seg_task2.name then
            return True;
         elsif pred_h_seg_task1 /= null and pred_h_seg_task2 /= null then
            -- DELTA: 'and Is_Immediate(pred_H_seg_task1, H_seg_task1) and Is_Immediate(pred_H_seg_task2, H_seg_task2)'
            return pred_h_seg_task1.name = pred_h_seg_task2.name
              and then is_immediate (pred_h_seg_task1, h_seg_task1)
              and then is_immediate (pred_h_seg_task2, h_seg_task2);
         elsif pred_h_seg_task1 = null and pred_h_seg_task2 = null then
            return True;
         end if;

         return False;
      end same_hseg;

      -- Returns true if H_seg_ip precedes tau_ij
      function seg_precedes
        (tau_ip : generic_task_ptr;
         tau_ij : generic_task_ptr;
         tau_ab : generic_task_ptr) return Boolean
      is
         h_seg_ip      : generic_task_ptr;
         pred_h_seg_ip : generic_task_ptr;
      begin
         h_seg_ip      := first_task_in_hseg (tau_ip, tau_ab);
         pred_h_seg_ip := pred (h_seg_ip);

         -- DELTA: in case the pred is supposed to be a delta
         if not is_immediate (pred_h_seg_ip, h_seg_ip) then
            pred_h_seg_ip := h_seg_ip;
         end if;

         return not same_hseg (tau_ip, tau_ij, tau_ab)
           and then
           (pred_h_seg_ip = null or else precedes (pred_h_seg_ip, tau_ij));
      end seg_precedes;

      -- varphi_ijk
      function varphi
        (tau_ij : generic_task_ptr;
         tau_ik : generic_task_ptr) return Integer
      is
         t_i  : Integer;
         o_ij : Integer;
         o_ik : Integer;
         j_ik : Integer;
      begin
         if tau_ij.task_type /= periodic_type or
           tau_ik.task_type /= periodic_type
         then
            raise generic_wcdops_plus_exception;
         end if;

         t_i  := periodic_task_ptr (tau_ik).period;
         o_ij := get_offset (tau_ij);
         o_ik := get_offset (tau_ik);
         j_ik := periodic_task_ptr (tau_ik).jitter;

         return t_i + o_ij - modulus (o_ik + j_ik, t_i);
      end varphi;

      function varphi_seg
        (tau_ij : generic_task_ptr;
         tau_ik : generic_task_ptr;
         tau_ab : generic_task_ptr) return Integer
      is
      begin
         if not in_hpi (tau_ij, tau_ab) then
            raise generic_wcdops_plus_exception;
         end if;

         return varphi (first_task_in_hseg (tau_ij, tau_ab), tau_ik);
      end varphi_seg;

      function p0
        (tau_ij : generic_task_ptr;
         tau_ik : generic_task_ptr) return Integer
      is
         varphi_ijk : Integer;
         j_ij       : Integer;
         t_i        : Integer;
      begin
         if tau_ij.task_type /= periodic_type or
           tau_ik.task_type /= periodic_type
         then
            raise generic_wcdops_plus_exception;
         end if;

         j_ij       := periodic_task_ptr (tau_ij).jitter;
         t_i        := periodic_task_ptr (tau_ik).period;
         varphi_ijk := varphi (tau_ij, tau_ik);

         return Integer
             (1.0 - Double'floor (Double (j_ij + varphi_ijk) / Double (t_i)));
      end p0;

      -- p0 of first task in tau_ij's segment when tau_ik starts the BP
      function p0_seg
        (tau_ij : generic_task_ptr;
         tau_ik : generic_task_ptr;
         tau_ab : generic_task_ptr) return Integer
      is
      begin
         return p0 (first_task_in_hseg (tau_ij, tau_ab), tau_ik);
      end p0_seg;

      function taskinterference
        (tau_ab : generic_task_ptr;
         tau_ik : generic_task_ptr;
         tau_ij : generic_task_ptr;
         w      : Integer;
         p      : Integer;
         tau_ac : generic_task_ptr) return Integer
      is
         taski : Integer := 0;

         p_seg_0ijk     : Integer;
         p_seg_0ikk     : Integer;
         varphi_seg_ijk : Integer;
         t_i            : Integer;
         c_ij           : Integer;

         h_seg_ik      : generic_task_ptr;
         h_seg_ij      : generic_task_ptr;
         h_seg_ab      : generic_task_ptr;
         h_seg_ac      : generic_task_ptr;
         pred_h_seg_ik : generic_task_ptr;
         pred_h_seg_ij : generic_task_ptr;
         pred_h_seg_ab : generic_task_ptr;
         pred_h_seg_ac : generic_task_ptr;
      begin
         if tau_ij.task_type /= periodic_type then
            raise generic_wcdops_plus_exception;
         end if;

         p_seg_0ijk     := p0_seg (tau_ij, tau_ik, tau_ab);
         varphi_seg_ijk := varphi_seg (tau_ij, tau_ik, tau_ab);
         t_i            := periodic_task_ptr (tau_ij).period;
         c_ij           := tau_ij.capacity;

         if p >= p_seg_0ijk and w > varphi_seg_ijk + (p - 1) * t_i then
            taski := c_ij;

            p_seg_0ikk    := p0_seg (tau_ik, tau_ik, tau_ab);
            h_seg_ik      := first_task_in_hseg (tau_ik, tau_ab);
            h_seg_ij      := first_task_in_hseg (tau_ij, tau_ab);
            h_seg_ab      := first_task_in_hseg (tau_ab, tau_ab);
            h_seg_ac      := first_task_in_hseg (tau_ac, tau_ab);
            pred_h_seg_ik := pred (h_seg_ik);
            pred_h_seg_ij := pred (h_seg_ij);
            pred_h_seg_ab := pred (h_seg_ab);
            pred_h_seg_ac := pred (h_seg_ac);

            -- Note: Verifying H_segs are not null is important since tau_i0 ghost is added only to Gamma_a
            -- and this function is also called on Gamma_i transactions
            if
              (p >= p_seg_0ikk
               and then seg_precedes (tau_ik, tau_ij, tau_ab)
               and then not same_hsec (tau_ik, tau_ij, tau_ab)) -- Rule 1a
              or else
              (pred_h_seg_ik /= null
               and then in_lpi (pred_h_seg_ik, tau_ab)
               and then pred_h_seg_ij /= null
               and then in_lpi (pred_h_seg_ij, tau_ab)
               and then
               (p /= p_seg_0ikk
                or else not same_hseg (h_seg_ik, h_seg_ij, tau_ab))) -- Rule 2a
              or else
              (pred_h_seg_ab /= null
               and then in_lpi (pred_h_seg_ab, tau_ab)
               and then pred_h_seg_ij /= null
               and then in_lpi (pred_h_seg_ij, tau_ab)) -- Rule 3a
              or else
              (pred_h_seg_ac /= null
               and then in_lpi (pred_h_seg_ac, tau_ab)
               and then pred_h_seg_ij /= null
               and then in_lpi (pred_h_seg_ij, tau_ab)) -- Rule 4a
              or else
              (not is_immediate_successor (tau_ik)
               and then periodic_task_ptr (tau_ik).jitter = 0
               and then p <= p_seg_0ikk
               and then precedes (tau_ij, tau_ik))
            then -- DELTA J: rule 5a: if tau_ij in same section as tau_ik and tau_ij precedes tau_ik and we are checking p <= p_seg_0ikk then burn it
               taski := 0;
            end if;
         end if;

         return taski;
      end taskinterference;

      procedure compute_sb
        (root   : in     generic_task_ptr;
         tau_im : in     generic_task_ptr;
         tau_ab : in     generic_task_ptr;
         sb     :    out tasks_set)
      is
         pred_im       : generic_task_ptr;
         h_seg_pred_im : generic_task_ptr;
      begin
         pred_im := pred (tau_im);

         if in_hpi (pred_im, tau_ab) then
            h_seg_pred_im := first_task_in_hseg (pred_im, tau_ab);
            pred_im       := pred (h_seg_pred_im);

            -- DELTA: If pred(H_seg_pred_im) is not immediate, then H_seg_pred_im's predecessor is actually an imaginary delta task, thus itself
            if not is_immediate (pred_im, h_seg_pred_im) then
               pred_im := h_seg_pred_im;
            end if;
         end if;

         if pred_im.name = root.name then
            add (sb, tau_im);
         end if;
      end compute_sb;

-- TODO: Comment this because it's different from Redell and a bit complicated.
      procedure compute_sb_sectioni
        (tau_ib   : in     generic_task_ptr;
         root     : in     generic_task_ptr;
         tau_ab   : in     generic_task_ptr;
         tau_ik   : in     generic_task_ptr;
         w        : in     Integer;
         p        : in     Integer;
         tau_ac   : in     generic_task_ptr;
         sb       :    out tasks_set;
         sectioni : in out Integer)
      is
         succ_ib              : tasks_set_ptr;
         tau_im_iterator      : tasks_iterator;
         tau_im               : generic_task_ptr;
         root_preceeds_a_hseg : Boolean := False;
      begin
         if tau_ik.task_type /= periodic_type then
            raise generic_wcdops_plus_exception;
         end if;

         succ_ib := succ (tau_ib);

         if not is_empty (succ_ib.all) then
            -- Check that tau_iB actually preceeds a segment
            reset_iterator (succ_ib.all, tau_im_iterator);
            loop
               current_element (succ_ib.all, tau_im, tau_im_iterator);

               -- DELTA: 'and then Is_Immediate(tau_iB, tau_im)'
               if (tau_ib.name /= root.name)
                 or else
                 (in_hpi (tau_im, tau_ab)
                  and then is_immediate (tau_ib, tau_im))
               then
                  root_preceeds_a_hseg := True;
               end if;

               exit when is_last_element (succ_ib.all, tau_im_iterator)
                 or else root_preceeds_a_hseg;
               next_element (succ_ib.all, tau_im_iterator);
            end loop;

            -- Update sectionI and add tasks to SB
            reset_iterator (succ_ib.all, tau_im_iterator);
            loop
               current_element (succ_ib.all, tau_im, tau_im_iterator);

               if in_hpi (tau_im, tau_ab) then
                  -- DELTA: Add tau_im to SB if it is not immediate.
                  if not is_immediate (tau_ib, tau_im) then
                     compute_sb (root, tau_im, tau_ab, sb);
                  end if;

                  -- DELTA: This condition is added because tau_im can be a non-immediate successor.
                  -- See below (in X case) for explanation on usefulness of test.
                  if root_preceeds_a_hseg then
                     sectioni :=
                       sectioni +
                       taskinterference (tau_ab, tau_ik, tau_im, w, p, tau_ac);
                     compute_sb_sectioni
                       (tau_im,
                        root,
                        tau_ab,
                        tau_ik,
                        w,
                        p,
                        tau_ac,
                        sb,
                        sectioni);
                  end if;
               elsif in_lpi (tau_im, tau_ab) then
                  compute_sb (root, tau_im, tau_ab, sb);
               else
                  compute_sb (root, tau_im, tau_ab, sb);

                  -- The recursive algorithm continues on to a branch created with a X tau_im only if tau_iB preceeds a Hseg.
                  -- Otherwise we don't want to add anything after the X tau_im to sectionI, nor any sub-branche starters to SB
                  if root_preceeds_a_hseg then
                     compute_sb_sectioni
                       (tau_im,
                        root,
                        tau_ab,
                        tau_ik,
                        w,
                        p,
                        tau_ac,
                        sb,
                        sectioni);
                  end if;
               end if;

               exit when is_last_element (succ_ib.all, tau_im_iterator);
               next_element (succ_ib.all, tau_im_iterator);
            end loop;
         end if;

         free_container (succ_ib.all);
         free (succ_ib, False);
      end compute_sb_sectioni;

      -- DELTA J: Function to remove interference from a task tau_iB's segment
      -- Unused procedure
      procedure remove_segment_interference
        (tau_ib : in     generic_task_ptr;
         tau_ab : in     generic_task_ptr;
         tau_ik : in     generic_task_ptr;
         w      : in     Integer;
         p      : in     Integer;
         tau_ac : in     generic_task_ptr;
         bi     : in out Integer)
      is
         succ_ib         : tasks_set_ptr;
         tau_im_iterator : tasks_iterator;
         tau_im          : generic_task_ptr;
      begin
         if in_hpi (tau_ib, tau_ab) then
            bi := bi - taskinterference (tau_ab, tau_ik, tau_ib, w, p, tau_ac);
         end if;

         succ_ib := succ (tau_ib);

         if not is_empty (succ_ib.all) then
            reset_iterator (succ_ib.all, tau_im_iterator);
            loop
               current_element (succ_ib.all, tau_im, tau_im_iterator);

               if in_hpi (tau_im, tau_ab)
                 and then same_hseg (tau_ib, tau_im, tau_ab)
               then
                  bi :=
                    bi -
                    taskinterference (tau_ab, tau_ik, tau_im, w, p, tau_ac);
                  remove_segment_interference
                    (tau_im,
                     tau_ab,
                     tau_ik,
                     w,
                     p,
                     tau_ac,
                     bi);
               end if;

               exit when is_last_element (succ_ib.all, tau_im_iterator);
               next_element (succ_ib.all, tau_im_iterator);
            end loop;
         end if;

         free_container (succ_ib.all);
         free (succ_ib, False);
      end remove_segment_interference;

      procedure branchinterference
        (tau_ab      : in     generic_task_ptr;
         tau_ik      : in     generic_task_ptr;
         tau_ib      : in     generic_task_ptr;
         w           : in     Integer;
         p           : in     Integer;
         tau_ac      : in     generic_task_ptr;
         branchi     : in out Integer;
         branchdelta : in out Integer)
      is
         pred_ib : generic_task_ptr;

         sb       : tasks_set;
         sectioni : Integer := 0;

         tau_is_iterator : tasks_iterator;
         tau_is          : generic_task_ptr;

         bi           : Integer := 0;
         bd           : Integer := 0;
         subbranchesi : Integer := 0;
         subbdelta    : Integer := 0;
      begin
         -- This differs a bit from the way Redell computes sectionI.
         -- We don't use a magical "S set" (i.e. H_im(tau_ab)), but a recursive algorithm.
         -- The recursive algorithm is more optimized for Cheddar ADL than computing H_im(tau_ab).
         compute_sb_sectioni
           (tau_ib,
            tau_ib,
            tau_ab,
            tau_ik,
            w,
            p,
            tau_ac,
            sb,
            sectioni);

         -- DELTA: Since we add a hpi task in SB if it does not succeed immediately its predecessor in H_seg_iB, we can call BranchInterference on the former
         -- so it needs to contribute to the interference.
         if in_hpi (tau_ib, tau_ab) then
            sectioni :=
              sectioni +
              taskinterference (tau_ab, tau_ik, tau_ib, w, p, tau_ac);
         end if;

         if not is_empty (sb) then
            reset_iterator (sb, tau_is_iterator);
            loop
               current_element (sb, tau_is, tau_is_iterator);

               branchinterference
                 (tau_ab,
                  tau_ik,
                  tau_is,
                  w,
                  p,
                  tau_ac,
                  bi,
                  bd);

               subbdelta    := max (subbdelta, bd);
               subbranchesi := subbranchesi + bi;

               exit when is_last_element (sb, tau_is_iterator);
               next_element (sb, tau_is_iterator);
            end loop;
         end if;

         if in_lpi (tau_ib, tau_ab) then
            branchi     := subbranchesi;
            branchdelta := max (sectioni - subbranchesi, subbdelta);

            -- DELTA: If tau_iB (in lpi) is not an immediate successor of pred_iB
            -- then only its branchDelta needs to be checked to see if it is lower than 0
            -- since a delta task between pred_iB and tau_iB would return the same branchI, and only check
            -- if branchDelta is higher than 0, as explained below formally.
            pred_ib := pred (tau_ib);
            if pred_ib /= null and then not is_immediate (pred_ib, tau_ib) then
               -- If tau_G between pred(tau_iB) and tau_iB:
               -- branchI := max(sectionI, subBranchesI) := max(0, subBranchesI) := subBranchesI where subBranchesI is branchI returned by tau_iB;
               -- branchDelta := max(subBranchesI + subBDelta - branchI, 0) := max(subBranchesI + subBDelta - subBranchesI, 0) := max(subBDelta) where subBDelta is branchDelta returned by tau_iB
               branchdelta := max (branchdelta, 0);
            end if;
         else
            branchi     := max (sectioni, subbranchesi);
            branchdelta := max (subbranchesi + subbdelta - branchi, 0);
            -- DELTA: here we do not check if tau_iB is an immediate successor of pred_iB  (in not hpi case) since even adding a delta between tau_iB and pred_iB
            -- would result in the same [branchI, branchDelta] returned by delta to pred_iB.
         end if;

         -- Free(SB, False);
      end branchinterference;

      -- DELTA J: New function
      procedure check_immediateness
        (gamma_i : in generic_task_group_ptr;
         tau_ab  : in generic_task_ptr;
         tau_ik  : in generic_task_ptr;
         p       : in Integer)
      is
         tau_ij_iterator : generic_task_iterator;
         tau_ij          : generic_task_ptr;

         p_seg_0ikk : Integer;

         t_i        : Integer;
         varphi_ijk : Integer;
         r_ij       : Integer;
      --pred_ij : Generic_Task_Ptr;
      --varphi_ipk : Integer;
      --r_ip : Integer;
      begin
         if not is_empty (gamma_i.task_list) then
            reset_head_iterator (gamma_i.task_list, tau_ij_iterator);
            loop
               current_element (gamma_i.task_list, tau_ij, tau_ij_iterator);

               if in_hpi (tau_ij, tau_ab) and
                 not is_immediate_successor (tau_ij)
               then
                  p_seg_0ikk := p0_seg (tau_ik, tau_ik, tau_ab);

                  if tau_ij.name /= tau_ik.name or
                    periodic_task_ptr (tau_ik).jitter /= 0 or
                    p /= p_seg_0ikk
                  then -- tau_ij potentialy considered immediate case
                     --pred_ij := pred(tau_ij);

                     t_i := periodic_task_ptr (tau_ij).period;

                     varphi_ijk := varphi (tau_ij, tau_ik);
                     r_ij := varphi_ijk + (p - 1) * t_i; -- tau_iB release @ p

                     --varphi_ipk := varphi(pred_ij, tau_ik);
                  --r_iP := varphi_iPk + (p - 1) * T_i; -- tau_iP release @ p

                     -- tau_ij considered immediate if true
                     if r_ij <
                       0
                     then  -- TODO: or else (r_ij > 0 and r_ip + C_ip + something >= r_is)
                        force_immediate_task (tau_ij);
                     end if;
                  end if;
               end if;

               exit when is_tail_element (gamma_i.task_list, tau_ij_iterator);
               next_element (gamma_i.task_list, tau_ij_iterator);
            end loop;
         end if;
      end check_immediateness;

      procedure transactioninterference
        (tau_ab     : in     generic_task_ptr;
         tau_ik     : in     generic_task_ptr;
         w          : in     Integer;
         tau_ac     : in     generic_task_ptr;
         transi_nob : in out Integer;
         transi_b   : in out Integer)
      is
         p_seg_0ink : Integer;
         jobi       : Integer := 0;
         jobdelta   : Integer := 0;
         transdelta : Integer := 0;

         gamma_i  : generic_task_group_ptr;
         tau_i1   : generic_task_ptr;
         tau_i0   : generic_task_ptr;
         h_seg_in : generic_task_ptr;
      begin
         transi_b   := 0;
         transi_nob := 0;

-- Add ghost root task: placed here for understanding.
-- Can be moved to somewhere earlier for optimization (e.g. Max_WWB function)
         gamma_i := search_task_group_by_task (my_system.task_groups, tau_ik);
         tau_i1  := get_root_task (gamma_i);

         tau_i0          := new generic_task; -- Scheduling_Task?
         tau_i0.name     := To_Unbounded_String ("wcdops+_ghost_root");
         tau_i0.cpu_name := To_Unbounded_String ("wcdops+_ghost_cpu");
         tau_i0.priority := 0;

         --Add(My_System.Tasks, tau_i0);
         add_one_task_dependency_precedence
           (my_system.dependencies,
            tau_i0,
            tau_i1);

         -- Last segment of Gamma_i
         h_seg_in := get_first_task_in_hseg_n (gamma_i, tau_ab);

         if h_seg_in /= null then
            p_seg_0ink := p0_seg (h_seg_in, tau_ik, tau_ab);

            -- Compute transI_NoB, transDelta and transI_B
            for p in p_seg_0ink .. 0 loop
               -- DELTA J: Force some tasks, at instance p of Gamma_i, to be immediate if they are not.
               check_immediateness
                 (gamma_i,
                  tau_ab,
                  tau_ik,
                  p); -- we can probably get p0 and then check if which earliest task jitter to the bp

               branchinterference
                 (tau_ab,
                  tau_ik,
                  tau_i0,
                  w,
                  p,
                  tau_ac,
                  jobi,
                  jobdelta);
               transi_nob := transi_nob + jobi;
               transdelta := max (transdelta, jobdelta);

               -- DELTA J: Unforce all immediateness
               clear_forced_immediate_tasks_set;
            end loop;

            transi_b := transi_nob + transdelta;
         end if;

         -- Free tau_i0
         delete_one_task_dependency_precedence
           (my_system.dependencies,
            tau_i0,
            tau_i1);
         Free (tau_i0);
      end transactioninterference;

      function w_mp
        (tau_ik : generic_task_ptr;
         tau_ab : generic_task_ptr;
         w      : Integer) return Integer
      is
         gamma_i         : generic_task_group_ptr;
         tau_ij_iterator : generic_task_iterator;
         tau_ij          : generic_task_ptr;

         c_ij           : Integer;
         t_i            : Integer;
         w_ik_p         : Integer := 0;
         varphi_seg_ijk : Integer;
      begin
         gamma_i := search_task_group_by_task (my_system.task_groups, tau_ik);

         if not is_empty (gamma_i.task_list) then
            reset_head_iterator (gamma_i.task_list, tau_ij_iterator);
            loop
               current_element (gamma_i.task_list, tau_ij, tau_ij_iterator);

               if in_mpi (tau_ij, tau_ab) then
                  if tau_ij.task_type /= periodic_type then
                     raise generic_wcdops_plus_exception;
                  end if;

                  c_ij           := tau_ij.capacity;
                  t_i            := periodic_task_ptr (tau_ij).period;
                  varphi_seg_ijk := varphi_seg (tau_ij, tau_ik, tau_ab);

                  -- Equation (19)
                  w_ik_p :=
                    w_ik_p +
                    ceil0 (Double (w - varphi_seg_ijk) / Double (t_i)) * c_ij;
               end if;

               exit when is_tail_element (gamma_i.task_list, tau_ij_iterator);
               next_element (gamma_i.task_list, tau_ij_iterator);
            end loop;
         end if;

         return w_ik_p;
      end w_mp;

      -- [Wik(tau_ab, w, tau_ac), WBik(tau_ab, w, tau_ac)] => Equation (20)
      procedure wwb
        (tau_ik : in     generic_task_ptr;
         tau_ab : in     generic_task_ptr;
         w      : in     Integer;
         tau_ac : in     generic_task_ptr;
         w_ik   :    out Integer;
         wb_ik  :    out Integer)
      is
         transi_nob : Integer := 0;
         transi_b   : Integer := 0;
         w_ik_p     : Integer; -- W_ik for p > 0
      begin
         transactioninterference
           (tau_ab,
            tau_ik,
            w,
            tau_ac,
            transi_nob,
            transi_b);

         w_ik_p := w_mp (tau_ik, tau_ab, w);

         -- Second part of Equation (20)
         w_ik  := transi_nob + w_ik_p;
         wb_ik := transi_b + w_ik_p;
      end wwb;

      -- [W_i*, WB_i*] => Equations (21) and (22) in one function
      procedure max_wwb
        (gamma_i : in     generic_task_group_ptr;
         tau_ab  : in     generic_task_ptr;
         w       : in     Integer;
         tau_ac  : in     generic_task_ptr;
         w_i     :    out Integer;
         wb_i    :    out Integer)
      is
         tau_ik_iterator : tasks_iterator;
         tau_ik          : generic_task_ptr;

         w_ik  : Integer;
         wb_ik : Integer;

         xp_i : tasks_set_ptr;

         -- DELTA J
         j_ik    : Integer;
         case0   : Integer;
         pred_ik : generic_task_ptr;
      begin
         w_i  := 0;
         wb_i := 0;

         xp_i := xp (gamma_i, tau_ab);

         if not is_empty (xp_i.all) then
            reset_iterator (xp_i.all, tau_ik_iterator);
            loop
               current_element (xp_i.all, tau_ik, tau_ik_iterator);

               -- DELTA J: tau_ik starting BP task is not immediate
               case0 := 1;
               if not is_immediate_successor (tau_ik) then
                  pred_ik := pred (tau_ik);

                  if not in_hpi (pred_ik, tau_ab) then
                     case0 := 0;
                  end if;
               end if;

               for casei in case0 .. 1 loop
                  -- DELTA J: See main procedure for tau_ik jitter cases
                  if casei = 0 then
                     j_ik := periodic_task_ptr (tau_ik).jitter;
                     periodic_task_ptr (tau_ik).jitter := 0;
                  end if;

                  wwb (tau_ik, tau_ab, w, tau_ac, w_ik, wb_ik);

                  w_i  := max (w_i, w_ik);
                  wb_i := max (wb_i, wb_ik);

                  -- DELTA J: See main procedure fot tau_ik jitter cases
                  if casei = 0 then
                     periodic_task_ptr (tau_ik).jitter := j_ik;
                  end if;
               end loop;

               exit when is_last_element (xp_i.all, tau_ik_iterator);
               next_element (xp_i.all, tau_ik_iterator);
            end loop;
         end if;

         free_container (xp_i.all);
         free (xp_i, False);
      end max_wwb;

      -- Busy period estimation
      function l
        (tau_ab : in generic_task_ptr;
         tau_ac : in generic_task_ptr) return Integer
      is
         l   : Integer;
         l_w : Integer;

         c_ab       : Integer;
         b_ab       : Integer;
         w_l_ac     : Integer;
         wb_l_ac    : Integer;
         dw_l_ac    : Integer;
         dw_i       : Integer;
         sum_max_wi : Integer := 0;
         max_dw_i   : Integer := 0;
         w_i        : Integer;
         wb_i       : Integer;

         convergence : Boolean := False;

         gamma_iterator : task_groups_iterator;
         gamma_i        : generic_task_group_ptr;
         gamma_a        : generic_task_group_ptr;
      begin
         gamma_a := search_task_group_by_task (my_system.task_groups, tau_ab);

         c_ab := tau_ab.capacity;
         b_ab := tau_ab.blocking_time;

         l := c_ab + b_ab;

         loop
            -- Compute W_ac' and WB_ac' with equation (20)
            --  tau_ik  tau_ab  w  tau_ac  Wik    WBik
            wwb (tau_ac, tau_ab, l, tau_ac, w_l_ac, wb_l_ac);
            dw_l_ac := wb_l_ac - w_l_ac;

            sum_max_wi := 0;
            max_dw_i   := 0;
            reset_iterator (my_system.task_groups, gamma_iterator);
            loop
               current_element
                 (my_system.task_groups,
                  gamma_i,
                  gamma_iterator);

               if gamma_i.name /= gamma_a.name then
                  -- Equation (21) and (22) all in one function
                  --      i        tau_ab  w  tau_ac -> for reduction rules
                  max_wwb
                    (gamma_i,
                     tau_ab,
                     l,
                     tau_ac,
                     w_i,
                     wb_i); -- Gives W_i := max(W_ik) and WB_i := max(WB_ik) for all tau_ik
                  dw_i := wb_i - w_i;

                  -- To compute term 3 and 4 of equation (34)
                  sum_max_wi :=
                    sum_max_wi + w_i; -- W_i is summed for all Gamma_i
                  max_dw_i :=
                    max (max_dw_i, dw_i); -- DW_i is compared for all Gamma_i
               end if;

               exit when is_last_element
                   (my_system.task_groups,
                    gamma_iterator);
               next_element (my_system.task_groups, gamma_iterator);
            end loop;

            -- Equation (34)
            l_w := b_ab + w_l_ac + sum_max_wi + max (dw_l_ac, max_dw_i);

            if l = l_w then
               convergence := True;
            end if;

            l := l_w;

            -- Warning: inifinity loop possible here, if no convergence. No convergence when CPU utilization > 100%
            -- TODO: Before starting the analysis, check that CPU utilization <= 100%
            exit when convergence;
         end loop;

         return l;
      end l;

      function pl_seg
        (tau_ab : generic_task_ptr;
         tau_ac : generic_task_ptr) return Integer
      is
         varphi_seg_0abc : Integer;
         l_abc           : Integer;
         t_a             : Integer;
      begin
         if tau_ac.task_type /= periodic_type then
            raise generic_wcdops_plus_exception;
         end if;

         l_abc           := l (tau_ab, tau_ac);
         varphi_seg_0abc := varphi_seg (tau_ab, tau_ac, tau_ab);
         t_a             := periodic_task_ptr (tau_ac).period;

         if in_mpi (tau_ab, tau_ab) then
            return ceil0 (Double (l_abc - varphi_seg_0abc) / Double (t_a));
         end if;
         -- Note: Case where C < B and not same_h(A, B, C) is not needed because different segments is already handled in Redell (to verify).

         return 0;
      end pl_seg;

      function taskinterference_gamma_a
        (tau_ab : generic_task_ptr;
         tau_ac : generic_task_ptr;
         tau_aj : generic_task_ptr;
         w      : Integer;
         p      : Integer;
         p_ab   : Integer) return Integer
      is
         taski : Integer := 0;

         p_seg_0ajc     : Integer;
         p_seg_0acc     : Integer;
         varphi_seg_ajc : Integer;
         t_a            : Integer;
         c_aj           : Integer;

         h_seg_ac      : generic_task_ptr;
         h_seg_aj      : generic_task_ptr;
         h_seg_ab      : generic_task_ptr;
         pred_h_seg_ac : generic_task_ptr;
         pred_h_seg_aj : generic_task_ptr;
         pred_h_seg_ab : generic_task_ptr;
      begin
         if tau_aj.task_type /= periodic_type then
            raise generic_wcdops_plus_exception;
         end if;

         p_seg_0ajc     := p0_seg (tau_aj, tau_ac, tau_ab);
         varphi_seg_ajc := varphi_seg (tau_aj, tau_ac, tau_ab);
         t_a            := periodic_task_ptr (tau_aj).period;
         c_aj           := tau_aj.capacity;

         if p >= p_seg_0ajc and w > varphi_seg_ajc + (p - 1) * t_a then
            taski := c_aj;

            p_seg_0acc := p0_seg (tau_ac, tau_ac, tau_ab);
            h_seg_ac   := first_task_in_hseg (tau_ac, tau_ab);
            h_seg_aj   := first_task_in_hseg (tau_aj, tau_ab);
            h_seg_ab   := first_task_in_hseg (tau_ab, tau_ab);

            pred_h_seg_ac := pred (h_seg_ac);
            pred_h_seg_aj := pred (h_seg_aj);
            pred_h_seg_ab := pred (h_seg_ab);

-- Note: a pred of a Hseg cannot be null
-- beacuse First_Task_In_Hseg never returns null if we add a ghost root task.
-- So condition "pred /= null" is not needed.

            if
              (p >= p_seg_0acc
               and then seg_precedes (tau_ac, tau_aj, tau_ab)
               and then not same_hsec (tau_ac, tau_aj, tau_ab)) -- Rule 1b
              or else
              (pred_h_seg_ac /= null
               and then in_lpi (pred_h_seg_ac, tau_ab)
               and then pred_h_seg_aj /= null
               and then in_lpi (pred_h_seg_aj, tau_ab)
               and then
               (p /= p_seg_0acc
                or else not same_hseg (h_seg_ac, h_seg_aj, tau_ab))) -- Rule 2b
              or else
              (pred_h_seg_ab /= null
               and then in_lpi (pred_h_seg_ab, tau_ab)
               and then pred_h_seg_aj /= null
               and then in_lpi (pred_h_seg_aj, tau_ab)
               and then
               (p /= p_ab
                or else not same_hseg (h_seg_ab, h_seg_aj, tau_ab))) -- Rule 3b
              or else
              (p <= p_ab
               and then seg_precedes (tau_aj, tau_ab, tau_ab)
               and then not same_hsec (tau_ab, tau_aj, tau_ab)) -- Rule 4b
              or else
              ((p >= p_ab and then precedes (tau_ab, tau_aj)) -- Rule 5b
               or else
               (p >= p_ab
                and then seg_precedes (tau_ab, tau_aj, tau_ab)
                and then not same_hsec (tau_ac, tau_ab, tau_ab))
               or else (p > p_ab and tau_ab.name = tau_aj.name))
              or else
              (not is_immediate_successor (tau_ac)
               and then periodic_task_ptr (tau_ac).jitter = 0
               and then p <= p_seg_0acc
               and then precedes (tau_aj, tau_ac))
            then -- DELTA J: Rule 6b (equivalent 5a)
               taski := 0;
            end if;
         end if;

         return taski;
      end taskinterference_gamma_a;

      procedure compute_sb_sectioni_gamma_a
        (tau_abr  : in     generic_task_ptr;
         root     : in     generic_task_ptr;
         tau_ab   : in     generic_task_ptr;
         tau_ac   : in     generic_task_ptr;
         w        : in     Integer;
         p        : in     Integer;
         p_ab     : in     Integer;
         sb       :    out tasks_set;
         sectioni : in out Integer)
      is
         succ_abr             : tasks_set_ptr;
         tau_am_iterator      : tasks_iterator;
         tau_am               : generic_task_ptr;
         root_preceeds_a_hseg : Boolean;
      begin
         succ_abr := succ (tau_abr);

         if not is_empty (succ_abr.all) then
            -- Check that tau_iB actually preceeds a segment
            reset_iterator (succ_abr.all, tau_am_iterator);
            loop
               current_element (succ_abr.all, tau_am, tau_am_iterator);

               if (tau_abr.name /= root.name)
                 or else
                 (in_hpi (tau_am, tau_ab)
                  and then is_immediate (tau_abr, tau_am))
               then
                  root_preceeds_a_hseg := True;
               end if;

               exit when is_last_element (succ_abr.all, tau_am_iterator)
                 or else root_preceeds_a_hseg;
               next_element (succ_abr.all, tau_am_iterator);
            end loop;

            reset_iterator (succ_abr.all, tau_am_iterator);
            loop
               current_element (succ_abr.all, tau_am, tau_am_iterator);

               if in_hpi (tau_am, tau_ab) then
                  if not is_immediate (tau_abr, tau_am) then
                     -- DELTA: See function Compute_SB_SectionI
                     compute_sb (root, tau_am, tau_ab, sb);
                  end if;

                  if root_preceeds_a_hseg then
                     sectioni :=
                       sectioni +
                       taskinterference_gamma_a
                         (tau_ab,
                          tau_ac,
                          tau_am,
                          w,
                          p,
                          p_ab);
                     compute_sb_sectioni_gamma_a
                       (tau_am,
                        root,
                        tau_ab,
                        tau_ac,
                        w,
                        p,
                        p_ab,
                        sb,
                        sectioni);
                  end if;
               elsif in_lpi (tau_am, tau_ab) then
                  -- DELTA: We cannot add tau_am directly, since it can have a non-immediate hpi task as predecessor
                  compute_sb (root, tau_am, tau_ab, sb);
               else
                  compute_sb (root, tau_am, tau_ab, sb);

                  if root_preceeds_a_hseg then
                     compute_sb_sectioni_gamma_a
                       (tau_am,
                        root,
                        tau_ab,
                        tau_ac,
                        w,
                        p,
                        p_ab,
                        sb,
                        sectioni);
                  end if;
               end if;

               exit when is_last_element (succ_abr.all, tau_am_iterator);
               next_element (succ_abr.all, tau_am_iterator);
            end loop;
         end if;

         free_container (succ_abr.all);
         free (succ_abr, False);
      end compute_sb_sectioni_gamma_a;

      procedure remove_segment_interference_gamma_a
        (tau_abr : in     generic_task_ptr;
         tau_ab  : in     generic_task_ptr;
         tau_ac  : in     generic_task_ptr;
         w       : in     Integer;
         p       : in     Integer;
         p_ab    : in     Integer;
         bi      : in out Integer)
      is
         succ_abr        : tasks_set_ptr;
         tau_am_iterator : tasks_iterator;
         tau_am          : generic_task_ptr;
      begin
         if in_hpi (tau_abr, tau_ab) then
            bi :=
              bi - taskinterference (tau_ab, tau_ac, tau_abr, w, p, tau_ac);
         end if;

         succ_abr := succ (tau_abr);

         if not is_empty (succ_abr.all) then
            -- Check that tau_iB actually preceeds a segment
            reset_iterator (succ_abr.all, tau_am_iterator);
            loop
               current_element (succ_abr.all, tau_am, tau_am_iterator);

               if in_hpi (tau_am, tau_ab)
                 and then same_hseg (tau_abr, tau_am, tau_ab)
               then
                  bi :=
                    bi -
                    taskinterference_gamma_a
                      (tau_ab,
                       tau_ac,
                       tau_am,
                       w,
                       p,
                       p_ab);
                  remove_segment_interference_gamma_a
                    (tau_am,
                     tau_ab,
                     tau_ac,
                     w,
                     p,
                     p_ab,
                     bi);
               end if;

               exit when is_last_element (succ_abr.all, tau_am_iterator);
               next_element (succ_abr.all, tau_am_iterator);
            end loop;
         end if;

         free_container (succ_abr.all);
         free (succ_abr, False);
      end remove_segment_interference_gamma_a;

      procedure branchinterference_gamma_a
        (tau_ab      : in     generic_task_ptr;
         tau_ac      : in     generic_task_ptr;
         tau_abr     : in     generic_task_ptr;
         w           : in     Integer;
         p           : in     Integer;
         p_ab        : in     Integer;
         branchi     : in out Integer;
         branchdelta : in out Integer)
      is
         pred_abr   : generic_task_ptr;
         p_seg_0acc : Integer;

         sb       : tasks_set;
         sectioni : Integer := 0;

         tau_as_iterator : tasks_iterator;
         tau_as          : generic_task_ptr;

         bi           : Integer := 0;
         bd           : Integer := 0;
         subbranchesi : Integer := 0;
         subbdelta    : Integer := 0;
      begin
         compute_sb_sectioni_gamma_a
           (tau_abr,
            tau_abr,
            tau_ab,
            tau_ac,
            w,
            p,
            p_ab,
            sb,
            sectioni);

         if in_hpi (tau_abr, tau_ab) then
            sectioni :=
              sectioni +
              taskinterference_gamma_a (tau_ab, tau_ac, tau_abr, w, p, p_ab);
         end if;

         if not is_empty (sb) then
            p_seg_0acc := p0_seg (tau_ac, tau_ac, tau_ab);

            reset_iterator (sb, tau_as_iterator);
            loop
               current_element (sb, tau_as, tau_as_iterator);

               branchinterference_gamma_a
                 (tau_ab,
                  tau_ac,
                  tau_as,
                  w,
                  p,
                  p_ab,
                  bi,
                  bd);

               subbranchesi := subbranchesi + bi;
               subbdelta    := max (subbdelta, bd);

               exit when is_last_element (sb, tau_as_iterator);
               next_element (sb, tau_as_iterator);
            end loop;
         end if;

         if in_lpi (tau_abr, tau_ab) then
            branchi     := subbranchesi;
            branchdelta := max (sectioni - subbranchesi, subbdelta);

            pred_abr := pred (tau_abr);
            if pred_abr /= null
              and then not is_immediate (pred_abr, tau_abr)
            then
               branchdelta := max (subbdelta, 0);
            end if;
         else
            branchi     := max (sectioni, subbranchesi);
            branchdelta := max (subbranchesi + subbdelta - branchi, 0);
         end if;

         --Free(SB, False);
      end branchinterference_gamma_a;

      procedure transactioninterference_gamma_a
        (tau_ac     : in     generic_task_ptr;
         tau_ab     : in     generic_task_ptr;
         w          : in     Integer;
         p_ab       : in     Integer;
         transi_nob : in out Integer;
         transi_b   : in out Integer)
      is
         p_seg_0anc : Integer;
         jobi       : Integer := 0;
         jobdelta   : Integer := 0;
         transdelta : Integer := 0;

         gamma_a  : generic_task_group_ptr;
         tau_a1   : generic_task_ptr;
         tau_a0   : generic_task_ptr;
         h_seg_an : generic_task_ptr;
      begin
         transi_nob := 0;
         transi_b   := 0;

-- Add ghost root task: placed here for understanding.
-- Can be moved to somewhere earlier for optimization (e.g. Max_WWB function)
         gamma_a := search_task_group_by_task (my_system.task_groups, tau_ac);
         tau_a1  := get_root_task (gamma_a);

         tau_a0          := new generic_task; -- Scheduling_Task?
         tau_a0.name     := To_Unbounded_String ("wcdops+_ghost_root");
         tau_a0.cpu_name := To_Unbounded_String ("wcdops+_ghost_cpu");
         tau_a0.priority := 0;

         --Add(My_System.Tasks, tau_a0);
         add_one_task_dependency_precedence
           (my_system.dependencies,
            tau_a0,
            tau_a1);

         h_seg_an := get_first_task_in_hseg_n (gamma_a, tau_ab);

         if h_seg_an /= null then
            p_seg_0anc := p0_seg (h_seg_an, tau_ac, tau_ab);

            -- Compute transI_NoB, transDelta and transI_B
            for p in p_seg_0anc .. 0 loop
               -- DELTA J: See TransactionInterference_Gamma_a
               check_immediateness (gamma_a, tau_ab, tau_ac, p);

               branchinterference_gamma_a
                 (tau_ab,
                  tau_ac,
                  tau_a0,
                  w,
                  p,
                  p_ab,
                  jobi,
                  jobdelta);
               transi_nob := transi_nob + jobi;
               transdelta := max (transdelta, jobdelta);

               -- DELTA J: Unforce all immediateness
               clear_forced_immediate_tasks_set;
            end loop;

            transi_b := transi_nob + transdelta;
         end if;

         -- Free tau_a0
         delete_one_task_dependency_precedence
           (my_system.dependencies,
            tau_a0,
            tau_a1);
         Free (tau_a0);
      end transactioninterference_gamma_a;

      function w_mp_gamma_a
        (tau_ac : generic_task_ptr;
         tau_ab : generic_task_ptr;
         w      : Integer;
         p_ab   : Integer) return Integer
      is
         gamma_a         : generic_task_group_ptr;
         tau_aj_iterator : generic_task_iterator;
         tau_aj          : generic_task_ptr;

         c_aj           : Integer;
         t_a            : Integer;
         varphi_seg_ajc : Integer;
         c_ab           : Integer;

         w_ac_p_1 : Integer := 0;
         w_ac_p_2 : Integer := 0;
         w_ac_p   : Integer := 0;
      begin
         gamma_a := search_task_group_by_task (my_system.task_groups, tau_ac);

         if not is_empty (gamma_a.task_list) then
            reset_head_iterator (gamma_a.task_list, tau_aj_iterator);
            loop
               current_element (gamma_a.task_list, tau_aj, tau_aj_iterator);

               if in_mpi (tau_aj, tau_ab) and tau_aj.name /= tau_ab.name then
                  if tau_aj.task_type /= periodic_type then
                     raise generic_wcdops_plus_exception;
                  end if;

                  c_aj           := tau_aj.capacity;
                  t_a            := periodic_task_ptr (tau_aj).period;
                  varphi_seg_ajc := varphi_seg (tau_aj, tau_ac, tau_ab);

                  if not precedes (tau_ab, tau_aj) then
                     -- Equation (26)
                     w_ac_p_1 :=
                       w_ac_p_1 +
                       ceil0 (Double (w - varphi_seg_ajc) / Double (t_a)) *
                         c_aj;
                  else
                     -- Equation (27)
                     w_ac_p_2 :=
                       w_ac_p_2 +
                       min
                         (p_ab - 1,
                          ceil0 (Double (w - varphi_seg_ajc) / Double (t_a)) *
                          c_aj);
                  end if;
               end if;

               exit when is_tail_element (gamma_a.task_list, tau_aj_iterator);
               next_element (gamma_a.task_list, tau_aj_iterator);
            end loop;

            c_ab := tau_ab.capacity;

            w_ac_p := w_ac_p_1 + max (0, p_ab * c_ab + w_ac_p_2);
         end if;

         return w_ac_p;
      end w_mp_gamma_a;

      -- [Wac(tau_ab, w, p_ab), WBac(tau_ab, w, p_ab)] => Equation (29)
      procedure wwb_gamma_a
        (tau_ac : in     generic_task_ptr;
         tau_ab : in     generic_task_ptr;
         w      : in     Integer;
         p_ab   :        Integer;
         w_ac   :    out Integer;
         wb_ac  :    out Integer)
      is
         transi_nob : Integer := 0;
         transi_b   : Integer := 0;
         w_ac_p     : Integer; -- W_ac for p > 0
      begin
         transactioninterference_gamma_a
           (tau_ac,
            tau_ab,
            w,
            p_ab,
            transi_nob,
            transi_b);

         w_ac_p := w_mp_gamma_a (tau_ac, tau_ab, w, p_ab);

         -- Second part of Equation (29)
         w_ac  := transi_nob + w_ac_p;
         wb_ac := transi_b + w_ac_p;
      end wwb_gamma_a;

      function w
        (tau_ab : generic_task_ptr;
         tau_ac : generic_task_ptr;
         p_ab   : Integer) return Integer
      is
         w   : Integer;
         w_w : Integer; -- Smiley variable is not amused...

         c_ab   : Integer; -- For initial w
         b_ab   : Integer; -- 1st element
         w_ac   : Integer; -- 2nd element
         p_0abc : Integer;

         w_i        : Integer;
         wb_i       : Integer;
         sum_max_wi : Integer; -- 3rd element
         dw_i       : Integer; -- To compute 2nd part of 4th element
         max_dw_i   : Integer := 0; -- 2nd part of 4th element
         wb_ac      : Integer; -- To compute 1st part of 4th element
         dw_ac      : Integer; -- 1st part of 4th element

         gamma_iterator : task_groups_iterator;
         gamma_i        : generic_task_group_ptr;
         gamma_a        : generic_task_group_ptr;

         convergence : Boolean := False;
      begin
         gamma_a := search_task_group_by_task (my_system.task_groups, tau_ab);

         c_ab := tau_ab.capacity;
         b_ab := tau_ab.blocking_time;

         p_0abc := p0 (tau_ab, tau_ac); -- Note: not p_seg_0abc but p_0abc
         w      := (p_ab - p_0abc + 1) * c_ab + b_ab;

         loop
         -- Compute W_ac and DW_ac of Equation (32) and part 1 of Equation (31)
            wwb_gamma_a (tau_ac, tau_ab, w, p_ab, w_ac, wb_ac);
            dw_ac := wb_ac - w_ac;

            -- Compute Equation (32)'s part 3 and Equation (31)'s part 2
            sum_max_wi := 0;
            max_dw_i   := 0;
            reset_iterator (my_system.task_groups, gamma_iterator);
            loop
               current_element
                 (my_system.task_groups,
                  gamma_i,
                  gamma_iterator);

               if gamma_i.name /= gamma_a.name then
                  -- Equation (21) and (22) all in one function
                  --      i        tau_ab  w  tau_ac -> for reduction rules
                  max_wwb
                    (gamma_i,
                     tau_ab,
                     w,
                     tau_ac,
                     w_i,
                     wb_i); -- Gives W_i* := max(W_ik) and WB_i* := max(WB_ik) for all tau_ik
                  dw_i := wb_i - w_i;

                  sum_max_wi :=
                    sum_max_wi + w_i; -- W_i is summed for all Gamma_i
                  max_dw_i :=
                    max (max_dw_i, dw_i); -- DW_i is compared for all Gamma_i
               end if;

               exit when is_last_element
                   (my_system.task_groups,
                    gamma_iterator);
               next_element (my_system.task_groups, gamma_iterator);
            end loop;

            -- Equation (32)
            w_w := b_ab + w_ac + sum_max_wi + max (dw_ac, max_dw_i);

            if w = w_w then
               convergence := True;
            end if;

            w := w_w;

            -- Warning: inifinity loop possible here, if no convergence. No convergence when CPU utilization > 100%
            -- TODO: Before starting the analysis, check that CPU utilization <= 100%
            exit when convergence;
         end loop;

         return w;
      end w;

      procedure estimate_successors_response_time
        (tau_ij : in generic_task_ptr)
      is
         succ_ij       : tasks_set_ptr;
         succ_iterator : tasks_iterator;
         succ_task     : generic_task_ptr;

         r_tau_ij : Integer;
         r_succ   : Integer;
         c_ij     : Integer;
      begin
         succ_ij := succ (tau_ij);

         if not is_empty (succ_ij.all) then
            reset_iterator (succ_ij.all, succ_iterator);
            loop
               current_element (succ_ij.all, succ_task, succ_iterator);

               r_tau_ij := get_response (tau_ij);
               r_succ   := get_response (succ_task);
               c_ij     := tau_ij.capacity;

               if r_succ < r_tau_ij then
                  set_response (succ_task, r_tau_ij + c_ij);
               end if;

               estimate_successors_response_time (succ_task);

               exit when is_last_element (succ_ij.all, succ_iterator);
               next_element (succ_ij.all, succ_iterator);
            end loop;
         end if;

         free_container (succ_ij.all);
         free (succ_ij, False);
      end estimate_successors_response_time;

      procedure estimate_predecessor_response_time
        (tau_ij : in generic_task_ptr)
      is
         pred_ij   : generic_task_ptr;
         r_tau_ij  : Integer;
         r_pred_ij : Integer;
         c_ij      : Integer;
      begin
         pred_ij := pred (tau_ij);

         if pred_ij /= null then
            r_tau_ij  := get_response (tau_ij);
            r_pred_ij := get_response (pred_ij);
            c_ij      := tau_ij.capacity;

            if r_tau_ij > r_pred_ij then
               set_response (pred_ij, r_tau_ij - c_ij);
            end if;

            estimate_predecessor_response_time (pred_ij);
         end if;
      end estimate_predecessor_response_time;

      procedure update_successors_jitter (tau_ij : in generic_task_ptr) is
         succ_ij       : tasks_set_ptr;
         succ_iterator : tasks_iterator;
         succ_task     : generic_task_ptr;
      begin
         succ_ij := succ (tau_ij);

         if not is_empty (succ_ij.all) then
            reset_iterator (succ_ij.all, succ_iterator);
            loop
               current_element (succ_ij.all, succ_task, succ_iterator);

               if succ_task.task_type /= periodic_type then
                  raise generic_wcdops_plus_exception;
               end if;

               periodic_task_ptr (succ_task).jitter :=
                 max (get_offset (succ_task), get_response (tau_ij)) -
                 get_offset (succ_task);

               update_successors_jitter (succ_task);

               exit when is_last_element (succ_ij.all, succ_iterator);
               next_element (succ_ij.all, succ_iterator);
            end loop;
         end if;

         free_container (succ_ij.all);
         free (succ_ij, False);
      end update_successors_jitter;

      -- Local variables --

      gamma_iterator : task_groups_iterator;
      gamma_a        : generic_task_group_ptr;

      tau_ab_iterator : generic_task_iterator;
      tau_ab          : generic_task_ptr;

      tau_ac_iterator : tasks_iterator;
      tau_ac          : generic_task_ptr;

      xp_a : tasks_set_ptr;

      r_w_ab  : Integer; -- Worst response of tau_ab
      r_w_abc : Integer; -- Worst response among reponses that depend on a tau_ab starting the BP and the analyzed p_ab
      r_ab    : Integer; -- To compare and store current and last response

      p_seg_0abc : Integer;
      p_seg_labc : Integer;

      w_abc      : Integer;
      varphi_abc : Integer;
      t_a        : Integer;
      o_ab       : Integer;

      convergence : Boolean;

      -- DELTA
--        pred_ab : Generic_Task_Ptr;
--        J_ab : Integer;
--        w_abc_FI : Integer;
--        w_abc_NI : Integer;
--        R_w_abc_FI : Integer;
--        R_w_abc_NI : Integer;

      -- DELTA J
      j_ac    : Integer;
      case0   : Integer;
      pred_ac : generic_task_ptr;

   -- TODO: Remove
   --X : Integer := 0;
   begin
      ---------------------------
      -- PROCEDURE BEGINS HERE --
      ---------------------------

      -- TODO a function to verify that the transaction is correct
      -- i.e. tree-shaped, offset values correct, no initial jitter...

      init_response_times (response_times);

      loop -- Convergence loop
         --put_line("***** X = " & X'Img & " *****");

         convergence := True;

         reset_iterator (my_system.task_groups, gamma_iterator);
         loop -- Transactions loop
            current_element (my_system.task_groups, gamma_a, gamma_iterator);

            if not is_empty (gamma_a.task_list) then
               reset_head_iterator (gamma_a.task_list, tau_ab_iterator);
               loop -- Analyzed tasks loop (tau_ab)
                  current_element (gamma_a.task_list, tau_ab, tau_ab_iterator);

--                    if tau_ab.name = "tau_12" then
--                       put_line("//// Analyzing tau_ab = " & to_string(tau_ab.name));
--                    end if;

                  r_ab   := get_response (tau_ab);
                  r_w_ab := 0;

                  xp_a := xp (gamma_a, tau_ab);
                  if not is_empty
                      (xp_a.all)
                  then -- Note: XP_a shouldn't be empty because at least tau_ab is in XP_a(tau_ab)
                     reset_iterator (xp_a.all, tau_ac_iterator);
                     loop -- BP starting tasks loop (tau_ac)
                        current_element (xp_a.all, tau_ac, tau_ac_iterator);

--                          if tau_ab.name = "tau_12" then
--                             put_line("  tau_ac = " & to_string(tau_ac.name));
--                          end if;

                        -- DELTA J: tau_ac starting BP task is not immediate
                        case0 := 1;
                        if not is_immediate_successor (tau_ac) then
                           pred_ac := pred (tau_ac);

                           if not in_hpi
                               (pred_ac,
                                tau_ab)
                           then -- 2 cases to check if the predecessor is not in lpi: tau_ac has jitter and no jitter
                              case0 := 0;
                           end if; -- otherwise if the pred is in hpi, the second case will be tested when the pred's segment starts BP
                        end if;

                        for casei in case0 .. 1 loop
               -- DELTA J: In the first case, the tau_ac's jitter is set to nil
               -- We memorize its jitter so we can set it back again later.
                           if casei = 0 then
                              j_ac := periodic_task_ptr (tau_ac).jitter;
                              periodic_task_ptr (tau_ac).jitter := 0;
                           end if;

            -- Compute p0 and pL for tau_ab's segment when tau_c starts the BP
                           p_seg_0abc := p0_seg (tau_ab, tau_ac, tau_ab);
                           p_seg_labc := pl_seg (tau_ab, tau_ac);

--                             if tau_ab.name = "tau_12" then
--                                put_line("  p_seg_0abc = " & p_seg_0abc'Img);
--                                put_line("  p_seg_Labc = " & p_seg_Labc'Img);
--                             end if;

                           -- For all p_ab in p0 to pL, take max R_w_ab
                           for p_ab in p_seg_0abc .. p_seg_labc loop
--                                if tau_ab.name = "tau_12" then
--                                   put_line("    @ p_ab = " & p_ab'Img);
--                                end if;

                              w_abc      := w (tau_ab, tau_ac, p_ab);
                              varphi_abc := varphi (tau_ab, tau_ac);
                              t_a        := periodic_task_ptr (tau_ab).period;
                              o_ab       := get_offset (tau_ab);

                              r_w_abc :=
                                w_abc - varphi_abc - (p_ab - 1) * t_a + o_ab;

--                                if tau_ab.name = "tau_12" then
--                                   put_line("        w_abc = " & w_abc'Img);
--                                   put_line("        varphi_abc = " & varphi_abc'Img);
--                                   put_line("        T_a = " & T_a'Img);
--                                   put_line("        O_ab = " & O_ab'Img);
--                                   put_line("        R_w_abc = " & R_w_abc'Img);
--                                end if;

                              -- Store maximum value of R_abc^w in R_ab^w
                              if r_w_abc > r_w_ab then
                                 r_w_ab := r_w_abc;
                              end if;

               -- Determine if R_w_abc is higher than deadline and stop if so
                              if stop_on_deadline_missed and
                                r_w_ab > get_global_deadline (tau_ab)
                              then
                                 raise deadline_missed_exception;
                              end if;
                           end loop;

      -- DELTA J: Set non-immediate tau_ac's jitter back (modified previously)
                           if casei = 0 then
                              periodic_task_ptr (tau_ac).jitter := j_ac;
                           end if;
                        end loop;

                        exit when is_last_element (xp_a.all, tau_ac_iterator);
                        next_element (xp_a.all, tau_ac_iterator);
                     end loop;
                  end if;

                  free_container (xp_a.all);
                  free (xp_a, False);

                  -- Update tau_ab's response time
                  if r_w_ab > r_ab then
                     r_ab := r_w_ab;
                     set_response (tau_ab, r_ab);
                     convergence := False;
                  end if;

      -- Estimate tau_ab's successors responses so they are not less than R_ab
                  --Estimate_Successors_Response_Time(tau_ab);
                  -- This gives wrong results and it wasn't mentioned in [Redell04] nor in [Palencia99]

                  -- Estimate tau_ab's predecessor response because R_ab may be less than R_a{b-1} due to application of tau_ac in XP_a
                  --Estimate_Predecessor_Response_Time(tau_ab);
                  -- This gives wrong results and it wasn't mentioned in [Redell04] nor in [Palencia99]

                  -- Jitter re-evaluation
                  update_successors_jitter (get_root_task (gamma_a));

                  exit when is_tail_element
                      (gamma_a.task_list,
                       tau_ab_iterator);
                  next_element (gamma_a.task_list, tau_ab_iterator);
               end loop;
            end if;

            exit when is_last_element (my_system.task_groups, gamma_iterator);
            next_element (my_system.task_groups, gamma_iterator);
         end loop;

         -- Warning: inifinity loop possible here, if no convergence. No convergence when CPU utilization > 100%
         -- TODO: Before starting the analysis, check that CPU utilization <= 100%
         --X := X + 1;
         exit when convergence;
      end loop;

      free_container (forced_immediate_tasks_set);
   end wcdops_plus_nimp;
end feasibility_test.transaction_worst_case_response_time;
