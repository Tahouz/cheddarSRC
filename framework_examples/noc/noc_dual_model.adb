
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
with noc_analysis; use noc_analysis; 
with noc_analysis.delays;	use noc_analysis.delays; 
with Network_Set; use Network_Set ; 
with Networks; use Networks; 


procedure noc_dual_model is

        dir1         			 	 : unbounded_string_list;	
	Sys          				 : system;	 
	Destination_tasks 		  	 : Tasks_set;   
	Source_tasks				 : Tasks_set;           		
	A_link_mat  				 : links_mat ; 
        Path_delay				 : Integer_Table   ; 
        shared_links 			   	 : Integer_Table  ;
	communication_time			 : Integer_Table  ; 
	SourceTask_position_Table                :  tab_Position ; 
        DestinationTask_position_Table           :  tab_Position ; 
        SourceTask_rank_table         	         :  processor_ranks   ;
        DestinationTask_rank_table               :  processor_ranks   ;


Begin 

	Call_Framework.initialize (False);

	initialize(Sys);
        Read_From_Xml_File (Sys, dir1, "framework_examples/noc/generated_system.xmlv3" );
        
	------------***********--------------
	---Section1: Compute the Flow Model from the task model, task mapping and the NoC model
	------------***********----------


	-------------------
	--generate messages's parameters : Source task position and destination task position : positions of Nodes running the source and destination task for each flow
	-------------------

        compute_source_destination_task ( My_tasks     		=>  Sys.Tasks,
	  		       My_Messages  	        => Sys.messages,
		               My_dep	    	        => Sys.dependencies, 
			       Destination_tasks        => Destination_tasks,   
	 		       Source_tasks	        => Source_tasks) ;  
      

	compute_source_destination_task_position       ( SourceTask_position_Table 		 => SourceTask_position_Table ,
							 DestinationTask_position_Table		 =>  DestinationTask_position_Table, 
							 SourceTask_rank_table			 => SourceTask_rank_table ,
							 DestinationTask_rank_table		 => DestinationTask_rank_table ,
							 Source_tasks           		 => Source_tasks ,   
                                                         Destination_tasks     		         => Destination_tasks,  
                                                         My_messages            		 => Sys.messages,
                                                         My_noc					 => Sys.networks) ;


	display_source_destination_task ( My_Messages  	        => Sys.messages,
		                          Destination_tasks     => Destination_tasks,   
	 		                  Source_tasks	        => Source_tasks,
					  SourceTask_position_Table 		=> SourceTask_position_Table ,
				     	  DestinationTask_position_Table 	=>  DestinationTask_position_Table ) ;  

	------------------
	--- generate and display used links for each message : the function F of the flow model 
	------------------

	generate_links  	  (  A_link_mat           	         => A_link_mat,
				     My_messages	     		 => Sys.messages,
			             SourceTask_position_Table 		 => SourceTask_position_Table ,
				     DestinationTask_position_Table 	 =>  DestinationTask_position_Table ,
				     SourceTask_rank_table    		 => SourceTask_rank_table
            			) ;  

	
	display_used_links      (My_messages	            => Sys.messages,
			     	    A_link_mat               => A_link_mat
            			) ; 






	-----------***********-----
	---Section2: Compute latency produced by the Network On Chip 
	-----------***********-----

 
	-----------
	--- calculate Path delay for each message 
	-----------
    
   	Compute_Path_delay (packet_size 	=> 5, 
                            injection_time   	=> 70,      
			    Path_delay		=> Path_delay) ;

	----------------------------------------
	--- Direct_Interference
	----------------------------------------

	compute_Direct_Interference     	   (A_link_mat        => A_link_mat ,
						    shared_links      => shared_links  
                           ) ;

   
	-------------------------------------
	---- Indirecte Interference 
	-------------------------------------

        Check_Indirect_Interference ( A_link_mat  	=>  A_link_mat   ,
				      shared_links      => shared_links      
                                          ); 
	----------------------------------------
	--- Communication Time 
	----------------------------------------
  
        Compute_Communication_Time ( My_messages	        => Sys.messages,   
                                     Path_delay                 => Path_delay, 
				     shared_links    		=> shared_links , 
				     communication_time		=> communication_time   
				    ) ; 

        -----------------


end  noc_dual_model;



