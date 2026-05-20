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

with io_tools;                      use io_tools;
with Ada.IO_Exceptions;             use Ada.IO_Exceptions;
with Ada.Strings.Unbounded.Text_IO; use Ada.Strings.Unbounded.Text_IO;
with Ada.Exceptions;                use Ada.Exceptions;
with translate;                     use translate;
with scheduler_io;                  use scheduler_io;
with Statements;                    use Statements;
with Simulations;                   use Simulations;
with Simulations.extended;          use Simulations.extended;
with Parameters;                    use Parameters;
use Parameters.User_Defined_Parameters_Table_Package;
with Parser;             use Parser;
with debug;              use debug;
with Sections;           use Sections;
with Automaton.extended; use Automaton.extended;
use Automaton.Transition_Lists_Package;
use Automaton.Package_Transition_Status;
with GNAT.Current_Exception; use GNAT.Current_Exception;
with Interpreter.extended;   use Interpreter.extended;

with Text_IO; use Text_IO;

package body scheduler.user_defined.interpreted.automata is

   -- Sketch of the simulation engine algorithm for an automaton user-defined
   -- scheduler.
   -- This algorithm is performed at each unit of time by the Do_Election
   -- sub-program
   --
   -- Step at nth unit of time :
   --    1.  Change transition status :
   --         1.1 Transition which are "ready", "rendezvous" or "guarded" must
   --             be set to "ready"
   --         1.2 Transition which are "pended" : stay "pended" if the delay
   --             is not exhausted. If the
   --             delay is exhausted, update the current location (transition
   --             outgoing location) and
   --             becomes "ready"
   --    2.  Check reachability for all transition : set transition status to
   --        "unreachable"
   --        transitions which are not outgoing transition of the current
   --        location for the corresponding automaton.
   --        We only analyze transitions with has
   --        a "ready" status.
   --    3.  Check guard (eg. timed constraints) for all transition.
   --        We only analyze transitions with has
   --        a "ready" status.
   --        A transition blocked due to a guard constraint see its status
   --        becoming "guarded".
   --    4.  Check synchronization constraint for all transitions.
   --        We only analyze transitions with has
   --        a "ready" status.
   --        A transition blocked due to a synchronization constraint see its
   --        status becoming "rendezvous".
   --    5.  Fire all transitions with a "ready" transition status.
   --        It means :
   --            5.1.  Run delay/clock statement (if so). This may lead to
   --                  change the
   --                  wakeup automaton date and its state to "pended"
   --            5.2.  Run sections. It means, run synchronization with the
   --                  scheduling engine.
   --                  Section run there can be priority, start, election or
   --                  task_activation section.
   --                  If an election section is run, then, the Do_Election
   --                  sub-program is over.
   --                  Depending on which automaton the election section
   --                  belong, Do_Election chose a task
   --                  in the task set corresponding to the given
   --                  processor/address space automaton.
   --            5.3.  Update current location (transition outgoing location)
   --                  for all fired transition
   --                  except for those which are "pended"
   --    6.  Restart at step 1 if, at least one transition is fire at step 5.
   --
   --

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
      no_task            : in out Boolean)
   is

      first_step           : Boolean := True;
      second_step          : Boolean := True;
      run_a_transition     : Boolean := False;
      run_election_section : Boolean := False;

   begin

      -- By default, no task is elected : it's a way
      -- to safely schedule an user_defined scheduler without
      -- a correctly designed code
      --
      no_task := True;

      -- Load statement execution, we load writtable user defined variable
      --
      load_read_write_interpreter_variables (my_scheduler, si, processor_name);

      -- We update simulation engine variables which has to update
      -- because of the task which was running at the previous unit of time
      --
      update_interpreter_variables_after_task_execution
        (my_scheduler,
         si,
         current_time,
         processor_name,
         empty_string,
         options);

      -- Transitions are run until an election section is called or
      -- all transitions are blocked (no task to run)
      --
      while (first_step or second_step) loop

         --    1.  Change transition status :
         --         1.1 Transition which are "ready", "rendezvous" or
         --"guarded" must be set to "ready"
         --         1.2 Transition which are "pended" : stay "pended" if the
         --delay is not exhausted. If the
         --             delay is exhausted, update the current location
         --(transition outgoing location) and
         --             becomes "ready"
         --
         for i in 0 .. my_scheduler.transition_data.nb_entries - 1 loop
            if my_scheduler.transition_data.entries (i).data.status /=
              pended
            then
               my_scheduler.transition_data.entries (i).data.status := ready;
            else
               check_delay_constraints
                 (my_scheduler,
                  my_scheduler.transition_data.entries (i).data,
                  my_scheduler.transition_data.entries (i).item,
                  current_time);
            end if;
         end loop;

         --    2.  Check reachability for all transition : set transition
         --        status to "unreachable"
         --        transitions which are not outgoing transition of the current
         --        location for the corresponding automaton.
         --        We only analyze transitions with has
         --        a "ready" status.
         --    3.  Check guard (eg. timed constraints) for all transition.
         --        We only analyze transitions with has
         --        a "ready" status.
         --
         for i in 0 .. my_scheduler.transition_data.nb_entries - 1 loop
            check_reachability
              (my_scheduler,
               my_scheduler.transition_data.entries (i).data,
               my_scheduler.transition_data.entries (i).item);

            check_guard_constraints
              (my_scheduler,
               my_scheduler.transition_data.entries (i).data);
         end loop;

         --    4.  Check synchronization constraint for all transitions.
         --        We only analyze transitions with has
         --        a "ready" status.
         --        A transition blocked due to a synchronization constraint
         --        see its status becoming "rendezvous".
         --
         for i in 0 .. my_scheduler.transition_data.nb_entries - 1 loop

            check_synchronization_constraints
              (my_scheduler,
               my_scheduler.transition_data.entries (i).data,
               si,
               result,
               msg,
               current_time,
               processor_name,
               options,
               event_to_generate,
               elected,
               no_task);
         end loop;

         --    5.  Fire all transitions with a "ready" transition status.
         --        It means :
         --            5.1.  Run delay/clock statement (if so). This may lead
         --                  to change the
         --                  wakeup automaton date and its state to "pended"
         --            5.2.  Run sections. It means, run synchronization with
         --                  the scheduling engine.
         --                  Section run there can be priority, start,
         --                  election or task_activation section.
         --                  If an election section is run, then, the
         --                  Do_Election sub-program is over.
         --                  Depending on which automaton the election section
         --                  belong, Do_Election chose a task
         --                  in the task set corresponding to the given
         --                  processor/address space automaton.
         --            5.3.  Update current location (transition outgoing
         --                  location) for all fired transition
         --                  except for those which are "pended"
         --
         run_a_transition := False;

         for i in 0 .. my_scheduler.transition_data.nb_entries - 1 loop

            -- Is the transition ready ? if so, fire it
            --
            if my_scheduler.transition_data.entries (i).data.status =
              ready
            then
               run_election_section := False;
               fire_a_transition
                 (my_scheduler,
                  my_scheduler.transition_data.entries (i).data,
                  my_scheduler.transition_data.entries (i).item,
                  si,
                  result,
                  msg,
                  current_time,
                  processor_name,
                  options,
                  event_to_generate,
                  elected,
                  no_task,
                  run_election_section);

               if run_election_section then

                  -- We update variables which has a clock type by
                  -- incrementing their value
                  --
                  for i in 0 .. my_scheduler.variables_table.nb_entries - 1
                  loop
                     if
                       (get_type
                          (my_scheduler.variables_table.entries (i)
                             .variable.all) =
                        simulation_clock)
                     then
                        my_scheduler.variables_table.entries (i).simulation
                          .integer_value :=
                          my_scheduler.variables_table.entries (i).simulation
                            .integer_value +
                          1;
                     end if;
                     if
                       (get_type
                          (my_scheduler.variables_table.entries (i)
                             .variable.all) =
                        simulation_array_clock)
                     then
                        for j in integer_table'range loop
                           my_scheduler.variables_table.entries (i).simulation
                             .integer_table_value
                             (j) :=
                             my_scheduler.variables_table.entries (i)
                               .simulation
                               .integer_table_value
                               (j) +
                             1;
                        end loop;
                     end if;
                  end loop;

                  -- After statement execution, we
                  -- save some task run time information
                  --
                  save_read_write_interpreter_variables
                    (my_scheduler,
                     si,
                     processor_name);

                  return;
               end if;
               run_a_transition := True;
            end if;
         end loop;

         --    6.  Restart at step 1 if, at least one transition is fired at
         --        step 5.
         --
         if run_a_transition then
            first_step  := True;
            second_step := True;
         end if;
         if (not first_step) and (not run_a_transition) then
            second_step := False;
         end if;
         if not run_a_transition then
            first_step := False;
         end if;

      end loop;

      -- No task was elected
      -- save simuluation data
      --

      -- We update variables which has a clock type by incrementing their value
      --
      for i in 0 .. my_scheduler.variables_table.nb_entries - 1 loop
         if
           (get_type (my_scheduler.variables_table.entries (i).variable.all) =
            simulation_clock)
         then
            my_scheduler.variables_table.entries (i).simulation
              .integer_value :=
              my_scheduler.variables_table.entries (i).simulation
                .integer_value +
              1;
         end if;
         if
           (get_type (my_scheduler.variables_table.entries (i).variable.all) =
            simulation_array_clock)
         then
            for j in integer_table'range loop
               my_scheduler.variables_table.entries (i).simulation
                 .integer_table_value
                 (j) :=
                 my_scheduler.variables_table.entries (i).simulation
                   .integer_table_value
                   (j) +
                 1;
            end loop;
         end if;
      end loop;

      -- After statement execution, we
      -- save some task run time information
      --
      save_read_write_interpreter_variables (my_scheduler, si, processor_name);

   end do_election;

   --    5.  Fire all transitions with a "ready" transition status.
   --        It means :
   --            5.1.  Run delay/clock statement (if so). This may lead to
   --                  change the
   --                  wakeup automaton date and its state to "pended"
   --            5.2.  Run sections. It means, run synchronization with the
   --                  scheduling engine.
   --                  Section run there can be priority, start, election or
   --                  task_activation section.
   --                  If an election section is run, then, the Do_Election
   --                  sub-program is over.
   --                  Depending on which automaton the election section
   --                  belong, Do_Election chose a task
   --                  in the task set corresponding to the given
   --                  processor/address space automaton.
   --            5.3.  Update current location (transition outgoing location)
   --                  for all fired transition
   --                  except for those which are "pended"
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
      an_election_section_was_run      : in out Boolean)
   is

      found_a_section_to_run    : Boolean := False;
      a_section                 : generic_section_ptr;
      election_on_processor     : Unbounded_String;
      election_on_address_space : Unbounded_String;
      found_automaton           : Boolean;

   begin

      put_debug
        ("fire transition (" &
         automaton_name_of_the_transition &
         ") : " &
         a_transition.code.name);

      -- Run the clock statement of the transition
      -- This statement delays the transition firing if a delay statement is
      -- present
      -- otherwhise, this statement update user-defiend variables
      --
      if a_transition.code.clocks /= null then
         declare
            simu_ptr : simulation_value_ptr;
         begin

            -- is it a "delay" statement or an assignement statement ?
            --
            if a_transition.code.clocks.statement_type =
              clock_statement_type
            then

               -- It's a delay statement
               -- Read the delay expression and save it into the transition
               -- status descriptor
               --
               simu_ptr :=
                 value_of
                   (clock_statement_ptr (a_transition.code.clocks).lvalue.all,
                    my_scheduler.variables_table,
                    a_transition.code.clocks.line_number,
                    a_transition.code.clocks.file_name);

               if (simu_ptr.ptype /= simulation_clock) and
                 (simu_ptr.ptype /= simulation_integer)
               then
                  Raise_Exception
                    (type_error'identity,
                     "Delay statement expression ; transition name " &
                     To_String (a_transition.code.name) &
                     To_String
                       ("; " & lb_uncompatible_type_error (Current_Language)));
               end if;

               a_transition.wakeup_time :=
                 current_time + simu_ptr.integer_value;
               a_transition.status := pended;
               free (simu_ptr);

            else

               -- It's an assignment statement which updates user-defined
               -- variables ...
               -- run it !
               --
               dispatch
                 (a_transition.code.clocks,
                  priority_type,
                  processor_name,
                  si,
                  my_scheduler.variables_table,
                  msg);
            end if;

         exception
            when Constraint_Error =>
               Raise_Exception
                 (statement_error'identity,
                  "transition " &
                  To_String (a_transition.code.name) &
                  " ; Exception raised :" &
                  Exception_Name &
                  "; " &
                  Exception_Message);
            when Storage_Error =>
               Raise_Exception
                 (statement_error'identity,
                  "transition " &
                  To_String (a_transition.code.name) &
                  " ; Exception raised :" &
                  Exception_Name &
                  "; " &
                  Exception_Message);
            when Program_Error =>
               Raise_Exception
                 (statement_error'identity,
                  "transition " &
                  To_String (a_transition.code.name) &
                  " ; Exception raised :" &
                  Exception_Name &
                  "; " &
                  Exception_Message);
         end;
      end if;

      -- Run the synchronization statement of the transition
      --
      if a_transition.code.synchronization /= null then
         begin
            found_a_section_to_run := True;
            a_section              :=
              generic_section_ptr
                (search_section
                   (Root_Statement_Pointer,
                    a_transition.code.synchronization.name));
         exception
            when section_not_found =>
               found_a_section_to_run := False;
         end;

         -- 3 cases : 1) it is an election section (synchronization between an
         --              automaton and the simulation engine)
         --           2) it is a priority section (synchronization between an
         --              automaton and the simulation engine)
         --           3) it is a synchronization between two automata
         --
         if found_a_section_to_run then

            if a_section.section_type = election_type then
               put_debug
                 ("Run election section : " &
                  a_transition.code.synchronization.name);

               -- The return statement must be run either on the processor,
               -- either on
               -- the address space depending on the automaton which call the
               -- election_section
               -- If no processor nor address space can be detected, it means
               -- that the Cheddar program is wrong !
               --

               -- 3 cases can be found at this step :
               --
               -- 1) "Automaton_Name_Of_The_Transition" is equal to the
               --    processor automaton ...
               --    it means the scheduling must select amound the tasks of
               --    the processor
               -- 2) If we found an address space which has an automaton name
               --    equal to "Automaton_Name_Of_The_Transition" ...
               --    it means the scheduling must select amound the tasks of
               --    this address space
               -- 3) Otherwise, something is wrong ! (may be the automaton
               --    name ??), then we raise an exception !
               --
               if
                 (automaton_name_of_the_transition =
                  my_scheduler.automaton_name)
               then
                  election_on_processor     := processor_name;
                  election_on_address_space := empty_string;
                  put_debug ("Run an election section on address space");
               else
                  found_automaton := False;
                  for i in 0 .. my_scheduler.local_scheduler.nb_entries - 1
                  loop
                     if my_scheduler.local_scheduler.entries (i).scheduler
                         .parameters
                         .scheduler_type =
                       automata_user_defined_protocol
                     then
                        if get_automaton_name
                            (automata_user_defined_scheduler
                               (my_scheduler.local_scheduler.entries (i)
                                  .scheduler.all)) =
                          automaton_name_of_the_transition
                        then
                           election_on_processor     := empty_string;
                           election_on_address_space :=
                             address_space_scheduler_ptr
                               (my_scheduler.local_scheduler.entries (i))
                               .corresponding_address_space
                               .name;
                           found_automaton := True;
                        end if;
                     end if;
                  end loop;

                  if not found_automaton then
                     Raise_Exception
                       (statement_error'identity,
                        "Return statement ; transition name " &
                        To_String (a_transition.code.name) &
                        "; Unable to know if the election " &
                        To_String (a_transition.code.synchronization.name) &
                        " must be run on the processor task set or on an address space task set");
                  end if;
               end if;

               -- Run the election section now
               --
               dispatch_return_statement
                 (my_scheduler,
                  computation_section_ptr (a_section).first_statement,
                  si,
                  current_time,
                  election_on_processor,
                  election_on_address_space,
                  options,
                  elected,
                  no_task);
               an_election_section_was_run := True;
            else
               put_debug
                 ("Run priority section : " &
                  a_transition.code.synchronization.name);
               dispatch
                 (computation_section_ptr (a_section).first_statement,
                  priority_type,
                  processor_name,
                  si,
                  my_scheduler.variables_table,
                  msg);
            end if;
         end if;
      end if;

      -- find the associated automaton and change its current state
      --
      if a_transition.status = pended then
         check_delay_constraints
           (my_scheduler,
            a_transition,
            automaton_name_of_the_transition,
            current_time);
      else
         for i in 0 .. my_scheduler.automaton_data.nb_entries - 1 loop
            if
              (my_scheduler.automaton_data.entries (i).item =
               automaton_name_of_the_transition)
            then
               if a_transition.code.from_state.name =
                 my_scheduler.automaton_data.entries (i).data.current_state
                   .name
               then
                  my_scheduler.automaton_data.entries (i).data.current_state :=
                    a_transition.code.to_state;
                  exit;
               end if;
            end if;
         end loop;
      end if;

   end fire_a_transition;

   --    1.  Change transition status :
   --         1.1 Transition which are "ready", "rendezvous" or "guarded" must
   --             be set to "ready"
   --         1.2 Transition which are "pended" : stay "pended" if the delay
   --             is not exhausted. If the
   --             delay is exhausted, update the current location (transition
   --             outgoing location) and
   --             becomes "ready"
   --
   procedure check_delay_constraints
     (my_scheduler : in out automata_user_defined_scheduler;
      a_transition                     : in out transition_status;
      automaton_name_of_the_transition : in     Unbounded_String;
      current_time                     : in     Natural)
   is

   begin
      if a_transition.status = pended then

         if a_transition.wakeup_time <= current_time then
            -- find the associated automaton and change its current location
            --
            a_transition.status := ready;

            for i in 0 .. my_scheduler.automaton_data.nb_entries - 1 loop
               if
                 (my_scheduler.automaton_data.entries (i).item =
                  automaton_name_of_the_transition)
               then
                  if a_transition.code.from_state.name =
                    my_scheduler.automaton_data.entries (i).data.current_state
                      .name
                  then
                     my_scheduler.automaton_data.entries (i).data
                       .current_state :=
                       a_transition.code.to_state;
                     exit;
                  end if;
               end if;
            end loop;

         end if;

      end if;
   end check_delay_constraints;

   --    2.  Check reachability for all transition : set transition status to
   --        "unreachable"
   --        transitions which are not outgoing transition of the current
   --        location for the corresponding automaton.
   --        We only analyze transitions with has
   --        a "ready" status.
   --
   procedure check_reachability
     (my_scheduler : in out automata_user_defined_scheduler;
      a_transition                     : in out transition_status;
      automaton_name_of_the_transition : in     Unbounded_String)
   is

   begin

      if a_transition.status = ready then

         for i in 0 .. my_scheduler.automaton_data.nb_entries - 1 loop

            -- Find the right automaton
            --
            if
              (my_scheduler.automaton_data.entries (i).item =
               automaton_name_of_the_transition)
            then
               -- find the transition and check it according to the automaton
               --current states
               --
               if a_transition.code.from_state.name /=
                 my_scheduler.automaton_data.entries (i).data.current_state
                   .name
               then
                  a_transition.status := unreachable;
                  exit;
               end if;
            end if;
         end loop;
      end if;

   end check_reachability;

   --    4.  Check synchronization constraint for all transitions.
   --        We only analyze transitions with has
   --        a "ready" status.
   --        A transition blocked due to a synchronization constraint see its
   --        status becoming "rendezvous".
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
      no_task           : in out Boolean)
   is

      found_a_synchronization : Boolean := True;
      a_section               : generic_section_ptr;

   begin
      if a_transition.status = ready then

         -- A synchronization is present ... check it !
         --
         if a_transition.code.synchronization /= null then
            -- First, the synchronization has not to be a section to run
            --
            begin
               found_a_synchronization := False;
               a_section               :=
                 generic_section_ptr
                   (search_section
                      (Root_Statement_Pointer,
                       a_transition.code.synchronization.name));
            exception
               when section_not_found =>
                  found_a_synchronization := True;
            end;

            -- We found something which is not a section to run ...
            -- we found something which is a synchronization
            --
            if found_a_synchronization then

               a_transition.status := rendezvous;
               for i in 0 .. my_scheduler.transition_data.nb_entries - 1 loop

                  -- Now, to fire the current transition, we must check that
                  --the other
                  -- transition is also ready to be fired and that ....  the
                  --synchronization operator is
                  -- the opposite one
                  --
                  if my_scheduler.transition_data.entries (i).data.status =
                    ready
                  then
                     if my_scheduler.transition_data.entries (i).data.code
                         .synchronization /=
                       null
                     then
                        if my_scheduler.transition_data.entries (i).data.code
                            .synchronization
                            .synchronization_type /=
                          a_transition.code.synchronization
                            .synchronization_type
                        then
                           if my_scheduler.transition_data.entries (i).data
                               .code
                               .synchronization
                               .name =
                             a_transition.code.synchronization.name
                           then
                              a_transition.status := ready;
                           end if;
                        end if;
                     end if;
                  end if;
               end loop;

            end if;
         end if;

      end if;
   end check_synchronization_constraints;

   --    3.  Check guard (eg. timed constraints) for all transition.
   --        We only analyze transitions with has
   --        a "ready" status.
   --
   procedure check_guard_constraints
     (my_scheduler : in out automata_user_defined_scheduler;
      a_transition : in out transition_status)
   is

      simu_ptr : simulation_value_ptr;

   begin

      if a_transition.status = ready then

         if a_transition.code.guards /= null then

            simu_ptr :=
              value_of
                (a_transition.code.guards.all,
                 my_scheduler.variables_table);

            if simu_ptr.ptype /= simulation_boolean then
               Raise_Exception
                 (type_error'identity,
                  "Guard expression ; transition name " &
                  To_String (a_transition.code.name) &
                  To_String
                    (lb_comma &
                     lb_uncompatible_type_error (Current_Language)));
            end if;

            -- If the guard is false, block the transition
            --
            if not simu_ptr.boolean_value then
               a_transition.status := guarded;
            end if;
            free (simu_ptr);
         end if;
      end if;

   exception
      when Constraint_Error =>
         Raise_Exception
           (statement_error'identity,
            "transition " &
            To_String (a_transition.code.name) &
            " ; Exception raised :" &
            Exception_Name &
            "; " &
            Exception_Message);
      when Storage_Error =>
         Raise_Exception
           (statement_error'identity,
            "transition " &
            To_String (a_transition.code.name) &
            " ; Exception raised :" &
            Exception_Name &
            "; " &
            Exception_Message);
      when Program_Error =>
         Raise_Exception
           (statement_error'identity,
            "transition " &
            To_String (a_transition.code.name) &
            " ; Exception raised :" &
            Exception_Name &
            "; " &
            Exception_Message);

   end check_guard_constraints;

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
      msg                : in out Unbounded_String)
   is

      sc_file_content : Unbounded_String;
      sc_file_name    : Unbounded_String;

      var : variables_range;

      my_iterator         : sections_iterator;
      an_automaton_status : automaton_status;
      a_transition_status : transition_status;
      a_section           : generic_section_ptr;

      a_transition : transition_ptr;
      list_ite     : transition_lists_iterator;

   begin

      -- We should check the scheduler behavior syntax ...
      --
      Open_Input (my_scheduler.parameters.user_defined_scheduler_source);
      create_parametric_variables (Parser.Variables_Table, my_tasks);
      Parser.First_File
        (my_scheduler.parameters.user_defined_scheduler_source_file_name);
      Parser.Yyparse;

      --
      -- And now, read address spaces .sc files
      --
      my_scheduler.local_scheduler := my_schedulers;
      for i in 0 .. my_schedulers.nb_entries - 1 loop
         if my_schedulers.entries (i).scheduler /= null then
            if
              (get_name (my_schedulers.entries (i).scheduler.all) /=
               automata_user_defined_protocol) and
              (get_name (my_schedulers.entries (i).scheduler.all) /=
               no_scheduling_protocol)
            then
               Raise_Exception
                 (syntax_error'identity,
                  "Address space " &
                  To_String
                    (address_space_scheduler_ptr (my_schedulers.entries (i))
                       .corresponding_address_space
                       .name) &
                  " must own either an automaton user defined scheduler or no local scheduler");

            else

               -- We should check the local scheduler behavior syntax ...
               --
               if
                 (get_name (my_schedulers.entries (i).scheduler.all) =
                  automata_user_defined_protocol)
               then
                  begin
                     sc_file_name :=
                       get_behavior_file_name
                         (user_defined_scheduler
                            (my_schedulers.entries (i).scheduler.all));
                     if sc_file_name /= empty_string then
                        sc_file_content := read_sequential_file (sc_file_name);
                     end if;

                  exception
                     when Ada.IO_Exceptions.Name_Error =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              sc_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)) &
                           ", Name_Error");
                     when Ada.IO_Exceptions.Status_Error =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              sc_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)) &
                           ", Status_Error");
                     when Ada.IO_Exceptions.Mode_Error =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              sc_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)) &
                           ", Mode_Error");
                     when Ada.IO_Exceptions.Use_Error =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              sc_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)) &
                           ", Use_Error");
                     when Ada.IO_Exceptions.Device_Error =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              sc_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)) &
                           ", Device_Error");
                     when Ada.IO_Exceptions.End_Error =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              sc_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)) &
                           ", End_Error");
                     when Ada.IO_Exceptions.Data_Error =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              sc_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)) &
                           ", Data_Error");
                     when Ada.IO_Exceptions.Layout_Error =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              sc_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)) &
                           ", Layout_Error");
                     when others =>
                        Raise_Exception
                          (parametric_file_error'identity,
                           To_String
                             (lb_file (Current_Language) &
                              lb_colon &
                              sc_file_name &
                              lb_comma &
                              lb_can_not_open_file (Current_Language)));
                  end;

                  Open_Input (sc_file_content);
                  Parser.Next_File (sc_file_name);
                  Parser.Yyparse;

               end if;

            end if;
         end if;
      end loop;

      -------------------------------------------------------------------------
      ---
      -- Initialize the set of variables of the user-defined scheduler
      -------------------------------------------------------------------------
      ---

      my_scheduler.variables_table := Parser.Variables_Table;
      my_scheduler.sets_table      := Parser.Sets_Table;

      -- Initialize user defined constant
      --
      initialize_parametric_variables
        (my_scheduler.variables_table,
         my_messages,
         my_buffers,
         my_resources,
         my_tasks,
         processor_name);

      -- Initialize user defined variables
      --

      -- "nb_processors"
      --
      var :=
        find_variable
          (my_scheduler.variables_table,
           To_Unbounded_String ("nb_processors"));
      my_scheduler.variables_table.entries (var).simulation.integer_value :=
        Integer (si.number_of_processors);

      -- "nb_address_spaces"
      --
      var :=
        find_variable
          (my_scheduler.variables_table,
           To_Unbounded_String ("nb_address_spaces"));
      my_scheduler.variables_table.entries (var).simulation.integer_value :=
        Integer (si.number_of_address_spaces);

      -- "simulation_length"
      --
      var :=
        find_variable
          (my_scheduler.variables_table,
           To_Unbounded_String ("simulation_length"));
      my_scheduler.variables_table.entries (var).simulation.integer_value :=
        si.simulation_length;

      -------------------------------------------------------------------------
      ---
      -- Initialize data for the simulation (transition and state data)
      -------------------------------------------------------------------------
      ---

      my_scheduler.root_statement_pointer := Parser.Root_Statement_Pointer;
      initialize (my_scheduler.transition_data);
      initialize (my_scheduler.automaton_data);

      if
        (get_number_of_elements (my_scheduler.root_statement_pointer) > 0)
      then

         reset_iterator (my_scheduler.root_statement_pointer, my_iterator);

         loop
            current_element
              (my_scheduler.root_statement_pointer,
               a_section,
               my_iterator);
            if a_section.all in synchronization_section then

               if is_empty
                   (synchronization_section_ptr (a_section).transition_list)
               then
                  Raise_Exception
                    (syntax_error'identity,
                     "automaton section " &
                     To_String (a_section.name) &
                     " ; an automaton must contain at least one transition");
               end if;

               -- Store simulation data related to the transition
               --
               reset_head_iterator
                 (synchronization_section_ptr (a_section).transition_list,
                  list_ite);
               loop
                  current_element
                    (synchronization_section_ptr (a_section).transition_list,
                     a_transition,
                     list_ite);

                  a_transition_status.code        := a_transition;
                  a_transition_status.status      := unreachable;
                  a_transition_status.wakeup_time := 0;
                  add
                    (my_scheduler.transition_data,
                     a_section.name,
                     a_transition_status);

                  if is_tail_element
                      (synchronization_section_ptr (a_section).transition_list,
                       list_ite)
                  then
                     exit;
                  end if;
                  next_element
                    (synchronization_section_ptr (a_section).transition_list,
                     list_ite);
               end loop;

               -- Store simulation data related to the automaton
               --
               an_automaton_status.current_state :=
                 search_initial_state
                   (synchronization_section_ptr (a_section).state_list);
               add
                 (my_scheduler.automaton_data,
                  a_section.name,
                  an_automaton_status);

            end if;
            exit when is_last_element
                (my_scheduler.root_statement_pointer,
                 my_iterator);
            next_element (my_scheduler.root_statement_pointer, my_iterator);
         end loop;
      end if;

      if (my_scheduler.automaton_data.nb_entries = 0) then
         Raise_Exception
           (syntax_error'identity,
            "An automaton scheduler must contain at least one automaton");
      end if;

      -- At the beginning of the scheduling simulation, all transitions must
      --be "ready"
      --
      for i in 0 .. my_scheduler.transition_data.nb_entries - 1 loop
         my_scheduler.transition_data.entries (i).data.status := ready;
      end loop;

      -- Run all start section : we first run start section which come from the
      -- processor sc file, and then, we run start section from address space
      --sc files
      --
      -- Load user_defined variable which can be changed by the programmer
      -- before executing sections
      --
      load_read_write_interpreter_variables (my_scheduler, si, processor_name);

      if
        (get_number_of_elements (my_scheduler.root_statement_pointer) > 0)
      then
         reset_iterator (my_scheduler.root_statement_pointer, my_iterator);
         loop
            current_element
              (my_scheduler.root_statement_pointer,
               a_section,
               my_iterator);
            if a_section.all in computation_section then
               if a_section.section_type = start_type then
                  -- Now : run "start" statements
                  --
                  dispatch
                    (computation_section_ptr (a_section).first_statement,
                     start_type,
                     processor_name,
                     si,
                     my_scheduler.variables_table,
                     msg);
               end if;
            end if;
            exit when is_last_element
                (my_scheduler.root_statement_pointer,
                 my_iterator);
            next_element (my_scheduler.root_statement_pointer, my_iterator);
         end loop;
      end if;

      -- After start section, we
      -- save some task run time information
      --
      save_read_write_interpreter_variables (my_scheduler, si, processor_name);

   end specific_scheduler_initialization;

   procedure set_automaton_name
     (my_scheduler : in out automata_user_defined_scheduler;
      to_set       : in     Unbounded_String)
   is
   begin
      my_scheduler.automaton_name := to_set;
   end set_automaton_name;

   function get_automaton_name
     (my_scheduler : in automata_user_defined_scheduler)
      return Unbounded_String
   is
   begin
      return my_scheduler.automaton_name;
   end get_automaton_name;

   procedure initialize
     (a_scheduler : in out automata_user_defined_scheduler)
   is
   begin
      reset (a_scheduler);
      a_scheduler.parameters.scheduler_type := automata_user_defined_protocol;
      a_scheduler.parameters.user_defined_scheduler_source := empty_string;
   end initialize;

   function copy
     (a_scheduler : in automata_user_defined_scheduler)
      return generic_scheduler_ptr
   is
      ptr : automata_user_defined_scheduler_ptr;

   begin

      ptr := new automata_user_defined_scheduler;

      ptr.previously_elected     := a_scheduler.previously_elected;
      ptr.parameters             := a_scheduler.parameters;
      ptr.root_statement_pointer := a_scheduler.root_statement_pointer;
      ptr.variables_table        := a_scheduler.variables_table;

      return generic_scheduler_ptr (ptr);

   end copy;

   procedure put (my_scheduler : in automata_user_defined_scheduler) is
   begin
      put (generic_scheduler (my_scheduler));
      put (my_scheduler.root_statement_pointer);
      put (my_scheduler.variables_table);
   end put;

end scheduler.user_defined.interpreted.automata;
