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
--    $Rev: 4714 $
--    $Date: 2023-12-18 00:07:26 +0100 (lun., 18 déc. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Framework_Config; use Framework_Config;
with xml_tag;          use xml_tag;
with scheduler;        use scheduler;
with translate;        use translate;
with Tasks;            use Tasks;
with task_set;         use task_set;
use task_set.generic_task_set;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with unbounded_strings;                 use unbounded_strings;
with dependency_services;               use dependency_services;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with debug; use debug;

package body call_dependency_framework is

   procedure chetto_parameter_modifications
     (sys                : in out System; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr; compute_deadlines : in Boolean;
      compute_priorities : in     Boolean; update_tasks_set : in Boolean;
      output             : in     Output_Format := String_Output)
   is

      tmp       : tasks_set;
      a_task    : generic_task_ptr;
      iterator1 : tasks_iterator;

   begin

      put_debug ("Call Chetto_Parameter_Modificiations");

      if compute_deadlines then

         result :=
           result & unbounded_lf & lb_minus &
           lb_chetto_deadline (Current_Language) & To_Unbounded_String (" (") &
           lb_see (Current_Language) & To_Unbounded_String ("[5], [6]).") &
           unbounded_lf & unbounded_lf;

      else
         result :=
           result & unbounded_lf & lb_minus &
           lb_chetto_priority (Current_Language) & To_Unbounded_String (" (") &
           lb_see (Current_Language) & To_Unbounded_String ("[5], [6]).") &
           unbounded_lf & unbounded_lf;
      end if;

      -- If we must update parameters, we do not work on temporary tasks_set
      -- Call logic and display new parameters
      --
      if update_tasks_set then
         set_parameters_according_to_chetto
           (sys.dependencies, sys.tasks, compute_deadlines,
            compute_priorities);

         -- Display priorities/deadlines
         --
         reset_iterator (sys.tasks, iterator1);
         loop

            current_element (sys.tasks, a_task, iterator1);
            result :=
              result & To_Unbounded_String ("- ") & a_task.name &
              To_Unbounded_String (" => ");
            if compute_deadlines then
               result :=
                 result & To_Unbounded_String (a_task.deadline'Img) &
                 unbounded_lf;
            else
               result :=
                 result & To_Unbounded_String (a_task.priority'Img) &
                 unbounded_lf;
            end if;

            exit when is_last_element (sys.tasks, iterator1);

            next_element (sys.tasks, iterator1);
         end loop;

         if compute_priorities then
            result :=
              result & lb_minus & lb_priorities_are_updated (Current_Language);
         else
            result :=
              result & lb_minus & lb_deadlines_are_updated (Current_Language);
         end if;
         result := result & unbounded_lf & unbounded_lf & unbounded_lf;

      else
         duplicate (sys.tasks, tmp);
         set_parameters_according_to_chetto
           (sys.dependencies, tmp, compute_deadlines, compute_priorities);

         -- Display priorities/deadlines
         --
         reset_iterator (tmp, iterator1);
         loop

            current_element (tmp, a_task, iterator1);
            result :=
              result & To_Unbounded_String ("- ") & a_task.name &
              To_Unbounded_String (" => ");
            if compute_deadlines then
               result :=
                 result & To_Unbounded_String (a_task.deadline'Img) &
                 unbounded_lf;
            else
               result :=
                 result & To_Unbounded_String (a_task.priority'Img) &
                 unbounded_lf;
            end if;

            exit when is_last_element (tmp, iterator1);

            next_element (tmp, iterator1);
         end loop;

         free (tmp);

      end if;

      result := result & unbounded_lf;

   exception
      when dependency_services.dependencies_period_error =>
         result :=
           result & lb_minus & lb_chetto_error2 (Current_Language) &
           unbounded_lf;
      when dependency_services.cyclic_graph_error =>
         result :=
           result & lb_minus & lb_chetto_error1 (Current_Language) &
           unbounded_lf;
      when dependency_services.task_model_error =>
         result :=
           result & lb_minus & lb_chetto_error3 (Current_Language) &
           unbounded_lf;
      when dependency_services.deadline_exhausted =>
         result :=
           result & lb_minus & lb_chetto_error4 (Current_Language) &
           unbounded_lf;

   end chetto_parameter_modifications;

   procedure compute_end_to_end_response_time
     (sys              : in out System; result : in out Unbounded_String;
      update_tasks_set : in     Boolean; one_step : in Boolean;
      output           : in     Output_Format := String_Output)
   is

      rt          : response_time_table;
      referencies : Unbounded_String := empty_string;
      message     : Unbounded_String := empty_string;

   begin

      put_debug ("Call Compute_End_To_End_Response_Time");

      initialize (rt);

      begin

         compute_end_to_end_response_time
           (sys, one_step, update_tasks_set, referencies, rt);

         if one_step then
            message :=
              message & lb_minus &
              lb_jitter_from_response_time_one_step (Current_Language);
         else
            message :=
              message & lb_minus &
              lb_jitter_from_response_time_all_steps (Current_Language);
         end if;

         message := message & referencies & unbounded_lf;

         if update_tasks_set then
            message :=
              message & lb_minus & lb_jitters_are_updated (Current_Language) &
              unbounded_lf;
         end if;

         message :=
           message & lb_task_response_time (Current_Language) & unbounded_lf;

         for i in 0 .. rt.nb_entries - 1 loop
            if (rt.entries (i).item /= null) then
               message :=
                 message & lb_tab4 & rt.entries (i).item.name &
                 To_Unbounded_String (" => ") &
                 Integer'Image (Integer (rt.entries (i).data)) & lb_comma &
                 lb_jitter (Current_Language) & To_Unbounded_String ("=") &
                 periodic_task_ptr (rt.entries (i).item).jitter'Img &
                 To_Unbounded_String (" ");
               if
                 (Natural (rt.entries (i).data) > rt.entries (i).item.deadline)
               then
                  message :=
                    message & lb_comma & lb_check_deadline (Current_Language) &
                    rt.entries (i).item.deadline'Img;
                  message := message & To_Unbounded_String (")");
               end if;

               message := message & unbounded_lf;
            end if;
         end loop;
         -- TODO JLE : not sure it is necessary
         message := message & unbounded_lf & unbounded_lf;

      exception
         when dependency_services.dependencies_period_error =>
            message :=
              message & lb_minus & lb_holistique_error1 (Current_Language) &
              unbounded_lf;
         when dependency_services.task_model_error =>
            result :=
              result & lb_minus & lb_holistique_error2 (Current_Language) &
              unbounded_lf;
         when task_set.task_must_be_periodic =>
            message :=
              message & lb_minus &
              lb_compute_scheduling_error_5 (Current_Language) & unbounded_lf;
         when task_set.task_must_have_period_equal_to_deadline =>
            message :=
              message & lb_minus &
              lb_compute_scheduling_error_4 (Current_Language) & unbounded_lf;
         when task_set.task_model_error =>
            message :=
              message & lb_minus &
              lb_compute_scheduling_error_6 (Current_Language) & unbounded_lf;
         when processor_utilization_exceeded =>
            message :=
              message & lb_minus &
              lb_compute_scheduling_error_7 (Current_Language) & unbounded_lf;
         when task_set.start_time_error =>
            message :=
              message & lb_minus &
              lb_compute_scheduling_error_12 (Current_Language) & unbounded_lf;
         when task_set.offset_error =>
            message :=
              message & lb_minus &
              lb_compute_scheduling_error_13 (Current_Language) & unbounded_lf;
         when invalid_scheduler =>
            message :=
              message & lb_minus &
              lb_compute_scheduling_error_18 (Current_Language) & unbounded_lf;

      end;

      result := result & message;

   end compute_end_to_end_response_time;

end call_dependency_framework;
