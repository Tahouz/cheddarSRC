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
--    $Rev: 5359 $
--    $Date: 2024-12-19 08:34:16 +0100 (jeu., 19 déc. 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Numerics.Generic_Elementary_Functions;
with Doubles;                   use Doubles;

package random_tools is

   -- Return a random parameter between min and max
   -- Generated values follow an uniform distribution
   -- 
   function get_rand_parameter
     (min  : in Natural;
      max  : in Natural;
      seed : in Generator) return Natural;

   function get_rand_parameter
     (min  : in Double;
      max  : in Double;
      seed : in Generator) return Double;



   -- generate poisson inter arrival time (and different from 0)
   -- Generated values follow a poisson distribution
   --
   function get_exponential_time
     (arrival_rate : in Double;
      seed         : in Generator) return Double;


   -- Return an uniform random value between 0 and 1
   --
   function drand48 return Long_Float;
   pragma import (C, drand48);


   -- Initialize a seed with "value"
   --
   procedure srand48 (value : in Integer);
   pragma import (C, srand48);


   -- UUniFast by Bini
   --
   type float_array is array (Integer range <>) of Float;
   type integer_array is array (Integer range <>) of Integer;

   function gen_uunifast (n : in Integer;           -- Number of task
   u                        : in Float)             -- Processor utilization
   return float_array;       -- Float array of task utilizations

   function gen_uunifast (n : in Integer;           -- Number of task
   u                        : in Integer)           -- Processor utilization
   return integer_array;     -- Integer array of task utilizations
   
   -- Uunifast function called with a value guarantee that is too small
   function gen_uunifast_with_limited_utilization (n : in Integer;           -- Number of task
   u                        : in Float)           -- Processor utilization
   return float_array;     -- Integer array of task utilizations


   -- This function is  Based on Goossens, J., & Macq, C. (2001).
   -- Limitation of the hyper-period in real-time periodic task set generation.
   -- In Proceedings of the RTS Embedded System (RTS’01).
   -- that generates a set of periods whose hyperperiod is limited
   --
   function generate_period_set_with_limited_hyperperiod
     (n_tasks             : in Integer;
      n_different_periods : in Integer) return integer_array;

   function generate_distinct_periods (n : in Integer) return integer_array;
   

end random_tools;
