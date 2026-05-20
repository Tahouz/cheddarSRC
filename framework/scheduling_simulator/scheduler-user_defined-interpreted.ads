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

with expressions; use expressions;
use expressions.variables_type_package;
with Interpreter; use Interpreter;
use Interpreter.Sets_Type_Package;
with Statements; use Statements;

package scheduler.user_defined.interpreted is

   type interpreted_user_defined_scheduler is
     abstract new user_defined_scheduler with private;
   type interpreted_user_defined_scheduler_ptr is
     access all interpreted_user_defined_scheduler'class;

   -- Procedure to load/save interpreter variables
   -- that are allowed to be read or written by sc programmers
   --
   procedure save_read_write_interpreter_variables
     (my_scheduler   : in     interpreted_user_defined_scheduler;
      si             : in out scheduling_information;
      processor_name : in     Unbounded_String);
   procedure load_read_write_interpreter_variables
     (my_scheduler   : in out interpreted_user_defined_scheduler;
      si             : in     scheduling_information;
      processor_name : in     Unbounded_String);

   -- When a task is run by the scheduling simulator,
   -- its state has changed. These changes must be stored in the interpreter
   -- variables : this procedure update interpreter variables of the
   -- elected task
   --
   procedure update_interpreter_variables_after_task_execution
     (my_scheduler       : in out interpreted_user_defined_scheduler;
      si                 : in out scheduling_information;
      current_time       : in     Natural;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      options            : in     scheduling_option);

   procedure dispatch_return_statement
     (my_scheduler       : in out interpreted_user_defined_scheduler;
      current            : in     generic_statement_ptr;
      si                 : in out scheduling_information;
      current_time       : in     Natural;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      options            : in     scheduling_option;
      elected            : in out tasks_range;
      no_task            : in out Boolean);

   procedure compute_activation_time
     (my_scheduler : in     interpreted_user_defined_scheduler;
      si           : in out scheduling_information;
      elected      : in     tasks_range;
      value        : in out Natural);

   function read_variable
     (my_scheduler : in interpreted_user_defined_scheduler;
      var_name     :    Unbounded_String) return Integer;

   function read_variable
     (my_scheduler : in interpreted_user_defined_scheduler;
      var_name     :    Unbounded_String) return Unbounded_String;

   function read_variable
     (my_scheduler : in interpreted_user_defined_scheduler;
      var_name     :    Unbounded_String) return Boolean;

   function read_variable
     (my_scheduler : in interpreted_user_defined_scheduler;
      var_name     :    Unbounded_String) return Double;

private

   type interpreted_user_defined_scheduler is abstract new user_defined_scheduler with
   record

      -- Variables table for the parsed scheduler
      -- (given by the parser)
      --
      variables_table : variables_table_type;

      -- Table of set statements given by the parser
      --
      sets_table : sets_table_type;

   end record;

end scheduler.user_defined.interpreted;
