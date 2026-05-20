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

with sets;

package cfg_node_set is

   ----------------------------------------------------
   -- In this package, we work with both CFG_Node_Table and CFG_Node_Set.
   -- The reason for that is because:
   -- + In the system, we use CFG_Node_Set
   -- + In the task, we use CFG_Node_Table
   -- We did by this way because this is the current implementation for other
   -- models of Cheddars such as processor and core_unit.
   ----------------------------------------------------

   ----------------------------------------------------------
   -- Definition of basic block set
   ----------------------------------------------------------

   package cfg_node_set is new sets
     (max_element    => Framework_Config.Max_CFG_Nodes,
      element        => cfg_node_ptr,
      free           => Free,
      copy           => Copy,
      put            => Put,
      xml_string     => XML_String,
      xml_ref_string => XML_Ref_String);

   use cfg_node_set;

   type cfg_nodes_set is new cfg_node_set.set with private;

   subtype cfg_nodes_range is cfg_node_set.element_range;
   subtype cfg_nodes_iterator is cfg_node_set.iterator;

   ----------------------------------------------------------
   -- Exceptions defined in the set package
   ----------------------------------------------------------

   -- Raised when a given CFG node is not in a CFG node set
   --
   cfg_node_not_found : exception;

   -- Raised when parameters provided to Add_Basic_Block are wrong
   --
   invalid_parameter : exception;

   ----------------------------------------------------------
   -- I/O operations
   ----------------------------------------------------------
   --     function Export_Aadl_Implementations
   --       (my_basic_blocks    : in Basic_Blocks_Set)
   --        return             Unbounded_String;
   --
   --     function Export_Aadl_Declarations
   --       (my_basic_blocks    : in Basic_Blocks_Set;
   --        Number_Of_Ht       : in Natural)
   --        return             Unbounded_String;

   ----------------------------------------------------
   -- CHECK
   ----------------------------------------------------

   procedure check_cfg_node
     (name       : in Unbounded_String;
      node_type  : in cfg_node_type;
      graph_type : in cfg_graph_type);

   ----------------------------------------------------
   -- ADD
   ----------------------------------------------------
   procedure add_cfg_node
     (my_cfg_nodes : in out cfg_nodes_set;
      a_cfg_node   : in out cfg_node_ptr;
      name         : in     Unbounded_String;
      node_type    : in     cfg_node_type;
      graph_type   : in     cfg_graph_type);

   procedure add_cfg_node
     (my_cfg_nodes : in out cfg_nodes_set;
      name         : in     Unbounded_String;
      node_type    : in     cfg_node_type;
      graph_type   : in     cfg_graph_type);

   ------------------------------------------------------
   -- SEARCH
   ------------------------------------------------------
   function search_cfg_node
     (my_cfg_nodes : in cfg_nodes_set;
      name         : in Unbounded_String) return cfg_node_ptr;
   --Search CFG node by name

   function search_cfg_node_by_id
     (my_cfg_nodes : in cfg_nodes_set;
      id           : in Unbounded_String) return cfg_node_ptr;
   --Search CFG node by cheddar_private_id

   ------------------------------------------------------
   -- DELETE
   ------------------------------------------------------

   procedure delete_cfg_node
     (my_cfg_nodes : in out cfg_nodes_set;
      name         : in     Unbounded_String);

   ------------------------------------------------------
   -- UPDATE
   ------------------------------------------------------

   procedure update_cfg_node
     (my_cfg_nodes : in out cfg_nodes_set;
      name         : in     Unbounded_String;
      node_type    : in     cfg_node_type;
      graph_type   : in     cfg_graph_type);

   ------------------------------------------------------
   -- NEXT, PREVIOUS
   ------------------------------------------------------
   procedure add_next_cfg_node
     (my_cfg_nodes   : in out cfg_nodes_set;
      name           : in     Unbounded_String;
      next_node_name : in     Unbounded_String);
   -- Add the CFG node with name="next_node_name : in" to
   -- the next_nodes of the CFG node with name="name : in".

   procedure add_next_cfg_node_by_id
     (my_cfg_nodes : in out cfg_nodes_set;
      a_cfg_node   : in out cfg_node_ptr;
      next_node_id : in     Unbounded_String);
   -- Add the CFG node with name="next_node_name : in" to
   -- the next_nodes of the CFG node a_cfg_node.

   procedure add_previous_cfg_node
     (my_cfg_nodes       : in out cfg_nodes_set;
      name               : in     Unbounded_String;
      previous_node_name : in     Unbounded_String);
   -- Add the CFG node with name="next_node_name : in" to
   -- the previous_nodes of the CFG node with name="name : in".

   procedure add_previous_cfg_node_by_id
     (my_cfg_nodes     : in out cfg_nodes_set;
      a_cfg_node       : in out cfg_node_ptr;
      previous_node_id : in     Unbounded_String);
   -- Add the CFG node with name="next_node_name : in" to
   -- the previous_nodes of the CFG node a_cfg_node.

   --procedure Set_Previous_CFG_Nodes
   --  (my_cfg_nodes            : in out CFG_Nodes_Set);
   --If all the next_nodes is set, this method is used to automatically
   --set the previous nodes.

private
   type cfg_nodes_set is new cfg_node_set.set with null record;

end cfg_node_set;
