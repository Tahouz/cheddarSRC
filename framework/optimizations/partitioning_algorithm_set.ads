
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
with Framework_Config;     	use Framework_Config;
with Ada.Exceptions;    use Ada.Exceptions;
with Translate;         use Translate;
with Objects;           use Objects;
with Objects.extended;  use Objects.extended;
with unbounded_strings; use unbounded_strings;
with Atomic_Operations;	use Atomic_Operations;
with CFG_Node_Set;	use CFG_Node_Set;
with CFG_Nodes;		use CFG_Nodes;
with sets;
with Task_Groups; use Task_Groups;
with Processors; use Processors;


package Partitioning_Algorithm_Set is

   ----------------------------------------------------
   ----------------------------------------------------
   -- This package is used for Modeling Partition Algorithms
   -- each node is an atomic operation.
   --
   -- Notes: in the implementation of Cheddar, a Partition Algorithms is always instantiated
   --  an Atomic_Operation.

	-- Definition of a set
   ----------------------------------------------------


   package Partitioning_Algorithm_Set is new Sets (
                                     max_element    => Framework_Config.Max_CFG_Nodes,
                                     element        => Partitioning_Algorithm_Ptr,
                                     free           => Free,
                                     copy           => Copy,
                                     put            => Put,
                                     xml_string     => XML_String,
                                     xml_ref_string => XML_Ref_String);

   use Partitioning_Algorithm_Set;

   type Partitioning_Algorithms_Set is new Partitioning_Algorithm_Set.set with private;

   subtype Partitioning_Algorithms_Range is Partitioning_Algorithm_Set.element_range;
   subtype Partitioning_Algorithms_Iterator is Partitioning_Algorithm_Set.iterator;

     ----------------------------------------------------------
   -- Exceptions defined in the set package
   ----------------------------------------------------------

   -- Raised when a given CFG node is not in a CFG node set
   --
   partitioning_algorithm_Not_Found : exception;

   -- Raised when parameters provided to Add_Basic_Block are wrong
   --
   Invalid_Parameter : exception;
     ----------------------------------------------------
   -- CHECK - Partitioning_Algorithm
   ----------------------------------------------------
   procedure Check_Partitioning_Algorithm
     (My_Partitioning_Algorithm	: in Partitioning_Algorithms_Set;
      name			: in Unbounded_String);
--      task_set			: in Generic_Task_Group_Ptr;
--      processor_set		: in Multi_Cores_Processor_Ptr);

  ----------------------------------------------------
   -- ADD - Partitioning_Algorithm
   ----------------------------------------------------
   procedure Add_Partitioning_Algorithm
     (My_Partitioning_Algorithms	: in out Partitioning_Algorithms_Set;
		A_Partitioning_Algorithm: in out Partitioning_Algorithm_Ptr;
      		name			: in Unbounded_String;
--		task_set		: in Generic_Task_Group_Ptr;
--		Processor_set		: in Multi_Cores_Processor_Ptr;
      		task_sorting		: in Task_Sort_Type;
      		looping			: in Loop_Operation_Type;
      		processor_sorting	: in Processor_Sort_Type;
      		feasibility_test	: in Feasibility_Test_Type);

   procedure Add_Partitioning_Algorithm
     (My_Partitioning_Algorithms	: in out Partitioning_Algorithms_Set;
      		name			: in Unbounded_String;
--		task_set		: in Generic_Task_Group_Ptr;
--		Processor_set		: in Multi_Cores_Processor_Ptr;
      		task_sorting		: in Task_Sort_Type;
      		looping			: in Loop_Operation_Type;
      		processor_sorting	: in Processor_Sort_Type;
      		feasibility_test	: in Feasibility_Test_Type);

    ------------------------------------------------------
   -- UPDATE - Partitioning_Algorithm
   ------------------------------------------------------
   procedure Update_Partitioning_Algorithm
          (My_Partitioning_Algorithms	: in out Partitioning_Algorithms_Set;
           	name			: in Unbounded_String;
           	New_name		: in Unbounded_String;
--		task_set		: in Generic_Task_Group_Ptr;
--		Processor_set		: in Multi_Cores_Processor_Ptr;
      		task_sorting		: in Task_Sort_Type;
      		looping			: in Loop_Operation_Type;
      		processor_sorting	: in Processor_Sort_Type;
      		feasibility_test	: in Feasibility_Test_Type);

   ------------------------------------------------------
   -- SEARCH
   ------------------------------------------------------
   function Search_Partitioning_Algorithm
     (My_Partitioning_Algorithms	: in Partitioning_Algorithms_Set;
      name          			: in Unbounded_String)
      return		Partitioning_Algorithm_Ptr;


   function Search_Partitioning_Algorithm_By_Id
     (My_Partitioning_Algorithms	: in Partitioning_Algorithms_Set;
      id          			: in Unbounded_String)
      return		Partitioning_Algorithm_Ptr;


   ------------------------------------------------------
   -- DELETE
   ------------------------------------------------------
   procedure Delete_Partitioning_Algorithm
     (My_Partitioning_Algorithms	: in out Partitioning_Algorithms_Set;
      A_Partitioning_Algorithm		: in out Partitioning_Algorithm_Ptr);


   procedure Delete_Partitioning_Algorithm
     (My_Partitioning_Algorithms	: in out Partitioning_Algorithms_Set;
      name 				: in Unbounded_String);
private
   type Partitioning_Algorithms_Set is new Partitioning_Algorithm_Set.set with null record;

end Partitioning_Algorithm_Set;
