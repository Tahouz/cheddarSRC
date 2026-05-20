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
--    $Rev: 3583 $
--    $Date: 2020-11-10 09:14:01 +0100 (mar. 10 nov. 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Calling PAES for the Task Clustering problem
-- To compile : make F2T_paes_method
-- To execute :
-- If we want to generate a task set :
--     ./F2T_paes_method -n <number_of_functions> -iter <iterations> -sched <scheduler_Name> -p <number_of_parellel_slaves> -select <selection_strategy>
--            -fitness <fitness_functions> -u <Total_cpu_utilization>  -n_diff_periods <Number_of_different_periods_in_the_function_set>
--            -n_res <Number_of_shared_resources> -rsf <resource_sharing_factor>
--
--
-- If we want to execute paes with a task set given in an xml file :
--     ./F2T_paes_method -n <number_of_functions> -i <xml_file_name> -iter <iterations> -sched <scheduler_Name> -p <number_of_parellel_slaves>
--	      -select <selection_strategy> -fitness <fitness_functions>
--
-- Examples: ./F2T_paes_method -n 6 -i initial_tasks_set.xmlv3 -iter 5000 -sched RM -select global -fitness "f1 f4"
--           ./F2T_paes_method -n 6 -iter 5000 -sched RM -select global -fitness "f1 f4" -u 90  -n_diff_periods 2  -n_res 2  -rsf 20
--           ./F2T_paes_method -n 6 -i initial_tasks_set.xmlv3 -iter 5000 -sched RM -select global -fitness "f1 f5 f3" -p 4 (for 4 parallel slaves)
--
-- Possible fitness functions:
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--	Minimization of preemptions
--
--		f1 => Min(number_of_preemptions)
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--	Minimization of context switches
--
--		f2 => Min(number_of_context_switches)
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--	Minimization of tasks (i.e. minimization of stack-memory)
--
--		f3 => Min(number_of_tasks)
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--	Maximization of the overall system laxity
--
--		f4 => Max(sum(laxities)) = Max(sum(Li)) = Max(sum(Di-Ri))
--
--		   => equivalent to:	Min (H0-sum(Li))
--
-- 		   H0 is the hyperperiod of the initial task set (H0 = LCM(Ti))
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--	Another function related to the system laxity
--
--		f5 => Max(sum(Li/Di)) = Max(sum(1-(Li/Di)))
--
--		   => equivalent to:   Min(sum(Ri/Di))
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--	Maximization of the minimum laxity
--
--		f6 => Max(min(Li))
--
--		   => equivalent to:   Min(H0-min(Li))
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--	Minimization of the overall worst case response time of tasks
--
--		f7 => Min(sum(Ri))
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--	Minimization of the maximum worst case response time
--
--		f8 => Min(max(Ri))
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--	Minimization of the overall worst case blocking time of tasks
--
--		f9 => Min(sum(Bi))
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
--	Minimization of the maximum worst case blocking time
--
--		f10 => Min(max(Bi))
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--	Minimization of shared resources (i.e. minimization of semaphores)
--
--		f11 => Min(number_of_resources)
--
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Text_IO;                           use Text_IO;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with unbounded_strings;                 use unbounded_strings;
with Ada.strings; use Ada.strings;
with Parameters;                        use Parameters;
with Parameters.extended;               use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;
with Systems;                           use Systems;
with Framework;                    	use Framework;
with Call_Framework;                    use Call_Framework;
with Call_Framework_Interface;          use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with Call_Scheduling_Framework;         use Call_Scheduling_Framework;

with Ada.Directories; use Ada.Directories;
with Ada.text_IO; use Ada.text_IO;
with Ada.Command_Line;  use Ada.Command_Line;
with GNAT.Command_Line; use GNAT.Command_Line;
with GNAT.OS_Lib;                       use GNAT.OS_Lib;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
with Ada.Strings; use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Directories; 			use Ada.Directories;
with Ada.Calendar; use Ada.Calendar;
with Ada.Calendar.Formatting;
use Ada.Calendar.Formatting;
with Ada.Text_IO; use Ada.Text_IO;

with architecture_factory; use architecture_factory;

with unbounded_strings;        use unbounded_strings;

with Tasks; use Tasks;

with Task_Set; use Task_Set;

With Resource_set; use Resource_set;

with Resources; use Resources;

with feasibility_test.feasibility_interval; use feasibility_test.feasibility_interval;
with feasibility_test.processor_utilization; use feasibility_test.processor_utilization;

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Directories; use Ada.Directories;

with scheduler_Interface; use scheduler_Interface;
with framework_config;  use framework_config;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with float_util; use float_util;
with Debug; use Debug;

with paes.chromosome_data_manipulation_f2t;
use paes.chromosome_data_manipulation_f2t;

with paes.objective_functions.function2task;
use paes.objective_functions.function2task;

with Paes.f2t; use Paes.f2t;

with Systems;               use Systems;
with paes.general_form_f2t;
with paes.objective_functions; use paes.objective_functions;
with Paes; use Paes;

procedure paes_method_f2t is

   procedure paes_F2T_architecture_exploration is new paes.general_form_f2t
     (init => paes.chromosome_data_manipulation_f2t.init_F2T,
      mutate => paes.chromosome_data_manipulation_f2t.mutate_F2T,
      evaluate => paes.objective_functions.function2task.evaluate_F2T);

   package Fix_IO is new Ada.Text_IO.Fixed_IO(DAY_DURATION); use Fix_IO;
   package Fl_IO is new Ada.Text_IO.float_IO(float); use fl_IO;

   My_System                      : System;
   Total_cpu_utilization          : float  := 0.00;
   N_diff_periods                 : Integer := 10;
   N_resources                    : Integer := 0;
   Resource_sharing_factor        : float := 0.00;
   critical_section_ratio         : float := 0.00;

   Dir                            : unbounded_string;
   Dir2                           : unbounded_string;
   Data,Data2                     : Unbounded_String;
   F                              : Ada.Text_IO.File_Type;


   dir1                           : unbounded_string_list;

   A_capacity                     : natural;
   A_period                       : natural;
   A_deadline                     : natural;


   F1,F2,F3,F4                    : Ada.Text_IO.File_Type;

   scheduler_Name                 : unbounded_String;
   initial_task_set_file_name     : unbounded_string;
   fitness_list,str,A_str         : unbounded_String;
   an_index                       : integer;

   --hyperperiod_candidate_task_set : integer;
   Max_hyperperiod                : integer;
   Processor_Utilization          : integer;
   actual_cpu_utilization         : float := 0.00;

   Start,Ends                     : Time;
   A_Duration                     : DURATION; --DAY_DURATION;
   v                              : integer;
   A_solution                     : solution_f2t;


   procedure Usage is
   begin
      New_Line;
      Put_Line ("paes_d is a program which from an initial schedulable task set,"
                & "generate with PAES the front pareto: a set of schedulable task sets.");

      New_Line;
      Put_Line("Check Cheddar home page for details :  http://beru.univ-brest.fr/~singhoff/cheddar ");
      New_Line;
      New_Line;
      Put_Line ("Usage : ./paes [switch] ");
      Put_Line ("   switch can be :");
      Put_Line ("            -h" & ASCII.HT & ASCII.HT &  ASCII.HT & ASCII.HT & ASCII.HT & "get this help");
      Put_Line ("            -n <number_of_functions>" & ASCII.HT & ASCII.HT & "the number of functions");
      Put_Line ("            -sched <scheduler_Name>" & ASCII.HT & ASCII.HT & "the scheduler can be RM or EDF ");
      Put_Line ("            -select <selection_strategy>" & ASCII.HT & ASCII.HT & "the selection strategy can be local (PAES original) or global");
      Put_Line ("            -iter <iterations>" & ASCII.HT & ASCII.HT & ASCII.HT & "the number of PAES iterations ");
      Put_Line ("            -i <xml_file_name>" & ASCII.HT & ASCII.HT & ASCII.HT & "the XML file contains the initial system i.e. each");
      Put_Line ("                              " & ASCII.HT & ASCII.HT & ASCII.HT &  "function is assigned to a task ");
      Put_Line ("            -u <total_cpu_utilization>" & ASCII.HT & ASCII.HT & "Total processor utilization ");
      Put_Line ("            -p <slaves>" &  ASCII.HT & ASCII.HT & ASCII.HT & ASCII.HT & "number parallel of slaves (default no slaves)");
      Put_Line ("            -n_diff_periods <Number_of_different_periods_in_the_function_set>" & ASCII.HT & "the number of different periods in the function set");
      Put_Line ("            -n_res <Number_of_shared_resources>" & ASCII.HT & "the number of shared resources in the function set");
      Put_Line ("            -rsf <Resource_sharing_factor>" & ASCII.HT & "the resource sharing factor");
      Put_Line ("            -fitness <fitness_functions>" & ASCII.HT & "the list of competing fitness functions (among the" 					& " following list) ");
      Put_Line ("                                        " & ASCII.HT & "used by PAES to drive the design space exploration:");
      Put_Line (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                & ASCII.HT & ASCII.HT & "Minimization of preemptions " & ASCII.LF
                & ASCII.HT & ASCII.HT & ASCII.HT & " F1 => Min(number_of_preemptions)");

      Put_Line (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                & ASCII.HT & ASCII.HT & "Minimization of context switches " & ASCII.LF
                & ASCII.HT & ASCII.HT & ASCII.HT & " F2 => Min(number_of_context_switches)");

      Put_Line (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                & ASCII.HT & ASCII.HT & "Minimization of tasks (i.e. minimization of stack-memory) " & ASCII.LF
                & ASCII.HT & ASCII.HT & ASCII.HT & " F3 => Min(number_of_tasks)");

      Put_Line (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                & ASCII.HT & ASCII.HT & "Maximization of the overall system laxity " & ASCII.LF
                & ASCII.HT & ASCII.HT & ASCII.HT & " F4 => Max(sum(laxities)) = Max(sum(Li)) = Max(sum(Di-Ri))" & ASCII.LF
                & ASCII.HT & ASCII.HT & ASCII.HT & "    => equivalent to:  Min (H0-sum(Li))");

      Put_Line (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                & ASCII.HT & ASCII.HT & "Another function related to the system laxity " & ASCII.LF
                & ASCII.HT & ASCII.HT & ASCII.HT & " F5 => Max(sum(Li/Di)) = Max(sum(1-(Li/Di)))" & ASCII.LF
                & ASCII.HT & ASCII.HT & ASCII.HT & "    => equivalent to:   Min(sum(Ri/Di))");

      Put_Line (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                & ASCII.HT & ASCII.HT & "Maximization of the minimum laxity " & ASCII.LF
                & ASCII.HT & ASCII.HT & ASCII.HT & " F6 => Max(min(Li))" & ASCII.LF
                & ASCII.HT & ASCII.HT & ASCII.HT & "    => equivalent to:   Min(H0-min(Li))");

      Put_Line (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                & ASCII.HT & ASCII.HT & "Minimization of the overall worst case response time of tasks " & ASCII.LF
                & ASCII.HT & ASCII.HT & ASCII.HT & " F7 => Min(sum(Ri))");

      Put_Line (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                & ASCII.HT & ASCII.HT & "Minimization of the maximum worst case response time " & ASCII.LF
                & ASCII.HT & ASCII.HT & ASCII.HT & " F8 => Min(max(Ri))");

      Put_Line (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                & ASCII.HT & ASCII.HT & "Minimization of the overall worst case blocking time of tasks " & ASCII.LF
                & ASCII.HT & ASCII.HT & ASCII.HT & " F9 => Min(sum(Bi))");

      Put_Line (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                & ASCII.HT & ASCII.HT & "Minimization of the maximum worst case blocking time " & ASCII.LF
                & ASCII.HT & ASCII.HT & ASCII.HT & " F10 => Min(max(Bi))");

      Put_Line (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                & ASCII.HT & ASCII.HT & "Minimization of shared resources (i.e. minimization of semaphores) " & ASCII.LF
                & ASCII.HT & ASCII.HT & ASCII.HT & " F11 => Min(number_of_resources)");

      Put_Line (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------");

      New_Line;
   end Usage;

begin

   Call_Framework.initialize (False);

   -- Get arguments
   --
   loop

      case GNAT.Command_Line.Getopt ("h n: sched: iter: i: u: p: fitness: select: n_diff_periods: n_res: rsf: csr: preprocessed_initial_sol") is
         when ASCII.NUL =>
            exit;

            -- parallel slaves. if = 0, then direct evaluation
	 when 'p' =>
	    if Full_Switch = "p" then
	       slaves := Integer'Value (GNAT.Command_Line.Parameter);
	       if slaves > MAX_SLAVES then
		  Put_Line ("too much slaves asked -- check MAX_SLAVES");
		  Usage;
		  OS_Exit (0);
	       end if;

	       if slaves < 1 then
		  Usage;
		  OS_Exit (0);
	       end if;

	       Put_Line ("Number of slaves = " & slaves'img);
	    end if;

	    if Full_Switch =  "preprocessed_initial_sol" then
	       Using_preprocessed_initial_sol := true;
	       Put_line ("Using the preprocessed initial solution");
	    end if;


         when 'n' =>
            if Full_Switch = "n" then
               genes := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Line ("Number of functions = " & genes'img);
            end if;
            if Full_Switch = "n_diff_periods" then
               N_diff_periods := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Line ("Number of different periods = " & N_diff_periods'img);
            end if;
            if Full_Switch = "n_res" then
               N_resources := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Line ("Number of resources = " & N_resources'img);
            end if;

         when 's' =>
            if Full_Switch = "sched" then
               scheduler_Name := To_Unbounded_String (GNAT.Command_Line.Parameter);
               Put_Line ("The scheduler is " & To_string(scheduler_Name));
               if scheduler_Name = "RM" then
                  The_Scheduler := Rate_Monotonic_Protocol;
                  Task_priority := 1;
                  Sched_policy  := SCHED_FIFO;
               elsif scheduler_Name = "EDF"  then
                  The_Scheduler := Earliest_Deadline_First_Protocol;
                  Task_priority := 0;
                  Sched_policy  := SCHED_OTHERS;
               else
                  Usage;
                  OS_Exit (0);
               end if;
            end if;
            if Full_Switch = "select" then
               A_str := To_Unbounded_String (GNAT.Command_Line.Parameter);
               if A_str = To_Unbounded_String("local") or A_str = To_Unbounded_String("global") then
                  A_SelectionStrategy := SelectionStrategy'Value(GNAT.Command_Line.Parameter);
                  Put_Line ("The Selection Strategy is " & A_SelectionStrategy'img);
               else
                  Usage;
                  OS_Exit (0);
               end if;
            end if;

         when 'i' =>
            if Full_Switch = "i" then
               initial_task_set_file_name := To_Unbounded_String (GNAT.Command_Line.Parameter);
               Put_Line ("The initial_task_set_file_name is " & To_string(initial_task_set_file_name));
            elsif Full_Switch = "iter" then
               iterations := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Line ("The number of iterations = " & iterations'img);
            end if;

         when 'u' =>
            Total_cpu_utilization := (Float'Value(GNAT.Command_Line.Parameter)/100.0);
            Processor_Utilization := Integer (Total_cpu_utilization * 100.0);
            Put ("The Total_cpu_utilization = ");
            fl_io.Put (Total_cpu_utilization, 8, 8, 0);
            Put (ASCII.LF);
            New_Line;

         when 'f' =>
            if Full_Switch = "fitness" then
               fitness_list := To_Unbounded_String (GNAT.Command_Line.Parameter);
               Put_Line ("The list of selected fitness functions is " & To_string(fitness_list));
            end if;

         when 'r' =>
            if Full_Switch = "rsf" then
               Resource_sharing_factor := (Float'Value(GNAT.Command_Line.Parameter)/100.0);
               Put ("The resource sharing factor = ");
               fl_io.Put (Resource_sharing_factor, 8, 8, 0);
               Put (ASCII.LF);
               New_Line;
            end if;

         when 'c' =>
            if Full_Switch = "csr" then
               critical_section_ratio := (Float'Value(GNAT.Command_Line.Parameter)/100.0);
               Put ("The critical section ratio = ");
               fl_io.Put (critical_section_ratio, 8, 8, 0);
               Put (ASCII.LF);
               New_Line;
            end if;

         when 'h' =>
            Usage;
            OS_Exit (0);

         when others =>
            Usage;
            OS_Exit (0);
      end case;
   end loop;

   create_system (My_system);

   initialize_FitnessFunctions;

   -- Customize PAES parameters according our problem :
   depth                 := 4;
   minmax                := 0;   -- minimization problem
   archive               := 200; -- the archive size is fixed to 200

   -- Interpret arguments to set Global variables
   --
   --
   -- 1) Initializing the list of selected objective functions
   --    and set the number of objectives
   --
   str := fitness_list;

   objectives := 1;
   Put_line ("List of fitness functions");
   Append (Data, "List of fitness functions" & ASCII.LF);

   while index(str, "f") /= 0 loop

      if index(Unbounded_Slice(str, index (str, "f") + 1, length(str)), "f") /= 0 then
         an_index :=  Integer'Value(To_String(Unbounded_Slice(str, index (str, "f") + 1, index (str, " ") - 1)));
         str := Unbounded_Slice(str, index (str, " ") + 1, length(str));
         objectives := objectives + 1;
      else
         an_index :=  Integer'Value(To_String(Unbounded_Slice(str, index (str, "f") + 1, length(str))));
         str := empty_string;
      end if;
      FitnessFunctions(an_index).Is_selected := 1;
      Put_Line(ASCII.HT & Suppress_Space (To_Unbounded_String ("f" & an_index'Img)) & " => " & FitnessFunctions(an_index).Name);
      Append (Data, ASCII.HT & Suppress_Space (To_Unbounded_String ("f" & an_index'Img))
              & " => " & FitnessFunctions(an_index).Name & ASCII.LF);
   end loop;

   -- 2) set the number of slaves, if the latter exceeds
   --    the number of iterations
   --
   if (iterations < slaves) then
      -- slaves correspond to the number of process that can be run in parallel
      -- it depends on the parallel machine capacities
      slaves:=iterations;
   end if;

   -- 3) Initialize the initial design either from the CheddarADL model
   --  provided by the user or. generating a design using parameters
   --  provided by the user (e.g. genes i.e. #functions, Total_cpu_utilization,
   --  N_diff_periods, #resources, Resource_sharing_factor,
   --  critical_section_ratio)
   --
   Initialize(Initial_System);
   for i in 1..genes loop
         A_solution.chrom_task(i) := i;
   end loop;

   if (Length (initial_task_set_file_name) /= 0) then

      -- we use the CheddarADL design described in the xml file given in argument
      --
      Ada.text_IO.put_line ("Initial_task_set_file_name : "
                            & To_string(initial_task_set_file_name));

      Read_From_Xml_File (My_System, dir1, initial_task_set_file_name);

      Hyperperiod_of_Initial_Taskset := Scheduling_Period
        (My_System.Tasks, to_unbounded_string("processor1"));

      Initial_System := My_System;
      -- Check the feasibility of the design given by the user
      --
      if Check_Feasibility_of_A_Solution (A_solution,0) then
         Put_Debug ("The initial design is schedulable");
      else
         Put_Debug ("The initial design is not schedulable!");
         return;
      end if;

   elsif (Total_cpu_utilization /= 0.00) then
      -- We use the provided processor utilization to generate
      -- a schedulable design model
      --
      Put_Debug ("generate a task set of " & genes'img
                 & " tasks with a total processor utilization" & Total_cpu_utilization'img );

      Create(F4,Ada.Text_IO.Out_File,"task_set_generation_runtime.txt");
      start := Clock;

      loop
         Generate_A_Customized_Ravenscar_System
           (my_system               => My_system,
            N                       => genes,
            Target_cpu_utilization  => Total_cpu_utilization,
            Current_cpu_utilization => actual_cpu_utilization,
            N_diff_periods          => N_diff_periods,
            N_resources             => N_resources,
            rsf                     => Resource_sharing_factor,
            csr                     => critical_section_ratio,
            A_sched_policy          => Sched_policy);

         Hyperperiod_of_Initial_Taskset := Scheduling_Period
           (Initial_System.Tasks, to_unbounded_string("processor1"));

         Initial_System := My_System;

         exit when Check_Feasibility_of_A_Solution(A_solution,0);

      end loop;

      Ends := Clock;
      A_Duration := Ends - Start;
      Put("Task_set_generation_time " & ASCII.HT & ASCII.HT & ": ");
      Put(A_Duration, 8, 8, 0);
      Put(" seconds");
      Put_Debug("");

      Put(F4, A_Duration, 8, 8, 0);
      Close(F4);

      Delay(1.0);

      Create(F1,Ada.Text_IO.Out_File,"current_cpu_utilization.txt");
      Put(F1, format(actual_cpu_utilization));
      Close(F1);

      Create(F2,Ada.Text_IO.Out_File,"error_cpu_utilization_generation.txt");
      Put(F2, format(ABS(Total_cpu_utilization - actual_cpu_utilization)));
      Close(F2);

      initial_task_set_file_name := To_Unbounded_String("initial_design.xmlv3");

      Initial_System := My_system;

   else

      Usage;
      OS_Exit (0);

   end if;

   Write_To_Xml_File(A_System  => Initial_System,
                     File_Name => "initial_design.xmlv3");


   Append (Data, " depth = " & depth'Img
           & "   iterations = " & iterations'Img
           & ASCII.LF);


   actual_cpu_utilization := Float (Processor_Utilization_Over_Period
     (Initial_System.Tasks, to_unbounded_string("processor1")));


   for i in 1..genes loop

      A_capacity := Task_Set.Get (My_Tasks   => Initial_System.Tasks,
                                  Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & i'Img)),
                                  Param_Name => Capacity);

      A_period := Task_Set.Get (My_Tasks   => Initial_System.Tasks,
                                Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & i'Img)),
                                Param_Name => Period);

      A_deadline := Task_Set.Get (My_Tasks   => Initial_System.Tasks,
                                  Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & i'Img)),
                                  Param_Name => Deadline);

      Put_Debug ("      C" & i'Img & " = " & A_capacity'Img);
      Put_Debug ("      T" & i'Img & " = " & A_period'Img);
      Put_Debug ("      D" & i'Img & " = " & A_deadline'Img);


   end loop;

   Put(ASCII.LF);
   Put ("The actual processor utilization is : ");
   fl_io.Put (actual_cpu_utilization, 8, 8, 0);
   Put_Debug(" ");--New_Line;

   Put(ASCII.LF);
   Put_Line ("The hyperperiod of the initial task set = " & Hyperperiod_of_Initial_Taskset'Img);
   Max_hyperperiod := Hyperperiod_of_Initial_Taskset;
   Put (ASCII.LF);

   Create(F, Ada.Text_IO.Out_File, "execution_trace.txt");
   Unbounded_IO.Put_Line(F, Data);
   Close(F);

   -- initialize One_to_one_mapping_solution
   for i in 1 .. genes loop
      One_to_one_mapping_solution.chrom_task (i) := i;
   end loop;



   if  Using_preprocessed_initial_sol then
      If Check_Feasibility_of_A_Solution (One_to_one_mapping_solution, 0) then
	 evaluate_F2T (One_to_one_mapping_solution, 0);
      end if;
      add_to_archive(One_to_one_mapping_solution);
      update_grid (One_to_one_mapping_solution);
   end if;

   ------------------------------------------------------------------------
   ------------------------------------------------------------------------
   -- Run PAES for the F2T architecture exploration problem ---------------
   ------------------------------------------------------------------------
   ------------------------------------------------------------------------
   Start := Clock;

   -- Running PAES
   paes_F2T_architecture_exploration;

   Ends := Clock;
   A_Duration := Ends - Start;
   Put("Paes_runtime" & ASCII.HT & ":");
   Put(A_Duration, 8, 8, 0);
   Put(" seconds");
   Put_Debug("");

   Create(F3,Ada.Text_IO.Out_File,"runtime.txt");
   Put(F3, A_Duration, 8, 8, 0);
   Close(F3);

   Ada.Strings.Unbounded.Delete(Data, 1, Length(Data));


   New_line;
   New_line;
   Append (Data, ASCII.LF);
   Append (Data, ASCII.LF);
   Put_Line("====================================================================================================== ");
   Put_Line("    The final Archive length = " & arclength'Img);
   Put_Line("    The final Archive is now... ");
   Append (Data,"======================================================================================"
           & "================ "  & ASCII.LF
           & "    The final Archive length = " & arclength'Img & ASCII.LF
           & "    The final Archive is now... " & ASCII.LF);



   for i in 1..arclength loop
      for k in 1 .. objectives loop
         Append (Data2, arc(i).obj(k)'Img & " ");
      end loop;
      Append (Data2,  ASCII.LF);
      --Append(Data2, arc(i).obj(1)'Img & " " & arc(i).obj(2)'Img & ASCII.LF);--& " " & arc(i).obj(3)'Img & ASCII.LF);

      Put_Line("-------------------------------------------------------------------------------------------------------");
      Append (Data, "-------------------------------------------------------------------------------------------------------"
              & ASCII.LF
              & "Solution " & i'img & ":  ");
      Put("Solution " & i'img & ":  ");
      print_genome(arc(i));
      for l in 1..genes loop
         Append (Data, arc(i).chrom_task(l)'Img & " ");
      end loop;
      Append (Data, ASCII.LF);

      Transform_Chromosome_To_CheddarADL_Model(My_system , arc(i));
      Write_To_Xml_File (A_System  => My_system,
                         File_Name => To_string (Suppress_Space (To_Unbounded_String ("solution" & i'Img & ".xmlv3"))));

      Put_Line("Objectives of solution " & i'img & " : ");
      Append (Data, "Objectives of solution " & i'img & " : " & ASCII.LF);

      v := 0;

      for e in 1 .. MAX_FITNESS loop

         if 	FitnessFunctions(e).Is_selected = 1 then
            v := v + 1;
            Append (Data, "  |  " & FitnessFunctions(e).Name & " = ");
            Put ("  |  " & FitnessFunctions(e).Name & " = " );
            If (e = 4) or (e = 6) then
               str := format (Float(Hyperperiod_of_Initial_Taskset) - arc(i).obj(v));
            else
               str := format (arc(i).obj(v));
            end if;
            Put(str);
            Append (Data,str);
         end if;
      end loop;
      Put_line ("  |");
      Put_Line("-------------------------------------------------------------------------------------------------------");
      Append (Data,  "  |" & ASCII.LF);
      Append (Data, "-------------------------------------------------------------------------------------------------------"
              & ASCII.LF);

   end loop;

   Put_Line(" ==================================================== "
            & " ================================================== ");

   Append (Data, "======================================================="
           & "=============================================== " & ASCII.LF);


   open(F,Ada.Text_IO.Append_File, "execution_trace.txt");
   Unbounded_IO.Put_Line(F, Data);
   Close(F);


   Create(F2,Ada.Text_IO.Out_File,"front.dat");
   Unbounded_IO.Put_Line(F2, Data2);
   Close(F2);

   Put_Line ("The hyperperiod of initial solution: " & Hyperperiod_of_Initial_Taskset'img);
   Put_Line ("The maximum hyperperiod of candidate solution: " & Max_hyperperiod'img);




end paes_method_f2t;


