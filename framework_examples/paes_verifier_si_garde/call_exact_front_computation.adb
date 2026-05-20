
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


with Text_IO;                           use Text_IO;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with unbounded_strings;                 use unbounded_strings;
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

with Paes_For_Clustering; use Paes_For_Clustering;
with Paes; use Paes;

with unbounded_strings;        use unbounded_strings;

with Tasks; use Tasks;

with Task_Set; use Task_Set;

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

with exact_front_computation; use exact_front_computation;

with Ada.Containers.Vectors;
use Ada.Containers; use Ada.Containers;
with Debug; use Debug;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with float_util; use float_util;

--  call_exact_front_computation
-- To compile : make exact_front
-- To execute :
-- If we want to generate a task set :
--     ./exactFront -n <number_of_functions> -sched <scheduler_Name>  -fitness <fitness_functions>
--            -u <Total_cpu_utilization>  -n_diff_periods <Number_of_different_periods_in_the_function_set>
--            -n_res <Number_of_shared_resources> -rsf <resource_sharing_factor>
--
--Examples: ./exactFront -n 6 -i initial_tasks_set.xmlv3 -sched RM -fitness "f1 f4"
--          ./exactFront -n 6 -sched RM -fitness "f1 f4" -u 90  -n_diff_periods 2  -n_res 2  -rsf 20
--          ./exactFront -n 6 -i initial_tasks_set.xmlv3 -sched RM -fitness "f1 f5 f3"
procedure call_exact_front_computation  is


   package Fix_IO is new Ada.Text_IO.Fixed_IO(DAY_DURATION); use Fix_IO;
   package Fl_IO is new Ada.Text_IO.float_IO(float); use fl_IO;
   package Flt_IO is new Ada.Text_IO.Float_IO(FLOAT); use Flt_IO;
   package dom_Container is new Vectors (Positive, Integer); use dom_Container;

   Dir                        : unbounded_string;
   Dir2                       : unbounded_string;
   Data,Data2                 : Unbounded_String;
   Data5,Data4                : Unbounded_String;
   F                          : Ada.Text_IO.File_Type;



   dir1                       : unbounded_string_list;

   A_capacity                 : natural;
   A_period                   : natural;
   A_deadline                 : natural;

   FileStream                 : stream;
   command                    : unbounded_String;
   F1,F2,F3,F5,F4,F6          : Ada.Text_IO.File_Type;
   line                       : unbounded_String;
   Buffer                     : unbounded_String;

   scheduler_Name             : unbounded_String;
   obj2_Name                  : unbounded_String;
   initial_task_set_file_name : unbounded_string;

   Max_hyperperiod,v,h        : integer;



   Start,Ends                 : Time;
   A_Duration                 : DURATION; --DAY_DURATION;

   Nb_Non_dominated_sol       : integer := 0;
   Exact_Pareto_front         : tab_sol_type(1..100);



   dom_tab                    : dom_Container.Vector;

   Cursor1,Cursor2            : Solution_Container.Cursor;
   Cursor3                    : dom_Container.Cursor;
   k, j                       : integer;
   My_System                  : System;
   fitness_list,str,A_str     : unbounded_String;
   an_index                   : integer;
   ok                         : boolean;

   Total_cpu_utilization      : float  := 0.00;
   N_diff_periods             : Integer := 10;
   N_resources                : Integer := 0;
   Resource_sharing_factor    : float := 0.00;
   critical_section_ratio     : float := 0.00;

   Processor_Utilization      : integer;
   actual_cpu_utilization     : float := 0.00;
   A_utilization              : float;

