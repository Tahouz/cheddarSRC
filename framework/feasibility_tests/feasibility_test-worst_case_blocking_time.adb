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
--    $Rev: 4608 $
--    $Date: 2023-10-26 16:08:53 +0200 (jeu., 26 oct. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

package body feasibility_test.worst_case_blocking_time is

   procedure compute_blocking_time
     (my_scheduler   : in     generic_scheduler_ptr;
      my_tasks       : in     tasks_set;
      my_resources   : in     resources_set;
      processor_name : in     Unbounded_String;
      msg            : in out Unbounded_String;
      blocking_time  :    out blocking_time_table)
   is
   begin
      case my_scheduler.parameters.scheduler_type is
         when rate_monotonic_protocol                 |
           deadline_monotonic_protocol                |
           posix_1003_highest_priority_first_protocol =>
            compute_blocking_time
              (fixed_priority_scheduler (my_scheduler.all),
               my_tasks,
               my_resources,
               processor_name,
               msg,
               blocking_time);
         when others =>
            raise invalid_scheduler;
      end case;
   end compute_blocking_time;

   function compute_pcp_blocking_time
     (my_tasks     : in tasks_set;
      my_resources : in resources_set;
      task_name    : in Unbounded_String) return Natural
   is
      blocking_time : Natural := 0;

      my_resource_iterator : resources_iterator;
      a_resource           : generic_resource_ptr;
      a_task1_ptr          : generic_task_ptr;
      a_task2_ptr          : generic_task_ptr;

   begin
      reset_iterator (my_resources, my_resource_iterator);
      loop
         current_element (my_resources, a_resource, my_resource_iterator);

         if (a_resource.protocol /= priority_ceiling_protocol) and
           (a_resource.protocol /= immediate_priority_ceiling_protocol)
         then
            raise other_resources_protocol_found;
         end if;

         for i in 0 .. a_resource.critical_sections.nb_entries - 1 loop

            -- We are on a resource used by Task_Name
            -- Let find now the largest private section
            --
            if (a_resource.critical_sections.entries (i).item = task_name) then

               for j in 0 .. a_resource.critical_sections.nb_entries - 1 loop

                  if
                    (a_resource.critical_sections.entries (j).item /=
                     task_name)
                  then

                     -- Check that the task is a lower priority task
                     --
                     a_task1_ptr := search_task (my_tasks, task_name);
                     a_task2_ptr :=
                       search_task
                         (my_tasks,
                          a_resource.critical_sections.entries (j).item);
                     if a_task2_ptr.priority < a_task1_ptr.priority then

                        blocking_time :=
                          Natural'max
                            (blocking_time,
                             a_resource.critical_sections.entries (j).data
                               .task_end -
                             a_resource.critical_sections.entries (j).data
                               .task_begin +
                             1);
                     end if;
                  end if;

               end loop;
            end if;
         end loop;

         exit when is_last_element (my_resources, my_resource_iterator);
         next_element (my_resources, my_resource_iterator);
      end loop;

      return blocking_time;

   end compute_pcp_blocking_time;

   function compute_pip_blocking_time
     (my_tasks     : in tasks_set;
      my_resources : in resources_set;
      task_name    : in Unbounded_String) return Natural
   is
      blocking_time : Natural := 0;

      my_resource_iterator : resources_iterator;
      a_resource           : generic_resource_ptr;
      my_task_iterator     : tasks_iterator;
      a_task1 : constant generic_task_ptr := search_task (my_tasks, task_name);
      a_task2              : generic_task_ptr;

   begin
      -- We look for all task which has a lowest priority
      -- Then, we add all critical section of these task
      --
      reset_iterator (my_tasks, my_task_iterator);
      loop
         current_element (my_tasks, a_task2, my_task_iterator);

         if (a_task2.priority <= a_task1.priority) and
           (a_task2.name /= a_task1.name)
         then

            -- We found a lowest priority task : now, find its critical
            -- sections !
            --
            reset_iterator (my_resources, my_resource_iterator);
            loop
               current_element
                 (my_resources,
                  a_resource,
                  my_resource_iterator);

               if a_resource.protocol /= priority_inheritance_protocol then
                  raise other_resources_protocol_found;
               end if;

               for i in 0 .. a_resource.critical_sections.nb_entries - 1 loop

                  -- We found a given critical section : increase blocking
                  --time !
                  --
                  if
                    (a_resource.critical_sections.entries (i).item =
                     a_task2.name)
                  then
                     blocking_time :=
                       blocking_time +
                       a_resource.critical_sections.entries (i).data.task_end -
                       a_resource.critical_sections.entries (i).data
                         .task_begin +
                       1;
                  end if;
               end loop;

               exit when is_last_element (my_resources, my_resource_iterator);
               next_element (my_resources, my_resource_iterator);
            end loop;

         end if;

         exit when is_last_element (my_tasks, my_task_iterator);
         next_element (my_tasks, my_task_iterator);
      end loop;
      return blocking_time;

   end compute_pip_blocking_time;

   function compute_bound_on_task_blocking_time
     (my_scheduler : in fixed_priority_scheduler;
      my_tasks     : in tasks_set;
      my_resources : in resources_set;
      a_task       : in Unbounded_String) return Natural
   is
      bound_on_blocking_time : Natural := 0;
      iterator1              : resources_iterator;
      resource1              : generic_resource_ptr;

   begin

      -- First check that each resource used by the task have the same protocol
      --
      same_protocol_control (my_resources, a_task);

      -- Dispatch blocking computation according to the protocol of resources
      --
      reset_iterator (my_resources, iterator1);

      loop
         current_element (my_resources, resource1, iterator1);

         -- Looking for task user in the task_list index_table
         --
         for i in 0 .. resource1.critical_sections.nb_entries - 1 loop
            case resource1.protocol is
               when priority_ceiling_protocol        |
                 immediate_priority_ceiling_protocol =>
                  bound_on_blocking_time :=
                    compute_pcp_blocking_time (my_tasks, my_resources, a_task);
               when priority_inheritance_protocol =>
                  bound_on_blocking_time :=
                    compute_pip_blocking_time (my_tasks, my_resources, a_task);
               when others =>
                  raise invalid_protocol;
            end case;

            return bound_on_blocking_time;
         end loop;

         exit when is_last_element (my_resources, iterator1);
         next_element (my_resources, iterator1);

      end loop;

      return bound_on_blocking_time;

   end compute_bound_on_task_blocking_time;

   procedure compute_blocking_time
     (my_scheduler   : in     fixed_priority_scheduler;
      my_tasks       : in     tasks_set;
      my_resources   : in     resources_set;
      processor_name : in     Unbounded_String;
      msg            : in out Unbounded_String;
      blocking_time  :    out blocking_time_table)
   is

      my_task_iterator1 : tasks_iterator;
      tmp               : tasks_set;
      a_task1           : generic_task_ptr;

   begin

      current_processor_name := processor_name;
      select_and_copy (my_tasks, tmp, select_cpu'access);

      -- Set priority according to the scheduler
      --
      if
        (my_scheduler.parameters.scheduler_type = deadline_monotonic_protocol)
      then
         set_priority_according_to_dm (tmp);
      else
         if
           (my_scheduler.parameters.scheduler_type = rate_monotonic_protocol)
         then
            set_priority_according_to_rm (tmp);
         end if;
      end if;

      initialize (blocking_time);

      -- Compute blocking time for each task
      --
      reset_iterator (tmp, my_task_iterator1);
      loop

         current_element (tmp, a_task1, my_task_iterator1);

         if a_task1.cpu_name = processor_name then

            begin
               blocking_time.entries (blocking_time.nb_entries).data :=
                 Double
                   (compute_bound_on_task_blocking_time
                      (my_scheduler,
                       tmp,
                       my_resources,
                       a_task1.name));
               blocking_time.entries (blocking_time.nb_entries).item :=
                 a_task1;
               blocking_time.nb_entries := blocking_time.nb_entries + 1;
            exception
               when can_not_used_different_protocol =>
                  msg :=
                    msg &
                    unbounded_lf &
                    lb_tab4 &
                    a_task1.name &
                    " => " &
                    lb_compute_blocking_error1 (Current_Language);
               when invalid_protocol =>
                  msg :=
                    msg &
                    unbounded_lf &
                    lb_tab4 &
                    a_task1.name &
                    " => " &
                    lb_compute_blocking_error3 (Current_Language);
            end;

         end if;

         exit when is_last_element (tmp, my_task_iterator1);

         next_element (tmp, my_task_iterator1);

      end loop;

      if msg /= empty_string then
         msg := msg & unbounded_lf;
      end if;

   end compute_blocking_time;

end feasibility_test.worst_case_blocking_time;
