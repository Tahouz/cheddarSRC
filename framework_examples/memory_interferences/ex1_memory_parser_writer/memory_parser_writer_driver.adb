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

with Ada.Text_IO;                       use Ada.Text_IO;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with Systems;                           use Systems;
with Initialize_Framework;              use Initialize_Framework;
with Call_Cache_Framework;              use Call_Cache_Framework;
with Cache_Access_Profile_Set;          use Cache_Access_Profile_Set;
with Unbounded_Strings;                 use Unbounded_strings;
with Unbounded_Strings;                 use Unbounded_Strings.Strings_Table_Package;
with Unbounded_Strings;                 use Unbounded_Strings.Unbounded_String_List_Package;
with Tasks;                             use Tasks;
with Task_Set;                          use Task_Set;
with Caches;                            use Caches;
with Caches;                            use Caches.Cache_Blocks_Table_Package;
with Cache_Block_Set;                   use Cache_Block_Set;
with Call_Framework;                    use Call_Framework;
with Call_Framework_Interface;          use Call_Framework_Interface;
with Call_Scheduling_Framework;         use Call_Scheduling_Framework;
with Basic_Block_Analysis;                       
with Sets;
with Core_Units;                        use Core_Units;
with Processor_Set;                     use Processor_Set;
with Scheduler_Interface;               use Scheduler_Interface;
with Memories;                          use Memories;
with Memories;                          use Memories.Memories_Table_Package;
with Address_Space_Set;                 use Address_Space_Set;
with Memory_Set;                        use Memory_Set;

