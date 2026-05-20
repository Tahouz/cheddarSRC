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
--    $Author: nam $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with Ada.Calendar;                      use Ada.Calendar;
with Ada.Calendar.Formatting;           use Ada.Calendar.Formatting;
with Ada.Directories;                   use Ada.Directories;
with Ada.Text_IO;                       use Ada.Text_IO;
with Systems;                           use Systems;
with Ada.Float_Text_IO;                 use Ada.Float_Text_IO;
with Framework_Config;                  use Framework_Config;
with Buffer_Test_Case_Generator;        use Buffer_Test_Case_Generator;
with unbounded_strings;                 use unbounded_strings;
with buffer_scheduling_simulation_test; use buffer_scheduling_simulation_test;
with Task_Set;                          use Task_Set;
with initialize_framework;              use initialize_framework;
with buffer_event_table_analyzer;       use buffer_event_table_analyzer;
with GNAT.OS_Lib;                       use GNAT.OS_Lib;
with GNAT.Command_Line;
with Ada.IO_Exceptions;
with Buffers.Extended;                  use Buffers.Extended;
with Integer_Arrays;                    use Integer_Arrays;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;

procedure buffer_sched
is
    ----------------------------------------------

    --Configuration for the scheduling simulator--
    default_Period               : Integer := 1000000;
    ----------------------------------------------
    H                            : Integer := 0;
    --Time_And_Date              : TIME;
    input_file_path              : Unbounded_String := empty_string;
    event_table_name             : Unbounded_String := empty_string;
    log_directory                : Unbounded_String := empty_string;
    sched_duration               : Integer := 0;
    sched                        : Scheduling_Table_Ptr;
    sys                          : System;
    Project_File_Dir_List        : unbounded_string_list;
    export_data                  : Boolean := False;
    max_offset                   : Integer := 0;
    ----------------------------------------------
    exp_dir : STRING := "xml/";
    ----------------------------------------------
    test_mode : Character := 'A';
    ----------------------------------------------
    --testAF : Amplitude_Function_Ptr;
    test_data_size : Integer := 0;

