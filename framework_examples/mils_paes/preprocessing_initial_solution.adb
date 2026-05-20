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



-- Input/Output                                                                              :
-- Input                                                                                     :
--	(1) functional_specification.xmlv3  => the CheddarADL model associated to the functional spec, i.e.
--					       each function is assigned to a task.
--
-- Outputs                                                                                   :
--	(1) initial_design_solution.xmlv3   => the CheddarADL model of the generated initial solution
-- 	(2) initial_chromosome_solution.txt => the chromosome representation of the generated initial solution
--

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Directories; use Ada.Directories;

with scheduler_Interface; use scheduler_Interface;
with framework_config;  use framework_config;
with feasibility_test.feasibility_interval; use feasibility_test.feasibility_interval;
with feasibility_test.processor_utilization; use feasibility_test.processor_utilization;
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

with Processors;          use Processors;
with Processor_Set;       use Processor_Set;
with processor_interface; use processor_interface;
use Processor_Set.Generic_Processor_Set;
with Scheduler_Interface; use Scheduler_Interface;
with Address_Spaces;      use Address_Spaces;
with Address_Space_Set;   use Address_Space_Set;

with Core_Units; use Core_Units;
use Core_Units.Core_Units_Table_Package;

with Tasks; use Tasks;
with Task_Set; use Task_Set;
with Resources; use Resources;
with Resource_Set; use Resource_Set;
use Resources.Resource_Accesses;
with float_util; use float_util;

with chromosome_data_manipulation;
use chromosome_data_manipulation;

with Objective_Functions_and_Feasibility_Checks;
use Objective_Functions_and_Feasibility_Checks;

with Paes_Utilities; use Paes_Utilities;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with float_util; use float_util;

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Directories; use Ada.Directories;


procedure preprocessing_initial_solution is

   Functional_spec_file_name           : unbounded_string;
   Functional_spec_system              : System;
   preprocessed_initial_sol_system     : System;
   dir1                                : unbounded_string_list;
   Number_of_resources_functional_spec : Resources_Range;

   Index_of_a_resource                 : Resources_Range;

   Number_of_functions_functional_spec : Tasks_Range;
   Nb_critical_sections_of_Resource_i  : Resource_Accesses_Range;
   Nb_CS_of_a_resource                 : Resource_Accesses_Range;
   A_Resources_set                     : Resources_Set;
   A_resource                          : Generic_Resource_Ptr;
   Nb_CS_of_resources                  : array (1 .. Max_Resources) of Resource_Accesses_Range;
   Index_of_sorted_resources           : array (1 .. Max_Resources) of Resources_Range;
   permutation                         : integer := 1;

   tmp1                                : Resource_Accesses_Range;
   tmp2                                : Resources_Range;

   A_preprocessed_initial_solution                          : solution;
   Is_function_assigned_to_a_task      : array (1 .. MAX_TASKS) of integer;
   Funct                               : array (1 .. MAX_Sections) of integer;
   Functions_periods                   : array (1 .. MAX_Sections) of natural;
   Functions_capacities                : array (1 .. MAX_Sections) of natural;
   tmp                                 : integer;
   A_task_name                         : Unbounded_String;
   A_function_index                    : integer;
   Nb_functions_accessing_the_resource : integer;
   A_task_index	                       : integer;
   tmp_mod                             : integer;
   task_period, task_capacity          : natural;
   Is_assigned                         : boolean;

   F                                   : Ada.Text_IO.File_Type;
   Data                                : Unbounded_String;
   One_to_one_mapping_solution         : solution;

   v                                   : integer;
   str, A_str                          : unbounded_String;


