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

with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Integer_Text_IO;          use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;
with systems;                      use systems;
with CFG_Nodes;                    use CFG_Nodes;
with basic_blocks;                 use basic_blocks;
with CFG_Nodes;                    use CFG_Nodes.CFG_Nodes_Table_Package;
with CFG_Nodes.extended;           use CFG_Nodes.extended;
with cfg_node_set;                 use cfg_node_set;
with cfg_node_set.basic_block_set; use cfg_node_set.basic_block_set;
with integer_arrays;               use integer_arrays;
with Tasks;                        use Tasks;
with Scheduling_Analysis;          use Scheduling_Analysis;
with cfg_edge_set;                 use cfg_edge_set;
with CFGs;                         use CFGs;
with cfg_edges;                    use cfg_edges;
with cfg_edges;                    use cfg_edges.cfg_edges_table_package;
with Caches;                       use Caches;
with Caches;                       use Caches.Cache_Blocks_Table_Package;
with cache_block_set;              use cache_block_set;
with cache_access_profile_set;     use cache_access_profile_set;
with Ada.Exceptions;               use Ada.Exceptions;
with translate;                    use translate;
with Framework_Config;             use Framework_Config;
with Core_Units;                   use Core_Units;
with Processors;                   use Processors;
with task_set;                     use task_set;
with cfg_set;                      use cfg_set;
with processor_set;                use processor_set;
with Processor_Interface;          use Processor_Interface;
with cache_set;                    use cache_set;
with unbounded_strings;            use unbounded_strings;
with Call_Framework_Interface;     use Call_Framework_Interface;
with tables;
with sets;

