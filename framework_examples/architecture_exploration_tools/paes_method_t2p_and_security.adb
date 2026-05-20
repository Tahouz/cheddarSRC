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
--            -select <selection_strategy> -fitness <fitness_functions>
--
-- Examples: ./F2T_paes_method -n 6 -i initial_tasks_set.xmlv3 -iter 5000 -sched RM -select global -fitness "f1 f4"
--           ./F2T_paes_method -n 6 -iter 5000 -sched RM -select global -fitness "f1 f4" -u 90  -n_diff_periods 2  -n_res 2  -rsf 20
--           ./F2T_paes_method -n 6 -i initial_tasks_set.xmlv3 -iter 5000 -sched RM -select global -fitness "f1 f5 f3" -p 4 (for 4 parallel slaves)
-- ./F2T_paes_method2 -n 8 -i test1_paes  -nb_partitions 2 -iter 5 -sched RM -select global -fitness "f1 f2 f3" | tee test--
-- ./F2T_paes_method2_d -n 8 -i test1_paes -nb_partitions 2 -iter 3 -sched HOP -select global -fitness "f1 f2 f3" | tee test

-- Possible fitness functions:
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--      Minimization of missed deadline
--
--              f1 => Min(missedDeadlines)
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--      Minimization of Bell-la Padula's (confidentiality) rules violations
--
--              f2 => Min(bellViolations)
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--      Minimization of f Biba's (integrity) rules violations
--
--              f3 => Min(bibaViolations)
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

with Text_IO;               use Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with unbounded_strings;   use unbounded_strings;
with Ada.Strings;         use Ada.Strings;
with Parameters;          use Parameters;
with Parameters.extended; use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;
with systems;                  use systems;
with framework;                use framework;
with call_framework;           use call_framework;
with Call_Framework_Interface; use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with call_scheduling_framework; use call_scheduling_framework;

with Ada.Directories;          use Ada.Directories;
with Ada.Text_IO;              use Ada.Text_IO;
with Ada.Command_Line;         use Ada.Command_Line;
with GNAT.Command_Line;        use GNAT.Command_Line;
with GNAT.OS_Lib;              use GNAT.OS_Lib;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with unbounded_strings;        use unbounded_strings;
with Ada.Strings;              use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with Ada.Directories;          use Ada.Directories;
with Ada.Calendar;             use Ada.Calendar;
with Ada.Calendar.Formatting;  use Ada.Calendar.Formatting;
with Ada.Text_IO;              use Ada.Text_IO;

with architecture_factory; use architecture_factory;

with unbounded_strings; use unbounded_strings;

with Tasks; use Tasks;

with task_set; use task_set;

with resource_set; use resource_set;

with Resources; use Resources;

with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;
with feasibility_test.processor_utilization;
use feasibility_test.processor_utilization;

with Ada.Text_IO;              use Ada.Text_IO;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with Ada.Directories;          use Ada.Directories;

with Scheduler_Interface; use Scheduler_Interface;
with Framework_Config;    use Framework_Config;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;
with float_util;          use float_util;
with debug;               use debug;

with Paes.chromosome_Data_Manipulation_t2p_and_security;
use Paes.chromosome_Data_Manipulation_t2p_and_security;

with Paes.objective_functions.t2p_and_security;
use Paes.objective_functions.t2p_and_security;

with model_generator; use model_generator;

--with Paes; use Paes;

with systems; use systems;

with Dependencies;             use Dependencies;
with task_dependencies;        use task_dependencies;
with task_dependencies;        use task_dependencies.half_dep_set;
with MILS_Security;            use MILS_Security;
with pipe_commands;            use pipe_commands;
with Paes.general_form;
with Paes.objective_functions; use Paes.objective_functions;
with Paes.t2p_and_security;    use Paes.t2p_and_security;
with Paes.t2p_and_security;    use Paes.t2p_and_security;
with Paes;                     use Paes;

