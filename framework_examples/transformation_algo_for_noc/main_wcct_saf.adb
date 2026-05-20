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
--    $Date  : 17/10/2018   $
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
with noc_analysis; use noc_analysis; 
with conv_flow_task; use conv_flow_task ; 
with scheduling_simulation_test_hlfet; use scheduling_simulation_test_hlfet; 
with Parameters;                        use Parameters;
with Parameters.extended;               use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;

procedure main_wcct_saf is

        dir1         			 	 : unbounded_string_list;	
	Sys, Sys1      				 : system;	 
	Response_List   			 : Framework_Response_Table;
	
	


	-------------------------------------
	
	Destination_tasks 		  	 : Tasks_set	      ;   
	Source_tasks				 : Tasks_set	      ;           		
	A_link_mat  				 : links_mat 	      ; 
        
        
	
	SourceTask_position_Table                : tab_Position       ; 
        DestinationTask_position_Table           : tab_Position       ; 
        SourceTask_rank_table         	         : processor_ranks    ;
        DestinationTask_rank_table               : processor_ranks    ;
	My_noc					 : Networks_Set       ; 


Begin 

	Call_Framework.initialize (False);

	initialize(Sys);

 
       	Read_From_Xml_File (Sys, dir1, "framework_examples/transformation_algo_for_noc/input_Model.xmlv3" );


	display_system 					(	System2  	=> Sys   
								) ; 
        -- afficher les tâches/ les processeurs / les messages ... du système d'entrée 

       	My_noc := Sys.networks ; 
	



	-----------------------------------------------
	-- Compute the flow Model and used links	
	-----------------------------------------------


	compute_source_destination_task 		(     My_tasks     		=> Sys.Tasks,
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


	display_source_destination_task 		( My_Messages  	        => Sys.messages,
						          Destination_tasks     => Destination_tasks,   
			 		                  Source_tasks	        => Source_tasks,
							  SourceTask_position_Table 		=> SourceTask_position_Table ,
						     	  DestinationTask_position_Table 	=>  DestinationTask_position_Table, 
							  SourceTask_rank_table			 => SourceTask_rank_table ,
							  DestinationTask_rank_table		 => DestinationTask_rank_table  ) ;  


	-------------------------------------
	--- generate and display used links for each message : the function F of the flow model 
	-------------------------------------

	generate_links  	  (  A_link_mat           	         => A_link_mat,
				     My_messages	     		 => Sys.messages,
			             SourceTask_position_Table 		 => SourceTask_position_Table ,
				     DestinationTask_position_Table 	 => DestinationTask_position_Table ,
				     SourceTask_rank_table    		 => SourceTask_rank_table
            			) ;  

	
	display_used_links      (My_messages	            => Sys.messages,
			     	    A_link_mat               => A_link_mat
            			) ; 




	-------------------------------------
	--- transforme the input model (Modèle d'architecture) into the output model (Modèle d'analyse)
	--- selon la méthode Accurate Communication time (ACT) for SAF NoC 
	-------------------------------------




	flow_to_task_WCCT_SAF (  My_processors	            => Sys.Processors,
			       My_tasks			    => Sys.Tasks,
			       My_messages	            => Sys.messages, 
			       My_Dependencies	    	    => Sys.dependencies, 
			       A_link_mat                   => A_link_mat,    
 			       Destination_tasks            => Destination_tasks,   
	 		       Source_tasks	            => Source_tasks ,
			       My_Address_Spaces            => Sys.Address_Spaces, 
			       My_core_units 		    => Sys.core_units  , 
			       packet_size 		    => 2 , 
			       One_Link_transmission_time   => 2 
	                            )  ; 
	

	-- the outputfile (Modèle d'analyse) is framework_examples/transformation_algo_for_noc/output_Model.xmlv3



        initialize(Sys1);
       	Read_From_Xml_File (Sys1, dir1, "framework_examples/transformation_algo_for_noc/output_Model.xmlv3" );

	display_system 					(	System2  	=> Sys1   
								) ; 
	-- afficher les tâches/ les processeurs / les messages ... du système de sortie 

        compute_scheduling_of_tasks(1000,Sys1,To_Unbounded_String("framework_examples/transformation_algo_for_noc/Scheduling_Result"),true);


end  main_wcct_saf;



