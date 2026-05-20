
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

with Random_Tools; use Random_Tools;
with Ada.Float_Text_IO;

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Unbounded_Strings; use Unbounded_Strings;
with convert_unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
use unbounded_strings.strings_table_package;
with Ada.Strings; use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;

with architecture_factory; use architecture_factory;

with Ada.text_IO; use Ada.text_IO;
with Ada.Integer_text_IO; use Ada.Integer_text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;

with Task_Set; use Task_Set;
with Tasks; use Tasks;
with Systems;  use Systems;
with Processors;          use Processors;
with Processor_Set;       use Processor_Set;
with processor_interface; use processor_interface;

with Core_Units; use Core_Units;
use Core_Units.Core_Units_Table_Package;
with Scheduler_Interface; use Scheduler_Interface;

--with Processors.extended; use Processors.extended;
with Address_Spaces;      use Address_Spaces;
with Address_Space_Set;   use Address_Space_Set;

with Call_Framework;                    use Call_Framework;
with Call_Framework_Interface;          use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with Call_Scheduling_Framework;         use Call_Scheduling_Framework;

with natural_util; 		use natural_util;
with feasibility_test.feasibility_interval; use feasibility_test.feasibility_interval;

with Pipe_Commands; use Pipe_Commands;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with unbounded_strings; use unbounded_strings;
with convert_unbounded_strings;
with Ada.Directories; use Ada.Directories;
with Paes_For_Clustering; use Paes_For_Clustering;
with Debug; use Debug;

with integer_util; use integer_util;

with Resources; use Resources;
use Resources.Resource_Accesses;
with float_util; use float_util;

