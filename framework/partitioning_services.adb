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

with Ada.Numerics;                      use Ada.Numerics;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with scheduler_io;                      use scheduler_io;
with Statements;                        use Statements;
with expressions;                       use expressions;
use expressions.variables_type_package;
with Processor_Interface; use Processor_Interface;
with Core_Units;          use Core_Units;
use Core_Units.Core_Units_Table_Package;
with Tasks;                           use Tasks;
with Ada.Strings.Unbounded.Text_IO;   use Ada.Strings.Unbounded.Text_IO;
with unbounded_strings;               use unbounded_strings;
with scheduler;                       use scheduler;
with Scheduler_Interface;             use Scheduler_Interface;
with Interpreter.extended;            use Interpreter.extended;
with dependency_services;             use dependency_services;
with translate;                       use translate;
with io_tools;                        use io_tools;
with Ada.IO_Exceptions;               use Ada.IO_Exceptions;
with Ada.Exceptions;                  use Ada.Exceptions;
with xml_generic_parsers;             use xml_generic_parsers;
with xml_generic_parsers.event_table; use xml_generic_parsers.event_table;
with Input_Sources.File;              use Input_Sources.File;
with Sax.Readers;                     use Sax.Readers;
with Text_IO;                         use Text_IO;
with Parser;                          use Parser;
with Sections;                        use Sections;
with section_set;                     use section_set;
with Address_Spaces;                  use Address_Spaces;
with debug;                           use debug;

