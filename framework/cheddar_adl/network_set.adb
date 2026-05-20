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

with unbounded_strings;    use unbounded_strings;
with Ada.Exceptions;       use Ada.Exceptions;
with translate;            use translate;
with initialize_framework; use initialize_framework;
with Objects.extended;     use Objects.extended;

package body network_set is

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
      processor_positions       : in positions_table     := no_position)
   is

   begin

      if name = "" then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_network_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_network (Current_Language) &
               " " &
               name &
               " : " &
               lb_network_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if (link_delay < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_network (Current_Language) &
               " " &
               name &
               " : link_delay " &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (number_of_processor < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_network (Current_Language) &
               " " &
               name &
               " : number_of_processor " &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (dimension < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_network (Current_Language) &
               " " &
               name &
               " : dimension " &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (number_of_virtual_channel < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_network (Current_Language) &
               " " &
               name &
               " : number_of_virtual_channel " &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (xdimension < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_network (Current_Language) &
               " " &
               name &
               " : Xdimension " &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (ydimension < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_network (Current_Language) &
               " " &
               name &
               " : Ydimension " &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

   end check_network;

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
      processor_positions       : in     positions_table     := no_position)
   is

      dummy : generic_network_ptr;
   begin
      add_network
        (my_networks,
         dummy,
         name,
         network_architecture_type,
         topology,
         link_delay,
         number_of_processor,
         dimension,
         xdimension,
         ydimension,
         number_of_virtual_channel,
         network_delay,
         switching_protocol,
         routing_protocol,
         processor_positions);
   end add_network;

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
      processor_positions       : in     positions_table     := no_position)
   is

      my_iterator           : iterator;
      new_noc_network       : noc_network_ptr;
      new_bus_network       : bus_network_ptr;
      new_spacewire_network : spacewire_network_ptr;

   begin

      check_initialize;

      check_network
        (my_networks,
         name,
         network_architecture_type,
         topology,
         link_delay,
         number_of_processor,
         dimension,
         xdimension,
         ydimension,
         number_of_virtual_channel,
         network_delay,
         switching_protocol,
         routing_protocol,
         processor_positions);

      if (get_number_of_elements (my_networks) > 0) then
         reset_iterator (my_networks, my_iterator);

         loop
            current_element (my_networks, a_network, my_iterator);

            if (name = a_network.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_network (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_network_name (Current_Language) &
                     lb_already_defined (Current_Language)));

            end if;

            exit when is_last_element (my_networks, my_iterator);

            next_element (my_networks, my_iterator);

         end loop;
      end if;

      check_network
        (my_networks,
         name,
         network_architecture_type,
         topology,
         link_delay,
         number_of_processor,
         dimension,
         xdimension,
         ydimension,
         number_of_virtual_channel,
         network_delay,
         switching_protocol,
         routing_protocol,
         processor_positions);

      case network_architecture_type is
         when shared_bus | crossbar | star | point_to_point_link =>
            new_bus_network := new bus_network;
            a_network       := generic_network_ptr (new_bus_network);
         when noc =>
            new_noc_network                           := new noc_network;
            new_noc_network.routing_protocol          := routing_protocol;
            new_noc_network.link_delay                := link_delay;
            new_noc_network.switching_protocol        := switching_protocol;
            new_noc_network.dimension                 := dimension;
            new_noc_network.topology                  := topology;
            new_noc_network.number_of_processor       := number_of_processor;
            new_noc_network.number_of_virtual_channel :=
              number_of_virtual_channel;
            new_noc_network.processor_positions := processor_positions;
            a_network := generic_network_ptr (new_noc_network);
         when spacewire =>
            new_spacewire_network                     := new spacewire_network;
            new_spacewire_network.Xdimension          := xdimension;
            new_spacewire_network.Ydimension          := ydimension;
            new_spacewire_network.routing_protocol    := routing_protocol;
            new_spacewire_network.number_of_processor := number_of_processor;
            new_spacewire_network.link_delay          := link_delay;
            new_spacewire_network.processor_positions := processor_positions;
            a_network := generic_network_ptr (new_spacewire_network);

      end case;

      a_network.name                      := name;
      a_network.network_architecture_type := network_architecture_type;
      a_network.network_delay             := network_delay;

      add (my_networks, a_network);

   exception
      when generic_network_set.full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_networks (Current_Language)));

   end add_network;

   procedure update_network
     (my_networks  : in out networks_set;
      name         : in     Unbounded_String;
      network_type : in     networks_architecture_type)
   is

      a_network : generic_network_ptr;

   begin

      a_network := search_network (my_networks, name);
      delete (my_networks, a_network);
      add_network (my_networks, name, network_type);

   end update_network;

   function search_network
     (my_networks : in networks_set;
      name        : in Unbounded_String) return generic_network_ptr
   is
      my_iterator : iterator;
      a_network   : generic_network_ptr;
      result      : generic_network_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_networks) then
         reset_iterator (my_networks, my_iterator);

         loop
            current_element (my_networks, a_network, my_iterator);

            if (a_network.name = name) then
               found  := True;
               result := a_network;
            end if;

            exit when is_last_element (my_networks, my_iterator);

            next_element (my_networks, my_iterator);

         end loop;
      end if;

      if not found then
         Raise_Exception
           (network_not_found'identity,
            To_String (lb_name (Current_Language) & " = " & name));
      end if;

      return result;

   end search_network;

   function export_aadl_implementations
     (my_networks : in networks_set) return Unbounded_String
   is
      my_iterator : iterator;
      a_network   : generic_network_ptr;

      result : Unbounded_String := empty_string;

   begin

      if not is_empty (my_networks) then

         reset_iterator (my_networks, my_iterator);

         loop
            current_element (my_networks, a_network, my_iterator);
            exit when is_last_element (my_networks, my_iterator);

            result :=
              result &
              To_Unbounded_String ("bus " & To_String (a_network.name));
            result :=
              result &
              To_Unbounded_String ("end " & To_String (a_network.name) & ";");

            result :=
              result &
              To_Unbounded_String
                ("bus implementation " & To_String (a_network.name) & ".Impl");
            result :=
              result &
              To_Unbounded_String
                ("end " & To_String (a_network.name) & ".Impl");

            next_element (my_networks, my_iterator);

         end loop;
      end if;

      return result;

   end export_aadl_implementations;

   function export_aadl_declarations
     (my_networks  : in networks_set;
      number_of_ht : in Natural) return Unbounded_String
   is
      my_iterator : iterator;
      a_network   : generic_network_ptr;

      result : Unbounded_String := empty_string;

   begin

      if not is_empty (my_networks) then

         reset_iterator (my_networks, my_iterator);

         loop
            current_element (my_networks, a_network, my_iterator);
            exit when is_last_element (my_networks, my_iterator);

            for i in 1 .. number_of_ht loop
               result := result & ASCII.HT;
            end loop;
            result :=
              result &
              To_Unbounded_String
                ("instancied_" &
                 To_String (a_network.name) &
                 " : bus " &
                 To_String (a_network.name) &
                 ".Impl;");

            next_element (my_networks, my_iterator);

         end loop;
      end if;

      return result;

   end export_aadl_declarations;

end network_set;
