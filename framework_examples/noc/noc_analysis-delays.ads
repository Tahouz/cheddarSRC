

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
with noc_analysis;    use noc_analysis; 
  
package noc_analysis.delays is

  ---------------------
  --    Constants    --
  ---------------------
  
  
  ---------------------
  --      Types      --
  ---------------------
  
   
  
  ----------------------
  -- Global variables --
  ----------------------
  
  

  -----------------------------
  -- subprograms --
  -----------------------------



	------------------------------
	---Path_delay-----------------
	------------------------------

	--compute the path delay for each message
	--the path delay depends on the message size (nbr_packet) and the path (used physical links)   

 procedure Compute_Path_delay (packet_size 		: in integer ;
                               injection_time  		: in integer ;        
		               Path_delay		: in out Integer_Table   ) ;


	---------------------------
	---compute_Direct_Interference -----
	---------------------------

	---calculate Direct_interference_delay 
	--1) calculate the number of shared physical link 
	--2) check if the source and/or the destination is also shared with other message 
	--3) calculate the delay.
	
 procedure compute_Direct_Interference     (   A_link_mat                : in links_mat ; 
					       shared_links 		 : in out Integer_Table 
                        		   ) ;

	---------------------------
 	---Check_Indirect_Interference
	---------------------------

	---check if there is indirect interference in the network 

 procedure Check_Indirect_Interference ( A_link_mat     	   : in  links_mat ;  
                                         shared_links              : in out Integer_Table   
					);

	-----------------------------
	---Compute_Communication_Time
	-----------------------------

	---Compute and display the worst case communication time for each flow 

 procedure Compute_Communication_Time ( My_messages		  : in Messages_Set ; 
					Path_delay  		  : in Integer_Table  ;  
                                        shared_links              : in Integer_Table  ;
					communication_time	  : in out Integer_Table   
                                          ) ; 




end noc_analysis.delays;