procedure paes_method_t2p_and_security is

   package paes_T2P_architecture_exploration is new Paes.general_form
     (init     => Paes.chromosome_Data_Manipulation_t2p_and_security.init_T2P,
      mutate => Paes.chromosome_Data_Manipulation_t2p_and_security.mutate_T2P,
      evaluate => Paes.objective_functions.t2p_and_security.evaluate_T2P);

   package Fix_IO is new Ada.Text_IO.Fixed_IO (Day_Duration);
   use Fix_IO;
   package Fl_IO is new Ada.Text_IO.Float_IO (Float);
   use Fl_IO;

   My_System               : system;
   Sys                     : system;
   Total_cpu_utilization   : Float   := 0.00;
   N_diff_periods          : Integer := 10;
   N_resources             : Integer := 0;
   Resource_sharing_factor : Float   := 0.00;
   critical_section_ratio  : Float   := 0.00;

   Dir         : Unbounded_String;
   Dir2        : Unbounded_String;
   Data, Data2 : Unbounded_String;

   F : Ada.Text_IO.File_Type;

   j               : Integer;
   My_iterator     : tasks_dependencies_iterator;
   Dep_Ptr         : dependency_ptr;
   My_dependencies : tasks_dependencies_ptr;

   dir1 : unbounded_string_list;

   --   A_capacity                     : natural;
   --   A_period                       : natural;
   --  A_deadline                     : natural;

   F1, F2, F3, F4, F5 : Ada.Text_IO.File_Type;

   scheduler_Name             : Unbounded_String;
   initial_task_set_file_name : Unbounded_String;
   fitness_list, str, A_str   : Unbounded_String;
   an_index, k                : Integer;

   --hyperperiod_candidate_task_set : integer;
   Max_hyperperiod        : Integer;
   Processor_Utilization  : Integer;
   actual_cpu_utilization : Float := 0.00;

   Start, Ends             : Time;
   A_Duration              : Duration; --DAY_DURATION;
   v                       : Integer;
   A_solution              : solution_t2p;
   com_cost                : com_cost_type;
   nb_com_theoric          : Integer;
   nb_com_after_scheduling : Integer;

   app_limit, num_app : Integer;

   procedure Usage is
   begin
      New_Line;
      put_debug
        ("paes_d is a program which from an initial schedulable task set," &
         "generate with PAES the front pareto: a set of schedulable task sets.");

      New_Line;
      put_debug
        ("Check Cheddar home page for details :  http://beru.univ-brest.fr/~singhoff/cheddar ");
      New_Line;
      New_Line;
      put_debug ("Usage : ./paes [switch] ");
      put_debug ("   switch can be :");
      put_debug
        ("            -h" &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         "get this help");
      put_debug
        ("            -n <number_of_functions>" &
         ASCII.HT &
         ASCII.HT &
         "the number of functions");
      put_debug
        ("            -sched <scheduler_Name>" &
         ASCII.HT &
         ASCII.HT &
         "the scheduler can be RM or EDF ");
      put_debug
        ("            -select <selection_strategy>" &
         ASCII.HT &
         ASCII.HT &
         "the selection strategy can be local (PAES original) or global");
      put_debug
        ("            -iter <iterations>" &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         "the number of PAES iterations ");
      put_debug
        ("            -i <xml_file_name>" &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         "the XML file contains the initial system i.e. each");
      put_debug
        ("                              " &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         "function is assigned to a task ");
      put_debug
        ("            -u <total_cpu_utilization>" &
         ASCII.HT &
         ASCII.HT &
         "Total processor utilization ");
      put_debug
        ("            -p <slaves>" &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         "number parallel of slaves (default no slaves)");
      put_debug
        ("            -n_diff_periods <Number_of_different_periods_in_the_function_set>" &
         ASCII.HT &
         "the number of different periods in the function set");
      put_debug
        ("            -n_res <Number_of_shared_resources>" &
         ASCII.HT &
         "the number of shared resources in the function set");
      put_debug
        ("            -rsf <Resource_sharing_factor>" &
         ASCII.HT &
         "the resource sharing factor");
      put_debug
        ("            -fitness <fitness_functions>" &
         ASCII.HT &
         "the list of competing fitness functions (among the" &
         " following list) ");
      put_debug
        ("                                        " &
         ASCII.HT &
         "used by PAES to drive the design space exploration:");
      put_debug
        (ASCII.HT &
         ASCII.HT &
         "---------------------------------------------------------------------------------" &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         "Minimization of preemptions " &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         " F1 => Min(number_of_preemptions)");

      put_debug
        (ASCII.HT &
         ASCII.HT &
         "---------------------------------------------------------------------------------" &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         "Minimization of context switches " &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         " F2 => Min(number_of_context_switches)");

      put_debug
        (ASCII.HT &
         ASCII.HT &
         "---------------------------------------------------------------------------------" &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         "Minimization of tasks (i.e. minimization of stack-memory) " &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         " F3 => Min(number_of_tasks)");

      put_debug
        (ASCII.HT &
         ASCII.HT &
         "---------------------------------------------------------------------------------" &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         "Maximization of the overall system laxity " &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         " F4 => Max(sum(laxities)) = Max(sum(Li)) = Max(sum(Di-Ri))" &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         "    => equivalent to:  Min (H0-sum(Li))");

      put_debug
        (ASCII.HT &
         ASCII.HT &
         "---------------------------------------------------------------------------------" &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         "Another function related to the system laxity " &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         " F5 => Max(sum(Li/Di)) = Max(sum(1-(Li/Di)))" &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         "    => equivalent to:   Min(sum(Ri/Di))");

      put_debug
        (ASCII.HT &
         ASCII.HT &
         "---------------------------------------------------------------------------------" &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         "Maximization of the minimum laxity " &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         " F6 => Max(min(Li))" &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         "    => equivalent to:   Min(H0-min(Li))");

      put_debug
        (ASCII.HT &
         ASCII.HT &
         "---------------------------------------------------------------------------------" &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         "Minimization of the overall worst case response time of tasks " &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         " F7 => Min(sum(Ri))");

      put_debug
        (ASCII.HT &
         ASCII.HT &
         "---------------------------------------------------------------------------------" &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         "Minimization of the maximum worst case response time " &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         " F8 => Min(max(Ri))");

      put_debug
        (ASCII.HT &
         ASCII.HT &
         "---------------------------------------------------------------------------------" &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         "Minimization of the overall worst case blocking time of tasks " &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         " F9 => Min(sum(Bi))");

      put_debug
        (ASCII.HT &
         ASCII.HT &
         "---------------------------------------------------------------------------------" &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         "Minimization of the maximum worst case blocking time " &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         " F10 => Min(max(Bi))");

      put_debug
        (ASCII.HT &
         ASCII.HT &
         "---------------------------------------------------------------------------------" &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         "Minimization of shared resources (i.e. minimization of semaphores) " &
         ASCII.LF &
         ASCII.HT &
         ASCII.HT &
         ASCII.HT &
         " F11 => Min(number_of_resources)");

      put_debug
        (ASCII.HT &
         ASCII.HT &
         "---------------------------------------------------------------------------------");

      New_Line;
   end Usage;

