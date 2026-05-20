
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
with Messages; use Messages;
with Dependencies; use Dependencies;
with Systems; use Systems;
with Processors;          use Processors;
with Processor_Set;       use Processor_Set;
with Address_Spaces;      use Address_Spaces;
with Address_Space_Set;   use Address_Space_Set;
with Message_Set;         use Message_Set;
with Task_Dependencies;   use Task_Dependencies;
with Task_Dependencies;   use Task_Dependencies.Half_Dep_Set;
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
with mils_security; use mils_security;
with mils_analysis; use mils_analysis;
with Memories; use Memories;

procedure generator_model_biba is 
   ---------------------------------------------
   N_tasks 		: constant integer := 7 ;
   N_messages 	: constant integer := 2 ; 
   ---------------------------------------------




   Nbr_processor     : constant integer := 9 ; 
   X_max            	: constant integer := 2 ; 
   Y_max 		: constant integer := 2 ;
   mem : Memories_Table;
     	
   a_task 		: Generic_Task_Ptr;
   a_task_p 		: Generic_Task_Ptr;

   a_system    	: System;
 --  a_system1   	: System;
   a_core		: Core_Unit_Ptr;
    

   a_cpu_name 	: Unbounded_String ; 
   a_address_Space   : Unbounded_String ;     
	
      

   z : natural := 000000;
   y : natural :=19;
   w : natural :=0;

   A_task_source :  Generic_Task_Ptr; 
   A_task_sink :  Generic_Task_Ptr;
--   A_task_grader :  Generic_Task_Ptr;
   
   A_task1 :  Generic_Task_Ptr;
   A_task2 :  Generic_Task_Ptr;
   A_task3 :  Generic_Task_Ptr;
   A_task4 :  Generic_Task_Ptr;
   A_task5 :  Generic_Task_Ptr;
   A_task6 :  Generic_Task_Ptr;
   A_task7 :  Generic_Task_Ptr;
   A_task8 :  Generic_Task_Ptr;
   A_task9 :  Generic_Task_Ptr;
   A_task10 :  Generic_Task_Ptr;
   A_task11 :  Generic_Task_Ptr;
   A_task12 :  Generic_Task_Ptr;
   A_task13 :  Generic_Task_Ptr;
   A_task14 :  Generic_Task_Ptr;
   A_task15 :  Generic_Task_Ptr;
   A_task16 :  Generic_Task_Ptr;
   A_task17 :  Generic_Task_Ptr;
   A_task18 :  Generic_Task_Ptr;
   A_task19 :  Generic_Task_Ptr;

   	

   
   tab_secu : array(1.. 2) of MILS_Integrity_Level_Type;
   
   
   My_iterator: Tasks_Dependencies_Iterator;
   Dep_Ptr: Dependency_Ptr;
   --Dep_Ptr1: Dependency_Ptr;

   My_dependencies1: Tasks_Dependencies_Ptr;

   
   TailleMax : constant natural := 100 ; 
--   Type T_Tableau is array(0..TailleMax) of Unbounded_String ;
--   tab : T_Tableau ;

  Project_File_Dir_List : unbounded_string_list;

--     Input_File_Name : Unbounded_String:=To_Unbounded_String("framework_examples/mils/xml_generated_biba/Bi_non_secure_output_Model1.xmlv3");
    Input_File_Name : Unbounded_String:=To_Unbounded_String("framework_examples/mils/xml/exp1/models/biba/biba_non_secure/Bi_non_secure_output_Model1.xmlv3");


