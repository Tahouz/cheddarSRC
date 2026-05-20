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
with Paes.chromosome_Data_Manipulation_t2p_and_security;
use Paes.chromosome_Data_Manipulation_t2p_and_security;

package body Paes.security_implementation is

   -------------------
   -- security configuration 1 (function calls - function calls) --
   -- only when intra partititions communications are consider attackable
   -------------------
   procedure security_configuration1
     (A_sys : in out systems.system;
      s     : in     solution_t2p)
   is

      encrypt_addr, decrypt_addr                            : Unbounded_String;
      capacity_encrypter, capacity_decrypter, capacity_hash : Natural;
      y, j, m, finish                                       : Integer;

      A_task_name : Unbounded_String;

      A_task_source : generic_task_ptr;
      A_task_sink   : generic_task_ptr;
   begin

      j := 1;

      y :=
        Integer
          (get_number_of_task_from_processor
             (A_sys.tasks,
              To_Unbounded_String ("processor1")));
      while (j <= genes_com) loop
         finish        := Index (s.chrom_com (j).source_sink, "_");
         A_task_source :=
           search_task
             (A_sys.tasks,
              suppress_space
                (Unbounded_Slice
                   (s.chrom_com (j).source_sink,
                    1,
                    finish - 1)));
         A_task_sink :=
           search_task
             (A_sys.tasks,
              suppress_space
                (Unbounded_Slice
                   (s.chrom_com (j).source_sink,
                    finish + 1,
                    Length (s.chrom_com (j).source_sink))));
         m                  := Integer'value (To_String (A_task_source.name));
         capacity_encrypter := encrypter_values (task_to_app (m));
         capacity_decrypter :=
           decrypter_values
             (task_to_app
                (m));   -- assumption capacity_encrypter=capacity_decrypter
         capacity_hash := Hash_values (task_to_app (m));
         -- add dependencies between tasks
         add_one_task_dependency_precedence
           (my_dependencies => A_sys.dependencies,
            source          => A_task_source,
            sink            => A_task_sink);
         if (s.chrom_com (j).mode = secure) then
            if
              (A_task_sink.mils_confidentiality_level <
               A_task_source.mils_confidentiality_level)
            then
               y := y + 1;
               put_debug
                 ("Downgrader (Encrypter & Decrypter): " &
                  y'img &
                  " is added");
               A_task_source.capacity :=
                 A_task_source.capacity + capacity_encrypter + Key_value;
               A_task_sink.capacity :=
                 A_task_sink.capacity + capacity_decrypter + Key_value;
               nb_bell_resolved := nb_bell_resolved + 1;
            end if;
            if
              (A_task_source.mils_integrity_level <
               A_task_sink.mils_integrity_level)
            then
               y := y + 1;
               put_debug ("Upgrader : " & y'img & " is added");
               A_task_source.capacity :=
                 A_task_source.capacity + capacity_hash;
               A_task_sink.capacity := A_task_sink.capacity + capacity_hash;
               nb_biba_resolved     := nb_biba_resolved + 1;

            end if;

         end if;
         j := j + 1;
      end loop;
   end security_configuration1;

   ---test1
   ---
   -------------------
   -- security configuration 2 (Rien - function calls) --
   -------------------
   procedure security_configuration2
     (A_sys : in out systems.system;
      s     : in     solution_t2p)
   is

      encrypt_addr, decrypt_addr                            : Unbounded_String;
      capacity_encrypter, capacity_decrypter, capacity_hash : Natural;
      y, j, m, finish                                       : Integer;

      A_task_name : Unbounded_String;

      A_task_source : generic_task_ptr;
      A_task_sink   : generic_task_ptr;
   begin

      j := 1;

      y :=
        Integer
          (get_number_of_task_from_processor
             (A_sys.tasks,
              To_Unbounded_String ("processor1")));
      while (j <= genes_com) loop
         finish        := Index (s.chrom_com (j).source_sink, "_");
         A_task_source :=
           search_task
             (A_sys.tasks,
              suppress_space
                (Unbounded_Slice
                   (s.chrom_com (j).source_sink,
                    1,
                    finish - 1)));
         A_task_sink :=
           search_task
             (A_sys.tasks,
              suppress_space
                (Unbounded_Slice
                   (s.chrom_com (j).source_sink,
                    finish + 1,
                    Length (s.chrom_com (j).source_sink))));
         m                  := Integer'value (To_String (A_task_source.name));
         capacity_encrypter := encrypter_values (task_to_app (m));
         capacity_decrypter := decrypter_values (task_to_app (m));
         capacity_hash      := Hash_values (task_to_app (m));
         -- add dependencies between tasks
         add_one_task_dependency_precedence
           (my_dependencies => A_sys.dependencies,
            source          => A_task_source,
            sink            => A_task_sink);

         if (s.chrom_com (j).mode = secure) then
            if
              (A_task_sink.mils_confidentiality_level <
               A_task_source.mils_confidentiality_level)
            then
               if
                 (A_task_source.address_space_name /=
                  A_task_sink.address_space_name)
               then

                  y := y + 1;
                  put_debug
                    ("Downgrader (Encrypter & Decrypter): " &
                     y'img &
                     " is added");
                  A_task_source.capacity :=
                    A_task_source.capacity + capacity_encrypter + Key_value;
                  A_task_sink.capacity :=
                    A_task_sink.capacity + capacity_decrypter + Key_value;
               end if;
               nb_bell_resolved := nb_bell_resolved + 1;
            end if;

            if
              (A_task_source.mils_integrity_level <
               A_task_sink.mils_integrity_level)
            then
               if
                 (A_task_source.address_space_name /=
                  A_task_sink.address_space_name)
               then
                  y := y + 1;
                  put_debug ("Upgrader : " & y'img & " is added");
                  A_task_source.capacity :=
                    A_task_source.capacity + capacity_hash;
                  A_task_sink.capacity := A_task_sink.capacity + capacity_hash;
               end if;
               nb_biba_resolved := nb_biba_resolved + 1;
            end if;
         elsif (s.chrom_com (j).mode = nosecure) then
            if
              (A_task_sink.mils_confidentiality_level <
               A_task_source.mils_confidentiality_level)
            then
               if
                 (A_task_source.address_space_name =
                  A_task_sink.address_space_name)
               then
                  nb_bell_resolved := nb_bell_resolved + 1;
               end if;

            end if;
            if
              (A_task_source.mils_integrity_level <
               A_task_sink.mils_integrity_level)
            then
               if
                 (A_task_source.address_space_name =
                  A_task_sink.address_space_name)
               then
                  nb_biba_resolved := nb_biba_resolved + 1;
               end if;
            end if;
         end if;
         j := j + 1;
      end loop;
   end security_configuration2;

   -------------------
   -- security configuration 3 (rien-task without M) --
   -------------------
   procedure security_configuration3
     (A_sys : in out systems.system;
      s     : in     solution_t2p)
   is

      encrypt_addr, decrypt_addr                            : Unbounded_String;
      capacity_encrypter, capacity_decrypter, capacity_hash : Natural;
      y, j, m, finish                                       : Integer;
      dep_bell_solved                                       : Boolean;
      A_task_name                                           : Unbounded_String;

      A_task_source,
      A_task_Key_source,
      A_task_DW,
      A_task_DW_decypt                 : generic_task_ptr;
      A_task_sink, A_task_Key_sink     : generic_task_ptr;
      A_task_UP_source, A_task_UP_sink : generic_task_ptr;
   begin
      j := 1;
      y :=
        Integer
          (get_number_of_task_from_processor
             (A_sys.tasks,
              To_Unbounded_String ("processor1")));
      while (j <= genes_com) loop
         finish        := Index (s.chrom_com (j).source_sink, "_");
         A_task_source :=
           search_task
             (A_sys.tasks,
              suppress_space
                (Unbounded_Slice
                   (s.chrom_com (j).source_sink,
                    1,
                    finish - 1)));
         A_task_sink :=
           search_task
             (A_sys.tasks,
              suppress_space
                (Unbounded_Slice
                   (s.chrom_com (j).source_sink,
                    finish + 1,
                    Length (s.chrom_com (j).source_sink))));

         m                  := Integer'value (To_String (A_task_source.name));
         capacity_encrypter := encrypter_values (task_to_app (m));
         capacity_decrypter := decrypter_values (task_to_app (m));
         capacity_hash      := Hash_values (task_to_app (m));

         if (s.chrom_com (j).mode = secure) then
            dep_bell_solved := False;
            if
              (A_task_sink.mils_confidentiality_level <
               A_task_source.mils_confidentiality_level)
            then
               if
                 (A_task_source.address_space_name /=
                  A_task_sink.address_space_name)
               then
                  -- consider the inter partition communication (adding tasks whitout multiplexing)
                  Put_Line ("A_task_source : " & A_task_source.name);
                  Put_Line ("A_task_sink : " & A_task_sink.name);
                  y := y + 1;
                  put_debug ("Downgrader (Encrypter): " & y'img & " is added");
                  add_task
                    (my_tasks => A_sys.tasks,
                     name => suppress_space (To_Unbounded_String ("" & y'img)),
                     cpu_name =>
                       suppress_space (To_Unbounded_String ("processor1")),
                     address_space_name => A_task_source.address_space_name,
                     core_name => suppress_space (To_Unbounded_String ("")),
                     task_type          => periodic_type,
                     start_time         => 0,
                     capacity           => capacity_encrypter,
                     period             => A_task_sink.deadline,
                     deadline           => A_task_sink.deadline,
                     jitter             => 0,
                     blocking_time      => 0,
                     priority => Integer'value (A_task_source.priority'img),
                     criticality        => 0,
                     policy             => sched_fifo,
                     mils_task          => downgrader);

                  A_task_DW :=
                    search_task
                      (A_sys.tasks,
                       suppress_space (To_Unbounded_String ("" & y'img)));
                  add_one_task_dependency_precedence
                    (my_dependencies => A_sys.dependencies,
                     source          => A_task_source,
                     sink            => A_task_DW);

                  y := y + 1;
                  put_debug
                    ("New downgrading task (Decrypter): " &
                     y'img &
                     " is added");
                  add_task
                    (my_tasks => A_sys.tasks,
                     name => suppress_space (To_Unbounded_String ("" & y'img)),
                     cpu_name =>
                       suppress_space (To_Unbounded_String ("processor1")),
                     address_space_name => A_task_sink.address_space_name,
                     core_name => suppress_space (To_Unbounded_String ("")),
                     task_type          => periodic_type,
                     start_time         => 0,
                     capacity           => capacity_decrypter,
                     period             => A_task_sink.deadline,
                     deadline           => A_task_sink.deadline,
                     jitter             => 0,
                     blocking_time      => 0,
                     priority => Integer'value (A_task_source.priority'img),
                     criticality        => 0,
                     policy             => sched_fifo,
                     mils_task          => downgrader);
                  A_task_DW_decypt :=
                    search_task
                      (A_sys.tasks,
                       suppress_space (To_Unbounded_String ("" & y'img)));
                  add_one_task_dependency_precedence
                    (my_dependencies => A_sys.dependencies,
                     source          => A_task_DW,
                     sink            => A_task_DW_decypt);
                  add_one_task_dependency_precedence
                    (my_dependencies => A_sys.dependencies,
                     source          => A_task_DW_decypt,
                     sink            => A_task_sink);

                  y := y + 1;
                  put_debug
                    ("New key set up task for encrypter: " &
                     y'img &
                     " is added");
                  add_task
                    (my_tasks => A_sys.tasks,
                     name => suppress_space (To_Unbounded_String ("" & y'img)),
                     cpu_name =>
                       suppress_space (To_Unbounded_String ("processor1")),
                     address_space_name => A_task_source.address_space_name,
                     core_name => suppress_space (To_Unbounded_String ("")),
                     task_type          => periodic_type,
                     start_time         => 0,
                     capacity           => Key_value,
                     period             => 100000000,
                     deadline           => 100000000,
                     jitter             => 0,
                     blocking_time      => 0,
                     priority           =>
                       Integer'value (A_task_source.priority'img) + 1,
                     criticality => 0,
                     policy      => sched_fifo,
                     mils_task   => downgrader);
                  A_task_Key_source :=
                    search_task
                      (A_sys.tasks,
                       suppress_space (To_Unbounded_String ("" & y'img)));
                  add_one_task_dependency_precedence
                    (my_dependencies => A_sys.dependencies,
                     source          => A_task_Key_source,
                     sink            => A_task_source);
                  y := y + 1;
                  put_debug
                    ("New key set up task for decrypter: " &
                     y'img &
                     " is added");
                  add_task
                    (my_tasks => A_sys.tasks,
                     name => suppress_space (To_Unbounded_String ("" & y'img)),
                     cpu_name =>
                       suppress_space (To_Unbounded_String ("processor1")),
                     address_space_name => A_task_sink.address_space_name,
                     core_name => suppress_space (To_Unbounded_String ("")),
                     task_type          => periodic_type,
                     start_time         => 0,
                     capacity           => Key_value,
                     period             => 100000000,
                     deadline           => 100000000,
                     jitter             => 0,
                     blocking_time      => 0,
                     priority => Integer'value (A_task_sink.priority'img) + 1,
                     criticality        => 0,
                     policy             => sched_fifo,
                     mils_task          => downgrader);
                  A_task_Key_sink :=
                    search_task
                      (A_sys.tasks,
                       suppress_space (To_Unbounded_String ("" & y'img)));
                  add_one_task_dependency_precedence
                    (my_dependencies => A_sys.dependencies,
                     source          => A_task_Key_sink,
                     sink            => A_task_sink);
               else
                  -- when there is no attackable intra communication
                  nb_bell_resolved := nb_bell_resolved + 1;
                  -- add dependencies between tasks
                  add_one_task_dependency_precedence
                    (my_dependencies => A_sys.dependencies,
                     source          => A_task_source,
                     sink            => A_task_sink);
               end if;
               dep_bell_solved := True;
            end if;
            --
            if
              (A_task_source.mils_integrity_level <
               A_task_sink.mils_integrity_level)
            then
               if (dep_bell_solved = False) then
                  -- when solving the problem of integrity, we keep the communication
                  -- but if there was no confidentiality problem solved, then there is already a link between the 2 tasks via DW
                  -- and also the case where there is no intra non-attackable communication
                  add_one_task_dependency_precedence
                    (my_dependencies => A_sys.dependencies,
                     source          => A_task_source,
                     sink            => A_task_sink);
                  nb_biba_resolved := nb_biba_resolved + 1;
               end if;

               if
                 (A_task_source.address_space_name /=
                  A_task_sink.address_space_name)
               then
                  Put_Line ("A_task_source : " & A_task_source.name);
                  Put_Line ("A_task_sink : " & A_task_sink.name);
                  y := y + 1;
                  put_debug ("Hash at emission : " & y'img & " is added");
                  add_task
                    (my_tasks => A_sys.tasks,
                     name => suppress_space (To_Unbounded_String ("" & y'img)),
                     cpu_name =>
                       suppress_space (To_Unbounded_String ("processor1")),
                     address_space_name => A_task_source.address_space_name,
                     core_name => suppress_space (To_Unbounded_String ("")),
                     task_type          => periodic_type,
                     start_time         => 0,
                     capacity           => capacity_hash,
                     period             => A_task_sink.deadline,
                     deadline           => A_task_sink.deadline,
                     jitter             => 0,
                     blocking_time      => 0,
                     priority => Integer'value (A_task_source.priority'img),
                     criticality        => 0,
                     policy             => sched_fifo,
                     mils_task          => downgrader);

                  A_task_UP_source :=
                    search_task
                      (A_sys.tasks,
                       suppress_space (To_Unbounded_String ("" & y'img)));
                  add_one_task_dependency_precedence
                    (my_dependencies => A_sys.dependencies,
                     source          => A_task_source,
                     sink            => A_task_UP_source);
                  add_one_task_dependency_precedence
                    (my_dependencies => A_sys.dependencies,
                     source          => A_task_UP_source,
                     sink            => A_task_source);
                  y := y + 1;
                  put_debug ("Hash at reception : " & y'img & " is added");
                  add_task
                    (my_tasks => A_sys.tasks,
                     name => suppress_space (To_Unbounded_String ("" & y'img)),
                     cpu_name =>
                       suppress_space (To_Unbounded_String ("processor1")),
                     address_space_name => A_task_sink.address_space_name,
                     core_name => suppress_space (To_Unbounded_String ("")),
                     task_type          => periodic_type,
                     start_time         => 0,
                     capacity           => capacity_hash,
                     period             => A_task_sink.deadline,
                     deadline           => A_task_sink.deadline,
                     jitter             => 0,
                     blocking_time      => 0,
                     priority => Integer'value (A_task_source.priority'img),
                     criticality        => 0,
                     policy             => sched_fifo,
                     mils_task          => downgrader);

                  A_task_UP_sink :=
                    search_task
                      (A_sys.tasks,
                       suppress_space (To_Unbounded_String ("" & y'img)));
                  add_one_task_dependency_precedence
                    (my_dependencies => A_sys.dependencies,
                     source          => A_task_sink,
                     sink            => A_task_UP_sink);
                  add_one_task_dependency_precedence
                    (my_dependencies => A_sys.dependencies,
                     source          => A_task_UP_sink,
                     sink            => A_task_sink);
               elsif
                 (A_task_source.address_space_name =
                  A_task_sink.address_space_name) and
                 (dep_bell_solved = True)
               then
                  nb_biba_resolved := nb_biba_resolved + 1;
               end if;

            end if;

         elsif (s.chrom_com (j).mode = nosecure) then
            -- add dependencies between tasks
            add_one_task_dependency_precedence
              (my_dependencies => A_sys.dependencies,
               source          => A_task_source,
               sink            => A_task_sink);

            if
              (A_task_sink.mils_confidentiality_level <
               A_task_source.mils_confidentiality_level)
            then
               if
                 (A_task_source.address_space_name =
                  A_task_sink.address_space_name)
               then
                  nb_bell_resolved := nb_bell_resolved + 1;
               end if;

            end if;
            if
              (A_task_source.mils_integrity_level <
               A_task_sink.mils_integrity_level)
            then
               if
                 (A_task_source.address_space_name =
                  A_task_sink.address_space_name)
               then
                  nb_biba_resolved := nb_biba_resolved + 1;
               end if;
            end if;
         else
            -- add dependencies between tasks
            add_one_task_dependency_precedence
              (my_dependencies => A_sys.dependencies,
               source          => A_task_source,
               sink            => A_task_sink);
         end if;
         j := j + 1;
      end loop;
   end security_configuration3;

   -------------------
   -- security configuration 4 (Rien - tasks with M) --
   -------------------
   procedure security_configuration4
     (A_sys : in out systems.system;
      s     : in     solution_t2p)
   is

      encrypt_addr, decrypt_addr                            : Unbounded_String;
      capacity_encrypter, capacity_decrypter, capacity_hash : Natural;
      y, j, i, m, k, finish                                 : Integer;
      dep_bell_solved                                       : Boolean;
      A_task_name                                           : Unbounded_String;

      A_task_source, A_task_DW_enc, A_task_DW_dec : generic_task_ptr;
      A_task_sink                                 : generic_task_ptr;
      A_task_UP                                   : generic_task_ptr;
      type security_partition is
        array (1 .. nb_partitions) of multiplexe_security_partition;
      multiplexe_security : security_partition;

   begin
      y :=
        Integer
          (get_number_of_task_from_processor
             (A_sys.tasks,
              To_Unbounded_String ("processor1")));
      for j in 1 .. nb_partitions loop
         multiplexe_security (j).addr :=
           suppress_space (To_Unbounded_String ("addr" & j'img));
         multiplexe_security (j).confidentiality_capacity_enc := 0;
         multiplexe_security (j).confidentiality_capacity_dec := 0;
         multiplexe_security (j).integrity_capacity           := 0;
      end loop;
      j := 1;
      while (j <= genes_com) loop
         finish        := Index (s.chrom_com (j).source_sink, "_");
         A_task_source :=
           search_task
             (A_sys.tasks,
              suppress_space
                (Unbounded_Slice
                   (s.chrom_com (j).source_sink,
                    1,
                    finish - 1)));
         A_task_sink :=
           search_task
             (A_sys.tasks,
              suppress_space
                (Unbounded_Slice
                   (s.chrom_com (j).source_sink,
                    finish + 1,
                    Length (s.chrom_com (j).source_sink))));

         m                  := Integer'value (To_String (A_task_source.name));
         capacity_encrypter := encrypter_values (task_to_app (m));
         capacity_decrypter := decrypter_values (task_to_app (m));
         capacity_hash      := Hash_values (task_to_app (m));

         if (s.chrom_com (j).mode = secure) then
            dep_bell_solved := False;
            --
            if
              (A_task_sink.mils_confidentiality_level <
               A_task_source.mils_confidentiality_level)
            then
               if
                 (A_task_source.address_space_name /=
                  A_task_sink.address_space_name)
               then
                  -- consider the inter partition communication
                  finish := Index (A_task_source.address_space_name, "r");
                  i      :=
                    Integer'value
                      (To_String
                         (suppress_space
                            (Unbounded_Slice
                               (A_task_source.address_space_name,
                                finish + 1,
                                Length (A_task_source.address_space_name)))));
                  k :=
                    Integer'value
                      (To_String
                         (suppress_space
                            (Unbounded_Slice
                               (A_task_sink.address_space_name,
                                finish + 1,
                                Length (A_task_source.address_space_name)))));
                  if
                    (multiplexe_security (i).confidentiality_capacity_enc = 0)
                  then
                     y := y + 1;
                     multiplexe_security (i).tsk_confidentiality_enc      := y;
                     multiplexe_security (i).confidentiality_capacity_enc :=
                       capacity_encrypter + Key_value;
                     add_task
                       (my_tasks => A_sys.tasks,
                        name     =>
                          suppress_space (To_Unbounded_String ("" & y'img)),
                        cpu_name =>
                          suppress_space (To_Unbounded_String ("processor1")),
                        address_space_name => A_task_source.address_space_name,
                        core_name => suppress_space (To_Unbounded_String ("")),
                        task_type          => periodic_type,
                        start_time         => 0,
                        capacity           =>
                          multiplexe_security (i).confidentiality_capacity_enc,
                        period        => A_task_sink.deadline,
                        deadline      => A_task_sink.deadline,
                        jitter        => 0,
                        blocking_time => 0,
                        priority => Integer'value (A_task_source.priority'img),
                        criticality   => 0,
                        policy        => sched_fifo,
                        mils_task     => downgrader);
                     A_task_DW_enc :=
                       search_task
                         (A_sys.tasks,
                          suppress_space (To_Unbounded_String ("" & y'img)));
                     add_one_task_dependency_precedence
                       (my_dependencies => A_sys.dependencies,
                        source          => A_task_source,
                        sink            => A_task_DW_enc);

                  else
                     multiplexe_security (i).confidentiality_capacity_enc :=
                       multiplexe_security (i).confidentiality_capacity_enc +
                       capacity_encrypter +
                       Key_value;
                     A_task_DW_enc :=
                       search_task
                         (A_sys.tasks,
                          suppress_space
                            (To_Unbounded_String
                               ("" &
                                multiplexe_security (i)
                                  .tsk_confidentiality_enc'
                                  img)));
                     A_task_DW_enc.capacity :=
                       multiplexe_security (i).confidentiality_capacity_enc;
                     add_one_task_dependency_precedence
                       (my_dependencies => A_sys.dependencies,
                        source          => A_task_source,
                        sink            => A_task_DW_enc);
                  end if;
                  if
                    (multiplexe_security (k).confidentiality_capacity_dec = 0)
                  then
                     y := y + 1;
                     multiplexe_security (k).tsk_confidentiality_dec      := y;
                     multiplexe_security (k).confidentiality_capacity_dec :=
                       capacity_decrypter + Key_value;
                     add_task
                       (my_tasks => A_sys.tasks,
                        name     =>
                          suppress_space (To_Unbounded_String ("" & y'img)),
                        cpu_name =>
                          suppress_space (To_Unbounded_String ("processor1")),
                        address_space_name => A_task_sink.address_space_name,
                        core_name => suppress_space (To_Unbounded_String ("")),
                        task_type          => periodic_type,
                        start_time         => 0,
                        capacity           =>
                          multiplexe_security (k).confidentiality_capacity_dec,
                        period        => A_task_sink.deadline,
                        deadline      => A_task_sink.deadline,
                        jitter        => 0,
                        blocking_time => 0,
                        priority => Integer'value (A_task_source.priority'img),
                        criticality   => 0,
                        policy        => sched_fifo,
                        mils_task     => downgrader);
                     A_task_DW_dec :=
                       search_task
                         (A_sys.tasks,
                          suppress_space (To_Unbounded_String ("" & y'img)));
                     add_one_task_dependency_precedence
                       (my_dependencies => A_sys.dependencies,
                        source          => A_task_DW_enc,
                        sink            => A_task_DW_dec);

                     add_one_task_dependency_precedence
                       (my_dependencies => A_sys.dependencies,
                        source          => A_task_DW_dec,
                        sink            => A_task_sink);
                  else
                     multiplexe_security (k).confidentiality_capacity_dec :=
                       multiplexe_security (k).confidentiality_capacity_dec +
                       capacity_decrypter +
                       Key_value;
                     A_task_DW_dec :=
                       search_task
                         (A_sys.tasks,
                          suppress_space
                            (To_Unbounded_String
                               ("" &
                                multiplexe_security (k)
                                  .tsk_confidentiality_dec'
                                  img)));
                     A_task_DW_dec.capacity :=
                       multiplexe_security (k).confidentiality_capacity_dec;
                     add_one_task_dependency_precedence
                       (my_dependencies => A_sys.dependencies,
                        source          => A_task_DW_enc,
                        sink            => A_task_DW_dec);

                     add_one_task_dependency_precedence
                       (my_dependencies => A_sys.dependencies,
                        source          => A_task_DW_dec,
                        sink            => A_task_sink);

                  end if;

               else
                  -- non attackable intra communications
                  nb_bell_resolved := nb_bell_resolved + 1;
                  -- add dependencies
                  add_one_task_dependency_precedence
                    (my_dependencies => A_sys.dependencies,
                     source          => A_task_source,
                     sink            => A_task_sink);
               end if;
               dep_bell_solved := True;
            end if;
            --
            if
              (A_task_source.mils_integrity_level <
               A_task_sink.mils_integrity_level)
            then
               if (dep_bell_solved = False) then
                  -- when solving the problem of integrity, we keep the communication
                  -- but if there was no confidentiality problem solved, then there is already a link between the 2 tasks via DW
                  -- and also intra communications not attackable
                  add_one_task_dependency_precedence
                    (my_dependencies => A_sys.dependencies,
                     source          => A_task_source,
                     sink            => A_task_sink);
                  nb_biba_resolved := nb_biba_resolved + 1;
               end if;
               if
                 (A_task_source.address_space_name /=
                  A_task_sink.address_space_name)
               then
                  finish := Index (A_task_source.address_space_name, "r");
                  i      :=
                    Integer'value
                      (To_String
                         (suppress_space
                            (Unbounded_Slice
                               (A_task_source.address_space_name,
                                finish + 1,
                                Length (A_task_source.address_space_name)))));
                  k :=
                    Integer'value
                      (To_String
                         (suppress_space
                            (Unbounded_Slice
                               (A_task_sink.address_space_name,
                                finish + 1,
                                Length (A_task_source.address_space_name)))));
                  if (multiplexe_security (i).integrity_capacity = 0) then
                     y                                          := y + 1;
                     multiplexe_security (i).tsk_integrity      := y;
                     multiplexe_security (i).integrity_capacity :=
                       capacity_hash;
                     put_debug
                       ("Hash is added for partition" &
                        To_String (multiplexe_security (i).addr));
                     add_task
                       (my_tasks => A_sys.tasks,
                        name     =>
                          suppress_space (To_Unbounded_String ("" & y'img)),
                        cpu_name =>
                          suppress_space (To_Unbounded_String ("processor1")),
                        address_space_name => A_task_source.address_space_name,
                        core_name => suppress_space (To_Unbounded_String ("")),
                        task_type          => periodic_type,
                        start_time         => 0,
                        capacity => multiplexe_security (i).integrity_capacity,
                        period             => A_task_sink.deadline,
                        deadline           => A_task_sink.deadline,
                        jitter             => 0,
                        blocking_time      => 0,
                        priority => Integer'value (A_task_source.priority'img),
                        criticality        => 0,
                        policy             => sched_fifo,
                        mils_task          => downgrader);
                     A_task_UP :=
                       search_task
                         (A_sys.tasks,
                          suppress_space (To_Unbounded_String ("" & y'img)));
                     add_one_task_dependency_precedence
                       (my_dependencies => A_sys.dependencies,
                        source          => A_task_source,
                        sink            => A_task_UP);
                     add_one_task_dependency_precedence
                       (my_dependencies => A_sys.dependencies,
                        source          => A_task_UP,
                        sink            => A_task_source);
                  else
                     multiplexe_security (i).integrity_capacity :=
                       multiplexe_security (i).integrity_capacity +
                       capacity_hash;
                     A_task_UP :=
                       search_task
                         (A_sys.tasks,
                          suppress_space
                            (To_Unbounded_String
                               ("" &
                                multiplexe_security (i).tsk_integrity'img)));
                     A_task_UP.capacity :=
                       multiplexe_security (i).integrity_capacity;
                     add_one_task_dependency_precedence
                       (my_dependencies => A_sys.dependencies,
                        source          => A_task_source,
                        sink            => A_task_UP);
                     add_one_task_dependency_precedence
                       (my_dependencies => A_sys.dependencies,
                        source          => A_task_UP,
                        sink            => A_task_source);

                  end if;
                  if (multiplexe_security (k).integrity_capacity = 0) then
                     y                                          := y + 1;
                     multiplexe_security (k).tsk_integrity      := y;
                     multiplexe_security (k).integrity_capacity :=
                       capacity_hash;
                     put_debug
                       ("Hash is added for partition" &
                        To_String (multiplexe_security (k).addr));
                     add_task
                       (my_tasks => A_sys.tasks,
                        name     =>
                          suppress_space (To_Unbounded_String ("" & y'img)),
                        cpu_name =>
                          suppress_space (To_Unbounded_String ("processor1")),
                        address_space_name => A_task_sink.address_space_name,
                        core_name => suppress_space (To_Unbounded_String ("")),
                        task_type          => periodic_type,
                        start_time         => 0,
                        capacity => multiplexe_security (i).integrity_capacity,
                        period             => A_task_sink.deadline,
                        deadline           => A_task_sink.deadline,
                        jitter             => 0,
                        blocking_time      => 0,
                        priority => Integer'value (A_task_source.priority'img),
                        criticality        => 0,
                        policy             => sched_fifo,
                        mils_task          => downgrader);
                     A_task_UP :=
                       search_task
                         (A_sys.tasks,
                          suppress_space (To_Unbounded_String ("" & y'img)));

                     add_one_task_dependency_precedence
                       (my_dependencies => A_sys.dependencies,
                        source          => A_task_sink,
                        sink            => A_task_UP);
                     add_one_task_dependency_precedence
                       (my_dependencies => A_sys.dependencies,
                        source          => A_task_UP,
                        sink            => A_task_sink);
                  else
                     multiplexe_security (k).integrity_capacity :=
                       multiplexe_security (k).integrity_capacity +
                       capacity_hash;
                     A_task_UP :=
                       search_task
                         (A_sys.tasks,
                          suppress_space
                            (To_Unbounded_String
                               ("" &
                                multiplexe_security (k).tsk_integrity'img)));
                     A_task_UP.capacity :=
                       multiplexe_security (k).integrity_capacity;
                     add_one_task_dependency_precedence
                       (my_dependencies => A_sys.dependencies,
                        source          => A_task_sink,
                        sink            => A_task_UP);
                     add_one_task_dependency_precedence
                       (my_dependencies => A_sys.dependencies,
                        source          => A_task_UP,
                        sink            => A_task_sink);
                  end if;
               elsif
                 (A_task_source.address_space_name =
                  A_task_sink.address_space_name) and
                 (dep_bell_solved = True)
               then
                  nb_biba_resolved := nb_biba_resolved + 1;
               end if;
            end if;

         elsif (s.chrom_com (j).mode = nosecure) then
            -- add dependencies between tasks
            add_one_task_dependency_precedence
              (my_dependencies => A_sys.dependencies,
               source          => A_task_source,
               sink            => A_task_sink);

            if
              (A_task_sink.mils_confidentiality_level <
               A_task_source.mils_confidentiality_level)
            then
               if
                 (A_task_source.address_space_name =
                  A_task_sink.address_space_name)
               then
                  nb_bell_resolved := nb_bell_resolved + 1;
               end if;

            end if;
            if
              (A_task_source.mils_integrity_level <
               A_task_sink.mils_integrity_level)
            then
               if
                 (A_task_source.address_space_name =
                  A_task_sink.address_space_name)
               then
                  nb_biba_resolved := nb_biba_resolved + 1;
               end if;
            end if;

         else
            -- add dependencies between tasks
            add_one_task_dependency_precedence
              (my_dependencies => A_sys.dependencies,
               source          => A_task_source,
               sink            => A_task_sink);
         end if;
         j := j + 1;
      end loop;
   end security_configuration4;

end Paes.security_implementation;
