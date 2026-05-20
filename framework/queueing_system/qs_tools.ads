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

with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Numerics.Generic_Elementary_Functions;
with Doubles;                   use Doubles;


package qs_tools is

   -- return a random parameter between min and max
   --
   function get_rand_parameter
     (min  : in Natural;
      max  : in Natural;
      seed : in Generator) return Natural;

   function get_rand_parameter
     (min  : in Double;
      max  : in Double;
      seed : in Generator) return Double;
      
   function Box_Muller_Normal
	 (min : in Natural;
	  max : in Natural;
	  seed : in Generator) return Natural;
	 
   function Box_Muller_Normal2
	 (min : in Natural;
	  max : in Natural;
	  seed : in Generator) return Natural;

   -- generate poisson inter arrival time (different from 0)
   --
   function get_exponential_time
     (mtbe : in Double;
      seed : in Generator) return Double;

end qs_tools;
