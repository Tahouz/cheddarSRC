
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

with Ada.Exceptions;		use Ada.Exceptions;
with CFG_Nodes;			use CFG_Nodes;
with CFG_Nodes;			use CFG_Nodes.CFG_Nodes_Table_Package;
with CFG_Node_Set;		use CFG_Node_Set;
with Atomic_Operations;		use Atomic_Operations;
with Objects;           	use Objects;
with Task_Groups;		use Task_Groups;
with Task_Group_Set;		use Task_Group_Set;
with Processor_Set;		use Processor_Set;
with Objects.extended;  	use Objects.extended;
with Text_IO;			use Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Integer_Arrays;		use Integer_Arrays;
with Translate;         	use Translate;
with Tables;

with sets;
with Processors; use Processors;
with Tasks; use Tasks;

package body CFG_Node_Set.Atomic_Operation_Set is

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
      feasibility_test		: in Feasibility_Test_Type)
--      loop_bound		: in Integer)
   is

   begin
      if (name = "") then
         Raise_Exception
           (Invalid_Parameter'Identity,
            To_String
              (Lb_CFG_Node (Current_Language) &
               Lb_Mandatory (Current_Language)));
      end if;

      if not Is_A_Valid_Identifier (Name) then
         Raise_Exception
           (Invalid_Parameter'Identity,
            To_String
              (Lb_CFG_Node (Current_Language) &
               Name &
               " : " &
               Lb_CFG_Node_Name (Current_Language) &
               Lb_Colon &
               Lb_Invalid_Identifier (Current_Language)));
      end if;


--         if ((sort_order) := "") then
--           Raise_Exception
--             (Invalid_Parameter'Identity,
--              To_String
--                (Lb_CFG_Node (Current_Language) &
--                 " " &
--                 Name &
--                 " : " &
--                 Lb_Sort_Atomic_Operation (Current_Language) &
--                 Lb_Must_Not_Be (Current_Language) &
--                 To_Unbounded_String (" Empty")));
--        end if;
--
--
--         if (feasibility_test = "") then
--           Raise_Exception
--             (Invalid_Parameter'Identity,
--              To_String
--                (Lb_CFG_Node (Current_Language) &
--                 " " &
--                 Name &
--                 " : " &
--                 Lb_Test_Atomic_Operation (Current_Language) &
--                 Lb_Must_Not_Be (Current_Language) &
--                 To_Unbounded_String (" Empty")));
--        end if;
--
--
--         if (placement_policy = "") then
--           Raise_Exception
--             (Invalid_Parameter'Identity,
--              To_String
--                (Lb_CFG_Node (Current_Language) &
--                 " " &
--                 Name &
--                 " : " &
--                 Lb_Allocate_Atomic_Operation (Current_Language) &
--                 Lb_Must_Not_Be (Current_Language) &
--                 To_Unbounded_String (" Empty")));
--        end if;

   end Check_Atomic_Operation;




     ----------------------------------------------------
   -- ADD - ATOMIC_OPERATION
   ----------------------------------------------------
procedure Add_Atomic_Operation
     (my_atomic_operations		: in out Atomic_Operations_Set;
      a_atomic_operation		: in out Atomic_Operation_Ptr;
      name			: in Unbounded_String;
      previous_nodes		: in CFG_Nodes_Table;
      next_nodes		: in CFG_Nodes_Table;
      node_type			: in CFG_Node_Type;
      graph_type		: in CFG_Graph_Type;
      task_sort			: in Task_Sort_Type;
--      loop_sequence 		: in Atomic_Operations_Table;
      processor_sort 		: in Processor_Sort_Type;
      feasibility_test		: in Feasibility_Test_Type)
--      loop_bound		: in Integer)
   is
      my_iterator             	: Atomic_Operations_Iterator;


         begin

      Check_Atomic_Operation(name,
                        previous_nodes,
                        next_nodes,
                        node_type,
                        graph_type,
                        task_sort,
--                        loop_sequence,
                        processor_sort,
			feasibility_test);
   --                     loop_bound);

      if (get_number_of_elements (my_atomic_operations) > 1) then
         reset_iterator(my_atomic_operations,my_iterator);

         loop
            current_element(my_atomic_operations,a_atomic_operation,my_iterator);
            if(name = a_atomic_operation.name) then
               Raise_Exception
                 (Invalid_Parameter'Identity,
                  To_String
                    (Lb_CFG_Node (Current_Language) &
                     " " &
                     Name &
                     " : " &
                     Lb_CFG_Node_Name (Current_Language) &
                     Lb_Already_Defined (Current_Language)));
            end if;
            exit when is_last_element (my_atomic_operations, my_iterator);
            next_element (my_atomic_operations, my_iterator);
         end loop;
      end if;

      a_atomic_operation				:= new Atomic_Operation;
      a_atomic_operation.task_sorting 			:= task_sort;
