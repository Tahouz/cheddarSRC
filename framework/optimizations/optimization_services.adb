
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

with Ada.Numerics;                      use Ada.Numerics;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Statements;                        use Statements;
with Expressions;                       use Expressions;
use Expressions.Variables_Type_Package;
with Ada.Strings.Unbounded.Text_IO;     use Ada.Strings.Unbounded.Text_IO;
with unbounded_strings;                 use unbounded_strings;
with Ada.IO_Exceptions;                 use Ada.IO_Exceptions;
with Ada.Integer_Text_IO;       	use Ada.Integer_Text_IO;
with Ada.Exceptions;                    use Ada.Exceptions;
with Text_IO;                           use Text_IO;
with Integer_Arrays;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Processor_Set; use Processor_Set;
with Processors; use Processors;
with Framework_Config; use Framework_Config;
with Translate; use Translate;
with Systems; use Systems;
with Scheduler_Interface; use Scheduler_Interface;
with Multiprocessor_Services; use Multiprocessor_Services;
with Address_Space_Set; use Address_Space_Set;
with Scheduler; use Scheduler;
with Partitioning_Algorithm_Set; use Partitioning_Algorithm_Set;
with debug; use debug;
with core_units; use core_units;
use core_units.Core_Units_Table_Package;



package body optimization_services  is

   procedure create_New_Processors
     (My_Processors 	: in out Processors_Set;
      My_Core	    	: in out Core_Units_Set;
      New_Processor  	: in out Integer;
      New_Core		: in out Integer)
   is
      a_core_unit_table : core_units_table;
      a_core            : Core_Unit_Ptr;

   begin
      Add_core_unit(My_Core ,
                    a_core,
      	suppress_space(to_unbounded_string("core" & New_Core'Img )),
      	not_preemptive,
      	0,
      	1.0,
      	40,
      	0,
      	0,
      	to_unbounded_string(""),
      	Rate_Monotonic_Protocol);
	Add (a_core_unit_table, a_core);
      Add_Processor (My_Processors,
                     suppress_space(to_unbounded_string("processor" & New_Processor'Img)),
                     a_core_unit_table);
   end create_New_Processors;


-- Run a Partitioning Algorithm Model

   Procedure run_model
     (My_Processors 		: in out Processors_Set;
      My_Core			: in out core_units_Set;
      New_Processor 		: in out Integer;
      New_Core			: in out Integer;
      My_Result_Tasks   	: in out Tasks_Set;
      My_Tasks      		: in Tasks_Set;
      A_Partitioning_Algorithm	: Partitioning_Algorithm_Ptr)

   is
      A_Task_Result            	: Periodic_Task_Ptr;
      My_Task_Iterator_Result 	: Tasks_Iterator;
      Temp_Task_Iterator      	: Tasks_Iterator;
      A_Processor             	: Generic_Processor_Ptr;
      My_Processor_Iterator   	: Processors_Iterator;

      Num_Of_Tasks            	: Integer := 0;
      Num_Of_Processors		: Integer := 0;
      Num_Of_Task1            	: Integer := 0;

      Task_Utilization, Total_Utilization : Float   := 0.0;

   begin


      create_New_Processors(My_Processors, My_Core, New_Processor,New_Core);
      -- Create a copy of task set for the task results
      duplicate (My_Tasks, My_Result_Tasks);

      -- Partitioning Algortithm  task Sorting by increasing peroid
      if  (A_Partitioning_Algorithm.task_sorting = Task_Period)  then
         sort (My_Result_Tasks, Increasing_Period'Access);

      -- reset task and processor sets
      reset_iterator (My_Result_Tasks, My_Task_Iterator_Result);
      Temp_Task_Iterator := My_Task_Iterator_Result;
      current_element (My_Result_Tasks,Generic_Task_Ptr (A_Task_Result), My_Task_Iterator_Result);

      reset_iterator (My_Processors, My_Processor_Iterator);
      current_element (My_Processors, A_Processor, My_Processor_Iterator);

       end if;
      -- Partitioning Algortithm Tasks Looping
      if A_Partitioning_Algorithm.looping = RMFF_loop then
         loop
            Num_Of_Task1 := Num_Of_Task1 + 1;
            loop

            reset_iterator (My_Result_Tasks, My_Task_Iterator_Result);
            current_element(My_Result_Tasks, Generic_Task_Ptr (A_Task_Result), My_Task_Iterator_Result);
            Num_Of_Tasks      := 0;
	    Total_Utilization := 0.0;
             -- Calculate Total_Utilization
               loop
               if A_Task_Result.cpu_name = A_Processor.name then
                  Num_Of_Tasks      := Num_Of_Tasks + 1;
                  Total_Utilization := Total_Utilization +
                    Float (A_Task_Result.capacity) /
                    Float (A_Task_Result.period);
               end if;
               exit when
                    is_last_element(My_Result_Tasks,My_Task_Iterator_Result);
               	    next_element (My_Result_Tasks, My_Task_Iterator_Result);
                    current_element(My_Result_Tasks,Generic_Task_Ptr (A_Task_Result),My_Task_Iterator_Result);
               end loop;

	     -- Partitioning Algortithm Feasibility Test
               if  (A_Partitioning_Algorithm.feasibility_test = Condition_IP_Test) then
            	My_Task_Iterator_Result := Temp_Task_Iterator;
            	current_element (My_Result_Tasks,Generic_Task_Ptr (A_Task_Result),My_Task_Iterator_Result);

                  Task_Utilization := Float (A_Task_Result.capacity) / Float (A_Task_Result.period);

            	if (Task_Utilization <= 2.0 * (1.0 /(1.0 + Total_Utilization / Float (Num_Of_Tasks)) ** Num_Of_Tasks) - 1.0)  then

                     A_Task_Result.cpu_name := A_Processor.name;
                     --put_debug ("Task Name & Cpu :" & A_Task_Result.name & " = " & A_Task_Result.cpu_name, very_verbose);

		  -- reset_iterator (My_Processors, My_Processor_Iterator);
                  current_element (My_Processors, A_Processor, My_Processor_Iterator);

                     exit;
                  else
                     if is_last_element (My_Processors, My_Processor_Iterator)
                  then
                        New_Processor := New_Processor + 1;
                         New_Core := New_Core + 1;
                        Num_Of_Processors := New_Processor;
                     create_New_Processors (My_Processors,My_Core, New_Processor,New_Core );

               end if;
			next_element (My_Processors, My_Processor_Iterator);
                     current_element (My_Processors, A_Processor, My_Processor_Iterator);

                  end if;

                  end if;

--		put_line ( A_Task_Result.name & " to " & A_processor.name );
            end loop;

         exit when is_last_element (My_Result_Tasks, My_Task_Iterator_Result);
         next_element (My_Result_Tasks, My_Task_Iterator_Result);
         Temp_Task_Iterator := My_Task_Iterator_Result;
         end loop;

         end if;
sort (My_Result_Tasks, Increasing_Name'Access);


      put_debug ("Number of Tasks :" & Num_Of_Task1'Img, very_verbose);
      put_debug ("Number of Processors :" & Num_Of_Processors'Img, very_verbose);

   end run_model;

end optimization_services;
