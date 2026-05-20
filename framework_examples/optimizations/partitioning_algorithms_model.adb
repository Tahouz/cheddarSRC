
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

------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Text_IO;                   	use Text_IO;
with Ada.Strings.Unbounded;     	use Ada.Strings.Unbounded;
with Unbounded_Strings;         	use Unbounded_Strings;
use Unbounded_Strings.Strings_Table_Package;
use Unbounded_Strings.Unbounded_String_List_Package;
with Ada.Exceptions;            	use Ada.Exceptions;
with Partitioning_Algorithm_Set; 	use Partitioning_Algorithm_Set;
with Atomic_Operations; 		use Atomic_Operations;
with Task_Set; use Task_Set;
with Tasks; use Tasks;
with Framework_Config; use Framework_Config;
with Processor_Set; use Processor_Set;
with Processors; use Processors;
with Translate; use Translate;
with Systems; use Systems;
with Scheduler_Interface; use Scheduler_Interface;
with Multiprocessor_Services; use Multiprocessor_Services;
with Address_Space_Set; use Address_Space_Set;
with Scheduler; use Scheduler;
with debug; use debug;
with core_units; use core_units;
use core_units.Core_Units_Table_Package;

package body partitioning_algorithms_model is

    -- Define a Partitioning Algorithm
   procedure partitioning_first_fit
     (My_Partitioning_Algorithms : in out Partitioning_Algorithms_Set;
      A_Partitioning_Algorithm	 : in out Partitioning_Algorithm_Ptr)
   is

   begin

      Add_Partitioning_Algorithm
        (My_Partitioning_Algorithms,
         A_Partitioning_Algorithm,
         To_Unbounded_String ("Rate_Monotonic_First_Fit"),
         Task_Period,
         RMFF_loop,
         Processor_Utilization,
         Condition_IP_Test);
end partitioning_first_fit;

procedure build_tasks_set
     (my_tasks : in out Tasks_Set)
   is

   begin

      Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_1"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 6,
               Period                  => 10,
               Deadline                => 4,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 6,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_2"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 8,
               Period                  => 20,
               Deadline                => 8,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 5,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_3"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 8,
               Period                  => 30,
               Deadline                => 9,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 4,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_4"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 5,
               Period                  => 40,
               Deadline                => 6,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 3,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_5"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 1,
               Period                  => 50,
               Deadline                => 2,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 2,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_6"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 1,
               Period                  => 60,
               Deadline                => 1,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 1,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

            Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_7"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 1,
               Period                  => 70,
               Deadline                => 1,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 1,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

            Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_8"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 1,
               Period                  => 80,
               Deadline                => 10,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 1,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_9"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 10,
               Period                  => 90,
               Deadline                => 9,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 8,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_10"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 8,
               Period                  => 100,
               Deadline                => 8,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 5,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_11"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 5,
               Period                  => 110,
               Deadline                => 4,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 1,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_12"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 9,
               Period                  => 120,
               Deadline                => 8,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 9,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_13"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 3,
               Period                  => 130,
               Deadline                => 3,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 9,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_14"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 1,
               Period                  => 140,
               Deadline                => 3,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 5,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

            Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_15"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 9,
               Period                  => 150,
               Deadline                => 1,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 12,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

            Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_16"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 7,
               Period                  => 160,
               Deadline                => 5,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 4,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

            Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_17"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 9,
               Period                  => 170,
               Deadline                => 8,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 9,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_18"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 3,
               Period                  => 180,
               Deadline                => 3,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 9,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_19"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 1,
               Period                  => 190,
               Deadline                => 9,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 5,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

            Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_20"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 9,
               Period                  => 200,
               Deadline                => 6,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 12,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

            Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_21"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 1,
               Period                  => 210,
               Deadline                => 3,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 5,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

            Add_Task(My_Tasks                => my_tasks,
               Name                    => To_Unbounded_String("Task_22"),
               Cpu_Name                => To_Unbounded_String("processor1"),
               Address_Space_Name      => To_Unbounded_String("ADDRESS_SPACE_A"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 9,
               Period                  => 220,
               Deadline                => 5,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 12,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

   end build_tasks_set;

   procedure build_processors_set
     (My_Processors 	: in out Processors_Set;
      My_Core	    	: in out Core_Units_Set;
      New_Processor  	: in out Integer;
      New_Core		: in out Integer)
   is
      a_core_unit_table : core_units_table;
      a_core            : Core_Unit_Ptr;


   begin
      New_Core := 1;
      New_Processor := 1;
      loop
         New_Core := New_Core + 1;
      Add_core_unit(My_Core ,
                    a_core,
      	suppress_space(to_unbounded_string("core" & New_Core'Img )),
      	preemptive,
      	0,
      	1.0,
      	40,
      	0,
      	0,
      	to_unbounded_string(""),
      	Rate_Monotonic_Protocol);
         Add (a_core_unit_table, a_core);

         exit when New_Core = 5;
         end loop;
      loop
        New_Processor := New_Processor + 1;
      Add_Processor (My_Processors,
                     suppress_space(to_unbounded_string("processor" & New_Processor'Img)),
                     a_core_unit_table);

         exit when New_Processor = 10;
         end loop;
   end build_processors_set;

end partitioning_algorithms_model;


