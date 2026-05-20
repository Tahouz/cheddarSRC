
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
--    $Rev: 3477 $
--    $Date: 2020-07-13 11:43:48 +0200 (Mon, 13 Jul 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions;

with Ada.Strings;               use Ada.Strings;
with Ada.Strings.Fixed;         use Ada.Strings.Fixed;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random ;
with unbounded_strings;        use unbounded_strings;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
with Ada.Strings; use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Directories; 			use Ada.Directories;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Unbounded_Strings; use Unbounded_Strings;
with convert_unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
use unbounded_strings.strings_table_package;
with Ada.Strings; use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;

with Ada.text_IO; use Ada.text_IO;
with Ada.Integer_text_IO; use Ada.Integer_text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;


with Tasks; use Tasks;
with Task_Set; use Task_Set;
with Resources; use Resources;
with Resource_Set; use Resource_Set;

with convert_unbounded_strings;
use unbounded_strings.unbounded_string_list_package;


with Scheduler_Interface; use Scheduler_Interface;
with Address_Spaces;      use Address_Spaces;
with Address_Space_Set;   use Address_Space_Set;


with Call_Framework;                    use Call_Framework;
with Call_Framework_Interface;          use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with Call_Scheduling_Framework;         use Call_Scheduling_Framework;

with Pipe_Commands; use Pipe_Commands;
with Ada.Text_IO; use Ada.Text_IO;

with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Directories; use Ada.Directories;

with GNAT.OS_Lib;  use GNAT.OS_Lib;
with Debug; use Debug;

with Random_Tools; use Random_Tools;


use unbounded_strings.strings_table_package;

with architecture_factory; use architecture_factory;

with Ada.Integer_text_IO; use Ada.Integer_text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;


with Systems;  use Systems;
with Processors;          use Processors;
with Processor_Set;       use Processor_Set;
with processor_interface; use processor_interface;
use Processor_Set.Generic_Processor_Set;

with Core_Units; use Core_Units;
use Core_Units.Core_Units_Table_Package;

with natural_util; 		use natural_util;
with feasibility_test.feasibility_interval; use feasibility_test.feasibility_interval;

with Objective_Functions_and_Feasibility_Checks;
use Objective_Functions_and_Feasibility_Checks;

with integer_util; use integer_util;

use Resources.Resource_Accesses;
with float_util; use float_util;

with Ada.Characters.Latin_1;
use Ada.Characters;
with Ada.Text_IO;  use Ada.Text_IO;
with GNAT.String_Split; use GNAT;
with Memories; use Memories;
with Dependencies; 		use Dependencies; 
with Task_Dependencies; 	use Task_Dependencies; 
with Task_Dependencies; 	use Task_Dependencies.Half_Dep_Set;


package body Chromosome_Data_Manipulation is

   --------------
   -- init_F2T --
   --------------

   procedure init_F2T
   is
      F         : Ada.Text_IO.File_Type;
      gene_i    : unbounded_String;
      chrom_str : unbounded_String;
      --  Subs is populated by the actual substrings.
      Subs      : String_Split.Slice_Set;
      --  just an arbitrary simple set of whitespace.
      Seps : constant String := " " & Latin_1.HT;

   begin

      if Using_preprocessed_initial_sol then
	 -- Initialize the current solution c with the preprocessed
	 -- initial solution

	 -- 1/ get the chromosome of the preprocessed initial solution
	 -- from the file chrom_preprocessed_initial_solution.txt
	 Open (File => F,
	       Mode => Ada.Text_IO.In_File,
	       Name => "chrom_preprocessed_initial_solution.txt");

	 loop
	    exit when Ada.Text_IO.End_Of_File (F);
	    Ada.Strings.Unbounded.Append (chrom_str, To_Unbounded_String(Get_Line (File => F)));
	 end loop;
	 close (F);
	 Put_Line ("chrom_str: " & To_string (chrom_str));
	 -- 2/ extract gene values from chrom_str to initialize the
	 -- initial current solution
	 -- The following code is inspired from:
	 -- http://wiki.ada-dk.org/gnat.string_split_basic_usage_example
	 String_Split.Create (S        => Subs,
		       From            => To_String(chrom_str),
		       Separators      => Seps,
		       Mode            => String_Split.Multiple);
	 for i in 1 .. genes loop
	    c.chrom_task (i) := Integer'Value(String_Split.Slice (Subs, String_Split.Slice_Number(i+1)));
	 end loop;
	 Put ("The initial preprocessed solution: ");
	 print_genome(c);

      else
	 -- initialize the current solution c with 1-1 fctsTotasks mapping
	 -- solution
         --
	 for i in 1 .. genes loop
	    c.chrom_task(i) := i;
	 end loop;

      end if;

      If Check_Feasibility_of_A_Solution (One_to_one_mapping_solution, 0) then
	 evaluate_F2T (c, 0);
      end if;

   end init_F2T;
   
   

   ----------------
   -- mutate_F2T --
   ----------------

   procedure mutate_F2T (s : in out solution; eidx : in Natural) is

      random_task, fn : integer;

      A_system : System;
      A_Task_set, New_Task_set : Tasks_Set;
      Nb_tasks, New_nb_tasks : integer;
      period_fn, period_j : natural;

      harmonic_tasks : chrom_type;
      tmp_mod, k, j, counter : integer;
      is_harmonic, exist : boolean;

      Sol_is_mutated : boolean;

      A_sol : solution;
      Nb_harmonic_tasks : integer;


      G : Ada.Numerics.Float_Random.Generator;
      New_resource_set : Resources_Set;

   begin

      Create_system (A_system);
      sol_is_mutated := false;
      reset(G); -- Initialise the float generator

      -- I think, we should add a counter, if this counter reach a threashold
      -- and it failed to generate a mutated solution then we stop

      counter := 1;

      while (not sol_is_mutated) and (counter <= 100000) loop

         Put_Debug ("................................................................");
         Put_Debug ("The " & counter'img & " attempt of the mutation procedure ");
         Put_Debug ("................................................................");

         A_sol := s;

         Transform_Chromosome_To_CheddarADL_Model (A_system, A_sol);

         Nb_tasks := Number_of_tasks (A_sol);

         fn := 0;
         --  choose randomly an index of a function between 1 and genes
         while (fn > genes) or (fn < 1) loop
            fn := integer (float(genes) * random(G));
         end loop;


         Put_Debug ("The randomly chosen function is : " & fn'img);

         -- determine the set of harmonic tasks with the choosen function fn
         K := 0;
         period_fn := Get (My_Tasks   => Initial_system.Tasks,
                           Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & fn'Img)),
                           Param_Name => Period);
         for j in 1 .. Nb_tasks loop

            period_j  := Get (My_Tasks   => A_system.Tasks,
                              Task_Name  => Suppress_Space (To_Unbounded_String ("Task" & j'Img)),
                              Param_Name => Period);

            if period_fn > period_j then
               tmp_mod := period_fn mod period_j;
            else
               tmp_mod := period_j mod period_fn;
            end if;

            if tmp_mod = 0 then
               Put_Debug ("period_fn = " & period_fn'Img & "  period_j = " & period_j'Img);
               k := k + 1;
               harmonic_tasks (k) := j;
               Put_Debug ("harmonic_tasks (" & k'Img & ") = " & j'Img);
            end if;
         end loop;

         nb_harmonic_tasks := k;

         -- if the set of tasks which are harmonic with "fn" is not empty
         -- else i.e the function fn is not harmonic with any task, only its own task
         -- then we repeat the procedure with another function chosen randomly
         if nb_harmonic_tasks /= 0 then

            -- choose randomly a task random_task over tasks in the set harmonic_tasks
            -- (including tau_j = chrom[fn]);

            is_harmonic := false;

            while (not is_harmonic) loop

               random_task := 0;

               -- generate a random number of task comprised between 1 and nb_tasks
               while (random_task > nb_tasks) or (random_task < 1) loop
                  random_task := integer (float(nb_tasks) * random(G));
               end loop;


               Put_Debug ("nb_tasks =" & nb_tasks'img & " and The task chosen randomly is :" & random_task'img);
               Put_Debug ("The harmonic tasks with " & fn'Img & " are: ");
               for j  in 1 .. nb_harmonic_tasks loop
                  Put_Debug ("  " & harmonic_tasks (j)'Img);
               end loop;
               Put_Debug(" ");--New_Line;

               -- verify if random_task is among the set of harmonic tasks
               j := 1;
               exist := false;
               while (not exist) and (j <= nb_harmonic_tasks) loop
                  if random_task = harmonic_tasks (j) then
                     exist := true;
                  end if;
                  j := j + 1;
               end loop;

               if exist then
                  is_harmonic := true;
               end if;

            end loop;


            if (random_task /= A_sol.chrom_task(fn)) then  -- if the function "fn" is not intially in
               -- the task "random_task" the "fn" is moved
               -- to the task "random_task"
               A_sol.chrom_task(fn) := random_task;
               sol_is_mutated := true;

            elsif (not is_isolated (fn, A_sol)) then
               -- if coincidentally the function "fn" is intially in the task "random_task"
               -- then if the function "fn" is not initially isolated, we create a new task
               -- in which we isolate it
               -- else i.e the function "fn" is alone then we repeat the procedure with another function
               -- chosen randomly
               A_sol.chrom_task(fn) := nb_tasks + 1;
               sol_is_mutated := true;
            end if;

         end if;

         if sol_is_mutated then

            Put_Debug(" ");
            Put_Debug ("The mutated solution is : ");
            print_debug_genome(A_sol);
            Put_Debug(" ");
            -- normalize the mutate solution
            normalize(A_sol);
            Put_Debug(" ");
            Put_Debug ("After normalization the candidate solution is : ");
            print_debug_genome(A_sol);
            Put_Debug(" ");

            -- After generating a mutate solution, we shoud verify
            -- if it is feasible else we must regenerate a new candidate solution:
            --

            If Check_Feasibility_of_A_Solution (A_sol,eidx) then
               Put_Debug (" The candidate solution is feasible");

               New_nb_tasks := Number_of_tasks (A_sol);

               sol_is_mutated := true;
               s := A_sol;

            else
               Put_Debug (" The candidate solution is NOt Feasible " &
                          " we should regenerate another candidate solution");
               sol_is_mutated := false;
               counter := counter + 1;
            end if;

         end if;

      end loop;

      if counter > 100000 then
         Put_Debug(" ");--New_Line;
         Put_Debug(" ");--New_Line;
         Put_Debug("Exit the program, there is no schedulable candidate solution !");
         Put_Debug(" ");--New_Line;
         Put_Debug(" ");--New_Line;
         OS_Exit (0);
      end if;

   end mutate_F2T;
   
  

   --------------------------------
   -- generate_next_solution_F2T --
   --------------------------------

   procedure generate_next_solution_F2T
     (s                         : in out solution;
      m                         : in out chrom_Type;
      space_search_is_exhausted : out boolean)
   is

      i,max  : integer;

   begin

      -- Update s: 1 1 1 1 -> 2 1 1 1 -> 1 2 1 1 -> 2 2 1 1 -> 3 2 1 1 -> 1 1 2 1 ...
      i := 1;
      s.chrom_task(i) := s.chrom_task(i) + 1;
      while ((i < genes) and (s.chrom_task(i) > m(i) + 1)) loop
         s.chrom_task(i) := 1;
         i := i + 1;
         s.chrom_task(i) := s.chrom_task(i) + 1;
      end loop;

      -- If i is has reached n-1 th element, then the last unique partitiong
      -- has been found
      --
      if (i = genes) then
         space_search_is_exhausted := true;
      else
         -- Because all the first i elements are now 1, s[i] (i + 1 th element)
         -- is the largest. So we update max by copying it to all the first i
         -- positions in m.
         max := s.chrom_task(i);
         if (m(i) > max) then
            max := m(i);
         end if;
         for j in 1 .. i-1 loop
            m(j) := max;
         end loop;

         space_search_is_exhausted := false;

      end if;

   end generate_next_solution_F2T;

   -----------------
   -- is_isolated --
   -----------------
   function is_isolated(function_index : integer;
                        s              : solution) return boolean
   is
      result : boolean := true;
      i      : integer :=  1;
   begin
      while (result and i <= genes) loop
         if (s.chrom_task(i) = s.chrom_task(function_index)) and then (function_index /= i) then
            result := false;
         end if;
         i := i + 1;
      end loop;

      return result;
   end is_isolated;

   ---------------
   -- Normalize --
   ---------------


   procedure normalize(s : in out solution)
   is
      nb_tasks : integer := 1;
      --  the vector var is used to know if a gene is normalized or not yet
      var : chrom_Type;
   begin
      --  initialization of the vector var.
      for i in 1..genes loop
         var(i) := 0;
      end loop;

      ------------------------------------------------------------
      --  if var(i) = 0   ==>  s.chrom(i) is not yet normalized
      --  if var(i) = 1   ==>  s.chrom(i) is normalized
      ------------------------------------------------------------

      for i in 1..genes loop

         if (var(i) = 0) then

            for j in i+1..genes loop
               if (s.chrom_task(j) = s.chrom_task(i)) and then (var(j) = 0) then
                  var(j) := 1;
                  --  if s.chrom(i) is not normalized then all s.chrom(j) (which egal s.all.chrom(i))
                  --  are not normalized
                  if (s.chrom_task(i) /= nb_tasks) then
                     s.chrom_task(j) := nb_tasks;
                  end if;
               end if;
            end loop;

            -- we normalize s.chrom(i)
            if (s.chrom_task(i) /= nb_tasks) then
               s.chrom_task(i) := nb_tasks;
            end if;
            var(i) := 1;
            nb_tasks := nb_tasks + 1;
         end if;
      end loop;

   end normalize;



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
         var(i) := s.chrom_task(i);
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

   
  

   ----------------------------------------------
   -- Transform_Chromosome_To_CheddarADL_Model --
   ----------------------------------------------

   procedure Transform_Chromosome_To_CheddarADL_Model (A_sys : in out System; s : in solution) is

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

               if (s.chrom_task(i) = s.chrom_task(j)) then

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
                     core_name               => Suppress_Space (To_Unbounded_String("")),
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
               if s.chrom_task(k) = s.chrom_task(A_function_index) then
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
            add (rt, Suppress_Space (To_Unbounded_String ("Task" & Integer'Image(s.chrom_task(A_function_index)))), r);

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

   end Transform_Chromosome_To_CheddarADL_Model;
   
 
   -------------------
   -- Create_system --
   -------------------

   Procedure Create_system (A_system     : in out System) is

      a_core : core_unit_ptr;

      a_core_unit_table : Core_Units_Table;
      mem : Memories_Table;
   begin

      Initialize(A_System);

      Add_Address_Space
	(A_System.address_spaces,
	 To_unbounded_string("addr1"),
	 To_unbounded_string("processor1"),
	 0,
	 0,
	 0,
	 0);


      Add_core_unit(My_core_units        => A_System.core_units,
                    A_core_unit          => a_core,
                    Name                 => to_unbounded_string("core1"),
                    Is_Preemptive        => preemptive,
                    Quantum              => 0,
                    speed                => 1,
                    capacity             => 0,
                    period               => 0,
                    Priority             => 0,
                    File_Name            => to_unbounded_string(""),
                    A_Scheduler          => The_scheduler,
                    mem                  => mem);

      Add (a_core_unit_table, a_core);

      Add_Processor(My_Processors => A_System.processors,
                    Name          => to_unbounded_string("processor1"),
                    a_Core        => a_core);

   end Create_system;
   
   

end Chromosome_Data_Manipulation;

