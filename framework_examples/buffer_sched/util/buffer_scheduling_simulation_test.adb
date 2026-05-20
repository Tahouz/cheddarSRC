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
with Ada.Text_IO, Ada.Integer_Text_IO;	use Ada.Text_IO, Ada.Integer_Text_IO;
with Ada.Float_Text_IO;			use Ada.Float_Text_IO;
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

package body buffer_scheduling_simulation_test is

    function scheduling_simulation_with_buffer
      (Period 		: in Natural;
       Sys 		: in out System;
       Output_File_Name 	: in Unbounded_String;
       Export_Data 	: in Boolean := FALSE)
      return Scheduling_Table_Ptr
    is
        -- A set of variables required to call the framework
        --
        Response_List         : Framework_Response_Table;
        Request_List          : Framework_Request_Table;
        A_Request             : Framework_Request;
        A_Param               : Parameter_Ptr;
        Project_File_List     : unbounded_string_list;
        Project_File_Dir_List : unbounded_string_list;

        Input_File_Name : Unbounded_String;
        -- The duration on which we must compute the scheduling
        --

        flag : Boolean := True;
        F: Ada.Text_IO.File_Type;
        Data: Unbounded_String;
    begin
        -- Initialize the Cheddar framework
        --
        Call_Framework.initialize (False);
        -- Read the XML project file
        --
        initialize (Project_File_List);
        -- Compute the scheduling on the period given by the argument
        --
        initialize (Response_List);
        initialize (Request_List);
        Initialize (A_Request);
        A_Request.statement   		:= Scheduling_Simulation_Time_Line;
        A_Param               		:= new Parameter (Integer_Parameter);
        A_Param.parameter_name          := To_Unbounded_String ("period");
        A_Param.integer_value := Period;
        add (A_Request.param, A_Param);

        A_Param               		:= new Parameter (Boolean_Parameter);
        A_Param.parameter_name          := To_Unbounded_String ("schedule_with_precedencies");
        A_Param.boolean_value := True;
        add (A_Request.param, A_Param);

        A_Param               		:= new Parameter (Boolean_Parameter);
        A_Param.parameter_name          := To_Unbounded_String ("schedule_with_offsets");
        A_Param.boolean_value := True;
        add (A_Request.param, A_Param);

        A_Param               		:= new Parameter (Boolean_Parameter);
        A_Param.parameter_name          := To_Unbounded_String ("schedule_with_crpd");
        A_Param.boolean_value := False;
        add (A_Request.param, A_Param);

        A_Param               		:= new Parameter (Boolean_Parameter);
        A_Param.parameter_name          := To_Unbounded_String ("schedule_with_resources");
        A_Param.boolean_value := True;
        add (A_Request.param, A_Param);

        A_Param               		:= new Parameter (Boolean_Parameter);
        A_Param.parameter_name          := To_Unbounded_String ("end_of_task_capacity");
        A_Param.boolean_value := True;
        add (A_Request.param, A_Param);

        A_Param               		:= new Parameter (Boolean_Parameter);
        A_Param.parameter_name          := To_Unbounded_String ("start_of_task_capacity");
        A_Param.boolean_value := True;
        add (A_Request.param, A_Param);

        A_Param               		:= new Parameter (Boolean_Parameter);
        A_Param.parameter_name          := To_Unbounded_String ("running_task");
        A_Param.boolean_value := False;
        add (A_Request.param, A_Param);

        A_Param               		:= new Parameter (Boolean_Parameter);
        A_Param.parameter_name          := To_Unbounded_String ("task_activation");
        A_Param.boolean_value := True;
        add (A_Request.param, A_Param);

        A_Param               		:= new Parameter (Boolean_Parameter);
        A_Param.parameter_name          := To_Unbounded_String ("preemption");
        A_Param.boolean_value := True;
        add (A_Request.param, A_Param);

        A_Param               		:= new Parameter (Boolean_Parameter);
        A_Param.parameter_name          := To_Unbounded_String ("buffer_underflow");
        A_Param.boolean_value := True;
        add (A_Request.param, A_Param);

        A_Param               		:= new Parameter (Boolean_Parameter);
        A_Param.parameter_name          := To_Unbounded_String ("buffer_overflow");
        A_Param.boolean_value := True;
        add (A_Request.param, A_Param);

        A_Param               		:= new Parameter (Boolean_Parameter);
        A_Param.parameter_name          := To_Unbounded_String ("buffer_overflow");
        A_Param.boolean_value := True;
        add (A_Request.param, A_Param);
        
        A_Param               		:= new Parameter (Boolean_Parameter);
        A_Param.parameter_name          := To_Unbounded_String ("anomaly_detection");
        A_Param.boolean_value := False;
        add (A_Request.param, A_Param);
        
        a_param                := new parameter (boolean_parameter);
        a_param.parameter_name := To_Unbounded_String ("dvfs");
        a_param.boolean_value  := False;
        add (a_request.param, a_param);

        add (Request_List, A_Request);

        Sequential_Framework_Request (Sys, Request_List, Response_List);

        if(Export_Data) then
            Put_Line("Export system");
            Systems.Write_To_Xml_File(A_System  => Sys,
                                      File_Name => "system_cheddar_adl_output.xml");
            Put_Line("Export event table");            
            Write_To_Xml_File (framework.Sched, Sys, Output_File_Name);
        end if;

        return framework.Sched;

    end scheduling_simulation_with_buffer;

end  buffer_scheduling_simulation_test;
