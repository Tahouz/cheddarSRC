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

with Ada.Strings.Unbounded.Text_IO; use Ada.Strings.Unbounded.Text_IO;
with Ada.Exceptions;                use Ada.Exceptions;
with Ada.Numerics;                  use Ada.Numerics;
with Ada.Numerics.Float_Random;     use Ada.Numerics.Float_Random;

with translate;                     use translate;
with time_unit_events;              use time_unit_events;
with qs_tools;                      use qs_tools;
with systems;                       use systems;
with Messages;                      use Messages;
with Tasks;                         use Tasks;
with Buffers;                       use Buffers;
with Resources;                     use Resources;
with Parameters;                    use Parameters;
use Parameters.User_Defined_Parameters_Table_Package;
with Laws;                          use Laws;
with Doubles;                       use Doubles;

with integer_util;

package body expressions is

   procedure put_name (obj : in generic_expression_ptr) is
   begin
      null;
   end put_name;
   procedure put_name (obj : in constant_expression_ptr) is
   begin
      null;
   end put_name;
   procedure put_name (obj : in variable_expression_ptr) is
   begin
      null;
   end put_name;
   procedure put_name (obj : in array_variable_expression_ptr) is
   begin
      null;
   end put_name;
   procedure put_name (obj : in binary_expression_ptr) is
   begin
      null;
   end put_name;
   procedure put_name (obj : in unary_expression_ptr) is
   begin
      null;
   end put_name;

   function get_name (obj : in generic_expression) return Unbounded_String is
   begin
      return To_Unbounded_String ("");
   end get_name;
   function get_name (obj : in constant_expression) return Unbounded_String is
   begin
      return To_Unbounded_String ("");
   end get_name;
   function get_name (obj : in variable_expression) return Unbounded_String is
   begin
      return To_Unbounded_String ("");
   end get_name;
   function get_name (obj : in unary_expression) return Unbounded_String is
   begin
      return To_Unbounded_String ("");
   end get_name;
   function get_name (obj : in binary_expression) return Unbounded_String is
   begin
      return To_Unbounded_String ("");
   end get_name;
   function get_name
     (obj : in array_variable_expression) return Unbounded_String
   is
   begin
      return To_Unbounded_String ("");
   end get_name;

   function get_name
     (obj : in generic_expression_ptr) return Unbounded_String
   is
   begin
      return To_Unbounded_String ("");
   end get_name;
   function get_name
     (obj : in variable_expression_ptr) return Unbounded_String
   is
   begin
      return To_Unbounded_String ("");
   end get_name;
   function get_name
     (obj : in array_variable_expression_ptr) return Unbounded_String
   is
   begin
      return To_Unbounded_String ("");
   end get_name;
   function get_name (obj : in unary_expression_ptr) return Unbounded_String is
   begin
      return To_Unbounded_String ("");
   end get_name;
   function get_name
     (obj : in constant_expression_ptr) return Unbounded_String
   is
   begin
      return To_Unbounded_String ("");
   end get_name;
   function get_name
     (obj : in binary_expression_ptr) return Unbounded_String
   is
   begin
      return To_Unbounded_String ("");
   end get_name;

   function xml_string (e : in variable_record_ptr) return Unbounded_String is
   begin
      raise xml_ref_string_error;
      return To_Unbounded_String ("");
   end xml_string;

   function xml_ref_string
     (e : in variable_record_ptr) return Unbounded_String
   is
   begin
      raise xml_ref_string_error;
      return To_Unbounded_String ("");
   end xml_ref_string;

   procedure put (v : in variable_record_ptr) is
   begin
      put (v.variable);
      put (v.simulation);
   end put;

   function find_variable
     (var_table : in variables_table_type;
      s         : in Unbounded_String;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return variables_range
   is
   begin
      for i in 0 .. var_table.nb_entries - 1 loop
         if var_table.entries (i).variable.name = s then
            return i;
         end if;
      end loop;

      if (line = 0) then
         Raise_Exception
           (expressions.syntax_error'identity,
            To_String
              (s & lb_comma & lb_undeclared_identifier (Current_Language)));
      else
         Raise_Exception
           (expressions.syntax_error'identity,
            "file " &
            To_String (file_name) &
            ", line " &
            line'img &
            To_String
              (lb_comma &
               s &
               lb_comma &
               lb_undeclared_identifier (Current_Language)));
      end if;

   end find_variable;

   function find_variable
     (var_table : in variables_table_type;
      s         : in String;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return variables_range
   is
   begin
      return find_variable
          (var_table,
           To_Unbounded_String (s),
           line,
           file_name);
   end find_variable;

   procedure check_variable_declaration
     (var_table : in variables_table_type;
      s         : in Unbounded_String;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string)
   is

      dummy : constant variables_range :=
        find_variable (var_table, s, line, file_name);

   begin
      null;
   end check_variable_declaration;

   procedure initialize_parametric_variables
     (var_table      : in out variables_table_type;
      my_messages    : in     messages_set;
      my_buffers     : in     buffers_set;
      my_resources   : in     resources_set;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String := empty_string)

   is

      var   : variables_range;
      index : simulations_range;

      a_message          : generic_message_ptr;
      a_message_iterator : messages_iterator;

      a_buffer          : buffer_ptr;
      a_buffer_iterator : buffers_iterator;

      a_task          : generic_task_ptr;
      a_task_iterator : tasks_iterator;

      a_resource          : generic_resource_ptr;
      a_resource_iterator : resources_iterator;

   begin

      ---------------------------------------------------------------
      --   Set message variables
      ---------------------------------------------------------------

      -- "nb_messages"
      --
      var := find_variable (var_table, To_Unbounded_String ("nb_messages"));
      var_table.entries (var).simulation.integer_value :=
        Integer (get_number_of_elements (my_messages));

      if not is_empty (my_messages) then
         reset_iterator (my_messages, a_message_iterator);
         index := 0;

         loop
            current_element (my_messages, a_message, a_message_iterator);

            -- "messages.name"
            --
            var :=
              find_variable (var_table, To_Unbounded_String ("messages.name"));
            var_table.entries (var).simulation.string_table_value (index) :=
              a_message.name;

            -- "messages.deadline"
            --
            var :=
              find_variable
                (var_table,
                 To_Unbounded_String ("messages.deadline"));
            var_table.entries (var).simulation.integer_table_value (index) :=
              Integer (a_message.deadline);

            -- "messages.delay"
            --
            var :=
              find_variable
                (var_table,
                 To_Unbounded_String ("messages.delay"));
            var_table.entries (var).simulation.integer_table_value (index) :=
              Integer (a_message.response_time);

            -- "messages.size"
            --
            var :=
              find_variable (var_table, To_Unbounded_String ("messages.size"));
            var_table.entries (var).simulation.integer_table_value (index) :=
              Integer (a_message.size);

            -- "messages.period" and "messages.jitter"
            --
            var :=
              find_variable
                (var_table,
                 To_Unbounded_String ("messages.period"));
            case a_message.message_type is
               when aperiodic_type =>
                  var_table.entries (var).simulation.integer_table_value
                    (index) :=
                    0;
               when others =>
                  var_table.entries (var).simulation.integer_table_value
                    (index) :=
                    Integer (periodic_message_ptr (a_message).period);
            end case;
            var :=
              find_variable
                (var_table,
                 To_Unbounded_String ("messages.jitter"));
            case a_message.message_type is
               when aperiodic_type =>
                  var_table.entries (var).simulation.integer_table_value
                    (index) :=
                    0;
               when others =>
                  var_table.entries (var).simulation.integer_table_value
                    (index) :=
                    Integer (periodic_message_ptr (a_message).jitter);
            end case;

            -- "messages.ready"
            --
            var :=
              find_variable
                (var_table,
                 To_Unbounded_String ("messages.ready"));
            var_table.entries (var).simulation.boolean_table_value (index) :=
              False;

            exit when is_last_element (my_messages, a_message_iterator);
            next_element (my_messages, a_message_iterator);
            index := index + 1;

         end loop;
      end if;

      ---------------------------------------------------------------
      --   Set buffer variables
      ---------------------------------------------------------------

      -- "nb_buffers"
      --
      var := find_variable (var_table, To_Unbounded_String ("nb_buffers"));
      if processor_name = empty_string then
         var_table.entries (var).simulation.integer_value :=
           Integer (get_number_of_elements (my_buffers));
      else
         var_table.entries (var).simulation.integer_value :=
           Integer
             (get_number_of_buffer_from_processor
                (my_buffers,
                 processor_name));
      end if;

      if not is_empty (my_buffers) then
         reset_iterator (my_buffers, a_buffer_iterator);
         index := 0;

         loop
            current_element (my_buffers, a_buffer, a_buffer_iterator);

            -- "buffers.processor_name"
            --
            var :=
              find_variable
                (var_table,
                 To_Unbounded_String ("buffers.processor_name"));
            var_table.entries (var).simulation.string_table_value (index) :=
              a_buffer.cpu_name;

            -- "buffers.name"
            --
            var :=
              find_variable (var_table, To_Unbounded_String ("buffers.name"));
            var_table.entries (var).simulation.string_table_value (index) :=
              a_buffer.name;

            -- "buffers.max_size"
            --
            var :=
              find_variable
                (var_table,
                 To_Unbounded_String ("buffers.max_size"));
            var_table.entries (var).simulation.integer_table_value (index) :=
              Integer (a_buffer.buffer_size);

            exit when is_last_element (my_buffers, a_buffer_iterator);
            next_element (my_buffers, a_buffer_iterator);
            index := index + 1;

         end loop;
      end if;

      ---------------------------------------------------------------
      --   Set resource variables
      ---------------------------------------------------------------

      -- "nb_resources"
      --
      var := find_variable (var_table, To_Unbounded_String ("nb_resources"));
      if processor_name = empty_string then
         var_table.entries (var).simulation.integer_value :=
           Integer (get_number_of_elements (my_resources));
      else
         var_table.entries (var).simulation.integer_value :=
           Integer
             (get_number_of_resource_from_processor
                (my_resources,
                 processor_name));
      end if;

      if not is_empty (my_resources) then
         reset_iterator (my_resources, a_resource_iterator);
         index := 0;

         loop
            current_element (my_resources, a_resource, a_resource_iterator);

            -- "resources.name"
            --
            var :=
              find_variable
                (var_table,
                 To_Unbounded_String ("resources.name"));
            var_table.entries (var).simulation.string_table_value (index) :=
              a_resource.name;

            -- "resources.initial_state"
            --
            var :=
              find_variable
                (var_table,
                 To_Unbounded_String ("resources.initial_state"));
            var_table.entries (var).simulation.integer_table_value (index) :=
              a_resource.state;

            -- "resources.protocol"
            --
            var :=
              find_variable
                (var_table,
                 To_Unbounded_String ("resources.protocol"));
            var_table.entries (var).simulation.string_table_value (index) :=
              To_Unbounded_String (a_resource.protocol'img);

            -- "resources.processor_name"
            --
            var :=
              find_variable
                (var_table,
                 To_Unbounded_String ("resources.processor_name"));
            var_table.entries (var).simulation.string_table_value (index) :=
              a_resource.cpu_name;

            exit when is_last_element (my_resources, a_resource_iterator);
            next_element (my_resources, a_resource_iterator);
            index := index + 1;

         end loop;
      end if;

      ---------------------------------------------------------------
      --   Set task variables
      ---------------------------------------------------------------

      -- "nb_tasks"
      --
      var := find_variable (var_table, To_Unbounded_String ("nb_tasks"));
      if processor_name = empty_string then
         var_table.entries (var).simulation.integer_value :=
           Integer (get_number_of_elements (my_tasks));
      else
         var_table.entries (var).simulation.integer_value :=
           Integer
             (get_number_of_task_from_processor (my_tasks, processor_name));
      end if;

      reset_iterator (my_tasks, a_task_iterator);
      index := 0;

      loop
         current_element (my_tasks, a_task, a_task_iterator);

         -- "tasks.priority"
         --
         var :=
           find_variable (var_table, To_Unbounded_String ("tasks.priority"));
         var_table.entries (var).simulation.integer_table_value (index) :=
           Integer (a_task.priority);

         -- "tasks.deadline"
         --
         var :=
           find_variable (var_table, To_Unbounded_String ("tasks.deadline"));
         var_table.entries (var).simulation.integer_table_value (index) :=
           Integer (a_task.deadline);

         -- "tasks.start_time"
         --
         var :=
           find_variable (var_table, To_Unbounded_String ("tasks.start_time"));
         var_table.entries (var).simulation.integer_table_value (index) :=
           Integer (a_task.start_time);

         -- "tasks.suspended"
         --
         var :=
           find_variable (var_table, To_Unbounded_String ("tasks.suspended"));
         var_table.entries (var).simulation.boolean_table_value (index) :=
           False;

         -- "tasks.type"
         --
         var := find_variable (var_table, To_Unbounded_String ("tasks.type"));
         var_table.entries (var).simulation.string_table_value (index) :=
           To_Unbounded_String (a_task.task_type'img);

         -- "tasks.processor_name"
         --
         var :=
           find_variable
             (var_table,
              To_Unbounded_String ("tasks.processor_name"));
         var_table.entries (var).simulation.string_table_value (index) :=
           a_task.cpu_name;

         -- "tasks.name"
         --
         var := find_variable (var_table, To_Unbounded_String ("tasks.name"));
         var_table.entries (var).simulation.string_table_value (index) :=
           a_task.name;

         -- "tasks.capacity"
         --
         var :=
           find_variable (var_table, To_Unbounded_String ("tasks.capacity"));
         var_table.entries (var).simulation.integer_table_value (index) :=
           Integer (a_task.capacity);

         -- "tasks.blocking_time"
         --
         var :=
           find_variable
             (var_table,
              To_Unbounded_String ("tasks.blocking_time"));
         var_table.entries (var).simulation.integer_table_value (index) :=
           Integer (a_task.blocking_time);

         -- "tasks.period"
         --
         var :=
           find_variable (var_table, To_Unbounded_String ("tasks.period"));
         case a_task.task_type is
            when aperiodic_type =>
               var_table.entries (var).simulation.integer_table_value
                 (index) :=
                 0;
            when others =>
               var_table.entries (var).simulation.integer_table_value
                 (index) :=
                 Integer (periodic_task_ptr (a_task).period);
         end case;

         -- "tasks.jitter"
         --
         var :=
           find_variable (var_table, To_Unbounded_String ("tasks.jitter"));
         case a_task.task_type is
            when aperiodic_type =>
               var_table.entries (var).simulation.integer_table_value
                 (index) :=
                 0;
            when others =>
               var_table.entries (var).simulation.integer_table_value
                 (index) :=
                 Integer (periodic_task_ptr (a_task).jitter);
         end case;

         -- user defined task's parameter :
         --

         for i in 0 .. a_task.parameters.nb_entries - 1 loop

            -- Find the user defined variable
            -- and set its value
            --
            for j in 0 .. var_table.nb_entries - 1 loop
               if var_table.entries (j).variable.name =
                 To_Unbounded_String ("tasks.") &
                   a_task.parameters.entries (i).parameter_name
               then

                  -- Now, set the value
                  --
                  if a_task.parameters.entries (i).type_of_parameter =
                    boolean_parameter
                  then
                     var_table.entries (j).simulation.boolean_table_value
                       (index) :=
                       Boolean (a_task.parameters.entries (i).boolean_value);
                  end if;
                  if a_task.parameters.entries (i).type_of_parameter =
                    integer_parameter
                  then
                     var_table.entries (j).simulation.integer_table_value
                       (index) :=
                       Integer (a_task.parameters.entries (i).integer_value);
                  end if;
                  if a_task.parameters.entries (i).type_of_parameter =
                    double_parameter
                  then
                     var_table.entries (j).simulation.double_table_value
                       (index) :=
                       Double (a_task.parameters.entries (i).double_value);
                  end if;
                  if a_task.parameters.entries (i).type_of_parameter =
                    string_parameter
                  then
                     var_table.entries (j).simulation.string_table_value
                       (index) :=
                       a_task.parameters.entries (i).string_value;
                  end if;
               end if;
            end loop;
         end loop;

         exit when is_last_element (my_tasks, a_task_iterator);
         next_element (my_tasks, a_task_iterator);
         index := index + 1;

      end loop;

   end initialize_parametric_variables;

   procedure create_parametric_variables
     (variables_table : in out variables_table_type;
      my_tasks        : in     tasks_set)
   is

      new_var           : variable_record_ptr;
      new_expr_array    : array_variable_expression_ptr;
      new_expr_variable : variable_expression_ptr;
      do_insert         : Boolean;
      a_task            : generic_task_ptr;
      iterator          : tasks_iterator;

   begin

      initialize (variables_table);

      ------------------------------------------------------
      --              common variables
      ------------------------------------------------------

      -- "previously_elected"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_integer;
      new_expr_variable.name := To_Unbounded_String ("previously_elected");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "nb_tasks"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_integer;
      new_expr_variable.name          := To_Unbounded_String ("nb_tasks");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "nb_processors"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_integer;
      new_expr_variable.name          := To_Unbounded_String ("nb_processors");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "nb_messages"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_integer;
      new_expr_variable.name          := To_Unbounded_String ("nb_messages");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "nb_buffers"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_integer;
      new_expr_variable.name          := To_Unbounded_String ("nb_buffers");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "nb_resources"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_integer;
      new_expr_variable.name          := To_Unbounded_String ("nb_resources");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "nb_address_spaces"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_integer;
      new_expr_variable.name := To_Unbounded_String ("nb_address_spaces");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "nb_time_units"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_integer;
      new_expr_variable.name          := To_Unbounded_String ("nb_time_units");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "simulation_time"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_integer;
      new_expr_variable.name := To_Unbounded_String ("simulation_time");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "simulation_length"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_integer;
      new_expr_variable.name := To_Unbounded_String ("simulation_length");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      ------------------------------------------------------
      --              Processor variables
      ------------------------------------------------------

      -- "processors.speed"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_integer;
      new_expr_variable.name := To_Unbounded_String ("processors.speed");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      ------------------------------------------------------
      --              Buffer variables
      ------------------------------------------------------

      -- "buffers.name"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_string;
      new_expr_variable.name          := To_Unbounded_String ("buffers.name");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "buffers.max_size"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_integer;
      new_expr_variable.name := To_Unbounded_String ("buffers.max_size");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "buffers.processor_name"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_string;
      new_expr_variable.name := To_Unbounded_String ("buffers.processor_name");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "buffers.users.time"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_integer;
      new_expr_variable.name := To_Unbounded_String ("buffers.users.time");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "buffers.users.size"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_integer;
      new_expr_variable.name := To_Unbounded_String ("buffers.users.size");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "buffers.users.task_name"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_string;
      new_expr_variable.name          :=
        To_Unbounded_String ("buffers.users.task_name");
      new_var.variable := new_expr_variable;
      add (variables_table, new_var);

      ------------------------------------------------------
      --              Message variables
      ------------------------------------------------------

      -- "messages.jitter"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_integer;
      new_expr_variable.name := To_Unbounded_String ("messages.jitter");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "messages.delay"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_integer;
      new_expr_variable.name := To_Unbounded_String ("messages.delay");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "messages.name"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_string;
      new_expr_variable.name          := To_Unbounded_String ("messages.name");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "messages.deadline"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_integer;
      new_expr_variable.name := To_Unbounded_String ("messages.deadline");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "messages.period"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_integer;
      new_expr_variable.name := To_Unbounded_String ("messages.period");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "messages.ready"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_boolean;
      new_expr_variable.name := To_Unbounded_String ("messages.ready");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "messages.size"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_integer;
      new_expr_variable.name          := To_Unbounded_String ("messages.size");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "messages.users.time"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_integer;
      new_expr_variable.name := To_Unbounded_String ("messages.users.time");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "messages.users.type"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_string;
      new_expr_variable.name := To_Unbounded_String ("messages.users.type");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "messages.users.task_name"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_string;
      new_expr_variable.name          :=
        To_Unbounded_String ("messages.users.task_name");
      new_var.variable := new_expr_variable;
      add (variables_table, new_var);

      ------------------------------------------------------
      --              Event variables
      ------------------------------------------------------

      -- "events.time"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_integer;
      new_expr_variable.name          := To_Unbounded_String ("events.time");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "events.processor_name"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_string;
      new_expr_variable.name := To_Unbounded_String ("events.processor_name");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "events.type"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_string;
      new_expr_variable.name          := To_Unbounded_String ("events.type");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "events.task_name"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_string;
      new_expr_variable.name := To_Unbounded_String ("events.task_name");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "events.buffer_name"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_string;
      new_expr_variable.name := To_Unbounded_String ("events.buffer_name");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "events.resource_name"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_string;
      new_expr_variable.name := To_Unbounded_String ("events.resource_name");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "events.message_name"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new variable_expression;
      new_expr_variable.variable_type := simulation_string;
      new_expr_variable.name := To_Unbounded_String ("events.message_name");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      ------------------------------------------------------
      --              Resource variables
      ------------------------------------------------------

      -- "resources.initial_state"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_integer;
      new_expr_variable.name          :=
        To_Unbounded_String ("resources.initial_state");
      new_var.variable := new_expr_variable;
      add (variables_table, new_var);

      -- "resources.processor_name"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_string;
      new_expr_variable.name          :=
        To_Unbounded_String ("resources.processor_name");
      new_var.variable := new_expr_variable;
      add (variables_table, new_var);

      -- "resources.protocol"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_string;
      new_expr_variable.name := To_Unbounded_String ("resources.protocol");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "resources.name"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_string;
      new_expr_variable.name := To_Unbounded_String ("resources.name");
      new_var.variable                := new_expr_variable;
      add (variables_table, new_var);

      -- "resources.current_state"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_integer;
      new_expr_variable.name          :=
        To_Unbounded_String ("resources.current_state");
      new_var.variable := new_expr_variable;
      add (variables_table, new_var);

      -- "resources.users.task_name"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_string;
      new_expr_variable.name          :=
        To_Unbounded_String ("resources.users.task_name");
      new_var.variable := new_expr_variable;
      add (variables_table, new_var);

      -- "resources.users.start_time"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_integer;
      new_expr_variable.name          :=
        To_Unbounded_String ("resources.users.start_time");
      new_var.variable := new_expr_variable;
      add (variables_table, new_var);

      -- "resources.users.end_time"
      --
      new_var                         := new variable_record;
      new_expr_variable               := new array_variable_expression;
      new_expr_variable.variable_type := simulation_array_integer;
      new_expr_variable.name          :=
        To_Unbounded_String ("resources.users.end_time");
      new_var.variable := new_expr_variable;
      add (variables_table, new_var);

      ------------------------------------------------------
      --              Task variables
      ------------------------------------------------------

      -- "tasks.priority"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_integer;
      new_expr_array.name          := To_Unbounded_String ("tasks.priority");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- "tasks.deadline"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_integer;
      new_expr_array.name          := To_Unbounded_String ("tasks.deadline");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- "tasks.start_time"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_integer;
      new_expr_array.name          := To_Unbounded_String ("tasks.start_time");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- "tasks.capacity"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_integer;
      new_expr_array.name          := To_Unbounded_String ("tasks.capacity");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- "tasks.rest_of_capacity"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_integer;
      new_expr_array.name := To_Unbounded_String ("tasks.rest_of_capacity");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- "tasks.used_capacity"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_integer;
      new_expr_array.name := To_Unbounded_String ("tasks.used_capacity");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- "tasks.activation_number"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_integer;
      new_expr_array.name := To_Unbounded_String ("tasks.activation_number");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- "tasks.wakeup_time"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_integer;
      new_expr_array.name := To_Unbounded_String ("tasks.wakeup_time");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- "tasks.used_cpu"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_integer;
      new_expr_array.name          := To_Unbounded_String ("tasks.used_cpu");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- "tasks.period"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_integer;
      new_expr_array.name          := To_Unbounded_String ("tasks.period");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- "tasks.ready"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_boolean;
      new_expr_array.name          := To_Unbounded_String ("tasks.ready");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- "tasks.suspended"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_boolean;
      new_expr_array.name          := To_Unbounded_String ("tasks.suspended");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- "tasks.type"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_string;
      new_expr_array.name          := To_Unbounded_String ("tasks.type");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- "tasks.processor_name"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_string;
      new_expr_array.name := To_Unbounded_String ("tasks.processor_name");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- "tasks.blocking_time"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_integer;
      new_expr_array.name := To_Unbounded_String ("tasks.blocking_time");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- "tasks.name"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_string;
      new_expr_array.name          := To_Unbounded_String ("tasks.name");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- "tasks.jitter"
      --
      new_var                      := new variable_record;
      new_expr_array               := new array_variable_expression;
      new_expr_array.variable_type := simulation_array_integer;
      new_expr_array.name          := To_Unbounded_String ("tasks.jitter");
      new_var.variable             := variable_expression_ptr (new_expr_array);
      add (variables_table, new_var);

      -- Task's user defined parameters
      --
      -- Find user defined parameters : scan all task
      -- Variables and add them
      --
      if not is_empty (my_tasks) then

         reset_iterator (my_tasks, iterator);
         loop
            current_element (my_tasks, a_task, iterator);

            for i in 0 .. a_task.parameters.nb_entries - 1 loop
               -- Is the Variable already exists ?
               --
               do_insert := True;
               for j in 0 .. variables_table.nb_entries - 1 loop
                  if variables_table.entries (j).variable.name =
                    To_Unbounded_String ("tasks.") &
                      a_task.parameters.entries (i).parameter_name
                  then
                     do_insert := False;
                  end if;
               end loop;

               if do_insert then
                  new_var        := new variable_record;
                  new_expr_array := new array_variable_expression;
                  if a_task.parameters.entries (i).type_of_parameter =
                    integer_parameter
                  then
                     new_expr_array.variable_type := simulation_array_integer;
                  end if;
                  if a_task.parameters.entries (i).type_of_parameter =
                    double_parameter
                  then
                     new_expr_array.variable_type := simulation_array_double;
                  end if;
                  if a_task.parameters.entries (i).type_of_parameter =
                    boolean_parameter
                  then
                     new_expr_array.variable_type := simulation_array_boolean;
                  end if;
                  if a_task.parameters.entries (i).type_of_parameter =
                    string_parameter
                  then
                     new_expr_array.variable_type := simulation_array_string;
                  end if;

                  new_expr_array.name :=
                    To_Unbounded_String ("tasks.") &
                    a_task.parameters.entries (i).parameter_name;
                  new_var.variable := variable_expression_ptr (new_expr_array);
                  add (variables_table, new_var);
               end if;

            end loop;

            exit when is_last_element (my_tasks, iterator);
            next_element (my_tasks, iterator);

         end loop;
      end if;

      ---------------------------------------------------------------
      -- Initialize simulation data : provide initial values for
      -- all variables
      ---------------------------------------------------------------

      -- Allocate simulation data
      --
      for i in 0 .. variables_table.nb_entries - 1 loop

         variables_table.entries (i).simulation :=
           new simulation_value
           (variable_expression_ptr (variables_table.entries (i).variable)
              .variable_type);

      end loop;

   end create_parametric_variables;

   --------------------------------------------------

   procedure put (s : in constant_expression) is
   begin
      Put (to_unbounded_string (s));
   end put;

   procedure put (s : in constant_expression_ptr) is
   begin
      Put (to_unbounded_string (s.all));
   end put;

   procedure put (s : in variable_expression) is
   begin
      Put (s.name);
      Put ("/");
      Put (s.variable_type'img);
   end put;

   procedure put (s : in variable_expression_ptr) is
   begin
      put (s.all);
   end put;

   procedure put (s : in array_variable_expression) is
   begin
      Put (s.name);
      Put ("/");
      Put (s.variable_type'img);
      if (s.array_index /= null) then
         put (s.array_index.all);
      end if;
   end put;

   procedure put (s : in array_variable_expression_ptr) is
   begin
      put (s.all);
   end put;

   procedure put (s : in binary_expression) is
   begin
      if (s.lvalue /= null) then
         put (s.lvalue.all);
      end if;
      Put (s.ope);
      if (s.rvalue /= null) then
         put (s.rvalue.all);
      end if;
   end put;

   procedure put (s : in binary_expression_ptr) is
   begin
      put (s.all);
   end put;

   procedure put (s : in unary_expression) is
   begin
      Put (to_unbounded_string (s));
   end put;

   procedure put (s : in unary_expression_ptr) is
   begin
      Put (to_unbounded_string (s.all));
   end put;

   --------------------------------------------------

   function xml_string (obj : in generic_expression) return Unbounded_String is
   begin
      raise xml_string_error;
      return To_Unbounded_String ("");
   end xml_string;

   function xml_string
     (obj : in generic_expression_ptr) return Unbounded_String
   is
   begin
      raise xml_string_error;
      return To_Unbounded_String ("");
   end xml_string;

   function xml_ref_string
     (obj : in generic_expression) return Unbounded_String
   is
   begin
      raise xml_ref_string_error;
      return To_Unbounded_String ("");
   end xml_ref_string;

   function xml_ref_string
     (obj : in generic_expression_ptr) return Unbounded_String
   is
   begin
      raise xml_ref_string_error;
      return To_Unbounded_String ("");
   end xml_ref_string;

   function xml_string
     (obj : in constant_expression) return Unbounded_String
   is
   begin
      raise xml_string_error;
      return To_Unbounded_String ("");
   end xml_string;

   function xml_string
     (obj : in constant_expression_ptr) return Unbounded_String
   is
   begin
      raise xml_string_error;
      return To_Unbounded_String ("");
   end xml_string;

   function xml_ref_string
     (obj : in constant_expression) return Unbounded_String
   is
   begin
      raise xml_ref_string_error;
      return To_Unbounded_String ("");
   end xml_ref_string;

   function xml_ref_string
     (obj : in constant_expression_ptr) return Unbounded_String
   is
   begin
      raise xml_ref_string_error;
      return To_Unbounded_String ("");
   end xml_ref_string;

   function xml_string (obj : in unary_expression) return Unbounded_String is
   begin
      raise xml_string_error;
      return To_Unbounded_String ("");
   end xml_string;

   function xml_string
     (obj : in unary_expression_ptr) return Unbounded_String
   is
   begin
      raise xml_string_error;
      return To_Unbounded_String ("");
   end xml_string;

   function xml_ref_string
     (obj : in unary_expression) return Unbounded_String
   is
   begin
      raise xml_ref_string_error;
      return To_Unbounded_String ("");
   end xml_ref_string;

   function xml_ref_string
     (obj : in unary_expression_ptr) return Unbounded_String
   is
   begin
      raise xml_ref_string_error;
      return To_Unbounded_String ("");
   end xml_ref_string;

   function xml_string (obj : in binary_expression) return Unbounded_String is
   begin
      raise xml_string_error;
      return To_Unbounded_String ("");
   end xml_string;

   function xml_string
     (obj : in binary_expression_ptr) return Unbounded_String
   is
   begin
      raise xml_string_error;
      return To_Unbounded_String ("");
   end xml_string;

   function xml_ref_string
     (obj : in binary_expression) return Unbounded_String
   is
   begin
      raise xml_ref_string_error;
      return To_Unbounded_String ("");
   end xml_ref_string;

   function xml_ref_string
     (obj : in binary_expression_ptr) return Unbounded_String
   is
   begin
      raise xml_ref_string_error;
      return To_Unbounded_String ("");
   end xml_ref_string;

   function xml_string
     (obj : in variable_expression) return Unbounded_String
   is
   begin
      raise xml_string_error;
      return To_Unbounded_String ("");
   end xml_string;

   function xml_string
     (obj : in variable_expression_ptr) return Unbounded_String
   is
   begin
      raise xml_string_error;
      return To_Unbounded_String ("");
   end xml_string;

   function xml_ref_string
     (obj : in variable_expression) return Unbounded_String
   is
   begin
      raise xml_ref_string_error;
      return To_Unbounded_String ("");
   end xml_ref_string;

   function xml_ref_string
     (obj : in variable_expression_ptr) return Unbounded_String
   is
   begin
      raise xml_ref_string_error;
      return To_Unbounded_String ("");
   end xml_ref_string;

   function xml_string
     (obj : in array_variable_expression) return Unbounded_String
   is
   begin
      raise xml_string_error;
      return To_Unbounded_String ("");
   end xml_string;

   function xml_string
     (obj : in array_variable_expression_ptr) return Unbounded_String
   is
   begin
      raise xml_string_error;
      return To_Unbounded_String ("");
   end xml_string;

   function xml_ref_string
     (obj : in array_variable_expression) return Unbounded_String
   is
   begin
      raise xml_ref_string_error;
      return To_Unbounded_String ("");
   end xml_ref_string;

   function xml_ref_string
     (obj : in array_variable_expression_ptr) return Unbounded_String
   is
   begin
      raise xml_ref_string_error;
      return To_Unbounded_String ("");
   end xml_ref_string;

   ------------------------------------------------------

   procedure initialize (s : in out constant_expression) is
   begin
      s.expression_type := constant_type;
   end initialize;

   procedure initialize (s : in out variable_expression) is
   begin
      s.expression_type := variable_type;
   end initialize;

   procedure initialize (s : in out array_variable_expression) is
   begin
      s.expression_type := array_variable_type;
   end initialize;

   procedure initialize (s : in out binary_expression) is
   begin
      s.expression_type := binary_type;
   end initialize;

   procedure initialize (s : in out unary_expression) is
   begin
      s.expression_type := unary_type;
   end initialize;

   ---------------------------------------------------------------

   function to_unbounded_string
     (c : constant_expression) return Unbounded_String
   is
   begin
      return to_unbounded_string (c.value);
   end to_unbounded_string;

   function to_unbounded_string
     (c : variable_expression) return Unbounded_String
   is
   begin
      return c.name;
   end to_unbounded_string;

   function to_unbounded_string
     (c : array_variable_expression) return Unbounded_String
   is
   begin
      return c.name;
   end to_unbounded_string;

   function to_unbounded_string
     (c : binary_expression) return Unbounded_String
   is
      result : Unbounded_String := empty_string;

   begin
      case c.ope is
         when to_integer_type =>
            null;
         when to_double_type =>
            null;
         when minus_type =>
            result := result & "-(";
         when plus_type =>
            result := result & "+(";
         when multiply_type =>
            result := result & "*(";
         when divide_type =>
            result := result & "/(";
         when equal_type =>
            result := result & "=(";
         when not_equal_type =>
            result := result & "/=(";
         when equal_less_type =>
            result := result & "<=(";
         when equal_greater_type =>
            result := result & ">=(";
         when inferior_type =>
            result := result & "<(";
         when superior_type =>
            result := result & ">(";
         when logic_and_type =>
            result := result & "and(";
         when logic_or_type =>
            result := result & "or(";
         when max_operator_type =>
            result := result & "max(";
         when min_operator_type =>
            result := result & "min(";
         when lcm_type =>
            result := result & "lcm(";
         when concatenate_type =>
            result := result & "&(";
         when exponential_type =>
            result := result & "**(";
         when modulo_type =>
            null;
         when logic_not_type =>
            null;
         when min_to_index_type =>
            null;
         when max_to_index_type =>
            null;
         when abs_type =>
            null;
         when get_resource_index_type =>
            null;
         when get_task_index_type =>
            null;
         when get_message_index_type =>
            null;
         when get_buffer_index_type =>
            null;
      end case;
      result := result & to_unbounded_string (c.lvalue.all);
      result := result & ",";
      result := result & to_unbounded_string (c.rvalue.all);
      result := result & ")";
      return result;
   end to_unbounded_string;

   function to_unbounded_string
     (c : unary_expression) return Unbounded_String
   is
      result : Unbounded_String := empty_string;

   begin
      case c.ope is
         when minus_type =>
            null;
         when plus_type =>
            null;
         when multiply_type =>
            null;
         when divide_type =>
            null;
         when equal_type =>
            null;
         when not_equal_type =>
            null;
         when equal_less_type =>
            null;
         when equal_greater_type =>
            null;
         when inferior_type =>
            null;
         when superior_type =>
            null;
         when logic_and_type =>
            null;
         when logic_or_type =>
            null;
         when max_operator_type =>
            null;
         when min_operator_type =>
            null;
         when concatenate_type =>
            null;
         when exponential_type =>
            null;
         when lcm_type =>
            null;
         when modulo_type =>
            result := result & "mod(";
         when logic_not_type =>
            result := result & "not(";
         when min_to_index_type =>
            result := result & "min_to_index(";
         when max_to_index_type =>
            result := result & "max_to_index(";
         when abs_type =>
            result := result & "abs(";
         when get_resource_index_type =>
            result := result & "get_resource_index(";
         when get_task_index_type =>
            result := result & "get_task_index(";
         when get_message_index_type =>
            result := result & "get_message_index(";
         when get_buffer_index_type =>
            result := result & "get_buffer_index(";
         when to_integer_type =>
            result := result & "to_integer(";
         when to_double_type =>
            result := result & "to_double(";
      end case;
      result := result & to_unbounded_string (c.value.all);
      result := result & ")";
      return result;
   end to_unbounded_string;

   ---------------------------------------------------------------

   function get_type
     (c         :    constant_expression;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return simulation_type
   is
   begin
      return c.value.ptype;
   end get_type;

   function get_type
     (c         :    variable_expression;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return simulation_type
   is
   begin
      return c.variable_type;
   end get_type;

   function get_type
     (c         :    binary_expression;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return simulation_type
   is
      a : constant simulation_type := get_type (c.rvalue.all);
      b : constant simulation_type := get_type (c.lvalue.all);
   begin
      if not has_compatible_type (a, b) then
         Raise_Exception
           (type_error'identity,
            "get_type(binary) ; line " &
            line'img &
            ", file " &
            To_String (file_name) &
            To_String (lb_comma) &
            To_String
              (lb_uncompatible_type_error (Current_Language) &
               lb_colon &
               To_Unbounded_String (a'img) &
               lb_comma &
               To_Unbounded_String (b'img)));
      end if;
      return a;
   end get_type;

   function get_type
     (c         :    unary_expression;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return simulation_type
   is
   begin
      -- For Get_Task_Index, Get_Buffer_Index ...
      -- the return value of the operation has a different type than its
      --argument
      --
      if (c.ope = get_resource_index_type) or
        (c.ope = get_task_index_type) or
        (c.ope = get_message_index_type) or
        (c.ope = get_buffer_index_type)
      then
         return (simulation_integer);
      end if;

      if (c.ope = to_integer_type) then
         return (simulation_integer);
      end if;
      if (c.ope = to_double_type) then
         return (simulation_double);
      end if;

      return get_type (c.value.all);

   end get_type;

   -------------------------------------------------------------------------

   function apply_random_operator
     (seed       : in Generator;
      parameters : in random_law_parameters_type;
      line       : in Natural          := 0;
      file_name  : in Unbounded_String := empty_string) return Integer;

   function apply_operator
     (lvalue    :    Integer;
      rvalue    :    Integer;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Integer;

   function apply_operator
     (lvalue    :    Double;
      rvalue    :    Double;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Double;

   function apply_operator
     (lvalue    :    Double;
      rvalue    :    Double;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Boolean;

   function apply_operator
     (lvalue    :    Unbounded_String;
      rvalue    :    Unbounded_String;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Unbounded_String;

   function apply_operator
     (lvalue    :    Unbounded_String;
      rvalue    :    Unbounded_String;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Boolean;

   function apply_operator
     (lvalue    :    Integer;
      rvalue    :    Integer;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Boolean;

   function apply_operator
     (lvalue    :    Boolean;
      rvalue    :    Boolean;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Boolean;

   function compute_binary_value
     (lvalue    :    simulation_value_ptr;
      rvalue    :    simulation_value_ptr;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String :=
        empty_string)
      return simulation_value_ptr;

   function apply_operator
     (value     :    Boolean;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Boolean;

   function apply_operator
     (value     :    Integer;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Integer;

   function apply_operator
     (value     :    Double;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Double;

   function apply_operator
     (value     :    Unbounded_String;
      v         :    variables_table_type;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Integer;

   function apply_random_operator
     (seed       : in Generator;
      parameters : in random_law_parameters_type;
      line       : in Natural          := 0;
      file_name  : in Unbounded_String := empty_string) return Integer
   is
      temp        : Double  := 0.0;
      temp2       : Double  := 0.0;
      value       : Integer;
      w           : Double  := 1.0;
      convergence : Boolean := False;
   begin

      case parameters.law is

         when exponential_law_type =>
            value :=
              Integer
                (get_exponential_time (Double (parameters.parameter1), seed));

         when uniform_law_type =>
            temp  := Double (parameters.parameter2 - parameters.parameter1);
            value :=
              Integer
                (Double (parameters.parameter1) +
                 Double (Random (seed)) * temp);

         when laplace_gauss_law_type =>
            while (convergence = False) loop
               temp  := Double (Random (seed)) * 2.0 - 1.0;
               temp2 := Double (Random (seed)) * 2.0 - 1.0;
               w     := temp**2 + temp2**2;
               if (w < 1.0) then
                  convergence := True;
               end if;
            end loop;
            w := Sqrt (-2.0 * Log (w) * Double (parameters.parameter2) / w);
            value := Integer (temp * w + Double (parameters.parameter1));
      end case;

      return value;

   end apply_random_operator;

   function apply_operator
     (lvalue    :    Integer;
      rvalue    :    Integer;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Integer
   is
   begin

      if ope = min_operator_type then
         if lvalue < rvalue then
            return lvalue;
         else
            return rvalue;
         end if;
      end if;
      if ope = max_operator_type then
         if lvalue > rvalue then
            return lvalue;
         else
            return rvalue;
         end if;
      end if;
      if ope = lcm_type then
         return integer_util.lcm (lvalue, rvalue);
      end if;
      if ope = plus_type then
         return lvalue + rvalue;
      end if;
      if ope = minus_type then
         return lvalue - rvalue;
      end if;
      if ope = multiply_type then
         return lvalue * rvalue;
      end if;
      if ope = divide_type then
         return lvalue / rvalue;
      end if;
      if ope = modulo_type then
         return lvalue mod rvalue;
      end if;

      Raise_Exception
        (type_error'identity,
         "apply_operator(integer,integer) ; line " &
         line'img &
         ", file " &
         To_String (file_name) &
         To_String (lb_comma) &
         To_String
           (lb_uncompatible_type_error (Current_Language) &
            lb_colon &
            To_Unbounded_String (lvalue'img) &
            lb_comma &
            To_Unbounded_String (rvalue'img) &
            lb_comma &
            To_Unbounded_String (ope'img)));

      -- Arithmetic exception : return 0 in any cases
      -- to avoid stopping the application
      --
   exception
      when others =>
         return 0;

   end apply_operator;

   function apply_operator
     (lvalue    :    Double;
      rvalue    :    Double;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Double
   is
   begin

      if ope = min_operator_type then
         if lvalue < rvalue then
            return lvalue;
         else
            return rvalue;
         end if;
      end if;
      if ope = max_operator_type then
         if lvalue > rvalue then
            return lvalue;
         else
            return rvalue;
         end if;
      end if;
      if ope = lcm_type then
         return Double (integer_util.lcm (Integer (lvalue), Integer (rvalue)));
      end if;
      if ope = plus_type then
         return lvalue + rvalue;
      end if;
      if ope = minus_type then
         return lvalue - rvalue;
      end if;
      if ope = multiply_type then
         return lvalue * rvalue;
      end if;

      if ope = divide_type then
         return lvalue / rvalue;
      end if;

      Raise_Exception
        (type_error'identity,
         "apply_operator(double,double) return double ; line " &
         line'img &
         ", file " &
         To_String (file_name) &
         To_String (lb_comma) &
         To_String
           (lb_uncompatible_type_error (Current_Language) &
            lb_colon &
            To_Unbounded_String (lvalue'img) &
            lb_comma &
            To_Unbounded_String (rvalue'img) &
            lb_comma &
            To_Unbounded_String (ope'img)));

      -- Arithmetic exception : return 0 in any cases
      -- to avoid stopping the application
      --
   exception
      when others =>
         return 0.0;
   end apply_operator;

   function apply_operator
     (lvalue    :    Double;
      rvalue    :    Double;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Boolean
   is
   begin
      if ope = equal_type then
         return lvalue = rvalue;
      end if;
      if ope = not_equal_type then
         return lvalue /= rvalue;
      end if;
      if ope = equal_less_type then
         return lvalue <= rvalue;
      end if;
      if ope = equal_greater_type then
         return lvalue >= rvalue;
      end if;
      if ope = inferior_type then
         return lvalue < rvalue;
      end if;
      if ope = superior_type then
         return lvalue > rvalue;
      end if;

      Raise_Exception
        (type_error'identity,
         "apply_operator(double,double) return boolean ; line " &
         line'img &
         ", file " &
         To_String (file_name) &
         To_String (lb_comma) &
         To_String
           (lb_uncompatible_type_error (Current_Language) &
            lb_colon &
            To_Unbounded_String (lvalue'img) &
            lb_comma &
            To_Unbounded_String (rvalue'img) &
            lb_comma &
            To_Unbounded_String (ope'img)));

   end apply_operator;

   function apply_operator
     (lvalue    :    Unbounded_String;
      rvalue    :    Unbounded_String;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Unbounded_String
   is
   begin
      if ope = concatenate_type then
         return lvalue & rvalue;
      end if;

      Raise_Exception
        (type_error'identity,
         "apply_operator(string,string) return string ; line " &
         line'img &
         ", file " &
         To_String (file_name) &
         To_String (lb_comma) &
         To_String
           (lb_uncompatible_type_error (Current_Language) &
            lb_colon &
            lvalue &
            lb_comma &
            rvalue &
            lb_comma &
            To_Unbounded_String (ope'img)));

   end apply_operator;

   function apply_operator
     (lvalue    :    Unbounded_String;
      rvalue    :    Unbounded_String;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Boolean
   is
   begin
      if ope = equal_type then
         return lvalue = rvalue;
      end if;
      if ope = not_equal_type then
         return lvalue /= rvalue;
      end if;
      if ope = equal_less_type then
         return lvalue <= rvalue;
      end if;
      if ope = equal_greater_type then
         return lvalue >= rvalue;
      end if;
      if ope = inferior_type then
         return lvalue < rvalue;
      end if;
      if ope = superior_type then
         return lvalue > rvalue;
      end if;

      Raise_Exception
        (type_error'identity,
         "apply_operator(string,string) return boolean ; line " &
         line'img &
         ", file " &
         To_String (file_name) &
         To_String (lb_comma) &
         To_String
           (lb_uncompatible_type_error (Current_Language) &
            lb_colon &
            lvalue &
            lb_comma &
            rvalue &
            lb_comma &
            To_Unbounded_String (ope'img)));

   end apply_operator;

   function apply_operator
     (lvalue    :    Integer;
      rvalue    :    Integer;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Boolean
   is
   begin
      if ope = equal_type then
         return lvalue = rvalue;
      end if;
      if ope = not_equal_type then
         return lvalue /= rvalue;
      end if;
      if ope = equal_less_type then
         return lvalue <= rvalue;
      end if;
      if ope = equal_greater_type then
         return lvalue >= rvalue;
      end if;
      if ope = inferior_type then
         return lvalue < rvalue;
      end if;
      if ope = superior_type then
         return lvalue > rvalue;
      end if;

      Raise_Exception
        (type_error'identity,
         "apply_operator(integer,integer) return boolean ; line " &
         line'img &
         ", file " &
         To_String (file_name) &
         To_String (lb_comma) &
         To_String
           (lb_uncompatible_type_error (Current_Language) &
            lb_colon &
            To_Unbounded_String (lvalue'img) &
            lb_comma &
            To_Unbounded_String (rvalue'img) &
            lb_comma &
            To_Unbounded_String (ope'img)));

   end apply_operator;

   function apply_operator
     (lvalue    :    Boolean;
      rvalue    :    Boolean;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Boolean
   is
   begin

      if ope = equal_type then
         return lvalue = rvalue;
      end if;
      if ope = not_equal_type then
         return lvalue /= rvalue;
      end if;
      if ope = equal_less_type then
         return lvalue <= rvalue;
      end if;
      if ope = equal_greater_type then
         return lvalue >= rvalue;
      end if;
      if ope = inferior_type then
         return lvalue < rvalue;
      end if;
      if ope = superior_type then
         return lvalue > rvalue;
      end if;
      if ope = logic_and_type then
         return lvalue and rvalue;
      end if;
      if ope = logic_or_type then
         return lvalue or rvalue;
      end if;

      Raise_Exception
        (type_error'identity,
         "apply_operator(boolean, boolean) return boolean ; line " &
         line'img &
         ", file " &
         To_String (file_name) &
         To_String (lb_comma) &
         To_String
           (lb_uncompatible_type_error (Current_Language) &
            lb_colon &
            To_Unbounded_String (lvalue'img) &
            lb_comma &
            To_Unbounded_String (rvalue'img) &
            lb_comma &
            To_Unbounded_String (ope'img)));

   end apply_operator;

   function compute_binary_value
     (lvalue    :    simulation_value_ptr;
      rvalue    :    simulation_value_ptr;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String :=
        empty_string)
      return simulation_value_ptr
   is
      res : simulation_value_ptr;

   begin

      case lvalue.ptype is

         -- Nothing to compute in the cases of random type
         -- because value_of functions already do the job
         -- by returning integer values
         --
         when simulation_random =>
            null;

         when simulation_array_random =>
            null;

         when simulation_integer | simulation_clock =>

            if (rvalue.ptype = simulation_integer) or
              (rvalue.ptype = simulation_clock)
            then

               if (ope = equal_type) or
                 (ope = not_equal_type) or
                 (ope = equal_less_type) or
                 (ope = equal_greater_type) or
                 (ope = inferior_type) or
                 (ope = superior_type)
               then
                  res := new simulation_value (simulation_boolean);
                  res.boolean_value :=
                    apply_operator
                      (lvalue.integer_value,
                       rvalue.integer_value,
                       ope,
                       line,
                       file_name);
               else
                  res := new simulation_value (simulation_integer);
                  res.integer_value :=
                    apply_operator
                      (lvalue.integer_value,
                       rvalue.integer_value,
                       ope,
                       line,
                       file_name);
               end if;

            else
               if (rvalue.ptype = simulation_array_integer) or
                 (rvalue.ptype = simulation_array_clock)
               then
                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res := new simulation_value (simulation_array_boolean);
                  else
                     res := new simulation_value (simulation_array_integer);
                  end if;

                  for i in simulations_range loop
                     if (ope = equal_type) or
                       (ope = not_equal_type) or
                       (ope = equal_less_type) or
                       (ope = equal_greater_type) or
                       (ope = inferior_type) or
                       (ope = superior_type)
                     then
                        res.boolean_table_value (i) :=
                          apply_operator
                            (lvalue.boolean_value,
                             rvalue.boolean_table_value (i),
                             ope,
                             line,
                             file_name);
                     else
                        res.integer_table_value (i) :=
                          apply_operator
                            (lvalue.integer_value,
                             rvalue.integer_table_value (i),
                             ope,
                             line,
                             file_name);
                     end if;
                  end loop;

               else
                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res :=
                       new simulation_value
                       (simulation_time_unit_array_boolean);
                  else
                     res :=
                       new simulation_value
                       (simulation_time_unit_array_integer);
                  end if;

                  for i in time_unit_range loop
                     if (ope = equal_type) or
                       (ope = not_equal_type) or
                       (ope = equal_less_type) or
                       (ope = equal_greater_type) or
                       (ope = inferior_type) or
                       (ope = superior_type)
                     then
                        res.boolean_time_unit_table_value (i) :=
                          apply_operator
                            (lvalue.boolean_value,
                             rvalue.boolean_time_unit_table_value (i),
                             ope,
                             line,
                             file_name);
                     else
                        res.integer_time_unit_table_value (i) :=
                          apply_operator
                            (lvalue.integer_value,
                             rvalue.integer_time_unit_table_value (i),
                             ope,
                             line,
                             file_name);
                     end if;
                  end loop;
               end if;
            end if;

         when simulation_string =>

            if rvalue.ptype = simulation_string then

               if (ope = equal_type) or
                 (ope = not_equal_type) or
                 (ope = equal_less_type) or
                 (ope = equal_greater_type) or
                 (ope = inferior_type) or
                 (ope = superior_type)
               then
                  res := new simulation_value (simulation_boolean);
                  res.boolean_value :=
                    apply_operator
                      (lvalue.string_value,
                       rvalue.string_value,
                       ope,
                       line,
                       file_name);
               else
                  res              := new simulation_value (simulation_string);
                  res.string_value :=
                    apply_operator
                      (lvalue.string_value,
                       rvalue.string_value,
                       ope,
                       line,
                       file_name);
               end if;

            else
               if rvalue.ptype = simulation_array_string then
                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res := new simulation_value (simulation_array_boolean);
                  else
                     res := new simulation_value (simulation_array_string);
                  end if;

                  for i in simulations_range loop
                     if (ope = equal_type) or
                       (ope = not_equal_type) or
                       (ope = equal_less_type) or
                       (ope = equal_greater_type) or
                       (ope = inferior_type) or
                       (ope = superior_type)
                     then
                        res.boolean_table_value (i) :=
                          apply_operator
                            (lvalue.boolean_value,
                             rvalue.boolean_table_value (i),
                             ope,
                             line,
                             file_name);
                     else
                        res.string_table_value (i) :=
                          apply_operator
                            (lvalue.string_value,
                             rvalue.string_table_value (i),
                             ope,
                             line,
                             file_name);
                     end if;
                  end loop;

               else
                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res :=
                       new simulation_value
                       (simulation_time_unit_array_boolean);
                  else
                     res :=
                       new simulation_value
                       (simulation_time_unit_array_string);
                  end if;

                  for i in time_unit_range loop
                     if (ope = equal_type) or
                       (ope = not_equal_type) or
                       (ope = equal_less_type) or
                       (ope = equal_greater_type) or
                       (ope = inferior_type) or
                       (ope = superior_type)
                     then
                        res.boolean_time_unit_table_value (i) :=
                          apply_operator
                            (lvalue.boolean_value,
                             rvalue.boolean_time_unit_table_value (i),
                             ope,
                             line,
                             file_name);
                     else
                        res.string_time_unit_table_value (i) :=
                          apply_operator
                            (lvalue.string_value,
                             rvalue.string_time_unit_table_value (i),
                             ope,
                             line,
                             file_name);
                     end if;
                  end loop;
               end if;
            end if;

         when simulation_double =>

            if rvalue.ptype = simulation_double then

               if (ope = equal_type) or
                 (ope = not_equal_type) or
                 (ope = equal_less_type) or
                 (ope = equal_greater_type) or
                 (ope = inferior_type) or
                 (ope = superior_type)
               then
                  res := new simulation_value (simulation_boolean);
                  res.boolean_value :=
                    apply_operator
                      (lvalue.double_value,
                       rvalue.double_value,
                       ope,
                       line,
                       file_name);
               else
                  res              := new simulation_value (simulation_double);
                  res.double_value :=
                    apply_operator
                      (lvalue.double_value,
                       rvalue.double_value,
                       ope,
                       line,
                       file_name);
               end if;

            else
               if rvalue.ptype = simulation_array_double then
                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res := new simulation_value (simulation_array_boolean);
                  else
                     res := new simulation_value (simulation_array_double);
                  end if;

                  for i in simulations_range loop
                     if (ope = equal_type) or
                       (ope = not_equal_type) or
                       (ope = equal_less_type) or
                       (ope = equal_greater_type) or
                       (ope = inferior_type) or
                       (ope = superior_type)
                     then
                        res.boolean_table_value (i) :=
                          apply_operator
                            (lvalue.boolean_value,
                             rvalue.boolean_table_value (i),
                             ope,
                             line,
                             file_name);
                     else
                        res.double_table_value (i) :=
                          apply_operator
                            (lvalue.double_value,
                             rvalue.double_table_value (i),
                             ope,
                             line,
                             file_name);
                     end if;
                  end loop;

               else
                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res :=
                       new simulation_value
                       (simulation_time_unit_array_boolean);
                  else
                     res :=
                       new simulation_value
                       (simulation_time_unit_array_double);
                  end if;

                  for i in time_unit_range loop
                     if (ope = equal_type) or
                       (ope = not_equal_type) or
                       (ope = equal_less_type) or
                       (ope = equal_greater_type) or
                       (ope = inferior_type) or
                       (ope = superior_type)
                     then
                        res.boolean_time_unit_table_value (i) :=
                          apply_operator
                            (lvalue.boolean_value,
                             rvalue.boolean_time_unit_table_value (i),
                             ope,
                             line,
                             file_name);
                     else
                        res.double_time_unit_table_value (i) :=
                          apply_operator
                            (lvalue.double_value,
                             rvalue.double_time_unit_table_value (i),
                             ope,
                             line,
                             file_name);
                     end if;
                  end loop;
               end if;
            end if;

         when simulation_boolean =>

            if rvalue.ptype = simulation_boolean then

               res               := new simulation_value (simulation_boolean);
               res.boolean_value :=
                 apply_operator
                   (lvalue.boolean_value,
                    rvalue.boolean_value,
                    ope,
                    line,
                    file_name);
            else
               if rvalue.ptype = simulation_array_boolean then

                  res := new simulation_value (simulation_array_boolean);

                  for i in simulations_range loop
                     res.boolean_table_value (i) :=
                       apply_operator
                         (lvalue.boolean_value,
                          rvalue.boolean_table_value (i),
                          ope,
                          line,
                          file_name);
                  end loop;

               else
                  res :=
                    new simulation_value (simulation_time_unit_array_boolean);

                  for i in time_unit_range loop
                     res.boolean_time_unit_table_value (i) :=
                       apply_operator
                         (lvalue.boolean_value,
                          rvalue.boolean_time_unit_table_value (i),
                          ope,
                          line,
                          file_name);
                  end loop;

               end if;
            end if;

         when simulation_array_integer | simulation_array_clock =>

            if (ope = equal_type) or
              (ope = not_equal_type) or
              (ope = equal_less_type) or
              (ope = equal_greater_type) or
              (ope = inferior_type) or
              (ope = superior_type)
            then
               res := new simulation_value (simulation_array_boolean);
            else
               res := new simulation_value (simulation_array_integer);
            end if;

            for i in simulations_range loop

               if (rvalue.ptype = simulation_array_clock) or
                 (rvalue.ptype = simulation_array_integer)
               then

                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res.boolean_table_value (i) :=
                       apply_operator
                         (lvalue.boolean_table_value (i),
                          rvalue.boolean_table_value (i),
                          ope,
                          line,
                          file_name);
                  else
                     res.integer_table_value (i) :=
                       apply_operator
                         (lvalue.integer_table_value (i),
                          rvalue.integer_table_value (i),
                          ope,
                          line,
                          file_name);
                  end if;

               else
                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res.boolean_table_value (i) :=
                       apply_operator
                         (lvalue.boolean_table_value (i),
                          rvalue.boolean_value,
                          ope,
                          line,
                          file_name);
                  else
                     res.integer_table_value (i) :=
                       apply_operator
                         (lvalue.integer_table_value (i),
                          rvalue.integer_value,
                          ope,
                          line,
                          file_name);
                  end if;

               end if;

            end loop;

         when simulation_array_double =>

            if (ope = equal_type) or
              (ope = not_equal_type) or
              (ope = equal_less_type) or
              (ope = equal_greater_type) or
              (ope = inferior_type) or
              (ope = superior_type)
            then
               res := new simulation_value (simulation_array_boolean);
            else
               res := new simulation_value (simulation_array_double);
            end if;

            for i in simulations_range loop

               if rvalue.ptype = simulation_array_double then
                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res.boolean_table_value (i) :=
                       apply_operator
                         (lvalue.boolean_table_value (i),
                          rvalue.boolean_table_value (i),
                          ope,
                          line,
                          file_name);
                  else
                     res.double_table_value (i) :=
                       apply_operator
                         (lvalue.double_table_value (i),
                          rvalue.double_table_value (i),
                          ope,
                          line,
                          file_name);
                  end if;
               else
                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res.boolean_table_value (i) :=
                       apply_operator
                         (lvalue.boolean_table_value (i),
                          rvalue.boolean_value,
                          ope,
                          line,
                          file_name);
                  else
                     res.double_table_value (i) :=
                       apply_operator
                         (lvalue.double_table_value (i),
                          rvalue.double_value,
                          ope,
                          line,
                          file_name);
                  end if;
               end if;

            end loop;

         when simulation_array_string =>

            if (ope = equal_type) or
              (ope = not_equal_type) or
              (ope = equal_less_type) or
              (ope = equal_greater_type) or
              (ope = inferior_type) or
              (ope = superior_type)
            then
               res := new simulation_value (simulation_array_boolean);
            else
               res := new simulation_value (simulation_array_string);
            end if;

            for i in simulations_range loop

               if rvalue.ptype = simulation_array_string then
                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res.boolean_table_value (i) :=
                       apply_operator
                         (lvalue.boolean_table_value (i),
                          rvalue.boolean_table_value (i),
                          ope,
                          line,
                          file_name);
                  else
                     res.string_table_value (i) :=
                       apply_operator
                         (lvalue.string_table_value (i),
                          rvalue.string_table_value (i),
                          ope,
                          line,
                          file_name);
                  end if;
               else
                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res.boolean_table_value (i) :=
                       apply_operator
                         (lvalue.boolean_table_value (i),
                          rvalue.boolean_value,
                          ope,
                          line,
                          file_name);
                  else
                     res.string_table_value (i) :=
                       apply_operator
                         (lvalue.string_table_value (i),
                          rvalue.string_value,
                          ope,
                          line,
                          file_name);
                  end if;
               end if;

            end loop;

         when simulation_array_boolean =>

            res := new simulation_value (simulation_array_boolean);

            for i in simulations_range loop

               if rvalue.ptype = simulation_array_boolean then
                  res.boolean_table_value (i) :=
                    apply_operator
                      (lvalue.boolean_table_value (i),
                       rvalue.boolean_table_value (i),
                       ope,
                       line,
                       file_name);
               else
                  res.boolean_table_value (i) :=
                    apply_operator
                      (lvalue.boolean_table_value (i),
                       rvalue.boolean_value,
                       ope,
                       line,
                       file_name);
               end if;

            end loop;

         when simulation_time_unit_array_integer =>

            if (ope = equal_type) or
              (ope = not_equal_type) or
              (ope = equal_less_type) or
              (ope = equal_greater_type) or
              (ope = inferior_type) or
              (ope = superior_type)
            then
               res :=
                 new simulation_value (simulation_time_unit_array_boolean);
            else
               res :=
                 new simulation_value (simulation_time_unit_array_integer);
            end if;

            for i in time_unit_range loop

               if rvalue.ptype = simulation_time_unit_array_integer then

                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res.boolean_time_unit_table_value (i) :=
                       apply_operator
                         (lvalue.boolean_time_unit_table_value (i),
                          rvalue.boolean_time_unit_table_value (i),
                          ope,
                          line,
                          file_name);
                  else
                     res.integer_time_unit_table_value (i) :=
                       apply_operator
                         (lvalue.integer_time_unit_table_value (i),
                          rvalue.integer_time_unit_table_value (i),
                          ope,
                          line,
                          file_name);
                  end if;

               else
                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res.boolean_time_unit_table_value (i) :=
                       apply_operator
                         (lvalue.boolean_time_unit_table_value (i),
                          rvalue.boolean_value,
                          ope,
                          line,
                          file_name);
                  else
                     res.integer_time_unit_table_value (i) :=
                       apply_operator
                         (lvalue.integer_time_unit_table_value (i),
                          rvalue.integer_value,
                          ope,
                          line,
                          file_name);
                  end if;

               end if;

            end loop;

         when simulation_time_unit_array_double =>

            if (ope = equal_type) or
              (ope = not_equal_type) or
              (ope = equal_less_type) or
              (ope = equal_greater_type) or
              (ope = inferior_type) or
              (ope = superior_type)
            then
               res :=
                 new simulation_value (simulation_time_unit_array_boolean);
            else
               res := new simulation_value (simulation_time_unit_array_double);
            end if;

            for i in time_unit_range loop

               if rvalue.ptype = simulation_time_unit_array_double then
                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res.boolean_time_unit_table_value (i) :=
                       apply_operator
                         (lvalue.boolean_time_unit_table_value (i),
                          rvalue.boolean_time_unit_table_value (i),
                          ope,
                          line,
                          file_name);
                  else
                     res.double_time_unit_table_value (i) :=
                       apply_operator
                         (lvalue.double_time_unit_table_value (i),
                          rvalue.double_time_unit_table_value (i),
                          ope,
                          line,
                          file_name);
                  end if;
               else
                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res.boolean_time_unit_table_value (i) :=
                       apply_operator
                         (lvalue.boolean_time_unit_table_value (i),
                          rvalue.boolean_value,
                          ope,
                          line,
                          file_name);
                  else
                     res.double_time_unit_table_value (i) :=
                       apply_operator
                         (lvalue.double_time_unit_table_value (i),
                          rvalue.double_value,
                          ope,
                          line,
                          file_name);
                  end if;
               end if;

            end loop;

         when simulation_time_unit_array_boolean =>

            res := new simulation_value (simulation_time_unit_array_boolean);

            for i in time_unit_range loop

               if rvalue.ptype = simulation_time_unit_array_boolean then
                  res.boolean_time_unit_table_value (i) :=
                    apply_operator
                      (lvalue.boolean_time_unit_table_value (i),
                       rvalue.boolean_time_unit_table_value (i),
                       ope,
                       line,
                       file_name);
               else
                  res.boolean_time_unit_table_value (i) :=
                    apply_operator
                      (lvalue.boolean_time_unit_table_value (i),
                       rvalue.boolean_value,
                       ope,
                       line,
                       file_name);
               end if;

            end loop;

         when simulation_time_unit_array_string =>

            if (ope = equal_type) or
              (ope = not_equal_type) or
              (ope = equal_less_type) or
              (ope = equal_greater_type) or
              (ope = inferior_type) or
              (ope = superior_type)
            then
               res :=
                 new simulation_value (simulation_time_unit_array_boolean);
            else
               res := new simulation_value (simulation_time_unit_array_string);
            end if;

            for i in time_unit_range loop

               if rvalue.ptype = simulation_time_unit_array_string then
                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res.boolean_time_unit_table_value (i) :=
                       apply_operator
                         (lvalue.boolean_time_unit_table_value (i),
                          rvalue.boolean_time_unit_table_value (i),
                          ope,
                          line,
                          file_name);
                  else
                     res.string_time_unit_table_value (i) :=
                       apply_operator
                         (lvalue.string_time_unit_table_value (i),
                          rvalue.string_time_unit_table_value (i),
                          ope,
                          line,
                          file_name);
                  end if;
               else
                  if (ope = equal_type) or
                    (ope = not_equal_type) or
                    (ope = equal_less_type) or
                    (ope = equal_greater_type) or
                    (ope = inferior_type) or
                    (ope = superior_type)
                  then
                     res.boolean_time_unit_table_value (i) :=
                       apply_operator
                         (lvalue.boolean_time_unit_table_value (i),
                          rvalue.boolean_value,
                          ope,
                          line,
                          file_name);
                  else
                     res.string_time_unit_table_value (i) :=
                       apply_operator
                         (lvalue.string_time_unit_table_value (i),
                          rvalue.string_value,
                          ope,
                          line,
                          file_name);
                  end if;
               end if;

            end loop;

      end case;

      return res;

   end compute_binary_value;

   function apply_operator
     (value     :    Boolean;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Boolean
   is
   begin

      if ope = logic_not_type then
         return not value;
      end if;

      Raise_Exception
        (type_error'identity,
         "apply_operator(boolean) return boolean ; line " &
         line'img &
         ", file " &
         To_String (file_name) &
         To_String (lb_comma) &
         To_String
           (lb_uncompatible_type_error (Current_Language) &
            lb_colon &
            To_Unbounded_String (value'img) &
            lb_comma &
            To_Unbounded_String (ope'img)));
   end apply_operator;

   function apply_operator
     (value     :    Integer;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Integer
   is
   begin

      if ope = abs_type then
         return abs value;
      end if;

      Raise_Exception
        (type_error'identity,
         "apply_operator(integer) return integer ; line " &
         line'img &
         ", file " &
         To_String (file_name) &
         To_String (lb_comma) &
         To_String
           (lb_uncompatible_type_error (Current_Language) &
            lb_colon &
            To_Unbounded_String (value'img) &
            lb_comma &
            To_Unbounded_String (ope'img)));
   end apply_operator;

   function apply_operator
     (value     :    Double;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Double
   is
   begin

      if ope = abs_type then
         return abs value;
      end if;

      Raise_Exception
        (type_error'identity,
         "apply_operator(double) return double ; line " &
         line'img &
         ", file " &
         To_String (file_name) &
         To_String (lb_comma) &
         To_String
           (lb_uncompatible_type_error (Current_Language) &
            lb_colon &
            To_Unbounded_String (value'img) &
            lb_comma &
            To_Unbounded_String (ope'img)));
   end apply_operator;

   function apply_operator
     (value     :    Unbounded_String;
      v         :    variables_table_type;
      ope       :    operator_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return Integer
   is
      var : variables_range;

   begin

      if ope = get_task_index_type then
         var := find_variable (v, To_Unbounded_String ("tasks.name"));
         for i in string_table'range loop
            if v.entries (var).simulation.string_table_value (i) = value then
               return Integer (i);
            end if;
         end loop;
         Raise_Exception
           (statement_error'identity,
            "line " &
            line'img &
            ", file " &
            To_String (file_name) &
            To_String (lb_comma) &
            To_String
              (lb_task_not_found (Current_Language) &
               lb_colon &
               value &
               lb_comma &
               To_Unbounded_String (ope'img)));
      end if;

      if ope = get_buffer_index_type then
         var := find_variable (v, To_Unbounded_String ("buffers.name"));
         for i in string_table'range loop
            if v.entries (var).simulation.string_table_value (i) = value then
               return Integer (i);
            end if;
         end loop;
         Raise_Exception
           (statement_error'identity,
            "line " &
            line'img &
            ", file " &
            To_String (file_name) &
            To_String (lb_comma) &
            To_String
              (lb_buffer_not_found (Current_Language) &
               lb_colon &
               value &
               lb_comma &
               To_Unbounded_String (ope'img)));
      end if;

      if ope = get_message_index_type then
         var := find_variable (v, To_Unbounded_String ("messages.name"));
         for i in string_table'range loop
            if v.entries (var).simulation.string_table_value (i) = value then
               return Integer (i);
            end if;
         end loop;
         Raise_Exception
           (statement_error'identity,
            "line " &
            line'img &
            ", file " &
            To_String (file_name) &
            To_String (lb_comma) &
            To_String
              (lb_message_not_found (Current_Language) &
               lb_colon &
               value &
               lb_comma &
               To_Unbounded_String (ope'img)));
      end if;

      if ope = get_resource_index_type then
         var := find_variable (v, To_Unbounded_String ("resources.name"));
         for i in string_table'range loop
            if v.entries (var).simulation.string_table_value (i) = value then
               return Integer (i);
            end if;
         end loop;
         Raise_Exception
           (statement_error'identity,
            "line " &
            line'img &
            ", file " &
            To_String (file_name) &
            To_String (lb_comma) &
            To_String
              (lb_resource_not_found (Current_Language) &
               lb_colon &
               value &
               lb_comma &
               To_Unbounded_String (ope'img)));
      end if;

      Raise_Exception
        (type_error'identity,
         "line " &
         line'img &
         ", file " &
         To_String (file_name) &
         To_String (lb_comma) &
         To_String
           (lb_uncompatible_type_error (Current_Language) &
            lb_colon &
            value &
            lb_comma &
            To_Unbounded_String (ope'img)));
   end apply_operator;

   ---------------------------------------------------------

   function value_of
     (c         :    binary_expression;
      v         :    variables_table_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String :=
        empty_string)
      return simulation_value_ptr
   is
      res, lvalue, rvalue : simulation_value_ptr;

   begin

      lvalue := value_of (c.lvalue.all, v, line, file_name);
      rvalue := value_of (c.rvalue.all, v, line, file_name);

      -- First case : it's a logical expression : the two values
      -- have to have the same type and the same size
      --
      -- Second case : the expression is an arithmetic statement. In
      -- this case, we are less strict : some expression can be composed
      -- of data with different types (types are then compatible)
      --
      -- Last case : type are not compatible, it's an error !
      --

      -- First case : it's a logical expression : the two values
      -- have to have the same type and the same size
      --
      if (rvalue.ptype /= lvalue.ptype) and
        ((c.ope = equal_type) or
         (c.ope = not_equal_type) or
         (c.ope = equal_less_type) or
         (c.ope = equal_greater_type) or
         (c.ope = logic_and_type) or
         (c.ope = logic_or_type) or
         (c.ope = logic_not_type) or
         (c.ope = inferior_type) or
         (c.ope = superior_type))
      then
         Raise_Exception
           (type_error'identity,
            "line " &
            line'img &
            ", file " &
            To_String (file_name) &
            To_String (lb_comma) &
            To_String
              (lb_uncompatible_type_error (Current_Language) &
               lb_colon &
               to_unbounded_string (c.lvalue.all) &
               lb_comma &
               to_unbounded_string (c.rvalue.all)));
      end if;

      -- Second case : the expression is an arithmetic statement. In
      -- this case, we are less strict : some expression can be composed
      -- of data with different types (types are then compatible)
      --
      if
        ((rvalue.ptype = lvalue.ptype) or
         ((lvalue.ptype = simulation_array_integer) and
          (rvalue.ptype = simulation_integer)) or
         ((lvalue.ptype = simulation_array_clock) and
          (rvalue.ptype = simulation_clock)) or
         ((lvalue.ptype = simulation_array_clock) and
          (rvalue.ptype = simulation_integer)) or
         ((lvalue.ptype = simulation_array_double) and
          (rvalue.ptype = simulation_double)) or
         ((lvalue.ptype = simulation_array_boolean) and
          (rvalue.ptype = simulation_boolean)) or
         ((lvalue.ptype = simulation_array_string) and
          (rvalue.ptype = simulation_string)) or
         ((lvalue.ptype = simulation_integer) and
          (rvalue.ptype = simulation_clock)) or
         ((lvalue.ptype = simulation_clock) and
          (rvalue.ptype = simulation_integer)) or
         ((lvalue.ptype = simulation_integer) and
          (rvalue.ptype = simulation_array_integer)) or
         ((lvalue.ptype = simulation_clock) and
          (rvalue.ptype = simulation_array_clock)) or
         ((lvalue.ptype = simulation_clock) and
          (rvalue.ptype = simulation_array_integer)) or
         ((lvalue.ptype = simulation_double) and
          (rvalue.ptype = simulation_array_double)) or
         ((lvalue.ptype = simulation_string) and
          (rvalue.ptype = simulation_array_string)) or
         ((lvalue.ptype = simulation_boolean) and
          (rvalue.ptype = simulation_array_boolean)) or
         ((lvalue.ptype = simulation_time_unit_array_integer) and
          (rvalue.ptype = simulation_integer)) or
         ((lvalue.ptype = simulation_time_unit_array_double) and
          (rvalue.ptype = simulation_double)) or
         ((lvalue.ptype = simulation_time_unit_array_boolean) and
          (rvalue.ptype = simulation_boolean)) or
         ((lvalue.ptype = simulation_time_unit_array_string) and
          (rvalue.ptype = simulation_string)) or
         ((lvalue.ptype = simulation_integer) and
          (rvalue.ptype = simulation_time_unit_array_integer)) or
         ((lvalue.ptype = simulation_double) and
          (rvalue.ptype = simulation_time_unit_array_double)) or
         ((lvalue.ptype = simulation_string) and
          (rvalue.ptype = simulation_time_unit_array_string)) or
         ((lvalue.ptype = simulation_boolean) and
          (rvalue.ptype = simulation_time_unit_array_boolean)))
      then
         res := compute_binary_value (lvalue, rvalue, c.ope);

      else

         -- Last case : type are not compatible, it's an error !
         --
         Raise_Exception
           (type_error'identity,
            "line " &
            line'img &
            ", file " &
            To_String (file_name) &
            To_String (lb_comma) &
            To_String
              (lb_uncompatible_type_error (Current_Language) &
               lb_colon &
               to_unbounded_string (c.lvalue.all) &
               lb_comma &
               to_unbounded_string (c.rvalue.all)));
      end if;

      free (lvalue);
      free (rvalue);

      return res;

   end value_of;

   function value_of
     (c         :    unary_expression;
      v         :    variables_table_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String :=
        empty_string)
      return simulation_value_ptr
   is
      res, value : simulation_value_ptr;

   begin

      value := value_of (c.value.all, v, line, file_name);

      if (value.ptype = simulation_double) and (c.ope = to_integer_type) then
         res               := new simulation_value (simulation_integer);
         res.integer_value := Integer (value.double_value);
         return res;
      end if;

      if (value.ptype = simulation_integer) and (c.ope = to_double_type) then
         res              := new simulation_value (simulation_double);
         res.double_value := Double (value.integer_value);
         return res;
      end if;

      if (value.ptype = simulation_array_string) or
        (value.ptype = simulation_time_unit_array_string)
      then
         Raise_Exception
           (type_error'identity,
            "line " &
            line'img &
            ", file " &
            To_String (file_name) &
            To_String (lb_comma) &
            To_String
              (lb_uncompatible_type_error (Current_Language) &
               lb_colon &
               value.ptype'img &
               lb_comma &
               To_Unbounded_String (c.ope'img)));
      end if;

      if (c.ope = max_to_index_type) or (c.ope = min_to_index_type) then
         return value;
      end if;

      -- Apply operator from an unary expression
      --
      case value.ptype is

         when simulation_string =>
            res               := new simulation_value (simulation_integer);
            res.integer_value :=
              apply_operator (value.string_value, v, c.ope, line, file_name);

         when simulation_array_string =>
            null;
         when simulation_time_unit_array_string =>
            null;

         -- Nothing to compute in the cases of random type
         -- because value_of functions already do the job
         -- by returning integer values
         --
         when simulation_random =>
            null;

         when simulation_array_random =>
            null;

         when simulation_time_unit_array_integer =>
            res := new simulation_value (simulation_time_unit_array_integer);
            for i in time_unit_range loop
               res.integer_time_unit_table_value (i) :=
                 apply_operator
                   (value.integer_time_unit_table_value (i),
                    c.ope,
                    line,
                    file_name);
            end loop;

         when simulation_array_integer | simulation_array_clock =>
            res := new simulation_value (simulation_array_integer);
            for i in simulations_range loop
               res.integer_table_value (i) :=
                 apply_operator
                   (value.integer_table_value (i),
                    c.ope,
                    line,
                    file_name);
            end loop;

         when simulation_integer | simulation_clock =>
            res               := new simulation_value (simulation_integer);
            res.integer_value :=
              apply_operator (value.integer_value, c.ope, line, file_name);

         when simulation_time_unit_array_double =>
            res := new simulation_value (simulation_time_unit_array_double);
            for i in time_unit_range loop
               res.double_time_unit_table_value (i) :=
                 apply_operator
                   (value.double_time_unit_table_value (i),
                    c.ope,
                    line,
                    file_name);
            end loop;

         when simulation_array_double =>
            res := new simulation_value (simulation_array_double);
            for i in simulations_range loop
               res.double_table_value (i) :=
                 apply_operator
                   (value.double_table_value (i),
                    c.ope,
                    line,
                    file_name);
            end loop;

         when simulation_double =>
            res              := new simulation_value (simulation_double);
            res.double_value :=
              apply_operator (value.double_value, c.ope, line, file_name);

         when simulation_time_unit_array_boolean =>
            res := new simulation_value (simulation_time_unit_array_boolean);
            for i in time_unit_range loop
               res.boolean_time_unit_table_value (i) :=
                 apply_operator
                   (value.boolean_time_unit_table_value (i),
                    c.ope,
                    line,
                    file_name);
            end loop;

         when simulation_array_boolean =>
            res := new simulation_value (simulation_array_boolean);
            for i in simulations_range loop
               res.boolean_table_value (i) :=
                 apply_operator
                   (value.boolean_table_value (i),
                    c.ope,
                    line,
                    file_name);
            end loop;

         when simulation_boolean =>
            res               := new simulation_value (simulation_boolean);
            res.boolean_value :=
              apply_operator (value.boolean_value, c.ope, line, file_name);
      end case;

      return res;

   end value_of;

   function value_of
     (c         :    constant_expression;
      v         :    variables_table_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String :=
        empty_string)
      return simulation_value_ptr
   is
   begin
      return copy (c.value);
   end value_of;

   function value_of
     (c         :    variable_expression;
      v         :    variables_table_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String :=
        empty_string)
      return simulation_value_ptr
   is
      new_val : simulation_value_ptr;
      seed    : Generator;

   begin
      for i in 0 .. v.nb_entries - 1 loop
         if v.entries (i).variable.name = c.name then
            if (v.entries (i).simulation.ptype = simulation_random) then
               Reset (seed, v.entries (i).simulation.random_value);
               new_val := new simulation_value (simulation_integer);
               new_val.integer_value :=
                 apply_random_operator
                   (seed,
                    v.entries (i).simulation.random_law_parameters,
                    line,
                    file_name);
               Save (seed, v.entries (i).simulation.random_value);
               return new_val;
            else
               return copy (v.entries (i).simulation);
            end if;
         end if;
      end loop;

      Raise_Exception
        (variable_error'identity,
         "line " &
         line'img &
         ", file " &
         To_String (file_name) &
         To_String (lb_comma) &
         To_String
           (lb_undeclared_identifier (Current_Language) & lb_colon & c.name));
   end value_of;

   function value_of
     (c         :    array_variable_expression;
      v         :    variables_table_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String :=
        empty_string)
      return simulation_value_ptr
   is
      new_val : simulation_value_ptr;
      index   : simulation_value_ptr;
      seed    : Generator;

   begin
      for i in 0 .. v.nb_entries - 1 loop
         if v.entries (i).variable.name = c.name then

            -- Two cases : return the all task array table or
            --          if an index is provided, return
            --          a scalar data
            --

            if (c.array_index /= null)

               -- indexed expression : return scalar data
               --
                then

               index := value_of (c.array_index.all, v, line, file_name);
               if index.ptype /= simulation_integer then
                  Raise_Exception
                    (type_error'identity,
                     "line " &
                     line'img &
                     ", file " &
                     To_String (file_name) &
                     To_String (lb_comma) &
                     To_String
                       (lb_index_error (Current_Language) &
                        lb_colon &
                        c.name));
               end if;

               if
                 (c.variable_type = simulation_array_clock or
                  c.variable_type = simulation_array_integer)
               then
                  new_val := new simulation_value (simulation_integer);
                  new_val.integer_value :=
                    v.entries (i).simulation.integer_table_value
                      (simulations_range (index.integer_value));
               end if;
               if c.variable_type = simulation_array_random then
                  Reset
                    (seed,
                     v.entries (i).simulation.random_table_value
                       (simulations_range (index.integer_value)));
                  new_val := new simulation_value (simulation_integer);
                  new_val.integer_value :=
                    apply_random_operator
                      (seed,
                       v.entries (i).simulation.random_table_law_parameters,
                       line,
                       file_name);
                  Save
                    (seed,
                     v.entries (i).simulation.random_table_value
                       (simulations_range (index.integer_value)));
               end if;
               if c.variable_type = simulation_array_double then
                  new_val := new simulation_value (simulation_double);
                  new_val.double_value :=
                    v.entries (i).simulation.double_table_value
                      (simulations_range (index.integer_value));
               end if;
               if c.variable_type = simulation_array_boolean then
                  new_val := new simulation_value (simulation_boolean);
                  new_val.boolean_value :=
                    v.entries (i).simulation.boolean_table_value
                      (simulations_range (index.integer_value));
               end if;
               if c.variable_type = simulation_array_string then
                  new_val := new simulation_value (simulation_string);
                  new_val.string_value :=
                    v.entries (i).simulation.string_table_value
                      (simulations_range (index.integer_value));
               end if;
               if c.variable_type = simulation_time_unit_array_integer then
                  new_val := new simulation_value (simulation_integer);
                  new_val.integer_value :=
                    v.entries (i).simulation.integer_time_unit_table_value
                      (time_unit_range (index.integer_value));
               end if;
               if c.variable_type = simulation_time_unit_array_double then
                  new_val := new simulation_value (simulation_double);
                  new_val.double_value :=
                    v.entries (i).simulation.double_time_unit_table_value
                      (time_unit_range (index.integer_value));
               end if;
               if c.variable_type = simulation_time_unit_array_boolean then
                  new_val := new simulation_value (simulation_boolean);
                  new_val.boolean_value :=
                    v.entries (i).simulation.boolean_time_unit_table_value
                      (time_unit_range (index.integer_value));
               end if;
               if c.variable_type = simulation_time_unit_array_string then
                  new_val := new simulation_value (simulation_string);
                  new_val.string_value :=
                    v.entries (i).simulation.string_time_unit_table_value
                      (time_unit_range (index.integer_value));
               end if;

               free (index);

               return new_val;

            else
               -- Array tables.
               --

               if c.variable_type = simulation_array_random then
                  new_val := new simulation_value (simulation_array_integer);
                  for j in simulations_range loop
                     Reset
                       (seed,
                        v.entries (i).simulation.random_table_value (j));
                     new_val.integer_table_value (j) :=
                       apply_random_operator
                         (seed,
                          v.entries (i).simulation.random_table_law_parameters,
                          line,
                          file_name);
                     Save
                       (seed,
                        v.entries (i).simulation.random_table_value (j));
                  end loop;
               end if;

               if
                 (c.variable_type = simulation_array_integer or
                  c.variable_type = simulation_array_clock)
               then
                  new_val := new simulation_value (simulation_array_integer);
                  new_val.integer_table_value :=
                    v.entries (i).simulation.integer_table_value;
               end if;

               if c.variable_type = simulation_array_double then
                  new_val := new simulation_value (simulation_array_double);
                  new_val.double_table_value :=
                    v.entries (i).simulation.double_table_value;
               end if;

               if c.variable_type = simulation_array_boolean then
                  new_val := new simulation_value (simulation_array_boolean);
                  new_val.boolean_table_value :=
                    v.entries (i).simulation.boolean_table_value;
               end if;

               if c.variable_type = simulation_array_string then
                  new_val := new simulation_value (simulation_array_string);
                  new_val.string_table_value :=
                    v.entries (i).simulation.string_table_value;
               end if;

               if c.variable_type = simulation_time_unit_array_integer then
                  new_val :=
                    new simulation_value (simulation_time_unit_array_integer);
                  new_val.integer_time_unit_table_value :=
                    v.entries (i).simulation.integer_time_unit_table_value;
               end if;

               if c.variable_type = simulation_time_unit_array_double then
                  new_val :=
                    new simulation_value (simulation_time_unit_array_double);
                  new_val.double_time_unit_table_value :=
                    v.entries (i).simulation.double_time_unit_table_value;
               end if;

               if c.variable_type = simulation_time_unit_array_boolean then
                  new_val :=
                    new simulation_value (simulation_time_unit_array_boolean);
                  new_val.boolean_time_unit_table_value :=
                    v.entries (i).simulation.boolean_time_unit_table_value;
               end if;

               if c.variable_type = simulation_time_unit_array_string then
                  new_val :=
                    new simulation_value (simulation_time_unit_array_string);
                  new_val.string_time_unit_table_value :=
                    v.entries (i).simulation.string_time_unit_table_value;
               end if;

               return new_val;
            end if;

         end if;

      end loop;

      Raise_Exception
        (variable_error'identity,
         "line " &
         line'img &
         ", file " &
         To_String (file_name) &
         To_String (lb_comma) &
         To_String
           (lb_undeclared_identifier (Current_Language) & lb_colon & c.name));
   end value_of;

end expressions;
