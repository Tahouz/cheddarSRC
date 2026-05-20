

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

----------------------------------------------------
-- Reserve for Isaac's analysis
----------------------------------------------------
with Ada.Strings.Unbounded; 	use Ada.Strings.Unbounded;
with unbounded_strings;     	use unbounded_strings;
with Framework_Config;     	use Framework_Config;
with CFG_Nodes;		    	use CFG_Nodes;
with CFG_Nodes.Extended;	use CFG_Nodes.Extended;
with Atomic_Operations;		use Atomic_Operations;
with sets;
with Task_Groups; use Task_Groups;
with Processors; use Processors;


package CFG_Node_Set.Atomic_Operation_Set is

   ----------------------------------------------------
   ----------------------------------------------------
   -- This package is used for a task's control flow graph analysis
   -- each node in the graph represent a atomic operation.
   --
   -- Notes: in the implementation of Cheddar, a CFG_Node is always instantiated
   -- either as a Basic_Block or an Atomic_Operation.
   -- + Some methods such as Search_Atomic_Operation, Search_Atomic_Operation_By_Id, ...
   -- are duplicated for Atomic_Operations to avoid type casting in the future.
   -- + The name of the methods is changed to improve the clarity thus no overload.
   ----------------------------------------------------


   package Atomic_Operation_Set is new Sets (
                                     max_element    => Framework_Config.Max_CFG_Nodes,
                                     element        => Atomic_Operation_Ptr,
                                     free           => Free,
                                     copy           => Copy,
                                     put            => Put,
                                     xml_string     => XML_String,
                                     xml_ref_string => XML_Ref_String);

   use Atomic_Operation_Set;

   type Atomic_Operations_Set is new Atomic_Operation_Set.set with private;

   subtype Atomic_Operations_Range is Atomic_Operation_Set.element_range;
   subtype Atomic_Operations_Iterator is Atomic_Operation_Set.iterator;

   ----------------------------------------------------
   -- CHECK - ATOMIC_OPERATION
   ----------------------------------------------------
   procedure Check_Atomic_Operation
     (name			: in Unbounded_String;
      previous_nodes		: in CFG_Nodes_Table;
      next_nodes		: in CFG_Nodes_Table;
      node_type			: in CFG_Node_Type;
      graph_type		: in CFG_Graph_Type;
      task_sort			: in Task_Sort_Type;
--      loop_sequence 		: in Atomic_Operations_Table;
      processor_sort 		: in Processor_Sort_Type;
      feasibility_test		: in Feasibility_Test_Type);
--      loop_bound		: in Integer);
   --Check if the input data for a atomic operation is valid or not.
   --Called by the Add_CFG_Node for Atomic_Operation.

 ----------------------------------------------------
   -- ADD - ATOMIC_OPERATION
   ----------------------------------------------------

   procedure Add_Atomic_Operation
     (my_atomic_operations	: in out Atomic_Operations_Set;
      a_atomic_operation	: in out Atomic_Operation_Ptr;
      name			: in Unbounded_String;
      previous_nodes		: in CFG_Nodes_Table;
      next_nodes		: in CFG_Nodes_Table;
      node_type			: in CFG_Node_Type;
      graph_type		: in CFG_Graph_Type;
      task_sort			: in Task_Sort_Type;
--      loop_sequence 		: in Atomic_Operations_Table;
      processor_sort 		: in Processor_Sort_Type;
      feasibility_test		: in Feasibility_Test_Type);
--      loop_bound		: in Integer);

   -- Add Atomic_Operation for Atomic_Operation_Set

procedure Add_Atomic_Operation
     (my_atomic_operations	: in out Atomic_Operations_Set;
      name			: in Unbounded_String;
      previous_nodes		: in CFG_Nodes_Table;
      next_nodes		: in CFG_Nodes_Table;
      node_type			: in CFG_Node_Type;
      graph_type		: in CFG_Graph_Type;
      task_sort			: in Task_Sort_Type;
--      loop_sequence 		: in Atomic_Operations_Table;
      processor_sort 		: in Processor_Sort_Type;
      feasibility_test		: in Feasibility_Test_Type);
--      loop_bound		: in Integer);

     -- Add Atomic_Operation for Atomic_Operation_Set
    ------------------------------------------------------
   -- UPDATE - ATOMIC_OPERATION
   ------------------------------------------------------
 procedure Update_Atomic_Operation
     (my_atomic_operations	: in out Atomic_Operations_Set;
      name			: in Unbounded_String;
      previous_nodes		: in CFG_Nodes_Table;
      next_nodes		: in CFG_Nodes_Table;
      node_type			: in CFG_Node_Type;
      graph_type		: in CFG_Graph_Type;
      task_sort			: in Task_Sort_Type;
--      loop_sequence 		: in Atomic_Operations_Table;
      processor_sort 		: in Processor_Sort_Type;
      feasibility_test		: in Feasibility_Test_Type);
