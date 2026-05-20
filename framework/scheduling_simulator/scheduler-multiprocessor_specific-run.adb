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

with Ada.Tags;                          use Ada.Tags;
with Text_IO;                           use Text_IO;

with debug;                             use debug;
with double_util;                       use double_util;
with id_generators;                     use id_generators;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Periodic_Tasks_Table_Package;
use Multiprocessor_Services_Interface.Run_Servers_Table_Package;
use Multiprocessor_Services_Interface.Naturals_Table_Package;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with systems;                           use systems;
with task_set;                          use task_set;
use task_set.generic_task_set;
with translate;                         use translate;
with unbounded_strings;                 use unbounded_strings;
with xml_tag;                           use xml_tag;
with doubles;                           use doubles;

package body scheduler.multiprocessor_specific.run is

   use type naturals_table_range;

   -- To generate unique server name

   my_id : id;

   --  As the scheduler is initialized once per core, define a global
   --  scheduler for the processor.

   global_scheduler : global_run_scheduler_ptr;
   global_version   : Natural := 0;

   --  Add item if not already present and keep table sorted.

   procedure add_unique_item (table : in out naturals_table; item : Natural);

   --  Compute the sum of server rates

   function compute_rate (servers : run_servers_table_ptr) return Double;

   --  Find a ready task and on tie, prefer the one previously running
   --  on core. tcbs is provided to find the tcb_id and so the
   --  task_id.
   --
   --  FIXME: should better use tcbs, but run servers are
   --  modeled as tasks not as jobs.

   function find_elected_task_for_core
     (tcbs : in tcb_table;
      core : in Unbounded_String) return tasks_range;

   --  Increment job id from run server structure and update its
   --  attributes release and deadline.

   procedure next_job (s : run_server_ptr);

   --  Put online info of run server

   procedure put_job (s : run_server_ptr);
   procedure put_jobs (s : run_servers_table);

   --  Put offline info of run server

   procedure put_run_server
     (indent    : Natural;
      server    : run_server_primal_ptr;
      recursive : Boolean := True);
   procedure put_run_server
     (indent    : Natural;
      server    : run_server_dual_ptr;
      recursive : Boolean := True);
   procedure put_run_server (indent : Natural; server : run_server_ptr);

   --  Compute the periods of a primal server based on its dual
   --  servers and then compute the releases and deadlines over its
   --  hyper-period.
   --
   --  FIXME: this should be improved when two periods are harmonic.
   --  Keep it this way for debugging purpose

   procedure compute_deadlines (primal : run_server_primal_ptr);

   --  PACK operation of RUN algorithm

   procedure pack_first_fit
     (dual_servers : in     run_servers_table_ptr;
      pack_servers :    out run_servers_table_ptr);

   --  DUAL operation of RUN algorithm

   procedure dual
     (primal_server : in     run_server_primal_ptr;
      dual_server   :    out run_server_dual_ptr);
   procedure dual
     (primal_servers : in     run_servers_table_ptr;
      dual_servers   :    out run_servers_table_ptr);

   --  Operation REDUCE = PACK + DUAL

   function reduce
     (dual_servers : in run_servers_table_ptr) return run_servers_table_ptr;

   --  Create a primal or dual server based on its counterpart

   function create (primal : run_server_primal_ptr) return run_server_dual_ptr;
   function create (dual : run_server_dual_ptr) return run_server_primal_ptr;

   --  Schedule with EDF scheduler dual servers of a primal server

   procedure schedule_dual_servers (duals : in out run_servers_table);

   --  Schedule a run server tree (recursively). Provide root primal
   --  server as input and return the running tasks as output.

   procedure schedule_run_server_tree
     (primal :        run_server_primal_ptr;
      tasks  : in out run_servers_table);

   -- Add Item in Table if not already present and keep table sorted.

   procedure add_unique_item (table : in out naturals_table; item : Natural) is
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
   end add_unique_item;

   function build_tcb
     (my_scheduler : in multiprocessor_run_scheduler;
      a_task       :    generic_task_ptr) return tcb_ptr
   is
      a_tcb : run_tcb_ptr;
   begin
      a_tcb := new run_tcb;
      initialize (tcb (a_tcb.all), a_task);
      initialize (a_tcb.all);

      return tcb_ptr (a_tcb);
   end build_tcb;

   procedure check_before_scheduling
     (my_scheduler   : in multiprocessor_run_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is
   begin
      periodic_control (my_tasks, processor_name);
   end check_before_scheduling;

   --  Compute periods of a primal server based on its inner primals
   --  periods and then compute its deadlines

   procedure compute_deadlines (primal : run_server_primal_ptr) is
      dual     : run_server_dual_ptr;
      hperiod  : Double; -- Hyper Period
      deadline : Natural;

   begin
      for d in 0 .. primal.packed_servers.nb_entries - 1 loop
         --  Compute periods and deadlines of a dual server
         --  Add periods to the primal server periods

         dual := run_server_dual_ptr (primal.packed_servers.entries (d));

         if dual.primal_server = null then
            -- Dual is a plain task

            add_unique_item (dual.periods, dual.period);
            add_unique_item (dual.deadlines, dual.period);
            add_unique_item (primal.periods, dual.period);

         else
            -- Dual is a regular dual server

            compute_deadlines (dual.primal_server);
            dual.periods   := dual.primal_server.periods;
            dual.deadlines := dual.primal_server.deadlines;
            for p in 0 .. dual.periods.nb_entries - 1 loop
               add_unique_item (primal.periods, dual.periods.entries (p));
            end loop;
         end if;
      end loop;

      --  Primal server periods are up to date. Compute hyper period

      hperiod := Double (primal.periods.entries (0));
      for p in 1 .. primal.periods.nb_entries - 1 loop
         hperiod := lcm (hperiod, Double (primal.periods.entries (p)));
      end loop;

      --  Update deadlines since hyper period and periods are up to date

      for p in 0 .. primal.periods.nb_entries - 1 loop
         deadline := 0;
         for i in 1 .. Natural (hperiod / Double (primal.periods.entries (p)))
         loop
            deadline := deadline + primal.periods.entries (p);
            add_unique_item (primal.deadlines, deadline);
         end loop;
      end loop;
   end compute_deadlines;

   --  Compute the global rate of a set of servers.
   --  FIXME: try to prevent imprecision using double.

   function compute_rate (servers : run_servers_table_ptr) return Double is
      rate : Double := 0.0;
   begin
      for s in 0 .. servers.nb_entries - 1 loop
         rate := rate + servers.entries (s).rate;
         rate := Double'adjacent (rate, Double'first);
      end loop;
      return rate;
   end compute_rate;

   function copy
     (a_scheduler : in multiprocessor_run_scheduler)
      return generic_scheduler_ptr
   is
      ptr : multiprocessor_run_scheduler_ptr;

   begin
      ptr                    := new multiprocessor_run_scheduler;
      ptr.parameters         := a_scheduler.parameters;
      ptr.previously_elected := a_scheduler.previously_elected;

      return generic_scheduler_ptr (ptr);
   end copy;

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

   procedure do_election
     (my_scheduler       : in out multiprocessor_run_scheduler;
      si                 : in out scheduling_information;
      result             : in out scheduling_sequence_ptr;
      msg                : in out Unbounded_String;
      current_time       : in     Natural;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      core_name          : in     Unbounded_String;
      options            : in     scheduling_option;
      event_to_generate  : in     time_unit_event_type_boolean_table;
      elected            : in out tasks_range;
      no_task            : in out Boolean)
   is
      servers : run_servers_table;
      s       : run_server_ptr;
      ps      : run_server_primal_ptr;
      ds      : run_server_dual_ptr;
   begin
      no_task := False;
      put_debug
        ("--**RUN**-- called on core " &
         To_String (core_name) &
         " at time" &
         current_time'img &
         " (to update at time" &
         global_scheduler.time_to_update'img &
         ")");

      if (current_time /= global_scheduler.time_to_update) then
         -- The scheduler has already been invoked

         if global_scheduler.running_tasks.nb_entries = 0 then
            no_task := True;
            return;
         end if;

         elected := find_elected_task_for_core (si.tcbs, core_name);
         put_debug
           ("--**RUN**-- elect task " &
            To_String (si.tcbs (elected).tsk.name) &
            " on core " &
            To_String (core_name) &
            " (cached result)");
         return;
      end if;

      global_scheduler.time_to_update := current_time + 1;

      -- First step : update releases, deadlines and capacities

      -- Actually, servers is a stack of servers to schedule

      initialize (servers);
      add (servers, run_server_ptr (global_scheduler.run_server_tree));
      while (servers.nb_entries > 0) loop

         s := servers.entries (servers.nb_entries - 1);
         delete (servers, servers.nb_entries - 1);
         if (s.job_deadline = current_time) then
            --  Update release and deadline

            next_job (s);

            --  Recursively schedule the inner servers

            if s.all in run_server_primal then
               ps := run_server_primal_ptr (s);
               for e in 0 .. ps.packed_servers.nb_entries - 1 loop
                  add (servers, ps.packed_servers.entries (e));
               end loop;

            elsif s.all in run_server_dual then
               ds := run_server_dual_ptr (s);
               if ds.primal_server /= null then
                  add (servers, run_server_ptr (ds.primal_server));
               end if;
            end if;
         end if;
      end loop;

      -- Second step : execute RUN scheduler.

      global_scheduler.run_server_tree.executing := True;
      initialize (global_scheduler.running_tasks);
      schedule_run_server_tree
        (global_scheduler.run_server_tree,
         global_scheduler.running_tasks);

      put_debug
        ("--**RUN**-- elect" &
         global_scheduler.running_tasks.nb_entries'img &
         " tasks");

      for e in 0 .. global_scheduler.running_tasks.nb_entries - 1 loop
         put_job (global_scheduler.running_tasks.entries (e));
      end loop;

      if global_scheduler.running_tasks.nb_entries = 0 then
         no_task := True;
         return;
      end if;

      elected := find_elected_task_for_core (si.tcbs, core_name);
      put_debug
        ("--**RUN**-- elect task " &
         To_String (si.tcbs (elected).tsk.name) &
         " on core " &
         To_String (core_name));
   end do_election;

   --  Find a ready task and on tie, prefer the one previously running
   --  on core. tcbs is provided to find the tcb_id and so the
   --  task_id.

   function find_elected_task_for_core
     (tcbs : in tcb_table;
      core : in Unbounded_String) return tasks_range
   is
      g      : constant global_run_scheduler_ptr := global_scheduler;
      tsk_id : run_servers_table_range           := 0;
      tcb_id : tasks_range                       := 0;

   begin
      put_debug ("looking for task running on core " & To_String (core));
      for e in 0 .. g.running_tasks.nb_entries - 1 loop
         if (g.running_tasks.entries (e).core = core) then
            --  A task was running on this core already

            tsk_id := e;
            exit;

         elsif (g.running_tasks.entries (e).core = Null_Unbounded_String) then
            --  Select this task in case core has not already been assigned

            tsk_id := e;
         end if;
      end loop;
      g.running_tasks.entries (tsk_id).core := core;

      --  Find the index using the task name. Not sure that tcb are
      --  always in the same order.

      while (tcbs (tcb_id).tsk.name /= g.running_tasks.entries (tsk_id).name)
      loop
         tcb_id := tcb_id + 1;
      end loop;

      --  Now we can remove it from running tasks.

      delete (g.running_tasks, tsk_id);

      return tcb_id;
   end find_elected_task_for_core;

   procedure initialize (a_tcb : in out run_tcb) is
   begin
      null;
   end initialize;

   procedure initialize (a_scheduler : in out multiprocessor_run_scheduler) is
   begin
      reset (a_scheduler);
      a_scheduler.parameters.scheduler_type :=
        reduction_to_uniprocessor_protocol;
      a_scheduler.version := global_version;
   end initialize;

   -- Update absolute job_release and job_deadline for the next
   -- job. Update job_id the relative index in the deadlines table.

   procedure next_job (s : run_server_ptr) is
   begin
      if (s.job_deadline = 0)
        or else (s.job = naturals_table_range (s.deadlines.nb_entries) - 1)
      then
         --  deadline is zero only when the simulation starts (special
         --  case). If deadline is zero or if the job is the last index in
         --  the deadlines table (a full cycle) get back to start.

         s.job          := 0;
         s.job_release  := s.job_deadline;
         s.job_deadline := s.job_deadline + s.deadlines.entries (s.job);

      else
         -- Get next job

         s.job          := s.job + 1;
         s.job_release  := s.job_deadline;
         s.job_deadline :=
           s.job_deadline +
           s.deadlines.entries (s.job) -
           s.deadlines.entries (s.job - 1);
      end if;

      -- Get duration (length of time window) and capacity

      s.job_duration := s.job_deadline - s.job_release;
      s.job_capacity := Natural (Double (s.job_duration) * s.rate);
   end next_job;

   --  Pack dual servers (possibly tasks). Produce a set of primal servers.
   --
   --  FIXME: should be worst fit packing.

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

         -- Cannot fill current primal server anymore.
         -- Add it to the set and create a new one.

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

   procedure put_job (s : run_server_ptr) is
   begin
      Put_Line ("Name      : " & To_String (s.name));
      Put_Line ("Job id    :" & s.job'img);
      Put_Line ("Duration  :" & s.job_duration'img);
      Put_Line ("Release   :" & s.job_release'img);
      Put_Line ("Deadline  :" & s.job_deadline'img);
      Put_Line ("Capacity  :" & s.job_capacity'img);
      Put_Line ("Executing : " & s.executing'img);
      Put_Line ("Rate      :" & s.rate'img);
      New_Line;
   end put_job;

   procedure put_jobs (s : run_servers_table) is
   begin
      for e in 0 .. s.nb_entries - 1 loop
         Put (To_String (s.entries (e).name));
         if (s.entries (e).executing) then
            Put ("(+) ");
         else
            Put ("(-) ");
         end if;
         put_job (s.entries (e));
      end loop;
      New_Line;
   end put_jobs;

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

   --  From a set of dual servers, apply RUN's offline part and produce
   --  a set of primal servers.

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

   procedure schedule_dual_servers (duals : in out run_servers_table) is
      dual     : run_server_dual_ptr;
      deadline : Natural; -- Earliest deadline
   begin
      dual     := null;
      deadline := Natural'last;

      --  Apply EDF and on tie prefer an already executing job

      for d in 0 .. duals.nb_entries - 1 loop
         if (duals.entries (d).job_capacity > 0) then
            if (duals.entries (d).job_deadline < deadline)
              or else
              ((duals.entries (d).job_deadline = deadline)
               and then duals.entries (d).executing)
            then
               dual     := run_server_dual_ptr (duals.entries (d));
               deadline := dual.job_deadline;
            end if;
         end if;
         duals.entries (d).executing := False;
      end loop;

      if dual = null then
         put_debug ("--**RUN**-- WARNING : no dual server to schedule");

         for e in 0 .. duals.nb_entries - 1 loop
            put_job (duals.entries (e));
         end loop;
      else
         dual.executing    := True;
         dual.job_capacity := dual.job_capacity - 1;
      end if;
   end schedule_dual_servers;

   --  Schedule run servers from the run tree. This is a recursive or
   --  hierarchical scheduling.

   procedure schedule_run_server_tree
     (primal :        run_server_primal_ptr;
      tasks  : in out run_servers_table)
   is
      dual   : run_server_dual_ptr;
      level0 : Boolean;
   begin
      -- Determine whether we are scheduling tasks or servers

      dual   := run_server_dual_ptr (primal.packed_servers.entries (0));
      level0 := (dual.primal_server = null);

      --  Primal runs out of budget and so is not executing

      if (primal.job_capacity = 0) then
         primal.executing := False;
      end if;

      if (not primal.executing) then
         --  Rule IV.2 (packed server not executing)

         --  set duals as not executing -- their primal will be executing
         for e in 0 .. primal.packed_servers.nb_entries - 1 loop
            dual := run_server_dual_ptr (primal.packed_servers.entries (e));
            dual.executing := False;
         end loop;

      else
         --  Rule IV.2 (packed server executing)

         primal.job_capacity := primal.job_capacity - 1;

         --  select which dual from duals will be executing
         schedule_dual_servers (primal.packed_servers);
      end if;

      if level0 then
         -- We update parameter tasks

         for e in 0 .. primal.packed_servers.nb_entries - 1 loop
            dual := run_server_dual_ptr (primal.packed_servers.entries (e));
            if dual.executing then
               -- We add it to the running tasks list
               -- We keep core as is

               add (tasks, run_server_ptr (dual));

            else
               -- We release the core previously assigned

               dual.core := Null_Unbounded_String;
            end if;
         end loop;

      else
         for e in 0 .. primal.packed_servers.nb_entries - 1 loop
            dual := run_server_dual_ptr (primal.packed_servers.entries (e));
            dual.primal_server.executing := not dual.executing;

            --  schedule the subtree whether its primal is executing or not
            schedule_run_server_tree (dual.primal_server, tasks);
         end loop;
      end if;
   end schedule_run_server_tree;

   procedure specific_scheduler_initialization
     (my_scheduler       : in out multiprocessor_run_scheduler;
      si                 : in out scheduling_information;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      my_tasks           : in out tasks_set;
      my_schedulers      : in     scheduler_table;
      my_resources       : in out resources_set;
      my_buffers         : in out buffers_set;
      my_messages        : in     messages_set;
      msg                : in out Unbounded_String)
   is
      task_set : run_servers_table_ptr; -- Tasks are mapped as dual servers
      run_tree : run_servers_table_ptr; -- Primal table with only root server
      a_server : run_server_ptr;
      i        : tasks_range;

   begin
      --  Define a unique global scheduler while this initialization
      --  function is called once per core

      if (my_scheduler.version < global_version) then
         my_scheduler.version     := global_version;
         my_scheduler.core_id     := global_scheduler.n_cores;
         global_scheduler.n_cores := global_scheduler.n_cores + 1;
         return;
      end if;

      --  Should free memory when global_scheduler /= null
      my_scheduler.core_id            := 0;
      global_version                  := global_version + 1;
      global_scheduler                := new global_run_scheduler;
      global_scheduler.n_cores        := 1;
      global_scheduler.time_to_update := 0;

      initialize (my_id);

      --  Feed task set with si.tcbs.tsk

      i        := 0;
      task_set := new run_servers_table;
      while (si.tcbs (i) /= null) loop
         -- A dual server with no primal server is a true periodic task

         a_server        := new run_server_dual;
         a_server.name   := si.tcbs (i).tsk.name;
         a_server.period := periodic_task_ptr (si.tcbs (i).tsk).period;
         a_server.rate   :=
           Double (si.tcbs (i).tsk.capacity) / Double (a_server.period);
         a_server.rate := Double'adjacent (a_server.rate, Double'first);

         add (task_set.all, a_server);
         i := i + 1;
      end loop;

      --  Build the tree from the task set based on a sequence of
      --  reduce operations (pack + dual)

      run_tree := reduce (task_set);

      --  run_tree is supposed to be a table with a unique primal server

      global_scheduler.run_server_tree :=
        run_server_primal_ptr (run_tree.entries (0));

      -- Once the run server tree is built compute releases and deadlines.

      compute_deadlines (global_scheduler.run_server_tree);

      New_Line;
      put_run_server (0, global_scheduler.run_server_tree, recursive => True);
   end specific_scheduler_initialization;

end scheduler.multiprocessor_specific.run;
