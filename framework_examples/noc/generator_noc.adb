
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
with Scheduler.Fixed_Priority ; use Scheduler.Fixed_Priority ; 

procedure generator_noc is 

 
-- number of tasks in the processor 
      N_tasks 		: constant integer := 4 ;   

      N_messages 	: constant integer := 3 ; 
      Nbr_processor     : constant integer := 16 ; 
      X_max            	: constant integer := 3 ; 
      Y_max 		: constant integer := 3 ;
	
      a_task 		: Generic_Task_Ptr;
      a_system    	: System;
      a_core		: Core_Unit_Ptr;
    

      a_cpu_name 	: Unbounded_String ; 
      a_address_Space   : Unbounded_String ;     
      i,j,i1 		: integer ;  
      Start_Time	: integer ;
	
      
      Target_cpu_utilization  	:  Float;	
      N_Different_Periods	: Integer ; 	
      U_values			: Random_Tools.Float_Array (0 .. N_tasks-1);
      T_values			: Random_Tools.Integer_Array (1 .. N_tasks);
      A_capacity 	 	: natural := 0;
      A_period 			: natural := 0;

      
	
      A_message1 : Generic_Message_Ptr;
      My_Iterator : Messages_iterator;

      A_task1 :  Generic_Task_Ptr; 
      A_task2 :  Generic_Task_Ptr;

      tab_src  : array (1.. N_messages) of integer ; 
      tab_dest : array (1.. N_messages) of integer ; 

      rand_destination  : array (1 .. 2*N_messages) of integer ;
       G       		: Ada.Numerics.Float_Random.Generator;
	
       Table1                : Positions_Table ;
       Position_tab 	     : array (1 .. 16) of Position ; 
        

  begin

      Set_Initialize;
      Initialize (A_System => a_system);

	

