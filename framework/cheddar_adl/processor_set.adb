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
--    $Rev: 4840 $
--    $Date: 2024-01-25 12:19:51 +0100 (jeu., 25 janv. 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Exceptions; use Ada.Exceptions;
with Processors;     use Processors;
with Core_Units;     use Core_Units;
use Core_Units.Core_Units_Table_Package;
with translate;                    use translate;
with Objects;                      use Objects;
with Objects.extended;             use Objects.extended;
with initialize_framework;         use initialize_framework;
with Scheduler_Interface.extended; use Scheduler_Interface.extended;

with Text_IO; use Text_IO;

package body processor_set is

   procedure check_core_unit
     (name           : in Unbounded_String;
      is_preemptive  : in preemptives_type;
      quantum        : in Integer;
      speed          : in Integer;
      capacity       : in Integer;
      period         : in Integer;
      priority       : in Integer;
      file_name      : in Unbounded_String;
      protocol_name  : in Unbounded_String;
      a_scheduler    : in schedulers_type;
      automaton_name : in Unbounded_String := empty_string;
      l1_cache       : in Unbounded_String := empty_string;
      start_time     : in Integer          := 0;
      threshold      : in Integer          := 0)

   is

   begin

      if (name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_core_unit_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_core_unit (Current_Language) &
               name &
               " : " &
               lb_core_unit_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if not is_a_valid_identifier (file_name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_core_unit (Current_Language) &
               " " &
               name &
               " , " &
               file_name &
               " : " &
               lb_parametric_file_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if
        ((a_scheduler = pipeline_user_defined_protocol) or
         (a_scheduler = automata_user_defined_protocol) or
         (a_scheduler = hierarchical_offline_protocol)) and
        (file_name = "")
      then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_core_unit (Current_Language) &
               name &
               " : " &
               lb_file_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if (file_name /= "") and
        (a_scheduler /= pipeline_user_defined_protocol) and
        (a_scheduler /= automata_user_defined_protocol) and
        (a_scheduler /= hierarchical_offline_protocol)
      then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_core_unit (Current_Language) &
               name &
               " : " &
               lb_file_name_control (Current_Language)));
      end if;

      if period < 0 then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_core_unit (Current_Language) &
               " " &
               name &
               " : " &
               lb_period (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               To_Unbounded_String ("0")));
      end if;


      if (capacity = 0) 
        and (a_scheduler = hierarchical_cyclic_protocol)
	then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_core_unit (Current_Language) &
               " " &
               name &
               " : " &
               lb_capacity (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_than (Current_Language) &
               To_Unbounded_String ("0")));
      end if;

      if capacity < 0 then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_core_unit (Current_Language) &
               " " &
               name &
               " : " &
               lb_capacity (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               To_Unbounded_String ("0")));
      end if;

      if start_time < 0 then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_core_unit (Current_Language) &
               " " &
               name &
               " : " &
               lb_start_time (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               To_Unbounded_String ("0")));
      end if;

      if (priority < Integer (priority_range'first)) or
        (priority > Integer (priority_range'last))
      then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_core_unit (Current_Language) &
               " " &
               name &
               " : " &
               lb_invalid_priority (Current_Language)));
      end if;

      if (quantum /= 0) and
        (a_scheduler /= posix_1003_highest_priority_first_protocol) and
        (a_scheduler /= round_robin_protocol) and
        (a_scheduler /= hierarchical_round_robin_protocol) 
      then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_core_unit (Current_Language) &
               name &
               " : " &
               lb_quantum_control (Current_Language)));
      end if;

      if (quantum < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_core_unit (Current_Language) &
               name &
               " : " &
               "Quantum" &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               To_Unbounded_String ("0")));
      end if;

      if (speed < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_core_unit (Current_Language) &
               name &
               " : " &
               lb_speed (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               To_Unbounded_String ("0")));
      end if;

      if (a_scheduler = no_scheduling_protocol) or
        (a_scheduler = user_defined_protocol)
      then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_core_unit (Current_Language) &
               " " &
               name &
               " : " &
               lb_invalid_scheduler (Current_Language)));
      end if;

      if not is_a_valid_identifier (l1_cache) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_core_unit (Current_Language) &
               name &
               " : " &
               lb_cache_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

   end check_core_unit;

   procedure add_core_unit
     (my_core_units            : in out core_units_set;
      a_core_unit              : in out core_unit_ptr;
      name                     : in     Unbounded_String;
      is_preemptive            : in     preemptives_type;
      quantum                  : in     Integer;
      speed                    : in     Integer;
      capacity                 : in     Integer;
      period                   : in     Integer;
      priority                 : in     Integer;
      file_name                : in     Unbounded_String;
      scheduling_protocol_name : in     Unbounded_String;
      a_scheduler              : in     schedulers_type;
      mem                      : in     memories_table   := no_memories;
      automaton_name           : in     Unbounded_String := empty_string;
      l1_cache                 : in     Unbounded_String := empty_string;
      start_time               : in     Integer          := 0;
      threshold                : in     Integer          := 0)

   is

      my_iterator : core_units_iterator;

   begin

      check_initialize;

      check_core_unit
        (name,
         is_preemptive,
         quantum,
         speed,
         capacity,
         period,
         priority,
         file_name,
         scheduling_protocol_name,
         a_scheduler,
         automaton_name,
         l1_cache,
         start_time,
         threshold);

      if (get_number_of_elements (my_core_units) > 0) then

         reset_iterator (my_core_units, my_iterator);

         loop
            current_element (my_core_units, a_core_unit, my_iterator);
            if (name = a_core_unit.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_core_unit (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_core_unit_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;

            exit when is_last_element (my_core_units, my_iterator);

            next_element (my_core_units, my_iterator);
         end loop;
      end if;

      a_core_unit      := new core_unit;
      a_core_unit.name := To_Unbounded_String (To_String (name));

      a_core_unit.speed                := speed;
      a_core_unit.l1_cache_system_name := l1_cache;
      a_core_unit.memory_partitions    := mem;

      a_core_unit.scheduling.capacity := capacity;
      a_core_unit.scheduling.period := period;
      a_core_unit.scheduling.start_time := start_time;
      a_core_unit.scheduling.threshold := threshold;
      a_core_unit.scheduling.scheduler_type := a_scheduler;
      a_core_unit.scheduling.quantum := quantum;
      a_core_unit.scheduling.preemptive_type := is_preemptive;
      a_core_unit.scheduling.priority := priority_range (priority);
      a_core_unit.scheduling.automaton_name := automaton_name;
      a_core_unit.scheduling.user_defined_scheduler_source_file_name :=
        file_name;
      a_core_unit.scheduling.user_defined_scheduler_protocol_name :=
        scheduling_protocol_name;

      add (my_core_units, a_core_unit);

   exception
      when generic_core_unit_set.full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_core_units (Current_Language)));

   end add_core_unit;

   -- verion mixed criticality with threshold parameters
   
   procedure add_core_unit
     (my_core_units            : in out core_units_set;
      name                     : in     Unbounded_String;
      is_preemptive            : in     preemptives_type;
      quantum                  : in     Integer;
      speed                    : in     Integer;
      capacity                 : in     Integer;
      period                   : in     Integer;
      priority                 : in     Integer;
      file_name                : in     Unbounded_String;
      scheduling_protocol_name : in     Unbounded_String;
      a_scheduler              : in     schedulers_type;
      mem                      : in     memories_table   := no_memories;
      automaton_name           : in     Unbounded_String := empty_string;
      l1_cache                 : in     Unbounded_String := empty_string;
      start_time               : in     Integer          := 0;
      threshold                : in     Integer          := 0)
   is

      dummy : core_unit_ptr;

   begin
      add_core_unit
        (my_core_units,
         dummy,
         name,
         is_preemptive,
         quantum,
         speed,
         capacity,
         period,
         priority,
         file_name,
         scheduling_protocol_name,
         a_scheduler,
         mem,
         automaton_name,
         l1_cache,
         start_time,
         threshold);
   end add_core_unit;

   procedure add_processor
     (my_processors    : in out processors_set;
      a_processor      : in out generic_processor_ptr;
      name             : in     Unbounded_String;
      cores            : in     core_units_table;
      a_migration      :        migrations_type := job_level_migration_type;
      a_processor_type :        processors_type := identical_multicores_type)
   is

      my_iterator             : processors_iterator;
      a_multi_cores_processor : multi_cores_processor_ptr;

   begin

      check_initialize;

      check_processor
        (my_processors,
         name,
         cores,
         a_migration,
         a_processor_type);

      if (get_number_of_elements (my_processors) > 0) then

         reset_iterator (my_processors, my_iterator);

         loop
            current_element (my_processors, a_processor, my_iterator);
            if (name = a_processor.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_processor (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_processor_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;

            exit when is_last_element (my_processors, my_iterator);

            next_element (my_processors, my_iterator);
         end loop;
      end if;

      if cores.nb_entries = 1 then
         add_processor (my_processors, a_processor, name, cores.entries (0));
      else
         a_multi_cores_processor                := new multi_cores_processor;
         a_multi_cores_processor.cores          := cores;
         a_multi_cores_processor.migration_type := a_migration;
         a_multi_cores_processor.processor_type := a_processor_type;
         a_processor := generic_processor_ptr (a_multi_cores_processor);
         a_processor.name                       := name;

         add (my_processors, a_processor);
      end if;

   exception
      when generic_processor_set.full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_processors (Current_Language)));

   end add_processor;

   procedure add_processor
     (my_processors    : in out processors_set;
      name             : in     Unbounded_String;
      cores            : in     core_units_table;
      a_migration      :        migrations_type := job_level_migration_type;
      a_processor_type :        processors_type := identical_multicores_type)
   is

      dummy : generic_processor_ptr;
   begin
      add_processor
        (my_processors,
         dummy,
         name,
         cores,
         a_migration,
         a_processor_type);
   end add_processor;

   procedure add_processor
     (my_processors : in out processors_set;
      a_processor   : in out generic_processor_ptr;
      name          : in     Unbounded_String;
      a_core        : in     core_unit_ptr)
   is

      my_iterator           : processors_iterator;
      a_mono_core_processor : mono_core_processor_ptr;

   begin

      check_initialize;

      check_processor (my_processors, name, a_core);

      if (get_number_of_elements (my_processors) > 0) then

         reset_iterator (my_processors, my_iterator);

         loop
            current_element (my_processors, a_processor, my_iterator);
            if (name = a_processor.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_processor (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_processor_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;

            exit when is_last_element (my_processors, my_iterator);

            next_element (my_processors, my_iterator);
         end loop;
      end if;

      a_mono_core_processor                := new mono_core_processor;
      a_mono_core_processor.core           := a_core;
      a_mono_core_processor.processor_type := monocore_type;
      a_processor := generic_processor_ptr (a_mono_core_processor);
      a_processor.name                     := name;

      add (my_processors, a_processor);

   exception
      when generic_processor_set.full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_processors (Current_Language)));

   end add_processor;

   procedure add_processor
     (my_processors : in out processors_set;
      name          : in     Unbounded_String;
      a_core        : in     core_unit_ptr)
   is
      dummy : generic_processor_ptr;
   begin
      add_processor (my_processors, dummy, name, a_core);
   end add_processor;

   function search_core_unit_by_id
     (my_core_units : in core_units_set;
      id            : in Unbounded_String) return core_unit_ptr
   is
      my_iterator : core_units_iterator;
      a_core_unit : core_unit_ptr;
      result      : core_unit_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_core_units) then

         reset_iterator (my_core_units, my_iterator);

         loop
            current_element (my_core_units, a_core_unit, my_iterator);

            if (a_core_unit.cheddar_private_id = id) then
               found  := True;
               result := a_core_unit;
            end if;

            exit when is_last_element (my_core_units, my_iterator);

            next_element (my_core_units, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (core_unit_not_found'identity,
            To_String (lb_core_unit_id (Current_Language) & "=" & id));
      end if;

      return result;

   end search_core_unit_by_id;

   function search_core_unit
     (my_core_units : in core_units_set;
      name          : in Unbounded_String) return core_unit_ptr
   is
      my_iterator : core_units_iterator;
      a_core_unit : core_unit_ptr;
      result      : core_unit_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_core_units) then

         reset_iterator (my_core_units, my_iterator);

         loop
            current_element (my_core_units, a_core_unit, my_iterator);

            if (a_core_unit.name = name) then
               found  := True;
               result := a_core_unit;
            end if;

            exit when is_last_element (my_core_units, my_iterator);

            next_element (my_core_units, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (core_unit_not_found'identity,
            To_String (lb_core_unit_name (Current_Language) & "=" & name));
      end if;

      return result;

   end search_core_unit;

   function search_processor
     (my_processors : in processors_set;
      name          : in Unbounded_String) return generic_processor_ptr
   is
      my_iterator : processors_iterator;
      a_processor : generic_processor_ptr;
      result      : generic_processor_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_processors) then

         reset_iterator (my_processors, my_iterator);

         loop
            current_element (my_processors, a_processor, my_iterator);

            if (a_processor.name = name) then
               found  := True;
               result := a_processor;
            end if;

            exit when is_last_element (my_processors, my_iterator);

            next_element (my_processors, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (processor_not_found'identity,
            To_String (lb_processor_name (Current_Language) & "=" & name));
      end if;

      return result;

   end search_processor;

   function search_processor_by_id
     (my_processors : in processors_set;
      id            : in Unbounded_String) return generic_processor_ptr
   is
      my_iterator : processors_iterator;
      a_processor : generic_processor_ptr;
      result      : generic_processor_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_processors) then

         reset_iterator (my_processors, my_iterator);

         loop
            current_element (my_processors, a_processor, my_iterator);

            if (a_processor.cheddar_private_id = id) then
               found  := True;
               result := a_processor;
            end if;

            exit when is_last_element (my_processors, my_iterator);

            next_element (my_processors, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (processor_not_found'identity,
            To_String (lb_processor_id (Current_Language) & "=" & id));
      end if;

      return result;

   end search_processor_by_id;

   function processor_is_present
     (my_processors : in processors_set;
      name          : in Unbounded_String) return Boolean
   is
      my_iterator : processors_iterator;
      a_processor : generic_processor_ptr;

      found : Boolean := False;

   begin

      if is_empty (my_processors) then
         return False;
      else
         reset_iterator (my_processors, my_iterator);

         loop
            current_element (my_processors, a_processor, my_iterator);

            if (a_processor.name = name) then
               found := True;
            end if;

            exit when is_last_element (my_processors, my_iterator);

            next_element (my_processors, my_iterator);

         end loop;

         return found;
      end if;

   end processor_is_present;

   function core_is_present
     (my_cores : in core_units_set;
      name     : in Unbounded_String) return Boolean
   is
      my_iterator : core_units_iterator;
      a_core      : core_unit_ptr;

      found : Boolean := False;

   begin

      if is_empty (my_cores) then
         return False;
      else
         reset_iterator (my_cores, my_iterator);

         loop
            current_element (my_cores, a_core, my_iterator);

            if (a_core.name = name) then
               found := True;
            end if;

            exit when is_last_element (my_cores, my_iterator);

            next_element (my_cores, my_iterator);

         end loop;

         return found;
      end if;

   end core_is_present;

   function export_aadl_implementations
     (my_processors : in processors_set) return Unbounded_String
   is
      my_iterator : processors_iterator;
      a_processor : generic_processor_ptr;

      result : Unbounded_String := empty_string;

   begin

      if not is_empty (my_processors) then

         reset_iterator (my_processors, my_iterator);

         loop
            current_element (my_processors, a_processor, my_iterator);

            result :=
              result &
              To_Unbounded_String
                ("processor " & To_String (a_processor.name)) &
              unbounded_lf;

            result :=
              result &
              To_Unbounded_String
                ("end " & To_String (a_processor.name) & ";") &
              unbounded_lf &
              unbounded_lf;

            result :=
              result &
              To_Unbounded_String
                ("processor implementation " &
                 To_String (a_processor.name) &
                 ".Impl") &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String (ASCII.HT & "properties ") &
              unbounded_lf;

            if a_processor.processor_type = monocore_type then
               result :=
                 result &
                 export_aadl_properties
                   (mono_core_processor_ptr (a_processor).core.scheduling,
                    2);
            end if;

            result :=
              result &
              To_Unbounded_String
                ("end " & To_String (a_processor.name) & ".Impl;") &
              unbounded_lf &
              unbounded_lf;

            exit when is_last_element (my_processors, my_iterator);

            next_element (my_processors, my_iterator);

         end loop;

      end if;

      return result;

   end export_aadl_implementations;

   function export_aadl_declarations
     (my_processors : in processors_set;
      number_of_ht  : in Natural) return Unbounded_String
   is
      my_iterator : processors_iterator;
      a_processor : generic_processor_ptr;

      result : Unbounded_String := empty_string;

   begin

      if not is_empty (my_processors) then

         reset_iterator (my_processors, my_iterator);

         loop
            current_element (my_processors, a_processor, my_iterator);

            for i in 1 .. number_of_ht loop
               result := result & ASCII.HT;
            end loop;
            result :=
              result &
              To_Unbounded_String
                ("instancied_" &
                 To_String (a_processor.name) &
                 " : processor " &
                 To_String (a_processor.name) &
                 ".Impl;") &
              unbounded_lf;

            exit when is_last_element (my_processors, my_iterator);

            next_element (my_processors, my_iterator);

         end loop;

      end if;

      return result;

   end export_aadl_declarations;

   function build_core_table
     (a_processor : generic_processor_ptr) return core_units_table
   is
      the_cores : core_units_table;

   begin
      if a_processor.processor_type = monocore_type then
         the_cores.nb_entries  := 1;
         the_cores.entries (0) := mono_core_processor_ptr (a_processor).core;
      else
         the_cores := multi_cores_processor_ptr (a_processor).cores;
      end if;

      return the_cores;
   end build_core_table;

   -- return a core from a processor (any of the core set)
   --
   function get_a_core
     (a_processor : generic_processor_ptr) return core_unit_ptr
   is
   begin
      if a_processor.processor_type = monocore_type then
         return mono_core_processor_ptr (a_processor).core;
      else
         return multi_cores_processor_ptr (a_processor).cores.entries (0);
      end if;
   end get_a_core;

-- Check a monocore processor
--
   procedure check_processor
     (my_processors : in processors_set;
      name          : in Unbounded_String;
      a_core        : in core_unit_ptr)
   is
   begin

      if (name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_processor_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_processor (Current_Language) &
               name &
               " : " &
               lb_processor_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if a_core = null then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_processor (Current_Language) &
               name &
               " : " &
               lb_core_unit (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

   end check_processor;

   -- Check a multicore processor
   --
   procedure check_processor
     (my_processors    : in processors_set;
      name             : in Unbounded_String;
      cores            : in core_units_table;
      a_migration      :    migrations_type;
      a_processor_type :    processors_type)
   is

      first_core : core_unit_ptr;

   begin

      if (name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_processor_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_processor (Current_Language) &
               name &
               " : " &
               lb_processor_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if cores.nb_entries <= 0 then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_processor (Current_Language) &
               name &
               " : " &
               lb_core_unit (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      first_core := cores.entries (0);

      for i in 0 .. cores.nb_entries - 1 loop
         if
           (first_core.scheduling.scheduler_type /=
            cores.entries (i).scheduling.scheduler_type)
         then
            Raise_Exception
              (invalid_parameter'identity,
               To_String
                 (lb_processor (Current_Language) &
                  name &
                  " : " &
                  lb_core_with_same_scheduler (Current_Language)));
         end if;
      end loop;

      for i in 0 .. cores.nb_entries - 1 loop
         if
           (cores.entries (i).scheduling.scheduler_type =
            hierarchical_polling_aperiodic_server_protocol) or
           (cores.entries (i).scheduling.scheduler_type =
            hierarchical_priority_exchange_aperiodic_server_protocol) or
           (cores.entries (i).scheduling.scheduler_type =
            hierarchical_sporadic_aperiodic_server_protocol) or
           (cores.entries (i).scheduling.scheduler_type =
            hierarchical_deferrable_aperiodic_server_protocol)
         then
            Raise_Exception
              (invalid_parameter'identity,
               To_String
                 (lb_processor (Current_Language) &
                  name &
                  " : " &
                  lb_hierarchical_not_allowed (Current_Language)));
         end if;
      end loop;

   end check_processor;

   procedure check_entity_referencing_cache
     (my_cores : in core_units_set;
      a_cache  : in generic_cache_ptr)
   is
      a_core      : core_unit_ptr;
      my_iterator : core_units_iterator;

   begin
      reset_iterator (my_cores, my_iterator);
      if not is_empty (my_cores) then
         loop
            current_element (my_cores, a_core, my_iterator);
            if (a_core.l1_cache_system_name = a_cache.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_core_unit (Current_Language) &
                     " " &
                     a_core.name &
                     " : " &
                     lb_cache (Current_Language) &
                     " " &
                     a_cache.name &
                     " : " &
                     lb_entity_referenced_elsewhere (Current_Language)));
            end if;

            exit when is_last_element (my_cores, my_iterator);
            next_element (my_cores, my_iterator);
         end loop;
      end if;

   end check_entity_referencing_cache;

   procedure check_entity_referencing_cache
     (my_processors : in processors_set;
      a_cache       : in generic_cache_ptr)
   is
      a_processor : generic_processor_ptr;
      my_iterator : processors_iterator;

   begin
      reset_iterator (my_processors, my_iterator);
      if not is_empty (my_processors) then
         loop
            current_element (my_processors, a_processor, my_iterator);
            if (a_processor.processor_type /= monocore_type) then
               if
                 (multi_cores_processor_ptr (a_processor)
                    .l2_cache_system_name =
                  a_cache.name)
               then
                  Raise_Exception
                    (invalid_parameter'identity,
                     To_String
                       (lb_processor (Current_Language) &
                        " " &
                        a_processor.name &
                        " : " &
                        lb_cache (Current_Language) &
                        " " &
                        a_cache.name &
                        " : " &
                        lb_entity_referenced_elsewhere (Current_Language)));
               end if;
            end if;

            exit when is_last_element (my_processors, my_iterator);
            next_element (my_processors, my_iterator);
         end loop;
      end if;

   end check_entity_referencing_cache;

   procedure check_entity_referencing_core_unit
     (my_processors : in processors_set;
      a_core_unit   : in core_unit_ptr)
   is
      a_processor   : generic_processor_ptr;
      my_iterator   : processors_iterator;
      cannot_delete : Boolean := False;

   begin
      reset_iterator (my_processors, my_iterator);
      if not is_empty (my_processors) then
         loop
            current_element (my_processors, a_processor, my_iterator);

            cannot_delete := False;
            if (a_processor.processor_type = monocore_type) then
               if
                 (mono_core_processor_ptr (a_processor).core.name =
                  a_core_unit.name)
               then
                  cannot_delete := True;
               end if;

            else
               for i in
                 0 ..
                     multi_cores_processor_ptr (a_processor).cores.nb_entries -
                     1
               loop
                  if
                    (multi_cores_processor_ptr (a_processor).cores.entries (i)
                       .name =
                     a_core_unit.name)
                  then
                     cannot_delete := True;
                  end if;
               end loop;
            end if;

            if (cannot_delete) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_processor (Current_Language) &
                     " " &
                     a_processor.name &
                     " : " &
                     lb_core_unit (Current_Language) &
                     " " &
                     a_core_unit.name &
                     " : " &
                     lb_entity_referenced_elsewhere (Current_Language)));
            end if;

            exit when is_last_element (my_processors, my_iterator);
            next_element (my_processors, my_iterator);
         end loop;
      end if;

   end check_entity_referencing_core_unit;

   procedure delete_core_unit
     (my_processors : in processors_set;
      a_core_unit   :    core_unit_ptr)
   is
      a_processor : generic_processor_ptr;
      my_iterator : processors_iterator;

   begin

      reset_iterator (my_processors, my_iterator);
      if not is_empty (my_processors) then
         loop
            current_element (my_processors, a_processor, my_iterator);

            if (a_processor.processor_type /= monocore_type) then
               for j in
                 0 ..
                     multi_cores_processor_ptr (a_processor).cores.nb_entries -
                     1
               loop
                  if a_core_unit.name =
                    multi_cores_processor_ptr (a_processor).cores.entries (j)
                      .name
                  then
                     multi_cores_processor_ptr (a_processor).cores.entries
                       (j) :=
                       multi_cores_processor_ptr (a_processor).cores.entries
                         ((multi_cores_processor_ptr (a_processor).cores
                             .nb_entries -
                           1));
                     multi_cores_processor_ptr (a_processor).cores
                       .nb_entries :=
                       multi_cores_processor_ptr (a_processor).cores
                         .nb_entries -
                       1;
                     exit;
                  end if;
               end loop;
            end if;

            exit when is_last_element (my_processors, my_iterator);
            next_element (my_processors, my_iterator);
         end loop;
      end if;
   end delete_core_unit;

end processor_set;
