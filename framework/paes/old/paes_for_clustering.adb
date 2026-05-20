
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

with Ada.text_IO; use Ada.text_IO;
with Ada.Integer_text_IO; use Ada.Integer_text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions;

with Ada.Strings;               use Ada.Strings;
with Ada.Strings.Fixed;         use Ada.Strings.Fixed;
with Ada.Numerics.Float_Random ; use Ada.Numerics.Float_Random ;
with unbounded_strings;        use unbounded_strings;

with Tasks; use Tasks;
with Task_Set; use Task_Set;
with Resources; use Resources;
with Resource_Set; use Resource_Set;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Unbounded_Strings; use Unbounded_Strings;
with convert_unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
with feasibility_test.feasibility_interval; use feasibility_test.feasibility_interval;

with Core_Units; use Core_Units;
use Core_Units.Core_Units_Table_Package;
--with Processors.extended; use Processors.extended;
with Scheduler_Interface; use Scheduler_Interface;
with Address_Spaces;      use Address_Spaces;
with Address_Space_Set;   use Address_Space_Set;
with Processors;          use Processors;
with Processor_Set;       use Processor_Set;
with processor_interface; use processor_interface;

with Call_Framework;                    use Call_Framework;
with Call_Framework_Interface;          use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with Call_Scheduling_Framework;         use Call_Scheduling_Framework;

with Pipe_Commands; use Pipe_Commands;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Directories; use Ada.Directories;

with GNAT.OS_Lib;                       use GNAT.OS_Lib;
with Debug; use Debug;

