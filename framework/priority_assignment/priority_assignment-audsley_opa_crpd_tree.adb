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
with Scheduling_Analysis;   use Scheduling_Analysis;
with Scheduling_Analysis;
use Scheduling_Analysis.Task_Release_Records_Table_Package;
with Scheduling_Analysis;
use Scheduling_Analysis.Relative_Priority_Records_Table_Package;
with integer_util;                use integer_util;
with priority_assignment.utility; use priority_assignment.utility;
with Tasks.extended;              use Tasks.extended;
with debug;                       use debug;
with cache_set;                   use cache_set;
with integer_arrays;              use integer_arrays;
with CFG_Nodes.extended;          use CFG_Nodes.extended;
with CFG_Nodes;                   use CFG_Nodes.CFG_Nodes_Table_Package;
with CFG_Nodes;                   use CFG_Nodes;
with Unchecked_Deallocation;
with tables;

package body priority_assignment.audsley_opa_crpd_tree is

   --------------------------------
   --
   --
   --------------------------------
   procedure copy_task_release_records_table
     (src  : in     task_release_records_table_ptr;
      dest : in out task_release_records_table_ptr)
   is
      a_trr_ptr : task_release_record_ptr;
   begin
      for i in 0 .. src.nb_entries - 1 loop
         a_trr_ptr := Copy (src.entries (i));
         add (dest.all, a_trr_ptr);
      end loop;
   end copy_task_release_records_table;

   procedure free_task_release_records_table
     (my_table    : in out task_release_records_table_ptr;
      free_object : in     Boolean := True)
   is
      procedure free_pointer is new Unchecked_Deallocation
        (task_release_records_table,
         task_release_records_table_ptr);
   begin
      if free_object then
         for i in 0 .. my_table.nb_entries - 1 loop
            Free (my_table.entries (i));
         end loop;
      end if;
      free_pointer (my_table);
   end free_task_release_records_table;

   procedure copy_relative_priority_records_table
     (src  : in     relative_priority_records_table_ptr;
      dest : in out relative_priority_records_table_ptr)
   is
      a_rpr_ptr : relative_priority_record_ptr;
   begin
      for i in 0 .. src.nb_entries - 1 loop
         a_rpr_ptr := Copy (src.entries (i));
         add (dest.all, a_rpr_ptr);
      end loop;
   end copy_relative_priority_records_table;

   procedure free_relative_priority_records_table
     (my_table    : in out relative_priority_records_table_ptr;
      free_object : in     Boolean := True)
   is
      procedure free_pointer is new Unchecked_Deallocation
        (relative_priority_records_table,
         relative_priority_records_table_ptr);
   begin
      if free_object then
         for i in 0 .. my_table.nb_entries - 1 loop
            Free (my_table.entries (i));
         end loop;
      end if;
      free_pointer (my_table);
   end free_relative_priority_records_table;

   procedure add_relative_priority_record
     (a_rprt : in out relative_priority_records_table;
      a_rpr  :        relative_priority_record_ptr)
   is
      flag : Boolean := True;
   begin
      if (a_rprt.nb_entries > 0) then
         for i in 0 .. a_rprt.nb_entries - 1 loop
            if
              (a_rpr.hpt_index = a_rprt.entries (i).hpt_index and
               a_rpr.lpt_index = a_rprt.entries (i).lpt_index)
            then
               flag := False;
            end if;
         end loop;
      end if;

      if (flag) then
         add (a_rprt, a_rpr);
      end if;
   end add_relative_priority_record;

   --------------------------------
   --
   --------------------------------
   function compute_crpd_of_job_activation
     (a_trrt               : in out task_release_records_table_ptr;
      time                 : in     Integer;
      preempting_job_index : in     task_release_records_range) return Integer
   is
      number_eucb : Integer := 0;
      crpd        : Integer := 0;
   begin

      for i in 0 .. a_trrt.nb_entries - 1 loop
         if
           (a_trrt.entries (i).release_time < time and
            a_trrt.entries (i).capacity > 0 and
            i /= preempting_job_index)
         then

            intersect
              (arr_a =>
                 task_release_record_ext_ptr (a_trrt.entries (i))
                   .ucbs_in_cache,
               arr_b =>
                 task_release_record_ext_ptr
                   (a_trrt.entries (preempting_job_index))
                   .ecbs,
               n => number_eucb);

            for j in
              0 ..
                  task_release_record_ext_ptr
                    (a_trrt.entries (preempting_job_index))
                    .ecbs
                    .size -
                  1
            loop
               remove_by_value
                 (task_release_record_ext_ptr (a_trrt.entries (i))
                    .ucbs_in_cache,
                  task_release_record_ext_ptr
                    (a_trrt.entries (preempting_job_index))
                    .ecbs
                    .elements
                    (j));
            end loop;

            a_trrt.entries (i).finish_time :=
              a_trrt.entries (i).finish_time + number_eucb;
            a_trrt.entries (i).capacity :=
              a_trrt.entries (i).capacity +
              number_eucb;       --Capacity of a task release record is REMAINING_CAPACITY
            a_trrt.entries (i).finish_time :=
              a_trrt.entries (i).finish_time + number_eucb;

            crpd := crpd + number_eucb;
         end if;
      end loop;
      return crpd;
   end compute_crpd_of_job_activation;

   procedure initialize_next_crpd_node
     (next_crpd_node : in out crpd_node_ptr;
      a_crpd_node    : in     crpd_node_ptr;
      index          : in     task_release_records_range;
      tat            : in     task_activation_type)
   is
      a_rpr : relative_priority_record_ptr;
   begin
      if (tat = preemption) then
         next_crpd_node        := new crpd_node;
         next_crpd_node.a_rprt := new relative_priority_records_table;
         copy_relative_priority_records_table
           (src  => a_crpd_node.a_rprt,
            dest => next_crpd_node.a_rprt);

         next_crpd_node.a_trrt := new task_release_records_table;
         copy_task_release_records_table
           (src  => a_crpd_node.a_trrt,
            dest => next_crpd_node.a_trrt);

         next_crpd_node.job_index := Integer (index);
         next_crpd_node.task_name :=
           next_crpd_node.a_trrt.entries (index).task_name;
         next_crpd_node.task_index :=
           next_crpd_node.a_trrt.entries (index).task_index;

         next_crpd_node.a_trrt.entries
           (task_release_records_range (a_crpd_node.job_index))
           .finish_time :=
           next_crpd_node.a_trrt.entries
             (task_release_records_range (a_crpd_node.job_index))
             .finish_time +
           next_crpd_node.a_trrt.entries (index).capacity;

         --Save the implicit relative priority
         put_debug
           ("III-" &
            To_String (a_crpd_node.task_name) &
            " - " &
            a_crpd_node.task_index'img);
         put_debug
           ("III-" &
            To_String (next_crpd_node.task_name) &
            " - " &
            next_crpd_node.task_index'img);
         a_rpr                      := new relative_priority_record;
         a_rpr.higher_priority_task :=
           next_crpd_node.a_trrt.entries (index).task_name;
         a_rpr.hpt_index := next_crpd_node.a_trrt.entries (index).task_index;
         a_rpr.lower_priority_task := a_crpd_node.task_name;
         a_rpr.lpt_index           := a_crpd_node.task_index;

         add_relative_priority_record (next_crpd_node.a_rprt.all, a_rpr);

      elsif (tat = deny_preemption) then
         if (optimize_nodes) then
            a_rpr                      := new relative_priority_record;
            a_rpr.higher_priority_task := a_crpd_node.task_name;
            a_rpr.hpt_index            := a_crpd_node.task_index;
            a_rpr.lower_priority_task  :=
              a_crpd_node.a_trrt.entries (index).task_name;
            a_rpr.lpt_index := a_crpd_node.a_trrt.entries (index).task_index;
            add_relative_priority_record (a_crpd_node.a_rprt.all, a_rpr);
         else
            next_crpd_node        := new crpd_node;
            next_crpd_node.a_rprt := new relative_priority_records_table;
            copy_relative_priority_records_table
              (src  => a_crpd_node.a_rprt,
               dest => next_crpd_node.a_rprt);

            next_crpd_node.a_trrt := new task_release_records_table;
            copy_task_release_records_table
              (src  => a_crpd_node.a_trrt,
               dest => next_crpd_node.a_trrt);

            next_crpd_node.job_index  := a_crpd_node.job_index;
            next_crpd_node.task_name  := a_crpd_node.task_name;
            next_crpd_node.task_index := a_crpd_node.task_index;

            next_crpd_node.crpd_value := 0;

            --Save the implicit relative priority
            a_rpr                      := new relative_priority_record;
            a_rpr.higher_priority_task := a_crpd_node.task_name;
            a_rpr.hpt_index            := a_crpd_node.task_index;
            a_rpr.lower_priority_task  :=
              next_crpd_node.a_trrt.entries (index).task_name;
            a_rpr.lpt_index :=
              next_crpd_node.a_trrt.entries (index).task_index;
            add_relative_priority_record (next_crpd_node.a_rprt.all, a_rpr);
         end if;

      elsif (tat = no_executing_job) then
         if (optimize_nodes) then
            a_crpd_node.job_index := Integer (index);
            a_crpd_node.task_name :=
              a_crpd_node.a_trrt.entries (index).task_name;
            a_crpd_node.task_index :=
              a_crpd_node.a_trrt.entries (index).task_index;
         else
            next_crpd_node        := new crpd_node;
            next_crpd_node.a_rprt := new relative_priority_records_table;
            copy_relative_priority_records_table
              (src  => a_crpd_node.a_rprt,
               dest => next_crpd_node.a_rprt);

            next_crpd_node.a_trrt := new task_release_records_table;
            copy_task_release_records_table
              (src  => a_crpd_node.a_trrt,
               dest => next_crpd_node.a_trrt);

            next_crpd_node.job_index := Integer (index);
            next_crpd_node.task_name :=
              a_crpd_node.a_trrt.entries (index).task_name;
            next_crpd_node.task_index :=
              a_crpd_node.a_trrt.entries (index).task_index;

            next_crpd_node.crpd_value := 0;
         end if;
      end if;
   end initialize_next_crpd_node;

   procedure update_node_crpd_interference
     (a_crpd_node    : in out crpd_node_ptr;
      next_crpd_node : in out crpd_node_ptr;
      crpd           : in     Integer)
   is
   begin
      if (crpd > 0) then
         next_crpd_node.crpd_value := crpd;
      else
         next_crpd_node.crpd_value := 0;
      end if;
   end update_node_crpd_interference;

   --------------------------------
   --
   --------------------------------
   procedure print_tree
     (a_node  : in     crpd_node_ptr;
      level   : in     Unbounded_String;
      level_n : in     Integer := 0;
      counter : in out Integer)
   is
      temp   : Unbounded_String;
      temp_n : Integer;
   begin
      temp := level;
      Append (temp, To_Unbounded_String ("--"));
      temp_n := level_n;
      temp_n := temp_n + 1;

      counter := counter + 1;

      put_debug
        (counter'img &
         "| " &
         ASCII.HT &
         temp_n'img &
         ASCII.HT &
         To_String (level) &
         " " &
         To_String (a_node.task_name) &
         " Release:" &
         a_node.a_trrt.entries (task_release_records_range (a_node.job_index))
           .release_time'
           img);

      put_debug (ASCII.HT & ASCII.HT & To_String (level) & " ");
      for i in 0 .. a_node.a_trrt.nb_entries - 1 loop
         put_debug
           (To_String (a_node.a_trrt.entries (i).task_name) &
            " " &
            a_node.a_trrt.entries (i).capacity'img &
            "| ");
      end loop;

      put_debug (ASCII.HT & ASCII.HT & To_String (level) & " ");
      for i in 0 .. a_node.a_rprt.nb_entries - 1 loop

         put_debug
           (a_node.a_rprt.entries (i).hpt_index'img &
            " >" &
            a_node.a_rprt.entries (i).lpt_index'img &
            "| ");
      end loop;

      if (a_node.next_nodes.nb_entries < 0) then
         return;
      end if;

      for i in 0 .. a_node.next_nodes.nb_entries - 1 loop
         print_tree
           (crpd_node_ptr (a_node.next_nodes.entries (i)),
            temp,
            temp_n,
            counter);
      end loop;

   end print_tree;

   procedure get_number_of_node
     (a_node  : in     crpd_node_ptr;
      level   : in     Unbounded_String;
      level_n : in     Integer := 0;
      counter : in out Integer)
   is
      temp   : Unbounded_String;
      temp_n : Integer;
   begin
      --TODO: Check how to pass by value in ADA
      --
      temp := level;
      Append (temp, To_Unbounded_String ("--"));
      temp_n := level_n;
      temp_n := temp_n + 1;

      counter := counter + 1;

      if (a_node.next_nodes.nb_entries < 0) then
         return;
      end if;

      for i in 0 .. a_node.next_nodes.nb_entries - 1 loop
         get_number_of_node
           (crpd_node_ptr (a_node.next_nodes.entries (i)),
            temp,
            temp_n,
            counter);
      end loop;
   end get_number_of_node;

   --------------------------------
   -- Solving the relative priority
   -- problem with Warshall Algorithm
   --------------------------------
   function check_active_condition
     (a_rprt         : in relative_priority_records_table_ptr;
      a_trrt         : in task_release_records_table_ptr;
      index          : in task_release_records_range;
      number_of_task : in Integer;
      job_index      : in task_release_records_range) return Boolean
   is
      waiting_jobs   : task_release_records_table_ptr;
      warshall_array : boolean_arr_2d_ptr;
      active_flag    : Boolean := True;
   begin

      --Find the set of waiting jobs
      waiting_jobs := new task_release_records_table;
      for i in reverse 0 .. index loop
         if (a_trrt.entries (i).capacity > 0) then
            add (waiting_jobs.all, a_trrt.entries (i));
         end if;
      end loop;

      --Initialize the array
      warshall_array :=
        new boolean_arr_2d (0 .. number_of_task - 1, 0 .. number_of_task - 1);
      for i in 0 .. number_of_task - 1 loop
         for j in 0 .. number_of_task - 1 loop
            warshall_array (i, j) := False;
         end loop;
      end loop;

      --Set value for the array
      for i in 0 .. a_rprt.nb_entries - 1 loop
         warshall_array
           (a_rprt.entries (i).hpt_index,
            a_rprt.entries (i).lpt_index) :=
           True;
      end loop;

      --Solving the array
      warshall_algorithm
        (warshall_array => warshall_array,
         size           => number_of_task);

      --Check task activation
      for i in 0 .. waiting_jobs.nb_entries - 1 loop
         if
           (warshall_array
              (waiting_jobs.entries (i).task_index,
               a_trrt.entries (job_index).task_index))
         then
            active_flag := False;
            free (waiting_jobs);
            free (warshall_array);
            return active_flag;
         end if;
      end loop;
      free (waiting_jobs);
      free (warshall_array);
      return active_flag;
   end check_active_condition;

   procedure check_preempting_condition
     (a_rprt                : in     relative_priority_records_table_ptr;
      preempted_task_index  : in     Integer;
      preempting_task_index : in     Integer;
      number_of_tasks       : in     Integer;
      active_flag           : in out Boolean)
   is
      warshall_array : boolean_arr_2d_ptr;
   begin
      active_flag := True;
      --Initialize the array
      warshall_array :=
        new boolean_arr_2d
        (0 .. number_of_tasks - 1, 0 .. number_of_tasks - 1);
      for i in 0 .. number_of_tasks - 1 loop
         for j in 0 .. number_of_tasks - 1 loop
            warshall_array (i, j) := False;
         end loop;
      end loop;

      --Set value for the array
      for i in 0 .. a_rprt.nb_entries - 1 loop
         warshall_array
           (a_rprt.entries (i).hpt_index,
            a_rprt.entries (i).lpt_index) :=
           True;
      end loop;

      --Solving the array
      warshall_algorithm
        (warshall_array => warshall_array,
         size           => number_of_tasks);

      if (warshall_array (preempted_task_index, preempting_task_index)) then
         active_flag := False;
         free (warshall_array);
         return;
      end if;

      free (warshall_array);
   end check_preempting_condition;

   --------------------------------
   --
   --------------------------------
   procedure check_active_task
     (tdi                 : in     Integer;
      number_of_task      : in     Integer;
      assessing_job_index : in     task_release_records_range;
      a_node              : in out crpd_node_ptr;
      index : in out task_release_records_range;                    -- IMPORTANT: index = a_node.index + 1;
      time                : in     Integer;
      flag                : in out Boolean;
      counter             : in out Integer;
      is_schedulable      : in out Boolean)
   is
      next_node      : crpd_node_ptr;
      spare_interval : Integer;
      active_flag    : Boolean;
      new_time       : Integer;
      crpd           : Integer := 0;
      a_rpr          : relative_priority_record_ptr;
   begin
      flag :=
        True;                                                             -- Output for Check_State procedure, true by default
      for j in reverse 0 .. index - 1
      loop                                          -- Find a job is released but not finished execution
         if
           (a_node.a_trrt.entries (j).capacity > 0)
         then                         -- Check: released jobs's capacity > 0
            flag        := False;
            active_flag :=
              check_active_condition
                (a_rprt         => a_node.a_rprt,
                 a_trrt         => a_node.a_trrt,
                 index          => index - 1,
                 number_of_task => number_of_task,
                 job_index      =>
                   j);        -- Check: is it possible for the job to be released

            if
              (active_flag)
            then                                               -- Check: ok to release
               next_node        := new crpd_node;
               next_node.a_trrt := new task_release_records_table;
               copy_task_release_records_table
                 (src  => a_node.a_trrt,
                  dest => next_node.a_trrt);
               next_node.job_index  := Integer (j);
               next_node.task_name  := next_node.a_trrt.entries (j).task_name;
               next_node.task_index := next_node.a_trrt.entries (j).task_index;

               spare_interval :=
                 next_node.a_trrt.entries (index).release_time -
                 time; --Get the spare interval spare_interval.
               if
                 (next_node.a_trrt.entries (j).capacity - spare_interval < 0)
               then
                  new_time := time + next_node.a_trrt.entries (j).capacity;
                  next_node.a_trrt.entries (j).capacity := 0;
               else
                  next_node.a_trrt.entries (j).capacity :=
                    next_node.a_trrt.entries (j).capacity - spare_interval;
                  new_time := next_node.a_trrt.entries (index).release_time;
               end if;

               next_node.a_rprt := new relative_priority_records_table;
               copy_relative_priority_records_table
                 (src  => a_node.a_rprt,
                  dest => next_node.a_rprt);

               for k in reverse 0 .. index - 1 loop
                  if
                    (next_node.a_trrt.entries (k).capacity > 0 and
                     next_node.a_trrt.entries (k).task_index /=
                       next_node.a_trrt.entries (j).task_index)
                  then
                     a_rpr := new relative_priority_record;
                     a_rpr.higher_priority_task :=
                       next_node.a_trrt.entries (j).task_name;
                     a_rpr.hpt_index :=
                       next_node.a_trrt.entries (j).task_index;
                     a_rpr.lower_priority_task :=
                       next_node.a_trrt.entries (k).task_name;
                     a_rpr.lpt_index :=
                       next_node.a_trrt.entries (k).task_index;
                     add_relative_priority_record
                       (next_node.a_rprt.all,
                        a_rpr);
                  end if;
               end loop;

               fill_tasks_ucbs_in_cache
                 (task_release_record_ext_ptr (next_node.a_trrt.entries (j)));
               ------------------------------------------------
               --CRPD computation
               ------------------------------------------------
               if (crpd_computation) then
                  crpd :=
                    compute_crpd_of_job_activation
                      (a_trrt               => next_node.a_trrt,
                       time                 => time,
                       preempting_job_index => j);
               else
                  crpd := 0;
               end if;

               update_node_crpd_interference
                 (a_crpd_node    => a_node,
                  next_crpd_node => next_node,
                  crpd           => crpd);

               add_next_crpd_node
                 (a_crpd_node      => a_node,
                  a_next_crpd_node => next_node);

               compute_crpd_tree
                 (tdi                 => tdi,
                  a_node              => next_node,
                  index               => index,
                  time                => new_time,
                  number_of_task      => number_of_task,
                  state               => True,
                  counter             => counter,
                  is_schedulable      => is_schedulable,
                  assessing_job_index => assessing_job_index);

               if (optimize_memory) then
                  free_task_release_records_table (next_node.a_trrt);
                  free_relative_priority_records_table (next_node.a_rprt);
                  Free (cfg_node_ptr (next_node));
               end if;
            end if;
         end if;
      end loop;
   end check_active_task;

   procedure compute_final_state
     (a_node         : in out crpd_node_ptr;
      number_of_task : in     Integer;
      tdi            : in     Integer)
   is
      time        : Integer;
      c_i         : Integer;
      flag        : Boolean := True;
      active_flag : Boolean := True;
   begin

      time :=
        a_node.a_trrt.entries (a_node.a_trrt.nb_entries - 1).release_time;

      while (time < tdi and flag) loop
         flag := False;
         for i in 0 .. a_node.a_trrt.nb_entries - 1 loop
            if (a_node.a_trrt.entries (i).capacity > 0) then
               flag        := True;
               active_flag := True;

               active_flag :=
                 check_active_condition
                   (a_rprt         => a_node.a_rprt,
                    a_trrt         => a_node.a_trrt,
                    index          => a_node.a_trrt.nb_entries - 1,
                    number_of_task => number_of_task,
                    job_index      => i);

               if (active_flag) then
                  c_i := a_node.a_trrt.entries (i).capacity;
                  a_node.a_trrt.entries (i).capacity :=
                    Integer'max
                      (0,
                       a_node.a_trrt.entries (i).capacity - (tdi - time));
                  time := Integer'min (tdi, time + c_i);
                  if (time = tdi) then
                     return;
                  end if;
               end if;
            end if;
         end loop;
      end loop;
   end compute_final_state;

   --------------------------------
   --1. CRPD is computed at preemption point
   --2. CRPS is computed at resumption point
   --3. Time call by compute tree: Next job's release time
   --------------------------------
   procedure compute_crpd_tree
     (tdi                 : in     Integer;
      number_of_task      : in     Integer;
      state               : in     Boolean := True;
      index : in task_release_records_range;                -- IMPORTANT: index = a_node.index + 1;
      assessing_job_index : in     task_release_records_range;
      counter             : in out Integer;
      a_node              : in out crpd_node_ptr;
      time : in Integer;                                           -- Release time of the job with index: index-1
      is_schedulable      : in out Boolean)
   is
      next_node : crpd_node_ptr;
      i         : task_release_records_range :=
        index;                  -- i: the index of the current task release
      active_flag : Boolean :=
        True;                                      -- use as an output for Check_Preemption_Condition, Check_Active_Condition function
      flag : Boolean :=
        True;                                      -- use as an output for Check_State procedure
      time_passed : Integer := 0;
      crpd        : Integer := 0;
      new_time    : Integer := 0;
   begin
      counter := counter + 1;
      if (is_schedulable = False) then
         return;
      end if;
      if (i = a_node.a_trrt.nb_entries) then

         compute_final_state
           (a_node         => a_node,
            number_of_task => number_of_task,
            tdi            => tdi);

         if (a_node.a_trrt.entries (assessing_job_index).capacity > 0) then
            is_schedulable := False;
         end if;

         return;
      end if;

      if (not optimize_memory) then
         put_debug ("Counter:" & counter'img & " - " & ASCII.HT);
         for i in 0 .. a_node.a_trrt.nb_entries - 1 loop
            put_debug
              (To_String (a_node.a_trrt.entries (i).task_name) &
               " " &
               a_node.a_trrt.entries (i).capacity'img &
               " " &
               a_node.a_trrt.entries (i).release_time'img &
               "| ");
         end loop;
         put_debug ("---");
         for i in 0 .. a_node.a_rprt.nb_entries - 1 loop
            put_debug
              (a_node.a_rprt.entries (i).hpt_index'img &
               " >" &
               a_node.a_rprt.entries (i).lpt_index'img &
               "| ");
         end loop;
         put_debug (" - Time:" & time'img);
         put_debug ("======");
         New_Line;
      end if;

      ----------------------------------------------------------
      --STEP 0: Check if a task missed its deadline
      ----------------------------------------------------------
      for j in 0 .. a_node.a_trrt.nb_entries - 1 loop
         if
           (a_node.a_trrt.entries (j).deadline < time and
            a_node.a_trrt.entries (j).capacity > 0)
         then
            return;
         end if;
      end loop;

      ----------------------------------------------------------
-- STEP 1: Check if executing job completed before the release time of J_alpha
      ----------------------------------------------------------
      time_passed := (a_node.a_trrt.entries (i).release_time - time);
      if
        (a_node.a_trrt.entries (task_release_records_range (a_node.job_index))
           .capacity -
         time_passed <
         0)
      then
         new_time :=
           time +
           a_node.a_trrt.entries
             (task_release_records_range (a_node.job_index))
             .capacity;
         a_node.a_trrt.entries (task_release_records_range (a_node.job_index))
           .capacity :=
           0;

         check_active_task
           (tdi                 => tdi,
            a_node              => a_node,
            index               => i,
            time                => new_time,
            flag                => flag,
            number_of_task      => number_of_task,
            counter             => counter,
            is_schedulable      => is_schedulable,
            assessing_job_index => assessing_job_index);

         if
           (flag = False)
         then                                                  -- Flag is false when the Check_State find a problem
            return;
         end if;
      else
         a_node.a_trrt.entries (task_release_records_range (a_node.job_index))
           .capacity :=
           a_node.a_trrt.entries
             (task_release_records_range (a_node.job_index))
             .capacity -
           time_passed;
      end if;

      ----------------------------------------------------------
      -- STEP 2: Check for preemption occurs or not because of the release of job with index i
      ----------------------------------------------------------
      if
        (a_node.a_trrt.entries (task_release_records_range (a_node.job_index))
           .capacity >
         0)
      then
         if
           (a_node.task_name = a_node.a_trrt.entries (i).task_name)
         then                 -- Check: two jobs of a same task - a task missed deadline (D_i <= T_i), stop this branch.
            return;
         end if;
         ------------------------------------------------
         -- CASE 1: preemption occurs
         -- The next node presents the job with index i
         -------------------------------------------------
         check_preempting_condition
           (a_rprt                => a_node.a_rprt,
            preempted_task_index  => a_node.task_index,
            preempting_task_index => a_node.a_trrt.entries (i).task_index,
            number_of_tasks       => number_of_task,
            active_flag           =>
              active_flag);      -- Check: can job be preempted by next job
         if (active_flag) then
            initialize_next_crpd_node (next_node, a_node, i, preemption);
            ------------------------------------------------
            --CRPD computation
            ------------------------------------------------
            if (crpd_computation) then
               crpd :=
                 compute_crpd_of_job_activation
                   (a_trrt               => next_node.a_trrt,
                    time => next_node.a_trrt.entries (i).release_time,
                    preempting_job_index => i);
            else
               crpd := 0;
            end if;

            update_node_crpd_interference
              (a_crpd_node    => a_node,
               next_crpd_node => next_node,
               crpd           => crpd);

            add_next_crpd_node
              (a_crpd_node      => a_node,
               a_next_crpd_node => next_node);
            ------------------------------------------------
            if (i <= a_node.a_trrt.nb_entries - 1) then
               compute_crpd_tree
                 (tdi                 => tdi,
                  a_node              => next_node,
                  index               => i + 1,
                  time => next_node.a_trrt.entries (i).release_time,
                  number_of_task      => number_of_task,
                  counter             => counter,
                  is_schedulable      => is_schedulable,
                  assessing_job_index => assessing_job_index);
            end if;

            if (optimize_memory) then
               free_relative_priority_records_table (next_node.a_rprt);
               free_task_release_records_table (next_node.a_trrt);
               Free (cfg_node_ptr (next_node));
            end if;
         end if;

         -------------------------------------------------
         -- CASE 2: preemption did NOT occurs
         -------------------------------------------------
         check_preempting_condition
           (a_rprt                => a_node.a_rprt,
            preempted_task_index  => a_node.a_trrt.entries (i).task_index,
            preempting_task_index => a_node.task_index,
            number_of_tasks       => number_of_task,
            active_flag           =>
              active_flag);      -- Check: can job be not preempted by next job
         if (active_flag) then
            initialize_next_crpd_node (next_node, a_node, i, deny_preemption);

            if (optimize_nodes) then
               if (i <= a_node.a_trrt.nb_entries - 1) then
                  compute_crpd_tree
                    (tdi                 => tdi,
                     a_node              => a_node,
                     index               => i + 1,
                     time => a_node.a_trrt.entries (i).release_time,
                     number_of_task      => number_of_task,
                     counter             => counter,
                     is_schedulable      => is_schedulable,
                     assessing_job_index => assessing_job_index);
               end if;
            else
               add_next_crpd_node
                 (a_crpd_node      => a_node,
                  a_next_crpd_node => next_node);
               if (i <= a_node.a_trrt.nb_entries - 1) then
                  compute_crpd_tree
                    (tdi                 => tdi,
                     a_node              => next_node,
                     index               => i + 1,
                     time => next_node.a_trrt.entries (i).release_time,
                     number_of_task      => number_of_task,
                     counter             => counter,
                     is_schedulable      => is_schedulable,
                     assessing_job_index => assessing_job_index);
               end if;
            end if;

            if (optimize_memory) then
               if (not optimize_nodes) then
                  free_relative_priority_records_table (next_node.a_rprt);
                  free_task_release_records_table (next_node.a_trrt);
               end if;
               Free (cfg_node_ptr (next_node));
            end if;
         end if;
      else
         -------------------------------------------------
         -- No active job, no preemption
         -- THe next node presents the job with index i
         -------------------------------------------------
         initialize_next_crpd_node (next_node, a_node, i, no_executing_job);

         if (optimize_nodes) then
            compute_crpd_tree
              (tdi                 => tdi,
               a_node              => a_node,
               index               => i + 1,
               time                => a_node.a_trrt.entries (i).release_time,
               number_of_task      => number_of_task,
               counter             => counter,
               is_schedulable      => is_schedulable,
               assessing_job_index => assessing_job_index);
         else
            add_next_crpd_node
              (a_crpd_node      => a_node,
               a_next_crpd_node => next_node);

            compute_crpd_tree
              (tdi                 => tdi,
               a_node              => next_node,
               index               => i + 1,
               time => next_node.a_trrt.entries (i).release_time,
               number_of_task      => number_of_task,
               counter             => counter,
               is_schedulable      => is_schedulable,
               assessing_job_index => assessing_job_index);
         end if;

         if (optimize_memory) then
            if (not optimize_nodes) then
               free_task_release_records_table (next_node.a_trrt);
               free_relative_priority_records_table (next_node.a_rprt);
            end if;
            Free (cfg_node_ptr (next_node));
         end if;
      end if;
      ----------------------------------------------------------
   end compute_crpd_tree;

   --------------------------------
   --
   --------------------------------
   procedure assess_release_set
     (a_trrt              : in out task_release_records_table_ptr;
      tdi                 : in     Integer;
      number_of_task      : in     Integer := 0;
      assessing_job_index : in     task_release_records_range;
      is_schedulable      : in out Boolean)
   is
      k       : Integer;
      a_node  : crpd_node_ptr;
      level   : Unbounded_String;
      time    : Integer := 0;
      counter : Integer := -1;
      a_rpr   : relative_priority_record_ptr;
   begin
      put_debug ("Number of Jobs:" & a_trrt.nb_entries'img);
      k := a_trrt.entries (assessing_job_index).task_index;

      put_debug ("Assess Release Set");

      a_node            := new crpd_node;
      a_node.job_index  := 0;
      a_node.task_name  := a_trrt.entries (0).task_name;
      a_node.task_index := a_trrt.entries (0).task_index;
      a_node.crpd_value := 0;
      a_node.a_rprt     := new relative_priority_records_table;
      a_node.a_trrt     := a_trrt;
      time              := a_trrt.entries (0).release_time;

      for i in 0 .. number_of_task - 1 loop
         if (i /= k) then
            a_rpr           := new relative_priority_record;
            a_rpr.hpt_index := i;
            a_rpr.lpt_index := k;

            add_relative_priority_record (a_node.a_rprt.all, a_rpr);
         end if;
      end loop;

      compute_crpd_tree
        (tdi                 => tdi,
         number_of_task      => number_of_task,
         counter             => counter,
         a_node              => a_node,
         index               => 1,
         time                => time,
         is_schedulable      => is_schedulable,
         assessing_job_index => assessing_job_index);

      put_debug ("Counter:" & counter'img);
      if (not optimize_memory) then
         counter := 0;
         put_debug ("=======================");
         print_tree (a_node, level, -1, counter);
      end if;
   end assess_release_set;

   --------------------------------
-- Perform feasibilitty testing with CRPD Interference computed by Tree method
   --
   --------------------------------
   procedure opa_feasibility_test_crpd
     (priority_level : in     Integer;
      number_of_task : in     Integer;
      i_task         : in out generic_task_ptr;
      my_tasks       : in out tasks_set;
      a_tuea         : in     task_ucb_ecb_array_ptr;
      is_schedulable :    out Boolean)
   is
      my_iterator_2 : tasks_iterator;
      j_task        : generic_task_ptr;
      t             : Integer;

      refined_tasks : tasks_set;

      c_i : Integer;
      t_i : Integer;
      d_i : Integer;
      s_i : Integer;
      p_i : Integer;

      o_max   : Integer := 0;
      t_start : Integer := 0;

      counter : Integer := 0;

      beta_set            : task_release_records_table_ptr;
      eta_set             : task_release_records_table_ptr;
      a_trr_ext           : task_release_record_ext_ptr;
      assessing_job_index : task_release_records_range;
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
            j_task.priority := 1;
         else
            j_task.priority := priority_range (priority_level);
         end if;

         if (j_task.start_time > o_max) then
            o_max := j_task.start_time;
         end if;

         exit when is_last_element (refined_tasks, my_iterator_2);
         next_element (refined_tasks, my_iterator_2);
      end loop;

      ------------------------------------------------------------------------
      --Print_Task_Set(refined_tasks);

      ------------------------------------------------------------------------
      is_schedulable := True;
      c_i            := i_task.capacity;
      t_i            := periodic_task_ptr (i_task).period;
      d_i            := i_task.deadline;
      s_i := Integer (Double'ceiling (Double (o_max) / Double (t_i))) * (t_i);
      p_i            :=
        calculate_pi
          (priority_level => priority_level,
           my_tasks       => refined_tasks);
      t       := s_i;
      counter := 0;
      put_debug
        ("C_i:" &
         c_i'img &
         " T_i:" &
         t_i'img &
         " - D_i:" &
         d_i'img &
         " - S_i:" &
         s_i'img &
         " - P_i:" &
         p_i'img);

      while (t < s_i + p_i) loop
         calculate_task_release_records_table
           (t_start  => t_start,
            t_end    => t,
            a_task   => i_task,
            my_tasks => refined_tasks,
            a_tuea   => a_tuea,
            a_trrt   => beta_set);
         assessing_job_index := beta_set.nb_entries;

         a_trr_ext              := new task_release_record_ext;
         a_trr_ext.task_name    := i_task.name;
         a_trr_ext.capacity     := i_task.capacity;
         a_trr_ext.release_time := t;
         a_trr_ext.finish_time  := t + i_task.capacity;
         a_trr_ext.deadline     := t + i_task.deadline;
         for i in 0 .. a_tuea'length - 1 loop
            if (a_tuea (i).task_name = i_task.name) then
               a_trr_ext.ucbs       := a_tuea (i).ucbs;
               a_trr_ext.ecbs       := a_tuea (i).ecbs;
               a_trr_ext.task_index := a_tuea (i).task_index;
            end if;
         end loop;
         a_trr_ext.completed := False;
         fill_tasks_ucbs_in_cache (a_trr_ext);
         add (beta_set.all, task_release_record_ptr (a_trr_ext));

         calculate_task_release_records_table
           (t_start  => t,
            t_end    => t + d_i,
            a_task   => i_task,
            my_tasks => refined_tasks,
            a_tuea   => a_tuea,
            a_trrt   => eta_set);

         for i in 0 .. eta_set.nb_entries - 1 loop
            add (beta_set.all, eta_set.entries (i));
         end loop;

         free (eta_set);

         assess_release_set
           (a_trrt              => beta_set,
            tdi                 => t + d_i,
            number_of_task      => number_of_task,
            assessing_job_index => assessing_job_index,
            is_schedulable      => is_schedulable);

         if (not is_schedulable) then
            return;
         end if;

         t_start := t;
         t       := t + t_i;
      end loop;
   end opa_feasibility_test_crpd;

end priority_assignment.audsley_opa_crpd_tree;
