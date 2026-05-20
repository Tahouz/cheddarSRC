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

with applicability_constraint.all_tasks_are_periodic;
use applicability_constraint.all_tasks_are_periodic;
with applicability_constraint.all_tasks_are_periodic_or_sporadic;
use applicability_constraint.all_tasks_are_periodic_or_sporadic;
with applicability_constraint.no_shared_cpu;
use applicability_constraint.no_shared_cpu;
with applicability_constraint.allowed_protocol;
use applicability_constraint.allowed_protocol;
with applicability_constraint.pip_no_deadlock;
use applicability_constraint.pip_no_deadlock;
with applicability_constraint.no_buffer;
use applicability_constraint.no_buffer;
with applicability_constraint.no_dependencies;
use applicability_constraint.no_dependencies;
with applicability_constraint.ceiling_priority_assignment;
use applicability_constraint.ceiling_priority_assignment;
with applicability_constraint.at_least_one_data;
use applicability_constraint.at_least_one_data;
with applicability_constraint.at_least_one_buffer;
use applicability_constraint.at_least_one_buffer;
with applicability_constraint.no_shared_resources;
use applicability_constraint.no_shared_resources;
with applicability_constraint.data_sharing_protocol;
use applicability_constraint.data_sharing_protocol;
with applicability_constraint.data_connectivity;
use applicability_constraint.data_connectivity;
with applicability_constraint.unsimultaneous_release_time_constraint;
use applicability_constraint.unsimultaneous_release_time_constraint;
with applicability_constraint.simultaneous_release_time_constraint;
use applicability_constraint.simultaneous_release_time_constraint;
with applicability_constraint.period_equal_deadline_constraint;
use applicability_constraint.period_equal_deadline_constraint;
with applicability_constraint.period_smaller_than_deadline_constraint;
use applicability_constraint.period_smaller_than_deadline_constraint;
with applicability_constraint.period_larger_than_deadline_constraint;
use applicability_constraint.period_larger_than_deadline_constraint;
with feasibility_tests_for_time_triggered_communication;
use feasibility_tests_for_time_triggered_communication;
with applicability_constraints_main_structure;
use applicability_constraints_main_structure;
with applicability_constraints_main_structure.extended;
use applicability_constraints_main_structure.extended;
with feasibility_tests_main_structure_factory;
use feasibility_tests_main_structure_factory;
with applicability_constraint.uniprocessor_scheduling_protocol;
use applicability_constraint.uniprocessor_scheduling_protocol;
with applicability_constraint.uniprocessor_quantum;
use applicability_constraint.uniprocessor_quantum;
with applicability_constraint.uniprocessor_preemptivity;
use applicability_constraint.uniprocessor_preemptivity;
with applicability_constraint.uniprocessor;
use applicability_constraint.uniprocessor;
with Generic_Graph;          use Generic_Graph;
with Dependencies;           use Dependencies;
with Ada.IO_Exceptions;      use Ada.IO_Exceptions;
with GNAT.Current_Exception; use GNAT.Current_Exception;
with unbounded_strings;      use unbounded_strings;
with GNAT.Command_Line;      use GNAT.Command_Line;
with GNAT.OS_Lib;            use GNAT.OS_Lib;
with Text_IO;                use Text_IO;
with version;                use version;
with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;
with systems;                use systems;
with task_set;               use task_set;
with task_dependencies;      use task_dependencies;
use task_dependencies.half_dep_set;
with processor_set;     use processor_set;
with address_space_set; use address_space_set;
with resource_set;      use resource_set;
with buffer_set;        use buffer_set;
with call_framework;    use call_framework;
with Tasks;             use Tasks;
use task_set.generic_task_set;
with debug;         use debug;
with Generic_Graph; use Generic_Graph;
use Generic_Graph.Edge_Lists_Package;
use Generic_Graph.Node_Lists_Package;
with DP_Graph;          use DP_Graph;
with DP_Graph.extended; use DP_Graph.extended;
with dp_graph_view;     use dp_graph_view;
use dp_graph_view.graph_list_package;
with architecture_factory; use architecture_factory;
with debug;                use debug;
with Ada.Real_Time;        use Ada.Real_Time;
with translate;            use translate;

