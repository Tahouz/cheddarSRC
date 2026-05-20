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

package body cache_block_set is

   ------------------------------------------------------
   -- CACHE BLOCK
   ------------------------------------------------------
   procedure check_cache_block
     (my_cache_blocks    : in out cache_blocks_set;
      a_cache_block      : in out cache_block_ptr;
      name               : in     Unbounded_String;
      cache_block_number : in     Natural)
   is
   begin
      if (name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cache_block_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cache_block (Current_Language) &
               name &
               " : " &
               lb_cache_block_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

   end check_cache_block;

   procedure add_cache_block
     (my_cache_blocks    : in out cache_blocks_set;
      a_cache_block      : in out cache_block_ptr;
      name               : in     Unbounded_String;
      cache_block_number : in     Natural)
   is
      my_iterator : cache_blocks_iterator;
   begin
      check_initialize;

      check_cache_block
        (my_cache_blocks    => my_cache_blocks,
         a_cache_block      => a_cache_block,
         name               => name,
         cache_block_number => cache_block_number);

      if (get_number_of_elements (my_cache_blocks) > 0) then
         reset_iterator (my_cache_blocks, my_iterator);
         loop
            current_element (my_cache_blocks, a_cache_block, my_iterator);
            if (name = a_cache_block.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_cache_block (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_cache_block_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;
            exit when is_last_element (my_cache_blocks, my_iterator);
            next_element (my_cache_blocks, my_iterator);
         end loop;
      end if;

      a_cache_block                    := new cache_block;
      a_cache_block.name               := name;
      a_cache_block.cache_block_number := cache_block_number;

      add (my_cache_blocks, a_cache_block);

   exception
      when cache_block_set.full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_can_not_define_more_cache_blocks (Current_Language)));
   end add_cache_block;

   procedure add_cache_block
     (my_cache_blocks    : in out cache_blocks_set;
      name               : in     Unbounded_String;
      cache_block_number : in     Natural)
   is
      a_cache_block : cache_block_ptr;
   begin
      add_cache_block
        (my_cache_blocks    => my_cache_blocks,
         a_cache_block      => a_cache_block,
         name               => name,
         cache_block_number => cache_block_number);
   end add_cache_block;

   function search_cache_block
     (my_cache_blocks : in cache_blocks_set;
      name            : in Unbounded_String) return cache_block_ptr
   is
      my_iterator   : cache_blocks_iterator;
      a_cache_block : cache_block_ptr;
      result        : cache_block_ptr;
      found         : Boolean := False;
   begin
      reset_iterator (my_cache_blocks, my_iterator);
      loop
         current_element (my_cache_blocks, a_cache_block, my_iterator);
         if (a_cache_block.name = name) then
            found  := True;
            result := a_cache_block;
         end if;

         exit when is_last_element (my_cache_blocks, my_iterator);

         next_element (my_cache_blocks, my_iterator);
      end loop;

      if not found then
         Raise_Exception
           (cache_block_not_found'identity,
            To_String (lb_cache_block (Current_Language) & "=" & name));
      end if;

      return result;
   end search_cache_block;

   function search_cache_block_by_id
     (my_cache_blocks : in cache_blocks_set;
      id              : in Unbounded_String) return cache_block_ptr
   is
      my_iterator   : cache_blocks_iterator;
      a_cache_block : cache_block_ptr;
      result        : cache_block_ptr;
      found         : Boolean := False;
   begin
      reset_iterator (my_cache_blocks, my_iterator);
      loop
         current_element (my_cache_blocks, a_cache_block, my_iterator);
         if (a_cache_block.cheddar_private_id = id) then
            found  := True;
            result := a_cache_block;
         end if;

         exit when is_last_element (my_cache_blocks, my_iterator);

         next_element (my_cache_blocks, my_iterator);
      end loop;

      if not found then
         Raise_Exception
           (cache_block_not_found'identity,
            To_String (lb_cache_block (Current_Language) & "=" & id));
      end if;

      return result;
   end search_cache_block_by_id;

   procedure delete_cache_block
     (my_cache_blocks : in out cache_blocks_set;
      name            : in     Unbounded_String)
   is
      a_cache_block : cache_block_ptr;
   begin
      a_cache_block := search_cache_block (my_cache_blocks, name);
      delete (my_cache_blocks, a_cache_block);
   end delete_cache_block;

   procedure update_cache_block
     (my_cache_blocks    : in out cache_blocks_set;
      name               : in     Unbounded_String;
      cache_block_number : in     Natural)
   is
      a_cache_block : cache_block_ptr;
   begin
      check_cache_block
        (my_cache_blocks    => my_cache_blocks,
         a_cache_block      => a_cache_block,
         name               => name,
         cache_block_number => cache_block_number);

      a_cache_block := search_cache_block (my_cache_blocks, name);

      delete (my_cache_blocks, a_cache_block);

      add_cache_block
        (my_cache_blocks    => my_cache_blocks,
         a_cache_block      => a_cache_block,
         name               => name,
         cache_block_number => cache_block_number);
   end update_cache_block;

end cache_block_set;
