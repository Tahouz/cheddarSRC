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
with Network_Set; use Network_Set; 
with Networks; use Networks; 
with Indexed_Tables;


package body noc_analysis is

  -----------------------------
  -- subprograms --
  -----------------------------

	-----------------------
	-- compute_source_destination_task--
	-----------------------

	-- generate destination tasks set and source task set --

    procedure compute_source_destination_task  
        ( My_tasks     		: in Tasks_set; 
	  My_Messages  	        : in Messages_Set;
	  My_dep	        : in Tasks_Dependencies_Ptr; 
	  Destination_tasks     : in out Tasks_set;   
	  Source_tasks	        : in out Tasks_set 
         ) 
    is 
        number_message : integer ; 	
	A_Message   : Generic_Message_Ptr;
	My_Iterator : Messages_iterator;
	My_Iterator1 : Tasks_Dependencies_Iterator;
	A_Half_Dep   : Dependency_Ptr;

    begin 

    reset_iterator (My_Messages, My_Iterator); 
    number_message := 1 ; 
    loop
	current_element (My_Messages, A_Message, My_Iterator);        
	if not is_empty (My_dep.Depends) then
        reset_iterator (My_dep.Depends, My_Iterator1);
             
	loop
           current_element  (My_dep.Depends,  A_Half_Dep,  My_Iterator1);
           if (A_Message = A_Half_Dep.asynchronous_communication_dependency_object) then
	    if (A_Half_Dep.asynchronous_communication_orientation = From_Object_To_Task) then 
                     add( Destination_tasks , A_Half_Dep.asynchronous_communication_dependent_task);
            else  add(Source_tasks , A_Half_Dep.asynchronous_communication_dependent_task ) ; 
            end if ; 
           end if ; 
	
	   exit when is_last_element (My_dep.Depends, My_Iterator1);
           next_element (My_dep.Depends, My_Iterator1);
        end loop;
	end if;
	      
     exit when is_last_element (My_Messages, My_Iterator);
     next_element (My_Messages, My_Iterator);
     number_message := number_message +1 ; 	
     end loop;

     
 end compute_source_destination_task ; 


	-----------------------------------------------------
	----display_source_destination_task 
	-----------------------------------------------------

     procedure display_source_destination_task ( My_Messages  	         : in Messages_Set ;
		                                 Destination_tasks       : in Tasks_set    ;   
	 		                         Source_tasks	         : in Tasks_set ; 
						 SourceTask_position_Table      		    :  in  tab_Position ; 
					         DestinationTask_position_Table            	    :  in  tab_Position   )  

       is 
	
	
        My_Iterator1    : Tasks_Iterator;
        My_Iterator2    : Messages_iterator;
	i               : integer ; 
        A_TaskNS        : Generic_Task_Ptr;
        A_TaskND        : Generic_Task_Ptr;
        A_Message       : Generic_Message_Ptr;
        

       begin 


	i := 1 ; 
	if not is_empty (Destination_tasks) then

         reset_iterator (Destination_tasks, My_Iterator1);
	 
         reset_iterator (My_Messages , My_Iterator2);

	loop
            current_element  (Destination_tasks, A_TaskND,     My_Iterator1);
	    current_element  (Source_tasks, A_TaskNS,     My_Iterator1);
	    current_element (My_Messages , A_Message, My_Iterator2);
      

	        --A_Message.name := Suppress_Space (To_String (A_TaskNS.cpu_name & A_TaskND.cpu_name));
	        A_Message.name := Suppress_Space (To_String (A_TaskNS.cpu_name & "proca    "));
                put(To_String(A_Message.name));
		put(":") ; 		
	

		put(To_String(A_TaskNS.name));		
		put(To_String(A_TaskNS.cpu_name));		
		put("----->") ; 
		put(To_String(A_TaskND.name));		
		put(To_string(A_TaskND.cpu_name));
		
		
		put("  /***/ ") ; 


	        put_Line("  ****//****     ");
                put("source_pos : ")  ;
		put(SourceTask_position_Table (i).X);
		put(SourceTask_position_Table (i).Y);
		put("  ===>  ");
		put("destination_pos : ")  ; 
		put( DestinationTask_position_Table(i).X);
		put( DestinationTask_position_Table(i).Y);
	
		put_Line("  ****//****     ");
                put_Line("  "); 
	


        exit when is_last_element       (Destination_tasks, My_Iterator1);
	next_element (Destination_tasks, My_Iterator1);
	next_element (My_Messages , My_Iterator2);
        i := i +1 ; 

	end loop ; 

        end if ; 



       end display_source_destination_task ;



