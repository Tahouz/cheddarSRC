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

with xml_tag;                use xml_tag;
with double_util;            use double_util;
with translate;              use translate;
with unbounded_strings;      use unbounded_strings;
with Text_IO;                use Text_IO;
with Ada.Exceptions;         use Ada.Exceptions;
with GNAT.Current_Exception; use GNAT.Current_Exception;

package body scheduler.fixed_priority.aperiodic_server.sporadic is

   procedure initialize
     (a_scheduler : in out sporadic_aperiodic_server_scheduler)
   is
   begin
      reset (a_scheduler);
      a_scheduler.parameters.scheduler_type :=
        hierarchical_sporadic_aperiodic_server_protocol;
   end initialize;

   function copy
     (a_scheduler : in sporadic_aperiodic_server_scheduler)
      return generic_scheduler_ptr
   is
      ptr : sporadic_aperiodic_server_scheduler_ptr;

   begin

      ptr := new sporadic_aperiodic_server_scheduler;

      ptr.parameters         := a_scheduler.parameters;
      ptr.previously_elected := a_scheduler.previously_elected;
      ptr.used_resource      := a_scheduler.used_resource;

      return generic_scheduler_ptr (ptr);

   end copy;

   procedure do_election
     (my_scheduler       : in out sporadic_aperiodic_server_scheduler;
      si                 : in out scheduling_information;
      result             : in out scheduling_sequence_ptr;
      msg                : in out Unbounded_String;
      current_time       : in     Natural;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      core_name          : in     Unbounded_String;
      options            : in     scheduling_option;
      event_to_generate  : in     time_unit_event_type_boolean_table;
      elected            : in out tasks_range;
      no_task            : in out Boolean)

   is

   begin

      do_election
        (aperiodic_server_scheduler (my_scheduler),
         si,
         result,
         msg,
         current_time,
         processor_name,
         address_space_name,
         core_name,
         options,
         event_to_generate,
         elected,
         no_task);

      -- Refill the server's capacity and put it back into idle mode
      --
      if my_scheduler.current_server_wake_time = current_time then
         my_scheduler.current_server_capacity :=
           my_scheduler.parameters.capacity;
         my_scheduler.server_is_idle := True;
      end if;

      -- Election : if there is a pending aperiodic task and
      -- the server's capacity is greater than 0 then
      -- the aperiodic task is serviced and the server's
      -- capacity decremented.
      -- We also check if the server was idle when aperiodic task
      -- occured. If it was we compute the new wake time.
      -- Otherwise the periodic task is ran.
      --
      no_task := True;
      if (my_scheduler.current_server_capacity > 0) and
        (my_scheduler.aperiodic_highest_priority /= Natural'first) and
        (my_scheduler.parameters.priority >
         priority_range (my_scheduler.periodic_highest_priority))
      then
         no_task                              := False;
         elected := my_scheduler.aperiodic_elected;
         my_scheduler.current_server_capacity :=
           my_scheduler.current_server_capacity - 1;

         if my_scheduler.server_is_idle = True then
            my_scheduler.server_is_idle           := False;
            my_scheduler.current_server_wake_time :=
              current_time + my_scheduler.parameters.period;
         end if;
      else
         if (my_scheduler.periodic_highest_priority /= Natural'first) then
            no_task := False;
            elected := my_scheduler.periodic_elected;
         end if;
      end if;

   end do_election;

end scheduler.fixed_priority.aperiodic_server.sporadic;
