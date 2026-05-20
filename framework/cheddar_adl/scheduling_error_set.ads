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
--    $Rev: 3477 $
--    $Date: 2020-07-13 11:43:48 +0200 (lun., 13 juil. 2020) $
--    $Author:  $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Framework_Config;      use Framework_Config;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Scheduling_Errors;     use Scheduling_Errors;
with sets;

package scheduling_error_set is

   ----------------------------------------------------------
   -- Definition of a set
   ----------------------------------------------------------

   package scheduling_error_set is new sets
     (max_element    => Framework_Config.Max_Scheduling_Errors,
      element        => scheduling_error_ptr,
      free           => Free,
      copy           => Copy,
      put            => Put,
      xml_string     => XML_String,
      xml_ref_string => XML_Ref_String);
   use scheduling_error_set;

   type scheduling_errors_set is new scheduling_error_set.set with private;

   subtype scheduling_errors_range is scheduling_error_set.element_range;
   subtype scheduling_errors_iterator is scheduling_error_set.iterator;

   ----------------------------------------------------------
   -- Exceptions defined in the set package
   ----------------------------------------------------------

   -- Raised when a given Scheduling_Error is not in a Scheduling_Error set
   --
   scheduling_error_not_found : exception;

   -- Raised when parameters provided to Add_Scheduling_Error are wrong
   --
   invalid_parameter : exception;

   ----------------------------------------------------------
   -- Procedure to proceed modification on a set
   ----------------------------------------------------------

   procedure check_scheduling_error
     (my_scheduling_errors      : in scheduling_errors_set;
      name                      : in Unbounded_String;
      a_scheduling_error_record : in scheduling_error_record);

   procedure add_scheduling_error
     (my_scheduling_errors      : in out scheduling_errors_set;
      a_scheduling_error        : in out scheduling_error_ptr;
      name                      : in     Unbounded_String;
      a_scheduling_error_record : in     scheduling_error_record);

   procedure add_scheduling_error
     (my_scheduling_errors      : in out scheduling_errors_set;
      name                      : in     Unbounded_String;
      a_scheduling_error_record : in     scheduling_error_record);

   ----------------------------------------------------------
   -- Search information from a set
   ----------------------------------------------------------

   function search_scheduling_error
     (my_scheduling_errors : in scheduling_errors_set;
      name                 : in Unbounded_String) return scheduling_error_ptr;

   function search_scheduling_error_by_id
     (my_scheduling_errors : in scheduling_errors_set;
      id                   : in Unbounded_String) return scheduling_error_ptr;

private

   type scheduling_errors_set is new scheduling_error_set.set with null record;

end scheduling_error_set;
