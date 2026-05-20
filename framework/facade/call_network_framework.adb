------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Cheddar is a GNU GPL real-time scheduling analysis tool.
-- This program provides services to automatically check schedulability and
-- other performance criteria of real-time architecture models.
--
-- Copyright (C) 2002-2023, Frank Singhoff, Alain Plantec, Jerome Legrand,
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

with GNAT.Current_Exception; use GNAT.Current_Exception;
with Text_IO;                use Text_IO;

with unbounded_strings;             use unbounded_strings;
with xml_tag;                       use xml_tag;
with doubles;                       use doubles;
with double_util;                   use double_util;
with translate;                     use translate;
with Framework_Config;              use Framework_Config;
with debug;                         use debug;
with spacewire_flow_transformation; use spacewire_flow_transformation;
with Networks;                      use Networks;
with network_set;                   use network_set;
use network_set.generic_network_set;
with Tasks;    use Tasks;
with task_set; use task_set;
use task_set.generic_task_set;
with Messages;    use Messages;
with message_set; use message_set;
use message_set.generic_message_set;
with Core_Units;    use Core_Units;
with processor_set; use processor_set;
use processor_set.generic_core_unit_set;
with task_dependencies; use task_dependencies;
use task_dependencies.half_dep_set;
with Dependencies; use Dependencies;

with Processors;               use Processors;
with processor_set;            use processor_set;
use processor_set.generic_processor_set;

