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

with Text_IO;             use Text_IO;
with Ada.Unchecked_Deallocation;	
     
with translate;           use translate;
with unbounded_strings;   use unbounded_strings;
with scheduler;           use scheduler;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with priority_assignment.rm; use priority_assignment.rm;
with priority_assignment.dm; use priority_assignment.dm;
with systems;                use systems;
with debug;                  use debug;
with scheduling_anomalies_services.online;
use scheduling_anomalies_services.online;
	
with Task_Set; use Task_Set;

package body scheduler.fixed_priority is

   function build_tcb
     (my_scheduler : in fixed_priority_scheduler;
      a_task       :    generic_task_ptr) return tcb_ptr
   is
      a_tcb : fixed_priority_tcb_ptr;
   begin
      a_tcb := new fixed_priority_tcb;
      initialize (tcb (a_tcb.all), a_task);
      initialize (a_tcb.all);
      return tcb_ptr (a_tcb);
   end build_tcb;

   procedure initialize (a_tcb : in out fixed_priority_tcb) is
   begin
      a_tcb.current_priority := a_tcb.tsk.priority;
   end initialize;

   procedure do_election
     (my_scheduler       : in out fixed_priority_scheduler;
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

      highiest_priority : Natural     := Natural'first;
      i                 : tasks_range := 0;
   begin
      -- For each task, call "check_resources" to
      -- take care of priority modification (PCP and PIP)
      --
      loop

         if (si.tcbs (i).tsk.cpu_name = processor_name) and
           ((address_space_name = To_Unbounded_String ("")) or
            (address_space_name = si.tcbs (i).tsk.address_space_name))
         then

            if
              ((si.tcbs (i).tsk.core_name = To_Unbounded_String ("")) or
               (si.tcbs (i).tsk.core_name = core_name))
            then

               if (si.tcbs (i).wake_up_time <= current_time) and
                 (si.tcbs (i).rest_of_capacity /= 0)
               then

                  check_jitter
                    (si.tcbs (i),
                     current_time,
                     si.tcbs (i).is_jitter_ready);
                  if (options.with_jitters = False) or
                    (si.tcbs (i).is_jitter_ready)
                  then

                     if (options.with_offsets = False) or
                       check_offset (si.tcbs (i), current_time)
                     then

                        if (options.with_precedencies = False) or
                          check_precedencies (si, current_time, si.tcbs (i))
                        then

                           if options.with_resources then
                              check_resource
                                (my_scheduler,
                                 si,
                                 result,
                                 current_time,
                                 si.tcbs (i),
                                 fixed_priority_tcb_ptr (si.tcbs (i))
                                   .is_resource_ready,
                                 event_to_generate);
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end if;

         i := i + 1;
         exit when si.tcbs (i) = null;
      end loop;

      -- We can compute scheduling since priorities are ok
      --
      i := 0;
      loop
         if not si.tcbs (i).already_run_at_current_time then

            if (si.tcbs (i).tsk.cpu_name = processor_name) and
              ((address_space_name = To_Unbounded_String ("")) or
               (address_space_name = si.tcbs (i).tsk.address_space_name))
            then

               if
                 ((si.tcbs (i).tsk.core_name = To_Unbounded_String ("")) or
                  (si.tcbs (i).tsk.core_name = core_name))
               then
                  if check_core_assignment (my_scheduler, si.tcbs (i)) then

                     if (si.tcbs (i).wake_up_time <= current_time) and
                       (Natural
                          (fixed_priority_tcb_ptr (si.tcbs (i))
                             .current_priority) >
                        highiest_priority) and
                       (si.tcbs (i).rest_of_capacity /= 0)
                     then

                        if (options.with_jitters = False) or
                          (si.tcbs (i).is_jitter_ready)
                        then

                           if (options.with_offsets = False) or
                             check_offset (si.tcbs (i), current_time)
                           then

                              if (options.with_precedencies = False) or
                                check_precedencies
                                  (si,
                                   current_time,
                                   si.tcbs (i))
                              then

                                 if (options.with_resources = False) or
                                   fixed_priority_tcb_ptr (si.tcbs (i))
                                     .is_resource_ready
                                 then

                                    highiest_priority :=
                                      Natural
                                        (fixed_priority_tcb_ptr (si.tcbs (i))
                                           .current_priority);
                                    elected := i;
                                 end if;
                              end if;
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end if;

         i := i + 1;
         exit when si.tcbs (i) = null;
      end loop;

      if highiest_priority = Natural'first then
         no_task := True;
      else
         no_task := False;
      end if;

   end do_election;

   procedure compute_ceiling_of_resources
     (my_scheduler       : in out fixed_priority_scheduler;
      si                 : in out scheduling_information;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      my_tasks           : in out tasks_set;
      my_resources       : in out resources_set)
   is

   begin
      -- Private scheduler data
      --
      my_scheduler.used_resource := False;

   -- Set priority ceiling of resources : only for PCP, PPCP and IPCP resources and
   -- only if Automatic_Assignment is requested
      --
      for k in 0 .. si.number_of_resources - 1 loop

         if
           (si.shared_resources (k).shared.protocol =
            priority_ceiling_protocol) or
	   (si.shared_resources (k).shared.protocol =
            pool_based_priority_ceiling_protocol) or
           (si.shared_resources (k).shared.protocol =
            immediate_priority_ceiling_protocol)
         then
            if si.shared_resources (k).shared.priority_assignment =
              manual_assignment
            then
               fixed_priority_resource_ptr (si.shared_resources (k))
                 .priority_ceiling :=
                 si.shared_resources (k).shared.priority;

            else

               fixed_priority_resource_ptr (si.shared_resources (k))
                 .priority_ceiling :=
                 priority_range'first;

               for i in
                 0 ..
                     si.shared_resources (k).shared.critical_sections
                       .nb_entries -
                     1
               loop
                  for j in 0 .. si.number_of_tasks - 1 loop
                     if si.shared_resources (k).shared.critical_sections
                         .entries
                         (i)
                         .item =
                       si.tcbs (j).tsk.name
                     then
                        fixed_priority_resource_ptr (si.shared_resources (k))
                          .priority_ceiling :=
                          priority_range'max
                            (fixed_priority_tcb_ptr (si.tcbs (j))
                               .current_priority,
                             fixed_priority_resource_ptr
                               (si.shared_resources (k))
                               .priority_ceiling);
                     end if;
                  end loop;
               end loop;
            end if;
         end if;
      end loop;

   end compute_ceiling_of_resources;
   
   --  Definition of the graph data structures that allow to compute
   --  the task pools in the case of
   --  Pool_Based_Priority_Ceiling_Protocol. The Graph is represented
   --  as an adjacency matrix.  The Graph is undirected. The tasks are
   --  the vertices and eachh shared resource between two tasks
   --  correspond to the presence of an adge between the two
   --  corresponding vertices.

   type Adj_Matrix is array (Tasks_Range range <>, Tasks_Range range <>) 
     of Boolean;
   type Adj_Matrix_Ptr is access all Adj_Matrix;
   procedure Free is new Ada.Unchecked_Deallocation
     (Adj_Matrix, Adj_Matrix_Ptr);
   procedure Print (M : in Adj_Matrix_Ptr);
   procedure Add_Edge (V : in Tasks_Range; 
	               W : in Tasks_Range; 
		       G : in Adj_Matrix_Ptr);	
   --  Since the graph is undirected, we use this function to fill G
   --  (V, W) and G (W, V) at the same time.

   --  The connected components of the graph is an arrray, indexed by
   --  the tasks and containing, for each task the number of the
   --  corresponding component (pool)

   type Connected_Comps is array (Tasks_Range range <>) of Integer;
   type Connected_Comps_Ptr is access all Connected_Comps;
   procedure Free is new Ada.Unchecked_Deallocation
     (Connected_Comps, Connected_Comps_Ptr);
   procedure Print (C : in Connected_Comps_Ptr);
   
   -- We also need to know to which pool belong a shared
   -- resource. This is done after computing the CCs of the graph.
   
   type Shared_Resource_Cc is array (Resources_Range range <>) of Integer;
   type Shared_Resource_Cc_Ptr is access all Shared_Resource_Cc;
   procedure Free is new Ada.Unchecked_Deallocation
     (Shared_Resource_Cc, Shared_Resource_Cc_Ptr);
   procedure Print (S : in Shared_Resource_Cc_Ptr);
   
   procedure Compute_Connected_Components (G  : in     Adj_Matrix_Ptr;
	                                   CC : in out Connected_Comps_Ptr);
   --  This procedure uses the DFS (Depth First Search) algorithm to
   --  compute the connexted components of the task graph.

   procedure Compute_Connected_Components (G  : in     Adj_Matrix_Ptr;
	                                   CC : in out Connected_Comps_Ptr) 
   is
      CC_Num  : Natural := 1;
      Visited : array (G'Range (1)) of Boolean := (others => False);

      procedure Explore (V : in Tasks_Range);   
      --  Explore subroutine of the DFS algorithm

      procedure Explore (V : in Tasks_Range) is
      begin
         Visited (V) := True;
	 CC (V) := CC_Num;
	 for W in G'Range (2) loop
            if G (V, W) and then not Visited (W) then
	       Explore (W);
	    end if;
	 end loop;
      end Explore;
   begin
      for V in G'Range (1) loop
         if not Visited (V) then
            Explore (V);
	    CC_Num := CC_Num + 1;
	 end if;
      end loop;
   end Compute_Connected_Components;

   procedure Print (M : in Adj_Matrix_Ptr) is
   begin
      for I in M'Range (1) loop
         for J in M'Range (2) loop
            Put (M (I, J)'Img & " ");
	 end loop;
	 New_Line;
      end loop;
   end Print;

   procedure Add_Edge (V : in Tasks_Range;
	               W : in Tasks_Range;
		       G : in Adj_Matrix_Ptr)
   is
   begin
      G (V, W) := True;
      G (W, V) := True;
   end Add_Edge;

   procedure Print (C : in Connected_Comps_Ptr) is
   begin
      for I in C'Range loop
         Put (C (I)'Img & " ");
      end loop;
      New_Line;
   end Print;
   
   procedure Print (S : in Shared_Resource_Cc_Ptr) is
   begin
      for I in S'Range loop
         Put (S (I)'Img & " ");
      end loop;
      New_Line;
   end Print;
      
   --  The graph and the connected components will be allocated
   --  dynamically once the number of tasks is known.

   G                  : Adj_Matrix_Ptr := null;
   CC                 : Connected_Comps_Ptr := null;
   Srcc               : Shared_Resource_Cc_Ptr := null;
   Task_Pool_Computed : Boolean := False;
   
   procedure Compute_Task_Pools (Si : in scheduling_information) is
      Do_Task_Pools : Boolean := False;
   begin
      
      --  We only compute the pools in the case of pool_based_priority_ceiling_protocol.
      
      for K in 0 .. Si.Number_Of_Resources - 1 loop
	 if Si.Shared_Resources (K).Shared.Protocol =
           Pool_Based_Priority_Ceiling_Protocol
	 then
	    Do_Task_Pools := True;
	    exit;
	 end if;
      end loop;
      
      if not Do_Task_Pools then
	 return;
      end if;
      
      --  Allocate an initialize new graph and connected components
      
      if G /= null then
	 Free (G);
      end if;
      
      G := new Adj_Matrix (0 .. si.number_of_tasks - 1, 0 .. si.number_of_tasks - 1);
      
      if Cc /= null then
	 Free (Cc);
      end if;
      
      CC := new Connected_Comps (0 .. si.number_of_tasks - 1);
      
      if Srcc /= null then
	 Free (Srcc);
      end if;
      
      Srcc := new Shared_Resource_Cc (0 .. si.number_of_resources - 1);
      
      G.all    := (others => (others => False));
      CC.all   := (others => 0);
      Srcc.all := (others => 0);
      
      --  Build the task graph. For each resource, we loop over the
      --  the tasks declared in the critical sections of the resource
      --  and we link them in the graph. 

      --  FIXME: Note that the code below is extremely inefficient (O
      --  (Tasks**2.Resources.CritSec**2)) since there is no mean to
      --  access the task index direcly from the critical section list
      --  of a shared resource and we are forced to compare the name
      --  strings to link the tasks. If we could access the task index
      --  from the critical section list of the resources, the
      --  complexity would be O (Resources.CritSec**2).
      
      for T in 0 .. si.number_of_tasks - 1 loop
	 for U in T .. si.number_of_tasks - 1 loop
	    for K in 0 .. Si.Number_Of_Resources - 1 loop
	       for C in 0 .. si.shared_resources (K).shared.critical_sections.nb_entries - 1 loop
		  for D in C .. si.shared_resources (K).shared.critical_sections.nb_entries - 1 loop
		     if Si.shared_resources (K).shared.Critical_Sections.Entries (C).Item =
		       Si.Tcbs (T).Tsk.Name and then
		       Si.shared_resources (K).shared.Critical_Sections.Entries (D).Item =
		       Si.Tcbs (U).Tsk.Name
		     then
			Add_Edge (T, U, G);
		     end if;
		  end loop;
	       end loop;
	    end loop;
	 end loop;
      end loop;
      
      --  Compute the pools of tasks
      
      Print (G); -- For debugging purpose

      Compute_Connected_Components (G, CC);

      Print (CC); -- For debugging purpose
      
      --  Compute pools for Shared Resources
      
      for T in 0 .. si.number_of_tasks - 1 loop
	 for K in 0 .. Si.Number_Of_Resources - 1 loop
	    for C in 0 .. si.shared_resources (K).shared.critical_sections.nb_entries - 1 loop
	       if Si.shared_resources (K).shared.Critical_Sections.Entries (C).Item =
		 Si.Tcbs (T).Tsk.Name
	       then
		  Srcc (K) := Cc (T);
	       end if;
	    end loop;
	 end loop;
      end loop;
	 
      Print (Srcc); -- For debugging purpose
      
   end Compute_Task_Pools;

   procedure specific_scheduler_initialization
     (my_scheduler       : in out fixed_priority_scheduler;
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

   begin

      -- Set priority according to the scheduler
      --
      if
        (my_scheduler.parameters.scheduler_type = deadline_monotonic_protocol)
      then
         set_priority_according_to_dm (my_tasks);
      else
         if
           (my_scheduler.parameters.scheduler_type = rate_monotonic_protocol)
         then
            set_priority_according_to_rm (my_tasks);
         end if;
      end if;

      for i in 0 .. si.number_of_tasks - 1 loop
         if (si.tcbs (i).tsk.cpu_name = processor_name) and
           ((address_space_name = To_Unbounded_String ("")) or
            (address_space_name = si.tcbs (i).tsk.address_space_name))
         then
            fixed_priority_tcb_ptr (si.tcbs (i)).current_priority :=
              si.tcbs (i).tsk.priority;
         end if;
      end loop;

      -- Set priority ceiling of resources (only to PCP resource
      --
      compute_ceiling_of_resources
        (my_scheduler,
         si,
         processor_name,
         address_space_name,
         my_tasks,
         my_resources);
   end specific_scheduler_initialization;

   procedure release_resource
     (my_scheduler      : in out fixed_priority_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             :        tcb_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table)
   is

      current_capacity : Natural := 0;
      a_item           : time_unit_event_ptr;
      ipcp_priority    : priority_range;

   begin

      if (si.number_of_resources > 0) then
         current_capacity := a_tcb.tsk.capacity - a_tcb.rest_of_capacity + 1;

         for index1 in 0 .. si.number_of_resources - 1 loop

            -- For each resource, check if the task hold resources
            -- and then release them
            --
            for index2 in
              0 ..
                  si.shared_resources (index1).shared.critical_sections
                    .nb_entries -
                  1
            loop


            -- Must be a Wait of a Mutex critical section
            --
            if (si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .data
                    .task_synchronization = mutex)
             or
               (si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .data
                    .task_synchronization = post)  then


                -- Check if the task end its critical section
                --
               if
                 (current_capacity =
                  si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .data
                    .task_end) and
                 (si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .item =
                  a_tcb.tsk.name)
               then
                  si.shared_resources (index1).shared.state :=
                    si.shared_resources (index1).shared.state + 1;
                  for i in 0 .. si.shared_resources (index1).nb_allocated - 1
                  loop
                     if si.shared_resources (index1).allocated_by (i) =
                       a_tcb.tsk.name
                     then
                        si.shared_resources (index1).allocated_by (i) :=
                          si.shared_resources (index1).allocated_by
                            (si.shared_resources (index1).nb_allocated - 1);
                        si.shared_resources (index1).nb_allocated :=
                          si.shared_resources (index1).nb_allocated - 1;

                        if event_to_generate (release_resource) then
                           a_item := new time_unit_event (release_resource);
                           a_item.release_resource :=
                             si.shared_resources (index1).shared;
                           a_item.release_task := a_tcb.tsk;
                           add (result.all, current_time, a_item);
                        end if;

                        exit;
                     end if;
                  end loop;

                  -- If PIP, PCP or PPCP is used, releasing a shared resource
                  -- should restore initial priority level of the
                  -- task
                  --
                  if
                    (si.shared_resources (index1).shared.protocol =
                     priority_inheritance_protocol) or
                    (si.shared_resources (index1).shared.protocol =
                     priority_ceiling_protocol) or
		    (si.shared_resources (index1).shared.protocol =
                     pool_based_priority_ceiling_protocol)
		  then

                     change_current_priority
                       (my_scheduler,
                        fixed_priority_tcb_ptr (a_tcb),
                        a_tcb.tsk.priority);

                  end if;

-- When releasing an IPCP resource, task priority should be
-- decreased to resource priority ceiling  of all currently allocated resource
                  --
                  if
                    (si.shared_resources (index1).shared.protocol =
                     immediate_priority_ceiling_protocol)
                  then
            -- Compute priority : max (static priority, ceiling priority of all
                     --                          allocated resource)
                     --
                     ipcp_priority :=
                       fixed_priority_tcb_ptr (a_tcb).tsk.priority;

                     for index3 in 0 .. si.number_of_resources - 1 loop
                        if si.shared_resources (index3).nb_allocated > 0 then
                           for index4 in
                             0 .. si.shared_resources (index3).nb_allocated - 1
                           loop
                              if
                                (si.shared_resources (index3).allocated_by
                                   (index4) =
                                 a_tcb.tsk.name) and
                                (fixed_priority_resource_ptr
                                   (si.shared_resources (index3))
                                   .priority_ceiling >
                                 ipcp_priority)
                              then
                                 ipcp_priority :=
                                   fixed_priority_resource_ptr
                                     (si.shared_resources (index3))
                                     .priority_ceiling;
                              end if;
                           end loop;
                        end if;
                     end loop;

                     -- Set priority
                     --
                     change_current_priority
                       (my_scheduler,
                        fixed_priority_tcb_ptr (a_tcb),
                        ipcp_priority);
                  end if;

               end if;
             end if;
            end loop;

         end loop;
      end if;

   end release_resource;

   procedure allocate_resource
     (my_scheduler      : in out fixed_priority_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             :        tcb_ptr;
      event_to_generate : in     time_unit_event_type_boolean_table)
   is

      current_capacity : Natural := 0;
      a_item           : time_unit_event_ptr;
      ipcp_priority    : priority_range;

   begin

      if (si.number_of_resources > 0) then

         current_capacity := a_tcb.tsk.capacity - a_tcb.rest_of_capacity + 1;

         for index1 in 0 .. si.number_of_resources - 1 loop

            -- For each resource, check if the task request the resource
            -- and if the resource is free
            -- otherwise, block the task
            --
            for index2 in
              0 ..
                  si.shared_resources (index1).shared.critical_sections
                    .nb_entries -
                  1
            loop

            -- Must be a Wait of a Mutex critical section
            --
            if (si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .data
                    .task_synchronization = mutex)
             or
               (si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .data
                    .task_synchronization = wait)  then

               -- For each resource, check if 
               -- the task is starting a critical section
               --
               if
                 (current_capacity =
                  si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .data
                    .task_begin) and
                 (si.shared_resources (index1).shared.critical_sections.entries
                    (index2)
                    .item =
                  a_tcb.tsk.name)
               then

                  si.shared_resources (index1).shared.state :=
                    si.shared_resources (index1).shared.state - 1;

                  si.shared_resources (index1).allocated_by
                    (si.shared_resources (index1).nb_allocated) :=
                    a_tcb.tsk.name;
                  si.shared_resources (index1).nb_allocated :=
                    si.shared_resources (index1).nb_allocated + 1;

                  -- when allocating an IPCP resource, task priority should be
                  -- raised to resource priority ceiling
                  --
                  if
                    (si.shared_resources (index1).shared.protocol =
                     immediate_priority_ceiling_protocol)
                  then
                     ipcp_priority :=
                       fixed_priority_tcb_ptr (a_tcb).current_priority;
                     ipcp_priority :=
                       priority_range'max
                         (ipcp_priority,
                          fixed_priority_resource_ptr
                            (si.shared_resources (index1))
                            .priority_ceiling);

                     -- Set priority
                     --
                     change_current_priority
                       (my_scheduler,
                        fixed_priority_tcb_ptr (a_tcb),
                        ipcp_priority);
                  end if;

                  if event_to_generate (allocate_resource) then
                     a_item := new time_unit_event (allocate_resource);
                     a_item.allocate_resource :=
                       si.shared_resources (index1).shared;
                     a_item.allocate_task := a_tcb.tsk;
                     add (result.all, current_time, a_item);
                  end if;

               end if;
	     end if;
            end loop;

         end loop;
      end if;

   end allocate_resource;

   procedure check_resource
     (my_scheduler      : in out fixed_priority_scheduler;
      si                : in out scheduling_information;
      result            : in out scheduling_sequence_ptr;
      current_time      : in     Natural;
      a_tcb             : in     tcb_ptr;
      is_ready          :    out Boolean;
      event_to_generate : in     time_unit_event_type_boolean_table)
   is

      current_capacity : Natural := 0;
      Num_Task         : Tasks_Range := 0;
   begin
      --  Compute the task poolsc(Only for PPCP, if not done yet).
      --  FIXME: The code below would be better if there is
      --  ainitialization routine for the fixed priority
      --  scheduler. For now, this does not work for a new model
      --  unless we close Cheddar and open it again.
      --
      if not Task_Pool_Computed then
	 Compute_Task_Pools (Si);
	 Task_Pool_Computed := True;
      end if;
      
      -- By default, the task is allowed to run
      --
      is_ready := True;

      if (si.number_of_resources > 0) then

         current_capacity := a_tcb.tsk.capacity - a_tcb.rest_of_capacity + 1;

         for resource_index in 0 .. si.number_of_resources - 1 loop

            for index2 in
              0 ..
              si.shared_resources (resource_index).shared.critical_sections
              .nb_entries -
              1
            loop

               -- Must be a Wait of a Mutex critical section
               --
               if (si.shared_resources (resource_index).shared.critical_sections.entries
                     (index2)
                     .data
                     .task_synchronization = mutex)
		 or
		 (si.shared_resources (resource_index).shared.critical_sections.entries
                    (index2)
                    .data
                    .task_synchronization = wait)  then

		  -- For each resource, check if the task requests the resource
		  -- i.e. that the task is starting a critical section
		  --
		  if
                    (current_capacity =
                       si.shared_resources (resource_index).shared.critical_sections
                       .entries
			 (index2)
                       .data
                       .task_begin) and
                      (si.shared_resources (resource_index).shared.critical_sections
			 .entries
			 (index2)
			 .item =
			 a_tcb.tsk.name)
		  then

                     -- PCP blocking : the requesting task must have a priority
                     -- strickly higher than the ceiling priority of
                     -- all previously allocated resources (allocated by other
                     -- tasks than the requesting task)
                     --
                     if
                       (si.shared_resources (resource_index).shared.protocol =
			  priority_ceiling_protocol)
                     then

			-- Scan already allocated resources to check if the
			-- requiring task
			-- has a highier priority than ALL allocated resource
			-- ceiling value : block the task in the other case
			--
			for index3 in 0 .. si.number_of_resources - 1 loop
                           if si.shared_resources (index3).nb_allocated > 0 then
                              for index4 in
				0 .. si.shared_resources (index3).nb_allocated - 1
                              loop
				 if
                                   (si.shared_resources (index3).allocated_by
                                      (index4) /=
                                      a_tcb.tsk.name) and
                                     (fixed_priority_resource_ptr
					(si.shared_resources (index3))
					.priority_ceiling >=
					fixed_priority_tcb_ptr (a_tcb)
					.current_priority)
				 then
                                    is_ready := False;
				 end if;
                              end loop;
                           end if;
			end loop;
                     end if;
		     
		     -- PPCP blocking : the requesting task must have a priority
                     -- strickly higher than the ceiling priority of
                     -- all previously allocated resources (allocated by other
                     -- tasks than the requesting task, belonging to the same pool
		     -- as the current task, i.e. sharing a resourc, directly or
		     -- indirectly with it)
                     --
                     if
                       (si.shared_resources (resource_index).shared.protocol =
			  pool_based_priority_ceiling_protocol)
                     then
			
			-- Scan already allocated resources from the
			-- same pool to check if the requiring task
			-- has a highier priority than ALL allocated
			-- resource ceiling value : block the task in
			-- the other case
			--
			
			--  Determine the task pool
			
			for J in 0 .. Si.Number_Of_Tasks - 1 loop
			   if Si.Tcbs (J).Tsk.Name = A_Tcb.Tsk.Name then
			      Num_Task := J;
			      Put_Debug ("Task " & To_String (a_tcb.tsk.name) & 
					   " of number " & Num_Task'Img &
					   " is of pool " 
					   & Cc (Num_Task)'Img);
			      exit;
			   end if;
			end loop;
			
			for index3 in 0 .. si.number_of_resources - 1 loop
                           if si.shared_resources (index3).nb_allocated > 0 
			     and then Srcc (Index3) = Cc (Num_Task)
			   then
                              for index4 in
				0 .. si.shared_resources (index3).nb_allocated - 1
                              loop
				 if
				   (si.shared_resources (index3).allocated_by
				      (index4) /=
				      a_tcb.tsk.name) and
				     (fixed_priority_resource_ptr
					(si.shared_resources (index3))
					.priority_ceiling >=
					fixed_priority_tcb_ptr (a_tcb)
					.current_priority)
				 then
				    is_ready := False;
				 end if;
                              end loop;
                           end if;
			end loop;
                     end if;
		     
		     -- Check that the task is available : i.e. the semaphore related
		     -- to the resource is free
                     --
                     if
                       (si.shared_resources (resource_index).shared.state = 0)
                     then
			is_ready := False;
                     end if;

                     -- The requesting task is blocked, for PI, PCP and PPCP
                     -- we must change the priority level of a task
                     -- that holds the resource (priority inheritance)
                     --
                     if (is_ready = False) then
			if
			  (si.shared_resources (resource_index).shared.protocol =
                             priority_inheritance_protocol) or
			    (si.shared_resources (resource_index).shared.protocol =
                               priority_ceiling_protocol) or
			    (si.shared_resources (resource_index).shared.protocol =
                               pool_based_priority_ceiling_protocol)   

			then	   
                           for i in
                             0 ..
                             si.shared_resources (resource_index)
                             .nb_allocated -
                             1
                           loop
                              for j in 0 .. si.number_of_tasks - 1 loop

				 if si.shared_resources (resource_index)
                                   .allocated_by
                                   (i) =
                                   si.tcbs (j).tsk.name
				 then

                                    change_current_priority
                                      (my_scheduler,
                                       fixed_priority_tcb_ptr (si.tcbs (j)),
                                       priority_range'max
					 (fixed_priority_tcb_ptr (a_tcb)
                                            .current_priority,
					  fixed_priority_tcb_ptr (si.tcbs (j))
                                            .current_priority));

				 end if;
                              end loop;
                           end loop;
			end if;
                     end if;

		     -- If the task is blocked due to a resource, we store this data
		     -- in its Tcb
                     --
                     if is_ready = False then
			put_debug
			  (To_String (a_tcb.tsk.name) &
                             " is waiting for " &
                             To_String
                               (si.shared_resources (resource_index).shared.name));
			a_tcb.wait_for_a_resource :=
			  si.shared_resources (resource_index).shared;
                     end if;

		  end if;
               end if;
            end loop;
         end loop;
      end if;

   end check_resource;

   function build_resource
     (my_scheduler : in fixed_priority_scheduler;
      a_resource   :    generic_resource_ptr) return shared_resource_ptr
   is
      new_a_resource : fixed_priority_resource_ptr;

   begin

      new_a_resource        := new fixed_priority_resource;
      new_a_resource.shared := a_resource;

      -- Set priority ceiling of the resource
      --
      new_a_resource.priority_ceiling := Low_Priority;

      return shared_resource_ptr (new_a_resource);

   end build_resource;

   procedure change_current_priority
     (my_scheduler : in out fixed_priority_scheduler'class;
      a_tcb        : in     fixed_priority_tcb_ptr;
      new_priority :        priority_range)
   is
   begin
      dispatched_change_current_priority (my_scheduler, a_tcb, new_priority);
   end change_current_priority;

   procedure dispatched_change_current_priority
     (my_scheduler : in out fixed_priority_scheduler;
      a_tcb        : in     fixed_priority_tcb_ptr;
      new_priority :        priority_range)
   is

   begin
      a_tcb.current_priority := new_priority;
   end dispatched_change_current_priority;

   procedure produce_running_task_event
     (my_scheduler : in     fixed_priority_scheduler;
      a_task       : in     tcb_ptr;
      options      : in     scheduling_option;
      si           : in     scheduling_information;
      an_event     :    out time_unit_event_ptr)
   is

      cache_state : Unbounded_String := empty_string;
      inp         : handler_input_parameter;
      outp        : handler_output_parameter;

   begin
      an_event                  := new time_unit_event (running_task);
      an_event.running_task     := a_task.tsk;
      an_event.running_core     := my_scheduler.corresponding_core_unit.name;
      an_event.current_priority :=
        fixed_priority_tcb_ptr (a_task).current_priority;
      an_event.crpd := a_task.crpd_capacity;
      for i in 0 .. a_task.ucbs_in_cache.size - 1 loop
         Append
           (cache_state,
            To_Unbounded_String (" " & a_task.ucbs_in_cache.elements (i)'img));
      end loop;
      an_event.cache_state := cache_state;
      if (options.with_anomaly_detection) then
         inp.event        := an_event;
         inp.runtime_data := si;
         scheduling_anomaly_handler (inp, my_scheduler, outp);
      end if;
   end produce_running_task_event;

   function export_xml_event_running_task
     (my_scheduler : in fixed_priority_scheduler;
      an_event     : in time_unit_event_ptr) return Unbounded_String
   is
      result : Unbounded_String := empty_string;
   begin
      result :=
        " " &
        an_event.running_task.name &
        " " &
        priority_range'image (an_event.current_priority) &
        " " &
        an_event.running_core &
        " ";
      return result;
   end export_xml_event_running_task;

end scheduler.fixed_priority;
