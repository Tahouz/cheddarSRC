
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Cheddar is a GNU GPL real-time scheduling analysis tool.
-- This program provides services to automatically check schedulability and
-- other performance criteria of real-time architecture models.
--
-- Copyright (C) 2002-2016, Frank Singhoff, Alain Plantec, Jerome Legrand
--
-- The Cheddar project was started in 2002 by 
-- Frank Singhoff, Lab-STICC UMR 6285 laboratory, Université de Bretagne Occidentale
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
--    $Rev: 3549 $
--    $Date: 2020-10-22 18:23:27 +0200 (Thu, 22 Oct 2020) $
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


with Address_Spaces;      use Address_Spaces;
with Address_Space_Set;   use Address_Space_Set;

with Call_Framework;                    use Call_Framework;
with Call_Framework_Interface;          use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with Call_Scheduling_Framework;         use Call_Scheduling_Framework;

with Parameters;                        use Parameters;
with Parameters.extended;               use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;

with natural_util; 		use natural_util;
with feasibility_test.feasibility_interval; use feasibility_test.feasibility_interval;

with Dependencies; 		use Dependencies; 
with Task_Dependencies; 	use Task_Dependencies; 
with Task_Dependencies; 	use Task_Dependencies.Half_Dep_Set;
with Message_Set ; 		use Message_Set; 
with Messages; 			use Messages; 
with MILS_Security;		use MILS_Security;


with Pipe_Commands; use Pipe_Commands;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with unbounded_strings; use unbounded_strings;
with convert_unbounded_strings;
with Ada.Directories; use Ada.Directories;

with Debug; use Debug;

with integer_util; use integer_util;

with Resources; use Resources;
use Resources.Resource_Accesses;
with float_util; use float_util;
with Framework_Config; use Framework_Config;
with result_parser; use result_parser;
with mils_analysis; use mils_analysis;


