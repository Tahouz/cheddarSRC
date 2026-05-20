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

with Text_IO;                   use Text_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with CFG_Nodes;			use CFG_Nodes;
with CFG_Nodes.Extended;	use CFG_Nodes.Extended;
with CFG_Nodes;			use CFG_Nodes.CFG_Nodes_Table_Package;
with CFG_Node_Set; 		use CFG_Node_Set;
with CFG_Node_Set.Basic_Block_Set; 	use CFG_Node_Set.Basic_Block_Set;
with Systems;			        use Systems;
with Integer_Arrays; 		        use Integer_Arrays;
with Tables;

with Caches; use Caches;
with Cache_Set; use Cache_Set;
with Basic_Blocks; use Basic_Blocks;
with Basic_Blocks;
use Basic_Blocks.Basic_Blocks_Table_Package;
with CFG_Edge_Set; 	use CFG_Edge_Set;
with CFG_Edges; 	use CFG_Edges;
with CFG_Edges;		use CFG_Edges.CFG_Edges_Table_Package;

package body CFG_Nodes_Builder is

   --
   -- EXAMPLE FROM MALARDALEN BENCHMARK SUITE - ABSINT

   procedure Build_CFG_Node_Set_Bs_Ait
     (my_cfg_nodes : in out CFG_Nodes_Set;
      my_cfg_edges : in out CFG_Edges_Set;
      offset : in out Integer)
   is
      a_cfg_node 	: CFG_Node_Ptr;
      No_Nodes		: CFG_Nodes_Table;
      Empty_String	: Unbounded_String := To_Unbounded_String("");
   begin

      Add_CFG_Node(my_cfg_nodes      		=> my_cfg_nodes,
                   a_cfg_node       		=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Bs_1"),
                   node_type           		=> CFG_Node_Type'Val(0),
                   graph_type			=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+0,
                   instruction_capacity 	=> 16,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  		=> 0);


      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Bs_2"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+16,
                   instruction_capacity 	=> 12,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Bs_3"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+28,
                   instruction_capacity 	=> 36,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Bs_4"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+64,
                   instruction_capacity 	=> 56,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Bs_5"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+120,
                   instruction_capacity 	=> 48,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Bs_6"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+168,
                   instruction_capacity 	=> 36,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Bs_7"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+204,
                   instruction_capacity 	=> 20,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Bs_8"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+224,
                   instruction_capacity 	=> 12,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Bs_9"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+236,
                   instruction_capacity 	=> 20,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Bs_10"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+256,
                   instruction_capacity 	=> 20,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      offset:= offset+276;

      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_bs_1"),To_Unbounded_String("Bs_1"),To_Unbounded_String("Bs_3"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_bs_2"),To_Unbounded_String("Bs_3"),To_Unbounded_String("Bs_9"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_bs_3"),To_Unbounded_String("Bs_4"),To_Unbounded_String("Bs_6"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_bs_4"),To_Unbounded_String("Bs_5"),To_Unbounded_String("Bs_9"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_bs_5"),To_Unbounded_String("Bs_6"),To_Unbounded_String("Bs_8"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_bs_6"),To_Unbounded_String("Bs_6"),To_Unbounded_String("Bs_10"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_bs_7"),To_Unbounded_String("Bs_7"),To_Unbounded_String("Bs_2"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_bs_8"),To_Unbounded_String("Bs_8"),To_Unbounded_String("Bs_9"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_bs_9"),To_Unbounded_String("Bs_9"),To_Unbounded_String("Bs_4"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_bs_10"),To_Unbounded_String("Bs_9"),To_Unbounded_String("Bs_5"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_bs_11"),To_Unbounded_String("Bs_9"),To_Unbounded_String("Bs_7"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_bs_12"),To_Unbounded_String("Bs_10"),To_Unbounded_String("Bs_9"));

   end Build_CFG_Node_Set_Bs_Ait;

   procedure Build_CFG_Node_Set_Fac_Ait
     (my_cfg_nodes : in out CFG_Nodes_Set;
      my_cfg_edges : in out CFG_Edges_Set;
      offset : in out Integer)
   is
      a_cfg_node 	: CFG_Node_Ptr;
      No_Nodes		: CFG_Nodes_Table;
      Empty_String	: Unbounded_String := To_Unbounded_String("");
   begin

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 => To_Unbounded_String ("Fac_1"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   => offset+0,
                   instruction_capacity => 24,
                   data_offset          => 0,
                   data_capacity        => 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 => To_Unbounded_String ("Fac_2"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   => offset+24,
                   instruction_capacity => 12,
                   data_offset          => 0,
                   data_capacity        => 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 => To_Unbounded_String ("Fac_3"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   => offset+36,
                   instruction_capacity => 20,
                   data_offset          => 0,
                   data_capacity        => 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 => To_Unbounded_String ("Fac_4"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   => offset+56,
                   instruction_capacity => 20,
                   data_offset          => 0,
                   data_capacity        => 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 => To_Unbounded_String ("Fac_5"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   => offset+76,
                   instruction_capacity => 20,
                   data_offset          => 0,
                   data_capacity        => 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 => To_Unbounded_String ("Fac_6"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   => offset+96,
                   instruction_capacity => 28,
                   data_offset          => 0,
                   data_capacity        => 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 => To_Unbounded_String ("Fac_7"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   => offset+124,
                   instruction_capacity => 12,
                   data_offset          => 0,
                   data_capacity        => 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 => To_Unbounded_String ("Fac_8"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   => offset+136,
                   instruction_capacity => 12,
                   data_offset          => 0,
                   data_capacity        => 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 => To_Unbounded_String ("Fac_9"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   => offset+148,
                   instruction_capacity => 20,
                   data_offset          => 0,
                   data_capacity        => 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 => To_Unbounded_String ("Fac_10"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   => offset+168,
                   instruction_capacity => 20,
                   data_offset          => 0,
                   data_capacity        => 10,
                   loop_bound	  	=> 0);

      offset:= offset+188;


      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fac_1"),To_Unbounded_String("Fac_1"),To_Unbounded_String("Fac_2"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fac_2"),To_Unbounded_String("Fac_1"),To_Unbounded_String("Fac_3"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fac_3"),To_Unbounded_String("Fac_1"),To_Unbounded_String("Fac_8"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fac_4"),To_Unbounded_String("Fac_2"),To_Unbounded_String("Fac_5"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fac_5"),To_Unbounded_String("Fac_3"),To_Unbounded_String("Fac_1"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fac_6"),To_Unbounded_String("Fac_3"),To_Unbounded_String("Fac_4"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fac_7"),To_Unbounded_String("Fac_4"),To_Unbounded_String("Fac_5"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fac_8"),To_Unbounded_String("Fac_5"),To_Unbounded_String("Fac_8"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fac_9"),To_Unbounded_String("Fac_6"),To_Unbounded_String("Fac_9"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fac_10"),To_Unbounded_String("Fac_6"),To_Unbounded_String("Fac_7"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fac_11"),To_Unbounded_String("Fac_7"),To_Unbounded_String("Fac_1"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fac_12"),To_Unbounded_String("Fac_8"),To_Unbounded_String("Fac_9"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fac_13"),To_Unbounded_String("Fac_9"),To_Unbounded_String("Fac_7"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fac_14"),To_Unbounded_String("Fac_9"),To_Unbounded_String("Fac_10"));

   end Build_CFG_Node_Set_Fac_Ait;

   procedure Build_CFG_Node_Set_Fibcall_Ait
     (my_cfg_nodes : in out CFG_Nodes_Set;
      my_cfg_edges : in out CFG_Edges_Set;
      offset : in out Integer)
   is
      a_cfg_node 	: CFG_Node_Ptr;
      No_Nodes		: CFG_Nodes_Table;
      Empty_String	: Unbounded_String := To_Unbounded_String("");
   begin

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Fib_1"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+0,
                   instruction_capacity 	=> 36,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Fib_2"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+36,
                   instruction_capacity 	=> 44,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 => To_Unbounded_String ("Fib_3"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   => offset+80,
                   instruction_capacity => 12,
                   data_offset          => 0,
                   data_capacity        => 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 => To_Unbounded_String ("Fib_4"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   => offset+92,
                   instruction_capacity => 20,
                   data_offset          => 0,
                   data_capacity        => 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Fib_5"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+112,
                   instruction_capacity 	=> 28,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Fib_6"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+140,
                   instruction_capacity 	=> 24,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Fib_7"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+164,
                   instruction_capacity 	=> 20,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      offset := offset + 184;

      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fib_1"),To_Unbounded_String("Fib_1"),To_Unbounded_String("Fib_3"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fib_1"),To_Unbounded_String("Fib_2"),To_Unbounded_String("Fib_3"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fib_1"),To_Unbounded_String("Fib_3"),To_Unbounded_String("Fib_4"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fib_1"),To_Unbounded_String("Fib_3"),To_Unbounded_String("Fib_5"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fib_1"),To_Unbounded_String("Fib_4"),To_Unbounded_String("Fib_2"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fib_1"),To_Unbounded_String("Fib_5"),To_Unbounded_String("Fib_7"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fib_1"),To_Unbounded_String("Fib_6"),To_Unbounded_String("Fib_1"));

   end Build_CFG_Node_Set_Fibcall_Ait;

   procedure Build_CFG_Node_Set_Fdct_Ait
     (my_cfg_nodes : in out CFG_Nodes_Set;
      my_cfg_edges : in out CFG_Edges_Set;
      offset : in out Integer)
   is
      a_cfg_node 	: CFG_Node_Ptr;
      No_Nodes		: CFG_Nodes_Table;
      Empty_String	: Unbounded_String := To_Unbounded_String("");
   begin

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Fdct_1"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+0,
                   instruction_capacity 	=> 28,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Fdct_2"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+28,
                   instruction_capacity 	=> 1276,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Fdct_3"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+1304,
                   instruction_capacity 	=> 12,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Fdct_4"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+1316,
                   instruction_capacity 	=> 16,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Fdct_5"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+1332,
                   instruction_capacity 	=> 1348,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Fdct_6"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+2680,
                   instruction_capacity 	=> 12,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Fdct_7"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+2692,
                   instruction_capacity 	=> 8,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Fdct_8"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+2700,
                   instruction_capacity 	=> 28,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Fdct_9"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+2728,
                   instruction_capacity 	=> 28,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      offset:= offset+2756;

      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fdct_1"),To_Unbounded_String("Fdct_1"),To_Unbounded_String("Fdct_3"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fdct_2"),To_Unbounded_String("Fdct_2"),To_Unbounded_String("Fdct_3"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fdct_3"),To_Unbounded_String("Fdct_3"),To_Unbounded_String("Fdct_2"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fdct_4"),To_Unbounded_String("Fdct_3"),To_Unbounded_String("Fdct_4"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fdct_5"),To_Unbounded_String("Fdct_4"),To_Unbounded_String("Fdct_6"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fdct_6"),To_Unbounded_String("Fdct_5"),To_Unbounded_String("Fdct_6"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fdct_7"),To_Unbounded_String("Fdct_6"),To_Unbounded_String("Fdct_5"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fdct_8"),To_Unbounded_String("Fdct_6"),To_Unbounded_String("Fdct_7"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fdct_9"),To_Unbounded_String("Fdct_7"),To_Unbounded_String("Fdct_9"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_fdct_10"),To_Unbounded_String("Fdct_8"),To_Unbounded_String("Fdct_1"));


   end Build_CFG_Node_Set_Fdct_Ait;

   procedure Build_CFG_Node_Set_InsertSort_Ait
     (my_cfg_nodes : in out CFG_Nodes_Set;
      my_cfg_edges : in out CFG_Edges_Set;
      offset : in out Integer)
   is
      a_cfg_node 	: CFG_Node_Ptr;
      No_Nodes		: CFG_Nodes_Table;
      Empty_String	: Unbounded_String := To_Unbounded_String("");
   begin

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("InsertSort_1"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+0,
                   instruction_capacity 	=> 188,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("InsertSort_2"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+188,
                   instruction_capacity 	=> 16,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("InsertSort_3"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+204,
                   instruction_capacity 	=> 108,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("InsertSort_4"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+312,
                   instruction_capacity 	=> 56,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("InsertSort_5"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+368,
                   instruction_capacity 	=> 16,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("InsertSort_6"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+384,
                   instruction_capacity 	=> 16,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("InsertSort_7"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+400,
                   instruction_capacity 	=> 20,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      offset := offset + 420;

      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_is_1"),To_Unbounded_String("InsertSort_1"),To_Unbounded_String("InsertSort_6"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_is_2"),To_Unbounded_String("InsertSort_2"),To_Unbounded_String("InsertSort_4"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_is_3"),To_Unbounded_String("InsertSort_3"),To_Unbounded_String("InsertSort_4"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_is_4"),To_Unbounded_String("InsertSort_4"),To_Unbounded_String("InsertSort_5"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_is_5"),To_Unbounded_String("InsertSort_4"),To_Unbounded_String("InsertSort_3"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_is_6"),To_Unbounded_String("InsertSort_5"),To_Unbounded_String("InsertSort_6"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_is_7"),To_Unbounded_String("InsertSort_6"),To_Unbounded_String("InsertSort_7"));


   end Build_CFG_Node_Set_InsertSort_Ait;

   procedure Build_CFG_Node_Set_Ns_Ait
     (my_cfg_nodes : in out CFG_Nodes_Set;
      my_cfg_edges : in out CFG_Edges_Set;
      offset : in out Integer)
   is
      a_cfg_node 	: CFG_Node_Ptr;
      No_Nodes		: CFG_Nodes_Table;
      Empty_String	: Unbounded_String := To_Unbounded_String("");
   begin

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_1"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+0,
                   instruction_capacity 	=> 20,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_2"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+20,
                   instruction_capacity 	=> 12,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_3"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+32,
                   instruction_capacity 	=> 20,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_4"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+52,
                   instruction_capacity 	=> 12,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_5"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+64,
                   instruction_capacity 	=> 112,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_6"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+176,
                   instruction_capacity 	=> 12,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);


      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_7"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+198,
                   instruction_capacity 	=> 16,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_8"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+214,
                   instruction_capacity 	=> 12,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_9"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+226,
                   instruction_capacity 	=> 16,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_10"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+242,
                   instruction_capacity 	=> 12,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_11"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+254,
                   instruction_capacity 	=> 16,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_12"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+270,
                   instruction_capacity 	=> 12,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_13"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+282,
                   instruction_capacity 	=> 16,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_14"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+282,
                   instruction_capacity 	=> 204,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_15"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+486,
                   instruction_capacity 	=> 4,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_16"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+490,
                   instruction_capacity 	=> 16,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_17"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+506,
                   instruction_capacity 	=> 16,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Ns_18"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+522,
                   instruction_capacity 	=> 12,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      offset := offset+534;

      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_1"),To_Unbounded_String("Ns_1"),To_Unbounded_String("Ns_13"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_2"),To_Unbounded_String("Ns_2"),To_Unbounded_String("Ns_11"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_3"),To_Unbounded_String("Ns_3"),To_Unbounded_String("Ns_9"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_4"),To_Unbounded_String("Ns_4"),To_Unbounded_String("Ns_7"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_5"),To_Unbounded_String("Ns_5"),To_Unbounded_String("Ns_6"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_6"),To_Unbounded_String("Ns_6"),To_Unbounded_String("Ns_7"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_7"),To_Unbounded_String("Ns_6"),To_Unbounded_String("Ns_8"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_8"),To_Unbounded_String("Ns_7"),To_Unbounded_String("Ns_5"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_9"),To_Unbounded_String("Ns_8"),To_Unbounded_String("Ns_9"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_10"),To_Unbounded_String("Ns_8"),To_Unbounded_String("Ns_10"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_11"),To_Unbounded_String("Ns_9"),To_Unbounded_String("Ns_4"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_12"),To_Unbounded_String("Ns_10"),To_Unbounded_String("Ns_11"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_13"),To_Unbounded_String("Ns_10"),To_Unbounded_String("Ns_12"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_14"),To_Unbounded_String("Ns_11"),To_Unbounded_String("Ns_3"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_15"),To_Unbounded_String("Ns_12"),To_Unbounded_String("Ns_13"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_16"),To_Unbounded_String("Ns_12"),To_Unbounded_String("Ns_14"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_17"),To_Unbounded_String("Ns_12"),To_Unbounded_String("Ns_15"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_18"),To_Unbounded_String("Ns_13"),To_Unbounded_String("Ns_2"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_19"),To_Unbounded_String("Ns_14"),To_Unbounded_String("Ns_16"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_20"),To_Unbounded_String("Ns_15"),To_Unbounded_String("Ns_16"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_21"),To_Unbounded_String("Ns_17"),To_Unbounded_String("Ns_1"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_ns_22"),To_Unbounded_String("Ns_16"),To_Unbounded_String("Ns_18"));


   end Build_CFG_Node_Set_Ns_Ait;

   procedure Build_CFG_Node_Set_Prime_Ait
     (my_cfg_nodes : in out CFG_Nodes_Set;
      my_cfg_edges : in out CFG_Edges_Set;
      offset : in out Integer)
   is
      a_cfg_node 	: CFG_Node_Ptr;
      No_Nodes		: CFG_Nodes_Table;
      Empty_String	: Unbounded_String := To_Unbounded_String("");
   begin

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_1"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+0,
                   instruction_capacity 	=> 52,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_2"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+52,
                   instruction_capacity 	=> 64,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_3"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+116,
                   instruction_capacity 	=> 12,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_4"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+128,
                   instruction_capacity 	=> 20,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_5"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+148,
                   instruction_capacity 	=> 24,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_6"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+172,
                   instruction_capacity 	=> 64,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_7"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+236,
                   instruction_capacity 	=> 20,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_8"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+256,
                   instruction_capacity 	=> 20,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_9"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+276,
                   instruction_capacity 	=> 16,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_10"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+292,
                   instruction_capacity 	=> 40,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_11"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+332,
                   instruction_capacity 	=> 16,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_12"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+348,
                   instruction_capacity 	=> 20,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_13"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+368,
                   instruction_capacity 	=> 12,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_14"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+380,
                   instruction_capacity 	=> 20,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_15"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+400,
                   instruction_capacity 	=> 12,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_16"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+412,
                   instruction_capacity 	=> 4,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_17"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+416,
                   instruction_capacity 	=> 16,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_18"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+432,
                   instruction_capacity 	=> 24,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_19"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+456,
                   instruction_capacity 	=> 20,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_20"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+476,
                   instruction_capacity 	=> 16,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_21"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+492,
                   instruction_capacity 	=> 16,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      Add_CFG_Node(my_cfg_nodes      	=> my_cfg_nodes,
                   a_cfg_node       	=> a_cfg_node,
                   name                 	=> To_Unbounded_String ("Prime_22"),
                   node_type           	=> CFG_Node_Type'Val(0),
                   graph_type		=> CFG_Graph_Type'Val(0),
                   instruction_offset   	=> offset+508,
                   instruction_capacity 	=> 32,
                   data_offset          	=> 0,
                   data_capacity        	=> 10,
                   loop_bound	  	=> 0);

      offset:= offset+540;

      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_1"),To_Unbounded_String("Prime_1"),To_Unbounded_String("Prime_2"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_2"),To_Unbounded_String("Prime_2"),To_Unbounded_String("Prime_3"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_3"),To_Unbounded_String("Prime_3"),To_Unbounded_String("Prime_4"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_4"),To_Unbounded_String("Prime_4"),To_Unbounded_String("Prime_5"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_5"),To_Unbounded_String("Prime_5"),To_Unbounded_String("Prime_6"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_6"),To_Unbounded_String("Prime_6"),To_Unbounded_String("Prime_7"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_7"),To_Unbounded_String("Prime_6"),To_Unbounded_String("Prime_12"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_8"),To_Unbounded_String("Prime_7"),To_Unbounded_String("Prime_8"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_9"),To_Unbounded_String("Prime_8"),To_Unbounded_String("Prime_9"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_10"),To_Unbounded_String("Prime_8"),To_Unbounded_String("Prime_18"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_11"),To_Unbounded_String("Prime_9"),To_Unbounded_String("Prime_10"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_12"),To_Unbounded_String("Prime_10"),To_Unbounded_String("Prime_11"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_13"),To_Unbounded_String("Prime_10"),To_Unbounded_String("Prime_14"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_14"),To_Unbounded_String("Prime_10"),To_Unbounded_String("Prime_15"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_15"),To_Unbounded_String("Prime_11"),To_Unbounded_String("Prime_6"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_16"),To_Unbounded_String("Prime_12"),To_Unbounded_String("Prime_13"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_17"),To_Unbounded_String("Prime_13"),To_Unbounded_String("Prime_10"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_18"),To_Unbounded_String("Prime_14"),To_Unbounded_String("Prime_16"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_19"),To_Unbounded_String("Prime_14"),To_Unbounded_String("Prime_17"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_20"),To_Unbounded_String("Prime_15"),To_Unbounded_String("Prime_17"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_21"),To_Unbounded_String("Prime_16"),To_Unbounded_String("Prime_17"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_22"),To_Unbounded_String("Prime_17"),To_Unbounded_String("Prime_19"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_23"),To_Unbounded_String("Prime_17"),To_Unbounded_String("Prime_20"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_24"),To_Unbounded_String("Prime_18"),To_Unbounded_String("Prime_17"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_25"),To_Unbounded_String("Prime_19"),To_Unbounded_String("Prime_21"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_26"),To_Unbounded_String("Prime_19"),To_Unbounded_String("Prime_22"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_27"),To_Unbounded_String("Prime_20"),To_Unbounded_String("Prime_22"));
      Add_CFG_Edge(my_cfg_edges,To_Unbounded_String("edg_prime_28"),To_Unbounded_String("Prime_21"),To_Unbounded_String("Prime_4"));



   end Build_CFG_Node_Set_Prime_Ait;

   --
   -- ADD THE CORESPONDING BASIC NODE TO THE SYSTEM
   -- Those methods also return a table.
   -- Use this table to add the set of basic nodes to the task
   procedure Add_CFG_Nodes_Bs_To_System
     (sys : in out System;
      my_cfg_nodes : in out CFG_Nodes_Table;
      my_cfg_edges : in out CFG_Edges_Table;
      offset : in out Integer)
   is
      dummy_cfg_nodes   : CFG_Nodes_Set;
      dummy_cfg_edges	: CFG_Edges_Set;
      a_cfg_node 	: CFG_Node_Ptr;
      a_cfg_edge	: CFG_Edge_Ptr;
      Empty_String	: Unbounded_String := To_Unbounded_String("");
      my_iterator       : CFG_Nodes_Iterator;
      my_iterator_2	: CFG_Edges_Iterator;

   begin

      Build_CFG_Node_Set_Bs_Ait (my_cfg_nodes 	=> dummy_cfg_nodes,
                                 my_cfg_edges   => dummy_cfg_edges,
                                 offset         => offset);

      reset_iterator(dummy_cfg_nodes,my_iterator);
      loop
         current_element(dummy_cfg_nodes,a_cfg_node,my_iterator);

         Add(my_cfg_nodes,a_cfg_node);
         Add(sys.CFG_Nodes,a_cfg_node);

         exit when is_last_element (dummy_cfg_nodes, my_iterator);
         next_element (dummy_cfg_nodes, my_iterator);
      end loop;

      reset_iterator(dummy_cfg_edges,my_iterator_2);
      loop
         current_element(dummy_cfg_edges,a_cfg_edge,my_iterator_2);

         Add(my_cfg_edges,a_cfg_edge);
         Add(sys.CFG_Edges,a_cfg_edge);

         exit when is_last_element (dummy_cfg_edges, my_iterator_2);
         next_element (dummy_cfg_edges, my_iterator_2);
      end loop;
   end Add_CFG_Nodes_Bs_To_System;

   procedure Add_CFG_Nodes_Fac_To_System
     (sys : in out System;
      my_cfg_nodes : in out CFG_Nodes_Table;
      my_cfg_edges : in out CFG_Edges_Table;
      offset : in out Integer)
   is
      dummy_cfg_nodes   : CFG_Nodes_Set;
      dummy_cfg_edges	: CFG_Edges_Set;
      a_cfg_node 	: CFG_Node_Ptr;
      a_cfg_edge	: CFG_Edge_Ptr;
      Empty_String	: Unbounded_String := To_Unbounded_String("");
      my_iterator       : CFG_Nodes_Iterator;
      my_iterator_2	: CFG_Edges_Iterator;

   begin

      Build_CFG_Node_Set_Fac_Ait (my_cfg_nodes 	 => dummy_cfg_nodes,
                                  my_cfg_edges   => dummy_cfg_edges,
                                  offset         => offset);

      reset_iterator(dummy_cfg_nodes,my_iterator);
      loop
         current_element(dummy_cfg_nodes,a_cfg_node,my_iterator);

         Add(my_cfg_nodes,a_cfg_node);
         Add(sys.CFG_Nodes,a_cfg_node);

         exit when is_last_element (dummy_cfg_nodes, my_iterator);
         next_element (dummy_cfg_nodes, my_iterator);
      end loop;

      reset_iterator(dummy_cfg_edges,my_iterator_2);
      loop
         current_element(dummy_cfg_edges,a_cfg_edge,my_iterator_2);

         Add(my_cfg_edges,a_cfg_edge);
         Add(sys.CFG_Edges,a_cfg_edge);

         exit when is_last_element (dummy_cfg_edges, my_iterator_2);
         next_element (dummy_cfg_edges, my_iterator_2);
      end loop;

   end Add_CFG_Nodes_Fac_To_System;

   procedure Add_CFG_Nodes_Fibcall_To_System
     (sys : in out System;
      my_cfg_nodes : in out CFG_Nodes_Table;
      my_cfg_edges : in out CFG_Edges_Table;
      offset : in out Integer)
   is
      dummy_cfg_nodes   : CFG_Nodes_Set;
      dummy_cfg_edges	: CFG_Edges_Set;
      a_cfg_node 	: CFG_Node_Ptr;
      a_cfg_edge	: CFG_Edge_Ptr;
      Empty_String	: Unbounded_String := To_Unbounded_String("");
      my_iterator       : CFG_Nodes_Iterator;
      my_iterator_2	: CFG_Edges_Iterator;
   begin

      Build_CFG_Node_Set_Fibcall_Ait(my_cfg_nodes   => dummy_cfg_nodes,
                                     my_cfg_edges   => dummy_cfg_edges,
                                     offset         => offset);

      reset_iterator(dummy_cfg_nodes,my_iterator);
      loop
         current_element(dummy_cfg_nodes,a_cfg_node,my_iterator);

         Add(my_cfg_nodes,a_cfg_node);
         Add(sys.CFG_Nodes,a_cfg_node);

         exit when is_last_element (dummy_cfg_nodes, my_iterator);
         next_element (dummy_cfg_nodes, my_iterator);
      end loop;

      reset_iterator(dummy_cfg_edges,my_iterator_2);
      loop
         current_element(dummy_cfg_edges,a_cfg_edge,my_iterator_2);

         Add(my_cfg_edges,a_cfg_edge);
         Add(sys.CFG_Edges,a_cfg_edge);

         exit when is_last_element (dummy_cfg_edges, my_iterator_2);
         next_element (dummy_cfg_edges, my_iterator_2);
      end loop;

   end Add_CFG_Nodes_Fibcall_To_System;
   --
   --

   procedure Add_CFG_Nodes_Fdct_To_System
     (sys : in out System;
      my_cfg_nodes : in out CFG_Nodes_Table;
      my_cfg_edges : in out CFG_Edges_Table;
      offset : in out Integer)
   is
      dummy_cfg_nodes   : CFG_Nodes_Set;
      dummy_cfg_edges	: CFG_Edges_Set;
      a_cfg_node 	: CFG_Node_Ptr;
      a_cfg_edge	: CFG_Edge_Ptr;
      Empty_String	: Unbounded_String := To_Unbounded_String("");
      my_iterator       : CFG_Nodes_Iterator;
      my_iterator_2	: CFG_Edges_Iterator;
   begin

      Build_CFG_Node_Set_Fdct_Ait(my_cfg_nodes   => dummy_cfg_nodes,
                                  my_cfg_edges   => dummy_cfg_edges,
                                  offset         => offset);

      reset_iterator(dummy_cfg_nodes,my_iterator);
      loop
         current_element(dummy_cfg_nodes,a_cfg_node,my_iterator);

         Add(my_cfg_nodes,a_cfg_node);
         Add(sys.CFG_Nodes,a_cfg_node);

         exit when is_last_element (dummy_cfg_nodes, my_iterator);
         next_element (dummy_cfg_nodes, my_iterator);
      end loop;

      reset_iterator(dummy_cfg_edges,my_iterator_2);
      loop
         current_element(dummy_cfg_edges,a_cfg_edge,my_iterator_2);

         Add(my_cfg_edges,a_cfg_edge);
         Add(sys.CFG_Edges,a_cfg_edge);

         exit when is_last_element (dummy_cfg_edges, my_iterator_2);
         next_element (dummy_cfg_edges, my_iterator_2);
      end loop;

   end Add_CFG_Nodes_Fdct_To_System;

   procedure Add_CFG_Nodes_InsertSort_To_System
     (sys : in out System;
      my_cfg_nodes : in out CFG_Nodes_Table;
      my_cfg_edges : in out CFG_Edges_Table;
      offset : in out Integer)
   is
      dummy_cfg_nodes   : CFG_Nodes_Set;
      dummy_cfg_edges	: CFG_Edges_Set;
      a_cfg_node 	: CFG_Node_Ptr;
      a_cfg_edge	: CFG_Edge_Ptr;
      Empty_String	: Unbounded_String := To_Unbounded_String("");
      my_iterator       : CFG_Nodes_Iterator;
      my_iterator_2	: CFG_Edges_Iterator;

   begin

      Build_CFG_Node_Set_InsertSort_Ait(my_cfg_nodes   => dummy_cfg_nodes,
                                        my_cfg_edges   => dummy_cfg_edges,
                                        offset         => offset);

      reset_iterator(dummy_cfg_nodes,my_iterator);
      loop
         current_element(dummy_cfg_nodes,a_cfg_node,my_iterator);

         Add(my_cfg_nodes,a_cfg_node);
         Add(sys.CFG_Nodes,a_cfg_node);

         exit when is_last_element (dummy_cfg_nodes, my_iterator);
         next_element (dummy_cfg_nodes, my_iterator);
      end loop;

      reset_iterator(dummy_cfg_edges,my_iterator_2);
      loop
         current_element(dummy_cfg_edges,a_cfg_edge,my_iterator_2);

         Add(my_cfg_edges,a_cfg_edge);
         Add(sys.CFG_Edges,a_cfg_edge);

         exit when is_last_element (dummy_cfg_edges, my_iterator_2);
         next_element (dummy_cfg_edges, my_iterator_2);
      end loop;

   end Add_CFG_Nodes_InsertSort_To_System;

   procedure Add_CFG_Nodes_Ns_To_System
     (sys : in out System;
      my_cfg_nodes : in out CFG_Nodes_Table;
      my_cfg_edges : in out CFG_Edges_Table;
      offset : in out Integer)
   is
      dummy_cfg_nodes   : CFG_Nodes_Set;
      dummy_cfg_edges	: CFG_Edges_Set;
      a_cfg_node 	: CFG_Node_Ptr;
      a_cfg_edge	: CFG_Edge_Ptr;
      Empty_String	: Unbounded_String := To_Unbounded_String("");
      my_iterator       : CFG_Nodes_Iterator;
      my_iterator_2	: CFG_Edges_Iterator;

   begin

      Build_CFG_Node_Set_Ns_Ait(my_cfg_nodes   => dummy_cfg_nodes,
                                my_cfg_edges   => dummy_cfg_edges,
                                offset         => offset);

      reset_iterator(dummy_cfg_nodes,my_iterator);
      loop
         current_element(dummy_cfg_nodes,a_cfg_node,my_iterator);

         Add(my_cfg_nodes,a_cfg_node);
         Add(sys.CFG_Nodes,a_cfg_node);

         exit when is_last_element (dummy_cfg_nodes, my_iterator);
         next_element (dummy_cfg_nodes, my_iterator);
      end loop;

      reset_iterator(dummy_cfg_edges,my_iterator_2);
      loop
         current_element(dummy_cfg_edges,a_cfg_edge,my_iterator_2);

         Add(my_cfg_edges,a_cfg_edge);
         Add(sys.CFG_Edges,a_cfg_edge);

         exit when is_last_element (dummy_cfg_edges, my_iterator_2);
         next_element (dummy_cfg_edges, my_iterator_2);
      end loop;

   end Add_CFG_Nodes_Ns_To_System;

   procedure Add_CFG_Nodes_Prime_To_System
     (sys : in out System;
      my_cfg_nodes : in out CFG_Nodes_Table;
      my_cfg_edges : in out CFG_Edges_Table;
      offset : in out Integer)
   is
      dummy_cfg_nodes   : CFG_Nodes_Set;
      dummy_cfg_edges	: CFG_Edges_Set;
      a_cfg_node 	: CFG_Node_Ptr;
      a_cfg_edge	: CFG_Edge_Ptr;
      Empty_String	: Unbounded_String := To_Unbounded_String("");
      my_iterator       : CFG_Nodes_Iterator;
      my_iterator_2	: CFG_Edges_Iterator;

   begin

      Build_CFG_Node_Set_Prime_Ait(my_cfg_nodes   => dummy_cfg_nodes,
                                   my_cfg_edges   => dummy_cfg_edges,
                                   offset         => offset);

      reset_iterator(dummy_cfg_nodes,my_iterator);
      loop
         current_element(dummy_cfg_nodes,a_cfg_node,my_iterator);

         Add(my_cfg_nodes,a_cfg_node);
         Add(sys.CFG_Nodes,a_cfg_node);

         exit when is_last_element (dummy_cfg_nodes, my_iterator);
         next_element (dummy_cfg_nodes, my_iterator);
      end loop;

      reset_iterator(dummy_cfg_edges,my_iterator_2);
      loop
         current_element(dummy_cfg_edges,a_cfg_edge,my_iterator_2);

         Add(my_cfg_edges,a_cfg_edge);
         Add(sys.CFG_Edges,a_cfg_edge);

         exit when is_last_element (dummy_cfg_edges, my_iterator_2);
         next_element (dummy_cfg_edges, my_iterator_2);
      end loop;

   end Add_CFG_Nodes_Prime_To_System;

end CFG_Nodes_Builder;
