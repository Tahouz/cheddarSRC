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

with xml_tag;     use xml_tag;
with double_util; use double_util;
with feasibility_test.processor_utilization;
use feasibility_test.processor_utilization;
with Text_IO;                  use Text_IO;
with translate;                use translate;
with unbounded_strings;        use unbounded_strings;
with scheduler;                use scheduler;
with Scheduling_Analysis;      use Scheduling_Analysis;
with Call_Framework_Interface; use Call_Framework_Interface;
with Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with priority_assignment.rm; use priority_assignment.rm;
with priority_assignment.dm; use priority_assignment.dm;
with systems;                use systems;
with cache_set;              use cache_set;
with Caches;                 use Caches;
with Caches;                 use Caches.Cache_Blocks_Table_Package;
with cache_access_profile_set;
use cache_access_profile_set.cache_access_profile_set;
with integer_arrays; use integer_arrays;
with sets;
with feasibility_test.memory_interferences;
use feasibility_test.memory_interferences;

package body feasibility_test.cache_interferences is

   function compute_gamma_ucb_union_multiset
     (my_tasks                  : in tasks_set;
      task_i                    : in generic_task_ptr;
      task_j                    : in generic_task_ptr;
      response_time             : in response_time_table;
      wiq                       : in Double;
      q                         : in Natural;
      crpd_computation_approach : in crpd_computation_approach_type :=
        ecb_only;
      block_reload_time        : in Natural                   := 0;
      my_cache_access_profiles : in cache_access_profiles_set :=
        no_cache_access_profile)
      return Natural
   is
      cap_j : cache_access_profile_ptr;
      cap_k : cache_access_profile_ptr;

      task_k : generic_task_ptr;

      my_iterator : tasks_iterator;

      n : Natural := 0;

      gamma_ij : Natural := 0;

      r_i  : Natural := 0;
      r_k  : Natural := 0;
      ekri : Natural := 0;
      ejrk : Natural := 0;
      ejri : Natural := 0;

      m_ucb_ij : integer_array;
      m_ecb_j  : integer_array;
      m        : integer_array;
   begin
      initialize (m);
      -----------------------------
      -- Compute: M_UCB_ij
      -----------------------------
      reset_iterator (my_tasks, my_iterator);
      loop
         current_element (my_tasks, task_k, my_iterator);
         --aff(i,j) = hep(i) \cap lp(j)
         if
           (task_k.priority >= task_i.priority and
            task_k.priority < task_j.priority and
            task_k.name /= task_j.name)
         then

            -- E_k(R_i) = ceiling((R_i + J_k / T_k)
            ekri :=
              Natural
                (Double'ceiling
                   ((Double (r_i) +
                     Double (periodic_task_ptr (task_k).jitter)) /
                    Double (periodic_task_ptr (task_k).period)));
            Put_Line ("R_i:" & r_i'img);
            Put_Line
              ("Periodic_Task_Ptr(task_k).jitter:" &
               periodic_task_ptr (task_k).jitter'img);
            Put_Line
              ("Periodic_Task_Ptr(task_k).period:" &
               periodic_task_ptr (task_k).period'img);
            Put_Line ("EkRi:" & ekri'img);

            -- E_j(R_k) = ceiling((R_k + J_j / T_j))
            for i in 0 .. response_time.nb_entries - 1 loop
               if (response_time.entries (i).item.name = task_k.name) then
                  r_k := Natural (response_time.entries (i).data);
               end if;
            end loop;

            if (task_k.name = task_i.name) then
               r_k := r_i;
            end if;

            ejrk :=
              Natural
                (Double'ceiling
                   ((Double (r_k) +
                     Double (periodic_task_ptr (task_j).jitter)) /
                    Double (periodic_task_ptr (task_j).period)));
            Put_Line ("R_k: " & r_k'img);
            Put_Line ("EjRk:" & ejrk'img);

            cap_k :=
              search_cache_access_profile
                (my_cache_access_profiles,
                 task_k.cache_access_profile_name);

            for i in 0 .. ekri * ejrk - 1 loop
               for i in 0 .. cap_k.UCBs.nb_entries - 1 loop
                  add (m_ucb_ij, cap_k.UCBs.entries (i).cache_block_number);
               end loop;
            end loop;

         end if;

         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;

      -----------------------------
      -- Compute: M_ECB_j
      -----------------------------

      -- E_j(R_i) = ceiling((R_i + J_j / T_j)
      ejri :=
        Natural
          (Double'ceiling
             ((Double (r_i) + Double (periodic_task_ptr (task_j).jitter)) /
              Double (periodic_task_ptr (task_j).period)));
      Put_Line ("EjRi:" & ejri'img);

      cap_j :=
        search_cache_access_profile
          (my_cache_access_profiles,
           task_j.cache_access_profile_name);
      for l in 0 .. ejri - 1 loop
         for i in 0 .. cap_j.ECBs.nb_entries - 1 loop
            add (m_ecb_j, True, cap_j.ECBs.entries (i).cache_block_number);
         end loop;
      end loop;

      -----------------------------
      -- Union
      -----------------------------
      m        := multiset_intersection (m_ucb_ij, m_ecb_j);
      gamma_ij := block_reload_time * m.size;

      return gamma_ij;

   end compute_gamma_ucb_union_multiset;

   function compute_gamma_ecb_union_multiset
     (my_tasks                  : in tasks_set;
      task_i                    : in generic_task_ptr;
      task_j                    : in generic_task_ptr;
      response_time             : in response_time_table;
      wiq                       : in Double;
      q                         : in Natural;
      crpd_computation_approach : in crpd_computation_approach_type :=
        ecb_only;
      block_reload_time        : in Natural                   := 0;
      my_cache_access_profiles : in cache_access_profiles_set :=
        no_cache_access_profile)
      return Natural
   is
      cap_j : cache_access_profile_ptr;
      cap_h : cache_access_profile_ptr;
      cap_k : cache_access_profile_ptr;

      task_h : generic_task_ptr;
      task_k : generic_task_ptr;

      my_iterator : tasks_iterator;

      arr_ecbu      : integer_array;
      arr_ucb_k     : integer_array;
      arr_intersect : integer_array;
      arr_cost      : integer_array;

      n : Natural := 0;

      gamma_ij : Natural := 0;

      r_i  : Natural := 0;
      r_k  : Natural := 0;
      ekri : Natural := 0;
      ejrk : Natural := 0;
      ejri : Natural := 0;

      m : integer_array;
   begin
      initialize (arr_ecbu);
      initialize (arr_ucb_k);
      initialize (arr_intersect);
      initialize (arr_cost);
      initialize (m);

      r_i := Natural (wiq) - q * task_i.capacity;

      Put_Line ("R_i: " & r_i'img);
      Put_Line ("Task_i: " & To_String (task_i.name));
      Put_Line ("Task_j: " & To_String (task_j.name));

      -----------------------------------------------
      --Compute (Union (h \in hp(j) \cup {j}) ECB_h)
      -----------------------------------------------

      --hp(j)
      reset_iterator (my_tasks, my_iterator);
      loop
         current_element (my_tasks, task_h, my_iterator);

         if
           (task_h.priority >= task_j.priority and task_h.name /= task_j.name)
         then

            cap_h :=
              search_cache_access_profile
                (my_cache_access_profiles,
                 task_h.cache_access_profile_name);
            for i in 0 .. cap_h.ECBs.nb_entries - 1 loop
               integer_arrays.add
                 (arr_ecbu,
                  True,
                  cap_h.ECBs.entries (i).cache_block_number);
            end loop;
         end if;

         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;

        --{j}
      cap_j :=
        search_cache_access_profile
          (my_cache_access_profiles,
           task_j.cache_access_profile_name);

      for i in 0 .. cap_j.ECBs.nb_entries - 1 loop
         integer_arrays.add
           (arr_ecbu,
            True,
            cap_j.ECBs.entries (i).cache_block_number);
      end loop;

      Put ("ECB Union Array: ");
      print (arr_ecbu);

      -----------------------------------------------
      --Compute UCB_k \cap arr_ecbu
      -----------------------------------------------
      reset_iterator (my_tasks, my_iterator);
      loop
         current_element (my_tasks, task_k, my_iterator);

         --aff(i,j) = hep(i) \cap lp(j)
         if
           (task_k.priority >= task_i.priority and
            task_k.priority < task_j.priority and
            task_k.name /= task_j.name)
         then

            Put_Line ("Task_k: " & To_String (task_k.name));

            cap_k :=
              search_cache_access_profile
                (my_cache_access_profiles,
                 task_k.cache_access_profile_name);
            for i in 0 .. cap_k.UCBs.nb_entries - 1 loop
               add (arr_ucb_k, cap_k.UCBs.entries (i).cache_block_number);
            end loop;

            Put ("Arr_UCB_k: ");
            print (arr_ucb_k);

            --UCB_k \cap arr_ecbu
            intersect
              (arr_a => arr_ucb_k,
               arr_b => arr_ecbu,
               arr_c => arr_intersect,
               n     => n);  -- n is number of evicting UCBs of k
            Put_Line ("N:" & n'img);

            -- E_k(R_i) = ceiling((R_i + J_k / T_k)
            ekri :=
              Natural
                (Double'ceiling
                   ((Double (r_i) +
                     Double (periodic_task_ptr (task_k).jitter)) /
                    Double (periodic_task_ptr (task_k).period)));
            Put_Line ("R_i:" & r_i'img);
            Put_Line
              ("Periodic_Task_Ptr(task_k).jitter:" &
               periodic_task_ptr (task_k).jitter'img);
            Put_Line
              ("Periodic_Task_Ptr(task_k).period:" &
               periodic_task_ptr (task_k).period'img);
            Put_Line ("EkRi:" & ekri'img);

            -- E_j(R_k) = ceiling((R_k + J_j / T_j))
            for i in 0 .. response_time.nb_entries - 1 loop
               if (response_time.entries (i).item.name = task_k.name) then
                  r_k := Natural (response_time.entries (i).data);
               end if;
            end loop;

            if (task_k.name = task_i.name) then
               r_k := r_i;
            end if;

            ejrk :=
              Natural
                (Double'ceiling
                   ((Double (r_k) +
                     Double (periodic_task_ptr (task_j).jitter)) /
                    Double (periodic_task_ptr (task_j).period)));
            Put_Line ("R_k: " & r_k'img);
            Put_Line ("EjRk:" & ejrk'img);

            for i in 0 .. ekri * ejrk - 1 loop
               add (m, n);
            end loop;
         end if;

         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;

      -- E_j(R_i) = ceiling((R_i + J_j / T_j)
      ejri :=
        Natural
          (Double'ceiling
             ((Double (r_i) + Double (periodic_task_ptr (task_j).jitter)) /
              Double (periodic_task_ptr (task_j).period)));
      Put_Line ("EjRi:" & ejri'img);
      -- CRPD computation
      sort_desc (m);

      Put ("==Multi set: ");
      print (m);

      for l in 0 .. ejri - 1 loop
         gamma_ij := gamma_ij + block_reload_time * m.elements (l);
      end loop;

      Put_Line ("==Result:" & gamma_ij'img);
      New_Line;

      return gamma_ij;
   end compute_gamma_ecb_union_multiset;

end feasibility_test.cache_interferences;
