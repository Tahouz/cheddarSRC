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

with translate;           use translate;
with unbounded_strings;   use unbounded_strings;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with qs_tools;       use qs_tools;
with Text_IO; use Text_IO;
with systems; use systems;
with debug;                             use debug;
with Core_Units;
use Core_Units;
use Core_Units.Core_Units_Table_Package;



package body scheduler.mixed_criticality is

   function build_tcb
     (my_scheduler : in mixed_criticality_scheduler;
      a_task       :    generic_task_ptr) return tcb_ptr
   is
      a_tcb : mixed_criticality_tcb_ptr;
   begin
      a_tcb := new mixed_criticality_tcb;
      initialize (tcb (a_tcb.all), a_task);
      initialize (a_tcb.all);
      return tcb_ptr (a_tcb);
   end build_tcb;
   
   function compute_HI_tasks
   (si	: in scheduling_information
   ) return Natural
   is
   	i :	tasks_range	:= 0;
   	nb :	Natural	:=0;
   begin
	loop
		if si.tcbs (i).tsk.criticality = 2 then
			nb := nb + 1;
		end if;
		i := i + 1;
	exit when si.tcbs (i) = null;
	end loop;
	return nb;
   end compute_HI_tasks;

   procedure initialize (a_tcb : in out mixed_criticality_tcb) is
   	temp_capacity : Natural;
   	seed	      : Generator;
   begin
      reset (seed,a_tcb.tsk.seed);
      a_tcb.is_execution_continue := False;
      a_tcb.current_quality_exit := a_tcb.tsk.qualities.entries(0).values_eu;
     
      a_tcb.current_capacities.nb_entries := 3;
      a_tcb.current_capacities.entries(0) := new execution_unit;
      a_tcb.current_capacities.entries(1) := new execution_unit;
      a_tcb.current_capacities.entries(2) := new execution_unit;
      
      a_tcb.q_improvement_protocol := a_tcb.tsk.qualities.entries(1).values_eu;
      
       
      a_tcb.current_capacities.entries(0).values_eu := a_tcb.tsk.capacities.entries(0).values_eu;  
      a_tcb.current_capacities.entries(1).values_eu := a_tcb.tsk.capacities.entries(1).values_eu;  
      a_tcb.current_capacities.entries(2).values_eu := a_tcb.tsk.capacities.entries(2).values_eu;
      
      a_tcb.current_dc_value := a_tcb.tsk.capacity;
      a_tcb.current_I_LO_value := a_tcb.tsk.capacities.entries(0).values_eu - a_tcb.current_dc_value;
      a_tcb.current_I_HI_value := a_tcb.current_capacities.entries(2).values_eu - a_tcb.current_dc_value;
      
      -- Compute E value
      temp_capacity := Box_Muller_Normal2(a_tcb.tsk.capacity,a_tcb.tsk.capacities.entries(2).values_eu,seed);
      a_tcb.rest_of_capacity := Natural'Max(1,temp_capacity); 
          
      put_debug("execution time between "&a_tcb.tsk.capacity'img&" and"&a_tcb.tsk.capacities.entries(2).values_eu'img&", results ="&a_tcb.rest_of_capacity'img,Minimal);
       
      Save(seed,a_tcb.task_seed);  
   end initialize;

   procedure check_before_scheduling
     (my_scheduler   : in mixed_criticality_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

   begin
      null;
   end check_before_scheduling;

   procedure specific_scheduler_initialization
     (my_scheduler       : in out mixed_criticality_scheduler;
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
     (my_scheduler       : in out mixed_criticality_scheduler;
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
   begin
      null;
   end do_election;

   function check_task_activiy_multicore
   (	si			: in scheduling_information;
 	my_scheduler		: in mixed_criticality_scheduler; 
	address_space_name     : in Unbounded_String;
	processor_name 	: in Unbounded_String;
	current_time		: in Natural;
	options	 	: in scheduling_option;
	targeted_task		: in tasks_range;
	cores			: in core_units_table)return Boolean
   is
   	i 			: tasks_range	:= 0;
	elected		: tasks_range;     
        highiest_priority 	: Natural := Natural'first;
        core_name		: Unbounded_String;
   begin
   	-- loop on the core set
	for j in 0 .. cores.nb_entries - 1 loop
		core_name := cores.entries(j).name;
		
		i:=0;
		highiest_priority := Natural'first;
		
		-- loop on the task set
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
							    				put_debug("find task"&elected'img,Minimal);
							    				
							    				if elected = targeted_task and highiest_priority /= Natural'first then
												return True;
										   	end if;
							    								    				
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
	end loop;
	
	if elected = targeted_task and highiest_priority /= Natural'first then
		return True;
   	else
   		return False;
   	end if;
   
   end check_task_activiy_multicore;
   
   
   procedure find_elected_task
	(si			: in out scheduling_information;
	 my_scheduler		: in out mixed_criticality_scheduler; 
	 core_name		: in Unbounded_String;
	 address_space_name    : in Unbounded_String;
	 processor_name 	: in Unbounded_String;
	 current_time		: in Natural;
	 options	 	: in scheduling_option;
	 highiest_priority 	: in out Natural;
	 elected 		: in out tasks_range;
	 result                : in out scheduling_sequence_ptr;
	 first_execution	: in out boolean)
   is
	i 			: tasks_range	:= 0;
	elected_task		: mixed_criticality_tcb_ptr;
	nb_cores		: Natural;
	the_cores        	: core_units_table;
        a_processor     	: generic_processor_ptr;
        current_core		: Natural;
        is_ftp_protocol_end	: Boolean	:= False;
   begin
   
   	
   	-- we retrieve the protocol
	my_scheduler.recovery_protocol := si.tcbs(0).tsk.qualities.entries(2).values_eu;
	
	loop
		if si.tcbs(i).wake_up_time > 0 and (current_time  = si.tcbs(i).wake_up_time) and si.tcbs (i).tsk.criticality = 0 and si.state = High_Criticality and first_execution
		then
	    			put_debug("LO job "&si.tcbs(i).activation'img&" from task "&i'img&" lost at release time:"&si.tcbs(i).wake_up_time'img ,Minimal);

	    			-- LO tasks are not activated in critical mode, but their next release is computed.
	    			compute_next_task_activation(my_scheduler,si.tcbs (i),si,options,i);
	    			si.nb_LO_jobs_stopped := si.nb_LO_jobs_stopped + 1;
	    			
	    			--*********** Bailout protocol ***************
				-- 6. LO tasks who should be released donated a budget of C(LO) to the BF	
				if my_scheduler.recovery_protocol = 3 and si.bp_bailout_mode then
					put_debug("[BAILOUT MODE] LO job "&si.tcbs(i).activation'img&" lost at release time:"&si.tcbs(i).wake_up_time'img&" BF before:"&si.bp_fund'img ,Minimal);
		    			si.bp_fund := si.bp_fund - mixed_criticality_tcb_ptr(si.tcbs(i)).current_capacities.entries(0).values_eu;
		    			put_debug("[BAILOUT MODE] BF after:"&si.bp_fund'img, Minimal);
		    			
		    		elsif my_scheduler.recovery_protocol = 3 and si.bp_recovery_mode then			
			
					if si.tcbs(i).wake_up_time > 0 and (current_time+1  = si.tcbs(i).wake_up_time) and si.tcbs (i).tsk.criticality = 0
					then
			    			put_debug("[RECOVERY MODE] LO job "&si.tcbs(i).activation'img&" lost at release time:"&si.tcbs(i).wake_up_time'img ,Minimal);
					end if;
		    		end if;				
		end if;
		
		-- quality improvement
		if my_scheduler.state = Low_Criticality then
			if mixed_criticality_tcb_ptr(si.tcbs (i)).q_improvement_protocol = 2 then
				if mixed_criticality_tcb_ptr(si.tcbs (i)).q_ftp_end and mixed_criticality_tcb_ptr(si.tcbs (i)).q_ftp_time = current_time then
					-- Let the task come back with quality of step
					compute_task_quality_improvement(mixed_criticality_tcb_ptr(si.tcbs (i)),si);
					mixed_criticality_tcb_ptr(si.tcbs (i)).q_ftp_end := False;
					mixed_criticality_tcb_ptr(si.tcbs (i)).q_ftp_launch := False;
					put_debug("quality improvement at time"&current_time'img,Minimal);
				end if;
			elsif mixed_criticality_tcb_ptr(si.tcbs (i)).q_improvement_protocol = 3 then
				if mixed_criticality_tcb_ptr(si.tcbs (i)).q_bailout_time = current_time and mixed_criticality_tcb_ptr(si.tcbs (i)).q_bailout_launch then
					compute_task_quality_improvement(mixed_criticality_tcb_ptr(si.tcbs (i)),si);
					mixed_criticality_tcb_ptr(si.tcbs (i)).q_bailout_launch := False;
					mixed_criticality_tcb_ptr(si.tcbs (i)).q_bailout_fund := 0;
					put_debug("quality improvement at time"&current_time'img,Minimal);
				end if;
			end if;
		end if;
		
		
		
		
		
		
		
		
		
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
				       		(Natural(mixed_criticality_tcb_ptr(si.tcbs (i)).tsk.priority) > highiest_priority) and
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
	
	i:=0;
		
	
	
	
	-- FTP protocol	
	------------------------------------------------------------------
	-- Multicore Case
	-- We get the number of cores
	a_processor	:= search_processor (si.processors, processor_name);
	the_cores	:= build_core_table (a_processor);
	current_core	:= search_core_number(the_cores,core_name);
	nb_cores	:= Natural(the_cores.nb_entries);
	
	--initialize the list
	initialize_cores_list(my_scheduler.cores_list,nb_cores);
	------------------------------------------------------------------
	elected_task := mixed_criticality_tcb_ptr(si.tcbs (elected));
	
	
	-- set the activity of the task
	if highiest_priority /= Natural'first then
		elected_task.is_active := True;
	end if;
	
	
	if my_scheduler.recovery_protocol = 2 and si.ftp_launch and not my_scheduler.FTP_retry then	
		------------------------------------------------- 
		---- the last task have finished is execution ---
		-------------------------------------------------
		if si.ftp_completion_time_of_current_task = current_time then
			si.ftp_completion_time_of_current_task := 0;
			my_scheduler.nb_tasks_without_overrun := my_scheduler.nb_tasks_without_overrun + 1;
			put_debug("=================> FTP1: task "&si.highest_priority_HItask'img &" execution ending at:"&current_time'img&" on core"&current_core'img&" at time"&current_time'img,Minimal);
						
			-- compute the next task to verify
			si.highest_priority_HItask := searches_next_task_to_executed_in_ftp(si,Natural(mixed_criticality_tcb_ptr(si.tcbs(si.highest_priority_HItask)).tsk.priority),elected,
			my_scheduler,address_space_name,processor_name,current_time,options,the_cores);
			if si.highest_priority_HItask = 0 then
				put_debug("=================> FTP1: No task active",Minimal);
				is_ftp_protocol_end := True;
			else 
				put_debug("=================> FTP1: The next task to wait is "&si.highest_priority_HItask'img,Minimal);
			end if;
			
		--------------------------------------
		-------- During task execution -------
		--------------------------------------
		elsif  si.highest_priority_HItask = elected or mixed_criticality_tcb_ptr( si.tcbs (si.highest_priority_HItask)).completion_time /= 0 then
			------------------------------------------------- 
			--- the waited task will finish his execution ---
			-------------------------------------------------
			if mixed_criticality_tcb_ptr( si.tcbs (si.highest_priority_HItask)).rest_of_capacity-1 = 0  then
				si.ftp_completion_time_of_current_task := current_time + 1;								
			end if;
			

			
		---------------------------------------------
		-------- task execution on other core -------
		---------------------------------------------	
		
		-- if we are on the same core that the one we search
		
		elsif  core_name = mixed_criticality_tcb_ptr( si.tcbs (si.highest_priority_HItask)).tsk.core_name or nb_cores = 1 then
				
			-------------------------------------------------------
			-- The highest priority task is not the elected one ---
			-------------------------------------------------------
				elected_task := mixed_criticality_tcb_ptr( si.tcbs (si.highest_priority_HItask));
				put_debug("=================> FTP2: task"&si.highest_priority_HItask'img&" is not active at "&current_time'img& " on core:"&current_core'img,Minimal);
				si.highest_priority_HItask := searches_next_task_to_executed_in_ftp(si,Natural(elected_task.tsk.priority),elected,
				my_scheduler,address_space_name,processor_name,current_time,options,the_cores);
				
				-- 0 means that no HI task is there
				if si.highest_priority_HItask = 0 then
					-- Recovery mode		
					do_recovery_mode(my_scheduler,options,si,result,current_time,High_Criticality,Low_Criticality);
					put_debug("=================> FTP2: protocol ending compute, HI to LO, time : "&current_time'img&" core: "&current_core'img,Minimal);
					my_scheduler.nb_tasks_without_overrun := 0;
					si.ftp_launch:= False;
					my_scheduler.FTP_retry := False;
				else
					put_debug("=================> FTP2: The next task to wait is "&si.highest_priority_HItask'img& " on core:"&current_core'img,Minimal);
					
					-- if the next task have only 1 time unit of execution
					if mixed_criticality_tcb_ptr( si.tcbs (si.highest_priority_HItask)).rest_of_capacity - 1 = 0 then
						si.ftp_completion_time_of_current_task := current_time + 1;
					end if;
				end if;	
		end if;
				
		------------------------------------------------- 	
		----------------- FTP protocol ending ---------------
		-------------------------------------------------
		if si.nb_HI_tasks = my_scheduler.nb_tasks_without_overrun or is_ftp_protocol_end then 
			-- Recovery mode		
			do_recovery_mode(my_scheduler,options,si,result,current_time,High_Criticality,Low_Criticality);
			put_debug("=================> FTP: protocol ending compute: HI to LO, time : "&current_time'img&" core: "&current_core'img,Minimal);
			my_scheduler.nb_tasks_without_overrun := 0;
			si.ftp_launch := False;
			my_scheduler.FTP_retry := False;
			is_ftp_protocol_end := False;		
		end if;
	end if;
	
	if my_scheduler.recovery_protocol = 2 and si.ftp_launch and not my_scheduler.FTP_retry then 
		
		if nb_cores /= 1 then
			if highiest_priority = Natural'first then
				set_cores_activity(my_scheduler.cores_list,current_core,False);
			end if;
			
			if check_cores_verify(my_scheduler.cores_list,current_core) then				
				if not check_cores_activities(my_scheduler.cores_list,current_core) then
					-- Recovery mode		
					do_recovery_mode(my_scheduler,options,si,result,current_time,High_Criticality,Low_Criticality);
					put_debug("=================> FTP protocol multicore : no active tasks => HI to LO, time : "&current_time'img,Minimal);
					my_scheduler.nb_tasks_without_overrun := 0;
					si.ftp_launch := False;
					my_scheduler.FTP_retry := False;
				end if;
			end if;			
		else
			if highiest_priority = Natural'first then
				-- Recovery mode		
				do_recovery_mode(my_scheduler,options,si,result,current_time,High_Criticality,Low_Criticality);
				put_debug("=================> FTP protocol monocore : no active tasks => HI to LO, time : "&current_time'img,Minimal);
				my_scheduler.nb_tasks_without_overrun := 0;
				si.ftp_launch := False;
				my_scheduler.FTP_retry := False;
			end if;
		end if;
	end if;
	
	
	--**************************************************************************
	--************* RECOVERY PROTOCOL MODE CHANGE FROM TIME PARAMETER **********
	--**************************************************************************
	
	-- Bailout protocol : Bailout mode to recovery mode
	if my_scheduler.recovery_protocol = 3 and current_time /= 0 then
		
		if si.bp_time_recovery = current_time  then
			-- A. Lowest priority JK HI job saved
			si.bp_jk_job := find_lowest_priority_HItask(si);			
			si.bp_recovery_mode := True;
			si.bp_bailout_mode := False;			
			si.bp_time_recovery := 0;
			si.bp_fund := 0;
			reset_loan(si);
			put_debug("[RECOVERY MODE] Recovery mode at time : "&current_time'img& " with lowest priority task : "&si.bp_jk_job'img,Minimal);
			
			
		
		-- Bailout protocol : recovery mode to normal mode
		elsif si.bp_time_mode_change = current_time then
			-- Recovery mode		
			do_recovery_mode(my_scheduler,options,si,result,current_time,High_Criticality,Low_Criticality);
			put_debug("[RECOVERY MODE] recovery mode ending : HI to LO, time : "&current_time'img,Minimal);
			si.idle_launch := False;
			si.bp_bailout_mode := False;
			si.bp_time_mode_change := 0;
			si.bp_recovery_mode := False;
			i:= 0;
			reset_loan(si);	
		end if;
	end if;
			
	
	--***************************************************
	--******************* IDLE TIME PROTOCOL ************
	--***************************************************
	if (my_scheduler.recovery_protocol = 1 or (my_scheduler.recovery_protocol = 3 and not si.bp_recovery_mode)) and si.idle_launch then	
		-- Condition to switch from HI to LO mode
		if highiest_priority = Natural'first and si.state = High_Criticality 
		then
			-- Recovery mode		
			do_recovery_mode(my_scheduler,options,si,result,current_time,High_Criticality,Low_Criticality);
			put_debug("[IDLE TIME] : HI to LO, time : "&current_time'img,Minimal);
			si.idle_launch := False;
			i:= 0;
			
			si.bp_fund := 0;
			si.bp_elected_task := 0;
			si.bp_bailout_mode := False;
			si.bp_recovery_mode := False;
			si.bp_time_recovery := 0;
			si.bp_time_mode_change := 0;
			reset_loan(si);

		end if;
	end if;	
		
		
	--------------------------------------------------------
	--------------- CONDITION TO QUALITY IMPROVEMENT--------
	--------------------------------------------------------
	if my_scheduler.state = Low_Criticality then
		case elected_task.q_improvement_protocol is
		
			-- Condition IDLE TIME => SYSTEM
			when 1 =>
				-- if a idle time occurs
				if highiest_priority = Natural'first
				then
					-- Let the tasks come back with quality of step
					-- improve quality of all task from step 
					-- function(), check before to improvement that quality is not on max
					compute_system_quality_improvement(si);
					
				end if;

			when others => 
				null;
		end case;
	end if;										
				
	if elected_task.rest_of_capacity-1 = 0 then
		elected_task.is_active := False;
	end if;	
	
   end find_elected_task;
	


   procedure do_recovery_mode
   	(my_scheduler       : in out mixed_criticality_scheduler; 
      options            : in scheduling_option;
      si                 : in out scheduling_information; 
      result             : in out scheduling_sequence_ptr;
      current_time       : in     Natural;
      from_mode 	  : in mode_range; 
      to_mode		  : in mode_range)
   is
   begin
	-- Change mode
	do_mode_change(my_scheduler,options,si,result,current_time,from_mode,to_mode);

	-- Reactivate LO tasks
	activate_tasks(to_mode,si,my_scheduler,options);
	
   end do_recovery_mode;
   
   
   -- function to calculate the system quality "sq" based on the definition of: 
   -- the system quality is the sum of the quality obtained by a task when 
   -- it has finished its execution correctly.
   procedure compute_quality
	(elected_task		: in mixed_criticality_tcb_ptr;
	 my_scheduler       : in out mixed_criticality_scheduler)
   is
   begin
	
   	-- Check if they rest 1 of capacity for the elected task
   	if elected_task.rest_of_capacity = 1 and not elected_task.suspended then
   	
   		-- We'll only take LO tasks into account.
   		if elected_task.tsk.criticality = 0 then
   			my_scheduler.quality_system := my_scheduler.quality_system + elected_task.current_quality_exit;
   		end if;
   	end if;
   end compute_quality;
   
   -- function to calculate the quality of the task based on the definition of: 
   -- the sum of the qualities achieved by a task
   procedure compute_task_quality
   	(elected_task	: in mixed_criticality_tcb_ptr;
	 find		: in Boolean;
	 my_scheduler	: in out mixed_criticality_scheduler)
   is
   begin
	
   	-- Check if they rest 1 of capacity for the elected task and the task is not in overrun 
   	-- with find variable
   	if elected_task.rest_of_capacity = 1 and not elected_task.suspended  and find then   	
   		-- The execution of the task is counted compared to its quality
   		elected_task.quality_task := elected_task.quality_task + elected_task.current_quality_exit;   		
   	end if;
   end compute_task_quality;
   
   -- function to display each values of quality task
   procedure display_quality_task
   	( si	: 	in scheduling_information)
   is
   	i : tasks_range := 0;
   begin
   	loop
   		if si.tcbs (i).tsk.criticality = 0 then
   			put_debug("task "&i'img&" have sum of quality of:"&mixed_criticality_tcb_ptr(si.tcbs (i)).quality_task'img,Minimal);
   		end if;
   	i := i + 1;		
	exit when si.tcbs (i) = null;
	end loop;
   end display_quality_task;
   
   
   procedure compute_missed_deadline
   	(elected_task	: in mixed_criticality_tcb_ptr;
   	 my_scheduler	: in out mixed_criticality_scheduler;
   	 current_time	: in Natural)
   is
   begin
   	if elected_task.rest_of_capacity = 0 and current_time /= elected_task.tsk.deadline and not elected_task.suspended then
   		my_scheduler.number_of_missed_deadline := my_scheduler.number_of_missed_deadline + 1;
   	end if;
   end compute_missed_deadline;

   procedure verification_of_budget_overruns
   (elected_task	: in out mixed_criticality_tcb_ptr;
    my_scheduler	: in out mixed_criticality_scheduler;
    result		: in out scheduling_sequence_ptr;
    find		: in out Boolean;
    highiest_priority	: in out Natural;
    si			: in out scheduling_information;
    options            : in scheduling_option;
    elected		: in tasks_range;
    current_time	: in Natural;
    current_mode	: in mode_range)
   is
     threshold_quality	: Integer     := my_scheduler.parameters.threshold;
     current_I		: Natural     := 0;
     current_c_lo	: Natural     := 0;
     cnt 		: Natural	:= 0;
     i			:tasks_range	:= 0;
   begin
   	-- FTP protocol
   	-- Check if the highest task and we are in retry case
	if my_scheduler.FTP_retry and elected = si.highest_priority_HItask then
		my_scheduler.FTP_retry := False;
	end if;
	
	--------------------------------------------
	-------------- OVERRUN CURRENT MODE---------
	--------------------------------------------
   	if (elected_task.completion_time + 1 > elected_task.current_capacities.entries(Execution_Units_Table_Package.table_range(current_mode)).values_eu) 
	and elected_task.rest_of_capacity /= 0 and not elected_task.suspended and not elected_task.is_execution_continue
	then
		------------------------------------------------
		----------- AMC-Quality ADAPTATION -------------
		------------------------------------------------
		if elected_task.current_quality_exit - 1 >= threshold_quality and get_name(my_scheduler) = "MIXED_CRITICALITY_QUALITY_AMC_PROTOCOL"
		   and elected_task.tsk.criticality /= 2		
		then
			put_debug("=================> Adaptation at time:"&current_time'img&" from task"&Natural(elected)'img,Minimal);
				
			my_scheduler.nb_adaptation := my_scheduler.nb_adaptation + 1;
					 	
			-- Reduce the capacity by the quality profile
			if elected_task.current_quality_exit = 2
			then
				elected_task.current_dc_value := mixed_criticality_tcb_ptr (si.tcbs (elected)).tsk.capacity * 30/100;
				 				
			elsif elected_task.current_quality_exit = 3
			then			 				 					
				elected_task.current_dc_value := mixed_criticality_tcb_ptr (si.tcbs (elected)).tsk.capacity * 50/100;			 			
			elsif elected_task.current_quality_exit = 4
			then
				elected_task.current_dc_value := mixed_criticality_tcb_ptr (si.tcbs (elected)).tsk.capacity * 70/100;		 					
			end if;
			
			
			-- quality improvement
			case elected_task.q_improvement_protocol is	
				-- Condition FTP protocol => TASK
				when 2 => 
					elected_task.q_ftp_launch := True;
				
				-- Condition BAILOUT MODE => TASK
				when 3 =>		
					if not elected_task.q_bailout_launch then
						elected_task.q_bailout_fund := elected_task.current_capacities.entries(2).values_eu - elected_task.current_capacities.entries(0).values_eu;
						put_debug("task bailout at time :"&current_time'img&" with BF :"&elected_task.q_bailout_fund'img,Minimal);
						elected_task.q_bailout_launch := True;
					else
						elected_task.q_bailout_fund := elected_task.q_bailout_fund + ( mixed_criticality_tcb_ptr(si.tcbs (elected)).current_capacities.entries(2).values_eu - mixed_criticality_tcb_ptr(si.tcbs (elected)).current_capacities.entries(0).values_eu);
						put_debug("bailout task overrun",Minimal);
					end if;      				
				when others => 
					null;
			end case;
			
			-- Reduce quality : Q(i) := Q(i-1) 
			elected_task.current_quality_exit := elected_task.current_quality_exit - 1;
			
			-- Change C(HI) values
			-- compute clo from the new E and coefficient
						
			elected_task.current_capacities.entries(0).values_eu := elected_task.current_dc_value + elected_task.current_I_LO_value;
			elected_task.current_capacities.entries(2).values_eu := elected_task.current_dc_value + elected_task.current_I_HI_value;
			
			-- lost the current LO job but degrade him after the next activation
			if elected_task.tsk.criticality /= 0
			then							
				elected_task.is_execution_continue := True;
			else
				compute_next_task_activation(my_scheduler,si.tcbs (elected),si,options,elected);
				highiest_priority := Natural'first;
				si.nb_LO_jobs_stopped := si.nb_LO_jobs_stopped +1;
			end if;
		----------------------------------------------
		--------------- MODE CHANGE ------------------
		----------------------------------------------
		else
			if elected_task.tsk.criticality /= 0 then
				put_debug("=================> Overrun at time :"&current_time'img& " from HI task "& elected'img&" with c(LO):"&elected_task.tsk.capacities.entries(0).values_eu'img&" with c(HI):"&elected_task.current_capacities.entries(2).values_eu'img,Minimal);
			else
				put_debug("=================> Overrun at time :"&current_time'img& " from LO task "& elected'img ,Minimal);
			end if;
			
			-- check if the task continue or not
			if elected_task.tsk.criticality = Natural(current_mode)
			then	
				elected_task.suspended := True;
				highiest_priority := Natural'first;			
			else
				elected_task.is_execution_continue := True;
			end if;

			do_mode_change(my_scheduler, options, si, result, current_time, current_mode, High_Criticality);

			-- If not SMC stops LO tasks
			if get_name(my_scheduler) /= mixed_criticality_smc_protocol then        
				-- stop tasks
	 			stop_tasks(current_mode,si,my_scheduler,true,options);
	 		end if; 
	 		
	 		 		
	 		--*******************************************************************
	 		--************* RECOVERY PROTOCOL MODE CHANGE FROM OVERRUN **********
	 		--*******************************************************************
	 		
	 		-- IDLE time protocol : normal mode to recovery mode
	 		if my_scheduler.recovery_protocol = 1  then
	 			put_debug("[IDLE protocol] =================> Enter in recovery mode at time :"&current_time'img,Minimal);
	 			si.idle_launch := True;	
	 		end if;
	 			
			-- FTP protocol : normal mode to recovery mode
			if my_scheduler.recovery_protocol = 2  then
				-- FTP activated
				put_debug("[FTP protocol] =================> Enter in recovery mode at time :"&current_time'img,Minimal);		
				si.ftp_launch := True;				
				si.highest_priority_HItask := find_highest_priority_HItask(si,0);
				put_debug("[FTP protocol] =================> The highest priority task find: "&si.highest_priority_HItask'img,Minimal);
				si.nb_HI_tasks := compute_nb_HI_task(si);		
			end if;
			
			-- Bailout protocol : normal mode to bailout mode
			-- 1. HI task exceeds its LO budget
			if my_scheduler.recovery_protocol = 3 and not si.bp_bailout_mode then
				-- A. Take a loan of (C(HI) - C(LO))
				-- B. Define BF = loan
				si.bp_fund := elected_task.current_capacities.entries(2).values_eu - elected_task.current_capacities.entries(0).values_eu;
				put_debug("[BAILOUT MODE] Enter in Bailout mode at time :"&current_time'img&" with BF :"&si.bp_fund'img,Minimal);
				-- save the current task
				si.bp_elected_task := elected;
				si.bp_bailout_mode := True;
				si.bp_recovery_mode := False;
				reset_loan(si);
				si.idle_launch := True;
				elected_task.bp_loan := True;
				si.bp_time_recovery := 0;
      				si.bp_time_mode_change := 0;
      				-- check if the task continue or not
				if elected_task.tsk.criticality = 2
				then
      					find := true;
      				end if;														
			end if;					
		end if;
		
	----------------------------------------------
	---------------- NO OVERRUN ------------------
	----------------------------------------------
		
	else		
		-- the selected task can be executed
		find := true;						
		--******************************************************
 		--************* RECOVERY PROTOCOL ENDING TASKS *********
 		--******************************************************
 				
		-- Bailout protocol : bailout mode
		if my_scheduler.recovery_protocol = 3 and si.bp_bailout_mode then			
			-- NO OVERRUN HI task: 
			-- 3. HI tasks ending execution with e time, e < C(LO)
			
			if (elected_task.completion_time + 1 <= elected_task.current_capacities.entries(0).values_eu) and mixed_criticality_tcb_ptr(si.tcbs (elected)).rest_of_capacity - 1 = 0 then			
				put_debug("[BAILOUT MODE] Task "&elected'img&" ending execution at time:"& Natural(current_time+1)'img&",  BF before:"&si.bp_fund'img, Minimal);				
				-- BF = BF - (C(LO) - e)
				si.bp_fund := si.bp_fund - ( mixed_criticality_tcb_ptr(si.tcbs (elected)).current_capacities.entries(0).values_eu - mixed_criticality_tcb_ptr(si.tcbs (elected)).completion_time) + 1;
				put_debug("[BAILOUT MODE] BF after:"&si.bp_fund'img, Minimal);

			-- OVERRUN HI task: 
			elsif (elected_task.completion_time + 1 > elected_task.current_capacities.entries(0).values_eu) and mixed_criticality_tcb_ptr(si.tcbs (elected)).rest_of_capacity - 1 = 0 then
				-- 4. HI tasks ending execution with e time, e > C(LO) and no loan
				if not elected_task.bp_loan then
			 		-- A. Take a loan of (C(HI) - C(LO))
					-- B. Adding BF = BF + loan
					
					elected_task.bp_loan := True;
					put_debug("[BAILOUT MODE] Overrun Task "&elected'img&" with no loan ending execution,  BF before:"&si.bp_fund'img, Minimal);
					si.bp_fund := si.bp_fund + ( mixed_criticality_tcb_ptr(si.tcbs (elected)).current_capacities.entries(2).values_eu - mixed_criticality_tcb_ptr(si.tcbs (elected)).completion_time) + 1;
					put_debug("[BAILOUT MODE] BF after:"&si.bp_fund'img, Minimal);					    
				
				-- 5. HI tasks ending execution with e time, e > C(LO) and a loan
				else
					
					-- if it is the task that triggered the recovery mode, we wait for it to finish
					if elected = si.bp_elected_task then
						-- A. Reduce BF = BF - (C(HI) - e)
					put_debug("[BAILOUT MODE] First Overrun Task "&elected'img&" with loan ending execution at time:"& Natural(current_time+1)'img&",  BF before:"&si.bp_fund'img, Minimal);
						-- THe last element of task_range is 100
						si.bp_elected_task := 100;
					else
						-- A. Reduce BF = BF - (C(HI) - e)
					put_debug("[BAILOUT MODE] Overrun Task "&elected'img&" with loan ending execution at time:"& Natural(current_time+1)'img&",  BF before:"&si.bp_fund'img, Minimal);
						si.bp_fund := si.bp_fund - ( mixed_criticality_tcb_ptr(si.tcbs (elected)).current_capacities.entries(2).values_eu - mixed_criticality_tcb_ptr(si.tcbs (elected)).completion_time) + 1;
					
					end if;				
					put_debug("[BAILOUT MODE] BF after:"&si.bp_fund'img, Minimal);
					
				end if;
			end if;
			
			-- 7. BF = 0
			if si.bp_fund <= 0 and si.bp_time_recovery = 0 then
				si.bp_time_recovery := current_time + 1;			
			end if;			
									
		-- Bailout protocol : recovery mode
		elsif my_scheduler.recovery_protocol = 3 and si.bp_recovery_mode then
							
			-- 9. JK jobs ending exection								
			if elected = si.bp_jk_job  and mixed_criticality_tcb_ptr(si.tcbs (elected)).rest_of_capacity - 1 = 0 then
				
				-- If the elected task exceed his budget
				if not si.bp_bailout_mode then
					si.bp_time_mode_change := current_time+1;
				end if;
			end if;
						
		end if;
		
		
		-- quality improvement ending task
		if my_scheduler.state = Low_Criticality and mixed_criticality_tcb_ptr(si.tcbs (elected)).rest_of_capacity - 1 = 0
		then
			case elected_task.q_improvement_protocol is	
				-- Condition FTP protocol => TASK
				when 2 => 
					
					if elected_task.q_ftp_launch then
						elected_task.q_ftp_end := True;
						elected_task.q_ftp_time := current_time + 1;
					end if;
				
				-- Condition BAILOUT MODE => TASK
				when 3 =>
					if elected_task.q_bailout_launch then
						if elected_task.q_bailout_fund <= 0  then
							elected_task.q_bailout_time := current_time + 1;
						else
							elected_task.q_bailout_fund := elected_task.q_bailout_fund - ( mixed_criticality_tcb_ptr(si.tcbs (elected)).current_capacities.entries(0).values_eu - mixed_criticality_tcb_ptr(si.tcbs (elected)).completion_time) + 1;
						end if;
						
						put_debug("task q improvement ending execution at time"&current_time'img &" with bf"&elected_task.q_bailout_fund'img&" and C(LO)"& mixed_criticality_tcb_ptr(si.tcbs (elected)).current_capacities.entries(0).values_eu'img,Minimal);	
						
					end if;
				when others => 
					null;
			end case;
		end if;	
	end if;
   end verification_of_budget_overruns;
	
	
	
  procedure reset_loan
  	( si	    : in out scheduling_information)
  is
  	i : tasks_range := 0;	  
  begin
  	-- Suspend tasks		
	loop
		mixed_criticality_tcb_ptr(si.tcbs(i)).bp_loan := False;							
		i := i + 1;
	exit when si.tcbs (i) = null;
	end loop;
  end reset_loan;
  	
  function compute_nb_HI_task
  	(si                 : in scheduling_information) return Natural
  is
  	nb : Natural := 0;
  	i : tasks_range := 0;
  begin
  	loop
  		if (Natural(mixed_criticality_tcb_ptr (si.tcbs (i)).tsk.criticality)) = 2 then
  			nb := nb + 1; 
  		end if;
  		i := i + 1;	
  	exit when si.tcbs (i) = null;
	end loop;
	
	return nb;
  end compute_nb_HI_task;

  function find_lowest_priority_HItask
  	(si		: in scheduling_information) return tasks_range
  is
  	min		: Natural	:= Natural'last;
  	highest_task 	: tasks_range 	:= 0;
  	i 		: tasks_range 	:= 0;
  begin
  	loop
  		if Natural(mixed_criticality_tcb_ptr (si.tcbs (i)).tsk.criticality) = 2 then
	  		if (Natural(mixed_criticality_tcb_ptr (si.tcbs (i)).tsk.priority) < min) then
	  			min := Natural(mixed_criticality_tcb_ptr (si.tcbs (i)).tsk.priority);
	  			highest_task := i;
	  		end if;
		end if;
  		i := i + 1;
  	exit when si.tcbs (i) = null;
	end loop;
	
	return highest_task;
	
  end find_lowest_priority_HItask;
  
  	
  function find_highest_priority_HItask
  	(si		: in scheduling_information;
  	task_priority	: in Natural) return tasks_range
  is
  	max 		: Natural	:= Natural'first;
  	highest_task 	: tasks_range 	:= 0;
  	i 		: tasks_range 	:= 0;
  begin
  	loop
  		if Natural(mixed_criticality_tcb_ptr (si.tcbs (i)).tsk.criticality) = 2 then
  			-- first time we just look for the highest priority task 
	  		if task_priority = 0 then
		  		if (Natural(mixed_criticality_tcb_ptr (si.tcbs (i)).tsk.priority) > max) then
		  			max := Natural(mixed_criticality_tcb_ptr (si.tcbs (i)).tsk.priority);
		  			highest_task := i;
		  		end if;
		  	else
		  		if (Natural(mixed_criticality_tcb_ptr (si.tcbs (i)).tsk.priority) < task_priority and Natural(mixed_criticality_tcb_ptr (si.tcbs(i)).tsk.priority) > max) then
		  			max := Natural(mixed_criticality_tcb_ptr (si.tcbs (i)).tsk.priority);
		  			highest_task := i;
		  		end if;
		  	end if;
		end if;
  		i := i + 1;
  	exit when si.tcbs (i) = null;
	end loop;
	
	return highest_task;
	
  end find_highest_priority_HItask;
  
  function searches_next_task_to_executed_in_ftp
  (si			: in scheduling_information;
   last_task_priority	: in Natural;
   current_elected	: in tasks_range;
   
   my_scheduler	: in mixed_criticality_scheduler; 
   address_space_name  : in Unbounded_String;
   processor_name 	: in Unbounded_String;
   current_time	: in Natural;
   options	 	: in scheduling_option;
   cores		: in core_units_table) return tasks_range
  is
  	max 			: Natural	:= Natural'first;
  	select_task 		: tasks_range 	:= 0;
  	i 			: tasks_range 	:= 0;
  	current_task_priority 	: Natural;
  	current_task_criticality: Natural;
  begin
  	put_debug("=================> FTP: find a task to execute",Minimal);
  	
  	loop
  		current_task_priority := Natural(mixed_criticality_tcb_ptr (si.tcbs(i)).tsk.priority);
  		current_task_criticality := Natural(mixed_criticality_tcb_ptr (si.tcbs(i)).tsk.criticality);
  		
		-- search HI tasks
		if  current_task_criticality = 2 then
			-- priority below the last elected task
	  		if current_task_priority < last_task_priority then
	  			-- look for the highest priority task after the last elected task
	  			if current_task_priority > max then
	  				-- check that it is active ===> we check if it's the one chosen for this unit of time.
	  				if check_task_activiy_multicore(si,my_scheduler,address_space_name,processor_name,current_time,options,i,cores) then
	  					max := current_task_priority;
			  			select_task := i;
			  		end if;
			  	end if;
			  	put_debug("======= FTP: check task"&i'img,Minimal);
	  		end if;
		end if;
		i := i + 1;
  		
  	exit when si.tcbs (i) = null;
	end loop;
	
	return select_task;
  end searches_next_task_to_executed_in_ftp;
				
		
   procedure do_mode_change
     (my_scheduler       : in out mixed_criticality_scheduler; 
      options            : in scheduling_option;
      si                 : in out scheduling_information; 
      result             : in out scheduling_sequence_ptr;
      current_time       : in     Natural;
      from_mode 	  : in mode_range; 
      to_mode		  : in mode_range ) is
       
  a_item : time_unit_event_ptr;

  begin
        
        -- change variable values
        my_scheduler.state 		:= to_mode;
        si.state	    		:= to_mode;
        my_scheduler.is_change_mode 	:= True;
        
        
        -- compute time spend
        if from_mode = Low_Criticality then
        	si.nb_mode_change 		:= si.nb_mode_change + 1;
        	si.lo_time_spend := current_time - si.hi_time_spend;
        	-- count the number of change mode
		-- remove this for the quality
		--produce_mode_change(my_scheduler,
		   --, si, a_item, from_mode, to_mode);
		--add (result.all, current_time, a_item);
        else 
        	si.hi_time_spend := current_time - si.lo_time_spend;
        end if;
  end do_mode_change;


  
  

  procedure stop_tasks
  	( from_mode : in mode_range;
  	  si	    : in out scheduling_information;
  	  my_scheduler : in out mixed_criticality_scheduler;
  	  activation_value : in boolean;
  	  options : in scheduling_option)
  is
  	i : tasks_range := 0;	  
  begin
  	-- Suspend tasks		
	loop
		if si.tcbs(i).tsk.criticality = 0
		then
			si.tcbs(i).suspended := activation_value;
			
			if my_scheduler.recovery_protocol = 3 then
				put_debug("[BAILOUT MODE] job "&si.tcbs(i).activation'img&" from task"&i'img&" is lost",Minimal);
			else
				put_debug("LO task"&i'img& " jobs:"&si.tcbs(i).activation'img&" is suspended",Minimal);
			end if;			
			compute_next_task_activation(my_scheduler,si.tcbs (i),si,options,i);
			--si.nb_LO_jobs_stopped := si.nb_LO_jobs_stopped + 1;
		end if;	
		i := i + 1;
		exit when si.tcbs (i) = null;
	end loop;
  end stop_tasks;
  
  procedure activate_tasks
  	( to_mode : in mode_range;
  	  si	    : in out scheduling_information;
  	  my_scheduler : in out mixed_criticality_scheduler;
  	  options : in scheduling_option)
  is
  	i : tasks_range := 0;	  
  begin
  	-- Suspend tasks		
	loop
		if si.tcbs(i).tsk.criticality = Natural(to_mode) 
		then
			si.tcbs(i).suspended := False;
			
			-- compute next activation of the task
			--compute_next_task_activation(my_scheduler,si.tcbs(i),si,options,i);
		end if;	
		i := i + 1;
		exit when si.tcbs (i) = null;
	end loop;
  end activate_tasks;


 
 procedure produce_mode_change
     (my_scheduler : in mixed_criticality_scheduler; options : in scheduling_option;
      si : in scheduling_information; an_event : out time_unit_event_ptr;
      from_mode : in mode_range; to_mode : in mode_range) is 

  begin
         an_event := new time_unit_event(mode_change);
         an_event.from_mode := from_mode;
         an_event.to_mode := to_mode;
  end produce_mode_change;
  
 procedure do_quality_result
  (my_scheduler       : in out mixed_criticality_scheduler; 
      options            : in scheduling_option;
      si                 : in scheduling_information; 
      result             : in out scheduling_sequence_ptr;
      quality            : in     Natural;
      from_mode 	  : in mode_range; 
      to_mode		  : in mode_range ) is 

      a_item             : time_unit_event_ptr;
      F 		  : File_Type;
 begin
 	-- count the number of change mode
        produce_mode_change(my_scheduler,
           options, si, a_item, from_mode, to_mode);
        add (result.all, quality, a_item);
        
 end do_quality_result;
 
 procedure produce_quality_tasks_results
  (my_scheduler       : in out mixed_criticality_scheduler; 
      options            : in scheduling_option;
      si                 : in scheduling_information; 
      result             : in out scheduling_sequence_ptr;
      from_mode 	  : in mode_range; 
      to_mode		  : in mode_range)
  is 
  	i : Tasks_range := 0;
  	a_item : time_unit_event_ptr;
  begin
  	-- Suspend tasks		
	loop
		if si.tcbs(i).tsk.criticality = 0 
		then
			-- create the event
			produce_mode_change(my_scheduler, options, si, a_item, from_mode, to_mode);
			
			-- add the quality task
			add (result.all, mixed_criticality_tcb_ptr(si.tcbs (i)).quality_task, a_item);
			
			
		end if;	
		i := i + 1;
		exit when si.tcbs (i) = null;
	end loop;
         
  end produce_quality_tasks_results;
 
procedure update_simulation_data_on_mode_change
     (my_scheduler : in out mixed_criticality_scheduler; 
      si : in out scheduling_information;
	elected : in tasks_range;
	no_task : in Boolean)
is 
	j : tasks_range;
	current_state : Natural;
	current_task : mixed_criticality_tcb_ptr;
begin
	current_state := Natural(si.state);
	
        if (my_scheduler.is_change_mode)
        then
                j := 0;
                loop
                	current_task := mixed_criticality_tcb_ptr(si.tcbs(j));
                	
                        -- Used the next criticality capacities
                        if j /= elected
                        then
                                if get_name(my_scheduler) = mixed_criticality_quality_amc_protocol then
		                        -- Recover the original quality exit and DC value
					current_task.current_quality_exit := current_task.tsk.qualities.entries(0).values_eu;
					current_task.current_dc_value := current_task.tsk.capacity;
				end if;                    
                        end if;
                        si.tcbs(j) := tcb_ptr(current_task);
                        j := j + 1;
                        exit when si.tcbs (j) = null;
                end loop;
                my_scheduler.is_change_mode := False;
        end if;
end update_simulation_data_on_mode_change;



-----------------------------------------------------------------------------
-- Function to fill the list
procedure initialize_cores_list
   (list	: in out list_cores_activity;
    nb_cores	: in	Natural)
is
	i : Natural;
	d : data_core;
begin
	i := 1;
	loop
		d := (i,True,False);
    		add_core_in_list(d,list);
    		i := i + 1;
    		exit when i = nb_cores +1;
    	end loop;
    
end initialize_cores_list;

procedure add_core_in_list
	(d : in data_core;
	 list : in out list_cores_activity)
is
begin
	list := new core_activity'(d,list);
end add_core_in_list;
   
-- set the activity of the core in the list
procedure set_cores_activity
   (list	: in out list_cores_activity;
    core	: in	Natural;
    elem	: in	Boolean)
is
	l	:	list_cores_activity := list;
begin
	loop
		if l.value.core = core then
			l.value.activity := elem;			
		end if;
		l := l.next;
	exit when l = NULL;
	end loop;
end set_cores_activity;	

-- check if all the cores is active
-- make sure all cores are checked

function check_cores_activities
   (list	: in out list_cores_activity;
    current_core : in Natural) return Boolean
is
	rep		: 	Boolean 	:= False;
	l	:	list_cores_activity := list;
begin
	loop
		if l.value.activity = True  then
			rep := True;
		end if;
		
		l := l.next;
	exit when l = NULL;
	end loop;
	
	return rep;	
end check_cores_activities;

-- check if all cores as verify before look their activity
function check_cores_verify
   (list	: in out list_cores_activity;
    current_core : in Natural) return Boolean
is
	cores_checked	: 	Boolean 	:= True;
	l1	:	list_cores_activity := list;
	l2	:	list_cores_activity := list;
begin
	-- loop to set check value of the current core on True
	loop	
		if l1.value.core = current_core then
			l1.value.check := True;
		end if;
		l1 := l1.next;
	exit when l1 = NULL;
	end loop;
	
	loop		
		if l2.value.check = False then
			cores_checked := False;
		end if;
		l2 := l2.next;
	exit when l2 = NULL;
	end loop;
	
	return cores_checked;
	
end check_cores_verify;

-- search the core number from a core_name
function search_core_number
   (cores	: in core_units_table;
    core_name	: Unbounded_String) return Natural
is
	core_number : Natural;
	
begin
	for core_index in 0 .. cores.nb_entries - 1 loop
		if cores.entries (core_index).name = core_name then
			core_number := Natural(core_index) + 1;
		end if;
	end loop;
	return core_number;
end search_core_number;
	
	
procedure compute_number_of_LO_jobs(
	my_scheduler : in out mixed_criticality_scheduler; 
        si : in scheduling_information)
is
	i : tasks_range := 0;
begin
	loop
		if si.tcbs(i).tsk.criticality = 0 then
			my_scheduler.nb_LO_jobs := my_scheduler.nb_LO_jobs + (si.simulation_length / periodic_task_ptr (si.tcbs (i).tsk).period);
		end if;
	i := i + 1;
	exit when si.tcbs(i) = NULL;
	end loop;

	put_Debug("nb LO job stopped:"&si.nb_LO_jobs_stopped'img&" with nb LO jobs:"&my_scheduler.nb_LO_jobs'img&" and simulaiton time:"&si.simulation_length'img,Minimal);
	--Compute nb lost jobs
  	my_scheduler.nb_LO_jobs := (100 * si.nb_LO_jobs_stopped)/my_scheduler.nb_LO_jobs;
  	
  	
end compute_number_of_LO_jobs;


procedure compute_system_quality_improvement( 
        si : in out scheduling_information)
is
	i : tasks_range := 0;
	current_task : mixed_criticality_tcb_ptr;
begin
	loop
		current_task := mixed_criticality_tcb_ptr(si.tcbs(i));
		
		if current_task.tsk.criticality = 0  and current_task.current_quality_exit < current_task.tsk.qualities.entries(0).values_eu
		then
			current_task.current_quality_exit := current_task.current_quality_exit + 1;
			update_capacity_from_quality(mixed_criticality_tcb_ptr(si.tcbs(i)));
			si.nb_quality_improvement := si.nb_quality_improvement + 1;
		end if;
	i := i + 1;
	exit when si.tcbs(i) = NULL;
	end loop;
		
end compute_system_quality_improvement;




procedure compute_task_quality_improvement( 
        current_task : in out mixed_criticality_tcb_ptr;
        si : in out scheduling_information)
is
begin		
	if current_task.tsk.criticality = 0  and current_task.current_quality_exit < current_task.tsk.qualities.entries(0).values_eu
	then
		current_task.current_quality_exit := current_task.current_quality_exit + 1;
		update_capacity_from_quality(current_task);
		si.nb_quality_improvement := si.nb_quality_improvement + 1;
	end if;		
end compute_task_quality_improvement;


procedure update_capacity_from_quality(
	elected_task : in out mixed_criticality_tcb_ptr)
is
begin
	-- Reduce the capacity by the quality profile
	if elected_task.current_quality_exit = 2
	then
		elected_task.current_dc_value := elected_task.tsk.capacity * 30/100;
		 				
	elsif elected_task.current_quality_exit = 3
	then			 				 					
		elected_task.current_dc_value := elected_task.tsk.capacity * 50/100;			 			
	elsif elected_task.current_quality_exit = 4
	then
		elected_task.current_dc_value := elected_task.tsk.capacity * 70/100;		 					
	else
		elected_task.current_dc_value := elected_task.tsk.capacity;
	end if;
end ;


end scheduler.mixed_criticality;



















