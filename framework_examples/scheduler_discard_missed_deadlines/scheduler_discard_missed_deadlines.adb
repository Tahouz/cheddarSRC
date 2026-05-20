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
--    $Rev: 4110 $
--    $Date: 2021-12-13 13:05:57 +0100 (lun., 13 déc. 2021) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

--Package for call scheduling simulation framework
with Ada.Text_IO;                       use Ada.Text_IO;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with Systems;                           use Systems;
with Framework;                         use Framework;
with initialize_framework;              use initialize_framework;
with Call_Framework;                    use Call_Framework;
with Call_Framework_Interface;          use Call_Framework_Interface;
with Call_Framework_Interface;          use Call_Framework_Interface.Framework_Response_Package;
with Call_Framework_Interface;          use Call_Framework_Interface.Framework_Request_Package;
with Parameters;                        use Parameters;
with unbounded_strings;                 use unbounded_strings;
with unbounded_strings;                 use unbounded_strings.strings_table_package;
with unbounded_strings;                 use unbounded_strings.unbounded_string_list_package;
with Parameters;                        use Parameters;
with Parameters;                        use Parameters.Framework_Parameters_Table_Package;
with Multiprocessor_Services;           use Multiprocessor_Services;
--

procedure scheduler_discard_missed_deadlines
is        
    -- A set of variables required to call the framework
    --
    Sys                     : System;    
    Response_List           : Framework_Response_Table;
    Request_List            : Framework_Request_Table;
    A_Request               : Framework_Request;
    A_Param                 : Parameter_Ptr;
    Project_File_List       : unbounded_string_list;
    Project_File_Dir_List   : unbounded_string_list;
    
    -- Config input, output, simulation period
    --
    Input_File_Name         : Unbounded_String := To_Unbounded_String("xml/input_test1.xmlv3");
    Output_Sys_File_Name    : Unbounded_String := To_Unbounded_String("xml/output_test1_sys.xmlv3");
    Output_EV_File_Name     : Unbounded_String := To_Unbounded_String("xml/output_test1_ev.xmlv3");
    Period                  : Natural := 40;
        
begin
    Put_Line("--Test scheduling simulation with discard missed deadlines");  

    Set_Initialize;
    Initialize (sys);

    sys.Read_From_Xml_File(Dir_List  => Project_File_Dir_List,
                           File_Name => Input_File_Name);
    
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
    A_Param.parameter_name      := To_Unbounded_String ("period");
    A_Param.integer_value       := Period;
    add (A_Request.param, A_Param);

    A_Param               		:= new Parameter (Boolean_Parameter);
    A_Param.parameter_name      := To_Unbounded_String ("schedule_with_precedencies");
    A_Param.boolean_value       := True;
    add (A_Request.param, A_Param);

    A_Param               		:= new Parameter (Boolean_Parameter);
    A_Param.parameter_name      := To_Unbounded_String ("schedule_with_offsets");
    A_Param.boolean_value       := True;
    add (A_Request.param, A_Param);

    A_Param               		:= new Parameter (Boolean_Parameter);
    A_Param.parameter_name      := To_Unbounded_String ("schedule_with_crpd");
    A_Param.boolean_value       := False;
    add (A_Request.param, A_Param);

    A_Param               		:= new Parameter (Boolean_Parameter);
    A_Param.parameter_name      := To_Unbounded_String ("schedule_with_resources");
    A_Param.boolean_value       := True;
    add (A_Request.param, A_Param);

    A_Param               		:= new Parameter (Boolean_Parameter);
    A_Param.parameter_name      := To_Unbounded_String ("end_of_task_capacity");
    A_Param.boolean_value := True;
    add (A_Request.param, A_Param);

    A_Param               		:= new Parameter (Boolean_Parameter);
    A_Param.parameter_name      := To_Unbounded_String ("start_of_task_capacity");
    A_Param.boolean_value       := True;
    add (A_Request.param, A_Param);

    A_Param               		:= new Parameter (Boolean_Parameter);
    A_Param.parameter_name      := To_Unbounded_String ("running_task");
    A_Param.boolean_value       := False;
    add (A_Request.param, A_Param);

    A_Param               		:= new Parameter (Boolean_Parameter);
    A_Param.parameter_name      := To_Unbounded_String ("task_activation");
    A_Param.boolean_value       := True;
    add (A_Request.param, A_Param);
        
    A_Param               		:= new Parameter (Boolean_Parameter);
    A_Param.parameter_name      := To_Unbounded_String ("anomaly_detection");
    A_Param.boolean_value       := False;
    add (A_Request.param, A_Param);
        
    a_param                     := new parameter (boolean_parameter);
    a_param.parameter_name      := To_Unbounded_String ("dvfs");
    a_param.boolean_value       := False;
    add (a_request.param, a_param);
    
    add (Request_List, A_Request);
    
    Sequential_Framework_Request (Sys, Request_List, Response_List);
    
    Put_Line("--Export system");
    Systems.Write_To_Xml_File(A_System  => Sys,
                              File_Name => Output_Sys_File_Name);
    Put_Line("--Export event table");            
    Write_To_Xml_File (framework.Sched, Sys, Output_EV_File_Name);


    
end scheduler_discard_missed_deadlines;
