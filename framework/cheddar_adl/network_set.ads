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

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Framework_Config;      use Framework_Config;
with Networks;              use Networks;
with sets;

package network_set is

   ----------------------------------------------------------
   -- Definition of a set
   ----------------------------------------------------------

   package generic_network_set is new sets
     (max_element    => Framework_Config.Max_Networks,
      element        => generic_network_ptr,
      free           => Free,
      copy           => Copy,
      put            => Put,
      xml_ref_string => XML_Ref_String,
      xml_string     => XML_String);
   use generic_network_set;

   type networks_set is new generic_network_set.set with private;

   subtype networks_range is generic_network_set.element_range;
   subtype networks_iterator is generic_network_set.iterator;

   ----------------------------------------------------------
   -- Exceptions defined in the set package
   ----------------------------------------------------------

   -- Raised when a given network is not in a network set
   --
   network_not_found : exception;

   -- Raised when parameters provided to Add_network are wrong
   --
   invalid_parameter : exception;

   ----------------------------------------------------------
   -- Table without any processor position
   ----------------------------------------------------------

   no_position : positions_table;

   ----------------------------------------------------------
   -- I/O operations
   ----------------------------------------------------------
   function export_aadl_implementations
     (my_networks : in networks_set) return Unbounded_String;

   function export_aadl_declarations
     (my_networks  : in networks_set;
      number_of_ht : in Natural) return Unbounded_String;

   ----------------------------------------------------------
   -- Procedure to proceed modification on a set
   ----------------------------------------------------------

   procedure check_network
     (my_networks               : in networks_set;
      name                      : in Unbounded_String;
      network_architecture_type : in networks_architecture_type;
      topology                  : in topology_type       := mesh_topology;
      link_delay                : in Integer             := 0;
      number_of_processor       : in Integer             := 0;
      dimension                 : in Integer             := 0;
      xdimension                : in Integer             := 0;
      ydimension                : in Integer             := 0;
      number_of_virtual_channel : in Integer             := 0;
      network_delay             : in networks_delay_type := bounded_delay;
      switching_protocol        : in switching_type      := wormwole;
      routing_protocol          : in routing_type        := xy;
      processor_positions       : in positions_table     := no_position);

   procedure update_network
     (my_networks  : in out networks_set;
      name         : in     Unbounded_String;
      network_type : in     networks_architecture_type);

   procedure add_network
     (my_networks               : in out networks_set;
      name                      : in     Unbounded_String;
      network_architecture_type : in     networks_architecture_type;
      topology                  : in     topology_type       := mesh_topology;
      link_delay                : in     Integer             := 0;
      number_of_processor       : in     Integer             := 0;
      dimension                 : in     Integer             := 0;
      xdimension                : in     Integer             := 0;
      ydimension                : in     Integer             := 0;
      number_of_virtual_channel : in     Integer             := 0;
      network_delay             : in     networks_delay_type := bounded_delay;
      switching_protocol        : in     switching_type      := wormwole;
      routing_protocol          : in     routing_type        := xy;
      processor_positions       : in     positions_table     := no_position);

   procedure add_network
     (my_networks               : in out networks_set;
      a_network                 :    out generic_network_ptr;
      name                      : in     Unbounded_String;
      network_architecture_type : in     networks_architecture_type;
      topology                  : in     topology_type       := mesh_topology;
      link_delay                : in     Integer             := 0;
      number_of_processor       : in     Integer             := 0;
      dimension                 : in     Integer             := 0;
      xdimension                : in     Integer             := 0;
      ydimension                : in     Integer             := 0;
      number_of_virtual_channel : in     Integer             := 0;
      network_delay             : in     networks_delay_type := bounded_delay;
      switching_protocol        : in     switching_type      := wormwole;
      routing_protocol          : in     routing_type        := xy;
      processor_positions       : in     positions_table     := no_position);

   ------------------------------------------------------
   -- Read information from a set
   ------------------------------------------------------

   function search_network
     (my_networks : in networks_set;
      name        : in Unbounded_String) return generic_network_ptr;

private

   type networks_set is new generic_network_set.set with null record;

end network_set;