-------------------------------
---compute_source_destination_task_position--
-------------------------------
--select position of each souce and destination task in order to compute after the used links.  
-------------------------------



        procedure compute_source_destination_task_position   (  	SourceTask_position_Table      		            :  in out tab_Position ; 
					            			DestinationTask_position_Table            	    :  in out tab_Position ; 
									SourceTask_rank_table				    	:  in out processor_ranks   ;
									DestinationTask_rank_table				    :  in out processor_ranks   ;	
									Source_tasks            : in out Tasks_set;   
			                                                Destination_tasks       : in out Tasks_set; 
                             				                My_messages             : in Messages_Set;  
			      	            			        My_noc			: in Networks_Set 
				) 
        is 
        My_Iterator1    : Tasks_Iterator;
        My_Iterator2    : Messages_iterator;
	My_Iterator3	: Network_Iterator ; 
        i,j             : integer ; 
        A_TaskNS        : Generic_Task_Ptr;
        A_TaskND        : Generic_Task_Ptr;
        A_Message       : Generic_Message_Ptr;
        A_noc		: NOC_Network_Ptr;--generic_network_ptr ; 
	Position1	     :  Position ; 
	Table1                : Positions_Table ;

        begin 
         
	i := 1 ; 
	if not is_empty (Destination_tasks) then

         reset_iterator (Destination_tasks, My_Iterator1);
	 
         reset_iterator (My_messages , My_Iterator2);

	loop
            current_element  (Destination_tasks, A_TaskND,     My_Iterator1);
	    current_element  (Source_tasks, A_TaskNS,     My_Iterator1);
	    current_element (My_messages , A_Message, My_Iterator2);

		      j := 0 ; 
                      reset_iterator (My_noc , My_Iterator3);
       		      loop 
		      current_element (My_noc , generic_network_ptr(A_noc), My_Iterator3);
	              Table1 := A_noc.processor_positions ;

        		if ( A_TaskNS.cpu_name = Table1.entries(0).item ) then  
				SourceTask_position_Table(i) :=  Table1.entries(0).data ;  --voir pb de j ? 
				SourceTask_rank_table(i) := 0  ;
			else 
				SourceTask_position_Table(i).X := 0 ; 
				SourceTask_position_Table(i).Y := 1  ; 
				SourceTask_rank_table(i) := 1 ;
        		end if ; 
                          
			if ( A_TaskND.cpu_name = Table1.entries(0).item ) then  
				DestinationTask_position_Table(i) :=  Table1.entries(0).data ;
				DestinationTask_rank_table(i) := 0  ;
			else 
				DestinationTask_position_Table(i).X := 3 ; 
				DestinationTask_position_Table(i).Y := 2  ; 
				DestinationTask_rank_table(i) := 1 ;
        		end if ; 
                        
					
		     j := j +1 ; 
        	     exit when is_last_element       (My_noc, My_Iterator3);
		     next_element (My_noc, My_Iterator3);
		     end loop ;
			
	exit when is_last_element       (Destination_tasks, My_Iterator1);
	next_element (Destination_tasks, My_Iterator1);
	next_element (My_messages , My_Iterator2);
        i := i +1 ; 

	end loop ; 

        end if ; 

        end compute_source_destination_task_position; 
    

