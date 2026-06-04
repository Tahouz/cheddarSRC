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
--    $Rev: 6373 $
--    $Date: 2026-03-24 12:05:12 +0100 (mar., 24 mars 2026) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Strings.Unbounded;
with Ada.Text_IO;                         use Ada.Text_IO;
with GNAT.Current_Exception;          use GNAT.Current_Exception;
with Doubles;                         use Doubles;
with xml_encoder;
with xml_tag;                         use xml_tag;
with scheduler.fixed_priority;        use scheduler.fixed_priority;
with scheduler.fixed_priority.dm;     use scheduler.fixed_priority.dm;
with scheduler.fixed_priority.rm;     use scheduler.fixed_priority.rm;
with double_util;                     use double_util;
with translate;                       use translate;
with Tasks;                           use Tasks;
with task_group_set;                  use task_group_set;
with event_analyzers;                 use event_analyzers;
with event_analyzer_set;              use event_analyzer_set;
with event_analyzer_set; use event_analyzer_set.generic_event_analyzer_set;
with unbounded_strings;               use unbounded_strings;
with Scheduling_Analysis;             use Scheduling_Analysis;
with expressions;                     use expressions;
with Framework_Config;                use Framework_Config;
with multiprocessor_services;         use multiprocessor_services;
with time_unit_events;                use time_unit_events;
use time_unit_events.time_unit_package;
with partitioning_services;           use partitioning_services;
with debug;                           use debug;
with priority_assignment.dm;          use priority_assignment.dm;
with priority_assignment.rm;          use priority_assignment.rm;
with priority_assignment.audsley_opa; use priority_assignment.audsley_opa;
with priority_assignment;             use priority_assignment;
with cache_set;                       use cache_set;
with priority_assignment.audsley_opa_crpd;
use priority_assignment.audsley_opa_crpd;
with feasibility_test; use feasibility_test;
with feasibility_test.processor_utilization;
use feasibility_test.processor_utilization;
with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;
with feasibility_test.periodic_task_worst_case_response_time;
use feasibility_test.periodic_task_worst_case_response_time;
with feasibility_test.transaction_worst_case_response_time;
use feasibility_test.transaction_worst_case_response_time;
with Scheduling_Analysis.extended.task_analysis;
use Scheduling_Analysis.extended.task_analysis;
with framework;  use framework;
with Core_Units; use Core_Units;
use Core_Units.Core_Units_Table_Package;
with Caches;                            use Caches;
with cache_block_set;                   use cache_block_set;
with cache_access_profile_set;          use cache_access_profile_set;
with Processor_Interface;               use Processor_Interface;
with feasibility_test.processor_demand; use feasibility_test.processor_demand;
with xml_tag;                           use xml_tag;
with xml_encoder; use xml_encoder;