--      a_atomic_operation.loop_sequence			:= loop_sequence;
      a_atomic_operation.feasibility_test		:= feasibility_test;
      a_atomic_operation.processor_sorting			:= processor_sort;
--      a_atomic_operation.loop_bound			:= 0;



      a_atomic_operation.name 				:= name;
      a_atomic_operation.previous_nodes			:= previous_nodes;
      a_atomic_operation.next_nodes			:= next_nodes;
      a_atomic_operation.node_type 			:= node_type;
      a_atomic_operation.graph_type			:= graph_type;

      add(my_atomic_operations,a_atomic_operation);

      exception
      when CFG_Node_Set.full_set =>
         Raise_Exception
           (Invalid_Parameter'Identity,
            To_String (Lb_Can_Not_Define_More_CFG_Node (Current_Language)));
   end Add_Atomic_Operation;

   procedure Add_Atomic_Operation
     (my_atomic_operations		: in out Atomic_Operations_Set;
      name			: in Unbounded_String;
      previous_nodes		: in CFG_Nodes_Table;
      next_nodes		: in CFG_Nodes_Table;
      node_type			: in CFG_Node_Type;
      graph_type		: in CFG_Graph_Type;
      task_sort			: in Task_Sort_Type;
--      loop_sequence 		: in Atomic_Operations_Table;
      processor_sort 		: in Processor_Sort_Type;
      feasibility_test		: in Feasibility_Test_Type)
--      loop_bound		: in Integer)
   is
      a_atomic_operation		: Atomic_Operation_Ptr;
   begin
      Add_Atomic_Operation(my_atomic_operations         	=> my_Atomic_Operations,
                   a_atomic_operation			=> a_atomic_operation,
                   name                 	=> name,
                   previous_nodes      		=> previous_nodes,
                   next_nodes          		=> next_nodes,
                   node_type            	=> node_type,
                   graph_type           	=> graph_type,
                   task_sort		 	=> task_sort,
--                   loop_sequence		=> loop_sequence,
                   processor_sort			=> processor_sort,
                   feasibility_test 		=> feasibility_test);
--                   loop_bound          		=> loop_bound);
   exception
      when CFG_Node_Set.full_set =>
         Raise_Exception
           (Invalid_Parameter'Identity,
            To_String (Lb_Can_Not_Define_More_CFG_Node (Current_Language)));
   end Add_Atomic_Operation;
   -----------------------------------------------------------------------------------------
--   ADD SORT_OPERATION
-------------------------------------------------------------------------------


    ------------------------------------------------------
   -- UPDATE - ATOMIC_OPERATION
   ------------------------------------------------------
   procedure Update_Atomic_Operation
     (my_atomic_operations		: in out Atomic_Operations_Set;
      name			: in Unbounded_String;
      previous_nodes		: in CFG_Nodes_Table;
      next_nodes		: in CFG_Nodes_Table;
      node_type			: in CFG_Node_Type;
      graph_type		: in CFG_Graph_Type;
      task_sort			: in Task_Sort_Type;
 --     loop_sequence 		: in Atomic_Operations_Table;
      processor_sort 		: in Processor_Sort_Type;
      feasibility_test		: in Feasibility_Test_Type)
--      loop_bound		: in Integer)
   is
      a_atomic_operation		: Atomic_Operation_Ptr;
   begin
      a_atomic_operation := Search_Atomic_Operation(my_atomic_operations,name);

      Delete_Atomic_Operation(my_atomic_operations,a_atomic_operation);

      Add_Atomic_Operation(my_atomic_operations        => my_Atomic_Operations,
                   a_atomic_operation			=> a_atomic_operation,
                   name                 	=> name,
                   previous_nodes      		=> previous_nodes,
                   next_nodes          		=> next_nodes,
                   node_type            	=> node_type,
                   graph_type           	=> graph_type,
--                   sort_atomic_operation 	=> sort_atomic_operation,
                   task_sort		 	=> task_sort,
--                   loop_sequence		=> loop_sequence,
                   processor_sort			=> processor_sort,
                   feasibility_test 		=> feasibility_test);
--                   loop_bound          		=> loop_bound);

   end Update_Atomic_Operation;
   ----------------------------------------------------
   -- ADD -(CFG_NODE) ATOMIC_OPERATION
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
      feasibility_test		: in Feasibility_Test_Type)
--      loop_bound		: in Integer)
   is
      my_iterator             	: CFG_Nodes_Iterator;
      new_atomic_operation	: Atomic_Operation_Ptr;

         begin

      Check_Atomic_Operation(name,
                        previous_nodes,
                        next_nodes,
                        node_type,
                        graph_type,
                        task_sort,
--			loop_sequence,
			processor_sort,
			feasibility_test);