package body basic_block_analysis is

   ------------------------------------------------------
   -- Procedure for analysis based on the algorithm in:
   -- Lee, Chang-Gun, et al.
   -- "Analysis of cache-related preemption delay in fixed-priority preemptive scheduling."
   -- IEEE Transactions on Computers 47.6 (1998): 700-713.
   ------------------------------------------------------

   procedure calculate_gen
     (my_basic_blocks    : in out basic_blocks_set;
      number_cache_block : in     Integer)
   is
      my_iterator     : basic_blocks_iterator;
      a_basic_block   : basic_block_ptr;
      ucb_basic_block : basic_block_ucb_ptr;
      cache_position  : Integer;
   begin
      reset_iterator (my_basic_blocks, my_iterator);
      loop
         current_element (my_basic_blocks, a_basic_block, my_iterator);
         ucb_basic_block := basic_block_ucb_ptr (a_basic_block);

         for i in 0 .. number_cache_block - 1 loop
            ucb_basic_block.gencbr.elements (i) := -1;
            ucb_basic_block.gencbl.elements (i) := -1;
         end loop;
         exit when is_last_element (my_basic_blocks, my_iterator);
         next_element (my_basic_blocks, my_iterator);
      end loop;

      reset_iterator (my_basic_blocks, my_iterator);
      loop
         current_element (my_basic_blocks, a_basic_block, my_iterator);
         for i in 0 .. ucb_basic_block.instruction_capacity - 1 loop
            cache_position :=
              (ucb_basic_block.instruction_offset + i) mod number_cache_block;
            ucb_basic_block.gencbr.elements (cache_position) :=
              ucb_basic_block.instruction_offset + i;
            if (ucb_basic_block.gencbl.elements (cache_position) = -1) then
               ucb_basic_block.gencbl.elements (cache_position) :=
                 ucb_basic_block.instruction_offset + i;
            end if;
         end loop;
         exit when is_last_element (my_basic_blocks, my_iterator);
         next_element (my_basic_blocks, my_iterator);
      end loop;
   end calculate_gen;

   procedure calculate_gen
     (my_basic_blocks  : in out basic_blocks_set;
      cache_size       : in     Integer;
      cache_block_size : in     Integer)
   is
      my_iterator     : basic_blocks_iterator;
      a_basic_block   : basic_block_ptr;
      ucb_basic_block : basic_block_ucb_ptr;

      memory_address           : Integer;
      memory_block_number      : Integer;
      memory_block_number_used : Integer;

      number_cache_block : Integer := cache_size / cache_block_size;

      first_cache_block : Integer;
      last_cache_block  : Integer;

      function get_cache_address
        (memory_address     : in Integer;
         number_cache_block : in Integer;
         cache_block_size   : in Integer) return Integer
      is
      begin
         return (memory_address / cache_block_size) mod number_cache_block;
      end get_cache_address;

      function get_memory_block_number
        (memory_address   : in Integer;
         cache_block_size : in Integer) return Integer
      is
      begin
         return (memory_address / cache_block_size);
      end get_memory_block_number;

   begin
      --Initilization
      reset_iterator (my_basic_blocks, my_iterator);
      loop
         current_element (my_basic_blocks, a_basic_block, my_iterator);
         ucb_basic_block := basic_block_ucb_ptr (a_basic_block);

         for i in 0 .. number_cache_block - 1 loop
            ucb_basic_block.gencbr.elements (i) := -1;
            ucb_basic_block.gencbl.elements (i) := -1;
         end loop;
         exit when is_last_element (my_basic_blocks, my_iterator);
         next_element (my_basic_blocks, my_iterator);
      end loop;

      --Calculation
      reset_iterator (my_basic_blocks, my_iterator);
      loop
         current_element (my_basic_blocks, a_basic_block, my_iterator);
         ucb_basic_block := basic_block_ucb_ptr (a_basic_block);

         first_cache_block :=
           get_cache_address
             (ucb_basic_block.instruction_offset,
              number_cache_block,
              cache_block_size);

         last_cache_block :=
           get_cache_address
             (ucb_basic_block.instruction_offset +
              ucb_basic_block.instruction_capacity -
              1,
              number_cache_block,
              cache_block_size);

         memory_block_number_used :=
           get_memory_block_number
             (ucb_basic_block.instruction_offset +
              ucb_basic_block.instruction_capacity,
              cache_block_size) -
           get_memory_block_number
             (ucb_basic_block.instruction_offset,
              cache_block_size);

         --Gen CBL - First Gen
         for cache_block in 0 .. number_cache_block - 1 loop
            --1
            if
              (cache_block >= first_cache_block and
               cache_block <= last_cache_block)
            then

               memory_address :=
                 ucb_basic_block.instruction_offset +
                 (cache_block - first_cache_block) * cache_block_size;

               memory_block_number :=
                 get_memory_block_number (memory_address, cache_block_size);
               ucb_basic_block.gencbl.elements (cache_block) :=
                 memory_block_number;
            end if;

            --2
            if
              (last_cache_block >= first_cache_block and
               cache_block > last_cache_block and
               memory_block_number_used >= number_cache_block)
            then

               memory_address :=
                 ucb_basic_block.instruction_offset +
                 (cache_block - first_cache_block) * cache_block_size;
               memory_block_number :=
                 get_memory_block_number (memory_address, cache_block_size);

               basic_block_ucb_ptr (a_basic_block).gencbl.elements
                 (cache_block) :=
                 memory_block_number;
            end if;

            --3
            if
              (last_cache_block >= first_cache_block and
               cache_block < first_cache_block and
               memory_block_number_used >= number_cache_block)
            then

               memory_address :=
                 ucb_basic_block.instruction_offset +
                 (cache_block + number_cache_block + first_cache_block) *
                   cache_block_size;
               memory_block_number :=
                 get_memory_block_number (memory_address, cache_block_size);

               basic_block_ucb_ptr (a_basic_block).gencbl.elements
                 (cache_block) :=
                 memory_block_number;
            end if;

            --4
            if
              (first_cache_block > last_cache_block and
               cache_block <= last_cache_block)
            then

               memory_address :=
                 ucb_basic_block.instruction_offset +
                 (cache_block + (number_cache_block - first_cache_block)) *
                   cache_block_size;
               memory_block_number :=
                 get_memory_block_number (memory_address, cache_block_size);

               basic_block_ucb_ptr (a_basic_block).gencbl.elements
                 (cache_block) :=
                 memory_block_number;
            end if;

            --5
            if
              (first_cache_block > last_cache_block and
               cache_block >= first_cache_block)
            then

               memory_address :=
                 ucb_basic_block.instruction_offset +
                 (cache_block - first_cache_block) * cache_block_size;
               memory_block_number :=
                 get_memory_block_number (memory_address, cache_block_size);

               basic_block_ucb_ptr (a_basic_block).gencbl.elements
                 (cache_block) :=
                 memory_block_number;

            end if;

            --6
            if
              (first_cache_block > last_cache_block and
               cache_block < first_cache_block and
               cache_block > last_cache_block and
               memory_block_number_used >= number_cache_block)
            then

               memory_address :=
                 ucb_basic_block.instruction_offset +
                 (cache_block + number_cache_block - first_cache_block) *
                   cache_block_size;
               memory_block_number :=
                 get_memory_block_number (memory_address, cache_block_size);

               basic_block_ucb_ptr (a_basic_block).gencbl.elements
                 (cache_block) :=
                 memory_block_number;

            end if;

         end loop;

         --Gen CBR - Last Gen
         for cache_block in 0 .. number_cache_block - 1 loop
            --1
            if
              (cache_block >= first_cache_block and
               cache_block <= last_cache_block)
            then

               memory_address :=
                 ucb_basic_block.instruction_offset +
                 ucb_basic_block.instruction_capacity -
                 1 -
                 (last_cache_block - cache_block) * cache_block_size;

               memory_block_number :=
                 get_memory_block_number (memory_address, cache_block_size);
               ucb_basic_block.gencbr.elements (cache_block) :=
                 memory_block_number;
            end if;

            --2
            if
              (last_cache_block >= first_cache_block and
               cache_block > last_cache_block and
               memory_block_number_used >= number_cache_block)
            then

               memory_address :=
                 ucb_basic_block.instruction_offset +
                 ucb_basic_block.instruction_capacity -
                 1 -
                 (last_cache_block + number_cache_block - cache_block) *
                   cache_block_size;

               memory_block_number :=
                 get_memory_block_number (memory_address, cache_block_size);
               ucb_basic_block.gencbr.elements (cache_block) :=
                 memory_block_number;

            end if;

            --3
            if
              (last_cache_block >= first_cache_block and
               cache_block < first_cache_block and
               memory_block_number_used >= number_cache_block)
            then

               memory_address :=
                 ucb_basic_block.instruction_offset +
                 ucb_basic_block.instruction_capacity -
                 1 -
                 (last_cache_block - cache_block) * cache_block_size;

               memory_block_number :=
                 get_memory_block_number (memory_address, cache_block_size);
               ucb_basic_block.gencbr.elements (cache_block) :=
                 memory_block_number;

            end if;

            --4
            if
              (first_cache_block > last_cache_block and
               cache_block <= last_cache_block)
            then

               memory_address :=
                 ucb_basic_block.instruction_offset +
                 ucb_basic_block.instruction_capacity -
                 1 -
                 (last_cache_block - cache_block) * cache_block_size;

               memory_block_number :=
                 get_memory_block_number (memory_address, cache_block_size);
               ucb_basic_block.gencbr.elements (cache_block) :=
                 memory_block_number;

            end if;

            --5
            if
              (first_cache_block > last_cache_block and
               cache_block >= first_cache_block)
            then

               memory_address :=
                 ucb_basic_block.instruction_offset +
                 ucb_basic_block.instruction_capacity -
                 1 -
                 (last_cache_block + number_cache_block - cache_block) *
                   cache_block_size;

               memory_block_number :=
                 get_memory_block_number (memory_address, cache_block_size);
               ucb_basic_block.gencbr.elements (cache_block) :=
                 memory_block_number;

            end if;

            --6
            if
              (first_cache_block > last_cache_block and
               cache_block < first_cache_block and
               cache_block > last_cache_block and
               memory_block_number_used >= number_cache_block)
            then

               memory_address :=
                 ucb_basic_block.instruction_offset +
                 ucb_basic_block.instruction_capacity -
                 1 -
                 (last_cache_block + number_cache_block - cache_block) *
                   cache_block_size;

               memory_block_number :=
                 get_memory_block_number (memory_address, cache_block_size);
               ucb_basic_block.gencbr.elements (cache_block) :=
                 memory_block_number;

            end if;

         end loop;

         exit when is_last_element (my_basic_blocks, my_iterator);
         next_element (my_basic_blocks, my_iterator);
      end loop;

   end calculate_gen;

   procedure calculate_rmb
     (my_basic_blocks    : in out basic_blocks_set;
      number_cache_block : in     Integer)
   is
      my_iterator   : basic_blocks_iterator;
      a_basic_block : basic_block_ptr;
      oldout        : integer_array;
      change        : Boolean := True;
   begin

      reset_iterator (my_basic_blocks, my_iterator);
      loop
         current_element (my_basic_blocks, a_basic_block, my_iterator);

         for i in 0 .. number_cache_block - 1 loop
            integer_arrays.add
              (arr     => basic_block_ucb_ptr (a_basic_block).rmbout (i),
               element =>
                 basic_block_ucb_ptr (a_basic_block).gencbr.elements (i));
         end loop;
         exit when is_last_element (my_basic_blocks, my_iterator);
         next_element (my_basic_blocks, my_iterator);
      end loop;

      --Calculation
      change := True;

      while change loop
         change := False;
         reset_iterator (my_basic_blocks, my_iterator);
         loop
            current_element (my_basic_blocks, a_basic_block, my_iterator);

            for i in 0 .. number_cache_block - 1 loop
               --                 Put_Line("===Cache Block: " & i'Img);
               for j in
                 0 ..
                     basic_block_ucb_ptr (a_basic_block).previous_nodes
                       .nb_entries -
                     1
               loop
                  --                    Put_Line("Basic block: " & To_String(a_basic_block.name & "(" & i'Img & ")")
                  --                             & " - Prev(" & j'Img & ")"
                  --                             & " : " & To_String(Basic_Block_UCB_Ptr(a_basic_block).previous_nodes.Entries(j).name));
   --                    Print(Basic_Block_UCB_Ptr (a_basic_block).RMBOut(i));

                  integer_arrays.union
                    (arr_a => basic_block_ucb_ptr (a_basic_block).rmbin (i),
                     arr_b =>
                       basic_block_ucb_ptr
                         (basic_block_ucb_ptr (a_basic_block).previous_nodes
                            .entries
                            (j))
                         .rmbout
                         (i));
               end loop;
               -- Put_Line("===========U-Complete");

               oldout := basic_block_ucb_ptr (a_basic_block).rmbout (i);
               --TODO: Revise why we have this assignment
               --
               if
                 (basic_block_ucb_ptr (a_basic_block).gencbr.elements (i) = -1)
               then
                  --Put_Line("-Assign RMBOut-RMBIn");
                  basic_block_ucb_ptr (a_basic_block).rmbout (i) :=
                    basic_block_ucb_ptr (a_basic_block).rmbin (i);
               end if;

               if
                 (basic_block_ucb_ptr (a_basic_block).rmbout (i) /= oldout)
               then
                  change := True;
               end if;
            end loop;

            exit when is_last_element (my_basic_blocks, my_iterator);
            next_element (my_basic_blocks, my_iterator);
         end loop;
      end loop;

   end calculate_rmb;

   procedure calculate_lmb
     (my_basic_blocks    : in out basic_blocks_set;
      number_cache_block : in     Integer)
   is
      my_iterator   : basic_blocks_iterator;
      a_basic_block : basic_block_ptr;
      oldin         : integer_array;
      change        : Boolean := True;
   begin
      --LMB
      --Initilization
      reset_iterator (my_basic_blocks, my_iterator);
      loop
         current_element (my_basic_blocks, a_basic_block, my_iterator);
         for i in 0 .. number_cache_block - 1 loop
            integer_arrays.add
              (arr     => basic_block_ucb_ptr (a_basic_block).lmbin (i),
               element =>
                 basic_block_ucb_ptr (a_basic_block).gencbl.elements (i));
         end loop;
         exit when is_last_element (my_basic_blocks, my_iterator);
         next_element (my_basic_blocks, my_iterator);
      end loop;

      --Calculation
      change := True;
      while change loop
         change := False;
         reset_tail_iterator (my_basic_blocks, my_iterator);
         loop
            current_element (my_basic_blocks, a_basic_block, my_iterator);

            for i in 0 .. number_cache_block - 1 loop
               for j in
                 0 ..
                     basic_block_ucb_ptr (a_basic_block).next_nodes
                       .nb_entries -
                     1
               loop
                  integer_arrays.union
                    (arr_a => basic_block_ucb_ptr (a_basic_block).lmbout (i),
                     arr_b =>
                       basic_block_ucb_ptr
                         (basic_block_ucb_ptr (a_basic_block).next_nodes
                            .entries
                            (j))
                         .lmbin
                         (i));
               end loop;

               oldin := basic_block_ucb_ptr (a_basic_block).lmbin (i);

               if
                 (basic_block_ucb_ptr (a_basic_block).gencbl.elements (i) = -1)
               then
                  basic_block_ucb_ptr (a_basic_block).lmbin (i) :=
                    basic_block_ucb_ptr (a_basic_block).lmbout (i);
               end if;

               if (basic_block_ucb_ptr (a_basic_block).lmbin (i) /= oldin) then
                  change := True;
               end if;

            end loop;

            exit when is_first_element (my_basic_blocks, my_iterator);
            previous_element (my_basic_blocks, my_iterator);
         end loop;
      end loop;
   end calculate_lmb;

   procedure intersect_usefulblocks
     (my_basic_blocks    : in out basic_blocks_set;
      number_cache_block : in     Integer)
   is
      my_iterator   : basic_blocks_iterator;
      a_basic_block : basic_block_ptr;
      arr_c         : integer_array;
      arr_mem       : integer_array;
      n             : Integer;
   begin
      reset_iterator (my_basic_blocks, my_iterator);
      loop
         arr_mem.size     := 0;
         arr_mem.elements := new integer_arr (0 .. 0);
         current_element (my_basic_blocks, a_basic_block, my_iterator);

         for j in
           0 .. basic_block_ucb_ptr (a_basic_block).next_nodes.nb_entries - 1
         loop

            for i in 0 .. number_cache_block - 1 loop
               integer_arrays.intersect
                 (arr_a => basic_block_ucb_ptr (a_basic_block).rmbout (i),
                  arr_b =>
                    basic_block_ucb_ptr
                      (basic_block_ucb_ptr (a_basic_block).next_nodes.entries
                         (j))
                      .lmbin
                      (i),
                  arr_c => arr_c,
                  n     => n);
               if (arr_c.size > 0) then
                  add (basic_block_ucb_ptr (a_basic_block).ucbs, True, i);
               end if;
            end loop;
         end loop;

         basic_block_ucb_ptr (a_basic_block).numberofusefulblock :=
           basic_block_ucb_ptr (a_basic_block).ucbs.size;

         exit when is_last_element (my_basic_blocks, my_iterator);
         next_element (my_basic_blocks, my_iterator);
      end loop;

   end intersect_usefulblocks;

   procedure calculate_usefulblocks
     (my_basic_blocks : in out basic_blocks_set;
      cache_size      : in     Integer;
      line_size       : in     Integer)
   is
      number_cache_block : Integer := cache_size / line_size;
   begin
      calculate_gen
        (my_basic_blocks  => my_basic_blocks,
         cache_size       => cache_size,
         cache_block_size => line_size);

      calculate_rmb
        (my_basic_blocks    => my_basic_blocks,
         number_cache_block => number_cache_block);

      calculate_lmb
        (my_basic_blocks    => my_basic_blocks,
         number_cache_block => number_cache_block);

      intersect_usefulblocks
        (my_basic_blocks    => my_basic_blocks,
         number_cache_block => number_cache_block);

   end calculate_usefulblocks;

   procedure calculate_cost_table
     (my_cfg_nodes           : in out cfg_nodes_set;
      my_cfg_edges           : in out cfg_edges_set;
      cache_blocks           : in     cache_blocks_table;
      cache_size             : in     Integer;
      line_size              : in     Integer;
      block_reload_time      : in     Integer;
      a_cache_access_profile : in out cache_access_profile_ptr;
      cost_arr               :    out integer_array)
   is
      my_iterator     : basic_blocks_iterator;
      a_basic_block   : basic_block_ptr;
      my_basic_blocks : basic_blocks_set;

      max_n_ucb : Integer := 0;

      my_cfg_node     : cfg_node_ptr;
      my_iterator_cfg : cfg_nodes_iterator;

      ucbs : integer_array;
      ecbs : integer_array;

   begin
      cost_arr.size     := 0;
      cost_arr.elements := new integer_arr (0 .. 0);

      --CONVERT CFG_Nodes_Set to Basic_Blocks_Set
      reset_iterator (my_cfg_nodes, my_iterator_cfg);
      loop
         current_element (my_cfg_nodes, my_cfg_node, my_iterator_cfg);

         add (my_basic_blocks, basic_block_ptr (my_cfg_node));

         exit when is_last_element (my_cfg_nodes, my_iterator_cfg);
         next_element (my_cfg_nodes, my_iterator_cfg);
      end loop;

      --CONVERT Basic_Blocks_Set to set of Basic_Blocks_UCB with information of previous_nodes, next_nodes.
      convert_to_basic_block_ucb_set
        (my_basic_blocks => my_basic_blocks,
         my_cfg_edges    => my_cfg_edges,
         size            => cache_size / line_size);

      calculate_usefulblocks (my_basic_blocks, cache_size, line_size);

      --COMPUTE Cost Table
      reset_iterator (my_basic_blocks, my_iterator);
      loop
         current_element (my_basic_blocks, a_basic_block, my_iterator);
         if (basic_block_ucb_ptr (a_basic_block).numberofusefulblock > 0) then
            integer_arrays.add
              (arr     => cost_arr,
               element =>
                 (basic_block_ucb_ptr (a_basic_block).numberofusefulblock) *
                 block_reload_time);
         end if;

         exit when is_last_element (my_basic_blocks, my_iterator);
         next_element (my_basic_blocks, my_iterator);
      end loop;

      --COMPUTE Cache Access Profile
      initialize (ucbs);
      initialize (ecbs);

      reset_iterator (my_basic_blocks, my_iterator);
      loop
         current_element (my_basic_blocks, a_basic_block, my_iterator);

         for i in 0 .. basic_block_ucb_ptr (a_basic_block).gencbr.size - 1 loop
            if
              (basic_block_ucb_ptr (a_basic_block).gencbr.elements (i) >= 0)
            then
               add (ecbs, True, i);
            end if;
         end loop;

         if
           (basic_block_ucb_ptr (a_basic_block).numberofusefulblock >
            max_n_ucb)
         then
            max_n_ucb :=
              basic_block_ucb_ptr (a_basic_block).numberofusefulblock;
            ucbs := basic_block_ucb_ptr (a_basic_block).ucbs;
         end if;

         exit when is_last_element (my_basic_blocks, my_iterator);
         next_element (my_basic_blocks, my_iterator);
      end loop;

      for i in 0 .. ucbs.size - 1 loop
         add
           (a_cache_access_profile.UCBs,
            cache_blocks.entries
              (Caches.cache_blocks_range (ucbs.elements (i))));
      end loop;
      for i in 0 .. ecbs.size - 1 loop
         add
           (a_cache_access_profile.ECBs,
            cache_blocks.entries
              (Caches.cache_blocks_range (ecbs.elements (i))));
      end loop;

      sort_desc (arr_a => cost_arr);

      reset_iterator (my_basic_blocks, my_iterator);
      loop
         current_element (my_basic_blocks, a_basic_block, my_iterator);
         if (basic_block_ucb_ptr (a_basic_block).numberofusefulblock > 0) then
            basic_block_ucb_ptr (a_basic_block).numberofusefulblock := 0;
         end if;
         exit when is_last_element (my_basic_blocks, my_iterator);
         next_element (my_basic_blocks, my_iterator);
      end loop;

   end calculate_cost_table;

   procedure calculate_task_cache_utilization
     (my_basic_blocks         : in out basic_blocks_table;
      cache_size              : in     Integer;
      cache_block_size        : in     Integer;
      cache_utilization_array : in out integer_array)
   is
      function get_cache_address
        (memory_address     : in Integer;
         number_cache_block : in Integer;
         cache_block_size   : in Integer) return Integer
      is
      begin
         return (memory_address / cache_block_size) mod number_cache_block;
      end get_cache_address;

      task_instruction_capacity : Integer := 0;
      task_instruction_offset   : Integer := 0;
      start_addr                : Integer;
      end_addr                  : Integer;
      number_cache_block        : Integer;

   begin

      for i in 0 .. my_basic_blocks.nb_entries - 1 loop
         task_instruction_capacity :=
           task_instruction_capacity +
           my_basic_blocks.entries (i).instruction_capacity;
      end loop;
      task_instruction_offset :=
        my_basic_blocks.entries (0).instruction_offset;

      number_cache_block := cache_size / cache_block_size;

      start_addr :=
        get_cache_address
          (task_instruction_offset,
           number_cache_block,
           cache_block_size);
      end_addr :=
        get_cache_address
          (task_instruction_offset + task_instruction_capacity,
           number_cache_block,
           cache_block_size);

      if (task_instruction_capacity > cache_size) then
         for i in 0 .. number_cache_block loop
            add (cache_utilization_array, i);
         end loop;
      end if;

      if
        (start_addr < end_addr and task_instruction_capacity < cache_size)
      then
         for i in start_addr .. end_addr loop
            add (cache_utilization_array, i);
         end loop;
      end if;

      if
        (start_addr > end_addr and task_instruction_capacity < cache_size)
      then
         for i in 0 .. end_addr loop
            add (cache_utilization_array, i);
         end loop;
         for i in start_addr .. number_cache_block loop
            add (cache_utilization_array, i);
         end loop;
      end if;

   end calculate_task_cache_utilization;

   procedure check_input_data
     (a_cfg   : in cfg_ptr;
      a_cache : in generic_cache_ptr)
   is
   begin
      if (a_cfg.nodes.nb_entries <= 0) then
         Raise_Exception
           (invalid_input_data'identity,
            To_String
              (lb_cfg (Current_Language) &
               a_cfg.name &
               lb_can_not_be_empty (Current_Language)));
      end if;

      if (a_cfg.nodes.nb_entries <= 0) then
         Raise_Exception
           (invalid_input_data'identity,
            To_String
              (lb_cfg (Current_Language) &
               a_cfg.name &
               lb_can_not_be_empty (Current_Language)));
      end if;

      if (a_cache.cache_blocks.nb_entries <= 0) then
         Raise_Exception
           (invalid_input_data'identity,
            To_String
              (lb_cache (Current_Language) &
               a_cache.name &
               lb_can_not_be_empty (Current_Language)));
      end if;

   end check_input_data;

   procedure compute_cache_access_profile
     (sys                    : in out system;
      task_name              : in     Unbounded_String;
      a_cache_access_profile :    out cache_access_profile_ptr)
   is
      my_cache     : generic_cache_ptr;
      my_core      : core_unit_ptr;
      my_processor : generic_processor_ptr;
      my_task      : generic_task_ptr;
      my_cfg       : cfg_ptr;
   begin
      -- Get the objects with corresponding names
      my_task      := search_task (sys.tasks, task_name);
      my_processor := search_processor (sys.processors, my_task.cpu_name);

      if my_processor.processor_type /= monocore_type then
         Raise_Exception
           (invalid_input_data'identity,
            To_String
              (lb_processor (Current_Language) &
               my_processor.name &
               lb_must_be (Current_Language) &
               "Monocore Processor"));
      end if;

      my_core  := mono_core_processor_ptr (my_processor).core;
      my_cache := search_cache (sys.caches, my_core.l1_cache_system_name);
      my_cfg   := search_cfg (sys.cfgs, my_task.cfg_name);

      check_input_data (my_cfg, my_cache);

      compute_cache_access_profile
        (a_task_set             => sys.tasks,
         a_task                 => my_task,
         a_cache                => my_cache,
         a_cfg                  => my_cfg,
         a_cache_access_profile => a_cache_access_profile);

      add (sys.cache_access_profiles, a_cache_access_profile);

   end compute_cache_access_profile;

   procedure compute_cache_access_profile
     (a_task_set             : in out tasks_set;
      a_task                 : in     generic_task_ptr;
      a_cache                : in     generic_cache_ptr;
      a_cfg                  : in     cfg_ptr;
      a_cache_access_profile :    out cache_access_profile_ptr)
   is
      my_cfg_nodes    : cfg_nodes_set;
      my_cfg_edges    : cfg_edges_set;
      my_iterator_cfg : cfg_nodes_iterator;
      cost_arr        : integer_array;
      my_cfg_node     : cfg_node_ptr;
   begin
      --
      for i in 0 .. a_cfg.nodes.nb_entries - 1 loop
         add
           (my_cfg_nodes,
            cfg_node_ptr (copy (basic_block_ptr (a_cfg.nodes.entries (i)))));
      end loop;
      for i in 0 .. a_cfg.edges.nb_entries - 1 loop
         add (my_cfg_edges, copy (a_cfg.edges.entries (i)));
      end loop;

      --Update the instruction_offset of the basic block according to the
      --task's position in the memory.
      if a_task.text_memory_start_address > 0 then
         reset_iterator (my_cfg_nodes, my_iterator_cfg);
         loop
            current_element (my_cfg_nodes, my_cfg_node, my_iterator_cfg);

            basic_block_ptr (my_cfg_node).instruction_offset :=
              basic_block_ptr (my_cfg_node).instruction_offset +
              a_task.text_memory_start_address;

            exit when is_last_element (my_cfg_nodes, my_iterator_cfg);
            next_element (my_cfg_nodes, my_iterator_cfg);
         end loop;
      end if;

      a_cache_access_profile      := new cache_access_profile;
      a_cache_access_profile.name := a_task.name & "_cap";

      calculate_cost_table
        (my_cfg_nodes           => my_cfg_nodes,
         my_cfg_edges           => my_cfg_edges,
         cache_blocks           => a_cache.cache_blocks,
         cache_size             => a_cache.cache_size,
         line_size              => a_cache.line_size,
         block_reload_time      => Integer (a_cache.block_reload_time),
         a_cache_access_profile => a_cache_access_profile,
         cost_arr               => cost_arr);

      -----------------------------------------------------
      -- Add(Sys.Cache_Access_Profiles,a_cache_access_profile);
      a_task.cache_access_profile_name := a_cache_access_profile.name;
      -----------------------------------------------------

   end compute_cache_access_profile;

end basic_block_analysis;
