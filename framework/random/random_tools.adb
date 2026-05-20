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
--    $Rev: 4927 $
--    $Date: 2024-03-29 00:54:57 +0100 (ven., 29 mars 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics; use Ada.Numerics;
with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Numerics.Elementary_Functions;

package body random_tools is

   function get_rand_parameter
     (min  : in Natural;
      max  : in Natural;
      seed : in Generator) return Natural
   is

      aux : Double;
      res : Natural;

   begin
   	
      aux :=
        Double (Random (seed)) * (Double (max) - Double (min)) + Double (min);
      res := Natural (aux);

      if (res < min) or (res > max) then
         raise Constraint_Error;
      end if;
      return res;
   end get_rand_parameter;

   function get_rand_parameter
     (min  : in Double;
      max  : in Double;
      seed : in Generator) return Double
   is
      res : Double := 0.0;

   begin
   	
      res := Double (Random (seed)) * (max - min) + min;

      if (res < min) or (res > max) then
         raise Constraint_Error;
      end if;

      return res;
   end get_rand_parameter;
   
   -- generate poisson inter arrival time (different from 0)
   --
   function get_exponential_time
     (arrival_rate : in Double;
      seed         : in Generator) return Double
   is
      result : Double;
   begin

      result := -1.0 / arrival_rate * Log (Double (Random (seed)));

      return (result);
   end get_exponential_time;

   pragma warnings (Off);
   -- generate a uniform distribution of task utilizations
   --
   function gen_uunifast (n : in Integer;           -- Number of task
   u                        : in Float)             -- Processor utilization
   return float_array        -- Float array of task utilizations
   is
      type value_type is new Float;
      package value_functions is new Ada.Numerics.Generic_Elementary_Functions
        (value_type);
      use value_functions;

      utilizations_array : float_array (0 .. n - 1);

      g        : Generator;
      sumu     : Float;
      nextsumu : value_type;
   begin
      Reset (g);
      sumu := u;
      for i in 1 .. n - 1 loop
         nextsumu :=
           value_type (sumu) *
           value_type (Random (g))**value_type (1.0 / (n - i));
         utilizations_array (i - 1) := sumu - Float (nextsumu);
         sumu                       := Float (nextsumu);
      end loop;
      utilizations_array (n - 1) := sumu;
      return utilizations_array;
   end gen_uunifast;

   -- generate a uniform distribution of task utilizations
   --
   function gen_uunifast
     (n : in Integer;           -- Number of task
      u : in Integer)           -- Processor utilization
      return integer_array      -- Integer array of task utilizations
   is
      type value_type is new Float;
      package value_functions is new Ada.Numerics.Generic_Elementary_Functions
        (value_type);
      use value_functions;

      utilizations_array : integer_array (0 .. n - 1);

      g        : Generator;
      sumu     : Float;
      nextsumu : value_type;
   begin
      Reset (g);
      sumu := Float (u);
      for i in 1 .. n - 1 loop
         nextsumu :=
           value_type (sumu) *
           value_type (Random (g))**value_type (1.0 / (n - i));
         utilizations_array (i - 1) :=
           Integer (Float'floor (sumu - Float (nextsumu)));
         sumu := Float (nextsumu);
      end loop;

      utilizations_array (n - 1) := Integer (u);
      for i in 0 .. n - 2 loop
         utilizations_array (n - 1) :=
           utilizations_array (n - 1) - utilizations_array (i);
      end loop;

      return utilizations_array;
   end gen_uunifast;
   pragma warnings (On);
   
   
   -- generate a uniform distribution of task utilizations
   -- with a minimum rate
   function gen_uunifast_with_limited_utilization
   	(n : in Integer;           -- Number of task
      	u : in Float)           -- Processor utilization
      	return float_array      -- Integer array of task utilizations
   is
   	find : Boolean;
   	utilizations_array : float_array (0 .. n - 1);
   begin
   	-- loop to find U values above 10E-03
   	loop
   		find := True;
   		
   		-- generate with UUinfast
   		utilizations_array := gen_uunifast (n, u);
   		
   		-- check values
   		for i in 0 .. n -1 loop
   			if utilizations_array(i) < 0.0025 then
   				find := False;
   			end if;
   		end loop;
   		
   	exit when find;
   	end loop;
   return utilizations_array;	
   end gen_uunifast_with_limited_utilization;
   
   
   function generate_distinct_periods (n : in Integer) return integer_array is

      m : constant array (1 .. 5, 1 .. 7) of Integer :=
        ((1, 2, 2, 4, 4, 4, 8),
         (1, 3, 3, 3, 3, 9, 9),
         (1, 5, 5, 5, 5, 0, 0),
         (1, 1, 7, 7, 7, 0, 0),
         (1, 1, 1, 1, 11, 0, 0));

      function random_limited_period return Integer is

         use Ada.Numerics.Float_Random;

         random_column : Integer := 0;
         a_period      : Integer := 1;
         g             : Ada.Numerics.Float_Random.Generator;
         x             : Integer := 0;
      begin
         Reset (g);
         for i in 1 .. 5 loop -- for each line i of the matrix M loop
            random_column := 0;
            x             := 0;
            while (random_column < 1) or (random_column > 7) or (x = 0) loop
               random_column := Integer (Float'rounding (7.0 * Random (g)));
               if (random_column >= 1) and (random_column <= 7) then
                  x := m (i, random_column);
               end if;
            end loop;
            a_period := a_period * m (i, random_column);
         end loop;
         return a_period;
      end random_limited_period;

      function found_element_in_array
        (x   : Integer;
         seq : integer_array) return Boolean
      is
         b : Boolean := False;
         i : Integer := 1;
      begin
         while not b and i <= seq'length loop
            if seq (i) = x then
               b := True;
            end if;
            i := i + 1;
         end loop;
         return b;
      end found_element_in_array;

      x                 : Integer;
      different_periods : integer_array (1 .. n);

   begin

      for i in 1 .. n loop
         different_periods (i) := 0;
      end loop;

      for i in 1 .. n loop
         loop
            x := random_limited_period;
            exit when not found_element_in_array (x, different_periods);
         end loop;
         different_periods (i) := x;
      end loop;

      return different_periods;

   end generate_distinct_periods;

   function generate_period_set_with_limited_hyperperiod
     (n_tasks             : in Integer;
      n_different_periods : in Integer) return integer_array
   is

      procedure shuffle_an_array (to_shuffle : in out integer_array) is

         use Ada.Numerics.Float_Random;

         n                 : Integer;
         g                 : Ada.Numerics.Float_Random.Generator;
         a_random_position : Integer := 0;
         a_value           : Integer;
      begin

         n := to_shuffle'length;
         Reset (g);
         while n > 1 loop
            a_random_position := 0;
            while (a_random_position < 1) or (a_random_position > n) loop
               a_random_position := Integer (Random (g) * Float (n));
            end loop;

            n                              := n - 1;
            a_value                        := to_shuffle (a_random_position);
            to_shuffle (a_random_position) := to_shuffle (n);
            to_shuffle (n)                 := a_value;

         end loop;
      end shuffle_an_array;

      x, k              : Integer;
      occurences        : integer_array (0 .. n_different_periods - 1);
      different_periods : integer_array (1 .. n_different_periods);
      set_of_periods    : integer_array (1 .. n_tasks);
      has_a_zero_value  : Boolean := True;

   begin

      -- Generate a set of different periods
      different_periods := generate_distinct_periods (n_different_periods);

      if n_different_periods = n_tasks then
         return different_periods;
      else
         -- Generate randomly occurence of each period in the set of tasks
         while has_a_zero_value loop

            occurences := gen_uunifast (n_different_periods, n_tasks);

            k := 0;
            loop
               x := occurences (k);
               k := k + 1;
               exit when ((k = n_different_periods) or (x = 0));
            end loop;

            if k = n_different_periods then
               has_a_zero_value := False;
            end if;
         end loop;

         -- Generate the set of periods from distincts_periods and occurences
         k := 1;
         for j in 0 .. n_different_periods - 1 loop
            for i in 1 .. occurences (j) loop
               set_of_periods (k) := different_periods (j + 1);
               k                  := k + 1;
            end loop;
         end loop;

         -- Rearrange randomly the set of periods
         shuffle_an_array (set_of_periods);
         return set_of_periods;

      end if;

   end generate_period_set_with_limited_hyperperiod;

end random_tools;
