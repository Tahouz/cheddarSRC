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

with Buffers; use Buffers;
use Buffers.Buffer_Roles_Package;
with queueing_system; use queueing_system;
use queueing_system.a_resp_time_consumer;

package Scheduling_Analysis.extended.buffer_analysis is

   no_performance_criteria : exception;

   -- Compute from a scheduling sequence buffer size for each
   -- time unit
   --
   procedure compute_buffer_size_from_simulation
     (sched   : in     scheduling_sequence_ptr;
      my_buff : in     buffer_ptr;
      buff    : in out buffer_size_table_ptr);

   -- Compute, from a buffer_Size_Table, maximum and average
   -- performance criterion
   --
   function compute_average_buffer_size_from_simulation
     (buff : in buffer_size_table_ptr) return Double;

   function compute_maximum_buffer_size_from_simulation
     (buff : in buffer_size_table_ptr) return Natural;

   function compute_maximum_waiting_time_from_simulation
     (buff                    : in buffer_size_table_ptr;
      average_consumer_period : in Double) return Double;

   function compute_average_waiting_time_from_simulation
     (buff                    : in buffer_size_table_ptr;
      average_consumer_period : in Double) return Double;

end Scheduling_Analysis.extended.buffer_analysis;
