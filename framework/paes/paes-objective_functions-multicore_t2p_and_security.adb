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

with random_tools; use random_tools;
with Ada.Float_Text_IO;

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
with convert_unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
use unbounded_strings.strings_table_package;
with Ada.Strings;              use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;

with architecture_factory; use architecture_factory;

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;

with task_set;            use task_set;
with Tasks;               use Tasks;
with systems;             use systems;
with Processors;          use Processors;
with processor_set;       use processor_set;
with Processor_Interface; use Processor_Interface;

with Core_Units; use Core_Units;
use Core_Units.Core_Units_Table_Package;
with Scheduler_Interface; use Scheduler_Interface;

with Address_Spaces;    use Address_Spaces;
with address_space_set; use address_space_set;

with call_framework;           use call_framework;
with Call_Framework_Interface; use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with call_scheduling_framework; use call_scheduling_framework;

with Parameters;          use Parameters;
with Parameters.extended; use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;

with natural_util; use natural_util;
with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;

with Dependencies;      use Dependencies;
with task_dependencies; use task_dependencies;
with task_dependencies; use task_dependencies.half_dep_set;
with message_set;       use message_set;
with Messages;          use Messages;
with MILS_Security;     use MILS_Security;

with pipe_commands;            use pipe_commands;
with Ada.Text_IO;              use Ada.Text_IO;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with unbounded_strings;        use unbounded_strings;
with convert_unbounded_strings;
with Ada.Directories;          use Ada.Directories;

with debug; use debug;

with integer_util; use integer_util;

with Resources; use Resources;
use Resources.Resource_Accesses;
with float_util;       use float_util;
with Framework_Config; use Framework_Config;
with result_parser;    use result_parser;
with mils_analysis;    use mils_analysis;
with Paes.chromosome_Data_Manipulation_multicore_t2p_and_security;
use Paes.chromosome_Data_Manipulation_multicore_t2p_and_security;

