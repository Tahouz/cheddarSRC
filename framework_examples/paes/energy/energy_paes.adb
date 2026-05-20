
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
-- ./F2T_paes_method2 -n 8 -i test1_paes  -nb_partitions 2 -iter 5 -sched RM -select global -fitness "f1 f2 f3" | tee test--
-- ./F2T_paes_method2_d -n 8 -i test1_paes -nb_partitions 2 -iter 3 -sched HOP -select global -fitness "f1 f2 f3" | tee test

-- Possible fitness functions:
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--	Minimization of missed deadline
--
--		f1 => Min(missedDeadlines)
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--	Minimization of Bell-la Padula's (confidentiality) rules violations
--
--		f2 => Min(bellViolations)
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--	Minimization of f Biba's (integrity) rules violations
--
--		f3 => Min(bibaViolations)
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------


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

with paes.chromosome_Data_Manipulation_t2p_and_security;
use paes.chromosome_Data_Manipulation_t2p_and_security;


with paes.objective_functions.t2p_and_security;
use paes.objective_functions.t2p_and_security;

with model_generator; use model_generator;

--with Paes; use Paes;


with Systems;               use Systems;

with Dependencies; 		use Dependencies;
with Task_Dependencies; 	use Task_Dependencies;
with Task_Dependencies; 	use Task_Dependencies.Half_Dep_Set;
with MILS_Security; use MILS_Security;
with Pipe_Commands; use Pipe_Commands;
with paes.general_form;
with paes.objective_functions; use paes.objective_functions;
with paes.t2p_and_security; use paes.t2p_and_security;
with paes.t2p_and_security; use  paes.t2p_and_security;
with Paes; use Paes;

