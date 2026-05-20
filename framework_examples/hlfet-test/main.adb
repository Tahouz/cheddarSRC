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


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- -- Contact : mourad.dridi@univ-brest.fr         
------------------------------------------------------------------------------
-- Last update 
--    $Date  : 16/05/2018   $
--    $Author: Mourad Dridi $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Integer_Text_IO;
use Ada.Integer_Text_IO;
with Ada.Command_Line;
use Ada.Command_Line;
with AADL_Config;       use AADL_Config;
with unbounded_strings; use unbounded_strings;
with Text_IO;           use Text_IO;
with Ada.Exceptions;                                    use Ada.Exceptions;
with translate; use translate;
with processor_set; use processor_set;
with text_io; use text_io;
with ada.strings.unbounded; use ada.strings.unbounded;
with unbounded_strings; use unbounded_strings;
with Dependencies ; use Dependencies; 
with Task_Dependencies; use Task_Dependencies; 
with Task_Dependencies; use Task_Dependencies.Half_Dep_Set;
with sets;
with Tasks;			use Tasks;
with Task_Set;                  use Task_Set;
with Message_Set ; use Message_Set ; 
with Messages; use Messages ; 
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
with Parameters;            use Parameters;
use Parameters.User_Defined_Parameters_Table_Package;
with Parameters.extended;   use Parameters.extended;
with Network_Set; use Network_Set ; 
with Networks; use Networks; 
with Blevel; use Blevel ; 
with Find_successors   ;    use Find_successors; 
with scheduling_simulation_test_hlfet; use scheduling_simulation_test_hlfet; 


procedure main is

        dir1         			 	 : unbounded_string_list;	
	Sys          				 : system		;		 

        blevel					 : Integer_Table	; 
        Capacity_table				 : Integer_Table	; 
        nbr_task				 : Integer     :=0     	;
        tasks_name_table 			 : String_Table         ; 

Begin 

	Call_Framework.initialize (False);

	initialize(Sys);
        Read_From_Xml_File (Sys, dir1, "framework_examples/noc/generated_system.xmlv3" );
        




	compute_blevel       ( My_tasks			    => Sys.Tasks,
			       nbr_task			    => nbr_task,
			       Capacity_table               => Capacity_table, 	
		               tasks_name_table             => tasks_name_table, 
			       blevel                       => blevel, 
			       My_messages	            => Sys.messages, 
			       My_Dependencies	    	    => Sys.dependencies 
			       ); 

        display_blevel   (  blevel   			    => blevel,
			    nbr_task			    => nbr_task 
  				) ; 

       --compute_scheduling_of_tasks  ( Period 		: in Natural,
	--			      Sys 		: in out System,
	--			      Output_File_Name 	: in Unbounded_String,
	--			      Export_Data 	: in Boolean := FALSE,
	--			      Result 		: out Natural);
    


        compute_scheduling_of_tasks(60,Sys,To_Unbounded_String("case_study_moro.xmlv3.ev.xml"),true);


end  main;



