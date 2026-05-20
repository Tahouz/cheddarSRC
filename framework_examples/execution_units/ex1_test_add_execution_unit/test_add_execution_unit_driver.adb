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
with Execution_Units;                   use Execution_Units;
with Execution_Unit_Set;                use Execution_Unit_Set;
with Sets;

procedure test_add_execution_unit_driver
is
    Sys                          : System;
    Project_File_List            : Unbounded_string_list;
    Project_File_Dir_List        : Unbounded_string_list;
    result                       : Unbounded_String;
    eu1_r                        : Execution_Unit_Record;
    eu2_r                        : Execution_Unit_Record;
    eu3_r                        : Execution_Unit_Record;
    k                            : Execution_Unit_Ptr;
    set1                         : Execution_Units_Set; -- - Create/Declare an execution unit set

begin
   -- Initialize the Cheddar framework
    --
    Call_Framework.initialize (False);

    -- 1. Read the system model from an XML project file
    --

    initialize (Project_File_List);

    Systems.Read_From_Xml_File (Sys,                    -- Object system, contains all entities found in input.xml
                                Project_File_Dir_List,  --
                                "input.xml");           -- Input system model
    
    
    -- 2. Code here
    -- - Create/Declare an execution unit set
   
    -- - Create/Declare an execution unit record (see example in framework_examples/scheduling_error)
    eu1_r.Unit_type := Compatible_phase;
    eu1_r.Time_Constraint_Name := Unbounded_Strings.empty_string;
    eu1_r.Capacity := 1;
    --eu1_r.Next_Execution_Unit_Name := Memory_phase;
    eu1_r.Order := 1;
  
    -- - Add the execution unit to the set
    Add_Execution_Unit(My_Execution_Units      => set1,
                       Name                    => To_Unbounded_String("ex1"),
                       A_Execution_Unit_Record => eu1_r);
    -- - Repeat and add 2-3 more execution units
    ------------ 2 eme E.U------------------------------------------------
    eu2_r.Unit_type := Memory_phase;
    eu2_r.Time_Constraint_Name := Unbounded_Strings.empty_string;
    eu2_r.Capacity := 1;
    --eu2_r.Next_Execution_Unit_Name := Execute_phase;
    eu2_r.Order := 2;
    Add_Execution_Unit(My_Execution_Units      => set1,
                       Name                    => To_Unbounded_String("ex2"),
                       A_Execution_Unit_Record => eu2_r);
    ----------- 3 eme E.U--------------------------------------------------
    eu3_r.Unit_type := Execute_phase;
    eu3_r.Time_Constraint_Name := Unbounded_Strings.empty_string;
    eu3_r.Capacity := 3;
    --eu3_r.Next_Execution_Unit_Name := Compatible_phase;
    eu3_r.Order := 3;
    Add_Execution_Unit(My_Execution_Units      => set1,
                       Name                    => To_Unbounded_String("ex3"),
                       A_Execution_Unit_Record => eu3_r);
    -- - Use loop and put_line to display all execution units added to the set
    --loop

        My_Iterator         : Iterator;
        A_Execution_Unit    : Execution_Unit_Ptr;
        if not is_empty(set1) then

        reset_iterator (set1, My_Iterator);
        loop
    
        current_element (set1, A_Execution_Unit, My_Iterator);
        Put_line("le type de l'execution unit est " & A_Execution_Unit.Unit_type'Img);
      -- A_Execution_Unit.name
        end loop;


    -- - Test the search function
    
    k := Search_Execution_Unit (set1,To_Unbounded_String("ex3"));
    Put_line("Execution unit found avec le nom ex3, capacity = : " & k.Capacity'Img & " et Order = : " & k.Order'Img);

    -- 3. Export the new system model to an xml file
    --
    Systems.Write_To_Xml_File(A_System  => Sys,
                              File_Name => "output.xml");
    Put_line("=============================================");
    Put_line("Finish write the system model with a scheduling error to output.xml");
    Put_line("");


end test_add_execution_unit_driver;
