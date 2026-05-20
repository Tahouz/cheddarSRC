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

package body TSN_Event_Table_Analyzer is
    package Integer_IO is new Ada.Text_IO.Integer_IO (Integer);
    package Float_IO is new Ada.Text_IO.Float_IO(FLOAT);

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
    
    procedure Print_Line
      (c : Character)
    is
    begin
        New_Line;
        for i in 0..99 loop
            Put(c);
        end loop;
        New_Line;
    end;
        
    procedure Print_Event
      (item          : Integer;
       type_of_event : Time_Unit_Event_Type;
       task_name     : Unbounded_String)
    is
    begin
        Integer_IO.Put(item,10);
        Text_IO.Set_Col ( Text_IO.Col + 5);
        Put(type_of_event'Img);
        Text_IO.Set_Col (50);
        Output_String(To_String(task_name),20);
        New_Line;
    end;
    
    procedure Print_Event
      (item          : Integer;
       type_of_event : Time_Unit_Event_Type)
    is
    begin
        Integer_IO.Put(item,10);
        Text_IO.Set_Col ( Text_IO.Col + 5);
        Put(type_of_event'Img);
        New_Line;
    end;
        
    procedure Print_Scheduling_Sequence
      (ETable                  : Scheduling_Sequence)
    is
    begin
        for i in 0..ETable.nb_entries-1 loop
            if (ETable.entries(i).data.type_of_event = Task_Activation) then
                Print_Event(item          => ETable.entries(i).item,
                            type_of_event => ETable.entries(i).data.type_of_event,
                            task_name     => ETable.entries(i).data.activation_task.name);
            end if;
        
            if (ETable.entries(i).data.type_of_event = Running_Task) then
                Print_Event(item          => ETable.entries(i).item,
                            type_of_event => ETable.entries(i).data.type_of_event,
                            task_name     => ETable.entries(i).data.running_task.name);
            end if;
            
            if (ETable.entries(i).data.type_of_event = CPU_Idle) then
                Print_Event(item          => ETable.entries(i).item,
                            type_of_event => ETable.entries(i).data.type_of_event);
            end if;
        end loop;
    end;

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

    procedure Sort_Event_Table_By_Time_RT_before_AV(ETable : in out Scheduling_Sequence)
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
                
                if (ETable.entries(J-1).item = ETable.entries(J).item 
                    AND ETable.entries(J-1).data.type_of_event = Task_Activation                      
                    AND ETable.entries(J).data.type_of_event = Running_Task) then
                    Swap_Events(ETable,J-1,J);
                    Finished := False;
                end if;

            end loop;
            exit when Finished;
        end loop;
    end Sort_Event_Table_By_Time_RT_before_AV;
    
    procedure Sort_Event_Table_By_Time_AV_before_RT(ETable : in out Scheduling_Sequence)
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
                
                if (ETable.entries(J-1).item = ETable.entries(J).item 
                    AND ETable.entries(J-1).data.type_of_event = Running_Task
                    AND ETable.entries(J).data.type_of_event = Task_Activation) then
                    Swap_Events(ETable,J-1,J);
                    Finished := False;
                end if;

            end loop;
            exit when Finished;
        end loop;
    end Sort_Event_Table_By_Time_AV_before_RT;

    procedure Analyze_TSN_Event_Table
      (Input_System 	 : in Unbounded_String;
       Input_Event_Table : in Unbounded_String;
       Sched_Duration    : in Integer;
       Log_Directory     : in Unbounded_String := empty_string)
    is
        Sys 	                         : System;
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
        
        Analyze_TSN_Event_Table(Sys,Sched,Sched_Duration,File_Name,Log_Directory);

    end Analyze_TSN_Event_Table;

    procedure Analyze_TSN_Event_Table
      (Sys 	                : in System;
       Sched                : in Scheduling_Table_Ptr;
       Sched_Duration       : in Integer;
       File_Name            : in Unbounded_String;
       Log_Directory        : in Unbounded_String := empty_string)
    is
        ETable      : Scheduling_Sequence_Ptr;
        TSN_ETable  : Scheduling_Sequence_Ptr;
        
        c : Integer := 0;
        t : Integer := 0;
        
        str_events : Unbounded_String;
        F : Ada.Text_IO.File_Type;
        
        cpu_idle : Boolean := False;                
    begin
        
        TSN_ETable := new Scheduling_Sequence;

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
        
        -- Scan Sheduling Table (version monocore)
        for j in 0..Sched.nb_entries-1 loop
        
            ETable := Sched.entries(j).data.result;
        
            for i in 0..ETable.nb_entries-1 loop
                if (ETable.entries(i).data.type_of_event = Task_Activation OR
                      ETable.entries(i).data.type_of_event = Running_Task) then
        
                    Add(TSN_ETable.all, ETable.entries(i).item, ETable.entries(i).data);
                end if;
        
            end loop;
        end loop;
        
        -- Sort by time before start analysis
        Sort_Event_Table_By_Time_RT_before_AV(TSN_ETable.all);
        -- Print_Scheduling_Sequence(TSN_ETable.all);
        
        -- Print_Line('=');
        --
        -- Put_Line("---Time---|--Charge--");
        for t in 0..Sched_Duration loop
            for i in 0..TSN_ETable.nb_entries-1 loop
                if (TSN_ETable.entries(i).item = t-1 AND TSN_ETable.entries(i).data.type_of_event = Running_Task) then
                    c := c - 1;
        
                elsif (TSN_ETable.entries(i).item = t AND TSN_ETable.entries(i).data.type_of_event = Task_Activation) then
        
                    -- Integer_IO.Put(t,5);
                    -- Integer_IO.Put(c,10);
                    -- New_Line;
        
                    str_events := str_events & t'Img;
                    str_events := str_events & c'Img;
                    str_events := str_events & ASCII.LF;
        
                    c := c + TSN_ETable.entries(i).data.activation_task.capacity;
        
                end if;
            end loop;
        
            -- Integer_IO.Put(t,5);
            -- Integer_IO.Put(c,10);
            -- New_Line;
        
            str_events := str_events & t'Img;
            str_events := str_events & c'Img;
            str_events := str_events & ASCII.LF;
        
        end loop;
        
        Create(F,Ada.Text_IO.Out_File,To_String(File_Name & "_Event.txt"));
        Unbounded_IO.Put(F, str_events);
        Close(F);
    end Analyze_TSN_Event_Table;
    
    
    function Verify_Idle_Time
      (Sys 	                : in System;
       Sched                : in Scheduling_Table_Ptr;
       Hyperperiod          : in Integer;
       Sched_Duration       : in Integer) return Integer
    is
        ETable      : Scheduling_Sequence_Ptr;
        TSN_ETable  : Scheduling_Sequence_Ptr;
        
        c : Integer := 0;
        bl : Integer := 0;
        idle_time : Integer := 0;
        
        cpu_idle : Boolean := False;
        e_index : Time_Unit_Package.indexed_table_range := 0;
        e_counter : Time_Unit_Package.indexed_table_range := 0;
    begin                
        TSN_ETable := new Scheduling_Sequence;

        -- Scan Sheduling Table (version monocore)
        for j in 0..Sched.nb_entries-1 loop
        
            ETable := Sched.entries(j).data.result;
        
            for i in 0..ETable.nb_entries-1 loop
                if (ETable.entries(i).data.type_of_event = Task_Activation OR
                      ETable.entries(i).data.type_of_event = Running_Task) then
        
                    Add(TSN_ETable.all, ETable.entries(i).item, ETable.entries(i).data);
                end if;
        
            end loop;
        end loop;
        
        -- Sort by time before start analysis
        Sort_Event_Table_By_Time_AV_before_RT(TSN_ETable.all);
              
        for t in 0..Sched_Duration loop
            e_counter := 0;            
            for i in e_index..TSN_ETable.nb_entries-1 loop                
                if (TSN_ETable.entries(i).item = t-1 AND TSN_ETable.entries(i).data.type_of_event = Running_Task) then                    
                    c := c - 1;
                    bl := c;
                    e_counter := e_counter + 1;                             
                    if ( t >= Hyperperiod AND c = 0) then
                        idle_time := t;
                        return idle_time;
                    end if;
                elsif (TSN_ETable.entries(i).item = t AND TSN_ETable.entries(i).data.type_of_event = Task_Activation) then
                    c := c + TSN_ETable.entries(i).data.activation_task.capacity;                    
                    e_counter := e_counter + 1;                                        
                elsif (TSN_ETable.entries(i).item > t) then
                    exit;
                end if;                
            end loop;
            
            e_index := e_index + e_counter;
            
            Integer_IO.Put(t,5);
            Integer_IO.Put(c,10);
            Integer_IO.Put(bl,10);
            New_Line;

            if ( t >= Hyperperiod AND bl = 0) then
                idle_time := t;
                return idle_time;
            end if;
                        
        end loop;
        
        return idle_time;
        
    end Verify_Idle_Time;
    
    
    function Verify_Idle_Time_CPU_Idle_EV
      (Sys 	                : in System;
       Sched                : in Scheduling_Table_Ptr;
       Hyperperiod          : in Integer;
       T0                   : in Integer;
       Sched_Duration       : in Integer) return Integer
    is
        ETable      : Scheduling_Sequence_Ptr;
        TSN_ETable  : Scheduling_Sequence_Ptr;
        
        idle_time : Integer := 0;
        
    begin                
        TSN_ETable := new Scheduling_Sequence;

        -- Scan Sheduling Table (version monocore)
        for j in 0..Sched.nb_entries-1 loop
        
            ETable := Sched.entries(j).data.result;
        
            for i in 0..ETable.nb_entries-1 loop
                if (ETable.entries(i).data.type_of_event = cpu_idle) then        
                    Add(TSN_ETable.all, ETable.entries(i).item, ETable.entries(i).data);
                end if;
        
            end loop;
        end loop;
        
        --Print_Scheduling_Sequence(ETable => TSN_ETable.all);
                             
        for i in 0..TSN_ETable.nb_entries-1 loop                
            if (TSN_ETable.entries(i).item >= (Hyperperiod + T0 + 1) AND TSN_ETable.entries(i).data.type_of_event = CPU_Idle) then    
                idle_time := TSN_ETable.entries(i).item; 
                return idle_time;
            end if;          
        end loop;
                         
        return idle_time;
        
    end Verify_Idle_Time_CPU_Idle_EV;
    
end  TSN_Event_Table_Analyzer;
