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
--    $Rev: 4714 $
--    $Date: 2023-12-18 00:07:26 +0100 (lun., 18 déc. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Text_IO; use Text_IO;

with xml_tag;  use xml_tag;
with Tasks;    use Tasks;
with task_set; use task_set;
use task_set.generic_task_set;
with Resources;    use Resources;
with resource_set; use resource_set;
use resource_set.generic_resource_set;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with translate;                use translate;
with unbounded_strings;        use unbounded_strings;
with Framework_Config;         use Framework_Config;
with Scheduler_Interface;      use Scheduler_Interface;
with scheduler;                use scheduler;
with scheduler_builder;        use scheduler_builder;
with scheduler.fixed_priority; use scheduler.fixed_priority;
with Scheduling_Analysis;      use Scheduling_Analysis;
with Scheduling_Analysis.extended.resource_analysis;
use Scheduling_Analysis.extended.resource_analysis;
use Scheduling_Analysis.Deadlock_Package;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
use Scheduling_Analysis.Priority_Inversion_List_Package;
use Scheduling_Analysis.Ceiling_Priority_Table_Package;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with priority_assignment.dm; use priority_assignment.dm;
with priority_assignment.rm; use priority_assignment.rm;
with priority_assignment.ceiling_priority;
use priority_assignment.ceiling_priority;
with feasibility_test.worst_case_blocking_time;
use feasibility_test.worst_case_blocking_time;
with framework;                 use framework;
with call_scheduling_framework; use call_scheduling_framework;
with double_util;               use double_util;
with doubles;                   use doubles;
with debug;                     use debug;

package body call_resource_framework is

   procedure compute_resource_ceiling_priority
     (sys         : in out System; result : in out Unbounded_String;
      a_processor : in     generic_processor_ptr; inject_priority : in Boolean;
      output      : in     Output_Format := String_Output)

   is

      a_resource           : generic_resource_ptr;
      has_raised_exception : Boolean := False;
      msg                  : Unbounded_String;
      ceiling_priorities   : ceiling_priority_table;

   begin

      put_debug ("Call Compute_Resource_Ceiling_Priority ");

      -- And now, compute ceiling priority
      --
      result :=
        result & lb_minus & lb_ceiling_priority (Current_Language) &
        To_Unbounded_String (" (") & lb_see (Current_Language) &
        To_Unbounded_String ("[3]) ") & lb_colon & unbounded_lf;

      msg := empty_string;

      compute_ceiling_priority
        (sys.tasks, sys.resources, a_processor.name, msg, ceiling_priorities);

      if msg /= empty_string then
         has_raised_exception := True;
         result               := result & msg;
      end if;

      -- Display all resource ceiling priority
      --

      for i in 0 .. ceiling_priorities.nb_entries - 1 loop
         result :=
           result & lb_tab4 & ceiling_priorities.entries (i).resource_name &
           To_Unbounded_String (" =>") &
           Integer'Image
             (Integer (ceiling_priorities.entries (i).ceiling_priority)) &
           unbounded_lf;
      end loop;

      result := result & unbounded_lf & unbounded_lf & unbounded_lf;

      -- Update ceiling priority
      --
      if inject_priority then

         if has_raised_exception then

            result :=
              result & unbounded_lf & lb_minus &
              lb_ceiling_priority_inject_failed (Current_Language) &
              unbounded_lf & unbounded_lf;

         else
            for i in 0 .. ceiling_priorities.nb_entries - 1 loop
               a_resource :=
                 search_resource
                   (sys.resources,
                    ceiling_priorities.entries (i).resource_name);
               a_resource.priority :=
                 ceiling_priorities.entries (i).ceiling_priority;
            end loop;

            result :=
              result & unbounded_lf & lb_minus &
              lb_ceiling_priority_inject_success (Current_Language) &
              unbounded_lf & unbounded_lf;
         end if;
      end if;

   end compute_resource_ceiling_priority;

   procedure compute_worst_case_blocking_time
     (sys                  : in out System; result : in out Unbounded_String;
      a_processor          : in     generic_processor_ptr;
      inject_blocking_time : in     Boolean;
      output               : in     Output_Format := String_Output)
   is

      a_task               : generic_task_ptr;
      has_raised_exception : Boolean := False;
      msg                  : Unbounded_String;
      blocking_time        : blocking_time_table;
      a_scheduler          : generic_scheduler_ptr;

   begin

      put_debug ("Call Compute_Worst_Case_Blocking_Time");

      -- And now, compute blocking time
      --
      result :=
        result & lb_minus & lb_worst_case_blocking_time (Current_Language) &
        To_Unbounded_String (" (") & lb_see (Current_Language) &
        To_Unbounded_String ("[3]) ") & lb_colon & unbounded_lf;

      msg := empty_string;

      a_scheduler := build_a_scheduler (a_processor);
      compute_blocking_time
        (a_scheduler, sys.tasks, sys.resources, a_processor.name, msg,
         blocking_time);
      free (a_scheduler);

      if msg /= empty_string then
         has_raised_exception := True;
         result               := result & msg;
      end if;

      -- Display all task blocking time
      --

      for i in
        0 ..
          blocking_time_range
            (get_number_of_task_from_processor (sys.tasks, a_processor.name) -
             1)
      loop
         if (blocking_time.entries (i).item /= null) then
            result :=
              result & lb_tab4 & blocking_time.entries (i).item.name &
              To_Unbounded_String (" =>") &
              Integer'Image (Integer (blocking_time.entries (i).data)) &
              unbounded_lf;
         end if;
      end loop;

      result := result & unbounded_lf & unbounded_lf & unbounded_lf;

      -- Update blocking time
      --
      if inject_blocking_time then

         if has_raised_exception then

            result :=
              result & unbounded_lf & lb_minus &
              lb_blocking_time_inject_failed (Current_Language) &
              unbounded_lf & unbounded_lf;

         else
            for i in
              0 ..
                blocking_time_range
                  (get_number_of_task_from_processor
                     (sys.tasks, a_processor.name) -
                   1)
            loop
               if (blocking_time.entries (i).item /= null) then

                  a_task :=
                    search_task
                      (sys.tasks, blocking_time.entries (i).item.name);
                  a_task.blocking_time :=
                    Natural (blocking_time.entries (i).data);
               end if;
            end loop;

            result :=
              result & unbounded_lf & lb_minus &
              lb_blocking_time_inject_success (Current_Language) &
              unbounded_lf & unbounded_lf;
         end if;
      end if;

   exception
      when invalid_scheduler =>
         result :=
           result & unbounded_lf & lb_minus &
           lb_compute_blocking_error2 (Current_Language) & unbounded_lf;

   end compute_worst_case_blocking_time;

   procedure compute_simulation_blocking_time
     (sys         : in out System; result : in out Unbounded_String;
      a_processor : in     generic_processor_ptr; worst_case : in Boolean;
      best_case   : in     Boolean; average_case : in Boolean;
      output      : in     Output_Format := String_Output)
   is

      a_task      : generic_task_ptr;
      my_iterator : tasks_iterator;
      min         : Natural := 0;
      max         : Natural := 0;
      average     : Double  := 0.0;

   begin

      put_debug ("Call Compute_Simulation_Blocking_Time");

      for j in 0 .. sched.nb_entries - 1 loop
         if sched.entries (j).item.name = a_processor.name then

            result :=
              result & lb_minus &
              lb_simulation_blocking_time (Current_Language) & lb_colon &
              unbounded_lf;

            reset_iterator (sys.tasks, my_iterator);

            loop
               current_element (sys.tasks, a_task, my_iterator);

               if (a_processor.name = a_task.cpu_name) then

                  blocking_time_from_simulation
                    (a_task, sys.resources, sched.entries (j).data.result, max,
                     min, average);

                  result :=
                    result & lb_tab4 & a_task.name &
                    To_Unbounded_String (" =>");
                  if worst_case then
                     result :=
                       result & max'Img & To_Unbounded_String ("/worst ");
                  end if;
                  if best_case then
                     result :=
                       result & min'Img & To_Unbounded_String ("/best ");
                  end if;
                  if average_case then
                     result :=
                       result & format (average) &
                       To_Unbounded_String ("/average ");
                  end if;
                  result := result & unbounded_lf;

               end if;

               exit when is_last_element (sys.tasks, my_iterator);

               next_element (sys.tasks, my_iterator);

            end loop;

         end if;
      end loop;

   end compute_simulation_blocking_time;

   procedure priority_inversion_detection
     (sys         : in out System; result : in out Unbounded_String;
      a_processor : in     generic_processor_ptr;
      output      : in     Output_Format := String_Output)
   is

      priority_inversion : priority_inversion_list;
      item               : priority_inversion_item_ptr;
      tmp_tasks          : tasks_set;
      my_scheduler       : generic_scheduler_ptr;

   begin

      put_debug ("Call Priority_Inversion_Detection");

      current_processor_name := a_processor.name;
      select_and_copy (sys.tasks, tmp_tasks, select_cpu'Access);

      -- Set priority according to the scheduler
      --
      my_scheduler := build_a_scheduler (a_processor);

      if (get_name (my_scheduler.all) = deadline_monotonic_protocol) then
         set_priority_according_to_dm (tmp_tasks);
      else
         if (get_name (my_scheduler.all) = rate_monotonic_protocol) then
            set_priority_according_to_rm (tmp_tasks);
         end if;
      end if;

      for j in 0 .. sched.nb_entries - 1 loop
         if sched.entries (j).item.name = a_processor.name then

            priority_inversion :=
              priority_inversion_from_simulation
                (tmp_tasks, sys.resources, a_processor.name,
                 sched.entries (j).data.result);

            if is_empty (priority_inversion) then
               result :=
                 result & lb_minus &
                 lb_no_priority_inversion_found (Current_Language) &
                 unbounded_lf;
            else
               result :=
                 result & lb_minus &
                 lb_simulation_priority_inversion (Current_Language) &
                 lb_colon & unbounded_lf;

               while not is_empty (priority_inversion) loop
                  item := get_head (priority_inversion);

                  result :=
                    result & To_Unbounded_String ("   ") & item.task_name &
                    lb_has_priority_inversion (Current_Language) &
                    item.resource_name & lb_from_the_time (Current_Language) &
                    To_Unbounded_String (item.start_time'Img) &
                    lb_to_the_time (Current_Language) &
                    To_Unbounded_String (item.end_time'Img) & lb_dot &
                    unbounded_lf;

                  delete (priority_inversion, item);

               end loop;
            end if;
         end if;
      end loop;

      free (tmp_tasks);
      free (my_scheduler);

      result := result & unbounded_lf & unbounded_lf;

   end priority_inversion_detection;

   procedure deadlock_detection
     (sys         : in out System; result : in out Unbounded_String;
      a_processor : in     generic_processor_ptr;
      output      : in     Output_Format := String_Output)
   is

      deadlock : deadlock_list;
      item     : deadlock_item_ptr;

   begin

      put_debug ("Call Deadlock_Detection");

      for j in 0 .. sched.nb_entries - 1 loop
         if sched.entries (j).item.name = a_processor.name then

            deadlock :=
              deadlock_from_simulation
                (sys.tasks, sys.resources, a_processor.name,
                 sched.entries (j).data.result);

            if is_empty (deadlock) then
               result :=
                 result & lb_minus & lb_no_deadlock_found (Current_Language) &
                 unbounded_lf;

            else
               result :=
                 result & lb_minus &
                 lb_simulation_deadlock (Current_Language) & lb_colon &
                 unbounded_lf;

               while not is_empty (deadlock) loop
                  item := get_head (deadlock);

                  result :=
                    result & To_Unbounded_String ("   ") & lb_minus &
                    lb_deadlock_at_time (Current_Language) &
                    To_Unbounded_String (item.time'Img) & lb_colon;
                  result := result & " " & item.task_name;
                  result :=
                    result & lb_wait_for (Current_Language) &
                    item.resource_name & lb_dot & unbounded_lf;

                  delete (deadlock, item);

               end loop;
            end if;
         end if;
      end loop;

   end deadlock_detection;

end call_resource_framework;
