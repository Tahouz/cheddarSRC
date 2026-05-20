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
--    $Rev: 6238 $
--    $Date: 2026-02-03 19:39:55 +0100 (mar., 03 févr. 2026) $
--    $Author: levieux $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with systems;  use systems;
with tasks;    use tasks;
with task_set; use task_set;
use task_set.generic_task_set;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;           use Ada.Text_IO;

package ipc_analysis is

   function get
     (a_system : in System; task_name : in Unbounded_String)
      return Generic_task_ptr;

   function get_dispatcher
     (a_system : in System; the_core_name : in Unbounded_String)
      return Generic_task_ptr;

   function get_read_write_delay
     (a_system : in System; the_task : in Generic_task_ptr) return Natural;

   function compute_dispatcher_receiver_BCET
     (a_system : in System; the_dispatcher : in Generic_task_ptr)
      return Natural;

   function compute_dispatcher_receiver_WCET
     (a_system : in System; the_dispatcher : in Generic_task_ptr)
      return Natural;

   function compute_dispatcher_WCET
     (a_system : in System; the_core_name : in Unbounded_String)
      return Natural;

   function compute_dispatcher_BCET
     (a_system : in System; the_core_name : in Unbounded_String)
      return Natural;

   function compute_dispatcher_WSAT
     (a_system : in System; the_core_name : in Unbounded_String)
      return Natural;

   function compute_dispatcher_receiver_WSAT
     (a_system : in System; the_dispatcher : in Generic_task_ptr)
      return Natural;

   function compute_dispatcher_receiver_WCRT
     (a_system : in System; the_dispatcher : in Generic_task_ptr)
      return Natural;

   function compute_dispatcher_BCRT
     (a_system : in System; the_core_name : in Unbounded_String)
      return Natural;

   function compute_dispatcher_WCRT
     (a_system : in System; the_core_name : in Unbounded_String)
      return Natural;

   function compute_dispatcher_WSHT
     (a_system : in System; the_core_name : in Unbounded_String)
      return Natural;

   function compute_dispatcher_BSHT
     (a_system : in System; the_core_name : in Unbounded_String)
      return Natural;

---------------------------------------------
----------SENDER TASK------------------------
---------------------------------------------

   function compute_sender_WSAT
     (a_system : in System; the_sender : in Generic_task_ptr) return Natural;

   function compute_task_WCET
     (a_system : in System; the_task : in Generic_task_ptr) return Natural;

   function compute_sender_BCET
     (a_system : in System; the_sender : in Generic_task_ptr) return Natural;

   function compute_sender_BCRT
     (a_system : in System; the_sender : in Generic_task_ptr) return Natural;

   function compute_sender_WCRT
     (a_system : in System; the_sender : in Generic_task_ptr) return Natural;

---------------------------------------------
----------RECEIVER TASK----------------------
---------------------------------------------

   function compute_receiver_BCET
     (a_system : in System; the_receiver : in Generic_task_ptr) return Natural;

   function compute_receiver_WCET
     (a_system : in System; the_receiver : in Generic_task_ptr) return Natural;

   function compute_receiver_BCRT
     (a_system : in System; the_receiver : in Generic_task_ptr) return Natural;

   function compute_receiver_WCRT
     (a_system : in System; the_receiver : in Generic_task_ptr) return Natural;

---------------------------------------------
----------INTER-CORE LATENCY-----------------
---------------------------------------------

   function compute_dispatcher_receiver_BCRT
     (a_system : in System; the_dispatcher : in Generic_task_ptr)
      return Natural;

   function compute_BICL
     (a_system   : in System; the_receiver : in Generic_task_ptr;
      the_sender : in Generic_task_ptr) return Natural;

   function compute_WICL
     (a_system     : in System; the_sender : in Generic_task_ptr;
      the_receiver : in Generic_task_ptr) return Natural;

end ipc_analysis;
