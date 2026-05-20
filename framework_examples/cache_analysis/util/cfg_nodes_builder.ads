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
with CFG_Nodes;		use CFG_Nodes;
with CFG_Nodes.Extended;	use CFG_Nodes.Extended;
with CFG_Node_Set; 		use CFG_Node_Set;
with Systems;			use Systems;
with CFG_Node_Set.Basic_Block_Set; use CFG_Node_Set.Basic_Block_Set;
with Basic_Blocks; use Basic_Blocks;
with CFG_Edge_Set; use CFG_Edge_Set;
with CFG_Edges; use CFG_Edges;

package CFG_Nodes_Builder is

   -------------------------------------------------

   --EXAMPLE FROM MALARDALEN BENCHMARK SUITE - ABSINT
   procedure Build_CFG_Node_Set_Bs_Ait
     (my_cfg_nodes : in out CFG_Nodes_Set;
      my_cfg_edges : in out CFG_Edges_Set;
      offset : in out Integer);

   procedure Build_CFG_Node_Set_Fac_Ait
     (my_cfg_nodes : in out CFG_Nodes_Set;
      my_cfg_edges : in out CFG_Edges_Set;
      offset : in out Integer);

   procedure Build_CFG_Node_Set_Fibcall_Ait
     (my_cfg_nodes : in out CFG_Nodes_Set;
      my_cfg_edges : in out CFG_Edges_Set;
      offset : in out Integer);

   procedure Build_CFG_Node_Set_Fdct_Ait
     (my_cfg_nodes : in out CFG_Nodes_Set;
      my_cfg_edges : in out CFG_Edges_Set;
      offset : in out Integer);

   procedure Build_CFG_Node_Set_InsertSort_Ait
     (my_cfg_nodes : in out CFG_Nodes_Set;
      my_cfg_edges : in out CFG_Edges_Set;
      offset : in out Integer);

   procedure Build_CFG_Node_Set_Ns_Ait
     (my_cfg_nodes : in out CFG_Nodes_Set;
      my_cfg_edges : in out CFG_Edges_Set;
      offset : in out Integer);

   procedure Build_CFG_Node_Set_Prime_Ait
     (my_cfg_nodes : in out CFG_Nodes_Set;
      my_cfg_edges : in out CFG_Edges_Set;
      offset : in out Integer);

   -------------------------------------------------
   procedure Add_CFG_Nodes_Bs_To_System
     (sys : in out System;
      my_cfg_nodes : in out CFG_Nodes_Table;
      my_cfg_edges : in out CFG_Edges_Table;
      offset : in out Integer);

   procedure Add_CFG_Nodes_Fac_To_System
     (sys : in out System;
      my_cfg_nodes : in out CFG_Nodes_Table;
      my_cfg_edges : in out CFG_Edges_Table;
      offset : in out Integer);

   procedure Add_CFG_Nodes_Fibcall_To_System
     (sys : in out System;
      my_cfg_nodes : in out CFG_Nodes_Table;
      my_cfg_edges : in out CFG_Edges_Table;
      offset : in out Integer);

   procedure Add_CFG_Nodes_Fdct_To_System
     (sys : in out System;
      my_cfg_nodes : in out CFG_Nodes_Table;
      my_cfg_edges : in out CFG_Edges_Table;
      offset : in out Integer);

   procedure Add_CFG_Nodes_InsertSort_To_System
     (sys : in out System;
      my_cfg_nodes : in out CFG_Nodes_Table;
      my_cfg_edges : in out CFG_Edges_Table;
      offset : in out Integer);

   procedure Add_CFG_Nodes_Ns_To_System
     (sys : in out System;
      my_cfg_nodes : in out CFG_Nodes_Table;
      my_cfg_edges : in out CFG_Edges_Table;
      offset : in out Integer);

   procedure Add_CFG_Nodes_Prime_To_System
     (sys : in out System;
      my_cfg_nodes : in out CFG_Nodes_Table;
      my_cfg_edges : in out CFG_Edges_Table;
      offset : in out Integer);
   -------------------------------------------------


end CFG_Nodes_Builder;
