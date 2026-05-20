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

with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with scheduler.fixed_priority;     use scheduler.fixed_priority;
with scheduler.fixed_priority.hpf; use scheduler.fixed_priority.hpf;
with Text_IO;                      use Text_IO;
with debug;                        use debug;
with expressions;                  use expressions;
with Ada.IO_Exceptions;            use Ada.IO_Exceptions;
with Ada.Exceptions;               use Ada.Exceptions;
with GNAT.Current_Exception;       use GNAT.Current_Exception;
with translate;                    use translate;

package body scheduler.hierarchical.offline is

   procedure initialize
     (a_scheduler : in out hierarchical_offline_scheduler)
   is
   begin
      reset (a_scheduler);
      a_scheduler.parameters.scheduler_type := hierarchical_cyclic_protocol;
   end initialize;

   function copy
     (a_scheduler : in hierarchical_offline_scheduler)
      return generic_scheduler_ptr
   is
      ptr : hierarchical_offline_scheduler_ptr;

   begin

      ptr := new hierarchical_offline_scheduler;

      ptr.parameters         := a_scheduler.parameters;
      ptr.previously_elected := a_scheduler.previously_elected;

      return generic_scheduler_ptr (ptr);

   end copy;

   function get_event_table
     (my_scheduler : in hierarchical_offline_scheduler)
      return scheduling_table_ptr
   is
   begin
      return my_scheduler.address_space_scheduling_table;
   end get_event_table;

   procedure set_event_table
     (my_scheduler : in out hierarchical_offline_scheduler;
      a_table      : in     scheduling_table_ptr)
   is
   begin
      my_scheduler.address_space_scheduling_table := a_table;
   end set_event_table;

   procedure check_before_scheduling
     (my_scheduler   : in hierarchical_offline_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

   begin
      null;
   end check_before_scheduling;

   procedure specific_scheduler_initialization
     (my_scheduler       : in out hierarchical_offline_scheduler;
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

      my_iterator : tasks_iterator;
      a_task      : generic_task_ptr;
      addr_name   : Unbounded_String;
      ok          : Boolean;

   begin

      -- Save local address space schedulers
      --
      my_scheduler.local_scheduler := my_schedulers;

      -- Reset address space activation
      --
      my_scheduler.last_release := 0;

      -- We start with the first entry of the address space
      -- offline scheduling table
      --
      my_scheduler.scheduling_table_index := 0;

      -- We check that we have an address space scheduling table
      --
      if my_scheduler.address_space_scheduling_table = null then
         Raise_Exception
           (parametric_file_error'identity,
            To_String
              (lb_file (Current_Language) &
               lb_colon &
               my_scheduler.parameters
                 .user_defined_scheduler_source_file_name &
               lb_comma &
               " Off-line address space scheduling table is mandatory"));

      end if;

      -- We check that the address space scheduling table has data for ONE and only ONE processor
      --
      if my_scheduler.address_space_scheduling_table.nb_entries /= 1 then
         Raise_Exception
           (parametric_file_error'identity,
            To_String
              (lb_file (Current_Language) &
               lb_colon &
               my_scheduler.parameters
                 .user_defined_scheduler_source_file_name &
               lb_comma &
               " Off-line address space scheduling table must contain events of one and only one processor here"));

      end if;

      -- We check we the address space scheduling table is not empty
      --
      if my_scheduler.address_space_scheduling_table.entries (0).data.result
          .nb_entries <=
        0
      then
         Raise_Exception
           (parametric_file_error'identity,
            To_String
              (lb_file (Current_Language) &
               lb_colon &
               my_scheduler.parameters
                 .user_defined_scheduler_source_file_name &
               lb_comma &
               " Empty off-line address space scheduling table not allowed here"));

      end if;

      -- We check that the event table for address_space scheduling has
      -- an address space activation event for all of its entries
      --
      for i in
        0 ..
            my_scheduler.address_space_scheduling_table.entries (0).data.result
              .nb_entries -
            1
      loop
         if my_scheduler.address_space_scheduling_table.entries (0).data.result
             .entries
             (i)
             .data
             .type_of_event /=
           address_space_activation
         then
            Raise_Exception
              (parametric_file_error'identity,
               To_String
                 (lb_file (Current_Language) &
                  lb_colon &
                  my_scheduler.parameters
                    .user_defined_scheduler_source_file_name &
                  lb_comma &
                  " Off-line address space scheduling table must only contain address_space_activation events"));

         end if;
      end loop;

      -- We check that each address space has at LEAST ONE task
      --
      for i in
        0 ..
            my_scheduler.address_space_scheduling_table.entries (0).data.result
              .nb_entries -
            1
      loop
         if my_scheduler.address_space_scheduling_table.entries (0).data.result
             .entries
             (i)
             .data
             .type_of_event =
           address_space_activation
         then
            addr_name :=
              my_scheduler.address_space_scheduling_table.entries (0).data
                .result
                .entries
                (i)
                .data
                .activation_address_space;

            ok := False;
            reset_iterator (my_tasks, my_iterator);
            loop
               current_element (my_tasks, a_task, my_iterator);
               if (addr_name = a_task.address_space_name) then
                  ok := True;
               end if;
               exit when is_last_element (my_tasks, my_iterator);

               next_element (my_tasks, my_iterator);
            end loop;

            if not ok then
               Raise_Exception
                 (parametric_file_error'identity,
                  To_String
                    (lb_file (Current_Language) &
                     lb_colon &
                     my_scheduler.parameters
                       .user_defined_scheduler_source_file_name &
                     lb_comma &
                     addr_name &
                     lb_comma &
                     " Each address space specificed in a off-line address space scheduling table must have only one task"));

            end if;

         end if;
      end loop;

-- We check that the event table, for its first entry, has an event for time 0
      --
      if my_scheduler.address_space_scheduling_table.entries (0).data.result
          .entries
          (0)
          .item /=
        0
      then
         Raise_Exception
           (parametric_file_error'identity,
            To_String
              (lb_file (Current_Language) &
               lb_colon &
               my_scheduler.parameters
                 .user_defined_scheduler_source_file_name &
               lb_comma &
               " First entry of off-line address space scheduling table must provide an event for time zero "));
      end if;

   -- Look for the local scheduler to run in the next units of time
   -- i.e. scheduler for the first entry of the address space scheduling table
      --
      for i in 0 .. my_scheduler.local_scheduler.nb_entries - 1 loop
         if address_space_scheduler_ptr
             (my_scheduler.local_scheduler.entries (i))
             .corresponding_address_space
             .name =
           my_scheduler.address_space_scheduling_table.entries (0).data.result
             .entries
             (0)
             .data
             .activation_address_space
         then
            my_scheduler.address_space_scheduler_index := i;
            exit;
         end if;

      end loop;

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
     (my_scheduler       : in out hierarchical_offline_scheduler;
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

      -- Check if we must switch the activated/schedulable address space
      --
      if my_scheduler.last_release +
        my_scheduler.address_space_scheduling_table.entries (0).data.result
          .entries
          (my_scheduler.scheduling_table_index)
          .data
          --.duration -1  = current_time
          .duration =
        current_time
      then
         -- Address space switching
         --
         put_debug
           ("Change of running address space at core " &
            To_String (my_scheduler.corresponding_core_unit.name),
            very_verbose);

         -- do Address space switch
         --
         my_scheduler.scheduling_table_index :=
           +my_scheduler.scheduling_table_index + 1;
         if my_scheduler.scheduling_table_index =
           my_scheduler.address_space_scheduling_table.entries (0).data.result
             .nb_entries
         then
            my_scheduler.scheduling_table_index := 0;
         end if;

         -- Reset release_time of the scheduler
         --
         my_scheduler.last_release := current_time;

         -- Look for the local scheduler to run in the next units of time
         --
         for i in 0 .. my_scheduler.local_scheduler.nb_entries - 1 loop
            if address_space_scheduler_ptr
                (my_scheduler.local_scheduler.entries (i))
                .corresponding_address_space
                .name =
              my_scheduler.address_space_scheduling_table.entries (0).data
                .result
                .entries
                (my_scheduler.scheduling_table_index)
                .data
                .activation_address_space
            then
               my_scheduler.address_space_scheduler_index := i;
               exit;
            end if;
         end loop;

         -- generate address space activation event
         --
         if event_to_generate (address_space_activation) then
            a_item := new time_unit_event (address_space_activation);
            a_item.activation_address_space :=
              my_scheduler.address_space_scheduling_table.entries (0).data
                .result
                .entries
                (my_scheduler.scheduling_table_index)
                .data
                .activation_address_space;
            a_item.duration :=
              my_scheduler.address_space_scheduling_table.entries (0).data
                .result
                .entries
                (my_scheduler.scheduling_table_index)
                .data
                .duration;
            add (result.all, current_time, a_item);
         end if;

      end if;

      -- generate an address space activation event for this first entry in the scheduling table
      -- in the beginning of the simulation
      --
      if current_time = 0 then
         if event_to_generate (address_space_activation) then
            if
              (my_scheduler.address_space_scheduling_table.nb_entries > 0)
            then
               if
                 (my_scheduler.address_space_scheduling_table.entries (0).data
                    .result
                    .nb_entries >
                  0)
               then
                  a_item := new time_unit_event (address_space_activation);
                  a_item.activation_address_space :=
                    my_scheduler.address_space_scheduling_table.entries (0)
                      .data
                      .result
                      .entries
                      (0)
                      .data
                      .activation_address_space;
                  a_item.duration :=
                    my_scheduler.address_space_scheduling_table.entries (0)
                      .data
                      .result
                      .entries
                      (0)
                      .data
                      .duration;
                  add (result.all, 0, a_item);
               end if;
            end if;
         end if;
      end if;

      -- Call the scheduler associated to the current address space
      -- No method dispatch => some schedulers are not allowed
      --

      put_debug
        ("Active address space is " &
         To_String
           (address_space_scheduler_ptr
              (my_scheduler.local_scheduler.entries
                 (my_scheduler.address_space_scheduler_index))
              .corresponding_address_space
              .name) &
         " at core " &
         To_String (my_scheduler.corresponding_core_unit.name),
         very_verbose);

      do_election
        (my_scheduler.local_scheduler.entries
           (my_scheduler.address_space_scheduler_index)
           .scheduler.all,
         si,
         result,
         msg,
         current_time,
         processor_name,
         address_space_scheduler_ptr
           (my_scheduler.local_scheduler.entries
              (my_scheduler.address_space_scheduler_index))
           .corresponding_address_space
           .name,
         core_name,
         options,
         event_to_generate,
         elected,
         no_task);

   end do_election;

   function build_resource
     (my_scheduler : in hierarchical_offline_scheduler;
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
     (my_scheduler : in hierarchical_offline_scheduler;
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

end scheduler.hierarchical.offline;
