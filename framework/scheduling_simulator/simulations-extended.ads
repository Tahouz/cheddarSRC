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

with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;

with time_unit_events;          use time_unit_events;
with Framework_Config;          use Framework_Config;
with Laws;                      use Laws;
with doubles;                   use doubles;

with Unchecked_Deallocation;

package Simulations.extended is

   function has_compatible_type
     (a : in simulation_type;
      b : in simulation_type) return Boolean;

   ------------------------------------------------------------------
   -- Type of data stored during a scheduling simulation
   ------------------------------------------------------------------

   type simulations_range is new Integer range 0 .. Max_Simulation;
   type sum_simulations_range is new Integer range 0 .. Sum_Simulation;

   type random_law_parameters_type is record
      law        : laws_type;
      parameter1 : Integer;
      parameter2 : Integer;
   end record;

   type boolean_table is array (simulations_range) of Boolean;
   type integer_table is array (simulations_range) of Integer;
   type double_table is array (simulations_range) of Double;
   type string_table is array (simulations_range) of Unbounded_String;
   type random_table is array (simulations_range) of State;

   type boolean_time_unit_table is array (time_unit_range) of Boolean;
   type integer_time_unit_table is array (time_unit_range) of Integer;
   type double_time_unit_table is array (time_unit_range) of Double;
   type string_time_unit_table is array (time_unit_range) of Unbounded_String;
   type random_time_unit_table is array (time_unit_range) of State;

   type simulation_value (ptype : simulation_type) is record
      case ptype is
         when simulation_boolean =>
            boolean_value : Boolean := True;
         when simulation_integer | simulation_clock =>
            integer_value : Integer := 0;
         when simulation_double =>
            double_value : Double := 0.0;
         when simulation_random =>
            random_value          : State;
            random_law_parameters : random_law_parameters_type;
         when simulation_string =>
            string_value : Unbounded_String;

         when simulation_array_boolean =>
            boolean_table_value : boolean_table := (others => True);
         when simulation_array_integer | simulation_array_clock =>
            integer_table_value : integer_table := (others => 0);
         when simulation_array_double =>
            double_table_value : double_table := (others => 0.0);
         when simulation_array_random =>
            random_table_value          : random_table;
            random_table_law_parameters : random_law_parameters_type;
         when simulation_array_string =>
            string_table_value : string_table;

         when simulation_time_unit_array_integer =>
            integer_time_unit_table_value : integer_time_unit_table :=
              (others => 0);
         when simulation_time_unit_array_double =>
            double_time_unit_table_value : double_time_unit_table :=
              (others => 0.0);
         when simulation_time_unit_array_string =>
            string_time_unit_table_value : string_time_unit_table;
         when simulation_time_unit_array_boolean =>
            boolean_time_unit_table_value : boolean_time_unit_table;

      end case;
   end record;

   type simulation_value_ptr is access simulation_value;

   procedure free is new Unchecked_Deallocation
     (simulation_value,
      simulation_value_ptr);

   procedure put (s : simulation_value_ptr);

   function to_unbounded_string
     (s        : in simulation_value_ptr;
      from, to : in Natural) return Unbounded_String;

   function to_unbounded_string
     (s : in simulation_value_ptr) return Unbounded_String;

   function copy
     (my_simulation : in simulation_value_ptr) return simulation_value_ptr;

end Simulations.extended;