package body call_network_framework is

   procedure compute_noc_path_delay
     (sys    : in System; result : in out Unbounded_String;
      output : in Output_Format := String_Output)
   is

      period_string : Unbounded_String;
      period        : Double := 0.0;

      msg : Unbounded_String;

   begin

      put_debug ("Compute_NoC_Path_Delay");

      result := empty_string;

      --Calculate_Feasibility_Interval
      --      (Sys,
      --       A_Processor,
      --       Validate,
      --       Period,
      --       Msg);

      period_string := " " & format (period, 0);

      result :=
        result & lb_minus & lb_scheduling_period (Current_Language) &
        period_string & msg & unbounded_lf;

   exception
      when task_set.task_must_be_periodic =>
         result :=
           result & lb_minus &
           lb_compute_scheduling_error_2 (Current_Language) & unbounded_lf;
      when task_set.task_model_error =>
         result :=
           result & lb_minus &
           lb_compute_scheduling_error_3 (Current_Language) & unbounded_lf;

   end compute_noc_path_delay;

   procedure compute_noc_communication_delay
     (sys    : in System; result : in out Unbounded_String;
      output : in Output_Format := String_Output)
   is
   begin
      null;
   end compute_noc_communication_delay;

   procedure compute_noc_direct_interference_delay
     (sys    : in System; result : in out Unbounded_String;
      output : in Output_Format := String_Output)
   is
   begin
      null;
   end compute_noc_direct_interference_delay;

   procedure compute_noc_indirect_interference_delay
     (sys    : in System; result : in out Unbounded_String;
      output : in Output_Format := String_Output)
   is
   begin
      null;
   end compute_noc_indirect_interference_delay;

   procedure compute_ectm_saf_transformation
     (sys : in System; result : in out Unbounded_String; update : in Boolean;
      output : in Output_Format := String_Output)
   is
   begin
      null;
   end compute_ectm_saf_transformation;

   procedure compute_ectm_wormhole_transformation
     (sys : in System; result : in out Unbounded_String; update : in Boolean;
      output : in Output_Format := String_Output)
   is
   begin
      null;
   end compute_ectm_wormhole_transformation;

   procedure compute_wcctm_saf_transformation
     (sys : in System; result : in out Unbounded_String; update : in Boolean;
      output : in Output_Format := String_Output)
   is
   begin
      null;
   end compute_wcctm_saf_transformation;

   procedure compute_wcctm_wormhole_transformation
     (sys : in System; result : in out Unbounded_String; update : in Boolean;
      output : in Output_Format := String_Output)
   is
   begin
      null;
   end compute_wcctm_wormhole_transformation;

   procedure compute_spacewire_scm_transformation
     (sys    : in out System; result : in out Unbounded_String;
      update : in     Boolean; output : in Output_Format := String_Output)
   is

      sys_result : System;
      number     : Integer;

      a_network   : generic_network_ptr;
      ite1        : networks_iterator;
      a_task      : generic_task_ptr;
      ite2        : tasks_iterator;
      a_message   : generic_message_ptr;
      ite3        : messages_iterator;
      a_processor : generic_processor_ptr;
      ite4        : processors_iterator;
      ite5        : tasks_dependencies_iterator;
      a_dep       : dependency_ptr;

   begin

      put_debug ("Call Compute_Spacewire_SCM_transformation");

      result := empty_string;
      initialize (sys_result);

      if (get_number_of_elements (sys.networks) > 0) then
         reset_iterator (sys.networks, ite1);

         loop
            current_element (sys.networks, a_network, ite1);

            result :=
              result &
              To_Unbounded_String
                ("- Producing DAG for the Spacewire network : ") &
              a_network.name & unbounded_lf;
            begin
               compute_spacewire_transformation
                 (sys, spacewire_network_ptr (a_network), sys_result);
            exception
               when dependency_not_found =>
                  result :=
                    result & To_Unbounded_String ("- Network ") &
                    a_network.name &
                    To_Unbounded_String
                      (": asynchronous message dependencies are needed to apply such analysis. ") &
                    unbounded_lf;
            end;

            exit when is_last_element (sys.networks, ite1);

            next_element (sys.networks, ite1);

         end loop;

         result :=
           result & To_Unbounded_String ("- Produced DAG : ") & unbounded_lf;

         number := Integer (get_number_of_elements (sys_result.processors));
         result := result & "   - " & number'Img & " Processor(s) : ";
         if (number > 0) then
            reset_iterator (sys_result.processors, ite4);
            loop
               current_element (sys_result.processors, a_processor, ite4);
               result := result & " " & a_processor.name & " ";
               exit when is_last_element (sys_result.processors, ite4);
               next_element (sys_result.processors, ite4);
            end loop;
         end if;
         result := result & unbounded_lf;

         number := Integer (get_number_of_elements (sys_result.tasks));
         result := result & "   - " & number'Img & " Task(s) : ";
         if (number > 0) then
            reset_iterator (sys_result.tasks, ite2);
            loop
               current_element (sys_result.tasks, a_task, ite2);
               result := result & " " & a_task.name & " ";
               exit when is_last_element (sys_result.tasks, ite2);
               next_element (sys_result.tasks, ite2);
            end loop;
         end if;
         result := result & unbounded_lf;

         number := Integer (get_number_of_elements (sys_result.messages));
         result := result & "   - " & number'Img & " Message(s) : ";
         if (number > 0) then
            reset_iterator (sys_result.messages, ite3);
            loop
               current_element (sys_result.messages, a_message, ite3);
               result := result & " " & a_message.name & " ";
               exit when is_last_element (sys_result.messages, ite3);
               next_element (sys_result.messages, ite3);
            end loop;
         end if;
         result := result & unbounded_lf;

         number :=
           Integer (get_number_of_elements (sys_result.dependencies.depends));
         result := result & "   - " & number'Img & " Dependency(ies) : ";
         if (number > 0) then
            reset_iterator (sys_result.dependencies.depends, ite5);
            loop
               current_element (sys_result.dependencies.depends, a_dep, ite5);
               if a_dep.type_of_dependency =
                 asynchronous_communication_dependency

               then
                  if
                    (a_dep.asynchronous_communication_orientation =
                     from_task_to_object)
                  then
                     result :=
                       result & " " &
                       a_dep.asynchronous_communication_dependent_task.name &
                       "=>" &
                       a_dep.asynchronous_communication_dependency_object
                         .name &
                       " ";
                  else
                     result :=
                       result & " " &
                       a_dep.asynchronous_communication_dependency_object
                         .name &
                       "=>" &
                       a_dep.asynchronous_communication_dependent_task.name &
                       " ";
                  end if;
               end if;
               exit when is_last_element
                   (sys_result.dependencies.depends, ite5);
               next_element (sys_result.dependencies.depends, ite5);
            end loop;
            result := result & unbounded_lf;
         end if;
      end if;
      result := result & unbounded_lf;
      result := result & unbounded_lf;

      if update then
         --initialize(sys);
         duplicate (sys_result, sys);
      end if;

   end compute_spacewire_scm_transformation;

end call_network_framework;
