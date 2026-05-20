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

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Framework_Config;      use Framework_Config;
with Resources;             use Resources;
use Resources.Resource_Accesses;
with sets;

package resource_set is

   ----------------------------------------------------------
   -- Definition of a shared resource set
   ----------------------------------------------------------

   package generic_resource_set is new sets
     (max_element    => Framework_Config.Max_Resources,
      element        => generic_resource_ptr,
      free           => Free,
      copy           => Copy,
      put            => Put,
      xml_string     => XML_String,
      xml_ref_string => XML_Ref_String);

   use generic_resource_set;

   type resources_set is new generic_resource_set.set with private;

   subtype resources_range is generic_resource_set.element_range;
   subtype resources_iterator is generic_resource_set.iterator;

   ----------------------------------------------------------
   -- Exceptions defined in the resource set package
   ----------------------------------------------------------

   -- Try to get/set a unkwon parameter
   --
   invalid_parameter : exception;

   -- The the resource name does ot exist in the set
   --
   resource_not_found : exception;

   -- all the resource  accessed by a task should have
   -- the same protocol type
   --
   can_not_used_different_protocol : exception;

   ----------------------------------------------------------
   -- I/O operations
   ----------------------------------------------------------

   function export_aadl_implementations
     (my_resources : in resources_set) return Unbounded_String;

   function export_aadl_declarations
     (my_resources       : in resources_set;
      address_space_name : in Unbounded_String;
      number_of_ht       : in Natural) return Unbounded_String;

   function export_aadl_connections
     (my_resources : in resources_set;
      a_task_name  : in Unbounded_String;
      number_of_ht : in Natural) return Unbounded_String;

   ----------------------------------------------------------
   -- Procedure to perform modification on a set
   ----------------------------------------------------------

   procedure update_resource
     (my_resources        : in out resources_set;
      name                : in     Unbounded_String;
      state               : in     Integer;
      address             : in     Integer;
      size                : in     Integer;
      cpu_name            : in     Unbounded_String;
      address_space_name  : in     Unbounded_String;
      protocol            : in     resources_type;
      affected_tasks      : in     resource_accesses_table;
      priority            : in     Integer;
      priority_assignment : in     priority_assignment_type);

   procedure check_resource
     (my_resources       : in resources_set;
      name               : in Unbounded_String;
      state              : in Integer;
      address            : in Integer;
      size               : in Integer;
      cpu_name           : in Unbounded_String;
      address_space_name : in Unbounded_String;
      protocol           : in resources_type;
      priority           : in Integer);

   procedure add_resource
     (my_resources        : in out resources_set;
      name                : in     Unbounded_String;
      state               : in     Integer;
      address             : in     Integer;
      size                : in     Integer;
      cpu_name            : in     Unbounded_String;
      address_space_name  : in     Unbounded_String;
      protocol            : in     resources_type;
      affected_tasks      : in     resource_accesses_table;
      priority            : in     Integer;
      priority_assignment : in     priority_assignment_type);

   procedure add_resource
     (my_resources        : in out resources_set;
      a_resource          : in out generic_resource_ptr;
      name                : in     Unbounded_String;
      state               : in     Integer;
      address             : in     Integer;
      size                : in     Integer;
      cpu_name            : in     Unbounded_String;
      address_space_name  : in     Unbounded_String;
      protocol            : in     resources_type;
      affected_tasks      : in     resource_accesses_table;
      priority            : in     Integer;
      priority_assignment : in     priority_assignment_type);

   -- Search for resources referencing an address space
   --
   procedure check_entity_referencing_address_space
     (my_resources : in resources_set;
      a_addr       : in Unbounded_String);
   procedure check_entity_referencing_processor
     (my_resources : in resources_set;
      a_processor  : in Unbounded_String);
   procedure check_entity_referencing_task
     (my_resources : in resources_set;
      a_task       : in Unbounded_String);

-- Delete all resources that are used by the task 'a_task'
--
   procedure delete_task
     (my_resources : in out resources_set;
      a_task       : in     Unbounded_String);

-- Delete all resources that are located on the address space 'a_addr'
--
   procedure delete_address_space
     (my_resources : in out resources_set;
      a_addr       : in     Unbounded_String);

-- Delete all resources that are located on the processor 'a_processor'
--
   procedure delete_processor
     (my_resources : in out resources_set;
      a_processor  : in     Unbounded_String);

   ------------------------------------------------------
   -- Read information from a set
   ------------------------------------------------------

   -- Get the number of tasks hosted by the
   -- processor "Processor_Name"
   --
   function get_number_of_resource_from_processor
     (my_resources   : in resources_set;
      processor_name : in Unbounded_String) return resources_range;

   -- Get the resource pointer of the resource named "Name"
   --
   function search_resource
     (my_resources : in resources_set;
      name         : in Unbounded_String) return generic_resource_ptr;

   -- SR append for binding
   function resource_is_present
     (my_resources : in resources_set;
      name         : in Unbounded_String) return Boolean;

   function search_resource_by_id
     (my_resources : in resources_set;
      id           : in Unbounded_String) return generic_resource_ptr;

   --------------------------------------------------------
   -- Functions to perform sort on a set
   --------------------------------------------------------

   procedure same_protocol_control
     (my_resources : in resources_set;
      a_task       : in Unbounded_String);

private

   type resources_set is new generic_resource_set.set with null record;

end resource_set;
