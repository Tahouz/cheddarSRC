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
--    $Rev: 4720 $
--    $Date: 2023-12-19 15:31:20 +0100 (mar., 19 déc. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Exceptions;                    use Ada.Exceptions;
with Text_IO;                           use Text_IO;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

with Resources;                         use Resources;
use Resources.Resource_Accesses;
with time_unit_events;                  use time_unit_events;
use time_unit_events.time_unit_package;
with natural_util;                      use natural_util;
with double_util;                       use double_util;
with integer_util;                      use integer_util;
with Objects;                           use Objects;
with Objects.extended;                  use Objects.extended;
with initialize_framework;              use initialize_framework;
with translate;                         use translate;
with unbounded_strings;                 use unbounded_strings;
with scheduler;                         use scheduler;
with Scheduling_Analysis;               use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with priority_assignment.rm;            use priority_assignment.rm;
with priority_assignment.dm;            use priority_assignment.dm;
with systems;                           use systems;
with xml_tag;                           use xml_tag;
with translate;                         use translate;
with Doubles;                           use Doubles;


package body feasibility_test.processor_utilization is

   function processor_utilization_over_deadline
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String;
      core_unit_name : in Unbounded_String := empty_string) return Double
   is
      utilization : Double := 0.0;

      my_iterator : tasks_iterator;
      a_task      : generic_task_ptr;

   begin

      -- Check if tasks are periodic
      --
      periodic_control (my_tasks, processor_name);

      -- Check if deadline a greater than 0
      --
      deadline_control (my_tasks, processor_name);

      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if
           ((a_task.cpu_name = processor_name) and
            (core_unit_name = empty_string)) or
           ((a_task.cpu_name = processor_name) and
            (a_task.core_name = core_unit_name))
         then
            utilization :=
              utilization +
              (Double (a_task.capacity) / Double (a_task.deadline));
         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);

      end loop;

      return utilization;

   end processor_utilization_over_deadline;

   function processor_utilization_over_period
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String;
      core_unit_name : in Unbounded_String := empty_string) return Double
   is
      utilization : Double := 0.0;

      my_iterator : tasks_iterator;
      a_task      : generic_task_ptr;

   begin

      -- Check if tasks are periodics
      --
      periodic_control (my_tasks, processor_name);

      reset_iterator (my_tasks, my_iterator);

      loop
         current_element (my_tasks, a_task, my_iterator);

         if
           ((a_task.cpu_name = processor_name) and
            (core_unit_name = empty_string)) or
           ((a_task.cpu_name = processor_name) and
            (a_task.core_name = core_unit_name))
         then
            if a_task.task_type /= aperiodic_type then
               utilization :=
                 utilization +
                 (Double (a_task.capacity) /
                  Double (periodic_task_ptr (a_task).period));
            end if;

         end if;

         exit when is_last_element (my_tasks, my_iterator);

         next_element (my_tasks, my_iterator);

      end loop;

      return utilization;

   end processor_utilization_over_period;

   procedure bound_on_processor_utilization
     (my_scheduler   : in     generic_scheduler_ptr;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Double;
      msg            : in out Unbounded_String)
   is
   begin

      case my_scheduler.parameters.scheduler_type is
         when earliest_deadline_first_protocol              |
           least_laxity_first_protocol                      |
           d_over_protocol                                  |
           maximum_urgency_first_based_on_laxity_protocol   |
           maximum_urgency_first_based_on_deadline_protocol =>
            bound_on_processor_utilization
              (dynamic_priority_scheduler (my_scheduler.all),
               my_tasks,
               processor_name,
               result,
               msg);
         when rate_monotonic_protocol                 |
           deadline_monotonic_protocol                |
           posix_1003_highest_priority_first_protocol =>
            bound_on_processor_utilization
              (fixed_priority_scheduler (my_scheduler.all),
               my_tasks,
               processor_name,
               result,
               msg);
         when others =>
            raise invalid_scheduler;
      end case;
   end bound_on_processor_utilization;

   procedure bound_on_processor_utilization
     (my_scheduler   : in     dynamic_priority_scheduler;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Double;
      msg            : in out Unbounded_String)
   is
   begin
      result := 1.0;
      msg    :=
        To_Unbounded_String (" (") &
        lb_see (Current_Language) &
        To_Unbounded_String ("[1], page 8, ") &
        lb_theorem (Current_Language) &
        To_Unbounded_String ("2). ");

   end bound_on_processor_utilization;

   procedure bound_on_processor_utilization
     (my_scheduler   : in     fixed_priority_scheduler;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Double;
      msg            : in out Unbounded_String)
   is

      nb : constant Double :=
        Double (get_number_of_task_from_processor (my_tasks, processor_name));
   begin

      if not is_harmonic (my_tasks, processor_name) then
         msg :=
           To_Unbounded_String (" (") &
           lb_see (Current_Language) &
           To_Unbounded_String ("[1], page 16, ") &
           lb_theorem (Current_Language) &
           To_Unbounded_String ("8). ");
         result := nb * (Pow (2.0, (1.0 / nb)) - 1.0);
      else
         msg :=
           To_Unbounded_String (" (") &
           lb_see (Current_Language) &
           To_Unbounded_String ("[19], page 13).");
         result := 1.0;
      end if;

   end bound_on_processor_utilization;

   procedure utilization_factor_feasibility_test
     (my_scheduler   : in     generic_scheduler_ptr;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Unbounded_String;
      output         : in     output_format := string_output)
   is
   begin
      case my_scheduler.parameters.scheduler_type is
         when rate_monotonic_protocol =>
            utilization_factor_feasibility_test
              (rm_scheduler (my_scheduler.all),
               my_tasks,
               processor_name,
               result,
               output);
         when deadline_monotonic_protocol =>
            utilization_factor_feasibility_test
              (dm_scheduler (my_scheduler.all),
               my_tasks,
               processor_name,
               result,
               output);
         when maximum_urgency_first_based_on_laxity_protocol |
           maximum_urgency_first_based_on_deadline_protocol  =>
            utilization_factor_feasibility_test
              (muf_scheduler (my_scheduler.all),
               my_tasks,
               processor_name,
               result,
               output);
         when least_laxity_first_protocol =>
            utilization_factor_feasibility_test
              (llf_scheduler (my_scheduler.all),
               my_tasks,
               processor_name,
               result,
               output);
         when earliest_deadline_first_protocol =>
            utilization_factor_feasibility_test
              (edf_scheduler (my_scheduler.all),
               my_tasks,
               processor_name,
               result,
               output);
         when d_over_protocol =>
            utilization_factor_feasibility_test
              (d_over_scheduler (my_scheduler.all),
               my_tasks,
               processor_name,
               result,
               output);
         when others =>
            if output /= xml_output then
               result :=
                 result &
                 lb_minus &
                 lb_compute_scheduling_error_19 (Current_Language) &
                 unbounded_lf;
            else
               result :=
                 result &
                 to_unbounded_string (" result=""false"" explanation=""");
               result :=
                 result & lb_compute_scheduling_error_19 (Current_Language);
               result :=
                 result &
                 to_unbounded_string (""" biblio=""") &
                 to_unbounded_string ("""");
            end if;
      end case;
   end utilization_factor_feasibility_test;

   procedure utilization_factor_feasibility_test
     (my_scheduler   : in     d_over_scheduler;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Unbounded_String;
      output         : in     output_format := string_output)
   is

      tmp               : tasks_set;
      bound             : Double           := 0.0;
      utildi            : Double           := 0.0;
      msg               : Unbounded_String := empty_string;
      verif             : Boolean          := True;
      a_task            : generic_task_ptr;
      my_task_iterator  : tasks_iterator;
      a_task2           : generic_task_ptr;
      my_task_iterator2 : tasks_iterator;
      calcul            : Double           := 0.0;
      l_debut           : Natural;
      l_dernier         : Natural;
      ech_sur_req       : Boolean          := True;
      pbconstraints     : Boolean          := False;
      msg2              : Unbounded_String := empty_string;
      msg3              : Unbounded_String := empty_string;

   begin

      start_time_control (my_tasks, processor_name);
      offset_control (my_tasks, processor_name);

      case get_preemptive (my_scheduler) is

         when preemptive =>
            bound_on_processor_utilization
              (dynamic_priority_scheduler (my_scheduler),
               my_tasks,
               processor_name,
               bound,
               msg);

            utildi :=
              processor_utilization_over_deadline (my_tasks, processor_name);

            if output /= xml_output then
               result := result & lb_minus & lb_utilization_bound1 (Current_Language);
               result := result & lb_d_over (Current_Language);
            end if;

            if utildi <= bound then
               if output = xml_output then
                  result :=
                    result &
                    to_unbounded_string (" result=""true"" explanation=""");
               end if;

               result := result & lb_sched_explanation1 (Current_Language);
               result :=
                 result & format (utildi);
               result := result & lb_sched_explanation12 (Current_Language);
               result :=
                 result & format (bound);
            else
               if output = xml_output then
                  result :=
                    result &
                    to_unbounded_string (" result=""false"" explanation=""");
               end if;

               result := result & lb_sched_explanation2 (Current_Language);
               result :=
                 result & format (utildi);
               result := result & lb_sched_explanation22 (Current_Language);
               result :=
                 result & format (bound);
            end if;

            if output /= xml_output then
               result := result & msg & unbounded_lf & unbounded_lf;
            else
               result :=
                 result &
                 to_unbounded_string (""" biblio=""") &
                 msg &
                 to_unbounded_string ("""");
            end if;

         when not_preemptive =>

            current_processor_name := processor_name;
            select_and_copy (my_tasks, tmp, select_cpu'access);

            msg2 := empty_string;

            --Check if the system is in stricts constraints
            --The test works only on stricts constraints !
            --
            reset_iterator (tmp, my_task_iterator);
            loop
               current_element (tmp, a_task, my_task_iterator);
               if (a_task.cpu_name = processor_name) then
                  if
                    (periodic_task_ptr (a_task).period /= a_task.deadline)
                  then
                     ech_sur_req := False;
                  end if;
               end if;
               exit when is_last_element (tmp, my_task_iterator);
               next_element (tmp, my_task_iterator);
            end loop;

            sort (tmp, increasing_deadline'access);
            reset_iterator (tmp, my_task_iterator);
            current_element (tmp, a_task, my_task_iterator);
            l_debut := periodic_task_ptr (a_task).period + 1;
            verif   := True;

            -- Main loop of all tasks
            --
            if ech_sur_req then

               if output /= xml_output then
                  result :=
                    result &
                    lb_minus &
                    lb_utilization_bound11 (Current_Language) &
                    lb_d_over (Current_Language);
               end if;

               loop
                  msg3 := empty_string;
                  if (a_task.cpu_name = processor_name) then
                     l_dernier := periodic_task_ptr (a_task).period - 1;
                     for l_courant in l_debut .. l_dernier loop
                        reset_iterator (tmp, my_task_iterator2);

                        -- Second loop until the current task
                        --
                        calcul := 0.0;
                        loop
                           current_element (tmp, a_task2, my_task_iterator2);
                           exit when a_task.name = a_task2.name;
                           calcul :=
                             calcul +
                             Double
                               ((Integer
                                   ((l_courant - 1) /
                                    periodic_task_ptr (a_task2).period)) *
                                a_task2.capacity);
                           next_element (tmp, my_task_iterator2);
                        end loop;

                        -- Checking
                        --
                        calcul := calcul + Double (a_task.capacity);
                        if calcul > Double (l_courant) then
                           verif := False;
                           msg3  := a_task.name & " ";
                        end if;
                     end loop;
                  end if;
                  msg2 := msg2 & msg3;
                  exit when is_last_element (tmp, my_task_iterator);
                  next_element (tmp, my_task_iterator);
                  current_element (tmp, a_task, my_task_iterator);
               end loop;
            else
               if output = xml_output then
                  result :=
                    result &
                    to_unbounded_string (" result=""false"" explanation=""");
                  result :=
                    result & lb_pb_strict_constraints (Current_Language);
                  result :=
                    result &
                    to_unbounded_string (""" biblio=""") &
                    to_unbounded_string ("""");
               else
                  result :=
                    result &
                    lb_minus &
                    lb_pb_strict_constraints (Current_Language) &
                    unbounded_lf;
               end if;

               pbconstraints := True;
            end if;

            -- Checks the result
            --
            if pbconstraints = False then
               if verif then
                  if output = xml_output then
                     result :=
                       result &
                       to_unbounded_string (" result=""true"" explanation=""");
                  end if;

                  result := result & lb_sched_explanation5 (Current_Language);
                  result := result & lb_sched_explanation52 (Current_Language);

                  if output = xml_output then
                     result :=
                       result &
                       to_unbounded_string (""" biblio=""") &
                       to_unbounded_string ("[8]") &
                       to_unbounded_string ("""");
                  else
                     result :=
                       result &
                       To_Unbounded_String (" (") &
                       lb_see (Current_Language) &
                       "[8].)" &
                       unbounded_lf;
                  end if;
               else
                  if output = xml_output then
                     result :=
                       result &
                       to_unbounded_string
                         (" result=""false"" explanation=""");
                  end if;

                  result := result & lb_sched_explanation6 (Current_Language);

                  if output = xml_output then
                     result :=
                       result &
                       lb_sched_explanation62 (Current_Language) &
                       lb_sched_explanation7 (Current_Language) &
                       msg2;

                     result :=
                       result &
                       to_unbounded_string (""" biblio=""") &
                       to_unbounded_string ("[8]") &
                       to_unbounded_string ("""");
                  else
                     result :=
                       result &
                       lb_sched_explanation62 (Current_Language) &
                       To_Unbounded_String (" (") &
                       lb_see (Current_Language) &
                       "[8])." &
                       unbounded_lf &
                       lb_sched_explanation7 (Current_Language) &
                       msg2 &
                       unbounded_lf;
                  end if;
               end if;
            end if;

      end case;

   end utilization_factor_feasibility_test;

   procedure utilization_factor_feasibility_test
     (my_scheduler   : in     edf_scheduler;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Unbounded_String;
      output         : in     output_format := string_output)
   is

      tmp               : tasks_set;
      bound             : Double           := 0.0;
      utildi            : Double           := 0.0;
      msg               : Unbounded_String := empty_string;
      verif             : Boolean          := True;
      a_task            : generic_task_ptr;
      my_task_iterator  : tasks_iterator;
      a_task2           : generic_task_ptr;
      my_task_iterator2 : tasks_iterator;
      calcul            : Double           := 0.0;
      l_debut           : Natural;
      l_dernier         : Natural;
      ech_sur_req       : Boolean          := True;
      pbconstraints     : Boolean          := False;
      msg2              : Unbounded_String := empty_string;
      msg3              : Unbounded_String := empty_string;

   begin

      start_time_control (my_tasks, processor_name);
      offset_control (my_tasks, processor_name);

      case get_preemptive (my_scheduler) is

         when preemptive =>
            bound_on_processor_utilization
              (dynamic_priority_scheduler (my_scheduler),
               my_tasks,
               processor_name,
               bound,
               msg);

            utildi :=
              processor_utilization_over_deadline (my_tasks, processor_name);

            if output /= xml_output then
               result := result & lb_minus & lb_utilization_bound1 (Current_Language);
               result := result & lb_edf (Current_Language);
            end if;

            if utildi <= bound then
               if output = xml_output then
                  result :=
                    result &
                    to_unbounded_string (" result=""true"" explanation=""");
               end if;

               result := result & lb_sched_explanation1 (Current_Language);
               result :=
                 result & format (utildi);
               result := result & lb_sched_explanation12 (Current_Language);
               result :=
                 result & format (bound);
            else
               if output = xml_output then
                  result :=
                    result &
                    to_unbounded_string (" result=""false"" explanation=""");
               end if;

               result := result & lb_sched_explanation2 (Current_Language);
               result :=
                 result & format (utildi);
               result := result & lb_sched_explanation22 (Current_Language);
               result :=
                 result & format (bound);
            end if;

            if output /= xml_output then
               result := result & msg & unbounded_lf & unbounded_lf;
            else
               result :=
                 result &
                 to_unbounded_string (""" biblio=""") &
                 msg &
                 to_unbounded_string ("""");
            end if;

         when not_preemptive =>

            current_processor_name := processor_name;
            select_and_copy (my_tasks, tmp, select_cpu'access);

            periodic_control (tmp, processor_name);

            msg2 := empty_string;

            --Check if the system is in stricts constraints
            --The test works only on stricts constraints !
            --
            reset_iterator (tmp, my_task_iterator);
            loop
               current_element (tmp, a_task, my_task_iterator);
               if (a_task.cpu_name = processor_name) then
                  if
                    (periodic_task_ptr (a_task).period /= a_task.deadline)
                  then
                     ech_sur_req := False;
                  end if;
               end if;
               exit when is_last_element (tmp, my_task_iterator);
               next_element (tmp, my_task_iterator);
            end loop;

            sort (tmp, increasing_deadline'access);
            reset_iterator (tmp, my_task_iterator);
            current_element (tmp, a_task, my_task_iterator);
            l_debut := periodic_task_ptr (a_task).period + 1;
            verif   := True;

            -- Main loop of all tasks
            --
            if ech_sur_req then

               if output /= xml_output then
                  result :=
                    result &
                    lb_minus &
                    lb_utilization_bound11 (Current_Language) &
                    lb_edf (Current_Language);
               end if;

               loop
                  msg3 := empty_string;
                  if (a_task.cpu_name = processor_name) then
                     l_dernier := periodic_task_ptr (a_task).period - 1;
                     for l_courant in l_debut .. l_dernier loop
                        reset_iterator (tmp, my_task_iterator2);

                        -- Second loop until the current task
                        --
                        calcul := 0.0;
                        loop
                           current_element (tmp, a_task2, my_task_iterator2);
                           exit when a_task.name = a_task2.name;
                           calcul :=
                             calcul +
                             Double
                               ((Integer
                                   ((l_courant - 1) /
                                    periodic_task_ptr (a_task2).period)) *
                                a_task2.capacity);
                           next_element (tmp, my_task_iterator2);
                        end loop;

                        -- Checking
                        --
                        calcul := calcul + Double (a_task.capacity);
                        if calcul > Double (l_courant) then
                           verif := False;
                           msg3  := a_task.name & " ";
                        end if;
                     end loop;
                  end if;
                  msg2 := msg2 & msg3;
                  exit when is_last_element (tmp, my_task_iterator);
                  next_element (tmp, my_task_iterator);
                  current_element (tmp, a_task, my_task_iterator);
               end loop;
            else
               if output = xml_output then
                  result :=
                    result &
                    to_unbounded_string (" result=""false"" explanation=""");
                  result :=
                    result & lb_pb_strict_constraints (Current_Language);
                  result :=
                    result &
                    to_unbounded_string (""" biblio=""") &
                    to_unbounded_string ("""");
               else
                  result :=
                    result &
                    lb_minus &
                    lb_pb_strict_constraints (Current_Language) &
                    unbounded_lf;
               end if;

               pbconstraints := True;
            end if;

            -- Checks the result
            --
            if pbconstraints = False then
               if verif then
                  if output = xml_output then
                     result :=
                       result &
                       to_unbounded_string (" result=""true"" explanation=""");
                  end if;

                  result := result & lb_sched_explanation5 (Current_Language);
                  result := result & lb_sched_explanation52 (Current_Language);

                  if output = xml_output then
                     result :=
                       result &
                       to_unbounded_string (""" biblio=""") &
                       to_unbounded_string ("[8]") &
                       to_unbounded_string ("""");
                  else
                     result :=
                       result &
                       To_Unbounded_String (" (") &
                       lb_see (Current_Language) &
                       "[8].)" &
                       unbounded_lf;
                  end if;
               else
                  if output = xml_output then
                     result :=
                       result &
                       to_unbounded_string
                         (" result=""false"" explanation=""");
                  end if;

                  result := result & lb_sched_explanation6 (Current_Language);

                  if output = xml_output then
                     result :=
                       result &
                       lb_sched_explanation62 (Current_Language) &
                       lb_sched_explanation7 (Current_Language) &
                       msg2;

                     result :=
                       result &
                       to_unbounded_string (""" biblio=""") &
                       to_unbounded_string ("[8]") &
                       to_unbounded_string ("""");
                  else
                     result :=
                       result &
                       lb_sched_explanation62 (Current_Language) &
                       To_Unbounded_String (" (") &
                       lb_see (Current_Language) &
                       "[8])." &
                       unbounded_lf &
                       lb_sched_explanation7 (Current_Language) &
                       msg2 &
                       unbounded_lf;
                  end if;

               end if;
            end if;

      end case;

   end utilization_factor_feasibility_test;

   procedure utilization_factor_feasibility_test
     (my_scheduler   : in     llf_scheduler;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Unbounded_String;
      output         : in     output_format := string_output)
   is

      bound  : Double           := 0.0;
      utildi : Double           := 0.0;
      msg    : Unbounded_String := empty_string;

   begin

      start_time_control (my_tasks, processor_name);
      offset_control (my_tasks, processor_name);

      case get_preemptive (my_scheduler) is

         when preemptive =>

            utildi :=
              processor_utilization_over_deadline (my_tasks, processor_name);

            bound_on_processor_utilization
              (dynamic_priority_scheduler (my_scheduler),
               my_tasks,
               processor_name,
               bound,
               msg);

            if output /= xml_output then
               result := result & lb_minus & lb_utilization_bound1 (Current_Language);
               result := result & lb_llf (Current_Language);
            end if;

            if utildi <= bound then
               if output = xml_output then
                  result :=
                    result &
                    to_unbounded_string (" result=""true"" explanation=""");
               end if;

               result := result & lb_sched_explanation1 (Current_Language);
               result :=
                 result & format (utildi);
               result := result & lb_sched_explanation12 (Current_Language);
               result :=
                 result & format (bound);
            else
               if output = xml_output then
                  result :=
                    result &
                    to_unbounded_string (" result=""false"" explanation=""");
               end if;

               result := result & lb_sched_explanation2 (Current_Language);
               result :=
                 result & format (utildi);
               result := result & lb_sched_explanation22 (Current_Language);
               result :=
                 result & format (bound);
            end if;

            if output /= xml_output then
               result :=
                 result &
                 To_Unbounded_String (" (") &
                 lb_see (Current_Language) &
                 To_Unbounded_String ("[7]).") &
                 unbounded_lf;
            else
			   -- TODO JLE : why the msg variable which contains a different biblio reference is not used???
               result := result & to_unbounded_string (""" biblio=""[7]""");
            end if;

         when not_preemptive =>

            if output = xml_output then
               result :=
                 result &
                 to_unbounded_string (" result=""false"" explanation=""");
               result := result & lb_pb_sched_unknown (Current_Language);
               result :=
                 result &
                 to_unbounded_string (""" biblio=""") &
                 to_unbounded_string ("""");
            else
               result :=
                 result & lb_minus & lb_pb_sched_unknown (Current_Language) & unbounded_lf;
            end if;
      end case;

   end utilization_factor_feasibility_test;

   procedure utilization_factor_feasibility_test
     (my_scheduler   : in     muf_scheduler;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Unbounded_String;
      output         : in     output_format := string_output)
   is

      tmp               : tasks_set;
      bound             : Double           := 0.0;
      utildi            : Double           := 0.0;
      msg               : Unbounded_String := empty_string;
      verif             : Boolean          := True;
      a_task            : generic_task_ptr;
      my_task_iterator  : tasks_iterator;
      a_task2           : generic_task_ptr;
      my_task_iterator2 : tasks_iterator;
      calcul            : Double           := 0.0;
      l_debut           : Natural;
      l_dernier         : Natural;
      ech_sur_req       : Boolean          := True;
      pbconstraints     : Boolean          := False;
      msg2              : Unbounded_String := empty_string;
      msg3              : Unbounded_String := empty_string;

   begin

      start_time_control (my_tasks, processor_name);
      offset_control (my_tasks, processor_name);

      case get_preemptive (my_scheduler) is

         when preemptive =>
            bound_on_processor_utilization
              (dynamic_priority_scheduler (my_scheduler),
               my_tasks,
               processor_name,
               bound,
               msg);

            utildi :=
              processor_utilization_over_deadline (my_tasks, processor_name);

            if output /= xml_output then
               result := result & lb_minus & lb_utilization_bound1 (Current_Language);
               result := result & lb_muf (Current_Language);
            end if;

            if utildi <= bound then
               if output = xml_output then
                  result :=
                    result &
                    to_unbounded_string (" result=""true"" explanation=""");
               end if;

               result := result & lb_sched_explanation1 (Current_Language);
               result :=
                 result & format (utildi);
               result := result & lb_sched_explanation12 (Current_Language);
               result :=
                 result & format (bound);
            else
               if output = xml_output then
                  result :=
                    result &
                    to_unbounded_string (" result=""false"" explanation=""");
               end if;

               result := result & lb_sched_explanation2 (Current_Language);
               result :=
                 result & format (utildi);
               result := result & lb_sched_explanation22 (Current_Language);
               result :=
                 result & format (bound);
            end if;

            if output /= xml_output then
               result := result & msg & unbounded_lf & unbounded_lf;
            else
               result :=
                 result &
                 to_unbounded_string (""" biblio=""") &
                 msg &
                 to_unbounded_string ("""");
            end if;
         when not_preemptive =>

            current_processor_name := processor_name;
            select_and_copy (my_tasks, tmp, select_cpu'access);

            msg2 := empty_string;

            --Check if the system is in stricts constraints
            --The test works only on stricts constraints !
            --
            reset_iterator (tmp, my_task_iterator);
            loop
               current_element (tmp, a_task, my_task_iterator);
               if (a_task.cpu_name = processor_name) then
                  if
                    (periodic_task_ptr (a_task).period /= a_task.deadline)
                  then
                     ech_sur_req := False;
                  end if;
               end if;
               exit when is_last_element (tmp, my_task_iterator);
               next_element (tmp, my_task_iterator);
            end loop;

            sort (tmp, increasing_deadline'access);
            reset_iterator (tmp, my_task_iterator);
            current_element (tmp, a_task, my_task_iterator);
            l_debut := periodic_task_ptr (a_task).period + 1;
            verif   := True;

            -- Main loop of all tasks
            --
            if ech_sur_req then

               if output /= xml_output then
                  result :=
                    result &
                    lb_minus &
                    lb_utilization_bound11 (Current_Language) &
                    lb_muf (Current_Language);
               end if;

               loop
                  msg3 := empty_string;
                  if (a_task.cpu_name = processor_name) then
                     l_dernier := periodic_task_ptr (a_task).period - 1;
                     for l_courant in l_debut .. l_dernier loop
                        reset_iterator (tmp, my_task_iterator2);

                        -- Second loop until the current task
                        --
                        calcul := 0.0;
                        loop
                           current_element (tmp, a_task2, my_task_iterator2);
                           exit when a_task.name = a_task2.name;
                           calcul :=
                             calcul +
                             Double
                               ((Integer
                                   ((l_courant - 1) /
                                    periodic_task_ptr (a_task2).period)) *
                                a_task2.capacity);
                           next_element (tmp, my_task_iterator2);
                        end loop;

                        -- Checking
                        --
                        calcul := calcul + Double (a_task.capacity);
                        if calcul > Double (l_courant) then
                           verif := False;
                           msg3  := a_task.name & " ";
                        end if;
                     end loop;
                  end if;
                  msg2 := msg2 & msg3;
                  exit when is_last_element (tmp, my_task_iterator);
                  next_element (tmp, my_task_iterator);
                  current_element (tmp, a_task, my_task_iterator);
               end loop;
            else
               if output = xml_output then
                  result :=
                    result &
                    to_unbounded_string (" result=""false"" explanation=""");
                  result :=
                    result & lb_pb_strict_constraints (Current_Language);
                  result :=
                    result &
                    to_unbounded_string (""" biblio=""") &
                    to_unbounded_string ("""");
               else
                  result :=
                    result &
                    lb_minus &
                    lb_pb_strict_constraints (Current_Language) &
                    unbounded_lf;
               end if;
               pbconstraints := True;
            end if;

            -- Checks the result
            --
            if pbconstraints = False then
               if verif then
                  if output = xml_output then
                     result :=
                       result &
                       to_unbounded_string (" result=""true"" explanation=""");
                  end if;

                  result := result & lb_sched_explanation5 (Current_Language);
                  result := result & lb_sched_explanation52 (Current_Language);
                  if output = xml_output then
                     result :=
                       result &
                       to_unbounded_string (""" biblio=""") &
                       to_unbounded_string ("[8]") &
                       to_unbounded_string ("""");
                  else
                     result :=
                       result &
                       To_Unbounded_String (" (") &
                       lb_see (Current_Language) &
                       "[8].)" &
                       unbounded_lf;
                  end if;
               else
                  if output = xml_output then
                     result :=
                       result &
                       to_unbounded_string
                         (" result=""false"" explanation=""");
                  end if;

                  result := result & lb_sched_explanation6 (Current_Language);

                  if output = xml_output then
                     result :=
                       result &
                       lb_sched_explanation62 (Current_Language) &
                       lb_sched_explanation7 (Current_Language) &
                       msg2;
                     result :=
                       result &
                       to_unbounded_string (""" biblio=""") &
                       to_unbounded_string ("[8]") &
                       to_unbounded_string ("""");
                  else
                     result :=
                       result &
                       lb_sched_explanation62 (Current_Language) &
                       To_Unbounded_String (" (") &
                       lb_see (Current_Language) &
                       "[8])." &
                       unbounded_lf &
                       lb_sched_explanation7 (Current_Language) &
                       msg2 &
                       unbounded_lf;
                  end if;
               end if;
            end if;

      end case;

   end utilization_factor_feasibility_test;

   procedure utilization_factor_feasibility_test
     (my_scheduler   : in     dm_scheduler;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Unbounded_String;
      output         : in     output_format := string_output)
   is

      bound  : Double           := 0.0;
      utildi : Double           := 0.0;
      msg    : Unbounded_String := empty_string;

   begin

      start_time_control (my_tasks, processor_name);
      offset_control (my_tasks, processor_name);

      utildi := processor_utilization_over_deadline (my_tasks, processor_name);
      bound_on_processor_utilization
        (fixed_priority_scheduler (my_scheduler),
         my_tasks,
         processor_name,
         bound,
         msg);

      case get_preemptive (my_scheduler) is

         when preemptive =>

            if output /= xml_output then
               result := result & lb_minus & lb_utilization_bound1 (Current_Language);
               result := result & lb_dm (Current_Language);
            end if;

            if utildi <= bound then
               if output = xml_output then
                  result :=
                    result &
                    to_unbounded_string (" result=""true"" explanation=""");
               end if;
               
               result := result & lb_sched_explanation1 (Current_Language);
               result :=
                 result & format (utildi);
               result := result & lb_sched_explanation12 (Current_Language);
               result :=
                 result & format (bound);
            else
               if output = xml_output then
                  result :=
                    result &
                    to_unbounded_string (" result=""false"" explanation=""");
               end if;

               result := result & lb_sched_explanation2 (Current_Language);
               result :=
                 result & format (utildi);
               result := result & lb_sched_explanation22 (Current_Language);
               result :=
                 result & format (bound);
            end if;
            if output /= xml_output then
               result :=
                 result &
                 To_Unbounded_String (" (") &
                 lb_see (Current_Language) &
                 To_Unbounded_String ("[7]).") &
                 unbounded_lf;
            else
               -- TODO JLE : why the msg variable which contains a different biblio reference is not used???
               result := result & to_unbounded_string (""" biblio=""[7]""");
            end if;

         when not_preemptive =>

            if output = xml_output then
               result :=
                 result &
                 to_unbounded_string (" result=""false"" explanation=""");
               result := result & lb_pb_sched_unknown (Current_Language);
               result :=
                 result &
                 to_unbounded_string (""" biblio=""") &
                 to_unbounded_string ("""");
            else
               result :=
                 result & lb_minus & lb_pb_sched_unknown (Current_Language) & unbounded_lf;
            end if;
      end case;

   end utilization_factor_feasibility_test;

   procedure utilization_factor_feasibility_test
     (my_scheduler   : in     rm_scheduler;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Unbounded_String;
      output         : in     output_format := string_output)
   is

      tmp               : tasks_set;
      bound             : Double           := 0.0;
      util              : Double           := 0.0;
      msg, msg2         : Unbounded_String := empty_string;
      verification      : Boolean          := True;
      a_task            : generic_task_ptr;
      my_task_iterator  : tasks_iterator;
      a_task2           : generic_task_ptr;
      my_task_iterator2 : tasks_iterator;
      compute           : Double           := 0.0;
      max_bi            : Double           := 0.0;
      i_bound           : Double           := 0.0;
      task_number       : Natural          := 0;

   begin

      start_time_control (my_tasks, processor_name);
      offset_control (my_tasks, processor_name);

      util := processor_utilization_over_period (my_tasks, processor_name);

      bound_on_processor_utilization
        (fixed_priority_scheduler (my_scheduler),
         my_tasks,
         processor_name,
         bound,
         msg);

      case get_preemptive (my_scheduler) is

         when preemptive =>

            if output /= xml_output then
               result :=
                 result &
                 lb_minus &
                 lb_utilization_bound1 (Current_Language) &
                 lb_rm (Current_Language);
            end if;

            if util <= bound then
               if output = xml_output then
                  result :=
                    result &
                    to_unbounded_string (" result=""true"" explanation=""");
               end if;

               result := result & lb_sched_explanation1 (Current_Language);
               result :=
                 result & format (util);
               result := result & lb_sched_explanation12 (Current_Language);
               result :=
                 result & format (bound);
            else
               if output = xml_output then
                  result :=
                    result &
                    to_unbounded_string (" result=""false"" explanation=""");
               end if;
               result := result & lb_sched_explanation3 (Current_Language);
               result :=
                 result & format (util);
               result := result & lb_sched_explanation22 (Current_Language);
               result :=
                 result & format (bound);
            end if;

            if output /= xml_output then
               result := result & msg & unbounded_lf & unbounded_lf;
            else
               result :=
                 result &
                 to_unbounded_string (""" biblio=""") &
                 msg &
                 to_unbounded_string ("""");
            end if;

         when not_preemptive =>

            if output /= xml_output then
               result :=
                 result &
                 lb_minus &
                 lb_utilization_bound11 (Current_Language) &
                 lb_rm (Current_Language);
            end if;

            current_processor_name := processor_name;
            select_and_copy (my_tasks, tmp, select_cpu'access);

            sort (tmp, increasing_period'access);

            msg2 := empty_string;

            -- Main loop of all tasks
            --
            verification := True;
            reset_iterator (tmp, my_task_iterator);
            loop
               current_element (tmp, a_task, my_task_iterator);
               if (a_task.cpu_name = processor_name) then
                  compute := 0.0;

                  -- Loop until the current task
                  --
                  reset_iterator (tmp, my_task_iterator2);
                  task_number := 0;
                  loop
                     current_element (tmp, a_task2, my_task_iterator2);
                     if (a_task2.cpu_name = processor_name) then
                        task_number := task_number + 1;
                        compute     :=
                          compute +
                          Double (a_task2.capacity) /
                            Double (periodic_task_ptr (a_task2).period);
                     end if;
                     exit when a_task.name = a_task2.name;
                     next_element (tmp, my_task_iterator2);
                  end loop;

                  -- Looking for the max Bi
                  --
                  max_bi := 0.0;
                  loop
                     exit when is_last_element (tmp, my_task_iterator2);
                     next_element (tmp, my_task_iterator2);
                     current_element (tmp, a_task2, my_task_iterator2);
                     if (a_task2.cpu_name = processor_name) then

                        if Double (a_task2.capacity) > max_bi then
                           max_bi := Double (a_task2.capacity);
                        end if;
                     end if;
                  end loop;
                  compute :=
                    compute +
                    max_bi / Double (periodic_task_ptr (a_task).period);
                  i_bound :=
                    (Double (task_number)) *
                    (Pow (2.0, (1.0 / (Double (task_number)))) - 1.0);

                  if compute > i_bound then
                     verification := False;
                     msg2         := msg2 & a_task.name & " ";
                  end if;
               end if;
               exit when is_last_element (tmp, my_task_iterator);
               next_element (my_tasks, my_task_iterator);
            end loop;

            -- Checks the result
            --
            if verification then
               if output = xml_output then
                  result := result & " result=""true"" explanation=""";
               end if;

               result := result & lb_sched_explanation5 (Current_Language);
               result := result & lb_sched_explanation52 (Current_Language);

               if output = xml_output then
                  result := result & " (" & format (i_bound) & ")";
                  result := result & """ biblio=""" & "[3]" & """";
               else
                  result :=
                    result & lb_see (Current_Language) & "[3]." & unbounded_lf;
               end if;
            else
               if output = xml_output then
                  result := result & " result=""false"" explanation=""";
               end if;

               result := result & lb_sched_explanation8 (Current_Language);

               if output = xml_output then
                  result :=
                    result &
                    lb_sched_explanation81 (Current_Language) &
                    to_unbounded_string (" (") &
                    lb_sched_explanation82 (Current_Language) &
                    msg2 &
                    to_unbounded_string (").");

                  result :=
                    result &
                    To_Unbounded_String (""" biblio=""") &
                    To_Unbounded_String ("[3]") &
                    To_Unbounded_String ("""");
               else
                  result :=
                    result &
                    lb_sched_explanation81 (Current_Language) &
                    To_Unbounded_String (" (") &
                    lb_see (Current_Language) &
                    "[3])." &
                    unbounded_lf &
                    lb_sched_explanation82 (Current_Language) &
                    msg2 &
                    unbounded_lf;
               end if;
            end if;

      end case;

      free (tmp);

   end utilization_factor_feasibility_test;

end feasibility_test.processor_utilization;
