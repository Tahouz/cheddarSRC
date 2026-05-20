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

with Framework_Config;      use Framework_Config;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Buffers;               use Buffers;
with Queueing_Systems;      use Queueing_Systems;
use Buffers.Buffer_Roles_Package;
with sets;

package buffer_set is

   ----------------------------------------------------------
   -- Definition of a set
   ----------------------------------------------------------

   package generic_buffer_set is new sets
     (max_element    => Framework_Config.Max_Buffers,
      element        => buffer_ptr,
      free           => Free,
      copy           => Copy,
      put            => Put,
      xml_string     => XML_String,
      xml_ref_string => XML_Ref_String);
   use generic_buffer_set;

   type buffers_set is new generic_buffer_set.set with private;

   subtype buffers_range is generic_buffer_set.element_range;
   subtype buffers_iterator is generic_buffer_set.iterator;

   ----------------------------------------------------------
   -- Exceptions defined in the set package
   ----------------------------------------------------------

   -- Raised when a given buffer is not in a buffer set
   --
   buffer_not_found : exception;

   -- Raised when parameters provided to Add_buffer are wrong
   --
   invalid_parameter : exception;

   ----------------------------------------------------------
   -- I/O operations
   ----------------------------------------------------------

   function export_aadl_implementations
     (my_buffers : in buffers_set) return Unbounded_String;

   ----------------------------------------------------------
   -- Procedure to proceed modification on a set
   ----------------------------------------------------------

   procedure check_buffer
     (my_buffers         : in buffers_set;
      name               : in Unbounded_String;
      size               : in Integer;
      cpu_name           : in Unbounded_String;
      address_space_name : in Unbounded_String);

   procedure add_buffer
     (my_buffers         : in out buffers_set;
      a_buffer           : in out buffer_ptr;
      name               : in     Unbounded_String;
      size               : in     Integer;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      a_qs               : in     queueing_systems_type;
      roles              : in     buffer_roles_table;
      initial_data       : in     Integer := 0);

   procedure add_buffer
     (my_buffers         : in out buffers_set;
      name               : in     Unbounded_String;
      size               : in     Integer;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      a_qs               : in     queueing_systems_type;
      roles              : in     buffer_roles_table;
      initial_data       : in     Integer := 0);

   procedure update_buffer
     (my_buffers         : in out buffers_set;
      name               : in     Unbounded_String;
      new_name           : in     Unbounded_String;
      size               : in     Integer;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      roles              : in     buffer_roles_table;
      initial_data       : in     Integer := 0);

   -- Search for buffers referencing an address space
   --
   procedure check_entity_referencing_address_space
     (my_buffers : in buffers_set;
      a_addr     : in Unbounded_String);
   procedure check_entity_referencing_processor
     (my_buffers  : in buffers_set;
      a_processor : in Unbounded_String);
   procedure check_entity_referencing_task
     (my_buffers : in buffers_set;
      a_task     : in Unbounded_String);

-- Delete all buffers located on the address space 'A_Addr'
--
   procedure delete_address_space
     (my_buffers : in out buffers_set;
      a_addr     : in     Unbounded_String);

-- Delete all buffers used by 'A_Task'
--
   procedure delete_task
     (my_buffers : in out buffers_set;
      a_task     : in     Unbounded_String);

-- Delete all buffers located on the processor 'A_Processor'
--
   procedure delete_processor
     (my_buffers  : in out buffers_set;
      a_processor : in     Unbounded_String);

   ------------------------------------------------------
   -- Read information from a set
   ------------------------------------------------------

   function search_buffer
     (my_buffers : in buffers_set;
      name       : in Unbounded_String) return buffer_ptr;

   function search_buffer_by_id
     (my_buffers : in buffers_set;
      id         : in Unbounded_String) return buffer_ptr;

   function get_number_of_buffer_from_processor
     (my_buffers     : in buffers_set;
      processor_name : in Unbounded_String) return buffers_range;

   ----------------------------------------------------------
   -- List of parameters the user can set of get directly
   -- throught the set
   ----------------------------------------------------------

   type buffer_parameters is (size, cpu_name, address_space_name, roles);

   function get
     (my_buffers  : in buffers_set;
      buffer_name : in Unbounded_String;
      param_name  : in buffer_parameters) return Unbounded_String;

   procedure set
     (my_buffers  : in out buffers_set;
      buffer_name : in     Unbounded_String;
      param_name  : in     buffer_parameters;
      param_value : in     Unbounded_String);

   function get
     (my_buffers  : in buffers_set;
      buffer_name : in Unbounded_String;
      param_name  : in buffer_parameters) return Natural;

   procedure set
     (my_buffers  : in out buffers_set;
      buffer_name : in     Unbounded_String;
      param_name  : in     buffer_parameters;
      param_value : in     Natural);

private

   type buffers_set is new generic_buffer_set.set with null record;

end buffer_set;
