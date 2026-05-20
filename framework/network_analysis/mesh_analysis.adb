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

with Ada.Text_IO;              use Ada.Text_IO;
with Ada.Integer_Text_IO;      use Ada.Integer_Text_IO;
with Ada.Command_Line;         use Ada.Command_Line;
with AADL_Config;              use AADL_Config;
with unbounded_strings;        use unbounded_strings;
with Text_IO;                  use Text_IO;
with Ada.Exceptions;           use Ada.Exceptions;
with translate;                use translate;
with processor_set;            use processor_set;
with Text_IO;                  use Text_IO;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with unbounded_strings;        use unbounded_strings;
with Dependencies;             use Dependencies;
with task_dependencies;        use task_dependencies;
with task_dependencies;        use task_dependencies.half_dep_set;
with sets;
with Tasks;                    use Tasks;
with task_set;                 use task_set;
with message_set;              use message_set;
with Messages;                 use Messages;
with systems;                  use systems;
with framework;                use framework;
with call_framework;           use call_framework;
with Call_Framework_Interface; use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with call_scheduling_framework;         use call_scheduling_framework;
with multiprocessor_services;           use multiprocessor_services;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
with Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with GNAT.Command_Line;
with GNAT.OS_Lib; use GNAT.OS_Lib;
with version;     use version;
with Parameters;  use Parameters;
use Parameters.User_Defined_Parameters_Table_Package;
with Parameters.extended; use Parameters.extended;
with network_set;         use network_set;
with Networks;            use Networks;
use Networks.Positions_Table_Package;
with indexed_tables;

