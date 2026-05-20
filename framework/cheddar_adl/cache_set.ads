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

with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with unbounded_strings;        use unbounded_strings;
with Framework_Config;         use Framework_Config;
with Caches;                   use Caches;
with cache_access_profile_set; use cache_access_profile_set;
with sets;

package cache_set is

   no_cache_blocks_table   : cache_blocks_table;
   no_cache_access_profile : cache_access_profiles_set;

   ----------------------------------------------------------
   -- CACHE
   ----------------------------------------------------------

   package generic_cache_set is new sets
     (max_element    => Framework_Config.Max_Caches,
      element        => generic_cache_ptr,
      free           => Free,
      copy           => Copy,
      put            => Put,
      xml_string     => XML_String,
      xml_ref_string => XML_Ref_String);

   use generic_cache_set;

   type caches_set is new generic_cache_set.set with private;

   subtype caches_range is generic_cache_set.element_range;
   subtype caches_iterator is generic_cache_set.iterator;

   -- Raised when a given cache is not in a cache unit
   -- set
   --
   cache_not_found : exception;

   -- Raised when parameters provided to Add_cache are wrong
   --
   invalid_parameter : exception;

   ----------------------------------------------------------
   -- I/O operations
   ----------------------------------------------------------
   function export_aadl_implementations
     (my_caches : in caches_set) return Unbounded_String;

   function export_aadl_declarations
     (my_caches    : in caches_set;
      number_of_ht : in Natural) return Unbounded_String;

   ----------------------------------------------------------
   -- Procedure to proceed modification on a set
   ----------------------------------------------------------

   procedure check_cache
     (name               : in Unbounded_String;
      cache_size         : in Natural;
      line_size          : in Natural;
      associativity      : in Natural;
      block_reload_time  : in Natural;
      coherence_protocol : in cache_coherence_protocol_type;
      replacement_policy : in cache_replacement_policy_type;
      cache_category     : in cache_type);

   -- Add a single cache to the set
   --
   procedure add_cache
     (my_caches            : in out caches_set;
      a_cache              : in out generic_cache_ptr;
      name                 : in     Unbounded_String;
      cache_size           : in     Natural;
      line_size            : in     Natural;
      associativity        : in     Natural;
      block_reload_time    : in     Natural;
      coherence_protocol   : in     cache_coherence_protocol_type;
      replacement_policy   : in     cache_replacement_policy_type;
      cache_category       : in     cache_type;
      a_cache_blocks_table : in cache_blocks_table := no_cache_blocks_table);

   procedure add_cache
     (my_caches            : in out caches_set;
      name                 : in     Unbounded_String;
      cache_size           : in     Natural;
      line_size            : in     Natural;
      associativity        : in     Natural;
      block_reload_time    : in     Natural;
      coherence_protocol   : in     cache_coherence_protocol_type;
      replacement_policy   : in     cache_replacement_policy_type;
      cache_category       : in     cache_type;
      a_cache_blocks_table : in cache_blocks_table := no_cache_blocks_table);

   -- Update a cache in the set
   --
   procedure update_cache
     (my_caches          : in out caches_set;
      name               : in     Unbounded_String;
      cache_size         : in     Natural;
      line_size          : in     Natural;
      associativity      : in     Natural;
      block_reload_time  : in     Natural;
      coherence_protocol : in     cache_coherence_protocol_type;
      replacement_policy : in     cache_replacement_policy_type;
      cache_category     : in     cache_type);

   -- Delete a cache in the set
   --

   procedure delete_cache
     (my_caches : in out caches_set;
      name      : in     Unbounded_String);

   ------------------------------------------------------
   -- Read information from a set
   ------------------------------------------------------

   -- Get the cache pointer of the cache named "Name"
   --
   function search_cache
     (my_caches : in caches_set;
      name      : in Unbounded_String) return generic_cache_ptr;
   function search_cache_by_id
     (my_caches : in caches_set;
      id        : in Unbounded_String) return generic_cache_ptr;

private
   type caches_set is new generic_cache_set.set with null record;

end cache_set;