procedure energy_paes is

   package paes_T2P_architecture_exploration is new paes.general_form
     (init =>paes.chromosome_Data_Manipulation_t2p_and_security.init_T2P,
      mutate => paes.chromosome_Data_Manipulation_t2p_and_security.mutate_T2P, --param
      evaluate => paes.objective_functions.t2p_and_security.evaluate_T2P);

   package Fix_IO is new Ada.Text_IO.Fixed_IO(DAY_DURATION); use Fix_IO;
   package Fl_IO is new Ada.Text_IO.float_IO(float); use fl_IO;

   My_System                      : System;
   Sys                            : System;
   Total_cpu_utilization          : float  := 0.00;
   N_diff_periods                 : Integer := 10;
   N_resources                    : Integer := 0;
   Resource_sharing_factor        : float := 0.00;
   critical_section_ratio         : float := 0.00;

   Dir                            : unbounded_string;
   Dir2                           : unbounded_string;
   Data,Data2 ,Data3                   : Unbounded_String;

   F                              : Ada.Text_IO.File_Type;

   j : Integer;
   My_iterator: Tasks_Dependencies_Iterator;
   Dep_Ptr: Dependency_Ptr;
   My_dependencies: Tasks_Dependencies_Ptr;

   dir1                           : unbounded_string_list;

   --   A_capacity                     : natural;
   --   A_period                       : natural;
   --  A_deadline                     : natural;



   F1,F2,F3,F4,F5                    : Ada.Text_IO.File_Type;

   scheduler_Name                 : unbounded_String;
   initial_task_set_file_name     : unbounded_string;
   fitness_list,str,A_str         : unbounded_String;
   an_index,k                       : integer;

   --hyperperiod_candidate_task_set : integer;
   Max_hyperperiod                : integer;
   Processor_Utilization          : integer;
   actual_cpu_utilization         : float := 0.00;

   Start,Ends                     : Time;
   A_Duration                     : DURATION; --DAY_DURATION;
   v                              : integer;
   A_solution                     : solution_t2p;
   com_cost                       : com_cost_type;
   nb_com_theoric                 : Integer;
   nb_com_after_scheduling        : Integer;

   app_limit,num_app              : Integer;

   procedure Usage is
   begin
      New_Line;
      Put_Debug ("paes_d is a program which from an initial schedulable task set,"
                 & "generate with PAES the front pareto: a set of schedulable task sets.");

      New_Line;
      Put_Debug("Check Cheddar home page for details :  http://beru.univ-brest.fr/~singhoff/cheddar ");
      New_Line;
      New_Line;
      Put_Debug ("Usage : ./paes [switch] ");
      Put_Debug ("   switch can be :");
      Put_Debug ("            -h" & ASCII.HT & ASCII.HT &  ASCII.HT & ASCII.HT & ASCII.HT & "get this help");
      Put_Debug ("            -n <number_of_functions>" & ASCII.HT & ASCII.HT & "the number of functions");
      Put_Debug ("            -sched <scheduler_Name>" & ASCII.HT & ASCII.HT & "the scheduler can be RM or EDF ");
      Put_Debug ("            -select <selection_strategy>" & ASCII.HT & ASCII.HT & "the selection strategy can be local (PAES original) or global");
      Put_Debug ("            -iter <iterations>" & ASCII.HT & ASCII.HT & ASCII.HT & "the number of PAES iterations ");
      Put_Debug ("            -i <xml_file_name>" & ASCII.HT & ASCII.HT & ASCII.HT & "the XML file contains the initial system i.e. each");
      Put_Debug ("                              " & ASCII.HT & ASCII.HT & ASCII.HT &  "function is assigned to a task ");
      Put_Debug ("            -u <total_cpu_utilization>" & ASCII.HT & ASCII.HT & "Total processor utilization ");
      Put_Debug ("            -p <slaves>" &  ASCII.HT & ASCII.HT & ASCII.HT & ASCII.HT & "number parallel of slaves (default no slaves)");
      Put_Debug ("            -n_diff_periods <Number_of_different_periods_in_the_function_set>" & ASCII.HT & "the number of different periods in the function set");
      Put_Debug ("            -n_res <Number_of_shared_resources>" & ASCII.HT & "the number of shared resources in the function set");
      Put_Debug ("            -rsf <Resource_sharing_factor>" & ASCII.HT & "the resource sharing factor");
      Put_Debug ("            -fitness <fitness_functions>" & ASCII.HT & "the list of competing fitness functions (among the" 					& " following list) ");
      Put_Debug ("                                        " & ASCII.HT & "used by PAES to drive the design space exploration:");
      Put_Debug (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                 & ASCII.HT & ASCII.HT & "Minimization of preemptions " & ASCII.LF
                 & ASCII.HT & ASCII.HT & ASCII.HT & " F1 => Min(number_of_preemptions)");

      Put_Debug (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                 & ASCII.HT & ASCII.HT & "Minimization of context switches " & ASCII.LF
                 & ASCII.HT & ASCII.HT & ASCII.HT & " F2 => Min(number_of_context_switches)");

      Put_Debug (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                 & ASCII.HT & ASCII.HT & "Minimization of tasks (i.e. minimization of stack-memory) " & ASCII.LF
                 & ASCII.HT & ASCII.HT & ASCII.HT & " F3 => Min(number_of_tasks)");

      Put_Debug (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                 & ASCII.HT & ASCII.HT & "Maximization of the overall system laxity " & ASCII.LF
                 & ASCII.HT & ASCII.HT & ASCII.HT & " F4 => Max(sum(laxities)) = Max(sum(Li)) = Max(sum(Di-Ri))" & ASCII.LF
                 & ASCII.HT & ASCII.HT & ASCII.HT & "    => equivalent to:  Min (H0-sum(Li))");

      Put_Debug (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                 & ASCII.HT & ASCII.HT & "Another function related to the system laxity " & ASCII.LF
                 & ASCII.HT & ASCII.HT & ASCII.HT & " F5 => Max(sum(Li/Di)) = Max(sum(1-(Li/Di)))" & ASCII.LF
                 & ASCII.HT & ASCII.HT & ASCII.HT & "    => equivalent to:   Min(sum(Ri/Di))");

      Put_Debug (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                 & ASCII.HT & ASCII.HT & "Maximization of the minimum laxity " & ASCII.LF
                 & ASCII.HT & ASCII.HT & ASCII.HT & " F6 => Max(min(Li))" & ASCII.LF
                 & ASCII.HT & ASCII.HT & ASCII.HT & "    => equivalent to:   Min(H0-min(Li))");

      Put_Debug (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                 & ASCII.HT & ASCII.HT & "Minimization of the overall worst case response time of tasks " & ASCII.LF
                 & ASCII.HT & ASCII.HT & ASCII.HT & " F7 => Min(sum(Ri))");

      Put_Debug (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                 & ASCII.HT & ASCII.HT & "Minimization of the maximum worst case response time " & ASCII.LF
                 & ASCII.HT & ASCII.HT & ASCII.HT & " F8 => Min(max(Ri))");

      Put_Debug (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                 & ASCII.HT & ASCII.HT & "Minimization of the overall worst case blocking time of tasks " & ASCII.LF
                 & ASCII.HT & ASCII.HT & ASCII.HT & " F9 => Min(sum(Bi))");

      Put_Debug (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                 & ASCII.HT & ASCII.HT & "Minimization of the maximum worst case blocking time " & ASCII.LF
                 & ASCII.HT & ASCII.HT & ASCII.HT & " F10 => Min(max(Bi))");

      Put_Debug (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------" & ASCII.LF
                 & ASCII.HT & ASCII.HT & "Minimization of shared resources (i.e. minimization of semaphores) " & ASCII.LF
                 & ASCII.HT & ASCII.HT & ASCII.HT & " F11 => Min(number_of_resources)");

      Put_Debug (ASCII.HT & ASCII.HT & "---------------------------------------------------------------------------------");

      New_Line;
   end Usage;

