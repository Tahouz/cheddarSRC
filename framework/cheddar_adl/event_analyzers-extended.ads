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

with expressions;           use expressions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Unchecked_Deallocation;
with Interpreter;           use Interpreter;
use Interpreter.Sets_Type_Package;

package event_analyzers.extended is

   type extended_event_analyzer is new event_analyzer with record

      -- Event Analyzer behavior in string format
      --
      string_behavior : Unbounded_String;

      -- Statements for each scheduling
      -- section (pointers given by the parser)
      --
      root_statement_pointer : section_table;

      -- Variables table for the parsed parametric file
      -- (given by the parser)
      --
      variables_table : variables_table_type;

      -- Table of set statements given by the parser
      --
      sets_table : sets_table_type;
   end record;

   type extended_event_analyzer_ptr is
     access all extended_event_analyzer'class;

   procedure free is new Unchecked_Deallocation
     (extended_event_analyzer'class,
      extended_event_analyzer_ptr);

   function copy
     (my_event_analyzer : in extended_event_analyzer_ptr)
      return extended_event_analyzer_ptr;

end event_analyzers.extended;
