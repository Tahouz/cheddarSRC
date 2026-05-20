
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

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Calling PAES for the Task Clustering problem
-- To compile : make paes
-- To execute :
-- If we want to generate a task set :
--     ./paes -n <number_of_functions> -iter <iterations> -sched <scheduler_Name> -p <number_of_parellel_slaves> -select <selection_strategy>
--            -fitness <fitness_functions> -u <Total_cpu_utilization>  -n_diff_periods <Number_of_different_periods_in_the_function_set>
--            -n_res <Number_of_shared_resources> -rsf <resource_sharing_factor>
--
--
-- If we want to execute paes with a task set given in an xml file :
--     ./paes -n <number_of_functions> -i <xml_file_name> -iter <iterations> -sched <scheduler_Name> -p <number_of_parellel_slaves>
--	      -select <selection_strategy> -fitness <fitness_functions>
--
-- Examples: ./paes -n 6 -i initial_tasks_set.xmlv3 -iter 5000 -sched RM -select global -fitness "f1 f4"
--           ./paes -n 6 -iter 5000 -sched RM -select global -fitness "f1 f4" -u 90  -n_diff_periods 2  -n_res 2  -rsf 20
--           ./paes -n 6 -i initial_tasks_set.xmlv3 -iter 5000 -sched RM -select global -fitness "f1 f5 f3" -p 4 (for 4 parallel slaves)
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

with Paes_For_Clustering;
with Paes; use Paes;

with unbounded_strings;        use unbounded_strings;

with Tasks; use Tasks;

with Task_Set; use Task_Set;

With Resource_set; use Resource_set;

with Resources; use Resources;

with Task_Clustering_Rules; use Task_Clustering_Rules;

with feasibility_test.feasibility_interval; use feasibility_test.feasibility_interval;

with Pipe_Commands; use Pipe_Commands;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Directories; use Ada.Directories;
with Paes_For_Clustering; use Paes_For_Clustering;
with Hypervolume_computation; use Hypervolume_computation;
with scheduler_Interface; use scheduler_Interface;
with framework_config;  use framework_config;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with float_util; use float_util;
with Debug; use Debug;