package body Paes_For_Clustering is


  -------------------------
  -- init_for_clustering --
  -------------------------

  procedure init_for_clustering
  is
   
  begin

    -- initialise the current solution c with values from 1 to genes
    -- as we suppose each function is assigned to a task.
    --
    for i in 1..genes loop
       c.chrom(i) := i;
    end loop;

    -- Initialize the Cheddar framework
    --
    Call_Framework.initialize (False);
  
    Create_system (Initial_System);

    -- Initialize the list of all possible fitness functions
    --
    for i in 1 .. MAX_FITNESS loop
	FitnessFunctions(i).Is_selected := 0; 
    end loop;

    FitnessFunctions(1).Name := To_Unbounded_String("f1 = preemptions");	 -- To Min
    FitnessFunctions(2).Name := To_Unbounded_String("f2 = contextSwitches"); 	 -- To Min
    FitnessFunctions(3).Name := To_Unbounded_String("f3 = tasks");		 -- To Min
    FitnessFunctions(4).Name := To_Unbounded_String("f4 = sum(Li) = sum(Di-Ri)");-- To Max --
    FitnessFunctions(5).Name := To_Unbounded_String("f5 = sum(Ri/Di)"); 	 -- To Min
    FitnessFunctions(6).Name := To_Unbounded_String("f6 = min(Li)"); 		 -- To Max --
    FitnessFunctions(7).Name := To_Unbounded_String("f7 = sum(Ri)"); 		 -- To Min
    FitnessFunctions(8).Name := To_Unbounded_String("f8 = max(Ri)");		 -- To Min
    FitnessFunctions(9).Name := To_Unbounded_String("f9 = sum(Bi)"); 		 -- To Min
    FitnessFunctions(10).Name := To_Unbounded_String("f10 = max(Bi)");		 -- To Min
    FitnessFunctions(11).Name := To_Unbounded_String("f11 = sharedResources");	 -- To Min
    
    -- Initialise the float generator
    --reset(G); 
  end init_for_clustering;

  -----------------------------
  -- evaluate_for_clustering --
  -----------------------------

  procedure evaluate_for_clustering (s : in out solution; eidx : in Natural) is

      F          : Ada.Text_IO.File_Type;
      line       : unbounded_String;
      Buffer     : unbounded_String;
      j          : integer;
  begin
      j := 0;
      for i in 1 .. MAX_FITNESS loop
	   if 	FitnessFunctions(i).Is_selected = 1 then
                j := j + 1;
		-- open the file output_eidx.txt 
		-- then read the line corresponding to the selected FitnessFunction
                Open (File => F,
            	      Mode => Ada.Text_IO.In_File,
                      Name => "Output" & eidx'img & ".txt");
		
 		Ada.Text_IO.Set_Line (File => F, To   => Ada.Text_IO.Count(i+1));
                line := To_unbounded_string(Get_Line (File => F));
                -- We distinguish the fitness to maximize i.e. (f4 and f6)
                -- in order to make all abjectives for minimization 
                -- So, we transforme f4 and f6 as follow :
                -- f4 = Hyperperiod_of_Initial_Taskset - f4
                -- f6 = Hyperperiod_of_Initial_Taskset - f6
		If (i = 4) or (i = 6) then
                 s.obj(j) := float(Hyperperiod_of_Initial_Taskset) - 
                                       Float'Value(To_String(Unbounded_Slice(line, 
                                   					     length(FitnessFunctions(i).Name & " = "),
                                            	  		             length(line))));
                else
                 s.obj(j) := Float'Value(To_String(Unbounded_Slice(line, 
                                   			           length(FitnessFunctions(i).Name & " = "),
                                            	  		   length(line))));
                end if;

                close(File => F);
             
	   end if;

      end loop;

      --Deleting the file "Output eidx.txt"
      --
      Open (File => F,
            Mode => Ada.Text_IO.In_File,
            Name => "Output" & eidx'img & ".txt");
      Ada.text_IO.Delete(File => F);


  end evaluate_for_clustering;


  ---------------------------
  -- Mutate_for_clustering --
  ---------------------------

  procedure mutate_for_clustering (s : in out solution; eidx : in Natural) is

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

     FileStream : stream;
     command    : unbounded_String;
     F          : Ada.Text_IO.File_Type;
     line       : unbounded_String;
     Buffer     : unbounded_String;
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
	   
          Appling_clustering_rules (A_system, A_sol);
          
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
                 Put_Debug(" ");

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


              if (random_task /= A_sol.chrom(fn)) then  -- if the function "fn" is not intially in
                                                        -- the task "random_task" the "fn" is moved
                                                        -- to the task "random_task"
                  A_sol.chrom(fn) := random_task;
                  sol_is_mutated := true;

              elsif (not is_isolated (fn, A_sol)) then
                  -- if coincidentally the function "fn" is intially in the task "random_task" 
                  -- then if the function "fn" is not initially isolated, we create a new task
                  -- in which we isolate it
                  -- else i.e the function "fn" is alone then we repeat the procedure with another function
                  -- chosen randomly 
                  A_sol.chrom(fn) := nb_tasks + 1;
                  sol_is_mutated := true;            
              end if;

          end if;
      
          if sol_is_mutated then

             Put_Debug(" ");-
             Put_Debug ("The mutated solution is : ");
             print_debug_genome(A_sol);
             Put_Debug(" ");
             -- normalize the mutate solution
             normalize(A_sol);
             Put_Debug(" ");
             Put_Debug ("After normalization the candidate solution is : ");
             print_debug_genome(A_sol);
             Put_Debug(" ");

             ----------------------------------------------------------------------------------------
             -- After generating a mutate solution, we shoud verify :
             -- 1) If the new solution is consistent or not i.e two non-harmonic functions
             --    which are grouped alone in the same task.
             -- 2) If it was a consistent solution then we should verify its schedulability
             --    by calling the Cheddar tool to simulate the scheduling of the candidate task set
             --    Else, we must regenerate a new candidate solution 
             -----------------------------------------------------------------------------------------

             If Check_Consistency_Of_A_Solution (A_sol) then
                Put_Debug (" The candidate solution is consistent and then we check the schedulability");
                -- check the schedulability
                Appling_clustering_rules (A_System, A_sol);
                
                New_nb_tasks := Number_of_tasks (A_sol); 
                
		-- Laurent //
		command := To_Unbounded_String("candidate_solution" & eidx'Img & ".xmlv3");
                
                Write_To_Xml_File(A_System  => A_System,
                                  File_Name => To_String(command));

		command  := To_Unbounded_String("~/call_cheddar "
                             & Hyperperiod_of_Initial_Taskset'img
                             & " candidate_solution\" & eidx'Img & ".xmlv3");
                FileStream := execute(To_string(command), read_file);

             	loop
                    begin
                       Buffer := read_next(FileStream);
                    exception
                       when Pipe_Commands.End_of_file => 
                         exit;
                    end;
                end loop;
             
                close(FileStream);

                Open(F, Ada.Text_IO.In_File,"Output" & eidx'Img & ".txt");
                line := To_Unbounded_String(get_line(F));

                if line = "schedulability : true" then

                	Put_Debug("**The candidate task set is schedulable**");
                    	sol_is_mutated := true;
                    	s := A_sol;

                else
                        Put_Debug("**The candidate task set is NOT schedulable**");
                        sol_is_mutated := false;
                        counter := counter + 1;
                end if; 
             
                Close(F);     
                                    
             else  
                Put_Debug (" The candidate solution is NOt consistent and then " &
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

  end mutate_for_clustering;
  
  -----------------
  -- is_isolated --
  -----------------


  function is_isolated(t : integer; s : solution) return boolean
  is
     result : boolean := true;
     i      : integer :=  1;
  begin
     while (result and i <= genes) loop
       if (s.chrom(i) = s.chrom(t)) and then (t /= i) then 
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
             if (s.chrom(j) = s.chrom(i)) and then (var(j) = 0) then
                var(j) := 1;
                --  if s.chrom(i) is not normalized then all s.chrom(j) (which egal s.all.chrom(i))
                --  are not normalized 
                if (s.chrom(i) /= nb_tasks) then
                    s.chrom(j) := nb_tasks;
                end if;
             end if;
          end loop;

          -- we normalize s.chrom(i)
          if (s.chrom(i) /= nb_tasks) then
             s.chrom(i) := nb_tasks;
          end if;
          var(i) := 1;
          nb_tasks := nb_tasks + 1; 
        end if;
     end loop;        

  end normalize;


end Paes_For_Clustering;
