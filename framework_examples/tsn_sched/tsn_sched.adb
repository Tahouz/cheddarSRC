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
with unbounded_strings;                 use unbounded_strings;
with Task_Set;                          use Task_Set;
with initialize_framework;              use initialize_framework;
with GNAT.OS_Lib;                       use GNAT.OS_Lib;
with GNAT.Command_Line;
with Ada.IO_Exceptions;
with Buffers.Extended;                  use Buffers.Extended;
with Integer_Arrays;                    use Integer_Arrays;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;

with TSN_Test_Case_Generator;           use TSN_Test_Case_Generator;
with TSN_Event_Table_Analyzer;          use TSN_Event_Table_Analyzer;
with CSV_Parser;                        use CSV_Parser;
with TSN_Scheduling_Simulation_Test;    use TSN_Scheduling_Simulation_Test;

with GNAT.OS_Lib;                       use GNAT.OS_Lib;
with GNAT.Command_Line;
with Ada.Real_Time;                     use Ada.Real_Time;
with Ada.Text_IO.Unbounded_IO;          use Ada.Text_IO.Unbounded_IO;
with Core_Units;                        use Core_Units;
with Tasks;                             use Tasks;
with Processor_Set;                     use Processor_Set;
with Scheduler_Interface;               use Scheduler_Interface;

procedure tsn_sched
is
    package Float_IO is new Ada.Text_IO.Float_IO(FLOAT);
    
    input_file_path : Unbounded_String := empty_string;
    test_mode       : Character := 'A';
    
    sys                          : System;
    a_core                       : Core_Units.Core_Unit_Ptr;
    a_task                       : Generic_Task_Ptr;
    my_iterator                  : tasks_iterator;
    pu                           : Float;
    str_pu                       : String (1..5);

    sched_duration               : Integer := 0;
    sched                        : Scheduling_Table_Ptr;
    Project_File_Dir_List        : unbounded_string_list;
    export_data                  : Boolean := False;
    str                          : Unbounded_String;
    log_directory                : Unbounded_String := empty_string;
    is_preemptive                : Unbounded_String := empty_string;
    scheduler                    : Unbounded_String := empty_string;
    sched_policy                 : Unbounded_String := empty_string;
    
    max_start_time               : Integer;
    t0                           : Integer;    
    H                            : Integer;
    idle_time                    : Integer;
    is_valid                     : Boolean := False;
    v                            : Float;
    str_v                        : String (1..5);
    
    str_data                     : Unbounded_String;
    
    Start_Time, Stop_Time        : Ada.Real_Time.Time;
    Elapsed_Time                 : Time_Span;
    
    F                            : Ada.Text_IO.File_Type;
