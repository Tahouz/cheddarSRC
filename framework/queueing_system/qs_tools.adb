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
--    $Rev: 5684 $
--    $Date: 2025-08-02 14:52:21 +0200 (sam., 02 août 2025) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics; use Ada.Numerics;
with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Numerics.Elementary_Functions;


package body qs_tools is

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
   
   -- generate values generates values according to the normal distribution law
   --
   function Box_Muller_Normal (min, max : Natural; seed : Generator) return Natural is
   R1, R2 : Float;
   M, S,v1,v2  : Float;
   res : Float := 0.0;
   begin
   	 v2 := float(max);
   	 v1 := float(min);
   	 S := (v2 - v1)/2.0;
   	 M := S + v1;
	 while res <= v1 or res >= v2 loop
		 R1 := Random (seed);		 
		 R2 := Random (seed);		 
		 res := M + S * float((Sqrt(-2.0 * Log(long_float(R1))) * Double(Elementary_Functions.Cos(2.0 * Pi * R2))));
	 end loop;
	 return Natural(res);
   end Box_Muller_Normal;


   -- generate values generates values according to the normal distribution law
   -- max represents C(HI) value
   -- min represents E value
   function Box_Muller_Normal2 (min, max : Natural; seed : Generator) return Natural is
   R1, R2 	: Float;
   M, S,v1,v2	: Float;
   res 	: Float := 0.0;
   CLO		: Float;
   begin
   	 CLO := float(max/2);
   	 v2 := float(max);
   	 v1 := float(min);
   	 
   	 S := (CLO - v1)/2.0;
   	 M := S + v1;
   	 
   	 
	 while res <= v1 or res >= v2 loop
		 R1 := Random (seed);		 
		 R2 := Random (seed);		 
		 res := M + S * float((Sqrt(-2.0 * Log(long_float(R1))) * Double(Elementary_Functions.Cos(2.0 * Pi * R2))));
	 end loop;
	 return Natural(res);
   end Box_Muller_Normal2;
   
   
   function get_exponential_time
     (mtbe : in Double;
      seed : in Generator) return Double
   is
      result : Double;
   begin

      result := -mtbe * Log (Double (Random (seed)));

      return (result);
   end get_exponential_time;

end qs_tools;
