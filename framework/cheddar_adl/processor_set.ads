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

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with unbounded_strings;     use unbounded_strings;
with Framework_Config;      use Framework_Config;
with Scheduler_Interface;   use Scheduler_Interface;
with Processors;            use Processors;
with Memories;              use Memories;
use Memories.Memories_Table_Package;
with Memory_set;              use Memory_set;
with Core_Units;            use Core_Units;
with Processor_Interface;   use Processor_Interface;
with Caches;                use Caches;
with Doubles;               use Doubles;

with sets;


package processor_set is

   ----------------------------------------------------------
   -- Definition of a set
   ----------------------------------------------------------

   package generic_processor_set is new sets
     (max_element    => Framework_Config.Max_Processors,
      element        => generic_processor_ptr,
      free           => Free,
      copy           => Copy,
      put            => Put,
      xml_string     => XML_String,
      xml_ref_string => XML_Ref_String);

   use generic_processor_set;

   type processors_set is new generic_processor_set.set with private;

   subtype processors_range is generic_processor_set.element_range;
   subtype processors_iterator is generic_processor_set.iterator;

   package generic_core_unit_set is new sets
     (max_element    => Framework_Config.Max_Core_Units,
      element        => core_unit_ptr,
      free           => Free,
      copy           => Copy,
      put            => Put,
      xml_string     => XML_String,
      xml_ref_string => XML_Ref_String);

   use generic_core_unit_set;

   type core_units_set is new generic_core_unit_set.set with private;

   subtype core_units_range is generic_core_unit_set.element_range;
   subtype core_units_iterator is generic_core_unit_set.iterator;

   ----------------------------------------------------------
   -- Exceptions defined in the set package
   ----------------------------------------------------------

   -- Raised when a given processor/core unit is not in a processor/core unit
   --set
   --
   processor_not_found : exception;
   core_unit_not_found : exception;

   -- Raised when parameters provided to Add_processor are wrong
   --
   invalid_parameter : exception;

   -- Raised when the scheduler code of a parametric scheduler
   -- does not have a right syntax
   --
   scheduler_syntax_error : exception;

   ----------------------------------------------------------
   -- I/O operations
   ----------------------------------------------------------

   function export_aadl_implementations
     (my_processors : in processors_set) return Unbounded_String;

   function export_aadl_declarations
     (my_processors : in processors_set;
      number_of_ht  : in Natural) return Unbounded_String;

   ----------------------------------------------------------
   -- Procedure to proceed modification on a set
   ----------------------------------------------------------

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
      threshold      : in Integer          := 0);

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
      threshold                : in     Integer          := 0);

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
      threshold                : in     Integer          := 0);
      
   

   --------------------------------------------

   -- Create a monocore processor
   --
   procedure add_processor
     (my_processors : in out processors_set;
      a_processor   : in out generic_processor_ptr;
      name          : in     Unbounded_String;
      a_core        : in     core_unit_ptr);

   procedure add_processor
     (my_processors : in out processors_set;
      name          : in     Unbounded_String;
      a_core        : in     core_unit_ptr);

   -- Check a monocore processor
   --
   procedure check_processor
     (my_processors : in processors_set;
      name          : in Unbounded_String;
      a_core        : in core_unit_ptr);

   -- Create a multicore processor
   --
   procedure add_processor
     (my_processors    : in out processors_set;
      a_processor      : in out generic_processor_ptr;
      name             : in     Unbounded_String;
      cores            : in     core_units_table;
      a_migration      :        migrations_type := job_level_migration_type;
      a_processor_type :        processors_type := identical_multicores_type);

   procedure add_processor
     (my_processors    : in out processors_set;
      name             : in     Unbounded_String;
      cores            : in     core_units_table;
      a_migration      :        migrations_type := job_level_migration_type;
      a_processor_type :        processors_type := identical_multicores_type);

   -- Check a multicore processor
   --
   procedure check_processor
     (my_processors    : in processors_set;
      name             : in Unbounded_String;
      cores            : in core_units_table;
      a_migration      :    migrations_type;
      a_processor_type :    processors_type);

   -- Check if processor entities make references to core or
   --
   procedure check_entity_referencing_core_unit
     (my_processors : in processors_set;
      a_core_unit   : in core_unit_ptr);
   procedure check_entity_referencing_cache
     (my_processors : in processors_set;
      a_cache       : in generic_cache_ptr);
   procedure check_entity_referencing_cache
     (my_cores : in core_units_set;
      a_cache  : in generic_cache_ptr);

---------------------------------------------
--  Delete subprograms
---------------------------------------------

   -- Delete all processors using the core 'a_core_unit'
   --
   procedure delete_core_unit
     (my_processors : in processors_set;
      a_core_unit   : in core_unit_ptr);

---------------------------------------------------------------
--  subprograms to handle cores of processors
---------------------------------------------------------------

   -- return a core from a processor (any of the core set)
   --
   function get_a_core
     (a_processor : generic_processor_ptr) return core_unit_ptr;

   -- build a table of core units for any processor type (both monocore or
   -- multicore)
   --
   function build_core_table
     (a_processor : generic_processor_ptr) return core_units_table;

   ------------------------------------------------------
   -- Read information from a set
   ------------------------------------------------------

   -- Get the processor pointer of the processor named "Name"
   --
   function search_processor
     (my_processors : in processors_set;
      name          : in Unbounded_String) return generic_processor_ptr;

   -- Get the core unit pointer of the core unit named "Name"
   --
   function search_core_unit
     (my_core_units : in core_units_set;
      name          : in Unbounded_String) return core_unit_ptr;

   -- Get the core unit pointer of the core unit with a given id
   --
   function search_core_unit_by_id
     (my_core_units : in core_units_set;
      id            : in Unbounded_String) return core_unit_ptr;

   -- Get the processor with a given id
   --
   function search_processor_by_id
     (my_processors : in processors_set;
      id            : in Unbounded_String) return generic_processor_ptr;

   function processor_is_present
     (my_processors : in processors_set;
      name          : in Unbounded_String) return Boolean;

   function core_is_present
     (my_cores : in core_units_set;
      name     : in Unbounded_String) return Boolean;

private

   type processors_set is new generic_processor_set.set with null record;
   type core_units_set is new generic_core_unit_set.set with null record;

end processor_set;
