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

with Text_IO;                   use Text_IO;
with unbounded_strings;         use unbounded_strings;
with Ada.Exceptions;            use Ada.Exceptions;
with GNAT.Current_Exception;    use GNAT.Current_Exception;
with translate;                 use translate;
with time_unit_events;          use time_unit_events;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Sections;                  use Sections;
use Sections.Sections_Type_io;
with Simulations;          use Simulations;
with Simulations.extended; use Simulations.extended;
with Statements.extended;  use Statements.extended;
with Laws;                 use Laws;
with task_dependencies;    use task_dependencies;
with task_set;             use task_set;
use task_set.generic_task_set;
with Tasks; use Tasks;

package body Interpreter.extended is

   procedure put (s : in section_table) is
   begin
      for i in sections_type'range loop
         if s (i) /= null then
            Put (" Section : ");
            Put (i);
            New_Line;
            recursive_put (s (i));
            New_Line;
            New_Line;
         end if;
      end loop;
   end put;

   function find_set
     (var : in sets_table_type;
      s   : in Unbounded_String) return sets_range
   is
   begin
      for i in 0 .. var.nb_entries - 1 loop
         if var.entries (i).set_id = s then
            return i;
         end if;
      end loop;
      Raise_Exception
        (expressions.syntax_error'identity,
         To_String
           (s & lb_comma & lb_undeclared_identifier (Current_Language)));

      return 0;

   end find_set;

   procedure check_set_declaration
     (var : in sets_table_type;
      s   : in Unbounded_String)
   is

      dummy : constant sets_range := find_set (var, s);
   begin
      null;
   end check_set_declaration;

   --------------------------------------------------------------

   procedure if_dispatch
     (current         : in     if_statement_ptr;
      current_section : in     sections_type;
      processor_name  : in     Unbounded_String;
      si              : in out scheduling_information;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String;
      next            : in out generic_statement_ptr)
   is

      simu_ptr : simulation_value_ptr;

   begin

      simu_ptr :=
        value_of
          (current.bool_expression.all,
           variables_table,
           current.line_number,
           current.file_name);

      if simu_ptr.ptype /= simulation_boolean then
         Raise_Exception
           (type_error'identity,
            "If statement, line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            To_String
              (lb_comma & lb_uncompatible_type_error (Current_Language)));
      end if;

      if simu_ptr.boolean_value then
         dispatch
           (current.then_statement,
            current_section,
            processor_name,
            si,
            variables_table,
            msg);
      else
         dispatch
           (current.else_statement,
            current_section,
            processor_name,
            si,
            variables_table,
            msg);
      end if;

      free (simu_ptr);

      next := current.next_statement;

   exception
      when Constraint_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);
      when Storage_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);
      when Program_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);

   end if_dispatch;

   procedure add_precedence_dispatch

     (current         : in     add_precedence_statement_ptr;
      processor_name  : in     Unbounded_String;
      si              : in out scheduling_information;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String;
      next            : in out generic_statement_ptr)
   is

      i            : tasks_range := 0;
      source_found : Boolean     := False;
      sink_found   : Boolean     := False;
      source       : generic_task_ptr;
      sink         : generic_task_ptr;

   begin

      loop
         if (si.tcbs (i).tsk.name = current.Add_Source) then
            source_found := True;
            source       := si.tcbs (i).tsk;
         end if;
         if (si.tcbs (i).tsk.name = current.Add_Sink) then
            sink_found := True;
            sink       := si.tcbs (i).tsk;
         end if;

         i := i + 1;
         exit when si.tcbs (i) = null;
      end loop;

      if not source_found then
         Raise_Exception
           (statement_error'identity,
            "add_precedence statement, line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " task " &
            To_String (source.name) &
            ", task not found ");
      end if;

      if not sink_found then
         Raise_Exception
           (statement_error'identity,
            "add_precedence statement, line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " task " &
            To_String (sink.name) &
            ", task not found ");
      end if;

      add_one_task_dependency_precedence (si.dependencies, source, sink);

      next := current.next_statement;

   end add_precedence_dispatch;

   procedure delete_precedence_dispatch
     (current         : in     delete_precedence_statement_ptr;
      processor_name  : in     Unbounded_String;
      si              : in out scheduling_information;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String;
      next            : in out generic_statement_ptr)
   is

      i            : tasks_range := 0;
      source_found : Boolean     := False;
      sink_found   : Boolean     := False;
      source       : generic_task_ptr;
      sink         : generic_task_ptr;

   begin

      loop
         if (si.tcbs (i).tsk.name = current.Delete_Source) then
            source_found := True;
            source       := si.tcbs (i).tsk;
         end if;
         if (si.tcbs (i).tsk.name = current.Delete_Sink) then
            sink_found := True;
            sink       := si.tcbs (i).tsk;
         end if;

         i := i + 1;
         exit when si.tcbs (i) = null;
      end loop;

      if not source_found then
         Raise_Exception
           (statement_error'identity,
            "delete_precedence statement, line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " task " &
            To_String (source.name) &
            ", task not found ");
      end if;

      if not sink_found then
         Raise_Exception
           (statement_error'identity,
            "delete_precedence statement, line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " task " &
            To_String (sink.name) &
            ", task not found ");
      end if;

      Put_Line
        ("delete fin  : " &
         To_String (source.name) &
         " " &
         To_String (sink.name));
      begin
         delete_one_task_dependency_precedence (si.dependencies, source, sink);
      exception
         when others =>
            Raise_Exception
              (statement_error'identity,
               "delete_precedence statement, line " &
               current.line_number'img &
               ", processor " &
               To_String (processor_name) &
               ", file " &
               To_String (current.file_name) &
               ", dependency cannot be removed ");
      end;

      next := current.next_statement;

   end delete_precedence_dispatch;

   procedure random_initialize_dispatch
     (current         : in     random_initialize_statement_ptr;
      processor_name  : in     Unbounded_String;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String;
      next            : in out generic_statement_ptr)
   is

      var        : variables_range;
      val1, val2 : simulation_value_ptr;
      seed       : Generator;

   begin

      var :=
        find_variable
          (variables_table,
           current.lvalue,
           current.line_number,
           current.file_name);

      case current.law is
         when uniform_law_type | laplace_gauss_law_type =>
            val1 :=
              value_of
                (current.parameter1.all,
                 variables_table,
                 current.line_number,
                 current.file_name);
            val2 :=
              value_of
                (current.parameter2.all,
                 variables_table,
                 current.line_number,
                 current.file_name);
         when exponential_law_type =>
            val1 :=
              value_of
                (current.parameter1.all,
                 variables_table,
                 current.line_number,
                 current.file_name);
            val2 := new simulation_value (simulation_integer);
      end case;

      if val1.ptype /= simulation_integer then
         Raise_Exception
           (type_error'identity,
            "Random  statement, line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            To_String
              (lb_comma & lb_uncompatible_type_error (Current_Language)));
      end if;
      if val2.ptype /= simulation_integer then
         Raise_Exception
           (type_error'identity,
            "Random  statement, line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            To_String
              (lb_comma & lb_uncompatible_type_error (Current_Language)));
      end if;

      -- Store random law parameters  in simulation data
      -- and initialize seed
      --
      if
        (variables_table.entries (var).simulation.ptype =
         simulation_array_random)
      then
         for i in simulations_range loop
            Reset (seed);
            Save
              (seed,
               variables_table.entries (var).simulation.random_table_value
                 (i));
         end loop;
         variables_table.entries (var).simulation.random_table_law_parameters
           .law :=
           current.law;
         variables_table.entries (var).simulation.random_table_law_parameters
           .parameter1 :=
           val1.integer_value;
         variables_table.entries (var).simulation.random_table_law_parameters
           .parameter2 :=
           val2.integer_value;

      else
         Reset (seed);
         Save (seed, variables_table.entries (var).simulation.random_value);
         variables_table.entries (var).simulation.random_law_parameters.law :=
           current.law;
         variables_table.entries (var).simulation.random_law_parameters
           .parameter1 :=
           val1.integer_value;
         variables_table.entries (var).simulation.random_law_parameters
           .parameter2 :=
           val2.integer_value;
      end if;

      free (val1);
      free (val2);

      next := current.next_statement;

   exception
      when Constraint_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);
      when Storage_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);
      when Program_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);

   end random_initialize_dispatch;

   procedure assign_dispatch
     (current         : in     assign_statement_ptr;
      processor_name  : in     Unbounded_String;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String;
      next            : in out generic_statement_ptr)
   is

      left_var      : variables_range;
      fully_indexed : Boolean         := False;
      val, index    : simulation_value_ptr;
      left_type     : simulation_type := get_type (current.lvalue.all);
      right_type    : simulation_type := get_type (current.rvalue.all);

   begin

      -- First of all : check that types of left and rigth value are
      --compatibles
      --
      if not has_compatible_type (left_type, right_type) then
         Raise_Exception
           (type_error'identity,
            "Assignement statement, line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            To_String
              (lb_comma &
               lb_uncompatible_type_error (Current_Language) &
               lb_colon &
               To_Unbounded_String (left_type'img) &
               lb_comma &
               To_Unbounded_String (right_type'img)));
      end if;

      if current.lvalue.expression_type = array_variable_type then
         if array_variable_expression_ptr (current.lvalue).array_index /=
           null
         then
            fully_indexed := True;
         end if;
      end if;

      -- Assignement from a scalar to another scalar
      --
      if not fully_indexed then

         left_var :=
           find_variable
             (variables_table,
              variable_expression_ptr (current.lvalue).name,
              current.line_number,
              current.file_name);
         val :=
           value_of
             (current.rvalue.all,
              variables_table,
              current.line_number,
              current.file_name);

         -- We can not initialize the left part when its type is
         -- scalar and when the right part type is vectorial
         -- The only exception is when the operator is a min_to_index
         -- or a max_to_index operator
         --

         if
           ((variables_table.entries (left_var).simulation.ptype =
             simulation_integer) or
            (variables_table.entries (left_var).simulation.ptype =
             simulation_clock) or
            (variables_table.entries (left_var).simulation.ptype =
             simulation_boolean) or
            (variables_table.entries (left_var).simulation.ptype =
             simulation_random) or
            (variables_table.entries (left_var).simulation.ptype =
             simulation_string) or
            (variables_table.entries (left_var).simulation.ptype =
             simulation_double)) and
           ((val.ptype = simulation_array_boolean) or
            (val.ptype = simulation_array_integer) or
            (val.ptype = simulation_array_clock) or
            (val.ptype = simulation_array_double) or
            (val.ptype = simulation_array_string) or
            (val.ptype = simulation_array_random))
         then
            Raise_Exception
              (type_error'identity,
               "Assignement statement, line " &
               current.line_number'img &
               ", processor " &
               To_String (processor_name) &
               ", file " &
               To_String (current.file_name) &
               To_String (lb_comma & lb_variable_size (Current_Language)));
         end if;

         if
           ((variables_table.entries (left_var).simulation.ptype =
             simulation_array_integer) or
            (variables_table.entries (left_var).simulation.ptype =
             simulation_array_boolean) or
            (variables_table.entries (left_var).simulation.ptype =
             simulation_array_string) or
            (variables_table.entries (left_var).simulation.ptype =
             simulation_array_double)) and
           ((val.ptype = simulation_time_unit_array_double) or
            (val.ptype = simulation_time_unit_array_double) or
            (val.ptype = simulation_time_unit_array_string) or
            (val.ptype = simulation_time_unit_array_integer))
         then
            Raise_Exception
              (type_error'identity,
               "Assignement statement, line " &
               current.line_number'img &
               ", processor " &
               To_String (processor_name) &
               ", file " &
               To_String (current.file_name) &
               To_String (lb_comma & lb_variable_size (Current_Language)));
         end if;

         -- Start to compute expression evaluation
         --

         if
           ((variables_table.entries (left_var).simulation.ptype =
             simulation_array_integer) or
            (variables_table.entries (left_var).simulation.ptype =
             simulation_array_clock)) and
           ((val.ptype = simulation_integer) or (val.ptype = simulation_clock))
         then
            for i in simulations_range loop
               variables_table.entries (left_var).simulation
                 .integer_table_value
                 (i) :=
                 val.integer_value;
            end loop;

         else
            if
              (variables_table.entries (left_var).simulation.ptype =
               simulation_time_unit_array_integer) and
              (val.ptype = simulation_integer)
            then
               for i in time_unit_range loop
                  variables_table.entries (left_var).simulation
                    .integer_time_unit_table_value
                    (i) :=
                    val.integer_value;
               end loop;

            else
               if
                 (variables_table.entries (left_var).simulation.ptype =
                  simulation_time_unit_array_double) and
                 (val.ptype = simulation_double)
               then
                  for i in time_unit_range loop
                     variables_table.entries (left_var).simulation
                       .double_time_unit_table_value
                       (i) :=
                       val.double_value;
                  end loop;

               else
                  if
                    (variables_table.entries (left_var).simulation.ptype =
                     simulation_time_unit_array_boolean) and
                    (val.ptype = simulation_boolean)
                  then
                     for i in time_unit_range loop
                        variables_table.entries (left_var).simulation
                          .boolean_time_unit_table_value
                          (i) :=
                          val.boolean_value;
                     end loop;

                  else
                     if
                       (variables_table.entries (left_var).simulation.ptype =
                        simulation_time_unit_array_string) and
                       (val.ptype = simulation_string)
                     then
                        for i in time_unit_range loop
                           variables_table.entries (left_var).simulation
                             .string_time_unit_table_value
                             (i) :=
                             val.string_value;
                        end loop;

                     else
                        if
                          (variables_table.entries (left_var).simulation
                             .ptype =
                           simulation_array_boolean) and
                          (val.ptype = simulation_boolean)
                        then
                           for i in simulations_range loop
                              variables_table.entries (left_var).simulation
                                .boolean_table_value
                                (i) :=
                                val.boolean_value;
                           end loop;

                        else
                           if
                             (variables_table.entries (left_var).simulation
                                .ptype =
                              simulation_array_double) and
                             (val.ptype = simulation_double)
                           then
                              for i in simulations_range loop
                                 variables_table.entries (left_var).simulation
                                   .double_table_value
                                   (i) :=
                                   val.double_value;
                              end loop;

                           else
                              if
                                (variables_table.entries (left_var).simulation
                                   .ptype =
                                 simulation_array_string) and
                                (val.ptype = simulation_string)
                              then
                                 for i in simulations_range loop
                                    variables_table.entries (left_var)
                                      .simulation
                                      .string_table_value
                                      (i) :=
                                      val.string_value;
                                 end loop;

                              else
                                 variables_table.entries (left_var)
                                   .simulation :=
                                   value_of
                                     (current.rvalue.all,
                                      variables_table,
                                      current.line_number,
                                      current.file_name);
                              end if;
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end if;

         free (val);

      else

         -- Indexed affectation : the left side AND the right side are indexed
         --

         index :=
           value_of
             (array_variable_expression_ptr (current.lvalue).array_index.all,
              variables_table,
              current.line_number,
              current.file_name);

         if index.ptype /= simulation_integer then
            Raise_Exception
              (type_error'identity,
               "Assignement statement, line " &
               current.line_number'img &
               ", processor " &
               To_String (processor_name) &
               ", file " &
               To_String (current.file_name) &
               To_String (lb_comma & lb_index_error (Current_Language)));
         end if;

         left_var :=
           find_variable
             (variables_table,
              variable_expression_ptr (current.lvalue).name,
              current.line_number,
              current.file_name);

         val :=
           value_of
             (current.rvalue.all,
              variables_table,
              current.line_number,
              current.file_name);

         if (val.ptype /= simulation_integer) and
           (val.ptype /= simulation_boolean) and
           (val.ptype /= simulation_double) and
           (val.ptype /= simulation_clock) and
           (val.ptype /= simulation_string)
         then
            Raise_Exception
              (type_error'identity,
               "Assignement statement, line " &
               current.line_number'img &
               ", processor " &
               To_String (processor_name) &
               ", file " &
               To_String (current.file_name) &
               ", rvalue " &
               To_String (lb_uncompatible_type_error (Current_Language)));
         end if;

         if
           ((val.ptype = simulation_integer) or
            (val.ptype = simulation_clock)) and
           ((variables_table.entries (left_var).simulation.ptype =
             simulation_array_integer) or
            (variables_table.entries (left_var).simulation.ptype =
             simulation_array_clock))
         then
            variables_table.entries (left_var).simulation.integer_table_value
              (simulations_range (index.integer_value)) :=
              val.integer_value;

         else
            if
              ((val.ptype = simulation_double) and
               (variables_table.entries (left_var).simulation.ptype =
                simulation_array_double))
            then
               variables_table.entries (left_var).simulation.double_table_value
                 (simulations_range (index.integer_value)) :=
                 val.double_value;
            else
               if
                 ((val.ptype = simulation_boolean) and
                  (variables_table.entries (left_var).simulation.ptype =
                   simulation_array_boolean))
               then

                  variables_table.entries (left_var).simulation
                    .boolean_table_value
                    (simulations_range (index.integer_value)) :=
                    val.boolean_value;

               else
                  if
                    ((val.ptype = simulation_string) and
                     (variables_table.entries (left_var).simulation.ptype =
                      simulation_array_string))
                  then

                     variables_table.entries (left_var).simulation
                       .string_table_value
                       (simulations_range (index.integer_value)) :=
                       val.string_value;

                  else
                     if
                       ((val.ptype = simulation_integer) and
                        (variables_table.entries (left_var).simulation.ptype =
                         simulation_time_unit_array_integer))
                     then
                        variables_table.entries (left_var).simulation
                          .integer_time_unit_table_value
                          (time_unit_range (index.integer_value)) :=
                          val.integer_value;

                     else
                        if
                          ((val.ptype = simulation_double) and
                           (variables_table.entries (left_var).simulation
                              .ptype =
                            simulation_time_unit_array_double))
                        then
                           variables_table.entries (left_var).simulation
                             .double_time_unit_table_value
                             (time_unit_range (index.integer_value)) :=
                             val.double_value;
                        else
                           if
                             ((val.ptype = simulation_boolean) and
                              (variables_table.entries (left_var).simulation
                                 .ptype =
                               simulation_time_unit_array_boolean))
                           then

                              variables_table.entries (left_var).simulation
                                .boolean_time_unit_table_value
                                (time_unit_range (index.integer_value)) :=
                                val.boolean_value;

                           else
                              if
                                ((val.ptype = simulation_string) and
                                 (variables_table.entries (left_var).simulation
                                    .ptype =
                                  simulation_time_unit_array_string))
                              then

                                 variables_table.entries (left_var).simulation
                                   .string_time_unit_table_value
                                   (time_unit_range (index.integer_value)) :=
                                   val.string_value;
                              else
                                 Raise_Exception
                                   (type_error'identity,
                                    "Assignement statement, line " &
                                    current.line_number'img &
                                    ", processor " &
                                    To_String (processor_name) &
                                    ", file " &
                                    To_String (current.file_name) &
                                    To_String
                                      (lb_comma &
                                       lb_uncompatible_type_error
                                         (Current_Language)));
                              end if;
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end if;

         free (index);
         free (val);

      end if;

      next := current.next_statement;

   exception
      when Constraint_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);
      when Storage_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);
      when Program_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);

   end assign_dispatch;

   procedure put_dispatch
     (current         : in     put_statement_ptr;
      processor_name  : in     Unbounded_String;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String;
      next            : in out generic_statement_ptr)
   is

      expr_simu_ptr : simulation_value_ptr;
      from_simu_ptr : simulation_value_ptr;
      to_simu_ptr   : simulation_value_ptr;

   begin

      if (current.put_from /= null) then
         from_simu_ptr :=
           value_of
             (current.put_from.all,
              variables_table,
              current.line_number,
              current.file_name);
      end if;
      if (current.put_to /= null) then
         to_simu_ptr :=
           value_of
             (current.put_to.all,
              variables_table,
              current.line_number,
              current.file_name);
      end if;
      expr_simu_ptr :=
        value_of
          (current.expression_to_be_displayed.all,
           variables_table,
           current.line_number,
           current.file_name);

      if (current.put_to /= null) then
         if (to_simu_ptr.ptype /= simulation_integer) or
           (from_simu_ptr.ptype /= simulation_integer)
         then
            Raise_Exception
              (type_error'identity,
               "Put parameter should be an integer, line " &
               current.line_number'img &
               ", processor " &
               To_String (processor_name) &
               ", file " &
               To_String (current.file_name) &
               To_String
                 (lb_comma & lb_uncompatible_type_error (Current_Language)));
         end if;
      end if;

      msg :=
        msg & To_Unbounded_String ("- Line " & current.line_number'img & ", ");

      if (current.put_to /= null) and (current.put_from /= null) then
         msg :=
           msg &
           to_unbounded_string
             (expr_simu_ptr,
              from_simu_ptr.integer_value,
              to_simu_ptr.integer_value) &
           unbounded_lf;

         free (from_simu_ptr);
         free (to_simu_ptr);

      else
         if
           ((expr_simu_ptr.ptype = simulation_time_unit_array_boolean) or
            (expr_simu_ptr.ptype = simulation_time_unit_array_integer) or
            (expr_simu_ptr.ptype = simulation_time_unit_array_double) or
            (expr_simu_ptr.ptype = simulation_time_unit_array_string))
         then
            msg :=
              msg &
              to_unbounded_string (current.expression_to_be_displayed.all) &
              "=" &
              to_unbounded_string
                (expr_simu_ptr,
                 Integer (time_unit_range'first),
                 Integer (time_unit_range'last)) &
              unbounded_lf;
         else
            if
              ((expr_simu_ptr.ptype = simulation_array_boolean) or
               (expr_simu_ptr.ptype = simulation_array_integer) or
               (expr_simu_ptr.ptype = simulation_array_clock) or
               (expr_simu_ptr.ptype = simulation_array_string) or
               (expr_simu_ptr.ptype = simulation_array_double))
            then
               msg :=
                 msg &
                 to_unbounded_string
                   (expr_simu_ptr,
                    Integer (simulations_range'first),
                    Integer (simulations_range'last)) &
                 unbounded_lf;
            else
               msg := msg & to_unbounded_string (expr_simu_ptr) & unbounded_lf;
            end if;
         end if;
      end if;

      free (expr_simu_ptr);

      next := current.next_statement;

   exception
      when Constraint_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);
      when Storage_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);
      when Program_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);

   end put_dispatch;

   procedure while_dispatch
     (current         : in     while_statement_ptr;
      current_section : in     sections_type;
      processor_name  : in     Unbounded_String;
      si              : in out scheduling_information;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String;
      next            : in out generic_statement_ptr)
   is

      simu_ptr : simulation_value_ptr;

   begin

      -- Let's run included statements :
      -- do a loop iteration
      --
      loop

         simu_ptr :=
           value_of
             (current.condition.all,
              variables_table,
              current.line_number,
              current.file_name);
         if simu_ptr.ptype /= simulation_boolean then
            Raise_Exception
              (type_error'identity,
               "while statement, line " &
               current.line_number'img &
               ", processor " &
               To_String (processor_name) &
               ", file " &
               To_String (current.file_name) &
               ", " &
               To_String (lb_uncompatible_type_error (Current_Language)));
         end if;

         exit when simu_ptr.boolean_value = False;

         dispatch
           (current.included_statement,
            current_section,
            processor_name,
            si,
            variables_table,
            msg);

      end loop;

      free (simu_ptr);

      next := generic_statement_ptr (current.next_statement);

   exception
      when Constraint_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);
      when Storage_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);
      when Program_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);

   end while_dispatch;

   procedure for_dispatch
     (current         : in     for_statement_ptr;
      current_section : in     sections_type;
      processor_name  : in     Unbounded_String;
      si              : in out scheduling_information;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String;
      next            : in out generic_statement_ptr)
   is

      var            : variables_range;
      var_loop_index : variables_range;

   begin

      -- Test is the expression included in the for
      -- statement is a variable ... raise a exception
      -- in the other cases
      --
      if current.for_index.expression_type = variable_type then
         if variable_expression_ptr (current.for_index).variable_type /=
           simulation_integer
         then
            Raise_Exception
              (type_error'identity,
               "for statement, line " &
               current.line_number'img &
               ", processor " &
               To_String (processor_name) &
               ", file " &
               To_String (current.file_name) &
               ", for expression have to be an integer variable");
         end if;
      else
         Raise_Exception
           (type_error'identity,
            "for statement, line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            ", for expression have to be an integer variable");
      end if;

      -- Let's run included statements :
      -- do a loop iteration
      --

      case current.for_type is
         when task_table_type =>
            var_loop_index :=
              find_variable
                (variables_table,
                 "nb_tasks",
                 current.line_number,
                 current.file_name);
         when processor_table_type =>
            var_loop_index :=
              find_variable
                (variables_table,
                 "nb_processors",
                 current.line_number,
                 current.file_name);
         when buffer_table_type =>
            var_loop_index :=
              find_variable
                (variables_table,
                 "nb_buffers",
                 current.line_number,
                 current.file_name);
         when time_unit_table_type =>
            var_loop_index :=
              find_variable
                (variables_table,
                 "nb_time_units",
                 current.line_number,
                 current.file_name);
         when resource_table_type =>
            var_loop_index :=
              find_variable
                (variables_table,
                 "nb_resources",
                 current.line_number,
                 current.file_name);
         when message_table_type =>
            var_loop_index :=
              find_variable
                (variables_table,
                 "nb_messages",
                 current.line_number,
                 current.file_name);
      end case;

      for i in
        0 ..
            Natural
              (variables_table.entries (var_loop_index).simulation
                 .integer_value -
               1)
      loop

         var :=
           find_variable
             (variables_table,
              variable_expression_ptr (current.for_index).name,
              current.line_number,
              current.file_name);
         variables_table.entries (var).simulation.integer_value := Integer (i);

         dispatch
           (current.included_statement,
            current_section,
            processor_name,
            si,
            variables_table,
            msg);

      end loop;

      next := generic_statement_ptr (current.next_statement);

   exception
      when Constraint_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);
      when Storage_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);
      when Program_Error =>
         Raise_Exception
           (statement_error'identity,
            "line " &
            current.line_number'img &
            ", processor " &
            To_String (processor_name) &
            ", file " &
            To_String (current.file_name) &
            " ; Exception raised :" &
            Exception_Name &
            ":" &
            Exception_Message);

   end for_dispatch;

   procedure dispatch
     (current         : in     generic_statement_ptr;
      current_section : in     sections_type;
      processor_name  : in     Unbounded_String;
      si              : in out scheduling_information;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String)
   is

      next       : generic_statement_ptr;
      my_current : generic_statement_ptr := current;

   begin

      if my_current /= null then
         loop

            -- Run the associated statement
            --
            case my_current.statement_type is

               when exit_statement_type =>
                  Raise_Exception
                    (exit_statement_exception'identity,
                     "line " &
                     current.line_number'img &
                     ", processor " &
                     To_String (processor_name) &
                     ", file " &
                     To_String (current.file_name) &
                     " ;  simulation stopped by exit statement.");

               when put_statement_type =>
                  put_dispatch
                    (put_statement_ptr (my_current),
                     processor_name,
                     variables_table,
                     msg,
                     next);

               when nop_statement_type =>
                  next := my_current.next_statement;

               when if_statement_type =>
                  if_dispatch
                    (if_statement_ptr (my_current),
                     current_section,
                     processor_name,
                     si,
                     variables_table,
                     msg,
                     next);

               when random_initialize_statement_type =>
                  random_initialize_dispatch
                    (random_initialize_statement_ptr (my_current),
                     processor_name,
                     variables_table,
                     msg,
                     next);

               when assign_statement_type | clock_statement_type =>
                  assign_dispatch
                    (assign_statement_ptr (my_current),
                     processor_name,
                     variables_table,
                     msg,
                     next);

               when for_statement_type =>
                  for_dispatch
                    (for_statement_ptr (my_current),
                     current_section,
                     processor_name,
                     si,
                     variables_table,
                     msg,
                     next);

               when return_statement_type =>
                  -- Check if a return statement is called
                  --
                  if
                    (return_statement_ptr (my_current).return_value /=
                     null) and
                    (current_section /= election_type)
                  then
                     Raise_Exception
                       (type_error'identity,
                        current_section'img &
                        " section, line " &
                        current.line_number'img &
                        ", processor " &
                        To_String (processor_name) &
                        ", file " &
                        To_String (current.file_name) &
                        ", invalid return value from return statement");
                  end if;
                  exit;

               when while_statement_type =>
                  while_dispatch
                    (while_statement_ptr (my_current),
                     current_section,
                     processor_name,
                     si,
                     variables_table,
                     msg,
                     next);

               when delete_precedence_statement_type =>
                  delete_precedence_dispatch
                    (delete_precedence_statement_ptr (my_current),
                     processor_name,
                     si,
                     variables_table,
                     msg,
                     next);

               when add_precedence_statement_type =>
                  add_precedence_dispatch
                    (add_precedence_statement_ptr (my_current),
                     processor_name,
                     si,
                     variables_table,
                     msg,
                     next);

               when set_statement_type =>
                  null;

               when subprogram_statement_type =>
                  null;

               when subprogram_call_statement_type =>
                  null;

            end case;

            -- Last statement ?
            --
            exit when next = null;

            my_current := next;

         end loop;
      end if;

   end dispatch;

end Interpreter.extended;
