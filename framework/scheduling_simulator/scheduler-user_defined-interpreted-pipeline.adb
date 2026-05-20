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
with Ada.Strings.Unbounded.Text_IO; use Ada.Strings.Unbounded.Text_IO;
with translate;                     use translate;
with scheduler_io;                  use scheduler_io;
with Statements;                    use Statements;
with Parameters;                    use Parameters;
use Parameters.User_Defined_Parameters_Table_Package;
with Parser;      use Parser;
with Sections;    use Sections;
with section_set; use section_set;
use section_set.package_generic_section_set;
with Ada.IO_Exceptions;    use Ada.IO_Exceptions;
with Ada.Exceptions;       use Ada.Exceptions;
with Interpreter.extended; use Interpreter.extended;

package body scheduler.user_defined.interpreted.pipeline is

   procedure initialize
     (a_scheduler : in out pipeline_user_defined_scheduler)
   is
   begin
      reset (a_scheduler);
      a_scheduler.parameters.scheduler_type := pipeline_user_defined_protocol;
   end initialize;

   function copy
     (a_scheduler : in pipeline_user_defined_scheduler)
      return generic_scheduler_ptr
   is
      ptr : pipeline_user_defined_scheduler_ptr;

   begin

      ptr := new pipeline_user_defined_scheduler;

      ptr.previously_elected     := a_scheduler.previously_elected;
      ptr.parameters             := a_scheduler.parameters;
      ptr.root_statement_pointer := a_scheduler.root_statement_pointer;
      ptr.variables_table        := a_scheduler.variables_table;

      return generic_scheduler_ptr (ptr);

   end copy;

   procedure put (my_scheduler : in pipeline_user_defined_scheduler) is
   begin
      put (generic_scheduler (my_scheduler));
      put (my_scheduler.root_statement_pointer);
      put (my_scheduler.variables_table);
   end put;

   procedure do_election
     (my_scheduler       : in out pipeline_user_defined_scheduler;
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

      current : generic_statement_ptr;

   begin

      -- By default, no task are elected : it's a way
      -- to safer schedule a user_defined scheduler without
      -- a correctly designed code (election part of it)
      --
      no_task := True;

      -- We update simulation engine variables which has to update
      -- because of the task which was running at the previous unit of time
      --
      load_read_write_interpreter_variables (my_scheduler, si, processor_name);
      update_interpreter_variables_after_task_execution
        (my_scheduler,
         si,
         current_time,
         processor_name,
         empty_string,
         options);

      -- Now, do "priority" section
      --
      current := my_scheduler.root_statement_pointer (Sections.priority_type);
      dispatch
        (current,
         priority_type,
         processor_name,
         si,
         my_scheduler.variables_table,
         msg);

      -- After priority section, we
      -- save some task run time information
      --
      save_read_write_interpreter_variables (my_scheduler, si, processor_name);

      -- Do "election" section
      --
      current := my_scheduler.root_statement_pointer (election_type);

      dispatch_return_statement
        (my_scheduler,
         current,
         si,
         current_time,
         processor_name,
         empty_string,
         options,
         elected,
         no_task);

   end do_election;

   -- Do "start" section statements
   --
   procedure specific_scheduler_initialization
     (my_scheduler       : in out pipeline_user_defined_scheduler;
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

      current   : generic_statement_ptr;
      var       : variables_range;
      a_section : computation_section_ptr;

   begin

      -- We should check the scheduler behavior syntax ...
      --
      Open_Input (my_scheduler.parameters.user_defined_scheduler_source);
      Parser.First_File
        (my_scheduler.parameters.user_defined_scheduler_source_file_name);
      create_parametric_variables (Parser.Variables_Table, my_tasks);
      Parser.Yyparse;

      -- Store syntax tree and compiling information
      --
      begin
         a_section :=
           computation_section_ptr
             (search_section
                (Parser.Root_Statement_Pointer,
                 Sections.start_type));
         my_scheduler.root_statement_pointer (Sections.start_type) :=
           a_section.first_statement;
      exception
         when others =>
            my_scheduler.root_statement_pointer (Sections.start_type) := null;
      end;

      begin
         a_section :=
           computation_section_ptr
             (search_section
                (Parser.Root_Statement_Pointer,
                 Sections.priority_type));
         my_scheduler.root_statement_pointer (Sections.priority_type) :=
           a_section.first_statement;
      exception
         when others =>
            my_scheduler.root_statement_pointer (Sections.priority_type) :=
              null;
      end;

      begin
         a_section :=
           computation_section_ptr
             (search_section
                (Parser.Root_Statement_Pointer,
                 Sections.election_type));
         my_scheduler.root_statement_pointer (Sections.election_type) :=
           a_section.first_statement;
      exception
         when others =>
            my_scheduler.root_statement_pointer (Sections.election_type) :=
              null;
      end;

      my_scheduler.variables_table := Parser.Variables_Table;

      my_scheduler.sets_table := Parser.Sets_Table;

      current := my_scheduler.root_statement_pointer (start_type);

      -- Initialize user_defined variables which are constant
      --
      initialize_parametric_variables
        (my_scheduler.variables_table,
         my_messages,
         my_buffers,
         my_resources,
         my_tasks,
         processor_name);

      -- Initialize scheduler-user_defined.adb specific user_defined variables
      --

      -- "nb_processors"
      --
      var :=
        find_variable
          (my_scheduler.variables_table,
           To_Unbounded_String ("nb_processors"));
      my_scheduler.variables_table.entries (var).simulation.integer_value :=
        Integer (si.number_of_processors);

      -- "processors.speed"
      --
      var :=
        find_variable
          (my_scheduler.variables_table,
           To_Unbounded_String ("processors.speed"));
      my_scheduler.variables_table.entries (var).simulation.integer_value :=
        my_scheduler.corresponding_core_unit.speed;

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

      -- Load user_defined variable which can be changed by the programmer
      -- before executing sections
      --
      load_read_write_interpreter_variables (my_scheduler, si, processor_name);

      -- Now : run "start" statements
      --
      dispatch
        (current,
         start_type,
         processor_name,
         si,
         my_scheduler.variables_table,
         msg);

      -- After start section, we
      -- save some task run time information
      --
      save_read_write_interpreter_variables (my_scheduler, si, processor_name);

   end specific_scheduler_initialization;

end scheduler.user_defined.interpreted.pipeline;
