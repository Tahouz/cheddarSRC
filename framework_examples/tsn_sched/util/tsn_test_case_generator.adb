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

with Text_IO;                          use Text_IO;
with Ada.Text_IO;	                   use Ada.Text_IO;
with Ada.Strings.Unbounded;            use Ada.Strings.Unbounded;
with Task_Set;                         use Task_Set;
with Tasks;			                   use Tasks;
with Core_Units;                       use Core_Units;
with Systems;                          use Systems;
with initialize_framework;             use initialize_framework;
with Processor_Set;                    use Processor_Set;
with Scheduler_Interface;              use Scheduler_Interface;
with unbounded_strings;                use unbounded_strings;
with Address_Space_Set;                use Address_Space_Set;
with Buffers;                          use Buffers;
with Buffer_Set;                       use Buffer_Set;
with Queueing_Systems;                 use Queueing_Systems;
with Buffer_Set;                       use Buffers.Buffer_Roles_Package;
with Dependencies;                     use Dependencies;
with Task_Dependencies;                use Task_Dependencies;
with Memories;                         use Memories;
with Memories;                         use Memories.Memories_Table_Package;

package body tsn_test_case_generator is


    procedure Case_Study_01 is
        sys_01 	          : System;
        core_01	          : Core_Unit_Ptr;
    begin
        --------------------------------------------------------------------------
        --System Initialization---------------------------------------------------
        Set_Initialize;
        Initialize (A_System => sys_01);

        Add_core_unit(My_core_units  => sys_01.Core_units,
                      A_core_unit	   => core_01,
                      Name           => To_Unbounded_String("Core_1"),
                      Is_Preemptive  => Not_Preemptive,
                      Quantum        => 0,
                      speed          => 1,
                      capacity       => 1,
                      period         => 1,
                      priority       => 1,
                      File_Name      => empty_string,
                      A_Scheduler    => Posix_1003_Highest_Priority_First_Protocol,
                      scheduling_protocol_name => To_Unbounded_String(""));

        Add_Processor(My_Processors => sys_01.Processors,
                      Name          => To_Unbounded_String("CPU_1"),
                      a_Core        => core_01);

        Add_Address_Space(My_Address_Spaces => sys_01.Address_Spaces,
                          Name              => To_Unbounded_String("Address_Space_1"),
                          Cpu_Name          => To_Unbounded_String("CPU_1"),
                          Text_Memory_Size  => 1024,
                          Stack_Memory_Size => 1024,
                          Data_Memory_Size  => 1024,
                          Heap_Memory_Size  => 1024);

        Add_Task(My_Tasks                => sys_01.Tasks,
                 Name                    => To_Unbounded_String("Task_1"),
                 Cpu_Name                => To_Unbounded_String("CPU_1"),
                 core_name               => empty_string,
                 Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
                 Task_Type               => Periodic_Type,
                 Start_Time              => 0,
                 Capacity                => 8,
                 Period                  => 12,
                 Deadline                => 12,
                 Jitter                  => 0,
                 Blocking_Time           => 0,
                 Priority                => 2,
                 Criticality             => 0,
                 Policy                  => SCHED_FIFO);

        Add_Task(My_Tasks                => sys_01.Tasks,
                 Name                    => To_Unbounded_String("Task_2"),
                 Cpu_Name                => To_Unbounded_String("CPU_1"),
                 core_name               => empty_string,
                 Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
                 Task_Type               => Periodic_Type,
                 Start_Time              => 8,
                 Capacity                => 5,
                 Period                  => 18,
                 Deadline                => 18,
                 Jitter                  => 0,
                 Blocking_Time           => 0,
                 Priority                => 1,
                 Criticality             => 0,
                 Policy                  => SCHED_FIFO);   

        sys_01.Write_To_Xml_File("xml/TSN_Sched_Case_Study_01.xmlv3");
        Put_Line("Export system to xml/TSN_Sched_Case_Study_01.xmlv3");

    end Case_Study_01;  
    
    procedure Case_Study_02 is
        sys_01 	          : System;
        core_01	          : Core_Unit_Ptr;
    begin
        --------------------------------------------------------------------------
        --System Initialization---------------------------------------------------
        Set_Initialize;
        Initialize (A_System => sys_01);

        Add_core_unit(My_core_units  => sys_01.Core_units,
                      A_core_unit	   => core_01,
                      Name           => To_Unbounded_String("Core_1"),
                      Is_Preemptive  => Not_Preemptive,
                      Quantum        => 0,
                      speed          => 1,
                      capacity       => 1,
                      period         => 1,
                      priority       => 1,
                      File_Name      => empty_string,
                      A_Scheduler    => Rate_Monotonic_Protocol,
                      scheduling_protocol_name => To_Unbounded_String(""));

        Add_Processor(My_Processors => sys_01.Processors,
                      Name          => To_Unbounded_String("CPU_1"),
                      a_Core        => core_01);

        Add_Address_Space(My_Address_Spaces => sys_01.Address_Spaces,
                          Name              => To_Unbounded_String("Address_Space_1"),
                          Cpu_Name          => To_Unbounded_String("CPU_1"),
                          Text_Memory_Size  => 1024,
                          Stack_Memory_Size => 1024,
                          Data_Memory_Size  => 1024,
                          Heap_Memory_Size  => 1024);

        Add_Task(My_Tasks                => sys_01.Tasks,
                 Name                    => To_Unbounded_String("Task_1"),
                 Cpu_Name                => To_Unbounded_String("CPU_1"),
                 core_name               => empty_string,
                 Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
                 Task_Type               => Periodic_Type,
                 Start_Time              => 0,
                 Capacity                => 8,
                 Period                  => 24,
                 Deadline                => 24,
                 Jitter                  => 0,
                 Blocking_Time           => 0,
                 Priority                => 2,
                 Criticality             => 0,
                 Policy                  => SCHED_FIFO);

        Add_Task(My_Tasks                => sys_01.Tasks,
                 Name                    => To_Unbounded_String("Task_2"),
                 Cpu_Name                => To_Unbounded_String("CPU_1"),
                 core_name               => empty_string,
                 Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
                 Task_Type               => Periodic_Type,
                 Start_Time              => 0,
                 Capacity                => 2,
                 Period                  => 12,
                 Deadline                => 12,
                 Jitter                  => 0,
                 Blocking_Time           => 0,
                 Priority                => 1,
                 Criticality             => 0,
                 Policy                  => SCHED_FIFO);   

        sys_01.Write_To_Xml_File("xml/TSN_Sched_Case_Study_02.xmlv3");
        Put_Line("Export system to xml/TSN_Sched_Case_Study_02.xmlv3");

    end Case_Study_02; 
    
    procedure Case_Study_03 is
        sys_01 	          : System;
        core_01	          : Core_Unit_Ptr;
    begin
        --------------------------------------------------------------------------
        --System Initialization---------------------------------------------------
        Set_Initialize;
        Initialize (A_System => sys_01);

        Add_core_unit(My_core_units  => sys_01.Core_units,
                      A_core_unit	   => core_01,
                      Name           => To_Unbounded_String("Core_1"),
                      Is_Preemptive  => Not_Preemptive,
                      Quantum        => 0,
                      speed          => 1,
                      capacity       => 1,
                      period         => 1,
                      priority       => 1,
                      File_Name      => empty_string,
                      A_Scheduler    => Rate_Monotonic_Protocol,
                      scheduling_protocol_name => To_Unbounded_String(""));

        Add_Processor(My_Processors => sys_01.Processors,
                      Name          => To_Unbounded_String("CPU_1"),
                      a_Core        => core_01);

        Add_Address_Space(My_Address_Spaces => sys_01.Address_Spaces,
                          Name              => To_Unbounded_String("Address_Space_1"),
                          Cpu_Name          => To_Unbounded_String("CPU_1"),
                          Text_Memory_Size  => 1024,
                          Stack_Memory_Size => 1024,
                          Data_Memory_Size  => 1024,
                          Heap_Memory_Size  => 1024);

        Add_Task(My_Tasks                => sys_01.Tasks,
                 Name                    => To_Unbounded_String("Task_1"),
                 Cpu_Name                => To_Unbounded_String("CPU_1"),
                 core_name               => empty_string,
                 Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
                 Task_Type               => Periodic_Type,
                 Start_Time              => 0,
                 Capacity                => 8,
                 Period                  => 24,
                 Deadline                => 24,
                 Jitter                  => 0,
                 Blocking_Time           => 0,
                 Priority                => 2,
                 Criticality             => 0,
                 Policy                  => SCHED_FIFO);

        Add_Task(My_Tasks                => sys_01.Tasks,
                 Name                    => To_Unbounded_String("Task_2"),
                 Cpu_Name                => To_Unbounded_String("CPU_1"),
                 core_name               => empty_string,
                 Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
                 Task_Type               => Periodic_Type,
                 Start_Time              => 0,
                 Capacity                => 9,
                 Period                  => 12,
                 Deadline                => 12,
                 Jitter                  => 0,
                 Blocking_Time           => 0,
                 Priority                => 1,
                 Criticality             => 0,
                 Policy                  => SCHED_FIFO);   

        sys_01.Write_To_Xml_File("xml/TSN_Sched_Case_Study_03.xmlv3");
        Put_Line("Export system to xml/TSN_Sched_Case_Study_03.xmlv3");

    end Case_Study_03; 
    
    
    procedure Case_Study_04 is
        sys_01 	          : System;
        core_01	          : Core_Unit_Ptr;
    begin
        --------------------------------------------------------------------------
        --System Initialization---------------------------------------------------
        Set_Initialize;
        Initialize (A_System => sys_01);

        Add_core_unit(My_core_units  => sys_01.Core_units,
                      A_core_unit	   => core_01,
                      Name           => To_Unbounded_String("Core_1"),
                      Is_Preemptive  => Not_Preemptive,
                      Quantum        => 0,
                      speed          => 1,
                      capacity       => 1,
                      period         => 1,
                      priority       => 1,
                      File_Name      => empty_string,
                      A_Scheduler    => Rate_Monotonic_Protocol,
                      scheduling_protocol_name => To_Unbounded_String(""));

        Add_Processor(My_Processors => sys_01.Processors,
                      Name          => To_Unbounded_String("CPU_1"),
                      a_Core        => core_01);

        Add_Address_Space(My_Address_Spaces => sys_01.Address_Spaces,
                          Name              => To_Unbounded_String("Address_Space_1"),
                          Cpu_Name          => To_Unbounded_String("CPU_1"),
                          Text_Memory_Size  => 1024,
                          Stack_Memory_Size => 1024,
                          Data_Memory_Size  => 1024,
                          Heap_Memory_Size  => 1024);

        Add_Task(My_Tasks                => sys_01.Tasks,
                 Name                    => To_Unbounded_String("Task_1"),
                 Cpu_Name                => To_Unbounded_String("CPU_1"),
                 core_name               => empty_string,
                 Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
                 Task_Type               => Periodic_Type,
                 Start_Time              => 0,
                 Capacity                => 8,
                 Period                  => 24,
                 Deadline                => 24,
                 Jitter                  => 0,
                 Blocking_Time           => 0,
                 Priority                => 2,
                 Criticality             => 0,
                 Policy                  => SCHED_FIFO);

        Add_Task(My_Tasks                => sys_01.Tasks,
                 Name                    => To_Unbounded_String("Task_2"),
                 Cpu_Name                => To_Unbounded_String("CPU_1"),
                 core_name               => empty_string,
                 Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
                 Task_Type               => Periodic_Type,
                 Start_Time              => 0,
                 Capacity                => 8,
                 Period                  => 12,
                 Deadline                => 12,
                 Jitter                  => 0,
                 Blocking_Time           => 0,
                 Priority                => 1,
                 Criticality             => 0,
                 Policy                  => SCHED_FIFO);   

        sys_01.Write_To_Xml_File("xml/TSN_Sched_Case_Study_04.xmlv3");
        Put_Line("Export system to xml/TSN_Sched_Case_Study_04.xmlv3");

    end Case_Study_04; 
    
end  tsn_test_case_generator;