begin

   Call_Framework.initialize (False);

   -- Get arguments
   --
   loop

      case GNAT.Command_Line.Getopt ("h n: nb_partitions: nb_app: sched: iter: i: u: p: fitness: select: n_diff_periods: exploration_version:  n_res: rsf: partition_period: csr: preprocessed_initial_sol") is
         when ASCII.NUL =>
            exit;

            -- parallel slaves. if = 0, then direct evaluation
         when 'p' =>
            if Full_Switch = "p" then
               slaves := Integer'Value (GNAT.Command_Line.Parameter);
               if slaves > MAX_SLAVES then
                  Put_Debug ("too much slaves asked -- check MAX_SLAVES");
                  Usage;
                  OS_Exit (0);
               end if;

               if slaves < 1 then
                  Usage;
                  OS_Exit (0);
               end if;

               Put_Debug ("Number of slaves = " & slaves'img);
            end if;

            if Full_Switch =  "preprocessed_initial_sol" then
               Using_preprocessed_initial_sol := true;
               Put_Debug ("Using the preprocessed initial solution");
            end if;

            if Full_Switch =  "partition_period" then
               partition_period := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug (" partitions period");
            end if;

         when 'n' =>
            if Full_Switch = "n" then
               genes := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("Number of task = " & genes'img);
            end if;
            if Full_Switch = "nb_partitions" then
               nb_partitions := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("Number of partitions = " & nb_partitions'img);
            end if;
            if Full_Switch = "nb_app" then
               nb_app := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("Number of applications = " & nb_app'img);
            end if;
            if Full_Switch = "n_diff_periods" then
               N_diff_periods := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("Number of different periods = " & N_diff_periods'img);
            end if;
            if Full_Switch = "n_res" then
               N_resources := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("Number of resources = " & N_resources'img);
            end if;

         when 's' =>
            if Full_Switch = "sched" then
               scheduler_Name := To_Unbounded_String (GNAT.Command_Line.Parameter);
               Put_Debug ("The scheduler is " & To_string(scheduler_Name));
               if scheduler_Name = "RM" then
                  The_Scheduler := Rate_Monotonic_Protocol;
                  Task_priority := 1;
                  Sched_policy  := SCHED_FIFO;
               elsif scheduler_Name = "EDF"  then
                  The_Scheduler := Earliest_Deadline_First_Protocol;
                  Task_priority := 0;
                  Sched_policy  := SCHED_OTHERS;
               elsif scheduler_Name = "HOP"  then
                  The_Scheduler := Hierarchical_Offline_Protocol;
                  Task_priority := 1;
                  Sched_policy  := SCHED_FIFO;
               else
                  Usage;
                  OS_Exit (0);
               end if;
            end if;
            if Full_Switch = "select" then
               A_str := To_Unbounded_String (GNAT.Command_Line.Parameter);
               if A_str = To_Unbounded_String("local") or A_str = To_Unbounded_String("global") then
                  A_SelectionStrategy := SelectionStrategy'Value(GNAT.Command_Line.Parameter);
                  Put_Debug ("The Selection Strategy is " & A_SelectionStrategy'img);
               else
                  Usage;
                  OS_Exit (0);
               end if;
            end if;

         when 'i' =>
            if Full_Switch = "i" then
               initial_task_set_file_name := To_Unbounded_String (GNAT.Command_Line.Parameter);
               Put_Debug ("The initial_task_set_file_name is " & To_string(initial_task_set_file_name));
            elsif Full_Switch = "iter" then
               iterations := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("The number of iterations = " & iterations'img);
            end if;

         when 'u' =>
            Total_cpu_utilization := (Float'Value(GNAT.Command_Line.Parameter)/100.0);
            Processor_Utilization := Integer (Total_cpu_utilization * 100.0);
            Put ("The Total_cpu_utilization = ");
            fl_io.Put (Total_cpu_utilization, 8, 8, 0);
            Put (ASCII.LF);
            New_Line;


              when 'e' =>
            if Full_Switch = "exploration_version" then
               exploration_version := Integer'Value(GNAT.Command_Line.Parameter);
               if (exploration_version=1) then
                  Put_Debug ("The exploration is " & To_string(fitness_list) & ": App_grain algorithm based");
               elsif (exploration_version=2) then
                  Put_Debug ("The exploration is " & To_string(fitness_list) & ": Mix_grain algorithm based");
               elsif (exploration_version=3) then
                  Put_Debug ("The exploration is " & To_string(fitness_list) & ": Task_grain algorithm based");
                end if;
            end if;

         when 'f' =>
            if Full_Switch = "fitness" then
               fitness_list := To_Unbounded_String (GNAT.Command_Line.Parameter);
               Put_Debug ("The list of selected fitness functions is " & To_string(fitness_list));
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


   c:= new solution_t2p;
   m:= new solution_t2p;
   for i in 1..arclength loop
      arc(i):=new solution_t2p;
   end loop;
   initialize_FitnessFunctions;

   -- Customize PAES parameters according our problem :
   depth                 := 1;
   minmax                := 0;   -- minimization problem
   archive               := 200; -- the archive size is fixed to 200

   -- Interpret arguments to set Global variables
   --
   --
   -- 1) Initializing the list of selected objective functions
   --    and set the number of objectives
   --
   str := fitness_list;

   --   objectives := 1;
   objectives := 14;
   Put_Debug ("List of fitness functions");
   Append (Data, "List of fitness functions" & ASCII.LF);

   while index(str, "f") /= 0 loop

      if index(Unbounded_Slice(str, index (str, "f") + 1, length(str)), "f") /= 0 then
         an_index :=  Integer'Value(To_String(Unbounded_Slice(str, index (str, "f") + 1, index (str, " ") - 1)));
         str := Unbounded_Slice(str, index (str, " ") + 1, length(str));
    --     objectives := objectives + 1;
      else
         an_index :=  Integer'Value(To_String(Unbounded_Slice(str, index (str, "f") + 1, length(str))));
         str := empty_string;
      end if;
      FitnessFunctions(an_index).Is_selected := 1;
      Put_Debug(ASCII.HT & Suppress_Space (To_Unbounded_String ("f" & an_index'Img)) & " => " & FitnessFunctions(an_index).Name);
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

   --initialize the number of tasks per application


   --Experiments1: 2 app
   nb_task_per_app(1):=15; --Rosace
   nb_task_per_app(2):=7;  --JPEG

   --Experiments2: 6 app
   --           nb_task_per_app(1):=15; --Rosace
   --           nb_task_per_app(2):=4;  --CFAR
   --           nb_task_per_app(3):=7;  --JPEG
   --           nb_task_per_app(4):=5;  --Autopilot1
   --           nb_task_per_app(5):=5;  --Autopilot2
   --           nb_task_per_app(6):=5;  --Autopilot3

   --           --Experiments4: 5 app
   --           nb_task_per_app(1):=15; --Rosace
   --           nb_task_per_app(2):=4;  --CFAR
   --           nb_task_per_app(3):=5;  --Autopilot1
   --           nb_task_per_app(4):=5;  --Autopilot2
   --           nb_task_per_app(5):=5;  --Autopilot3
   --

   --Experiments6: 2 autopilot
   --     nb_task_per_app(1):=5; --Autopilot1
   --     nb_task_per_app(2):=5;  --Autopilot2

   ---Initialize encryption set up key value---
   Key_value:=9;
   ---Initialize encrypters values for each app---
   encrypter_values(1):= 1;  --app1
   encrypter_values(2):= 1683; -- App2
   ---Initialize decrypter values for each app---
   decrypter_values(1):= 1;  --app1
   decrypter_values(2):= 1683; -- App2
   ---Initialize decrypter values for each app---
   hash_values(1):= 1;  --app1
   hash_values(2):= 1017; -- App2

   --Initialize communication mechanisms overhead for each app--
   display_blackboard_time_values(1):= 1; --app1
   display_blackboard_time_values(2):= 1; --app2
   read_blackboard_time_values(1):= 1;    --app1
   read_blackboard_time_values(2):= 1;

   write_sampling_port_time_values(1):= 28; --app1
   write_sampling_port_time_values(2):= 28; --app2
   read_sampling_port_time_values(1):= 28; --app1
   read_sampling_port_time_values(2):= 28; --app2

   num_app:=1;
   app_limit:=nb_task_per_app(1);


   for i in 1 .. genes loop
      -- Put all the tasks in the same partition
      A_solution.chrom_task(i) := 1;
      -- define task to application assignment
      -- for task_to_app(i); index for tasks and value for application
       if (num_app<=nb_app) then
               task_to_app(i):=num_app;
               if (i>=app_limit) then
                  num_app:=num_app+1;
                  app_limit:=app_limit+nb_task_per_app(num_app);
               end if;
      end if;
      Put (task_to_app(i)'Img & " ");
   end loop;


   --Hyperperiod_of_Initial_Taskset := 2250;
   --  Hyperperiod_of_Initial_Taskset := 4250;
   Hyperperiod_of_Initial_Taskset := 6250;
   -- Hyperperiod_of_Initial_Taskset := 10125;
   --Hyperperiod_of_Initial_Taskset := 8250;
   --Hyperperiod_of_Initial_Taskset := 8125;
   --Hyperperiod_of_Initial_Taskset := 12000;
   create_system (My_system, A_solution);

   if (Length (initial_task_set_file_name) /= 0) then

      -- we use the CheddarADL design described in the xml file given in argument
      --
      Ada.text_IO.put_line ("Initial_task_set_file_name : "
                            & To_string(initial_task_set_file_name));

      Read_From_Xml_File (My_System, dir1, initial_task_set_file_name);

      Initial_System := My_System;
      ----------------------------
      ----------------------------
   elsif (Total_cpu_utilization /= 0.00) then
      -- We use the provided processor utilization to generate
      -- a schedulable design model
      --

      Put_Debug ("generate a task set of " & genes'img
                 & " tasks with a total processor utilization" & Total_cpu_utilization'img );

      Create(F4,Ada.Text_IO.Out_File,"task_set_generation_runtime.txt");
      start := Clock;
      generator_model_Uunifast( A_solution, nb_partitions, N_diff_periods, Total_cpu_utilization) ;

      Ends := Clock;
      A_Duration := Ends - Start;
      Put("Task_set_generation_time " & ASCII.HT & ASCII.HT & ": ");
      Put(A_Duration, 8, 8, 0);
      Put(" seconds");
      Put_Debug("");

      Put(F4, A_Duration, 8, 8, 0);
      Close(F4);

      Delay(1.0);

      Create(F1,Ada.Text_IO.Out_File,"currentactual_cpu_utilization_cpu_utilization.txt");
      Put(F1, format(actual_cpu_utilization));
      Close(F1);

      Create(F2,Ada.Text_IO.Out_File,"error_cpu_utilization_generation.txt");
      Put(F2, format(ABS(Total_cpu_utilization - actual_cpu_utilization)));
      Close(F2);

      initial_task_set_file_name := To_Unbounded_String("initial_design.xmlv3");

   else

      Usage;
      OS_Exit (0);

   end if;

   ---------------------------------------------
   My_dependencies:= Initial_System.Dependencies;
   if is_empty( My_dependencies.Depends) then
      Put_Debug("No dependencies");
   else
      j:= 1;
      k:= 1;
      reset_iterator(My_dependencies.Depends, My_iterator);
      loop
         current_element(My_dependencies.Depends, Dep_Ptr, My_iterator);
         if(Dep_Ptr.type_of_dependency=precedence_dependency)then
            if ( (Dep_Ptr.precedence_sink.mils_confidentiality_level=UnClassified)AND
                  ((Dep_Ptr.precedence_source.mils_confidentiality_level= Secret)OR (Dep_Ptr.precedence_source.mils_confidentiality_level= Top_Secret)) )
              OR ( (Dep_Ptr.precedence_source.mils_integrity_level= Low ) AND
                      (( Dep_Ptr.precedence_sink.mils_integrity_level=Medium) OR ( Dep_Ptr.precedence_sink.mils_integrity_level=High)) )then
               -- Resolve confidentiality constraints problem (communications High)
               A_solution.chrom_com(j).mode := secure;
               A_solution.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));

            elsif(Dep_Ptr.precedence_sink.mils_confidentiality_level< Dep_Ptr.precedence_source.mils_confidentiality_level)
              OR (Dep_Ptr.precedence_source.mils_integrity_level< Dep_Ptr.precedence_sink.mils_integrity_level)then
              --confidentiality and integrity violations  (communications Low)
               NonSecure_list(k) := j;
               k := k+1;
               A_solution.chrom_com(j).mode := secure;
               A_solution.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));

            else
               --communications with no security violations
               A_solution.chrom_com(j).mode := norisk;
               A_solution.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));

            end if;

            j := j+1;
         end if;
         exit when is_last_element (My_Dependencies.Depends, My_Iterator);
         next_element (My_Dependencies.Depends, My_Iterator);
      end loop;
      Nb_NonSecure_low:=k-1;
      genes_com := j-1;


   end if;
   Put_Debug("Nb_NonSecure_low "&Nb_NonSecure_low'Img);
   Put_Debug("genes_com "&genes_com'Img);
   print_genome(A_solution);


   -- Check the feasibility of the design given by the user
   --
   if Check_Feasibility_of_A_Solution (A_solution,0) then
      Put_Debug ("The initial design is schedulable");
   else
      Put_Debug ("The initial design is not schedulable!");
      return;
   end if;
   -----------------------------------------------------------------

   Write_To_Xml_File(A_System  => Initial_System,
                     File_Name => "initial_design.xmlv3");


   Append (Data, " depth = " & depth'Img
           & "   iterations = " & iterations'Img
           & ASCII.LF);


   actual_cpu_utilization := Float (Processor_Utilization_Over_Period
                                    (Initial_System.Tasks, to_unbounded_string("processor1")));


   Put(ASCII.LF);
   Put ("The actual processor utilization is : ");
   fl_io.Put (actual_cpu_utilization, 8, 8, 0);
   Put_Debug(" ");

   Put(ASCII.LF);
   Put_Debug ("The hyperperiod of the initial task set = " & Hyperperiod_of_Initial_Taskset'Img);
   Max_hyperperiod := Hyperperiod_of_Initial_Taskset;
   Put (ASCII.LF);

   Create(F, Ada.Text_IO.Out_File, "execution_trace.txt");
   Unbounded_IO.Put_Line(F, Data);
   Close(F);


   ------------------------------------------------------------------------
   ------------------------------------------------------------------------
   -- Run PAES for the F2T architecture exploration problem ---------------
   ------------------------------------------------------------------------
   ------------------------------------------------------------------------
   Start := Clock;

   -- Running PAES
   paes_T2P_architecture_exploration.parallel_general_form;

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
   Put_Debug("====================================================================================================== ");
   Put_Debug("    The final Archive length = " & arclength'Img);
   Put_Debug("    The final Archive is now... ");
   Append (Data,"======================================================================================"
           & "================ "  & ASCII.LF
           & "    The final Archive length = " & arclength'Img & ASCII.LF
           & "    The final Archive is now... " & ASCII.LF);



   for i in 1..arclength loop
      for k in 1 .. max_fitness loop
         If (FitnessFunctions(k).Is_selected = 1) then
            Append (Data2, arc(i).obj(k)'Img & " ");
         end if;
      end loop;
      Append (Data2,  ASCII.LF);

      Put_Debug("-------------------------------------------------------------------------------------------------------");
      Append (Data, "-------------------------------------------------------------------------------------------------------"
              & ASCII.LF
              & "Solution " & i'img & ":  ");
      Put("Solution " & i'img & ":  ");
      print_genome(solution_t2p(arc(i).all));

      for l in 1..genes loop
         Append (Data, solution_t2p(arc(i).all).chrom_task(l)'Img & " ");
      end loop;
      Append (Data,  ASCII.LF);

      for l in 1..genes_com loop
         Append (Data,solution_t2p(arc(i).all).chrom_com(l).mode'Img & " " & To_String(solution_t2p(arc(i).all).chrom_com(l).source_sink) & "    ");
      end loop;
      Append (Data, ASCII.LF);
      Append (Data, "security architecture configuration" & solution_t2p(arc(i).all).security_config'img & " : " & ASCII.LF);
      Put("security configuration: " & solution_t2p(arc(i).all).security_config'img);

      Append (Data, "Hyperperiod: " & arc(i).hyperperiod'img & ASCII.LF);
      Put("Hyperperiod: " & arc(i).hyperperiod'img);

      Create_system (Sys, solution_t2p(arc(i).all));
      Transform_Chromosome_To_CheddarADL_Model(Sys ,solution_t2p(arc(i).all));
      Write_To_Xml_File (A_System  => Sys,
                         File_Name => To_string (Suppress_Space (To_Unbounded_String ("solution" & i'Img & ".xmlv3"))));

      Put_Debug("Objectives of solution " & i'img & " : ");
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
               str := format (arc(i).obj(e));
            end if;
            Put(str);
            Append (Data,str);
         end if;
      end loop;
      Append (Data,  "  |" & ASCII.LF);
      communication_cost(sys, com_cost);
      nb_com_theoric:=Integer(com_cost(1)+com_cost(2)+com_cost(3)+com_cost(4));
      nb_com_after_scheduling:= nb_com_theoric-Integer(arc(i).obj(1));
      Append (Data,"Number of emission for intra partition communications  : " & com_cost(1)'img & ASCII.LF);
      Append (Data,"Number of reception for intra partition communications  : " & com_cost(2)'img & ASCII.LF);
      Append (Data,"Number of emission for inter partition communications  : " & com_cost(3)'img & ASCII.LF);
      Append (Data,"Number of reception for inter partition communications  : " & com_cost(4)'img & ASCII.LF);
      Append (Data,"Total number of emission and reception (theoric) : " & nb_com_theoric'img & ASCII.LF);
      if (nb_com_after_scheduling>=0)then
         Append (Data,"Total number of emission and reception (considering scheduling) : " & nb_com_after_scheduling'img & ASCII.LF);
      else
         Append (Data,"All intra and inter partition communication failed their deadline " & ASCII.LF);
      end if;
      Append (Data,"Communication cost considering feasibility interval  : " &  com_cost(5)'img & ASCII.LF);

      Put_Debug ("  |");
      Put_Debug("-------------------------------------------------------------------------------------------------------");
      Append (Data,  "  |" & ASCII.LF);
      Append (Data, "-------------------------------------------------------------------------------------------------------"
              & ASCII.LF);




   end loop;

   for n in 1 .. 15 loop
         Append
           (Data3,
            "Number of choice of security architecture" &
              n'img &
              " : " &
              nb_secu_conf_choice (n)'img &
              ASCII.LF);
      end loop;

   Create (F5, Ada.Text_IO.Out_File, "PAES_Execution_iter.dat");
   Unbounded_IO.Put_Line (F5, Data3);
   Close (F5);

   Put_Debug(" ==================================================== "
             & " ================================================== ");

   Append (Data, "======================================================="
           & "=============================================== " & ASCII.LF);


   open(F,Ada.Text_IO.Append_File, "execution_trace.txt");
   Unbounded_IO.Put_Line(F, Data);
   Close(F);


   Create(F2,Ada.Text_IO.Out_File,"front.dat");
   Unbounded_IO.Put_Line(F2, Data2);
   Close(F2);

   Put_Debug ("The hyperperiod of initial solution: " & Hyperperiod_of_Initial_Taskset'img);
   Put_Debug ("The maximum hyperperiod of candidate solution: " & Max_hyperperiod'img);




end energy_paes;



