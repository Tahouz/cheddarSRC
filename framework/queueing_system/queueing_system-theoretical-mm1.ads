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

package queueing_system.theoretical.mm1 is

   type mm1_queueing_system_theoretical is new generic_queueing_system_theoretical with
   null record;
   type mm1_queueing_system_theoretical_ptr is
     access all generic_queueing_system_theoretical'class;

   procedure initialize
     (a_queueing_system : in out mm1_queueing_system_theoretical);

   -- return the theorec average waiting time of one customer in the queue
   --
   procedure qs_average_waiting_time
     (a_queueing_system : in     mm1_queueing_system_theoretical;
      result            : in out Double);

   -- return the theorec average number of customer in the queue
   --
   procedure qs_average_number_customer
     (a_queueing_system : in     mm1_queueing_system_theoretical;
      result            : in out Double);

   -- return the theorec maximum waiting time of one customer in the queue
   --
   procedure qs_maximum_waiting_time
     (a_queueing_system : in     mm1_queueing_system_theoretical;
      result            : in out Double);

   -- return the theorec maximum number of customer in the queue
   --
   procedure qs_maximum_number_customer
     (a_queueing_system : in     mm1_queueing_system_theoretical;
      result            : in out Double);

   -- return the theorec probability to have N customer in the qs
   --
   function get_probability_of_state
     (a_queueing_system : in mm1_queueing_system_theoretical;
      n                 : in Natural) return Double;

end queueing_system.theoretical.mm1;
