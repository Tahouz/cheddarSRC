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

package scheduler.dynamic_priority is

   type dynamic_priority_scheduler is
     abstract new generic_scheduler with private;
   type dynamic_priority_scheduler_ptr is
     access all dynamic_priority_scheduler'class;

   type dynamic_priority_tcb is new tcb with record
      dynamic_deadline : Natural;
   end record;
   type dynamic_priority_tcb_ptr is access all dynamic_priority_tcb'class;

   procedure initialize (a_tcb : in out dynamic_priority_tcb);

   function build_tcb
     (my_scheduler : in dynamic_priority_scheduler;
      a_task       :    generic_task_ptr) return tcb_ptr;

   procedure check_before_scheduling
     (my_scheduler   : in dynamic_priority_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String);

   procedure specific_scheduler_initialization
     (my_scheduler       : in out dynamic_priority_scheduler;
      si                 : in out scheduling_information;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      my_tasks           : in out tasks_set;
      my_schedulers      : in     scheduler_table;
      my_resources       : in out resources_set;
      my_buffers         : in out buffers_set;
      my_messages        : in     messages_set;
      msg                : in out Unbounded_String);

private

   type dynamic_priority_scheduler is abstract new generic_scheduler with
   null record;

end scheduler.dynamic_priority;
