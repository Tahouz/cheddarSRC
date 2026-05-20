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
--    $Date: 2023-09-29 16:02:19 +0200 (ven. 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Exceptions;        use Ada.Exceptions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Command_Line;      use Ada.Command_Line;
with GNAT.Command_Line;
with GNAT.OS_Lib;           use GNAT.OS_Lib;

with call_framework;           use call_framework;
with call_framework_interface; use call_framework_interface;
use call_framework_interface.framework_response_package;
use call_framework_interface.framework_request_package;
with framework;                         use framework;
with call_scheduling_framework;         use call_scheduling_framework;
with multiprocessor_services;           use multiprocessor_services;
with multiprocessor_services_interface; use multiprocessor_services_interface;
use multiprocessor_services_interface.scheduling_result_per_processor_package;
with scheduling_analysis.extended.mixed_criticality_analysis;
use scheduling_analysis.extended.mixed_criticality_analysis;
with Objects;  use Objects;
with Tasks;    use Tasks;
with Task_Set; use Task_Set;
use task_set.generic_task_set;
with Systems;           use Systems;
with Processors;        use Processors;
with Processor_Set;     use Processor_Set;
with Address_Spaces;    use Address_Spaces;
with Address_Space_Set; use Address_Space_Set;
with Core_Units;        use Core_Units;
use Core_Units.Core_Units_Table_Package;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with parameters;          use parameters;
with parameters.extended; use parameters.extended;
use parameters.framework_parameters_table_package;
with systems;             use systems;
with Processor_Interface; use Processor_Interface;
with Scheduler_Interface; use Scheduler_Interface;

with version;           use version;
with unbounded_strings; use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with Random_Tools;         use Random_Tools;
with architecture_factory; use architecture_factory;
with unbounded_strings;    use unbounded_strings;
with call_framework;       use call_framework;
with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;
with doubles; use doubles;

with scheduling_analysis;          use scheduling_analysis;
with scheduling_analysis.extended; use scheduling_analysis.extended;
with scheduling_analysis.extended.task_analysis;
use scheduling_analysis.extended.task_analysis;
use scheduling_analysis.extended.task_occurence_table_package;

with scheduler.mixed_criticality;           use scheduler.mixed_criticality;

with time_unit_events; use time_unit_events;
use time_unit_events.time_unit_lists_package;
use time_unit_events.time_unit_package;

procedure schedule_amc is


   -- A set of variables required to call the framework
   --
   response_list : framework_response_table;
   request_list  : framework_request_table;
   a_request     : framework_request;
   a_param       : parameter_ptr;

   sys : System;

   project_file_dir_list : unbounded_string_list;
   project_file_list     : unbounded_string_list;

   msg                  : Unbounded_String;
   Feasibility_Interval : Double;
   validate             : Boolean;
   a_processor          : Generic_Processor_Ptr;

   RT : Boolean := False;
   Output_EV_File_Name    : Unbounded_String;
   F 			   : File_Type;
   i 			   : integer := 1;
   nb_mode_change 	   : natural :=0;
   nb_stop_task	   : natural := 0;
   HI_time_mode_change	   : Natural :=0;
   result		   : Natural := 0;
   
   metric		   : Unbounded_String;

begin

   -- Initialize the Cheddar framework
   --
   call_framework.initialize (False);
   --  Parse command line
   --
   if Argument_Count /= 4 then
      Put ("Usage: " & Command_Name & " ");
      Put_Line ("RT InputFilename OutputFileName metric");
      GNAT.OS_Lib.OS_Exit (1);
   else
      RT := Boolean'Value (Argument (1));
   end if;

   -- open file
   Create (F, Out_File, Argument(3));
   
   -- Read the XML project file
   --
   initialize (project_file_list);
   declare
      File_Name : String := Argument (2);
   begin
      Output_EV_File_Name := File_Name & to_unbounded_string(".schedule");
      systems.read_from_xml_file (sys, project_file_dir_list, file_name);
   end;
   
   -- metric to evaluate
   metric :=  To_Unbounded_String(argument(4));
   a_processor :=
     search_processor (sys.processors, to_unbounded_string ("processor1"));
     
   Calculate_feasibility_interval
     (sys, a_processor, validate, Feasibility_Interval, msg);
   Feasibility_Interval := Feasibility_Interval * 2.0;
   
   Put_Line (F, "Feasibility_Interval : " & Feasibility_Interval'Img);

   -- Compute the scheduling on the period given by the argument
   --
   initialize (response_list);
   initialize (request_list);
   initialize (a_request);
   
   -- Simulation protocol selection
   a_request.statement    := scheduling_simulation_time_line;
   a_param                := new parameter (integer_parameter);
   a_param.parameter_name := To_Unbounded_String ("period");
   a_param.integer_value  := integer (feasibility_interval);

   add (a_request.param, a_param);
   a_param                := new parameter (boolean_parameter);
   a_param.parameter_name := To_Unbounded_String ("schedule_with_offsets");
   a_param.boolean_value  := True;
   add (a_request.param, a_param);
   a_param                := new parameter (boolean_parameter);
   a_param.parameter_name := To_Unbounded_String ("schedule_with_precedencies");
   a_param.boolean_value := True;
   add (a_request.param, a_param);
   
   a_param                := new parameter (boolean_parameter);
   a_param.parameter_name := To_Unbounded_String ("schedule_with_resources");
   a_param.boolean_value  := True;
   add (a_request.param, a_param);
   
   a_param                := new parameter (boolean_parameter);
   a_param.parameter_name := To_Unbounded_String ("schedule_with_jitters");
   a_param.boolean_value  := False;
   add (a_request.param, a_param);
   a_param                := new parameter (boolean_parameter);
   a_param.parameter_name := To_Unbounded_String ("minimize_preemption");
   a_param.boolean_value  := False;
   add (a_request.param, a_param);
   a_param                := new parameter (boolean_parameter);
   a_param.parameter_name := To_Unbounded_String ("discard_missed_deadline");
   a_param.boolean_value  := False;
   add (a_request.param, a_param);
   
   a_param                := new parameter (integer_parameter);
   a_param.parameter_name := To_Unbounded_String ("seed_value");
   a_param.integer_value  := 0;
   add (a_request.param, a_param);
   
   a_param                := new parameter (boolean_parameter);
   a_param.parameter_name := To_Unbounded_String ("predictable");
   a_param.boolean_value  := True;
   add (a_request.param, a_param);
   
   add (request_list, a_request);
   sequential_framework_request (sys, request_list, response_list);

   

   initialize (a_request);
   initialize (a_request.param);
   initialize (response_list);
   initialize (request_list);

   a_param                := new parameter (boolean_parameter);
   a_param.parameter_name := To_Unbounded_String ("worst_case");
   a_param.boolean_value  := True;
   add (a_request.param, a_param);

   a_param                := new parameter (boolean_parameter);
   a_param.parameter_name := To_Unbounded_String ("best_case");
   a_param.boolean_value  := True;
   add (a_request.param, a_param);

   a_param                := new parameter (boolean_parameter);
   a_param.parameter_name := To_Unbounded_String ("average_case");
   a_param.boolean_value  := True;
   add (a_request.param, a_param);

   a_request.target    := a_processor.name;
   a_request.statement := scheduling_simulation_response_time;
   add (request_list, a_request);
   sequential_framework_request (sys, request_list, response_list);
 
   if metric = "HTE_HMC" then
	   for i in 0 .. framework.sched.nb_entries - 1 loop
	       number_of_mode_change_from_simulation(framework.sched.entries (i).data.result,nb_mode_change,HI_time_mode_change);
	   	 Put_line(F,"nb_mode_change :" & Natural'image(nb_mode_change));
	   	 Put_line(F,"HI_time_mode_change :" & Natural'image(HI_time_mode_change));
	   end loop;
   end if;
   
   if metric = "stop_task" then
	   for i in 0 .. framework.sched.nb_entries - 1 loop
	   	number_of_ending_tasks_from_simulation(framework.sched.entries (i).data.result,nb_stop_task);
	   	Put_line(F,"nb_stop_task :" & Natural'image(nb_stop_task));
	   end loop;
   end if;
   
   --for i in 0 .. framework.sched.nb_entries - 1 loop
   --	compute_quality_from_simulation(framework.sched.entries (i).data.result,nb_mode_change);
   --	Put_line(F,"hi_time_spend :" & Natural'image(nb_mode_change));
   --end loop;
   
   
   -- compute the quality
   if metric = "quality" then
   	for i in 0 .. framework.sched.nb_entries - 1 loop
	   	compute_quality_from_simulation(framework.sched.entries(i).data.result,nb_mode_change);	   	
	   	for j in 0 .. framework.sched.entries(i).data.result.nb_entries - 1 loop
			 if (framework.sched.entries(i).data.result.entries (j).data.type_of_event = mode_change)
			 then
			 	Put_line(F,"quality :" & Natural'image(framework.sched.entries(i).data.result.entries (j).item));			 	      
			 end if;
		end loop;
   	end loop;   	
   end if;
   
   -- compute all the data
   if metric = "all" then
   	for i in 0 .. framework.sched.nb_entries - 1 loop
	   	compute_quality_from_simulation(framework.sched.entries(i).data.result,nb_mode_change);	   	
	   	for j in 0 .. framework.sched.entries(i).data.result.nb_entries - 1 loop
			 if (framework.sched.entries(i).data.result.entries (j).data.type_of_event = mode_change)
			 then
			 
			 	case result is
			 	
			 		when 0 => 
			 			Put_line(F,"JNE(%):" & Natural'image(framework.sched.entries(i).data.result.entries (j).item));
			 			result := result + 1;
			 		when 1 => 
			 			Put_line(F,"TiL(%):" & Natural'image(framework.sched.entries(i).data.result.entries (j).item));
			 			result := result + 1;
			 		when 2 => 
			 			Put_line(F,"nMC:" & Natural'image(framework.sched.entries(i).data.result.entries (j).item));
			 			result := result + 1;
			 		when 3 => 
			 			Put_line(F,"nQI:" & Natural'image(framework.sched.entries(i).data.result.entries (j).item));
			 			result := result + 1;
			 		when others =>
			 			Put_line(F,"quality:" & Natural'image(framework.sched.entries(i).data.result.entries (j).item));
			 	end case;			 			 	      
			 end if;
		end loop;
   	end loop; 
   	
   	if (RT) then
	      for j in 0 .. response_list.nb_entries - 1 loop      	 
		 Put_Line (F,To_String (response_list.entries (j).title));
		 Put_Line (F,To_String (response_list.entries (j).text));
	      end loop;
	   end if;
	     	
   end if;
   result := 0;


   if metric = "response_time" then
	   if (RT) then
	      for j in 0 .. response_list.nb_entries - 1 loop      	 
		 Put_Line (F,To_String (response_list.entries (j).title));
		 Put_Line (F,To_String (response_list.entries (j).text));
	      end loop;
	   end if;
   end if;
   --Put_Line("--Export event table");            
   --Write_To_Xml_File (framework.Sched, Sys, Output_EV_File_Name);
   close(F);

end schedule_amc;
