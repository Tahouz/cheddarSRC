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
with Network_Set ; use Network_Set ; 
with Networks; use Networks ; 
with Indexed_Tables;
with framework_config ; 
use framework_config ; 
  
package noc_analysis is

  ---------------------
  --    Constants    --
  ---------------------

  max_noc_links_per_message 	: constant integer := 6 ;  -- max_dim is the maximum number of possible links used by one packet 


  one_hope_delay 		: constant integer := 8 ;  --one_hope_delay presents the transmission delay of the packet for one hope ( between two routers) (cycle)  
  
  ---------------------
  --      Types      --
  ---------------------


  
   type processor_rank       is new integer range 0..16 ;

   Type processor_ranks      is array (1 .. Max_Messages ) of processor_rank ;   
  
   type noc_links is 
	record 
		source      : processor_rank ;
		destination : processor_rank ; 
	end record ;


-- A renommer egalement
   Type links_tab	 is array(1.. max_noc_links_per_message) of noc_links ;

   type links_mat 	 is array (1..Max_Messages) of links_tab ;

   Type tab_Position 	 is array (1 .. Max_Messages ) of Position ;

     
   Type Integer_Table    is array (1 .. Max_Messages ) of integer ; 

  ----------------------
  -- Global variables --
  ----------------------
 
 
  link_table_size         :  processor_ranks  ; --(a supp)
  

  -----------------------------
  -- subprograms --
  -----------------------------
 

 	-----------------------
	--compute_source_destination_task--
	-----------------------

	-- generate destination tasks set and source task set from sys.tasks and sys.dependencies--
	-- source task set and destination task set help us to define the nodeS and nodeD which are parameters of our flow model -------------- 
  	-- nodeS and nodeD are the nodes running the source task and the destination task; those two parameters helps us to compute used physical links --- 

 procedure compute_source_destination_task ( My_tasks		        : in Tasks_set; 
				             My_Messages  	        : in Messages_Set;
				             My_dep	        	: in Tasks_Dependencies_Ptr ;
			              	     Destination_tasks     	: in out Tasks_set;   
               				     Source_tasks	        : in out Tasks_set 
				            ) ;



	----------------------------------
	----display_source_destination_task
	----------------------------------

 procedure display_source_destination_task ( My_Messages  	         : in Messages_Set ;
		                          Destination_tasks     	 : in Tasks_set    ;   
	 		                  Source_tasks	        	 : in Tasks_set ;
					  SourceTask_position_Table      		    :  in tab_Position ; 
					  DestinationTask_position_Table            	    :  in tab_Position   ) ; 



        ----------------------------------------------
	---compute_source_destination_task_position---
	----------------------------------------------

	--select position of each souce and destination task in order to compute the used links for each flow---  
        --which the destination and source task positions are parameters of our flow model----------------------

 procedure compute_source_destination_task_position (SourceTask_position_Table      		    :  in out tab_Position ; 
					             DestinationTask_position_Table            	    :  in out tab_Position ; 
						     SourceTask_rank_table				    	 :  in out processor_ranks   ;
						     DestinationTask_rank_table				   	 :  in out processor_ranks   ;	
						     Source_tasks               : in out Tasks_set;   
                                                     Destination_tasks          : in out Tasks_set; 
                                                     My_messages                : in Messages_Set;
                                                     My_noc			: in Networks_Set ) ;



	-------------------------
	---procedure gen_links---
	-------------------------
	
	--generate used links for each message
	
 procedure generate_links          (A_link_mat               : in out links_mat;
				    My_messages	             : in Messages_Set; 			        
 				    SourceTask_position_Table      		    :  in tab_Position ; 
			            DestinationTask_position_Table            	    :  in tab_Position  ;
				    SourceTask_rank_table :  in  processor_ranks   
          			     ) ;  



 procedure display_used_links      (My_messages	            : in Messages_Set; 
			     	    A_link_mat              : in links_mat 
                 )  ; 




end noc_analysis; 
