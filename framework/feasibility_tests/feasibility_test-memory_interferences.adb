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

package body feasibility_test.memory_interferences is

-- Compute rdp_inter, equation  1
--
   procedure maximum_interbank_interferences_memory_delay
     (rdp_inter   :    out Double;
      t           : in     Double;
      my_tasks    : in     tasks_set;
      a_processor : in     generic_processor_ptr;
      my_memory   : in     dram_memory_ptr)
   is
      a_task           : generic_task_ptr;
      my_task_iterator : tasks_iterator;
   begin
      rdp_inter := 0.0;
      reset_iterator (my_tasks, my_task_iterator);
      loop
         current_element (my_tasks, a_task, my_task_iterator);

         if (a_task.cpu_name /= a_processor.name) then
            rdp_inter :=
              rdp_inter +
              (Double
                 (my_memory.l_pre_inter +
                  my_memory.l_act_inter +
                  my_memory.l_rw_inter));
         end if;

         exit when is_last_element (my_tasks, my_task_iterator);
         next_element (my_tasks, my_task_iterator);
      end loop;
   end maximum_interbank_interferences_memory_delay;

-- Compute rdp_intra, equation  3
--
   procedure maximum_intrabank_interferences_memory_delay
     (rdp_intra   :    out Double;
      t           : in     Double;
      my_tasks    : in     tasks_set;
      a_processor : in     generic_processor_ptr;
      my_memory   : in     dram_memory_ptr)
   is
      a_task               : generic_task_ptr;
      my_task_iterator     : tasks_iterator;
      rdp_inter, reorder_p : Double;
   begin
      reorder_p := 0.0;
      queued_memory_request (reorder_p, t, my_tasks, a_processor, my_memory);
      rdp_intra := reorder_p;
      reset_iterator (my_tasks, my_task_iterator);
      loop
         current_element (my_tasks, a_task, my_task_iterator);

         if (a_task.cpu_name /= a_processor.name) then
            rdp_inter := 0.0;
            maximum_interbank_interferences_memory_delay
              (rdp_inter,
               t,
               my_tasks,
               a_processor,
               my_memory);
            rdp_intra := rdp_intra + (Double (my_memory.l_conf) + rdp_inter);
         end if;

         exit when is_last_element (my_tasks, my_task_iterator);
         next_element (my_tasks, my_task_iterator);
      end loop;
   end maximum_intrabank_interferences_memory_delay;

-- Compute reorder_p, equation 4
--
   procedure queued_memory_request
     (reorder_p   :    out Double;
      t           : in     Double;
      my_tasks    : in     tasks_set;
      a_processor : in     generic_processor_ptr;
      my_memory   : in     dram_memory_ptr)
   is
      a_task           : generic_task_ptr;
      my_task_iterator : tasks_iterator;
   begin
      reorder_p := Double (my_memory.l_conhit);
      reset_iterator (my_tasks, my_task_iterator);
      loop
         current_element (my_tasks, a_task, my_task_iterator);

         if (a_task.cpu_name /= a_processor.name) then
            reorder_p :=
              reorder_p +
              (Double (my_memory.l_rw_inter * my_memory.n_reorder));
         end if;

         exit when is_last_element (my_tasks, my_task_iterator);
         next_element (my_tasks, my_task_iterator);
      end loop;
   end queued_memory_request;

-- Compute rdp, equation 5
--
   procedure worst_case_per_request_interference_delay
     (rdp         :    out Double;
      t           : in     Double;
      my_tasks    : in     tasks_set;
      a_processor : in     generic_processor_ptr;
      my_memory   : in     dram_memory_ptr)
   is
      rdp_inter, rdp_intra : Double;
   begin
      rdp_inter := 0.0;
      rdp_intra := 0.0;
      maximum_interbank_interferences_memory_delay
        (rdp_inter,
         t,
         my_tasks,
         a_processor,
         my_memory);
      maximum_intrabank_interferences_memory_delay
        (rdp_intra,
         t,
         my_tasks,
         a_processor,
         my_memory);
      rdp := rdp_inter + rdp_intra;
   end worst_case_per_request_interference_delay;

-- Compute apt, equation 6
--
   procedure maximum_number_of_memory_request
     (apt         :    out Double;
      t           : in     Double;
      my_tasks    : in     tasks_set;
      a_processor : in     generic_processor_ptr)
   is
      a_task           : generic_task_ptr;
      my_task_iterator : tasks_iterator;
   begin
      apt := 0.0;
      reset_iterator (my_tasks, my_task_iterator);
      loop
         current_element (my_tasks, a_task, my_task_iterator);

         if (a_task.cpu_name = a_processor.name) then
            apt :=
              apt +
              Double'ceiling (t / Double (periodic_task_ptr (a_task).period)) *
                (Double (a_task.maximum_number_of_memory_request_per_job));
         end if;

         exit when is_last_element (my_tasks, my_task_iterator);
         next_element (my_tasks, my_task_iterator);
      end loop;
   end maximum_number_of_memory_request;