package body partitioning_services is

   procedure partition_small_task
     (src_processors   : in     processors_set;
      src_tasks        : in     tasks_set;
      msg              : in out Unbounded_String;
      result_tasks     : in out tasks_set;
      processor_result :    out processors_iterator)
   is

      a_task_result           : periodic_task_ptr;
      my_task_iterator_result : tasks_iterator;
      a_processor             : generic_processor_ptr;
      my_processor_iterator   : processors_iterator;
      the_cores               : core_units_table;

      processor_util, beta : Float   := 0.0;
      s_cur                : Float   := 1.0;
      first_run            : Boolean := True;

   begin
      -- validate the processor/task set
      validate_multiprocessor_tasks (src_processors, src_tasks);

      -- copy the input task set to the result one which processor/core name will be modified according to the placement algorithm
      duplicate (src_tasks, result_tasks);
      sort (result_tasks, increasing_si'access);

      -- reset the task iterator
      reset_iterator (result_tasks, my_task_iterator_result);
      current_element
        (result_tasks,
         generic_task_ptr (a_task_result),
         my_task_iterator_result);

      -- reset the processor iterator
      reset_iterator (src_processors, my_processor_iterator);
      current_element (src_processors, a_processor, my_processor_iterator);

      loop -- processors/tasks
         if first_run = False then
            if is_last_element (src_processors, my_processor_iterator) then
               duplicate (src_tasks, result_tasks);
               raise no_such_processors;
            end if;

            -- next processor
            next_element (src_processors, my_processor_iterator);
            current_element
              (src_processors,
               a_processor,
               my_processor_iterator);
         end if;

         first_run := False;
         if Float (a_task_result.capacity) / Float (a_task_result.period) >
           1.0
         then
            duplicate (src_tasks, result_tasks);
            raise no_such_processors;
         end if;

         the_cores := build_core_table (a_processor);

         -- set the first task processor/core name. JLE : have to make this initialization at different places for the monocore/multicore cases (the exit condidition location
         -- seems to be important, otherwise, the placement is different)
         if a_processor.processor_type = monocore_type then
            a_task_result.cpu_name  := a_processor.name;
            a_task_result.core_name := the_cores.entries (0).name;
         end if;

         exit when is_last_element (result_tasks, my_task_iterator_result);

         for i in 0 .. the_cores.nb_entries - 1 loop
            -- set the first task processor/core name
            if a_processor.processor_type /= monocore_type then
               a_task_result.cpu_name  := a_processor.name;
               a_task_result.core_name := the_cores.entries (i).name;
            end if;

            processor_util :=
              Float (a_task_result.capacity) / Float (a_task_result.period);
            s_cur :=
              Float (Log (Float (a_task_result.period), 2.0)) -
              Float'floor (Float (Log (Float (a_task_result.period), 2.0)));
            beta := 0.0;

            loop -- tasks
               if is_last_element (result_tasks, my_task_iterator_result) then
                  first_run := True;
                  exit;
               end if;

               -- next task
               next_element (result_tasks, my_task_iterator_result);
               current_element
                 (result_tasks,
                  generic_task_ptr (a_task_result),
                  my_task_iterator_result);

               beta :=
                 (Float (Log (Float (a_task_result.period), 2.0)) -
                  Float'floor
                    (Float (Log (Float (a_task_result.period), 2.0)))) -
                 s_cur;
               processor_util :=
                 processor_util +
                 Float (a_task_result.capacity) / Float (a_task_result.period);

               if
                 (processor_util <=
                  Float'max
                    (Float (Log (2.0, e)),
                     1.0 - beta * Float (Log (2.0, e))))
               then
                  a_task_result.cpu_name  := a_processor.name;
                  a_task_result.core_name := the_cores.entries (i).name;
               else
                  exit; -- go to next core
               end if;
            end loop; -- tasks

            if first_run = True then
               exit;
            end if;
         end loop; -- cores

      end loop;

      processor_result := my_processor_iterator;
      sort (result_tasks, increasing_name'access);

   end partition_small_task;

   procedure partition_small_task
     (src_processors : in     processors_set;
      src_tasks      : in     tasks_set;
      msg            : in out Unbounded_String;
      result_tasks   : in out tasks_set)
   is
      tmp : processors_iterator;
   begin

      msg :=
        To_Unbounded_String (" (") &
        lb_see (Current_Language) &
        To_Unbounded_String ("[9], [10]) ");

      partition_small_task (src_processors, src_tasks, msg, result_tasks, tmp);
   end partition_small_task;

   procedure partition_small_task
     (src_processors   : in     processors_set;
      result_tasks     : in out tasks_set;
      processor_result :    out processors_iterator)
   is
      src_tasks : tasks_set;
      msg       : Unbounded_String;
   begin
      duplicate (result_tasks, src_tasks);
      partition_small_task
        (src_processors,
         src_tasks,
         msg,
         result_tasks,
         processor_result);
   end partition_small_task;

   procedure rm_general_tasks
     (src_processors : in     processors_set;
      result_tasks   : in out tasks_set)
   is

      a_task_result           : periodic_task_ptr;
      a_task_tmp              : periodic_task_ptr;
      a_task_iterator         : tasks_iterator;
      my_task_iterator_result : tasks_iterator;
      tmp_iterator            : tasks_iterator;
      a_processor             : generic_processor_ptr;
      my_processor_iterator   : processors_iterator;
      src_tasks               : tasks_set;
      the_cores               : core_units_table;

      num_of_tasks                        : Integer := 0;
      task_utilization, total_utilization : Float   := 0.0;
      goto_first_loop                     : Boolean := False;
   begin
      duplicate (result_tasks, src_tasks);

      -- reset the task iterator
      reset_iterator (result_tasks, my_task_iterator_result);
      current_element
        (result_tasks,
         generic_task_ptr (a_task_result),
         my_task_iterator_result);

      -- reset the processor iterator
      reset_iterator (src_processors, my_processor_iterator);
      current_element (src_processors, a_processor, my_processor_iterator);

      sort (result_tasks, increasing_period'access);

      -- Empty processor/core name
      --
      loop
         a_task_result.cpu_name  := To_Unbounded_String ("");
         a_task_result.core_name := To_Unbounded_String ("");

         exit when is_last_element (result_tasks, my_task_iterator_result);

         next_element (result_tasks, my_task_iterator_result);
         current_element
           (result_tasks,
            generic_task_ptr (a_task_result),
            my_task_iterator_result);
      end loop;

      -- re initialize the tasks iterator
      reset_iterator (result_tasks, my_task_iterator_result);
      current_element
        (result_tasks,
         generic_task_ptr (a_task_result),
         my_task_iterator_result);

      loop  -- tasks
         loop -- processors
            if goto_first_loop then
               goto_first_loop := False;
               exit;
            end if;

            the_cores := build_core_table (a_processor);

            for i in 0 .. the_cores.nb_entries - 1 loop
               -- Fetch information for condition-IP
               --
               -- backup the current tasks iterator
               tmp_iterator := my_task_iterator_result;

               -- reset the task iterator
               reset_iterator (result_tasks, my_task_iterator_result);
               current_element
                 (result_tasks,
                  generic_task_ptr (a_task_result),
                  my_task_iterator_result);

               -- compute the current total utilisation and number of tasks placed on the current core
               num_of_tasks      := 0;
               total_utilization := 0.0;
               loop
                  -- JLLE : perhaps the condition a_task_result.cpu_name = a_processor.name should be added
                  if a_task_result.core_name = the_cores.entries (i).name then
                     num_of_tasks      := num_of_tasks + 1;
                     total_utilization :=
                       total_utilization +
                       Float (a_task_result.capacity) /
                         Float (a_task_result.period);
                  end if;

                  exit when is_last_element
                      (result_tasks,
                       my_task_iterator_result);

                  next_element (result_tasks, my_task_iterator_result);
                  current_element
                    (result_tasks,
                     generic_task_ptr (a_task_result),
                     my_task_iterator_result);
               end loop;

               -- restore the current tasks iterator
               my_task_iterator_result := tmp_iterator;

               current_element
                 (result_tasks,
                  generic_task_ptr (a_task_result),
                  my_task_iterator_result);

               task_utilization :=
                 Float (a_task_result.capacity) / Float (a_task_result.period);

               if task_utilization <=
                 2.0 *
                     (1.0 /
                      ((1.0 + total_utilization / Float (num_of_tasks)))**
                        num_of_tasks) -
                   1.0
               then
                  if total_utilization = 0.0 then
                     a_task_result.cpu_name  := a_processor.name;
                     a_task_result.core_name := the_cores.entries (i).name;

                     goto_first_loop := True;

                     exit; -- next task, same processor
                  end if;

                  -- reset the task iterator
                  reset_iterator (result_tasks, a_task_iterator);
                  current_element
                    (result_tasks,
                     generic_task_ptr (a_task_tmp),
                     a_task_iterator);

                  loop -- tasks
                     -- JLE perhaps the condition a_task_tmp.cpu_name = a_processor.name should be added
                     if a_task_tmp.core_name = the_cores.entries (i).name and
                       a_task_tmp /= a_task_result
                     then
                        if a_task_result.period < a_task_tmp.period and
                          (Integer
                             (Float'floor
                                (Float (a_task_tmp.period) /
                                 Float (a_task_result.period))) *
                           (a_task_tmp.period - a_task_result.capacity) >=
                           a_task_tmp.capacity or
                           a_task_tmp.period >=
                             Integer
                                   (Float'ceiling
                                      (Float (a_task_tmp.period) /
                                       Float (a_task_result.period))) *
                                 a_task_result.capacity +
                               a_task_tmp.capacity)
                        then
                           a_task_result.cpu_name  := a_processor.name;
                           a_task_result.core_name :=
                             the_cores.entries (i).name;

                           -- reset the processor iterator
                           reset_iterator
                             (src_processors,
                              my_processor_iterator);
                           goto_first_loop := True;

                           exit; -- next task, first processor
                        else
                           if a_task_result.period >= a_task_tmp.period and
                             ((
                               (Integer
                                  (Float'floor
                                     (Float (a_task_result.period) /
                                      Float (a_task_tmp.period))) *
                                (a_task_result.period -
                                 a_task_tmp.capacity)) >=
                               a_task_result.capacity) or
                              (a_task_result.period >=
                               (Integer
                                  (Float'ceiling
                                     (Float (a_task_result.period) /
                                      Float (a_task_tmp.period))) *
                                a_task_tmp.capacity +
                                a_task_result.capacity)))
                           then
                              a_task_result.cpu_name  := a_processor.name;
                              a_task_result.core_name :=
                                the_cores.entries (i).name;

                              -- reset the processor iterator
                              reset_iterator
                                (src_processors,
                                 my_processor_iterator);
                              goto_first_loop := True;

                              exit; -- go to next task, first processor
                           else
                              if is_last_element
                                  (src_processors,
                                   my_processor_iterator) and
                                i = the_cores.nb_entries - 1
                              then -- no placement has been found for this task and there is no place, raise an error
                                 duplicate (src_tasks, result_tasks);
                                 raise no_such_processors;
                              end if;

                              exit; -- go to next core
                           end if;
                        end if;
                     end if;

                     exit when is_last_element (result_tasks, a_task_iterator);

                     next_element (result_tasks, a_task_iterator);
                     current_element
                       (result_tasks,
                        generic_task_ptr (a_task_tmp),
                        a_task_iterator);
                  end loop; -- tasks

                  if goto_first_loop = True then -- the task has been placed
                     exit;
                  end if;
               else
                  if is_last_element
                      (src_processors,
                       my_processor_iterator) and
                    i = the_cores.nb_entries - 1
                  then -- no placement has been found for this task and there is no place, raise an error
                     duplicate (src_tasks, result_tasks);
                     raise no_such_processors;
                  end if;
               end if;
            end loop; -- cores

            if goto_first_loop = False then
               next_element (src_processors, my_processor_iterator);
               current_element
                 (src_processors,
                  a_processor,
                  my_processor_iterator);
            end if;

         end loop; -- processors

         exit when is_last_element (result_tasks, my_task_iterator_result);

         next_element (result_tasks, my_task_iterator_result);
      end loop; -- tasks
   end rm_general_tasks;

   procedure partition_general_task
     (src_processors : in     processors_set;
      src_tasks      : in     tasks_set;
      msg            : in out Unbounded_String;
      result_tasks   : in out tasks_set)
   is

      a_task_result           : periodic_task_ptr;
      my_task_iterator_result : tasks_iterator;
      my_processor_iterator   : processors_iterator;
      a_processor             : generic_processor_ptr;

      rmst_tasks : tasks_set;
      rmgt_tasks : tasks_set;
      tmp_cpus   : processors_set;

      rmst_index, rmgt, num_of_tasks : Integer := 0;

   begin
      -- validate the processor/task set
      validate_multiprocessor_tasks (src_processors, src_tasks);

      msg :=
        To_Unbounded_String (" (") &
        lb_see (Current_Language) &
        To_Unbounded_String ("[9], [10]) ");

      -- copy the input task set to the result one which processor/core name will be modified according to the placement algorithm
      duplicate (src_tasks, result_tasks);
      sort (result_tasks, increasing_utilization'access);

      -- Scan for max Alfa to make division between RMST and RMGT tasks
      --
      reset_iterator (result_tasks, my_task_iterator_result);
      current_element
        (result_tasks,
         generic_task_ptr (a_task_result),
         my_task_iterator_result);
      loop
         if Float (a_task_result.capacity) / Float (a_task_result.period) >
           1.0 / 3.0
         then
            exit;
         else
            rmgt := rmgt + 1;
         end if;

         exit when is_last_element (result_tasks, my_task_iterator_result);

         next_element (result_tasks, my_task_iterator_result);
         current_element
           (result_tasks,
            generic_task_ptr (a_task_result),
            my_task_iterator_result);
      end loop;

      -- Make bin-packing for RMST and RMGT
      --
      reset_iterator (result_tasks, my_task_iterator_result);
      current_element
        (result_tasks,
         generic_task_ptr (a_task_result),
         my_task_iterator_result);
      loop
         exit when rmst_index = rmgt;

         add (rmst_tasks, generic_task_ptr (a_task_result));
         rmst_index := rmst_index + 1;

         next_element (result_tasks, my_task_iterator_result);
         current_element
           (result_tasks,
            generic_task_ptr (a_task_result),
            my_task_iterator_result);
      end loop;

      num_of_tasks := Integer (get_number_of_elements (result_tasks));
      if rmgt /= num_of_tasks then
         loop
            current_element
              (result_tasks,
               generic_task_ptr (a_task_result),
               my_task_iterator_result);
            add (rmgt_tasks, generic_task_ptr (a_task_result));

            exit when is_last_element (result_tasks, my_task_iterator_result);

            next_element (result_tasks, my_task_iterator_result);
         end loop;
      end if;

      -- Call RMST and RMGT functions respectively
      --
      if (is_empty (rmst_tasks) = False) then
         partition_small_task
           (src_processors,
            rmst_tasks,
            my_processor_iterator);
      end if;

      if False = is_last_element (src_processors, my_processor_iterator) and
        is_empty (rmgt_tasks) = False
      then
         -- Make processor set for RMGT
         --
         next_element (src_processors, my_processor_iterator);
         current_element (src_processors, a_processor, my_processor_iterator);
         loop
            add (tmp_cpus, a_processor);

            exit when is_last_element (src_processors, my_processor_iterator);

            next_element (src_processors, my_processor_iterator);
            current_element
              (src_processors,
               a_processor,
               my_processor_iterator);
         end loop;

         rm_general_tasks (tmp_cpus, rmgt_tasks);

      else
         if (is_last_element (src_processors, my_processor_iterator)) and
           (is_empty (rmgt_tasks) = False)
         then
            duplicate (src_tasks, result_tasks);
            raise no_such_processors;
         end if;
      end if;

      -- Put results of two functions to returning task set
      --
      if not is_empty (rmst_tasks) then
         duplicate (rmst_tasks, result_tasks);
      end if;

      if not is_empty (rmgt_tasks) then
         reset_iterator (rmgt_tasks, my_task_iterator_result);
         current_element
           (rmgt_tasks,
            generic_task_ptr (a_task_result),
            my_task_iterator_result);
         loop
            
            add (result_tasks, generic_task_ptr (a_task_result));

            exit when is_last_element (rmgt_tasks, my_task_iterator_result);

            next_element (rmgt_tasks, my_task_iterator_result);
            current_element
              (rmgt_tasks,
               generic_task_ptr (a_task_result),
               my_task_iterator_result);
         end loop;
      end if;

      sort (result_tasks, increasing_name'access);

   end partition_general_task;

   procedure partition_next_fit
     (src_processors : in     processors_set;
      src_tasks      : in     tasks_set;
      msg            : in out Unbounded_String;
      result_tasks   : in out tasks_set)
   is

      a_task_result           : periodic_task_ptr;
      my_task_iterator_result : tasks_iterator;
      a_processor             : generic_processor_ptr;
      my_processor_iterator   : processors_iterator;
      the_cores               : core_units_table;

      m                 : Integer := 2;
      total_utilization : Float   := 0.0;
      condition_ip      : Boolean := False;

   begin
      -- validate the processor/task set
      validate_multiprocessor_tasks (src_processors, src_tasks);

      msg :=
        To_Unbounded_String (" (") &
        lb_see (Current_Language) &
        To_Unbounded_String ("[9], [10]) ");

      -- copy the input task set to the result one which processor/core name will be modified according to the placement algorithm
      duplicate (src_tasks, result_tasks);
      sort (result_tasks, increasing_period'access);

      -- reset the task iterator
      reset_iterator (result_tasks, my_task_iterator_result);
      current_element
        (result_tasks,
         generic_task_ptr (a_task_result),
         my_task_iterator_result);

      -- reset the processor iterator
      reset_iterator (src_processors, my_processor_iterator);
      current_element (src_processors, a_processor, my_processor_iterator);

      loop
         the_cores := build_core_table (a_processor);
         if a_processor.processor_type =
           monocore_type
         then -- JLE : have to make this initialization at different location for the monocore/multicore cases
            if Float (a_task_result.capacity) / Float (a_task_result.period) <=
              1.0
            then
               a_task_result.cpu_name  := a_processor.name;
               a_task_result.core_name := the_cores.entries (0).name;
            else
               duplicate (src_tasks, result_tasks);
               raise no_such_processors;
            end if;
         end if;

         exit when is_last_element (result_tasks, my_task_iterator_result);

         for i in 0 .. the_cores.nb_entries - 1 loop
            if a_processor.processor_type /=
              monocore_type
            then -- JLE : have to make this initialization at different location for the monocore/multicore cases
               if Float (a_task_result.capacity) /
                 Float (a_task_result.period) <=
                 1.0
               then
                  a_task_result.cpu_name  := a_processor.name;
                  a_task_result.core_name := the_cores.entries (i).name;
               else
                  duplicate (src_tasks, result_tasks);
                  raise no_such_processors;
               end if;
            end if;

            loop -- tasks
               exit when is_last_element
                   (result_tasks,
                    my_task_iterator_result);

               total_utilization :=
                 total_utilization +
                 Float (a_task_result.capacity) / Float (a_task_result.period);

               -- next task
               next_element (result_tasks, my_task_iterator_result);
               current_element
                 (result_tasks,
                  generic_task_ptr (a_task_result),
                  my_task_iterator_result);

               if Float (a_task_result.capacity) /
                 Float (a_task_result.period) <=
                 2.0 *
                     (1.0 /
                      (1.0 + total_utilization / Float ((m - 1)))**(m - 1)) -
                   1.0 and
                 total_utilization <=
                   Float (m - 1) * (2.0**(1.0 / Float (m - 1)) - 1.0)
               then
                  condition_ip := True;
               else
                  condition_ip := False;
               end if;

               if condition_ip then
                  a_task_result.cpu_name  := a_processor.name;
                  a_task_result.core_name := the_cores.entries (i).name;
                  m                       := m + 1;
               else
                  if i = the_cores.nb_entries - 1 then -- last core
                     if is_last_element
                         (src_processors,
                          my_processor_iterator)
                     then
                        duplicate (src_tasks, result_tasks);
                        raise no_such_processors;
                     end if;

                     -- next processor
                     next_element (src_processors, my_processor_iterator);
                     current_element
                       (src_processors,
                        a_processor,
                        my_processor_iterator);
                  end if;

                  total_utilization := 0.0;
                  m                 := 2;
                  exit;
               end if;
            end loop; -- tasks

            if i = the_cores.nb_entries - 1 then
               exit;
            end if;
         end loop; -- cores

      end loop; -- processors

      sort (result_tasks, increasing_name'access);

   end partition_next_fit;

   procedure partition_first_fit
     (src_processors : in     processors_set;
      src_tasks      : in     tasks_set;
      msg            : in out Unbounded_String;
      result_tasks   : in out tasks_set)
   is

      a_task_result           : periodic_task_ptr;
      my_task_iterator_result : tasks_iterator;
      temp_task_iterator      : tasks_iterator;
      a_processor             : generic_processor_ptr;
      my_processor_iterator   : processors_iterator;
      the_cores               : core_units_table;

      num_of_tasks                        : Integer := 0;
      task_utilization, total_utilization : Float   := 0.0;

      next_task : Boolean := False;
   begin
      -- validate the processor/task set
      validate_multiprocessor_tasks (src_processors, src_tasks);

      msg :=
        To_Unbounded_String (" (") &
        lb_see (Current_Language) &
        To_Unbounded_String ("[9], [10]) ");

      -- copy the input task set to the result one which processor/core name will be modified according to the placement algorithm
      duplicate (src_tasks, result_tasks);
      sort (result_tasks, increasing_period'access);

      -- reset the task iterator
      reset_iterator (result_tasks, my_task_iterator_result);
      temp_task_iterator := my_task_iterator_result;
      current_element
        (result_tasks,
         generic_task_ptr (a_task_result),
         my_task_iterator_result);

      -- reset the processor iterator
      reset_iterator (src_processors, my_processor_iterator);
      current_element (src_processors, a_processor, my_processor_iterator);

      -- Empty processor/core name
      --
      loop
         a_task_result.cpu_name  := To_Unbounded_String ("");
         a_task_result.core_name := To_Unbounded_String ("");

         exit when is_last_element (result_tasks, my_task_iterator_result);

         next_element (result_tasks, my_task_iterator_result);
         current_element
           (result_tasks,
            generic_task_ptr (a_task_result),
            my_task_iterator_result);
      end loop;

      -- re reset the task iterator
      reset_iterator (result_tasks, my_task_iterator_result);
      current_element
        (result_tasks,
         generic_task_ptr (a_task_result),
         my_task_iterator_result);

      loop -- tasks
         loop -- processor
            -- get the core(s) of the current processor
            the_cores := build_core_table (a_processor);

            for i in 0 .. the_cores.nb_entries - 1 loop
               -- Fetch information for condition-IP
               --
               -- reset the task iterator
               reset_iterator (result_tasks, my_task_iterator_result);
               current_element
                 (result_tasks,
                  generic_task_ptr (a_task_result),
                  my_task_iterator_result);

               num_of_tasks      := 0;
               total_utilization := 0.0;
               loop
                  if a_task_result.cpu_name = a_processor.name and
                    a_task_result.core_name = the_cores.entries (i).name
                  then
                     num_of_tasks      := num_of_tasks + 1;
                     total_utilization :=
                       total_utilization +
                       Float (a_task_result.capacity) /
                         Float (a_task_result.period);
                  end if;

                  exit when is_last_element
                      (result_tasks,
                       my_task_iterator_result);

                  -- next task
                  next_element (result_tasks, my_task_iterator_result);
                  current_element
                    (result_tasks,
                     generic_task_ptr (a_task_result),
                     my_task_iterator_result);
               end loop;

               my_task_iterator_result := temp_task_iterator;
               current_element
                 (result_tasks,
                  generic_task_ptr (a_task_result),
                  my_task_iterator_result);

               task_utilization :=
                 Float (a_task_result.capacity) / Float (a_task_result.period);
               if
                 (task_utilization <=
                  2.0 *
                      (1.0 /
                       (1.0 + total_utilization / Float (num_of_tasks))**
                         num_of_tasks) -
                    1.0)
               then
                  a_task_result.cpu_name  := a_processor.name;
                  a_task_result.core_name := the_cores.entries (i).name;

                  -- reset the processor iterator
                  reset_iterator (src_processors, my_processor_iterator);
                  current_element
                    (src_processors,
                     a_processor,
                     my_processor_iterator);

                  next_task := True;
                  exit; -- next task, exit the current core loop, must also exit the processor loop
               end if;
            end loop; -- cores

            if next_task = True then
               next_task := False;
               exit;
            else -- all the cores of the current processor have been scanned with no good result go to the next processor
               if is_last_element
                   (src_processors,
                    my_processor_iterator)
               then -- no more processor for the current task
                  duplicate (src_tasks, result_tasks);
                  raise no_such_processors;
               end if;

               next_element (src_processors, my_processor_iterator);
               current_element
                 (src_processors,
                  a_processor,
                  my_processor_iterator);
            end if;
         end loop; -- processors

         exit when is_last_element (result_tasks, my_task_iterator_result);

         next_element (result_tasks, my_task_iterator_result);
         temp_task_iterator := my_task_iterator_result;
      end loop; -- tasks

      sort (result_tasks, increasing_name'access);

   end partition_first_fit;

   procedure partition_best_fit
     (src_processors : in     processors_set;
      src_tasks      : in     tasks_set;
      msg            : in out Unbounded_String;
      result_tasks   : in out tasks_set)
   is

      a_task_result           : periodic_task_ptr;
      my_task_iterator_result : tasks_iterator;
      a_processor             : generic_processor_ptr;
      my_processor_iterator   : processors_iterator;
      temp_task_iterator      : tasks_iterator;
      best_cpu                : processors_iterator;
      best_core_name          : Unbounded_String := To_Unbounded_String ("");
      the_cores               : core_units_table;

      m                            : Integer := 1;
      best_fit_value               : Float   := 2.0;
      best_fit_tmp_value, tot_util : Float;
      first_task                   : Boolean := True;
      assignable                   : Boolean;

   begin
      -- validate the processor/task set
      validate_multiprocessor_tasks (src_processors, src_tasks);

      msg :=
        To_Unbounded_String (" (") &
        lb_see (Current_Language) &
        To_Unbounded_String ("[9], [10]) ");

      -- copy the input task set to the result one which processor/core name will be modified according to the placement algorithm
      duplicate (src_tasks, result_tasks);
      sort (result_tasks, increasing_period'access);

      -- reset the task iterator
      reset_iterator (result_tasks, my_task_iterator_result);
      current_element
        (result_tasks,
         generic_task_ptr (a_task_result),
         my_task_iterator_result);

      -- Zero processor locations
      --
      loop
         a_task_result.cpu_name  := To_Unbounded_String ("");
         a_task_result.core_name := To_Unbounded_String ("");

         exit when is_last_element (result_tasks, my_task_iterator_result);

         next_element (result_tasks, my_task_iterator_result);
         current_element
           (result_tasks,
            generic_task_ptr (a_task_result),
            my_task_iterator_result);
      end loop;

      -- re reset the task iterator
      reset_iterator (result_tasks, my_task_iterator_result);
      current_element
        (result_tasks,
         generic_task_ptr (a_task_result),
         my_task_iterator_result);

      loop -- tasks
         -- reset the processor iterator
         reset_iterator (src_processors, my_processor_iterator);
         current_element (src_processors, a_processor, my_processor_iterator);

         -- Loop scans best processor for task to be placed
         --
         loop -- processors
            -- get the core(s) of the current processor
            the_cores := build_core_table (a_processor);

            -- test for condition IP
            --
            if first_task then
               if Float (a_task_result.capacity) /
                 Float (a_task_result.period) <=
                 1.0
               then
                  reset_iterator (src_processors, best_cpu);
                  my_processor_iterator := best_cpu;
                  best_core_name        := the_cores.entries (0).name;
                  first_task            := False;
                  assignable            := True;
                  exit;
               else
                  assignable := False;
                  exit;
               end if;
            else
               for i in 0 .. the_cores.nb_entries - 1 loop
                  temp_task_iterator := my_task_iterator_result;

                  -- get CPU data
                  --
                  -- reset the task iterator
                  reset_iterator (result_tasks, my_task_iterator_result);
                  current_element
                    (result_tasks,
                     generic_task_ptr (a_task_result),
                     my_task_iterator_result);

                  m        := 1;
                  tot_util := 0.0;

                  loop -- tasks
                     if a_task_result.cpu_name = a_processor.name and
                       a_task_result.core_name = the_cores.entries (i).name
                     then
                        m        := m + 1;
                        tot_util :=
                          tot_util +
                          Float (a_task_result.capacity) /
                            Float (a_task_result.period);
                     end if;
                     exit when is_last_element
                         (result_tasks,
                          my_task_iterator_result);
                     next_element (result_tasks, my_task_iterator_result);
                     current_element
                       (result_tasks,
                        generic_task_ptr (a_task_result),
                        my_task_iterator_result);
                  end loop;
                  my_task_iterator_result := temp_task_iterator;
                  current_element
                    (result_tasks,
                     generic_task_ptr (a_task_result),
                     my_task_iterator_result);

                  if Float (a_task_result.capacity) /
                    Float (a_task_result.period) <=
                    2.0 * (1.0 / (1.0 + tot_util / Float ((m - 1)))**(m - 1)) -
                      1.0
                  then
                  -- Tricky Condition IP testing because mathematics function
                  -- doesn't seem to understand handle
                  -- zero number very well in following check (M := 0
                  -- happens when processor is empty)
                     --
                     if m > 1 then
                        if tot_util <=
                          Float (m - 1) *
                            (2.0**Float (1.0 / Float (m - 1)) - 1.0)
                        then
                           best_fit_tmp_value :=
                             2.0 *
                             (1.0 /
                              ((1.0 + tot_util / Float (m - 1))**(m - 1))) -
                             1.0;
                           if best_fit_tmp_value < best_fit_value then
                              best_fit_value := best_fit_tmp_value;
                              best_cpu       := my_processor_iterator;
                              best_core_name := the_cores.entries (i).name;
                              assignable     := True;
                           end if;
                        end if;
                     else
                        best_fit_tmp_value :=
                          2.0 *
                          (1.0 / (1.0 + tot_util / Float (m - 1)**(m - 1))) -
                          1.0;
                        if best_fit_tmp_value < best_fit_value then
                           best_fit_value := best_fit_tmp_value;
                           best_cpu       := my_processor_iterator;
                           best_core_name := the_cores.entries (i).name;
                           assignable     := True;
                        end if;
                     end if;
                     -- End of tricky testing
                     --
                  end if;
               end loop; -- cores
            end if;

            exit when is_last_element (src_processors, my_processor_iterator);
            next_element (src_processors, my_processor_iterator);
            current_element
              (src_processors,
               a_processor,
               my_processor_iterator);
         end loop; -- processors

         if assignable then
            -- save task to best CPU
            --
            current_element (src_processors, a_processor, best_cpu);
            a_task_result.cpu_name  := a_processor.name;
            a_task_result.core_name := best_core_name;
            assignable              := False;
            best_fit_value          := 2.0;
         else
            duplicate (src_tasks, result_tasks);
            raise no_such_processors;
         end if;

         exit when is_last_element (result_tasks, my_task_iterator_result);
         next_element (result_tasks, my_task_iterator_result);
         current_element
           (result_tasks,
            generic_task_ptr (a_task_result),
            my_task_iterator_result);
      end loop; -- tasks

      sort (result_tasks, increasing_name'access);
   end partition_best_fit;

   procedure validate_multiprocessor_tasks
     (src_processors : in processors_set;
      src_tasks      : in tasks_set)
   is

      a_processor           : generic_processor_ptr;
      my_processor_iterator : processors_iterator;
      the_cores             : core_units_table;

   begin
      -- check if tasks are periodic
      --
      -- reset the processor iterator
      reset_iterator (src_processors, my_processor_iterator);
      loop
         current_element (src_processors, a_processor, my_processor_iterator);
         periodic_control (src_tasks, a_processor.name);
         exit when True =
           is_last_element (src_processors, my_processor_iterator);
         next_element (src_processors, my_processor_iterator);
      end loop;

      -- check if processors/cores are rate-monotonic and non pre-emptive
      --
      -- reset the processor iterator
      reset_iterator (src_processors, my_processor_iterator);
      loop
         current_element (src_processors, a_processor, my_processor_iterator);

-- get all the cores of the processor (only one when the processor is monocore)
         the_cores := build_core_table (a_processor);
         for i in 0 .. the_cores.nb_entries - 1 loop
            if the_cores.entries (i).scheduling.scheduler_type /=
              rate_monotonic_protocol
            then
               raise invalid_scheduler_multiprocessors;
            end if;
            if the_cores.entries (i).scheduling.preemptive_type =
              not_preemptive
            then
               raise invalid_scheduler_multiprocessors;
            end if;
         end loop;

         exit when is_last_element (src_processors, my_processor_iterator);
         next_element (src_processors, my_processor_iterator);
      end loop;

   end validate_multiprocessor_tasks;

end partitioning_services;
