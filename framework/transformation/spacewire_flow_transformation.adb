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

with Ada.Integer_Text_IO;   use Ada.Integer_Text_IO;
with Text_IO;               use Text_IO;
with Ada.Exceptions;        use Ada.Exceptions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with translate;             use translate;
with Text_IO;               use Text_IO;
with unbounded_strings;     use unbounded_strings;
with Dependencies;          use Dependencies;
with task_dependencies;     use task_dependencies;
use task_dependencies.half_dep_set;
with Tasks;       use Tasks;
with task_set;    use task_set;
with message_set; use message_set;
with Messages;    use Messages;
with systems;     use systems;
with version;     use version;
with Parameters;  use Parameters;
use Parameters.User_Defined_Parameters_Table_Package;
with Parameters.extended;  use Parameters.extended;
with mesh_analysis;        use mesh_analysis;
with mesh_analysis.delays; use mesh_analysis.delays;
with Memories;             use Memories;
use Memories.Memories_Table_Package;
with Processors;    use Processors;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with debug; use debug;

package body spacewire_flow_transformation is

   procedure compute_spacewire_transformation
     (sys       : in     system;
      a_network : in     spacewire_network_ptr;
      result    :    out system)
   is

      destination_tasks              : tasks_set;
      source_tasks                   : tasks_set;
      a_link_mat                     : links_mat;
      sourcetask_position_table      : tab_position;
      destinationtask_position_table : tab_position;
      sourcetask_rank_table          : processor_ranks;
      destinationtask_rank_table     : processor_ranks;

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;
      found        : Boolean := False;

   begin

      -- Check that the model to analyze contains at least
      -- message depenencies
      --
      if not is_empty (sys.dependencies.depends) then
         reset_iterator (sys.dependencies.depends, my_iterator1);

         loop
            current_element
              (sys.dependencies.depends,
               a_half_dep,
               my_iterator1);
            if
              (a_half_dep.type_of_dependency =
               asynchronous_communication_dependency)
            then
               found := True;
            end if;

            exit when is_last_element (sys.dependencies.depends, my_iterator1);
            next_element (sys.dependencies.depends, my_iterator1);
         end loop;
      end if;

      if not found then
         raise dependency_not_found;
      end if;

      -----------------------------------------------
      -- Compute the flow Model and used links
      -----------------------------------------------
      -----------------------------------------------
      -- generate two tables : Destination_tasks and Source_tasks from sys.
      -- task Source_task(i) send a message to task Destination_task.
      -----------------------------------------------

      compute_source_destination_task
        (my_tasks          => sys.tasks,
         my_messages       => sys.messages,
         my_dep            => sys.dependencies,
         destination_tasks => destination_tasks,
         source_tasks      => source_tasks);

      -----------------------------------------------
      -- generate two tables : Destination_tasks_position_table and Source_tasks_position_table.
      -- task Source_task(i) will be executed on SourceTask_position_Table(i).
      -- task Destination_task(i) will be executed on Destination_Task_position_Table(i).
      -----------------------------------------------

      compute_spw_source_destination_task_position
        (sourcetask_position_table      => sourcetask_position_table,
         destinationtask_position_table => destinationtask_position_table,
         sourcetask_rank_table          => sourcetask_rank_table,
         destinationtask_rank_table     => destinationtask_rank_table,
         source_tasks                   => source_tasks,
         destination_tasks              => destination_tasks,
         my_messages                    => sys.messages,
         a_network                      => a_network);

      -------------------------------------
      --- generate used links for each
      --- message : the function F of the flow model
      -------------------------------------

      generate_links_spw
        (a_link_mat                     => a_link_mat,
         my_messages                    => sys.messages,
         sourcetask_position_table      => sourcetask_position_table,
         destinationtask_position_table => destinationtask_position_table,
         sourcetask_rank_table          => sourcetask_rank_table,
         a_network                      => a_network);

      -------------------------------------------------
      --- Create the DAG model from the design model
      -------------------------------------------------

      flow_to_task_spw
        (sys               => sys,
         a_link_mat        => a_link_mat,
         destination_tasks => destination_tasks,
         source_tasks      => source_tasks,
         a_network         => a_network,
         result            => result);

   end compute_spacewire_transformation;

   ------------------------------------------------------------------------------------
   ------------------------------------------------------------------------------------
   ----- flow_to_task_Spacewire converts the flow model generated by             ------
   ----- the Spw network to a task model                                         ------
   ----- For SpW Router:                                                         ------
   ----- 1 tram/link ==> 1 task                                                  ------
   ----- 1 link      ==> 1 processor                                             ------
   ------------------------------------------------------------------------------------
   ----- PS: 1. Delete (Spw architecture network / dependencies / messages)      ------
   -----     2. add new messages with new dependencies.                          ------
   ------------------------------------------------------------------------------------

   procedure flow_to_task_spw
     (sys               : in     system;
      a_link_mat        : in     links_mat;
      destination_tasks : in     tasks_set;
      source_tasks      : in     tasks_set;
      a_network         : in     spacewire_network_ptr;
      result            : in out system)
   is

      a_core          : core_unit_ptr;
      a_cpu_name      : Unbounded_String;
      a_address_space : Unbounded_String;
      a_capacity      : Natural := 0;
      a_period        : Natural := 0;
      a_task          : generic_task_ptr;

      mem : memories_table;

      my_iterator1 : tasks_iterator;
      my_iterator2 : messages_iterator;

      my_iterator3 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

      a_message                                    : generic_message_ptr;
      i, var1, var2, var3, var4, var5, packet_size : Integer;

      a_link       : mesh_links;
      a_link_table : links_tab;
      a_taskns     : generic_task_ptr;
      a_tasknd     : generic_task_ptr;

      a_message1, a_message2 : generic_message_ptr;
      a_task1                : generic_task_ptr;
      a_task2                : generic_task_ptr;

   begin

      -- Copy all data of the source model
      -- For dependencies, we copy all dependencies
      -- except asynchronous messages as we transform them
      -- to take network into account
      --
      duplicate (sys.core_units, result.core_units);
      duplicate (sys.processors, result.processors);
      duplicate (sys.address_spaces, result.address_spaces);
      duplicate (sys.tasks, result.tasks);
      duplicate (sys.resources, result.resources);
      duplicate (sys.buffers, result.buffers);

      if not is_empty (sys.dependencies.depends) then
         reset_iterator (sys.dependencies.depends, my_iterator3);

         loop
            current_element
              (sys.dependencies.depends,
               a_half_dep,
               my_iterator3);
            if
              (a_half_dep.type_of_dependency /=
               asynchronous_communication_dependency)
            then
               add (result.dependencies.depends, a_half_dep);
               null;
            end if;

            exit when is_last_element (sys.dependencies.depends, my_iterator3);
            next_element (sys.dependencies.depends, my_iterator3);
         end loop;
      end if;

      -- Create processing units of the DAG
      --
      add_core_unit
        (my_core_units            => result.core_units,
         a_core_unit              => a_core,
         name => suppress_space (To_Unbounded_String ("Core_Link")),
         is_preemptive            => preemptive,
         quantum                  => 0,
         speed                    => 1,
         capacity                 => 1,
         period                   => 1,
         priority                 => 1,
         file_name                => empty_string,
         scheduling_protocol_name => empty_string,
         a_scheduler => dag_highest_level_first_estimated_times_protocol,
         automaton_name           => empty_string,
         start_time               => 0,
         mem                      => mem);

      --------------------------
      -- Horizontal links
      --------------------------

      for j in 0 .. a_network.Ydimension - 1 loop
         var1 := a_network.Ydimension * j;

         for i in 0 .. a_network.Xdimension - 1 loop

            var2 := var1;
            var1 := var1 + 1;

            add_processor
              (my_processors => result.processors,
               name          =>
                 suppress_space
                   (To_Unbounded_String
                      ("proc_link " & var2'img & "To " & var1'img)),
               a_core => a_core);

            add_processor
              (my_processors => result.processors,
               name          =>
                 suppress_space
                   (To_Unbounded_String
                      ("proc_link " & var1'img & "To " & var2'img)),
               a_core => a_core);

            add_address_space
              (my_address_spaces => result.address_spaces,
               name              =>
                 suppress_space
                   (To_Unbounded_String
                      ("Address_Space_" & var2'img & "To" & var1'img)),
               cpu_name =>
                 suppress_space
                   (To_Unbounded_String
                      ("proc_link" & var2'img & "To" & var1'img)),
               text_memory_size  => 1024,
               stack_memory_size => 1024,
               data_memory_size  => 1024,
               heap_memory_size  => 1024);

            add_address_space
              (my_address_spaces => result.address_spaces,
               name              =>
                 suppress_space
                   (To_Unbounded_String
                      ("Address_Space_" & var1'img & "To" & var2'img)),
               cpu_name =>
                 suppress_space
                   (To_Unbounded_String
                      ("proc_link" & var1'img & "To" & var2'img)),
               text_memory_size  => 1024,
               stack_memory_size => 1024,
               data_memory_size  => 1024,
               heap_memory_size  => 1024);

         end loop;

      end loop;

      --------------------------
      -- Vertical links
      --------------------------

      for j in 0 .. a_network.Ydimension - 1 loop
         var1 := j;

         for i in 0 .. a_network.Xdimension - 1 loop

            var2 := var1;
            var1 := var1 + a_network.Xdimension;

            add_processor
              (my_processors => result.processors,
               name          =>
                 suppress_space
                   (To_Unbounded_String
                      ("proc_link " & var2'img & "To " & var1'img)),
               a_core => a_core);

            add_processor
              (my_processors => result.processors,
               name          =>
                 suppress_space
                   (To_Unbounded_String
                      ("proc_link " & var1'img & "To " & var2'img)),
               a_core => a_core);

            add_address_space
              (my_address_spaces => result.address_spaces,
               name              =>
                 suppress_space
                   (To_Unbounded_String
                      ("Address_Space_" & var2'img & "To" & var1'img)),
               cpu_name =>
                 suppress_space
                   (To_Unbounded_String
                      ("proc_link" & var2'img & "To" & var1'img)),
               text_memory_size  => 1024,
               stack_memory_size => 1024,
               data_memory_size  => 1024,
               heap_memory_size  => 1024);

            add_address_space
              (my_address_spaces => result.address_spaces,
               name              =>
                 suppress_space
                   (To_Unbounded_String
                      ("Address_Space_" & var1'img & "To" & var2'img)),
               cpu_name =>
                 suppress_space
                   (To_Unbounded_String
                      ("proc_link" & var1'img & "To" & var2'img)),
               text_memory_size  => 1024,
               stack_memory_size => 1024,
               data_memory_size  => 1024,
               heap_memory_size  => 1024);

         end loop;

      end loop;

      i := 1;
      reset_iterator (sys.messages, my_iterator2);
      reset_iterator (destination_tasks, my_iterator1);
      loop
         current_element (sys.messages, a_message, my_iterator2);
         current_element (destination_tasks, a_tasknd, my_iterator1);
         current_element (source_tasks, a_taskns, my_iterator1);

         a_link_table := a_link_mat (i);
         for j in 1 .. Integer (link_table_size (i)) loop
            a_link      := a_link_table (j);
            packet_size := a_message.size;
            ---------------------------------------
            ------converts flows to tasks----------
            ---------------------------------------

            for flit in 1 .. packet_size loop

               add_task
                 (my_tasks => result.tasks,
                  a_task   => a_task,
                  name     =>
                    suppress_space
                      (To_Unbounded_String
                         ("Task_flow" & i'img & j'img & ":" & flit'img)),
                  cpu_name =>
                    suppress_space
                      (To_Unbounded_String
                         ("proc_link" &
                          a_link.source'img &
                          "To" &
                          a_link.destination'img)),
                  address_space_name =>
                    suppress_space
                      (To_Unbounded_String
                         ("Address_Space_" &
                          a_link.source'img &
                          "To" &
                          a_link.destination'img)),
                  core_name  => empty_string,
                  task_type  => periodic_type,
                  start_time => 0,
                  capacity   =>
                    a_network
                      .link_delay,                             --- le temps de transmission (Path delay) d'un seul flit/lien
                  period =>
                    Integer'max
                      (periodic_task_ptr (a_taskns).period,
                       periodic_task_ptr (a_tasknd)
                         .period),                        --- Periode de tâche source
                  deadline =>
                    Integer'max
                      (a_taskns.deadline,
                       a_tasknd
                         .deadline),                        --- Periode de tâche source
                  jitter        => 0,
                  blocking_time => 0,
                  priority      =>
                    1,                                        --- Priorité de la tâche source
                  criticality => 0,
                  policy      => sched_fifo);

               put_debug ("Added task name   :    " & To_String (a_task.name));
               ---------------------------------------
               ------Produce Messages between---------
               --------task_flow----------------------
               ---------------------------------------

               var3 := j;
               if var3 > 1 then
                  add_message
                    (my_messages => result.messages,
                     name        =>
                       suppress_space
                         (To_Unbounded_String
                            ("Message_of_flow_H " &
                             i'img &
                             ":" &
                             var3'img &
                             ":" &
                             flit'img)),
                     size               => 0,
                     period             => 0,
                     deadline           => 0,
                     jitter             => 0,
                     param              => no_user_defined_parameter,
                     response_time      => 0,
                     communication_time => 0);
               end if;

               ---------------------------------------
               ------Produce dependency between-------
               ------  task_flow               -------
               ---------------------------------------

               var3 := j;

               if var3 > 1 then

                  var4 := var3 - 1;

                  a_task1 :=
                    search_task
                      (result.tasks,
                       suppress_space
                         (To_Unbounded_String
                            ("Task_flow" &
                             i'img &
                             var4'img &
                             ":" &
                             flit'img)));
                  a_task2 :=
                    search_task
                      (result.tasks,
                       suppress_space
                         (To_Unbounded_String
                            ("Task_flow" &
                             i'img &
                             var3'img &
                             ":" &
                             flit'img)));
                  a_message2 :=
                    search_message
                      (result.messages,
                       suppress_space
                         (To_Unbounded_String
                            ("Message_of_flow_H " &
                             i'img &
                             ":" &
                             var3'img &
                             ":" &
                             flit'img)));

                  add_one_task_dependency_asynchronous_communication
                    (my_dependencies   => result.dependencies,
                     a_task            => a_task1,
                     a_dep             => a_message2,
                     a_type            => from_task_to_object,
                     protocol_property => first_message);

                  add_one_task_dependency_asynchronous_communication
                    (my_dependencies   => result.dependencies,
                     a_task            => a_task2,
                     a_dep             => a_message2,
                     a_type            => from_object_to_task,
                     protocol_property => first_message);

                  put_debug
                    ("from   :    " &
                     To_String (a_task1.name) &
                     "  to  " &
                     To_String (a_task2.name) &
                     " over " &
                     To_String (a_message2.name));

               end if;
            end loop;

         end loop;                                                                                                                                                                                                                      ---------------------------------------
         ------Produce Messages between ------
         ------  Source task and          ------
         ------   the first task_flow     ------

         ---------------------------------------
         for flit in 1 .. packet_size loop

            add_message
              (my_messages => result.messages,
               name        =>
                 suppress_space
                   (To_Unbounded_String
                      ("Message_of_flow" &
                       i'img &
                       ":" &
                       flit'img &
                       "from_source")),
               size               => 0,
               period             => 0,
               deadline           => 0,
               jitter             => 0,
               param              => no_user_defined_parameter,
               response_time      => 0,
               communication_time => 0);
            ---------------------------------------
            ------Produce dependency between ------
            ------  Source task and          ------
            ------   the first task_flow     ------
            ---------------------------------------

            a_message1 :=
              search_message
                (result.messages,
                 suppress_space
                   (To_Unbounded_String
                      ("Message_of_flow" &
                       i'img &
                       ":" &
                       flit'img &
                       "from_source")));
            a_task1 :=
              search_task
                (result.tasks,
                 suppress_space
                   (To_Unbounded_String
                      ("Task_flow" & i'img & "1" & ":" & flit'img)));

            add_one_task_dependency_asynchronous_communication
              (my_dependencies   => result.dependencies,
               a_task            => a_taskns,
               a_dep             => a_message1,
               a_type            => from_task_to_object,
               protocol_property => first_message);

            add_one_task_dependency_asynchronous_communication
              (my_dependencies   => result.dependencies,
               a_task            => a_task1,
               a_dep             => a_message1,
               a_type            => from_object_to_task,
               protocol_property => first_message);

            put_debug
              ("from   :    " &
               To_String (a_taskns.name) &
               "  to  " &
               To_String (a_task1.name) &
               " over " &
               To_String (a_message1.name));

            ---------------------------------------
            ------Produce Messages between ------
            ------  the last task_flow       ------
            ------ and the Destination task  ------
            ---------------------------------------

            add_message
              (my_messages => result.messages,
               name        =>
                 suppress_space
                   (To_Unbounded_String
                      ("Message_of_flow" &
                       i'img &
                       ":" &
                       flit'img &
                       "To_Destination")),
               size               => 0,
               period             => 0,
               deadline           => 0,
               jitter             => 0,
               param              => no_user_defined_parameter,
               response_time      => 0,
               communication_time => 0);

            ---------------------------------------
            ------Produce dependency between ------
            ------  the last task_flow       ------
            ------ and the Destination task  ------
            ---------------------------------------

            a_message1 :=
              search_message
                (result.messages,
                 suppress_space
                   (To_Unbounded_String
                      ("Message_of_flow" &
                       i'img &
                       ":" &
                       flit'img &
                       "To_Destination")));
            var5    := Integer (link_table_size (i));
            a_task2 :=
              search_task
                (result.tasks,
                 suppress_space
                   (To_Unbounded_String
                      ("Task_flow" & i'img & var5'img & ":" & flit'img)));

            add_one_task_dependency_asynchronous_communication
              (my_dependencies   => result.dependencies,
               a_task            => a_task2,
               a_dep             => a_message1,
               a_type            => from_task_to_object,
               protocol_property => first_message);

            add_one_task_dependency_asynchronous_communication
              (my_dependencies   => result.dependencies,
               a_task            => a_tasknd,
               a_dep             => a_message1,
               a_type            => from_object_to_task,
               protocol_property => first_message);

            put_debug
              ("from   :    " &
               To_String (a_task2.name) &
               "  to  " &
               To_String (a_tasknd.name) &
               " over " &
               To_String (a_message1.name));

         end loop;

         i := i + 1;

         exit when is_last_element (sys.messages, my_iterator2);

         next_element (sys.messages, my_iterator2);
         next_element (destination_tasks, my_iterator1);

      end loop;

   end flow_to_task_spw;

end spacewire_flow_transformation;
