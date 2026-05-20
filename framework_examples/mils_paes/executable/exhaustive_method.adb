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
--    $Rev: 4589 $
--    $Date: 2023-09-29 16:02:19 +0200 (ven., 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

--  exhaustive_method
-- To compile : make F2T_exhaustive_method
-- To execute :
-- If we want to generate a task set :
--     ./F2T_exhaustive_method -n <number_of_functions> -sched <scheduler_Name>  -fitness <fitness_functions>
--            -u <Total_cpu_utilization>  -n_diff_periods <Number_of_different_periods_in_the_function_set>
--            -n_res <Number_of_shared_resources> -rsf <resource_sharing_factor>
--
--Examples: ./F2T_exhaustive_method -n 6 -i initial_tasks_set.xmlv3 -sched RM -fitness "f1 f4"
--          ./F2T_exhaustive_method -n 6 -sched RM -fitness "f1 f4" -u 90  -n_diff_periods 2  -n_res 2  -rsf 20
--          ./F2T_exhaustive_method -n 6 -i initial_tasks_set.xmlv3 -sched RM -fitness "f1 f5 f3"
--          ./F2T_exhaustive_method2 -n 8 -i test1_paes -nb_partitions 2  -sched HOP -fitness "f1 f2 f3"


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

with chromosome_data_manipulation;
use chromosome_data_manipulation;

with Objective_Functions_and_Feasibility_Checks;
use Objective_Functions_and_Feasibility_Checks;

with Paes_Utilities; use Paes_Utilities;

with Systems;               use Systems;
with exhaustive_method_general_form;
with Dependencies; 		use Dependencies;
with Task_Dependencies; 	use Task_Dependencies;
with Task_Dependencies; 	use Task_Dependencies.Half_Dep_Set;
with MILS_Security; use MILS_Security;



procedure exhaustive_method is

   procedure exhaustive_F2T_architecture_exploration is
     new exhaustive_method_general_form
       (generate_next_solution => chromosome_data_manipulation.generate_next_solution_F2T,
        check_feasibility      => Objective_Functions_and_Feasibility_Checks.Check_Feasibility_of_A_Solution,
        evaluate               => Objective_Functions_and_Feasibility_Checks.evaluate_F2T,
        normalize              => chromosome_data_manipulation.normalize);

   package Fix_IO is new Ada.Text_IO.Fixed_IO(DAY_DURATION); use Fix_IO;
   package Fl_IO is new Ada.Text_IO.float_IO(float); use fl_IO;


   My_System                  : System;
   Sys                            : System;
   Total_cpu_utilization      : float  := 0.00;
   N_diff_periods             : Integer := 10;
   N_resources                : Integer := 0;
   Resource_sharing_factor    : float := 0.00;
   critical_section_ratio     : float := 0.00;

   Dir                        : unbounded_string;
   Dir2                       : unbounded_string;
   Data,Data2                 : Unbounded_String;
   F1,F2,F3,F4,F5             : Ada.Text_IO.File_Type;

   dir1                       : unbounded_string_list;

--     A_capacity                 : natural;
--     A_period                   : natural;
--     A_deadline                 : natural;


   scheduler_Name             : unbounded_String;
   initial_task_set_file_name : unbounded_string;
   fitness_list,str,A_str     : unbounded_String;
   an_index                   : integer;

   Max_hyperperiod            : integer;
   Processor_Utilization      : integer;
   actual_cpu_utilization     : float := 0.00;

   Start,Ends                 : Time;
   A_Duration                 : DURATION; --DAY_DURATION;
   v                          : integer;
   A_solution                 : solution;

   j,k : Integer;
   My_iterator: Tasks_Dependencies_Iterator;
   Dep_Ptr: Dependency_Ptr;
   My_dependencies: Tasks_Dependencies_Ptr;

begin

   Call_Framework.initialize (False);


   -- Get arguments
   --
   loop

      case GNAT.Command_Line.Getopt ("n: nb_partitions: sched: i: fitness: u: n_diff_periods: DW_capacity_encrypt: DW_capacity_decrypt: Key_capacity_DW: UP_capacity: UP_capacity2: DW_capacity_encrypt2: DW_capacity_decrypt2:  partition_period: n_res: rsf: csr:") is
         when ASCII.NUL =>
            exit;

         when 'n' =>
            if Full_Switch = "n" then
               genes := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("Number of tasks = " & genes'img);
            end if;
            if Full_Switch = "nb_partitions" then
               nb_partitions := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("Number of partitions = " & nb_partitions'img);
            end if;
            if Full_Switch = "n_diff_periods" then
               N_diff_periods := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("Number of different periods = " & N_diff_periods'img);
            end if;
            if Full_Switch = "n_res" then
               N_resources := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("Number of resources = " & N_resources'img);
            end if;

        when 'p' =>

            if Full_Switch =  "partition_period" then
	       partition_period := Integer'Value(GNAT.Command_Line.Parameter);
	       Put_Debug (" partitions period");
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

                  OS_Exit (0);
               end if;
            end if;
            if Full_Switch = "select" then
               A_str := To_Unbounded_String (GNAT.Command_Line.Parameter);
               if A_str = To_Unbounded_String("local") or A_str = To_Unbounded_String("global") then
                  A_SelectionStrategy := SelectionStrategy'Value(GNAT.Command_Line.Parameter);
                  Put_Debug ("The Selection Strategy is " & A_SelectionStrategy'img);
               else

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
          when 'D' =>
            if Full_Switch = "DW_capacity_encrypt" then
               DW_capacity_encrypt := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("Capacity of encrypter for real time application = " & DW_capacity_encrypt'img);
            elsif Full_Switch = "DW_capacity_decrypt" then
               DW_capacity_decrypt := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("Capacity of decrypter for real time application = " & DW_capacity_decrypt'img);
            elsif Full_Switch = "DW_capacity_encrypt2" then
               DW_capacity_encrypt2 := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("Capacity of encrypter for multimedia application = " & DW_capacity_encrypt2'img);
            elsif Full_Switch = "DW_capacity_decrypt2" then
               DW_capacity_decrypt2 := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("Capacity of decrypter for real time application = " & DW_capacity_decrypt2'img);
            end if;
         when 'U' =>
            if Full_Switch = "UP_capacity" then
               UP_capacity := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("Capacity of upgraders for real time application = " & UP_capacity'img);
            elsif Full_Switch = "UP_capacity2" then
               UP_capacity2 := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("Capacity of upgraders for multimedia application = " & UP_capacity2'img);
            end if;
         when 'K' =>
            if Full_Switch = "Key_capacity_DW" then
               Key_capacity_DW := Integer'Value(GNAT.Command_Line.Parameter);
               Put_Debug ("Capacity of to set up downgraders Key = " & Key_capacity_DW'img);
            end if;

         when others =>
            OS_Exit (0);
      end case;
   end loop;



   initialize_FitnessFunctions;

   archive               := 200; -- the archive size is fixed to 200
   depth                 := 4;
   minmax                := 0;   -- minimization problem


   -- Interpret arguments to set Global variables
   --
   --
   -- 1) Initializing the list of selected objective functions
   --    and set the number of objectives
   --
   str := fitness_list;
   objectives := 1;
   Put_Debug ("List of fitness functions");


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
      Put_Debug(ASCII.HT & Suppress_Space (To_Unbounded_String ("f" & an_index'Img)) & " => " & FitnessFunctions(an_index).Name);

   end loop;


   -- 2) Initialize the initial design either from the CheddarADL model
   --  provided by the user or. generating a design using parameters
   --  provided by the user (e.g. genes i.e. #functions, Total_cpu_utilization,
   --  N_diff_periods, #resources, Resource_sharing_factor,
   --  critical_section_ratio)
   --
   Initialize(Initial_System);
   for i in 1..genes loop
         A_solution.chrom_task(i) := 1;
   end loop;
   create_system (My_system, A_solution);
   Hyperperiod_of_Initial_Taskset := 4250;

   if (Length (initial_task_set_file_name) /= 0) then

      -- we use the CheddarADL design described in the xml file given in argument
      --
      Ada.text_IO.put_line ("Initial_task_set_file_name : "
                            & To_string(initial_task_set_file_name));

      Read_From_Xml_File (My_System, dir1, initial_task_set_file_name);

--        Hyperperiod_of_Initial_Taskset := Scheduling_Period
--          (My_System.Tasks, to_unbounded_string("Processor"));


      Initial_System := My_System;

   elsif (Total_cpu_utilization /= 0.00) then
      -- We use the provided processor utilization to generate
      -- a schedulable design model
      --
      Put_Debug ("generate a task set of " & genes'img
                 & " tasks with a total processor utilization" & Total_cpu_utilization'img );

      Create(F4,Ada.Text_IO.Out_File,"task_set_generation_runtime.txt");
      start := Clock;
      generator_model( A_solution, nb_partitions, N_diff_periods, Total_cpu_utilization) ;

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


   else

      OS_Exit (0);

   end if;
   ----------------------------------------------------------------------------------------
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
               -- Resolve confidentiality and constraints problem
                  A_solution.chrom_com(j).mode := emission;
                  A_solution.chrom_com(j).link := tsk;
                  A_solution.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));

            elsif(Dep_Ptr.precedence_sink.mils_confidentiality_level< Dep_Ptr.precedence_source.mils_confidentiality_level)
                 OR (Dep_Ptr.precedence_source.mils_integrity_level< Dep_Ptr.precedence_sink.mils_integrity_level)then
                  NonSecure_list(k) := j;
                  k := k+1;

                  --                       A_solution.chrom_com(j).mode := emission;
                  --                       A_solution.chrom_com(j).link := tsk;

                  A_solution.chrom_com(j).mode := noDW;
                  A_solution.chrom_com(j).link := noDW;
                  A_solution.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
            else
                  A_solution.chrom_com(j).mode := noDW;
                  A_solution.chrom_com(j).link := noDW;
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
      -- Check the feasibility of the design given by the user
      --
      if Check_Feasibility_of_A_Solution (A_solution,0) then
         Put_Debug ("The initial design is schedulable");
      else
         Put_Debug ("The initial design is not schedulable!");
         return;
      end if;

   ----------------------------------------------------------------------------------------
   Write_To_Xml_File(A_System  => Initial_System,
                     File_Name => "initial_design.xmlv3");

   evaluate_F2T (A_solution,0);
   actual_cpu_utilization := Float (Processor_Utilization_Over_Period(Initial_System.Tasks, to_unbounded_string("processor1")));


--     for i in 1..genes loop
--
--        A_capacity := Task_Set.Get (My_Tasks   => Initial_System.Tasks,
--                                    Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & i'Img)),
--                                    Param_Name => Capacity);
--
--        A_period := Task_Set.Get (My_Tasks   => Initial_System.Tasks,
--                                  Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & i'Img)),
--                                  Param_Name => Period);
--
--        A_deadline := Task_Set.Get (My_Tasks   => Initial_System.Tasks,
--                                    Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & i'Img)),
--                                    Param_Name => Deadline);
--
--        Put_Debug ("      C" & i'Img & " = " & A_capacity'Img);
--        Put_Debug ("      T" & i'Img & " = " & A_period'Img);
--        Put_Debug ("      D" & i'Img & " = " & A_deadline'Img);
--
--
--     end loop;

   Put(ASCII.LF);
   Put ("The actual processor utilization is : ");
   fl_io.Put (actual_cpu_utilization, 8, 8, 0);
   Put_Debug(" ");--New_Line;

   Put(ASCII.LF);
   Put_Debug ("The hyperperiod of the initial task set = " & Hyperperiod_of_Initial_Taskset'Img);
   Max_hyperperiod := Hyperperiod_of_Initial_Taskset;
   Put (ASCII.LF);


   --------------------------------------
   -- Exact search of the pareto front --
   --------------------------------------


   start := Clock;

   exhaustive_F2T_architecture_exploration;


   Ends := Clock;
   A_Duration := Ends - Start;

   Put("Exact method computation time" & ASCII.HT & ASCII.HT & ": ");
   Put(A_Duration, 10, 10, 0);
   Put(" seconds");
   Put_Debug("");

   Create(F3,Ada.Text_IO.Out_File,"runtime_exhaustive_method.txt");
   Put(F3, A_Duration, 10, 10, 0);
   Close(F3);



   Put_Debug("====================================================================================================== ");
   Put_Debug("    The number of the exact pareto front solutions = " & arclength'Img);
   Put_Debug("    The exact pareto front solutions are ... ");
   Append(Data, "====================================================================================================== " & ASCII.LF);
   Append(Data, "    The number of the exact pareto front solutions = " & arclength'Img & ASCII.LF);
   Append(Data, "    The exact pareto front solutions are ... " & ASCII.LF);

   for i in 1 .. arclength loop

      for k in 1 .. objectives loop
         Append (Data2, arc(i).obj(k)'Img & " ");
      end loop;
      Append (Data2,  ASCII.LF);

      Put_Debug("---------------------------------------------------------------------------------------");
      Put("Solution " & i'img & ":  ");
      Append(Data, "---------------------------------------------------------------------------------------" & ASCII.LF);
      Append(Data, "Solution " & i'img & ":  ");

      print_genome(arc(i));


      for l in 1..genes loop
         Append (Data, arc(i).chrom_task(l)'Img & " ");
      end loop;
      Append (Data,  ASCII.LF);
      for l in 1..genes_com loop
         Append (Data,arc(i).chrom_com(l).mode'Img & " " & arc(i).chrom_com(l).link'Img & " " & To_String(arc(i).chrom_com(l).source_sink) & "    ");
      end loop;
      Append (Data, ASCII.LF);
      Create_system (Sys, arc(i));
      Transform_Chromosome_To_CheddarADL_Model(Sys , arc(i));
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
               str := format (arc(i).obj(v));
            end if;
            Put(str);
            Append (Data,str);
         end if;
      end loop;
      Put_Debug ("  |");
      Put_Debug("-------------------------------------------------------------------------------------------------------");
      Append (Data,  "  |" & ASCII.LF);
      Append (Data, "-------------------------------------------------------------------------------------------------------"
              & ASCII.LF);


   end loop;

   Put_Debug(" ==================================================== "
            & " ================================================== ");

   Append (Data, "======================================================="
           & "=============================================== " & ASCII.LF);


   Create(F4,Ada.Text_IO.Out_File,"solutions_exact_front.txt");
   Unbounded_IO.Put_Line(F4, Data);
   Close(F4);

   Create(F5,Ada.Text_IO.Out_File,"front_optimal.dat");
   Unbounded_IO.Put_Line(F5, Data2);
   Close(F5);




end exhaustive_method;