--                        loop_bound);

      if (get_number_of_elements (my_cfg_nodes) > 1) then
         reset_iterator(my_cfg_nodes,my_iterator);

         loop
            current_element(my_cfg_nodes,a_cfg_node,my_iterator);
            if(name = a_cfg_node.name) then
               Raise_Exception
                 (Invalid_Parameter'Identity,
                  To_String
                    (Lb_CFG_Node (Current_Language) &
                     " " &
                     Name &
                     " : " &
                     Lb_CFG_Node_Name (Current_Language) &
                     Lb_Already_Defined (Current_Language)));
            end if;
            exit when is_last_element (my_cfg_nodes, my_iterator);
            next_element (my_cfg_nodes, my_iterator);
         end loop;
      end if;

      new_atomic_operation				:= new Atomic_Operation;
      new_atomic_operation.task_sorting			:= task_sort;
--      new_atomic_operation.loop_sequence		:= loop_sequence;
      new_atomic_operation.processor_sorting			:= processor_sort;
      new_atomic_operation.feasibility_test		:= feasibility_test;
--      new_atomic_operation.loop_bound			:= 0;


      a_cfg_node				:= CFG_Node_Ptr (new_atomic_operation);
      a_cfg_node.name 				:= name;
      a_cfg_node.previous_nodes			:= previous_nodes;
      a_cfg_node.next_nodes			:= next_nodes;
      a_cfg_node.node_type 			:= node_type;
      a_cfg_node.graph_type			:= graph_type;

      add(my_cfg_nodes,a_cfg_node);

      exception
      when CFG_Node_Set.full_set =>
         Raise_Exception
           (Invalid_Parameter'Identity,
            To_String (Lb_Can_Not_Define_More_CFG_Node (Current_Language)));
   end Add_CFG_Node;

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
      feasibility_test		: in Feasibility_Test_Type)
--      loop_bound		: in Integer)
   is
      a_cfg_node		: CFG_Node_Ptr;
   begin
      Add_CFG_Node(my_cfg_nodes         	=> my_cfg_nodes,
                   a_cfg_node			=> a_cfg_node,
                   name                 	=> name,
                   previous_nodes      		=> previous_nodes,
                   next_nodes          		=> next_nodes,
                   node_type            	=> node_type,
                   graph_type           	=> graph_type,
                   task_sort		 	=> task_sort,
--                   loop_sequence		=> loop_sequence,
                   processor_sort			=> processor_sort,
                   feasibility_test 		=> feasibility_test);
