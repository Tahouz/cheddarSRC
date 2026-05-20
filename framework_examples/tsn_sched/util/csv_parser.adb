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
with Ada.Strings.Fixed;
with Task_Set;                         use Task_Set;
with Tasks;			                   use Tasks;
with Core_Units;                       use Core_Units;
with Systems;                          use Systems;
with initialize_framework;             use initialize_framework;
with GNAT.String_Split;                use GNAT.String_Split;
with Processor_Set;                    use Processor_Set;
with Scheduler_Interface;              use Scheduler_Interface;
with unbounded_strings;                use unbounded_strings;
with Address_Space_Set;                use Address_Space_Set;
with Ada.Strings;
with Ada.Characters.Latin_1;

package body CSV_Parser is
    
    function Strip_Trailing_CRLF (S : String) return String is
        use Ada.Characters.Latin_1;
        Last : Integer := S'Last;
    begin
        -- Remove trailing LF if present
        if Last >= S'First and then S (Last) = LF then
            Last := Last - 1;
        end if;

        -- Remove trailing CR if present (covers CRLF or lone CR)
        if Last >= S'First and then S (Last) = CR then
            Last := Last - 1;
        end if;

        if Last < S'First then
            return "";
        else
            return S (S'First .. Last);
        end if;
    end Strip_Trailing_CRLF;

    procedure parse_csv (File_Name : in String)
    is 
        F    : File_Type;        
        Subs : GNAT.String_Split.Slice_Set;
        Seps : constant String := ",";
        
        sys_01 	          : System;
        core_01	          : Core_Unit_Ptr;
        task_index        : Natural := 1;
        
        str : Unbounded_String;
    begin
        
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
        
        ---------------------------------------------
        Put_Line("Open file :" & File_Name);        
        Open (F, In_File, File_Name);
        while not End_Of_File (F) loop  
            declare
                period : Integer;
                capacity : Integer;
                offset : Integer;
                
            begin
                str := To_Unbounded_String(Get_Line(F));
                
                declare 
                    str2 : String := Strip_Trailing_CRLF(To_String(str));
                begin
                    Put_Line(str2);
                    GNAT.String_Split.Create(S          => Subs,
                                             From       => str2,
                                             Separators => Seps,
                                             Mode       => GNAT.String_Split.Multiple);
                
               
                
                    period := Integer'Value (GNAT.String_Split.Slice (Subs, 1));
                    Put_Line("Period: " & period'Img);
                    capacity := Integer'Value (GNAT.String_Split.Slice (Subs, 2));
                    Put_Line("Capacity: " & capacity'Img);

                    offset := Integer'Value (GNAT.String_Split.Slice (Subs, 3));
                    Put_Line("Offset: " & offset'Img);
                
                    Put_Line(period'Img & ","
                             & capacity'Img & ","
                             & offset'Img);
                end;
                Add_Task(My_Tasks                => sys_01.Tasks,
                         Name                    => To_Unbounded_String("Task_" & Ada.Strings.Fixed.Trim(task_index'Img, Ada.Strings.Left)),
                         Cpu_Name                => To_Unbounded_String("CPU_1"),
                         core_name               => empty_string,
                         Address_Space_Name      => To_Unbounded_String("Address_Space_1"),
                         Task_Type               => Periodic_Type,
                         Start_Time              => offset,
                         Capacity                => capacity,
                         Period                  => period,
                         Deadline                => period,
                         Jitter                  => 0,
                         Blocking_Time           => 0,
                         Priority                => 1,
                         Criticality             => 0,
                         Policy                  => SCHED_FIFO);
                task_index := task_index + 1;
            end;                
        end loop;   
        
        sys_01.Write_To_Xml_File(File_Name & ".xmlv3");
        Put_Line("Export system to " & File_Name & ".xmlv3");
        ---------------------------------------------
    end parse_csv;
        
end CSV_Parser;
