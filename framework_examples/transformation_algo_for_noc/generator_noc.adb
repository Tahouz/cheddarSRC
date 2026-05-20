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
-- Last update : 
--    $Date: 2018-10-10 12:00:00$
--    $Author: Dridi $
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




package body generator_noc is


     procedure generate_noc  (  Nbr_task_in_processor	    	    : in integer  ; 
				iteration		            : in integer  
				       )

     is 


      Nbr_processor     : constant integer := 4 ; 
      X_max            	: constant integer := 1 ; 
      Y_max 		: constant integer := 1 ;

     	
      a_task 				: Generic_Task_Ptr;
      a_system    			: System;
      a_core				: Core_Unit_Ptr;
      index_tab, var	 		: integer ;  

      A_capacity 	: natural := 0;
      A_period 		: natural := 0;
      A_message1 	: Generic_Message_Ptr;
      A_task1		:  Generic_Task_Ptr; 
      A_task2 		:  Generic_Task_Ptr;	
      Table1            : Positions_Table ;
      Position_tab 	: array (1 .. Nbr_processor) of Position ; 
        

  begin

      Set_Initialize;
      Initialize (A_System => a_system);

		---------------------------------------------------------------------------------------------------------------------
		------------------------------ THE    NOC     MODEL -----------------------------------------------------------------
		---------------------------------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------------------------------


						---------------------------
						--generate Network "NoC"---
						---------------------------

     index_tab  := 1 ; 

     for i in 0 .. X_max loop              
	for j in 0 .. Y_max loop 
             Position_tab(index_tab).X       := i  		;
	     Position_tab(index_tab).Y 	     := j  		;
	     index_tab 	  		     := index_tab + 1   ; 	 
	end loop ; 
     end loop ; 

     for i in 1 .. Nbr_processor loop 
     add (Table1, Suppress_Space ((To_Unbounded_string("Processor"& i'Img ))), Position_tab(i) ) ; 
     end loop ; 

     Add_Network (My_Networks          => a_system.networks		,
                   Name                => To_Unbounded_String ("NoC")	,
                   Network_Type        => NOC          			,
	           Network_Delay       => bounded_delay			,
                   Routing_Protocol    =>  XY          			,
                   Processor_Positions => Table1       			);


						-------------------------
						--generate Core_unit-----
						-------------------------
	     
      for i in  0.. X_max loop  
         for j in 0..Y_max loop 
              Add_core_unit(My_core_units  => a_system.Core_units		,
                    A_core_unit	  	   => a_core				,
                    Name           	   => Suppress_Space (To_Unbounded_String ("Core_" & i'Img & j'Img)),
                    Is_Preemptive  	   => preemptive			,
                    Quantum        	   => 0					,
                    speed          	   => 1.0				,
                    capacity        	   => 1					,
                    period         	   => 1					,
                    priority       	   => 1					,
                    File_Name      	   => empty_string			,
                    A_Scheduler            => DAG_highest_level_first_estimated_times_protocol, 
                    automaton_name 	   => empty_string			,
                    start_time     	   => 0					);

           end loop ; 
	end loop ; 


						--------------------------
						--generate Processors-----
						--------------------------

     for i in 1 .. Nbr_processor loop 

     	Add_Processor(My_Processors => a_system.Processors,
                      Name	    => Suppress_Space ((To_Unbounded_string("Processor"& i'Img ))) , 
	              a_Core        => a_core); 
     end loop ; 
 
						----------------------------
						--generate Address_space----
						----------------------------

       for i in 1 .. Nbr_processor loop  
 	     Add_Address_Space(	      My_Address_Spaces 	 => a_system.Address_Spaces,
				      Name	                 => Suppress_Space (To_Unbounded_String ("Address_Space_" & i'Img)),
				      Cpu_Name     	         => Suppress_Space ((To_Unbounded_string("Processor"& i'Img ))) ,
				      Text_Memory_Size  	 => 1024,
				      Stack_Memory_Size 	 => 1024,
				      Data_Memory_Size  	 => 1024,
				      Heap_Memory_Size  	 => 1024);
       end loop ; 
 


		---------------------------------------------------------------------------------------------------------
		------------------------------------THE  TASK    MODEL  +   TASK   MAPPING ------------------------------
		---------------------------------------------------------------------------------------------------------

     
						-------------------------------
						------   generate tasks  ------ 
						-------------------------------


    

	Initialize (a_system.Tasks);
 
	  
	    for j in 1 .. Nbr_processor loop

		for i in 1 .. Nbr_task_in_processor loop 

		       A_period   := 40;    	
		       A_capacity := 38 ; 
		
		       Add_Task(My_Tasks                 => a_system.Tasks,
		       A_Task			 	 => a_task,
		       Name                      	 => Suppress_Space (To_Unbounded_String ("Task"&j'Img&i'Img)),
		       Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"& j'Img ))) ,
		       Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space_" & j'Img)),
		       Task_Type               	 	 => Periodic_Type,
		       Start_Time              		 => 0 ,
		       Capacity                	  	 => A_capacity,
		       Period                   	 => A_period,
		       Deadline                 	 => A_period,
		       Jitter                   	 => 0,
		       Blocking_Time            	 => 0,
		       Priority                 	 => 1,
		       Criticality              	 => 0,
		       Policy                   	 => Sched_Fifo);

                      put_line ("Added task name   :    "& To_String(a_task.name) ) ;
		end loop ; 

	   end loop ;      



		--------------------------------------------------------------------------------------------
		--------------------------------THE----FLOW----MODEL--------------------------------------
		--------------------------------------------------------------------------------------------


		---------------------------------
		---- One - To - One       -------
		---------------------------------	


						-------------------------------------------
						----- produce My_Messages & DEPENDENCY ---- 
						-------------------------------------------

	for j in 1 .. Nbr_task_in_processor loop 
	      for i in 1 .. (Nbr_processor -1 )loop 
              
	      	Add_Message    (My_Messages        => a_system.messages,
			     	Name               => Suppress_Space (To_Unbounded_String("Message" & i'Img & j'Img)),
			      	Size               => 0,
			      	Period             => 0,
			      	Deadline           => 0,
			      	Jitter             => 0,
			      	Param              => No_User_Defined_Parameter,
			      	Response_Time      => 0,
			      	Communication_Time => 0
		 	 );

                var := i + 1 ; 
                A_message1 	:=  Search_Message (a_system.messages, Suppress_Space (To_Unbounded_String("Message" & i'Img & j'Img)) );
		A_task1   	:=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("Task"& i'Img & j'Img))) ;
             	A_task2 	:=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("Task"&var'Img & j'Img)));   

	        Add_One_Task_Dependency_asynchronous_communication (My_Dependencies => a_system.dependencies,
							            A_Task          => A_task1,
							            A_Dep           => A_message1,
							            A_Type          => FROM_TASK_TO_OBJECT, 
								    protocol_property => All_Messages
													);

                Add_One_Task_Dependency_asynchronous_communication (My_Dependencies => a_system.dependencies,
							            A_Task          => A_task2,
							            A_Dep           => A_message1,
							            A_Type          => FROM_OBJECT_TO_TASK,
								    protocol_property => All_Messages
													); 


   		put_line ("from   :    "& To_String(A_task1.name) & "  to  " & To_String(A_task2.name) & " over " & To_String(A_message1.name) ) ;


     	      end loop ; 
         end loop ; 
  
	

						   





  
      Put_Line ("------------------------");
      Put_Line ("Write system to xml file");
      Write_To_Xml_File
        (A_System  => a_system,
         File_Name => Suppress_Space (To_Unbounded_String ("framework_examples/transformation_algo_for_noc/Input_file/Experimentation1/input_Model" & iteration'Img & ".xmlv3")));
      Put_Line ("Finish write");
      Put_Line ("------------------------");

	




	end generate_noc ; 




end generator_noc ; 
