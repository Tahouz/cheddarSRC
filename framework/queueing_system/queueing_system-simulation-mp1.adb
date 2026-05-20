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

with qs_tools; use qs_tools;

package body queueing_system.simulation.Mp1 is

   procedure initialize
     (a_queueing_system : in out mp1_queueing_system_simulation)
   is
   begin
      initialize (generic_queueing_system_simulation (a_queueing_system));

      a_queueing_system.queueing_system_type := qs_mp1;
   end initialize;

   function compute_service_time
     (a_queueing_system : in mp1_queueing_system_simulation;
      seed              : in Generator) return Double
   is
      Prev_Act : Double := 0.0;
      Next_Act : Double := 0.0;

      Prev_Ri_Index : resp_time_consumer_range;
      Next_Ri_Index : resp_time_consumer_range;

      Prev_Ri : Double := 0.0;
      Next_Ri : Double := 0.0;

      Mst : constant Double :=
        1.0 / a_queueing_system.service_rate.entries (0).data;
      T_Arr        : constant Double  := a_queueing_system.t_arr;
      Empty_Buffer : constant Boolean := a_queueing_system.empty_buffer;
      Result       : Double           := 0.0;
   begin
      Prev_Act := Double'floor (T_Arr / Mst);
      Next_Act := Prev_Act + 1.0;

      Prev_Ri_Index :=
        resp_time_consumer_range
          (double_mod
             (Prev_Act,
              Double (a_queueing_system.consumer_resp_time.nb_entries)));

      Next_Ri_Index :=
        resp_time_consumer_range
          (double_mod
             (Next_Act,
              Double (a_queueing_system.consumer_resp_time.nb_entries)));

      Prev_Ri :=
        a_queueing_system.consumer_resp_time.entries (Prev_Ri_Index).data;
      Next_Ri :=
        a_queueing_system.consumer_resp_time.entries (Next_Ri_Index).data;

      if Empty_Buffer then
         if T_Arr < (Prev_Act * Mst + Prev_Ri) then
            Result := (Prev_Act * Mst + Prev_Ri) - T_Arr;
         else
            Result := (Next_Act * Mst + Next_Ri) - T_Arr;
         end if;
      else
         Result := Next_Ri + Mst - Prev_Ri;
      end if;

      return Result;
   end compute_service_time;

   function compute_inter_arrival_time
     (a_queueing_system : in mp1_queueing_system_simulation;
      seed              : in Generator) return Double
   is
      Result       : Double          := 0.0;
      Arrival_Rate : constant Double :=
        a_queueing_system.arrival_rate.entries (0).data;
   begin
      Result := get_exponential_time (1.0 / Arrival_Rate, seed);
      return Result;
   end compute_inter_arrival_time;

end queueing_system.simulation.Mp1;
