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

with scheduler;           use scheduler;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with scheduler.fixed_priority;     use scheduler.fixed_priority;
with scheduler.fixed_priority.hpf; use scheduler.fixed_priority.hpf;
with Text_IO;                      use Text_IO;
with debug;                        use debug;

package body scheduler.hierarchical.cyclic is

   procedure initialize (a_scheduler : in out hierarchical_cyclic_scheduler) is
   begin
      reset (a_scheduler);
      a_scheduler.parameters.scheduler_type := hierarchical_cyclic_protocol;
   end initialize;

   function copy
     (a_scheduler : in hierarchical_cyclic_scheduler)
      return generic_scheduler_ptr
   is
      ptr : hierarchical_cyclic_scheduler_ptr;

   begin

      ptr := new hierarchical_cyclic_scheduler;

      ptr.parameters         := a_scheduler.parameters;
      ptr.previously_elected := a_scheduler.previously_elected;

      return generic_scheduler_ptr (ptr);

   end copy;

   procedure check_before_scheduling
     (my_scheduler   : in hierarchical_cyclic_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

   begin
      null;
   end check_before_scheduling;

   procedure specific_scheduler_initialization
     (my_scheduler       : in out hierarchical_cyclic_scheduler;
      si                 : in out scheduling_information;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      my_tasks           : in out tasks_set;
      my_schedulers      : in     scheduler_table;
      my_resources       : in out resources_set;
      my_buffers         : in out buffers_set;
      my_messages        : in     messages_set;
      msg                : in out Unbounded_String)
   is

   begin

      -- Reset index on local address space scheduler
      --
      my_scheduler.address_space_index := 0;

      -- Reset address space activation
      --
      my_scheduler.last_release := 0;

      -- Save local address schedulers
      --
      my_scheduler.local_scheduler := my_schedulers;

      -- Do local scheduler initializations
      --
      for i in 0 .. my_scheduler.local_scheduler.nb_entries - 1 loop
         specific_scheduler_initialization
           (my_scheduler.local_scheduler.entries (i).scheduler.all,
            si,
            processor_name,
            address_space_scheduler_ptr
              (my_scheduler.local_scheduler.entries (i))
              .corresponding_address_space
              .name,
            my_tasks,
            my_schedulers,
            my_resources,
            my_buffers,
            my_messages,
            msg);
      end loop;

   end specific_scheduler_initialization;

   procedure do_election
     (my_scheduler       : in out hierarchical_cyclic_scheduler;
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

      a_item : time_unit_event_ptr;

   begin

      -- Call the scheduler associated to the current address space
      -- No method dispatch => some scheduler are not allowed
      --

      put_debug
        ("Active address space is " &
         To_String
           (address_space_scheduler_ptr
              (my_scheduler.local_scheduler.entries
                 (my_scheduler.address_space_index))
              .corresponding_address_space
              .name),
         very_verbose);

      do_election
        (my_scheduler.local_scheduler.entries
           (my_scheduler.address_space_index)
           .scheduler.all,
         si,
         result,
         msg,
         current_time,
         processor_name,
         address_space_scheduler_ptr
           (my_scheduler.local_scheduler.entries
              (my_scheduler.address_space_index))
           .corresponding_address_space
           .name,
         core_name,
         options,
         event_to_generate,
         elected,
         no_task);

      ---------------------------------------------------
      --  Update variables for address space scheduling
      ---------------------------------------------------

      -- generate an address space activation event for this first entry in the scheduling table
      -- in the beginning of the simulation
      --
      if current_time = 0 then
         if event_to_generate (address_space_activation) then
            a_item := new time_unit_event (address_space_activation);
            a_item.activation_address_space :=
              address_space_scheduler_ptr
                (my_scheduler.local_scheduler.entries
                   (my_scheduler.address_space_index))
                .corresponding_address_space
                .name;
            a_item.duration :=
                my_scheduler.local_scheduler.entries
                   (my_scheduler.address_space_index)
                   .scheduler.parameters.capacity;
            add (result.all, 0, a_item);
         end if;
      end if;

      -- Check if we must switch the activated/schedulable address space
      --
      if my_scheduler.last_release +
                my_scheduler.local_scheduler.entries
                   (my_scheduler.address_space_index)
                   .scheduler.parameters.capacity =
        current_time
      then
         -- Address space switching
         --

         put_debug ("Change of running address space", very_verbose);

         -- generate address space activation event
         --
         if event_to_generate (address_space_activation) then
            a_item := new time_unit_event (address_space_activation);
            a_item.activation_address_space :=
              address_space_scheduler_ptr
                (my_scheduler.local_scheduler.entries
                   (my_scheduler.address_space_index))
                .corresponding_address_space
                .name;
            a_item.duration :=
                my_scheduler.local_scheduler.entries
                   (my_scheduler.address_space_index)
                   .scheduler.parameters.capacity;
            add (result.all, current_time, a_item);
         end if;

         -- Do Address space switch
         --
         my_scheduler.last_release := current_time;

         my_scheduler.address_space_index :=
           my_scheduler.address_space_index + 1;
         if my_scheduler.local_scheduler.entries
             (my_scheduler.address_space_index) =
           null
         then
            my_scheduler.address_space_index := 0;
         end if;

      end if;

   end do_election;

   function build_resource
     (my_scheduler : in hierarchical_cyclic_scheduler;
      a_resource   :    generic_resource_ptr) return shared_resource_ptr
   is
      new_a_resource : fixed_priority_resource_ptr;
   begin

      new_a_resource        := new fixed_priority_resource;
      new_a_resource.shared := a_resource;

      -- Set priority ceiling of the resource
      --
      new_a_resource.priority_ceiling := Low_Priority;

      return shared_resource_ptr (new_a_resource);
   end build_resource;

   function build_tcb
     (my_scheduler : in hierarchical_cyclic_scheduler;
      a_task       :    generic_task_ptr) return tcb_ptr
   is
      a_tcb : hpf_tcb_ptr;
   begin
      a_tcb := new hpf_tcb;
      initialize (tcb (a_tcb.all), a_task);
      initialize (fixed_priority_tcb (a_tcb.all));
      initialize (a_tcb.all);
      return tcb_ptr (a_tcb);
   end build_tcb;

end scheduler.hierarchical.cyclic;
