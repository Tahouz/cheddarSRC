
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
with Ada.Real_Time;         use Ada.Real_Time;

with call_framework;           use call_framework;
with call_framework_interface; use call_framework_interface;
use call_framework_interface.framework_response_package;
use call_framework_interface.framework_request_package;
with framework;                         use framework;
with call_scheduling_framework;         use call_scheduling_framework;
with multiprocessor_services;           use multiprocessor_services;
with multiprocessor_services_interface; use multiprocessor_services_interface;
use multiprocessor_services_interface.scheduling_result_per_processor_package;
with Objects;  use Objects;
with Tasks;    use Tasks;
with Task_Set; use Task_Set;
use task_set.generic_task_set;
with Systems;           use Systems;
with Processors;        use Processors;
with Processor_Set;     use Processor_Set;
with Messages;     use Messages;
with Message_Set;     use Message_Set;
with Dependencies;    use Dependencies;
with networks;        use networks;
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
with double_util; use double_util;

with scheduling_analysis;          use scheduling_analysis;
with scheduling_analysis.extended; use scheduling_analysis.extended;
with scheduling_analysis.extended.task_analysis;
use scheduling_analysis.extended.task_analysis;
use scheduling_analysis.extended.task_occurence_table_package;


with time_unit_events; use time_unit_events;
use time_unit_events.time_unit_lists_package;
use time_unit_events.time_unit_package;
with sets ;
with natural_util ; use natural_util ; 
with discrete_util; 



package body spacewire_analysis is


