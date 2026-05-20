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
with Find_successors   ;    use Find_successors; 
 
package body Blevel is

  -----------------------------
  -- subprograms --
  -----------------------------


  --------------------------------------------------------------
  --  There are 3 tables :     			   -------------
 
  --- 1. Capacity_table : Capacity of each task    -------------
  --- 2. Task_table     : name of each task        -------------
  --- 3. Blevel 	: blevel of each task      -------------

  --- Task_table(1)        : the name of the entry task    -----
  --- Task_table(nbr_task) : the name of exit task  	   -----
															
  --- Capacity(blevel) _table(1)        : the capacity     -----
  --- (blevel) of the entry task  			   -----
  --- Capacity(blevel) _table(nbr_task) : the capacity     -----
  --- (blevel) of exit task			           -----
  --------------------------------------------------------------	



  procedure compute_blevel  (       My_tasks			    : in Tasks_set   ;
			            nbr_task			    : in out integer ;
				    Capacity_table                  : in out Integer_Table; 
				    tasks_name_table                : in out String_Table; 
			            blevel                          : in out Integer_Table;     
			            My_messages	                    : in Messages_Set  ; 
			            My_Dependencies                 : in Tasks_Dependencies_Ptr  
  				       )  
  
  is

	
  i, i1, i5, j, Rang_Successors_tasks_table_size, max	: integer          ; 
  My_Iterator1          				: Tasks_Iterator   ; 
  a_task, My_task 					: Generic_Task_Ptr ; 
  Successors_tasks, empty      				: Tasks_set        ;
  Rang_Successors_tasks_table, empty_table		: Integer_Table    ; 

  begin
									--------------------------------
									-----  Compute the       -------
									-----  Capacity_table    -------
									--------------------------------
									
  i := 1 ; 

  if not is_empty (My_tasks) then

    reset_iterator (My_tasks, My_Iterator1);
	 
    loop

  	current_element  (My_tasks, a_task,     My_Iterator1);

  	Capacity_table(i) := a_task.capacity; 
        tasks_name_table(i)      := a_task.name ; 

   	exit when is_last_element (My_tasks, My_Iterator1);	     
 
 	next_element (My_tasks, My_Iterator1);
 
 	i := i +1 ; 

    end loop ; 
  
    nbr_task := i ; 

  end if ; 
									--------------------------------
									-----  Compute the       -------
									-----  blevel            -------
									--------------------------------

  j := nbr_task-1 ;  
  blevel(nbr_task) := Capacity_table(nbr_task) ;                        --- blevel of exit_task   ------


  for i in 1 .. nbr_task-1 loop
       
        Rang_Successors_tasks_table_size := 0 ; 
        max 				 := 0 ; 
        Successors_tasks                 := empty ;
        Rang_Successors_tasks_table	 := empty_table ;  

         
        --put(To_String(tasks_name_table(i) )) ; 
       
        My_task :=  Search_Task (My_tasks, Suppress_Space (tasks_name_table(i))) ;


        find_successors_task (  My_task			            => My_task,  
				My_tasks			    => My_tasks,
			        nbr_task			    => nbr_task,				    
			        My_messages	                    => My_messages,  
			        My_Dependencies                     => My_dependencies,  
				Successors_tasks                    => Successors_tasks,
                                Rang_Successors_tasks_table         => Rang_Successors_tasks_table,
 				Rang_Successors_tasks_table_size    => Rang_Successors_tasks_table_size
			       ); 
    
	

        
        
        -- if      Rang_Successors_tasks_table_size = 0  then 
	--	   max  := 0 ; 
        -- end if ; 



         if     Rang_Successors_tasks_table_size = 1  then 
		   max  := blevel( Rang_Successors_tasks_table(1) )  ; 
         end if ; 
 


         if  Rang_Successors_tasks_table_size > 1  then 
            
            for i1 in 1 ..  Rang_Successors_tasks_table_size loop 
            
		if blevel( Rang_Successors_tasks_table(i1) ) > max then 
		max :=  blevel( Rang_Successors_tasks_table(i1) ) ; 
		end if ; 

            end loop ; 

	 end if; 
          


	  blevel(j) := Capacity_table(j) + max   ; 

       

	  j := j - 1 ;  	



  end loop;   



  end compute_blevel; 












  procedure display_blevel  (  blevel   			: in out Integer_table;
			       nbr_task			        : in out integer				
					)

  is 

  i 			: integer ; 

  begin 
 
  for i in 1 .. nbr_task loop
  
   put((blevel(i)));
   	
  end loop;   


 

  end display_blevel ; 





end Blevel ;
