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
with Ada.Text_IO, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;
with Ada.Float_Text_IO;		use Ada.Float_Text_IO;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Tasks;			use Tasks;
with Tasks;			use Tasks.Generic_Task_List_Package;
with Task_Set;                  use Task_Set;
with Task_Group_Set;            use Task_Group_Set;
with Task_Groups; 		use Task_Groups;
with Offsets;			use Offsets;
with Offsets;			use Offsets.Offsets_Table_Package;
with Offsets.extended;		use Offsets.extended;
with Tasks; 			use Tasks;
with Address_Space_Set; 	use Address_Space_Set;
with Address_Space_Set; 	use Address_space_Set.Generic_address_space_Set;

with Tables;
with lists;
with sets;
with Ada.Finalization;
with indexed_tables;
with natural_util;
with access_lists;

with Scheduler_Interface; 	use Scheduler_Interface;
with processor_interface; 	use processor_interface;
with Scheduling_Analysis; 	use Scheduling_Analysis;
with Scheduling_Analysis;	use Scheduling_Analysis.Task_Release_Records_Table_Package;
with Scheduling_Analysis;	use Scheduling_Analysis.Relative_Priority_Records_Table_Package;

with Priority_Assignment.Audsley_OPA; 		use Priority_Assignment.Audsley_OPA;
with Priority_Assignment.Audsley_OPA_CRPD_Tree;	use Priority_Assignment.Audsley_OPA_CRPD_Tree;
with Priority_Assignment.Utility;		use Priority_Assignment.Utility;

with binary_trees;
with architecture_factory; use architecture_factory;
with Ada.Calendar; use Ada.Calendar;
with Ada.Calendar.Formatting;
use Ada.Calendar.Formatting;

with Random_Tools;		use Random_Tools;
with Framework_Config; 		use Framework_Config;
with Ada.Text_IO.Unbounded_IO; 	use Ada.Text_IO.Unbounded_IO;
with Processors; 		use Processors;
with Systems; 			use Systems;
with Processor_Set; 		use Processor_Set;
with Ada.Exceptions;
with unbounded_strings; use unbounded_strings;
with Ada.Directories; 	use Ada.Directories;
with Cache_Set; 	use Cache_Set;
with Caches; 		use Caches;
with Scheduler; 	use Scheduler;
with Core_Units; 	use Core_Units;

with initialize_framework; 		  use initialize_framework;
with Priority_Assignment; 		  use Priority_Assignment;
with Tasks.Extended; 			  use Tasks.Extended;
with Integer_Arrays; 			  use Integer_Arrays;
with audsley_opa_crpd_test;               use audsley_opa_crpd_test;
with Priority_Assignment_Test_Printer;    use Priority_Assignment_Test_Printer;