--                   loop_bound          		=> loop_bound);
   exception
      when CFG_Node_Set.full_set =>
         Raise_Exception
           (Invalid_Parameter'Identity,
            To_String (Lb_Can_Not_Define_More_CFG_Node (Current_Language)));
   end Add_CFG_Node;

       ------------------------------------------------------
   -- SEARCH
   ------------------------------------------------------
   function Search_Atomic_Operation
     (my_atomic_operations	: in Atomic_Operations_Set;
      name          	: in Unbounded_String)
      return		Atomic_Operation_Ptr
   is
      my_iterator 	: Atomic_Operations_Iterator;
      a_atomic_operation : Atomic_Operation_Ptr;
      result      	: Atomic_Operation_Ptr;
      found 		: Boolean := False;
   begin
      reset_iterator(my_atomic_operations,my_iterator);
      loop
         current_element (my_atomic_operations, a_atomic_operation, my_iterator);
         if (a_atomic_operation.name = name) then
            found  := True;
            result := a_atomic_operation;
         end if;

         exit when is_last_element (my_atomic_operations,my_iterator);
         next_element (my_atomic_operations,my_iterator);
      end loop;

      if not Found then
         Raise_Exception
           (CFG_Node_Not_Found'Identity,
            To_String (Lb_CFG_Node_Name (Current_Language) & "=" & Name));
      end if;

      return Result;

   end Search_Atomic_Operation;

   function Search_Atomic_Operation_By_Id
     (my_atomic_operations 	: in Atomic_Operations_Set;
      id 		: in Unbounded_String)
      return            Atomic_Operation_Ptr
   is
      my_iterator 	: Atomic_Operations_Iterator;
      a_atomic_operation  	: Atomic_Operation_Ptr;
      result      	: Atomic_Operation_Ptr;
      found 		: Boolean := False;
   begin
      reset_iterator(my_atomic_operations,my_iterator);
      loop
         current_element (my_atomic_operations, a_atomic_operation, my_iterator);
         if (a_atomic_operation.cheddar_private_id = id) then
            found  := True;
            result := a_atomic_operation;
         end if;

         exit when is_last_element (my_atomic_operations,my_iterator);
         next_element (my_atomic_operations,my_iterator);
      end loop;

      if not Found then
         Raise_Exception
           (CFG_Node_Not_Found'Identity,
            To_String (Lb_CFG_Node_Name (Current_Language) & "=" & id));
      end if;

      return Result;

   end Search_Atomic_Operation_By_Id;

   ------------------------------------------------------
   -- DELETE
   ------------------------------------------------------
   procedure Delete_Atomic_Operation
     (my_atomic_operations		: in out Atomic_Operations_Set;
      a_atomic_operation		: in out Atomic_Operation_Ptr)
   is
   begin
      delete (my_atomic_operations, a_atomic_operation);
   end Delete_Atomic_Operation;

   procedure Delete_Atomic_Operation
     (my_atomic_operations		: in out Atomic_Operations_Set;
      name 			: in Unbounded_String)
   is
      a_atomic_operation		: Atomic_Operation_Ptr;
   begin
      a_atomic_operation := Search_Atomic_Operation(my_atomic_operations, name);
      delete (my_atomic_operations, a_atomic_operation);
   end Delete_Atomic_Operation;
   ------------------------------------------------------
   -- NEXT, PREVIOUS
   ------------------------------------------------------
   procedure Add_Next_Atomic_Operation
     (my_atomic_operations		: in out Atomic_Operations_Set;
      name			: in Unbounded_String;
      next_operation_name		: in Unbounded_String)
   is
      a_atomic_operation		: Atomic_Operation_Ptr;
      a_next_atomic_operation	: Atomic_Operation_Ptr;
   begin
      a_atomic_operation := Search_Atomic_Operation(my_atomic_operations,name);
      a_next_atomic_operation := Search_Atomic_Operation(my_atomic_operations,next_operation_name);

      add(a_atomic_operation.next_nodes,CFG_Node_Ptr(a_next_atomic_operation));
   end Add_Next_Atomic_Operation;

   procedure Add_Next_Atomic_Operation_By_Id
     (my_atomic_operations		: in out Atomic_Operations_Set;
      a_atomic_operation		: in out Atomic_Operation_Ptr;
      next_operation_id		: in Unbounded_String)
   is
      a_next_atomic_operation	: Atomic_Operation_Ptr;
   begin
      a_next_atomic_operation := Search_Atomic_Operation_By_Id(my_atomic_operations,next_operation_id);
      add(a_atomic_operation.next_nodes,CFG_Node_Ptr(a_next_atomic_operation));
   end Add_Next_Atomic_Operation_By_Id;

   procedure Add_Previous_Atomic_Operation
     (my_atomic_operations	: in out Atomic_Operations_Set;
      name			: in Unbounded_String;
      previous_operation_name	: in Unbounded_String)
   is
      a_atomic_operation		: Atomic_Operation_Ptr;
      a_previous_atomic_operation	: Atomic_Operation_Ptr;
   begin
      a_atomic_operation := Search_Atomic_Operation(my_atomic_operations,name);
      a_previous_atomic_operation := Search_Atomic_Operation(my_atomic_operations,previous_operation_name);

      add(a_atomic_operation.previous_nodes,CFG_Node_Ptr(a_previous_atomic_operation));
   end Add_Previous_Atomic_Operation;

   procedure Add_Previous_Atomic_Operation_By_Id
     (my_atomic_operations		: in out Atomic_Operations_Set;
      a_atomic_operation		: in out Atomic_Operation_Ptr;
      previous_operation_id		: in Unbounded_String)
   is
      a_previous_atomic_operation	: Atomic_Operation_Ptr;
   begin
      a_previous_atomic_operation := Search_Atomic_Operation_By_Id(my_atomic_operations,previous_operation_id);
      add(a_atomic_operation.previous_nodes,CFG_Node_Ptr(a_previous_atomic_operation));
   end Add_Previous_Atomic_Operation_By_Id;

   procedure Set_Previous_Atomic_Operations
     (my_atomic_operations 		: in out Atomic_Operations_Set)
   is
      my_iterator             	: Atomic_Operations_Iterator;
      a_atomic_operation		: Atomic_Operation_Ptr;
   begin
      reset_iterator(my_atomic_operations,my_iterator);
      loop
         current_element(my_atomic_operations,a_atomic_operation,my_iterator);

         for i in 0..a_atomic_operation.next_nodes.Nb_Entries-1 loop

            Add_Previous_Atomic_Operation(my_atomic_operations 		=> my_atomic_operations,
                                     name            		=> a_atomic_operation.next_nodes.Entries(i).name,
                                     previous_operation_name  	=> a_atomic_operation.name);
         end loop;

         exit when is_last_element (my_atomic_operations, my_iterator);
         next_element (my_atomic_operations, my_iterator);
      end loop;

   end Set_Previous_Atomic_Operations;
 end CFG_Node_Set.Atomic_Operation_Set;
