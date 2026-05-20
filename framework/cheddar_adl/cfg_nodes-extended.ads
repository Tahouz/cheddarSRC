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

with CFG_Nodes;           use CFG_Nodes;
with basic_blocks;        use basic_blocks;
with integer_arrays;      use integer_arrays;
with Scheduling_Analysis; use Scheduling_Analysis;
with Scheduling_Analysis;
use Scheduling_Analysis.Relative_Priority_Records_Table_Package;
with Scheduling_Analysis;
use Scheduling_Analysis.Task_Release_Records_Table_Package;

package CFG_Nodes.extended is

   ----------------------------------------------------
   --
   ----------------------------------------------------
   type cfg_node_ext;
   type cfg_node_ext_ptr is access all cfg_node_ext'class;
   type cfg_node_ext is new cfg_node with record
      next_nodes     : cfg_nodes_table;
      previous_nodes : cfg_nodes_table;
   end record;

   ----------------------------------------------------
   --
   ----------------------------------------------------
   type basic_block_ext;
   type basic_block_ext_ptr is access all basic_block_ext'class;
   type basic_block_ext is new basic_block with record
      next_nodes     : cfg_nodes_table;
      previous_nodes : cfg_nodes_table;
   end record;

   ----------------------------------------------------
   -- This object is used for Useful Basic Block (Lee, 1996) Analysis.
   -- It helps the analysis becomes easier to implement, debug.
   ----------------------------------------------------
   type basic_block_ucb_arr is array (Natural range <>) of integer_array;
   type basic_block_ucb_arr_ptr is access basic_block_ucb_arr;

   type basic_block_ucb;
   type basic_block_ucb_ptr is access all basic_block_ucb'class;
   type basic_block_ucb is new basic_block_ext with record
      gencbr              : integer_array;
      gencbl              : integer_array;
      rmbin               : basic_block_ucb_arr_ptr;
      rmbout              : basic_block_ucb_arr_ptr;
      lmbin               : basic_block_ucb_arr_ptr;
      lmbout              : basic_block_ucb_arr_ptr;
      ucbs                : integer_array;
      numberofusefulblock : Integer;
   end record;

   ----------------------------------------------------
   --
   ----------------------------------------------------
   type crpd_node;
   type crpd_node_ptr is access all crpd_node'class;
   type crpd_node is new cfg_node_ext with record
      job_index  : Natural;
      task_index : Natural;
      task_name  : Unbounded_String;
      crpd_value : Natural;
      a_trrt     : task_release_records_table_ptr;
      a_rprt     : relative_priority_records_table_ptr;
   end record;

   procedure add_next_crpd_node
     (a_crpd_node      : in crpd_node_ptr;
      a_next_crpd_node : in crpd_node_ptr);

   ----------------------------------------------------
   --
   ----------------------------------------------------
   procedure get_description;

end CFG_Nodes.extended;
