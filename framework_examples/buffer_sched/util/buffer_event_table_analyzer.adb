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

with Text_IO;                   	use Text_IO;
with Ada.Integer_Text_IO;	        use Ada.Integer_Text_IO;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Strings.Unbounded; 		use Ada.Strings.Unbounded;
with Systems;               		use Systems;
with Caches;                		use Caches;
with Cache_Set;             		use Cache_Set;
with initialize_framework; 		use initialize_framework;
with unbounded_strings; 		use unbounded_strings;
with unbounded_strings; 		use unbounded_strings.strings_table_package;
with unbounded_strings;			use unbounded_strings.unbounded_string_list_package;
with Call_Framework; 			use Call_Framework;
with Integer_Arrays; 			use Integer_Arrays;
with Basic_Block_Analysis; 		use Basic_Block_Analysis;
with CFGs; 				use CFGs;
with CFG_Node_Set.Basic_Block_Set;	use CFG_Node_Set.Basic_Block_Set;
with Basic_Blocks; 			use Basic_Blocks;
with CFG_Nodes.Extended; 		use CFG_Nodes.Extended;
with Ada.Integer_Text_IO;       	use Ada.Integer_Text_IO;
with Call_Cache_Framework; 		use Call_Cache_Framework;
with Processor_Set; 			use Processor_Set;
with Scheduler_Interface; 		use Scheduler_Interface;
with Core_Units; 			use Core_Units;
with Address_Space_Set; 		use Address_Space_Set;
with Ada.IO_Exceptions;                 use Ada.IO_Exceptions;
with GNAT.Current_Exception;            use GNAT.Current_Exception;
with Text_IO;                           use Text_IO;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with unbounded_strings;                 use unbounded_strings;
with Parameters;                        use Parameters;
with Parameters.extended;               use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;
with Systems;                           use Systems;
with Framework;                    	use Framework;
with Call_Framework;                    use Call_Framework;
with Call_Framework_Interface;          use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with Call_Scheduling_Framework;         use Call_Scheduling_Framework;
with Multiprocessor_Services;           use Multiprocessor_Services;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
with Multiprocessor_Services_Interface;	use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with GNAT.Command_Line;
with GNAT.OS_Lib;                       use GNAT.OS_Lib;
with Version;                           use Version;
with Ada.Exceptions;                    use Ada.Exceptions;
with Time_Unit_Events;                  use Time_Unit_Events;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Directories; 			use Ada.Directories;
with Scheduler;				use Scheduler;
with architecture_factory;              use architecture_factory;
with Debug;				use Debug;
with Scheduler.Fixed_Priority.Rm; 	use Scheduler.Fixed_Priority.Rm;
with Scheduler.Dynamic_Priority.Edf;	use Scheduler.Dynamic_Priority.Edf;
with Scheduler.Fixed_Priority.Hpf; 	use Scheduler.Fixed_Priority.Hpf;
with Framework_Config; 			use Framework_Config;
with Ada.Calendar; 			use Ada.Calendar;
with Ada.Calendar.Formatting;		use Ada.Calendar.Formatting;
with Cache_Utility; 			use Cache_Utility;
with Offsets;               		use Offsets;
with Offsets.extended;      		use Offsets.extended;
with Offsets;  				use Offsets.Offsets_Table_Package;
with Tables;
with Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
with Ada.Numerics.Float_Random;
with Caches;				use Caches.Cache_Blocks_Table_Package;
with Cache_Block_Set;			use Cache_Block_Set;
with Scheduling_Analysis; 		use Scheduling_Analysis;
with Time_Unit_Events;			use Time_Unit_Events.Time_Unit_Package;
with Buffers;                           use Buffers;
with Buffer_Set;                        use Buffer_Set;
with sets;
with Ada.Strings.Fixed;
with Ada.Strings;                       use Ada.Strings;
with Ada.Directories;

