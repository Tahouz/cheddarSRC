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
with tasks; use tasks;
with task_dependencies; use task_dependencies;
use task_dependencies.Half_Dep_Set;
with dependencies; use dependencies;
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
with time_unit_events; use time_unit_events;
use time_unit_events.Time_Unit_Package;
with debug; use debug;
with GNAT.Command_Line;
with GNAT.OS_Lib;                       use GNAT.OS_Lib;
with Version;                           use Version;
with Ada.Exceptions;                    use Ada.Exceptions;


procedure produce_noc_message_set is

   -- A set of variables required to call the framework
   --
   Response_List         : Framework_Response_Table;
   Request_List          : Framework_Request_Table;
   A_Request             : Framework_Request;
   A_Param               : Parameter_Ptr;
   Sys                   : System;
   Project_File_List     : unbounded_string_list;
   Project_File_Dir_List : unbounded_string_list;

   -- Is the command should run in verbose mode ?
   --
   Verbose : Boolean := False;

   -- The XML file to read
   --
   Input_File      : Boolean := False;
   Input_File_Name : Unbounded_String;

   -- The file to write
   --
   Output_File      : Boolean := False;
   Output_File_Name : Unbounded_String;

   -- The duration on which we must compute the scheduling
   --
   Period_String : Unbounded_String;
   Period        : Natural;
   Ok            : Boolean;

   -- The result : the message to send
   --
   message_sequence : unbounded_string;

   -- To analyse the dependencies
   --
   sending_iterator, receiving_Iterator : Tasks_Dependencies_Iterator;
   A_sending_Dep, a_receiving_dep   : Dependency_Ptr;
   receiving_Task : Generic_Task_Ptr;


   procedure Usage is
   begin
      Put_Line(
"produce_noc_message_set is a program which computes a scheduling from an XML  Cheddar project file and save the result in a text file. The output text file only contains when each message is sent by the task of the XML Cheddar model.");

      New_Line;
      Put_Line(
"Check Cheddar home page for details :  http://beru.univ-brest.fr/~singhoff/cheddar "
);
      New_Line;
      New_Line;
      Put_Line ("Usage : produce_noc_message_set [switch] period");
      Put_Line ("   switch can be :");
      Put_Line ("            -u get this help");
      Put_Line ("            -v verbose mode ");
      Put_Line(
"            -o file-name, write the result in the file  file-name ");
      Put_Line(
"            -i file-name, read the system to analyze from the XML file  file-name "
);
      New_Line;
   end Usage;

