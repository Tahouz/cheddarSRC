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

package body queueing_system.theoretical.mg1 is

   procedure initialize
     (a_queueing_system : in out mg1_queueing_system_theoretical)
   is
   begin
      initialize (generic_queueing_system_theoretical (a_queueing_system));

      a_queueing_system.queueing_system_type := qs_mg1;
   end initialize;

   procedure qs_average_waiting_time
     (a_queueing_system : in     mg1_queueing_system_theoretical;
      result            : in out Double)
   is

      arrival_rate : constant Double :=
        a_queueing_system.arrival_rate.entries (0).data;
      avg_service_time : constant Double := a_queueing_system.avg_service;
      var_service_time : constant Double := a_queueing_system.var_service;
      taw              : Double          := 0.0;
   begin
      taw :=
        avg_service_time +
        (arrival_rate * avg_service_time * avg_service_time +
           arrival_rate * var_service_time) /
          (2.0 * (1.0 - arrival_rate * avg_service_time));

      result := taw;
   end qs_average_waiting_time;

   procedure qs_average_number_customer
     (a_queueing_system : in     mg1_queueing_system_theoretical;
      result            : in out Double)
   is

      arrival_rate : constant Double :=
        a_queueing_system.arrival_rate.entries (0).data;
      avg_service_time : constant Double := a_queueing_system.avg_service;
      var_service_time : constant Double := a_queueing_system.var_service;
      tao              : Double          := 0.0;
   begin
      tao :=
        avg_service_time +
        (arrival_rate * avg_service_time * avg_service_time +
           arrival_rate * var_service_time) /
          (2.0 * (1.0 - arrival_rate * avg_service_time));
      tao := tao * arrival_rate;

      result := tao;
   end qs_average_number_customer;

   procedure qs_maximum_number_customer
     (a_queueing_system : in     mg1_queueing_system_theoretical;
      result            : in out Double)
   is
   begin
      result := 0.0;
      --      raise Not_Implemented;
   end qs_maximum_number_customer;

   function get_probability_of_state
     (a_queueing_system : in mg1_queueing_system_theoretical;
      n                 : in Natural) return Double
   is
   begin
      raise not_implemented;
      return 0.0;
   end get_probability_of_state;

   procedure qs_maximum_waiting_time
     (a_queueing_system : in     mg1_queueing_system_theoretical;
      result            : in out Double)
   is
   begin
      result := 0.0;
      --      raise Not_Implemented;
   end qs_maximum_waiting_time;

end queueing_system.theoretical.mg1;
