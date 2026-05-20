
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

with Ada.Strings.Unbounded;
use  Ada.Strings.Unbounded;
with Generic_Graph; use Generic_Graph;
with Tasks; use Tasks;
with Task_Set; use Task_Set;
with Task_Groups; use Task_Groups;
with Task_Group_Set; use Task_Group_Set;
with Buffers; use Buffers;
with Messages; use Messages;
with Dependencies; use Dependencies;
with Resources; use Resources;
use Resources.Resource_Accesses;
with Systems; use Systems;
with Processors;          use Processors;
with Processor_Set;       use Processor_Set;
with Address_Spaces;      use Address_Spaces;
with Address_Space_Set;   use Address_Space_Set;
with Caches;              use Caches;
with Caches;		  use Caches.Cache_Blocks_Table_Package;
with Message_Set;         use Message_Set;
with Buffer_Set; use Buffer_Set;
with Network_Set;        use Network_Set;
with Event_Analyzer_Set; use Event_Analyzer_Set;
with Resource_Set;       use Resource_Set;
with Task_Dependencies; use Task_Dependencies;
with Buffers; use Buffers;
use Buffers.Buffer_Roles_Package;
with Queueing_Systems; use Queueing_Systems;
with convert_strings;
with unbounded_strings; use unbounded_strings;
with convert_unbounded_strings;
with Text_IO; use Text_IO;
with Systems; use Systems;
with Objects; use Objects;
with Parameters.extended; use Parameters.extended;
with Scheduler_Interface; use Scheduler_Interface;
with Ada.Finalization;
with unbounded_strings; use unbounded_strings;
with architecture_factory; use architecture_factory;
use unbounded_strings.unbounded_string_list_package;
with Unchecked_Deallocation;
with sets;
with Framework_Config; use Framework_Config;
with Ada.Float_Text_IO;
with Offsets; 		use Offsets;
with Offsets; 		use Offsets.Offsets_Table_Package;
with Random_Tools; 	use Random_Tools;
with initialize_framework; use initialize_framework;
with Random_Tools; use Random_Tools;
with Ada.Numerics.Float_Random; 
with Core_Units ; use Core_Units ; 
with Networks ; use Networks ; 
use networks.Positions_Table_Package;
with Ada.Numerics.Float_Random ; use Ada.Numerics.Float_Random ;
with noc_analysis;    use noc_analysis; 
with noc_analysis.delays ; use noc_analysis.delays ; 


package noc_flow_transformation is

  ---------------------
  --    Constants    --
  ---------------------
      X_max            	: constant integer := 2;  --3 ; 
      Y_max 		: constant integer := 2;  --3 ;

      N_tasks 		: constant integer := 4  ;  

      One_Link_delay    : constant integer := 10 ;  -- delay of communication over one link   used in SAF NoC 
  
  ---------------------
  --      Types      --
  ---------------------
  
   
  
  ----------------------
  -- Global variables --
  ----------------------
       a_system,Sys    	: System;
       a_core		: Core_Unit_Ptr;
       a_cpu_name 	: Unbounded_String ; 
       a_address_Space  : Unbounded_String ;
       U_values		: Random_Tools.Float_Array (0 .. N_tasks-1);
       T_values		: Random_Tools.Integer_Array (1 .. N_tasks);
       A_capacity 	: natural := 0;
       A_period 	: natural := 0;
       a_task 		: Generic_Task_Ptr;
  

  -----------------------------
  -- subprograms --
  -----------------------------



-------------------------------------------------------
------------------------------------------------------- 
--- Convert the flow model to a task model       ------
--- for SAF NoC Router (1 flow / link ==> 1 task ------
---   ------	--------	--------	------- 
--- a) 1 link ==> 1 processor                        --   
--- b) 1 flow/link ==> 1 task  (1 flow ==> task set) --   
--- c) delate dependency and add new dependency   -----   
--- d) delate NoC                                 -----   
-------------------------------------------------------
-------------------------------------------------------

	----------------------------------------------
	----------------------------------------------
	--- generate file.XML for the new ------------
	--- task/processor Model (multipro Model) ---- 
	----------------------------------------------
	----------------------------------------------


