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

with Ada.Exceptions;       use Ada.Exceptions;
with translate;            use translate;
with Objects;              use Objects;
with Objects.extended;     use Objects.extended;
with unbounded_strings;    use unbounded_strings;
with initialize_framework; use initialize_framework;
with debug;                use debug;

package body battery_set is

   procedure add_battery
     (my_batteries       : in out batteries_set; name : in Unbounded_String;
      cpu_name           : in     Unbounded_String; capacity : in Integer;
      e_max : in     Integer; e_min : in Integer; initial_energy : in Integer;
      rechargeable_power : in     Integer)

   is

      dummy : battery_ptr;

   begin
      add_battery
        (my_batteries, dummy, name, cpu_name, capacity, e_max, e_min,
         initial_energy, rechargeable_power);
   end add_battery;

   procedure check_battery
     (my_batteries       : in batteries_set; name : in Unbounded_String;
      cpu_name           : in Unbounded_String; capacity : in Integer;
      e_max : in Integer; e_min : in Integer; initial_energy : in Integer;
      rechargeable_power : in Integer)
   is

   begin

      if (name = "") then
         Raise_Exception
           (invalid_parameter'Identity,
            To_String
              (lb_battery_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'Identity,
            To_String
              (lb_battery (Current_Language) & " " & name & " : " &
               lb_battery_name (Current_Language) & lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if (cpu_name = "") then
         Raise_Exception
           (invalid_parameter'Identity,
            To_String
              (lb_battery (Current_Language) & " " & name & " : " &
               lb_processor_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (cpu_name) then
         Raise_Exception
           (invalid_parameter'Identity,
            To_String
              (lb_battery (Current_Language) & name & " : " &
               lb_processor_name (Current_Language) & lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if (rechargeable_power <= 0) then
         Raise_Exception
           (invalid_parameter'Identity,
            To_String
              (lb_battery (Current_Language) & " " & name & " : " &
               lb_rechargeable_power (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_than (Current_Language) & "0"));
      end if;

      if (initial_energy < 0) then
         Raise_Exception
           (invalid_parameter'Identity,
            To_String
              (lb_battery (Current_Language) & " " & name &
               " : initial_energy " & lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) & "0"));
      end if;

      if (e_max < 0) then
         Raise_Exception
           (invalid_parameter'Identity,
            To_String
              (lb_battery (Current_Language) & " " & name & " : e_max " &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) & "0"));
      end if;

      if (e_min < 0) then
         Raise_Exception
           (invalid_parameter'Identity,
            To_String
              (lb_battery (Current_Language) & " " & name & " : e_min " &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) & "0"));
      end if;

      if (capacity <= 0) then
         Raise_Exception
           (invalid_parameter'Identity,
            To_String
              (lb_battery (Current_Language) & " " & name & " : " &
               lb_capacity (Current_Language) & lb_must_be (Current_Language) &
               lb_greater_than (Current_Language) & "0"));
      end if;

   end check_battery;

   procedure add_battery
     (my_batteries   : in out batteries_set; a_battery : in out battery_ptr;
      name           : in     Unbounded_String; cpu_name : in Unbounded_String;
      capacity       : in     Integer; e_max : in Integer; e_min : in Integer;
      initial_energy : in     Integer; rechargeable_power : in Integer)
   is

      my_iterator : iterator;

   begin

      check_initialize;

      check_battery
        (my_batteries, name, cpu_name, capacity, e_max, e_min, initial_energy,
         rechargeable_power);

      if (get_number_of_elements (my_batteries) > 0) then

         reset_iterator (my_batteries, my_iterator);

         loop
            current_element (my_batteries, a_battery, my_iterator);
            if (name = a_battery.name) then
               Raise_Exception
                 (invalid_parameter'Identity,
                  To_String
                    (lb_battery (Current_Language) & " " & name & " : " &
                     lb_battery_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;

            exit when is_last_element (my_batteries, my_iterator);

            next_element (my_batteries, my_iterator);
         end loop;
      end if;

      a_battery                    := new battery;
      a_battery.name               := name;
      a_battery.cpu_name           := cpu_name;
      a_battery.capacity           := capacity;
      a_battery.e_max              := e_max;
      a_battery.e_min              := e_min;
      a_battery.initial_energy     := initial_energy;
      a_battery.rechargeable_power := rechargeable_power;
      add (my_batteries, a_battery);

   exception
      when full_set =>
         Raise_Exception
           (invalid_parameter'Identity,
            To_String (lb_can_not_define_more_batteries (Current_Language)));

   end add_battery;

   function search_battery
     (my_batteries : in batteries_set; name : in Unbounded_String)
      return battery_ptr
   is

      my_iterator : batteries_iterator;
      a_battery   : battery_ptr;
      result      : battery_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_batteries) then

         reset_iterator (my_batteries, my_iterator);

         loop
            current_element (my_batteries, a_battery, my_iterator);

            if (a_battery.name = name) then
               found  := True;
               result := a_battery;
            end if;

            exit when is_last_element (my_batteries, my_iterator);

            next_element (my_batteries, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (battery_not_found'Identity,
            To_String (lb_battery_name (Current_Language) & "=" & name));
      end if;

      return result;

   end search_battery;

end battery_set;