package body paes.objective_functions.deadline2energy is

   -------------------------------------
   -- Check_Feasibility_of_A_Solution --
   -------------------------------------

   function Check_Feasibility_of_A_Solution (s : in out solution_deadline2energy; eidx : in Natural) return boolean is

      Is_feasible                      : boolean;
      nb_tasks                         : Integer:=0;
      i, k                                : Integer;
      Initial_Taskset                  : Tasks_Set := Initial_system.Tasks;
      criticality_i, Sched_Period, laxity  : integer;
      A_system                         : systems.System;
      FileStream                       : stream;
      command                          : unbounded_String;
      F                                : Ada.Text_IO.File_Type;
      line                             : unbounded_String;
      Buffer                           : unbounded_String;
      T_name                : unbounded_string;
      Tasks_Ptr             : Generic_Task_Ptr; 
   
      
      My_iterator: Tasks_Dependencies_Iterator;
      Dep_Ptr: Dependency_Ptr;
      My_dependencies: Tasks_Dependencies_Ptr;
      
      -- A set of variables required to call the framework
   
      Response_List   		 : Framework_Response_Table;
      response_time         : integer;
      
      Result:   Unbounded_String;
      num_echeance	    : integer:=0;
      start,finish          : integer;
      str            : unbounded_string;
      sub_str               : unbounded_string;
      str1	            : unbounded_string;
      str2                  : unbounded_string;

      Processor_name         : unbounded_string;
      
      -- To read the Cheddar architecture model

      Project_File_List     : unbounded_string_list;
      Project_File_Dir_List : unbounded_string_list;
      
      -- The XML file to read
      --
      Input_File      : Boolean := False;
      Input_File_Name : Unbounded_String;
      
      
      
   begin
       
      Is_feasible := true;
      Processor_name := To_Unbounded_String("processor1");
      Sched_Period:= Hyperperiod_of_Initial_Taskset;

      if slaves > 0 then 
         if eidx /= 0 then
            Create_system (A_System, s);
            Transform_Chromosome_To_CheddarADL_Model (A_System, s);
         else
            A_System := Initial_system;
         end if;
      else
         
         Create_system (A_System,s);
         Transform_Chromosome_To_CheddarADL_Model (A_System, s);
      
      end if;
 
      
      nb_tasks := Integer (Get_Number_Of_Task_From_Processor
                           (A_system.Tasks, Suppress_Space(To_unbounded_string("processor1")))
                          );
      -- 1)  Check the schedulability through scheduling simulation
      Hyperperiod_of_Initial_Taskset:= Number_of_partitions(s)*2000+125;
      s.hyperperiod:=Hyperperiod_of_Initial_Taskset;
      if Is_feasible then
         Put_Debug("==Check the schedulability through scheduling simulation==");
         Write_To_Xml_File(A_System  => A_System,
                           File_Name => "candidate_solution" & eidx'Img & ".xmlv3");
         Put_Debug("Hyperperiod_of_Initial_Taskset: "&Hyperperiod_of_Initial_Taskset'img);

         command  := To_Unbounded_String
           ("./callCheddar_securityAnalysis"
            & Hyperperiod_of_Initial_Taskset'img
            & " candidate_solution\" & eidx'Img & ".xmlv3");

         
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
           

      end if;

 
      -- 6) check if a task with high criticality missed a deadline
         
      ---initialize the Cheddar framework
   
      if Is_feasible then
        
         Open(F, Ada.Text_IO.In_File,"Output2" & eidx'Img & ".txt");
         while (not Ada.Text_IO.End_of_File(F))  loop
            line :=  To_Unbounded_String(get_line(F));
       
            Append (str1,""& line & ASCII.LF);
         end loop;
     

         Close(F);
      
      
         str2:= str1;
         
         for i in 1 ..nb_tasks loop
            if Is_feasible then
               if (i=1) Then
                  start :=2+ index (str2, "Task response time computed from simulation :") + length(To_Unbounded_String("Task response time computed from simulation : "));
                  finish := index (str2, " => ");
                  T_name := Suppress_Space(Unbounded_Slice(str2,start,finish));
              
                  str2 := Unbounded_Slice(str2,
                                          2+ index (str2, "/worst")+length(To_Unbounded_String("/worst")),
                                          length(str2));
                  if (To_String(Suppress_Space(Unbounded_Slice(str2,2,10)))="response") Then
                     str2 := Unbounded_Slice(str2,2+index (str2, "capacity")+length(To_Unbounded_String("capacity")),length(str2));
                  else                
                     While (Suppress_Space(To_String(Unbounded_Slice(str2,2,9)))="missed") loop
                        k:=1;
                        str2 :=  Unbounded_Slice(str2,1+index (str2, ")"),length(str2));
                     end loop;
                     if(k=1) Then
                        k:=0;
                        str2 :=  Unbounded_Slice(str2,2,length(str2));
                     end if; 

                  end if; 
               else
                  finish := index (str2, " => ");

                  T_name := Suppress_Space(Unbounded_Slice(str2,1,finish));
                  --                                      Put_Line("T_name : " & To_String(T_name));
            
                  str2 := Unbounded_Slice(str2,2+index (str2, "/worst")+length(To_Unbounded_String("/worst")),length(str2));
                  if (To_String(Suppress_Space(Unbounded_Slice(str2,2,10)))="response") Then
                     str2 := Unbounded_Slice(str2,2+index (str2, "capacity")+length(To_Unbounded_String("capacity")),length(str2));
                     
                  else 
               
                     While (Suppress_Space(To_String(Unbounded_Slice(str2,2,9)))="missed") loop
                        k:=1;
                        str2 :=  Unbounded_Slice(str2,1+index (str2, ")"),length(str2));
                     end loop;
                     if(k=1) Then
                        k:=0;
                        str2 :=  Unbounded_Slice(str2,2,length(str2));
                     end if; 
                  end if;
                 
               end if;

               New_Line;
               start := index (str1, "=> ") + length(To_Unbounded_String("=> "));

               finish := index (str1, "/worst") - 1;

               response_time := integer'Value (to_string(Unbounded_Slice(str1,start,finish)));

               str1 := Unbounded_Slice(str1,
                                       index (str1, "/worst") + length(To_Unbounded_String("/worst")),
                                       length(str1));
         
               Tasks_Ptr:=Search_Task (A_system.Tasks, T_name);
               laxity:=Tasks_Ptr.deadline-response_time;
               criticality_i := Get(My_Tasks   => A_system.Tasks,
                                    Task_Name  => T_name,
                                    Param_Name => criticality);
               if ((laxity<0)OR (response_time =0)) AND (criticality_i/=0) Then  -- critical task missed its deadline
                  Is_feasible:= False;
      
               end if;	

            end if; 
         end loop;
 
      end if;
      return Is_feasible;

   end Check_Feasibility_of_A_Solution;
   ----------------------          
         
   ------------------
   -- evaluate_T2P --
   ------------------

   procedure evaluate_deadline2energy (s : in out generic_solution'Class; eidx : in Natural) is

      F                              : Ada.Text_IO.File_Type;
      line                           : unbounded_String;
      Buffer                         : unbounded_String;
      j                             : integer;
      My_System                      : systems.System;

   begin
      j := 0;
      -- open the file output_eidx.txt
      -- then read the line corresponding to the selected FitnessFunction
      Open (File => F,
            Mode => Ada.Text_IO.In_File,
            Name => "Output" & eidx'img & ".txt");
      for i in 1 .. MAX_FITNESS loop
         if FitnessFunctions(i).Is_selected = 1 then
            Put_Debug("FitnessFunctions: "& To_String(FitnessFunctions(i).Name));
            j := j + 1;
            
            Ada.Text_IO.Set_Line (File => F, To   => Ada.Text_IO.Count(j+1));
            line := To_unbounded_string(Get_Line (File => F));
            -- We distinguish the fitness to maximize i.e. (f4 and f6)
            -- in order to make all abjectives for minimization
            -- So, we transforme f4 and f6 as follow :
            -- f4 = Hyperperiod_of_Initial_Taskset - f4
            -- f6 = Hyperperiod_of_Initial_Taskset - f6
            -- Put_Line("line: "& To_String(line));
            If (i = 4) or (i = 6) then
               s.obj(i) := float(Hyperperiod_of_Initial_Taskset) -
                 Float'Value(To_String(Unbounded_Slice(line,
                             length(FitnessFunctions(i).Name & " = "),
                             length(line))));
            elsif(i = 13) then
               s.obj(i) := Float'Value(To_String(Unbounded_Slice(line,
                                       length(FitnessFunctions(i).Name & " = ")-1,
                                       length(line))))- Float(nb_bell_resolved);
            elsif(i = 14) then
               s.obj(i) := Float'Value(To_String(Unbounded_Slice(line,
                                       length(FitnessFunctions(i).Name & " = ")-1,
                                       length(line))))- Float(nb_biba_resolved);
            else
               s.obj(i) := Float'Value(To_String(Unbounded_Slice(line,
                                       length(FitnessFunctions(i).Name & " = ")-1,
                                       length(line))));
            end if;
    

         end if;
        

      end loop;
                   
      close(File => F);
      -- Deleting the file "Output eidx.txt"

      Open (File => F,
            Mode => Ada.Text_IO.In_File,
            Name => "Output" & eidx'img & ".txt");
      Ada.text_IO.Delete(File => F);
      Put_Debug("end_evaluation");
       
   end evaluate_deadline2energy;
   
   

end paes.objective_functions.deadline2energy;