begin

   call_framework.initialize (False);

   -- Get arguments
   --
   loop

      case GNAT.Command_Line.Getopt
        ("h n: nb_partitions: nb_app: sched: iter: i: u: p: fitness: select: n_diff_periods: exploration_version: intra_partition_safe:  n_res: rsf: partition_period: csr: preprocessed_initial_sol")
      is
         when ASCII.NUL =>
            exit;

         -- parallel slaves. if = 0, then direct evaluation
         when 'p' =>
            if Full_Switch = "p" then
               slaves := Integer'value (GNAT.Command_Line.Parameter);
               if slaves > MAX_SLAVES then
                  put_debug ("too much slaves asked -- check MAX_SLAVES");
                  Usage;
                  OS_Exit (0);
               end if;

               if slaves < 1 then
                  Usage;
                  OS_Exit (0);
               end if;

               put_debug ("Number of slaves = " & slaves'img);
            end if;

            if Full_Switch = "preprocessed_initial_sol" then
               Using_preprocessed_initial_sol := True;
               put_debug ("Using the preprocessed initial solution");
            end if;

            if Full_Switch = "partition_period" then
               partition_period := Integer'value (GNAT.Command_Line.Parameter);
               put_debug (" partitions period");
            end if;

         when 'n' =>
            if Full_Switch = "n" then
               genes := Integer'value (GNAT.Command_Line.Parameter);
               put_debug ("Number of task = " & genes'img);
            end if;
            if Full_Switch = "nb_partitions" then
               nb_partitions := Integer'value (GNAT.Command_Line.Parameter);
               put_debug ("Number of partitions = " & nb_partitions'img);
            end if;
            if Full_Switch = "nb_app" then
               nb_app := Integer'value (GNAT.Command_Line.Parameter);
               put_debug ("Number of applications = " & nb_app'img);
            end if;
            if Full_Switch = "n_diff_periods" then
               N_diff_periods := Integer'value (GNAT.Command_Line.Parameter);
               put_debug
                 ("Number of different periods = " & N_diff_periods'img);
            end if;
            if Full_Switch = "n_res" then
               N_resources := Integer'value (GNAT.Command_Line.Parameter);
               put_debug ("Number of resources = " & N_resources'img);
            end if;

         when 's' =>
            if Full_Switch = "sched" then
               scheduler_Name :=
                 To_Unbounded_String (GNAT.Command_Line.Parameter);
               put_debug ("The scheduler is " & To_String (scheduler_Name));
               if scheduler_Name = "RM" then
                  The_Scheduler := rate_monotonic_protocol;
                  Task_priority := 1;
                  Sched_policy  := sched_fifo;
               elsif scheduler_Name = "EDF" then
                  The_Scheduler := earliest_deadline_first_protocol;
                  Task_priority := 0;
                  Sched_policy  := sched_others;
               elsif scheduler_Name = "HOP" then
                  The_Scheduler := hierarchical_offline_protocol;
                  Task_priority := 1;
                  Sched_policy  := sched_fifo;
               else
                  Usage;
                  OS_Exit (0);
               end if;
            end if;
            if Full_Switch = "select" then
               A_str := To_Unbounded_String (GNAT.Command_Line.Parameter);
               if A_str = To_Unbounded_String ("local") or
                 A_str = To_Unbounded_String ("global")
               then
                  A_SelectionStrategy :=
                    selectionstrategy'value (GNAT.Command_Line.Parameter);
                  put_debug
                    ("The Selection Strategy is " & A_SelectionStrategy'img);
               else
                  Usage;
                  OS_Exit (0);
               end if;
            end if;

         when 'i' =>
            if Full_Switch = "i" then
               initial_task_set_file_name :=
                 To_Unbounded_String (GNAT.Command_Line.Parameter);
               put_debug
                 ("The initial_task_set_file_name is " &
                  To_String (initial_task_set_file_name));
            elsif Full_Switch = "iter" then
               iterations := Integer'value (GNAT.Command_Line.Parameter);
               put_debug ("The number of iterations = " & iterations'img);
            elsif Full_Switch = "intra_partition_safe" then
               intra_partition_safe :=
                 Integer'value (GNAT.Command_Line.Parameter);
               put_debug
                 ("intra_partition_safe = " & intra_partition_safe'img);
            end if;

         when 'u' =>
            Total_cpu_utilization :=
              (Float'value (GNAT.Command_Line.Parameter) / 100.0);
            Processor_Utilization := Integer (Total_cpu_utilization * 100.0);
            Put ("The Total_cpu_utilization = ");
            Fl_IO.Put (Total_cpu_utilization, 8, 8, 0);
            Put (ASCII.LF);
            New_Line;

         when 'e' =>
            if Full_Switch = "exploration_version" then
               exploration_version :=
                 Integer'value (GNAT.Command_Line.Parameter);
               if (exploration_version = 1) then
                  put_debug
                    ("The exploration is " & ": App_grain algorithm based");
               elsif (exploration_version = 2) then
                  put_debug
                    ("The exploration is " & ": Mix_grain algorithm based");
               elsif (exploration_version = 3) then
                  put_debug
                    ("The exploration is " & ": Task_grain algorithm based");
               end if;
            end if;

         when 'f' =>
            if Full_Switch = "fitness" then
               fitness_list :=
                 To_Unbounded_String (GNAT.Command_Line.Parameter);
               put_debug
                 ("The list of selected fitness functions is " &
                  To_String (fitness_list));
            end if;

         when 'r' =>
            if Full_Switch = "rsf" then
               Resource_sharing_factor :=
                 (Float'value (GNAT.Command_Line.Parameter) / 100.0);
               Put ("The resource sharing factor = ");
               Fl_IO.Put (Resource_sharing_factor, 8, 8, 0);
               Put (ASCII.LF);
               New_Line;
            end if;

         when 'c' =>
            if Full_Switch = "csr" then
               critical_section_ratio :=
                 (Float'value (GNAT.Command_Line.Parameter) / 100.0);
               Put ("The critical section ratio = ");
               Fl_IO.Put (critical_section_ratio, 8, 8, 0);
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
   depth   := 5;
   minmax  := 0;   -- minimization problem
   archive := 200; -- the archive size is fixed to 200

   c := new solution_t2p;
   m := new solution_t2p;
   for i in 1 .. archive loop
      arc (i) := new solution_t2p;
      tmp (i) := new solution_t2p;
   end loop;
   initialize_fitnessfunctions;

   -- Interpret arguments to set Global variables
   --
   --
   -- 1) Initializing the list of selected objective functions
   --    and set the number of objectives
   --
   str := fitness_list;

   objectives := 1;
   put_debug ("List of fitness functions");
   Append (Data, "List of fitness functions" & ASCII.LF);

   while Index (str, "f") /= 0 loop

      if Index
          (Unbounded_Slice (str, Index (str, "f") + 1, Length (str)),
           "f") /=
        0
      then
         an_index :=
           Integer'value
             (To_String
                (Unbounded_Slice
                   (str,
                    Index (str, "f") + 1,
                    Index (str, " ") - 1)));
         str := Unbounded_Slice (str, Index (str, " ") + 1, Length (str));
         objectives := objectives + 1;
      else
         an_index :=
           Integer'value
             (To_String
                (Unbounded_Slice (str, Index (str, "f") + 1, Length (str))));
         str := empty_string;
      end if;
      fitnessfunctions (an_index).is_selected := 1;
      put_debug
        (ASCII.HT &
         suppress_space (To_Unbounded_String ("f" & an_index'img)) &
         " => " &
         fitnessfunctions (an_index).name);
      Append
        (Data,
         ASCII.HT &
         suppress_space (To_Unbounded_String ("f" & an_index'img)) &
         " => " &
         fitnessfunctions (an_index).name &
         ASCII.LF);
   end loop;

   -- 2) set the number of slaves, if the latter exceeds
   --    the number of iterations
   --
   if (iterations < slaves) then
      -- slaves correspond to the number of process that can be run in parallel
      -- it depends on the parallel machine capacities
      slaves := iterations;
   end if;
   -- 3) Initialize the initial design either from the CheddarADL model
   --  provided by the user or. generating a design using parameters
   --  provided by the user (e.g. genes i.e. #functions, Total_cpu_utilization,
   --  N_diff_periods, #resources, Resource_sharing_factor,
   --  critical_section_ratio)
   --

   initialize (Initial_System);

   --initialize the number of tasks per application

   --Experiments1: 2 app
--     nb_task_per_app(1):=15; --Rosace
--     nb_task_per_app(2):=7;  --JPEG

   --Experiments2: 6 app
--              nb_task_per_app(1):=15; --Rosace
--              nb_task_per_app(2):=4;  --CFAR
--              nb_task_per_app(3):=7;  --JPEG
--              nb_task_per_app(4):=5;  --Autopilot1
--              nb_task_per_app(5):=5;  --Autopilot2
--              nb_task_per_app(6):=5;  --Autopilot3

   --           --Experiments4: 5 app
--     --           nb_task_per_app(1):=15; --Rosace
--     --           nb_task_per_app(2):=4;  --CFAR
--     --           nb_task_per_app(3):=5;  --Autopilot1
--     --           nb_task_per_app(4):=5;  --Autopilot2
--     --           nb_task_per_app(5):=5;  --Autopilot3
--     --

   --Experiments6: 2 autopilot
   nb_task_per_app (1) := 5; --Autopilot1
   nb_task_per_app (2) := 5;  --Autopilot2

   ---Initialize encryption set up key value---
   Key_value := 9;
   ---Initialize encrypters values for each app---
   encrypter_values (1) := 34;  --app1
   encrypter_values (2) := 34; -- App2
--   encrypter_values(2):= 1683; -- App2
--     encrypter_values(2):= 1; -- App2
--     encrypter_values(3):= 1683; -- App3
--     encrypter_values(4):= 34; -- App4
--     encrypter_values(5):= 34; -- App5
--     encrypter_values(6):= 34; -- App6
   ---Initialize decrypter values for each app---
   decrypter_values (1) := 34;  --app1
   decrypter_values (2) := 34; -- App2
--     decrypter_values(2):= 1; -- App2
--     decrypter_values(3):= 1683; -- App3
--     decrypter_values(4):= 34; -- App4
--     decrypter_values(5):= 34; -- App5
--     decrypter_values(6):= 34; -- App6
   ---Initialize decrypter values for each app---
   Hash_values (1) := 21;  --app1
   Hash_values (2) := 21; -- App2
--     hash_values(2):= 1; -- App2
--     hash_values(3):= 1017; -- App3
--     hash_values(4):= 21; -- App4
--     hash_values(5):= 21; -- App5
--     hash_values(6):= 21; -- App6

   --Initialize communication mechanisms overhead for each app--
   display_blackboard_time_values (1) := 1; --app1
   display_blackboard_time_values (2) := 1; --app2
--     display_blackboard_time_values(3):= 7714; --app2
--     display_blackboard_time_values(4):= 156; --app2
--     display_blackboard_time_values(5):= 156; --app2
--     display_blackboard_time_values(6):= 156; --app2

   read_blackboard_time_values (1) := 1;    --app1
   read_blackboard_time_values (2) := 1;    --app2
--     read_blackboard_time_values(3):= 9947;    --app1
--     read_blackboard_time_values(4):= 201;    --app1
--     read_blackboard_time_values(5):= 201;    --app1
--     read_blackboard_time_values(6):= 201;    --app1

   write_sampling_port_time_values (1) := 28; --app1
   write_sampling_port_time_values (2) := 28; --app2
--     write_sampling_port_time_values(3):= 51209; --app1
--     write_sampling_port_time_values(4):= 1033; --app1
--     write_sampling_port_time_values(5):= 1033; --app1
--     write_sampling_port_time_values(6):= 1033; --app1

   read_sampling_port_time_values (1) := 28; --app1
   read_sampling_port_time_values (2) := 28; --app2
--     read_sampling_port_time_values(3):= 43038; --app1
--     read_sampling_port_time_values(4):= 868; --app1
--     read_sampling_port_time_values(5):= 868; --app1
--     read_sampling_port_time_values(6):= 868; --app1

   num_app   := 1;
   app_limit := nb_task_per_app (1);

   for i in 1 .. genes loop
      -- Put all the tasks in the same partition
      A_solution.chrom_task (i) := 1;
      -- define task to application assignment
      -- for task_to_app(i); index for tasks and value for application
      if (num_app <= nb_app) then
         task_to_app (i) := num_app;
         if (i >= app_limit) then
            num_app   := num_app + 1;
            app_limit := app_limit + nb_task_per_app (num_app);
         end if;
      end if;
      Put (task_to_app (i)'img & " ");
   end loop;

--   Hyperperiod_of_Initial_Taskset := 2250;
   Hyperperiod_of_Initial_Taskset := 4250;
   -- Hyperperiod_of_Initial_Taskset := 6250;
   -- Hyperperiod_of_Initial_Taskset := 10125;
   --Hyperperiod_of_Initial_Taskset := 8250;
   --Hyperperiod_of_Initial_Taskset := 8125;
   --Hyperperiod_of_Initial_Taskset := 12000;
   Create_system (My_System, A_solution);

   if (Length (initial_task_set_file_name) /= 0) then

   -- we use the CheddarADL design described in the xml file given in argument
      --
      Ada.Text_IO.Put_Line
        ("Initial_task_set_file_name : " &
         To_String (initial_task_set_file_name));

      read_from_xml_file (My_System, dir1, initial_task_set_file_name);

      Initial_System := My_System;
   ----------------------------
   ----------------------------
   elsif (Total_cpu_utilization /= 0.00) then
      -- We use the provided processor utilization to generate
      -- a schedulable design model
      --

      put_debug
        ("generate a task set of " &
         genes'img &
         " tasks with a total processor utilization" &
         Total_cpu_utilization'img);

      Create (F4, Ada.Text_IO.Out_File, "task_set_generation_runtime.txt");
      Start := Clock;
      generator_model_Uunifast
        (A_solution,
         nb_partitions,
         N_diff_periods,
         Total_cpu_utilization);

      Ends       := Clock;
      A_Duration := Ends - Start;
      Put ("Task_set_generation_time " & ASCII.HT & ASCII.HT & ": ");
      Put (A_Duration, 8, 8, 0);
      Put (" seconds");
      put_debug ("");

      Put (F4, A_Duration, 8, 8, 0);
      Close (F4);

      delay (1.0);

      Create
        (F1,
         Ada.Text_IO.Out_File,
         "currentactual_cpu_utilization_cpu_utilization.txt");
      Put (F1, format (actual_cpu_utilization));
      Close (F1);

      Create
        (F2,
         Ada.Text_IO.Out_File,
         "error_cpu_utilization_generation.txt");
      Put (F2, format (abs (Total_cpu_utilization - actual_cpu_utilization)));
      Close (F2);

      initial_task_set_file_name :=
        To_Unbounded_String ("initial_design.xmlv3");

   else

      Usage;
      OS_Exit (0);

   end if;

   ---------------------------------------------
   My_dependencies := Initial_System.dependencies;
   if is_empty (My_dependencies.depends) then
      put_debug ("No dependencies");
   else
      j := 1;
      k := 1;
      reset_iterator (My_dependencies.depends, My_iterator);
      loop
         current_element (My_dependencies.depends, Dep_Ptr, My_iterator);
         if (Dep_Ptr.type_of_dependency = precedence_dependency) then
            if
              ((Dep_Ptr.precedence_sink.mils_confidentiality_level =
                unclassified) and
               ((Dep_Ptr.precedence_source.mils_confidentiality_level =
                 secret) or
                (Dep_Ptr.precedence_source.mils_confidentiality_level =
                 top_secret))) or
              ((Dep_Ptr.precedence_source.mils_integrity_level = low) and
               ((Dep_Ptr.precedence_sink.mils_integrity_level = medium) or
                (Dep_Ptr.precedence_sink.mils_integrity_level = high)))
            then
         -- Resolve confidentiality constraints problem (communications High)
               A_solution.chrom_com (j).mode        := secure;
               A_solution.chrom_com (j).source_sink :=
                 suppress_space
                   (To_String (Dep_Ptr.precedence_source.name) &
                    "_" &
                    To_String (Dep_Ptr.precedence_sink.name));

            elsif
              (Dep_Ptr.precedence_sink.mils_confidentiality_level <
               Dep_Ptr.precedence_source.mils_confidentiality_level) or
              (Dep_Ptr.precedence_source.mils_integrity_level <
               Dep_Ptr.precedence_sink.mils_integrity_level)
            then
               --confidentiality and integrity violations  (communications Low)
               NonSecure_list (k)                   := j;
               k                                    := k + 1;
               A_solution.chrom_com (j).mode        := secure;
               A_solution.chrom_com (j).source_sink :=
                 suppress_space
                   (To_String (Dep_Ptr.precedence_source.name) &
                    "_" &
                    To_String (Dep_Ptr.precedence_sink.name));

            else
               --communications with no security violations
               A_solution.chrom_com (j).mode        := norisk;
               A_solution.chrom_com (j).source_sink :=
                 suppress_space
                   (To_String (Dep_Ptr.precedence_source.name) &
                    "_" &
                    To_String (Dep_Ptr.precedence_sink.name));

            end if;

            j := j + 1;
         end if;
         exit when is_last_element (My_dependencies.depends, My_iterator);
         next_element (My_dependencies.depends, My_iterator);
      end loop;
      Nb_NonSecure_low := k - 1;
      genes_com        := j - 1;

   end if;
   put_debug ("Nb_NonSecure_low " & Nb_NonSecure_low'img);
   put_debug ("genes_com " & genes_com'img);
   print_genome (A_solution);

   -- Check the feasibility of the design given by the user
   --
   if Check_Feasibility_of_A_Solution (A_solution, 0) then
      put_debug ("The initial design is schedulable");
   else
      put_debug ("The initial design is not schedulable!");
      return;
   end if;
   -----------------------------------------------------------------

   write_to_xml_file
     (a_system  => Initial_System,
      file_name => "initial_design.xmlv3");

   Append
     (Data,
      " depth = " &
      depth'img &
      "   iterations = " &
      iterations'img &
      ASCII.LF);

   actual_cpu_utilization :=
     Float
       (processor_utilization_over_period
          (Initial_System.tasks,
           To_Unbounded_String ("processor1")));

   Put (ASCII.LF);
   Put ("The actual processor utilization is : ");
   Fl_IO.Put (actual_cpu_utilization, 8, 8, 0);
   put_debug (" ");

   Put (ASCII.LF);
   put_debug
     ("The hyperperiod of the initial task set = " &
      Hyperperiod_of_Initial_Taskset'img);
   Max_hyperperiod := Hyperperiod_of_Initial_Taskset;
   Put (ASCII.LF);

   Create (F, Ada.Text_IO.Out_File, "execution_trace.txt");
   Unbounded_IO.Put_Line (F, Data);
   Close (F);

   ------------------------------------------------------------------------
   ------------------------------------------------------------------------
   -- Run PAES for the F2T architecture exploration problem ---------------
   ------------------------------------------------------------------------
   ------------------------------------------------------------------------
   Start := Clock;

   -- Running PAES
   paes_T2P_architecture_exploration.sequential_general_form;

   Ends       := Clock;
   A_Duration := Ends - Start;
   Put ("Paes_runtime" & ASCII.HT & ":");
   Put (A_Duration, 8, 8, 0);
   Put (" seconds");
   put_debug ("");

   Create (F3, Ada.Text_IO.Out_File, "runtime.txt");
   Put (F3, A_Duration, 8, 8, 0);
   Close (F3);

   Ada.Strings.Unbounded.Delete (Data, 1, Length (Data));

   New_Line;
   New_Line;
   Append (Data, ASCII.LF);
   Append (Data, ASCII.LF);
   put_debug
     ("====================================================================================================== ");
   put_debug ("    The final Archive length = " & arclength'img);
   put_debug ("    The final Archive is now... ");
   Append
     (Data,
      "======================================================================================" &
      "================ " &
      ASCII.LF &
      "    The final Archive length = " &
      arclength'img &
      ASCII.LF &
      "    The final Archive is now... " &
      ASCII.LF);

   for i in 1 .. arclength loop
      for k in 1 .. objectives loop
         Append (Data2, arc (i).obj (k)'img & " ");
      end loop;
      Append (Data2, ASCII.LF);

      put_debug
        ("-------------------------------------------------------------------------------------------------------");
      Append
        (Data,
         "-------------------------------------------------------------------------------------------------------" &
         ASCII.LF &
         "Solution " &
         i'img &
         ":  ");
      Put ("Solution " & i'img & ":  ");
      print_genome (solution_t2p (arc (i).all));

      for l in 1 .. genes loop
         Append (Data, solution_t2p (arc (i).all).chrom_task (l)'img & " ");
      end loop;
      Append (Data, ASCII.LF);

      for l in 1 .. genes_com loop
         Append
           (Data,
            solution_t2p (arc (i).all).chrom_com (l).mode'img &
            " " &
            To_String (solution_t2p (arc (i).all).chrom_com (l).source_sink) &
            "    ");
      end loop;
      Append (Data, ASCII.LF);
      Append
        (Data,
         "security architecture configuration" &
         solution_t2p (arc (i).all).security_config'img &
         " : " &
         ASCII.LF);
      Put
        ("security configuration: " &
         solution_t2p (arc (i).all).security_config'img);

      Append (Data, "Hyperperiod: " & arc (i).hyperperiod'img & ASCII.LF);
      Put ("Hyperperiod: " & arc (i).hyperperiod'img);

      Create_system (Sys, solution_t2p (arc (i).all));
      Transform_Chromosome_To_CheddarADL_Model
        (Sys,
         solution_t2p (arc (i).all));
      write_to_xml_file
        (a_system  => Sys,
         file_name =>
           To_String
             (suppress_space
                (To_Unbounded_String ("solution" & i'img & ".xmlv3"))));

      put_debug ("Objectives of solution " & i'img & " : ");
      Append (Data, "Objectives of solution " & i'img & " : " & ASCII.LF);

      v := 0;

      for e in 1 .. max_fitness loop

         if fitnessfunctions (e).is_selected = 1 then
            v := v + 1;
            Append (Data, "  |  " & fitnessfunctions (e).name & " = ");
            Put ("  |  " & fitnessfunctions (e).name & " = ");
            if (e = 4) or (e = 6) then
               str :=
                 format
                   (Float (Hyperperiod_of_Initial_Taskset) - arc (i).obj (v));
            else
               str := format (arc (i).obj (v));
            end if;
            Put (str);
            Append (Data, str);
         end if;
      end loop;
      Append (Data, "  |" & ASCII.LF);
      communication_cost (Sys, com_cost);
      nb_com_theoric :=
        Integer (com_cost (1) + com_cost (2) + com_cost (3) + com_cost (4));
      nb_com_after_scheduling := nb_com_theoric - Integer (arc (i).obj (1));
      Append
        (Data,
         "Number of emission for intra partition communications  : " &
         com_cost (1)'img &
         ASCII.LF);
      Append
        (Data,
         "Number of reception for intra partition communications  : " &
         com_cost (2)'img &
         ASCII.LF);
      Append
        (Data,
         "Number of emission for inter partition communications  : " &
         com_cost (3)'img &
         ASCII.LF);
      Append
        (Data,
         "Number of reception for inter partition communications  : " &
         com_cost (4)'img &
         ASCII.LF);
      Append
        (Data,
         "Total number of emission and reception (theoric) : " &
         nb_com_theoric'img &
         ASCII.LF);
      if (nb_com_after_scheduling >= 0) then
         Append
           (Data,
            "Total number of emission and reception (considering scheduling) : " &
            nb_com_after_scheduling'img &
            ASCII.LF);
      else
         Append
           (Data,
            "All intra and inter partition communication failed their deadline " &
            ASCII.LF);
      end if;
      Append
        (Data,
         "Communication cost considering feasibility interval  : " &
         com_cost (5)'img &
         ASCII.LF);

      put_debug ("  |");
      put_debug
        ("-------------------------------------------------------------------------------------------------------");
      Append (Data, "  |" & ASCII.LF);
      Append
        (Data,
         "-------------------------------------------------------------------------------------------------------" &
         ASCII.LF);

   end loop;

   for n in 1 .. 4 loop
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

   put_debug
     (" ==================================================== " &
      " ================================================== ");

   Append
     (Data,
      "=======================================================" &
      "=============================================== " &
      ASCII.LF);

   Open (F, Ada.Text_IO.Append_File, "execution_trace.txt");
   Unbounded_IO.Put_Line (F, Data);
   Close (F);

   Create (F2, Ada.Text_IO.Out_File, "front.dat");
   Unbounded_IO.Put_Line (F2, Data2);
   Close (F2);

   put_debug
     ("The hyperperiod of initial solution: " &
      Hyperperiod_of_Initial_Taskset'img);
   put_debug
     ("The maximum hyperperiod of candidate solution: " & Max_hyperperiod'img);

end paes_method_t2p_and_security;