package body mesh_analysis is

   -----------------------------
   -- subprograms --
   -----------------------------

   -----------------------
   -- compute_source_destination_task--
   -----------------------

   -- generate destination tasks set and source task set --

   procedure compute_source_destination_task
     (my_tasks          : in     tasks_set;
      my_messages       : in     messages_set;
      my_dep            : in     tasks_dependencies_ptr;
      destination_tasks : in out tasks_set;
      source_tasks      : in out tasks_set)
   is
      number_message : Integer;
      a_message      : generic_message_ptr;
      my_iterator    : messages_iterator;
      my_iterator1   : tasks_dependencies_iterator;
      a_half_dep     : dependency_ptr;

   begin

      reset_iterator (my_messages, my_iterator);
      number_message := 1;
      loop
         current_element (my_messages, a_message, my_iterator);
         if not is_empty (my_dep.depends) then
            reset_iterator (my_dep.depends, my_iterator1);

            loop
               current_element (my_dep.depends, a_half_dep, my_iterator1);
               if
                 (a_half_dep.type_of_dependency =
                  asynchronous_communication_dependency)
               then
                  if
                    (a_message =
                     a_half_dep.asynchronous_communication_dependency_object)
                  then
                     if
                       (a_half_dep.asynchronous_communication_orientation =
                        from_object_to_task)
                     then
                        add
                          (destination_tasks,
                           a_half_dep
                             .asynchronous_communication_dependent_task);
                     else
                        add
                          (source_tasks,
                           a_half_dep
                             .asynchronous_communication_dependent_task);
                     end if;
                  end if;
               end if;

               exit when is_last_element (my_dep.depends, my_iterator1);
               next_element (my_dep.depends, my_iterator1);
            end loop;
         end if;

         exit when is_last_element (my_messages, my_iterator);
         next_element (my_messages, my_iterator);
         number_message := number_message + 1;
      end loop;

   end compute_source_destination_task;

   -----------------------------------------------------
   ----display_source_destination_task -----------------
   -----------------------------------------------------

   procedure display_source_destination_task
     (my_messages                    : in     messages_set;
      destination_tasks              : in     tasks_set;
      source_tasks                   : in     tasks_set;
      sourcetask_position_table      : in     tab_position;
      destinationtask_position_table : in     tab_position;
      sourcetask_rank_table          : in out processor_ranks;
      destinationtask_rank_table     : in out processor_ranks)

   is

      my_iterator1 : tasks_iterator;
      my_iterator2 : messages_iterator;
      i            : Integer;
      a_taskns     : generic_task_ptr;
      a_tasknd     : generic_task_ptr;
      a_message    : generic_message_ptr;

   begin
      Put_Line ("Display source and destination tasks           ");

      i := 1;
      if not is_empty (destination_tasks) then

         reset_iterator (destination_tasks, my_iterator1);

         reset_iterator (my_messages, my_iterator2);

         loop
            current_element (destination_tasks, a_tasknd, my_iterator1);
            current_element (source_tasks, a_taskns, my_iterator1);
            current_element (my_messages, a_message, my_iterator2);

            Put_Line ("    ");
            Put_Line ("    ");

            Put (To_String (a_message.name));
            Put_Line ("   : ");

            Put (To_String (a_taskns.name));
            Put ("  ");
            Put (To_String (a_taskns.cpu_name));
            Put ("(");
            Put (Integer (sourcetask_rank_table (i)));
            Put (")  ");
            Put ("   ----->   ");
            Put (To_String (a_tasknd.name));
            Put ("  ");
            Put (To_String (a_tasknd.cpu_name));
            Put ("  (");
            Put (Integer (destinationtask_rank_table (i)));
            Put (")  ");

            Put_Line (" . ");
            Put ("source_pos : ");
            Put (sourcetask_position_table (i).X);
            Put (sourcetask_position_table (i).Y);
            Put ("  ===>  ");
            Put ("destination_pos : ");
            Put (destinationtask_position_table (i).X);
            Put (destinationtask_position_table (i).Y);

            Put_Line ("  ");

            exit when is_last_element (destination_tasks, my_iterator1);
            next_element (destination_tasks, my_iterator1);
            next_element (my_messages, my_iterator2);
            i := i + 1;

         end loop;

      end if;

   end display_source_destination_task;

   ------------------------------------------------
   ---compute_source_destination_task_position-----
   ------------------------------------------------
   --select position of each souce and destination
   --task in order to compute after the used links.
   ------------------------------------------------

   procedure compute_noc_source_destination_task_position
     (sourcetask_position_table      : in out tab_position;
      destinationtask_position_table : in out tab_position;
      sourcetask_rank_table          : in out processor_ranks;
      destinationtask_rank_table     : in out processor_ranks;
      source_tasks                   : in out tasks_set;
      destination_tasks              : in out tasks_set;
      my_messages                    : in     messages_set;
      my_noc                         : in     networks_set)

   is
      my_iterator1 : tasks_iterator;
      my_iterator2 : messages_iterator;
      my_iterator3 : networks_iterator;
      i, j         : Integer;
      cpu_index    : processor_rank;
      a_taskns     : generic_task_ptr;
      a_tasknd     : generic_task_ptr;
      a_noc        : noc_network_ptr;
      table1       : positions_table;

   begin

      i := 1;
      if not is_empty (destination_tasks) then

         reset_iterator (destination_tasks, my_iterator1);

         loop
            current_element (destination_tasks, a_tasknd, my_iterator1);
            current_element (source_tasks, a_taskns, my_iterator1);

            j := 0;
            reset_iterator (my_noc, my_iterator3);
            loop
               current_element
                 (my_noc,
                  generic_network_ptr (a_noc),
                  my_iterator3);
               table1 := a_noc.processor_positions;

               cpu_index := 1;
               for index_table in 0 .. table1.nb_entries loop

                  if
                    (a_taskns.cpu_name = table1.entries (index_table).item)
                  then
                     sourcetask_position_table (i).X :=
                       table1.entries (index_table).data.X;
                     sourcetask_position_table (i).Y :=
                       table1.entries (index_table).data.Y;
                     sourcetask_rank_table (i) := cpu_index;
                  end if;

                  if
                    (a_tasknd.cpu_name = table1.entries (index_table).item)
                  then
                     destinationtask_position_table (i).X :=
                       table1.entries (index_table).data.X;
                     destinationtask_position_table (i).Y :=
                       table1.entries (index_table).data.Y;
                     destinationtask_rank_table (i) := cpu_index;
                  end if;

                  cpu_index := cpu_index + 1;
               end loop;

               j := j + 1;
               exit when is_last_element (my_noc, my_iterator3);
               next_element (my_noc, my_iterator3);
            end loop;

            exit when is_last_element (destination_tasks, my_iterator1);
            next_element (destination_tasks, my_iterator1);
            i := i + 1;

         end loop;

      end if;

   end compute_noc_source_destination_task_position;

   procedure compute_spw_source_destination_task_position
     (sourcetask_position_table      : in out tab_position;
      destinationtask_position_table : in out tab_position;
      sourcetask_rank_table          : in out processor_ranks;
      destinationtask_rank_table     : in out processor_ranks;
      source_tasks                   : in     tasks_set;
      destination_tasks              : in     tasks_set;
      my_messages                    : in     messages_set;
      a_network                      : in     spacewire_network_ptr)

   is
      my_iterator1 : tasks_iterator;
      my_iterator2 : messages_iterator;
      my_iterator3 : networks_iterator;
      my_iterator4 : tasks_iterator;
      i, j         : Integer;
      cpu_index    : processor_rank;
      a_taskns     : generic_task_ptr;
      a_tasknd     : generic_task_ptr;
      table1       : positions_table;

   begin

      i := 1;
      if not is_empty (destination_tasks) then

         reset_iterator (destination_tasks, my_iterator1);
         reset_iterator (source_tasks, my_iterator4);

         loop
            current_element (destination_tasks, a_tasknd, my_iterator1);
            current_element (source_tasks, a_taskns, my_iterator4);

            j      := 0;
            table1 := a_network.processor_positions;

            cpu_index := 1;
            for index_table in 0 .. table1.nb_entries - 1 loop

               if (a_taskns.cpu_name = table1.entries (index_table).item) then
                  sourcetask_position_table (i).X :=
                    table1.entries (index_table).data.X;
                  sourcetask_position_table (i).Y :=
                    table1.entries (index_table).data.Y;
                  sourcetask_rank_table (i) := cpu_index;
               end if;

               if (a_tasknd.cpu_name = table1.entries (index_table).item) then
                  destinationtask_position_table (i).X :=
                    table1.entries (index_table).data.X;
                  destinationtask_position_table (i).Y :=
                    table1.entries (index_table).data.Y;
                  destinationtask_rank_table (i) := cpu_index;
               end if;

               cpu_index := cpu_index + 1;
            end loop;

            j := j + 1;

            exit when is_last_element (destination_tasks, my_iterator1);
            next_element (destination_tasks, my_iterator1);
            next_element (source_tasks, my_iterator4);
            i := i + 1;

         end loop;

      end if;

   end compute_spw_source_destination_task_position;

   ------------------------------
   ---procedure generate_links---
   ------------------------------
   --generate used links --------
   --for each message -----------
   ------------------------------

   procedure generate_links_noc
     (a_link_mat                     : in out links_mat;
      my_messages                    : in     messages_set;
      sourcetask_position_table      : in     tab_position;
      destinationtask_position_table : in     tab_position;
      sourcetask_rank_table          : in     processor_ranks)

   is
      my_iterator2                        : messages_iterator;
      a_message                           : generic_message_ptr;
      i, diff_x, diff_x1, diff_y, diff_y1 : Integer;
      cpu_position, y_max                 : processor_rank;
      a_link, a_link_invalid              : mesh_links;
      a_link_table                        : links_tab;

   begin

      a_link_invalid.source      := 0;
      a_link_invalid.destination := 0;
      i                          := 1;
      y_max                      := 2;

      reset_iterator (my_messages, my_iterator2);
      loop
         current_element (my_messages, a_message, my_iterator2);

         diff_x :=
           destinationtask_position_table (i).X -
           sourcetask_position_table (i).X;
         cpu_position        := sourcetask_rank_table (i);
         link_table_size (i) := 0;

         for index in 1 .. max_mesh_links_per_message loop
            a_link_table (index) := a_link_invalid;
         end loop;

         diff_y :=
           destinationtask_position_table (i).Y -
           sourcetask_position_table (i).Y;

         if (diff_y > 0) then

            for j in 1 .. diff_y loop
               a_link.source                                := cpu_position;
               a_link.destination := cpu_position + 1;
               cpu_position := cpu_position + 1;
               link_table_size (i) := link_table_size (i) + 1;
               a_link_table (Integer (link_table_size (i))) := a_link;
            end loop;

         else
            if (diff_y < 0) then
               diff_y1 := -diff_y;
               for j in 1 .. diff_y1 loop
                  a_link.source                                := cpu_position;
                  a_link.destination := cpu_position - 1;
                  cpu_position := cpu_position - 1;
                  link_table_size (i) := link_table_size (i) + 1;
                  a_link_table (Integer (link_table_size (i))) := a_link;
               end loop;

            end if;

         end if;

         if (diff_x > 0) then

            for j in 1 .. diff_x loop
               a_link.source                                := cpu_position;
               a_link.destination := cpu_position + y_max + 1;
               cpu_position := cpu_position + (y_max + 1);
               link_table_size (i) := link_table_size (i) + 1;
               a_link_table (Integer (link_table_size (i))) := a_link;

            end loop;

         else
            if (diff_x < 0) then

               diff_x1 := -diff_x;
               for j in 1 .. diff_x1 loop

                  a_link.source                                := cpu_position;
                  a_link.destination := cpu_position - y_max + 1;
                  cpu_position := cpu_position - (y_max + 1);
                  link_table_size (i) := link_table_size (i) + 1;
                  a_link_table (Integer (link_table_size (i))) := a_link;

               end loop;

            end if;
         end if;

         a_link_mat (i) := a_link_table;
         i              := i + 1;

         exit when is_last_element (my_messages, my_iterator2);
         next_element (my_messages, my_iterator2);

      end loop;

   end generate_links_noc;

   procedure generate_links_spw
     (a_link_mat                     : in out links_mat;
      my_messages                    : in     messages_set;
      sourcetask_position_table      : in     tab_position;
      destinationtask_position_table : in     tab_position;
      sourcetask_rank_table          : in     processor_ranks;
      a_network                      : in     spacewire_network_ptr)

   is
      my_iterator2                        : messages_iterator;
      a_message                           : generic_message_ptr;
      i, diff_x, diff_x1, diff_y, diff_y1 : Integer;
      cpu_position                        : processor_rank;
      a_link, a_link_invalid              : mesh_links;
      a_link_table                        : links_tab;
      my_iterator3                        : networks_iterator;

   begin

      a_link_invalid.source      := 0;
      a_link_invalid.destination := 0;
      i                          := 1;

      reset_iterator (my_messages, my_iterator2);
      loop
         current_element (my_messages, a_message, my_iterator2);

         diff_x :=
           destinationtask_position_table (i).X -
           sourcetask_position_table (i).X;
         cpu_position        := sourcetask_rank_table (i);
         link_table_size (i) := 0;

         for index in 1 .. max_mesh_links_per_message loop
            a_link_table (index) := a_link_invalid;
         end loop;

         diff_y :=
           destinationtask_position_table (i).Y -
           sourcetask_position_table (i).Y;
         if (diff_y > 0) then

            for j in 1 .. diff_y loop
               a_link.source                                := cpu_position;
               a_link.destination := cpu_position + 1;
               cpu_position := cpu_position + 1;
               link_table_size (i) := link_table_size (i) + 1;
               a_link_table (Integer (link_table_size (i))) := a_link;
            end loop;

         else
            if (diff_y < 0) then
               diff_y1 := -diff_y;
               for j in 1 .. diff_y1 loop
                  a_link.source                                := cpu_position;
                  a_link.destination := cpu_position - 1;
                  cpu_position := cpu_position - 1;
                  link_table_size (i) := link_table_size (i) + 1;
                  a_link_table (Integer (link_table_size (i))) := a_link;
               end loop;

            end if;

         end if;

         if (diff_x > 0) then

            for j in 1 .. diff_x loop
               a_link.source      := cpu_position;
               a_link.destination :=
                 cpu_position + processor_rank (a_network.Xdimension);

               cpu_position :=
                 cpu_position + (processor_rank (a_network.Xdimension));
               link_table_size (i) := link_table_size (i) + 1;
               a_link_table (Integer (link_table_size (i))) := a_link;

            end loop;

         else
            if (diff_x < 0) then

               diff_x1 := -diff_x;
               for j in 1 .. diff_x1 loop

                  a_link.source      := cpu_position;
                  a_link.destination :=
                    cpu_position - processor_rank (a_network.Xdimension);
                  cpu_position :=
                    cpu_position - processor_rank (a_network.Xdimension);
                  link_table_size (i) := link_table_size (i) + 1;
                  a_link_table (Integer (link_table_size (i))) := a_link;

               end loop;

            end if;
         end if;

         a_link_mat (i) := a_link_table;
         i              := i + 1;

         exit when is_last_element (my_messages, my_iterator2);
         next_element (my_messages, my_iterator2);

      end loop;

   end generate_links_spw;

   procedure display_used_links
     (my_messages : in messages_set;
      a_link_mat  : in links_mat)

   is
      my_iterator2 : messages_iterator;
      a_message    : generic_message_ptr;
      i            : Integer;
      a_link       : mesh_links;
      a_link_table : links_tab;

   begin

      Put_Line ("        display used links and flow Model           ");

      i := 1;
      reset_iterator (my_messages, my_iterator2);
      loop
         current_element (my_messages, a_message, my_iterator2);
         Put_Line ("");
         Put (To_String (a_message.name));
         Put ("  :   ");
         a_link_table := a_link_mat (i);

         for j in 1 .. Integer (link_table_size (i)) loop
            a_link := a_link_table (j);
            Put ("  e(");
            Put (Integer (a_link.source));
            Put (Integer (a_link.destination));
            Put (")  ");
         end loop;

         i := i + 1;

         exit when is_last_element (my_messages, my_iterator2);
         next_element (my_messages, my_iterator2);
      end loop;
      Put_Line (" ");
   end display_used_links;

end mesh_analysis;