package body architecture_analyzer is

   function analyze (sys : system) return Unbounded_String is
      result : Boolean := True;

      acs    : all_cases_structure;
      g      : graph;
      g2     : graph;
      g3     : graph;
      g_list : graph_list;

      --temporary
      g_iterator : graph_list_iterator;
      dp         : design_pattern;
      compliant  : Boolean;

      t_start            : Time;
      t_stop             : Time;
      execution_time     : Time_Span;
      ms                 : Time_Span;
      execution_time_int : Integer;
      file_content       : Unbounded_String;
      return_to_user     : Unbounded_String;
   begin

      --Initialization
      --

      ms             := Milliseconds (1);
      t_start        := Clock;
      return_to_user := empty_string;
      Initialize (g);

      g.cheddar_private_id := To_Unbounded_String ("Testing Graph");

      return_to_user :=
        return_to_user &
        To_Unbounded_String ("System Metrics:    ") &
        unbounded_lf &
        To_Unbounded_String ("Number of resources:") &
        To_Unbounded_String (get_number_of_elements (sys.resources)'img) &
        unbounded_lf &
        To_Unbounded_String ("Number of dependencies:") &
        To_Unbounded_String
          (get_number_of_elements (sys.dependencies.depends)'img) &
        unbounded_lf &
        To_Unbounded_String ("Number of tasks:") &
        To_Unbounded_String (get_number_of_elements (sys.tasks)'img) &
        unbounded_lf &
        To_Unbounded_String ("Number of buffers:") &
        To_Unbounded_String (get_number_of_elements (sys.buffers)'img) &
        unbounded_lf &
        To_Unbounded_String ("Number of processors:") &
        To_Unbounded_String (get_number_of_elements (sys.processors)'img) &
        unbounded_lf &
        unbounded_lf;

      --Step 0: Environment verification
      --
      if not environment_uni_processor_bool (sys) then
         return_to_user :=
           return_to_user &
           "The environment does not meet Uniprocessor Environment Constraint" &
           unbounded_lf &
           "The system will not be analyzed." &
           unbounded_lf &
           unbounded_lf &
           environment_uni_processor_txt (sys);
         return return_to_user;
      end if;

      --Step 1: Building Dependency Graph
      --
      put_debug (return_to_user);
      put_debug ("STEP1");
      g := build_graph_from_system (sys);
      put_debug ("************************Graph");
      put_debug
        (To_Unbounded_String ("Nodes:    ") &
         To_Unbounded_String (get_number_of_elements (g.Nodes)'img));
      put_debug
        (To_Unbounded_String ("Edges:    ") &
         To_Unbounded_String (get_number_of_elements (g.Edges)'img));
      put_debug ("************************Graph");
      -- Step 2 Graph analysis
      --
      put_debug ("STEP2");

      g_list := connexity_view (g);
      put_debug
        (To_Unbounded_String ("GraphListLEnght:    ") &
         To_Unbounded_String (get_number_of_elements (g_list)'img));
      put_debug ("STEP2BIS");
      dp        := compose (g_list);
      compliant := False;

      put_debug ("STEP3");
      -- Step 3 Design Pattern confirmation: Applying Applicability constraints
      --

      case dp is
         when time_triggered_communication =>
            if time_triggered_communication_bool (sys) then
               return_to_user :=
                 return_to_user &
                 ("The system is a Time Triggered Communication Design Pattern instance.") &
                 unbounded_lf;
               compliant := True;
            else
               return_to_user :=
                 return_to_user &
                 time_triggered_communication_txt (sys) &
                 unbounded_lf;
            end if;
         when ravenscar =>
            if ravenscar_bool (sys) then
               return_to_user :=
                 return_to_user &
                 ("The system is a Ravenscar Design Pattern instance.") &
                 unbounded_lf;
               compliant := True;
            else
               return_to_user := return_to_user & ravenscar_txt (sys);
            end if;
         when unplugged =>
            if unplugged_bool (sys) then
               return_to_user :=
                 return_to_user &
                 ("The system is a Unplugged Design Pattern instance.") &
                 unbounded_lf;
               compliant := True;
            else
               return_to_user := return_to_user & unplugged_txt (sys);
            end if;
      end case;

      put_debug ("STEP4");
      -- Step 4 Applicability case of feasibility tests determination
      --
      if (compliant) then
         case dp is
            when time_triggered_communication =>
               put_debug ("Before Building Main structure");
               time_triggered_communication_feasibility_tests_main_structure
                 (acs,
                  sys);
               put_debug ("After Building Main structure");
               evaluate (acs, sys);
               put_debug ("Displaying AC evaluation");
               put (acs);
               t_stop             := Clock;
               execution_time     := t_stop - t_start;
               execution_time_int := execution_time / ms;
               file_content       :=
                 "Time_Triggered_Communication design pattern, selected feasibility tests: " &
                 file_content &
                 unbounded_lf &
                 get_tests_list (acs) &
                 " Compute time:" &
                 execution_time_int'img;

               return_to_user := return_to_user & file_content;

            when ravenscar =>
               ravenscar_feasibility_tests_main_structure (acs, sys);
               evaluate (acs, sys);
               t_stop             := Clock;
               execution_time     := t_stop - t_start;
               execution_time_int := execution_time / ms;
               file_content       :=
                 "Ravenscar design pattern, selected feasibility tests:" &
                 file_content &
                 get_tests_list (acs) &
                 " Compute time:" &
                 execution_time_int'img;
               return_to_user := return_to_user & file_content;

            when unplugged =>

               unplugged_feasibility_tests_main_structure (acs, sys);
               evaluate (acs, sys);
               t_stop             := Clock;
               execution_time     := t_stop - t_start;
               execution_time_int := execution_time / ms;

               file_content :=
                 "Unplugged design pattern, selected feasibility tests:" &
                 file_content &
                 get_tests_list (acs) &
                 " Compute time:" &
                 execution_time_int'img;

               return_to_user := return_to_user & file_content;
         end case;
      end if;

      return return_to_user;

   end analyze;

   function time_triggered_communication_txt
     (sys : system) return Unbounded_String
   is

      result : Unbounded_String :=
        "The system may be a Time_Triggered_Communication design pattern intance," &
        unbounded_lf &
        "but the following constraints are not met." &
        unbounded_lf;
      temp : Boolean := False;

   begin

      -- TT1 periodical tasks only
      temp := r1 (sys);
      if not (temp) then
         result := result & r1_txt & unbounded_lf;
      end if;

      -- TT4 no shared data
      temp := r5 (sys);
      if not (temp) then
         result := result & r5_txt & unbounded_lf;
      end if;

      -- TT2 and TT5 time triggered dependency
      temp := r6 (sys);
      if not (temp) then
         result := result & r6_txt & unbounded_lf;
      end if;

      -- SR remove (already test in the uniprocessor env
      -- temp := r7 (sys);
      -- if not (temp) then
      --    result := result & r7_txt & unbounded_lf;
      -- end if;

      -- TT3 no buffer
      temp := r9_2 (sys);
      if not (temp) then
         result := result & r9_2_txt & unbounded_lf;
      end if;

      return result;

   end time_triggered_communication_txt;

   -- r1: all tasks are periodical
   -- r2: protocols fixedrpriority, EDF, LLF
   -- r3: the preemption policy is defined
   -- r4: the scheduler doesn’t use quantum
   -- r5: no shared data (no associated resource in Cheddar)
   -- r6: time_triggered dependency (sampled or delayed)
   -- r7: no hierarchical schedulers
   -- r8: periodic or sporadic task only
   -- r9_1: at least one shared resource
   -- r9_2: no buffer
   -- r9_3: at least one buffer
   -- r10: shared data  accesses protected by semaphores, and 2 tasks connected
   -- r11: shared data protocols (PIP, ICPP or PCP)
   -- r12: data shared access priority greater than tasks priorities
   -- r13: for PIP, no more than 2 tasks on each shared data
   -- r14: ???
   -- r15: independant tasks

   function time_triggered_communication_bool (sys : system) return Boolean is

      result : Boolean := True;
      temp   : Boolean := False;

   begin
      -- TT1 periodical tasks only
      temp   := r1 (sys);
      result := (result and temp);

      -- TT4 no shared data
      temp   := r5 (sys);
      result := (result and temp);

      -- TT3 no buffer
      temp   := r9_2 (sys);
      result := (result and temp);

      -- TT2 and TT5 time triggered dependency
      temp   := r6 (sys);
      result := (result and temp);

      -- SR remove (already test in the uniprocessor env
      -- temp   := r7 (sys);
      -- result := (result and temp);

      -- SR duplicate ? --> remove
      -- temp   := r9_2 (sys);
      -- result := (result and temp);

      return result;

   end time_triggered_communication_bool;

   function ravenscar_txt (sys : system) return Unbounded_String is

      result : Unbounded_String :=
        "The system may be a Ravenscar design pattern intance," &
        unbounded_lf &
        "but the following constraints are not met." &
        unbounded_lf;
      temp : Boolean := False;

   begin

      -- Rav1 Periodic or sporadic tasks
      temp := r8 (sys);
      if not (temp) then
         result := result & r8_txt & unbounded_lf;
      end if;

      -- Rav2 at least one shared data
      temp := r9_1 (sys);
      if not (temp) then
         result := result & r9_1_txt & unbounded_lf;
      end if;

      -- Rav3 no buffer
      temp := r9_2 (sys);
      if not (temp) then
         result := result & r9_2_txt & unbounded_lf;
      end if;

      -- Rav4 semaphore protected shared data
      temp := r10 (sys);
      if not (temp) then
         result := result & r10_txt & unbounded_lf;
      end if;

      -- Rav5 PIP, ICPP or PCP
      temp := r11 (sys);
      if not (temp) then
         result := result & r11_txt & unbounded_lf;
      end if;

      -- Rav6 data shared access priority greater than tasks priorities
      temp := r12 (sys);
      if not (temp) then
         result := result & r12_txt & unbounded_lf;
      end if;

      -- Rav7: for PIP, no more than 2 tasks on each shared data
      temp := r13 (sys);
      if not (temp) then
         result := result & r13_txt & unbounded_lf;
      end if;
      return result;

   end ravenscar_txt;

   function ravenscar_bool (sys : system) return Boolean is

      result : Boolean := True;
      temp   : Boolean := False;

   begin

      -- Rav1 Periodic or sporadic tasks
      temp   := r8 (sys);
      result := (result and temp);

      -- Rav2 at least one shared data
      temp   := r9_1 (sys);
      result := (result and temp);

      -- Rav3 no buffer
      temp   := r9_2 (sys);
      result := (result and temp);

      -- Rav4 semaphore protected shared data
      temp   := r10 (sys);
      result := (result and temp);

      -- Rav5 PIP, ICPP or PCP
      temp   := r11 (sys);
      result := (result and temp);

      -- Rav6 data shared access priority greater than tasks priorities
      temp   := r12 (sys);
      result := (result and temp);

      -- Rav7: for PIP, no more than 2 tasks on each shared data
      temp   := r13 (sys);
      result := (result and temp);

      return result;

   end ravenscar_bool;

   function unplugged_txt (sys : system) return Unbounded_String is

      result : Unbounded_String :=
        "The system may be a Unplugged design pattern intance," &
        unbounded_lf &
        "but the following constraints are not met." &
        unbounded_lf;
      temp : Boolean := False;

   begin

      -- SR remove (already test in the uniprocessor env
      -- temp := r7 (sys);
      -- if not (temp) then
      --    result := result & r7_txt & unbounded_lf;
      -- end if;

      -- Unp1 periodical tasks only
      temp := r1 (sys);
      if not (temp) then
         result := result & r8_txt & unbounded_lf;
      end if;

      -- Unp2 independant tasks
      temp := r15 (sys);
      if not (temp) then
         result := result & r15_txt & unbounded_lf;
      end if;

      -- Unp3 no shared data (proposal SR)
      temp := r5 (sys);
      if not (temp) then
         result := result & r15_txt & unbounded_lf;
      end if;

      return result;

   end unplugged_txt;

   function unplugged_bool (sys : system) return Boolean is

      result : Boolean := True;
      temp   : Boolean := False;

   begin

      -- SR remove (already test in the uniprocessor env
      -- temp   := r7 (sys);
      -- result := (result and temp);

      -- Unp1 periodical tasks only
      temp   := r1 (sys);
      result := (result and temp);

      -- Unp2 independant tasks
      temp   := r15 (sys);
      result := (result and temp);

      -- Unp3 no shared data (proposal SR)
      temp   := r5 (sys);
      result := (result and temp);

      return result;

   end unplugged_bool;

   function blackboard_bool (sys : system) return Boolean is

      result : Boolean := True;
      temp   : Boolean := False;

   begin
      -- not implemented yet (stephane)

      -- BB1 periodic or sporadic task only
      temp   := r8 (sys);
      result := (result and temp);

      -- BB2 at least one buffer
      temp   := r9_3 (sys);
      result := (result and temp);

      -- temp   := r8 (sys);  -- BB1
      -- result := (result and temp);

      return False;

   end blackboard_bool;

   function blackboard_txt (sys : system) return Unbounded_String is

      result : Unbounded_String :=
        "The system may be a Black Board design pattern intance," &
        unbounded_lf &
        "but the following constraints are not met." &
        unbounded_lf;
      temp : Boolean := False;

   begin

      temp := r8 (sys);
      if not (temp) then
         result := result & r8_txt & unbounded_lf;
      end if;

      temp := r9_3 (sys);
      if not (temp) then
         result := result & r9_3_txt & unbounded_lf;
      end if;
--
--       temp := r15 (sys);
--      if not (temp) then
--         result := result & r15_txt & unbounded_lf;
--      end if;
      null;

      return result;

   end blackboard_txt;

   function queuedbuffer_bool (sys : system) return Boolean is

      result : Boolean := True;
      temp   : Boolean := False;

   begin
      -- not implemented yet (stephane)
      return False;

   end queuedbuffer_bool;

   function environment_uni_processor_txt
     (sys : system) return Unbounded_String
   is

      result : Unbounded_String := empty_string;
      temp   : Boolean          := False;

   begin
      temp := r0 (sys);
      if not (temp) then
         result := result & r0_txt & unbounded_lf;
         return result;
      end if;

      temp := r2 (sys);
      if not (temp) then
         result := result & r2_txt & unbounded_lf;
      end if;

      temp := r3 (sys);
      if not (temp) then
         result := result & r3_txt & unbounded_lf;
      end if;

      temp := r4 (sys);
      if not (temp) then
         result := result & r4_txt & unbounded_lf;
      end if;

      -- SR add constraint Env5 (no hierachical schedulers)
      temp := r7 (sys);
      if not (temp) then
         result := result & r7_txt & unbounded_lf;
      end if;

      return result;

   end environment_uni_processor_txt;

   function environment_uni_processor_bool (sys : system) return Boolean is

      result : Boolean := True;
      temp   : Boolean := False;

   begin

      temp   := r0 (sys);
      result := (result and temp);
      if not result then
         return result;
      end if;

      temp   := r2 (sys);
      result := (result and temp);

      temp   := r3 (sys);
      result := (result and temp);

      --  constraint Env4 (no quantum)
      temp   := r4 (sys);
      result := (result and temp);

      -- SR add constraint Env5 (no hierachical schedulers)
      temp   := r7 (sys);
      result := (result and temp);

      return result;

   end environment_uni_processor_bool;

   procedure write_result_to_file
     (res       : in Unbounded_String;
      file_name : in Unbounded_String)
   is

      into : File_Type;

   begin
      --
      Create (into, Mode => Out_File, Name => To_String (file_name));

      New_Line (into);
      --
      Put_Line (into, To_String (res));

      New_Line (into);

      Close (into);

   end write_result_to_file;

end architecture_analyzer;
