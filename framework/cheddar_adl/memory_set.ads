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
--    $Author:  $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Framework_Config;      use Framework_Config;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Memories;              use Memories;
with sets;

package memory_set is

   ----------------------------------------------------------
   -- Definition of a set
   ----------------------------------------------------------

   package generic_memory_set is new sets
     (max_element    => Framework_Config.Max_Memories,
      element        => generic_memory_ptr,
      free           => Free,
      copy           => Copy,
      put            => Put,
      xml_string     => XML_String,
      xml_ref_string => XML_Ref_String);
   use generic_memory_set;

   type memories_set is new generic_memory_set.set with private;

   subtype memories_range is generic_memory_set.element_range;
   subtype memories_iterator is generic_memory_set.iterator;

   ----------------------------------------------------------
   -- Exceptions defined in the set package
   ----------------------------------------------------------

   -- Raised when a given Memory is not in a memory set
   --
   memory_not_found : exception;

   -- Raised when parameters provided to Add_Memory are wrong
   --
   invalid_parameter : exception;

   ----------------------------------------------------------
   -- Empty memory table
   --
   no_memories : memories_table;

   ----------------------------------------------------------
   -- Procedure to proceed modification on a set
   ----------------------------------------------------------

   procedure check_memory
     (my_memories     : in memories_set;
      name            : in Unbounded_String;
      a_memory_record : in memory_record);

   procedure add_memory
     (my_memories     : in out memories_set;
      a_memory        : in out generic_memory_ptr;
      name            : in     Unbounded_String;
      a_memory_record : in     memory_record);

   procedure add_memory
     (my_memories     : in out memories_set;
      name            : in     Unbounded_String;
      a_memory_record : in     memory_record);

   ----------------------------------------------------------
   -- Read information from a set
   ----------------------------------------------------------

   function search_memory_by_id
     (my_memories : in memories_set;
      id          : in Unbounded_String) return generic_memory_ptr;

   function search_memory
     (my_memories : in memories_set;
      name        : in Unbounded_String) return generic_memory_ptr;

private

   type memories_set is new generic_memory_set.set with null record;

end memory_set;