begin

   Copyright ("produce_noc_message_set");

   -- Get arguments
   --
   loop
      case GNAT.Command_Line.Getopt ("u v i: o:") is
         when ASCII.NUL =>
            exit;

         when 'i' =>
            Input_File      := True;
            Input_File_Name :=
               To_Unbounded_String (GNAT.Command_Line.Parameter);

         when 'o' =>
            Output_File      := True;
            Output_File_Name :=
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

   loop
      declare
         S : constant String :=
           GNAT.Command_Line.Get_Argument (Do_Expansion => True);

      begin
         exit when S'Length = 0;
         Period_String := Period_String & S;
      end;
   end loop;

   -- Check the period on which we will compute the scheduling
   --
   to_natural (Period_String, Period, Ok);
   if not Ok then
      Raise_Exception
        (Constraint_Error'Identity,
         "The period to compute the scheduling must be a numeric value");
   end if;

   -- Is an input file and an output file given ???
   --
   if (not Input_File) or (not Output_File) then
      Usage;
      OS_Exit (0);
   end if;

   -- Initialize the Cheddar framework
   --
   Call_Framework.initialize (False);

   -- Read the XML project file
   --
   initialize (Project_File_List);
   Systems.Read_From_Xml_File (Sys, Project_File_Dir_List, Input_File_Name);

   -- Compute the scheduling on the period given by the argument
   --
   Initialize (Response_List);
   Initialize (Request_List);
   Initialize (A_Request);
   A_Request.statement    := Scheduling_Simulation_Time_Line;
   A_Param                := new Parameter (Integer_Parameter);
   A_Param.parameter_name := To_Unbounded_String ("period");
   A_Param.integer_value  := Period;
   Add (A_Request.param, A_Param);
   A_Param                := new Parameter (Boolean_Parameter);
   A_Param.parameter_name := To_Unbounded_String ("schedule_with_offsets");
   A_Param.boolean_value  := True;
   Add (A_Request.param, A_Param);
   A_Param                := new Parameter (Boolean_Parameter);
   A_Param.parameter_name :=
      To_Unbounded_String ("schedule_with_precedencies");
   A_Param.boolean_value  := True;
   Add (A_Request.param, A_Param);
   A_Param                := new Parameter (Boolean_Parameter);
   A_Param.parameter_name := To_Unbounded_String ("schedule_with_resources");
   A_Param.boolean_value  := True;
   Add (A_Request.param, A_Param);
   A_Param                := new Parameter (Integer_Parameter);
   A_Param.parameter_name := To_Unbounded_String ("seed_value");
   A_Param.integer_value  := 0;
   Add (A_Request.param, A_Param);
   Add (Request_List, A_Request);
   Sequential_Framework_Request (Sys, Request_List, Response_List);

   if Verbose then
      Put_Line (To_String (Response_List.Entries (0).title));
      for J in 0 .. Response_List.Nb_Entries - 1 loop
         Put_Line (To_String (Response_List.Entries (J).text));
      end loop;
   end if;


   -- Export  message sequence
   --
   message_sequence := empty_string;
      for J in 0 .. Sched.nb_entries - 1 loop
         put_debug("Processor name => " & to_string(sched.entries(j).item.name) );
         for u in 0 ..  Sched.entries (j).data.result.nb_entries -1 loop

            if Sched.entries (J).data.result.entries(u).data.type_of_event = end_of_task_capacity then
              put_debug("task " & 
                 to_string(Sched.entries (J).data.result.entries(u).data.end_task.name) &
		 " completion  time => " & 
                 Sched.entries (J).data.result.entries(u).item'img );


      if not is_empty (sys.Dependencies.Depends) then
         reset_iterator (sys.Dependencies.Depends, sending_Iterator);
         loop
            current_element (sys.Dependencies.Depends, a_sending_Dep, sending_Iterator);

            if A_sending_Dep.type_of_dependency = dependencies.asynchronous_Communication_Dependency then

		if (Sched.entries (J).data.result.entries(u).data.end_task.name = A_sending_Dep.asynchronous_communication_dependent_task.name) 
		and (A_sending_Dep.asynchronous_communication_orientation = from_task_to_object)
		then
		

		-- Look for receiving task
		--
                receiving_task:=null;
         	reset_iterator (sys.Dependencies.Depends, receiving_Iterator);
         	loop
            		current_element (sys.Dependencies.Depends, A_receiving_Dep, receiving_iterator);

            		if A_receiving_Dep.type_of_dependency = dependencies.asynchronous_Communication_Dependency then
            		    if A_receiving_Dep.asynchronous_communication_orientation = from_object_to_task then
				if A_sending_Dep.asynchronous_communication_dependency_object.name =
				   A_receiving_Dep.asynchronous_communication_dependency_object.name then
					receiving_task:=A_receiving_Dep.asynchronous_communication_dependent_task;
				end if;
			     end if;
			end if;
	
                	exit when is_last_element (sys.Dependencies.Depends, receiving_Iterator);
                	next_element (sys.Dependencies.Depends, receiving_Iterator);
         	end loop;
		

		-- Produce item in the file
		--
			if receiving_task /= null then
            			message_sequence := message_sequence & Sched.entries (J).data.result.entries(u).data.end_task.cpu_name & " " & 
					receiving_task.cpu_name & " " &
					Sched.entries (J).data.result.entries(u).item'img & " " & Sched.entries (J).data.result.entries(u).data.end_task.deadline'img & 
					" " & ASCII.CR & ASCII.LF;
			end if;
                 end if;
            end if;

            exit when is_last_element (sys.Dependencies.Depends, sending_Iterator);
            next_element (sys.Dependencies.Depends, sending_Iterator);
         end loop;
      end if;

 	end if;
         end loop;
      end loop;

   write_sequential_file (Output_File_Name, message_sequence);


end produce_noc_message_set;


