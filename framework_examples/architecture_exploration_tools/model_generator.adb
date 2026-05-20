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
--    $Rev: 3561 $
--    $Date: 2020-11-02 08:25:02 +0100 (Mon, 02 Nov 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

with Ada.Strings;               use Ada.Strings;
with Ada.Strings.Fixed;         use Ada.Strings.Fixed;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with unbounded_strings;         use unbounded_strings;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;

with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with unbounded_strings;        use unbounded_strings;
with Ada.Strings;              use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with Ada.Directories;          use Ada.Directories;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with unbounded_strings;        use unbounded_strings;
with convert_unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
use unbounded_strings.strings_table_package;
with Ada.Strings;              use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;

with Dependencies;      use Dependencies;
with task_dependencies; use task_dependencies;
with task_dependencies; use task_dependencies.half_dep_set;
with message_set;       use message_set;
with Messages;          use Messages;

with Tasks;        use Tasks;
with task_set;     use task_set;
with Resources;    use Resources;
with resource_set; use resource_set;
with Objects;      use Objects;
with convert_unbounded_strings;
use unbounded_strings.unbounded_string_list_package;

with Scheduler_Interface; use Scheduler_Interface;
with Address_Spaces;      use Address_Spaces;
with address_space_set;   use address_space_set;

with call_framework;           use call_framework;
with Call_Framework_Interface; use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with call_scheduling_framework; use call_scheduling_framework;

with pipe_commands; use pipe_commands;
with Ada.Text_IO;   use Ada.Text_IO;

with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with Ada.Directories;          use Ada.Directories;

with GNAT.OS_Lib; use GNAT.OS_Lib;
with debug;       use debug;

with random_tools; use random_tools;

use unbounded_strings.strings_table_package;

with architecture_factory; use architecture_factory;

with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;

with systems;             use systems;
with Processors;          use Processors;
with processor_set;       use processor_set;
with Processor_Interface; use Processor_Interface;
use processor_set.generic_processor_set;

with Core_Units; use Core_Units;
use Core_Units.Core_Units_Table_Package;

with natural_util; use natural_util;
with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;

with integer_util; use integer_util;

use Resources.Resource_Accesses;
with float_util; use float_util;

with Ada.Characters.Latin_1; use Ada.Characters;
with Ada.Text_IO;            use Ada.Text_IO;
with GNAT.String_Split;      use GNAT;
with MILS_Security;          use MILS_Security;

with random_tools; use random_tools;
with Memories;     use Memories;

with Paes.objective_functions.t2p_and_security;
use Paes.objective_functions.t2p_and_security;
with Paes.security_implementation; use Paes.security_implementation;

with Paes.chromosome_Data_Manipulation_t2p_and_security;
use Paes.chromosome_Data_Manipulation_t2p_and_security;
with Paes; use Paes;
package body model_generator is

   procedure generator_model_Uunifast
     (a_solution            : in solution_t2p;
      nb_partitions         : in Integer;
      N_diff_periods        : in Integer;
      Total_cpu_utilization : in Float)
   is
      ---------------------------------------------
      a_system : system;

      actual_cpu_utilization : Float := 0.00;

      Hyperperiod_of_Initial_Taskset : Integer := 4250;

      T_values : integer_array (1 .. genes);
      --     Priority_values          : Integer_Array (1 .. genes):=(5,4,3,2,1,5,4,3,2,1,5,4,3,2,1);
      Priority_values : integer_array (1 .. genes) :=
        (5, 4, 3, 2, 1, 5, 4, 3, 2, 1, 5, 4, 3, 2, 1);

      ---------------------------------------------
      Period12000_values : integer_array (1 .. 13) :=
        (500,
         600,
         750,
         800,
         1000,
         1200,
         1500,
         2000,
         2400,
         3000,
         4000,
         6000,
         12000);
      Period_N_diff_periods : integer_array (1 .. 3) :=
        (0,
         0,
         0); --to 3 different periods shoose randomly in Period12000_values

      G             : Ada.Numerics.Float_Random.Generator;
      j             : Integer;
      A_task_source : generic_task_ptr;
      A_task_sink   : generic_task_ptr;
      found         : Boolean;

      Project_File_Dir_List : unbounded_string_list;

      function found_element_in_array
        (x              : Integer;
         Seq            : integer_array;
         N_diff_periods : Integer) return Boolean
      is
         b : Boolean := False;
         i : Integer := 1;
      begin
         for j in 1 .. N_diff_periods loop
            if (Seq (i) = x) then
               b := True;
            end if;

         end loop;

         return b;
      end found_element_in_array;

      procedure Shuffle_An_Array (To_Shuffle : in out integer_array) is

         use Ada.Numerics.Float_Random;

         N                 : Integer;
         G                 : Ada.Numerics.Float_Random.Generator;
         A_random_position : Integer := 0;
         A_value           : Integer;
      begin

         N := To_Shuffle'length;
         Reset (G);
         while N > 1 loop
            A_random_position := 0;
            while (A_random_position < 1) or (A_random_position > N) loop
               A_random_position := Integer (Random (G) * Float (N));
            end loop;

            N                              := N - 1;
            A_value                        := To_Shuffle (A_random_position);
            To_Shuffle (A_random_position) := To_Shuffle (N);
            To_Shuffle (N)                 := A_value;

         end loop;
      end Shuffle_An_Array;

   begin
      Reset (G); -- Initialise the float generator
      if (N_diff_periods = 0) then
         --cas1
         --         T_values:=(500,1000,1000,500,1000,500,1000,1000,500,1000,500,1000,1000,500,1000);
         T_values :=
           (500,
            1000,
            1000,
            500,
            1000,
            500,
            1000,
            1000,
            500,
            1000,
            500,
            1000,
            1000,
            500,
            1000);
      --  T_values:=(500,1000,1000,2000,2000,500,1000,1000,2000,2000,500,1000,1000,2000,2000);
      -- T_values:=(500,1000,1000,2000,2000,500,1000,1000,2000,2000,500,1000,1000,2000,2000,1000,1000,1000,1000,1000,1000,1000);
      --   cas2_set1
      --   T_values:=(800,4000,4000,600,600,800,4000,4000,600,600,800,4000,4000,600,600);
      --   cas2_set2
      --     T_values:=(1200,750,750,4000,4000,1200,750,750,4000,4000,1200,750,750,4000,4000);
      --   cas2_set3
      -- T_values:=(800,1000,1000,6000,6000,800,1000,1000,6000,6000,800,1000,1000,6000,6000);

      else
         j := 0;
         --  choose randomly N_diff_periods periods in Period12000_values
         for i in 1 .. N_diff_periods loop
            loop
               while (j > 13) or (j < 1) loop
                  j := Integer (Float (13) * Random (G));
               end loop;

               found :=
                 found_element_in_array
                   (Period12000_values (j),
                    Period_N_diff_periods,
                    N_diff_periods);

               exit when not found;
            end loop;

            Period_N_diff_periods (i) := Period12000_values (j);
            Shuffle_An_Array (Period12000_values);

         end loop;

         for i in 1 .. genes loop
            if (i = 1) or (i = 6) or (i = 11) then
               T_values (i) := Period_N_diff_periods (1);
            elsif (i = 2) or (i = 7) or (i = 12) then
               T_values (i) := Period_N_diff_periods (2);
            elsif (i = 3) or (i = 8) or (i = 13) then
               T_values (i) := Period_N_diff_periods (2);
            elsif (i = 4) or (i = 9) or (i = 14) then
               T_values (i) := Period_N_diff_periods (3);
            elsif (i = 5) or (i = 10) or (i = 15) then
               T_values (i) := Period_N_diff_periods (3);
            end if;

         end loop;

      end if;

      --------------------------------------------------------
      ------   generate core, processor, address_space  ------
      --------------------------------------------------------

      Create_system (a_system, a_solution);

      -------------------------
      --generate task set -----
      -------------------------

      create_independant_periodic_taskset_system
        (s                       => a_system,
         current_cpu_utilization => actual_cpu_utilization,
         n_tasks                 => genes,
         target_cpu_utilization  => Total_cpu_utilization,
         t_values                => T_values,
         priority_values         => Priority_values);

      Initial_System := a_system;

      ------------------------------
      ---  Assigne the security levels of tasks and  produce dependency  ---
      ------------------------------
      for i in 1 .. genes loop
         A_task_source :=
           search_task
             (Initial_System.tasks,
              suppress_space (To_Unbounded_String ("Task" & i'img)));
         A_task_source.name :=
           suppress_space (To_Unbounded_String ("" & i'img));
      end loop;

      A_task_source :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("1")));

      A_task_sink :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("2")));

      A_task_source.mils_confidentiality_level := top_secret;
      A_task_source.mils_integrity_level       := medium;

      add_one_task_dependency_precedence
        (my_dependencies => Initial_System.dependencies,
         source          => A_task_source,
         sink            => A_task_sink);

      A_task_source :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("2")));

      A_task_sink :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("3")));
      A_task_source.mils_confidentiality_level := secret;
      A_task_source.mils_integrity_level       := high;
      -- A_task_source.criticality:=3;
      add_one_task_dependency_precedence
        (my_dependencies => Initial_System.dependencies,
         source          => A_task_source,
         sink            => A_task_sink);

      A_task_source :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("3")));
      A_task_sink :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("4")));
      A_task_source.mils_confidentiality_level := top_secret;
      A_task_source.mils_integrity_level       := high;

      add_one_task_dependency_precedence
        (my_dependencies => Initial_System.dependencies,
         source          => A_task_source,
         sink            => A_task_sink);

      A_task_source :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("4")));
      A_task_sink :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("5")));
      A_task_source.mils_confidentiality_level := secret;
      A_task_source.mils_integrity_level       := medium;
      add_one_task_dependency_precedence
        (my_dependencies => Initial_System.dependencies,
         source          => A_task_source,
         sink            => A_task_sink);

      ----------------------------------1\C8RE DUPLICATION-----------------------------------------
      A_task_source :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("6")));
      A_task_sink :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("7")));
      --        A_task_source.mils_confidentiality_level:= Top_Secret;
      --        A_task_source.mils_integrity_level:= Medium;
      add_one_task_dependency_precedence
        (my_dependencies => Initial_System.dependencies,
         source          => A_task_source,
         sink            => A_task_sink);

      A_task_source :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("7")));
      A_task_sink :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("8")));
      --        A_task_source.mils_confidentiality_level:= Secret;
      --        A_task_source.mils_integrity_level:= High;
      -- A_task_source.criticality:=3;
      add_one_task_dependency_precedence
        (my_dependencies => Initial_System.dependencies,
         source          => A_task_source,
         sink            => A_task_sink);

      A_task_source :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("8")));
      A_task_sink :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("9")));
      --        A_task_source.mils_confidentiality_level:= Top_Secret;
      --        A_task_source.mils_integrity_level:= High;

      add_one_task_dependency_precedence
        (my_dependencies => Initial_System.dependencies,
         source          => A_task_source,
         sink            => A_task_sink);

      A_task_source :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("9")));
      A_task_sink :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("10")));
      --        A_task_source.mils_confidentiality_level:= Secret;
      --        A_task_source.mils_integrity_level:= Medium;
      add_one_task_dependency_precedence
        (my_dependencies => Initial_System.dependencies,
         source          => A_task_source,
         sink            => A_task_sink);
      ------------------------------2\C8ME DUPLICATION-----------------------------------------
      A_task_source :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("11")));
      A_task_sink :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("12")));
      A_task_source.mils_confidentiality_level := top_secret;
      A_task_source.mils_integrity_level       := medium;
      add_one_task_dependency_precedence
        (my_dependencies => Initial_System.dependencies,
         source          => A_task_source,
         sink            => A_task_sink);

      A_task_source :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("12")));
      A_task_sink :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("13")));
      A_task_source.mils_confidentiality_level := secret;
      A_task_source.mils_integrity_level       := high;
      --   A_task_source.criticality:=3;
      add_one_task_dependency_precedence
        (my_dependencies => Initial_System.dependencies,
         source          => A_task_source,
         sink            => A_task_sink);

      A_task_source :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("13")));
      A_task_sink :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("14")));
      A_task_source.mils_confidentiality_level := top_secret;
      A_task_source.mils_integrity_level       := high;

      add_one_task_dependency_precedence
        (my_dependencies => Initial_System.dependencies,
         source          => A_task_source,
         sink            => A_task_sink);

      A_task_source :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("14")));
      A_task_sink :=
        search_task
          (Initial_System.tasks,
           suppress_space (To_Unbounded_String ("15")));
      A_task_source.mils_confidentiality_level := secret;
      A_task_source.mils_integrity_level       := medium;
      add_one_task_dependency_precedence
        (my_dependencies => Initial_System.dependencies,
         source          => A_task_source,
         sink            => A_task_sink);

      -------------------------------------------------------------------------------------------

      put_debug ("Writing test_Unifast.xmlv3");
      write_to_xml_file
        (a_system  => Initial_System,
         file_name =>
           suppress_space (To_Unbounded_String ("test_Unifast.xmlv3")));
      put_debug ("Finish write test_Unifast.xmlv3");

   end generator_model_Uunifast;

   ------------------
   -- duplication --
   ------------------

   procedure Task_duplicate is
      Sys             : system;
      My_iterator     : tasks_dependencies_iterator;
      Dep_Ptr         : dependency_ptr;
      My_dependencies : tasks_dependencies_ptr;
      y               : Natural := genes + 1;
      A_task_source   : generic_task_ptr;
      A_task_sink     : generic_task_ptr;
      addr            : Unbounded_String;
   begin
      Sys             := Initial_System;
      My_dependencies := Sys.dependencies;
      reset_iterator (My_dependencies.depends, My_iterator);
      loop
         current_element (My_dependencies.depends, Dep_Ptr, My_iterator);
         if
           (Dep_Ptr.precedence_source.address_space_name =
            To_Unbounded_String ("addr1"))
         then
            addr := To_Unbounded_String ("addr2");
         else
            addr := To_Unbounded_String ("addr1");
         end if;

         add_task
           (my_tasks           => Sys.tasks,
            name => suppress_space (To_Unbounded_String ("" & y'img)),
            cpu_name => suppress_space ((To_Unbounded_String ("processor1"))),
            address_space_name => suppress_space (addr),
            core_name          => To_Unbounded_String (""),
            task_type          => periodic_type,
            start_time         => 0,
            capacity           => Dep_Ptr.precedence_source.capacity,
            period             => Dep_Ptr.precedence_source.deadline,
            deadline           => Dep_Ptr.precedence_source.deadline,
            jitter             => 0,
            blocking_time      => 0,
            priority => Integer'value (Dep_Ptr.precedence_source.priority'img),
            criticality        => 0,
            policy             => sched_fifo,
            mils_task          => Dep_Ptr.precedence_source.mils_task);
         A_task_source :=
           search_task
             (Initial_System.tasks,
              suppress_space (To_Unbounded_String (Integer'image (y))));
         y := y + 1;
         if
           (Dep_Ptr.precedence_sink.address_space_name =
            To_Unbounded_String ("addr1"))
         then
            addr := To_Unbounded_String ("addr2");
         else
            addr := To_Unbounded_String ("addr1");
         end if;

         add_task
           (my_tasks           => Sys.tasks,
            name => suppress_space (To_Unbounded_String ("" & y'img)),
            cpu_name => suppress_space ((To_Unbounded_String ("processor1"))),
            address_space_name => suppress_space (addr),
            core_name          => To_Unbounded_String (""),
            task_type          => periodic_type,
            start_time         => 0,
            capacity           => Dep_Ptr.precedence_sink.capacity,
            period             => Dep_Ptr.precedence_sink.deadline,
            deadline           => Dep_Ptr.precedence_sink.deadline,
            jitter             => 0,
            blocking_time      => 0,
            priority => Integer'value (Dep_Ptr.precedence_sink.priority'img),
            criticality        => 0,
            policy             => sched_fifo,
            mils_task          => Dep_Ptr.precedence_sink.mils_task);

         A_task_sink :=
           search_task
             (Initial_System.tasks,
              suppress_space (To_Unbounded_String (Integer'image (y))));
         add_one_task_dependency_precedence
           (my_dependencies => Sys.dependencies,
            source          => A_task_source,
            sink            => A_task_sink);

      end loop;

   end Task_duplicate;

end model_generator;