begin
    loop
        case GNAT.Command_Line.Getopt ("t: f: e: d: x: l: n") is
        when ASCII.NUL =>
            exit;
            when 't' =>
            Put_Line("Test mode: " & GNAT.Command_Line.Parameter);
            test_mode := GNAT.Command_Line.Parameter(1);
        when 'f' =>
            Put_Line("File: " & GNAT.Command_Line.Parameter);
            input_file_path := To_Unbounded_String(GNAT.Command_Line.Parameter);
        when 'e' =>
            Put_Line("Event table: " & GNAT.Command_Line.Parameter);
            event_table_name := To_Unbounded_String(GNAT.Command_Line.Parameter);
        when 'd' =>
            Put_Line("Sched duration: " & GNAT.Command_Line.Parameter);
            sched_duration := Integer'Value(GNAT.Command_Line.Parameter);
        when 'x' =>
            Put_Line("Export Data: " & GNAT.Command_Line.Parameter);
            if (Integer'Value(GNAT.Command_Line.Parameter) = 1) then
                export_data := True;
            else
                export_data := False;
            end if;
        when 'l' =>
            Put_Line("Log Directory: " & GNAT.Command_Line.Parameter);
            log_directory := To_Unbounded_String(GNAT.Command_Line.Parameter);
        when 'n' =>
            Put_Line("No debug");
            Cheddar_Debug := No_Debug;
        when others =>
            OS_Exit(0);
        end case;
    end loop;

    if(test_mode = 'F') then
        if(input_file_path = empty_string) then
            Put_Line("- Please specify system file name with -f FILENAME");
            GNAT.OS_Lib.OS_Exit (0);
        end if;

        Set_Initialize;
        Initialize (sys);

        sys.Read_From_Xml_File(Dir_List  => Project_File_Dir_List,
                               File_Name => input_file_path);

        begin
            if(sched_duration = 0) then
                sched_duration := get_max_offset(sys.Tasks) + get_max_start_time(sys.Tasks) + Compute_Hyperperiod(sys.Tasks);
            end if;
        exception
            when Constraint_Error =>
                sched_duration := Integer'Last;
        end;

        -- Run the simulation and export data
        Put_Line("- Simulation Period:" & sched_duration'Img);     
        sched := scheduling_simulation_with_buffer(sched_duration,sys,To_Unbounded_String(To_String(input_file_path) & ".ev.xml"),export_data);
        Put_Line("- Simulation complete !");

        if (export_data) then
            Put_Line("- Exported Event Table to: " & To_String(input_file_path) & ".ev.xml");
        end if;

        -- Analyze the event table
        Put_Line("- Analyze_Buffer_Event_Table");
        Put_Line(To_String(input_file_path));

        Analyze_Buffer_Event_Table(Sys            => sys,
                                   Sched          => sched,
                                   Sched_Duration => sched_duration,
                                   File_Name      => To_Unbounded_String(Ada.Directories.Simple_Name(Name => To_String(input_file_path))),
                                   Log_Directory  => log_directory);

    elsif(test_mode = 'I') then
        analyze_buffer_event_table(Input_System      => input_file_path,
                                   Input_Event_Table => event_table_name,
                                   Sched_Duration    => sched_duration,
                                   Log_Directory     => log_directory);

    elsif(test_mode = '1') then
        Set_Directory(exp_dir);
        Case_Study_01;
        sys.Read_From_Xml_File(Dir_List  => Project_File_Dir_List,
                               File_Name => To_Unbounded_String("Buffer_Sched_Case_Study_01.xmlv3"));
        sched := scheduling_simulation_with_buffer(40,
                                                   sys,
                                                   To_Unbounded_String("Buffer_Sched_Case_Study_01_Event_Table.xml"),TRUE);

    elsif(test_mode = '2') then
        Set_Directory(exp_dir);
        Case_Study_02_Buffer_Initial_Data;
        sys.Read_From_Xml_File(Dir_List  => Project_File_Dir_List,
                               File_Name => To_Unbounded_String("Buffer_Sched_Case_Study_02_Buffer_Initial_Data.xmlv3"));
        sched := scheduling_simulation_with_buffer(40,
                                                   sys,
                                                   To_Unbounded_String("Buffer_Sched_Case_Study_02_Buffer_Initial_Data_Event_Table.xml"),TRUE);

    elsif(test_mode = '3') then
        Set_Directory(exp_dir);
        Case_Study_03_Buffer_Underflow;
        sys.Read_From_Xml_File(Dir_List  => Project_File_Dir_List,
                               File_Name => To_Unbounded_String("Buffer_Sched_Case_Study_03_Buffer_Underflow.xmlv3"));
        sched := scheduling_simulation_with_buffer(40,
                                                   sys,
                                                   To_Unbounded_String("Buffer_Sched_Case_Study_03_Buffer_Underflow_Event_Table.xml"),TRUE);

    elsif(test_mode = '4') then
        Set_Directory(exp_dir);
        Case_Study_04_Buffer_Overflow;
        sys.Read_From_Xml_File(Dir_List  => Project_File_Dir_List,
                               File_Name => To_Unbounded_String("Buffer_Sched_Case_Study_04_Buffer_Overflow.xmlv3"));
        sched := scheduling_simulation_with_buffer(40,
                                                   sys,
                                                   To_Unbounded_String("Buffer_Sched_Case_Study_04_Buffer_Overflow_Event_Table.xml"),TRUE);

    elsif(test_mode = '5') then
        Set_Directory(exp_dir);
        Case_Study_05_Discrete_Cosine_Transform;
        sys.Read_From_Xml_File(Dir_List  => Project_File_Dir_List,
                               File_Name => To_Unbounded_String("Buffer_Sched_Case_Study_05_Discrete_Cosine_Transform.xmlv3"));
        sched := scheduling_simulation_with_buffer(142848,
                                                   sys,
                                                   To_Unbounded_String("Buffer_Sched_Case_Study_05_Discrete_Cosine_Transform_Event_Table.xml"),TRUE);

    elsif(test_mode = '6') then
        Set_Directory(exp_dir);
        Case_Study_06_Multi_Processor;
        
        sys.Read_From_Xml_File(Dir_List  => Project_File_Dir_List,
                               File_Name => To_Unbounded_String("Buffer_Sched_Case_Study_06_Multi_Processor.xmlv3"));

        sched := scheduling_simulation_with_buffer(40,
                                                   sys,
                                                   To_Unbounded_String("Buffer_Sched_Case_Study_06_Multi_Processor_Event_Table.xml"),TRUE);
    elsif(test_mode = '7') then
        Set_Directory(exp_dir);
        Case_Study_07_USCDF;
    elsif(test_mode = '8') then
        for i in 1..10 loop
            test_data_size := Get_Data_Size(Amplitude_Function_Str => "5_4(1_2)",
                                            Activation_Number      => i);
        end loop;
    end if;

end buffer_sched;
