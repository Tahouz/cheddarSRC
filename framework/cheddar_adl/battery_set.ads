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
--    $Rev: 4713 $
--    $Date: 2023-12-18 00:02:03 +0100 (lun., 18 déc. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Framework_Config;      use Framework_Config;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Batteries;             use Batteries;
with sets;

package battery_set is

   ----------------------------------------------------------
   -- Definition of a set
   ----------------------------------------------------------

   package generic_battery_set is new sets
     (max_element    => Framework_Config.Max_Batteries, element => battery_ptr,
      free => Free, copy => Copy, put => Put, xml_string => XML_String,
      xml_ref_string => XML_Ref_String);
   use generic_battery_set;

   type batteries_set is new generic_battery_set.set with private;

   subtype batteries_range is generic_battery_set.element_range;
   subtype batteries_iterator is generic_battery_set.iterator;

   ----------------------------------------------------------
   -- Exceptions defined in the set package
   ----------------------------------------------------------

   -- Raised when a given buffer is not in a set
   --
   battery_not_found : exception;

   -- Raised when parameters provided to Add_battery are wrong
   --
   invalid_parameter : exception;

   ----------------------------------------------------------
   -- Procedure to proceed modification on a set
   ----------------------------------------------------------

   procedure check_battery
     (my_batteries       : in batteries_set; name : in Unbounded_String;
      cpu_name           : in Unbounded_String; capacity : in Integer;
      e_max : in Integer; e_min : in Integer; initial_energy : in Integer;
      rechargeable_power : in Integer);

   procedure add_battery
     (my_batteries   : in out batteries_set; a_battery : in out battery_ptr;
      name           : in     Unbounded_String; cpu_name : in Unbounded_String;
      capacity       : in     Integer; e_max : in Integer; e_min : in Integer;
      initial_energy : in     Integer; rechargeable_power : in Integer);

   procedure add_battery
     (my_batteries       : in out batteries_set; name : in Unbounded_String;
      cpu_name           : in     Unbounded_String; capacity : in Integer;
      e_max : in     Integer; e_min : in Integer; initial_energy : in Integer;
      rechargeable_power : in     Integer);

   function search_battery
     (my_batteries : in batteries_set; name : in Unbounded_String)
      return battery_ptr;

private

   type batteries_set is new generic_battery_set.set with null record;

end battery_set;
