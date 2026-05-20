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

package body Buffer_Test_Case_Generator is

   procedure Add_Channel
     (Name           : in String;
      ProdRate       : in Integer;
      ConsRate       : in Integer;
      Source         : in String;
      Target         : in String;
      InitialToken   : in Integer;
      MaxSize        : in Integer;
      Sys            : in out System)
   is
      buffer              : Buffer_Ptr;
      bufferTbl           : Buffer_Roles_Table;

      role_01_Prod     : Buffer_Role;
      role_01_Cons     : Buffer_Role;
      task_i              : Generic_Task_Ptr;
   begin
      initialize(bufferTbl);

      task_i := Search_Task(Sys.Tasks,To_Unbounded_String(Source));
      role_01_Prod.the_role := Queuing_Producer;
      role_01_Prod.size     := ProdRate;
      role_01_Prod.time     := task_i.capacity;
      role_01_Prod.timeout  := 0;
      Add(bufferTbl, task_i.name, role_01_Prod);

      task_i := Search_Task(Sys.Tasks,To_Unbounded_String(Target));
      role_01_Cons.the_role := Queuing_Consumer;
      role_01_Cons.size     := ConsRate;
      role_01_Cons.time     := 1;
      role_01_Cons.timeout  := 0;
      Add(bufferTbl, task_i.name, role_01_Cons);

      Add_Buffer(My_Buffers         => Sys.Buffers,
                 A_Buffer           => buffer,
                 Name               => To_Unbounded_String(Name),
                 Size               => MaxSize,
                 Cpu_Name           => To_Unbounded_String("CPU_1"),
                 Address_Space_Name => To_Unbounded_String("Address_Space_1"),
                 A_Qs               => Qs_Pp1,
                 Roles              => bufferTbl,
                 Initial_Data       => InitialToken);

      task_i := Search_Task(Sys.Tasks,To_Unbounded_String(Source));
      Add_One_Task_Dependency_queueing_buffer(My_Dependencies => Sys.Dependencies,
                                              A_Task          => task_i,
                                              A_Dep           => buffer,
                                              A_Type          => From_Task_To_Object);

      task_i := Search_Task(Sys.Tasks,To_Unbounded_String(Target));
      Add_One_Task_Dependency_queueing_buffer(My_Dependencies => Sys.Dependencies,
                                              A_Task          => task_i,
                                              A_Dep           => buffer,
                                              A_Type          => From_Object_To_Task);
   end Add_Channel;

   procedure Case_Study_01 is
      sys_01 	          : System;
      core_01	          : Core_Unit_Ptr;

      --BUFFER 01
      buffer_01           : Buffer_Ptr;
      bufferTbl_01        : Buffer_Roles_Table;

      role_01_T1_Prod     : Buffer_Role;
      role_01_T2_Cons     : Buffer_Role;

      ---BUFFER 02
      buffer_02           : Buffer_Ptr;
      bufferTbl_02        : Buffer_Roles_Table;

      role_02_T2_Prod     : Buffer_Role;

      task_i              : Generic_Task_Ptr;
      mem_t               : Memories_Table;
   begin
      --------------------------------------------------------------------------
      --System Initialization---------------------------------------------------
      Set_Initialize;
      Initialize (A_System => sys_01);

      Add_core_unit(My_core_units  => sys_01.Core_units,
                    A_core_unit	   => core_01,
                    Name           => To_Unbounded_String("Core_1"),
                    Is_Preemptive  => preemptive,
                    Quantum        => 0,
                    speed          => 1,
                    capacity       => 1,
                    period         => 1,
                    priority       => 1,
                    File_Name      => empty_string,
                    A_Scheduler    => Posix_1003_Highest_Priority_First_Protocol,
                    scheduling_protocol_name => To_Unbounded_String(""),
	            Mem            => mem_t,
                    automaton_name => empty_string,
                    l1_cache       => To_Unbounded_String ("Cache_1"),
                    start_time     => 0);

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
               Capacity                => 6,
               Period                  => 40,
               Deadline                => 30,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 7,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("Task_2"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => empty_string,
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
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

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("Task_3"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => empty_string,
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
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

      initialize(bufferTbl_01);

      --BUFFER 01
      role_01_T1_Prod.the_role := Queuing_Producer;
      role_01_T1_Prod.size     := 3;
      role_01_T1_Prod.time     := 6;
      role_01_T1_Prod.timeout  := 3;
      Add(bufferTbl_01, To_Unbounded_String("Task_1"), role_01_T1_Prod);

      role_01_T2_Cons.the_role := Queuing_Consumer;
      role_01_T2_Cons.size     := 3;
      role_01_T2_Cons.time     := 1;
      role_01_T2_Cons.timeout  := 3;    
      Add(bufferTbl_01, To_Unbounded_String("Task_2"), role_01_T2_Cons);

      Add_Buffer(My_Buffers         => sys_01.Buffers,
                 A_Buffer           => buffer_01,
                 Name               => To_Unbounded_String("Buffer_01"),
                 Size               => 10,
                 Cpu_Name           => To_Unbounded_String("CPU_1"),
                 Address_Space_Name => To_Unbounded_String("Address_Space_1"),
                 A_Qs               => Qs_Pp1,
                 Roles              => bufferTbl_01,
                 Initial_Data       => 0);

      task_i := Search_Task(sys_01.Tasks,To_Unbounded_String("Task_1"));
      Add_One_Task_Dependency_queueing_buffer(My_Dependencies => sys_01.Dependencies,
                                              A_Task          => task_i,
                                              A_Dep           => buffer_01,
                                              A_Type          => From_Task_To_Object);

      task_i := Search_Task(sys_01.Tasks,To_Unbounded_String("Task_2"));
      Add_One_Task_Dependency_queueing_buffer(My_Dependencies => sys_01.Dependencies,
                                              A_Task          => task_i,
                                              A_Dep           => buffer_01,
                                              A_Type          => From_Object_To_Task);

      --BUFFER 02
      role_02_T2_Prod.the_role := Queuing_Producer;
      role_02_T2_Prod.size     := 3;
      role_02_T2_Prod.time     := 1;
      role_02_T2_Prod.timeout  := 3;
      Add(bufferTbl_02, To_Unbounded_String("Task_2"), role_02_T2_Prod);

      Add_Buffer(My_Buffers         => sys_01.Buffers,
                 A_Buffer           => buffer_02,
                 Name               => To_Unbounded_String("Buffer_02"),
                 Size               => 10,
                 Cpu_Name           => To_Unbounded_String("CPU_1"),
                 Address_Space_Name => To_Unbounded_String("Address_Space_1"),
                 A_Qs               => Qs_Pp1,
                 Roles              => bufferTbl_02,
                 Initial_Data       => 0);

      task_i := Search_Task(sys_01.Tasks,To_Unbounded_String("Task_2"));
      Add_One_Task_Dependency_queueing_buffer(My_Dependencies => sys_01.Dependencies,
                                              A_Task          => task_i,
                                              A_Dep           => buffer_02,
                                              A_Type          => From_Task_To_Object);

      --------------------------------------------------------------------------

      sys_01.Write_To_Xml_File("Buffer_Sched_Case_Study_01.xmlv3");
      Put_Line("Export system to Buffer_Sched_Case_Study_01.xmlv3");

   end Case_Study_01;

   procedure Case_Study_02_Buffer_Initial_Data is
      sys_01 	          : System;
      core_01	          : Core_Unit_Ptr;

      --BUFFER 01
      buffer_01           : Buffer_Ptr;
      bufferTbl_01        : Buffer_Roles_Table;

      --role_01_T1_Prod     : Buffer_Role;
      role_01_T2_Cons     : Buffer_Role;

      ---BUFFER 02
      buffer_02           : Buffer_Ptr;
      bufferTbl_02        : Buffer_Roles_Table;

      role_02_T2_Prod     : Buffer_Role;

      task_i              : Generic_Task_Ptr;
	  mem_t               : Memories_Table;
   begin
      --------------------------------------------------------------------------
      --System Initialization---------------------------------------------------
      Set_Initialize;
      Initialize (A_System => sys_01);

      Add_core_unit(My_core_units  => sys_01.Core_units,
                    A_core_unit	   => core_01,
                    Name           => To_Unbounded_String("Core_1"),
                    Is_Preemptive  => preemptive,
                    Quantum        => 0,
                    speed          => 1,
                    capacity       => 1,
                    period         => 1,
                    priority       => 1,
                    File_Name      => empty_string,
                    A_Scheduler    => Posix_1003_Highest_Priority_First_Protocol,
                    scheduling_protocol_name => To_Unbounded_String(""),
	            Mem            => mem_t,
                    automaton_name => empty_string,
                    l1_cache       => To_Unbounded_String ("Cache_1"),
                    start_time     => 0);

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
               Capacity                => 6,
               Period                  => 40,
               Deadline                => 30,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 6,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("Task_2"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => empty_string,
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
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

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("Task_3"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => empty_string,
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
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

      initialize(bufferTbl_01);

      --BUFFER 01
      --        role_01_T1_Prod.the_role := Queuing_Producer;
      --        role_01_T1_Prod.size     := 3;
      --        role_01_T1_Prod.time     := 6;
      --        role_01_T1_Prod.timeout  := 3;
      --        Add(bufferTbl_01, To_Unbounded_String("Task_1"), role_01_T1_Prod);

      role_01_T2_Cons.the_role := Queuing_Consumer;
      role_01_T2_Cons.size     := 3;
      role_01_T2_Cons.time     := 1;
      role_01_T2_Cons.timeout  := 3;
      Add(bufferTbl_01, To_Unbounded_String("Task_2"), role_01_T2_Cons);

      Add_Buffer(My_Buffers         => sys_01.Buffers,
                 A_Buffer           => buffer_01,
                 Name               => To_Unbounded_String("Buffer_01"),
                 Size               => 10,
                 Cpu_Name           => To_Unbounded_String("CPU_1"),
                 Address_Space_Name => To_Unbounded_String("Address_Space_1"),
                 A_Qs               => Qs_Pp1,
                 Roles              => bufferTbl_01,
                 Initial_Data       => 6);

      --        task_i := Search_Task(sys_01.Tasks,To_Unbounded_String("Task_1"));
      --        Add_One_Task_Dependency_queueing_buffer(My_Dependencies => sys_01.Dependencies,
      --                                                A_Task          => task_i,
      --                                                A_Dep           => buffer_01,
      --                                                A_Type          => From_Task_To_Object);

      task_i := Search_Task(sys_01.Tasks,To_Unbounded_String("Task_2"));
      Add_One_Task_Dependency_queueing_buffer(My_Dependencies => sys_01.Dependencies,
                                              A_Task          => task_i,
                                              A_Dep           => buffer_01,
                                              A_Type          => From_Object_To_Task);

      --BUFFER 02
      role_02_T2_Prod.the_role := Queuing_Producer;
      role_02_T2_Prod.size     := 3;
      role_02_T2_Prod.time     := 1;
      role_02_T2_Prod.timeout  := 3;
      Add(bufferTbl_02, To_Unbounded_String("Task_2"), role_02_T2_Prod);

      Add_Buffer(My_Buffers         => sys_01.Buffers,
                 A_Buffer           => buffer_02,
                 Name               => To_Unbounded_String("Buffer_02"),
                 Size               => 10,
                 Cpu_Name           => To_Unbounded_String("CPU_1"),
                 Address_Space_Name => To_Unbounded_String("Address_Space_1"),
                 A_Qs               => Qs_Pp1,
                 Roles              => bufferTbl_02,
                 Initial_Data       => 0);

      task_i := Search_Task(sys_01.Tasks,To_Unbounded_String("Task_2"));
      Add_One_Task_Dependency_queueing_buffer(My_Dependencies => sys_01.Dependencies,
                                              A_Task          => task_i,
                                              A_Dep           => buffer_02,
                                              A_Type          => From_Task_To_Object);

      --------------------------------------------------------------------------

      sys_01.Write_To_Xml_File("Buffer_Sched_Case_Study_02_Buffer_Initial_Data.xmlv3");
      Put_Line("Export system to Buffer_Sched_Case_Study_02_Buffer_Initial_Data.xmlv3");

   end Case_Study_02_Buffer_Initial_Data;

   procedure Case_Study_03_Buffer_Underflow is
      sys_01 	          : System;
      core_01	          : Core_Unit_Ptr;

      --BUFFER 01
      buffer_01           : Buffer_Ptr;
      bufferTbl_01        : Buffer_Roles_Table;

      --role_01_T1_Prod     : Buffer_Role;
      role_01_T2_Cons     : Buffer_Role;

      ---BUFFER 02
      buffer_02           : Buffer_Ptr;
      bufferTbl_02        : Buffer_Roles_Table;

      role_02_T2_Prod     : Buffer_Role;

      task_i              : Generic_Task_Ptr;
	  mem_t               : Memories_Table;
   begin
      --------------------------------------------------------------------------
      --System Initialization---------------------------------------------------
      Set_Initialize;
      Initialize (A_System => sys_01);

      Add_core_unit(My_core_units  => sys_01.Core_units,
                    A_core_unit	   => core_01,
                    Name           => To_Unbounded_String("Core_1"),
                    Is_Preemptive  => preemptive,
                    Quantum        => 0,
                    speed          => 1,
                    capacity       => 1,
                    period         => 1,
                    priority       => 1,
                    File_Name      => empty_string,
                    A_Scheduler    => Posix_1003_Highest_Priority_First_Protocol,
                    Mem            => mem_t,
                    scheduling_protocol_name => To_Unbounded_String(""),
                    automaton_name => empty_string,
                    l1_cache       => To_Unbounded_String ("Cache_1"),
                    start_time     => 0);

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
               Capacity                => 6,
               Period                  => 40,
               Deadline                => 30,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 6,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("Task_2"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => empty_string,
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
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

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("Task_3"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => empty_string,
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
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

      initialize(bufferTbl_01);

      --BUFFER 01
      --        role_01_T1_Prod.the_role := Queuing_Producer;
      --        role_01_T1_Prod.size     := 3;
      --        role_01_T1_Prod.time     := 6;
      --        role_01_T1_Prod.timeout  := 3;
      --        Add(bufferTbl_01, To_Unbounded_String("Task_1"), role_01_T1_Prod);

      role_01_T2_Cons.the_role := Queuing_Consumer;
      role_01_T2_Cons.size     := 3;
      role_01_T2_Cons.time     := 1;
      role_01_T2_Cons.timeout  := 3;
      Add(bufferTbl_01, To_Unbounded_String("Task_2"), role_01_T2_Cons);

      Add_Buffer(My_Buffers         => sys_01.Buffers,
                 A_Buffer           => buffer_01,
                 Name               => To_Unbounded_String("Buffer_01"),
                 Size               => 10,
                 Cpu_Name           => To_Unbounded_String("CPU_1"),
                 Address_Space_Name => To_Unbounded_String("Address_Space_1"),
                 A_Qs               => Qs_Pp1,
                 Roles              => bufferTbl_01,
                 Initial_Data       => 0);

      --        task_i := Search_Task(sys_01.Tasks,To_Unbounded_String("Task_1"));
      --        Add_One_Task_Dependency_queueing_buffer(My_Dependencies => sys_01.Dependencies,
      --                                                A_Task          => task_i,
      --                                                A_Dep           => buffer_01,
      --                                                A_Type          => From_Task_To_Object);

      task_i := Search_Task(sys_01.Tasks,To_Unbounded_String("Task_2"));
      Add_One_Task_Dependency_queueing_buffer(My_Dependencies => sys_01.Dependencies,
                                              A_Task          => task_i,
                                              A_Dep           => buffer_01,
                                              A_Type          => From_Object_To_Task);

      --BUFFER 02
      role_02_T2_Prod.the_role := Queuing_Producer;
      role_02_T2_Prod.size     := 3;
      role_02_T2_Prod.time     := 1;
      role_02_T2_Prod.timeout  := 3;
      Add(bufferTbl_02, To_Unbounded_String("Task_2"), role_02_T2_Prod);

      Add_Buffer(My_Buffers         => sys_01.Buffers,
                 A_Buffer           => buffer_02,
                 Name               => To_Unbounded_String("Buffer_02"),
                 Size               => 10,
                 Cpu_Name           => To_Unbounded_String("CPU_1"),
                 Address_Space_Name => To_Unbounded_String("Address_Space_1"),
                 A_Qs               => Qs_Pp1,
                 Roles              => bufferTbl_02,
                 Initial_Data       => 0);

      task_i := Search_Task(sys_01.Tasks,To_Unbounded_String("Task_2"));
      Add_One_Task_Dependency_queueing_buffer(My_Dependencies => sys_01.Dependencies,
                                              A_Task          => task_i,
                                              A_Dep           => buffer_02,
                                              A_Type          => From_Task_To_Object);

      --------------------------------------------------------------------------

      sys_01.Write_To_Xml_File("Buffer_Sched_Case_Study_03_Buffer_Underflow.xmlv3");
      Put_Line("Export system to Buffer_Sched_Case_Study_03_Buffer_Underflow.xmlv3");

   end Case_Study_03_Buffer_Underflow;

   procedure Case_Study_04_Buffer_Overflow is
      sys_01 	          : System;
      core_01	          : Core_Unit_Ptr;

      --BUFFER 01
      buffer_01           : Buffer_Ptr;
      bufferTbl_01        : Buffer_Roles_Table;

      role_01_T1_Prod     : Buffer_Role;
      role_01_T2_Cons     : Buffer_Role;

      ---BUFFER 02
      buffer_02           : Buffer_Ptr;
      bufferTbl_02        : Buffer_Roles_Table;

      role_02_T2_Prod     : Buffer_Role;

      task_i              : Generic_Task_Ptr;
	  mem_t               : Memories_Table;
   begin
      --------------------------------------------------------------------------
      --System Initialization---------------------------------------------------
      Set_Initialize;
      Initialize (A_System => sys_01);

      Add_core_unit(My_core_units  => sys_01.Core_units,
                    A_core_unit	   => core_01,
                    Name           => To_Unbounded_String("Core_1"),
                    Is_Preemptive  => preemptive,
                    Quantum        => 0,
                    speed          => 1,
                    capacity       => 1,
                    period         => 1,
                    priority       => 1,
                    File_Name      => empty_string,
                    A_Scheduler    => Posix_1003_Highest_Priority_First_Protocol,
                    Mem            => mem_t,
                    scheduling_protocol_name => To_Unbounded_String(""),
                    automaton_name => empty_string,
                    l1_cache       => To_Unbounded_String ("Cache_1"),
                    start_time     => 0);

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
               core_name               => To_Unbounded_String("Core_1"),
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
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

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("Task_2"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => To_Unbounded_String("Core_1"),
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
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

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("Task_3"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => To_Unbounded_String("Core_1"),
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
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

      initialize(bufferTbl_01);

      --BUFFER 01
      role_01_T1_Prod.the_role := Queuing_Producer;
      role_01_T1_Prod.size     := 11;
      role_01_T1_Prod.time     := 6;
      role_01_T1_Prod.timeout  := 3;
      Add(bufferTbl_01, To_Unbounded_String("Task_1"), role_01_T1_Prod);

      role_01_T2_Cons.the_role := Queuing_Consumer;
      role_01_T2_Cons.size     := 3;
      role_01_T2_Cons.time     := 1;
      role_01_T2_Cons.timeout  := 3;
      Add(bufferTbl_01, To_Unbounded_String("Task_2"), role_01_T2_Cons);

      Add_Buffer(My_Buffers         => sys_01.Buffers,
                 A_Buffer           => buffer_01,
                 Name               => To_Unbounded_String("Buffer_01"),
                 Size               => 10,
                 Cpu_Name           => To_Unbounded_String("CPU_1"),
                 Address_Space_Name => To_Unbounded_String("Address_Space_1"),
                 A_Qs               => Qs_Pp1,
                 Roles              => bufferTbl_01,
                 Initial_Data       => 0);

      task_i := Search_Task(sys_01.Tasks,To_Unbounded_String("Task_1"));
      Add_One_Task_Dependency_queueing_buffer(My_Dependencies => sys_01.Dependencies,
                                              A_Task          => task_i,
                                              A_Dep           => buffer_01,
                                              A_Type          => From_Task_To_Object);

      task_i := Search_Task(sys_01.Tasks,To_Unbounded_String("Task_2"));
      Add_One_Task_Dependency_queueing_buffer(My_Dependencies => sys_01.Dependencies,
                                              A_Task          => task_i,
                                              A_Dep           => buffer_01,
                                              A_Type          => From_Object_To_Task);

      --BUFFER 02
      role_02_T2_Prod.the_role := Queuing_Producer;
      role_02_T2_Prod.size     := 3;
      role_02_T2_Prod.time     := 1;
      role_02_T2_Prod.timeout  := 3;
      Add(bufferTbl_02, To_Unbounded_String("Task_2"), role_02_T2_Prod);

      Add_Buffer(My_Buffers         => sys_01.Buffers,
                 A_Buffer           => buffer_02,
                 Name               => To_Unbounded_String("Buffer_02"),
                 Size               => 10,
                 Cpu_Name           => To_Unbounded_String("CPU_1"),
                 Address_Space_Name => To_Unbounded_String("Address_Space_1"),
                 A_Qs               => Qs_Pp1,
                 Roles              => bufferTbl_02,
                 Initial_Data       => 0);

      task_i := Search_Task(sys_01.Tasks,To_Unbounded_String("Task_2"));
      Add_One_Task_Dependency_queueing_buffer(My_Dependencies => sys_01.Dependencies,
                                              A_Task          => task_i,
                                              A_Dep           => buffer_02,
                                              A_Type          => From_Task_To_Object);

      --------------------------------------------------------------------------

      sys_01.Write_To_Xml_File("Buffer_Sched_Case_Study_04_Buffer_Overflow.xmlv3");
      Put_Line("Export system to Buffer_Sched_Case_Study_04_Buffer_Overflow.xmlv3");

   end Case_Study_04_Buffer_Overflow;

   procedure Case_Study_05_Discrete_Cosine_Transform is
      sys_01 	          : System;
      core_01	          : Core_Unit_Ptr;
	  mem_t               : Memories_Table;
   begin
      --------------------------------------------------------------------------
      --System Initialization---------------------------------------------------
      Set_Initialize;
      Initialize (A_System => sys_01);

      Add_core_unit(My_core_units  => sys_01.Core_units,
                    A_core_unit	   => core_01,
                    Name           => To_Unbounded_String("Core_1"),
                    Is_Preemptive  => preemptive,
                    Quantum        => 0,
                    speed          => 1,
                    capacity       => 1,
                    period         => 1,
                    priority       => 1,
                    File_Name      => empty_string,
                    A_Scheduler    => Posix_1003_Highest_Priority_First_Protocol,
                    Mem            => mem_t,
                    scheduling_protocol_name => To_Unbounded_String(""),
                    automaton_name => empty_string,
                    l1_cache       => To_Unbounded_String ("Cache_1"),
                    start_time     => 0);

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

      ------------------------------------------------------------------------------
      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("AnonFilter_a0__263"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => empty_string,
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 1536,
               Period                  => 142848,
               Deadline                => 142848,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 3,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("AnonFilter_a1__319"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => empty_string,
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 19456,
               Period                  => 142848,
               Deadline                => 142848,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 6,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("FileReader__258"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => empty_string,
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 1,
               Period                  => 142848,
               Deadline                => 142848,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 2,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("FileWriter__322"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => empty_string,
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 1,
               Period                  => 142848,
               Deadline                => 142848,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 1,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("Post_CollapsedDataParallel_2__292"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => empty_string,
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 2851,
               Period                  => 142848,
               Deadline                => 142848,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 5,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("Pre_CollapsedDataParallel_1__269"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => empty_string,
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 2595,
               Period                  => 142848,
               Deadline                => 142848,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 4,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("iDCT_1D_reference_fine__286"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => empty_string,
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 47616,
               Period                  => 142848,
               Deadline                => 142848,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 8,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("iDCT_1D_reference_fine__309"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => empty_string,
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 47616,
               Period                  => 142848,
               Deadline                => 142848,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 7,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);


      --Channel-----------------------------------------------------------------
      Add_Channel(Name         => "ch0",
                  ProdRate     => 256,
                  ConsRate     => 256,
                  Source       => "FileReader__258",
                  Target       => "AnonFilter_a0__263",
                  InitialToken => 256,
                  MaxSize      => 256,
                  Sys          => sys_01);

      Add_Channel(Name         => "ch1",
                  ProdRate     => 256,
                  ConsRate     => 256,
                  Source       => "AnonFilter_a0__263",
                  Target       => "Pre_CollapsedDataParallel_1__269",
                  InitialToken => 256,
                  MaxSize      => 256,
                  Sys          => sys_01);

      Add_Channel(Name         => "ch2",
                  ProdRate     => 256,
                  ConsRate     => 256,
                  Source       => "Pre_CollapsedDataParallel_1__269",
                  Target       => "iDCT_1D_reference_fine__286",
                  InitialToken => 256,
                  MaxSize      => 256,
                  Sys          => sys_01);

      Add_Channel(Name         => "ch3",
                  ProdRate     => 256,
                  ConsRate     => 256,
                  Source       => "iDCT_1D_reference_fine__286",
                  Target       => "Post_CollapsedDataParallel_2__292",
                  InitialToken => 0,
                  MaxSize      => 256,
                  Sys          => sys_01);

      Add_Channel(Name         => "ch4",
                  ProdRate     => 256,
                  ConsRate     => 256,
                  Source       => "Post_CollapsedDataParallel_2__292",
                  Target       => "iDCT_1D_reference_fine__309",
                  InitialToken => 256,
                  MaxSize      => 256,
                  Sys          => sys_01);

      Add_Channel(Name         => "ch5",
                  ProdRate     => 256,
                  ConsRate     => 256,
                  Source       => "iDCT_1D_reference_fine__309",
                  Target       => "AnonFilter_a1__319",
                  InitialToken => 0,
                  MaxSize      => 256,
                  Sys          => sys_01);

      Add_Channel(Name         => "ch6",
                  ProdRate     => 256,
                  ConsRate     => 256,
                  Source       => "AnonFilter_a1__319",
                  Target       => "FileWriter__322",
                  InitialToken => 0,
                  MaxSize      => 256,
                  Sys          => sys_01);


      --------------------------------------------------------------------------

      sys_01.Write_To_Xml_File("Buffer_Sched_Case_Study_05_Discrete_Cosine_Transform.xmlv3");
      Put_Line("Export system to Buffer_Sched_Case_Study_05_Discrete_Cosine_Transform.xmlv3");

   end Case_Study_05_Discrete_Cosine_Transform;

   procedure Case_Study_06_Multi_Processor is
      sys_01 	          : System;
      core_01	          : Core_Unit_Ptr;
      core_02             : Core_Unit_Ptr;

      --BUFFER 01
      buffer_01           : Buffer_Ptr;
      bufferTbl_01        : Buffer_Roles_Table;

      role_01_T1_Prod     : Buffer_Role;
      role_01_T2_Cons     : Buffer_Role;


      task_i              : Generic_Task_Ptr;
	  mem_t               : Memories_Table;
   begin
      --------------------------------------------------------------------------
      --System Initialization---------------------------------------------------
      Set_Initialize;
      Initialize (A_System => sys_01);

      Add_core_unit(My_core_units  => sys_01.Core_units,
                    A_core_unit	   => core_01,
                    Name           => To_Unbounded_String("Core_1"),
                    Is_Preemptive  => preemptive,
                    Quantum        => 0,
                    speed          => 1,
                    capacity       => 1,
                    period         => 1,
                    priority       => 1,
                    File_Name      => empty_string,
                    A_Scheduler    => Posix_1003_Highest_Priority_First_Protocol,
                    Mem            => mem_t,
                    scheduling_protocol_name => To_Unbounded_String(""),
                    automaton_name => empty_string,
                    l1_cache       => To_Unbounded_String ("Cache_1"),
                    start_time     => 0);

      Add_Processor(My_Processors => sys_01.Processors,
                    Name          => To_Unbounded_String("CPU_1"),
                    a_Core        => core_01);

      Add_core_unit(My_core_units  => sys_01.Core_units,
                    A_core_unit	   => core_02,
                    Name           => To_Unbounded_String("Core_2"),
                    Is_Preemptive  => preemptive,
                    Quantum        => 0,
                    speed          => 1,
                    capacity       => 1,
                    period         => 1,
                    priority       => 1,
                    File_Name      => empty_string,
                    A_Scheduler    => Posix_1003_Highest_Priority_First_Protocol,
                    Mem            => mem_t,
                    scheduling_protocol_name => To_Unbounded_String(""),
                    automaton_name => empty_string,
                    l1_cache       => To_Unbounded_String ("Cache_2"),
                    start_time     => 0);

      Add_Processor(My_Processors => sys_01.Processors,
                    Name          => To_Unbounded_String("CPU_2"),
                    a_Core        => core_02);

      Add_Address_Space(My_Address_Spaces => sys_01.Address_Spaces,
                        Name              => To_Unbounded_String("Address_Space_1"),
                        Cpu_Name          => To_Unbounded_String("CPU_1"),
                        Text_Memory_Size  => 1024,
                        Stack_Memory_Size => 1024,
                        Data_Memory_Size  => 1024,
                        Heap_Memory_Size  => 1024);

      Add_Address_Space(My_Address_Spaces => sys_01.Address_Spaces,
                        Name              => To_Unbounded_String("Address_Space_2"),
                        Cpu_Name          => To_Unbounded_String("CPU_2"),
                        Text_Memory_Size  => 1024,
                        Stack_Memory_Size => 1024,
                        Data_Memory_Size  => 1024,
                        Heap_Memory_Size  => 1024);

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("Task_1"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => To_Unbounded_String("Core_1"),
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
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

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("Task_2"),
               Cpu_Name                => To_Unbounded_String("CPU_2"),
               core_name               => To_Unbounded_String("Core_2"),               
               Address_Space_Name      => To_Unbounded_String("Address_Space_2"),
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

      initialize(bufferTbl_01);

      --BUFFER 01
      role_01_T1_Prod.the_role := Queuing_Producer;
      role_01_T1_Prod.size     := 3;
      role_01_T1_Prod.time     := 6;
      role_01_T1_Prod.timeout  := 3;
      Add(bufferTbl_01, To_Unbounded_String("Task_1"), role_01_T1_Prod);

      role_01_T2_Cons.the_role := Queuing_Consumer;
      role_01_T2_Cons.size     := 3;
      role_01_T2_Cons.time     := 1;
      role_01_T2_Cons.timeout  := 3;
      Add(bufferTbl_01, To_Unbounded_String("Task_2"), role_01_T2_Cons);

      Add_Buffer(My_Buffers         => sys_01.Buffers,
                 A_Buffer           => buffer_01,
                 Name               => To_Unbounded_String("Buffer_01"),
                 Size               => 10,
                 Cpu_Name           => To_Unbounded_String("CPU_1"),
                 Address_Space_Name => To_Unbounded_String("Address_Space_1"),
                 A_Qs               => Qs_Pp1,
                 Roles              => bufferTbl_01,
                 Initial_Data       => 0);

      task_i := Search_Task(sys_01.Tasks,To_Unbounded_String("Task_1"));
      Add_One_Task_Dependency_queueing_buffer(My_Dependencies => sys_01.Dependencies,
                                              A_Task          => task_i,
                                              A_Dep           => buffer_01,
                                              A_Type          => From_Task_To_Object);

      task_i := Search_Task(sys_01.Tasks,To_Unbounded_String("Task_2"));
      Add_One_Task_Dependency_queueing_buffer(My_Dependencies => sys_01.Dependencies,
                                              A_Task          => task_i,
                                              A_Dep           => buffer_01,
                                              A_Type          => From_Object_To_Task);
      --------------------------------------------------------------------------

      sys_01.Write_To_Xml_File("Buffer_Sched_Case_Study_06_Multi_Processor.xmlv3");
      Put_Line("Export system to Buffer_Sched_Case_Study_06_Multi_Processor.xmlv3");

   end Case_Study_06_Multi_processor;

   procedure Case_Study_07_USCDF is
      sys_01 	          : System;
      core_01	          : Core_Unit_Ptr;

      --BUFFER 01
      buffer_01           : Buffer_Ptr;
      bufferTbl_01        : Buffer_Roles_Table;

      role_01_T1_Prod     : Buffer_Role;
      role_01_T2_Cons     : Buffer_Role;


      task_i              : Generic_Task_Ptr;
	  mem_t               : Memories_Table;
   begin
      --------------------------------------------------------------------------
      --System Initialization---------------------------------------------------
      Set_Initialize;
      Initialize (A_System => sys_01);

      Add_core_unit(My_core_units  => sys_01.Core_units,
                    A_core_unit	   => core_01,
                    Name           => To_Unbounded_String("Core_1"),
                    Is_Preemptive  => preemptive,
                    Quantum        => 0,
                    speed          => 1,
                    capacity       => 1,
                    period         => 1,
                    priority       => 1,
                    File_Name      => empty_string,
                    A_Scheduler    => Posix_1003_Highest_Priority_First_Protocol,
                    Mem            => mem_t,
                    scheduling_protocol_name => To_Unbounded_String(""),
                    automaton_name => empty_string,
                    l1_cache       => To_Unbounded_String ("Cache_1"),
                    start_time     => 0);

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
               core_name               => To_Unbounded_String("Core_1"),
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 6,
               Period                  => 20,
               Deadline                => 20,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 2,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      Add_Task(My_Tasks                => sys_01.Tasks,
               Name                    => To_Unbounded_String("Task_2"),
               Cpu_Name                => To_Unbounded_String("CPU_1"),
               core_name               => To_Unbounded_String("Core_1"),
               Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
               Task_Type               => Periodic_Type,
               Start_Time              => 0,
               Capacity                => 6,
               Period                  => 20,
               Deadline                => 20,
               Jitter                  => 0,
               Blocking_Time           => 0,
               Priority                => 1,
               Criticality             => 0,
               Policy                  => SCHED_FIFO);

      initialize(bufferTbl_01);

      --BUFFER 01
      role_01_T1_Prod.the_role := UCSDF_Producer;
      role_01_T1_Prod.size     := 1;
      role_01_T1_Prod.time     := 6;
      role_01_T1_Prod.timeout  := 3;
      role_01_T1_Prod.amplitude_function := To_Unbounded_String("4(1_2)");
      Add(bufferTbl_01, To_Unbounded_String("Task_1"), role_01_T1_Prod);

      role_01_T2_Cons.the_role := UCSDF_Consumer;
      role_01_T2_Cons.size     := 1;
      role_01_T2_Cons.time     := 1;
      role_01_T2_Cons.timeout  := 3;
      role_01_T2_Cons.amplitude_function := To_Unbounded_String("4(1_2)");
      Add(bufferTbl_01, To_Unbounded_String("Task_2"), role_01_T2_Cons);

      Add_Buffer(My_Buffers         => sys_01.Buffers,
                 A_Buffer           => buffer_01,
                 Name               => To_Unbounded_String("Buffer_01"),
                 Size               => 10,
                 Cpu_Name           => To_Unbounded_String("CPU_1"),
                 Address_Space_Name => To_Unbounded_String("Address_Space_1"),
                 A_Qs               => Qs_Pp1,
                 Roles              => bufferTbl_01,
                 Initial_Data       => 0);

      task_i := Search_Task(sys_01.Tasks,To_Unbounded_String("Task_1"));
      Add_One_Task_Dependency_queueing_buffer(My_Dependencies => sys_01.Dependencies,
                                              A_Task          => task_i,
                                              A_Dep           => buffer_01,
                                              A_Type          => From_Task_To_Object);

      task_i := Search_Task(sys_01.Tasks,To_Unbounded_String("Task_2"));
      Add_One_Task_Dependency_queueing_buffer(My_Dependencies => sys_01.Dependencies,
                                              A_Task          => task_i,
                                              A_Dep           => buffer_01,
                                              A_Type          => From_Object_To_Task);

      --------------------------------------------------------------------------

      sys_01.Write_To_Xml_File("Buffer_Sched_Case_Study_07_UCSDF.xmlv3");
      Put_Line("Export system to Buffer_Sched_Case_Study_07_UCSDF.xmlv3");

   end Case_Study_07_USCDF;

end  Buffer_Test_Case_Generator;
