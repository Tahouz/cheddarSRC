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

with io_tools;                          use io_tools;
with Text_IO;                           use Text_IO;
with Processor_Set;                     use Processor_Set;
use Processor_Set.Generic_Processor_Set;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with Parameters;                        use Parameters;
with Parameters.extended;               use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;
with Task_Set;                          use Task_Set;
use Task_Set.Generic_Task_Set;
with tasks;                             use tasks;
with task_dependencies;                 use task_dependencies;
with Messages;                          use Messages;
with Message_Set;                        use Message_Set;
use task_dependencies.Half_Dep_Set;
with dependencies;                      use dependencies;
with sets;                             
with Systems;                           use Systems;
with Call_Framework;                    use Call_Framework;
with Call_Framework_Interface;          use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with framework;                         use framework;
with Call_Scheduling_Framework;         use Call_Scheduling_Framework;
with Multiprocessor_Services;           use Multiprocessor_Services;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with debug; use debug;
with GNAT.Command_Line;
with GNAT.OS_Lib;                       use GNAT.OS_Lib;
with Version;                           use Version;
with Ada.Exceptions;                    use Ada.Exceptions;

with mils_security; use mils_security;
with mils_analysis; use mils_analysis;

procedure Read_Model is


   -- To read the Cheddar architecture model
   --
   Sys                   : System;
   COIs : array_tasks_set(1..1);
   a_task : Generic_Task_Ptr;
        
   Project_File_List     : unbounded_string_list;
   Project_File_Dir_List : unbounded_string_list;

   -- Is the command should run in verbose mode ?
   --
   Verbose : Boolean := False;

   -- The XML file to read
   --
   Input_File      : Boolean := False;
   Input_File_Name : Unbounded_String;



   procedure Usage is
   begin
      Put_Line(
"read_sys reads and displays to the screen a Cheddar architecture model .");

      New_Line;
      Put_Line(
"Check Cheddar home page for details :  http://beru.univ-brest.fr/~singhoff/cheddar "
);
      New_Line;
      New_Line;
      Put_Line ("Usage : read_sys [switch] ");
      Put_Line ("   switch can be :");
      Put_Line ("            -u get this help");
      Put_Line ("            -v verbose mode ");
      Put_Line(
"            -i file-name, read and print the architecture model from the XML file  file-name "
);
      New_Line;
   end Usage;


begin

   Copyright ("read_sys");

   -- Get arguments
   --
   loop
      case GNAT.Command_Line.Getopt ("u v i:") is
         when ASCII.NUL =>
            exit;

         when 'i' =>
            Input_File      := True;
            Input_File_Name :=
               To_Unbounded_String (GNAT.Command_Line.Parameter);

         when 'v' =>
            Verbose := True;
         when 'u' =>
            Usage;
            OS_Exit (0);

         when others =>
            Usage;
            OS_Exit (0);
      end case;
   end loop;

   -- Is an input file given ???
   --
   if (not Input_File) then
      Usage;
      OS_Exit (0);
   end if;

   -- Initialize the Cheddar framework
   --
   Call_Framework.initialize (False);

   -- Read the XML project file
   --
   initialize (Project_File_List);
   Initialize (Sys);
   Systems.Read_From_Xml_File (Sys, Project_File_Dir_List, Input_File_Name);

--     X : Task_Ptr;
--     
--     X.Deadline=10;
--     X.MILS_security:=0;

   
   Initialize (COIs(1));
 --  Initialize (COIs(2));
   for j in 1 .. 2 loop
	       Add_Task(My_Tasks                 => COIs(1),
               A_Task			 	 => a_task,
               Name                      	 => Suppress_Space (To_Unbounded_String (""&j'Img)),
               Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("processor1" ))) ,
               Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("addr1")),
               Task_Type               	 	 => Periodic_Type,
               Start_Time              		 => 0 ,
               Capacity                	  	 => 5,
               Period                   	 => 50,
               Deadline                 	 => 50,
               Jitter                   	 => 0,
               Blocking_Time            	 => 0,
               Priority                 	 => 1,
               Criticality              	 => 0,
               Policy                   	 => Sched_Fifo);
   	   end loop ;

--     Add_Task(My_Tasks                 => COIs(2),
--                 A_Task			 	 => a_task,
--                 Name                      	 => Suppress_Space (To_Unbounded_String ("2")),
--                 Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor" ))) ,
--                 Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("ea")),
--                 Task_Type               	 	 => Periodic_Type,
--                 Start_Time              		 => 0 ,
--                 Capacity                	  	 => 5,
--                 Period                   	 => 50,
--                 Deadline                 	 => 50,
--                 Jitter                   	 => 0,
--                 Blocking_Time            	 => 0,
--                 Priority                 	 => 1,
--                 Criticality              	 => 0,
--                 Policy                   	 => Sched_Fifo);
      

--    
   if chinese_wall(Sys,COIs)then
      Put_Line("Chinese_wall = true !");
   else
      Put_Line("Chinese_wall = false !"); 
   end if;
   if bell_lapadula(Sys) then 
      Put_Line("Bell_lapadula = true !");
   else
      Put_Line("Bell_lapadula = false !"); 
   end if;

   if biba(Sys)then 
      Put_Line("Biba = true !");
   else
      Put_Line("Biba = false !");
   end if;

end Read_Model;

