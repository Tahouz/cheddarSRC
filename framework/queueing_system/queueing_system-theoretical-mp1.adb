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

with queueing_system; use queueing_system.a_resp_time_consumer;

package body queueing_system.theoretical.mp1 is

   procedure initialize
     (a_queueing_system : in out mp1_queueing_system_theoretical)
   is
   begin
      initialize (generic_queueing_system_theoretical (a_queueing_system));

      a_queueing_system.queueing_system_type := qs_mp1;
   end initialize;

   procedure qs_average_waiting_time
     (a_queueing_system : in     mp1_queueing_system_theoretical;
      result            : in out Double)
   is

      package double_io is new Text_IO.Float_IO (Double);
      use double_io;

      avg_service_time : Double := 0.0;
      var_service_time : Double := 0.0;
      rau              : Double := 0.0;
      taw              : Double := 0.0;
      wi               : Double := 0.0;
      resp_time        : Double := 0.0;
      resp_time_prec   : Double :=
        a_queueing_system.consumer_resp_time.entries
          (a_queueing_system.consumer_resp_time.nb_entries - 1)
          .data;
      nb_service_time : Double          := 0.0;
      pcons           : constant Double :=
        1.0 / a_queueing_system.service_rate.entries (0).data;
      arrival_rate : constant Double :=
        a_queueing_system.arrival_rate.entries (0).data;
   begin
      -- service time
      --
      avg_service_time := pcons / (2.0 * (1.0 - arrival_rate * (pcons / 2.0)));

      rau := arrival_rate * avg_service_time;

      -- variance
      --
      for i in 0 .. a_queueing_system.consumer_resp_time.nb_entries - 1 loop
         resp_time := a_queueing_system.consumer_resp_time.entries (i).data;

         wi := resp_time + pcons - resp_time_prec;
         -- compute the variance
         var_service_time := var_service_time + wi * wi;

         resp_time_prec  := resp_time;
         nb_service_time := nb_service_time + 1.0;
      end loop;

      var_service_time := var_service_time / nb_service_time;
      var_service_time :=
        (1.0 - rau) * (pcons * pcons / 12.0) +
        rau * (var_service_time - pcons * pcons);

      taw :=
        avg_service_time +
        arrival_rate *
          (avg_service_time * avg_service_time + var_service_time) /
          (2.0 * (1.0 - arrival_rate * pcons)); -- Mst));

      result := taw;

   end qs_average_waiting_time;

   procedure qs_average_number_customer
     (a_queueing_system : in     mp1_queueing_system_theoretical;
      result            : in out Double)
   is

      avg_service_time : Double := 0.0;
      var_service_time : Double := 0.0;
      rau              : Double := 0.0;
      tao              : Double := 0.0;
      wi               : Double := 0.0;
      resp_time        : Double := 0.0;
      resp_time_prec   : Double :=
        a_queueing_system.consumer_resp_time.entries
          (a_queueing_system.consumer_resp_time.nb_entries - 1)
          .data;
      nb_service_time : Double          := 0.0;
      pcons           : constant Double :=
        1.0 / a_queueing_system.service_rate.entries (0).data;
      arrival_rate : constant Double :=
        a_queueing_system.arrival_rate.entries (0).data;
   begin
      -- service time
      --
      avg_service_time := pcons / (2.0 * (1.0 - arrival_rate * (pcons / 2.0)));

      rau := arrival_rate * avg_service_time;

      -- variance
      --
      for i in 0 .. a_queueing_system.consumer_resp_time.nb_entries - 1 loop
         resp_time := a_queueing_system.consumer_resp_time.entries (i).data;

         wi := resp_time + pcons - resp_time_prec;
         -- compute the variance
         var_service_time := var_service_time + wi * wi;

         resp_time_prec  := resp_time;
         nb_service_time := nb_service_time + 1.0;
      end loop;

      var_service_time := var_service_time / nb_service_time;
      var_service_time :=
        (1.0 - rau) * (pcons * pcons / 12.0) +
        rau * (var_service_time - pcons * pcons);

      tao :=
        avg_service_time +
        arrival_rate *
          (avg_service_time * avg_service_time + var_service_time) /
          (2.0 * (1.0 - arrival_rate * pcons)); -- Mst));
      tao := arrival_rate * tao;

      result := tao;
   end qs_average_number_customer;

   --   -- return the simulated average waiting time of one customer in the
   --queue
   --   --
   --   procedure Qs_Average_Waiting_Time_Simulation (
   --         A_Queueing_System : in out Mp1_Queueing_System_theoretical;
   --         Arrival_Rate      : in     Double;
   --         Service_Rate      : in     Double;
   --         Result            : in out Double               ) is

   --      package Double_Io is new Text_Io.Float_Io(Double);
   --      use Double_Io;

   --      Avg_Service_Time : Double := A_Queueing_System.Avg_Service;
   --      Var_Service_Time : Double := A_Queueing_System.Var_Service;

   --      Rau : Double := 0.0;
   --   begin
   --      --      Put_Line("Avg_Service_Time" & Avg_Service_Time'Img);
   --      --      Put_Line("var_Service_Time" & Var_Service_Time'Img);

   --      Rau := Arrival_Rate * Avg_Service_Time;
   --      Put(Rau,Aft=>4, Exp => 0);
   --      New_Line;

   --      Result:= Avg_Service_Time + (Arrival_Rate * Avg_Service_Time *
   --         Avg_Service_Time + Arrival_Rate* Var_Service_Time)
   --         /(2.0*(1.0 - Arrival_Rate * Avg_Service_Time));
   --   end Qs_Average_Waiting_Time_Simulation;

   --   -- return the simulated average number of customer in the queue
   --   --
   --   procedure Qs_Average_Number_Customer_Simulation (
   --         A_Queueing_System : in     Mp1_Queueing_System_theoretical;
   --         Arrival_Rate      : in     Double;
   --         Service_Rate      : in     Double;
   --         Result            : in out Double) is

   --      Avg_Service_Time : Double := A_Queueing_System.Avg_Service;

   --      Var_Service_Time : Double := A_Queueing_System.Var_Service;

   --   begin

   --      Result:= Avg_Service_Time + (Arrival_Rate * Avg_Service_Time *
   --         Avg_Service_Time + Arrival_Rate* Var_Service_Time)
   --         /(2.0*(1.0 - Arrival_Rate * Avg_Service_Time));
   --      Result:= Result* Arrival_Rate;
   --   end Qs_Average_Number_Customer_Simulation;

   procedure qs_maximum_waiting_time
     (a_queueing_system : in     mp1_queueing_system_theoretical;
      result            : in out Double)
   is
   begin
      raise not_implemented;
   end qs_maximum_waiting_time;

   procedure qs_maximum_number_customer
     (a_queueing_system : in     mp1_queueing_system_theoretical;
      result            : in out Double)
   is
   begin
      raise not_implemented;
   end qs_maximum_number_customer;

   function get_probability_of_state
     (a_queueing_system : in mp1_queueing_system_theoretical;
      n                 : in Natural) return Double
   is
   begin
      raise not_implemented;
      return 0.0;
   end get_probability_of_state;

end queueing_system.theoretical.mp1;
