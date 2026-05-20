
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

with Ada.Exceptions;    use Ada.Exceptions;
with Translate;         use Translate;
with Objects;           use Objects;
with Objects.extended;  use Objects.extended;
with unbounded_strings; use unbounded_strings;
with Atomic_Operations;		use Atomic_Operations;
with Text_IO;			use Text_IO;
with Ada.Integer_Text_IO;       use Ada.Integer_Text_IO;
with Integer_Arrays;		use Integer_Arrays;
with Tables;

with sets;
with Task_Groups; use Task_Groups;
with Processors; use Processors;

package body Partitioning_Algorithm_Set is

     ----------------------------------------------------
   -- CHECK - Partitioning_Algorithm
   ----------------------------------------------------
   procedure Check_Partitioning_Algorithm
     (My_Partitioning_Algorithm	: in Partitioning_Algorithms_Set;
      name			: in Unbounded_String)
--      task_set			: in Generic_Task_Group_Ptr;
--      processor_set		: in Multi_Cores_Processor_Ptr)
   is

   begin
      if (name = "") then
         Raise_Exception
           (Invalid_Parameter'Identity,
            To_String
              (Lb_Partitioning_Algorithm_Name (Current_Language) &
               Lb_Mandatory (Current_Language)));
      end if;

      if not Is_A_Valid_Identifier (Name) then
         Raise_Exception
           (Invalid_Parameter'Identity,
            To_String
              (Lb_Partitioning_Algorithm (Current_Language) &
               Name &
               " : " &
               Lb_Partitioning_Algorithm_Name (Current_Language) &
               Lb_Colon &
               Lb_Invalid_Identifier (Current_Language)));
      end if;


--        if (task_set.name = "") then
--           Raise_Exception
--             (Invalid_Parameter'Identity,
--              To_String
--                 (Lb_Partitioning_Algorithm (Current_Language) &
--                  " " &
--                  Name &
--                  " : " &
--                  Lb_Task_Sort_Type (Current_Language) &
--                  Lb_Mandatory (Current_Language)));
--        end if;
--
--        if (processor_set.name = "") then
--           Raise_Exception
--             (Invalid_Parameter'Identity,
--              To_String
--                 (Lb_Partitioning_Algorithm (Current_Language) &
--                  " " &
--                  Name &
--                  " : " &
--                  Lb_Loop_Operation_Type (Current_Language) &
--                  Lb_Mandatory (Current_Language)));
--        end if;


   end Check_Partitioning_Algorithm;

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
      		feasibility_test	: in Feasibility_Test_Type)
   is
      My_iterator             	: Partitioning_Algorithms_Iterator;

         begin

  Check_Partitioning_Algorithm
     (My_Partitioning_Algorithms,
	name);
--	task_set,
--	processor_set);

      if (get_number_of_elements (My_Partitioning_Algorithms) > 1) then
         reset_iterator(My_Partitioning_Algorithms,My_iterator);

         loop
            current_element(My_Partitioning_Algorithms,A_Partitioning_Algorithm,My_iterator);
            if(name = A_Partitioning_Algorithm.name) then
               Raise_Exception
                 (Invalid_Parameter'Identity,
                  To_String
                    (Lb_Partitioning_Algorithm (Current_Language) &
                     " " &
                     Name &
                     " : " &
                     Lb_Partitioning_Algorithm_Name (Current_Language) &
                     Lb_Already_Defined (Current_Language)));
            end if;
            exit when is_last_element (My_Partitioning_Algorithms, My_iterator);
            next_element (My_Partitioning_Algorithms, My_iterator);
         end loop;
      end if;

      	A_Partitioning_Algorithm			:= new Partitioning_Algorithm;
        A_Partitioning_Algorithm.name			:= name;
--        A_Partitioning_Algorithm.task_set		:= task_set;
--	A_Partitioning_Algorithm.processor_set		:= processor_set;
	A_Partitioning_Algorithm.task_sorting		:= task_sorting;
	A_Partitioning_Algorithm.looping		:= looping;
	A_Partitioning_Algorithm.processor_sorting	:= processor_sorting;
       	A_Partitioning_Algorithm.feasibility_test	:= feasibility_test;

      add(My_Partitioning_Algorithms,A_Partitioning_Algorithm);

      exception
      when full_set =>
         Raise_Exception
           (Invalid_Parameter'Identity,
            To_String (Lb_Can_Not_Define_More_Partitioning_Algorithm (Current_Language)));
   end Add_Partitioning_Algorithm;
     ----------------------------------------------------
   -- ADD - Partitioning_Algorithm
   ----------------------------------------------------
   procedure Add_Partitioning_Algorithm
     (My_Partitioning_Algorithms	: in out Partitioning_Algorithms_Set;
      		name			: in Unbounded_String;
--		task_set		: in Generic_Task_Group_Ptr;
--		Processor_set		: in Multi_Cores_Processor_Ptr;
      		task_sorting		: in Task_Sort_Type;
      		looping			: in Loop_Operation_Type;
      		processor_sorting	: in Processor_Sort_Type;
      		feasibility_test	: in Feasibility_Test_Type)
   is
      A_Partitioning_Algorithm             : Partitioning_Algorithm_Ptr;

         begin

  Add_Partitioning_Algorithm
        (My_Partitioning_Algorithms,
         A_Partitioning_Algorithm,
         name,
--         task_set,
--        processor_set,
         task_sorting,
         looping,
         processor_sorting,
         feasibility_test);
   end Add_Partitioning_Algorithm;

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
      		feasibility_test	: in Feasibility_Test_Type)
   is
          A_Partitioning_Algorithm             : Partitioning_Algorithm_Ptr;
   begin

      A_Partitioning_Algorithm	:= Search_Partitioning_Algorithm (My_Partitioning_Algorithms, name);
      A_Partitioning_Algorithm.name	 		:= New_name;
