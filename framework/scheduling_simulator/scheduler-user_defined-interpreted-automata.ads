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

with section_set; use section_set;
use section_set.package_generic_section_set;
with Automaton; use Automaton;
use Automaton.Package_Automaton_Status;

package scheduler.user_defined.interpreted.automata is

   type automata_user_defined_scheduler is
     new interpreted_user_defined_scheduler with private;
   type automata_user_defined_scheduler_ptr is
     access all automata_user_defined_scheduler'class;

   procedure initialize (a_scheduler : in out automata_user_defined_scheduler);

   function copy
     (a_scheduler : in automata_user_defined_scheduler)
      return generic_scheduler_ptr;

   procedure set_automaton_name
     (my_scheduler : in out automata_user_defined_scheduler;
      to_set       : in     Unbounded_String);

   function get_automaton_name
     (my_scheduler : in automata_user_defined_scheduler)
      return Unbounded_String;

   procedure put (my_scheduler : in automata_user_defined_scheduler);

   procedure do_election
     (my_scheduler       : in out automata_user_defined_scheduler;
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
      no_task            : in out Boolean);

   procedure specific_scheduler_initialization
     (my_scheduler       : in out automata_user_defined_scheduler;
      si                 : in out scheduling_information;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      my_tasks           : in out tasks_set;
      my_schedulers      : in     scheduler_table;
      my_resources       : in out resources_set;
      my_buffers         : in out buffers_set;
      my_messages        : in     messages_set;
      msg                : in out Unbounded_String);

   -- Check the current state of the automaton : is the transition reachable ?
   --  from the current automaton location
   --
   procedure check_reachability
     (my_scheduler : in out automata_user_defined_scheduler;
      a_transition                     : in out transition_status;
      automaton_name_of_the_transition : in     Unbounded_String);

   -- Check synchronization : is the transition awaiting another one ?
   --
   procedure check_synchronization_constraints
     (my_scheduler      : in out automata_user_defined_scheduler;
      a_transition      : in out transition_status;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      msg               : in out Unbounded_String;
      current_time      : in     Natural;
      processor_name    : in     Unbounded_String;
      options           : in     scheduling_option;
      event_to_generate : in     time_unit_event_type_boolean_table;
      elected           : in out tasks_range;
      no_task           : in out Boolean);

   -- Check the guard : is the guard true ?
   --
   procedure check_guard_constraints
     (my_scheduler : in out automata_user_defined_scheduler;
      a_transition : in out transition_status);

   -- Check the delay statements : can we wake up the transition ?
   --
   procedure check_delay_constraints
     (my_scheduler : in out automata_user_defined_scheduler;
      a_transition                     : in out transition_status;
      automaton_name_of_the_transition : in     Unbounded_String;
      current_time                     : in     Natural);

   -- This sub-program fires a transition
   --
   procedure fire_a_transition
     (my_scheduler : in out automata_user_defined_scheduler;
      a_transition                     : in out transition_status;
      automaton_name_of_the_transition : in     Unbounded_String;
      si                               : in out scheduling_information;
      result                           : in out scheduling_sequence_ptr;
      msg                              : in out Unbounded_String;
      current_time                     : in     Natural;
      processor_name                   : in     Unbounded_String;
      options                          : in     scheduling_option;
      event_to_generate                : in time_unit_event_type_boolean_table;
      elected                          : in out tasks_range;
      no_task                          : in out Boolean;
      an_election_section_was_run      : in out Boolean);

private

   type automata_user_defined_scheduler is new interpreted_user_defined_scheduler with
   record

      -- Name of the automaton which is supposed to model the scheduler of the
      -- processor
      --
      automaton_name : Unbounded_String;

      -- Stores the set of sections with their code
      --
      root_statement_pointer : sections_set;

      -- The shedulers of each address space
      --
      local_scheduler : scheduler_table;

      -- Variable which store simulation data
      -- (status of automata and transitions)
      --
      transition_data : transition_status_table;
      automaton_data  : automaton_status_table;
   end record;

end scheduler.user_defined.interpreted.automata;
