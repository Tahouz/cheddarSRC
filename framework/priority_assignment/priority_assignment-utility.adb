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
with Scheduling_Analysis;   use Scheduling_Analysis;
with Scheduling_Analysis;
use Scheduling_Analysis.Task_Release_Records_Table_Package;
with tables;
with task_set;         use task_set;
with Tasks;            use Tasks;
with natural_util;     use natural_util;
with Tasks.extended;   use Tasks.extended;
with integer_arrays;   use integer_arrays;
with Framework_Config; use Framework_Config;
with Caches;           use Caches;
with Caches;           use Caches.Cache_Blocks_Table_Package;

package body priority_assignment.utility is

   procedure put (obj : in task_release_records_table_ptr) is
   begin
      for i in 0 .. obj.nb_entries - 1 loop
         Put_Line (To_String (obj.entries (i).task_name));
      end loop;
   end put;

   procedure warshall_algorithm
     (warshall_array : in out boolean_arr_2d_ptr;
      size           : in     Integer)
   is
   begin
      for k in 0 .. size - 1 loop
         for i in 0 .. size - 1 loop
            if (warshall_array (i, k)) then
               for j in 0 .. size - 1 loop
                  warshall_array (i, j) :=
                    warshall_array (i, j) or
                    (warshall_array (i, k) and warshall_array (k, j));
               end loop;
            end if;
         end loop;
      end loop;
   end warshall_algorithm;

   function calculate_pi
     (priority_level : in Integer;
      my_tasks       : in tasks_set) return Integer
   is
      pi          : Integer := 1;
      my_iterator : tasks_iterator;
      i_task      : generic_task_ptr;
   begin
      reset_iterator (my_tasks, my_iterator);
      loop
         current_element (my_tasks, i_task, my_iterator);
         pi := lcm (pi, periodic_task_ptr (i_task).period);
         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;
      return pi;
   end calculate_pi;

   function calculate_h (my_tasks : in tasks_set) return Integer is
      h           : Integer := 1;
      my_iterator : tasks_iterator;
      i_task      : generic_task_ptr;
   begin
      reset_iterator (my_tasks, my_iterator);
      loop
         current_element (my_tasks, i_task, my_iterator);

         h := lcm (h, periodic_task_ptr (i_task).period);
         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;
      return h;
   end calculate_h;

   procedure refine_offset
     (a_task        : in     generic_task_ptr;
      my_tasks      : in     tasks_set;
      refined_tasks :    out tasks_set)
   is
      my_iterator : tasks_iterator;
      j_task      : generic_task_ptr;

      --Oi : Float := Float(a_task.offsets.Entries(0).offset_value);
      oi : Float := Float (a_task.start_time);
      oj : Float;
      tj : Float;
      lj : Float;

   begin
      duplicate (my_tasks, refined_tasks);
      -- if(a_task.offsets.Entries(0).offset_value = 0) then
      if (a_task.start_time = 0) then
         return;
      end if;

      reset_iterator (refined_tasks, my_iterator);

      loop
         current_element (refined_tasks, j_task, my_iterator);
         oj := Float (j_task.start_time);
         tj := Float (periodic_task_ptr (j_task).period);

         if (j_task.name = a_task.name) then
            j_task.start_time := 0;
         else
            if (oi > oj) then
               lj                := Float'ceiling ((oi - oj) / tj);
               j_task.start_time := Natural (lj * tj + oj) - Natural (oi);
            else
               j_task.start_time := j_task.start_time - Natural (oi);
            end if;
         end if;

         exit when is_last_element (refined_tasks, my_iterator);

         next_element (refined_tasks, my_iterator);

      end loop;

   end refine_offset;

   procedure calculate_task_release_records_table
     (t_start                      : in     Integer;
      t_end                        : in     Integer;
      a_task                       : in out generic_task_ptr;
      my_tasks                     : in out tasks_set;
      a_task_release_records_table :    out task_release_records_table)
   is
      my_iterator : tasks_iterator;
      i_task      : generic_task_ptr;

      track_time : Integer := t_start;

      finished : Boolean;
      temp     : task_release_record_ptr;

      a_task_release_record : task_release_record_ptr;
   begin
      --CALCULATE
      reset_iterator (my_tasks, my_iterator);
      loop
         current_element (my_tasks, i_task, my_iterator);
         track_time := t_start;
         if
           (i_task.name /= a_task.name and i_task.priority > a_task.priority)
         then

            -- track_time:= Periodic_Task_Ptr(i_task).period * (t_start/Periodic_Task_Ptr(i_task).period) + i_task.offsets.Entries(0).offset_value;
            track_time :=
              periodic_task_ptr (i_task).period *
              (t_start / periodic_task_ptr (i_task).period) +
              i_task.start_time;
            while (track_time < t_start) loop
               track_time := track_time + periodic_task_ptr (i_task).period;
            end loop;

            while (track_time < t_end) loop

               a_task_release_record              := new task_release_record;
               a_task_release_record.task_name    := i_task.name;
               a_task_release_record.capacity     := i_task.capacity;
               a_task_release_record.release_time := track_time;
               a_task_release_record.finish_time  :=
                 track_time + i_task.capacity;
               a_task_release_record.deadline := track_time + i_task.deadline;
               add (a_task_release_records_table, a_task_release_record);

               track_time := track_time + periodic_task_ptr (i_task).period;
            end loop;
         end if;
         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;

      --SORT
      loop
         finished := True;
         for j in 0 .. a_task_release_records_table.nb_entries - 2 loop
            if
              (a_task_release_records_table.entries (j + 1).release_time <
               a_task_release_records_table.entries (j).release_time)
            then
               finished                                     := False;
               temp := a_task_release_records_table.entries (j + 1);
               a_task_release_records_table.entries (j + 1) :=
                 a_task_release_records_table.entries (j);
               a_task_release_records_table.entries (j) := temp;
            end if;
         end loop;

         exit when finished;
      end loop;
   end calculate_task_release_records_table;

   procedure calculate_task_release_records_table
     (t_start  : in     Integer;
      t_end    : in     Integer;
      a_task   : in     generic_task_ptr;
      my_tasks : in out tasks_set;
      a_tuea   : in     task_ucb_ecb_array_ptr;
      a_trrt   :    out task_release_records_table_ptr)
   is
      my_iterator : tasks_iterator;
      i_task      : generic_task_ptr;
      track_time  : Integer := t_start;
      finished    : Boolean;
      temp        : task_release_record_ptr;
      a_trr       : task_release_record_ptr;
      a_trr_ext   : task_release_record_ext_ptr;
   begin
      a_trrt := new task_release_records_table;

      --COMPUTE
      reset_iterator (my_tasks, my_iterator);
      loop
         current_element (my_tasks, i_task, my_iterator);
         track_time := t_start;
         if
           (i_task.name /= a_task.name and i_task.priority > a_task.priority)
         then

            --track_time:= Periodic_Task_Ptr(i_task).period * (t_start/Periodic_Task_Ptr(i_task).period) + i_task.offsets.Entries(0).offset_value;
            track_time :=
              periodic_task_ptr (i_task).period *
              (t_start / periodic_task_ptr (i_task).period) +
              i_task.start_time;
            while (track_time < t_start) loop
               track_time := track_time + periodic_task_ptr (i_task).period;
            end loop;

            while (track_time < t_end) loop
               a_trr_ext              := new task_release_record_ext;
               a_trr_ext.task_name    := i_task.name;
               a_trr_ext.capacity     := i_task.capacity;
               a_trr_ext.release_time := track_time;
               a_trr_ext.finish_time  := track_time + i_task.capacity;
               a_trr_ext.deadline     := track_time + i_task.deadline;
               a_trr_ext.completed    := False;
               for i in 0 .. a_tuea'length - 1 loop
                  if (a_tuea (i).task_name = i_task.name) then
                     a_trr_ext.ucbs       := a_tuea (i).ucbs;
                     a_trr_ext.ecbs       := a_tuea (i).ecbs;
                     a_trr_ext.task_index := a_tuea (i).task_index;
                  end if;
               end loop;
               fill_tasks_ucbs_in_cache (a_trr_ext);

               a_trr := task_release_record_ptr (a_trr_ext);
               add (a_trrt.all, a_trr);
               track_time := track_time + periodic_task_ptr (i_task).period;
            end loop;
         end if;
         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;

      --SORT
      loop
         finished := True;
         for j in 0 .. a_trrt.nb_entries - 2 loop
            if
              (a_trrt.entries (j + 1).release_time <
               a_trrt.entries (j).release_time)
            then
               finished               := False;
               temp                   := a_trrt.entries (j + 1);
               a_trrt.entries (j + 1) := a_trrt.entries (j);
               a_trrt.entries (j)     := temp;
            end if;
         end loop;

         exit when finished;
      end loop;

   end calculate_task_release_records_table;

   procedure check_ccb
     (a_task_ucb_ecb_array : in     task_ucb_ecb_array_ptr;
      preempting_task      : in     Unbounded_String;
      preempted_task       : in     Unbounded_String;
      n_ccb                :    out Natural)
   is
      m, n : Integer;
   begin
      n_ccb := 0;
      for i in 0 .. a_task_ucb_ecb_array'length - 1 loop
         if (a_task_ucb_ecb_array (i).task_name = preempting_task) then
            m := i;
         end if;
         if (a_task_ucb_ecb_array (i).task_name = preempted_task) then
            n := i;
         end if;
      end loop;

      intersect
        (arr_a => a_task_ucb_ecb_array (m).ecbs,
         arr_b => a_task_ucb_ecb_array (n).ucbs,
         n     => n_ccb);
   end check_ccb;

   procedure get_eucbs
     (a_task_ucb_ecb_array : in     task_ucb_ecb_array_ptr;
      preempting_task      : in     Unbounded_String;
      preempted_task       : in     Unbounded_String;
      arr_eucbs            :    out integer_array)
   is
      m, n  : Integer;
      n_ccb : Integer;
   begin
      n_ccb := 0;
      for i in 0 .. a_task_ucb_ecb_array'length - 1 loop
         if (a_task_ucb_ecb_array (i).task_name = preempting_task) then
            m := i;
         end if;
         if (a_task_ucb_ecb_array (i).task_name = preempted_task) then
            n := i;
         end if;
      end loop;

      intersect
        (arr_a => a_task_ucb_ecb_array (m).ecbs,
         arr_b => a_task_ucb_ecb_array (n).ucbs,
         arr_c => arr_eucbs,
         n     => n_ccb);
   end get_eucbs;

   function get_crpd_by_ncb (n_ucb_ecb : in Integer) return Integer is
   begin
      return n_ucb_ecb;
   end get_crpd_by_ncb;

