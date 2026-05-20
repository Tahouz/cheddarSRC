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
--    $Rev:  $
--    $Date:  $
--    $Author:  $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Text_IO;                       use Ada.Text_IO;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with Systems;                           use Systems;
with Initialize_Framework;              use Initialize_Framework;
with Call_Cache_Framework;              use Call_Cache_Framework;
with Cache_Access_Profile_Set;          use Cache_Access_Profile_Set;
with Unbounded_Strings;                 use Unbounded_strings;
with Unbounded_Strings;                 use Unbounded_Strings.Strings_Table_Package;
with Unbounded_Strings;                 use Unbounded_Strings.Unbounded_String_List_Package;
with Call_Framework;                    use Call_Framework;
with Call_Framework_Interface;          use Call_Framework_Interface;
with Call_Scheduling_Framework;         use Call_Scheduling_Framework;                    
with Scheduling_Errors;                 use Scheduling_Errors;
with Scheduling_Error_Set;              use Scheduling_Error_Set;
with Sets;

procedure scheduling_error_example_driver
is
    Sys                          : System;
    Project_File_List            : unbounded_string_list;
    Project_File_Dir_List        : unbounded_string_list;
    result                       : Unbounded_String;

    se_r                         : Scheduling_Error_Record;    
begin
    -- Initialize the Cheddar framework
    --
    Call_Framework.initialize (False);

    -- Read the XML project file
    --

    initialize (Project_File_List);

    Systems.Read_From_Xml_File (Sys,
                                Project_File_Dir_List,
                                "input.xml");

    se_r.error_type := Early_Service_Start;
    se_r.time := 10;
    se_r.error_action := Stop_Schedule;
    se_r.user_defined_action := Unbounded_Strings.empty_string;
    
    Add_Scheduling_Error(My_Scheduling_Errors      => Sys.Scheduling_Errors,
                         Name                      => To_Unbounded_String("se02"),
                         A_Scheduling_Error_Record => se_r);
        
    Systems.Write_To_Xml_File(A_System  => Sys,
                              File_Name => "output.xml");
    Put_line("=============================================");
    Put_line("Finish write the system model with a scheduling error to output.xml");
    Put_line("");

end scheduling_error_example_driver;
