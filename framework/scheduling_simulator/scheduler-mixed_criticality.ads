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
with execution_units; use execution_units;
with execution_units.extended; use execution_units.extended;

with time_unit_events;          use time_unit_events;
use time_unit_events.time_unit_package;


package scheduler.mixed_criticality is

   -- Definition of a list type for cores
   type core_activity;
   type list_cores_activity is access core_activity;
   
   type data_core is
   record
   	core : Natural;
   	activity : Boolean;
   	check	: Boolean;
   end record;
   
   type core_activity is
   record
   	value : data_core;
   	next: list_cores_activity;
   end record;
   
   -- add a core in the list
   procedure add_core_in_list
   (d : in data_core;
    list : in out list_cores_activity);
    
   -- Function to fill the list
   procedure initialize_cores_list
   (list	: in out list_cores_activity;
    nb_cores	: in	Natural);
   
   -- set the activity of the core in the list
   procedure set_cores_activity
   (list	: in out list_cores_activity;
    core	: in	Natural;
    elem	: in	Boolean);
    
   -- check if all the cores is active
   function check_cores_activities
   (list	: in out list_cores_activity;
    current_core: in Natural) return Boolean;
    
   -- check if all the cores are covered
   function check_cores_verify
   (list	: in out list_cores_activity;
    current_core: in Natural) return Boolean;
     
   -- search core number in table cores
   function search_core_number
   (cores	: in core_units_table;
    core_name	: Unbounded_String) return Natural;
     
     
   type mixed_criticality_scheduler is abstract new generic_scheduler with
   record
     	state				: mode_range := Low_Criticality;
     	is_change_mode			: Boolean := False;
     	nb_recursif			: Natural := 0;
     	index				: Natural := 0;
     	quality_system			: Natural := 0;
     	number_of_missed_deadline	: Natural := 0;
     	nb_QOS_change			: Natural := 0;
     	nb_adaptation			: Natural := 0;
     	nb_LO_jobs			: Natural := 0;
     	
     	-- Recovery mode protocol
     	recovery_protocol		: Natural := 2;
     	nb_tasks_without_overrun 	: Natural := 0;
     	highest_priority_HItask 	: tasks_range := 0;
     	FTP_retry			: Boolean := False;
     	cores_list			: list_cores_activity;
     	
     	
     	-- Dregradation strategy
     	-- for now only 1 policy : all tasks is activated
     	quality_degradation_policy : Natural := 1;
     	
   end record; 
     
   type mixed_criticality_scheduler_ptr is
     access all mixed_criticality_scheduler'class;

     
   type mixed_criticality_tcb is new tcb with record
      dynamic_deadline		: Natural;
      current_capacities	: execution_units_table;
      current_dc_value		: Natural;
      current_I_LO_value	: Natural;
      current_I_HI_value	: Natural;
      current_quality_exit	: Natural;
      is_execution_continue	: Boolean;
      completion_time		: Natural := 0;
      is_active		: Boolean := False; 
      bp_loan			: Boolean := False;
      quality_task		: Natural := 0;
      
      -- quality improvement
      q_improvement_protocol	: Natural := 0; --(0:no protocol, 1:idle time, 2:ftp, 3:bailout)
      q_improvement_step	: Natural := 1; -- describe the step up in quality 
      
      -- IDLE
      
      -- FTP
      q_ftp_launch		: Boolean := False;
      q_ftp_end		: Boolean := False;
      q_ftp_time		: Natural := 0;
      
      -- BAILOUT
      q_bailout_fund		: integer := 0;
      q_bailout_launch		: Boolean := False;
      q_bailout_time		: Natural := 0;
      
      
      
   end record;

   type mixed_criticality_tcb_ptr is access all mixed_criticality_tcb'class;

   procedure initialize (a_tcb : in out mixed_criticality_tcb);

   function build_tcb
     (my_scheduler : in mixed_criticality_scheduler;
      a_task       :    generic_task_ptr) return tcb_ptr;

   function find_highest_priority_HItask
  	(si		: in scheduling_information;
  	task_priority	: in Natural) return tasks_range;
  	
   function find_lowest_priority_HItask
  	(si		: in scheduling_information) return tasks_range;
  	
   function searches_next_task_to_executed_in_ftp
   (si			: in scheduling_information;
   last_task_priority	: in Natural;
   current_elected	: in tasks_range;
   my_scheduler	: in mixed_criticality_scheduler; 
   address_space_name  : in Unbounded_String;
   processor_name 	: in Unbounded_String;
   current_time	: in Natural;
   options	 	: in scheduling_option;
   cores		: in core_units_table) return tasks_range;
  
   function compute_nb_HI_task
   	(si                 : in scheduling_information) return Natural;
   	
   procedure reset_loan
   	(si                 : in out scheduling_information);
   procedure check_before_scheduling
     (my_scheduler   : in mixed_criticality_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String);
      
   function check_task_activiy_multicore
   (	si			: in scheduling_information;
 	my_scheduler		: in mixed_criticality_scheduler; 
	address_space_name     : in Unbounded_String;
	processor_name 	: in Unbounded_String;
	current_time		: in Natural;
	options	 	: in scheduling_option;
	targeted_task		: in tasks_range;
	cores			: in core_units_table)return Boolean;

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
      msg                : in out Unbounded_String);

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
      no_task            : in out Boolean);

    procedure do_recovery_mode
   	(my_scheduler       : in out mixed_criticality_scheduler; 
      options            : in scheduling_option;
      si                 : in out scheduling_information; 
      result             : in out scheduling_sequence_ptr;
      current_time       : in     Natural;
      from_mode 	  : in mode_range; 
      to_mode		  : in mode_range);
      
   procedure find_elected_task
	(si			: in out scheduling_information;
	 my_scheduler		: in out mixed_criticality_scheduler; 
	 core_name		: in Unbounded_String;
	 address_space_name     : in Unbounded_String;
	 processor_name 	: in Unbounded_String;
	 current_time		: in Natural;
	 options	 	: in scheduling_option;
	 highiest_priority 	: in out Natural;
	 elected 		: in out tasks_range;
	 result            	: in out scheduling_sequence_ptr;
	 first_execution	: in out boolean);
	 
    procedure verification_of_budget_overruns
	   (elected_task	: in out mixed_criticality_tcb_ptr;
	    my_scheduler	: in out mixed_criticality_scheduler;
	    result		: in out scheduling_sequence_ptr;
	    find		: in out Boolean;
	    highiest_priority	: in out Natural;
	    si			: in out scheduling_information;
	    options             : in scheduling_option;
	    elected		: in tasks_range;
	    current_time	: in Natural;
	    current_mode	: in mode_range
	    );
  
   procedure compute_quality
	(elected_task		: in mixed_criticality_tcb_ptr;
	 my_scheduler       : in out mixed_criticality_scheduler);
	 
   procedure compute_task_quality
	(elected_task		: in mixed_criticality_tcb_ptr;
	 find			: in Boolean;
	 my_scheduler       	: in out mixed_criticality_scheduler);
	 
   procedure display_quality_task
   	( si	: 	in scheduling_information);
	 
   procedure compute_missed_deadline
   	(elected_task	: in mixed_criticality_tcb_ptr;
   	 my_scheduler	: in out mixed_criticality_scheduler;
   	 current_time	: in Natural);	 

   procedure update_simulation_data_on_mode_change
	(my_scheduler	: in out mixed_criticality_scheduler;
	 si		: in out scheduling_information;
	 elected	: in tasks_range;
	no_task		: Boolean);

   procedure do_mode_change
     (my_scheduler       : in out mixed_criticality_scheduler;
      options            : in scheduling_option;
      si                 : in out scheduling_information;
      result             : in out scheduling_sequence_ptr;
      current_time       : in     Natural;
      from_mode : in mode_range; to_mode: in mode_range );
      
  procedure do_quality_result
  (my_scheduler       : in out mixed_criticality_scheduler; 
      options            : in scheduling_option;
      si                 : in scheduling_information; 
      result             : in out scheduling_sequence_ptr;
      quality	          : in     Natural;
      from_mode 	  : in mode_range; 
      to_mode		  : in mode_range );
      
  procedure produce_quality_tasks_results
     (my_scheduler       : in out mixed_criticality_scheduler; 
      options            : in scheduling_option;
      si                 : in scheduling_information; 
      result             : in out scheduling_sequence_ptr;
      from_mode 	  : in mode_range; 
      to_mode		  : in mode_range);

  procedure stop_tasks
  	( from_mode : in mode_range;
  	  si	    : in out scheduling_information;
  	  my_scheduler : in out mixed_criticality_scheduler;
  	  activation_value : in boolean;
  	  options : in scheduling_option);
  
   procedure activate_tasks
  	( to_mode : in mode_range;
  	  si	    : in out scheduling_information;
  	  my_scheduler : in out mixed_criticality_scheduler;
  	   options : in scheduling_option);
  	    
  procedure produce_mode_change
     (my_scheduler : in mixed_criticality_scheduler; options : in scheduling_option;
      si : in scheduling_information; an_event : out time_unit_event_ptr;
      from_mode : in mode_range; to_mode : in mode_range);
   
  procedure compute_number_of_LO_jobs(
	my_scheduler : in out mixed_criticality_scheduler; 
        si : in scheduling_information);
        
  procedure compute_system_quality_improvement( 
        si : in out scheduling_information);
        
  procedure compute_task_quality_improvement( 
        current_task : in out mixed_criticality_tcb_ptr;
        si : in out scheduling_information);
        
  procedure update_capacity_from_quality(
	elected_task : in out mixed_criticality_tcb_ptr);
private


end scheduler.mixed_criticality;
