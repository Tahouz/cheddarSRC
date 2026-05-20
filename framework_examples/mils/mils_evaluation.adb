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
with Ada.Command_Line;                  use Ada.Command_Line;


with Time_Unit_Events;                  use Time_Unit_Events;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Directories; 			use Ada.Directories;
with Scheduler;				use Scheduler;

with result_parser; use result_parser;
with mils_security; use mils_security;
with mils_analysis; use mils_analysis;
with Framework_Config; use Framework_Config;

procedure mils_evaluation is
   Sys                   : System;
   command         : unbounded_String;
   Result:   Unbounded_String;
   num_echeance	    : integer:=0;

   start,finish          : integer;
   str            : unbounded_string;
   str1            : unbounded_string;



   sched_period          : unbounded_string;
   Period                : Natural;
   Ok            : Boolean;

   Processor_name         : unbounded_string;


   security      : Integer;
   security1      : Integer;


   -- A set of variables required to call the framework
   --
   Response_List   		 : Framework_Response_Table;
   Request_List    		 : Framework_Request_Table;
   A_Param             	 	 : Parameter_Ptr;
   A_Request      	 	 : Framework_Request;



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

    procedure Usage is
    begin
      Put_Line("mils_evaluation run  both scheduling analysis and security analysis of a MILS Cheddar ADL model.");

      New_Line;
      Put_Line("Check Cheddar home page for details :  http://beru.univ-brest.fr/~singhoff/cheddar");
      New_Line;
      New_Line;
      Put_Line ("Usage : mils_evaluation [switch] ");
      Put_Line ("   switch can be :");
      Put_Line ("            -u get this help");
      Put_Line ("            -v verbose mode ");
      Put_Line(
"            -i file-name, read and print the architecture model from the XML file  file-name "
);
      New_Line;
   end Usage;



begin

   --Copyright ("mils_evaluation");

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

   loop
      declare
         S : constant String :=
           GNAT.Command_Line.Get_Argument (Do_Expansion => True);
         M : constant String :=
          GNAT.Command_Line.Get_Argument (Do_Expansion => True);

      begin
         Put_Line("S'Length" & S'Length'img);
         Put_Line("M'Length" & M'Length'img);
         exit when ((S'Length = 0) OR (M'Length = 0));
         sched_period := sched_period & S;
         Processor_name := Processor_name & M;
      end;
   end loop;


    -- Check the period on which we will compute the scheduling
   --
   to_natural (sched_period, Period, Ok);
   if not Ok then
      Raise_Exception
        (Constraint_Error'Identity,
         "The period to compute the scheduling must be a numeric value");
   end if;

   -- Is an input file given ???
   --
   if (not Input_File) then
      Usage;
      OS_Exit (0);
   end if;

   -- Initialize the Cheddar framework
   --

   Call_Framework.initialize (False);

   Cheddar_Debug := No_Debug;

   initialize(Sys);
   Systems.Read_From_Xml_File (Sys, Project_File_Dir_List, Input_File_Name);


   initialize (Response_List);
   initialize (Request_List);
   Initialize (A_Request);
   A_Request.statement   := Scheduling_Simulation_Time_Line;
   A_Param               := new Parameter (Integer_Parameter);
   A_Param.parameter_name          := To_Unbounded_String ("period");

   A_Param.integer_value := Period;
   add (A_Request.param, A_Param);
   A_Param               := new Parameter (Boolean_Parameter);
   A_Param.parameter_name          := To_Unbounded_String ("schedule_with_offsets");
   A_Param.boolean_value := True;
   add (A_Request.param, A_Param);
   A_Param               := new Parameter (Boolean_Parameter);
   A_Param.parameter_name          :=
      To_Unbounded_String ("schedule_with_precedencies");
   A_Param.boolean_value := False;
   add (A_Request.param, A_Param);
   A_Param               := new Parameter (Boolean_Parameter);
   A_Param.parameter_name          := To_Unbounded_String ("schedule_with_resources");
   A_Param.boolean_value := True;
   add (A_Request.param, A_Param);
   A_Param               := new Parameter (Integer_Parameter);
   A_Param.parameter_name          := To_Unbounded_String ("seed_value");
   A_Param.integer_value := 0;
   add (A_Request.param, A_Param);
   add (Request_List, A_Request);
   Sequential_Framework_Request (Sys, Request_List, Response_List);

   initialize (Request_List);
   initialize (Response_List);
   Initialize (A_Request);
   A_Request.statement := Scheduling_Simulation_Basics;
   add (Request_List, A_Request);
   Sequential_Framework_Request (Sys, Request_List, Response_List);
   Sequential_Framework_Request (Sys, Request_List, Response_List);


   -- Extracting the decision about the schedulability
   -- From the simulation
   parse_task_context_switch(sys, Processor_name, Response_List.entries (1).text, Result);
   parse_task_preemption(sys, Processor_name, Response_List.entries (1).text, Result);
   parse_task_response_time( sys, Processor_name, Response_List.entries (1).text, num_echeance, Result);
   security := bell_lapadula (sys);
   Append (Result, "<bell_lapadulla>"& security'img & "<\bell_lapadulla>" & ASCII.LF);
   security1 := biba(sys);
   Append (Result, "<biba>"& security1'img & "<\biba>" & ASCII.LF);
   str :=Input_File_Name;
   str1:=Input_File_Name;
   start := index (str1, "-")+ length(To_Unbounded_String("-"));
   finish := index (str1, ".xmlv3")-1;
   str1 := Unbounded_Slice(str1,start,finish);
   start := index (str1, "-")+ length(To_Unbounded_String("-"));
   str1 := Unbounded_Slice(str1,start,length(str1));
   start := index (str1, "-")+ length(To_Unbounded_String("-"));
   str1 := Unbounded_Slice(str1,start,length(str1));


--   Append (Result, To_String(Unbounded_Slice(str1,1,length(str1)))&"      "&  num_echeance'img &"      "& security'img & "      "& security1'img&"      "& To_String(Input_File_Name) & ASCII.LF);
   Append (Result, num_echeance'img &"      "& security'img & "      "& security1'img&"      "& To_String(Input_File_Name) & ASCII.LF);


    Put_Line (To_String(Result));
end mils_evaluation;