begin

      Call_Framework.initialize (False);

      create_system (My_system);

      -- Get arguments
      --
      loop

	 case GNAT.Command_Line.Getopt ("n: sched: i: fitness: u: n_diff_periods: n_res: rsf: csr:") is
            when ASCII.NUL =>
               exit;

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
                      OS_Exit (0);
                   end if;
               end if;


            when 'f' =>
               if Full_Switch = "fitness" then
                   fitness_list := To_Unbounded_String (GNAT.Command_Line.Parameter);
                   Put_Line ("The list of selected fitness functions is " & To_string(fitness_list));
               end if;


            when 'i' =>
                   initial_task_set_file_name := To_Unbounded_String (GNAT.Command_Line.Parameter);
                   Put_Debug ("The initial_task_set_file_name is " & To_string(initial_task_set_file_name));

	    when 'u' =>
               Total_cpu_utilization := (Float'Value(GNAT.Command_Line.Parameter)/100.0);
               Processor_Utilization := Integer (Total_cpu_utilization * 100.0);
               Put ("The Total_cpu_utilization = ");
               fl_io.Put (Total_cpu_utilization, 8, 8, 0);
               Put (ASCII.LF);
               New_Line;

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

            when others =>
              OS_Exit (0);
         end case;
      end loop;

      -- the initial_system
      -- and the list of all possible Fitness functions
      init_for_clustering;

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

             Create(F6,Ada.Text_IO.Out_File,"task_set_generation_runtime.txt");
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


             Put(F6, A_Duration, 8, 8, 0);
             Close(F6);

             Delay(1.0);


             initial_task_set_file_name := To_Unbounded_String("initial_tasks_set.xmlv3");

             Initial_System := My_system;


      end if;


      Write_To_Xml_File(A_System  => Initial_System,
                        File_Name => "initial_tasks_set.xmlv3");


      My_system := Initial_System;

      actual_cpu_utilization := 0.00;
      New_line;

      for i in 1..genes loop

            A_capacity := Task_Set.Get (My_Tasks   => My_system.Tasks,
                                        Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & i'Img)),
                                        Param_Name => Capacity);

            A_period := Task_Set.Get (My_Tasks   => My_system.Tasks,
                                      Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & i'Img)),
                                      Param_Name => Period);

            A_deadline := Task_Set.Get (My_Tasks   => My_system.Tasks,
                                        Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & i'Img)),
                                        Param_Name => Deadline);

            Ada.text_IO.Put ("      C" & i'Img & " = " & A_capacity'Img);
            Ada.text_IO.Put ("      T" & i'Img & " = " & A_period'Img);
            Ada.text_IO.Put ("      D" & i'Img & " = " & A_deadline'Img);

            New_Line;
            A_utilization := Float(A_capacity) / Float(A_period);
            actual_cpu_utilization :=  actual_cpu_utilization + A_utilization;

      end loop;

      Put(ASCII.LF);
      Put ("The actual processor utilization is : ");
      fl_io.Put (actual_cpu_utilization, 8, 8, 0);

      New_line;
      Hyperperiod_of_Initial_Taskset := Scheduling_Period (Initial_System.Tasks, to_unbounded_string("processor1"));
      Put(ASCII.LF);
      Put_Line ("The hyperperiod of the initial task set = " & Hyperperiod_of_Initial_Taskset'Img);
      Max_hyperperiod := Hyperperiod_of_Initial_Taskset;


      --------------------------------------
      -- Exact search of the pareto front --
      --------------------------------------

      Create(F3,Ada.Text_IO.Out_File,"Time_of_execution.txt");
      start := Clock;

      New_Line;
      New_Line;
      enumerate_sol;
      Put_Debug(" ************************************************************************************************ ");
      Append (Data5, " ************************************************************************************************ " & ASCII.LF);
      Append (Data5, "    The number of all consistent solutions = " & nb_consistent'Img & ASCII.LF);
      Append (Data5, "    The number of all consistent and schedulable solutions = " & nb_consistent_sched'Img & ASCII.LF);
      Append (Data5, "    consistent and schedulable solutions are ... " & ASCII.LF);
      Put_Line("    The number of all consistent solutions = " & nb_consistent'Img);
      Put_Line("    The number of all consistent and schedulable solutions = " & nb_consistent_sched'Img);
      Put_Debug("    consistent and schedulable solutions are ... ");


      Cursor1 := Solution_Container.First(All_consistent_valid_solutions);
      k := 1;
      while Solution_Container.Has_Element(Cursor1) loop

	  Put_Debug("-------------------------------------------------------------------------------------------------------");
          Append (Data5, "-------------------------------------------------------------------------------------------------------" & ASCII.LF);
          Put_Debug("Solution " & k'img & ":  ");
          Append (Data5, "Solution " & k'img & ":  ");
          print_debug_genome(Solution_Container.Element(Cursor1));

          for l in 1..genes loop
              Append (Data5, Solution_Container.Element(Cursor1).chrom(l)'Img & " ");
          end loop;
          Append (Data5, ASCII.LF);
          Put_Debug("Objectives of solution " & k'img & " : ");
          Append (Data5, "Objectives of solution " & k'img & " : " & ASCII.LF);

	  v := 0;
          for e in 1 .. MAX_FITNESS loop
            if 	FitnessFunctions(e).Is_selected = 1 then
                v := v + 1;
		Append (Data5, "  |  " & FitnessFunctions(e).Name & " = ");
                Put_debug ("  |  " & FitnessFunctions(e).Name & " = " );

		If (e = 4) or (e = 6) then
                        str :=  format (Float(Hyperperiod_of_Initial_Taskset) - Solution_Container.Element(Cursor1).obj(v));
                	--fl_IO.Put(Float(Hyperperiod_of_Initial_Taskset) - arc(q).obj(v), 8, 5, 0);
                	--Append (Data, Float(Float(Hyperperiod_of_Initial_Taskset) - arc(q).obj(v))'Img);
                else
                        str :=  format (Solution_Container.Element(Cursor1).obj(v));
                	--fl_IO.Put(arc(q).obj(v), 8, 5, 0);
                	--Append (Data, arc(q).obj(v)'Img);
                end if;
                Put_debug (str);
                Append (Data5, str);
            end if;
          end loop;
	  Put_Debug ("  |");
          Put_Debug("-------------------------------------------------------------------------------------------------------");
          Append (Data5,  "  |" & ASCII.LF);
          Append (Data5, "-------------------------------------------------------------------------------------------------------"
                  & ASCII.LF);

          Solution_Container.Next(Cursor1);
          k := k + 1;

      end loop;



      Put_Debug(" *********************************************************************************************** ");

      Append (Data5, " ************************************************************************************************ " & ASCII.LF);

      -- Compute the exact pareto front from all consistent and schedulable solutions

      for i in 1 .. nb_consistent_sched loop
          dom_Container.Append(dom_tab, -1);
          --dom_tab(i) := -1;
      end loop;

      Cursor1 := Solution_Container.First(All_consistent_valid_solutions);


      k := 1;

      while Solution_Container.Has_Element(Cursor1) loop
          Cursor2 := Solution_Container.First(All_consistent_valid_solutions);
          j := 1;
          while Solution_Container.Has_Element(Cursor2) loop
              if (k /= j) then

		  h := 1;  ok := true;
		  while (h <= objectives) and ok loop

			if (Solution_Container.Element(Cursor1).obj(h) >= Solution_Container.Element(Cursor2).obj(h)) then
				ok := true;
			else
				ok := false;
			end if;
                        h := h + 1;
		  end loop;

		  if  (ok) then
			h := 1;  ok := false;
		  	while (h <= objectives) and (Not ok) loop

				if (Solution_Container.Element(Cursor1).obj(h) > Solution_Container.Element(Cursor2).obj(h)) then
					ok := true;
				end if;
                                h := h + 1;
		 	 end loop;

			 if ok then
				dom_Container.Replace_Element (Container => dom_tab,
                                                               Index     => k,
                                                               New_Item  => 1);
			 end if;

		  end if;

              end if;
              Solution_Container.Next(Cursor2);
              j := j + 1;
          end loop;
          k := k + 1;
          Solution_Container.Next(Cursor1);
      end loop;

      k := 1;
      Cursor3 := dom_Container.First(dom_tab);
      while dom_Container.Has_Element(Cursor3) loop
            if (dom_Container.Element(Cursor3) = -1) then

               Nb_Non_dominated_sol := Nb_Non_dominated_sol + 1;
               Exact_Pareto_front (Nb_Non_dominated_sol) :=  Solution_Container.Element(All_consistent_valid_solutions,k);

            end if;
            k := k + 1;
            dom_Container.Next(Cursor3);
      end loop;



      Put_Line("====================================================================================================== ");
      Put_Line("    The number of the exact pareto front solutions = " & Nb_Non_dominated_sol'Img);
      Put_Line("    The exact pareto front solutions are ... ");
      Append(Data2, "====================================================================================================== " & ASCII.LF);
      Append(Data2, "    The number of the exact pareto front solutions = " & Nb_Non_dominated_sol'Img & ASCII.LF);
      Append(Data2, "    The exact pareto front solutions are ... " & ASCII.LF);

      for i in 1..Nb_Non_dominated_sol loop

        for k in 1 .. objectives loop
             Append (Data4, Exact_Pareto_front(i).obj(k)'Img & " ");
        end loop;
        Append (Data4,  ASCII.LF);

        Put_Line("---------------------------------------------------------------------------------------");
   	Put("Solution " & i'img & ":  ");
        Append(Data2, "---------------------------------------------------------------------------------------" & ASCII.LF);
   	Append(Data2, "Solution " & i'img & ":  ");
   	print_genome(Exact_Pareto_front(i));
	for l in 1..genes loop
                     Append (Data2, Exact_Pareto_front(i).chrom(l)'Img & " ");
        end loop;
        Append (Data2, ASCII.LF);

	Appling_clustering_rules(My_system , Exact_Pareto_front(i));
        Write_To_Xml_File (A_System  => My_system,
                           File_Name => To_string (Suppress_Space (To_Unbounded_String ("solution" & i'Img & ".xmlv3"))));

        Put_Line("Objectives of solution " & i'img & " : ");
        Append (Data2, "Objectives of solution " & i'img & " : " & ASCII.LF);

	v := 0;
        for e in 1 .. MAX_FITNESS loop
            if 	FitnessFunctions(e).Is_selected = 1 then
               v := v + 1;
	       Append (Data2, "  |  " & FitnessFunctions(e).Name & " = ");
               Put ("  |  " & FitnessFunctions(e).Name & " = " );
	       If (e = 4) or (e = 6) then
                    str := format (Float(Hyperperiod_of_Initial_Taskset) - Exact_Pareto_front(i).obj(v));
               else
                    str := format (Exact_Pareto_front(i).obj(v));
               end if;
               Put(str);
               Append (Data2,str);
            end if;
        end loop;
	Put_line ("  |");
        Put_Line("-------------------------------------------------------------------------------------------------------");
	Append (Data2,  "  |" & ASCII.LF);
        Append (Data2, "-------------------------------------------------------------------------------------------------------"
                & ASCII.LF);

      end loop;
      Put_Line("===================================================="
               & "================================================== ");
      Append (Data2, "======================================================="
              & "=============================================== " & ASCII.LF);




      Create(F2,Ada.Text_IO.Out_File,"solutions_exact_front.txt");
      Unbounded_IO.Put_Line(F2, Data2);
      Close(F2);

      Create(F4,Ada.Text_IO.Out_File,"front_optimal.dat");
      Unbounded_IO.Put_Line(F4, Data4);
      Close(F4);


      Create(F5,Ada.Text_IO.Out_File,"Valid_sol1.txt");
      Unbounded_IO.Put_Line(F5, Data5);
      Close(F5);

      Ends := Clock;
      A_Duration := Ends - Start;

      Put("Exact method computation time" & ASCII.HT & ASCII.HT & ": ");
      Put(A_Duration, 8, 8, 0);
      Put(" seconds");
      Put_Debug("");

      Put(F3, A_Duration, 8, 8, 0);
      Close(F3);


end call_exact_front_computation;
