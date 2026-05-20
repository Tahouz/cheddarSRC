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
--    $Rev: 4711 $
--    $Date: 2023-12-17 21:17:48 +0100 (dim., 17 déc. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with batteries; use batteries;

package scheduler.dynamic_priority.edfett is

   type edfett_scheduler is new dynamic_priority_scheduler with private;
   type edfett_scheduler_ptr is access all edfett_scheduler'Class;

   procedure initialize (a_scheduler : in out edfett_scheduler);

   function copy
     (a_scheduler : in edfett_scheduler) return generic_scheduler_ptr;

   procedure specific_scheduler_initialization
     (my_scheduler       : in out edfett_scheduler;
      si : in out scheduling_information; processor_name : in Unbounded_String;
      address_space_name : in Unbounded_String; my_tasks : in out tasks_set;
      my_schedulers : in scheduler_table; my_resources : in out resources_set;
      my_buffers         : in out buffers_set; my_messages : in messages_set;
      msg                : in out Unbounded_String);

   procedure do_election
     (my_scheduler       : in out edfett_scheduler;
      si                 : in out scheduling_information;
      result : in out scheduling_sequence_ptr; msg : in out Unbounded_String;
      current_time       : in Natural; processor_name : in Unbounded_String;
      address_space_name : in     Unbounded_String;
      core_name          : in Unbounded_String; options : in scheduling_option;
      event_to_generate  : in     time_unit_event_type_boolean_table;
      elected            : in out tasks_range; no_task : in out Boolean);

   procedure produce_energy_event
     (my_scheduler : in edfett_scheduler; options : in scheduling_option;
      si : in scheduling_information; an_event : out time_unit_event_ptr);

private

   type edfett_scheduler is new dynamic_priority_scheduler with record

      -- Energy at Current_Time
      current_energy : Natural := 0;

      -- Battery of the processor
      -- This implementation is limited with one battery
      current_battery : battery_ptr;

   end record;

end scheduler.dynamic_priority.edfett;