package body audsley_opa_test is

   procedure build_delta_star_set
     (my_task : in out Tasks_Set)
   is
      a_offset : Offset_Type;
      b_offset : Offset_Type;
      c_offset : Offset_Type;
      d_offset : Offset_Type;
      e_offset : Offset_Type;
      f_offset : Offset_Type;

      offset_t_a: Offsets_Table;
      offset_t_b: Offsets_Table;
      offset_t_c: Offsets_Table;
      offset_t_d: Offsets_Table;
      offset_t_e: Offsets_Table;
      offset_t_f: Offsets_Table;

   begin
      Set_Initialize;
      a_offset.offset_value := 4;
      b_offset.offset_value := 5;
      c_offset.offset_value := 0;
      d_offset.offset_value := 7;
      e_offset.offset_value := 27;
      f_offset.offset_value := 0;

      a_offset.activation := 0;
      b_offset.activation := 0;
      c_offset.activation := 0;
      d_offset.activation := 0;
      e_offset.activation := 0;
      f_offset.activation := 0;

      Add(offset_t_a,a_offset);
      Add(offset_t_b,b_offset);
      Add(offset_t_c,c_offset);
      Add(offset_t_d,d_offset);
      Add(offset_t_e,e_offset);
      Add(offset_t_f,f_offset);


      Add_Task(My_Tasks                => my_task,
               Name                    => To_Unbounded_String("Task_F"),
               Cpu_Name                => To_Unbounded_String("CPU_01"),
               Address_Space_Name      => To_Unbounded_String("Address_Space_01"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 6,
               Period                  => 40,
               Deadline                => 30,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 6,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_task,
               Name                    => To_Unbounded_String("Task_E"),
               Cpu_Name                => To_Unbounded_String("CPU_01"),
               Address_Space_Name      => To_Unbounded_String("Address_Space_01"),
               Task_Type               => Periodic_Type,
               Start_Time              => 27,
               Capacity                => 8,
               Period                  => 40,
               Deadline                => 14,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 5,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_task,
               Name                    => To_Unbounded_String("Task_D"),
               Cpu_Name                => To_Unbounded_String("CPU_01"),
               Address_Space_Name      => To_Unbounded_String("Address_Space_01"),
               Task_Type               => Periodic_Type,
               Start_Time              => 7,
               Capacity                => 8,
               Period                  => 40,
               Deadline                => 9,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 4,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_task,
               Name                    => To_Unbounded_String("Task_C"),
               Cpu_Name                => To_Unbounded_String("CPU_01"),
               Address_Space_Name      => To_Unbounded_String("Address_Space_01"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 5,
               Period                  => 20,
               Deadline                => 6,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 3,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_task,
               Name                    => To_Unbounded_String("Task_B"),
               Cpu_Name                => To_Unbounded_String("CPU_01"),
               Address_Space_Name      => To_Unbounded_String("Address_Space_01"),
               Task_Type               => Periodic_Type,
               Start_Time              => 5,
               Capacity                => 1,
               Period                  => 10,
               Deadline                => 2,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 2,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => my_task,
               Name                    => To_Unbounded_String("Task_A"),
               Cpu_Name                => To_Unbounded_String("CPU_01"),
               Address_Space_Name      => To_Unbounded_String("Address_Space_01"),
               Task_Type               => Periodic_Type,
               Start_Time              => 4,
               Capacity                => 1,
               Period                  => 10,
               Deadline                => 1,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 1,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

   end build_delta_star_set;

   procedure test_OPA
   is
      my_task 		: Tasks_Set;
      a_system 		: System;
      a_core		: Core_Unit_Ptr;
   begin
      build_delta_star_set(my_task => my_task);
      OPA(my_tasks => my_task);
      Print_Task_Set(my_task);

      Set_Initialize;
      Initialize (A_System => a_system);

      Add_core_unit(My_core_units  => a_system.Core_units,
                    A_core_unit	   => a_core,
                    Name           => To_Unbounded_String("Core_01"),
                    Is_Preemptive  => preemptive,
                    Quantum        => 0,
                    speed          => 1.0,
                    capacity       => 1,
                    period         => 1,
                    priority       => 1,
                    File_Name      => empty_string,
                    A_Scheduler    => Posix_1003_Highest_Priority_First_Protocol,
                    automaton_name => empty_string,
                    l1_cache       => To_Unbounded_String ("Cache_01"),
                    start_time     => 0);

      Add_Processor(My_Processors => a_system.Processors,
                    Name          => To_Unbounded_String("CPU_01"),
                    a_Core        => a_core);

      Add_Address_Space(My_Address_Spaces => a_system.Address_Spaces,
                        Name              => To_Unbounded_String("Address_Space_01"),
                        Cpu_Name          => To_Unbounded_String("CPU_01"),
                        Text_Memory_Size  => 1024,
                        Stack_Memory_Size => 1024,
                        Data_Memory_Size  => 1024,
                        Heap_Memory_Size  => 1024);

      a_system.Tasks := my_task;

      a_system.Write_To_Xml_File("OPA_Example.xmlv3");
   end test_OPA;

end audsley_opa_test;


