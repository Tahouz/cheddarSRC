
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

with Systems;                               use Systems;
with tasks;                                 use tasks;
with Task_Set;                              use Task_Set;
                                            use Task_Set.Generic_Task_Set;
with dependencies;                          use dependencies;
with task_dependencies;                     use task_dependencies;
                                            use task_dependencies.Half_Dep_Set;
with processors; use processors;
with Processor_Set;                         use Processor_Set;
use Processor_Set.Generic_Processor_Set;
with Parameters;                            use Parameters;
with Parameters.extended;                   use Parameters.extended;
                                            use Parameters.Framework_Parameters_Table_Package;

with framework;                             use framework;
with Call_Framework;                        use Call_Framework;
with Call_Framework_Interface;              use Call_Framework_Interface;
                                            use Call_Framework_Interface.Framework_Response_Package;
                                            use Call_Framework_Interface.Framework_Request_Package;
with Call_Scheduling_Framework;             use Call_Scheduling_Framework;
with Multiprocessor_Services;               use Multiprocessor_Services;
with Multiprocessor_Services_Interface;     use Multiprocessor_Services_Interface;
                                            use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;

with GNAT.Command_Line;
with GNAT.OS_Lib;                           use GNAT.OS_Lib;
with debug;                                 use debug;
with io_tools;                              use io_tools;
with Text_IO;                               use Text_IO;
with Version;                               use Version;
with Ada.Exceptions;                        use Ada.Exceptions;
with Ada.Numerics.Aux;                      use Ada.Numerics.Aux;
with Ada.Strings.Unbounded;                 use Ada.Strings.Unbounded;
with unbounded_strings;                     use unbounded_strings;
                                            use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Calendar;
with Ada.Calendar.Formatting;
with Ada.Text_IO; use Ada.Text_IO;

with scheduling_anomalies_services; use scheduling_anomalies_services;


procedure scheduling_anomalies is

   Sys                          : System;
   Tasks		                : Tasks_Set;
   Project_File_List            : unbounded_string_list;
   Project_File_Dir_List        : unbounded_string_list;
   Validate                     : Boolean := False;
   Verbose  : Boolean := False;
   Input_File      : Boolean := False;
   Input_File_Name : Unbounded_String;
   Processor_Name : Unbounded_String;
   Msg : Unbounded_String;
   

   procedure Usage is
   begin
      Put_Line ("scheduling_anomalies computes the feasiblity based on processor utilization bound for multiprocessor of a Cheddar architecture model .");
      New_Line;
      Put_Line ("Check Cheddar home page for details :  http://beru.univ-brest.fr/~singhoff/cheddar ");
      New_Line;
      New_Line;
      Put_Line ("Usage : scheduling_anomalies [switch] ");
      Put_Line ("   switch can be :");
      Put_Line ("            -u get this help");
      Put_Line ("            -v verbose mode ");
      Put_Line ("            -i file-name, read and print the architecture model from the XML file  file-name ");
      Put_Line ("            -p name, name is the name of the processor to apply the computation");
      New_Line;
   end Usage;

   procedure Print_Task_Set( my_tasks : Tasks_Set ) is
      a_task      : Generic_Task_Ptr;
      my_iterator : Tasks_Iterator;
   begin
      Put_Line("Name"
               & ASCII.HT & "Pi"
               & ASCII.HT & "Ci"
               & ASCII.HT & "Ti"
               & ASCII.HT & "Di"
               & ASCII.HT & "Oi"
               & ASCII.HT & "STi");

      reset_iterator(my_tasks, my_iterator);
      loop
         current_element (my_tasks, a_task, my_iterator);

         Put_Line(To_String(a_task.name)
                  & ASCII.HT & a_task.priority'Img
                  & ASCII.HT & a_task.capacity'Img
                  & ASCII.HT & Periodic_Task_Ptr(a_task).period'Img
                  & ASCII.HT & a_task.deadline'Img
                  & ASCII.HT & a_task.offsets.Entries(0).offset_value'Img
                  & ASCII.HT & a_task.start_time'Img);

         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;
      Put_Line("");
   end Print_Task_Set;

begin
   Copyright ("scheduling_anomalies");

   loop
      case GNAT.Command_Line.Getopt ("u v i:") is
         when ASCII.NUL =>
            exit;
         when 'p' =>
            Processor_Name := To_Unbounded_String (GNAT.Command_Line.Parameter);
         when 'i' =>
            Input_File      := True;
            Input_File_Name := To_Unbounded_String (GNAT.Command_Line.Parameter);
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

   if (not Input_File) then
      Usage;
      OS_Exit (0);
   end if;

   Call_Framework.initialize(False);
   Initialize (Sys);
   Systems.Read_From_Xml_File (Sys, Project_File_Dir_List, Input_File_Name);

   Tasks := Sys.Tasks;
   Print_Task_Set (Tasks);

   scheduling_anomalies_analyzer(sys,msg);
   put_line(to_string(msg));

end scheduling_anomalies;