procedure flow_to_task_SAF  (  My_processors	    	    : in out Processors_set;
			       My_tasks			    : in out Tasks_set     ;
			       My_messages	            : in out Messages_Set  ; 
			       My_Dependencies              : in out Tasks_Dependencies_Ptr ; 
			       A_link_mat                   : in links_mat     ;
			       Destination_tasks            : in Tasks_set     ;   
	 		       Source_tasks	            : in Tasks_set     ;
			       My_Address_Spaces            : in Address_Spaces_set; 
			       My_core_units		    : in core_units_Set 	 
			); 



-------------------------------------------------------
------------------------------------------------------- 
--- Convert the flow model to a task model       ------
--- for SAF/Wormhole NoC Router  		-------
--- (1 flow ==> 1 task  + 1 processor + adresse space--
---   ------	--------	--------	------- 
---  delate dependency and add new dependency   -------   
---  delate NoC                                 -------   
-------------------------------------------------------


	----------------------------------------------
	----------------------------------------------
	--- generate file.XML for the new ------------
	--- task/processor Model (multipro Model) ---- 
	----------------------------------------------
	----------------------------------------------
   
procedure flow_to_task_WCCT_SAF  (      My_processors	            : in out Processors_set;
			       My_tasks			    : in out Tasks_set     ;
			       My_messages	            : in out Messages_Set  ; 
			       My_Dependencies              : in out Tasks_Dependencies_Ptr ; 
			       A_link_mat                   : in links_mat     ;
			       Destination_tasks            : in Tasks_set     ;   
	 		       Source_tasks	            : in Tasks_set     ;
			       My_Address_Spaces            : in Address_Spaces_set; 
			       My_core_units		    : in core_units_Set; 
			       packet_size 	            : in integer ; 
			       One_Link_transmission_time   : in integer  	 
			);
	
-------------------------------------------------------
------------------------------------------------------- 
--- Convert the flow model to a task model      -------
--- for SAF/Wormhole NoC Router  		-------
--- (1 flow/link ==> a task_set  		-------
---                where nbr = packet_size = nbr flit--        
---   ------	--------	--------	------- 
--- a) 1 link ==> 1 processor                        --   
--- b) 1 flow/link ==> a taskset  		     --   
--- c) delate dependency and add new dependency   -----   
--- d) delate NoC                                 -----   
-------------------------------------------------------


	----------------------------------------------
	----------------------------------------------
	--- generate file.XML for the new ------------
	--- task/processor Model (multipro Model) ---- 
	----------------------------------------------
	----------------------------------------------

procedure flow_to_task_Wormhole  ( My_processors	            : in out Processors_set;
			       My_tasks			    : in out Tasks_set     ;
			       My_messages	            : in out Messages_Set  ; 
			       My_Dependencies              : in out Tasks_Dependencies_Ptr ; 
			       A_link_mat                   : in links_mat     ;
			       Destination_tasks            : in Tasks_set     ;   
	 		       Source_tasks	            : in Tasks_set     ;
			       My_Address_Spaces            : in Address_Spaces_set; 
			       My_core_units		    : in core_units_Set ;  	 
			       Packet_size 		    : in integer 	
			
			);
	
procedure flow_to_task_WCCT_Wormhole  (      My_processors	            : in out Processors_set;
			       My_tasks			    : in out Tasks_set     ;
			       My_messages	            : in out Messages_Set  ; 
			       My_Dependencies              : in out Tasks_Dependencies_Ptr ; 
			       A_link_mat                   : in links_mat     ;
			       Destination_tasks            : in Tasks_set     ;   
	 		       Source_tasks	            : in Tasks_set     ;
			       My_Address_Spaces            : in Address_Spaces_set; 
			       My_core_units		    : in core_units_Set; 
			       packet_size 	            : in integer ; 
			       One_Link_transmission_time   : in integer  	 
			);


end noc_flow_transformation;