-------
--generate Network "NoC"
-------

     --Initialize( NOC_Network)
     for i in 1 .. 16 loop 
             
             Position_tab(i).X := 0   ;
	     Position_tab(i).Y := 0  ; 

     end loop ; 



     for i in 1 .. 16 loop 
     add (Table1, To_Unbounded_string("Processor"& i'Img ), Position_tab(i) ) ; 
     end loop ; 


     Add_Network (My_Networks  => a_system.networks,
                   Name         =>  To_Unbounded_String ("NoC"),
                   Network_Type => NOC,
	           Network_Delay => bounded_delay,
                   Routing_Protocol =>  XY,
                   Processor_Positions => Table1);

-------
--generate Core_unit
------
     
      for i in  0.. X_max loop  
         for j in 0..Y_max loop 
      Add_core_unit(My_core_units  => a_system.Core_units,
                    A_core_unit	   => a_core,
                    Name           => Suppress_Space (To_Unbounded_String ("Core_" & i'Img & j'Img)),
                    Is_Preemptive  => preemptive,
                    Quantum        => 0,
                    speed          => 1.0,
                    capacity       => 1,
                    period         => 1,
                    priority       => 1,
                    File_Name      => empty_string,
                    A_Scheduler    => Rate_Monotonic_Protocol, -- Fixed_Priority_Scheduler,
                    automaton_name => empty_string,
                    start_time     => 0);

           end loop ; 
	end loop ; 

-------
--generate Address_space 
------
    for i in  0.. X_max loop  
         for j in 0..Y_max loop  

	 Add_Address_Space(My_Address_Spaces => a_system.Address_Spaces,
                      Name              => Suppress_Space (To_Unbounded_String ("Address_Space_" & i'Img & j'Img)),
                      Cpu_Name          => Suppress_Space (To_Unbounded_String("proc"& i'Img & j'Img & "_mak")),
                      Text_Memory_Size  => 1024,
                      Stack_Memory_Size => 1024,
                      Data_Memory_Size  => 1024,
                      Heap_Memory_Size  => 1024);
         end loop ; 
     end loop ; 

-------
--generate Processors 
------


     
      for i in  0.. X_max loop  
         for j in 0..Y_max loop 


      Add_Processor(My_Processors => a_system.Processors,
                    Name          => Suppress_Space (To_Unbounded_String("proc"& i'Img & j'Img & "_mak")),
                    a_Core        => a_core);

	end loop ; 
      end loop ; 
      
------
--produce tasks 
------


	Initialize (a_system.Tasks);
 

        for i in 1..Nbr_processor loop 

	
	if i = 1  then 
		a_cpu_name := To_Unbounded_String("proc00_mak") ; 
		a_address_Space := To_Unbounded_String("Address_Space_00") ;  

		for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) := 0.025  ; 
                 T_values(i1)   := 1000 ; 
	         Start_Time	:=0 ;
	        end loop ; 

        end if ; 

        if i = 2  then 
		a_cpu_name :=To_Unbounded_String( "proc01_mak") ; 
		a_address_Space :=To_Unbounded_String( "Address_Space_01") ;  

		for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) := 0.025  ; 
                 T_values(i1)   := 1000 ; 
	         Start_Time	:= 1 ;
	        end loop ; 

	end if ; 

        if i = 3  then 
		a_cpu_name :=To_Unbounded_String( "proc02_mak") ; 
		a_address_Space := To_Unbounded_String("Address_Space_02") ;  

		for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) := 0.025   ; 
                 T_values(i1)   := 1000 ; 
	         Start_Time	:=0 ;
	        end loop ; 

	end if ; 

	if i = 4  then 
		a_cpu_name := To_Unbounded_String("proc03_mak") ; 
		a_address_Space := To_Unbounded_String("Address_Space_03") ;  

		for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) := 0.025   ; 
                 T_values(i1)   := 1000 ; 
	         Start_Time	:=0 ;
	        end loop ; 

	end if ; 

        if i = 5  then 
		a_cpu_name := To_Unbounded_String("proc10_mak") ; 
		a_address_Space := To_Unbounded_String("Address_Space_10") ;  

		for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) :=  0.025  ; 
                 T_values(i1)   := 1000 ; 
	         Start_Time	:=0 ;
	        end loop ; 

	end if ; 

        if i = 6  then 
		a_cpu_name := To_Unbounded_String("proc11_mak") ; 
		a_address_Space := To_Unbounded_String("Address_Space_11") ;  

		for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) := 0.025  ; 
                 T_values(i1)   := 1000 ; 
	         Start_Time	:= 0 ;
	        end loop ; 

	end if ; 

        if i = 7  then 
		a_cpu_name := To_Unbounded_String("proc12_mak") ; 
		a_address_Space := To_Unbounded_String("Address_Space_12") ;  

		for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) :=  0.025   ; 
                 T_values(i1)   := 1000 ; 
	         Start_Time	:= 10 ;
	        end loop ; 

	end if ; 

	if i = 8  then 
		a_cpu_name := To_Unbounded_String("proc13_mak") ; 
		a_address_Space := To_Unbounded_String("Address_Space_13") ;  

		for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) :=  0.025  ; 
                 T_values(i1)   := 1000 ; 
	         Start_Time	:=0 ;
	        end loop ; 

	end if ; 

	if i = 9  then 
		a_cpu_name := To_Unbounded_String("proc20_mak") ; 
		a_address_Space := To_Unbounded_String("Address_Space_20") ;  

		for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) :=  0.025  ; 
                 T_values(i1)   := 1000 ; 
	         Start_Time	:=0 ;
	        end loop ; 

	end if ; 

        if i = 10 then 
		a_cpu_name := To_Unbounded_String("proc21_mak") ; 
		a_address_Space := To_Unbounded_String("Address_Space_21") ;  

		for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) := 0.025   ; 
                 T_values(i1)   := 1000 ; 
	         Start_Time	:= 1 ;
	        end loop ; 

	end if ; 

        if i = 11 then 
		a_cpu_name := To_Unbounded_String("proc22_mak") ; 
		a_address_Space := To_Unbounded_String("Address_Space_22") ; 

		for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) := 0.025  ; 
                 T_values(i1)   := 1000 ; 
	         Start_Time	:=0 ;
	        end loop ; 

	end if ; 

	if i = 12 then 
		a_cpu_name := To_Unbounded_String("proc23_mak") ; 
		a_address_Space :=To_Unbounded_String("Address_Space_23") ;  

		for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) :=  0.025  ; 
                 T_values(i1)   := 1000 ; 
	         Start_Time	:=0 ;
	        end loop ; 

	end if ; 

	if i = 13  then 
		a_cpu_name := To_Unbounded_String("proc30_mak") ; 
		a_address_Space := To_Unbounded_String("Address_Space_30") ;  

		for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) := 0.025   ; 
                 T_values(i1)   := 1000 ; 
	         Start_Time	:=0 ;
	        end loop ; 

	end if ; 

        if i = 14  then 
		a_cpu_name := To_Unbounded_String("proc31_mak") ; 
		a_address_Space := To_Unbounded_String("Address_Space_31") ;  

		for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) := 0.025  ; 
                 T_values(i1)   := 1000 ; 
	         Start_Time	:=0 ;
	        end loop ; 

	end if ; 

        if i = 15  then 
		a_cpu_name := To_Unbounded_String("proc32_mak") ; 
		a_address_Space := To_Unbounded_String("Address_Space_32") ; 

		for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) :=  0.025  ; 
                 T_values(i1)   := 1000 ; 
	         Start_Time	:= 1 ;
	        end loop ; 

	end if ; 

	if i = 16  then 
		a_cpu_name := To_Unbounded_String("proc33_mak") ; 
		a_address_Space := To_Unbounded_String("Address_Space_33") ;  

		for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) := 0.125 ; 
                 T_values(i1)   := 10000 ; 
   	         Start_Time 	:= 0	;
	        end loop ; 



	end if ; 
		
	  Target_cpu_utilization := 0.15 ; 
	  N_Different_Periods := 2 ; 	
	

	       for i1 in 1 .. N_Tasks loop 
                 U_values(i1-1) :=  0.225  ; 
                 T_values(i1)   := 1000 ; 
	         Start_Time	:=0 ;
	        end loop ; 

	  
	  for j in 1 .. N_Tasks loop

	        A_period := Natural (T_values(j));    
	
                A_capacity := Integer (Float'Rounding (Float(A_period) * U_values(j-1)));
		    if A_capacity = 0 then
			A_capacity := 1;
		    end if;
		
	

	       Add_Task(My_Tasks                  => a_system.Tasks,
               A_Task			 => a_task,
               Name                      => Suppress_Space (To_Unbounded_String ("Task"&j'Img&i'Img)),
               Cpu_Name                  => a_cpu_name,
               Address_Space_Name        => a_address_Space,
               Task_Type                 => Periodic_Type,
               Start_Time                => Start_Time ,
               Capacity                  => A_capacity,
               Period                    => A_period,
               Deadline                  => A_period,
               Jitter                    => 0,
               Blocking_Time             => 0,
               Priority                  => 1,
               Criticality               => 0,
               Policy                    => Sched_Fifo);

		

	  end loop ;      

      end loop ; 


------
--produce My_Messages 
------


      	Add_Message(My_Messages        => a_system.messages,
      	Name               => Suppress_Space (To_Unbounded_String("Message1")),
      	Size               => 12,
      	Period             => 10,
      	Deadline           => 10,
      	Jitter             => 10,
      	Param              => No_User_Defined_Parameter,
      	Response_Time      => 10,
      	Communication_Time => 10);
     



-------
-- produce dependency 
-------  
    
     tab_src  := ( 1,  2 ,  3   ) ; 
     tab_dest := (16 , 6 ,  11  ) ;


    reset_iterator (a_system.messages, My_Iterator);
    i := 1 ; 
    
	loop
	    current_element (a_system.messages, A_message1, My_Iterator);     
            	    
	    A_task1 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("Task1"& tab_src(i)'Img))) ;
            A_task2 :=  Search_Task (a_system.Tasks, Suppress_Space (To_Unbounded_String ("Task2"& tab_dest(i)'Img )));   

		
            Add_One_Task_Dependency_asynchronous_communication (My_Dependencies => a_system.dependencies,
            A_Task          => A_task1,
            A_Dep           => A_message1,
            A_Type          => FROM_TASK_TO_OBJECT);

            Add_One_Task_Dependency_asynchronous_communication (My_Dependencies => a_system.dependencies,
            A_Task          => A_task2,
            A_Dep           => A_message1,
            A_Type          => FROM_OBJECT_TO_TASK); 

      
	     
	   exit when is_last_element (a_system.messages, My_Iterator);
           next_element (a_system.messages, My_Iterator);
	   i := i+1 ;   	
        end loop;








      Put_Line ("------------------------");
      Put_Line ("Write system to xml file");
      Write_To_Xml_File
        (A_System  => a_system,
         File_Name => "framework_examples/noc/generated_system.xmlv3");
      Put_Line ("Finish write");
      Put_Line ("------------------------");

	




end  generator_noc;



