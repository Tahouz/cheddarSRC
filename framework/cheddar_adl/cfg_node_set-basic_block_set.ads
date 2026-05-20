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
with CFG_Nodes;             use CFG_Nodes;
with CFG_Nodes.extended;    use CFG_Nodes.extended;
with basic_blocks;          use basic_blocks;
with tables;
with sets;
with cfg_edge_set;          use cfg_edge_set;

package cfg_node_set.basic_block_set is

   ----------------------------------------------------
   -- This package is used for a task's control flow graph analysis
   -- each node in the graph represent a basic block.
   --
   -- Notes: in the implementation of Cheddar, a CFG_Node is always instantiated
   -- either as a Basic_Block or an Atomic_Operation.
   -- + Some methods such as Search_Basic_Block, Search_Basic_Block_By_Id, ...
   -- are duplicated for Basic_Blocks to avoid type casting in the future.
   -- + The name of the methods is changed to improve the clarity thus no overload.
   ----------------------------------------------------

   package basic_block_set is new sets
     (max_element    => Framework_Config.Max_CFG_Nodes,
      element        => basic_block_ptr,
      free           => free,
      copy           => copy,
      put            => put,
      xml_string     => xml_string,
      xml_ref_string => xml_ref_string);

   use basic_block_set;

   type basic_blocks_set is new basic_block_set.set with private;

   subtype basic_blocks_range is basic_block_set.element_range;
   subtype basic_blocks_iterator is basic_block_set.iterator;

   ----------------------------------------------------
   -- CHECK - BASIC_BLOCK
   ----------------------------------------------------
   procedure check_basic_block
     (name                 : in Unbounded_String;
      node_type            : in cfg_node_type;
      graph_type           : in cfg_graph_type;
      instruction_offset   : in Integer;
      instruction_capacity : in Integer;
      data_offset          : in Integer;
      data_capacity        : in Integer;
      loop_bound           : in Integer);
   --Check if the input data for a basic block is valid or not.
   --Called by the Add_CFG_Node for Basic_Block.

   ----------------------------------------------------
   -- ADD - BASIC_BLOCK
   ----------------------------------------------------
   procedure add_basic_block
     (my_basic_blocks      : in out basic_blocks_set;
      a_basic_block        : in out basic_block_ptr;
      name                 : in     Unbounded_String;
      node_type            : in     cfg_node_type;
      graph_type           : in     cfg_graph_type;
      instruction_offset   : in     Integer;
      instruction_capacity : in     Integer;
      data_offset          : in     Integer;
      data_capacity        : in     Integer;
      loop_bound           : in     Integer := 0);
   -- Add a Basic_Block to a Basic_Blocks_Set

   procedure add_basic_block
     (my_basic_blocks      : in out basic_blocks_set;
      name                 : in     Unbounded_String;
      node_type            : in     cfg_node_type;
      graph_type           : in     cfg_graph_type;
      instruction_offset   : in     Integer;
      instruction_capacity : in     Integer;
      data_offset          : in     Integer;
      data_capacity        : in     Integer;
      loop_bound           : in     Integer := 0);
   -- Add a Basic_Block to a Basic_Blocks_Set

   ------------------------------------------------------
   -- UPDATE - BASIC_BLOCK
   ------------------------------------------------------
   procedure update_basic_block
     (my_basic_blocks      : in out basic_blocks_set;
      name                 : in     Unbounded_String;
      node_type            : in     cfg_node_type;
      graph_type           : in     cfg_graph_type;
      instruction_offset   : in     Integer;
      instruction_capacity : in     Integer;
      data_offset          : in     Integer;
      data_capacity        : in     Integer;
      loop_bound           : in     Integer);

   ------------------------------------------------------
   -- DELETE
   ------------------------------------------------------
   procedure delete_basic_block
     (my_basic_blocks : in out basic_blocks_set;
      a_basic_block   : in out basic_block_ptr);

   procedure delete_basic_block
     (my_basic_blocks : in out basic_blocks_set;
      name            : in     Unbounded_String);

   ----------------------------------------------------
   -- ADD - (CFG_NODE) BASIC_BLOCK
   ----------------------------------------------------

   procedure add_cfg_node
     (my_cfg_nodes         : in out cfg_nodes_set;
      a_cfg_node           : in out cfg_node_ptr;
      name                 : in     Unbounded_String;
      node_type            : in     cfg_node_type;
      graph_type           : in     cfg_graph_type;
      instruction_offset   : in     Integer;
      instruction_capacity : in     Integer;
      data_offset          : in     Integer;
      data_capacity        : in     Integer;
      loop_bound           : in     Integer := 0);
   -- Add a (CFG_Node)Basic_Block to a CFG_Nodes_Set

   procedure add_cfg_node
     (my_cfg_nodes         : in out cfg_nodes_set;
      name                 : in     Unbounded_String;
      node_type            : in     cfg_node_type;
      graph_type           : in     cfg_graph_type;
      instruction_offset   : in     Integer;
      instruction_capacity : in     Integer;
      data_offset          : in     Integer;
      data_capacity        : in     Integer;
      loop_bound           : in     Integer := 0);
   -- Add a (CFG_Node)Basic_Block to a CFG_Nodes_Set

   ------------------------------------------------------
   -- SEARCH
   ------------------------------------------------------
   function search_basic_block
     (my_basic_blocks : in basic_blocks_set;
      name            : in Unbounded_String) return basic_block_ptr;
   --Search Basic_Block by name

   function search_basic_block_by_id
     (my_basic_blocks : in basic_blocks_set;
      id              : in Unbounded_String) return basic_block_ptr;
   --Search Basic_Block by cheddar_private_id

   ------------------------------------------------------
   -- NEXT, PREVIOUS
   ------------------------------------------------------
   procedure add_next_basic_block
     (my_basic_blocks : in out basic_blocks_set;
      name            : in     Unbounded_String;
      next_block_name : in     Unbounded_String);
   -- Add the Basic_Block with name="next_node_name : in" to
   -- the next_nodes of the Basic_Block with name="name : in".

   procedure add_next_basic_block_by_id
     (my_basic_blocks : in out basic_blocks_set;
      a_basic_block   : in out basic_block_ptr;
      next_block_id   : in     Unbounded_String);
   -- Add the Basic_Block with id="previous_block_id : in" to
   -- the next_nodes of the Basic_Block a_basic_block.

   procedure add_previous_basic_block
     (my_basic_blocks     : in out basic_blocks_set;
      name                : in     Unbounded_String;
      previous_block_name : in     Unbounded_String);
   -- Add the Basic_Block with name="previous_block_name : in" to
   -- the previous_nodes of the Basic_Block with name="name : in".

   procedure add_previous_basic_block_by_id
     (my_basic_blocks   : in out basic_blocks_set;
      a_basic_block     : in out basic_block_ptr;
      previous_block_id : in     Unbounded_String);
   -- Add the Basic_Block with id="previous_block_id : in" to
   -- the previous_nodes of the Basic_Block a_basic_block.

   procedure set_previous_basic_blocks
     (my_basic_blocks : in out basic_blocks_set);
   --If all the next_nodes is set, this method is used to automatically
   --set the previous nodes.

   ----------------------------------------------------
   -- CONVERT
   -- Methods for analysis based on the Useful Cache Block (UCB)
   ----------------------------------------------------

   procedure convert_to_basic_block_ucb_set
     (my_cfg_nodes : in out cfg_nodes_set;
      my_cfg_edges : in out cfg_edges_set;
      size         : in     Integer);
   -- Convert a normal CFG_Node to Basic_Block_UCB
   -- Basic_Block_UCB is defined at CFG_Nodes.Extended

   procedure convert_to_basic_block_ucb_set
     (my_basic_blocks : in out basic_blocks_set;
      my_cfg_edges    : in out cfg_edges_set;
      size            : in     Integer);
   -- Convert a normal Basic_Block to Basic_Block_UCB
   -- Basic_Block_UCB is defined at CFG_Nodes.Extended

private
   type basic_blocks_set is new basic_block_set.set with null record;

end cfg_node_set.basic_block_set;
