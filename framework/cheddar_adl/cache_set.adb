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

with Ada.Exceptions;       use Ada.Exceptions;
with Caches;               use Caches;
with Objects;              use Objects;
with Objects.extended;     use Objects.extended;
with Text_IO;              use Text_IO;
with translate;            use translate;
with sets;
with initialize_framework; use initialize_framework;
with Caches;               use Caches.Cache_Blocks_Table_Package;

package body cache_set is

   ------------------------------------------------------
   -- CACHE
   ------------------------------------------------------
   procedure check_cache
     (name               : in Unbounded_String;
      cache_size         : in Natural;
      line_size          : in Natural;
      associativity      : in Natural;
      block_reload_time  : in Natural;
      coherence_protocol : in cache_coherence_protocol_type;
      replacement_policy : in cache_replacement_policy_type;
      cache_category     : in cache_type)
   is
   begin
      if (name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cache_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cache (Current_Language) &
               name &
               " : " &
               lb_cache_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if cache_size < 1 then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cache (Current_Language) &
               " " &
               name &
               " : " &
               lb_cache_size (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (line_size < 1) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cache (Current_Language) &
               " " &
               name &
               " : " &
               lb_line_size (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (cache_size rem line_size /= 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cache (Current_Language) &
               " " &
               name &
               " : " &
               lb_line_size (Current_Language) &
               lb_must_be (Current_Language) &
               lb_divisible (Current_Language) &
               " " &
               lb_cache_size (Current_Language)));
      end if;

      if (associativity < 1) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cache (Current_Language) &
               " " &
               name &
               " : " &
               lb_associativity (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               To_Unbounded_String ("0")));
      end if;

      if (block_reload_time <= 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cache (Current_Language) &
               " " &
               name &
               " : " &
               lb_block_reload_time (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               To_Unbounded_String ("0")));
      end if;

   end check_cache;

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
      a_cache_blocks_table : in cache_blocks_table := no_cache_blocks_table)
   is
      my_iterator                : caches_iterator;
      new_cache_type             : cache_type;
      new_data_cache             : data_cache_ptr;
      new_instruction_cache      : instruction_cache_ptr;
      new_data_instruction_cache : data_instruction_cache_ptr;
      number_of_block            : Integer;
      a_cache_block              : cache_block_ptr;
   begin
      check_initialize;

      check_cache
        (name,
         cache_size,
         line_size,
         associativity,
         block_reload_time,
         coherence_protocol,
         replacement_policy,
         cache_category);

      if (get_number_of_elements (my_caches) > 0) then
         reset_iterator (my_caches, my_iterator);
         loop
            current_element (my_caches, a_cache, my_iterator);
            if (name = a_cache.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_cache (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_cache_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;
            exit when is_last_element (my_caches, my_iterator);
            next_element (my_caches, my_iterator);

         end loop;
      end if;

      if (cache_category = data_cache_type) then
         new_data_cache := new data_cache;
         new_cache_type := data_cache_type;
         a_cache        := generic_cache_ptr (new_data_cache);
      else
         if (cache_category = instruction_cache_type) then
            new_instruction_cache := new instruction_cache;
            new_cache_type        := instruction_cache_type;
            a_cache               := generic_cache_ptr (new_instruction_cache);
         else
            if (cache_category = data_instruction_cache_type) then
               new_data_instruction_cache := new data_instruction_cache;
               new_cache_type             := data_instruction_cache_type;
               a_cache := generic_cache_ptr (new_data_instruction_cache);
            end if;
         end if;
      end if;

      number_of_block            := cache_size / line_size;
      a_cache.name               := name;
      a_cache.cache_size         := cache_size;
      a_cache.line_size          := line_size;
      a_cache.associativity      := associativity;
      a_cache.replacement_policy := replacement_policy;
      a_cache.block_reload_time  := block_reload_time;
      a_cache.coherence_protocol := coherence_protocol;
      if (a_cache_blocks_table.nb_entries > 0) then
         a_cache.cache_blocks := a_cache_blocks_table;
      else
         for i in 0 .. number_of_block - 1 loop
            a_cache_block      := new cache_block;
            a_cache_block.name :=
              suppress_space (To_String (name & "_cb_" & i'img));
            a_cache_block.cache_block_number := Natural (i);
            add (a_cache.cache_blocks, a_cache_block);
         end loop;
      end if;

      add (my_caches, a_cache);
   exception
      when generic_cache_set.full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_caches (Current_Language)));
   end add_cache;

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
      a_cache_blocks_table : in cache_blocks_table := no_cache_blocks_table)
   is
      a_cache : generic_cache_ptr;
   begin
      add_cache
        (my_caches,
         a_cache,
         name,
         cache_size,
         line_size,
         associativity,
         block_reload_time,
         coherence_protocol,
         replacement_policy,
         cache_category,
         a_cache_blocks_table);
   end add_cache;

   procedure update_cache
     (my_caches          : in out caches_set;
      name               : in     Unbounded_String;
      cache_size         : in     Natural;
      line_size          : in     Natural;
      associativity      : in     Natural;
      block_reload_time  : in     Natural;
      coherence_protocol : in     cache_coherence_protocol_type;
      replacement_policy : in     cache_replacement_policy_type;
      cache_category     : in     cache_type)
   is
      the_cache          : generic_cache_ptr;
      a_cache_blocks_tbl : cache_blocks_table;
   begin

      check_cache
        (name,
         cache_size,
         line_size,
         associativity,
         block_reload_time,
         coherence_protocol,
         replacement_policy,
         cache_category);

      the_cache          := search_cache (my_caches, name);
      a_cache_blocks_tbl := the_cache.cache_blocks;

      delete (my_caches, the_cache);

      add_cache
        (my_caches,
         name,
         cache_size,
         line_size,
         associativity,
         block_reload_time,
         coherence_protocol,
         replacement_policy,
         cache_category,
         a_cache_blocks_tbl);

   end update_cache;

   procedure delete_cache
     (my_caches : in out caches_set;
      name      : in     Unbounded_String)
   is
      the_cache : generic_cache_ptr;
   begin
      the_cache := search_cache (my_caches, name);
      delete (my_caches, the_cache);
   end delete_cache;

   function search_cache
     (my_caches : in caches_set;
      name      : in Unbounded_String) return generic_cache_ptr
   is
      my_iterator : caches_iterator;
      a_cache     : generic_cache_ptr;
      result      : generic_cache_ptr;
      found       : Boolean := False;
   begin

      if not is_empty (my_caches) then

         reset_iterator (my_caches, my_iterator);
         loop
            current_element (my_caches, a_cache, my_iterator);
            if (a_cache.name = name) then
               found  := True;
               result := a_cache;
            end if;

            exit when is_last_element (my_caches, my_iterator);

            next_element (my_caches, my_iterator);
         end loop;

      end if;

      if not found then
         Raise_Exception
           (cache_not_found'identity,
            To_String (lb_cache_name (Current_Language) & "=" & name));
      end if;

      return result;
   end search_cache;

   function search_cache_by_id
     (my_caches : in caches_set;
      id        : in Unbounded_String) return generic_cache_ptr
   is
      my_iterator : caches_iterator;
      a_cache     : generic_cache_ptr;
      result      : generic_cache_ptr;
      found       : Boolean := False;
   begin

      if not is_empty (my_caches) then

         reset_iterator (my_caches, my_iterator);
         loop
            current_element (my_caches, a_cache, my_iterator);
            if (a_cache.cheddar_private_id = id) then
               found  := True;
               result := a_cache;
            end if;

            exit when is_last_element (my_caches, my_iterator);

            next_element (my_caches, my_iterator);
         end loop;

      end if;

      if not found then
         Raise_Exception
           (cache_not_found'identity,
            To_String (lb_cache_id (Current_Language) & "=" & id));
      end if;

      return result;
   end search_cache_by_id;

   function export_aadl_implementations
     (my_caches : in caches_set) return Unbounded_String
   is
      my_iterator : caches_iterator;
      a_cache     : generic_cache_ptr;
      result      : Unbounded_String := empty_string;
   begin
      if not is_empty (my_caches) then
         reset_iterator (my_caches, my_iterator);

         loop
            current_element (my_caches, a_cache, my_iterator);

            result :=
              result &
              To_Unbounded_String ("cache " & To_String (a_cache.name)) &
              unbounded_lf;

            result :=
              result &
              To_Unbounded_String ("end " & To_String (a_cache.name) & ";") &
              unbounded_lf &
              unbounded_lf;

            result :=
              result &
              To_Unbounded_String
                ("cache implementation " &
                 To_String (a_cache.name) &
                 ".Impl") &
              unbounded_lf;

--TODO: Add more code here when understand more about the AADL implementation

            result :=
              result &
              To_Unbounded_String
                ("end " & To_String (a_cache.name) & ".Impl;") &
              unbounded_lf &
              unbounded_lf;

            exit when is_last_element (my_caches, my_iterator);

            next_element (my_caches, my_iterator);

         end loop;
      end if;
      return result;
   end export_aadl_implementations;

   function export_aadl_declarations
     (my_caches    : in caches_set;
      number_of_ht : in Natural) return Unbounded_String
   is
      my_iterator : caches_iterator;
      a_cache     : generic_cache_ptr;
      result      : Unbounded_String := empty_string;
   begin

      if not is_empty (my_caches) then
         reset_iterator (my_caches, my_iterator);

         loop
            current_element (my_caches, a_cache, my_iterator);
            for i in 1 .. number_of_ht loop
               result := result & ASCII.HT;
            end loop;
            result :=
              result &
              To_Unbounded_String
                ("instancied_" &
                 To_String (a_cache.name) &
                 " : cache " &
                 To_String (a_cache.name) &
                 ".Impl;") &
              unbounded_lf;

            exit when is_last_element (my_caches, my_iterator);
            next_element (my_caches, my_iterator);

         end loop;
      end if;
      return result;
   end export_aadl_declarations;

end cache_set;