begin

   Call_Framework.initialize (False);

   Functional_spec_file_name := To_Unbounded_String (Argument (1));

   Read_From_Xml_File (Functional_spec_system, dir1, Functional_spec_file_name);

   -- Resources are sorted in decreasing order of number
   -- of functions that use resources.
   -- Res                                                                                    : the set of resources in the functional specification,
   -- sorted in decreasing order of use (i.e. by the number of functions
   -- using each resource);

   -- Res is an array containing index of resources sorted in decreasing
   -- order of number of functions that use resources (i.e. number of critical sections)

   -----------------------------------------------------------------------------
   -- Initialize parameters
   --
   Number_of_resources_functional_spec := Get_Number_Of_Resource_From_Processor
     (Functional_spec_system.Resources, To_Unbounded_String ("Processor"));

   Put_Line ("Number_of_resources_in_Functional_spec = "
	     & Number_of_resources_functional_spec'img);

   Number_of_functions_functional_spec := Get_Number_Of_Task_From_Processor
     (Functional_spec_system.Tasks, To_Unbounded_String ("Processor"));

   Put_Line ("Number_of_tasks_in_Functional_spec = "
	     & Number_of_functions_functional_spec'img);

   genes := Integer (Number_of_functions_functional_spec);

   --scheduling with RM
   The_Scheduler := Rate_Monotonic_Protocol;
   Task_priority := 1;
   Sched_policy  := SCHED_FIFO;

   Initial_System := Functional_spec_system;

   Hyperperiod_of_Initial_Taskset := Scheduling_Period
     (Functional_spec_system.Tasks, to_unbounded_string ("Processor"));

   objectives := 3;
   initialize_FitnessFunctions;
   -- selected fitness functions are: f1 f4 and f6
--     FitnessFunctions (1).Is_selected := 1;
--     FitnessFunctions (4).Is_selected := 1;
--     FitnessFunctions (9).Is_selected := 1;
   FitnessFunctions (1).Is_selected := 1;
   FitnessFunctions (2).Is_selected := 1;
   FitnessFunctions (3).Is_selected := 1

   -- Initialize one-to-one mapping solution
   for i in 1 .. genes loop
     One_to_one_mapping_solution.chrom_task(i) := i;
   end loop;

   If Check_Feasibility_of_A_Solution (One_to_one_mapping_solution, 0) then
      evaluate_F2T (One_to_one_mapping_solution, 0);
   end if;

   -----------------------------------------------------------------------------

   Put_Line ("*** Before sorting ***");
   for i in 1 .. Number_of_resources_functional_spec loop

      Index_of_sorted_resources (Integer (i)) := i;

      -- Extracting all resources of the initial system model
      -- in which each function is assigned to a task
      -- So, in the initial system model there is no difference
      -- between a task or a function   (Function1 == Task1)

      A_resource := search_Resource (Functional_spec_system.Resources,
				     suppress_space (To_Unbounded_String ("R" & i'Img)));

      Nb_critical_sections_of_Resource_i := A_resource.critical_sections.nb_entries;

      Nb_CS_of_resources (Integer (i)) := Nb_critical_sections_of_Resource_i;

      Put_Line ("R(" & i'Img & ") || #SC =>> "
		& i'Img & " || " & Nb_critical_sections_of_Resource_i'Img);

   end loop;

   --  sort elements of Nb_CS_of_resources in the decreasing order of #SC
   --
   permutation := 1;
   while permutation = 1 loop
      permutation := 0;
      for j in 1 .. Integer (Number_of_resources_functional_spec)-1 loop
	 if (Nb_CS_of_resources (j) < Nb_CS_of_resources (j + 1)) then
	    -- permut Nb_CS_of_resources (j) and Nb_CS_of_resources (j+1)
	    tmp1 := Nb_CS_of_resources (j);
	    Nb_CS_of_resources (j) := Nb_CS_of_resources (j + 1);
	    Nb_CS_of_resources (j + 1) := tmp1;
	    --
	    -- permut Index_of_sorted_resources (j) and Index_of_sorted_resources (j+1)
	    tmp2 := Index_of_sorted_resources (j);
	    Index_of_sorted_resources (j) := Index_of_sorted_resources (j + 1);
	    Index_of_sorted_resources (j + 1) := tmp2;

	    permutation := 1;
	 end if;
      end loop;
   end loop;

   Put_Line ("*** After sorting ***");
   for i in 1 .. Number_of_resources_functional_spec loop


      Put_Line ("R(" & Index_of_sorted_resources (Integer (i))'Img & ") || #SC =>> "
		& Index_of_sorted_resources (Integer (i))'Img & " || " & Nb_CS_of_resources (Integer (i))'Img);

   end loop;

   -- At the begining all functions are not assigned to tasks
   -- if the function F_i is assigned to a task => Is_function_assigned_to_a_task (i) = 1
   -- Is_function_assigned_to_a_task (i) = 0, otherwise
   for i in 1 .. Integer(Number_of_functions_functional_spec) loop
      Is_function_assigned_to_a_task (i) := 0;
      A_preprocessed_initial_solution.chrom_task(i) := 0;
   end loop;

   -- By looking at sorted resources one by one,
   -- functions that use the same resource are assigned
   -- to the same task wherever possible.
   --
   A_task_index := 1;

   for i in 1 .. Number_of_resources_functional_spec loop


      Index_of_a_resource := Index_of_sorted_resources (Integer (i));

      Nb_CS_of_a_resource := Nb_CS_of_resources (Integer (i));

      -- As we assume that each function F_k accessing a resource R_i,
      -- issues only a single request of R_i per job.
      -- This means each critical section of R_i is associated to a different
      -- function.
      --
      Nb_functions_accessing_the_resource := Integer(Nb_CS_of_a_resource);

      A_resource :=
	search_Resource (Functional_spec_system.Resources,
		  suppress_space (To_Unbounded_String ("R" & Index_of_a_resource'Img)));

      --        Nb_critical_sections_of_Resource_i := A_resource.critical_sections.nb_entries;
      --
      Put_Line ("===============================================");
      Put_Line ("+++++ R (" & Index_of_a_resource'img & ") +++++");
      Put ("functions using R (" & Index_of_a_resource'img & ") are                          : ");
      for j in 0 .. Nb_CS_of_a_resource - 1 loop
	 -- A task name is in the form "Taskxxx"
	 -- where xxx is the index of the task (i.e the function)
	 -- Here, we trait resources of the initial model
	 -- were each Task represent a function i.e. Task1 => Function1
	 -- Task2 => Function2 ...
	 A_task_name := A_resource.Critical_sections.entries (j).item;
	 A_function_index := Integer'Value
	   (to_string (Unbounded_Slice (A_task_name, length (To_Unbounded_String ("Task"))+1, length (A_task_name))));

	 Funct (Integer (j)+1) := A_function_index;
	 Put ("F(" & A_function_index'img & ")    ");
      end loop;

      New_Line;
      Put_Line("::::::::::::::::::::::::::::::::::::::::::::::::::");
      -- Sorting Funct in increasing order of function periods
      for j in 1 .. Nb_functions_accessing_the_resource loop
	 Functions_periods (j) :=
	   Get (My_Tasks   => Functional_spec_system.Tasks,
	 Task_Name  => Suppress_Space
	   (To_Unbounded_String ("Task" & Funct(j)'Img)),
	 Param_Name => Period);

	 Put (" Period (F( " & Funct (j)'Img & ")) = "
       & Natural'Image (Functions_periods (j)) & "   ");

	 Functions_capacities (j) :=
	   Get (My_Tasks   => Functional_spec_system.Tasks,
	 Task_Name  => Suppress_Space
	   (To_Unbounded_String ("Task" & Funct(j)'Img)),
	 Param_Name => Capacity);

      end loop;

      New_line;

      for j in 1 .. Nb_functions_accessing_the_resource loop

	 Put (" Capacity (F( " & Funct (j)'Img & ")) = "
       & Natural'Image (Functions_capacities (j)) & "   ");

      end loop;

      permutation := 1;
      while permutation = 1 loop
	 permutation := 0;
	 for j in 1 .. (Nb_functions_accessing_the_resource - 1) loop
	    if (Functions_periods (j) > Functions_periods (j + 1)) then
	       -- Functions_periods (j) and Functions_periods (j+1)
	       tmp := Functions_periods (j);
	       Functions_periods (j) := Functions_periods (j + 1);
	       Functions_periods (j + 1) := tmp;

	       -- Funct (j) and Funct (j+1)
	       tmp := Funct (j);
	       Funct (j) := Funct (j + 1);
	       Funct (j + 1) := tmp;
	       permutation := 1;
	    end if;
	 end loop;
      end loop;

      Put ("functions using R (" & Index_of_a_resource'img & ") sorted by increasing periods : ");
      for j in 1 .. Nb_functions_accessing_the_resource loop
	 Put ("F(" & Integer'Image (Funct (j)) & ")    ");
      end loop;
      New_line;
--        for j in 1 .. Nb_functions_accessing_the_resource loop
--  	  Put (" Period (F( " & Funct (j)'Img & ")) = "
--         & Natural'Image (Functions_periods (j)) & "   ");
--        end loop;

      New_line;
      Put_Line ("===============================================");

      -- group harmonic functions in the table Funct
      -- PS : only not assigned functions
      --
      for j in 1 .. Nb_functions_accessing_the_resource loop

	 -- if Funct(j) is not assigned to a task then we determine
	 -- functions in Funct (other than Funct(j)) that are harmonic
	 -- Funct(j)
         --
	 Is_assigned := false;

	 if (A_preprocessed_initial_solution.chrom_task (Funct (j)) = 0) then

	    task_period := Functions_periods (j);
	    task_capacity := Functions_capacities (j);
	    -- determine the set of harmonic functions (other than Funct(j))
	    -- with the function Funct(j) and that are not yet assigned to tasks
	    --
	    --z := 0;

	    for k in 1 .. Nb_functions_accessing_the_resource loop

	       if k /= j then

		  if Functions_periods (j) > Functions_periods (k) then
		     tmp_mod := Functions_periods (j) mod Functions_periods (k);
		  else
		     tmp_mod := Functions_periods (k) mod Functions_periods (j);
		     task_period := Functions_periods (j);
		  end if;

		  if tmp_mod = 0 and A_preprocessed_initial_solution.chrom_task (Funct (k)) = 0 then
		     task_capacity := task_capacity + Functions_capacities (k);
		     if task_period > Functions_periods (k) then
			task_period := Functions_periods (k);
		     end if;

		     if task_capacity < task_period then
			Is_assigned := true;
			if A_preprocessed_initial_solution.chrom_task (Funct (j)) = 0 then
			   A_preprocessed_initial_solution.chrom_task (Funct (j)) := A_task_index;
			end if;
			A_preprocessed_initial_solution.chrom_task (Funct (k)) := A_task_index;
		     end if;

		     --z := z + 1;
		     --Harmonic_funct_set (z) := Funct (k);
		  end if;

	       end if;

	    end loop;

	    if is_assigned then
	       A_task_index := A_task_index + 1;
	    end if;

	 end if;


      end loop;

   end loop;

   print_genome (A_preprocessed_initial_solution);
   -- For functions that are not yet assigned, assign each of them to a task;
   for j in 1 .. genes loop
      if A_preprocessed_initial_solution.chrom_task (j) = 0 then
	 A_preprocessed_initial_solution.chrom_task (j) := A_task_index;
	 A_task_index := A_task_index + 1;
      end if;
   end loop;
   print_genome (A_preprocessed_initial_solution);
   normalize (A_preprocessed_initial_solution);
   Put ("After normalization the candidate initial solution is : ");
   print_genome (A_preprocessed_initial_solution);

   -- once a possible initial solution is produced, we check its
   -- feasibility to decide whether to accept or rearrange it by mutation to
   -- regenerate from it a feasible one.

   If Check_Feasibility_of_A_Solution (A_preprocessed_initial_solution,1) then
      Put_Line (" The produced candidate initial solution"
		& " is feasible and we accept it :-)");
   else
      Put_Line (" The produced candidate initial solution"
		& " is NOT feasible and we mutate it in order"
		  & " to generate from it a feasible solution");
      mutate_F2T (A_preprocessed_initial_solution,1);
      Put ("After mutation, the initial solution is:  ");
      print_genome (A_preprocessed_initial_solution);
   end if;

   Put_Line ("øøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøø");
   Put ("The final initial solution is:  ");
   print_genome (A_preprocessed_initial_solution);
   Put_Line ("øøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøøø");

   -- Save the produced preprocessed initial solution:
   -- the chromosome representation: chrom_preprocessed_initial_solution.txt
   -- and the associated CheddarADL model: design_preprocessed_initial_solution.xmlv3

   for l in 1..genes loop
      Append (Data, A_preprocessed_initial_solution.chrom_task (l)'Img & " ");
   end loop;

   Create(F, Ada.Text_IO.Out_File, "chrom_preprocessed_initial_solution.txt");
   Unbounded_IO.Put(F, Data);
   Close(F);


   Create_system (preprocessed_initial_sol_system, A_preprocessed_initial_solution);
   Transform_Chromosome_To_CheddarADL_Model
     (preprocessed_initial_sol_system, A_preprocessed_initial_solution);

   Write_To_Xml_File (A_System  => preprocessed_initial_sol_system,
                      File_Name => "design_preprocessed_initial_solution.xmlv3");

   -- print eval les 2 sols: pour comparer blocking-time (f6) et laxity (f4)
   Put_line ("Objectives of the two initial solutions:");

   Put_Line ("-------------------------------------------------------------------------------------------------------");

   Put ("1-1 initial Sol: ");

   print_genome (One_to_one_mapping_solution);
   Put_Line("Objectives of 1-1 initial Sol: ");

   v := 0;

   for e in 1 .. MAX_FITNESS loop

      if FitnessFunctions (e).Is_selected = 1 then

            v := v + 1;

            Put ("  |  " & FitnessFunctions(e).Name & " = " );
            If (e = 4) or (e = 6) then
               str := format (Float(Hyperperiod_of_Initial_Taskset) - One_to_one_mapping_solution.obj(v));
            else
               str := format (One_to_one_mapping_solution.obj(v));
            end if;
            Put(str);
      end if;

   end loop;


   Put_line ("  |");

   Put_Line ("-------------------------------------------------------------------------------------------------------");


  Put_Line ("-------------------------------------------------------------------------------------------------------");

   Put ("Preprocessed initial Sol: ");
   evaluate_F2T (A_preprocessed_initial_solution, 1);
   print_genome (A_preprocessed_initial_solution);
   Put_Line("Objectives of Preprocessed initial Sol: ");

   v := 0;

   for e in 1 .. MAX_FITNESS loop

      if FitnessFunctions (e).Is_selected = 1 then

            v := v + 1;

            Put ("  |  " & FitnessFunctions(e).Name & " = " );
            If (e = 4) or (e = 6) then
               str := format (Float(Hyperperiod_of_Initial_Taskset) - A_preprocessed_initial_solution.obj(v));
            else
               str := format (A_preprocessed_initial_solution.obj(v));
            end if;
            Put(str);
      end if;

   end loop;


   Put_line ("  |");

   Put_Line ("-------------------------------------------------------------------------------------------------------");

end preprocessing_initial_solution;

