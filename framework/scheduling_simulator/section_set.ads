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
with Sections;              use Sections;
with sets;

package section_set is

   ----------------------------------------------------------
   -- Definition of a set
   ----------------------------------------------------------

   package package_generic_section_set is new sets
     (max_element    => Framework_Config.Max_Sections,
      element        => generic_section_ptr,
      copy           => Copy,
      free           => Free,
      put            => Put,
      xml_string     => XML_String,
      xml_ref_string => XML_Ref_String);
   use package_generic_section_set;

   type sections_set is new package_generic_section_set.set with private;

   subtype sections_range is package_generic_section_set.element_range;
   subtype sections_iterator is package_generic_section_set.iterator;

   ----------------------------------------------------------
   -- Exceptions defined in the set package
   ----------------------------------------------------------

   -- Raised when a given task is not in a section set
   --
   section_not_found : exception;

   -- Raised when parameters provided to Add_Section are wrong
   --
   invalid_parameter : exception;

   ----------------------------------------------------------
   -- I/O operations
   ----------------------------------------------------------

   function export_aadl_implementations
     (my_sections : in sections_set) return Unbounded_String;

   function export_aadl_declarations
     (my_sections  : in sections_set;
      number_of_ht : in Natural) return Unbounded_String;

   ----------------------------------------------------------
   -- Procedure to proceed modification on a set
   ----------------------------------------------------------

   procedure check_section
     (my_sections  : in sections_set;
      name         : in Unbounded_String;
      section_type : in sections_type);

   procedure add_section
     (my_sections  : in out sections_set;
      name         : in     Unbounded_String;
      section_type : in     sections_type);

   procedure add_section
     (my_sections  : in out sections_set;
      a_section    : in out generic_section_ptr;
      name         : in     Unbounded_String;
      section_type : in     sections_type);

   -- Search a section with its name
   --
   function search_section
     (my_sections : in sections_set;
      name        : in Unbounded_String) return generic_section_ptr;

   -- Search the first section of a given type
   --
   function search_section
     (my_sections : in sections_set;
      type_name   : in sections_type) return generic_section_ptr;

private

   type sections_set is new package_generic_section_set.set with null record;

end section_set;