procedure display_scheduled_task is 
begin
 for i in 0 .. sched.nb_entries - 1 loop
         for j in 0 .. sched.entries (i).data.result.nb_entries - 1 loop
            Put (sched.entries (i).data.result.entries (j).item'img); put(" ");
            Put (sched.entries (i).data.result.entries (j).data.type_of_event'img); put (" ");
            if (sched.entries (i).data.result.entries (j).data.type_of_event=task_activation)
                 then
                Put (to_string(sched.entries (i).data.result.entries (j).data.activation_task.name));
            end if;
            if (sched.entries (i).data.result.entries (j).data.type_of_event=running_task)
                 then
                Put (to_string(sched.entries (i).data.result.entries (j).data.running_task.name));
            end if;
            new_line;
         end loop;
      end loop;
end display_scheduled_task;



   procedure compute_scheduling (sys : in out system; processor_name : in unbounded_string; Feasibility_Interval : in integer) is 

   -- A set of variables required to call the framework
   --
   response_list : framework_response_table;
   request_list  : framework_request_table;
   a_request     : framework_request;
   a_param       : parameter_ptr;

begin	

   -- Compute the scheduling on the period given by the argument
   --
   initialize (response_list);
   initialize (request_list);
   initialize (a_request);
   
   -- Simulation protocol selection
   a_request.statement    := scheduling_simulation_time_line;
   a_param                := new parameter (integer_parameter);
   a_param.parameter_name := To_Unbounded_String ("period");
   a_param.integer_value  := feasibility_interval;

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

   a_request.target    := processor_name;
   a_request.statement := scheduling_simulation_response_time;
   add (request_list, a_request);
   sequential_framework_request (sys, request_list, response_list);
 
end compute_scheduling; 




procedure display_task (sys : in system)  is
   my_iterator_t           : tasks_iterator;
   my_task                 : Generic_task_ptr ; 
begin

         reset_iterator (sys.tasks, my_iterator_t);

        loop
           current_element (sys.tasks, my_task, my_iterator_t);

            put_line("task name : " & to_string(my_task.name));
           exit when is_last_element (sys.tasks, my_iterator_t);

           next_element (sys.tasks, my_iterator_t);

         end loop;
end display_task ;


 procedure compute_worst_execution_time  (sys : in system) is 
  subtype task_occurence_range is task_occurence_table_package.table_range;
  current_date             : integer;
  my_task_occurence_table  : task_occurence_table_ptr;
  task_occurence_number    : task_occurence_range ; 
  worst_execution_time     : Natural ; 
  a_task                  :  Generic_task_ptr;
  my_iterator_t           : tasks_iterator;

 begin
   task_occurence_number    := 0;
   worst_execution_time     := 0 ; 

   my_task_occurence_table := new task_occurence_table;
   reset_iterator (sys.tasks, my_iterator_t);
   loop
      current_element (sys.tasks, a_task, my_iterator_t);

      for k in 0 .. sched.nb_entries - 1 loop
          for j in 0 .. sched.entries(k).data.result.nb_entries - 1 loop

              if sched.entries (k).data.result.entries (j).data.type_of_event=task_activation  then
                  if sched.entries (k).data.result.entries (j).data.activation_task.name = a_task.name then
                current_date := sched.entries(k).data.result.entries(j).item;
                task_occurence_number := task_occurence_number + 1;
                my_task_occurence_table.entries(task_occurence_number).arrival_time := current_date;
                  end if;
              end if;


              if sched.entries (k).data.result.entries (j).data.type_of_event = end_of_task_capacity then
                  if sched.entries (k).data.result.entries (j).data.end_task.name =a_task.name then
                      current_date := sched.entries(k).data.result.entries(j).item;
                      my_task_occurence_table.entries(task_occurence_number).completion_time := current_date ;
                      my_task_occurence_table.entries(task_occurence_number).response_time :=
                      my_task_occurence_table.entries(task_occurence_number).completion_time - my_task_occurence_table.entries(task_occurence_number).arrival_time;
                     -- put_line(Integer'image(my_task_occurence_table.entries(task_occurence_number).response_time)); 

                      if my_task_occurence_table.entries(task_occurence_number).response_time > worst_execution_time then
                         worst_execution_time :=my_task_occurence_table.entries(task_occurence_number).response_time;
                      end if;
                  end if;
              end if;
              if task_occurence_number > 0 then
                    my_task_occurence_table.entries(task_occurence_number).response_time := worst_execution_time;
              end if;

        end loop;
      end loop;


     -- Produce line for the CVS file
     --
     put(to_string(a_task.name));
     Put_Line("; " & Integer'Image(worst_execution_time));

      exit when is_last_element (sys.tasks, my_iterator_t);
      next_element (sys.tasks, my_iterator_t);
      worst_execution_time:=0;
   end loop;

 end compute_worst_execution_time ;


   


-- PPCM computation
--
procedure ppcm_compute (sys : in system; PPCM  : out double)  is
   current_period : double;
  
   a_task         : Generic_task_ptr;
   my_iterator_t  : tasks_iterator;

begin
   reset_iterator(sys.tasks, my_iterator_t);

   current_element(sys.tasks, a_task, my_iterator_t);
   PPCM := double(periodic_task_ptr(a_task).period);

   begin
     loop

      current_element(sys.tasks, a_task, my_iterator_t);
      current_period := double(periodic_task_ptr(a_task).period);

      PPCM := double_util.lcm(PPCM, current_period);

      exit when is_last_element(sys.tasks, my_iterator_t);
      next_element(sys.tasks, my_iterator_t);
     end loop;
   exception
       when constraint_error =>
		PPCM:=double'Last;
   end;

   put_line("PPCM of periods: " & double'Image(PPCM));
end ppcm_compute;

procedure ppcm_compute (sys : in system; PPCM  : out Natural)  is
   package natural_discrete is new discrete_util (Natural);
   subtype discrete_element is integer;

   current_period : Natural;
  
   a_task         : Generic_task_ptr;
   my_iterator_t  : tasks_iterator;

begin
   reset_iterator(sys.tasks, my_iterator_t);

   current_element(sys.tasks, a_task, my_iterator_t);
   PPCM := periodic_task_ptr(a_task).period;

   begin
     loop

      current_element(sys.tasks, a_task, my_iterator_t);
      current_period := periodic_task_ptr(a_task).period;

      PPCM := natural_discrete.lcm(PPCM, current_period);

      exit when is_last_element(sys.tasks, my_iterator_t);
      next_element(sys.tasks, my_iterator_t);
     end loop;
   exception
       when constraint_error =>
		PPCM:=Natural'Last;
   end;

   put_line("PPCM of periods: " & Natural'Image(PPCM));
end ppcm_compute;

  -- Wakeup Task computation

function  task_wakeup_compute (sys : in system; a_task : in Generic_task_Ptr) return double is
   result         : double :=0.0;
   nb_wakeup      : double :=0.0;
   my_task        : generic_task_ptr;
   PPCM           : double :=0.0;
   my_iterator_t  : tasks_iterator;
begin
      ppcm_compute(sys, PPCM);
      reset_iterator (sys.tasks, my_iterator_t);

        loop
           current_element (sys.tasks, my_task, my_iterator_t);
           nb_wakeup := PPCM / double(periodic_task_ptr(my_task).period);

           exit when is_last_element (sys.tasks, my_iterator_t);
           result := result + nb_wakeup;

           next_element (sys.tasks, my_iterator_t);

         end loop;
         return result;
end task_wakeup_compute;






procedure create_tdma_frame(sys : in system; frame : in out tdma_frame_type) is

minimum_slot_number  : constant integer := 32;
found : boolean ;
a_slot : slot_id_type;
a_task : generic_task_ptr;
my_iterator  : tdma_set.iterator;

begin
     a_slot:=2;
     for t in 0 .. sched.nb_entries - 1 loop
        for j in 0 .. sched.entries(t).data.result.nb_entries - 1 loop
            if sched.entries(t).data.result.entries(j).data.type_of_event = end_of_task_capacity then
		     if task_wakeup_compute(sys, sched.entries(t).data.result.entries(j).data.end_task) < double(minimum_slot_number) then
			     frame(a_slot).Slot_id := a_slot;
                             add(frame(a_slot).emitters, sched.entries(t).data.result.entries(j).data.end_task);
		             frame(a_slot).duration := integer(get_number_of_elements(frame(a_slot).emitters));
		             frame(a_slot).start_time := sched.entries(t).data.result.entries(j).item;
			     frame(a_slot-1).duration := sched.entries(t).data.result.entries(j).item;
                             a_slot := a_slot + 1;
				     
		             frame(a_slot).duration := integer(get_number_of_elements(frame(a_slot).emitters));
		             frame(a_slot).start_time := sched.entries(t).data.result.entries(j).item +frame(a_slot-1).duration ;
                             a_slot := a_slot + 1;
	             end if ; 
                     if task_wakeup_compute(sys, sched.entries(t).data.result.entries(j).data.end_task) > double(minimum_slot_number) then
                   --  Check if the task is already in the set
			    for i in slot_id_type'range loop
				    if  not is_empty(frame(i).emitters) then
					    reset_iterator(frame(i).emitters, my_iterator);
                                            found := false;
                            loop
			       	    current_element(frame(i).emitters, a_task, my_iterator);
                               -- put_line("TG = " & to_string(a_task.name));
                               -- put_line("TD = " & to_string(sched.entries(t).data.result.entries(j).data.end_task.name));
				    if a_task.name = sched.entries(t).data.result.entries(j).data.end_task.name then
					    found:=True;
                                    end if ;

                             exit when is_last_element(frame(i).emitters, my_iterator);
                             next_element(frame(i).emitters, my_iterator);
                            end loop;
		                    end if ;  
 
                            if found = false then
				    frame(a_slot).Slot_id := a_slot;
				    if get_number_of_elements(frame(a_slot).emitters) < 6 then
					    add(frame(a_slot).emitters, sched.entries(t).data.result.entries(j).data.end_task);
                                    end if;
				    frame(a_slot).duration := integer(get_number_of_elements(frame(a_slot).emitters));
                                    frame(a_slot).start_time := sched.entries(t).data.result.entries(j).item;
                                    frame(a_slot-1).duration := sched.entries(t).data.result.entries(j).item;
                                    a_slot := a_slot + 1;
				     
				    frame(a_slot).duration := 0 ;
                                    frame(a_slot).start_time := sched.entries(t).data.result.entries(j).item 
				    +frame(a_slot-1).duration ;

				    if get_number_of_elements(frame(a_slot).emitters) = 6 then
					    a_slot := a_slot + 1;
                                            frame(a_slot).Slot_id := a_slot;
                                            frame(a_slot).duration := 0;
                                            frame(a_slot).start_time := frame(a_slot-1).start_time + frame(a_slot-1).duration;
                                    end if;
			            if a_slot = 64 then
					    a_slot := 2;
                                    end if ;
			     end if ;  
 
	                     end loop;  
                     end if; 
            end if; 
       	end loop; 
     end loop;

end create_tdma_frame;



 procedure display_tdma_frame(frame : in tdma_frame_type) is

 begin
	for i in slot_id_type'range loop
		put_line("Slot id/start time/duration : " & frame(i).Slot_id'img & "/" & frame(i).start_time'img & "/" & frame(i).duration'img );
		put(frame(i).emitters);
	end loop;
end display_tdma_frame;


procedure apply_chetto(sys : in out system) is
       Tarb : natural := 0 ; 
       Tcom : natural := 1 ;
       deadline_e1_r1 : natural; 
       my_task : Generic_Task_Ptr ; 
       my_iterator_t  : tasks_iterator;

begin
-- Modifier l echeance des taches dans sys.tasks
-- ex : tache X de processor1 doit avoir l echeance min entre son échéance et la tache X_receiver de processor2
   
       reset_iterator (sys.tasks, my_iterator_t);

      loop
       	   current_element (sys.tasks, my_task, my_iterator_t);
	   my_task.deadline := periodic_task_ptr(my_task).period  ;
	   Put_Line ("Deadline of task_receiver :" & natural'image (my_task.deadline));  
	   deadline_e1_r1 := (my_task.deadline - my_task.capacity); 
	   my_task.deadline := Natural'Min (my_task.deadline , deadline_e1_r1 - Tcom - Tarb ); 
	   Put_Line ("Deadline of task_emitter : " & natural'image (my_task.deadline)); 

	   exit when is_last_element (sys.tasks, my_iterator_t);
           

           next_element (sys.tasks, my_iterator_t);

       end loop;
        



end apply_chetto;








end spacewire_analysis;
