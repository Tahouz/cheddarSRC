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

with Tasks;            use Tasks;
with Framework_Config; use Framework_Config;
with systems;          use systems;

package body priority_assignment.dm is

   procedure set_priority_according_to_dm
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

      sort (tmp, decreasing_deadline'access);

      -- Assign priorities
      --
      reset_iterator (tmp, iterator1);

      loop
         current_element (tmp, task1, iterator1);

         if (task1.cpu_name = processor_name) or
           (processor_name = empty_string)
         then

            task1.priority := current_prio;
            current_prio   := current_prio + 1;
         end if;

         exit when is_last_element (tmp, iterator1);
         next_element (tmp, iterator1);

      end loop;

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

   end set_priority_according_to_dm;

end priority_assignment.dm;
