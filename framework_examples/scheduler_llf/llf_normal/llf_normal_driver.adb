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
--    $Rev: 3475 $
--    $Date: 2020-07-13 10:35:38 +0200 (lun., 13 juil. 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Text_IO;                   use Ada.Text_IO;
with Cache_Access_Profile_Util;	    use Cache_Access_Profile_Util;
with Systems;                       use Systems;
with scheduling_simulation_util;    use scheduling_simulation_util;
with Ada.Strings.Unbounded;         use Ada.Strings.Unbounded;
with Parameters;                    use Parameters;
with Parameters.extended;           use Parameters.extended;
                                    use Parameters.Framework_Parameters_Table_Package;
with Framework_Config;              use Framework_Config;
with Call_Framework_Interface;      use Call_Framework_Interface;
                                    use Call_Framework_Interface.Framework_Response_Package;
                                    use Call_Framework_Interface.Framework_Request_Package;
with unbounded_strings;             use unbounded_strings;
                                    use unbounded_strings.strings_table_package;
                                    use unbounded_strings.unbounded_string_list_package;
with call_framework;                use call_framework;
with Systems;                       use Systems;
with Framework;                     use Framework;
with Tables;
with Multiprocessor_Services;       use Multiprocessor_Services;

procedure llf_normal_driver
is    
    -- A set of variable to configure the simulation
    --
    Period 		: Natural := 70;
    Sys 		: System;
    Input_File_Name     : Unbounded_String := To_Unbounded_String("example1_univ_colorado.xmlv3");
    Output_File_Name    : Unbounded_String := To_Unbounded_String("example1_univ_colorado.xmlv3.ev.xml");
    Export_Data 	: Boolean := TRUE;
    Result 		: Natural := 0;
    
    -- A set of variables required to call the framework
    --
    Response_List         : Framework_Response_Table;
    Request_List          : Framework_Request_Table;
    A_Request             : Framework_Request;
    A_Param               : Parameter_Ptr;
    Project_File_List     : unbounded_string_list;
    Project_File_Dir_List : unbounded_string_list;

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
    A_Request.statement           := Scheduling_Simulation_Time_Line;
    A_Param                       := new Parameter (Integer_Parameter);
    A_Param.parameter_name        := To_Unbounded_String ("period");
    A_Param.integer_value         := Period;
    add (A_Request.param, A_Param);

    A_Param                       := new Parameter (Boolean_Parameter);
    A_Param.parameter_name        := To_Unbounded_String ("schedule_with_offsets");
    A_Param.boolean_value := True;
    add (A_Request.param, A_Param);

    A_Param                       := new Parameter (Boolean_Parameter);
    A_Param.parameter_name        := To_Unbounded_String ("schedule_with_crpd");
    A_Param.boolean_value         := True;
    add (A_Request.param, A_Param);

    A_Param                       := new Parameter (Boolean_Parameter);
    A_Param.parameter_name        := To_Unbounded_String ("running_task");
    A_Param.boolean_value         := True;
    add (A_Request.param, A_Param);

    A_Param                       := new Parameter (Boolean_Parameter);
    A_Param.parameter_name        := To_Unbounded_String ("schedule_with_precedencies");
    A_Param.boolean_value := False;
    add (A_Request.param, A_Param);

    A_Param                       := new Parameter (Boolean_Parameter);
    A_Param.parameter_name        := To_Unbounded_String ("schedule_with_resources");
    A_Param.boolean_value         := False;
    add (A_Request.param, A_Param);

    A_Param                       := new Parameter (Boolean_Parameter);
    A_Param.parameter_name        := To_Unbounded_String ("end_of_task_capacity");
    A_Param.boolean_value         := False;
    add (A_Request.param, A_Param);

    A_Param                       := new Parameter (Boolean_Parameter);
    A_Param.parameter_name        := To_Unbounded_String ("start_of_task_capacity");
    A_Param.boolean_value         := False;
    add (A_Request.param, A_Param);

    A_Param                       := new Parameter (Boolean_Parameter);
    A_Param.parameter_name        := To_Unbounded_String ("task_activation");
    A_Param.boolean_value         := True;
    add (A_Request.param, A_Param);

    A_Param                       := new Parameter (Boolean_Parameter);
    A_Param.parameter_name        := To_Unbounded_String ("preemption");
    A_Param.boolean_value         := True;
    add (A_Request.param, A_Param);

    A_Param                       := new Parameter (Integer_Parameter);
    A_Param.parameter_name        := To_Unbounded_String ("seed_value");
    A_Param.integer_value         := 0;
    add (A_Request.param, A_Param);
    add (Request_List, A_Request);
    
    Initialize (Sys);
    Systems.Read_From_Xml_File (Sys,
                                Project_File_Dir_List,
                                Input_File_Name);
    

    Put_Line("START: SCHED SIMULATION");

    Sequential_Framework_Request (Sys, Request_List, Response_List);

    Put(Response_List);

    Put_Line("END: SCHED SIMULATION");

    if(flag)then
        Result := 1;
        --Put_Line("RESULT = 1");
    else
        Result := 0;
        --Put_Line("RESULT = 0");
    end if;

    if(Export_Data) then
        Write_To_Xml_File (framework.Sched, Sys, Output_File_Name);
    end if;                
end llf_normal_driver;