package body call_scheduling_framework is

   procedure compute_simulation_time_line
     (sys               : in out system;
      result            : in out Unbounded_String;
      period            : in     Natural;
      options           : in     scheduling_option;
      event_to_generate : in     time_unit_event_type_boolean_table;
      output            : in     output_format := string_output)
   is

   begin

      put_debug ("Call Compute_Simulation_Time_Line");

      sort (sys.tasks, increasing_name'access);
      scheduling_base_period := period;

      initialize (sched.all);
      build_multiprocessor_scheduling
        (sys,
         sched,
         event_to_generate,
         period,
         options);

   exception
      when exit_statement_exception =>
         result :=
           result &
           lb_minus &
           lb_simulation_warning (Current_Language) &
           Exception_Message &
           unbounded_lf;
      when parametric_file_error =>
         result :=
           result &
           lb_minus &
           lb_simulation_error (Current_Language) &
           lb_parametric_file_error (Current_Language) &
           lb_comma &
           Exception_Message &
           unbounded_lf;
      when type_error =>
         result :=
           result &
           lb_minus &
           lb_simulation_error (Current_Language) &
           lb_type_error (Current_Language) &
           lb_comma &
           Exception_Message &
           unbounded_lf;
      when statement_error =>
         result :=
           result &
           lb_minus &
           lb_simulation_error (Current_Language) &
           lb_statement_error (Current_Language) &
           lb_comma &
           Exception_Message &
           unbounded_lf;
      when variable_error =>
         result :=
           result &
           lb_minus &
           lb_simulation_error (Current_Language) &
           lb_variable_error (Current_Language) &
           lb_comma &
           Exception_Message &
           unbounded_lf;
      when syntax_error =>
         result :=
           result &
           lb_minus &
           lb_simulation_error (Current_Language) &
           lb_syntax_error (Current_Language) &
           lb_comma &
           Exception_Message &
           unbounded_lf;
      when time_unit_package.indexed_table_full =>
         result :=
           result &
           lb_minus &
           lb_compute_scheduling_error_22 (Current_Language) &
           unbounded_lf;
         initialize (sched.all);
      when cache_access_profile_must_be_defined =>
         result :=
           result &
           unbounded_lf &
           lb_cache_access_profile_must_be_defined (Current_Language) &
           unbounded_lf;
   end compute_simulation_time_line;

   procedure compute_simulation_basics
     (sys         : in     system;
      result      : in out Unbounded_String;
      a_processor : in     generic_processor_ptr;
      output      : in     output_format := string_output)
   is

      check : Unbounded_String;

   begin

      put_debug ("Call Compute_Simulation_Basics");

      if output = xml_output then
         result :=
           result &
           start_feasibility_Test &
           To_Unbounded_String (" name=""") &
           lb_task_response_time_from_simulation (Current_Language) &
           To_Unbounded_String (""" reference=""") &
           a_processor.name &
           To_Unbounded_String (""">") &
           unbounded_lf;
      end if;

      check := empty_string;
      compute_simulation_number_of_context_switch
        (sys,
         check,
         a_processor,
         output);
      result := result & check;

      check := empty_string;
      compute_simulation_number_of_preemption
        (sys,
         check,
         a_processor,
         output);
      result := result & check;

      --check := empty_string;
      --compute_simulation_number_of_overflow
      --  (sys,
      --   check,
      --   a_processor,
      --   output);
      --result := result & check;

      --check := empty_string;
      --compute_simulation_number_of_underflow
      --  (sys,
      --   check,
      --   a_processor,
      --   output);
      --result := result & check;

      check := empty_string;
      compute_simulation_response_time
        (sys,
         check,
         a_processor,
         True,
         False,
         False,
         output);
      result := result & unbounded_lf & check & unbounded_lf;

      if output = xml_output then
         result := result & end_feasibility_Test & unbounded_lf;
      end if;
   end compute_simulation_basics;

   procedure compute_simulation_number_of_context_switch
     (sys         : in     system;
      result      : in out Unbounded_String;
      a_processor : in     generic_processor_ptr;
      output      : in     output_format := string_output)
   is

      nb : Natural := 0;
      Nb_Str : Unbounded_String := empty_string;

   begin

      put_debug ("Call Compute_Simulation_Number_Of_Context_Switch");

      for j in 0 .. sched.nb_entries - 1 loop

         if sched.entries (j).item.name = a_processor.name then

            if sched.entries (j).data.error_msg /= empty_string then
               if output /= xml_output then
                  result :=
                    result & sched.entries (j).data.error_msg & unbounded_lf;
               end if;
               Nb_Str := empty_string;
            else
               nb :=
                 number_of_switch_context_from_simulation
                   (sched.entries (j).data.result);

               Nb_Str := To_Unbounded_String (nb'img);

               if output /= xml_output then
                  result :=
                    result &
                    lb_minus &
                    lb_number_of_context_switch (Current_Language) &
                    lb_colon &
                    nb'img &
                    unbounded_lf;
               end if;
            end if;

            if output = xml_output then
               result :=
                 result &
                 start_computation &
                 To_Unbounded_String (" name=") &
                 To_Unbounded_String ("""") &
                 lb_number_of_context_switch (Current_Language) &
                 To_Unbounded_String ("""") &
                 To_Unbounded_String (" reference=") &
                 To_Unbounded_String ("""") &
                 a_processor.name &
                 To_Unbounded_String ("""") &
                 To_Unbounded_String (" value=""") &
                 Nb_Str &
                 To_Unbounded_String (""" note=""") &
                 sched.entries (j).data.error_msg &
                 To_Unbounded_String (""" biblio=") &
                 To_Unbounded_String ("""""/>") &
                 unbounded_lf;
            end if;
         end if;
      end loop;
   end compute_simulation_number_of_context_switch;

   procedure compute_simulation_number_of_preemption
     (sys         : in     system;
      result      : in out Unbounded_String;
      a_processor : in     generic_processor_ptr;
      output      : in     output_format := string_output)
   is

      nb : Natural := 0;
      Nb_Str : Unbounded_String := empty_string;

   begin

      put_debug ("Call Compute_Simulation_Number_Of_Preemption");

      for j in 0 .. sched.nb_entries - 1 loop

         if sched.entries (j).item.name = a_processor.name then

            if sched.entries (j).data.error_msg /= empty_string then
               if output /= xml_output then
                  result :=
                    result & sched.entries (j).data.error_msg & unbounded_lf;

               end if;
               Nb_Str := empty_string;
            else
               nb :=
                 number_of_preemption_from_simulation
                   (sched.entries (j).data.result,
                    sys.tasks);

               Nb_Str := To_Unbounded_String (nb'img);

               if output /= xml_output then
                  result := result & sched.entries (j).data.scheduling_msg;
                  result :=
                     result &
                     lb_minus &
                     lb_number_of_preemption (Current_Language) &
                     lb_colon &
                     nb'img &
                     unbounded_lf;
                end if;
            end if;

            if output = xml_output then
               result :=
                 result &
                 start_computation &
                 To_Unbounded_String (" name=") &
                 To_Unbounded_String ("""") &
                 lb_number_of_preemption (Current_Language) &
                 To_Unbounded_String ("""") &
                 To_Unbounded_String (" reference=") &
                 To_Unbounded_String ("""") &
                 a_processor.name &
                 To_Unbounded_String ("""") &
                 To_Unbounded_String (" value=""") &
                 Nb_Str &
                 To_Unbounded_String (""" note=""") &
                 sched.entries (j).data.error_msg &
                 To_Unbounded_String (""" biblio=") &
                 To_Unbounded_String ("""""/>") &
                 unbounded_lf;
            end if;
         end if;
      end loop;

   end compute_simulation_number_of_preemption;

   procedure compute_simulation_number_of_overflow
     (sys         : in     system;
      result      : in out Unbounded_String;
      a_processor : in     generic_processor_ptr;
      output      : in     output_format := string_output)
   is

      nb : Natural := 0;

   begin

      put_debug ("Call Compute_Simulation_Number_Of_Overflow");

      for j in 0 .. sched.nb_entries - 1 loop

         if sched.entries (j).item.name = a_processor.name then

            if sched.entries (j).data.error_msg /= empty_string then
               result :=
                 result & sched.entries (j).data.error_msg & unbounded_lf;

            else
               nb :=
                 number_of_overflow_from_simulation
                   (sched.entries (j).data.result);

               if (nb > 0) then
                  result := result & sched.entries (j).data.scheduling_msg;
                  result :=
                    result &
                    lb_minus &
                    lb_number_of_overflow (Current_Language) &
                    lb_colon &
                    nb'img &
                    unbounded_lf;
               end if;

            end if;

         end if;
      end loop;

   end compute_simulation_number_of_overflow;

   procedure compute_simulation_number_of_underflow
     (sys         : in     system;
      result      : in out Unbounded_String;
      a_processor : in     generic_processor_ptr;
      output      : in     output_format := string_output)
   is

      nb : Natural := 0;

   begin

      put_debug ("Call Compute_Simulation_Number_Of_Overflow");

      for j in 0 .. sched.nb_entries - 1 loop

         if sched.entries (j).item.name = a_processor.name then

            if sched.entries (j).data.error_msg /= empty_string then
               result :=
                 result & sched.entries (j).data.error_msg & unbounded_lf;

            else
               nb :=
                 number_of_underflow_from_simulation
                   (sched.entries (j).data.result);

               if (nb > 0) then
                  result := result & sched.entries (j).data.scheduling_msg;
                  result :=
                    result &
                    lb_minus &
                    lb_number_of_underflow (Current_Language) &
                    lb_colon &
                    nb'img &
                    unbounded_lf;
               end if;
            end if;

         end if;
      end loop;

   end compute_simulation_number_of_underflow;

   procedure compute_simulation_response_time
     (sys          : in     system;
      result       : in out Unbounded_String;
      a_processor  : in     generic_processor_ptr;
      worst_case   :        Boolean;
      best_case    :        Boolean;
      average_case :        Boolean;
      output       : in     output_format := string_output)
   is
      check                  : Unbounded_String := empty_string;
      a_task                 : generic_task_ptr;
      my_iterator            : tasks_iterator;
      min                    : Natural          := 0;
      max                    : Natural          := 0;
      average                : Double           := 0.0;
      missed                 : Boolean          := False;
      completed              : Boolean          := True;
      has_error              : Boolean          := False;
      has_discarded_deadline : Boolean          := False;
      A_Scheduler : generic_scheduler_ptr;
      preemptive  : Unbounded_String := empty_string;
      Max_Str     : Unbounded_String := empty_string;
      Min_Str     : Unbounded_String := empty_string;
      Average_Str : Unbounded_String := empty_string;
      error_str   : Unbounded_String := empty_string;

   begin

      put_debug ("Call Compute_Simulation_Response_Time");
      for j in 0 .. sched.nb_entries - 1 loop
         if sched.entries (j).item.name = a_processor.name then

            if sched.entries (j).data.error_msg /= empty_string then
               has_error := True;
               error_str := sched.entries (j).data.error_msg;
            end if;

            --  Check if there are discarded missed deadlines
            --
            for k in 0 .. sched.entries (j).data.result.nb_entries - 1 loop
               if
                 (sched.entries (j).data.result.entries (k).data
                    .type_of_event =
                  discard_missed_deadline)
               then
                  has_discarded_deadline := True;
               end if;
            end loop;

            if
              (get_number_of_task_from_processor
                 (sys.tasks,
                  a_processor.name) >
               0) and
              (not has_discarded_deadline)
            then

               if output /= xml_output then
                  result :=
                    lb_minus &
                    lb_task_response_time_from_simulation (Current_Language) &
                    lb_colon &
                    unbounded_lf;
               end if;

               reset_iterator (sys.tasks, my_iterator);

               loop
                  current_element (sys.tasks, a_task, my_iterator);

                  check := empty_string;
                  if (a_processor.name = a_task.cpu_name) then

                     response_time_by_simulation
                       (a_task,
                        sched.entries (j).data.result,
                        check,
                        max,
                        min,
                        average);

                  

                     if output /= xml_output then

                        result :=
                        result &
                        lb_tab4 &
                        a_task.name &
                        To_Unbounded_String (" =>");

                     else
                        declare
                           Best_Str    : Unbounded_String := empty_string;
                           Average_Str : Unbounded_String := empty_string;
                           Worst_Str   : Unbounded_String := empty_string;

                        begin

                           if best_case then
                              Best_Str := To_Unbounded_String(min'Img);
                           end if;

                           if average_case then
                              Average_Str := format(average);
                           end if;

                           if worst_case then
                              Worst_Str := To_Unbounded_String(max'Img);
                           end if;

                           result :=
                           result &
                           response_time_xml
                              (a_task.name,
                              Best_Str,
                              Average_Str,
                              Worst_Str) &
                           unbounded_lf;

                        end;
                     end if;
                     if worst_case then
                        if output /= xml_output then
                           result :=
                             result & max'img & To_Unbounded_String ("/worst ");
   
                        end if;
                     end if;

                     if best_case then
                        if output /= xml_output then
                           result :=
                             result & min'img & To_Unbounded_String ("/best ");
                        
                        end if;
                     end if;

                     if average_case then
                        if output /= xml_output then
                           result :=
                             result &
                             format (average) &
                             To_Unbounded_String ("/average ");
                        
                        end if;
                     end if;

                     if (worst_case) and (max = 0) then
                        if output /= xml_output then
                           result :=
                             result &
                             lb_comma &
                             lb_task_is_not_over_response_time_is_not_computed
                               (Current_Language);
                        end if;

                        completed := False;
                     end if;

                     if output /= xml_output then
                        result := result & check & unbounded_lf;
                     end if;

                     if check /= empty_string then
                        missed := True;
                     end if;
                  end if;

                  exit when is_last_element (sys.tasks, my_iterator);

                  next_element (sys.tasks, my_iterator);

               end loop;
            end if;
         end if;
      end loop;

      -- test the feasibility
      if output = xml_output then
         result := result & To_Unbounded_String("<schedulable ");
         A_Scheduler := build_a_scheduler (a_processor);

         if get_preemptive (A_Scheduler.all) = "PREEMPTIVE" then
            preemptive := To_Unbounded_String ("true");
         else
            preemptive := To_Unbounded_String ("false");
         end if;

         result := result & start_schedulability;
         result :=
           result &
           To_Unbounded_String (" scheduler=""") &
           get_name (A_Scheduler.all) &
           To_Unbounded_String ("""") &
           To_Unbounded_String (" preemptive=""") &
           preemptive &
           To_Unbounded_String ("""");
      end if;

      if not has_error then
         if has_discarded_deadline then
            if output /= xml_output then
               result :=
                 result &
                 lb_minus &
                 lb_cannot_compute_wcrt_with_discard_missed_deadline
                   (Current_Language);
            else
               result :=
                 result &
                 To_Unbounded_String (" result=""false"" explanation=""") &
                 lb_cannot_compute_wcrt_with_discard_missed_deadline
                   (Current_Language) &
                 unbounded_lf;
            end if;
         elsif completed = True then
            if missed = False then
               if output /= xml_output then
                  result :=
                    result &
                    lb_minus &
                    lb_no_deadline_missed_in_the_computed_scheduling
                      (Current_Language) &
                    unbounded_lf;
               else
                  result :=
                    result &
                    To_Unbounded_String (" result=""true"" explanation=""") &
                    lb_no_deadline_missed_in_the_computed_scheduling
                      (Current_Language) &
                    unbounded_lf;
               end if;
            else
               if output /= xml_output then
                  result :=
                    result &
                    lb_minus &
                    lb_deadline_will_be_missed_task_are_not_schedulable
                      (Current_Language) &
                    unbounded_lf;
               else
                  result :=
                    result &
                    To_Unbounded_String (" result=""false"" explanation=""") &
                    lb_deadline_will_be_missed_task_are_not_schedulable
                      (Current_Language) &
                    unbounded_lf;
               end if;
            end if;
         else
            if output /= xml_output then
               result :=
                 result &
                 lb_minus &
                 lb_cannot_say_if_deadline_will_be_missed_in_the_computed_scheduling
                   (Current_Language);
            else
               result :=
                 result &
                 To_Unbounded_String (" result=""false"" explanation=""") &
                 lb_cannot_say_if_deadline_will_be_missed_in_the_computed_scheduling
                   (Current_Language);
            end if;
         end if;

         if output = xml_output then
            result := result & To_Unbounded_String ("""");
         end if;
      else
         if output = xml_output then
            result :=
              result &
              To_Unbounded_String (" result=""false"" explanation=""") &
              error_str &
              To_Unbounded_String ("""");
         end if;
      end if;

      if output = xml_output then
         result :=
           result &
           To_Unbounded_String (" biblio=") &
           To_Unbounded_String ("""""/>");
      end if;

   end compute_simulation_response_time;

   procedure compute_feasibility_interval
     (sys         : in     system;
      result      : in out Unbounded_String;
      a_processor : in     generic_processor_ptr;
      output      : in     output_format := string_output)
   is

      period_string  : Unbounded_String;
      free_ut_string : Unbounded_String;

      period   : Double := 0.0;
      util     : Double := 0.0;
      free_ut  : Double := 0.0;
      validate : Boolean;
      msg      : Unbounded_String;

   begin

      put_debug ("Call Compute_Feasibility_Interval");

      begin
         calculate_feasibility_interval
           (sys,
            a_processor,
            validate,
            period,
            msg);
      exception
         when Constraint_Error =>
            -- A large task set with many different period values can lead to
            -- a CONSTRAINT_ERROR exception due to type overflow
            --
            result :=
              result &
              To_Unbounded_String ("- ") &
              Exception_Name &
              " " &
              Exception_Message &
              unbounded_lf;
            result :=
              result &
              lb_minus &
              "Cheddar warning:  Scheduling period overflow! " &
              unbounded_lf;
      end;

      period_string := " " & format (period, 0);

      if output = xml_output
       then
         declare 
         intermediate_scheduling_period : unbounded_string := period_string;
         begin
         xml_encoder.wrap_scheduling_period(intermediate_scheduling_period);
         result :=
           result & intermediate_scheduling_period;
         end ;
      else
         result :=
           result &
           lb_minus &
           lb_scheduling_period (Current_Language) &
           period_string &
           msg &
           unbounded_lf;
           
      end if;

      util := processor_utilization_over_period (sys.tasks, a_processor.name);

      if (a_processor.processor_type = monocore_type) then
         free_ut := period * (1.0 - util);
      else
         free_ut :=
           period *
           (Double (multi_cores_processor_ptr (a_processor).cores.nb_entries) -
            util);
      end if;
      free_ut := Double'max (0.0, free_ut);

      if free_ut > Double (Natural'last) then
         free_ut_string := To_Unbounded_String (Double'image (free_ut));
      else
         free_ut_string :=
           To_Unbounded_String (Natural'image (Natural (free_ut)));
      end if;

      if output = xml_output then
      declare 
      intermediate_unused : Ada.Strings.Unbounded.Unbounded_String := format (free_ut) ;
      begin 
         xml_encoder.wrap_unused_period(intermediate_unused);
         result :=
           result &
           intermediate_unused;
         end ;
      else
         result :=
           result &
           To_Unbounded_String ("-") &
           free_ut_string &
           lb_free_unit_time (Current_Language) &
           unbounded_lf;
      end if;

   exception
      when task_set.task_must_be_periodic =>
         if output /= xml_output then
            result :=
              result &
              lb_minus &
              lb_compute_scheduling_error_2 (Current_Language) &
              unbounded_lf;
         else
            result :=
              result &
              To_Unbounded_String (" exception=""") &
              lb_compute_scheduling_error_2 (Current_Language) &
              To_Unbounded_String ("""/>") &
              unbounded_lf;
         end if;
      when task_set.task_model_error =>
         if output /= xml_output then
            result :=
              result &
              lb_minus &
              lb_compute_scheduling_error_3 (Current_Language) &
              unbounded_lf;
         else
            result :=
              result &
              To_Unbounded_String (" exception=""") &
              lb_compute_scheduling_error_3 (Current_Language) &
              To_Unbounded_String ("""/>") &
              unbounded_lf;
         end if;
   end compute_feasibility_interval;

   procedure compute_feasibility_processor_utilization_factor
     (sys         : in     system;
      result      : in out Unbounded_String;
      a_processor : in     generic_processor_ptr;
      output      : in     output_format := string_output)
   is

      util        : Double;
      utildi      : Double;
      a_scheduler : generic_scheduler_ptr;
      preemptive  : Unbounded_String := empty_string;

   begin

      put_debug ("Call Compute_Feasibility_Processor_Utilization_Factor");

      -- Compute feasibility interval
      --
      if output /= xml_output then
         result :=
           result &
           lb_feasibility_number1 (Current_Language) &
           unbounded_lf &
           unbounded_lf;
      end if;

      compute_feasibility_interval (sys, result, a_processor, output);

      --  if output = xml_output then
      --     result :=
      --       result &
      --       start_computation &
      --       To_Unbounded_String (" name=") &
      --       To_Unbounded_String ("""") &
      --       Lb_Xml_Processor_Utilization_Factor_Deadline (Current_Language) &
      --       To_Unbounded_String ("""") &
      --       To_Unbounded_String (" reference=") &
      --       To_Unbounded_String ("""") &
      --       a_processor.name &
      --       To_Unbounded_String ("""");
      --  end if;

      -- Compute number of cores of the processor
      --
      if output /= xml_output then
         if (a_processor.processor_type = monocore_type) then
            result :=
              result &
              lb_minus &
              lb_processor_has_number_of_cores (Current_Language) &
              To_Unbounded_String (" 1. ") &
              unbounded_lf;
         else
            result :=
              result &
              lb_minus &
              lb_processor_has_number_of_cores (Current_Language) &
              To_Unbounded_String
                (" " &
                 multi_cores_processor_ptr (a_processor).cores.nb_entries'img &
                 ". ") &
              unbounded_lf;
         end if;
      end if;

      -- Compute processor utilization faction over deadline
      --
      begin
         utildi :=
           processor_utilization_over_deadline (sys.tasks, a_processor.name);

         if output = xml_output then
         declare
         intermediate_utilization_over_deadline:Unbounded_String:=  format (utildi);
         begin
            xml_encoder.wrap_utilization_over_deadline(intermediate_utilization_over_deadline);
            result :=
              result &
              intermediate_utilization_over_deadline;
         end;
         else
            result :=
              result &
              lb_minus &
              lb_utilization_with_deadline (Current_Language) &
              format (utildi) &
              To_Unbounded_String (" (") &
              lb_see (Current_Language) &
              To_Unbounded_String ("[1], page 6). ") &
              unbounded_lf;
         end if;
      exception
         when task_set.task_must_be_periodic =>
            if output /= xml_output then
               result :=
                 result &
                 lb_minus &
                 lb_compute_scheduling_error_9 (Current_Language) &
                 unbounded_lf;
            else
               result :=
                 result & To_Unbounded_String (" value=""NA"" explanation=""");
               result :=
                 result & lb_compute_scheduling_error_9 (Current_Language);
               result :=
                 result &
                 To_Unbounded_String (""" biblio=""") &
                 To_Unbounded_String ("""/>") &
                 unbounded_lf;
            end if;
         when task_set.task_model_error =>
            if output /= xml_output then
               result :=
                 result &
                 lb_minus &
                 lb_compute_scheduling_error_10 (Current_Language) &
                 unbounded_lf;
            else
               result :=
                 result & To_Unbounded_String (" value=""NA"" explanation=""");
               result :=
                 result & lb_compute_scheduling_error_10 (Current_Language);
               result :=
                 result &
                 To_Unbounded_String (""" biblio=""") &
                 To_Unbounded_String ("""/>") &
                 unbounded_lf;
            end if;
         when deadline_error =>
            if output /= xml_output then
               result :=
                 result &
                 lb_minus &
                 lb_compute_scheduling_error_21 (Current_Language) &
                 unbounded_lf;
            else
               result :=
                 result & To_Unbounded_String (" value=""NA"" explanation=""");
               result :=
                 result & lb_compute_scheduling_error_10 (Current_Language);
               result :=
                 result &
                 To_Unbounded_String (""" biblio=""") &
                 To_Unbounded_String ("""/>") &
                 unbounded_lf;
            end if;
      end;

      --  if output = xml_output then
      --     result :=
      --       result &
      --       start_computation &
      --       To_Unbounded_String (" name=") &
      --       To_Unbounded_String ("""") &
      --       Lb_Xml_Processor_Utilization_Factor_Period (Current_Language) &
      --       To_Unbounded_String ("""") &
      --       To_Unbounded_String (" reference=") &
      --       To_Unbounded_String ("""") &
      --       a_processor.name &
      --       To_Unbounded_String ("""");
      --  end if;

      -- Compute processor utilization factor over period
      --
      begin
         util :=
           processor_utilization_over_period (sys.tasks, a_processor.name);

         if output = xml_output then
         declare
         intermediate_utilization_over_period:Unbounded_String := format(util);
         begin
         xml_encoder.wrap_utilization_over_period(intermediate_utilization_over_period);
            result :=
              result & intermediate_utilization_over_period;

         end;
         else
            result :=
              result &
              lb_minus &
              lb_utilization_with_period (Current_Language) &
              format (util) &
              To_Unbounded_String (" (") &
              lb_see (Current_Language) &
              To_Unbounded_String ("[1], page 6). ") &
              unbounded_lf;
         end if;
      exception
         when task_set.task_must_be_periodic =>
            if output /= xml_output then
               result :=
                 result &
                 lb_minus &
                 lb_compute_scheduling_error_9 (Current_Language) &
                 unbounded_lf;
            else
               result := result & To_Unbounded_String (" value=""NA"" explanation=""");
               result := result & lb_compute_scheduling_error_9 (current_language);
               result := result & To_Unbounded_String (""" biblio=""") & To_Unbounded_String ("""/>") & unbounded_lf;
            end if;
         when task_set.task_model_error =>
            if output /= xml_output then
               result :=
                 result &
                 lb_minus &
                 lb_compute_scheduling_error_10 (Current_Language) &
                 unbounded_lf;
            else               
               result := result & To_Unbounded_String (" value=""NA"" explanation=""");
               result := result & lb_compute_scheduling_error_10 (Current_Language);
               result := result & To_Unbounded_String (""" biblio=""") & To_Unbounded_String ("""/>") &
               unbounded_lf;
            end if;
      end;

      -- In the case of a partitionned multiprocessor with cores
      -- compute & display the core unit utilization factor
      --
      if (a_processor.processor_type /= monocore_type) and
        (a_processor.migration_type = no_migration_type)
      then
      declare
      cores_intermediate:Unbounded_String :=To_Unbounded_String(""); 
      begin


         --  if output /= xml_output then
         --     result :=
         --       result &
         --       lb_minus &
         --       lb_core_utilization (Current_Language) &
         --       To_Unbounded_String (" (") &
         --       lb_see (Current_Language) &
         --       To_Unbounded_String ("[1], page 6) ") &
         --       unbounded_lf;
         --   end if;

         for i in
           0 .. multi_cores_processor_ptr (a_processor).cores.nb_entries - 1
         loop
            -- Compute core unit utilization faction over deadline
            declare
            core_intermediate : Unbounded_String := To_Unbounded_String("");
            begin
               --  if output = xml_output then
               --     result :=
               --        result &
               --        start_computation &
               --        To_Unbounded_String (" name=") &
               --        To_Unbounded_String ("""") &
               --        Lb_Xml_Core_Utilization_Factor_Deadline (Current_Language) &
               --        To_Unbounded_String ("""") &
               --        To_Unbounded_String (" reference=") &
               --        To_Unbounded_String ("""") &
               --        Multi_Cores_Processor_ptr(a_processor).cores.entries(i).name &
               --        To_Unbounded_String ("""");
               --  end if;

               utildi :=
                 processor_utilization_over_deadline
                   (sys.tasks,
                    a_processor.name,
                    multi_cores_processor_ptr (a_processor).cores.entries (i)
                      .name);

               if output /= xml_output then
                  result :=
                    result &
                    lb_tab5 & lb_minus &
                    lb_core_utilization_with_deadline (Current_Language) &
                    multi_cores_processor_ptr (a_processor).cores.entries (i)
                      .name &
                    " : " &
                    format (utildi) &
                    To_Unbounded_String (".") &
                    unbounded_lf;
               else
               declare 
               utilization_over_deadline : Unbounded_String := format (utildi);
               begin 
                  xml_encoder.wrap_utilization_over_deadline(utilization_over_deadline);
                  core_intermediate :=
                     core_intermediate &
                     utilization_over_deadline;
                  end;
               end if;
            exception
               when task_set.task_must_be_periodic =>
                  if output /= xml_output then
                     result :=
                       result &
                       lb_minus &
                       lb_compute_scheduling_error_9 (Current_Language) &
                       unbounded_lf;
                  else
                     result := result & To_Unbounded_String (" value=""NA"" explanation=""");
                     result := result & lb_compute_scheduling_error_9 (Current_Language);
                     result := result & To_Unbounded_String (""" biblio=""") & To_Unbounded_String ("""/>") &
                     unbounded_lf;
                  end if;
               when task_set.task_model_error =>
                  if output /= xml_output then
                     result :=
                       result &
                       lb_minus &
                       lb_compute_scheduling_error_10 (Current_Language) &
                       unbounded_lf;
                  else
                     result := result & To_Unbounded_String (" value=""NA"" explanation=""");
                     result := result & lb_compute_scheduling_error_10 (Current_Language);
                     result := result & To_Unbounded_String (""" biblio=""") & To_Unbounded_String ("""/>") &
                     unbounded_lf;
                  end if;
               when deadline_error =>
                  if output /= xml_output then
                     result :=
                       result &
                       lb_minus &
                       lb_compute_scheduling_error_21 (Current_Language) &
                       unbounded_lf;
                  else
                     result := result & To_Unbounded_String (" value=""NA"" explanation=""");
                     result := result & lb_compute_scheduling_error_21 (Current_Language);
                     result := result & To_Unbounded_String (""" biblio=""") & To_Unbounded_String ("""/>") &
                     unbounded_lf;
                  end if;

            -- Compute core unit utilization factor over period
            --
            begin
               if output = xml_output then
                  result :=
                     result &
                     start_computation &
                     To_Unbounded_String (" name=") &
                     To_Unbounded_String ("""") &
                     Lb_Xml_Core_Utilization_Factor_Period (Current_Language) &
                     To_Unbounded_String ("""") &
                     To_Unbounded_String (" reference=") &
                     To_Unbounded_String ("""") &
                     Multi_Cores_Processor_ptr(a_processor).cores.entries(i).name &
                     To_Unbounded_String ("""");
               end if;

               util :=
                 processor_utilization_over_period
                   (sys.tasks,
                    a_processor.name,
                    multi_cores_processor_ptr (a_processor).cores.entries (i)
                      .name);

               if output /= xml_output then
                  result :=
                    result &
                    lb_tab5 & lb_minus &
                    lb_core_utilization_with_period (Current_Language) &
                    multi_cores_processor_ptr (a_processor).cores.entries (i)
                      .name &
                    " : " &
                    format (util) &
                    To_Unbounded_String (".") &
                    unbounded_lf;
               else
               declare 
               utilization_over_period : Unbounded_String := format(util);
               begin
                  xml_encoder.wrap_utilization_over_period(utilization_over_period);
                  core_intermediate :=
                     core_intermediate &
                     utilization_over_period;
                  end;
               end if;
            exception
               when task_set.task_must_be_periodic =>
                  if output /= xml_output then
                     result :=
                       result &
                       lb_minus &
                       lb_compute_scheduling_error_9 (Current_Language) &
                       unbounded_lf;
                  else
                     result := result & To_Unbounded_String (" value=""NA"" explanation=""");
                     result := result & lb_compute_scheduling_error_9 (Current_Language);
                     result := result & To_Unbounded_String (""" biblio=""") & To_Unbounded_String ("""/>") &
                     unbounded_lf;
                  end if;
               when task_set.task_model_error =>
                  if output /= xml_output then
                     result :=
                       result &
                       lb_minus &
                       lb_compute_scheduling_error_10 (Current_Language) &
                       unbounded_lf;
                  else
                     result := result & To_Unbounded_String (" value=""NA"" explanation=""");
                     result := result & lb_compute_scheduling_error_10 (Current_Language);
                     result := result & To_Unbounded_String (""" biblio=""") & To_Unbounded_String ("""/>") &
                     unbounded_lf;
                  end if;
                  cores_intermediate := cores_intermediate & core_intermediate;
            end;
            end;
         end loop;
         xml_encoder.wrap_cores(cores_intermediate);
         result:= result & cores_intermediate ;
         end;
      end if;

      -- Compute feasibility test on the Processor utilization bound
      --
      if (a_processor.processor_type = monocore_type) then
         begin
            a_scheduler := build_a_scheduler (a_processor);

            if output = xml_output then
               result := result & Ada.Strings.Unbounded.To_Unbounded_String("<schedulable");

               if get_preemptive (a_scheduler.all) = "PREEMPTIVE" then
                  preemptive := To_Unbounded_String ("true");
               else
                  preemptive := To_Unbounded_String ("false");
               end if;

               result :=
                 result &
                 To_Unbounded_String (" scheduler=""") &
                 get_name (a_scheduler.all) &
                 To_Unbounded_String ("""") &
                 To_Unbounded_String (" preemptive=""") &
                 preemptive &
                 To_Unbounded_String ("""");
            end if;

            utilization_factor_feasibility_test
              (a_scheduler,
               sys.tasks,
               a_processor.name,
               result,
               output);
               
            if output = xml_output then
               result := result & To_Unbounded_String ("/>") & unbounded_lf;
            end if;

            free (a_scheduler);

         exception
            when task_set.task_must_be_periodic =>
               if output /= xml_output then
                  result :=
                    result &
                    lb_minus &
                    lb_compute_scheduling_error_9 (Current_Language) &
                    unbounded_lf;
               else
                  result :=
                    result &
                    To_Unbounded_String (" result=""false"" explanation=""");
                  result :=
                    result & lb_compute_scheduling_error_9 (current_language);
                  result :=
                    result &
                    To_Unbounded_String (""" biblio=""") &
                    To_Unbounded_String ("""/>") &
                    unbounded_lf;
               end if;
            when task_set.task_model_error =>
               if output /= xml_output then
                  result :=
                    result &
                    lb_minus &
                    lb_compute_scheduling_error_10 (Current_Language) &
                    unbounded_lf;
               else
                  result :=
                    result &
                    To_Unbounded_String (" result=""false"" explanation=""");
                  result :=
                    result & lb_compute_scheduling_error_10 (current_language);
                  result :=
                    result &
                    To_Unbounded_String (""" biblio=""") &
                    To_Unbounded_String ("""/>") &
                    unbounded_lf;
               end if;
            when deadline_error =>
               if output /= xml_output then
                  result :=
                    result &
                    lb_minus &
                    lb_compute_scheduling_error_21 (Current_Language) &
                    unbounded_lf;
               else
                  result :=
                    result &
                    To_Unbounded_String (" result=""false"" explanation=""");
                  result :=
                    result & lb_compute_scheduling_error_21 (current_language);
                  result :=
                    result &
                    To_Unbounded_String (""" biblio=""") &
                    To_Unbounded_String ("""/>") &
                    unbounded_lf;
               end if;
            when task_set.start_time_error =>
               if output /= xml_output then
                  result :=
                    result &
                    lb_minus &
                    lb_compute_scheduling_error_23 (Current_Language) &
                    unbounded_lf;
               else
                  result :=
                    result &
                    To_Unbounded_String (" result=""false"" explanation=""");
                  result :=
                    result & lb_compute_scheduling_error_23 (current_language);
                  result :=
                    result &
                    To_Unbounded_String (""" biblio=""") &
                    To_Unbounded_String ("""/>") &
                    unbounded_lf;
               end if;
            when task_set.offset_error =>
               if output /= xml_output then
                  result :=
                    result &
                    lb_minus &
                    lb_compute_scheduling_error_24 (Current_Language) &
                    unbounded_lf;
               else
                  result :=
                    result &
                    To_Unbounded_String (" result=""false"" explanation=""");
                  result :=
                    result & lb_compute_scheduling_error_24 (current_language);
                  result :=
                    result &
                    To_Unbounded_String (""" biblio=""") &
                    To_Unbounded_String ("""/>") &
                    unbounded_lf;
               end if;
         end;
      else
          result := result & start_schedulability;
          result :=
				result &
				To_Unbounded_String (" result=""notImplemented"" explanation=""The feasibility test for processor utilization is not implemented for the multicore case");
			  result :=
				result &
				To_Unbounded_String (""" biblio=""") &
				To_Unbounded_String ("""/>") &
				unbounded_lf;
      end if;
   end compute_feasibility_processor_utilization_factor;

   procedure compute_feasibility_test_by_name
     (sys         : in     system;
      result      : in out Unbounded_String;
      a_processor : in     generic_processor_ptr;
      test_name   :        Unbounded_String;
      output      : in     output_format := string_output)
   is

   begin
      put_debug ("Call Compute_Feasibility_Test_By_Name");

      result := result & unbounded_lf;

   end compute_feasibility_test_by_name;

   procedure compute_feasibility_response_time
     (sys                            : in out system;
      result                         : in out Unbounded_String;
      a_transaction                  : in     transaction_wcrt_type;
      wcrt_with_memory_interferences : in memory_interference_computation_approach_type :=
        no_memory_interference;
      with_crpd   : in crpd_computation_approach_type := no_crpd;
      a_processor : in generic_processor_ptr;
      output      : in output_format                  := string_output)
   is

      rt          : response_time_table;
      msg         : Unbounded_String := empty_string;
      missed      : Boolean          := False;
      a_scheduler : generic_scheduler_ptr;
      preemptive  : Unbounded_String := empty_string;
      intermediate_task_wcrsts :Ada.Strings.Unbounded.Unbounded_String := empty_string;

   begin

      put_debug ("Call Compute_Feasibility_Response_Time");

      if output /= xml_output then
         result :=
           result &
           unbounded_lf &
           lb_feasibility_number2 (Current_Language) &
           unbounded_lf &
           unbounded_lf;
      end if;


      -- In case of global scheduling, we have no method right now 
      -- to compute WCRT : so, display a message and return
      --
      if (a_processor.processor_type /= monocore_type) and
        (a_processor.migration_type /= no_migration_type) then
            if output /= xml_output then
         result :=
           result &
           unbounded_lf &
           "- Cannot compute WCRT for global multiprocessor scheduling " &
           unbounded_lf &
           unbounded_lf;
          end if;
	 return;
      end if;
	


      case a_transaction is
         when periodic =>
            a_scheduler := build_a_scheduler (a_processor);
            compute_response_time
              (a_scheduler,
               sys,
               a_processor.name,
               msg,
               rt,
               wcrt_with_memory_interferences,
               with_crpd);
            free (a_scheduler);

         when tindell =>
            tindell_compute_offset_response_time
              (sys.task_groups,
               a_processor.name,
               msg,
               rt);

         when audsley =>
            audsley_compute_offset_response_time
              (sys.task_groups,
               a_processor.name,
               msg,
               rt);

         when palencia =>
            palencia_compute_offset_response_time
              (sys.task_groups,
               a_processor.name,
               msg,
               rt);

         when wcdops_plus =>
            wcdops_plus (sys, msg, rt, False);

         when wcdops_plus_nim =>
            wcdops_plus_nimp (sys, msg, rt, False);

      end case;

      if output /= xml_output then
         result :=
           result &
           lb_minus &
           lb_worst_case_task_response_time (Current_Language) &
           lb_colon &
           msg &
           unbounded_lf;
      end if;

      for i in
        0 ..
            response_time_range
              (get_number_of_task_from_processor
                 (sys.tasks,
                  a_processor.name) -
               1)
      loop
         if (rt.entries (i).item /= null) then
            if output /= xml_output then
               result :=
                 result &
                 lb_tab4 &
                 rt.entries (i).item.name &
                 To_Unbounded_String (" =>") &
                 Integer'image (Integer (rt.entries (i).data));
            else
            declare 
               intermediate_task_wcrst : Ada.Strings.Unbounded.Unbounded_String := format (rt.entries (i).data);
               begin
               xml_encoder.wrap_wcrt(intermediate_task_wcrst , rt.entries (i).item.name);
               intermediate_task_wcrsts :=
                 intermediate_task_wcrsts &
                 intermediate_task_wcrst;
               end;
            end if;

            if
              (Natural (rt.entries (i).data) > rt.entries (i).item.deadline)
            then
               if output /= xml_output then
                  result :=
                    result &
                    lb_comma &
                    lb_check_deadline (Current_Language) &
                    rt.entries (i).item.deadline'img &
                    To_Unbounded_String (")");
               end if;

               missed := True;
            end if;

            intermediate_task_wcrsts := intermediate_task_wcrsts & unbounded_lf;
         end if;
      end loop;
      if output = xml_output then
         xml_encoder.wrap_wcrts(intermediate_task_wcrsts);
         result := result & intermediate_task_wcrsts;
      end if;
      

      if output = xml_output then
         result := result & Ada.Strings.Unbounded.To_Unbounded_String("<schedulable");
         a_scheduler := build_a_scheduler (a_processor);
         if get_preemptive (a_scheduler.all) = "PREEMPTIVE" then
            preemptive := To_Unbounded_String ("true");
         else
            preemptive := To_Unbounded_String ("false");
         end if;

         result :=
           result &
           To_Unbounded_String (" scheduler=""") &
           get_name (a_scheduler.all) &
           To_Unbounded_String ("""") &
           To_Unbounded_String (" preemptive=""") &
           preemptive &
           To_Unbounded_String ("""");
      end if;

      if missed = False then
         if output /= xml_output then
            result :=
              result &
              lb_minus &
              lb_no_deadline_will_be_missed_task_are_schedulable
                (Current_Language);
      else
            result :=
              result &
              To_Unbounded_String (" result=""true""") &
              To_Unbounded_String (" explanation=""") &
              lb_no_deadline_will_be_missed_task_are_schedulable
                (Current_Language) &
              To_Unbounded_String ("""");
         end if;
      else
         if output /= xml_output then
            result :=
              result &
              lb_minus &
              lb_deadline_will_be_missed_task_are_not_schedulable
                (Current_Language);
         else
            result :=
              result &
              To_Unbounded_String (" result=""false""") &
              To_Unbounded_String (" explanation=""") &
              lb_deadline_will_be_missed_task_are_not_schedulable
                (Current_Language) &
              To_Unbounded_String ("""");
         end if;
      end if;

      if output /= xml_output then
         result :=
           result & unbounded_lf & unbounded_lf;
      else
         result :=
           result & To_Unbounded_String (" biblio=""""/>") & unbounded_lf;
      end if;

   exception
      when task_set.task_must_have_period_equal_to_deadline =>
         if output /= xml_output then
            result :=
              result &
              lb_minus &
              lb_compute_scheduling_error_4 (Current_Language) &
              unbounded_lf;
         else
            result :=
              result &
              start_schedulability &
              To_Unbounded_String (" scheduler=""") & 
              get_name (a_scheduler.all) &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" preemptive=""") &
              preemptive &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" result=""false""") &
              To_Unbounded_String (" explanation=""") &
              lb_compute_scheduling_error_4 (Current_Language) &
              To_Unbounded_String (""" biblio=""""/>") &
              unbounded_lf;
         end if;
      when task_set.task_must_be_periodic =>
         if output /= xml_output then
            result :=
              result &
              lb_minus &
              lb_compute_scheduling_error_5 (Current_Language) &
              unbounded_lf;
         else
            result :=
              result &
              start_schedulability &
              To_Unbounded_String (" scheduler=""") & 
              get_name (a_scheduler.all) &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" preemptive=""") &
              preemptive &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" result=""false""") &
              To_Unbounded_String (" explanation=""") &
              lb_compute_scheduling_error_5 (Current_Language) &
              To_Unbounded_String (""" biblio=""""/>") &
              unbounded_lf;
         end if;
      when task_set.task_model_error =>
         if output /= xml_output then
            result :=
              result &
              lb_minus &
              lb_compute_scheduling_error_6 (Current_Language) &
              unbounded_lf;
         else
            result :=
              result &
              start_schedulability &
              To_Unbounded_String (" scheduler=""") & 
              get_name (a_scheduler.all) &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" preemptive=""") &
              preemptive &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" result=""false""") &
              To_Unbounded_String (" explanation=""") &
              lb_compute_scheduling_error_6 (Current_Language) &
              To_Unbounded_String (""" biblio=""""/>") &
              unbounded_lf;
         end if;
      when processor_utilization_exceeded =>
         if output /= xml_output then
            result :=
              result &
              lb_minus &
              lb_compute_scheduling_error_7 (Current_Language) &
              unbounded_lf;
         else
            result :=
              result &
              start_schedulability &
              To_Unbounded_String (" scheduler=""") & 
              get_name (a_scheduler.all) &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" preemptive=""") &
              preemptive &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" result=""false""") &
              To_Unbounded_String (" explanation=""") &
              lb_compute_scheduling_error_7 (Current_Language) &
              To_Unbounded_String (""" biblio=""""/>") &
              unbounded_lf;
         end if;
      when task_set.start_time_error =>
         if output /= xml_output then
            result :=
              result &
              lb_minus &
              lb_compute_scheduling_error_12 (Current_Language) &
              unbounded_lf;
         else
            result :=
              result &
              start_schedulability &
              To_Unbounded_String (" scheduler=""") & 
              get_name (a_scheduler.all) &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" preemptive=""") &
              preemptive &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" result=""false""") &
              To_Unbounded_String (" explanation=""") &
              lb_compute_scheduling_error_12 (Current_Language) &
              To_Unbounded_String (""" biblio=""""/>") &
              unbounded_lf;
         end if;
      when task_set.offset_error =>
         if output /= xml_output then
            result :=
              result &
              lb_minus &
              lb_compute_scheduling_error_13 (Current_Language) &
              unbounded_lf;
         else
            result :=
              result &
              start_schedulability &
              To_Unbounded_String (" scheduler=""") & 
              get_name (a_scheduler.all) &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" preemptive=""") &
              preemptive &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" result=""false""") &
              To_Unbounded_String (" explanation=""") &
              lb_compute_scheduling_error_13 (Current_Language) &
              To_Unbounded_String (""" biblio=""""/>") &
              unbounded_lf;
         end if;
      when invalid_scheduler =>
         if output /= xml_output then
            result :=
              result &
              lb_minus &
              lb_compute_scheduling_error_18 (Current_Language) &
              unbounded_lf;
         else
            result :=
              result &
              start_schedulability &
              To_Unbounded_String (" scheduler=""") & 
              get_name (a_scheduler.all) &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" preemptive=""") &
              preemptive &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" result=""false""") &
              To_Unbounded_String (" explanation=""") &
              lb_compute_scheduling_error_18 (Current_Language) &
              To_Unbounded_String (""" biblio=""""/>") &
              unbounded_lf;
         end if;
      when computation_time_exceeded =>
         if output /= xml_output then
            result :=
              result &
              lb_minus &
              lb_computation_time_exceeded (Current_Language) &
              unbounded_lf;
         else
            result :=
              result &
              start_schedulability &
              To_Unbounded_String (" scheduler=""") & 
              get_name (a_scheduler.all) &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" preemptive=""") &
              preemptive &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" result=""false""") &
              To_Unbounded_String (" explanation=""") &
              lb_computation_time_exceeded (Current_Language) &
              To_Unbounded_String (""" biblio=""""/>") &
              unbounded_lf;
         end if;
      when transaction_error =>
         if output /= xml_output then
            result :=
              result &
              lb_minus &
              lb_compute_scheduling_error_25 (Current_Language) &
              unbounded_lf;
         else
            result :=
              result &
              start_schedulability &
              To_Unbounded_String (" scheduler=""") & 
              get_name (a_scheduler.all) &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" preemptive=""") &
              preemptive &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" result=""false""") &
              To_Unbounded_String (" explanation=""") &
              lb_compute_scheduling_error_25 (Current_Language) &
              To_Unbounded_String (""" biblio=""""/>") &
              unbounded_lf;
         end if;
      when task_set.generic_task_set.empty_set =>
         if output /= xml_output then
            result :=
              result &
              lb_minus &
              lb_compute_scheduling_error_26 (Current_Language) &
              unbounded_lf;
         else
            result :=
              result &
              start_schedulability &
              To_Unbounded_String (" scheduler=""") & 
              get_name (a_scheduler.all) &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" preemptive=""") &
              preemptive &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" result=""false""") &
              To_Unbounded_String (" explanation=""") &
              lb_compute_scheduling_error_26 (Current_Language) &
              To_Unbounded_String (""" biblio=""""/>") &
              unbounded_lf;
         end if;
      when cache_access_profile_must_be_defined =>
         if output /= xml_output then
            result :=
              result &
              lb_cache_access_profile_must_be_defined (Current_Language) &
              unbounded_lf;
         else
            result :=
              result &
              start_schedulability &
              To_Unbounded_String (" scheduler=""") & 
              get_name (a_scheduler.all) &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" preemptive=""") &
              preemptive &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" result=""false""") &
              To_Unbounded_String (" explanation=""") &
              lb_cache_access_profile_must_be_defined (Current_Language) &
              To_Unbounded_String (""" biblio=""""/>") &
              unbounded_lf;
         end if;
      when cache_access_profile_must_be_defined_for_all_tasks =>
         if output /= xml_output then
            result :=
              result &
              lb_cache_access_profile_must_be_defined (Current_Language) &
              unbounded_lf;
         else
            result :=
              result &
              start_schedulability &
              To_Unbounded_String (" scheduler=""") & 
              get_name (a_scheduler.all) &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" preemptive=""") &
              preemptive &
              To_Unbounded_String ("""") &
              To_Unbounded_String (" result=""false""") &
              To_Unbounded_String (" explanation=""") &
              lb_cache_access_profile_must_be_defined (Current_Language) &
              To_Unbounded_String (""" biblio=""""/>") &
              unbounded_lf;
         end if;

   end compute_feasibility_response_time;

   procedure set_priorities
     (sys         : in out system;
      result      : in out Unbounded_String;
      a_processor : in     generic_processor_ptr;
      a_scheduler : in     framework_statement_type;
      output      : in     output_format := string_output)
   is

      ok               : Boolean := True;
      error_msg        : Unbounded_String;
      a_task           : generic_task_ptr;
      my_task_iterator : tasks_iterator;

   begin

      put_debug ("Call Set_Priorities");

      begin
         if
           (a_scheduler =
            scheduling_set_priorities_according_to_rate_monotonic)
         then
            set_priority_according_to_rm (sys.tasks, a_processor.name);
         elsif
           (a_scheduler =
            scheduling_set_priorities_according_to_deadline_monotonic)
         then
            set_priority_according_to_dm (sys.tasks, a_processor.name);
         elsif
           (a_scheduler = scheduling_set_priorities_according_to_audsley_opa)
         then
            set_priority_according_to_audsley_opa
              (sys.tasks,
               a_processor.name);
         elsif
           (a_scheduler =
            scheduling_set_priorities_according_to_opa_crpd_pt_simplified)
         then
            set_priority_according_to_cpa
              (sys.tasks,
               sys.cache_access_profiles,
               pt_simplified,
               a_processor.name);
         elsif
           (a_scheduler = scheduling_set_priorities_according_to_opa_crpd_pt)
         then
            set_priority_according_to_cpa
              (sys.tasks,
               sys.cache_access_profiles,
               pt_binomial_coefficient,
               a_processor.name);
         elsif
           (a_scheduler = scheduling_set_priorities_according_to_opa_crpd_tree)
         then
            set_priority_according_to_cpa
              (sys.tasks,
               sys.cache_access_profiles,
               tree,
               a_processor.name);
         end if;

      exception
         when task_set.task_must_be_periodic =>
            ok        := False;
            error_msg := lb_minus & lb_priorities_error1 (Current_Language);
         when generic_task_set.empty_set =>
            ok        := False;
            error_msg := lb_minus & lb_priorities_error2 (Current_Language);
         when no_feasible_priority_assignment_exception =>
            ok        := False;
            error_msg := lb_minus & lb_priorities_error_opa (Current_Language);
         when no_feasible_priority_assignment_with_crpd_exception =>
            ok        := False;
            error_msg := lb_priorities_error_opa_crpd (Current_Language);
         when offset_must_be_defined =>
            ok        := False;
            error_msg := lb_minus & lb_offset_must_be_defined_for_opa (Current_Language);
         when cache_access_profile_not_found =>
            ok        := False;
            error_msg :=
              lb_minus &
              lb_cache_access_profile_must_be_defined_for_opa
                (Current_Language);
         when cache_access_profile_must_be_defined =>
            ok        := False;
            error_msg :=
              lb_minus &
              lb_cache_access_profile_must_be_defined_for_opa
                (Current_Language);
      end;

      if ok then
         if output /= xml_output then
            if
              (a_scheduler =
               scheduling_set_priorities_according_to_rate_monotonic)
            then
               result :=
                 result &
                 lb_set_priorities_rm (Current_Language);
            end if;
            if
              (a_scheduler =
               scheduling_set_priorities_according_to_deadline_monotonic)
            then
               result :=
                 result &
                 lb_set_priorities_dm (Current_Language);
            end if;
            if
              (a_scheduler = scheduling_set_priorities_according_to_audsley_opa)
            then
               result :=
                 result &
                 lb_set_priorities_audsley_opa (Current_Language);
            end if;
            if
              (a_scheduler = scheduling_set_priorities_according_to_opa_crpd_pt)
            then
               result :=
                 result &
                 lb_set_priorities_opa_crpd_pt (Current_Language);
            end if;
            if
              (a_scheduler =
               scheduling_set_priorities_according_to_opa_crpd_pt_simplified)
            then
               result :=
                 result &
                 lb_set_priorities_opa_crpd_pt_simplified (Current_Language);
            end if;
            if
              (a_scheduler = scheduling_set_priorities_according_to_opa_crpd_tree)
            then
               result :=
                 result &
                 lb_set_priorities_opa_crpd_tree (Current_Language);
            end if;

            result :=
              result &
              unbounded_lf &
              lb_minus &
              lb_priorities (Current_Language);
         end if;
         if output = xml_output then 

            result := xml_encoder.priority_xml(sys , a_processor);
         else
         reset_iterator (sys.tasks, my_task_iterator);
         loop
            current_element (sys.tasks, a_task, my_task_iterator);

            if (a_task.cpu_name = a_processor.name) then
                  result :=
                    result &
                    unbounded_lf &
                    lb_tab4 &
                    a_task.name &
                    To_Unbounded_String (" =>") &
                    To_Unbounded_String (a_task.priority'img);
            end if;
            exit when is_last_element (sys.tasks, my_task_iterator);
            next_element (sys.tasks, my_task_iterator);
         end loop;
         end if;
         if output /= xml_output then -- TODO JLE : not sure it is still needed
            result :=
              result & unbounded_lf & unbounded_lf;
         end if;

      else
         if output /= xml_output then
            result := result & error_msg;
         else
            result :=
              result &
              To_Unbounded_String ("<error explanation=""") &
              error_msg &
              To_Unbounded_String ("""/>") &
              unbounded_lf;
            result := result & end_feasibility_Test;
         end if;
      end if;

   end set_priorities;

   procedure run_user_defined_event_handlers
     (sys    : in     system;
      result : in out Unbounded_String;
      output : in     output_format := string_output)
   is

      msg               : Unbounded_String;
      my_iterator       : event_analyzers_iterator;
      an_event_analyzer : event_analyzer_ptr;

   begin

      put_debug ("Call Run_User_Defined_Event_Handlers");

      if (get_number_of_elements (sys.event_analyzers) > 0) then

         reset_iterator (sys.event_analyzers, my_iterator);

         loop
            current_element
              (sys.event_analyzers,
               an_event_analyzer,
               my_iterator);

            -- Run an event analyzer
            ---
            begin
               msg := empty_string;

               result := result & unbounded_lf & unbounded_lf;

               result :=
                 result &
                 lb_minus &
                 lb_event_analyzer_name (Current_Language) &
                 lb_colon &
                 an_event_analyzer.event_analyzer_source_file_name &
                 unbounded_lf &
                 unbounded_lf;

               run_an_event_analyzer (sys, sched, an_event_analyzer, msg);

               result := result & msg;

               result := result & unbounded_lf & unbounded_lf;

            exception
               when parametric_file_error =>
                  result :=
                    result &
                    lb_minus &
                    lb_simulation_error (Current_Language) &
                    lb_parametric_file_error (Current_Language) &
                    lb_comma &
                    Exception_Message &
                    unbounded_lf;
               when type_error =>
                  result :=
                    result &
                    lb_minus &
                    lb_simulation_error (Current_Language) &
                    lb_type_error (Current_Language) &
                    lb_comma &
                    Exception_Message &
                    unbounded_lf;
               when statement_error =>
                  result :=
                    result &
                    lb_minus &
                    lb_simulation_error (Current_Language) &
                    lb_statement_error (Current_Language) &
                    lb_comma &
                    Exception_Message &
                    unbounded_lf;
               when variable_error =>
                  result :=
                    result &
                    lb_minus &
                    lb_simulation_error (Current_Language) &
                    lb_variable_error (Current_Language) &
                    lb_comma &
                    Exception_Message &
                    unbounded_lf;
               when syntax_error =>
                  result :=
                    result &
                    lb_minus &
                    lb_simulation_error (Current_Language) &
                    lb_syntax_error (Current_Language) &
                    lb_comma &
                    Exception_Message &
                    unbounded_lf;
            end;

            exit when is_last_element (sys.event_analyzers, my_iterator);

            next_element (sys.event_analyzers, my_iterator);

         end loop;

      end if;

   end run_user_defined_event_handlers;

   procedure partionning_tasks
     (sys             : in out system;
      result          : in out Unbounded_String;
      a_parition_rule : in     partioning_type;
      output          : in     output_format := string_output)
   is

      partitionned_task_set : tasks_set;
      a_task                : generic_task_ptr;
      my_task_iterator      : tasks_iterator;
      msg                   : Unbounded_String := empty_string;
      a_core_processor_name : Unbounded_String;

   begin

      put_debug ("Call Partionning_Tasks");

      case a_parition_rule is

         when general_task =>
            partition_general_task
              (sys.processors,
               sys.tasks,
               msg,
               partitionned_task_set);
         when best_fit =>
            partition_best_fit
              (sys.processors,
               sys.tasks,
               msg,
               partitionned_task_set);
         when next_fit =>
            partition_next_fit
              (sys.processors,
               sys.tasks,
               msg,
               partitionned_task_set);
         when first_fit =>
            partition_first_fit
              (sys.processors,
               sys.tasks,
               msg,
               partitionned_task_set);
         when small_task =>
            partition_small_task
              (sys.processors,
               sys.tasks,
               msg,
               partitionned_task_set);
      end case;

      if output /= xml_output then
         result :=
           result &
           lb_minus &
           lb_partitioning_result (Current_Language) &
           msg &
           lb_colon &
           unbounded_lf;
      end if;

      sys.tasks := partitionned_task_set;

      if output = Xml_Output then 
         result := xml_encoder.partioning_xml(sys);
      else
         reset_iterator (sys.tasks, my_task_iterator);
         loop
            current_element (sys.tasks, a_task, my_task_iterator);

               result :=
               result &
               unbounded_lf &
               lb_tab4 &
               a_task.name &
               To_Unbounded_String (" =>") &
               a_task.cpu_name;

            exit when is_last_element (sys.tasks, my_task_iterator);
            next_element (sys.tasks, my_task_iterator);
         end loop;
      end if;

      if output /= xml_output then -- TODO JLE : not sure if it is still needed
         result := result & unbounded_lf & unbounded_lf;
      end if;
   exception
      when processors_should_have_the_same_scheduler =>
         if output /= xml_output then
            result := result & lb_minus & lb_partition_error1 (Current_Language);
         else
            result :=
              result &
              To_Unbounded_String ("<error explanation=""") &
              lb_partition_error1 (current_language) &
              To_Unbounded_String ("""/>");
         end if;
      when no_such_processors =>
         if output /= xml_output then
            result := result & lb_minus & lb_partition_error2 (Current_Language);
         else
            result :=
              result &
              To_Unbounded_String ("<error explanation=""") &
              lb_partition_error2 (current_language) &
              To_Unbounded_String ("""/>");
         end if;
      when invalid_scheduler_multiprocessors =>
         if output /= xml_output then
            result := result & lb_minus & lb_partition_error3 (Current_Language);
         else
            result :=
              result &
              To_Unbounded_String ("<error explanation=""") &
              lb_partition_error3 (current_language) &
              To_Unbounded_String ("""/>");
         end if;
      when task_set.task_must_be_periodic =>
         if output /= xml_output then
            result := result & lb_minus & lb_partition_error4 (Current_Language);
         else
            result :=
              result &
              To_Unbounded_String ("<error explanation=""") &
              lb_partition_error4 (current_language) &
              To_Unbounded_String ("""/>");
         end if;

   end partionning_tasks;

   procedure compute_feasibility_basics
     (sys         : in out system;
      result      : in out Unbounded_String;
      a_processor : in     generic_processor_ptr;
      output      : in     output_format := string_output)
   is
   begin

      put_debug ("Call Compute_Feasibility_Basics");

      --  if output = xml_output then
      --     result :=
      --       result &
      --       start_feasibility_Test &
      --       To_Unbounded_String (" name=""") &
      --       Lb_Xml_Processor_Utilization_Factor (Current_Language) &
      --       To_Unbounded_String (""" reference=""") &
      --       a_processor.name &
      --       To_Unbounded_String (""">") &
      --       unbounded_lf;
      --  end if;

      compute_feasibility_processor_utilization_factor
        (sys,
         result,
         a_processor,
         output);

      --  if output = xml_output then
      --     result := result & end_feasibility_Test & unbounded_lf;

      --     result :=
      --       result &
      --       start_feasibility_Test &
      --       To_Unbounded_String (" name=""") &
      --       Lb_Xml_Worst_Case_Response_Time (Current_Language) &
      --       To_Unbounded_String (""" reference=""") &
      --       a_processor.name &
      --       To_Unbounded_String (""">") &
      --       unbounded_lf;
      --  end if;

      compute_feasibility_response_time
        (sys,
         result,
         periodic,
         no_memory_interference,
         no_crpd,
         a_processor,
         output);

      if output = xml_output then
         result := result & end_feasibility_Test;
      end if;

   end compute_feasibility_basics;

   ------------------------------------------------------------------------
   -- Compute_Feasibility_By_Demand_Bound_Function
--  "Preemptively Scheduling Hard-Real-Time Sporadic Tasks on One processor",
   --    Baruah, Mok and Rosier, 1990
   -- Implementation Notes:
   --  S. Rubini, 11/2018
   ------------------------------------------------------------------------
   procedure compute_feasibility_by_demand_bound_function
     (sys         : in     system;
      result      : in out Unbounded_String;
      a_processor : in     generic_processor_ptr;
      output      : in     output_format := string_output)
   is
      compute_report : feasibility_test.processor_demand
        .feasibility_test_report;
      a_scheduler : generic_scheduler_ptr;

   begin
      put_debug ("Call Compute_Feasibility_By_Demand_Bound_Function");

      result :=
        result &
        lb_feasibility_dbf (Current_Language) &
        unbounded_lf &
        unbounded_lf;

      a_scheduler := build_a_scheduler (a_processor);

      begin

         sporadic_periodic_task_set_feasibility_test
           (a_scheduler,
            sys.tasks,
            a_processor.name,
            compute_report);

         -- report results
         if compute_report.feasible then

            if compute_report.motivation = by_processor_utilization_factor then
               result :=
                 result &
                 lb_sched_explanation1 (Current_Language) &
                 lb_sched_explanation12 (Current_Language) &
                 format (compute_report.processor_utilization_bound) &
                 To_Unbounded_String (" (") &
                 lb_see (Current_Language) &
                 To_Unbounded_String ("[1], page 6). ") &
                 unbounded_lf &
                 lb_minus &
                 lb_utilization_with_period (Current_Language) &
                 format (compute_report.processor_utilization) &
                 unbounded_lf &

                 unbounded_lf;

            elsif compute_report.motivation = by_dbf then

               result :=
                 result &
                 lb_minus &
                 lb_sched_explanation_dbf1 (Current_Language) &
                 compute_report.check_interval'img &
                 To_Unbounded_String (" (") &
                 lb_see (Current_Language) &
                 To_Unbounded_String ("[22], page 6). ") &
                 unbounded_lf;

            else
               null;   -- TODO  raise an exception
            end if;

         else  -- unfeasible
            if compute_report.motivation = by_processor_utilization_factor then
               result :=
                 result &
                 lb_sched_explanation2 (Current_Language) &
                 lb_sched_explanation22 (Current_Language) &
                 format (compute_report.processor_utilization_bound) &
                 To_Unbounded_String (" (") &
                 lb_see (Current_Language) &
                 To_Unbounded_String ("[1], page 6). ") &
                 unbounded_lf &
                 lb_minus &
                 lb_utilization_with_period (Current_Language) &
                 format (compute_report.processor_utilization) &
                 unbounded_lf;

            elsif compute_report.motivation = by_dbf then
               -- Compute_Report.Overrun_Time /= 0
               result :=
                 result &
                 lb_minus &
                 lb_sched_explanation_dbf2 (Current_Language) &
                 compute_report.check_interval'img &
                 To_Unbounded_String (" (") &
                 lb_see (Current_Language) &
                 To_Unbounded_String ("[22], page ?). ") &
                 unbounded_lf &
                 lb_minus &
                 lb_feasibility_dbf_check_interval (Current_Language) &
                 compute_report.check_interval'img &
                 unbounded_lf &
                 lb_minus &
                 lb_feasibility_dbf_overrun_instant (Current_Language) &
                 compute_report.overrun_time'img &
                 unbounded_lf;
            else
               null;
            end if;

         end if;
      exception
         when task_set.task_must_be_sporadic_or_periodic =>
            result :=
              result &
              lb_minus &
              lb_compute_scheduling_error_27 (Current_Language) &
              unbounded_lf;

         when invalid_scheduler =>
            result :=
              result &
              lb_minus &
              lb_compute_scheduling_error_18 (Current_Language) &
              unbounded_lf;

      end;

   end compute_feasibility_by_demand_bound_function;

end call_scheduling_framework;