-----------------------------------------------------------------------------
   function compute_crpd_potential_preempted
     (sets : in ias_ptr;
      k    : in Integer;
      n    : in Integer) return Integer
   is
      generic
         type integers is range <>;
      package combinations is
         type combination is array (Natural range <>) of integers;
         procedure first (x : in out combination);
         procedure next (x : in out combination);
      end combinations;

      package body combinations is
         procedure first (x : in out combination) is
         begin
            x (0) := integers'first;
            for i in 1 .. x'last loop
               x (i) := x (i - 1) + 1;
            end loop;
         end first;
         procedure next (x : in out combination) is
         begin
            for i in reverse x'range loop
               if x (i) <
                 integers'val (integers'pos (integers'last) - x'last + i)
               then
                  x (i) := x (i) + 1;
                  for j in i + 1 .. x'last loop
                     x (j) := x (j - 1) + 1;
                  end loop;
                  return;
               end if;
            end loop;
            raise Constraint_Error;
         end next;
      end combinations;

      subtype five is Integer range 0 .. n - 1;
      package fives is new combinations (five);
      use fives;

      x : combination (0 .. k - 1);
   --------------------------------------------------------------------------
      n_eucb     : Integer := 0;
      arr_result : integer_array;
   begin
      first (x);
      initialize (arr_result);
      for i in x'range loop
         union (arr_a => arr_result, arr_b => sets (x (i)));
      end loop;
      n_eucb := arr_result.size;

      loop
         next (x);
         initialize (arr_result);
         for i in x'range loop
            union (arr_a => arr_result, arr_b => sets (x (i)));
         end loop;
         if (n_eucb < arr_result.size) then
            n_eucb := arr_result.size;
         end if;
      end loop;
   exception
      when Constraint_Error =>
         --Put_Line(n_eucb'Img);
         free (arr_result);
         return n_eucb;
   end compute_crpd_potential_preempted;
-----------------------------------------------------------------------------

   procedure initialize (a_ias : in out ias_ptr) is
   begin
      a_ias := new ias (0 .. 0);
   end initialize;

   procedure add (a_ias : in out ias_ptr; a_ia : in integer_array) is
      temp_ias : ias_ptr;
   begin
      temp_ias := new ias (0 .. a_ias'length);
      for i in 0 .. a_ias'length - 1 loop
         temp_ias (i) := a_ias (i);
      end loop;
      temp_ias (a_ias'length) := a_ia;
      free (a_ias);
      a_ias := temp_ias;
   end add;

   procedure fill_tasks_ucbs_in_cache
     (a_trr : in out task_release_record_ext_ptr)
   is
   begin
      free (a_trr.ucbs_in_cache.elements);
      initialize (a_trr.ucbs_in_cache);

      for i in 0 .. a_trr.ucbs.size - 1 loop
         add (a_trr.ucbs_in_cache, a_trr.ucbs.elements (i));
      end loop;
   end fill_tasks_ucbs_in_cache;

   procedure initialize
     (my_task_ucb_ecb : in out task_ucb_ecb;
      task_name       : in     Unbounded_String;
      task_index      : in     Integer := 0;
      ucbs            : in     integer_array;
      crpd_ucb        : in     Integer := 0;
      ecbs            : in     integer_array;
      crpd_ecb        : in     Integer := 0)
   is
   begin
      my_task_ucb_ecb.task_name  := task_name;
      my_task_ucb_ecb.task_index := task_index;
      my_task_ucb_ecb.ucbs       := ucbs;
      my_task_ucb_ecb.ecbs       := ecbs;
      my_task_ucb_ecb.crpd_ucb   := crpd_ucb;
      my_task_ucb_ecb.crpd_ecb   := crpd_ecb;
   end initialize;

   function get_task_crpd_ecb
     (a_task_ucb_ecb_array_ptr : in task_ucb_ecb_array_ptr;
      task_name                : in Unbounded_String) return Integer
   is
   begin
      for i in 0 .. a_task_ucb_ecb_array_ptr'length - 1 loop
         if (a_task_ucb_ecb_array_ptr (i).task_name = task_name) then
            return a_task_ucb_ecb_array_ptr (i).crpd_ecb;
         end if;
      end loop;
      return 0;
   end get_task_crpd_ecb;

   function get_task_crpd_ucb
     (a_task_ucb_ecb_array_ptr : in task_ucb_ecb_array_ptr;
      task_name                : in Unbounded_String) return Integer
   is
   begin
      for i in 0 .. a_task_ucb_ecb_array_ptr'length - 1 loop
         if (a_task_ucb_ecb_array_ptr (i).task_name = task_name) then
            return a_task_ucb_ecb_array_ptr (i).crpd_ucb;
         end if;
      end loop;
      return 0;
   end get_task_crpd_ucb;

   procedure cap_to_tuea
     (my_tasks                 : in     tasks_set;
      my_cache_access_profiles : in     cache_access_profiles_set;
      a_task_ucb_ecb_array     : in out task_ucb_ecb_array_ptr)
   is
      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;

      a_cache_access_profile : cache_access_profile_ptr;

      ucb_array : integer_array;
      ecb_array : integer_array;

      n     : Integer;
      index : Integer := 0;
   begin
      n := Integer (get_number_of_elements (my_set => my_tasks));
      a_task_ucb_ecb_array := new task_ucb_ecb_array (0 .. n - 1);

      reset_iterator (my_set => my_tasks, my_iterator => my_iterator);
      loop
         current_element (my_tasks, a_task, my_iterator);

         a_cache_access_profile :=
           search_cache_access_profile
             (my_cache_access_profiles => my_cache_access_profiles,
              name                     => a_task.cache_access_profile_name);

         initialize (ecb_array);
         initialize (ucb_array);

         for i in 0 .. a_cache_access_profile.ECBs.nb_entries - 1 loop
            add
              (ecb_array,
               a_cache_access_profile.ECBs.entries (i).cache_block_number);
         end loop;
         for i in 0 .. a_cache_access_profile.UCBs.nb_entries - 1 loop
            add
              (ucb_array,
               a_cache_access_profile.UCBs.entries (i).cache_block_number);
         end loop;

         a_task_ucb_ecb_array (index).task_name  := a_task.name;
         a_task_ucb_ecb_array (index).task_index := index;
         a_task_ucb_ecb_array (index).ucbs       := ucb_array;
         a_task_ucb_ecb_array (index).ecbs       := ecb_array;
         a_task_ucb_ecb_array (index).crpd_ecb   :=
           get_crpd_by_ncb (ecb_array.size);
         a_task_ucb_ecb_array (index).crpd_ucb :=
           get_crpd_by_ncb (ucb_array.size);

         index := index + 1;

         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;
      Put_Line ("");
   end cap_to_tuea;
end priority_assignment.utility;
