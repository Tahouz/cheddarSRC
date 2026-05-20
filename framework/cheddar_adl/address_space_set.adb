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

with Ada.Exceptions;   use Ada.Exceptions;
with time_unit_events; use time_unit_events;
use time_unit_events.time_unit_package;
with Tasks;     use Tasks;
with Resources; use Resources;
use Resources.Resource_Accesses;
with translate;                    use translate;
with Objects;                      use Objects;
with Objects.extended;             use Objects.extended;
with integer_util;
with initialize_framework;         use initialize_framework;
with Text_IO;                      use Text_IO;
with Scheduler_Interface.extended; use Scheduler_Interface.extended;

package body address_space_set is

   procedure add_address_space
     (my_address_spaces          : in out address_spaces_set;
      name                       : in     Unbounded_String;
      cpu_name                   : in     Unbounded_String;
      text_memory_size           : in     Integer;
      stack_memory_size          : in     Integer;
      data_memory_size           : in     Integer;
      heap_memory_size           : in     Integer;
      is_preemptive              : in     preemptives_type := preemptive;
      quantum                    : in     Integer                         := 0;
      file_name                  : in     Unbounded_String := empty_string;
      a_scheduler : in     schedulers_type := no_scheduling_protocol;
      automaton_name             : in     Unbounded_String := empty_string;
      mils_confidentiality_level : in     mils_confidentiality_level_type :=
        top_secret;
      mils_integrity_level : in mils_integrity_level_type := high;
      mils_component       : in mils_component_type       := sls;
      mils_partition       : in mils_partition_type       := device;
      mils_compliant       : in Boolean                   := True)
   is

      dummy : address_space_ptr;
   begin
      add_address_space
        (my_address_spaces,
         dummy,
         name,
         cpu_name,
         text_memory_size,
         stack_memory_size,
         data_memory_size,
         heap_memory_size,
         is_preemptive,
         quantum,
         file_name,
         a_scheduler,
         automaton_name,
         mils_confidentiality_level,
         mils_integrity_level,
         mils_component,
         mils_partition,
         mils_compliant);
   end add_address_space;

   procedure check_address_space
     (my_address_spaces          : in address_spaces_set;
      name                       : in Unbounded_String;
      cpu_name                   : in Unbounded_String;
      text_memory_size           : in Integer;
      stack_memory_size          : in Integer;
      data_memory_size           : in Integer;
      heap_memory_size           : in Integer;
      is_preemptive              : in preemptives_type := preemptive;
      quantum                    : in Integer                         := 0;
      file_name                  : in Unbounded_String := empty_string;
      a_scheduler : in schedulers_type := no_scheduling_protocol;
      automaton_name             : in Unbounded_String := empty_string;
      mils_confidentiality_level : in mils_confidentiality_level_type :=
        top_secret;
      mils_integrity_level : in mils_integrity_level_type := high;
      mils_component       : in mils_component_type       := sls;
      mils_partition       : in mils_partition_type       := device;
      mils_compliant       : in Boolean                   := True)
   is

   begin

      if name = "" then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_address_space (Current_Language) &
               " " &
               name &
               " : " &
               lb_address_space_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_address_space (Current_Language) &
               " " &
               name &
               " : " &
               lb_address_space_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if cpu_name = "" then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_processor_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (cpu_name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_address_space (Current_Language) &
               " " &
               name &
               " : " &
               lb_processor_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if (text_memory_size < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_address_space (Current_Language) &
               " " &
               name &
               " : " &
               lb_text_memory_size (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (data_memory_size < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_address_space (Current_Language) &
               " " &
               name &
               " : " &
               lb_data_memory_size (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (heap_memory_size < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_address_space (Current_Language) &
               " " &
               name &
               " : " &
               lb_heap_memory_size (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (stack_memory_size < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_address_space (Current_Language) &
               " " &
               name &
               " : " &
               lb_stack_memory_size (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (file_name /= "") and
        (a_scheduler /= automata_user_defined_protocol) and
        (a_scheduler /= compiled_user_defined_protocol) and
        (a_scheduler /= pipeline_user_defined_protocol)
      then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_address_space (Current_Language) &
               " " &
               name &
               " : " &
               lb_file_name_control (Current_Language)));
      end if;

      if not is_a_valid_identifier (file_name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_address_space (Current_Language) &
               " " &
               name &
               " , " &
               file_name &
               " : " &
               lb_parametric_file_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if (quantum < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_address_space (Current_Language) &
               " " &
               name &
               " : " &
               "Quantum" &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if a_scheduler /= rate_monotonic_protocol and
        a_scheduler /= deadline_monotonic_protocol and
        a_scheduler /= posix_1003_highest_priority_first_protocol and
        a_scheduler /= earliest_deadline_first_protocol and
        a_scheduler /= least_laxity_first_protocol and
        a_scheduler /= round_robin_protocol and
        a_scheduler /= maximum_urgency_first_based_on_deadline_protocol and
        a_scheduler /= maximum_urgency_first_based_on_laxity_protocol and
        a_scheduler /= time_sharing_based_on_wait_time_protocol and
        a_scheduler /= time_sharing_based_on_cpu_usage_protocol and
        a_scheduler /= d_over_protocol and
        a_scheduler /= automata_user_defined_protocol and
        a_scheduler /= compiled_user_defined_protocol and
        a_scheduler /= no_scheduling_protocol
      then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_address_space (Current_Language) &
               " " &
               name &
               " : " &
               lb_invalid_scheduler (Current_Language)));
      end if;

   end check_address_space;

   procedure add_address_space
     (my_address_spaces          : in out address_spaces_set;
      a_address_space            : in out address_space_ptr;
      name                       : in     Unbounded_String;
      cpu_name                   : in     Unbounded_String;
      text_memory_size           : in     Integer;
      stack_memory_size          : in     Integer;
      data_memory_size           : in     Integer;
      heap_memory_size           : in     Integer;
      is_preemptive              : in     preemptives_type := preemptive;
      quantum                    : in     Integer                         := 0;
      file_name                  : in     Unbounded_String := empty_string;
      a_scheduler : in     schedulers_type := no_scheduling_protocol;
      automaton_name             : in     Unbounded_String := empty_string;
      mils_confidentiality_level : in     mils_confidentiality_level_type :=
        top_secret;
      mils_integrity_level : in mils_integrity_level_type := high;
      mils_component       : in mils_component_type       := sls;
      mils_partition       : in mils_partition_type       := device;
      mils_compliant       : in Boolean                   := True)
   is

      my_iterator : address_spaces_iterator;

   begin

      check_initialize;

      check_address_space
        (my_address_spaces,
         name,
         cpu_name,
         text_memory_size,
         stack_memory_size,
         data_memory_size,
         heap_memory_size,
         is_preemptive,
         quantum,
         file_name,
         a_scheduler,
         automaton_name,
         mils_confidentiality_level,
         mils_integrity_level,
         mils_component,
         mils_partition,
         mils_compliant);

      if (get_number_of_elements (my_address_spaces) > 0) then

         reset_iterator (my_address_spaces, my_iterator);

         loop
            current_element (my_address_spaces, a_address_space, my_iterator);
            if (name = a_address_space.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_address_space (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_address_space_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;

            exit when is_last_element (my_address_spaces, my_iterator);

            next_element (my_address_spaces, my_iterator);
         end loop;
      end if;

      a_address_space := new address_space;

      a_address_space.cpu_name                   := cpu_name;
      a_address_space.name                       := name;
      a_address_space.text_memory_size           := text_memory_size;
      a_address_space.stack_memory_size          := stack_memory_size;
      a_address_space.data_memory_size           := data_memory_size;
      a_address_space.heap_memory_size           := heap_memory_size;
      a_address_space.mils_confidentiality_level := mils_confidentiality_level;
      a_address_space.mils_integrity_level       := mils_integrity_level;
      a_address_space.mils_component             := mils_component;
      a_address_space.mils_partition             := mils_partition;
      a_address_space.mils_compliant             := mils_compliant;

      a_address_space.scheduling.quantum := quantum;
      a_address_space.scheduling.automaton_name := automaton_name;
      a_address_space.scheduling.scheduler_type := a_scheduler;
      a_address_space.scheduling.preemptive_type := is_preemptive;
      a_address_space.scheduling.user_defined_scheduler_source_file_name :=
        file_name;
      a_address_space.scheduling.period     := 0;
      a_address_space.scheduling.priority   := 0;
      a_address_space.scheduling.start_time := 0;
      a_address_space.scheduling.capacity   := 0;

      add (my_address_spaces, a_address_space);

   exception
      when generic_address_space_set.full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_can_not_define_more_address_spaces (Current_Language)));

   end add_address_space;

   function search_address_space_by_id
     (my_address_spaces : in address_spaces_set;
      id                : in Unbounded_String) return address_space_ptr
   is
      my_iterator : address_spaces_iterator;
      a_addr      : address_space_ptr;
      result      : address_space_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_address_spaces) then

         reset_iterator (my_address_spaces, my_iterator);

         loop
            current_element (my_address_spaces, a_addr, my_iterator);

            if (a_addr.cheddar_private_id = id) then
               found  := True;
               result := a_addr;
            end if;

            exit when is_last_element (my_address_spaces, my_iterator);

            next_element (my_address_spaces, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (address_space_not_found'identity,
            To_String (lb_address_space_id (Current_Language) & "=" & id));
      end if;

      return result;
   end search_address_space_by_id;

   function search_address_space
     (my_address_spaces : in address_spaces_set;
      name              : in Unbounded_String) return address_space_ptr
   is
      my_iterator : address_spaces_iterator;
      a_addr      : address_space_ptr;
      result      : address_space_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_address_spaces) then

         reset_iterator (my_address_spaces, my_iterator);

         loop
            current_element (my_address_spaces, a_addr, my_iterator);

            if (a_addr.name = name) then
               found  := True;
               result := a_addr;
            end if;

            exit when is_last_element (my_address_spaces, my_iterator);

            next_element (my_address_spaces, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (address_space_not_found'identity,
            To_String (lb_address_space_name (Current_Language) & "=" & name));
      end if;

      return result;
   end search_address_space;

   function address_space_is_present
     (my_address_spaces : in address_spaces_set;
      name              : in Unbounded_String) return Boolean
   is
      my_iterator     : address_spaces_iterator;
      a_address_space : address_space_ptr;

      found : Boolean := False;

   begin

      if is_empty (my_address_spaces) then
         return False;
      else
         reset_iterator (my_address_spaces, my_iterator);

         loop
            current_element (my_address_spaces, a_address_space, my_iterator);

            if (a_address_space.name = name) then
               found := True;
            end if;

            exit when is_last_element (my_address_spaces, my_iterator);

            next_element (my_address_spaces, my_iterator);

         end loop;

         return found;
      end if;

   end address_space_is_present;

   procedure delete_processor
     (my_address_spaces : in out address_spaces_set;
      a_processor       : in     Unbounded_String)
   is

      tmp             : address_spaces_set;
      a_address_space : address_space_ptr;
      my_iterator     : address_spaces_iterator;

   begin

      if (get_number_of_elements (my_address_spaces) > 0) then

         reset_iterator (my_address_spaces, my_iterator);
         loop
            current_element (my_address_spaces, a_address_space, my_iterator);

            if (a_address_space.cpu_name = a_processor) then
               add (tmp, a_address_space);
            end if;

            exit when is_last_element (my_address_spaces, my_iterator);
            next_element (my_address_spaces, my_iterator);
         end loop;

         if not is_empty (tmp) then
            reset_iterator (my_address_spaces, my_iterator);
            loop
               current_element (tmp, a_address_space, my_iterator);

               delete (my_address_spaces, a_address_space);

               exit when is_last_element (tmp, my_iterator);
               next_element (tmp, my_iterator);
            end loop;

            reset (tmp, False);
         end if;
      end if;

   end delete_processor;

   --
   -- AADL export sub-programs
   --

   function export_aadl_implementations
     (my_address_spaces : in address_spaces_set;
      my_tasks          : in tasks_set;
      my_resources      : in resources_set) return Unbounded_String
   is
      my_iterator1    : address_spaces_iterator;
      a_address_space : address_space_ptr;

      my_iterator2 : tasks_iterator;
      a_task       : generic_task_ptr;

      my_iterator3 : resources_iterator;
      a_resource   : generic_resource_ptr;

      result               : Unbounded_String := empty_string;
      thread_subcomponents : Unbounded_String := empty_string;
      data_subcomponents   : Unbounded_String := empty_string;
      first_resource       : Boolean          := True;

   begin

      if not is_empty (my_address_spaces) then

         reset_iterator (my_address_spaces, my_iterator1);

         loop
            current_element (my_address_spaces, a_address_space, my_iterator1);

            result :=
              result &
              To_Unbounded_String
                ("process " & To_String (a_address_space.name)) &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String
                ("end " & To_String (a_address_space.name) & ";") &
              unbounded_lf;

            result := result & unbounded_lf;
            result :=
              result &
              To_Unbounded_String
                ("process implementation " &
                 To_String (a_address_space.name) &
                 ".Impl") &
              unbounded_lf;

            thread_subcomponents :=
              export_aadl_declarations (my_tasks, a_address_space.name, 2);
            data_subcomponents :=
              export_aadl_declarations (my_resources, a_address_space.name, 2);
            if (thread_subcomponents /= empty_string) or
              (data_subcomponents /= empty_string)
            then
               result :=
                 result &
                 To_Unbounded_String (ASCII.HT & "subcomponents") &
                 unbounded_lf &
                 thread_subcomponents &
                 data_subcomponents;
            end if;

            if data_subcomponents /= empty_string then

               reset_iterator (my_tasks, my_iterator2);

               result :=
                 result &
                 To_Unbounded_String (ASCII.HT & "connections") &
                 unbounded_lf;

               loop
                  current_element (my_tasks, a_task, my_iterator2);

                  if a_task.address_space_name = a_address_space.name then
                     result :=
                       result &
                       export_aadl_connections (my_resources, a_task.name, 2);
                  end if;

                  exit when is_last_element (my_tasks, my_iterator2);

                  next_element (my_tasks, my_iterator2);

               end loop;
            end if;

            result :=
              result &
              To_Unbounded_String (ASCII.HT & "properties") &
              unbounded_lf;

            result :=
              result &
              To_Unbounded_String
                (ASCII.HT &
                 ASCII.HT &
                 "Cheddar_Properties::Source_Global_Text_Size => " &
                 a_address_space.text_memory_size'img &
                 " kb ;") &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String
                (ASCII.HT &
                 ASCII.HT &
                 "Cheddar_Properties::Source_Global_Data_Size => " &
                 a_address_space.data_memory_size'img &
                 " kb ;") &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String
                (ASCII.HT &
                 ASCII.HT &
                 "Cheddar_Properties::Source_Global_Heap_Size => " &
                 a_address_space.heap_memory_size'img &
                 " kb ;") &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String
                (ASCII.HT &
                 ASCII.HT &
                 "Cheddar_Properties::Source_Global_Stack_Size => " &
                 a_address_space.stack_memory_size'img &
                 " kb ;") &
              unbounded_lf;
            if a_address_space.scheduling.scheduler_type /=
              no_scheduling_protocol
            then
               result :=
                 result &
                 export_aadl_properties (a_address_space.scheduling, 2);
            end if;

            if data_subcomponents /= empty_string then

               result :=
                 result &
                 To_Unbounded_String
                   (ASCII.HT &
                    ASCII.HT &
                    "Cheddar_Properties::Critical_Section => (") &
                 unbounded_lf;

               reset_iterator (my_resources, my_iterator3);

               loop
                  current_element (my_resources, a_resource, my_iterator3);

                  if a_resource.address_space_name = a_address_space.name then

                     if a_resource.critical_sections.nb_entries /= 0 then
                        if not first_resource then
                           result :=
                             result & To_Unbounded_String (",") & unbounded_lf;
                        end if;
                        first_resource := False;
                        for i in
                          0 .. a_resource.critical_sections.nb_entries - 1
                        loop
                           result :=
                             result &
                             ASCII.HT &
                             ASCII.HT &
                             ASCII.HT &
                             """" &
                             "instancied_" &
                             To_String (a_resource.name) &
                             """" &
                             "," &
                             unbounded_lf;
                           result :=
                             result &
                             To_Unbounded_String
                               (ASCII.HT &
                                ASCII.HT &
                                ASCII.HT &
                                """" &
                                "instancied_" &
                                To_String
                                  (a_resource.critical_sections.entries (i)
                                     .item) &
                                """,""" &
                                To_String
                                  (integer_util.format
                                     (a_resource.critical_sections.entries (i)
                                        .data
                                        .task_begin)) &
                                """,""" &
                                To_String
                                  (integer_util.format
                                     (a_resource.critical_sections.entries (i)
                                        .data
                                        .task_end)) &
                                """");
                           if i /=
                             a_resource.critical_sections.nb_entries - 1
                           then
                              result := result & To_Unbounded_String (",");
                              result := result & unbounded_lf;
                           end if;
                        end loop;
                     end if;
                  end if;

                  exit when is_last_element (my_resources, my_iterator3);

                  next_element (my_resources, my_iterator3);

               end loop;

               result :=
                 result &
                 To_Unbounded_String (ASCII.HT & ASCII.HT & ASCII.HT & ");") &
                 unbounded_lf;
            end if;

            result :=
              result &
              To_Unbounded_String
                ("end " & To_String (a_address_space.name) & ".Impl;") &
              unbounded_lf;

            result := result & unbounded_lf;

            exit when is_last_element (my_address_spaces, my_iterator1);

            next_element (my_address_spaces, my_iterator1);

         end loop;

      end if;

      return result;

   end export_aadl_implementations;

   function export_aadl_declarations
     (my_address_spaces : in address_spaces_set;
      number_of_ht      : in Natural) return Unbounded_String
   is
      my_iterator     : address_spaces_iterator;
      a_address_space : address_space_ptr;

      result : Unbounded_String := empty_string;

   begin

      if not is_empty (my_address_spaces) then

         reset_iterator (my_address_spaces, my_iterator);

         loop
            current_element (my_address_spaces, a_address_space, my_iterator);

            for i in 1 .. number_of_ht loop
               result := result & ASCII.HT;
            end loop;

            result :=
              result &
              To_Unbounded_String
                ("instancied_" &
                 To_String (a_address_space.name) &
                 " : process " &
                 To_String (a_address_space.name) &
                 ".Impl;") &
              unbounded_lf;

            exit when is_last_element (my_address_spaces, my_iterator);

            next_element (my_address_spaces, my_iterator);

         end loop;

      end if;

      return result;

   end export_aadl_declarations;

   function export_aadl_properties
     (my_address_spaces : in address_spaces_set;
      number_of_ht      : in Natural) return Unbounded_String
   is
      my_iterator     : address_spaces_iterator;
      a_address_space : address_space_ptr;

      result : Unbounded_String := empty_string;

   begin

      if not is_empty (my_address_spaces) then

         reset_iterator (my_address_spaces, my_iterator);

         loop
            current_element (my_address_spaces, a_address_space, my_iterator);

            for i in 1 .. number_of_ht loop
               result := result & ASCII.HT;
            end loop;

            result :=
              result &
              To_Unbounded_String
                ("Actual_Processor_Binding => reference instancied_" &
                 To_String (a_address_space.cpu_name) &
                 " applies to instancied_" &
                 To_String (a_address_space.name) &
                 ";") &
              unbounded_lf;

            exit when is_last_element (my_address_spaces, my_iterator);

            next_element (my_address_spaces, my_iterator);

         end loop;

      end if;

      return result;

   end export_aadl_properties;

   procedure check_entity_referencing_processor
     (my_address_spaces : in address_spaces_set;
      a_processor       : in Unbounded_String)
   is

      my_iterator : address_spaces_iterator;
      a_addr      : address_space_ptr;

   begin
      if (get_number_of_elements (my_address_spaces) > 0) then

         reset_iterator (my_address_spaces, my_iterator);
         loop
            current_element (my_address_spaces, a_addr, my_iterator);

            if (a_addr.cpu_name = a_processor) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_processor (Current_Language) &
                     " " &
                     a_processor &
                     " : " &
                     lb_address_space (Current_Language) &
                     " " &
                     a_addr.name &
                     " : " &
                     lb_entity_referenced_elsewhere (Current_Language)));
            end if;

            exit when is_last_element (my_address_spaces, my_iterator);
            next_element (my_address_spaces, my_iterator);
         end loop;

      end if;
   end check_entity_referencing_processor;

end address_space_set;
