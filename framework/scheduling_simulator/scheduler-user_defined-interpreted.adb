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

with translate;  use translate;
with Parameters; use Parameters;
use Parameters.User_Defined_Parameters_Table_Package;
with Ada.Exceptions; use Ada.Exceptions;
with debug;          use debug;
with section_set;    use section_set;
use section_set.package_generic_section_set;
with Simulations;          use Simulations;
with Simulations.extended; use Simulations.extended;
with Interpreter.extended; use Interpreter.extended;

package body scheduler.user_defined.interpreted is

   function read_variable
     (my_scheduler : in interpreted_user_defined_scheduler;
      var_name     :    Unbounded_String) return Integer
   is
      var : variables_range;
   begin
      -- Look for the variable
      --
      var := find_variable (my_scheduler.variables_table, var_name);

      if get_type (my_scheduler.variables_table.entries (var).variable.all) /=
        simulation_integer
      then
         Raise_Exception
           (type_error'identity,
            "read_variable on " & To_String (var_name));
      end if;

      return my_scheduler.variables_table.entries (var).simulation
          .integer_value;

   end read_variable;

   function read_variable
     (my_scheduler : in interpreted_user_defined_scheduler;
      var_name     :    Unbounded_String) return Unbounded_String
   is
      var : variables_range;
   begin
      -- Look for the variable
      --
      var := find_variable (my_scheduler.variables_table, var_name);

      if get_type (my_scheduler.variables_table.entries (var).variable.all) /=
        simulation_string
      then
         Raise_Exception
           (type_error'identity,
            "read_variable on " & To_String (var_name));
      end if;

      return my_scheduler.variables_table.entries (var).simulation
          .string_value;

   end read_variable;

   function read_variable
     (my_scheduler : in interpreted_user_defined_scheduler;
      var_name     :    Unbounded_String) return Boolean
   is
      var : variables_range;
   begin
      -- Look for the variable
      --
      var := find_variable (my_scheduler.variables_table, var_name);

      if get_type (my_scheduler.variables_table.entries (var).variable.all) /=
        simulation_boolean
      then
         Raise_Exception
           (type_error'identity,
            "read_variable on " & To_String (var_name));
      end if;

      return my_scheduler.variables_table.entries (var).simulation
          .boolean_value;

   end read_variable;

   function read_variable
     (my_scheduler : in interpreted_user_defined_scheduler;
      var_name     :    Unbounded_String) return Double
   is
      var : variables_range;
   begin
      -- Look for the variable
      --
      var := find_variable (my_scheduler.variables_table, var_name);

      if get_type (my_scheduler.variables_table.entries (var).variable.all) /=
        simulation_double
      then
         Raise_Exception
           (type_error'identity,
            "read_variable on " & To_String (var_name));
      end if;

      return my_scheduler.variables_table.entries (var).simulation
          .double_value;

   end read_variable;

   procedure load_read_write_interpreter_variables
     (my_scheduler   : in out interpreted_user_defined_scheduler;
      si             : in     scheduling_information;
      processor_name : in     Unbounded_String)
   is

      var           : variables_range;
      var_task_name : variables_range;

   begin

      -- "processors.speed"
      --
      var :=
        find_variable
          (my_scheduler.variables_table,
           To_Unbounded_String ("processors.speed"));
      my_scheduler.variables_table.entries (var).simulation.integer_value :=
        my_scheduler.corresponding_core_unit.speed;

      -- Task parameters
      --
      var_task_name :=
        find_variable
          (my_scheduler.variables_table,
           To_Unbounded_String ("tasks.name"));

      for j in 0 .. si.number_of_tasks - 1 loop

         if processor_name = si.tcbs (j).tsk.cpu_name then

            for z in 0 .. si.number_of_tasks - 1 loop
               if my_scheduler.variables_table.entries (var_task_name)
                   .simulation
                   .string_table_value
                   (simulations_range (z)) =
                 si.tcbs (j).tsk.name
               then

                  -- "tasks.priority"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.priority"));
                  my_scheduler.variables_table.entries (var).simulation
                    .integer_table_value
                    (simulations_range (z)) :=
                    Integer (si.tcbs (j).tsk.priority);

                  -- "tasks.deadline"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.deadline"));
                  my_scheduler.variables_table.entries (var).simulation
                    .integer_table_value
                    (simulations_range (z)) :=
                    Integer (si.tcbs (j).tsk.deadline);

                  -- "tasks.start_time"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.start_time"));
                  my_scheduler.variables_table.entries (var).simulation
                    .integer_table_value
                    (simulations_range (z)) :=
                    Integer (si.tcbs (j).tsk.start_time);

                  -- "tasks.processor_name"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.processor_name"));
                  my_scheduler.variables_table.entries (var).simulation
                    .string_table_value
                    (simulations_range (z)) :=
                    si.tcbs (j).tsk.cpu_name;

                  -- "tasks.name"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.name"));
                  my_scheduler.variables_table.entries (var).simulation
                    .string_table_value
                    (simulations_range (z)) :=
                    si.tcbs (j).tsk.name;

                  -- "tasks.capacity"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.capacity"));
                  my_scheduler.variables_table.entries (var).simulation
                    .integer_table_value
                    (simulations_range (z)) :=
                    Integer (si.tcbs (j).tsk.capacity);

                  -- "tasks.suspended"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.suspended"));
                  my_scheduler.variables_table.entries (var).simulation
                    .boolean_table_value
                    (simulations_range (z)) :=
                    si.tcbs (j).suspended;

                  -- "tasks.used_capacity"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.used_capacity"));
                  my_scheduler.variables_table.entries (var).simulation
                    .integer_table_value
                    (simulations_range (z)) :=
                    Integer (si.tcbs (j).used_capacity);

                  -- "tasks.wakeup_time"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.wakeup_time"));
                  my_scheduler.variables_table.entries (var).simulation
                    .integer_table_value
                    (simulations_range (z)) :=
                    Integer (si.tcbs (j).wake_up_time);

                  -- "tasks.rest_of_capacity"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.rest_of_capacity"));
                  my_scheduler.variables_table.entries (var).simulation
                    .integer_table_value
                    (simulations_range (z)) :=
                    Integer (si.tcbs (j).rest_of_capacity);

                  -- "tasks.blocking_time"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.blocking_time"));
                  my_scheduler.variables_table.entries (var).simulation
                    .integer_table_value
                    (simulations_range (z)) :=
                    Integer (si.tcbs (j).tsk.blocking_time);

                  -- "tasks.period"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.period"));
                  case si.tcbs (j).tsk.task_type is
                     when aperiodic_type =>
                        my_scheduler.variables_table.entries (var).simulation
                          .integer_table_value
                          (simulations_range (z)) :=
                          0;
                     when others =>
                        my_scheduler.variables_table.entries (var).simulation
                          .integer_table_value
                          (simulations_range (z)) :=
                          Integer (periodic_task_ptr (si.tcbs (j).tsk).period);
                  end case;

                  -- "tasks.jitter"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.jitter"));
                  case si.tcbs (j).tsk.task_type is
                     when aperiodic_type =>
                        my_scheduler.variables_table.entries (var).simulation
                          .integer_table_value
                          (simulations_range (z)) :=
                          0;
                     when others =>
                        my_scheduler.variables_table.entries (var).simulation
                          .integer_table_value
                          (simulations_range (z)) :=
                          Integer (periodic_task_ptr (si.tcbs (j).tsk).jitter);
                  end case;

                  -- user defined task's parameter :
                  --

                  for i in 0 .. si.tcbs (j).tsk.parameters.nb_entries - 1 loop

                     -- Find the user defined variable
                     -- and set its value
                     --
                     for k in 0 .. my_scheduler.variables_table.nb_entries - 1
                     loop
                        if my_scheduler.variables_table.entries (k).variable
                            .name =
                          To_Unbounded_String ("tasks.") &
                            si.tcbs (j).tsk.parameters.entries (i)
                              .parameter_name
                        then

                           -- Now, set the value
                           --
                           if si.tcbs (j).tsk.parameters.entries (i)
                               .type_of_parameter =
                             boolean_parameter
                           then
                              my_scheduler.variables_table.entries (k)
                                .simulation
                                .boolean_table_value
                                (simulations_range (z)) :=
                                Boolean
                                  (si.tcbs (j).tsk.parameters.entries (i)
                                     .boolean_value);
                           end if;
                           if si.tcbs (j).tsk.parameters.entries (i)
                               .type_of_parameter =
                             integer_parameter
                           then
                              my_scheduler.variables_table.entries (k)
                                .simulation
                                .integer_table_value
                                (simulations_range (z)) :=
                                Integer
                                  (si.tcbs (j).tsk.parameters.entries (i)
                                     .integer_value);
                           end if;
                           if si.tcbs (j).tsk.parameters.entries (i)
                               .type_of_parameter =
                             double_parameter
                           then
                              my_scheduler.variables_table.entries (k)
                                .simulation
                                .double_table_value
                                (simulations_range (z)) :=
                                Double
                                  (si.tcbs (j).tsk.parameters.entries (i)
                                     .double_value);
                           end if;
                           if si.tcbs (j).tsk.parameters.entries (i)
                               .type_of_parameter =
                             string_parameter
                           then
                              my_scheduler.variables_table.entries (k)
                                .simulation
                                .string_table_value
                                (simulations_range (z)) :=
                                si.tcbs (j).tsk.parameters.entries (i)
                                  .string_value;
                           end if;
                        end if;
                     end loop;
                  end loop;

               end if;
            end loop;

         end if;
      end loop;

   end load_read_write_interpreter_variables;

   procedure save_read_write_interpreter_variables
     (my_scheduler   : in     interpreted_user_defined_scheduler;
      si             : in out scheduling_information;
      processor_name : in     Unbounded_String)
   is

      var           : variables_range;
      var_task_name : variables_range;

   begin

      -- "processors.speed"
      --
      var :=
        find_variable
          (my_scheduler.variables_table,
           To_Unbounded_String ("processors.speed"));
      my_scheduler.corresponding_core_unit.speed :=
        my_scheduler.variables_table.entries (var).simulation.integer_value;

      -- Task parameters
      --
      var_task_name :=
        find_variable
          (my_scheduler.variables_table,
           To_Unbounded_String ("tasks.name"));

      for j in 0 .. si.number_of_tasks - 1 loop

         if processor_name = si.tcbs (j).tsk.cpu_name then

            for z in 0 .. si.number_of_tasks - 1 loop
               if my_scheduler.variables_table.entries (var_task_name)
                   .simulation
                   .string_table_value
                   (simulations_range (z)) =
                 si.tcbs (j).tsk.name
               then

                  -- "tasks.priority"
                  --
                  begin
                     var :=
                       find_variable
                         (my_scheduler.variables_table,
                          To_Unbounded_String ("tasks.priority"));
                     si.tcbs (j).tsk.priority :=
                       priority_range
                         (my_scheduler.variables_table.entries (var).simulation
                            .integer_table_value
                            (simulations_range (z)));
                  exception
                     when Constraint_Error =>
                        Raise_Exception
                          (type_error'identity,
                           "Task priority range check error  " &
                           To_String
                             (parametric_task_ptr (si.tcbs (j).tsk).name) &
                           " " &
                           Integer'image
                             (my_scheduler.variables_table.entries (var)
                                .simulation
                                .integer_table_value
                                (simulations_range (z))));
                  end;

                  -- "tasks.deadline"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.deadline"));
                  si.tcbs (j).tsk.deadline :=
                    my_scheduler.variables_table.entries (var).simulation
                      .integer_table_value
                      (simulations_range (z));

                  -- "tasks.suspended"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.suspended"));
                  si.tcbs (j).suspended :=
                    my_scheduler.variables_table.entries (var).simulation
                      .boolean_table_value
                      (simulations_range (z));

                  -- "tasks.start_time"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.start_time"));
                  si.tcbs (j).tsk.start_time :=
                    my_scheduler.variables_table.entries (var).simulation
                      .integer_table_value
                      (simulations_range (z));

                  -- "tasks.capacity"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.capacity"));
                  si.tcbs (j).tsk.capacity :=
                    my_scheduler.variables_table.entries (var).simulation
                      .integer_table_value
                      (simulations_range (z));

                  -- "tasks.wakeup_time"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.wakeup_time"));
                  si.tcbs (j).wake_up_time :=
                    my_scheduler.variables_table.entries (var).simulation
                      .integer_table_value
                      (simulations_range (z));

                  -- "tasks.used_capacity"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.used_capacity"));
                  si.tcbs (j).used_capacity :=
                    my_scheduler.variables_table.entries (var).simulation
                      .integer_table_value
                      (simulations_range (z));

                  -- "tasks.rest_of_capacity"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.rest_of_capacity"));
                  si.tcbs (j).rest_of_capacity :=
                    my_scheduler.variables_table.entries (var).simulation
                      .integer_table_value
                      (simulations_range (z));

                  -- "tasks.blocking_time"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.blocking_time"));
                  si.tcbs (j).tsk.blocking_time :=
                    my_scheduler.variables_table.entries (var).simulation
                      .integer_table_value
                      (simulations_range (z));

                  -- "tasks.period"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.period"));
                  case si.tcbs (j).tsk.task_type is
                     when aperiodic_type =>
                        null;
                     when others =>
                        periodic_task_ptr (si.tcbs (j).tsk).period :=
                          my_scheduler.variables_table.entries (var).simulation
                            .integer_table_value
                            (simulations_range (z));
                  end case;

                  -- "tasks.jitter"
                  --
                  var :=
                    find_variable
                      (my_scheduler.variables_table,
                       To_Unbounded_String ("tasks.jitter"));
                  case si.tcbs (j).tsk.task_type is
                     when aperiodic_type =>
                        null;
                     when others =>
                        periodic_task_ptr (si.tcbs (j).tsk).jitter :=
                          my_scheduler.variables_table.entries (var).simulation
                            .integer_table_value
                            (simulations_range (z));
                  end case;

                  -- user defined task's parameter :
                  --
                  for i in 0 .. si.tcbs (j).tsk.parameters.nb_entries - 1 loop

                     -- Find the user defined variable
                     -- and set its value
                     --
                     for k in 0 .. my_scheduler.variables_table.nb_entries - 1
                     loop
                        if my_scheduler.variables_table.entries (k).variable
                            .name =
                          To_Unbounded_String ("tasks.") &
                            si.tcbs (j).tsk.parameters.entries (i)
                              .parameter_name
                        then

                           -- Now, set the value
                           --
                           if si.tcbs (j).tsk.parameters.entries (i)
                               .type_of_parameter =
                             boolean_parameter
                           then
                              si.tcbs (j).tsk.parameters.entries (i)
                                .boolean_value :=
                                my_scheduler.variables_table.entries (k)
                                  .simulation
                                  .boolean_table_value
                                  (simulations_range (z));
                           end if;
                           if si.tcbs (j).tsk.parameters.entries (i)
                               .type_of_parameter =
                             integer_parameter
                           then
                              si.tcbs (j).tsk.parameters.entries (i)
                                .integer_value :=
                                my_scheduler.variables_table.entries (k)
                                  .simulation
                                  .integer_table_value
                                  (simulations_range (z));
                           end if;
                           if si.tcbs (j).tsk.parameters.entries (i)
                               .type_of_parameter =
                             double_parameter
                           then
                              si.tcbs (j).tsk.parameters.entries (i)
                                .double_value :=
                                my_scheduler.variables_table.entries (k)
                                  .simulation
                                  .double_table_value
                                  (simulations_range (z));
                           end if;
                           if si.tcbs (j).tsk.parameters.entries (i)
                               .type_of_parameter =
                             string_parameter
                           then
                              si.tcbs (j).tsk.parameters.entries (i)
                                .string_value :=
                                my_scheduler.variables_table.entries (k)
                                  .simulation
                                  .string_table_value
                                  (simulations_range (z));
                           end if;
                        end if;
                     end loop;
                  end loop;

               end if;
            end loop;

         end if;
      end loop;

   end save_read_write_interpreter_variables;

   procedure compute_activation_time
     (my_scheduler : in     interpreted_user_defined_scheduler;
      si           : in out scheduling_information;
      elected      : in     tasks_range;
      value        : in out Natural)
   is

      set_id             : sets_range;
      user_defined_delay : simulation_value_ptr;

   begin

      set_id :=
        find_set
          (my_scheduler.sets_table,
           parametric_task_ptr (si.tcbs (elected).tsk).activation_rule);

      user_defined_delay :=
        value_of
          (my_scheduler.sets_table.entries (set_id).set_value.all,
           my_scheduler.variables_table);

      if (user_defined_delay.ptype /= simulation_integer) and
        (user_defined_delay.ptype /= simulation_array_integer)
      then
         Raise_Exception
           (type_error'identity,
            "Task activation rule, activation rule " &
            To_String
              (parametric_task_ptr (si.tcbs (elected).tsk).activation_rule) &
            To_String
              (lb_comma & lb_uncompatible_type_error (Current_Language)));
      end if;

      -- If it's a vector, return the corresponding index
      -- else, just return the computed integer
      --
      if user_defined_delay.ptype = simulation_integer then
         value := user_defined_delay.integer_value;
      else
         value :=
           user_defined_delay.integer_table_value
             (simulations_range (elected));
      end if;

      put_debug
        ("Compute activation time for task " &
         To_String (si.tcbs (elected).tsk.name) &
         " : value is " &
         Natural'image (value));

   end compute_activation_time;

   -- A election is done in 3 steps :
   --        1) we check and retrieve return information
   --        2) tasks queues should be updated
   --        3) we find the running task
   --

   procedure dispatch_return_statement
     (my_scheduler       : in out interpreted_user_defined_scheduler;
      current            : in     generic_statement_ptr;
      si                 : in out scheduling_information;
      current_time       : in     Natural;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      options            : in     scheduling_option;
      elected            : in out tasks_range;
      no_task            : in out Boolean)
   is

      return_val             : generic_expression_ptr;
      election_value         : simulation_value_ptr;
      current_selected_value : simulation_value_ptr;
      i                      : tasks_range := 0;
      var                    : variables_range;
      var_task_name          : variables_range;

   begin

      -- We should have, at least a election_section !
      --
      if current = null then
         Raise_Exception
           (statement_error'identity,
            "An election section is mandatory");
      end if;

      -- Only one type of statement is allowed on "election" section :
      -- a return statement
      --
      if current.all not in return_statement'class then
         Raise_Exception
           (statement_error'identity,
            "Election section, line " &
            current.line_number'img &
            ", file " &
            To_String (current.file_name) &
            ", return statement expected");
      end if;

      -- Look for the variable which stores task names
      --
      var_task_name :=
        find_variable
          (my_scheduler.variables_table,
           To_Unbounded_String ("tasks.name"));

      -- Do return statement
      --

      -- The return statement should be :
      --      1) either a min/max_to_index expression composed of
      --        a array variable only. Boolean/double/string array variable
      --are forbidden
      --      2) or an integer constant
      --      3) or an integer variable
      --      4) when the constant is -1, it means that no task must elected
      --
      --      Others expression must raise an error
      --

      return_val := return_statement_ptr (current).return_value;

      ------------------------------------------------------------
      -- 2) and 3) the return statement is a constant or a variable
      ------------------------------------------------------------

      if (return_val.expression_type = variable_type) or
        (return_val.expression_type = constant_type)
      then

         if (return_val.expression_type = constant_type) then
            put_debug
              ("Do a constant election at time " &
               current_time'img &
               " ; processor/addr space " &
               processor_name &
               "/" &
               address_space_name);
            if constant_expression_ptr (return_val).value.ptype /=
              simulation_integer
            then
               Raise_Exception
                 (statement_error'identity,
                  "Election section, line " &
                  current.line_number'img &
                  ", file " &
                  To_String (current.file_name) &
                  ", invalid constant expression type referenced in a return statement");
            end if;

            -- No task to run
            --
            if
              (constant_expression_ptr (return_val).value.integer_value = -1)
            then
               no_task := True;
               return;
            end if;

            if
              (constant_expression_ptr (return_val).value.integer_value <
               Integer (tasks_range'first)) or
              (constant_expression_ptr (return_val).value.integer_value >
               Integer (tasks_range'last))
            then
               Raise_Exception
                 (statement_error'identity,
                  "Election section, line " &
                  current.line_number'img &
                  ", file " &
                  To_String (current.file_name) &
                  ", invalid range constant type referenced in a return statement");
            end if;

            i :=
              tasks_range
                (constant_expression_ptr (return_val).value.integer_value);
         end if;

         if (return_val.expression_type = variable_type) then
            put_debug
              ("Do a variable election at time " &
               current_time'img &
               " ; processor/addr space " &
               processor_name &
               "/" &
               address_space_name);
            var :=
              find_variable
                (my_scheduler.variables_table,
                 variable_expression_ptr (return_val).name);
            if my_scheduler.variables_table.entries (var).simulation.ptype /=
              simulation_integer
            then
               Raise_Exception
                 (statement_error'identity,
                  "Election section, line " &
                  current.line_number'img &
                  ", file " &
                  To_String (current.file_name) &
                  ", invalid variable expression type referenced in a return statement");
            end if;
            if
              (my_scheduler.variables_table.entries (var).simulation
                 .integer_value <
               Integer (simulations_range'first)) or
              (my_scheduler.variables_table.entries (var).simulation
                 .integer_value >
               Integer (tasks_range'last))
            then
               Raise_Exception
                 (statement_error'identity,
                  "Election section, line " &
                  current.line_number'img &
                  ", file " &
                  To_String (current.file_name) &
                  ", invalid range variable type referenced in a return statement");
            end if;
            i :=
              tasks_range
                (my_scheduler.variables_table.entries (var).simulation
                   .integer_value);
         end if;

         -- Convert user_defined variable index towards tcb index
         --
         for j in 0 .. si.number_of_tasks - 1 loop
            if my_scheduler.variables_table.entries (var_task_name).simulation
                .string_table_value
                (simulations_range (i)) =
              si.tcbs (j).tsk.name
            then

               -- Check that the task is ready ... and elect it !
               --
               if not si.tcbs (j).already_run_at_current_time then
                  if check_core_assignment (my_scheduler, si.tcbs (j)) then
                     if
                       ((si.tcbs (j).tsk.cpu_name = processor_name) or
                        (si.tcbs (j).tsk.address_space_name =
                         address_space_name))
                     then
                        if (si.tcbs (j).wake_up_time <= current_time) then
                           if (si.tcbs (j).suspended = False) then
                              if (si.tcbs (j).rest_of_capacity /= 0) then
                                 if (options.with_offsets = False) or
                                   check_offset (si.tcbs (j), current_time)
                                 then
                                    if (options.with_precedencies = False) or
                                      check_precedencies
                                        (si,
                                         current_time,
                                         si.tcbs (j))
                                    then
                                       elected := j;
                                       no_task := False;
                                    end if;
                                 end if;
                              end if;
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end loop;

         return;
      end if;

      -------------------------------------------------------------------------
      ---------
      -- 1) the case when the return statement is a max/min_to_index expression
      -------------------------------------------------------------------------
      ---------

      if (return_val.expression_type = unary_type) then
         if (unary_expression_ptr (return_val).ope = min_to_index_type) or
           (unary_expression_ptr (return_val).ope = max_to_index_type)
         then

            put_debug
              ("Do a min/max_to_index election at time " &
               current_time'img &
               " ; processor/addr space " &
               processor_name &
               "/" &
               address_space_name);

            -------------------------------------------------------------------
            ---------------------
            -- Some checks on the type of the variable on which we will run
            --the min/max statement
            -------------------------------------------------------------------
            ---------------------

            if (unary_expression_ptr (return_val).ope = min_to_index_type) then
               if
                 (unary_expression_ptr (return_val).value.expression_type /=
                  array_variable_type)
               then
                  Raise_Exception
                    (statement_error'identity,
                     "Election section, line " &
                     current.line_number'img &
                     ", file " &
                     To_String (current.file_name) &
                     ", invalid min_to_index expression in return statement");
               end if;

               if
                 (array_variable_expression_ptr
                    (unary_expression_ptr (return_val).value)
                    .variable_type /=
                  simulation_array_integer) and
                 (array_variable_expression_ptr
                    (unary_expression_ptr (return_val).value)
                    .variable_type /=
                  simulation_array_double)
               then
                  Raise_Exception
                    (statement_error'identity,
                     "Election section, line " &
                     current.line_number'img &
                     ", file " &
                     To_String (current.file_name) &
                     ", min_to_index expression in return statement should be an integer array variable");
               end if;
            end if;

            if (unary_expression_ptr (return_val).ope = max_to_index_type) then
               if
                 (unary_expression_ptr (return_val).value.expression_type /=
                  array_variable_type)
               then
                  Raise_Exception
                    (statement_error'identity,
                     "Election section, line " &
                     current.line_number'img &
                     ", file " &
                     To_String (current.file_name) &
                     ", invalid max_to_index expression in return statement");
               end if;

               if
                 (array_variable_expression_ptr
                    (unary_expression_ptr (return_val).value)
                    .variable_type /=
                  simulation_array_integer)
               then
                  Raise_Exception
                    (statement_error'identity,
                     "Election section, line " &
                     current.line_number'img &
                     ", file " &
                     To_String (current.file_name) &
                     ", max_to_index expression in return statement should be an integer array variable");
               end if;
            end if;

            ---------------------------------------------------------
            -- The type of the expression is ok, run the return now
            ---------------------------------------------------------

            election_value :=
              value_of
                (array_variable_expression
                   (unary_expression_ptr (return_val).value.all),
                 my_scheduler.variables_table,
                 current.line_number,
                 current.file_name);

            if (election_value.ptype = simulation_array_double) then
               current_selected_value :=
                 new simulation_value (simulation_double);
               if unary_expression_ptr (return_val).ope =
                 min_to_index_type
               then
                  current_selected_value.double_value := Double'last;
               else
                  current_selected_value.double_value := Double'first;
               end if;
            else
               current_selected_value :=
                 new simulation_value (simulation_integer);
               if unary_expression_ptr (return_val).ope =
                 min_to_index_type
               then
                  current_selected_value.integer_value := Integer'last;
               else
                  current_selected_value.integer_value := Integer'first;
               end if;
            end if;

            -- Now, loop on the array variable to find the appropriate task to
            -- be elected
            --

            i := 0;
            loop
               if not si.tcbs (i).already_run_at_current_time then
                  if check_core_assignment (my_scheduler, si.tcbs (i)) then
                     if
                       ((si.tcbs (i).tsk.cpu_name = processor_name) or
                        (si.tcbs (i).tsk.address_space_name =
                         address_space_name))
                     then
                        if (si.tcbs (i).suspended = False) then
                           if (si.tcbs (i).wake_up_time <= current_time) and
                             (si.tcbs (i).rest_of_capacity /= 0)
                           then
                              if (options.with_offsets = False) or
                                check_offset (si.tcbs (i), current_time)
                              then
                                 if (options.with_precedencies = False) or
                                   check_precedencies
                                     (si,
                                      current_time,
                                      si.tcbs (i))
                                 then

                                    -- Integer case
                                    --
                                    if
                                      (election_value.ptype =
                                       simulation_array_integer)
                                    then

                                       -- Min_To_Index case
                                       --
                                       if
                                         (unary_expression_ptr (return_val)
                                            .ope =
                                          min_to_index_type) and
                                         (election_value.integer_table_value
                                            (simulations_range (i)) <
                                          current_selected_value.integer_value)
                                       then
                                          elected := i;
                                          current_selected_value
                                            .integer_value :=
                                            election_value.integer_table_value
                                              (simulations_range (i));
                                       end if;

                                       -- Max_To_Index case
                                       --
                                       if
                                         (unary_expression_ptr (return_val)
                                            .ope =
                                          max_to_index_type) and
                                         (election_value.integer_table_value
                                            (simulations_range (i)) >
                                          current_selected_value.integer_value)
                                       then
                                          elected := i;
                                          current_selected_value
                                            .integer_value :=
                                            election_value.integer_table_value
                                              (simulations_range (i));
                                       end if;

                                    -- Double case
                                    --
                                    else

                                       -- Min_To_Index case
                                       --
                                       if
                                         (unary_expression_ptr (return_val)
                                            .ope =
                                          min_to_index_type) and
                                         (election_value.double_table_value
                                            (simulations_range (i)) <
                                          current_selected_value.double_value)
                                       then
                                          elected := i;
                                          current_selected_value
                                            .double_value :=
                                            election_value.double_table_value
                                              (simulations_range (i));
                                       end if;

                                       -- Max_To_Index case
                                       --
                                       if
                                         (unary_expression_ptr (return_val)
                                            .ope =
                                          max_to_index_type) and
                                         (election_value.double_table_value
                                            (simulations_range (i)) >
                                          current_selected_value.double_value)
                                       then
                                          elected := i;
                                          current_selected_value
                                            .double_value :=
                                            election_value.double_table_value
                                              (simulations_range (i));
                                       end if;

                                    end if;
                                 end if;
                              end if;
                           end if;
                        end if;
                     end if;
                  end if;
               end if;

               i := i + 1;
               exit when si.tcbs (i) = null;
            end loop;

            if (election_value.ptype = simulation_array_integer) then

               if
                 ((unary_expression_ptr (return_val).ope =
                   min_to_index_type) and
                  (current_selected_value.integer_value /= Integer'last)) or
                 ((unary_expression_ptr (return_val).ope =
                   max_to_index_type) and
                  (current_selected_value.integer_value /= Integer'first))
               then
                  no_task := False;
               end if;
            else
               if
                 ((unary_expression_ptr (return_val).ope =
                   min_to_index_type) and
                  (current_selected_value.double_value /= Double'last)) or
                 ((unary_expression_ptr (return_val).ope =
                   max_to_index_type) and
                  (current_selected_value.double_value /= Double'first))
               then
                  no_task := False;
               end if;
            end if;

            free (election_value);
            return;
         end if;
      end if;

      ------------------------------------------------------------
      -- Others expression in a return statement is a mistake
      ------------------------------------------------------------

      Raise_Exception
        (statement_error'identity,
         "Election section, line " &
         current.line_number'img &
         ", file " &
         To_String (current.file_name) &
         ", invalid expression referenced in a return statement");

   end dispatch_return_statement;

   procedure update_interpreter_variables_after_task_execution
     (my_scheduler       : in out interpreted_user_defined_scheduler;
      si                 : in out scheduling_information;
      current_time       : in     Natural;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      options            : in     scheduling_option)
   is

      var           : variables_range;
      var_task_name : variables_range;

   begin

      -- Look for the variable which stores task names
      --
      var_task_name :=
        find_variable
          (my_scheduler.variables_table,
           To_Unbounded_String ("tasks.name"));

      -- We set the variables changed by the simulation each unit of time
      --
      var :=
        find_variable
          (my_scheduler.variables_table,
           To_Unbounded_String ("tasks.activation_number"));
      for i in 0 .. si.number_of_tasks - 1 loop
         if processor_name = si.tcbs (i).tsk.cpu_name then
            for j in 0 .. si.number_of_tasks - 1 loop
               if my_scheduler.variables_table.entries (var_task_name)
                   .simulation
                   .string_table_value
                   (simulations_range (j)) =
                 si.tcbs (i).tsk.name
               then
                  my_scheduler.variables_table.entries (var).simulation
                    .integer_table_value
                    (simulations_range (j)) :=
                    Integer (si.tcbs (i).activation);
               end if;
            end loop;
         end if;
      end loop;

      for i in 0 .. si.number_of_tasks - 1 loop
         if my_scheduler.variables_table.entries (var_task_name).simulation
             .string_table_value
             (simulations_range (i)) =
           si.tcbs (my_scheduler.previously_elected).tsk.name
         then
            var :=
              find_variable
                (my_scheduler.variables_table,
                 To_Unbounded_String ("tasks.used_capacity"));
            my_scheduler.variables_table.entries (var).simulation
              .integer_table_value
              (simulations_range (i)) :=
              Integer
                (si.tcbs (my_scheduler.previously_elected).used_capacity);

            var :=
              find_variable
                (my_scheduler.variables_table,
                 To_Unbounded_String ("tasks.rest_of_capacity"));
            my_scheduler.variables_table.entries (var).simulation
              .integer_table_value
              (simulations_range (i)) :=
              Integer
                (si.tcbs (my_scheduler.previously_elected).rest_of_capacity);

            var :=
              find_variable
                (my_scheduler.variables_table,
                 To_Unbounded_String ("tasks.used_cpu"));
            my_scheduler.variables_table.entries (var).simulation
              .integer_table_value
              (simulations_range (i)) :=
              Integer (si.tcbs (my_scheduler.previously_elected).used_cpu);
         end if;
      end loop;

      var :=
        find_variable
          (my_scheduler.variables_table,
           To_Unbounded_String ("previously_elected"));
      my_scheduler.variables_table.entries (var).simulation.integer_value :=
        Integer (my_scheduler.previously_elected);

      var :=
        find_variable
          (my_scheduler.variables_table,
           To_Unbounded_String ("simulation_time"));
      my_scheduler.variables_table.entries (var).simulation.integer_value :=
        Integer (current_time);

      -- Check if tasks are ready or not
      --
      var :=
        find_variable
          (my_scheduler.variables_table,
           To_Unbounded_String ("tasks.ready"));

      for i in 0 .. si.number_of_tasks - 1 loop
         if
           ((si.tcbs (i).tsk.cpu_name = processor_name) or
            (si.tcbs (i).tsk.address_space_name = address_space_name))
         then
            for j in 0 .. si.number_of_tasks - 1 loop
               if my_scheduler.variables_table.entries (var_task_name)
                   .simulation
                   .string_table_value
                   (simulations_range (j)) =
                 si.tcbs (i).tsk.name
               then
                  my_scheduler.variables_table.entries (var).simulation
                    .boolean_table_value
                    (simulations_range (j)) :=
                    False;
               end if;
            end loop;
         end if;
      end loop;

      for i in 0 .. si.number_of_tasks - 1 loop
         if
           ((si.tcbs (i).tsk.cpu_name = processor_name) or
            (si.tcbs (i).tsk.address_space_name = address_space_name))
         then
            if (si.tcbs (i).wake_up_time <= current_time) and
              (si.tcbs (i).rest_of_capacity /= 0)
            then
               if (options.with_offsets = False) or
                 check_offset (si.tcbs (i), current_time)
               then
                  if (options.with_precedencies = False) or
                    check_precedencies (si, current_time, si.tcbs (i))
                  then
                     for j in 0 .. si.number_of_tasks - 1 loop
                        if my_scheduler.variables_table.entries (var_task_name)
                            .simulation
                            .string_table_value
                            (simulations_range (j)) =
                          si.tcbs (i).tsk.name
                        then
                           my_scheduler.variables_table.entries (var)
                             .simulation
                             .boolean_table_value
                             (simulations_range (j)) :=
                             True;
                        end if;
                     end loop;
                  end if;
               end if;
            end if;
         end if;
      end loop;

   end update_interpreter_variables_after_task_execution;

end scheduler.user_defined.interpreted;
