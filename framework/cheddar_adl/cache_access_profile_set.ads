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
with unbounded_strings;     use unbounded_strings;
with Framework_Config;      use Framework_Config;
with Caches;                use Caches;
with sets;

package cache_access_profile_set is

   ------------------------------------------------------
   -- CACHE ACCESS PROFILE
   ------------------------------------------------------
   package cache_access_profile_set is new sets
     (max_element    => Framework_Config.Max_Tasks,
      element        => cache_access_profile_ptr,
      free           => Free,
      copy           => Copy,
      put            => Put,
      xml_string     => XML_String,
      xml_ref_string => XML_Ref_String);

   use cache_access_profile_set;

   type cache_access_profiles_set is
     new cache_access_profile_set.set with private;

   subtype cache_access_profiles_range is
     cache_access_profile_set.element_range;
   subtype cache_access_profiles_iterator is cache_access_profile_set.iterator;

   --
   -- Exception
   --
   cache_access_profile_not_found : exception;

   cache_access_profile_must_be_defined : exception;

   cache_access_profile_must_be_defined_for_all_tasks : exception;

   invalid_parameter : exception;
   --
   -- Add
   --
   procedure add_cache_access_profile
     (my_cache_access_profiles : in out cache_access_profiles_set;
      a_cache_access_profile   : in out cache_access_profile_ptr;
      name                     : in     Unbounded_String;
      ucbs                     : in     cache_blocks_table;
      ecbs                     : in     cache_blocks_table);

   procedure add_cache_access_profile
     (my_cache_access_profiles : in out cache_access_profiles_set;
      name                     : in     Unbounded_String;
      ucbs                     : in     cache_blocks_table;
      ecbs                     : in     cache_blocks_table);

   --
   -- Update
   --
   procedure update_cache_access_profile
     (my_cache_access_profiles : in out cache_access_profiles_set;
      name                     : in     Unbounded_String;
      ucbs                     : in     cache_blocks_table;
      ecbs                     : in     cache_blocks_table);

   --
   -- Search
   --
   function search_cache_access_profile
     (my_cache_access_profiles : in cache_access_profiles_set;
      name : in Unbounded_String) return cache_access_profile_ptr;

   --
   -- Delete
   --
   procedure delete_cache_access_profile
     (my_cache_access_profiles : in out cache_access_profiles_set;
      name                     : in     Unbounded_String);

private
   type cache_access_profiles_set is new cache_access_profile_set.set with
   null record;

end cache_access_profile_set;