package body Task_Clustering_Rules is
 
  -------------------------------------------
  -- Generate_initial_schedulable_task_set --
  -------------------------------------------

  procedure Generate_initial_schedulable_system
     (my_system        : in out System;
      N                : in Integer;
      U 	       : in Float;
      N_diff_periods   : in Integer;
      N_resources      : in Integer;
      rsf              : in Float;
      csr	       : in Float)
  is
   
      use Ada.Float_Text_IO;

      FileStream  	   		: stream;
      command     	   		: unbounded_String;
      F,F1,F2          	   		: Ada.Text_IO.File_Type;
      line        	   		: unbounded_String;
      Buffer      	   		: unbounded_String;
      hyperperiod 	   		: integer;
      My_resources 	   		: Resources_set;
      my_tasks         	   		: Tasks_Set;
      current_U		   		: float;
      suited_current_cpu_utilization	: boolean := false;
      schedulable 			: boolean := false;
      Variation_percentage 		: float := 0.09;   -- Tolerated percentage of variation from the target cpu_utilization

  begin

     Call_Framework.initialize (False);

     while not schedulable or  not suited_current_cpu_utilization loop
	suited_current_cpu_utilization	:= false;
        schedulable := false;
	current_U := 0.0;

	Create_Independant_Periodic_TaskSet_System
     		(S			  => my_system,
		 Current_cpu_utilization  => current_U,
      		 N_Tasks          	  => N,
      		 Target_cpu_utilization   => U,
      		 D_Min	       		  => 1.0,
      		 D_Max	       		  => 1.0,
      		 Is_synchronous		  => true,
      		 N_Different_Periods	  => N_diff_periods, --10,
      		 A_sched_policy		  => Sched_policy);

	Add_Resource_Set_To_System
	       (S			  => my_system,
      		N_Resources		  => N_resources,
      		Resource_sharing_factor	  => rsf,
		critical_section_ratio    => csr); 

	Write_To_Xml_File(A_System  => my_system,
                          File_Name => "candidate_solution 0.xmlv3");
	
        Hyperperiod := Scheduling_Period (my_system.Tasks, to_unbounded_string("processor1"));
	Put_line ("hyper_period = " & Hyperperiod'img);
      
        if current_U <= 1.0 then

     		command  := To_Unbounded_String("~/call_cheddar "  
                  	                        & Hyperperiod'img
                  	                        & " candidate_solution\ 0.xmlv3");

		FileStream := execute(To_String(command), read_file);
        
        	loop
           	begin
                	Buffer := read_next(FileStream);
           	exception
                	when Pipe_Commands.End_of_file => 
                	      exit;
           	end;
        	end loop;
          
        	close(FileStream);

        	Open(F, Ada.Text_IO.In_File,"Output 0.txt");
        	line := To_Unbounded_String(get_line(F));
   
        	if line = "schedulability : true" then
             		schedulable := true;
             		Initial_System := my_system;
        	end if; 
             
        	Close(F);     

        end if;

	if ABS(U - current_U) <= Variation_percentage then
		suited_current_cpu_utilization := true;
	end if;

     end loop;

     Create(F1,Ada.Text_IO.Out_File,"current_cpu_utilization.txt");
     Put(F1, format(current_U));
     Close(F1);

     Create(F2,Ada.Text_IO.Out_File,"error_cpu_utilization_generation.txt");
     Put(F2, format(ABS(U - current_U)));
     Close(F2);        

  end Generate_initial_schedulable_system;

  ---------------------
  -- number_of_tasks --
  ---------------------

  function Number_of_tasks (s : in solution) return integer is
    permutation : integer := 1;
    var : chrom_type;
    nb_tasks, tmp : integer;
  begin
    --  assignment of the table var with elements of s.chrom
    for i in 1..genes loop 
       var(i) := s.chrom(i);
    end loop;

    --  sorting elements of var in the increasing order
    while permutation = 1 loop
      permutation := 0;
      for i in 1..genes-1 loop
        if (var(i) > var(i+1)) then
          tmp := var(i);
          var(i) := var(i+1);
          var(i+1) := tmp;
          permutation := 1;
        end if;
      end loop;
    end loop; 

    nb_tasks := genes;

    for i in 1..genes-1 loop
      if (var(i) = var(i+1)) then
         nb_tasks := nb_tasks - 1;
      end if;
    end loop;

    return nb_tasks;

  end Number_of_tasks;


  ------------------------------
  -- Appling_clustering_rules --
  ------------------------------

  procedure Appling_clustering_rules (A_sys : in out System; s : in solution) is

     A_Tasks_set                        : Tasks_Set;
     A_Task                	 	: Periodic_Task;
     nb_tasks,k,A_function_index    	: integer;
     period_i, period_j    	 	: natural;
     capacity_i, capacity_j	 	: natural;
     deadline_i, deadline_j  	 	: natural;
     var                    	 	: chrom_type;
     A_task_name			: Unbounded_String;

     Initial_number_of_resources 	: Resources_Range;
     Nb_critical_sections_of_Resource_i : Resource_Accesses_Range;
     A_Resources_set           	 	: Resources_Set;
     A_resource 			: Generic_Resource_Ptr;
     r                                  : critical_section;
     rt, rt2           		        : Resource_Accesses_Table;
     Is_shared				: boolean;
     tab				: array (Resource_Accesses_Range) of integer;
  begin

     -- 1) Generate the tasks set from the solution s
     --
     nb_tasks := number_of_tasks(s);

     Initialize (A_Task);

     for i in 1..genes loop
        var(i) := 0;
     end loop;
 
     k := 1;
       
     for i in 1..genes loop

          Put_Debug ("i = " & i'img); 
          Initialize (A_Task);

          if var(i) = 0 then

             var (i) := 1; 
            
             period_i   := Get (My_Tasks   => Initial_system.Tasks, 
                                Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & i'Img)),
                                Param_Name => Period);
	     Put_Debug ("period_i = " & period_i'img); 
             capacity_i := Get (My_Tasks   => Initial_system.Tasks, 
                                Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & i'Img)),
                                Param_Name => Capacity);
	     Put_Debug ("capacity_i = " & capacity_i'img); 
             deadline_i := Get (My_Tasks   => Initial_system.Tasks, 
                                Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & i'Img)),
                                Param_Name => Deadline);
             Put_Debug ("deadline_i = " & deadline_i'img); 

             for j in i+1 .. genes loop

                 if (s.chrom(i) = s.chrom(j)) then

                     var (j) := 1;

                     period_j   := Get(My_Tasks   => Initial_system.Tasks, 
                                       Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & j'Img)),
                                       Param_Name => Period);
                     
                     capacity_j := Get(My_Tasks   => Initial_system.Tasks, 
                                       Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & j'Img)),
                                       Param_Name => Capacity);

                     deadline_j := Get(My_Tasks   => Initial_system.Tasks, 
                                       Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & j'Img)),
                                       Param_Name => Deadline);

                     if (A_Task.period = 0) then
                     
                         A_Task.capacity := capacity_i + capacity_j;     

                         if period_i > period_j then
                             A_Task.period := period_j;
                         else
                             A_Task.period := period_i;
                         end if;

                         if deadline_i > deadline_j then
                             A_Task.deadline := deadline_j;
                         else
                             A_Task.deadline := deadline_i;
                         end if;

                     else

                         A_Task.capacity := A_Task.capacity + capacity_j;

                         if A_Task.period > period_j then
                             A_Task.period := period_j;
                         end if;

                         if A_Task.deadline > deadline_j then
                             A_Task.deadline := deadline_j;
                         end if;

                     end if;
             
                 end if;   
            
             end loop;

             if (A_Task.period = 0) then

                 A_Task.period   := period_i;
                 A_Task.capacity := capacity_i;
                 A_Task.deadline := deadline_i;

             end if;
   	     
            Add_Task(My_Tasks                => A_Tasks_set, 
                     Name                    => Suppress_Space (To_Unbounded_String ("Task" & k'Img)),
                     Cpu_Name                => To_Unbounded_String("processor1"),
                     Address_Space_Name      => To_Unbounded_String("addr1"),
                     Task_Type               => Periodic_Type,
                     Start_Time              => 0,
                     Capacity                => A_Task.capacity,
                     Period                  => A_Task.period,
                     Deadline                => A_Task.deadline,
                     Jitter                  => 0,
                     Blocking_Time           => 0,
                     Priority                => Task_priority,
                     Criticality             => 0,
                     Policy                  => Sched_policy);
              
              k := k + 1;
                     
          end if;

     end loop;

     A_sys.Tasks := A_Tasks_set;

     -- 2) Deduce the resources set from the solution s
     
     Initial_number_of_resources := Get_Number_Of_Resource_From_Processor
     					(Initial_system.Resources, To_Unbounded_String("processor1"));

     Put_debug ("Initial_number_of_resources = " & Initial_number_of_resources'img);

     for i in 1 .. Initial_number_of_resources loop

	Initialize(rt);

	-- Extracting all resources of the initial system model
	-- in which each function is assigned to a task
	-- So, in the initial system model there is no difference
	-- between a task or a function   (Function1 == Task1)

	A_resource := search_Resource (Initial_System.Resources,
				       suppress_space (To_Unbounded_String ("R" & i'Img)));

	Nb_critical_sections_of_Resource_i := A_resource.critical_sections.nb_entries;
	
     	for j in 0 .. Nb_critical_sections_of_Resource_i - 1 loop 	
		-- A task name is in the form "Taskxxx" 
		-- where xxx is the index of the task (i.e the function)
		-- Here, we trait resources of the initial model
		-- were each Task represent a function i.e. Task1 => Function1
		-- Task2 => Function2 ...
		A_task_name := A_resource.Critical_sections.entries(j).item;
		A_function_index := Integer'Value 
			(to_string (Unbounded_Slice (A_task_name,length(To_Unbounded_String("Task"))+1,length(A_task_name))));
                -- Compute new critical_section_j of the Resource_i 
                k := 1;
		r.task_begin := A_resource.Critical_sections.entries(j).data.task_begin;
		r.task_end := A_resource.Critical_sections.entries(j).data.task_end;
		While (k < A_function_index) loop 
			if s.chrom(k) = s.chrom(A_function_index) then
			     r.task_begin := r.task_begin
					      + Get (My_Tasks   => Initial_system.Tasks, 
                                       		     Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & k'Img)),
                                       		     Param_Name => Capacity);
			     r.task_end := r.task_end
					      + Get (My_Tasks   => Initial_system.Tasks, 
                                       		     Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & k'Img)),
                                       		     Param_Name => Capacity);
			end if;
			k := k + 1;
                end loop;
		-- Add the computed critical_section_j to the table of 
		-- critical sections of the Resource_i 
		add (rt, Suppress_Space (To_Unbounded_String ("Task" & Integer'Image(s.chrom(A_function_index)))), r);   
         	
     	end loop;
	
	-- There is two cases that we have to deal with :
	--	
	--1) Case_1 : Check if there are consecutive critical sections for the same task
	-- For example, the computation of new critical-sections (CSs) according to the solution s,
	-- gives the following CSs: 
	--	Task1	task_begin=2	task_end=3  (**)   -- the function accessing the CS is assigned to Task1
	-- 	Task2	task_begin=1	task_end=1  	   -- the function accessing the CS is assigned to Task2
	-- 	Task1	task_begin=4	task_end=4  (**)   -- the function accessing the CS is assigned to Task1
	--
	-- => The two critical-sections marked (**) are consecutive, so It's better
	--    to merge them in the same CS, the resulting CSs are :
	--	Task1	task_begin=2	task_end=4  
	-- 	Task2	task_begin=1	task_end=1   
	--
	-- 2) Case_2 : Check if the resource_i is accessed by a single task i.e all 
	-- critical sections  of the resource_i corresponds to the same task,
	-- in other words, all functions that access the resource_i are assigned
	-- to the same task.
	-- For example, the computation of new critical-sections (CSs) according to the solution s,
	-- gives the following CSs:
	-- 	Task1	task_begin=2	task_end=3  
	-- 	Task1	task_begin=1	task_end=1
	-- 	Task1	task_begin=5	task_end=6  
	--
	-- => In this case, the resource_i is used only by the Task1, so It is no longer shared
	--    between tasks, for that, we no longer need to consider it in the conccurency model
	--    (i.e the analysis model) 
	--  
	--  
	Is_shared := false;

	for j in 0 .. rt.nb_entries - 1 loop
		tab(j) := 0;
	end loop;

	
	for j in 0 .. rt.nb_entries - 1 loop		
	   if tab(j) = 0 then
		tab(j) := 1;
		for l in j+1 .. rt.nb_entries - 1 loop
		    if tab(l) = 0 then
		       if (rt.entries(j).item = rt.entries(l).item) then
			   tab(l) := 1;
			   -- check if critical sections of rt.entries(l) and rt.entries(j) are consecutive 
			   if (rt.entries(l).data.task_begin = (rt.entries(j).data.task_end + 1)) then
				rt.entries(j).data.task_end := rt.entries(l).data.task_end;
				tab(l) := 2; -- rt.entries(l) sould be deleted after because, 
					     -- its critical section is concatenated in the 
					     -- critical section of rt.entries(j)
			   elsif (rt.entries(j).data.task_begin = (rt.entries(l).data.task_end + 1)) then
				rt.entries(j).data.task_begin := rt.entries(l).data.task_begin;
				tab(l) := 2; -- rt.entries(l) sould be deleted after because
					     -- its critical section is concatenated in the 
					     -- critical section of rt.entries(j)
			   end if;
		       else
			   -- The resource_i is shared by at least 2 tasks
			   Is_shared := true; 	
		       end if;
		    end if;    
		end loop;
	   end if;		 	
	end loop; 
	
	-- delete rt.entries(l) whose critical sections are merged in other critical sections  
	Initialize (rt2);
        for j in 0 .. rt.nb_entries - 1 loop
	   if tab(j) /= 2 then
		rt2.entries(rt2.nb_entries) := rt.entries(j); 
		rt2.nb_entries := rt2.nb_entries + 1;
	   end if;
	end loop;
	
	-- Add the resource to the system "A_sys" only if 
	-- it is shared by at least 2 tasks
	if Is_shared then
	    Add_Resource (A_Resources_set,
                          suppress_space (To_Unbounded_String ("R" & i'Img)),
                          1,
                          0,
                          0,
                          To_Unbounded_String ("processor1"),
                          To_Unbounded_String ("addr1"),
                          Priority_Ceiling_Protocol,
                          rt2,
                          0,
                          Automatic_Assignment);
         end if; 

     end loop;
			
     A_sys.Resources := A_Resources_set;

  end Appling_clustering_rules;

  -------------------
  -- Create_system --
  -------------------
  
  Procedure Create_system (A_system     : in out System) is
     
      a_core : core_unit_ptr;

  begin
  
      Initialize(A_System);

      Add_Address_Space(A_System.address_spaces, to_unbounded_string("addr1"), to_unbounded_string("processor1"), 0, 0, 0, 0);

      Add_core_unit(My_core_units        => A_System.core_units,
                    A_core_unit          => a_core,
                    Name                 => to_unbounded_string("core1"),
                    Is_Preemptive        => preemptive,
                    Quantum              => 0,
                    speed                => 1.0,
                    capacity             => 0,
                    period               => 0,
                    Priority             => 0,
                    File_Name            => to_unbounded_string(""),
                    A_Scheduler          => The_scheduler);


      Add_Processor(My_Processors => A_System.processors,
                    Name          => to_unbounded_string("processor1"),
                    a_Core        => a_core);

   end Create_system;

  -------------------------------------
  -- Check_Consistency_Of_A_Solution --
  -------------------------------------

  function Check_Consistency_Of_A_Solution (s : in solution) return boolean is

      Is_consistent			: boolean;      
      min_periods               	: Integer;
      nb_tasks				: Integer;
      gcd_periods               	: Integer;
      i                         	: Integer;
      nb_functions_in_task_i    	: Integer;
      periods_array             	: array (1 .. genes) of Integer;
      Initial_Taskset           	: Tasks_Set := Initial_system.Tasks;
      A_System				: System;
      capacity_i, deadline_i, period_i 	: integer;
      Total_Processor_Utilization	: float;
  begin
      
      
      Is_consistent := true;

      nb_tasks := number_of_tasks(s);

      Create_system (A_System);
      Appling_clustering_rules (A_System, s);
      
      -- 1) Check for each task of the candidate solution that Ci <= Di 
      -- 2) Check that the total processor Utilization <= 1
      i := 1;
      Total_Processor_Utilization := 0.0;

      while (i<= nb_tasks) and Is_consistent loop
	   
	   capacity_i := Get(My_Tasks   => A_system.Tasks, 
                             Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & i'Img)),
                             Param_Name => Capacity);

	   deadline_i := Get(My_Tasks   => A_system.Tasks, 
                             Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & i'Img)),
                             Param_Name => Deadline);

	   period_i := Get(My_Tasks   => A_system.Tasks, 
                           Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & i'Img)),
                           Param_Name => Period);

	   if capacity_i > deadline_i then
		Is_consistent := false;
	   end if;

	   Total_Processor_Utilization := Total_Processor_Utilization + Float(capacity_i) / Float(period_i);
	   i := i + 1;
      end loop;   

      if Is_consistent then 
          if (Total_Processor_Utilization > 1.0) then
	     Is_consistent := false;
          end if;
      end if;

      -- 3) check if there are two non-harmonic functions which are 
      -- grouped alone in the same task.
      i := 1;

      while (i<= nb_tasks) and Is_consistent loop

          nb_functions_in_task_i := 0;

          for j in 1 .. genes loop

          	if (s.chrom(j) = i) then
                   nb_functions_in_task_i := nb_functions_in_task_i + 1;
                   periods_array (nb_functions_in_task_i) := 
                              Get(My_Tasks   => Initial_Taskset, 
                                  Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & j'Img)),
                                  Param_Name => Period);
                   
                 end if;

          end loop;
          
          if (nb_functions_in_task_i = 2) then

             if ( periods_array(1) < periods_array(2) ) then
             	  min_periods := periods_array(1);
             else 
                  min_periods := periods_array(2);	   
             end if;

             gcd_periods := integer_util.gcd (periods_array(1) , periods_array(2));
      
             if (min_periods /= gcd_periods) then
                  Is_consistent := false;
             end if;


          elsif (nb_functions_in_task_i > 2) then

              min_periods := periods_array(1);

              gcd_periods := integer_util.gcd (periods_array(1) , periods_array(2));

              for j in 2 .. nb_functions_in_task_i loop
                  
                  if (periods_array(j) < min_periods) then
                       
                      min_periods := periods_array(j);

                  end if;
                  
                  if (j < nb_functions_in_task_i) then

                  	gcd_periods := integer_util.gcd (gcd_periods, periods_array(j+1));

                  end if;

              end loop; 
          
              if (min_periods /= gcd_periods) then
                  Is_consistent := false;
              end if;

          else 
              Is_consistent := true;
          end if;
      
          i := i + 1;
    
      end loop;   
      
      return Is_consistent;

   end Check_Consistency_Of_A_Solution;

end Task_Clustering_Rules;