begin

   Set_Initialize;
   Initialize (A_System => a_system);

   -------------------------
   --generate Core_unit-----
   -------------------------
	     

   Add_core_unit(My_core_units  => a_system.Core_units		,
                 A_core_unit	  	   => a_core				,
                 Name           	   => Suppress_Space (To_Unbounded_String ("Core")),
                 Is_Preemptive  	   => preemptive			,
                 Quantum        	   => 0					,
                 speed          	   => 1				,
                 capacity        	   => 1					,
                 period         	   => 1					,
                 priority       	   => 1					,
                 File_Name      	   => empty_string			,
                 A_Scheduler            => Posix_1003_Highest_Priority_First_Protocol, 
                 automaton_name 	   => empty_string			,
                 start_time     	   => 0					,
                 mem                  => mem);



   --------------------------
   --generate Processor-----
   --------------------------


   Add_Processor(My_Processors => a_system.Processors,
                 Name	    => Suppress_Space ((To_Unbounded_string("Processor"))) , 
                 a_Core        => a_core); 
 
   ----------------------------
   --generate Address_space----
   ----------------------------


   Add_Address_Space(	      My_Address_Spaces 	 => a_system.Address_Spaces,
                     Name	                 => Suppress_Space (To_Unbounded_String ("Address_Space")),
                     Cpu_Name     	         => Suppress_Space ((To_Unbounded_string("Processor"))) ,
                     Text_Memory_Size  	 => 1024,
                     Stack_Memory_Size 	 => 1024,
                     Data_Memory_Size  	 => 1024,
                     Heap_Memory_Size  	 => 1024);
 


   ---------------------------------------------------------------------------------------------------------
   ------------------------------------THE  TASK    MODEL  +   TASK   MAPPING ------------------------------
   ---------------------------------------------------------------------------------------------------------

     
   -------------------------------
   ------   generate tasks  ------ 
   -------------------------------




   Initialize (a_system.Tasks);
 
		
   Add_Task(My_Tasks                	 => a_system.Tasks,
            A_Task			 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("1")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 => Periodic_Type,
            Start_Time              	 => 0,
            Capacity                	 => 9,
            Period                   	 => 1000,
            Deadline                 	 => 1000,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 37,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret);
                       
   Add_Task(My_Tasks                 	 => a_system.Tasks,
            A_Task			 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("2")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 => Periodic_Type,
            Start_Time              	 => 0 ,
            Capacity                	 => 5,
            Period                   	 => 1000,
            Deadline                 	 => 1000,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 35,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret );  
                            
   Add_Task(My_Tasks                	 => a_system.Tasks,
            A_Task			 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("3")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 => Periodic_Type,
            Start_Time              	 => 0 ,
            Capacity                	  	 => 34,
            Period                   	 => 1000,
            Deadline                 	 => 1000,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 33,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret ); 
                            
   Add_Task(My_Tasks                 => a_system.Tasks,
            A_Task			 	 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("4")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 	 => Periodic_Type,
            Start_Time              		 => 0 ,
            Capacity                	  	 => 3,
            Period                   	 => 1000,
            Deadline                 	 => 1000,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 31,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret ); 

   Add_Task(My_Tasks                 => a_system.Tasks,
            A_Task			 	 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("5")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 	 => Periodic_Type,
            Start_Time              		 => 0 ,
            Capacity                	  	 => 20,
            Period                   	 => 500,
            Deadline                 	 => 500,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 29,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret );                             

   Add_Task(My_Tasks                 => a_system.Tasks,
            A_Task			 	 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("6")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 	 => Periodic_Type,
            Start_Time              		 => 0 ,
            Capacity                	  	 => 10,
            Period                   	 => 1000,
            Deadline                 	 => 1000,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 27,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret );   
                            
   Add_Task(My_Tasks                 => a_system.Tasks,
            A_Task			 	 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("7")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 	 => Periodic_Type,
            Start_Time              		 => 0 ,
            Capacity                	  	 => 10,
            Period                   	 => 1000,
            Deadline                 	 => 1000,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 25,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret ); 
                            
   Add_Task(My_Tasks                 => a_system.Tasks,
            A_Task			 	 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("8")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 	 => Periodic_Type,
            Start_Time              		 => 0 ,
            Capacity                	  	 => 10,
            Period                   	 => 1000,
            Deadline                 	 => 1000,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 23,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret ); 
                            
   Add_Task(My_Tasks                 => a_system.Tasks,
            A_Task			 	 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("9")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 	 => Periodic_Type,
            Start_Time              		 => 0 ,
            Capacity                	  	 => 10,
            Period                   	 => 1000,
            Deadline                 	 => 1000,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 21,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret );
                            
   Add_Task(My_Tasks                 => a_system.Tasks,
            A_Task			 	 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("10")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 	 => Periodic_Type,
            Start_Time              		 => 0 ,
            Capacity                	  	 => 10,
            Period                   	 => 1000,
            Deadline                 	 => 1000,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 19,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret );  
                            
   Add_Task(My_Tasks                 => a_system.Tasks,
            A_Task			 	 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("11")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 	 => Periodic_Type,
            Start_Time              		 => 0 ,
            Capacity                	  	 => 10,
            Period                   	 => 2000,
            Deadline                 	 => 2000,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 17,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret );
                            
   Add_Task(My_Tasks                 => a_system.Tasks,
            A_Task			 	 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("12")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 	 => Periodic_Type,
            Start_Time              		 => 0 ,
            Capacity                	  	 => 10,
            Period                   	 => 1000,
            Deadline                 	 => 1000,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 15,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret );
                            
   Add_Task(My_Tasks                 => a_system.Tasks,
            A_Task			 	 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("13")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 	 => Periodic_Type,
            Start_Time              		 => 0 ,
            Capacity                	  	 => 10,
            Period                   	 => 1000,
            Deadline                 	 => 1000,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 13,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret ); 
                            
   Add_Task(My_Tasks                 => a_system.Tasks,
            A_Task			 	 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("14")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 	 => Periodic_Type,
            Start_Time              		 => 0 ,
            Capacity                	  	 => 50,
            Period                   	 => 2000,
            Deadline                 	 => 2000,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 11,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret );   
                            
   Add_Task(My_Tasks                 => a_system.Tasks,
            A_Task			 	 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("15")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 	 => Periodic_Type,
            Start_Time              		 => 0 ,
            Capacity                	  	 => 50,
            Period                   	 => 1000,
            Deadline                 	 => 1000,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 9,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret );   
                            
   Add_Task(My_Tasks                 => a_system.Tasks,
            A_Task			 	 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("16")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 	 => Periodic_Type,
            Start_Time              		 => 0 ,
            Capacity                	  	 => 50,
            Period                   	 => 2000,
            Deadline                 	 => 2000,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 7,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret );
                            
   Add_Task(My_Tasks                 => a_system.Tasks,
            A_Task			 	 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("17")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 	 => Periodic_Type,
            Start_Time              		 => 0 ,
            Capacity                	  	 => 50,
            Period                   	 => 1000,
            Deadline                 	 => 1000,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 5,
            Criticality              	 => 0,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret ); 
                            
   Add_Task(My_Tasks                 => a_system.Tasks,
            A_Task			 	 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("18")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 	 => Periodic_Type,
            Start_Time              		 => 0 ,
            Capacity                	  	 => 10,
            Period                   	 => 500,
            Deadline                 	 => 500,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 27,
            Criticality              	 => 3,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret );   
                            
   Add_Task(My_Tasks                 => a_system.Tasks,
            A_Task			 	 => a_task,
            Name                      	 => Suppress_Space (To_Unbounded_String ("19")),
            Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
            Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
            Task_Type               	 	 => Periodic_Type,
            Start_Time              		 => 0 ,
            Capacity                	  	 => 10,
            Period                   	 => 500,
            Deadline                 	 => 500,
            Jitter                   	 => 0,
            Blocking_Time            	 => 0,
            Priority                 	 => 27,
            Criticality              	 => 3,
            Policy                   	 => Sched_Fifo,
            mils_confidentiality_level   => Secret );   


  

   ------------------------------
   ---    produce dependency  --- 
   ------------------------------     

   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("1"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("2"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("2"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("3"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("3"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("4"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("5"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("6"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("5"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("7"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("5"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("8"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("5"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("9"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("5"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("10"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("6"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("11"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("7"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("12"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("8"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("12"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("8"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("13"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);

   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("9"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("12"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("10"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("13"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("11"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("12"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("11"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("14"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("12"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("15"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("13"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("16"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("13"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("17"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("15"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("18"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("17"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("19"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("18"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("5"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);
                            
   A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("19"))) ;
   A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("5"))); 
   Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                       Source          => A_task_source,
                                       Sink           => A_task_sink);


   tab_secu(1):= High;
   tab_secu(2):= Medium;
   
       
   for a in 1 .. 2 loop
      for b in 1 .. 2 loop
         for c in 1 .. 2 loop
            for d in 1 .. 2 loop
               for e in 1 .. 2 loop
                  for f in 1 .. 2 loop
                     for g in 1 .. 2 loop
                        for h in 1 .. 2 loop
                           for i in 1 .. 2 loop
                              for j in 1 .. 2 loop
                                 for k in 1 .. 2 loop
                                    for l in 1 .. 2 loop
                                       for m in 1 .. 2 loop
                                          for n in 1 .. 2 loop
                                             for o in 1 .. 2 loop
                                                for p in 1 .. 2 loop
                                                   for q in 1 .. 2 loop
                                                      for r in 1 .. 2 loop
                                                         for s in 1 .. 2 loop
                                                            A_task1 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("1"))) ;
                                                            A_task1.mils_integrity_level:= tab_secu(a);

                                                            A_task2 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("2"))) ;
                                                            A_task2.mils_integrity_level:= tab_secu(b);                            

                                                            A_task3 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("3"))) ;
                                                            A_task3.mils_integrity_level:= tab_secu(c);

                                                            A_task4 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("4"))) ;
                                                            A_task4.mils_integrity_level:= tab_secu(d);

                                                            A_task5 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("5"))) ;
                                                            A_task5.mils_integrity_level:= tab_secu(e);          
                  
                                                            A_task6 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("6"))) ;
                                                            A_task6.mils_integrity_level:= tab_secu(f);                   
         
                                                            A_task7 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("7"))) ;
                                                            A_task7.mils_integrity_level:= tab_secu(g);                            

                                                            A_task8 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("8"))) ;
                                                            A_task8.mils_integrity_level:= tab_secu(h);                            

                                                            A_task9 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("9"))) ;
                                                            A_task9.mils_integrity_level:= tab_secu(i);                            

                                                            A_task10 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("10"))) ;
                                                            A_task10.mils_integrity_level:= tab_secu(j);                            

                                                            A_task11 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("11"))) ;
                                                            A_task11.mils_integrity_level:= tab_secu(k);                 
           
                                                            A_task12 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("12"))) ;
                                                            A_task12.mils_integrity_level:= tab_secu(l);                            

                                                            A_task13 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("13"))) ;
                                                            A_task13.mils_integrity_level:= tab_secu(m);                            

                                                            A_task14 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("14"))) ;
                                                            A_task14.mils_integrity_level:= tab_secu(n); 
  
                                                            A_task15 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("15"))) ;
                                                            A_task15.mils_integrity_level:= tab_secu(o);
                            
                                                            A_task16 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("16"))) ;
                                                            A_task16.mils_integrity_level:= tab_secu(p);                            
                            
                                                            A_task17 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("17"))) ;
                                                            A_task17.mils_integrity_level:= tab_secu(q);                            
                            
                                                            A_task18 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("18"))) ;
                                                            A_task18.mils_integrity_level:= tab_secu(r);                            
                            
                                                            A_task19 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("19"))) ;
                                                            A_task19.mils_integrity_level:= tab_secu(s);  
                            
                                                            z:=z+1;
                                                            Put_Line ("-----------Not secured file-----------");
                                                            Put_Line ("Write system to xml file"&z'Img);
                                                            Write_To_Xml_File
                                                              (A_System  => a_system,
--                                                               File_Name => Suppress_Space (To_Unbounded_String ( "framework_examples/mils/xml_generated_biba/Bi_non_secure_output_Model"&z'Img&".xmlv3")));
                                                            File_Name => Suppress_Space (To_Unbounded_String ( "framework_examples/mils/xml/exp1/models/biba/biba_non_secure/Bi_non_secure_output_Model"&z'Img&".xmlv3")));
                                                            
                                                            Put_Line ("Finish write"&z'Img);
                                                            Put_Line ("----------Not secured file------------");                                                              
                                                            ---------------------------------------------------------------------------------------
  --                                                          a_system1:=a_system;  
                                                            a_task_p:= a_task;
               --                                             a_system1.Dependencies:=a_system.Dependencies;

                                                            My_dependencies1 := a_system.Dependencies;

                                                            reset_iterator(My_dependencies1.Depends, My_iterator);
                                                            loop
                                                               current_element(My_dependencies1.Depends, Dep_Ptr, My_iterator); 
                                                            
                                                               if (Dep_Ptr.type_of_dependency=precedence_dependency)then
                                                                    
                                                                  if (Dep_Ptr.precedence_source.mils_integrity_level<Dep_Ptr.precedence_sink.mils_integrity_level) then 
                                                                     if ((Dep_Ptr.precedence_source.mils_task/=Downgrader) AND (Dep_Ptr.precedence_source.mils_task/=Upgrader)AND
                                                                           (Dep_Ptr.precedence_sink.mils_task/=Downgrader)AND (Dep_Ptr.precedence_sink.mils_task/=Upgrader)) then
                                                                 
                                                                     Put_Line(" biba precedence_source :" &  To_String(Dep_Ptr.precedence_source.name));
						                     Put_Line(" biba precedence_sink :" &  To_String(Dep_Ptr.precedence_sink.name));
                                                                     y:=y+1;
                                                                     Put_Line("y:"& y'Img);
                                                                     Add_Task(My_Tasks                 => a_system.Tasks,
                                                                              A_Task			 	 => a_task_p,
                                                                              Name                      	 => Suppress_Space (To_Unbounded_String (""&y'img)),
                                                                              Cpu_Name                 	 => Suppress_Space ((To_Unbounded_string("Processor"))) ,
                                                                              Address_Space_Name       	 => Suppress_Space (To_Unbounded_String ("Address_Space")),
                                                                              Task_Type               	 	 => Periodic_Type,
                                                                              Start_Time              		 => 0 ,
                                                                              Capacity                	  	 => 166,
                                                                              Period                   	 => 2000,
                                                                              Deadline                 	 => 2000,
                                                                              Jitter                   	 => 0,
                                                                              Blocking_Time            	 => 0,
                                                                              Priority                 	 => Integer'Value( Dep_Ptr.precedence_source.priority'Img),
                                                                              Criticality              	 => 3,
                                                                              Policy                   	 => Sched_Fifo,
                                                                              mils_task            => Upgrader );  
                                                                     A_task_source :=  Search_Task (a_system.Tasks, Dep_Ptr.precedence_source.name) ;
                                                                     A_task_sink :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String (""&y'img))); 
                                                                     Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                                                                                         Source          => A_task_source,
                                                                                                         Sink           => A_task_sink);
                                                                     A_task_source :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String (""&y'img))) ;
                                                                     A_task_sink :=  Search_Task (a_system.Tasks, Dep_Ptr.precedence_sink.name); 
                                                                     Add_One_Task_Dependency_precedence (My_Dependencies => a_system.dependencies,
                                                                                                         Source          => A_task_source,
                                                                                                         Sink           => A_task_sink); 
                                                                     Delete_One_Task_Dependency_precedence(My_Dependencies1, Dep_Ptr.precedence_source, Dep_Ptr.precedence_sink);

                                                                     end if;
                                                                     end if;
                                                               	end if;
                                                               
                                                               exit when is_last_element (My_Dependencies1.Depends, My_Iterator);
                                                               next_element (My_Dependencies1.Depends, My_Iterator);
                                                            end loop;
                                                                     Put_Line ("-------Secured file------------");
                                                                     Put_Line ("Write system to xml file"&z'Img);
                                                                     Write_To_Xml_File
                                                                       (A_System  => a_system,
--                                                                        File_Name => Suppress_Space (To_Unbounded_String ( "framework_examples/mils/xml_generated_biba/Bi_secure_output_Model"&z'Img&".xmlv3")));
                                                                    File_Name => Suppress_Space (To_Unbounded_String ( "framework_examples/mils/xml/exp1/models/biba/biba_secure/Bi_secure_output_Model"&z'Img&".xmlv3")));

                                                                     Put_Line ("Finish write"&z'Img);
                                                                     Put_Line ("-----------Secured file------------");    
                                                            
                                                            
                                                            ----------------------------------------------------------------------------------------------
                                                              initialize(a_system);
  							      Systems.Read_From_Xml_File (a_system, Project_File_Dir_List, Input_File_Name);
                                                               y:=19;
                                                            --------------------------------------------------------------------------------------------------------- 
                                                
                          
                            
                                                         end loop;
                                                      end loop;
                                                   end loop;
                                                end loop;
                                             end loop;
                                          end loop;
                                       end loop;
                                    end loop;
                                 end loop;
                              end loop;
                           end loop;
                        end loop;
                     end loop;
                  end loop;
               end loop;
            end loop;
         end loop;
      end loop;
   end loop;
                           

end  generator_model_biba;



