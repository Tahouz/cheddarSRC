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

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with expressions;           use expressions;
with tables;
with Framework_Config;      use Framework_Config;
with Sections;              use Sections;
with Statements;            use Statements;
with scheduler;             use scheduler;

package Interpreter.extended is

   procedure put (s : in section_table);

   -- Looking for a set statement in the table
   --
   function find_set
     (var : in sets_table_type;
      s   : in Unbounded_String) return sets_range;

   procedure check_set_declaration
     (var : in sets_table_type;
      s   : in Unbounded_String);

   ---------------------------------------------------------------------
   --- Functions and procedure in this part of the package perform
   --  interpretation of the statements  which are part of
   --  user-defined schedulers or user-defined event analyzers
   ----------------------------------------------------------------------

   procedure dispatch
     (current         : in     generic_statement_ptr;
      current_section : in     sections_type;
      processor_name  : in     Unbounded_String;
      si              : in out scheduling_information;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String);

   procedure if_dispatch
     (current         : in     if_statement_ptr;
      current_section : in     sections_type;
      processor_name  : in     Unbounded_String;
      si              : in out scheduling_information;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String;
      next            : in out generic_statement_ptr);

   procedure assign_dispatch
     (current         : in     assign_statement_ptr;
      processor_name  : in     Unbounded_String;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String;
      next            : in out generic_statement_ptr);

   procedure random_initialize_dispatch
     (current         : in     random_initialize_statement_ptr;
      processor_name  : in     Unbounded_String;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String;
      next            : in out generic_statement_ptr);

   procedure put_dispatch
     (current         : in     put_statement_ptr;
      processor_name  : in     Unbounded_String;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String;
      next            : in out generic_statement_ptr);

   procedure while_dispatch
     (current         : in     while_statement_ptr;
      current_section : in     sections_type;
      processor_name  : in     Unbounded_String;
      si              : in out scheduling_information;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String;
      next            : in out generic_statement_ptr);

   procedure for_dispatch
     (current         : in     for_statement_ptr;
      current_section : in     sections_type;
      processor_name  : in     Unbounded_String;
      si              : in out scheduling_information;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String;
      next            : in out generic_statement_ptr);

   procedure delete_precedence_dispatch
     (current         : in     delete_precedence_statement_ptr;
      processor_name  : in     Unbounded_String;
      si              : in out scheduling_information;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String;
      next            : in out generic_statement_ptr);

   procedure add_precedence_dispatch
     (current         : in     add_precedence_statement_ptr;
      processor_name  : in     Unbounded_String;
      si              : in out scheduling_information;
      variables_table : in out variables_table_type;
      msg             : in out Unbounded_String;
      next            : in out generic_statement_ptr);

end Interpreter.extended;
