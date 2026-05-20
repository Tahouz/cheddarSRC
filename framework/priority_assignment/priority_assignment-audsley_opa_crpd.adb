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
with priority_assignment.utility;     use priority_assignment.utility;
with priority_assignment.audsley_opa; use priority_assignment.audsley_opa;
with Tasks.extended;                  use Tasks.extended;
with debug;                           use debug;
with integer_arrays;                  use integer_arrays;
with cache_set;                       use cache_set;
with priority_assignment.audsley_opa_crpd_pt;
use priority_assignment.audsley_opa_crpd_pt;
with priority_assignment.audsley_opa_crpd_tree;
use priority_assignment.audsley_opa_crpd_tree;
with systems; use systems;
with Caches;  use Caches;
with Offsets; use Offsets.Offsets_Table_Package;
with sets;
with tables;

package body priority_assignment.audsley_opa_crpd is

   procedure check_input_data
     (my_tasks                 : in tasks_set;
      my_cache_access_profiles : in cache_access_profiles_set)
   is
      a_task          : generic_task_ptr;
      my_iterator     : tasks_iterator;
      a_cap           : cache_access_profile_ptr;
      my_iterator_cap : cache_access_profiles_iterator;
   begin

      if
        (Integer (get_number_of_elements (my_cache_access_profiles)) <= 0)
      then
         raise cache_access_profile_must_be_defined;
      end if;

      reset_iterator (my_tasks, my_iterator);
      loop
         current_element (my_tasks, a_task, my_iterator);

         if (a_task.task_type /= periodic_type) then
            raise task_must_be_periodic;
         end if;

         --           if(a_task.offsets.Nb_Entries <= 0) then
         --              raise Offset_Must_Be_Defined;
         --           end if;

--Exception Cache_Access_Profile_Not_Found will be raised if there is a problem
         a_cap :=
           search_cache_access_profile
             (my_cache_access_profiles,
              a_task.cache_access_profile_name);

         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;
   end check_input_data;

   procedure cpa
     (my_tasks                 : in out tasks_set;
      my_cache_access_profiles : in     cache_access_profiles_set;
      complexity : in crpd_inteference_computation_complexity := pt_simplified)
   is
      delta_set                : tasks_set;
      delta_set_ecb            : tasks_set;
      my_iterator              : tasks_iterator;
      my_iterator_ecb          : tasks_iterator;
      a_task                   : generic_task_ptr;
      a_task_ecb               : generic_task_ptr;
      temp_task                : generic_task_ptr;
      n                        : Integer := 1;
      unassigned               : Boolean;
      is_schedulable           : Boolean;
      a_task_ucb_ecb_array_ptr : task_ucb_ecb_array_ptr;
      a_cap                    : cache_access_profile_ptr;
   begin
      cap_to_tuea
        (my_tasks                 => my_tasks,
         my_cache_access_profiles => my_cache_access_profiles,
         a_task_ucb_ecb_array     => a_task_ucb_ecb_array_ptr);

      duplicate (src => my_tasks, dest => delta_set);

      n := Integer (delta_set.get_number_of_elements);
      for j in 1 .. n loop
         unassigned := True;
         sort
           (delta_set,
            decreasing_period_deadline'
              access);                     --The task set is sorted by period and deadline - DESC
         reset_iterator (delta_set, my_iterator);

         loop
            current_element (delta_set, a_task, my_iterator);
            --Put_Line("Assessing task: " & To_String(a_task.name) & " at priority level: " & j'Img);

            if (complexity = ecb_only) then
               --
               duplicate (delta_set, delta_set_ecb);
               reset_iterator (delta_set_ecb, my_iterator_ecb);
               loop
                  current_element (delta_set_ecb, a_task_ecb, my_iterator_ecb);
                  if (a_task_ecb.name /= a_task.name) then
                     a_cap :=
                       search_cache_access_profile
                         (my_cache_access_profiles,
                          a_task_ecb.cache_access_profile_name);
                     a_task_ecb.capacity :=
                       a_task_ecb.capacity +
                       Natural
                         (a_cap.ECBs
                            .nb_entries);       -- Adding ECB to task's capacity
                  end if;

                  exit when is_last_element (delta_set_ecb, my_iterator_ecb);
                  next_element (delta_set_ecb, my_iterator_ecb);
               end loop;

               opa_feasibility_test
                 (priority_level => j,
                  i_task         => a_task,
                  my_tasks       => delta_set_ecb,
                  is_schedulable => is_schedulable);

            elsif (complexity = pt_simplified) then
               opa_feasibility_test_crpd_upperbound
                 (priority_level           => j,
                  i_task                   => a_task,
                  my_tasks                 => delta_set,
                  is_schedulable           => is_schedulable,
                  a_task_ucb_ecb_array_ptr => a_task_ucb_ecb_array_ptr,
                  be_complexity            => False);
            elsif (complexity = pt_binomial_coefficient) then
               opa_feasibility_test_crpd_upperbound
                 (priority_level           => j,
                  i_task                   => a_task,
                  my_tasks                 => delta_set,
                  is_schedulable           => is_schedulable,
                  a_task_ucb_ecb_array_ptr => a_task_ucb_ecb_array_ptr,
                  be_complexity            => True);
            elsif (complexity = tree) then
               opa_feasibility_test_crpd
                 (priority_level => j,
                  i_task         => a_task,
                  my_tasks       => delta_set,
                  a_tuea         => a_task_ucb_ecb_array_ptr,
                  is_schedulable => is_schedulable,
                  number_of_task => n);
            end if;

            if (is_schedulable) then
               --Put_Line("Assign priority level:" & j'Img & " to task: " & To_String(a_task.name) & ASCII.LF & "---");
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

   end cpa;

   procedure set_priority_according_to_cpa
     (my_tasks                 : in out tasks_set;
      my_cache_access_profiles : in     cache_access_profiles_set;
      computation_complexity   : in crpd_inteference_computation_complexity :=
        pt_simplified;
      processor_name : in Unbounded_String := empty_string)
   is

      iterator1 : tasks_iterator;
      task1     : generic_task_ptr;
      iterator2 : tasks_iterator;
      task2     : generic_task_ptr;
      tmp       : tasks_set;

   begin
      if processor_name = empty_string then
         duplicate (my_tasks, tmp);
      else
         current_processor_name := processor_name;
         select_and_copy (my_tasks, tmp, select_cpu'access);
      end if;

      periodic_control (tmp, processor_name);
      check_input_data (tmp, my_cache_access_profiles);

      -- Assign priorities
      --
      cpa
        (my_tasks                 => tmp,
         my_cache_access_profiles => my_cache_access_profiles,
         complexity               => computation_complexity);

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
   end set_priority_according_to_cpa;

end priority_assignment.audsley_opa_crpd;
