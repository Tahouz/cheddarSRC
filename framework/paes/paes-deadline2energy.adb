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
--    $Rev: 3838 $
--    $Date: 2021-04-22 13:20:19 +0200 (jeu. 22 avril 2021) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Text_IO;           use Ada.Text_IO;
with debug;                 use debug;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with unbounded_strings;         use unbounded_strings;
with Ada.Strings;               use Ada.Strings;
with float_util;                use float_util;
with architecture_factory;      use architecture_factory;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Paes.objective_functions;  use Paes.objective_functions;

package body Paes.deadline2energy is

   ------------------
   -- print_genome --
   ------------------

   procedure print_genome (s : solution_deadline2energy) is

   begin
      null;
   end print_genome;

   ------------------------
   -- print_debug_genome --
   ------------------------

   procedure print_debug_genome (s : solution_deadline2energy) is
   begin
      null;
   end print_debug_genome;

   function compute_consumption
     (s : in solution_deadline2energy;
      r : in rov_consumption) return Integer
   is
      result : Integer := 0;
   begin
      if (s.power_conversion = on) then
         result := result + r.power_conversion;
      end if;
      if (s.processor = on) then
         result := result + r.processor;
      end if;
      if (s.lights = on) then
         result := result + r.lights;
      end if;
      if (s.thrusters = on) then
         result := result + r.thrusters;
      end if;
      if (s.VLC = on) then
         result := result + r.VLC;
      end if;
      if (s.ultrasound_comm = on) then
         result := result + r.ultrasound_comm;
      end if;
      if (s.ultrasound_position = on) then
         result := result + r.ultrasound_position;
      end if;
      if (s.CAS = on) then
         result := result + r.CAS;
      end if;
      if (s.sensors = on) then
         result := result + r.sensors;
      end if;
      if (s.camera = on) then
         result := result + r.camera;
      end if;
      if (s.object_recognition = on) then
         result := result + r.object_recognition;
      end if;

      return result;

   end compute_consumption;

end Paes.deadline2energy;
