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

with Ada.Strings.Unbounded;
use  Ada.Strings.Unbounded;
with Generic_Graph; use Generic_Graph;
with Tasks; use Tasks;
with Task_Set; use Task_Set;
with Task_Groups; use Task_Groups;
with Task_Group_Set; use Task_Group_Set;
with Messages; use Messages;
with Dependencies; use Dependencies;
with Systems; use Systems;
with Processors;          use Processors;
with Processor_Set;       use Processor_Set;
with Address_Spaces;      use Address_Spaces;
with Address_Space_Set;   use Address_Space_Set;
with Message_Set;         use Message_Set;
with Task_Dependencies;   use Task_Dependencies;
with Task_Dependencies;   use Task_Dependencies.Half_Dep_Set;
with convert_strings;
with unbounded_strings; use unbounded_strings;
with convert_unbounded_strings;
with Text_IO; use Text_IO;
with Systems; use Systems;
with Objects; use Objects;
with Parameters.extended; use Parameters.extended;
with Scheduler_Interface; use Scheduler_Interface;
with Ada.Finalization;
with unbounded_strings; use unbounded_strings;
with architecture_factory; use architecture_factory;
use unbounded_strings.unbounded_string_list_package;
with Unchecked_Deallocation;
with sets;
with Call_Framework;                    use Call_Framework;
with Call_Framework_Interface;          use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with framework;                         use framework;
with Call_Scheduling_Framework;         use Call_Scheduling_Framework;
with Framework_Config; use Framework_Config;
with Ada.Float_Text_IO;
with Offsets; 		use Offsets;
with Offsets; 		use Offsets.Offsets_Table_Package;
with Random_Tools; 	use Random_Tools;
with initialize_framework; use initialize_framework;
with Random_Tools; use Random_Tools;
with Ada.Numerics.Float_Random;
with Core_Units ; use Core_Units ;
with Networks ; use Networks ;
use networks.Positions_Table_Package;
with Ada.Numerics.Float_Random ; use Ada.Numerics.Float_Random ;
with debug; use debug;
with GNAT.Command_Line;
with GNAT.OS_Lib;                       use GNAT.OS_Lib;
with Version;                           use Version;
with mils_security; use mils_security;
with mils_analysis; use mils_analysis;

procedure verify_biba is
   Sys                   : System;
   a_task 		: Generic_Task_Ptr;

   -- To read the Cheddar architecture model

   Project_File_List     : unbounded_string_list;
   Project_File_Dir_List : unbounded_string_list;

   -- Is the command should run in verbose mode ?
   --
   Verbose : Boolean := False;

   -- The XML file to read
   --
   Input_File      : Boolean := False;
   Input_File_Name : Unbounded_String;

   y : natural;

   A_task_source :  Generic_Task_Ptr;
   A_task_sink :  Generic_Task_Ptr;

   My_iterator: Tasks_Dependencies_Iterator;
   Dep_Ptr: Dependency_Ptr;
   My_dependencies1: Tasks_Dependencies_Ptr;
   security      : Integer;

   procedure Usage is
   begin
      Put_Line("read_sys reads and displays to the screen a Cheddar architecture model .");

      New_Line;
      Put_Line("Check Cheddar home page for details :  http://beru.univ-brest.fr/~singhoff/cheddar ");
      New_Line;
      New_Line;
      Put_Line ("Usage : read_sys [switch] ");
      Put_Line ("   switch can be :");
      Put_Line ("            -u get this help");
      Put_Line ("            -v verbose mode ");
      Put_Line("            -i file-name, read and print the architecture model from the XML file  file-name ");
      New_Line;
   end Usage;

begin



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
   security:=biba(sys);
   Put_Line("biba violation:"& security'Img);

 	y:=19;


   if (security > 0) then


     		 My_dependencies1 := Sys.Dependencies;
                 reset_iterator(My_dependencies1.Depends, My_iterator);
                 loop
         	 current_element(My_dependencies1.Depends, Dep_Ptr, My_iterator);
        	 if (Dep_Ptr.type_of_dependency=precedence_dependency)then
                 if (Dep_Ptr.precedence_source.mils_integrity_level<Dep_Ptr.precedence_sink.mils_integrity_level) then
                 if ((Dep_Ptr.precedence_source.mils_task/=Downgrader) AND (Dep_Ptr.precedence_source.mils_task/=Upgrader)AND
                       (Dep_Ptr.precedence_sink.mils_task/=Downgrader)AND (Dep_Ptr.precedence_sink.mils_task/=Upgrader)) then
                     	Put_Line(" precedence_source :" &  To_String(Dep_Ptr.precedence_source.name));
                  	Put_Line(" precedence_sink :" &  To_String(Dep_Ptr.precedence_sink.name));
                 	y:=y+1;
                  	Put_Line("y1:"& y'Img);
                   	Add_Task(My_Tasks                 => Sys.Tasks,
                                      A_Task			 	 => a_task,
                                      Name                      	 => Suppress_Space (To_Unbounded_String (""&y'img)),
                                      Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
                                      Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
                                      Task_Type               	 	 => Periodic_Type,
                                      Start_Time              		 => 0 ,
                                      Capacity                	  	 => 166,
                                      Period                   	 => 2000,
                                      Deadline                 	 => 2000,
                                      Jitter                   	 => 0,
                                      Blocking_Time            	 => 0,
                                      Priority                 	 => Integer'Value( Dep_Ptr.precedence_source.priority'Img),
                                      Criticality              	 => 3,
                                      Policy                   	 => Sched_Fifo,
                                      mils_task            => Upgrader );
                        A_task_source :=  Search_Task (Sys.Tasks, Dep_Ptr.precedence_source.name) ;
                        A_task_sink :=  Search_Task (Sys.Tasks, Suppress_Space (To_Unbounded_String (""&y'img)));
                        Add_One_Task_Dependency_precedence (My_Dependencies => Sys.dependencies,
                                      Source          => A_task_source,
                                      Sink           => A_task_sink);
                        A_task_source :=  Search_Task (Sys.Tasks, Suppress_Space (To_Unbounded_String (""&y'img))) ;
                        A_task_sink :=  Search_Task (Sys.Tasks, Dep_Ptr.precedence_sink.name);
                        Add_One_Task_Dependency_precedence (My_Dependencies => Sys.dependencies,
                                      Source          => A_task_source,
                                      Sink           => A_task_sink);
                        Delete_One_Task_Dependency_precedence(My_Dependencies1, Dep_Ptr.precedence_source, Dep_Ptr.precedence_sink);



            	 	end if;
            	end if;
            	end if;
               exit when is_last_element (My_Dependencies1.Depends, My_Iterator);
              next_element (My_Dependencies1.Depends, My_Iterator);
             end loop;

       		Put_Line ("-------Secured file------------");
                Write_To_Xml_File
                (A_System  => Sys,
                 File_Name => Suppress_Space (To_Unbounded_String ( "Bi_secure_output_Model.xmlv3")));
                Put_Line ("Finish write");






	end if;


   end verify_biba;