procedure memory_parser_writer_driver
is
    procedure test_create_and_write_dram is
        Sys                          : System;
        Project_File_List            : unbounded_string_list;
        Project_File_Dir_List        : unbounded_string_list;
        result                       : Unbounded_String;

        a_core                       : Core_Unit_Ptr;
        a_memory                     : Generic_Memory_Ptr;
        mem_t                        : Memories_Table;
        mem_r                        : Memory_Record;
    
    begin
        -- Initialize the Cheddar framework
        --
        Call_Framework.initialize (False);

        -- Read the XML project file
        --
        initialize (Project_File_List);
    
        mem_r.size                      := 1;
        mem_r.access_latency            := 1;
        mem_r.memory_category           := DRAM_Type;  
        mem_r.shared_access_latency     := 1;  
        mem_r.private_access_latency    := 1;  
        mem_r.l_rw_inter                := 1;  
        mem_r.l_act_inter               := 1;  
        mem_r.l_pre_inter               := 1;  
        mem_r.n_reorder                 := 1;  
        mem_r.l_conhit                  := 1;  
        mem_r.l_conf                    := 1;  
        mem_r.nb_bank                   := 1;  
        mem_r.partition_mode            := True;  
    
        Add_Memory(My_memories     => Sys.Memories,
                   A_Memory        => a_memory,
                   Name            => To_Unbounded_String("Memory_01"),
                   A_Memory_Record => mem_r);
    
        Add(A_Table   => mem_t,
            A_Element => a_memory);
        
        Add_core_unit(My_core_units  => Sys.Core_units,
                      A_core_unit    => a_core,
                      Name           => To_Unbounded_String("Core_01"),
                      Is_Preemptive  => preemptive,
                      Quantum        => 0,
                      speed          => 1,
                      capacity       => 1,
                      period         => 1,
                      priority       => 1,
                      File_Name      => empty_string,
                      A_Scheduler    => Posix_1003_Highest_Priority_First_Protocol,
                      Mem            => mem_t,
                      automaton_name => empty_string,
                      l1_cache       => To_Unbounded_String ("Cache_01"),
                      start_time     => 0);

        Add_Processor(My_Processors => Sys.Processors,
                      Name          => To_Unbounded_String("CPU_01"),
                      a_Core        => a_core);
    
        Add_Address_Space(My_Address_Spaces => Sys.Address_Spaces,
                          Name              => To_Unbounded_String("Address_Space_01"),
                          Cpu_Name          => To_Unbounded_String("CPU_01"),
                          Text_Memory_Size  => 1024,
                          Stack_Memory_Size => 1024,
                          Data_Memory_Size  => 1024,
                          Heap_Memory_Size  => 1024); 
    
        Systems.Write_To_Xml_File(A_System  => Sys,
                                  File_Name => "output_write_dram.xml");  
    end test_create_and_write_dram;
    
    procedure test_create_and_write_kalray is
        Sys                          : System;
        Project_File_List            : unbounded_string_list;
        Project_File_Dir_List        : unbounded_string_list;
        result                       : Unbounded_String;

        a_core                       : Core_Unit_Ptr;
        a_memory                     : Generic_Memory_Ptr;
        mem_t                        : Memories_Table;
        mem_r                        : Memory_Record;
    
    begin
        -- Initialize the Cheddar framework
        --
        Call_Framework.initialize (False);

        -- Read the XML project file
        --
        initialize (Project_File_List);
    
        mem_r.size                      := 1;
        mem_r.access_latency            := 1;
        mem_r.memory_category           := Kalray_Type;  
        mem_r.shared_access_latency     := 1;  
        mem_r.private_access_latency    := 1;  
        mem_r.l_rw_inter                := 1;  
        mem_r.l_act_inter               := 1;  
        mem_r.l_pre_inter               := 1;  
        mem_r.n_reorder                 := 1;  
        mem_r.l_conhit                  := 1;  
        mem_r.l_conf                    := 1;  
        mem_r.nb_bank                   := 1;  
        mem_r.partition_mode            := True;  
    
        Add_Memory(My_memories     => Sys.Memories,
                   A_Memory        => a_memory,
                   Name            => To_Unbounded_String("Memory_01"),
                   A_Memory_Record => mem_r);
    
        Add(A_Table   => mem_t,
            A_Element => a_memory);
        
        Add_core_unit(My_core_units  => Sys.Core_units,
                      A_core_unit    => a_core,
                      Name           => To_Unbounded_String("Core_01"),
                      Is_Preemptive  => preemptive,
                      Quantum        => 0,
                      speed          => 1,
                      capacity       => 1,
                      period         => 1,
                      priority       => 1,
                      File_Name      => empty_string,
                      A_Scheduler    => Posix_1003_Highest_Priority_First_Protocol,
                      Mem            => mem_t,
                      automaton_name => empty_string,
                      l1_cache       => To_Unbounded_String ("Cache_01"),
                      start_time     => 0);

        Add_Processor(My_Processors => Sys.Processors,
                      Name          => To_Unbounded_String("CPU_01"),
                      a_Core        => a_core);
    
        Add_Address_Space(My_Address_Spaces => Sys.Address_Spaces,
                          Name              => To_Unbounded_String("Address_Space_01"),
                          Cpu_Name          => To_Unbounded_String("CPU_01"),
                          Text_Memory_Size  => 1024,
                          Stack_Memory_Size => 1024,
                          Data_Memory_Size  => 1024,
                          Heap_Memory_Size  => 1024);
    
        Systems.Write_To_Xml_File(A_System  => Sys,
                                  File_Name => "output_write_kalray.xml");  
    end test_create_and_write_kalray;
    
    procedure test_create_and_write_generic_memory is
        Sys                          : System;
        Project_File_List            : unbounded_string_list;
        Project_File_Dir_List        : unbounded_string_list;
        result                       : Unbounded_String;

        a_core		                 : Core_Unit_Ptr;
        a_memory                     : Generic_Memory_Ptr;
        mem_t                        : Memories_Table;
        mem_r                        : Memory_Record;
    
    begin
        -- Initialize the Cheddar framework
        --
        Call_Framework.initialize (False);

        -- Read the XML project file
        --
        initialize (Project_File_List);
    
        mem_r.size                      := 1;
        mem_r.access_latency            := 1;
        mem_r.memory_category           := Generic_Memory_Type;  
        mem_r.shared_access_latency     := 1;  
        mem_r.private_access_latency    := 1;  
        mem_r.l_rw_inter                := 1;  
        mem_r.l_act_inter               := 1;  
        mem_r.l_pre_inter               := 1;  
        mem_r.n_reorder                 := 1;  
        mem_r.l_conhit                  := 1;  
        mem_r.l_conf                    := 1;  
        mem_r.nb_bank                   := 1;  
        mem_r.partition_mode            := True;  
    
        Add_Memory(My_memories     => Sys.Memories,
                   A_Memory        => a_memory,
                   Name            => To_Unbounded_String("Memory_01"),
                   A_Memory_Record => mem_r);
    
        Add(A_Table   => mem_t,
            A_Element => a_memory);
        
        Add_core_unit(My_core_units  => Sys.Core_units,
                      A_core_unit    => a_core,
                      Name           => To_Unbounded_String("Core_01"),
                      Is_Preemptive  => preemptive,
                      Quantum        => 0,
                      speed          => 1,
                      capacity       => 1,
                      period         => 1,
                      priority       => 1,
                      File_Name      => empty_string,
                      A_Scheduler    => Posix_1003_Highest_Priority_First_Protocol,
                      Mem            => mem_t,
                      automaton_name => empty_string,
                      l1_cache       => To_Unbounded_String ("Cache_01"),
                      start_time     => 0);

        Add_Processor(My_Processors => Sys.Processors,
                      Name          => To_Unbounded_String("CPU_01"),
                      a_Core        => a_core);
    
        Add_Address_Space(My_Address_Spaces => Sys.Address_Spaces,
                          Name              => To_Unbounded_String("Address_Space_01"),
                          Cpu_Name          => To_Unbounded_String("CPU_01"),
                          Text_Memory_Size  => 1024,
                          Stack_Memory_Size => 1024,
                          Data_Memory_Size  => 1024,
                          Heap_Memory_Size  => 1024);   
    
        Systems.Write_To_Xml_File(A_System  => Sys,
                                  File_Name => "output_write_generic_memory.xml");  
    end test_create_and_write_generic_memory;

    a_system_with_dram           : System;
    a_system_with_kalray         : System;
    a_system_with_generic_mem    : System;
    Project_File_List            : unbounded_string_list;
    Project_File_Dir_List        : unbounded_string_list;

begin
    --Create and write system models with memory entities to xml files
    test_create_and_write_generic_memory;
    test_create_and_write_dram;   
    test_create_and_write_kalray;
    
    --Parse the xml files created above and rewrite system models with memory entities to xml files
    Call_Framework.initialize (False);
    initialize (Project_File_List);

    Systems.Read_From_Xml_File (a_system_with_generic_mem, Project_File_Dir_List, "output_write_generic_memory.xml");
    Systems.Write_To_Xml_File(a_system_with_generic_mem, "output_parse_generic_memory.xml");
    
    Systems.Read_From_Xml_File (a_system_with_dram, Project_File_Dir_List, "output_write_dram.xml");
    Systems.Write_To_Xml_File(a_system_with_dram, "output_parse_dram.xml");

    Systems.Read_From_Xml_File (a_system_with_kalray, Project_File_Dir_List, "output_write_kalray.xml");
    Systems.Write_To_Xml_File(a_system_with_kalray, "output_parse_kalray.xml");
    
end memory_parser_writer_driver;

