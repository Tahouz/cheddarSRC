
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

with Text_IO;                           use Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Unbounded_Strings; use Unbounded_Strings;
with Ada.Exceptions;                    use Ada.Exceptions;

with Resources;                         use Resources;
use Resources.Resource_Accesses;
with natural_util;                      use natural_util;
with double_util;                       use double_util;
with integer_util;                      use integer_util;
with Task_Groups;                       use Task_Groups;
with Tasks;                             use Tasks;
use Tasks.Generic_Task_List_Package;
with Task_Set;                          use Task_Set;
with Task_Groups;                       use Task_Groups;
with Task_Group_Set;                    use Task_Group_Set;
with Systems;                           use Systems;
with Task_Dependencies;                 use Task_Dependencies;
with Dependencies;                      use Dependencies;

package body Task_Group_Transformation is
   procedure Multiframe_to_Transaction
     (My_Multiframe : in Multiframe_Task_Group_Ptr;
      A_System      : in out System) -- New Transaction System
   is
      -- New transaction variables
      A_Transaction    : Transaction_Task_Group_Ptr;
      A_Task_Group     : Generic_Task_Group_Ptr;
      A_Periodic_Task  : Periodic_Task_Ptr;
      Offset_Sum       : Integer;
      New_Offset       : Offset_Type_Ptr;
      New_Offset_Table : Offsets_Table_Ptr;
      Start_Time       : Integer;

      -- Old Multiframe variables
      A_Frame_Task       : Frame_Task_Ptr;
      A_Task             : Generic_Task_Ptr;
      Task_List_Iterator : Generic_Task_Iterator;
   begin
      A_Transaction      := new Transaction_Task_Group;
      A_Transaction.name := My_Multiframe.name;
      -- TODO: other task_group attributes
      A_Task_Group := Generic_Task_Group_Ptr (A_Transaction);

      Add_Task_Group(A_System.task_groups, A_Task_Group);

      Offset_Sum := 0;

      if not is_empty(My_Multiframe.task_list) then
         -- Transaction.startTime = Multiframe.startTime = Multiframe.first_task.startTime
         A_Task := get_head(My_Multiframe.task_list);
         Start_Time := A_Task.Start_Time;

         reset_head_iterator
           (My_Multiframe.task_list,
            Task_List_Iterator);
         loop
            current_element
              (My_Multiframe.task_list,
               A_Task,
               Task_List_Iterator);
            A_Frame_Task := Frame_Task_Ptr (A_Task);

            New_Offset              := new Offset_Type;
            New_Offset.offset_value := Offset_Sum;
            New_Offset.activation   := 0;
            New_Offset_Table        := new Offsets_Table;
            Offsets_Table_Package.Add (New_Offset_Table.all, New_Offset.all);

            Add_Task
              (A_System.Tasks,
               A_System.Task_Groups,
               A_Transaction.name,
               A_Frame_Task.name,
               A_Frame_Task.cpu_name,
               A_Frame_Task.address_space_name,
               Periodic_Type, -- Periodic_Type mandatory
               Start_Time,
               A_Frame_Task.capacity,
               1, -- temporary period
               A_Frame_Task.deadline,
               0, -- jitter
               A_Frame_Task.blocking_time,
               Integer (A_Frame_Task.priority),
               A_Frame_Task.criticality,
               A_Frame_Task.policy,
               New_Offset_Table.all,
               A_Frame_Task.stack_memory_size,
               A_Frame_Task.text_memory_size,
               A_Frame_Task.parameters,
               empty_string,
               0, -- seed
               True, -- predictable
               A_Frame_Task.context_switch_overhead);

            Offset_Sum := Offset_Sum + A_Frame_Task.interarrival;

            if is_tail_element
                 (My_Multiframe.task_list,
                  Task_List_Iterator)
            then
               exit;
            end if;

            next_element
              (My_Multiframe.task_list,
               Task_List_Iterator);
         end loop;

         -- Set transaction period
         A_Transaction.period := Offset_Sum;

         -- Loop to set task periods and precedence_dependencies in the
         --created transaction
         reset_head_iterator
           (A_Transaction.task_list,
            Task_List_Iterator);
         loop
            current_element
              (A_Transaction.task_list,
               A_Task,
               Task_List_Iterator);
            A_Periodic_Task        := Periodic_Task_Ptr (A_Task);
            A_Periodic_Task.period := Offset_Sum;

            Update_All_Task_Dependencies(A_System.dependencies, A_Task);

            if is_tail_element
                 (A_Transaction.task_list,
                  Task_List_Iterator)
            then
               exit;
            end if;

            next_element
              (A_Transaction.task_list,
               Task_List_Iterator);
         end loop;

      end if;
   end Multiframe_to_Transaction;

   procedure Modify_Offsets
     (A_System : in out System) -- New Transaction System
   is
      Changed : Boolean := true;

      A_Half_Dep : Dependency_Ptr;
      Task_Dependencies_It : Tasks_Dependencies_Iterator;

      Source_Task : Generic_Task_Ptr;
      Sink_Task : Generic_Task_Ptr;

      New_Offset       : Offset_Type_Ptr;
      New_Offset_Table : Offsets_Table_Ptr;

      Opq : Integer;
      Cpq : Integer;
      Spq : Integer;
      rpq : Integer;
      Oij : Integer;
      Cij : Integer;
      Dij : Integer;
      Sij : Integer;
      rij : Integer;
      Phi : Integer;

      Dependent_Task_Groups : Task_Groups_Set;

      use Task_Dependencies.Half_Dep_Set;
   begin
      while (Changed) loop -- While modifications took place
         Changed := false;
         if not is_empty(A_System.Dependencies.Depends) then
            reset_iterator(A_System.Dependencies.Depends, Task_Dependencies_It);
            loop -- through precedence dependencies
               current_element(A_System.Dependencies.Depends, A_Half_Dep, Task_Dependencies_It);

               if A_Half_Dep.type_of_dependency = Precedence_Dependency then
                  Source_Task := A_Half_Dep.precedence_source;
                  Sink_Task := A_Half_Dep.precedence_sink;

                  -- tau_pq variables
                  Opq := 0;
                  if (Source_Task.offsets.Nb_Entries > 0) then
                     Opq := Source_Task.offsets.entries(0).offset_value;
                  end if;
                  Cpq := Source_Task.capacity;
                  Spq := Source_Task.start_time;
                  rpq := Spq + Opq;

                  -- tau_ij variables
                  Oij := 0;
                  if (Sink_Task.offsets.Nb_Entries > 0) then
                     Oij := Sink_Task.offsets.entries(0).offset_value;
                  end if;
                  Cij := Sink_Task.capacity;
                  Dij := Sink_Task.deadline;
                  Sij := Sink_Task.start_time;
                  rij := Sij + Oij;

                  if (rpq + Cpq > rij) then
                     Phi := rpq + Cpq - rij; -- Difference between tau_ij's (supposed) new offset and its current

                     Oij := Oij + Phi; -- Modify tau_ij's offset
                     Dij := Dij - Phi; -- Shorten tau_ij's relative deadline

                     rij := Sij + Oij;
                     if (rij + Dij < rij + Cij) then
                        put_line(To_String(Source_Task.name & " < " & Sink_Task.name));
                        raise Deadline_Violated;
                     end if;

                     Sink_Task.deadline := Dij;
                     if (Sink_Task.offsets.Nb_Entries > 0) then
                        Sink_Task.offsets.entries(0).offset_value := Oij;
                     else
                        New_Offset              := new Offset_Type;
                        New_Offset.offset_value := Oij;
                        New_Offset.activation   := 0;
                        New_Offset_Table        := new Offsets_Table;
                        Offsets_Table_Package.Add (New_Offset_Table.all, New_Offset.all);
                        Sink_Task.offsets := New_Offset_Table.all;
                     end if;

                     Changed := true;
                  end if;
               end if;

               exit when is_last_element(A_System.Dependencies.Depends, Task_Dependencies_It);
               next_element(A_System.Dependencies.Depends, Task_Dependencies_It);
            end loop;
         end if;
      end loop;
   end Modify_Offsets;

   -- Note that we do this here instead of inside the changed loop since that loop is in O(n²)
   -- We only loop through n/2 <=> O(n) this way.
   procedure Merge_Transactions(A_System : in out System) is
      A_Half_Dep : Dependency_Ptr;
      Task_Dependencies_It : Tasks_Dependencies_Iterator;

      Source_Task : Generic_Task_Ptr;
      Sink_Task : Generic_Task_Ptr;
      Source_Group : Generic_Task_Group_Ptr;
      Sink_Group : Generic_Task_Group_Ptr;

      Sij : Integer;
      Oij : Integer;
      rij : Integer;
      r_min : Integer := -1;

      Task_Groups_It : Task_Groups_Iterator;
      A_Task_Group : Generic_Task_Group_Ptr;

      Task_List_It : Generic_Task_Iterator;
      A_Task : Generic_Task_Ptr;

      New_Offset       : Offset_Type_Ptr;
      New_Offset_Table : Offsets_Table_Ptr;

      use Task_Dependencies.Half_Dep_Set;
   begin
      -- Loop through dependencies and merge togerther transactions with task dependencies
      if not is_empty(A_System.Dependencies.Depends) then
         reset_iterator(A_System.Dependencies.Depends, Task_Dependencies_It);
         loop -- through precedence dependencies
            current_element(A_System.Dependencies.Depends, A_Half_Dep, Task_Dependencies_It);

            if A_Half_Dep.type_of_dependency = Precedence_Dependency then
               Source_Task := A_Half_Dep.precedence_source;
               Sink_Task := A_Half_Dep.precedence_sink;

               Source_Group := Search_Task_Group_By_Task(A_System.Task_Groups, Source_Task.name);
               Sink_Group := Search_Task_Group_By_Task(A_System.Task_Groups, Sink_Task.name);

               if (Sink_Group.name /= Source_Group.name) then
                  reset_head_iterator (Sink_Group.task_list, Task_List_It);
                  loop
                     current_element (Sink_Group.task_list, A_Task, Task_List_It);

                     add_tail(Source_Group.task_list, A_Task);

                     exit when is_tail_element (Sink_Group.task_list, Task_List_It);
                     next_element (Sink_Group.task_list, Task_List_It);
                  end loop;

                  delete(A_System.Task_Groups, Sink_Group);
               end if;
            end if;

            exit when is_last_element(A_System.Dependencies.Depends, Task_Dependencies_It);
            next_element(A_System.Dependencies.Depends, Task_Dependencies_It);
         end loop;
      end if;


      if not is_empty(A_System.Task_Groups) then
         reset_iterator(A_System.Task_Groups, Task_Groups_It);
         loop
            current_element(A_System.Task_Groups, A_Task_Group, Task_Groups_It);

            if not is_empty(A_Task_Group.task_list) then
               -- Search for r_min (rij = start_time + offset)
               r_min := -1;

               reset_head_iterator (A_Task_Group.task_list, Task_List_It);
               loop
                  current_element (A_Task_Group.task_list, A_Task, Task_List_It);

                  Sij := A_Task.start_time;
                  Oij := 0;
                  if (A_Task.offsets.Nb_Entries > 0) then
                     Oij := A_Task.offsets.entries(0).offset_value;
                  end if;
                  rij := Sij + Oij;

                  if (r_min < 0) then
                     r_min := rij;
                  else
                     r_min := Integer'Min(rij, r_min);
                  end if;

                  exit when is_tail_element (A_Task_Group.task_list, Task_List_It);
                  next_element (A_Task_Group.task_list, Task_List_It);
               end loop;

               -- Loop through task_list to set: rij := Oij + Sij - r_min; Oij := rij; Sij := 0;
               reset_head_iterator (A_Task_Group.task_list, Task_List_It);
               loop
                  current_element (A_Task_Group.task_list, A_Task, Task_List_It);

                  Sij := A_Task.start_time;
                  Oij := 0;
                  if (A_Task.offsets.Nb_Entries > 0) then
                     Oij := A_Task.offsets.entries(0).offset_value;
                  end if;
                  rij := Sij + Oij - r_min;

                  -- Update offset and set start_time to 0
                  A_Task.start_time := 0;
                  if (A_Task.offsets.Nb_Entries > 0) then
                     A_Task.offsets.entries(0).offset_value := rij;
                  else
                     New_Offset              := new Offset_Type;
                     New_Offset.offset_value := rij;
                     New_Offset.activation   := 0;
                     New_Offset_Table        := new Offsets_Table;
                     Offsets_Table_Package.Add (New_Offset_Table.all, New_Offset.all);
                     A_Task.offsets := New_Offset_Table.all;
                  end if;

                  exit when is_tail_element (A_Task_Group.task_list, Task_List_It);
                  next_element (A_Task_Group.task_list, Task_List_It);
               end loop;

               -- Sort task_list by asc offset
               sort(A_Task_Group.task_list, Increasing_Offset'Access);

               exit when is_last_element(A_System.Task_Groups, Task_Groups_It);
               next_element(A_System.Task_Groups, Task_Groups_It);
            end if;
         end loop;

      end if;
   end Merge_Transactions;

   procedure Multiframe_To_Transaction_Sys
     (My_System : in out System; -- Multiframe System
      A_System  : in out System) -- Transaction System
   is
      My_Iterator  : Task_Groups_Iterator;
      A_Task_Group : Generic_Task_Group_Ptr;
      A_Multiframe : Multiframe_Task_Group_Ptr;
   begin
      Initialize (A_System);

      Duplicate (My_System, A_System); -- Clone all entities in My_System to A_System

      reset_iterator (My_System.Task_Groups, My_Iterator);

      loop
         current_element (My_System.Task_Groups, A_Task_Group, My_Iterator);
         A_Multiframe := Multiframe_Task_Group_Ptr (A_Task_Group);

         -- Delete A_Multiframe from A_System (clone) without deleting processors, etc...
         A_Task_Group := Search_Task_Group(A_System.task_groups, A_Multiframe.name);
         delete_task_group(A_System, A_Task_Group, false);

         -- Create Transaction (in A_System) from A_Multiframe (in My_System)
         Multiframe_to_Transaction(A_Multiframe, A_System);

         exit when is_last_element (My_System.Task_Groups, My_Iterator);
         next_element (My_System.Task_Groups, My_Iterator);
      end loop;
   end Multiframe_To_Transaction_Sys;

   procedure Multiframe_To_Transaction_Sys_Crossref
     (My_System : in out System; -- Multiframe System
      A_System  : in out System;
      Merge     : in Boolean := false) -- Transaction System
   is
      My_Iterator  : Task_Groups_Iterator;
      A_Task_Group : Generic_Task_Group_Ptr;
      A_Multiframe : Multiframe_Task_Group_Ptr;
      A_Task_Dependencies_Set: Tasks_Dependencies_Ptr;
   begin
      Initialize (A_System);
      A_Task_Dependencies_Set := new Tasks_Dependencies;

      A_System.Core_units := My_System.Core_units;
      A_System.Processors := My_System.Processors;
      A_System.Resources := My_System.Resources;
      A_System.Messages := My_System.Messages;
      duplicate(My_System.Dependencies, A_Task_Dependencies_Set); -- Need to duplicate so My_System still has the correct dependency pointers
      A_System.Dependencies := A_Task_Dependencies_Set;

      A_System.Buffers := My_System.Buffers;
      A_System.Networks := My_System.Networks;
      A_System.Event_Analyzers := My_System.Event_Analyzers;
      A_System.Address_Spaces := My_System.Address_Spaces;

      reset_iterator (My_System.Task_Groups, My_Iterator);

      loop
         current_element (My_System.Task_Groups, A_Task_Group, My_Iterator);
         A_Multiframe := Multiframe_Task_Group_Ptr (A_Task_Group);

         -- Create Transaction (in A_System) from A_Multiframe (in My_System)
         Multiframe_to_Transaction (A_Multiframe, A_System);

         exit when is_last_element (My_System.Task_Groups, My_Iterator);
         next_element (My_System.Task_Groups, My_Iterator);
      end loop;

      if (Merge) then
         Modify_Offsets(A_System);
         Merge_Transactions(A_System);
      end if;

      -- Entity pointer status after transformation:
      -- Shared: Processors, core_units, resources, messages, buffers, networks, event_analyzers
      -- Duplicates (updated): Task_dependencies
      -- New: Tasks

      -- If we only want updated duplicates and new pointers: Procedure Update_Core(processors_set, my_core) needs to be written
   end Multiframe_To_Transaction_Sys_Crossref;

   procedure Add_Delta_Tasks
     (My_System : in out System)
   is
      function Pred
        (tau_ij : Generic_Task_Ptr)
         return Generic_Task_Ptr
      is
         use Task_Dependencies.Half_Dep_Set;

         pred_ij : Generic_Task_Ptr;

         A_Task_Dependencies_Iterator : Tasks_Dependencies_Iterator;
         A_Half_Dep : Dependency_Ptr;
      begin
         if not is_empty(My_System.Dependencies.Depends) then
            reset_iterator(My_System.Dependencies.Depends, A_Task_Dependencies_Iterator);
            loop
               current_element(My_System.Dependencies.Depends, A_Half_Dep, A_Task_Dependencies_Iterator);

               if A_Half_Dep.type_of_dependency = Precedence_Dependency then
                  if A_Half_Dep.precedence_sink.name = tau_ij.name then
                     pred_ij := A_Half_Dep.precedence_source;
                     return pred_ij;
                  end if;
               end if;

               exit when is_last_element(My_system.Dependencies.Depends, A_Task_Dependencies_Iterator);
               next_element(My_System.Dependencies.Depends, A_Task_Dependencies_Iterator);
            end loop;
         end if;

         return null;
      end Pred;

      function Get_Offset
        (tau : Generic_Task_Ptr)
         return Integer
      is
         New_Offset : Offset_Type_Ptr;

         use Offsets.Offsets_Table_Package;
      begin
         if tau.offsets.nb_entries > 0 then
            for I in 0 .. tau.offsets.nb_entries - 1 loop
               if tau.offsets.entries(I).activation = 0 then
                  return tau.offsets.entries(I).offset_value;
               end if;
            end loop;
         end if;

         New_Offset := new Offset_Type;
         New_Offset.offset_value := 0;
         New_Offset.activation := 0;
         Add(tau.offsets, New_Offset.all);

         return 0;
      end Get_Offset;

      Gamma_iterator : Task_Groups_Iterator;
      Gamma_i : Generic_Task_Group_Ptr;
      tau_ij_iterator : Generic_Task_Iterator;
      tau_ij : Generic_Task_Ptr;
      pred_ij : Generic_Task_Ptr;

      O_pred : Integer;
      C_pred : Integer;
      O_ij : Integer;
      New_Offset : Offset_Type_Ptr;
      New_Offset_Table : Offsets_Table_Ptr;
      deltaTask : Periodic_Task_Ptr;

      I : Integer := 0;
   begin
      reset_iterator(My_System.Task_Groups, Gamma_iterator);
      loop -- Transactions loop
         current_element(My_System.Task_Groups, Gamma_i, Gamma_iterator);

         if not is_empty(Gamma_i.task_list) then
            reset_head_iterator(Gamma_i.task_list, tau_ij_iterator);
            loop
               current_element(Gamma_i.task_list, tau_ij, tau_ij_iterator);

               pred_ij := pred(tau_ij);

               if pred_ij /= null then
                  O_pred := get_offset(pred_ij);
                  C_pred := pred_ij.capacity;
                  O_ij := get_offset(tau_ij);

                  if O_ij > O_pred + C_pred then
                     I := I + 1;

                     deltaTask := new Periodic_Task;
                     deltaTask.name := suppress_space("wcdops_delta" & I'Img);
                     deltaTask.cpu_name := suppress_space("wcdops_delta_cpu" & I'Img);
                     deltaTask.priority := 1;
                     deltaTask.deadline := tau_ij.deadline;
                     deltaTask.capacity := O_ij - O_pred - C_pred;
                     deltaTask.period := Periodic_Task_Ptr(tau_ij).period;
                     deltaTask.jitter := 0;

                     New_Offset              := new Offset_Type;
                     New_Offset.offset_value := O_pred + C_pred;
                     New_Offset.activation   := 0;
                     New_Offset_Table        := new Offsets_Table;
                     Offsets_Table_Package.Add (New_Offset_Table.all, New_Offset.all);

                     deltaTask.offsets := New_Offset_Table.all;

                     --Add(My_System.Tasks, tau_i0);
                     Add(Gamma_i.task_list, Generic_Task_Ptr(deltaTask));
                     Add_One_Task_Dependency_precedence(My_System.Dependencies, pred_ij, Generic_Task_Ptr(deltaTask));
                     Add_One_Task_Dependency_precedence(My_System.Dependencies, Generic_Task_Ptr(deltaTask), tau_ij);
                     Delete_One_Task_Dependency_precedence(My_System.Dependencies, pred_ij, tau_ij);
                  end if;
               end if;

               exit when is_tail_element(Gamma_i.task_list, tau_ij_iterator);
               next_element(Gamma_i.task_list, tau_ij_iterator);
            end loop;
         end if;

         exit when is_last_element(My_System.Task_Groups, Gamma_iterator);
         next_element(My_System.Task_Groups, Gamma_Iterator);
      end loop;
   end Add_Delta_Tasks;

   procedure Delete_Delta_Tasks
     (My_System : in out System)
   is
      Gamma_iterator : Task_Groups_Iterator;
      Gamma_i : Generic_Task_Group_Ptr;
      tau_ij_iterator : Generic_Task_Iterator;
      tau_ij : Generic_Task_Ptr;
      pred_ij : Generic_Task_Ptr;
      succ_ij : Generic_Task_Ptr;

      I : Integer := 0;

      Ghost : constant String := "wcdops";
   begin
      reset_iterator(My_System.Task_Groups, Gamma_iterator);
      loop -- Transactions loop
         current_element(My_System.Task_Groups, Gamma_i, Gamma_iterator);

         if not is_empty(Gamma_i.task_list) then
            reset_head_iterator(Gamma_i.task_list, tau_ij_iterator);
            loop
               current_element(Gamma_i.task_list, tau_ij, tau_ij_iterator);

               if to_string(tau_ij.name)'Length >= Ghost'Length and then to_string(tau_ij.name) (to_string(tau_ij.name)'First .. to_string(tau_ij.name)'First + Ghost'Length - 1) = Ghost then
                  pred_ij := Get_A_Predecessor(My_System.Dependencies, tau_ij);
                  succ_ij := Get_A_Successor(My_System.Dependencies, tau_ij);

                  Delete_One_Task_Dependency_precedence(My_System.Dependencies, pred_ij, tau_ij);
                  Delete_One_Task_Dependency_precedence(My_System.Dependencies, tau_ij, succ_ij);

                  Add_One_Task_Dependency_precedence(My_System.Dependencies, pred_ij, succ_ij);

                  Free(tau_ij);
               end if;

               exit when is_tail_element(Gamma_i.task_list, tau_ij_iterator);
               next_element(Gamma_i.task_list, tau_ij_iterator);
            end loop;
         end if;

         exit when is_last_element(My_System.Task_Groups, Gamma_iterator);
         next_element(My_System.Task_Groups, Gamma_Iterator);
      end loop;
   end Delete_Delta_Tasks;

   procedure Add_Root_Tasks
     (My_System : in out System)
   is
      function Pred
        (tau_ij : Generic_Task_Ptr)
         return Generic_Task_Ptr
      is
         use Task_Dependencies.Half_Dep_Set;

         pred_ij : Generic_Task_Ptr;

         A_Task_Dependencies_Iterator : Tasks_Dependencies_Iterator;
         A_Half_Dep : Dependency_Ptr;
      begin
         if not is_empty(My_System.Dependencies.Depends) then
            reset_iterator(My_System.Dependencies.Depends, A_Task_Dependencies_Iterator);
            loop
               current_element(My_System.Dependencies.Depends, A_Half_Dep, A_Task_Dependencies_Iterator);

               if A_Half_Dep.type_of_dependency = Precedence_Dependency then
                  if A_Half_Dep.precedence_sink.name = tau_ij.name then
                     pred_ij := A_Half_Dep.precedence_source;
                     return pred_ij;
                  end if;
               end if;

               exit when is_last_element(My_system.Dependencies.Depends, A_Task_Dependencies_Iterator);
               next_element(My_System.Dependencies.Depends, A_Task_Dependencies_Iterator);
            end loop;
         end if;

         return null;
      end Pred;

      Gamma_iterator : Task_Groups_Iterator;
      Gamma_i : Generic_Task_Group_Ptr;
      tau_ij_iterator : Generic_Task_Iterator;
      tau_ij : Generic_Task_Ptr;
      pred_ij : Generic_Task_Ptr;

      New_Offset : Offset_Type_Ptr;
      New_Offset_Table : Offsets_Table_Ptr;
      tau_i1 : Periodic_Task_Ptr;

      n_tasks_no_pred : Integer := 0;
   begin
      reset_iterator(My_System.Task_Groups, Gamma_iterator);
      loop -- Transactions loop
         current_element(My_System.Task_Groups, Gamma_i, Gamma_iterator);

         tau_i1 := null;
         n_tasks_no_pred := 0;
         if not is_empty(Gamma_i.task_list) then
            reset_head_iterator(Gamma_i.task_list, tau_ij_iterator);
            loop
               current_element(Gamma_i.task_list, tau_ij, tau_ij_iterator);

               pred_ij := pred(tau_ij);

               if pred_ij = null then
                  n_tasks_no_pred := n_tasks_no_pred + 1;

                  if (n_tasks_no_pred > 1) then
                     if (tau_i1 = null) then
                        tau_i1 := new Periodic_Task;
                        tau_i1.name := Gamma_i.name & suppress_space("_root");
                        tau_i1.cpu_name := Gamma_i.name & suppress_space("_root_cpu");
                        tau_i1.priority := 1;
                        tau_i1.deadline := Integer'Last;
                        tau_i1.capacity := 0;
                        tau_i1.period := Periodic_Task_Ptr(tau_ij).period;
                        tau_i1.jitter := 0;

                        New_Offset              := new Offset_Type;
                        New_Offset.offset_value := 0;
                        New_Offset.activation   := 0;
                        New_Offset_Table        := new Offsets_Table;
                        Offsets_Table_Package.Add (New_Offset_Table.all, New_Offset.all);

                        tau_i1.offsets := New_Offset_Table.all;

                        Add(Gamma_i.task_list, Generic_Task_Ptr(tau_i1));
                     end if;

                     Add_One_Task_Dependency_precedence(My_System.Dependencies, Generic_Task_Ptr(tau_i1), tau_ij);
                  end if;
               end if;

               exit when is_tail_element(Gamma_i.task_list, tau_ij_iterator);
               next_element(Gamma_i.task_list, tau_ij_iterator);
            end loop;
         end if;

         exit when is_last_element(My_System.Task_Groups, Gamma_iterator);
         next_element(My_System.Task_Groups, Gamma_Iterator);
      end loop;
   end Add_Root_Tasks;

end Task_Group_Transformation;