procedure call_paes  is

   procedure init is new Paes.init (Paes_For_Clustering.init_for_clustering);
   procedure mutate is new Paes.mutate (Paes_For_Clustering.mutate_for_clustering);
   procedure evaluate is new Paes.evaluate (Paes_For_Clustering.evaluate_for_clustering);

   package Fix_IO is new Ada.Text_IO.Fixed_IO(DAY_DURATION); use Fix_IO;
   package Fl_IO is new Ada.Text_IO.float_IO(float); use fl_IO;

   -- for parallel execution
   -- a ToDo and a Done lists, protected by a mutex
   ToDoSolList	: array(0..MAX_SLAVES) of solution;
   ToDoIndex    : integer := 0;
   DoneSolList	: array(0..MAX_SLAVES) of solution;
   DoneIndex    : integer := 0;

   task type Mutex is
      entry P;
      entry V;
      entry E;
   end Mutex;

   task body Mutex is
      finished : boolean := false;
   begin
      loop
         select
            accept P;
         or
            accept E do
               finished := true; -- loop
            end E;
         end select;
         if (not finished) then
            accept V;
         else
            exit;
         end if;
      end loop;
   end Mutex;

   DoneSolMutex : mutex;
   TodoSolMutex : mutex;

   task type slave_task;
   task body slave_task is
      found : integer;
      tomute : solution;
      eidx : integer;
   begin
      loop
         loop
            found := 0;
            ToDoSolMutex.P;
            if ToDoIndex > 0 then
               ToDoIndex := ToDoIndex - 1;
               tomute := ToDoSolList(ToDoIndex);
               found := 1;
            end if;
            ToDoSolMutex.V;
            if found = 1 then
               exit;
            end if;
            delay 0.5;
         end loop;
         eidx := tomute.grid_loc;

         if eidx < 0 then -- marked for ending task
            exit;
         end if;
         mutate(tomute, eidx);
         evaluate(tomute,eidx);

         DoneSolMutex.P;
         DoneSolList(DoneIndex) := tomute;
         DoneIndex := DoneIndex + 1;
         DoneSolMutex.V;
      end loop;
      --Put_Line("I am dead");
   end slave_task;

   RunningSlaves                  : array(1..MAX_SLAVES) of slave_task;


   result                         : integer;
   mfound                         : integer;
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

   FileStream                     : stream;
   command                        : unbounded_String;
   F1,F2,F3,F4                    : Ada.Text_IO.File_Type;
   line                           : unbounded_String;
   Buffer                         : unbounded_String;

   scheduler_Name                 : unbounded_String;
   initial_task_set_file_name     : unbounded_string;
   fitness_list,str,A_str         : unbounded_String;
   an_index                       : integer;

   hyperperiod_candidate_task_set : integer;
   Max_hyperperiod                : integer;
   Processor_Utilization          : integer;
   actual_cpu_utilization         : float := 0.00;
   A_utilization                  : float;

   Start,Ends                     : Time;
   A_Duration                     : DURATION; --DAY_DURATION;
   v                              : integer;

   slaves                         : natural := 0;

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

   create_system (My_system);
   -- Get arguments
   --
   loop
      case GNAT.Command_Line.Getopt ("h n: sched: iter: i: u: p: fitness: select: n_diff_periods: n_res: rsf: csr:") is
         when ASCII.NUL =>
            exit;

            -- parallel slaves. if = 0, then direct evaluation
         when 'p' =>
            slaves := Integer'Value(GNAT.Command_Line.Parameter);
            if slaves > MAX_SLAVES then
               Put_Line("too much slaves asked -- check MAX_SLAVES");
               Usage;
               OS_Exit (0);
            end if;
            if slaves < 1 then
               Usage;
               OS_Exit (0);
            end if;
            Put_Line ("Number of slaves = " & slaves'img);

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


   -- Customize PAES parameters according our problem :
   depth                 := 4;
   minmax                := 0;   -- minimization problem
   archive               := 200; -- the archive size is fixed to 200


   -- Initializing the current solution c,
   -- the initial_system
   -- and the list of all possible Fitness functions
   init;

   -- Initializing the list of selected Fitness functions
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


   if (iterations < slaves) then
      -- slaves correspond to the number of process that can be run in parallel
      -- it depends on the parallel machine capacities
      slaves:=iterations;
   end if;


   if (Length (initial_task_set_file_name) /= 0) then

      -- we use the task set described in the xml file given in argument
      Initialize(Initial_System);
      Ada.text_IO.put_line ("Initial_task_set_file_name : " & To_string(initial_task_set_file_name));
      Read_From_Xml_File (Initial_System, dir1, initial_task_set_file_name);

      Write_To_Xml_File(A_System  => Initial_System,
                        File_Name => "initial_tasks_set.xmlv3");


      Write_To_Xml_File(A_System  => Initial_System,
                        File_Name => "candidate_solution 0.xmlv3");

      Hyperperiod_of_Initial_Taskset := Scheduling_Period (Initial_System.Tasks, to_unbounded_string("processor1"));
      -- Check the schedulability of the given task set
      command  := To_Unbounded_String("~/call_cheddar "
                                      & Hyperperiod_of_Initial_Taskset'img
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

      Open(F1, Ada.Text_IO.In_File,"Output 0.txt");
      line := To_Unbounded_String(get_line(F1));

      if line = "schedulability : true" then
         Put_Debug ("The initial tasks set is schedulable");
      else
         Put_Debug ("The initial tasks set is not schedulable!");
         return;
      end if;

      Close(F1);


   elsif (Total_cpu_utilization /= 0.00) then
      Put_Debug ("generate a task set of " & genes'img
                 & " tasks with a total processor utilization" & Total_cpu_utilization'img );

      Create(F4,Ada.Text_IO.Out_File,"task_set_generation_runtime.txt");
      start := Clock;

      -- We use the given processor utilization to generate a task set
      -- Generate_initial_schedulable_System (My_system, genes, Total_cpu_utilization);
      Generate_initial_schedulable_System
        (my_system        => My_system,
         N                => genes,
         U 	          => Total_cpu_utilization,
         N_diff_periods   => N_diff_periods,
         N_resources      => N_resources,
         rsf              => Resource_sharing_factor,
         csr		  => critical_section_ratio);

      Ends := Clock;
      A_Duration := Ends - Start;
      Put("Task_set_generation_time " & ASCII.HT & ASCII.HT & ": ");
      Put(A_Duration, 8, 8, 0);
      Put(" seconds");
      Put_Debug("");


      Put(F4, A_Duration, 8, 8, 0);
      Close(F4);

      Delay(1.0);


      initial_task_set_file_name := To_Unbounded_String("initial_tasks_set.xmlv3");

      Initial_System := My_system;

   else
      Usage;
      OS_Exit (0);

   end if;

   Write_To_Xml_File(A_System  => Initial_System,
                     File_Name => "initial_tasks_set.xmlv3");

   Append (Data, " depth =" & depth'Img
           & "   iterations =" & iterations'Img
           & ASCII.LF);

   actual_cpu_utilization := 0.00;

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

      Put_Debug(" ");--New_Line;
      A_utilization := Float(A_capacity) / Float(A_period);
      actual_cpu_utilization :=  actual_cpu_utilization + A_utilization;

   end loop;

   Put(ASCII.LF);
   Put ("The actual processor utilization is : ");
   fl_io.Put (actual_cpu_utilization, 8, 8, 0);
   Put_Debug(" ");--New_Line;
   Hyperperiod_of_Initial_Taskset := Scheduling_Period (Initial_System.Tasks, to_unbounded_string("processor1"));
   Put(ASCII.LF);
   Put_Line ("The hyperperiod of the initial task set = " & Hyperperiod_of_Initial_Taskset'Img);
   Max_hyperperiod := Hyperperiod_of_Initial_Taskset;
   Put (ASCII.LF);

   Create(F,Ada.Text_IO.Out_File,"execution_trace.txt");


   print_genome(c);    -- Uncomment to check genome is correct
   for l in 1..genes loop
      Append (Data, c.chrom(l)'Img & " ");
   end loop;
   Append (Data, ASCII.LF);
   Put (ASCII.LF);

   evaluate(c,0);

   -- Initialization of the Anti-Ideal point to the initial solution
   Z1_anti_ideal := c.obj(1);
   Z2_anti_ideal := c.obj(2);
   Put_Debug ("Z1_anti_ideal = " & Z1_anti_ideal'Img);
   Put_Debug ("Z2_anti_ideal = " & Z2_anti_ideal'Img);

   print_eval(c);      -- Uncomment to check objective values generated
   New_line;
   for k in 1 .. objectives loop
      Append (Data, format(c.obj(k)) & " ");
   end loop;
   Append (Data, ASCII.LF);


   add_to_archive(c);
   update_grid(c);

   Put_Line (" arclength = " & arclength'Img);
   Append (Data, " arclength = " & arclength'Img & ASCII.LF);
   New_Line; --Put_Debug (" ");
   Append (Data, ASCII.LF);

   Put_Line("The genetic material in the archive is now... ");
   Append (Data, "The genetic material in the archive is now... " & ASCII.LF);
   for l in 1..arclength loop
      print_eval(arc(l));
      for k in 1 .. objectives loop
         Append (Data, format(arc(l).obj(k)) & " ");
      end loop;
      New_Line; --Put_Debug(" ");
      Append (Data, ASCII.LF);
      Put (ASCII.LF);
   end loop;
   New_Line; --Put_Debug(" ");
   Append (Data, ASCII.LF);

   for q in 1..arclength loop
      Put_Line("-------------------------------------------------------------------------------------------------------");
      Append (Data, "-------------------------------------------------------------------------------------------------------" & ASCII.LF);
      Put("Solution " & q'img & ":  ");
      Append (Data, "Solution " & q'img & ":  ");
      print_genome(arc(q));

      for l in 1..genes loop
         Append (Data, arc(q).chrom(l)'Img & " ");
      end loop;
      Append (Data, ASCII.LF);
      Put_Line("Objectives of solution " & q'img & " : ");
      Append (Data, "Objectives of solution " & q'img & " : " & ASCII.LF);

      v := 0;
      for e in 1 .. MAX_FITNESS loop
         if 	FitnessFunctions(e).Is_selected = 1 then
            v := v + 1;
            Append (Data, "  |  " & FitnessFunctions(e).Name & " = ");
            Put ("  |  " & FitnessFunctions(e).Name & " = " );
            If (e = 4) or (e = 6) then
               str :=  format (Float(Hyperperiod_of_Initial_Taskset) - arc(q).obj(v));
               --fl_IO.Put(Float(Hyperperiod_of_Initial_Taskset) - arc(q).obj(v), 8, 5, 0);
               --Append (Data, Float(Float(Hyperperiod_of_Initial_Taskset) - arc(q).obj(v))'Img);
            else
               str :=  format (arc(q).obj(v));
               --fl_IO.Put(arc(q).obj(v), 8, 5, 0);
               --Append (Data, arc(q).obj(v)'Img);
            end if;
            Put (str);
            Append (Data, str);
         end if;
      end loop;
      Put_line ("  |");
      Put_Line("-------------------------------------------------------------------------------------------------------");
      Append (Data,  "  |" & ASCII.LF);
      Append (Data, "-------------------------------------------------------------------------------------------------------"
              & ASCII.LF);
   end loop;
   New_Line; --Put_Debug(" ");
   Append (Data, ASCII.LF);

   -------------------------
   -- begin the main loop --
   -------------------------

   Start := Clock;

   --Parallel running of first mutations
   --useless tasks are told to die
   if slaves > 0 then
      ToDoSolMutex.P;
      for i in 0..MAX_SLAVES-1 loop

         ToDoSolList(i) := c;
         if i < slaves then
            ToDoSolList(i).grid_loc := i;
         else
            ToDoSolList(i).grid_loc := -1;
         end if;
      end loop;
      ToDoIndex := MAX_SLAVES;
      ToDoSolMutex.V;
   else --killing all tasks (except mutex)
      ToDoSolMutex.P;
      for i in 0..MAX_SLAVES-1 loop
         ToDoSolList(i).grid_loc := -1;
      end loop;
      ToDoIndex := MAX_SLAVES;
      ToDoSolMutex.V;
   end if;

   for i in 0..iterations-1 loop

      Put_Debug(" ");--New_Line;
      Append (Data, ASCII.LF);
      Put_Debug(" ------------------ ");
      Append (Data, " ------------------ " & ASCII.LF);


      Put_Debug("  iteration = " & i'Img);
      Append (Data, "  iteration = " & i'Img & ASCII.LF);

      Put_Debug(" ------------------ ");
      Append (Data, " ------------------ " & ASCII.LF);
      Put_Debug(" ");--New_Line;
      Append (Data, ASCII.LF);


      m := c;     --  copy the current solution
      Put_Debug(" ");--New_Line;
      Append (Data, ASCII.LF);
      Put_Debug(" Objectives of the current solution : ");
      Append (Data, " Objectives of the current solution : ");
      print_debug_eval(c);
      for k in 1 .. objectives loop
         Append (Data, c.obj(k)'Img & " ");
      end loop;

      Append (Data, ASCII.LF);

      Put_Debug(" ");--New_Line;
      Append (Data, ASCII.LF);
      Put_Debug(" The current solution : ");
      Append (Data, " The current solution : " & ASCII.LF);
      print_debug_genome(c);
      for l in 1..genes loop
         Append (Data, c.chrom(l)'Img & " ");
      end loop;
      Append (Data, ASCII.LF);
      Put_Debug(" ");--New_Line;
      Append (Data, ASCII.LF);

      -- in sequential:
      -- mutate(m, 0);
      -- in parallel, when deployed:
      -- run_mutate(m, i);
      -- for test of reentrant code
      if slaves < 1 then
         mutate(m, 0); --sequential
         evaluate(m,0);
      else
         mfound := 0;
         loop
            DoneSolMutex.P;
            if DoneIndex > 0 then
               DoneIndex := DoneIndex - 1;
               m := DoneSolList(DoneIndex);
               mfound := 1;
            end if;
            DoneSolMutex.V;
            if mfound = 1 then
               exit;
            end if;
            delay 0.5;
         end loop;

      end if;

      Put_Debug(" The mutated normalized solution of iteration " & i'Img & " : ");
      Append (Data, " The mutated normalized solution of iteration " & i'Img & " : " & ASCII.LF);
      print_debug_genome(m);
      for l in 1..genes loop
         Append (Data, m.chrom(l)'Img & " ");
      end loop;
      Append (Data, ASCII.LF);

      -- compute the hyperperiod of the candidate solution "m"
      Appling_clustering_rules(My_System, m);
      hyperperiod_candidate_task_set := Scheduling_Period (My_system.Tasks, to_unbounded_string("processor1"));
      Put_Debug ("The hyperperiod of the candidate task set is : " & hyperperiod_candidate_task_set'img);
      if Max_hyperperiod < hyperperiod_candidate_task_set then
         Max_hyperperiod := hyperperiod_candidate_task_set;
      end if;

      -- compare coordinates of ideal point with coordinates of the
      -- candidate solution
      if m.obj(1) > Z1_anti_ideal then
         Z1_anti_ideal := m.obj(1);
      end if;

      if m.obj(2) > Z2_anti_ideal then
         Z2_anti_ideal := m.obj(2);
      end if;
      Put_Debug(" The Anti-Ideal point in the iteration " & i'Img & " is : ");
      Put_Debug ("Z1_anti_ideal = " & Z1_anti_ideal'Img);
      Put_Debug ("Z2_anti_ideal = " & Z2_anti_ideal'Img);


      Put_Debug(" Objectives of the mutated solution : ");
      Append (Data, " Objectives of the mutated solution : ");
      print_debug_eval(m);
      for k in 1 .. objectives loop
         Append (Data, m.obj(k)'Img & " ");
      end loop;

      Append (Data, ASCII.LF);


      Put_Debug(" ");--New_Line;
      Put_Debug(" ");--New_Line;
      Append (Data, ASCII.LF);
      Append (Data, ASCII.LF);
      Put_Debug(" Comparing ");
      Append (Data, " Comparing ");
      print_debug_eval(c);
      for k in 1 .. objectives loop
         Append (Data, format(c.obj(k)) & " ");
      end loop;

      Append (Data, ASCII.LF);
      Put_Debug("and ");
      Append (Data, "and ");
      print_debug_eval(m);
      for k in 1 .. objectives loop
         Append (Data, format(m.obj(k)) & " ");
      end loop;
      Append (Data, ASCII.LF);
      Put_Debug(" ");--New_Line;
      Put_Debug(" ");--New_Line;
      Append (Data, ASCII.LF);
      Append (Data, ASCII.LF);

      --  MINIMIZE MAXIMIZE
      if (minmax = 0) then
         result := compare_min(c.obj, m.obj, objectives);
      else
         result := compare_max(c.obj, m.obj, objectives);
      end if;


      if A_SelectionStrategy = local then -- The PAES original

         if (result /= 1) then     --  if mutant is not dominated by current (else discard it)

            if (result = -1) then --  if mutant dominates current

               Put_Debug("m dominates c");
               Append (Data, "m dominates c" & ASCII.LF);
               update_grid(m);  --  calculate grid location of mutant solution and renormalize
               --  archive if necessary
               archive_soln(m); --  update the archive by removing all dominated individuals

               c := m;          --  replace c with m

            elsif (result = 0) then -- if mutant and current are nondominated wrt each other

               result := compare_to_archive(m);

               if (result /= -1) then --  if mutant is not dominated by archive (else discard it)

                  update_grid(m);

                  archive_soln(m);


                  if (grid_pop(m.grid_loc) <= grid_pop(c.grid_loc)) or (result = 1) then
                     -- if mutant dominates the archive or
                     -- is in less crowded grid loc than c
                     -- then replace c with m

                     c := m;

                  end if;

               end if;

            end if;

         end if;

      else -- The global selection strategy

         result := compare_to_archive(m);

         if (result /= -1) then --  if mutant is not dominated by archive (else discard it)
            update_grid(m);
            archive_soln(m);
         end if;
         c := selectNext; --  in all cases, the next current solution is selected from the archive

      end if;

      if slaves > 0 then
         if i <= (iterations - slaves) then
            ToDoSolMutex.P;
            ToDoSolList(ToDoIndex) := c;
            ToDoSolList(ToDoIndex).grid_loc := slaves + i;
            ToDoIndex := ToDoIndex + 1;
            ToDoSolMutex.V;
         end if;
      end if;

      Put_Debug(" ");--New_Line;
      Append (Data, ASCII.LF);
      Put_Debug("The genetic material in the archive is now... ");
      Append (Data, "The genetic material in the archive is now... " & ASCII.LF);
      for q in 1..arclength loop
         Put_Debug("-------------------------------------------------------------------------------------------------------");
         Append (Data, "-------------------------------------------------------------------------------------------------------"
                 & ASCII.LF);
         Put_Debug("Solution " & q'img & ":  ");
         Append (Data, "Solution " & q'img & ":  ");
         print_debug_genome(arc(q));
         for l in 1..genes loop
            Append (Data, arc(q).chrom(l)'Img & " ");
         end loop;

         Appling_clustering_rules(My_system , arc(q));
         Write_To_Xml_File(A_System  => My_system,
                           File_Name => To_string(Suppress_Space (To_Unbounded_String ("solution" & q'Img & ".xmlv3"))));

         Append (Data, ASCII.LF);

         Put_Debug ("Objectives of solution " & q'img & " : ");
         Append (Data, "Objectives of solution " & q'img & " : " & ASCII.LF);

         v := 0;
         for e in 1 .. MAX_FITNESS loop
            if 	FitnessFunctions(e).Is_selected = 1 then
               v := v + 1;
               Append (Data, "  |  " & FitnessFunctions(e).Name & " = ");
               Put_Debug ("  |  " & FitnessFunctions(e).Name & " = " );
               If (e = 4) or (e = 6) then
                  str :=  format (Float(Hyperperiod_of_Initial_Taskset) - arc(q).obj(v));
               else
                  str :=  format (arc(q).obj(v));
               end if;
               Put_Debug(str);
               Append (Data, str);
            end if;
         end loop;
         Put_Debug ("  |");
         Put_Debug("-------------------------------------------------------------------------------------------------------");
         Append (Data,  "  |" & ASCII.LF);
         Append (Data, "-------------------------------------------------------------------------------------------------------"
                 & ASCII.LF);

      end loop;
      Put_Debug(" ");--New_Line;
      Append (Data, ASCII.LF);
      Unbounded_IO.Put_Line(F, Data);
      Ada.Strings.Unbounded.Delete(Data, 1, Length(Data));
   end loop;

   Put_Debug(" ");--New_Line;
   Put_Debug(" ");--New_Line;
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

      Put_Line("-------------------------------------------------------------------------------------------------------");
      Append (Data, "-------------------------------------------------------------------------------------------------------"
              & ASCII.LF
              & "Solution " & i'img & ":  ");
      Put("Solution " & i'img & ":  ");
      print_genome(arc(i));
      for l in 1..genes loop
         Append (Data, arc(i).chrom(l)'Img & " ");
      end loop;
      Append (Data, ASCII.LF);

      Appling_clustering_rules(My_system , arc(i));
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
   Put_Line("===================================================="
            & "================================================== ");
   Append (Data, "======================================================="
           & "=============================================== " & ASCII.LF);
   Unbounded_IO.Put_Line(F, Data);
   Close(F);

   Create(F2,Ada.Text_IO.Out_File,"front.dat");
   Unbounded_IO.Put_Line(F2, Data2);
   Close(F2);

   Put_Line ("The hyperperiod of initial solution: " & Hyperperiod_of_Initial_Taskset'img);
   Put_Line ("The maximum hyperperiod of candidate solution: " & Max_hyperperiod'img);

   Ends := Clock;
   A_Duration := Ends - Start;
   Put("Paes_runtime" & ASCII.HT & ":");
   Put(A_Duration, 8, 8, 0);
   Put(" seconds");
   Put_Debug("");

   Create(F3,Ada.Text_IO.Out_File,"runtime.txt");
   Put(F3, A_Duration, 8, 8, 0);
   Close(F3);

   --send invalid task to end the slaves
   if slaves > 0 then
      ToDoSolMutex.P;
      for i in 0..slaves-1 loop
         ToDoSolList(i) := c;
         ToDoSolList(i).grid_loc := -1;
      end loop;
      ToDoIndex := slaves;
      ToDoSolMutex.V;
   end if;
   -- end all tasks
   ToDoSolMutex.E;
   DoneSolMutex.E;

end call_paes;