package body Paes.objective_functions.multicore_t2p_and_security is

   -------------------------------------
   -- Check_Feasibility_of_A_Solution --
   -------------------------------------

   function Check_Feasibility_of_A_Solution
     (s    : in out solution_t2p_t2c;
      eidx : in     Natural) return Boolean
   is

      Is_feasible                         : Boolean;
      nb_tasks                            : Integer   := 0;
      i, k                                : Integer;
      Initial_Taskset                     : tasks_set := Initial_System.tasks;
      criticality_i, Sched_Period, laxity : Integer;
      A_system                            : systems.system;
      FileStream                          : stream;
      command                             : Unbounded_String;
      F                                   : Ada.Text_IO.File_Type;
      line                                : Unbounded_String;
      Buffer                              : Unbounded_String;
      T_name                              : Unbounded_String;
      Tasks_Ptr                           : generic_task_ptr;

      My_iterator     : tasks_dependencies_iterator;
      Dep_Ptr         : dependency_ptr;
      My_dependencies : tasks_dependencies_ptr;

      -- A set of variables required to call the framework

      Response_List : framework_response_table;
      response_time : Integer;

      Result        : Unbounded_String;
      num_echeance  : Integer := 0;
      start, finish : Integer;
      str           : Unbounded_String;
      sub_str       : Unbounded_String;
      str1          : Unbounded_String;
      str2          : Unbounded_String;

      Processor_name : Unbounded_String;

      -- To read the Cheddar architecture model

      Project_File_List     : unbounded_string_list;
      Project_File_Dir_List : unbounded_string_list;

      -- The XML file to read
      --
      Input_File      : Boolean := False;
      Input_File_Name : Unbounded_String;

   begin

      Is_feasible    := True;
      Processor_name := To_Unbounded_String ("processor1");
      Sched_Period   := Hyperperiod_of_Initial_Taskset;

      if slaves > 0 then
         if eidx /= 0 then
            Create_system (A_system, s);
            Transform_Chromosome_To_CheddarADL_Model (A_system, s);
         else
            A_system := Initial_System;
         end if;
      else

         Create_system (A_system, s);
         Transform_Chromosome_To_CheddarADL_Model (A_system, s);

      end if;

      nb_tasks :=
        Integer
          (get_number_of_task_from_processor
             (A_system.tasks,
              suppress_space (To_Unbounded_String ("processor1"))));
      -- 1) Check for each task of the candidate solution that Ci <= Di
      -- 2) Check that the total processor Utilization <= 1
      i := 1;

      --3) check if a communication "high" violates a confidentiality rule

      My_dependencies := A_system.dependencies;
      if is_empty (My_dependencies.depends) then
         put_debug ("No dependencies");
         return False;
      else
         reset_iterator (My_dependencies.depends, My_iterator);
         while Is_feasible loop
            current_element (My_dependencies.depends, Dep_Ptr, My_iterator);
            if (Dep_Ptr.type_of_dependency = precedence_dependency) then
               if
                 (Dep_Ptr.precedence_sink.mils_confidentiality_level =
                  unclassified) and
                 ((Dep_Ptr.precedence_source.mils_confidentiality_level =
                   secret) or
                  (Dep_Ptr.precedence_source.mils_confidentiality_level =
                   top_secret))
               then

                  Is_feasible := False;

               end if;
            end if;

            exit when is_last_element (My_dependencies.depends, My_iterator);
            next_element (My_dependencies.depends, My_iterator);
         end loop;

      end if;

      --4) check if a communication "high" violates an integrity rule
      if is_empty (My_dependencies.depends) then
         put_debug ("No dependencies");
         return False;
      else
         reset_iterator (My_dependencies.depends, My_iterator);
         while Is_feasible loop

            current_element (My_dependencies.depends, Dep_Ptr, My_iterator);
            if (Dep_Ptr.type_of_dependency = precedence_dependency) then
               if (Dep_Ptr.precedence_sink.mils_integrity_level = low) and
                 ((Dep_Ptr.precedence_source.mils_integrity_level = medium) or
                  (Dep_Ptr.precedence_source.mils_integrity_level = high))
               then
                  Is_feasible := False;
               end if;
            end if;

            exit when is_last_element (My_dependencies.depends, My_iterator);
            next_element (My_dependencies.depends, My_iterator);
         end loop;
      end if;
      --4) check safety constraints: 3 instances of the same task should not be assigned to the same partition
      for i in 1 .. nb_tasks loop
         if ((0 < i) and (i <= genes / 3)) then
            if (s.chrom_t2p (i) = s.chrom_t2p (Task_instances (1, i))) or
              (s.chrom_t2p (i) = s.chrom_t2p (Task_instances (2, i))) or
              (s.chrom_t2p (Task_instances (1, i)) =
               s.chrom_t2p (Task_instances (2, i)))
            then
               Is_feasible := False;
            end if;
         elsif (genes < i) and (i <= 2 * genes) then
            if
              (s.chrom_t2p (i) =
               s.chrom_t2p (Task_instances (1, i - genes / 3))) or
              (s.chrom_t2p (i) =
               s.chrom_t2p (Task_instances (2, i - genes / 3))) or
              (s.chrom_t2p (Task_instances (1, i - genes / 3)) =
               s.chrom_t2p (Task_instances (2, i - genes / 3)))
            then
               Is_feasible := False;
            end if;
         elsif (2 * genes < i) and (i <= 3 * genes) then
            if
              (s.chrom_t2p (i) =
               s.chrom_t2p (Task_instances (1, i - 2 * genes / 3))) or
              (s.chrom_t2p (i) =
               s.chrom_t2p (Task_instances (2, i - 2 * genes / 3))) or
              (s.chrom_t2p (Task_instances (1, i - 2 * genes / 3)) =
               s.chrom_t2p (Task_instances (2, i - 2 * genes / 3)))
            then
               Is_feasible := False;
            end if;
         end if;
      end loop;

      -- 4) Check the schedulability through scheduling simulation
      Hyperperiod_of_Initial_Taskset := Number_of_partitions (s) * 2000 + 250;
      s.hyperperiod                  := Hyperperiod_of_Initial_Taskset;
      if Is_feasible then
         put_debug
           ("==Check the schedulability through scheduling simulation==");
         write_to_xml_file
           (a_system  => A_system,
            file_name => "candidate_solution" & eidx'img & ".xmlv3");
         put_debug
           ("Hyperperiod_of_Initial_Taskset: " &
            Hyperperiod_of_Initial_Taskset'img);
         command :=
           To_Unbounded_String
             ("./callCheddar_securityAnalysis" &
              Hyperperiod_of_Initial_Taskset'img &
              " candidate_solution\" &
              eidx'img &
              ".xmlv3");

         Put_Line ("end callCheddar_securityAnalysis");
         FileStream := execute (To_String (command), read_file);
         loop
            begin
               Buffer := read_next (FileStream);
            exception
               when pipe_commands.end_of_file =>
                  exit;
            end;
         end loop;

         close (FileStream);
      end if;

      -- 6) check if a task with high criticality missed a deadline

      ---initialize the Cheddar framework

      if Is_feasible then

         Open (F, Ada.Text_IO.In_File, "Output2" & eidx'img & ".txt");
         while (not Ada.Text_IO.End_Of_File (F)) loop
            line := To_Unbounded_String (Get_Line (F));
            Append (str1, "" & line & ASCII.LF);
         end loop;
         Close (F);

         str2 := str1;

         for i in 1 .. nb_tasks loop
            if Is_feasible then
               if (i = 1) then
                  start :=
                    2 +
                    Index
                      (str2,
                       "Task response time computed from simulation :") +
                    Length
                      (To_Unbounded_String
                         ("Task response time computed from simulation : "));
                  finish := Index (str2, " => ");
                  T_name :=
                    suppress_space (Unbounded_Slice (str2, start, finish));

                  str2 :=
                    Unbounded_Slice
                      (str2,
                       2 +
                       Index (str2, "/worst") +
                       Length (To_Unbounded_String ("/worst")),
                       Length (str2));
                  if
                    (To_String
                       (suppress_space (Unbounded_Slice (str2, 2, 10))) =
                     "response")
                  then
                     str2 :=
                       Unbounded_Slice
                         (str2,
                          2 +
                          Index (str2, "capacity") +
                          Length (To_Unbounded_String ("capacity")),
                          Length (str2));
                  else
                     while
                       (suppress_space
                          (To_String (Unbounded_Slice (str2, 2, 9))) =
                        "missed")
                     loop
                        k    := 1;
                        str2 :=
                          Unbounded_Slice
                            (str2,
                             1 + Index (str2, ")"),
                             Length (str2));
                     end loop;
                     if (k = 1) then
                        k    := 0;
                        str2 := Unbounded_Slice (str2, 2, Length (str2));
                     end if;

                  end if;
               else
                  finish := Index (str2, " => ");

                  T_name := suppress_space (Unbounded_Slice (str2, 1, finish));
                  --                                      Put_Line("T_name : " & To_String(T_name));

                  str2 :=
                    Unbounded_Slice
                      (str2,
                       2 +
                       Index (str2, "/worst") +
                       Length (To_Unbounded_String ("/worst")),
                       Length (str2));
                  if
                    (To_String
                       (suppress_space (Unbounded_Slice (str2, 2, 10))) =
                     "response")
                  then
                     str2 :=
                       Unbounded_Slice
                         (str2,
                          2 +
                          Index (str2, "capacity") +
                          Length (To_Unbounded_String ("capacity")),
                          Length (str2));

                  else

                     while
                       (suppress_space
                          (To_String (Unbounded_Slice (str2, 2, 9))) =
                        "missed")
                     loop
                        k    := 1;
                        str2 :=
                          Unbounded_Slice
                            (str2,
                             1 + Index (str2, ")"),
                             Length (str2));
                     end loop;
                     if (k = 1) then
                        k    := 0;
                        str2 := Unbounded_Slice (str2, 2, Length (str2));
                     end if;
                  end if;

               end if;

               New_Line;
               start :=
                 Index (str1, "=> ") + Length (To_Unbounded_String ("=> "));

               finish := Index (str1, "/worst") - 1;

               response_time :=
                 Integer'value
                   (To_String (Unbounded_Slice (str1, start, finish)));

               str1 :=
                 Unbounded_Slice
                   (str1,
                    Index (str1, "/worst") +
                    Length (To_Unbounded_String ("/worst")),
                    Length (str1));

               Tasks_Ptr     := search_task (A_system.tasks, T_name);
               laxity        := Tasks_Ptr.deadline - response_time;
               criticality_i :=
                 get
                   (my_tasks   => A_system.tasks,
                    task_name  => T_name,
                    param_name => criticality);
               if ((laxity < 0) or (response_time = 0)) and
                 (criticality_i /= 0)
               then  -- critical task missed its deadline
                  Is_feasible := False;

               end if;

            end if;
         end loop;

      end if;
      return Is_feasible;

   end Check_Feasibility_of_A_Solution;
   ----------------------

   ------------------
   -- evaluate_multicore_T2P --
   ------------------

   procedure evaluate_multicore_T2P
     (s    : in out generic_solution'class;
      eidx : in     Natural)
   is

      F         : Ada.Text_IO.File_Type;
      line      : Unbounded_String;
      Buffer    : Unbounded_String;
      j         : Integer;
      My_System : systems.system;

   begin
      j := 0;

      -- open the file output_eidx.txt
      -- then read the line corresponding to the selected FitnessFunction
      Open
        (File => F,
         Mode => Ada.Text_IO.In_File,
         Name => "Output" & eidx'img & ".txt");
      for i in 1 .. max_fitness loop
         if (fitnessfunctions (i).is_selected = 1) then
            put_debug
              ("FitnessFunctions: " & To_String (fitnessfunctions (i).name));
            j := j + 1;

            Ada.Text_IO.Set_Line (File => F, To => Ada.Text_IO.Count (j + 1));
            line := To_Unbounded_String (Get_Line (File => F));
            -- We distinguish the fitness to maximize i.e. (f4 and f6)
            -- in order to make all abjectives for minimization
            -- So, we transforme f4 and f6 as follow :
            -- f4 = Hyperperiod_of_Initial_Taskset - f4
            -- f6 = Hyperperiod_of_Initial_Taskset - f6

            if (i = 4) or (i = 6) then
               s.obj (j) :=
                 Float (Hyperperiod_of_Initial_Taskset) -
                 Float'value
                   (To_String
                      (Unbounded_Slice
                         (line,
                          Length (fitnessfunctions (i).name & " = "),
                          Length (line))));
            elsif (i = 13) then
               s.obj (j) :=
                 Float'value
                   (To_String
                      (Unbounded_Slice
                         (line,
                          Length (fitnessfunctions (i).name & " = ") - 1,
                          Length (line)))) -
                 Float (nb_bell_resolved);
            elsif (i = 14) then
               s.obj (j) :=
                 Float'value
                   (To_String
                      (Unbounded_Slice
                         (line,
                          Length (fitnessfunctions (i).name & " = ") - 1,
                          Length (line)))) -
                 Float (nb_biba_resolved);
            elsif (i = 16) then
               s.obj (j) := Float (Number_of_cores (solution_t2p_t2c (s)));
            else
               s.obj (j) :=
                 Float'value
                   (To_String
                      (Unbounded_Slice
                         (line,
                          Length (fitnessfunctions (i).name & " = ") - 1,
                          Length (line))));
            end if;
         end if;

      end loop;

      Close (File => F);
      -- Deleting the file "Output eidx.txt"

      Open
        (File => F,
         Mode => Ada.Text_IO.In_File,
         Name => "Output" & eidx'img & ".txt");
      Ada.Text_IO.Delete (File => F);
      put_debug ("end_evaluation");

   end evaluate_multicore_T2P;

end Paes.objective_functions.multicore_t2p_and_security;