-- Compute jd_inter, equation 7
--
   procedure worst_case_interbank_interferences_delay
     (jd_inter    :    out Double;
      t           : in     Double;
      my_tasks    : in     tasks_set;
      a_processor : in     generic_processor_ptr;
      my_memory   : in     dram_memory_ptr)
   is
      a_task           : generic_task_ptr;
      my_task_iterator : tasks_iterator;
      apt              : Double;
   begin
      jd_inter := 0.0;
      reset_iterator (my_tasks, my_task_iterator);
      loop
         current_element (my_tasks, a_task, my_task_iterator);

         if (a_task.cpu_name /= a_processor.name) then
            apt := 0.0;
            maximum_number_of_memory_request (apt, t, my_tasks, a_processor);
            jd_inter :=
              jd_inter +
              (apt *
               Double
                 ((my_memory.l_act_inter +
                   my_memory.l_rw_inter +
                   my_memory.l_pre_inter)));
         end if;

         exit when is_last_element (my_tasks, my_task_iterator);
         next_element (my_tasks, my_task_iterator);
      end loop;
   end worst_case_interbank_interferences_delay;

-- Compute jd_intra, equation 8
--
   procedure worst_case_intrabank_interferences_delay
     (jd_intra    :    out Double;
      t           : in     Double;
      my_tasks    : in     tasks_set;
      a_processor : in     generic_processor_ptr;
      my_memory   : in     dram_memory_ptr)
   is
      a_task           : generic_task_ptr;
      my_task_iterator : tasks_iterator;
      apt, jd_inter    : Double;
   begin
      jd_intra := 0.0;
      reset_iterator (my_tasks, my_task_iterator);
      loop
         current_element (my_tasks, a_task, my_task_iterator);

         if (a_task.cpu_name /= a_processor.name) then
            apt := 0.0;
            maximum_number_of_memory_request (apt, t, my_tasks, a_processor);
            jd_inter := 0.0;
            worst_case_interbank_interferences_delay
              (jd_inter,
               t,
               my_tasks,
               a_processor,
               my_memory);
            jd_intra :=
              jd_intra + (apt * Double (my_memory.l_conf)) + jd_inter;
         end if;

         exit when is_last_element (my_tasks, my_task_iterator);
         next_element (my_tasks, my_task_iterator);
      end loop;
   end worst_case_intrabank_interferences_delay;

-- Compute jd, equation 9
--
   procedure worst_case_interferences_delay
     (jd          :    out Double;
      t           : in     Double;
      my_tasks    : in     tasks_set;
      a_processor : in     generic_processor_ptr;
      my_memory   : in     dram_memory_ptr)
   is

      jd_inter, jd_intra : Double;
   begin
      jd_inter := 0.0;
      jd_intra := 0.0;
      worst_case_interbank_interferences_delay
        (jd_inter,
         t,
         my_tasks,
         a_processor,
         my_memory);
      worst_case_intrabank_interferences_delay
        (jd_intra,
         t,
         my_tasks,
         a_processor,
         my_memory);
      jd := jd_inter + jd_intra;
   end worst_case_interferences_delay;

-- Compute min_delay, equation 10
--
   procedure memory_interferences_delay
     (min_delay   :    out Double;
      t           : in     Double;
      task_i      : in     generic_task_ptr;
      my_sys      : in     system;
      a_processor : in     Unbounded_String)
   is

      task1                    : generic_task_ptr;
      processor1               : generic_processor_ptr;
      memory1                  : generic_memory_ptr;
      my_task_iterator         : tasks_iterator;
      my_memory_iterator       : memories_iterator;
      left_min, right_min, rdp : Double;
   begin

      processor1 := search_processor (my_sys.processors, a_processor);
      min_delay  := 0.0;

      if (not is_empty (my_sys.memories)) then
         reset_iterator (my_sys.memories, my_memory_iterator);
         loop
            current_element (my_sys.memories, memory1, my_memory_iterator);

            -- Compute right side of the equation
            --
            right_min := 0.0;
            worst_case_interferences_delay
              (right_min,
               t,
               my_sys.tasks,
               processor1,
               dram_memory_ptr (memory1));

            -- Compute left side of the equation
            --
            left_min := 0.0;
            rdp      := 0.0;
            worst_case_per_request_interference_delay
              (rdp,
               t,
               my_sys.tasks,
               processor1,
               dram_memory_ptr (memory1));
            left_min :=
              rdp * Double (task_i.maximum_number_of_memory_request_per_job);
            reset_iterator (my_sys.tasks, my_task_iterator);
            loop
               current_element (my_sys.tasks, task1, my_task_iterator);

               if (task1.name /= task_i.name) then
                  left_min :=
                    left_min +
                    Double'ceiling
                        (t / Double (periodic_task_ptr (task1).period)) *
                      Double (task1.maximum_number_of_memory_request_per_job) *
                      rdp;

               end if;

               exit when is_last_element (my_sys.tasks, my_task_iterator);
               next_element (my_sys.tasks, my_task_iterator);
            end loop;

            -- Compute actual min_delay
            --
            if (left_min <= right_min) then
               min_delay := min_delay + left_min;
            else
               min_delay := min_delay + right_min;
            end if;

            exit when is_last_element (my_sys.memories, my_memory_iterator);
            next_element (my_sys.memories, my_memory_iterator);
         end loop;
      end if;

   end memory_interferences_delay;

end feasibility_test.memory_interferences;