package body buffer_event_table_analyzer is
    package Integer_IO is new Ada.Text_IO.Integer_IO (Integer);
    package Float_IO is new Ada.Text_IO.Float_IO(FLOAT);

    buffer_header_line : String := ""
      & "===================================================================================================="
      & ASCII.LF
      & "Buffer             Size         Max Data       Utilization (Max)   Diff (Max)     Utilization (Time)"
      & ASCII.LF
      & "===================================================================================================="
      & ASCII.LF;

    event_header_line : String := ""
      & "===================================================================================================="
      & ASCII.LF
      & "Time           Event               Task                   Buffer         Data Size      Current Size"
      & ASCII.LF
      & "===================================================================================================="
      & ASCII.LF;


    procedure Output_String
      ( Item : in String;
        Width : in Integer;
        Separator : in String := "";
        Truncate : Boolean := True)
    is
        Field_Index : Integer;
    begin
        Field_Index := Integer(Text_IO.Col);
        if Item'length > Width-2 and Truncate then
            Text_IO.Put(Item(Item'First..Width-2) & Separator);
        else
            Text_IO.Put(Item & Separator);
        end if;
        Text_IO.Set_Col ( Text_IO.Count(Field_Index + Width));
    end Output_String;

    procedure Append_String
      (Source   : in out Unbounded_String;
       New_Item : in String;
       Width    : in Integer;
       Margin   : in Integer   := 0;
       Justify  : in Alignment := Left)
    is
    begin
        if New_Item'length > Width then
            Append(Source,New_Item(New_Item'First..Width));
        else
            if(Justify = Left) then
                Append(Source,New_Item);
                for i in 1..(Width-New_Item'Length) loop
                    Append(Source," ");
                end loop;
            elsif(Justify = Right) then
                for i in 1..(Width-New_Item'Length) loop
                    Append(Source," ");
                end loop;
                Append(Source,New_Item);
            end if;
        end if;

        for i in 1..Margin loop
            Append(Source," ");
        end loop;
    end Append_String;

    procedure Swap_Events
      (ETable : in out Scheduling_Sequence;
       a : in Time_Unit_Package.indexed_table_range;
       b : in Time_Unit_Package.indexed_table_range)
    is
        Temp : Time_Unit_Package.item;
    begin
        Temp := ETable.entries(a);
        ETable.entries(a) := ETable.entries(b);
        ETable.entries(b) := Temp;
    end Swap_Events;

    procedure Sort_Event_Table_By_Time(ETable : in out Scheduling_Sequence)
    is
        Finished : Boolean;
    begin
        loop
            Finished := True;
            for J in 1.. ETable.nb_entries-1 loop
                if ETable.entries(J-1).item > ETable.entries(J).item then
                    Swap_Events(ETable,J-1,J);
                    Finished := False;
                end if;
            end loop;
            exit when Finished;
        end loop;
    end Sort_Event_Table_By_Time;

    procedure Sort_Event_Table_By_Time_And_Event_Type(ETable : in out Scheduling_Sequence)
    is
        Finished : Boolean;
    begin
        loop
            Finished := True;
            for J in 1.. ETable.nb_entries-1 loop
                if ETable.entries(J-1).item > ETable.entries(J).item then
                    Swap_Events(ETable,J-1,J);
                    Finished := False;
                elsif ETable.entries(J-1).item = ETable.entries(J).item AND
                  ETable.entries(J-1).data.type_of_event = Read_From_Buffer AND
                  ETable.entries(J).data.type_of_event = Write_To_Buffer then
                    Swap_Events(ETable,J-1,J);
                    Finished := False;
                end if;
            end loop;
            exit when Finished;
        end loop;
    end Sort_Event_Table_By_Time_And_Event_Type;

    procedure Analyze_Buffer_Event_Table
      (Input_System 	 : in Unbounded_String;
       Input_Event_Table : in Unbounded_String;
       Sched_Duration    : in Integer;
       Log_Directory     : in Unbounded_String := empty_string)
    is
        Sys 	                       : System;
        Sched                            : Scheduling_Table_Ptr;
        Project_File_Dir_List            : Unbounded_String_List;
        File_Name                        : Unbounded_String;
    begin
        Set_Initialize;
        Initialize (sys);

        -- Import System----------------------------------------------------------
        --------------------------------------------------------------------------
        Put_Line("===Read system model===");
        Sys.Read_From_Xml_File(Dir_List  => Project_File_Dir_List,
                               File_Name => Input_System);

        -- Import Event Table-----------------------------------------------------
        --------------------------------------------------------------------------
        Put_Line("===Read event table===");
        Read_From_Xml_File(Sched     => Sched,
                           Sys       => Sys,
                           File_Name => To_String(Input_Event_Table));

        File_Name := To_Unbounded_String(Ada.Directories.Simple_Name(Name => To_String(Input_System)));
        
        Analyze_Buffer_Event_Table(Sys,Sched,Sched_Duration,File_Name,Log_Directory);

    end Analyze_Buffer_Event_Table;

    procedure Analyze_Buffer_Event_Table
      (Sys 	        : in System;
       Sched            : in Scheduling_Table_Ptr;
       Sched_Duration   : in Integer;
       File_Name 	: in Unbounded_String;
       Log_Directory    : in Unbounded_String := empty_string)
    is

        ETable                           : Scheduling_Sequence_Ptr;
        Buffer_ETable                    : Scheduling_Sequence;

        iterator_buffer                  : Buffers_Iterator;
        ptr_buffer                       : Buffer_Ptr;

        max_current_size                 : Integer := 0;
        min_current_size                 : Integer := Integer'Last;
        buffer_utilization_max           : Float := 0.0;
        buffer_utilization_min           : Float := 0.0;
        sum_buffer_utilization_max       : Float := 0.0;
        sum_buffer_utilization_min       : Float := 0.0;

        sum_utilization_time_unit        : Float   := 0.0;
        buffer_utilization_time          : Float   := 0.0;
        sum_buffer_utilization_time      : Float   := 0.0;

        buffer_initial_size              : Integer := 0;
        prev_time                        : Integer := 0;
        last_time                        : Integer := 0;
        current_time                     : Integer := 0;
        current_size                     : Integer := 0;
        number_of_preemption             : Integer := 0;

        total_current_number_token       : Integer := 0;
        last_total_current_number_token  : Integer := 0;
        total_buffer_size                : Integer := 0;
        min_current_number_token         : Integer := Integer'Last;
        max_current_number_token         : Integer := 0;
        avg_current_number_token         : Float   := 0.0;
        sum_current_number_token         : Long_Integer := 0;
        total_sched_number_token         : Long_Integer := 0;

        result                           : Unbounded_String;
        result_buffer_utilization_time   : String(1 .. 5);
        result_buffer_utilization_max    : String(1 .. 5);
        result_buffer_utilization_min    : String(1 .. 5);
        result_preemption                : String(1 .. 5);
        result_min_current_number_token  : String(1 .. 5);
        result_max_current_number_token  : String(1 .. 5);
        result_avg_current_number_token  : String(1 .. 5);
        result_error_code                : String(1 .. 5);
        F                                : Ada.Text_IO.File_Type;

        str_buffer                       : Unbounded_String;
        str_all_buffer                   : Unbounded_String;

        is_underflow                     : Boolean := False;
        is_overflow                      : Boolean := False;
        error_code                       : Integer := 0;
        
        procedure print_line
          (c : Character)
        is
        begin
            New_Line;
            for i in 0..99 loop
                Put(c);
            end loop;
            New_Line;
        end;

        procedure print_buffer_header
        is
        begin
            print_line('=');
            print_line('=');
            Output_String("Buffer",15);
            Output_String("Size",15);
            Output_String("Max Data",15);
            Output_String("Utilization (Max)",20);
            Output_String("Diff (Max)",15);
            Output_String("Utilization (Time)",20);
            print_line('=');
        end;

        procedure print_buffer
          (a_buffer : in Buffer_Ptr;
           max_current_size : in Integer;
           buffer_utilization_max : in Float;
           buffer_utilization_time : in Float)
        is
        begin
            Output_String(To_String(a_buffer.name),15);
            Put(a_buffer.buffer_size'Img);
            Text_IO.Set_Col (30);
            Put(max_current_size    'Img);
            Text_IO.Set_Col (45);
            Float_IO.Put(buffer_utilization_max,2,2,0);
            Text_IO.Set_Col (65);
            Put((a_buffer.buffer_size - max_current_size));
            Text_IO.Set_Col (85);
            Float_IO.Put(buffer_utilization_time,2,2,0);
            New_line;
        end;

        procedure print_buffer
          (r_string                : out Unbounded_String;
           a_buffer                : in Buffer_Ptr;
           max_current_size        : in Integer;
           buffer_utilization_max  : in Float;
           buffer_utilization_time : in Float)
        is
            str_buffer_utilization_max : String (1..5);
            str_buffer_utilization_time : String (1..5);
            diff : Integer := 0;
        begin

            Float_IO.Put(str_buffer_utilization_max, buffer_utilization_max,2,0);
            Float_IO.Put(str_buffer_utilization_time, buffer_utilization_time,2,0);
            diff := a_buffer.buffer_size - max_current_size;


            Append_String(r_string,To_String(a_buffer.name),20);
            Append_String(r_string,Integer'Image(a_buffer.buffer_size),15);
            Append_String(r_string,Integer'Image(max_current_size),15);
            Append_String(r_string,str_buffer_utilization_max,20);
            Append_String(r_string,Integer'Image(diff),15);
            Append_String(r_string,str_buffer_utilization_time,10);
            Append(r_string,ASCII.LF);
        end;

        procedure print_event
          (item          : Integer;
           type_of_event : Time_Unit_Event_Type;
           task_name     : Unbounded_String;
           buffer_name   : Unbounded_String;
           data_size     : Integer;
           current_size  : Integer)
        is
        begin
            Integer_IO.Put(item,10);
            Text_IO.Set_Col ( Text_IO.Col + 5);
            Put(type_of_event'Img);
            Text_IO.Set_Col (35);
            Output_String(To_String(task_name),20);
            Output_String(To_String(buffer_name),15);
            Integer_IO.Put(data_size,15);
            Integer_IO.Put(current_size,15);
            New_Line;
        end;

        procedure print_event
          (str_event     : out Unbounded_String;
           item          : in Integer;
           type_of_event : in Time_Unit_Event_Type;
           task_name     : in Unbounded_String;
           buffer_name   : in Unbounded_String;
           data_size     : in Integer;
           current_size  : in Integer)
        is
        begin
            Append_String(str_event,Integer'Image(item),15);
            Append_String(str_event,type_of_event'Img,20);
            Append_String(str_event,To_String(task_name),20,2);
            Append_String(str_event,To_String(buffer_name),15);
            Append_String(str_event,Integer'Image(data_size),15);
            Append_String(str_event,Integer'Image(current_size),15);
            Append(str_event,ASCII.LF);
        end;

        procedure print_scheduling_sequence
          (ETable                  : Scheduling_Sequence)
        is
            str_all_event           : Unbounded_String;
        begin
            print_line('=');
            Output_String("Time",15);
            Output_String("Event",20);
            Output_String("Task",20);
            Output_String("Buffer",15);
            Output_String("Data Size",15);
            Output_String("Current Size",15);
            print_line('=');

            Append(str_all_event,event_header_line);

            for i in 0..ETable.nb_entries-1 loop
                if (ETable.entries(i).data.type_of_event = READ_FROM_BUFFER) then
                    print_event(item          => ETable.entries(i).item,
                                type_of_event => ETable.entries(i).data.type_of_event,
                                task_name     => ETable.entries(i).data.read_task.name,
                                buffer_name   => ETable.entries(i).data.read_buffer.name,
                                data_size     => ETable.entries(i).data.read_size,
                                current_size  => ETable.entries(i).data.read_buffer_current_data_size);

                    print_event(str_event     => str_all_event,
                                item          => ETable.entries(i).item,
                                type_of_event => ETable.entries(i).data.type_of_event,
                                task_name     => ETable.entries(i).data.read_task.name,
                                buffer_name   => ETable.entries(i).data.read_buffer.name,
                                data_size     => ETable.entries(i).data.read_size,
                                current_size  => ETable.entries(i).data.read_buffer_current_data_size);
                end if;

                if (ETable.entries(i).data.type_of_event = WRITE_TO_BUFFER) then
                    print_event(item          => ETable.entries(i).item,
                                type_of_event => ETable.entries(i).data.type_of_event,
                                task_name     => ETable.entries(i).data.write_task.name,
                                buffer_name   => ETable.entries(i).data.write_buffer.name,
                                data_size     => ETable.entries(i).data.write_size,
                                current_size  => ETable.entries(i).data.write_buffer_current_data_size);

                    print_event(str_event     => str_all_event,
                                item          => ETable.entries(i).item,
                                type_of_event => ETable.entries(i).data.type_of_event,
                                task_name     => ETable.entries(i).data.write_task.name,
                                buffer_name   => ETable.entries(i).data.write_buffer.name,
                                data_size     => ETable.entries(i).data.write_size,
                                current_size  => ETable.entries(i).data.write_buffer_current_data_size);
                end if;

                if (ETable.entries(i).data.type_of_event = BUFFER_UNDERFLOW) then
                    print_event(item          => ETable.entries(i).item,
                                type_of_event => ETable.entries(i).data.type_of_event,
                                task_name     => ETable.entries(i).data.underflow_task.name,
                                buffer_name   => ETable.entries(i).data.underflow_buffer.name,
                                data_size     => ETable.entries(i).data.underflow_read_size,
                                current_size  => ETable.entries(i).data.underflow_buffer_current_data_size);

                    print_event(str_event     => str_all_event,
                                item          => ETable.entries(i).item,
                                type_of_event => ETable.entries(i).data.type_of_event,
                                task_name     => ETable.entries(i).data.underflow_task.name,
                                buffer_name   => ETable.entries(i).data.underflow_buffer.name,
                                data_size     => ETable.entries(i).data.underflow_read_size,
                                current_size  => ETable.entries(i).data.underflow_buffer_current_data_size);
                end if;
                    
                if (ETable.entries(i).data.type_of_event = BUFFER_OVERFLOW) then
                    print_event(item          => ETable.entries(i).item,
                                type_of_event => ETable.entries(i).data.type_of_event,
                                task_name     => ETable.entries(i).data.overflow_task.name,
                                buffer_name   => ETable.entries(i).data.overflow_buffer.name,
                                data_size     => ETable.entries(i).data.overflow_write_size,
                                current_size  => ETable.entries(i).data.overflow_buffer_current_data_size);

                    print_event(str_event     => str_all_event,
                                item          => ETable.entries(i).item,
                                type_of_event => ETable.entries(i).data.type_of_event,
                                task_name     => ETable.entries(i).data.overflow_task.name,
                                buffer_name   => ETable.entries(i).data.overflow_buffer.name,
                                data_size     => ETable.entries(i).data.overflow_write_size,
                                current_size  => ETable.entries(i).data.overflow_buffer_current_data_size);
                end if;
            end loop;

            print_line('=');
            Output_String("Time",15);
            Output_String("Event",20);
            Output_String("Task",20);
            Output_String("Buffer",15);
            Output_String("Data Size",15);
            Output_String("Current Size",15);
            print_line('=');
        end;

        procedure print_scheduling_table
          (Sched : in Scheduling_Table_Ptr)
        is
            ETable                  : Scheduling_Sequence_Ptr;
            str_all_event           : Unbounded_String;
        begin
            for j in 0..Sched.nb_entries-1 loop

                ETable := Sched.entries(j).data.result;

                print_line('=');
                Output_String("Time",15);
                Output_String("Event",20);
                Output_String("Task",20);
                Output_String("Buffer",15);
                Output_String("Data Size",15);
                Output_String("Current Size",15);
                print_line('=');

                Append(str_all_event,event_header_line);

                for i in 0..ETable.nb_entries-1 loop
                    if (ETable.entries(i).data.type_of_event = READ_FROM_BUFFER) then
                        print_event(item          => ETable.entries(i).item,
                                    type_of_event => ETable.entries(i).data.type_of_event,
                                    task_name     => ETable.entries(i).data.read_task.name,
                                    buffer_name   => ETable.entries(i).data.read_buffer.name,
                                    data_size     => ETable.entries(i).data.read_size,
                                    current_size  => ETable.entries(i).data.read_buffer_current_data_size);

                        print_event(str_event     => str_all_event,
                                    item          => ETable.entries(i).item,
                                    type_of_event => ETable.entries(i).data.type_of_event,
                                    task_name     => ETable.entries(i).data.read_task.name,
                                    buffer_name   => ETable.entries(i).data.read_buffer.name,
                                    data_size     => ETable.entries(i).data.read_size,
                                    current_size  => ETable.entries(i).data.read_buffer_current_data_size);
                    end if;

                    if (ETable.entries(i).data.type_of_event = WRITE_TO_BUFFER) then
                        print_event(item          => ETable.entries(i).item,
                                    type_of_event => ETable.entries(i).data.type_of_event,
                                    task_name     => ETable.entries(i).data.write_task.name,
                                    buffer_name   => ETable.entries(i).data.write_buffer.name,
                                    data_size     => ETable.entries(i).data.write_size,
                                    current_size  => ETable.entries(i).data.write_buffer_current_data_size);

                        print_event(str_event     => str_all_event,
                                    item          => ETable.entries(i).item,
                                    type_of_event => ETable.entries(i).data.type_of_event,
                                    task_name     => ETable.entries(i).data.write_task.name,
                                    buffer_name   => ETable.entries(i).data.write_buffer.name,
                                    data_size     => ETable.entries(i).data.write_size,
                                    current_size  => ETable.entries(i).data.write_buffer_current_data_size);
                    end if;
                                        
                    if (ETable.entries(i).data.type_of_event = BUFFER_UNDERFLOW) then
                        print_event(item          => ETable.entries(i).item,
                                    type_of_event => ETable.entries(i).data.type_of_event,
                                    task_name     => ETable.entries(i).data.underflow_task.name,
                                    buffer_name   => ETable.entries(i).data.underflow_buffer.name,
                                    data_size     => ETable.entries(i).data.underflow_read_size,
                                    current_size  => ETable.entries(i).data.underflow_buffer_current_data_size);

                        print_event(str_event     => str_all_event,
                                    item          => ETable.entries(i).item,
                                    type_of_event => ETable.entries(i).data.type_of_event,
                                    task_name     => ETable.entries(i).data.underflow_task.name,
                                    buffer_name   => ETable.entries(i).data.underflow_buffer.name,
                                    data_size     => ETable.entries(i).data.underflow_read_size,
                                    current_size  => ETable.entries(i).data.underflow_buffer_current_data_size);
                    end if;
                    
                    if (ETable.entries(i).data.type_of_event = BUFFER_OVERFLOW) then
                        print_event(item          => ETable.entries(i).item,
                                    type_of_event => ETable.entries(i).data.type_of_event,
                                    task_name     => ETable.entries(i).data.overflow_task.name,
                                    buffer_name   => ETable.entries(i).data.overflow_buffer.name,
                                    data_size     => ETable.entries(i).data.overflow_write_size,
                                    current_size  => ETable.entries(i).data.overflow_buffer_current_data_size);

                        print_event(str_event     => str_all_event,
                                    item          => ETable.entries(i).item,
                                    type_of_event => ETable.entries(i).data.type_of_event,
                                    task_name     => ETable.entries(i).data.overflow_task.name,
                                    buffer_name   => ETable.entries(i).data.overflow_buffer.name,
                                    data_size     => ETable.entries(i).data.overflow_write_size,
                                    current_size  => ETable.entries(i).data.overflow_buffer_current_data_size);
                    end if;

                end loop;

                Create(F,Ada.Text_IO.Out_File,To_String(File_Name & "_Event.txt"));
                Unbounded_IO.Put(F, str_all_event);
                Close(F);
            end loop;
        end;

        function check_overflow
          (Sched : in Scheduling_Table_Ptr)
           return Boolean
        is
            ETable : Scheduling_Sequence_Ptr;
        begin            
            for j in 0..Sched.nb_entries-1 loop

                ETable := Sched.entries(j).data.result;
                
                for i in 0..ETable.nb_entries-1 loop                                   
                    if (ETable.entries(i).data.type_of_event = BUFFER_OVERFLOW) then
                        return True;
                    end if;
                end loop;
            end loop;
            
            return False;
        end;
        
        function check_underflow
          (Sched : in Scheduling_Table_Ptr)
           return Boolean
        is
            ETable : Scheduling_Sequence_Ptr;
        begin            
            for j in 0..Sched.nb_entries-1 loop

                ETable := Sched.entries(j).data.result;
                
                for i in 0..ETable.nb_entries-1 loop                                   
                    if (ETable.entries(i).data.type_of_event = BUFFER_UNDERFLOW) then
                        return True;
                    end if;
                end loop;
            end loop;
            
            return False;
        end;
                                          
        function get_number_of_preemption
          (Sched : in Scheduling_Table_Ptr)
           return Integer
        is
            number_of_preemption : Integer := 0;
            ETable               : Scheduling_Sequence_Ptr;
        begin
            for j in 0..Sched.nb_entries-1 loop

                ETable := Sched.entries(j).data.result;

                for i in 0..ETable.nb_entries-1 loop

                    if (ETable.entries(i).data.type_of_event = PREEMPTION) then

                        number_of_preemption := number_of_preemption + 1;
                    end if;
                end loop;
            end loop;
            return number_of_preemption;
        end;

    begin
        Put_Line("- Starting buffer utilization analysis");

        If(Log_Directory /= empty_string) then
            begin
                Set_Directory(To_String(Log_Directory));
            exception
                when Ada.IO_Exceptions.Name_Error  =>
                    Create_Directory(To_String(Log_Directory));
                    Set_Directory(To_String(Log_Directory));
            end;
        else
            begin
                Set_Directory("log/");
            exception
                when Ada.IO_Exceptions.Name_Error  =>
                    Create_Directory("log/");
                    Set_Directory("log/");
            end;
        end if;


        -- Sheduling Table--------------------------------------------------------
        --------------------------------------------------------------------------
        print_scheduling_table(Sched);     
        
        -- Over/Under flow check--------------------------------------------------
        --------------------------------------------------------------------------
        is_underflow := check_underflow(Sched);
        if(is_underflow) then
            error_code := error_code+1;
        end if;
        
        is_overflow := check_overflow(Sched);
        if(is_overflow) then
            error_code := error_code+2;
        end if;
        --------------------------------------------------------------------------
        
        
        -- Buffer Utilisation Analysis--------------------------------------------
        -- Analysis is done per buffer
        --------------------------------------------------------------------------
        print_buffer_header;

        reset_iterator (Sys.Buffers, iterator_buffer);
        loop
            current_element (Sys.Buffers, ptr_buffer, iterator_buffer);

            initialize(Buffer_ETable);  --Store events related to the buffer
            max_current_size := 0;
            str_buffer := empty_string;

            -- Analyse Buffer Utilisation (Max)
            --
            for j in 0..Sched.nb_entries-1 loop

                ETable := Sched.entries(j).data.result;

                for i in 0..ETable.nb_entries-1 loop

                    if (ETable.entries(i).data.type_of_event = READ_FROM_BUFFER) then

                        if(ETable.entries(i).data.read_buffer.name = ptr_buffer.name) then

                            if(max_current_size < ETable.entries(i).data.read_buffer_current_data_size) then
                                max_current_size := ETable.entries(i).data.read_buffer_current_data_size;
                            end if;

                            if(min_current_size > ETable.entries(i).data.read_buffer_current_data_size -
                                 ETable.entries(i).data.read_size) then
                                min_current_size := ETable.entries(i).data.read_buffer_current_data_size -
                                  ETable.entries(i).data.read_size;
                            end if;

                            Add(Buffer_ETable, ETable.entries(i).item, ETable.entries(i).data);
                        end if;

                    elsif(ETable.entries(i).data.type_of_event = WRITE_TO_BUFFER) then

                        if(ETable.entries(i).data.write_buffer.name = ptr_buffer.name) then

                            if(max_current_size < ETable.entries(i).data.write_buffer_current_data_size +
                                 ETable.entries(i).data.write_size) then

                                max_current_size := ETable.entries(i).data.write_buffer_current_data_size +
                                  ETable.entries(i).data.write_size;
                            end if;

                            if(min_current_size > ETable.entries(i).data.write_buffer_current_data_size) then
                                min_current_size := ETable.entries(i).data.write_buffer_current_data_size;
                            end if;

                            Add(Buffer_ETable, ETable.entries(i).item, ETable.entries(i).data);
                        end if;
                    end if;
                end loop;
            end loop;

            buffer_utilization_max := Float(max_current_size)/Float(ptr_buffer.buffer_size);
            buffer_utilization_min := Float(min_current_size)/Float(ptr_buffer.buffer_size);
            sum_buffer_utilization_max := sum_buffer_utilization_max + buffer_utilization_max;
            sum_buffer_utilization_min := sum_buffer_utilization_min + buffer_utilization_min;
            -----------------------------------------------------------------------

            -- Analyse Buffer Utilisation Over Time
            --
            buffer_initial_size         := ptr_buffer.buffer_initial_data_size;
            current_time                := 0;
            prev_time                   := 0;
            sum_utilization_time_unit   := 0.0;

            Sort_Event_Table_By_Time(Buffer_ETable);
            for i in 0..Buffer_ETable.nb_entries-1 loop

                current_time := Buffer_ETable.entries(i).item;

                if (Buffer_ETable.entries(i).data.type_of_event = READ_FROM_BUFFER) then
                    current_size := Buffer_ETable.entries(i).data.read_buffer_current_data_size;

                elsif (Buffer_ETable.entries(i).data.type_of_event = WRITE_TO_BUFFER) then
                    current_size := Buffer_ETable.entries(i).data.write_buffer_current_data_size;

                end if;

                sum_utilization_time_unit := sum_utilization_time_unit
                  + (Float(current_size)/Float(ptr_buffer.buffer_size))
                  * Float(current_time-prev_time);

                prev_time := current_time;
            end loop;

            if (Buffer_ETable.entries(Buffer_ETable.nb_entries-1).data.type_of_event = READ_FROM_BUFFER) then

                current_size :=
                  Buffer_ETable.entries(Buffer_ETable.nb_entries-1).data.read_buffer_current_data_size
                  - Buffer_ETable.entries(Buffer_ETable.nb_entries-1).data.read_size;

            elsif (Buffer_ETable.entries(Buffer_ETable.nb_entries-1).data.type_of_event = WRITE_TO_BUFFER) then

                current_size :=
                  Buffer_ETable.entries(Buffer_ETable.nb_entries-1).data.write_buffer_current_data_size
                  + Buffer_ETable.entries(Buffer_ETable.nb_entries-1).data.write_size;
            end if;

            sum_utilization_time_unit := sum_utilization_time_unit
              + (Float(current_size)/Float(ptr_buffer.buffer_size))
              * Float(Sched_Duration-Buffer_ETable.entries(Buffer_ETable.nb_entries-1).item);

            buffer_utilization_time := sum_utilization_time_unit / Float(Sched_Duration);
            sum_buffer_utilization_time := sum_buffer_utilization_time + buffer_utilization_time;
            -----------------------------------------------------------------------

            print_buffer(ptr_buffer,
                         max_current_size,
                         buffer_utilization_max,
                         buffer_utilization_time);

            print_buffer(str_buffer,
                         ptr_buffer,
                         max_current_size,
                         buffer_utilization_max,
                         buffer_utilization_time);

            Append(str_all_buffer, str_buffer);

            exit when is_last_element (Sys.Buffers, iterator_buffer);
            next_element (Sys.Buffers, iterator_buffer);
        end loop;

        -- Buffer Utilisation Analysis--------------------------------------------
        -- Analysis over time
        -- - Copy All event into a table
        -- - Sort the events by time, if same time, then WRITE before READ
        -- - Compute the total tokens at a given time
        --
        --------------------------------------------------------------------------
        total_current_number_token := 0;

        reset_iterator (Sys.Buffers, iterator_buffer);
        loop
            current_element (Sys.Buffers, ptr_buffer, iterator_buffer);
            total_buffer_size := total_buffer_size + ptr_buffer.buffer_size;
            total_current_number_token := total_current_number_token + ptr_buffer.buffer_initial_data_size;
            exit when is_last_element (Sys.Buffers, iterator_buffer);
            next_element (Sys.Buffers, iterator_buffer);
        end loop;

        initialize(Buffer_ETable);

        for j in 0..Sched.nb_entries-1 loop
            ETable := Sched.entries(j).data.result;
            for i in 0..ETable.nb_entries-1 loop
                if (ETable.entries(i).data.type_of_event = READ_FROM_BUFFER) OR
                  (ETable.entries(i).data.type_of_event = WRITE_TO_BUFFER) then

                    Add(Buffer_ETable, ETable.entries(i).item, ETable.entries(i).data);
                end if;
            end loop;
        end loop;

        Sort_Event_Table_By_Time_And_Event_Type(Buffer_ETable);
        print_scheduling_sequence(Buffer_ETable);                          
             
        current_time := 0;
        last_time := 0;
        for i in 0..Buffer_ETable.nb_entries-1 loop
            current_time := Buffer_ETable.entries(i).item;

            if(current_time /= prev_time) then
                sum_current_number_token := sum_current_number_token + Long_Integer(last_total_current_number_token) * Long_Integer((current_time-prev_time));
            end if;

            if (Buffer_ETable.entries(i).data.type_of_event = READ_FROM_BUFFER) then
                total_current_number_token := total_current_number_token - Buffer_ETable.entries(i).data.read_size;
            elsif (Buffer_ETable.entries(i).data.type_of_event = WRITE_TO_BUFFER) then
                total_current_number_token := total_current_number_token + Buffer_ETable.entries(i).data.write_size;
            end if;

            prev_time := current_time;
            last_total_current_number_token := total_current_number_token;

            Put_Line("- " & current_time'Img & " : " & total_current_number_token'Img & " / " & total_buffer_size'Img);

            if(total_current_number_token > max_current_number_token) then
                max_current_number_token := total_current_number_token;
            end if;

            if(total_current_number_token < min_current_number_token) then
                min_current_number_token := total_current_number_token;
            end if;
        end loop;


        
        sum_current_number_token := sum_current_number_token + Long_Integer(last_total_current_number_token) * Long_Integer(Sched_Duration-prev_time);
        total_sched_number_token := Long_Integer(total_buffer_size)*Long_Integer(Sched_Duration);        
        Put_Line("Debug data: sum_current: " & sum_current_number_token'Img);
        Put_Line("Debug data: sum_current: " & total_sched_number_token'Img);
        avg_current_number_token := Float(sum_current_number_token)/Float(total_sched_number_token);                
        
        --------------------------------------------------------------------------
        -- Output data -----------------------------------------------------------
        --------------------------------------------------------------------------

        Create(F,Ada.Text_IO.Out_File, To_String(File_Name & "_Buffer.txt"));
        Unbounded_IO.Put(F, To_Unbounded_String(buffer_header_line));
        Unbounded_IO.Put(F, str_all_buffer);
        Unbounded_IO.Put(F, To_Unbounded_String(buffer_header_line));
        Close(F);

        --------------------------------------------------------------------------
        -- Output data ---------------------------------------------------
        --------------------------------------------------------------------------
        print_line('=');
        
        if(is_overflow) then
            Put_Line("BUFFER OVERFLOW detected !");
        end if;
        if(is_underflow) then
            Put_Line("BUFFER UNDERFLOW detected !");
        end if;
        
        Put("Average buffer utilization (Max, per buffer): ");
        Float_IO.Put(sum_buffer_utilization_max / Float(get_number_of_elements(Sys.Buffers)),
                     2,2,0);
        Float_IO.Put(result_buffer_utilization_max,
                     sum_buffer_utilization_max / Float(get_number_of_elements(Sys.Buffers)),
                     2,0);
        New_Line;

        Put("Average buffer utilization (Min, per buffer): ");
        Float_IO.Put(sum_buffer_utilization_min / Float(get_number_of_elements(Sys.Buffers)),
                     2,2,0);
        Float_IO.Put(result_buffer_utilization_min,
                     sum_buffer_utilization_min / Float(get_number_of_elements(Sys.Buffers)),
                     2,0);
        New_Line;

        Put("Average buffer utilization (Over time): ");
        Float_IO.Put(sum_buffer_utilization_time / Float(get_number_of_elements(Sys.Buffers)),
                     2,2,0);
        Float_IO.Put(result_buffer_utilization_time,
                     sum_buffer_utilization_time / Float(get_number_of_elements(Sys.Buffers)),
                     2,0);
        New_Line;

        Float_IO.Put(result_min_current_number_token,
                     Float(min_current_number_token)/Float(total_buffer_size),
                     2,0);
        Put_Line("Min total current number of token: "
                 & result_min_current_number_token
                 & " ("
                 & min_current_number_token'Img &" /" & total_buffer_size'Img
                 & ")");


        Float_IO.Put(result_max_current_number_token,
                     Float(max_current_number_token)/Float(total_buffer_size),
                     2,0);
        Put_Line("Max total current number of token: "
                 & result_max_current_number_token
                 & " ("
                 & max_current_number_token'Img
                 & " /" & total_buffer_size'Img
                 & ")");

        Float_IO.Put(result_avg_current_number_token,
                     avg_current_number_token,
                     2,0);
        Put("Average total current number of token: ");
        Float_IO.Put(avg_current_number_token,
                     2,2,0);
        New_Line;

        number_of_preemption := get_number_of_preemption(Sched);
        Put_Line("Number of preemption: " & number_of_preemption'Img);
        Integer_IO.Put(result_preemption, number_of_preemption);
        
        
        Put("Error code: " & error_code'Img);
        Integer_IO.Put(result_error_code, error_code);

        print_line('=');
        
        begin
            Open(F,Ada.Text_IO.Append_File,"Result.txt");
        exception
            when Ada.IO_Exceptions.Name_Error =>
                Create(F,Ada.Text_IO.Out_File,"Result.txt");
                Unbounded_IO.Put_Line(F, To_Unbounded_String("<filename>, <avg buff min>, <avg buff max>, <avg buf avg>, <preempt>, <tot token min>, <tot token max>, <tot token avg>"));
        end;

        Append_String(result,To_String(File_Name),70);
        Append_String(result,"," & result_buffer_utilization_min,10);
        Append_String(result,"," & result_buffer_utilization_max,10);
        Append_String(result,"," & result_buffer_utilization_time,10);
        Append_String(result,"," & result_preemption,10);
        Append_String(result,"," & result_min_current_number_token,10);
        Append_String(result,"," & result_max_current_number_token,10);
        Append_String(result,"," & result_avg_current_number_token,10);
        Append_String(result,"," & result_error_code,10);
        Unbounded_IO.Put(F, result);
        Close(F);

    end analyze_buffer_event_table;

end  buffer_event_table_analyzer;
