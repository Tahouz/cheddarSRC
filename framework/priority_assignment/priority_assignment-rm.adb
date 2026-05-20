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
--    $Rev: 4830 $
--    $Date: 2024-01-19 20:05:12 +0100 (ven., 19 janv. 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with systems;          use systems;
with Tasks;            use Tasks;
with Framework_Config; use Framework_Config;

package body priority_assignment.rm is
     
   procedure set_priority_according_to_rm
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

      sort (tmp, decreasing_period'access);

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

   end set_priority_according_to_rm;
   
   
   procedure set_priority_according_to_rm
     (my_tasks       : in out tasks_set;
      processor_name : in     Unbounded_String := empty_string;
      criticality    : in     Integer)
   is

      iterator1    : tasks_iterator;
      task1        : generic_task_ptr;
      iterator2    : tasks_iterator;
      task2        : generic_task_ptr;
      current_prio : priority_range;
      tmp          : tasks_set;

   begin

      if processor_name = empty_string then
         duplicate (my_tasks, tmp);
      else
         current_processor_name := processor_name;
         select_and_copy (my_tasks, tmp, select_cpu'access);
      end if;

      -- check the criticality to choose the godd priority interval
      if criticality = 0
      then
      	current_prio := 1;
      elsif criticality = 1
      then
      	current_prio := 70;
      elsif criticality = 2
      then
      	current_prio := 140;
      end if;
      
      periodic_control (tmp, processor_name);

      sort (tmp, decreasing_period'access);

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

   end set_priority_according_to_rm;
   
   
   
   procedure set_priority_mixedcriticality_rm
   (my_tasks       : in out tasks_set;
      processor_name : in     Unbounded_String := empty_string)
   is

      iterator1    : tasks_iterator;
      task1        : generic_task_ptr;
      iterator2    : tasks_iterator;
      task2        : generic_task_ptr;
      iterator3    : tasks_iterator;
      task3        : generic_task_ptr;
      iterator4    : tasks_iterator;
      task4        : generic_task_ptr;
      current_prio : priority_range := 1;
      tmp          : tasks_set;
      taskset1     : tasks_set;
      taskset2     : tasks_set;
      taskset3     : tasks_set;
   begin
   
      if processor_name = empty_string then
         duplicate (my_tasks, tmp);
      else
         current_processor_name := processor_name;
         select_and_copy (my_tasks, tmp, select_cpu'access);
      end if;

      periodic_control (tmp, processor_name);

      initialize(taskset1);
      initialize(taskset2);
      initialize(taskset3);
      
      -- Divide the task into 3 subtaskset by criticality
      reset_iterator (tmp, iterator1);
      loop
      	current_element (tmp, task1, iterator1);
      	if (task1.cpu_name = processor_name) or
           (processor_name = empty_string)
        then
        	if task1.criticality = 0
        	then
        		add(taskset1,task1);
        	elsif task1.criticality = 1
        	then
        		add(taskset2,task1);
        	elsif task1.criticality = 2
        	then
        		add(taskset3,task1);
        	end if;
        end if;	
      	exit when is_last_element (tmp, iterator1);
        next_element (tmp, iterator1);
      end loop;
      
      -- apply rm on each subtaskset
      if not is_empty(taskset1)
      then
      	set_priority_according_to_rm(taskset1,processor_name,0);
      end if;
      if not is_empty(taskset2)
      then
      	set_priority_according_to_rm(taskset2,processor_name,1);
      end if;
      if not is_empty(taskset3)
      then
      	set_priority_according_to_rm(taskset3,processor_name,2);
      end if;
      
      -- Copy resulting task objects in My_Tasks
      --
      reset_iterator (My_Tasks, iterator1);
      loop
         current_element (My_Tasks, task1, iterator1);
         reset_iterator (taskset1, iterator2);
         reset_iterator (taskset2, iterator3);
         reset_iterator (taskset3, iterator4);
         
         -- for the first subtaskset
         if not is_empty(taskset1)
         then
		 loop
		    current_element (taskset1, task2, iterator2);
		    if (task2.name = task1.name) then
		       task1.priority := task2.priority;
		    end if;

		    exit when task2.name = task1.name;
		    exit when is_last_element (taskset1, iterator2);
		    next_element (taskset1, iterator2);
		 end loop;
         end if;
         -- for the second subtaskset
         if not is_empty(taskset2)
         then
		 loop
		    current_element (taskset2, task3, iterator3);
		    if (task3.name = task1.name) then
		       task1.priority := task3.priority;
		    end if;

		    exit when task3.name = task1.name;
		    exit when is_last_element (taskset2, iterator3);
		    next_element (taskset2, iterator3);
		 end loop;
	 end if;
         
         -- for the third subtaskset
         if not is_empty(taskset3)
         then
		 loop
		    current_element (taskset3, task4, iterator4);
		    if (task4.name = task1.name) then
		       task1.priority := task4.priority;
		    end if;

		    exit when task4.name = task1.name;
		    exit when is_last_element (taskset3, iterator4);
		    next_element (taskset3, iterator4);
		 end loop;
	 end if;
         exit when is_last_element (My_Tasks, iterator1);
         next_element (My_Tasks, iterator1);
      end loop;
      
      
      -- free
      free (tmp);
      
   end set_priority_mixedcriticality_rm;

end priority_assignment.rm;
