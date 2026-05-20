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


package body Find_successors is

  -----------------------------
  -- subprograms --
  -----------------------------


	



  procedure find_successors_task  ( My_task			    	: in Generic_Task_Ptr ;     
				    My_tasks			   	: in Tasks_set   ;
			            nbr_task			    	: in integer ;				    
			            My_messages	                    	: in Messages_Set  ; 
			            My_Dependencies                 	: in Tasks_Dependencies_Ptr;  
				    Successors_tasks                	: in out Tasks_set;
                                    Rang_Successors_tasks_table         : in out Integer_Table;
 				    Rang_Successors_tasks_table_size    : in out integer  

				 	  
  				       )  
  
 

  is
 
  	A_Message, A_Message1   			: Generic_Message_Ptr;
	My_Iterator, My_Iterator2 			: Messages_iterator;
	My_Iterator1, My_Iterator3 			: Tasks_Dependencies_Iterator;
	A_Half_Dep  					: Dependency_Ptr;	
 	Messages					: Messages_Set  ;
        a_task1, a_task2 				: Generic_Task_Ptr ; 
	compteur1, compteur2				: integer   ; 
        My_Iterator4, My_Iterator5		        : Tasks_Iterator;
  begin
  

												---------------------------------------------------------
												----------- find Messages where the source task ---------
												-----------            is My_task              ----------
  												---------------------------------------------------------

  --put(To_String(My_task.name));

  reset_iterator (My_Messages, My_Iterator); 

  loop

    current_element (My_Messages, A_Message, My_Iterator);         

    if not is_empty (My_Dependencies.Depends) then

    reset_iterator (My_Dependencies.Depends, My_Iterator1);

    loop

       current_element  (My_Dependencies.Depends,  A_Half_Dep,  My_Iterator1);

       if (A_Message = A_Half_Dep.asynchronous_communication_dependency_object) then

           if (A_Half_Dep.asynchronous_communication_orientation = From_Task_To_Object) then 

                
              	if ( A_Half_Dep.asynchronous_communication_dependent_task = My_task) then 

             		add( Messages , A_Message);
	                
                end if ; 

            end if ; 

        end if ; 
	
    exit when is_last_element (My_Dependencies.Depends, My_Iterator1);

    next_element (My_Dependencies.Depends, My_Iterator1);

    end loop;

    end if;
	      
   exit when is_last_element (My_Messages, My_Iterator);
 
   next_element (My_Messages, My_Iterator);

   end loop;


												---------------------------------------------------------
												----------- find destination tasks  of          ---------
												-----------            Messages                 ---------
												---------------------------------------------------------

  if not is_empty (Messages) then

  reset_iterator (Messages, My_Iterator2); 

  loop

    current_element (Messages, A_Message1, My_Iterator2);         

    if not is_empty (My_Dependencies.Depends) then

    reset_iterator (My_Dependencies.Depends, My_Iterator3);

    loop

       current_element  (My_Dependencies.Depends,  A_Half_Dep,  My_Iterator3);

       if (A_Message1 = A_Half_Dep.asynchronous_communication_dependency_object) then

           if (A_Half_Dep.asynchronous_communication_orientation = From_Object_To_Task) then 

               add( Successors_tasks , A_Half_Dep.asynchronous_communication_dependent_task);
                

            end if ; 

        end if ; 
	
    exit when is_last_element (My_Dependencies.Depends, My_Iterator3);

    next_element (My_Dependencies.Depends, My_Iterator3);

    end loop;

    end if;

	      
   exit when is_last_element (Messages, My_Iterator2);
 
   next_element (Messages, My_Iterator2);

   end loop;


  end if ; 



												---------------------------------------------------------
												----------- compute Rang_Successors_tasks_table ---------
												----------- and Rang_Successors_tasks_table_size---------
												---------------------------------------------------------
	
    compteur1 := 0 ;

    if not is_empty (Successors_tasks) then
              

	    compteur1 := 1 ; 

	    reset_iterator (Successors_tasks, My_Iterator4);

	    loop 
		current_element  (Successors_tasks , a_task1 ,     My_Iterator4)   ;
	 
		compteur2 := 1 ; 

		reset_iterator (My_tasks, My_Iterator5);

		loop 

			current_element  (My_tasks , a_task2 ,     My_Iterator5)   ;    

		        if a_task1.name = a_task2.name  then 
			
			Rang_Successors_tasks_table(compteur1) := compteur2 ; 

			end if  ; 
		
			compteur2 := compteur2 + 1 ; 

		        exit when is_last_element (My_tasks, My_Iterator5 );

		        next_element (My_tasks      , My_Iterator5)      ;
		         
		end loop ; 


	   
	   exit when is_last_element (Successors_tasks, My_Iterator4 );

	   compteur1 := compteur1 + 1 ; 

	   next_element (Successors_tasks, My_Iterator4)      ;
		 
	   end loop;

	    


  end if ; 

  Rang_Successors_tasks_table_size := compteur1  ;


  end find_successors_task; 


















end Find_successors ;