--      A_Partitioning_Algorithm.task_set  		:=  task_set;
--      A_Partitioning_Algorithm.processor_set		:=  processor_set;
      A_Partitioning_Algorithm.task_sorting		:=   task_sorting;
      A_Partitioning_Algorithm.looping			:=  looping;
      A_Partitioning_Algorithm.processor_sorting	:=  processor_sorting;
      A_Partitioning_Algorithm.feasibility_test		:=  feasibility_test;

   end Update_Partitioning_Algorithm;

   ------------------------------------------------------
   -- SEARCH
   ------------------------------------------------------
   function Search_Partitioning_Algorithm
     (My_Partitioning_Algorithms	: in Partitioning_Algorithms_Set;
      name          			: in Unbounded_String)
      return		Partitioning_Algorithm_Ptr
   is
      My_iterator 		: Partitioning_Algorithms_Iterator;
      A_Partitioning_Algorithm 	: Partitioning_Algorithm_Ptr;
      result      		: Partitioning_Algorithm_Ptr;
      found 			: Boolean := False;
   begin
      reset_iterator(My_Partitioning_Algorithms,My_iterator);
      loop
         current_element (My_Partitioning_Algorithms, A_Partitioning_Algorithm, My_iterator);
         if (A_Partitioning_Algorithm.name = name) then
            found  := True;
            result := A_Partitioning_Algorithm;
         end if;

         exit when is_last_element (My_Partitioning_Algorithms,My_iterator);
         next_element (My_Partitioning_Algorithms,My_iterator);
      end loop;

      if not Found then
         Raise_Exception
           (partitioning_algorithm_Not_Found'Identity,
            To_String (Lb_Partitioning_Algorithm_Name (Current_Language) & "=" & Name));
      end if;

      return Result;

   end Search_Partitioning_Algorithm;

   function Search_Partitioning_Algorithm_By_Id
     (My_Partitioning_Algorithms	: in Partitioning_Algorithms_Set;
      id          			: in Unbounded_String)
      return		Partitioning_Algorithm_Ptr
   is
      My_iterator 		: Partitioning_Algorithms_Iterator;
      A_Partitioning_Algorithm 	: Partitioning_Algorithm_Ptr;
      Result      		: Partitioning_Algorithm_Ptr;
      Found 			: Boolean := False;
   begin
      reset_iterator(My_Partitioning_Algorithms,My_iterator);
      loop
         current_element (My_Partitioning_Algorithms, A_Partitioning_Algorithm, My_iterator);
         if (A_Partitioning_Algorithm.cheddar_private_id = id) then
            Found  := True;
            Result := A_Partitioning_Algorithm;
         end if;

         exit when is_last_element (My_Partitioning_Algorithms,My_iterator);
         next_element (My_Partitioning_Algorithms,My_iterator);
      end loop;

      if not Found then
         Raise_Exception
           (Partitioning_Algorithm_Not_Found'Identity,
            To_String (Lb_Partitioning_Algorithm_id (Current_Language) & "=" & id));
      end if;

      return Result;

   end Search_Partitioning_Algorithm_By_Id;

   ------------------------------------------------------
   -- DELETE
   ------------------------------------------------------
   procedure Delete_Partitioning_Algorithm
     (My_Partitioning_Algorithms	: in out Partitioning_Algorithms_Set;
      A_Partitioning_Algorithm		: in out Partitioning_Algorithm_Ptr)
   is
   begin
      delete (My_Partitioning_Algorithms, A_Partitioning_Algorithm);
   end Delete_Partitioning_Algorithm;

   procedure Delete_Partitioning_Algorithm
     (My_Partitioning_Algorithms	: in out Partitioning_Algorithms_Set;
      name 				: in Unbounded_String)
   is
      A_Partitioning_Algorithm		: Partitioning_Algorithm_Ptr;
   begin
      A_Partitioning_Algorithm := Search_Partitioning_Algorithm(My_Partitioning_Algorithms, name);
      delete (My_Partitioning_Algorithms, A_Partitioning_Algorithm);
   end Delete_Partitioning_Algorithm;
 end Partitioning_Algorithm_Set;
