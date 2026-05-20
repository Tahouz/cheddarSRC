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

with Address_Spaces;        use Address_Spaces;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
with Framework_Config;      use Framework_Config;
with Scheduler_Interface;   use Scheduler_Interface;
with task_set;              use task_set;
with resource_set;          use resource_set;
with MILS_Security;         use MILS_Security;
with sets;

package address_space_set is

   ----------------------------------------------------------
   -- Definition of a set
   ----------------------------------------------------------

   package generic_address_space_set is new sets
     (max_element    => Framework_Config.Max_Address_Spaces,
      element        => address_space_ptr,
      free           => Free,
      copy           => Copy,
      put            => Put,
      xml_string     => XML_String,
      xml_ref_string => XML_Ref_String);

   use generic_address_space_set;

   type address_spaces_set is new generic_address_space_set.set with private;

   subtype address_spaces_range is generic_address_space_set.element_range;
   subtype address_spaces_iterator is generic_address_space_set.iterator;

   ----------------------------------------------------------
   -- Exceptions defined in the set package
   ----------------------------------------------------------

   -- Raised when a given address space is not in a address space set
   --
   address_space_not_found : exception;

   -- Raised when parameters provided to Add_Address_Space are wrong
   --
   invalid_parameter : exception;

   ----------------------------------------------------------
   -- I/O operations
   ----------------------------------------------------------
   function export_aadl_declarations
     (my_address_spaces : in address_spaces_set;
      number_of_ht      : in Natural) return Unbounded_String;

   function export_aadl_implementations
     (my_address_spaces : in address_spaces_set;
      my_tasks          : in tasks_set;
      my_resources      : in resources_set) return Unbounded_String;

   function export_aadl_properties
     (my_address_spaces : in address_spaces_set;
      number_of_ht      : in Natural) return Unbounded_String;

   ----------------------------------------------------------
   -- Procedure to proceed modification on a set
   ----------------------------------------------------------

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
      mils_compliant       : in Boolean                   := True);

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
      mils_compliant       : in Boolean                   := True);

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
      mils_compliant       : in Boolean                   := True);

   -- Search for task groups referencing an address space
   --
   procedure check_entity_referencing_processor
     (my_address_spaces : in address_spaces_set;
      a_processor       : in Unbounded_String);

-- Delete all address spaces located on 'A_Processor'
--
   procedure delete_processor
     (my_address_spaces : in out address_spaces_set;
      a_processor       : in     Unbounded_String);

   ------------------------------------------------------
   -- Read information from a set
   ------------------------------------------------------

   function search_address_space
     (my_address_spaces : in address_spaces_set;
      name              : in Unbounded_String) return address_space_ptr;
   function search_address_space_by_id
     (my_address_spaces : in address_spaces_set;
      id                : in Unbounded_String) return address_space_ptr;

   function address_space_is_present
     (my_address_spaces : in address_spaces_set;
      name              : in Unbounded_String) return Boolean;

private

   type address_spaces_set is new generic_address_space_set.set with
   null record;

end address_space_set;
