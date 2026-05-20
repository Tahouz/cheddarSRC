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

package body queueing_system.theoretical is

   procedure theoretical_results
     (a_queueing_system : in generic_queueing_system_theoretical'class;
      message           : in Unbounded_String)
   is

      awt, anc, mwt, mnc : Double := 0.0;
   begin
      -- criteria computation
      qs_average_waiting_time (a_queueing_system, awt);
      qs_average_number_customer (a_queueing_system, anc);
      qs_maximum_waiting_time (a_queueing_system, mwt);
      qs_maximum_number_customer (a_queueing_system, mnc);

      -- criteria display
      Put_Line ("theoretical Results");
      New_Line;
      Put_Line
        ("AW" &
         To_String (message) &
         " " &
         a_queueing_system.utilisation'img &
         " " &
         awt'img);
      Put_Line
        ("AO" &
         To_String (message) &
         " " &
         a_queueing_system.utilisation'img &
         " " &
         anc'img);
      Put_Line
        ("MW" &
         To_String (message) &
         " " &
         a_queueing_system.utilisation'img &
         " " &
         mwt'img);
      Put_Line
        ("MO" &
         To_String (message) &
         " " &
         a_queueing_system.utilisation'img &
         " " &
         mnc'img);
      New_Line;
   end theoretical_results;

   procedure initialize
     (a_queueing_system : in out generic_queueing_system_theoretical)
   is

   begin
      initialize (generic_queueing_system (a_queueing_system));
   end initialize;

   procedure reset
     (a_queueing_system : in out generic_queueing_system_theoretical)
   is

   begin
      initialize (generic_queueing_system_theoretical (a_queueing_system));
   end reset;

   function get_probability_density
     (a_queueing_system : in generic_queueing_system_theoretical'class;
      n                 : in Natural := 0) return Double
   is
      state  : Natural;
      result : Double := 0.0;
   begin
      state := n;
      if state > a_queueing_system.max_state then
         return (-1.0);
      end if;
      if state = 0 then
         state := a_queueing_system.max_state;
      end if;

      for i in 0 .. state loop
         result := result + get_probability_of_state (a_queueing_system, i);
      end loop;

      return result;
   end get_probability_density;

   function get_probability_of_full_buffer
     (a_queueing_system : in generic_queueing_system_theoretical) return Double
   is
   begin
      raise not_implemented;
      return 0.0;
   end get_probability_of_full_buffer;

   function get_probability_of_task_block
     (a_queueing_system : in generic_queueing_system_theoretical) return Double
   is
   begin
      raise not_implemented;
      return 0.0;
   end get_probability_of_task_block;

   function get_probability_of_queueing
     (a_queueing_system : in generic_queueing_system_theoretical) return Double
   is
   begin
      raise not_implemented;
      return 0.0;
   end get_probability_of_queueing;

end queueing_system.theoretical;