--      loop_bound		: in Integer);

   --  Update Atomic_Operation for Atomic_Operation_Set

   ------------------------------------------------------
   -- DELETE
   ------------------------------------------------------
   procedure Delete_Atomic_Operation
     (my_atomic_operations		: in out Atomic_Operations_Set;
      a_atomic_operation		: in out Atomic_Operation_Ptr);

   procedure Delete_Atomic_Operation
     (my_atomic_operations		: in out Atomic_Operations_Set;
      name 				: in Unbounded_String);

    --  Delete Atomic_Operation for Atomic_Operation_Set
   ----------------------------------------------------
   -- ADD -CFG_NODES ATOMIC_OPERATION
   ----------------------------------------------------

   procedure Add_CFG_Node
     (my_cfg_nodes		: in out CFG_Nodes_Set;
      a_cfg_node		: in out CFG_Node_Ptr;
      name			: in Unbounded_String;
      previous_nodes		: in CFG_Nodes_Table;
      next_nodes		: in CFG_Nodes_Table;
      node_type			: in CFG_Node_Type;
      graph_type		: in CFG_Graph_Type;
       task_sort			: in Task_Sort_Type;
--      loop_sequence 		: in Atomic_Operations_Table;
      processor_sort 		: in Processor_Sort_Type;
      feasibility_test		: in Feasibility_Test_Type);
--      loop_bound		: in Integer);

   -- Add CFG Node for Atomic_Operation

procedure Add_CFG_Node
     (my_cfg_nodes		: in out CFG_Nodes_Set;
      name			: in Unbounded_String;
      previous_nodes		: in CFG_Nodes_Table;
      next_nodes		: in CFG_Nodes_Table;
      node_type			: in CFG_Node_Type;
      graph_type		: in CFG_Graph_Type;
      task_sort			: in Task_Sort_Type;
--      loop_sequence 		: in Atomic_Operations_Table;
      processor_sort 		: in Processor_Sort_Type;
      feasibility_test		: in Feasibility_Test_Type);
--      loop_bound		: in Integer);

   -- Add CFG Node for Atomic_Operation
    ------------------------------------------------------
   -- SEARCH
   ------------------------------------------------------
   function Search_Atomic_Operation
     (my_atomic_operations	: in Atomic_Operations_Set;
      name          		: in Unbounded_String)
      return		Atomic_Operation_Ptr;
   --Search Atomic_Operation by name

   function Search_Atomic_Operation_By_Id
     (my_atomic_operations 	: in Atomic_Operations_Set;
      id 			: in Unbounded_String)
      return            Atomic_Operation_Ptr;
   --Search Atomic_Operation by cheddar_private_id

   ------------------------------------------------------
   -- NEXT, PREVIOUS
   ------------------------------------------------------
   procedure Add_Next_Atomic_Operation
     (my_atomic_operations		: in out Atomic_Operations_Set;
      name				: in Unbounded_String;
      next_operation_name		: in Unbounded_String);
   -- Add the Atomic_Operation with name="next_node_name : in" to
   -- the next_nodes of the Atomic_Operation with name="name : in".

   procedure Add_Next_Atomic_Operation_By_Id
     (my_atomic_operations		: in out Atomic_Operations_Set;
      a_atomic_operation		: in out Atomic_Operation_Ptr;
      next_operation_id			: in Unbounded_String);
   -- Add the Atomic_Operation with id="previous_operation_id : in" to
   -- the next_nodes of the Atomic_Operation a_atomic_operation.

   procedure Add_Previous_Atomic_Operation
     (my_atomic_operations		: in out Atomic_Operations_Set;
      name				: in Unbounded_String;
      previous_operation_name		: in Unbounded_String);
   -- Add the Atomic_Operation with name="previous_operation_name : in" to
   -- the previous_nodes of the Atomic_Operation with name="name : in".

   procedure Add_Previous_Atomic_Operation_By_Id
     (my_atomic_operations		: in out Atomic_Operations_Set;
      a_atomic_operation		: in out Atomic_Operation_Ptr;
      previous_operation_id		: in Unbounded_String);
   -- Add the Atomic_Operation with id="previous_operation_id : in" to
   -- the previous_nodes of the Atomic_Operation a_atomic_operation.

   procedure Set_Previous_Atomic_Operations
     (my_atomic_operations 		: in out Atomic_Operations_Set);
   --If all the next_nodes is set, this method is used to automatically
   --set the previous nodes.
private
   type Atomic_Operations_Set is new Atomic_Operation_Set.set with null record;

end CFG_Node_Set.Atomic_Operation_Set;