-------------------------
---procedure generate_links---
-------------------------
--generate used links for each message
-------------------------

   procedure generate_links
       (A_link_mat              : in out links_mat;  
	My_messages	        : in Messages_Set; 
	SourceTask_position_Table    	  		    :  in tab_Position ; 
        DestinationTask_position_Table            	    :  in tab_Position ;
	SourceTask_rank_table :  in  processor_ranks   
                 ) 
	
   is
	My_Iterator2						       	 : Messages_iterator;
	A_Message	       					 	 : Generic_Message_Ptr;
	i, Diff_X , Diff_X1 , Diff_Y, Diff_Y1, j 			 : integer ; 
	cpu_position 	 						 : processor_rank  ;  
        A_link , A_link_invalid 					 : noc_Links ; 
	index 								 : integer ;
	A_link_table 							 : Links_tab ; 
 
    begin
   
	A_link_invalid.source := 0 ; 
        A_link_invalid.destination := 0 ;   

	i := 1 ; 
	reset_iterator (My_messages, My_Iterator2);
	loop 
	current_element (My_messages, A_Message, My_Iterator2);


  	Diff_X:=  DestinationTask_position_Table(i).X - SourceTask_position_Table(i).X ; 
  	cpu_position :=  SourceTask_rank_table(i) ;
  	link_table_size(i) := 0 ; 
        
        for index in 1 .. max_noc_links_per_message loop 
        A_link_table(index):= A_link_invalid ;  
        end loop ; 
	
   	

  	Diff_Y :=  DestinationTask_position_Table(i).Y - SourceTask_position_Table(i).Y;
	 

	if (Diff_Y>0 ) then 

		for j in 1 .. Diff_Y loop	
		
		A_link.source := cpu_position ; 
		A_link.destination := cpu_position+1 ;
                cpu_position:= cpu_position+1 ; 
		link_table_size(i) := link_table_size(i) +1 ;  
        	A_link_table(Integer(link_table_size(i))) := A_link ;

		end loop ;

	else if (Diff_Y<0) then 
	      Diff_Y1 := - Diff_Y ; 
	      for j in 1 .. Diff_Y1 loop 
		A_link.source := cpu_position ; 
		A_link.destination := cpu_position-1 ;
    		cpu_position:= cpu_position-1 ;		
		link_table_size(i) := link_table_size(i) +1 ;  
        	A_link_table(Integer(link_table_size(i))) := A_link ;
		
              end loop ;


	    

	end if ; 
	end if ; 
	
	if ( Diff_X > 0) then   

		for j in 1 .. Diff_X loop 
		    A_link.source := cpu_position ; 
		    A_link.destination := cpu_position +4 ; 
		    cpu_position:= cpu_position+4 ; 
		    link_table_size(i) := link_table_size(i) +1 ;  
         	    A_link_table(Integer(link_table_size(i))) := A_link ; 
		    		
		end loop ; 

        else if (Diff_X < 0 ) then
	
                 Diff_X1 := - Diff_X ;         
	         for j in 1 .. Diff_X1 loop 
		    
		    A_link.source := cpu_position ; 
		    A_link.destination := cpu_position -4 ;
		    cpu_position:= cpu_position -4 ;  
		    link_table_size(i) := link_table_size(i) +1 ;  
        	    A_link_table(Integer(link_table_size(i))) := A_link ; 
		    
                 end loop ; 
    
        end if ;
	end if ; 

       
           
    
        A_link_mat(i) :=  A_link_table ;
        i := i +1 ;


    exit when is_last_element (My_messages, My_Iterator2);
    next_element (My_messages, My_Iterator2);
	
	 
    end loop;


 end generate_links ; 





   procedure display_used_links
       (My_messages	        : in Messages_Set; 
	A_link_mat              : in links_mat 
                 ) 
	
   is
	My_Iterator2						       	 : Messages_iterator;
	A_Message	       					 	 : Generic_Message_Ptr;
	i,j 					 			 : integer ; 
        A_link 			 					 : noc_Links ; 
	A_link_table 							 : Links_tab ; 
 
    begin
   
	
	i := 1 ; 
	reset_iterator (My_messages, My_Iterator2);
	loop 
	current_element (My_messages, A_Message, My_Iterator2);

   	put_Line ("======-----*****------======") ;
    
   	put_Line ("") ;
   	put(To_String(A_Message.name));
   	put(":   ") ; 
   	A_link_table := A_link_mat(i) ;
  
 	For j in 1 .. Integer(link_table_size(i)) loop 

        A_link := A_link_table(j) ; 
        put ("e(") ;
        put(Integer(A_link.source));
        put(Integer(A_link.destination)); 
        put(")") ; 

        end loop ; 

        i := i +1 ;
 
        exit when is_last_element (My_messages, My_Iterator2 );

        next_element (My_messages, My_Iterator2);
	
	 
        end loop;
        put_Line ("======-----*****------======") ;


   end display_used_links ; 





end noc_analysis;
