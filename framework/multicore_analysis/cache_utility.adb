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

with Caches;         use Caches;
with Caches;         use Caches.Cache_Blocks_Table_Package;
with scheduler;      use scheduler;
with integer_arrays; use integer_arrays;

package body cache_utility is

   procedure swap_tasks_cache_location
     (a_task       : in generic_task_ptr;
      b_task       : in generic_task_ptr;
      caps         : in cache_access_profiles_set;
      cache_blocks : in cache_blocks_table;
      cs           : in Integer)
   is
      a_cap : cache_access_profile_ptr;
      b_cap : cache_access_profile_ptr;

      a_start_set, a_end_set : Integer := 0;
      b_start_set, b_end_set : Integer := 0;

      a_ucb_counter : Integer := 0;
      b_ucb_counter : Integer := 0;

      a_nb_ucb : Integer := 0;
      b_nb_ucb : Integer := 0;

      a_nb_ecb : Integer := 0;
      b_nb_ecb : Integer := 0;
   begin

      a_cap :=
        search_cache_access_profile (caps, a_task.cache_access_profile_name);
      b_cap :=
        search_cache_access_profile (caps, b_task.cache_access_profile_name);

      -- Swap Here
      a_start_set := b_cap.ECBs.entries (0).cache_block_number;
      b_start_set := a_cap.ECBs.entries (0).cache_block_number;

      a_end_set := (a_start_set + Integer (a_cap.ECBs.nb_entries)) mod cs;
      b_end_set := (b_start_set + Integer (b_cap.ECBs.nb_entries)) mod cs;

      a_nb_ucb := Integer (a_cap.UCBs.nb_entries);
      b_nb_ucb := Integer (b_cap.UCBs.nb_entries);

      a_nb_ecb := Integer (a_cap.ECBs.nb_entries);
      b_nb_ecb := Integer (b_cap.ECBs.nb_entries);

      a_ucb_counter := 0;
      b_ucb_counter := 0;

      -----------------------------------
      -- Regenerate the UCBs and ECBs of task A
      -----------------------------------

      initialize (a_cap.UCBs);
      initialize (a_cap.ECBs);

      if (a_start_set < a_end_set and a_nb_ecb < cs) then
         for j in a_start_set .. a_end_set - 1 loop
            add (a_cap.ECBs, cache_blocks.entries (cache_blocks_range (j)));
            if (a_ucb_counter < a_nb_ucb) then
               add (a_cap.UCBs, cache_blocks.entries (cache_blocks_range (j)));
               a_ucb_counter := a_ucb_counter + 1;
            end if;
         end loop;
      end if;

      if (a_start_set > a_end_set and a_nb_ecb < cs) then
         for j in a_start_set .. cs - 1 loop
            add (a_cap.ECBs, cache_blocks.entries (cache_blocks_range (j)));
            if (a_ucb_counter < a_nb_ucb) then
               add (a_cap.UCBs, cache_blocks.entries (cache_blocks_range (j)));
               a_ucb_counter := a_ucb_counter + 1;
            end if;
         end loop;
         for j in 0 .. a_end_set - 1 loop
            add (a_cap.ECBs, cache_blocks.entries (cache_blocks_range (j)));
            if (a_ucb_counter < a_nb_ucb) then
               add (a_cap.UCBs, cache_blocks.entries (cache_blocks_range (j)));
               a_ucb_counter := a_ucb_counter + 1;
            end if;
         end loop;
      end if;

      if (a_nb_ecb >= cs) then
         for j in a_start_set .. cs - 1 loop
            add (a_cap.ECBs, cache_blocks.entries (cache_blocks_range (j)));
            if (a_ucb_counter < a_nb_ucb) then
               add (a_cap.UCBs, cache_blocks.entries (cache_blocks_range (j)));
               a_ucb_counter := a_ucb_counter + 1;
            end if;
         end loop;
         for j in 0 .. a_start_set - 1 loop
            add (a_cap.ECBs, cache_blocks.entries (cache_blocks_range (j)));
            if (a_ucb_counter < a_nb_ucb) then
               add (a_cap.UCBs, cache_blocks.entries (cache_blocks_range (j)));
               a_ucb_counter := a_ucb_counter + 1;
            end if;
         end loop;
      end if;

      -----------------------------------
      -- Regenerate the UCBs and ECBs of task B
      -----------------------------------
      initialize (b_cap.UCBs);
      initialize (b_cap.ECBs);

      if (b_start_set < b_end_set and b_nb_ecb < cs) then
         for j in b_start_set .. b_end_set - 1 loop
            add (b_cap.ECBs, cache_blocks.entries (cache_blocks_range (j)));
            if (b_ucb_counter < b_nb_ucb) then
               add (b_cap.UCBs, cache_blocks.entries (cache_blocks_range (j)));
               b_ucb_counter := b_ucb_counter + 1;
            end if;
         end loop;
      end if;

      if (b_start_set > b_end_set and b_nb_ecb < cs) then
         for j in b_start_set .. cs - 1 loop
            add (b_cap.ECBs, cache_blocks.entries (cache_blocks_range (j)));
            if (b_ucb_counter < b_nb_ucb) then
               add (b_cap.UCBs, cache_blocks.entries (cache_blocks_range (j)));
               b_ucb_counter := b_ucb_counter + 1;
            end if;
         end loop;
         for j in 0 .. b_end_set - 1 loop
            add (b_cap.ECBs, cache_blocks.entries (cache_blocks_range (j)));
            if (b_ucb_counter < b_nb_ucb) then
               add (b_cap.UCBs, cache_blocks.entries (cache_blocks_range (j)));
               b_ucb_counter := b_ucb_counter + 1;
            end if;
         end loop;
      end if;

      if (b_nb_ecb >= cs) then
         for j in b_start_set .. cs - 1 loop
            add (b_cap.ECBs, cache_blocks.entries (cache_blocks_range (j)));
            if (b_ucb_counter < b_nb_ucb) then
               add (b_cap.UCBs, cache_blocks.entries (cache_blocks_range (j)));
               b_ucb_counter := b_ucb_counter + 1;
            end if;
         end loop;
         for j in 0 .. b_start_set - 1 loop
            add (b_cap.ECBs, cache_blocks.entries (cache_blocks_range (j)));
            if (b_ucb_counter < b_nb_ucb) then
               add (b_cap.UCBs, cache_blocks.entries (cache_blocks_range (j)));
               b_ucb_counter := b_ucb_counter + 1;
            end if;
         end loop;
      end if;

   end swap_tasks_cache_location;

   procedure fill_tasks_ucbs_in_cache (a_tcb : in out tcb_ptr) is
   begin
      free (a_tcb.ucbs_in_cache.elements);
      initialize (a_tcb.ucbs_in_cache);
      for i in 0 .. a_tcb.ucbs.size - 1 loop
         add (a_tcb.ucbs_in_cache, a_tcb.ucbs.elements (i));
      end loop;
   end fill_tasks_ucbs_in_cache;

   function compute_crpd (a_tcb : in tcb_ptr) return Integer is
      ucb_rc : Integer := 0;
   begin
      ucb_rc := a_tcb.ucbs.size - a_tcb.ucbs_in_cache.size;
      return ucb_rc;
   end compute_crpd;

end cache_utility;
