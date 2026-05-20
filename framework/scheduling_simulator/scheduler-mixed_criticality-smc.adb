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
--    $Rev: 3520 $
--    $Date: 2020-07-23 12:44:45 +0200 (Thu, 23 Jul 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with scheduler;           use scheduler;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with scheduler.fixed_priority;     use scheduler.fixed_priority;
with scheduler.fixed_priority.hpf; use scheduler.fixed_priority.hpf;
with Text_IO;                      use Text_IO;
with debug;                        use debug;

package body scheduler.mixed_criticality.smc is

   procedure initialize
     (a_scheduler : in out mixed_criticality_smc_scheduler)
   is
   begin
      reset (a_scheduler);
      a_scheduler.parameters.scheduler_type := mixed_criticality_smc_protocol;
   end initialize;

   function copy
     (a_scheduler : in mixed_criticality_smc_scheduler)
      return generic_scheduler_ptr
   is
      ptr : mixed_criticality_smc_scheduler_ptr;

   begin

      ptr := new mixed_criticality_smc_scheduler;

      ptr.parameters         := a_scheduler.parameters;
      ptr.previously_elected := a_scheduler.previously_elected;

      return generic_scheduler_ptr (ptr);

   end copy;

   procedure check_before_scheduling
     (my_scheduler   : in mixed_criticality_smc_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

   begin
      null;
   end check_before_scheduling;

   procedure specific_scheduler_initialization
     (my_scheduler       : in out mixed_criticality_smc_scheduler;
      si                 : in out scheduling_information;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      my_tasks           : in out tasks_set;
      my_schedulers      : in     scheduler_table;
      my_resources       : in out resources_set;
      my_buffers         : in out buffers_set;
      my_messages        : in     messages_set;
      msg                : in out Unbounded_String)
   is

   begin
      null;
   end specific_scheduler_initialization;

   procedure do_election
     (my_scheduler       : in out mixed_criticality_smc_scheduler;
      si                 : in out scheduling_information;
      result             : in out scheduling_sequence_ptr;
      msg                : in out Unbounded_String;
      current_time       : in     Natural;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      core_name          : in     Unbounded_String;
      options            : in     scheduling_option;
      event_to_generate  : in     time_unit_event_type_boolean_table;
      elected            : in out tasks_range;
      no_task            : in out Boolean)
   is
      highiest_priority        	: Natural       := Natural'first;
      i                        	: tasks_range   := 0;
      j                        	: tasks_range   := 0;
      stop_low			: Boolean	:= False;
      stop_medium		: Boolean	:= False;
      stop_high			: Boolean	:= False;
      a_item        		: time_unit_event_ptr;
      find			: Boolean	:= False;
      k				: Boolean	:= False;
   begin
   	
	-- main loop
	loop
		-- election loop
		i := 0;
		loop
			if not si.tcbs (i).already_run_at_current_time and not si.tcbs(i).suspended
			then
	    			if (si.tcbs (i).tsk.cpu_name = processor_name) and
	      				((address_space_name = To_Unbounded_String ("")) or
	       				(address_space_name = si.tcbs (i).tsk.address_space_name))
	    			then
			       	if
				 ((si.tcbs (i).tsk.core_name = To_Unbounded_String ("")) or
				  (si.tcbs (i).tsk.core_name = core_name))
			       	then			 
						if check_core_assignment (my_scheduler, si.tcbs (i)) 
						then
					     		if (si.tcbs (i).wake_up_time <= current_time) and
					       		(Natural(mixed_criticality_tcb_ptr (si.tcbs (i)).tsk.priority) > highiest_priority) and
					       		(si.tcbs (i).rest_of_capacity /= 0)
					     		then					     				

								if (options.with_jitters = False) or (si.tcbs (i).is_jitter_ready)
								then									  				

						   			if (options.with_offsets = False) or check_offset (si.tcbs (i), current_time)
						   			then					

						      				if (options.with_precedencies = False) or check_precedencies(si,current_time,si.tcbs (i))
						      				then						    
							    				highiest_priority := Natural(mixed_criticality_tcb_ptr (si.tcbs (i)).tsk.priority);
							    				elected := i;
							    				
						      				end if;
						   			end if;
								end if;
					     		end if;
					  	end if;
			       	end if;
			    	end if;
			end if;
		i := i + 1;
		exit when si.tcbs (i) = null;
		end loop;
		
		if highiest_priority = Natural'first then
			no_task := True;
		else
			
			no_task := False;
		 
			-- Verifiy if the current task exceed its computing budget
			-- Check if we are in LO mode
			if (my_scheduler.state = Low_Criticality)
		 	then
		 		-- We check if a low WCET of a task exceed its time
		 		if mixed_criticality_tcb_ptr( si.tcbs (elected)).completion_time + 1> 
		 		mixed_criticality_tcb_ptr (si.tcbs (elected)).tsk.capacities.entries(0).values_eu and mixed_criticality_tcb_ptr( si.tcbs (elected)).rest_of_capacity /= 0 and not mixed_criticality_tcb_ptr(si.tcbs (elected)).suspended and not mixed_criticality_tcb_ptr( si.tcbs (elected)).is_execution_continue
				then
					-- mode change
					--put_line("capacity : "&mixed_criticality_tcb_ptr (si.tcbs (elected)).current_capacities.entries(0).values_eu'img);
					--put_line("time : "&current_time'img);
					--put_line("AMC mode change LOW -> ME! ");

					if si.tcbs (elected).tsk.criticality = 0
					then
						si.tcbs (elected).suspended := True;
						highiest_priority := Natural'first;
					else
						mixed_criticality_tcb_ptr( si.tcbs (elected)).is_execution_continue := True;
					end if;
					
					-- count the number of change mode
					produce_mode_change(my_scheduler,
					   options, si, a_item, 0, 1);
					add (result.all, current_time, a_item);
					
					-- stop Low execution
			 		stop_low := True;         
			 		
			 		-- change variable values
					my_scheduler.state := Medium_Criticality;
					my_scheduler.is_change_mode := True;
										
		 		else
		 			-- elected task is good
		 			find := true;
		 		end if;
		 	
		 	-- We check if we are in ME mode
			elsif (my_scheduler.state = Medium_Criticality)
			then 
		 		if (mixed_criticality_tcb_ptr(si.tcbs (elected)).completion_time + 1 > 
		 		mixed_criticality_tcb_ptr(si.tcbs (elected)).tsk.capacities.entries(1).values_eu) and mixed_criticality_tcb_ptr( si.tcbs (elected)).rest_of_capacity /= 0 and not mixed_criticality_tcb_ptr(si.tcbs (elected)).suspended and not mixed_criticality_tcb_ptr( si.tcbs (elected)).is_execution_continue
				then
					-- mode change
					--put_line("time : "&current_time'img);
					--put_line("AMC mode change ME -> HI! ");
					
					if si.tcbs (elected).tsk.criticality = 1
					then
						si.tcbs (elected).suspended := True;
						highiest_priority := Natural'first;
					else
						mixed_criticality_tcb_ptr( si.tcbs (elected)).is_execution_continue := True;
					end if;

					
					-- count the number of change mode
					produce_mode_change(my_scheduler,
					   options, si, a_item, 1, 2);
					add (result.all, current_time, a_item);
					
					-- stop Low execution
			 		stop_medium := True;         
			 		
			 		-- change variable values
					my_scheduler.state := High_Criticality;
					my_scheduler.is_change_mode := True;
					mixed_criticality_tcb_ptr(si.tcbs (elected)).completion_time := 0;
		 		else
		 			find := true;
		 		end if;
		 	
		 	-- We check if we are in HI mode
			elsif (my_scheduler.state = High_Criticality)
		 	then
		 		if (mixed_criticality_tcb_ptr(si.tcbs (elected)).completion_time + 1 > 
		 		mixed_criticality_tcb_ptr(si.tcbs (elected)).tsk.capacities.entries(2).values_eu) and mixed_criticality_tcb_ptr( si.tcbs (elected)).rest_of_capacity /= 0 and not mixed_criticality_tcb_ptr(si.tcbs (elected)).suspended and not mixed_criticality_tcb_ptr( si.tcbs (elected)).is_execution_continue
				then
					-- mode change 
			    		-- go to Fail state
			    		if not si.tcbs (elected).suspended then
						put_line("AMC mode change HI -> FAIL ! ");
					end if;
					si.tcbs (elected).suspended := True;
					
					-- stop high execution
					stop_high := True;
			    		my_scheduler.is_change_mode := True;	    				
		 		else
		 			find := true;
		 		end if;
		 	end if;
		
			-- suspend LO,ME or HI tasks
			if stop_low or stop_medium or stop_high
			then
				i := 0;
				loop
					if si.tcbs(i).tsk.criticality = 0 and stop_low
					then
						si.tcbs(i).suspended := True;
					elsif si.tcbs(i).tsk.criticality = 1 and stop_medium
					then
						si.tcbs(i).suspended := True;
					elsif si.tcbs(i).tsk.criticality = 2 and stop_high
					then
						si.tcbs(i).suspended := True;
					end if;	
					i := i + 1;
					exit when si.tcbs (i) = null;
				end loop;
				stop_low := False;
				stop_medium := False;		
			end if;
		


			-- During a mode change
			if (my_scheduler.is_change_mode)
			then
				j := 0;
				loop		
					-- Used the next criticality capacities
					if j /= elected
					then
						-- ME
						if my_scheduler.state = Medium_Criticality 
						then							
							-- check tasks not yet activated
							if mixed_criticality_tcb_ptr(si.tcbs(j)).current_capacities.entries(0).values_eu = si.tcbs(j).rest_of_capacity
							   and not si.tcbs(j).suspended					
							then
								si.tcbs(j).rest_of_capacity := mixed_criticality_tcb_ptr(si.tcbs(j)).current_capacities.entries(1).values_eu;
								
							end if;
						-- HI
						elsif my_scheduler.state = High_Criticality 
						then
							if mixed_criticality_tcb_ptr(si.tcbs(j)).current_capacities.entries(1).values_eu = si.tcbs(j).rest_of_capacity
							   and not si.tcbs(j).suspended
							then
								si.tcbs(j).rest_of_capacity := mixed_criticality_tcb_ptr(si.tcbs(j)).current_capacities.entries(2).values_eu;
								
							end if;
						end if;
					end if;
					j := j + 1;
					exit when si.tcbs (j) = null;
				end loop;	
				my_scheduler.is_change_mode := False;	
			end if;
		end if;
	exit when find or no_task;
	end loop;	

	-- increment the number of time units executed by the task
	if not no_task
	then
		mixed_criticality_tcb_ptr( si.tcbs (elected)).completion_time := mixed_criticality_tcb_ptr (si.tcbs (elected)).completion_time + 1;
	end if;
      put_debug ("Call Do_Election: SMC : Elected : " & elected'img);
   end do_election;

end scheduler.mixed_criticality.smc;
