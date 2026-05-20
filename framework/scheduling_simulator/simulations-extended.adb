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

with Ada.Strings.Unbounded.Text_IO; use Ada.Strings.Unbounded.Text_IO;
with unbounded_strings;             use unbounded_strings;

package body Simulations.extended is

   function to_unbounded_string
     (s        : in simulation_value_ptr;
      from, to : in Natural) return Unbounded_String
   is
      msg       : Unbounded_String := empty_string;
      safe_from : Natural          := 0;
      safe_to   : Natural          := 0;

   begin

      if (s /= null) then

         if (s.ptype = simulation_random) or
           (s.ptype = simulation_array_random)
         then
            return empty_string;
         end if;

         if
           ((s.ptype = simulation_time_unit_array_boolean) or
            (s.ptype = simulation_time_unit_array_integer) or
            (s.ptype = simulation_time_unit_array_double) or
            (s.ptype = simulation_time_unit_array_string))
         then
            if Integer (time_unit_range'first) <= Integer (from) then
               safe_from := from;
            else
               safe_from := Natural (time_unit_range'first);
            end if;
            if Integer (time_unit_range'last) >= to then
               safe_to := to;
            else
               safe_to := Natural (time_unit_range'last);
            end if;
         end if;

         if
           ((s.ptype = simulation_array_boolean) or
            (s.ptype = simulation_array_integer) or
            (s.ptype = simulation_array_string) or
            (s.ptype = simulation_array_clock) or
            (s.ptype = simulation_array_double))
         then

            if Integer (simulations_range'first) <= Integer (from) then
               safe_from := from;
            else
               safe_from := Natural (simulations_range'first);
            end if;
            if Integer (simulations_range'last) >= to then
               safe_to := to;
            else
               safe_to := Natural (simulations_range'last);
            end if;
         end if;

         case s.ptype is
            when simulation_random =>
               null;
            when simulation_array_random =>
               null;
            when simulation_integer | simulation_clock =>
               return To_Unbounded_String (s.integer_value'img);
            when simulation_boolean =>
               return To_Unbounded_String (s.boolean_value'img);
            when simulation_double =>
               return To_Unbounded_String (s.double_value'img);
            when simulation_string =>
               return s.string_value;
            when simulation_time_unit_array_boolean =>
               for i in time_unit_range loop
                  if (Natural (i) >= safe_from) and
                    (Natural (i) <= safe_to)
                  then
                     msg :=
                       msg & s.boolean_time_unit_table_value (i)'img & ' ';
                  end if;
               end loop;
            when simulation_time_unit_array_integer =>
               for i in time_unit_range loop
                  if (Natural (i) >= safe_from) and
                    (Natural (i) <= safe_to)
                  then
                     msg :=
                       msg & s.integer_time_unit_table_value (i)'img & ' ';
                  end if;
               end loop;
            when simulation_time_unit_array_double =>
               for i in time_unit_range loop
                  if (Natural (i) >= safe_from) and
                    (Natural (i) <= safe_to)
                  then
                     msg := msg & s.double_time_unit_table_value (i)'img & ' ';
                  end if;
               end loop;
            when simulation_time_unit_array_string =>
               for i in time_unit_range loop
                  if (Natural (i) >= safe_from) and
                    (Natural (i) <= safe_to)
                  then
                     msg := msg & s.string_time_unit_table_value (i) & ' ';
                  end if;
               end loop;
            when simulation_array_boolean =>
               for i in simulations_range loop
                  if (Natural (i) >= safe_from) and
                    (Natural (i) <= safe_to)
                  then
                     msg := msg & s.boolean_table_value (i)'img & ' ';
                  end if;
               end loop;
            when simulation_array_integer | simulation_array_clock =>
               for i in simulations_range loop
                  if (Natural (i) >= safe_from) and
                    (Natural (i) <= safe_to)
                  then
                     msg := msg & s.integer_table_value (i)'img & ' ';
                  end if;
               end loop;
            when simulation_array_double =>
               for i in simulations_range loop
                  if (Natural (i) >= safe_from) and
                    (Natural (i) <= safe_to)
                  then
                     msg := msg & s.double_table_value (i)'img & ' ';
                  end if;
               end loop;
            when simulation_array_string =>
               for i in simulations_range loop
                  if (Natural (i) >= safe_from) and
                    (Natural (i) <= safe_to)
                  then
                     msg := msg & s.string_table_value (i) & ' ';
                  end if;
               end loop;
         end case;
      end if;
      return msg;

   end to_unbounded_string;

   function to_unbounded_string
     (s : simulation_value_ptr) return Unbounded_String
   is
   begin
      return to_unbounded_string (s, 0, 0);
   end to_unbounded_string;

   procedure put (s : simulation_value_ptr) is
   begin
      Put (to_unbounded_string (s));
   end put;

   function copy
     (my_simulation : in simulation_value_ptr) return simulation_value_ptr
   is
      new_simulation : simulation_value_ptr;

   begin
      new_simulation := new simulation_value (my_simulation.ptype);

      case my_simulation.ptype is

         when simulation_random =>
            new_simulation.random_value := my_simulation.random_value;
         when simulation_boolean =>
            new_simulation.boolean_value := my_simulation.boolean_value;
         when simulation_integer | simulation_clock =>
            new_simulation.integer_value := my_simulation.integer_value;
         when simulation_double =>
            new_simulation.double_value := my_simulation.double_value;
         when simulation_string =>
            new_simulation.string_value := my_simulation.string_value;

         when simulation_array_boolean =>
            new_simulation.boolean_table_value :=
              my_simulation.boolean_table_value;
         when simulation_array_integer | simulation_array_clock =>
            new_simulation.integer_table_value :=
              my_simulation.integer_table_value;
         when simulation_array_double =>
            new_simulation.double_table_value :=
              my_simulation.double_table_value;
         when simulation_array_string =>
            new_simulation.string_table_value :=
              my_simulation.string_table_value;
         when simulation_array_random =>
            new_simulation.random_table_value :=
              my_simulation.random_table_value;

         when simulation_time_unit_array_boolean =>
            new_simulation.boolean_time_unit_table_value :=
              my_simulation.boolean_time_unit_table_value;
         when simulation_time_unit_array_integer =>
            new_simulation.integer_time_unit_table_value :=
              my_simulation.integer_time_unit_table_value;
         when simulation_time_unit_array_double =>
            new_simulation.double_time_unit_table_value :=
              my_simulation.double_time_unit_table_value;
         when simulation_time_unit_array_string =>
            new_simulation.string_time_unit_table_value :=
              my_simulation.string_time_unit_table_value;

      end case;

      return new_simulation;

   end copy;

   function has_compatible_type
     (a : in simulation_type;
      b : in simulation_type) return Boolean
   is
      ok : Boolean := False;

      procedure reversable_check
        (a : in simulation_type;
         b : in simulation_type)
      is

      begin

         -- Same type : it's ok
         --
         if a = b then
            ok := True;
         end if;

         -- integer and clock types are compatibles
         --
         if a = simulation_clock and b = simulation_integer then
            ok := True;
         end if;
         if a = simulation_array_clock and b = simulation_array_integer then
            ok := True;
         end if;

         -- An array variable can be initialized with a constant
         -- of the same type
         --
         if a = simulation_clock and b = simulation_array_clock then
            ok := True;
         end if;
         if a = simulation_integer and b = simulation_array_integer then
            ok := True;
         end if;
         if a = simulation_string and b = simulation_array_string then
            ok := True;
         end if;
         if a = simulation_random and b = simulation_array_random then
            ok := True;
         end if;
         if a = simulation_boolean and b = simulation_array_boolean then
            ok := True;
         end if;
         if a = simulation_double and b = simulation_array_double then
            ok := True;
         end if;

         if a = simulation_time_unit_array_integer and
           b = simulation_array_integer
         then
            ok := True;
         end if;
         if a = simulation_time_unit_array_string and
           b = simulation_array_string
         then
            ok := True;
         end if;
         if a = simulation_time_unit_array_boolean and
           b = simulation_array_boolean
         then
            ok := True;
         end if;
         if a = simulation_time_unit_array_double and
           b = simulation_array_double
         then
            ok := True;
         end if;

         if a = simulation_time_unit_array_integer and
           b = simulation_integer
         then
            ok := True;
         end if;
         if a = simulation_time_unit_array_string and
           b = simulation_string
         then
            ok := True;
         end if;
         if a = simulation_time_unit_array_boolean and
           b = simulation_boolean
         then
            ok := True;
         end if;
         if a = simulation_time_unit_array_double and
           b = simulation_double
         then
            ok := True;
         end if;

      end reversable_check;

   begin

      reversable_check (a, b);
      reversable_check (b, a);

      return ok;

   end has_compatible_type;

end Simulations.extended;
