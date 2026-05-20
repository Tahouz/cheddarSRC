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

with systems;               use systems;
with primitive_xml_strings; use primitive_xml_strings;
with message_set;           use message_set;
use message_set.generic_message_set;
with buffer_set; use buffer_set;
use buffer_set.generic_buffer_set;
with task_set; use task_set;
use task_set.generic_task_set;
with resource_set; use resource_set;
use resource_set.generic_resource_set;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
with Framework_Config;      use Framework_Config;
with Simulations;           use Simulations;
with Simulations.extended;  use Simulations.extended;
with Text_IO;               use Text_IO;
with tables;
with Ada.Finalization;
with convert_strings;
with convert_unbounded_strings;
with Objects;               use Objects;

package expressions is

   -- The data type does not match the expected type
   --
   type_error : exception;

   -- Statement exception (such as unexpected statement)
   --
   statement_error : exception;

   -- Exception raised when an error occurs
   -- on variable operations
   --
   variable_error : exception;

   -- Syntax error detected
   --
   syntax_error : exception;

   -- This exception is raised when a parametric file can not be read
   --
   parametric_file_error : exception;

   -- This exception is raised wheh an exit statement is run
   --
   exit_statement_exception : exception;

   ---------------------------------------------------------
   -- Valid operator used to build expressions
   --
   type operator_type is
     (plus_type,
      minus_type,
      divide_type,
      multiply_type,
      exponential_type,
      modulo_type,
      equal_type,
      not_equal_type,
      equal_less_type,
      equal_greater_type,
      inferior_type,
      superior_type,
      logic_and_type,
      logic_or_type,
      logic_not_type,
      min_operator_type,
      max_operator_type,
      min_to_index_type,
      max_to_index_type,
      lcm_type,
      abs_type,
      to_integer_type,
      to_double_type,
      get_resource_index_type,
      get_task_index_type,
      get_message_index_type,
      get_buffer_index_type,
      concatenate_type);

   procedure to_operator_type is new convert_strings
     (operator_type,
      plus_type);
   procedure to_operator_type is new convert_unbounded_strings
     (operator_type,
      plus_type);
   package operator_type_io is new Text_IO.Enumeration_IO (operator_type);
   use operator_type_io;

   -----------------------------------------------------------

   -- A predefinition of the variable type
   --
   type variable_expression;
   type variable_expression_ptr is access all variable_expression'class;

   ---------------------------------------------------------
   -- Table to store the list of variables of
   -- a parametric scheduler. For each variable,
   -- the current simulation values are also stored
   --

   type variable_record is record
      variable   : variable_expression_ptr;
      simulation : simulation_value_ptr;
   end record;
   type variable_record_ptr is access variable_record;

   procedure put (v : in variable_record_ptr);
   function xml_string (e : in variable_record_ptr) return Unbounded_String;
   function xml_ref_string
     (e : in variable_record_ptr) return Unbounded_String;

   package variables_type_package is new tables
     (variable_record_ptr,
      Max_Variables,
      put,
      xml_string,
      xml_ref_string);
   use variables_type_package;

   subtype variables_range is variables_type_package.table_range;
   subtype variables_table_type is variables_type_package.table;

   -- Looking for a variable in the variable table
   --
   function find_variable
     (var_table : in variables_table_type;
      s         : in Unbounded_String;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return variables_range;

   function find_variable
     (var_table : in variables_table_type;
      s         : in String;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return variables_range;

   -- Check is a given variable is already defined in a
   -- variable table
   --
   procedure check_variable_declaration
     (var_table : in variables_table_type;
      s         : in Unbounded_String;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string);

   -- Load into the parametric simulator
   -- data from task, processor, message and buffer elements
   --
   -- The number of object (tasks, resources, buffers) is initialized
   -- accordig to the correspondig processor (parameter processor_name)
   -- if processor_name is an empty string, all tasks/buffers/resources
   -- of all procesors are considered
   --
   procedure initialize_parametric_variables
     (var_table      : in out variables_table_type;
      my_messages    : in     messages_set;
      my_buffers     : in     buffers_set;
      my_resources   : in     resources_set;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String := empty_string);

   -- Add the parametric variable in a variable table
   --
   procedure create_parametric_variables
     (variables_table : in out variables_table_type;
      my_tasks        : in     tasks_set);

   ---------------------------------------------------------

   type expressions_type is
     (constant_type,
      variable_type,
      array_variable_type,
      binary_type,
      unary_type,
      random_type);

   procedure to_expressions_type is new convert_strings
     (expressions_type,
      constant_type);
   procedure to_expressions_type is new convert_unbounded_strings
     (expressions_type,
      constant_type);
   package expressions_type_io is new Text_IO.Enumeration_IO
     (expressions_type);
   use expressions_type_io;

   type generic_expression is abstract new named_object with record
      expression_type : expressions_type;
   end record;
   type generic_expression_ptr is access all generic_expression'class;

   procedure put (s : in generic_expression) is abstract;
   procedure put (s : in generic_expression_ptr) is abstract;

   function xml_string
     (obj : in generic_expression_ptr) return Unbounded_String;
   function xml_string (obj : in generic_expression) return Unbounded_String;
   function xml_ref_string
     (obj : in generic_expression_ptr) return Unbounded_String;
   function xml_ref_string
     (obj : in generic_expression) return Unbounded_String;
   procedure put_name (obj : in generic_expression_ptr);
   function get_name (obj : in generic_expression) return Unbounded_String;
   function get_name (obj : in generic_expression_ptr) return Unbounded_String;

   function to_unbounded_string
     (c : generic_expression) return Unbounded_String is abstract;

   function get_type
     (c         :    generic_expression;
      line      : in Natural          := 0;
      file_name : in Unbounded_String :=
        empty_string)
      return simulation_type is abstract;

   function value_of
     (c         : in generic_expression;
      v         : in variables_table_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String :=
        empty_string)
      return simulation_value_ptr is abstract;

   ------------------------------------------

   type constant_expression is new generic_expression with record
      value : simulation_value_ptr;
   end record;

   type constant_expression_ptr is access all constant_expression'class;

   function xml_string
     (obj : in constant_expression_ptr) return Unbounded_String;
   function xml_string (obj : in constant_expression) return Unbounded_String;
   function xml_ref_string
     (obj : in constant_expression_ptr) return Unbounded_String;
   function xml_ref_string
     (obj : in constant_expression) return Unbounded_String;

   procedure put (s : in constant_expression);
   procedure put (s : in constant_expression_ptr);

   procedure put_name (obj : in constant_expression_ptr);
   function get_name (obj : in constant_expression) return Unbounded_String;
   function get_name
     (obj : in constant_expression_ptr) return Unbounded_String;

   function to_unbounded_string
     (c : constant_expression) return Unbounded_String;

   function get_type
     (c         :    constant_expression;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return simulation_type;

   procedure initialize (s : in out constant_expression);

   function value_of
     (c         : in constant_expression;
      v         : in variables_table_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String :=
        empty_string)
      return simulation_value_ptr;

   ------------------------------------------

   type variable_expression is new generic_expression with record

      -- Type of the variable (integer, boolean, ...)
      --
      variable_type : simulation_type;
   end record;

   function xml_string
     (obj : in variable_expression_ptr) return Unbounded_String;
   function xml_string (obj : in variable_expression) return Unbounded_String;
   function xml_ref_string
     (obj : in variable_expression_ptr) return Unbounded_String;
   function xml_ref_string
     (obj : in variable_expression) return Unbounded_String;

   procedure put (s : in variable_expression);
   procedure put (s : in variable_expression_ptr);

   procedure put_name (obj : in variable_expression_ptr);
   function get_name (obj : in variable_expression) return Unbounded_String;
   function get_name
     (obj : in variable_expression_ptr) return Unbounded_String;

   function to_unbounded_string
     (c : variable_expression) return Unbounded_String;

   function get_type
     (c         :    variable_expression;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return simulation_type;

   procedure initialize (s : in out variable_expression);

   function value_of
     (c         : in variable_expression;
      v         : in variables_table_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String :=
        empty_string)
      return simulation_value_ptr;

   ------------------------------------------

   type array_variable_expression is new variable_expression with record
      array_index : generic_expression_ptr;
   end record;

   type array_variable_expression_ptr is
     access all array_variable_expression'class;

   function xml_string
     (obj : in array_variable_expression_ptr) return Unbounded_String;
   function xml_string
     (obj : in array_variable_expression) return Unbounded_String;
   function xml_ref_string
     (obj : in array_variable_expression_ptr) return Unbounded_String;
   function xml_ref_string
     (obj : in array_variable_expression) return Unbounded_String;

   procedure put (s : in array_variable_expression);
   procedure put (s : in array_variable_expression_ptr);

   procedure put_name (obj : in array_variable_expression_ptr);
   function get_name
     (obj : in array_variable_expression) return Unbounded_String;
   function get_name
     (obj : in array_variable_expression_ptr) return Unbounded_String;

   function to_unbounded_string
     (c : array_variable_expression) return Unbounded_String;

   procedure initialize (s : in out array_variable_expression);

   function value_of
     (c         : in array_variable_expression;
      v         : in variables_table_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String :=
        empty_string)
      return simulation_value_ptr;

   ------------------------------------------

   type binary_expression is new generic_expression with record
      ope    : operator_type;
      rvalue : generic_expression_ptr;
      lvalue : generic_expression_ptr;
   end record;
   type binary_expression_ptr is access all binary_expression'class;

   function xml_string
     (obj : in binary_expression_ptr) return Unbounded_String;
   function xml_string (obj : in binary_expression) return Unbounded_String;
   function xml_ref_string
     (obj : in binary_expression_ptr) return Unbounded_String;
   function xml_ref_string
     (obj : in binary_expression) return Unbounded_String;

   procedure put (s : in binary_expression);
   procedure put (s : in binary_expression_ptr);

   procedure put_name (obj : in binary_expression_ptr);
   function get_name (obj : in binary_expression) return Unbounded_String;
   function get_name (obj : in binary_expression_ptr) return Unbounded_String;

   function to_unbounded_string
     (c : binary_expression) return Unbounded_String;

   function get_type
     (c         :    binary_expression;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return simulation_type;

   procedure initialize (s : in out binary_expression);

   function value_of
     (c         : in binary_expression;
      v         : in variables_table_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String :=
        empty_string)
      return simulation_value_ptr;

   ------------------------------------------

   type unary_expression is new generic_expression with record
      ope   : operator_type;
      value : generic_expression_ptr;
   end record;
   type unary_expression_ptr is access all unary_expression'class;

   function xml_string (obj : in unary_expression_ptr) return Unbounded_String;
   function xml_string (obj : in unary_expression) return Unbounded_String;
   function xml_ref_string
     (obj : in unary_expression_ptr) return Unbounded_String;
   function xml_ref_string (obj : in unary_expression) return Unbounded_String;

   procedure put (s : in unary_expression);
   procedure put (s : in unary_expression_ptr);

   procedure put_name (obj : in unary_expression_ptr);
   function get_name (obj : in unary_expression) return Unbounded_String;
   function get_name (obj : in unary_expression_ptr) return Unbounded_String;

   function to_unbounded_string (c : unary_expression) return Unbounded_String;

   function get_type
     (c         :    unary_expression;
      line      : in Natural          := 0;
      file_name : in Unbounded_String := empty_string) return simulation_type;

   procedure initialize (s : in out unary_expression);

   function value_of
     (c         : in unary_expression;
      v         : in variables_table_type;
      line      : in Natural          := 0;
      file_name : in Unbounded_String :=
        empty_string)
      return simulation_value_ptr;

end expressions;
