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

with Text_IO;        use Text_IO;

with qs_tools;       use qs_tools;
with debug;          use debug;

with scheduler;           use scheduler;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with scheduler.mixed_criticality; use  scheduler.mixed_criticality;


package body scheduler.mixed_criticality.quality_amc is

   procedure initialize
     (a_scheduler : in out mixed_criticality_quality_amc_scheduler)
   is
   begin
      reset (a_scheduler);
      a_scheduler.parameters.scheduler_type := mixed_criticality_quality_amc_protocol;
   end initialize;

   function copy
     (a_scheduler : in mixed_criticality_quality_amc_scheduler)
      return generic_scheduler_ptr
   is
      ptr : mixed_criticality_quality_amc_scheduler_ptr;

   begin

      ptr := new mixed_criticality_quality_amc_scheduler;

      ptr.parameters         := a_scheduler.parameters;
      ptr.previously_elected := a_scheduler.previously_elected;

      return generic_scheduler_ptr (ptr);

   end copy;

   procedure check_before_scheduling
     (my_scheduler   : in mixed_criticality_quality_amc_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

   begin
      null;
   end check_before_scheduling;

   procedure specific_scheduler_initialization
     (my_scheduler       : in out mixed_criticality_quality_amc_scheduler;
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
     (my_scheduler       : in out mixed_criticality_quality_amc_scheduler;
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
      highiest_priority        	: Natural     := Natural'first;
      threshold_quality		: Integer     := my_scheduler.parameters.threshold;
      Quality_max			: Integer     := my_scheduler.parameters.capacity;
      elected_task			: mixed_criticality_tcb_ptr;
      find				: Boolean	:= False; 
      first_execution			: Boolean	:= TRue;

   begin
	-- main loop
	loop
		-- task election
		--
		find_elected_task(si, my_scheduler, core_name, address_space_name, processor_name, current_time, options, highiest_priority, elected, result,first_execution);
		first_execution := False;
		-- if they are no elected task
		--
		if highiest_priority = Natural'first then
			no_task := True;
		else
			elected_task := mixed_criticality_tcb_ptr( si.tcbs (elected));
			no_task := False;
		 
			-- Verify if the current task exceed its computing budget
			--
			verification_of_budget_overruns
			   (elected_task, my_scheduler,result, find, highiest_priority, si,
			    options, elected, current_time, my_scheduler.state);
			    
			
			-- update the sum of the qualities achieved by the elected task
			compute_task_quality(elected_task,find,my_scheduler);
			
			-- update_simulation_data_on_mode_change
			--
			update_simulation_data_on_mode_change(my_scheduler, si, elected, no_task);
			
		end if;
		
	exit when find or no_task;
	end loop;	
	
	first_execution := True;

	-- increment the number of time units executed by the task
	--
	if not no_task
	then
		elected_task.completion_time := elected_task.completion_time + 1;
		
		if elected_task.rest_of_capacity-1 = 0 then		
			-- compute ending execution
			if elected_task.tsk.criticality = 2 then
				si.nb_hi_finished_execution := si.nb_hi_finished_execution + 1;
			else
				si.nb_lo_finished_execution := si.nb_lo_finished_execution + 1;
			end if;
		end if;
	end if;
	
	
	if current_time = si.simulation_length-1 then
		-- Compute nb LO jobs
  		compute_number_of_LO_jobs(my_scheduler,si);

		-- compute time spend in LO mode
		if si.state = Low_Criticality then
			si.lo_time_spend := (current_time+1) - si.hi_time_spend;
		else 
			si.hi_time_spend := (current_time+1) - si.lo_time_spend;
		end if;
		
		
			
		-- Number of lost jobs
		put_debug("JNE(%):"&my_scheduler.nb_LO_jobs'img,Minimal);
		do_quality_result(my_scheduler, options, si, result, my_scheduler.nb_LO_jobs, 0, 1);
		
		-- Time in LO mode
		put_debug("TiL(%):"&si.lo_time_spend'img,Minimal);
		do_quality_result(my_scheduler, options, si, result, si.lo_time_spend, 0, 1);
		
		-- Number of mode change
		put_debug("nMC:"&si.nb_mode_change'img,Minimal);
		do_quality_result(my_scheduler, options, si, result, si.nb_mode_change, 0, 1);
		
		-- Number of quality improvement
		put_debug("nQI:"&si.nb_quality_improvement'img,Minimal);
		do_quality_result(my_scheduler, options, si, result, si.nb_quality_improvement, 0, 1);

		-- quality	
		produce_quality_tasks_results(my_scheduler, options, si, result, 0, 1);
	end if;
      put_debug ("Call Do_Election: ANYTIME AMC : Elected : " & elected'img);
   end do_election;


end scheduler.mixed_criticality.quality_amc;