begin    
    loop
        case GNAT.Command_Line.Getopt ("t: f: n: l: p: s: y:") is
        when ASCII.NUL =>
            exit;
            when 't' =>
            Put_Line("- Test mode: " & GNAT.Command_Line.Parameter);
            test_mode := GNAT.Command_Line.Parameter(1);
        when 'f' =>
            Put_Line("- File: " & GNAT.Command_Line.Parameter);
            input_file_path := To_Unbounded_String(GNAT.Command_Line.Parameter);
        when 'n' =>
            Put_Line("- No debug");
            Cheddar_Debug := No_Debug;
        when 'l' =>
            Put_Line("Log Directory: " & GNAT.Command_Line.Parameter);
            log_directory := To_Unbounded_String(GNAT.Command_Line.Parameter);
        when 'p' =>
            Put_Line("Preemptivity " & GNAT.Command_Line.Parameter);
            is_preemptive := To_Unbounded_String(GNAT.Command_Line.Parameter);
        when 's' =>
            Put_Line("Scheduler " & GNAT.Command_Line.Parameter);
            scheduler := To_Unbounded_String(GNAT.Command_Line.Parameter);
        when 'y' =>
            Put_Line("Sched Policy " & GNAT.Command_Line.Parameter);
            sched_policy := To_Unbounded_String(GNAT.Command_Line.Parameter);
        when others =>
            OS_Exit(0);
        end case;
    end loop;
 
    if(test_mode = 'C') then 
        if(input_file_path = empty_string) then
            Put_Line("- Please specify system file name with -f FILENAME");
            GNAT.OS_Lib.OS_Exit (0);
        end if;
        
        parse_csv(File_Name => To_String(input_file_path));   
    
    elsif(test_mode = 'A') then 
        Analyze_TSN_Event_Table(Input_System      => To_Unbounded_String("xml/TSN_Sched_Case_Study_01.xmlv3"),
                                Input_Event_Table => To_Unbounded_String("xml/TSN_Sched_Case_Study_01_EV.xmlv3"),
                                Sched_Duration    => 80);
    elsif(test_mode = 'S') then
        Set_Initialize;
        Initialize (sys);
        
        sys.Read_From_Xml_File(Dir_List  => Project_File_Dir_List,
                               File_Name => input_file_path);
        
        -- Filename
        str_data := str_data & To_Unbounded_String(Ada.Directories.Simple_Name(Name => To_String(input_file_path)));
                                        
        -- Compute processor utilization
        pu := compute_processor_utilization(Sys.tasks);        
        Float_IO.Put(str_pu, pu,2,0);
        
        Put_Line("- Processor Utilization:" & str_pu);
        str_data := str_data & "," & str_pu;
        
        -- Compute O_Max
        max_start_time := get_max_start_time(Sys.tasks);
        
        Put_Line("- Max Start Time:" & max_start_time'Img);
        str_data := str_data & "," & max_start_time'Img;        
        
        -- Compute t0
        t0 := Compute_T0(Sys.tasks);
               
        Put_Line("- t0:" & t0'Img);
        str_data := str_data & "," & t0'Img;
        
        -- Compute Sched Duration
        H := Compute_Hyperperiod(sys.Tasks);
                
        Put_Line("- Hyperperiod :" & H'Img);     
        str_data := str_data & "," & H'Img;
        
        begin
            if(sched_duration = 0) then
                sched_duration := max_start_time + 2*H;
            end if;
        exception
            when Constraint_Error =>
                sched_duration := Integer'Last;
        end;
        
        Put_Line("- Simulation Period:" & sched_duration'Img);    
        str_data := str_data & "," & sched_duration'Img;
        
        Start_Time := Clock;
        sched := scheduling_simulation_tsn(sched_duration,sys,To_Unbounded_String(To_String(input_file_path) & ".ev.xml"),export_data);
        Stop_Time := Clock;
        Elapsed_Time := Stop_Time - Start_Time;
        
        Put_Line("- Simulation complete - Elapsed time: " & Duration'Image(To_Duration (Elapsed_Time)) & " seconds");
        
                                         
        --  Analyze_TSN_Event_Table(Sys            => sys,
        --                          Sched          => sched,
        --                          Sched_Duration => sched_duration,
        --                          File_Name      => To_Unbounded_String(Ada.Directories.Simple_Name(Name => To_String(input_file_path))),
        --                          Log_Directory  => log_directory);
        
        idle_time := Verify_Idle_Time_CPU_Idle_EV(Sys            => sys,
                                                  Sched          => sched,
                                                  Hyperperiod    => H,
                                                  t0             => t0,
                                                  Sched_Duration => sched_duration);
        Put_Line("- Idle time:" & idle_time'Img);
        
        str_data := str_data & "," & idle_time'Img;
        
        -- Simulation time
        str_data := str_data & "," & Duration'Image(To_Duration (Elapsed_Time));
        
        -- Scheduler
        a_core := search_core_unit(my_core_units => Sys.core_units,
                                   name          => To_Unbounded_String("Core_1"));
        
        if(To_String(sched_policy) = "HPF") then
            a_core.scheduling.scheduler_type := Posix_1003_Highest_Priority_First_Protocol;
        elsif(To_String(scheduler) = "RM") then
            a_core.scheduling.scheduler_type := Rate_Monotonic_Protocol;
        elsif(To_String(scheduler) = "EDF") then
            a_core.scheduling.scheduler_type := Earliest_Deadline_First_Protocol;
        end if;
        
        if(To_String(is_preemptive) = "Not_Preemptive") then 
            a_core.scheduling.preemptive_type := Not_Preemptive;
        else
            a_core.scheduling.preemptive_type := Preemptive;
        end if;
        
        str_data := str_data & ", " & a_core.scheduling.scheduler_type'Img;
        str_data := str_data & ", " & a_core.scheduling.preemptive_type'Img;
        
        reset_iterator (Sys.tasks, my_iterator);

        loop
            current_element (Sys.tasks, a_task, my_iterator);
           
            if (To_String(sched_policy) = "RR") then
                a_task.policy := Sched_Rr;
            else
                a_task.policy := Sched_Fifo;
            end if;
           
            exit when is_last_element (Sys.tasks, my_iterator);
            next_element (Sys.tasks, my_iterator);
        end loop;
        
        
        -- SCHED_FIFO or SCHED_RR
        
        
        
        a_task := search_task(my_tasks => Sys.tasks,
                              name     => To_Unbounded_String("Task_1"));
        str_data := str_data & ", " & a_task.policy'Img;                              
        
        
        
        -- Verification
        
        v := Float(idle_time - t0 - 1 - H)/Float(H);
        Put_Line("- V :" & v'Img);
        if ( v >= 0.0 AND v <= pu) then
            is_valid := True;
        else    
            is_valid := False;
        end if;
        Float_IO.Put(str_v, v,2,0);
        str_data := str_data & "," & str_v;
        str_data := str_data & "," & is_valid'Img;
        
        --- Create directory and write data
        
        Put_Line(To_String(str_data));        
        if(log_directory /= empty_string) then
            begin
                Set_Directory(To_String(log_directory));
            exception
                when Ada.IO_Exceptions.Name_Error  =>
                    Create_Directory(To_String(log_directory));
                    Set_Directory(To_String(log_directory));
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
        
        begin
            Open(F,Ada.Text_IO.Append_File,"result_" & Base_Name(Containing_Directory(To_String(input_file_path))) & ".txt");
        exception
            when Ada.IO_Exceptions.Name_Error =>
                Create(F,Ada.Text_IO.Out_File,"result_" & Base_Name(Containing_Directory(To_String(input_file_path))) & ".txt");
                --Unbounded_IO.Put_Line(F,To_Unbounded_String("<task_set_name>,<PU>,<o_max>,<t_0>,<H>,<sched_duration>,<idle_point>,<sched_time>,<scheduler>,<preemptive>,<sched_policy>"));
        end;
        Unbounded_IO.Put_Line(F, str_data);
        Close(F);
    elsif (test_mode = 'G') then
        Case_Study_04;       
    end if; 
    
end tsn_sched;
