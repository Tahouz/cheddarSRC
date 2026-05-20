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
with CFG_Nodes;                    use CFG_Nodes.CFG_Nodes_Table_Package;
with CFG_Nodes.extended;           use CFG_Nodes.extended;
with cfg_node_set;                 use cfg_node_set;
with integer_arrays;               use integer_arrays;
with Tasks;                        use Tasks;
with Scheduling_Analysis;          use Scheduling_Analysis;
with cfg_node_set.basic_block_set; use cfg_node_set.basic_block_set;
with basic_blocks;                 use basic_blocks;
with basic_blocks;                 use basic_blocks.basic_blocks_table_package;
with cfg_edge_set;                 use cfg_edge_set;
with CFGs;                         use CFGs;
with Caches;                       use Caches;
with task_set;                     use task_set;
with tables;
with Call_Framework_Interface;     use Call_Framework_Interface;

package basic_block_analysis is

   ------------------------------------------------------
   -- Analysis based on the algorithm in:
   -- Lee, Chang-Gun, et al.
   -- "Analysis of cache-related preemption delay in fixed-priority preemptive scheduling."
   -- Computers, IEEE Transactions on 47.6 (1998): 700-713.
   ------------------------------------------------------

   ------------------------------------------------------
   -- EXCEPTION
   ------------------------------------------------------

   --Raised when the Input Data to perform cache access profile computation is invalid
   invalid_input_data : exception;

   ------------------------------------------------------
   -- ENTRY POINT
   ------------------------------------------------------
   procedure compute_cache_access_profile
     (sys                    : in out system;
      task_name              : in     Unbounded_String;
      a_cache_access_profile :    out cache_access_profile_ptr);

   procedure compute_cache_access_profile
     (a_task_set             : in out tasks_set;
      a_task                 : in     generic_task_ptr;
      a_cache                : in     generic_cache_ptr;
      a_cfg                  : in     cfg_ptr;
      a_cache_access_profile :    out cache_access_profile_ptr);

   ------------------------------------------------------
   --
   ------------------------------------------------------
   -- Calculate the GEN Set for each basic block
   -- The Gen for calculation of RMB and LMB is calculated separately.
   -- They are named GenCBR and GenCBL, respectively.
   procedure calculate_gen
     (my_basic_blocks  : in out basic_blocks_set;
      cache_size       : in     Integer;
      cache_block_size : in     Integer);

   -- Calculate the RMB set for each basic block
   procedure calculate_rmb
     (my_basic_blocks    : in out basic_blocks_set;
      number_cache_block : in     Integer);

   -- Calculate the LMB set for each basic block
   procedure calculate_lmb
     (my_basic_blocks    : in out basic_blocks_set;
      number_cache_block : in     Integer);

   -- Do the intersection to find the number of useful blocks
   procedure intersect_usefulblocks
     (my_basic_blocks    : in out basic_blocks_set;
      number_cache_block : in     Integer);

   -- Methods that call the Calculate_GEN,Calculate_RMB,Calculate_LMB,
   -- and Intersect_UsefulBlocks.
   procedure calculate_usefulblocks
     (my_basic_blocks : in out basic_blocks_set;
      cache_size      : in     Integer;
      line_size       : in     Integer);

   --
   procedure calculate_cost_table
     (my_cfg_nodes           : in out cfg_nodes_set;
      my_cfg_edges           : in out cfg_edges_set;
      cache_blocks           : in     cache_blocks_table;
      cache_size             : in     Integer;
      line_size              : in     Integer;
      block_reload_time      : in     Integer;
      a_cache_access_profile : in out cache_access_profile_ptr;
      cost_arr               :    out integer_array);

   --
   procedure calculate_task_cache_utilization
     (my_basic_blocks         : in out basic_blocks_table;
      cache_size              : in     Integer;
      cache_block_size        : in     Integer;
      cache_utilization_array : in out integer_array);

end basic_block_analysis;
