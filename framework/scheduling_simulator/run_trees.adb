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
-- Cheddar has been published in the "Agence de Protection des
-- Programmes/France" in 2008.
-- Since 2008, Ellidiss technologies also contributes to the development of
-- Cheddar and provides industrial support.
--
-- The full list of contributors and sponsors can be found in README.md
-- SPONSORS.txt
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

with xml_tag;             use xml_tag;
with double_util;         use double_util;
with translate;           use translate;
with unbounded_strings;   use unbounded_strings;
with systems;             use systems;
with Ada.Tags;            use Ada.Tags;
with Text_IO;             use Text_IO;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with systems;             use systems;
with Tasks;               use Tasks;
with task_set;            use task_set;
use task_set.generic_task_set;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Naturals_Table_Package;
use Multiprocessor_Services_Interface.Periodic_Tasks_Table_Package;
use Multiprocessor_Services_Interface.Run_Servers_Table_Package;
with id_generators;       use id_generators;
with debug;               use debug;

package body run_trees is

   -- To generate server name
   --
   my_id : id;

   procedure add_single_item (table : in out naturals_table; item : Natural);

   function compute_rate (servers : run_servers_table_ptr) return Double;

   -- Add Item if not already present and sort.

   procedure add_single_item (table : in out naturals_table; item : Natural) is
   begin
      for e in 0 .. table.nb_entries - 1 loop
         if (table.entries (e) = item) then
            return;

         elsif (table.entries (e) > item) then
            table.entries (e + 1 .. table.nb_entries) :=
              table.entries (e .. table.nb_entries - 1);
            table.entries (e) := item;
            table.nb_entries  := table.nb_entries + 1;
            return;
         end if;
      end loop;
      add (table, item);
   end add_single_item;

   --  Compute periods of this primal server based on its inner primals
   --  periods and then compute its deadlines

   procedure compute_deadlines (primal : run_server_primal_ptr) is
      dual     : run_server_dual_ptr;
      hperiod  : Double; -- Hyper Period
      deadline : Natural;

   begin
      for d in 0 .. primal.packed_servers.nb_entries - 1 loop
         dual := run_server_dual_ptr (primal.packed_servers.entries (d));

         -- Dual is a plain task

         if dual.primal_server = null then
            add_single_item (dual.periods, dual.period);
            add_single_item (dual.deadlines, dual.period);
            add_single_item (primal.periods, dual.period);

         -- Dual has an effective primal server

         else
            compute_deadlines (dual.primal_server);
            dual.periods   := dual.primal_server.periods;
            dual.deadlines := dual.primal_server.deadlines;
            for p in 0 .. dual.periods.nb_entries - 1 loop
               add_single_item (primal.periods, dual.periods.entries (p));
            end loop;
         end if;
      end loop;

      hperiod := Double (primal.periods.entries (0));
      for p in 1 .. primal.periods.nb_entries - 1 loop
         hperiod := lcm (hperiod, Double (primal.periods.entries (p)));
      end loop;

      for p in 0 .. primal.periods.nb_entries - 1 loop
         deadline := 0;
         for i in 1 .. Natural (hperiod / Double (primal.periods.entries (p)))
         loop
            deadline := deadline + primal.periods.entries (p);
            add_single_item (primal.deadlines, deadline);
         end loop;
      end loop;
   end compute_deadlines;

   --  Compute the global rate of a set of servers

   function compute_rate (servers : run_servers_table_ptr) return Double is
      rate : Double := 0.0;
   begin
      for s in 0 .. servers.nb_entries - 1 loop
         rate := rate + servers.entries (s).rate;
         rate := Double'adjacent (rate, Double'first);
      end loop;
      return rate;
   end compute_rate;

   -- Create a dual server associated to a primal server

   function create
     (primal : run_server_primal_ptr) return run_server_dual_ptr
   is
      dual : run_server_dual_ptr;
   begin
      dual               := new run_server_dual;
      dual.name          := primal.name & "*";
      dual.primal_server := primal;
      dual.rate          := 1.0 - primal.rate;
      dual.deadlines     := primal.deadlines;
      dual.periods       := primal.periods;

      return dual;
   end create;

   -- Create a primal server including at least Dual as first dual server

   function create (dual : run_server_dual_ptr) return run_server_primal_ptr is
      primal : run_server_primal_ptr;
      id_val : Unbounded_String;
   begin
      generate_id (my_id, id_val);
      primal      := new run_server_primal;
      primal.name := "S" & id_val;
      add (primal.packed_servers, run_server_ptr (dual));
      primal.rate := dual.rate;
      initialize (primal.deadlines);
      initialize (primal.periods);
      return primal;
   end create;

   procedure dual
     (primal_server : in     run_server_primal_ptr;
      dual_server   :    out run_server_dual_ptr)
   is
   begin
      dual_server := create (primal_server);
   end dual;

   procedure dual
     (primal_servers : in     run_servers_table_ptr;
      dual_servers   :    out run_servers_table_ptr)
   is
      a_dual : run_server_dual_ptr;
   begin
      dual_servers := new run_servers_table;
      for i in 0 .. primal_servers.nb_entries - 1 loop
         dual (run_server_primal_ptr (primal_servers.entries (i)), a_dual);
         add (dual_servers.all, run_server_ptr (a_dual));
      end loop;
   end dual;

   -- Loop on pack/dual until we get a single server
   -- Called at simulator initialization

   --  procedure initial_reduce
   --    (my_tasks    : in tasks_set;
   --     a_processor : in unbounded_string)
   --  is
   --     task_list : run_servers_table_ptr; -- Tasks mapped as dual servers
   --     result    : run_servers_table_ptr; -- Primal servers
   --  begin
   --     put_debug ("initial_reduce");
   --     initialize_root_run_tree (my_tasks, a_processor, task_list);

   --     result := reduce (task_list);
   --     -- Result is supposed to be a table with a single primal server

   --     root := run_server_primal_ptr (result.entries (0));
   --     compute_deadlines (run_server_primal_ptr (root));

   --     new_line;
   --     put_run_server (0, root, recursive => true);
   --  end initial_reduce;

   -- Map each task into a dual RUN server and store it into Results

   --  procedure initialize_root_run_tree
   --    (my_tasks    : in     tasks_set;
   --     a_processor : in     unbounded_string;
   --     result      :    out run_servers_table_ptr)
   --  is
   --     a_task      : generic_task_ptr;
   --     my_iterator : tasks_iterator;

   --     a_server  : run_server_dual_ptr;
   --     task_rate : double;
   --  begin
   --     initialize (my_id);

   --     result := new run_servers_table;
   --     reset_iterator (my_tasks, my_iterator);
   --     loop
   --        current_element (my_tasks, a_task, my_iterator);

   --        if (a_task.cpu_name = a_processor) then
   --           task_rate :=
   --             double (a_task.capacity) /
   --             double (periodic_task_ptr (a_task).period);

   --           -- A dual server with no primal server is a true periodic task

   --           a_server        := new run_server_dual;
   --           a_server.name   := a_task.name;
   --           a_server.period := periodic_task_ptr (a_task).period;
   --           a_server.rate   := task_rate;

   --           add (result.all, run_server_ptr (a_server));
   --        end if;

   --        exit when is_last_element (my_tasks, my_iterator);
   --        next_element (my_tasks, my_iterator);
   --     end loop;
   --  end initialize_root_run_tree;

   --  Pack dual servers (possibly tasks) and produce a set of primal servers

   procedure pack_first_fit
     (dual_servers : in     run_servers_table_ptr;
      pack_servers :    out run_servers_table_ptr)
   is
      a_server : run_server_primal_ptr;
      rate     : Double;
   begin
      pack_servers := new run_servers_table; --  Primal Servers
      a_server     := create (run_server_dual_ptr (dual_servers.entries (0)));
      for i in 1 .. dual_servers.nb_entries - 1 loop

         -- Cannot fill current primal server anymore
         -- Add it to the set and create a new one

         rate :=
           Double'adjacent
             (a_server.rate + dual_servers.entries (i).rate,
              Double'first);
         if (rate > 1.0) then
            add (pack_servers.all, run_server_ptr (a_server));
            a_server :=
              create (run_server_dual_ptr (dual_servers.entries (i)));

         else
            a_server.rate :=
              Double'adjacent
                (a_server.rate + dual_servers.entries (i).rate,
                 Double'first);
            add (a_server.packed_servers, dual_servers.entries (i));
         end if;
      end loop;
      add (pack_servers.all, run_server_ptr (a_server));
   end pack_first_fit;

   --  Indent to represent hierarchy

   procedure put_indent (indent : Natural) is
   begin
      for i in 1 .. indent loop
         Put ("   ");
      end loop;
   end put_indent;

   procedure put_run_server
     (indent    : Natural;
      server    : run_server_primal_ptr;
      recursive : Boolean := True)
   is
      dual : run_server_dual_ptr;
   begin
      put_indent (indent);
      Put_Line ("Primal RUN Server : ");
      put_run_server (indent, run_server_ptr (server));

      put_indent (indent);
      Put ("Pack : ");
      for i in 0 .. server.packed_servers.nb_entries - 1 loop
         Put (To_String (server.packed_servers.entries (i).name) & " ");
      end loop;
      New_Line;
      New_Line;

      if not recursive then
         return;
      end if;

      Put_Line ("-----------------------------------------------");
      for i in 0 .. server.packed_servers.nb_entries - 1 loop
         dual := run_server_dual_ptr (server.packed_servers.entries (i));
         put_run_server (indent + 1, dual, recursive);
      end loop;
      Put_Line ("-----------------------------------------------");
   end put_run_server;

   procedure put_run_server
     (indent    : Natural;
      server    : run_server_dual_ptr;
      recursive : Boolean := True)
   is
      primal : run_server_primal_ptr := server.primal_server;
   begin
      if primal = null then
         put_indent (indent);
         Put_Line ("Periodic Task : ");
         put_run_server (indent, run_server_ptr (server));
      else
         put_indent (indent);
         Put_Line ("Dual Server: ");
         put_run_server (indent, run_server_ptr (server));
         New_Line;
         put_run_server (indent, primal, recursive);
      end if;
   end put_run_server;

   procedure put_run_server (indent : Natural; server : run_server_ptr) is
   begin
      put_indent (indent);
      Put_Line ("Name : " & To_String (server.name));
      put_indent (indent);
      Put_Line ("Rate : " & server.rate'img);
      put_indent (indent);
      Put ("Periods :");
      for e in 0 .. server.periods.nb_entries - 1 loop
         Put (server.periods.entries (e)'img);
      end loop;
      New_Line;
      put_indent (indent);
      Put ("Deadlines :");
      for e in 0 .. server.deadlines.nb_entries - 1 loop
         Put (server.deadlines.entries (e)'img);
      end loop;
      New_Line;
   end put_run_server;

   -- From a set of dual servers, produce a set of primal servers
   --
   function reduce
     (dual_servers : in run_servers_table_ptr) return run_servers_table_ptr
   is
      -- Server table AFTER a PACK operation
      pack_result : run_servers_table_ptr;

      -- Server table AFTER a DUAL operation
      dual_result : run_servers_table_ptr;
      rate        : Double;
   begin
      pack_first_fit (dual_servers, pack_result);
      rate := compute_rate (pack_result);
      if (rate <= 1.0) then
         return pack_result;
      end if;
      dual (pack_result, dual_result);
      return reduce (dual_result);
   end reduce;

end run_trees;
