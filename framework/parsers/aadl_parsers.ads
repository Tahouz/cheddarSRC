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
-- Frank Singhoff, Lab-STICC UMR CNRS 6285, Universite de Bretagne Occidentale
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

with Ada.Finalization;
with systems;       use systems;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with unbounded_strings; use unbounded_strings;
use unbounded_strings.unbounded_string_list_package;

package aadl_parsers is

   -- AADL parser
   --
   type aadl_project_parser is new Ada.Finalization.Controlled with private;

   -- Methods for all Cheddar AADL parsers
   --
   procedure initialize_project_parser (handler : in out aadl_project_parser);

   function get_parsed_system (handler : aadl_project_parser) return system;

   procedure initialize (handler : in out aadl_project_parser);

   procedure parse
     (handler           : in out aadl_project_parser;
      dir_list          :        unbounded_string_list;
      project_file_list :        unbounded_string_list);

   -- Exception raised by clients of AADL_Parser when something goes
   -- wrong during AADL parsing
   --
   aadl_read_error : exception;

private

   type aadl_project_parser is new Ada.Finalization.Controlled with record
      parsed_system : system;
   end record;

end aadl_parsers;
