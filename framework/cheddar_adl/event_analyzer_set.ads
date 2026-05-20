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
with Framework_Config;      use Framework_Config;
with event_analyzers;       use event_analyzers;
with sets;

package event_analyzer_set is

   ----------------------------------------------------------
   -- Definition of a set
   ----------------------------------------------------------

   package generic_event_analyzer_set is new sets
     (max_element    => Framework_Config.Max_Event_Analyzers,
      element        => event_analyzer_ptr,
      free           => free,
      copy           => copy,
      put            => put,
      xml_string     => xml_string,
      xml_ref_string => xml_string);

   use generic_event_analyzer_set;

   type event_analyzers_set is new generic_event_analyzer_set.set with private;

   subtype event_analyzers_range is generic_event_analyzer_set.element_range;
   subtype event_analyzers_iterator is generic_event_analyzer_set.iterator;

   ----------------------------------------------------------
   -- Exceptions defined in the set package
   ----------------------------------------------------------

   -- Raised when a given event analyzer is not in a event analyzer set
   --
   event_analyzer_not_found : exception;

   -- Raised when parameters provided to Add_event_analyzer are wrong
   --
   invalid_parameter : exception;

   ----------------------------------------------------------
   -- I/O operations
   ----------------------------------------------------------

   function export_aadl_properties
     (my_event_analyzers : in event_analyzers_set;
      number_of_ht       : in Natural) return Unbounded_String;

   ----------------------------------------------------------
   -- Procedure to proceed modification on a set
   ----------------------------------------------------------

   procedure check_event_analyzer
     (my_event_analyzers : in event_analyzers_set;
      name               : in Unbounded_String;
      file_name          : in Unbounded_String);

   procedure add_event_analyzer
     (my_event_analyzers : in out event_analyzers_set;
      name               : in     Unbounded_String;
      file_name          : in     Unbounded_String);

   ------------------------------------------------------
   -- Read information from a set
   ------------------------------------------------------

   -- Get the task pointer of the task named "Name"
   --
   function search_event_analyzer
     (my_event_analyzers : in event_analyzers_set;
      name               : in Unbounded_String) return event_analyzer_ptr;

private

   type event_analyzers_set is new generic_event_analyzer_set.set with
   null record;

end event_analyzer_set;
