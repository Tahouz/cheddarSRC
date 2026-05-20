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
-- Frank Singhoff, Lab-STICC UMR CNRS 6285, Universite de Bretagne Occidentale
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
--    $Rev: 5118 $
--    $Date: 2024-08-21 16:52:22 +0200 (mer., 21 août 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with AADL_Config;       use AADL_Config;
with unbounded_strings; use unbounded_strings;
with Text_IO;           use Text_IO;
with Ada.Exceptions;    use Ada.Exceptions;
with Resources;         use Resources;
use Resources.Resource_Accesses;
with translate;     use translate;
with processor_set; use processor_set;
with resource_set;  use resource_set;

package body task_dependencies is


   -------------------------------------------------------
   -- Internal sub-programs
   -------------------------------------------------------


   -- Add a task in the Dependent task list
   -- only if it not already present
   --
   procedure add_dependent_tasks
     (my_dependencies : in out tasks_dependencies_ptr;
      my_task         : in     generic_task_ptr)
   is

      ite1   : tasks_iterator;
      a_task : generic_task_ptr;

   begin

      if not is_empty (my_dependencies.dependent_tasks) then
         reset_iterator (my_dependencies.dependent_tasks, ite1);
         loop
            current_element (my_dependencies.dependent_tasks, a_task, ite1);

            if a_task.name = my_task.name then
               return;
            end if;

            exit when is_last_element (my_dependencies.dependent_tasks, ite1);
            next_element (my_dependencies.dependent_tasks, ite1);
         end loop;
      end if;

      add (my_dependencies.dependent_tasks, my_task);

   end add_dependent_tasks;


   -- Delete a dependent task if it exists
   --
   procedure delete_dependent_tasks
     (my_dependencies : in out tasks_dependencies_ptr;
      my_task         : in     generic_task_ptr)
   is
      ite1         : tasks_iterator;
      a_task       : generic_task_ptr;
      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;
      todelete     : Boolean := True;
   begin
      -- First search in dependencies if the task is not part of another dependency.
      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);
         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            case a_half_dep.type_of_dependency is
               when remote_procedure_call_dependency =>
                  if
                    (a_half_dep.remote_procedure_call_client.name =
                     my_task.name) or
                    (a_half_dep.remote_procedure_call_server.name =
                     my_task.name)
                  then
                     todelete := False;
                  end if;

               when precedence_dependency =>
                  if (a_half_dep.precedence_source.name = my_task.name) or
                    (a_half_dep.precedence_sink.name = my_task.name)
                  then
                     todelete := False;
                  end if;

               when queueing_buffer_dependency =>
                  if
                    (a_half_dep.buffer_dependent_task.name = my_task.name)
                  then
                     todelete := False;
                  end if;

               when asynchronous_communication_dependency =>
                  if
                    (a_half_dep.asynchronous_communication_dependent_task
                       .name =
                     my_task.name)
                  then
                     todelete := False;
                  end if;

               when tdma_communication_dependency =>
                  if
                    (a_half_dep.tdma_communication_dependent_task
                       .name =
                     my_task.name)
                  then
                     todelete := False;
                  end if;

               when time_triggered_communication_dependency =>
                  if
                    (a_half_dep.time_triggered_communication_sink.name =
                     my_task.name)
                  then
                     todelete := False;
                  end if;

               when resource_dependency =>
                  if
                    (a_half_dep.resource_dependency_task.name = my_task.name)
                  then
                     todelete := False;
                  end if;

               when black_board_buffer_dependency =>
                  if
                    (a_half_dep.black_board_dependent_task.name = my_task.name)
                  then
                     todelete := False;
                  end if;
            end case;

            exit when is_last_element (my_dependencies.depends, my_iterator1);
            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      if todelete then
         if not is_empty (my_dependencies.dependent_tasks) then
            reset_iterator (my_dependencies.dependent_tasks, ite1);
            loop
               current_element (my_dependencies.dependent_tasks, a_task, ite1);

               if a_task.name = my_task.name then
                  delete (my_dependencies.dependent_tasks, a_task);
                  return;
               end if;

               exit when is_last_element
                   (my_dependencies.dependent_tasks,
                    ite1);
               next_element (my_dependencies.dependent_tasks, ite1);
            end loop;
         end if;
      end if;

   end delete_dependent_tasks;

   -------------------------------------------------------------------------
   -- Sub-programs required for any type of dependencies
   -------------------------------------------------------------------------

   procedure free (my_dependencies : in out tasks_dependencies_ptr) is
   begin
      free (my_dependencies.dependent_tasks);
      free (my_dependencies.depends);
   end free;

   function xml_root_string
     (obj   : in tasks_dependencies_ptr;
      level : in Natural := 0) return Unbounded_String
   is
   begin
      if (obj /= null) then
         return xml_root_string (obj.depends);
      else
         return empty_string;
      end if;
   end xml_root_string;

   function xml_string
     (obj   : in tasks_dependencies_ptr;
      level : in Natural := 0) return Unbounded_String
   is
   begin
      if (obj /= null) then
         return xml_string (obj.depends);
      else
         return empty_string;
      end if;
   end xml_string;

   function export_aadl_properties
     (my_dependencies : in tasks_dependencies_ptr;
      number_of_ht    : in Natural) return Unbounded_String
   is
      my_iterator     : tasks_dependencies_iterator;
      a_half_dep      : dependency_ptr;
      head_is_written : Boolean := False;

      result : Unbounded_String := empty_string;

   begin

      if Aadl_Export_Precedencies_To_Properties then

         if not is_empty (my_dependencies.depends) then

            reset_iterator (my_dependencies.depends, my_iterator);
            loop
               current_element
                 (my_dependencies.depends,
                  a_half_dep,
                  my_iterator);

               if a_half_dep.type_of_dependency = precedence_dependency then

                  if not head_is_written then
                     for i in 1 .. number_of_ht loop
                        result := result & ASCII.HT;
                     end loop;
                     result :=
                       result &
                       To_Unbounded_String
                         ("Cheddar_Properties::Task_Precedencies => (") &
                       unbounded_lf;
                     head_is_written := True;
                  else
                     result := result & "," & unbounded_lf;
                  end if;

                  for i in 1 .. number_of_ht + 1 loop
                     result := result & ASCII.HT;
                  end loop;
                  result :=
                    result &
                    """" &
                    "instancied_" &
                    a_half_dep.precedence_source.address_space_name &
                    ".instancied_" &
                    a_half_dep.precedence_source.name &
                    """" &
                    ", " &
                    """" &
                    "instancied_" &
                    a_half_dep.precedence_source.address_space_name &
                    ".instancied_" &
                    a_half_dep.precedence_sink.name &
                    """";
               end if;

               exit when is_last_element
                   (my_dependencies.depends,
                    my_iterator);

               next_element (my_dependencies.depends, my_iterator);

            end loop;

            if head_is_written then
               result := result & To_Unbounded_String (");") & unbounded_lf;
            end if;
         end if;

      end if;

      return result;

   end export_aadl_properties;

   procedure duplicate
     (src  : in     tasks_dependencies_ptr;
      dest : in out tasks_dependencies_ptr)
   is

   begin
      duplicate (src.depends, dest.depends);
      duplicate (src.dependent_tasks, dest.dependent_tasks);
   end duplicate;

   procedure reset
     (my_dependencies : in out tasks_dependencies_ptr;
      free_object     : in     Boolean := False)
   is

   begin
      reset (my_dependencies.depends, free_object);
      reset (my_dependencies.dependent_tasks, free_object);
   end reset;

   procedure put (my_dependencies : in tasks_dependencies_ptr) is

   begin
      Put ("Task list/index : ");
      New_Line;
      put (my_dependencies.dependent_tasks);

      Put ("Dependencies : ");
      New_Line;
      put (my_dependencies.depends);
   end put;


   ------------------------------------------------------------------------
   --  Services below allow to add  dependencies.
   ------------------------------------------------------------------------

   -- Add ALL dependencies taken from the definition
   -- of a given buffer
   --
   procedure add_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      my_tasks        : in     tasks_set;
      a_buffer        : in     buffer_ptr)
   is

      task1 : generic_task_ptr;

   begin

      delete_all_task_dependencies (my_dependencies, a_buffer);

      for i in 0 .. a_buffer.roles.nb_entries - 1 loop
         task1 := search_task (my_tasks, a_buffer.roles.entries (i).item);
         if a_buffer.roles.entries (i).data.the_role = queuing_producer then
            add_one_task_dependency_queueing_buffer
              (my_dependencies,
               task1,
               a_buffer,
               from_task_to_object);
         else
            add_one_task_dependency_queueing_buffer
              (my_dependencies,
               task1,
               a_buffer,
               from_object_to_task);
         end if;
      end loop;

   end add_all_task_dependencies;

   -- Add ALL dependencies taken from the definition
   -- of a given resource
   --
   procedure add_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      my_tasks        : in     tasks_set;
      a_resource      : in     generic_resource_ptr)
   is

      task1 : generic_task_ptr;

   begin

      delete_all_task_dependencies (my_dependencies, a_resource);

      for i in 0 .. a_resource.critical_sections.nb_entries - 1 loop
         task1 :=
           search_task
             (my_tasks,
              a_resource.critical_sections.entries (i).item);
         add_one_task_dependency_resource (my_dependencies, task1, a_resource);
      end loop;

   end add_all_task_dependencies;


   --------------------------------------------------------------------
   -- Add ONE dependency (one sub-progream for each type of dependency
   --------------------------------------------------------------------
  
   -- Add a Time_Triggered_Communication constraint between two tasks
   -- (a dependency with a Time_Triggered_Communication_Timing_Property_Type)
   --
   procedure add_one_task_dependency_time_triggered
     (my_dependencies : in out tasks_dependencies_ptr;
      from_task       : in     generic_task_ptr;
      to_task         : in     generic_task_ptr;
      timing_type     : in time_triggered_communication_timing_property_type)
   is
      a_dep_ptr : dependency_ptr;
   begin
      a_dep_ptr := new dependency (time_triggered_communication_dependency);
      a_dep_ptr.time_triggered_communication_source := from_task;
      a_dep_ptr.time_triggered_communication_sink   := to_task;
      a_dep_ptr.time_triggered_timing_property      := timing_type;

      add (my_dependencies.depends, a_dep_ptr);

      add_dependent_tasks (my_dependencies, to_task);
   end add_one_task_dependency_time_triggered;

   -- Add a Resource constraint between a task and a resource
   --
   procedure add_one_task_dependency_resource
     (my_dependencies : in out tasks_dependencies_ptr;
      dependent_task  : in     generic_task_ptr;
      a_resource      : in     generic_resource_ptr)
   is
      a_dep_ptr : dependency_ptr;
   begin
      a_dep_ptr := new dependency (resource_dependency);
      a_dep_ptr.resource_dependency_resource := a_resource;
      a_dep_ptr.resource_dependency_task     := dependent_task;

      add (my_dependencies.depends, a_dep_ptr);

      add_dependent_tasks (my_dependencies, dependent_task);
   end add_one_task_dependency_resource;

   procedure add_one_task_dependency_tdma_communication
     (my_dependencies   : in out tasks_dependencies_ptr;
      a_task            : in     generic_task_ptr;
      a_dep             : in     generic_message_ptr;
      a_type            : in     orientation_dependency_type)

   is

      a_dep_ptr : dependency_ptr;

   begin

      a_dep_ptr := new dependency (tdma_communication_dependency);
      a_dep_ptr.tdma_communication_dependent_task    := a_task;
      a_dep_ptr.tdma_communication_orientation       := a_type;
      a_dep_ptr.tdma_communication_dependency_object := a_dep;

      add (my_dependencies.depends, a_dep_ptr);

      add_dependent_tasks (my_dependencies, a_task);

   end add_one_task_dependency_tdma_communication;

   procedure add_one_task_dependency_asynchronous_communication
     (my_dependencies   : in out tasks_dependencies_ptr;
      a_task            : in     generic_task_ptr;
      a_dep             : in     generic_message_ptr;
      a_type            : in     orientation_dependency_type;
      protocol_property : in asynchronous_communication_protocol_property_type :=
        first_message)

   is

      a_dep_ptr : dependency_ptr;

   begin

      a_dep_ptr := new dependency (asynchronous_communication_dependency);
      a_dep_ptr.asynchronous_communication_dependent_task    := a_task;
      a_dep_ptr.asynchronous_communication_orientation       := a_type;
      a_dep_ptr.asynchronous_communication_dependency_object := a_dep;
      a_dep_ptr.asynchronous_communication_protocol_property :=
        protocol_property;

      add (my_dependencies.depends, a_dep_ptr);

      add_dependent_tasks (my_dependencies, a_task);

   end add_one_task_dependency_asynchronous_communication;

   procedure add_one_task_dependency_queueing_buffer
     (my_dependencies : in out tasks_dependencies_ptr;
      a_task          : in     generic_task_ptr;
      a_dep           : in     buffer_ptr;
      a_type          : in     orientation_dependency_type)
   is

      a_dep_ptr : dependency_ptr;
   begin
      a_dep_ptr := new dependency (queueing_buffer_dependency);
      a_dep_ptr.buffer_dependent_task    := a_task;
      a_dep_ptr.buffer_orientation       := a_type;
      a_dep_ptr.buffer_dependency_object := a_dep;

      add (my_dependencies.depends, a_dep_ptr);

      add_dependent_tasks (my_dependencies, a_task);
   end add_one_task_dependency_queueing_buffer;

   procedure add_one_task_dependency_black_board_buffer
     (my_dependencies : in out tasks_dependencies_ptr;
      a_task          : in     generic_task_ptr;
      a_dep           : in     buffer_ptr;
      a_type          : in     orientation_dependency_type)
   is

      a_dep_ptr : dependency_ptr;
   begin
      a_dep_ptr := new dependency (black_board_buffer_dependency);
      a_dep_ptr.black_board_dependent_task    := a_task;
      a_dep_ptr.black_board_orientation       := a_type;
      a_dep_ptr.black_board_dependency_object := a_dep;

      add (my_dependencies.depends, a_dep_ptr);

      add_dependent_tasks (my_dependencies, a_task);
   end add_one_task_dependency_black_board_buffer;

   procedure add_one_task_dependency_precedence
     (my_dependencies : in out tasks_dependencies_ptr;
      source          : in     generic_task_ptr;
      sink            : in     generic_task_ptr)
   is

      a_dep_ptr : dependency_ptr;
   begin
      a_dep_ptr                   := new dependency (precedence_dependency);
      a_dep_ptr.precedence_source := source;
      a_dep_ptr.precedence_sink   := sink;

      add (my_dependencies.depends, a_dep_ptr);

      add_dependent_tasks (my_dependencies, source);
      add_dependent_tasks (my_dependencies, sink);
   end add_one_task_dependency_precedence;

   procedure add_one_task_dependency_remote_procedure_call
     (my_dependencies : in out tasks_dependencies_ptr;
      client          : in     generic_task_ptr;
      server          : in     generic_task_ptr)
   is

      a_dep_ptr : dependency_ptr;
   begin
      a_dep_ptr := new dependency (remote_procedure_call_dependency);
      a_dep_ptr.remote_procedure_call_client := client;
      a_dep_ptr.remote_procedure_call_server := server;

      add (my_dependencies.depends, a_dep_ptr);

      add_dependent_tasks (my_dependencies, client);
      add_dependent_tasks (my_dependencies, server);
   end add_one_task_dependency_remote_procedure_call;

   ------------------------------------------------------------------
   -- Sub-program to handle buffer dependency
   ------------------------------------------------------------------

   function has_buffer_to_read
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return Boolean
   is
      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = queueing_buffer_dependency then
               if (a_half_dep.buffer_dependent_task.name = my_task.name) and
                 (a_half_dep.buffer_orientation = from_object_to_task)
               then
                  return True;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      return False;

   end has_buffer_to_read;

   function has_buffer_to_write
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return Boolean
   is
      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = queueing_buffer_dependency then
               if (a_half_dep.buffer_dependent_task.name = my_task.name) and
                 (a_half_dep.buffer_orientation = from_task_to_object)
               then
                  return True;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      return False;

   end has_buffer_to_write;

   ------------------------------------------------------------------
   -- Sub-program to handle precedence dependency
   ------------------------------------------------------------------

   function get_a_precedence_successor
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return generic_task_ptr
   is
      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = precedence_dependency then
               if (a_half_dep.precedence_source.name = my_task.name) then
                  return Copy (a_half_dep.precedence_sink);
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      raise dependency_not_found;
      return null;

   end get_a_precedence_successor;

   function get_a_precedence_predecessor
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return generic_task_ptr
   is
      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = precedence_dependency then
               if (a_half_dep.precedence_sink.name = my_task.name) then
                  return Copy (a_half_dep.precedence_source);
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      raise dependency_not_found;
      return null;

   end get_a_precedence_predecessor;

   function has_precedence_predecessor
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return Boolean
   is
      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = precedence_dependency then
               if (a_half_dep.precedence_sink.name = my_task.name) then
                  return True;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      return False;
   end has_precedence_predecessor;

   function has_precedence_successor
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return Boolean
   is
      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = precedence_dependency then
               if (a_half_dep.precedence_source.name = my_task.name) then
                  return True;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      return False;
   end has_precedence_successor;

   function get_precedence_successors_list
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return tasks_set
   is
      result   : tasks_set;
      new_task : generic_task_ptr;

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = precedence_dependency then
               if (a_half_dep.precedence_source.name = my_task.name) then
                  new_task := Copy (a_half_dep.precedence_sink);
                  add (result, new_task);
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      return result;
   end get_precedence_successors_list;

   function get_precedence_predecessors_list
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return tasks_set
   is
      result   : tasks_set;
      new_task : generic_task_ptr;

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = precedence_dependency then
               if (a_half_dep.precedence_sink.name = my_task.name) then
                  new_task := Copy (a_half_dep.precedence_source);
                  add (result, new_task);
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      return result;
   end get_precedence_predecessors_list;


   ------------------------------------------------------------------
   -- Sub-program to handle asynchronous communication dependency
   ------------------------------------------------------------------

   function has_asynchronous_communication_predecessor
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return Boolean
   is
      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency =
              asynchronous_communication_dependency
            then
               if
                 (a_half_dep.asynchronous_communication_orientation =
                  from_object_to_task)
               then
                  if
                    (a_half_dep.asynchronous_communication_dependent_task
                       .name =
                     my_task.name)
                  then
                     return True;
                  end if;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      return False;
   end has_asynchronous_communication_predecessor;

   function get_asynchronous_communication_successors_list
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return tasks_set
   is
      result   : tasks_set;
      new_task : generic_task_ptr;

      my_iterator1, my_iterator2 : tasks_dependencies_iterator;
      a_half_dep, a_half_dep2    : dependency_ptr;

      a_message : generic_message_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency =
              asynchronous_communication_dependency
            then
               if
                 (a_half_dep.asynchronous_communication_dependent_task.name =
                  my_task.name)
               then
                  if
                    (a_half_dep.asynchronous_communication_orientation =
                     from_task_to_object)
                  then

                     a_message :=
                       a_half_dep.asynchronous_communication_dependency_object;
                     reset_iterator (my_dependencies.depends, my_iterator2);

                     loop
                        current_element
                          (my_dependencies.depends,
                           a_half_dep2,
                           my_iterator2);

                        if a_half_dep2.type_of_dependency =
                          asynchronous_communication_dependency
                        then
                           if
                             (a_half_dep2
                                .asynchronous_communication_dependency_object
                                .name =
                              a_message.name)
                           then
                              if
                                (a_half_dep2
                                   .asynchronous_communication_orientation =
                                 from_object_to_task)
                              then

                                 new_task :=
                                   Copy
                                     (a_half_dep2
                                        .asynchronous_communication_dependent_task);
                                 add (result, new_task);

                              end if;
                           end if;
                        end if;

                        exit when is_last_element
                            (my_dependencies.depends,
                             my_iterator2);
                        next_element (my_dependencies.depends, my_iterator2);
                     end loop;

                  end if;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      return result;
   end get_asynchronous_communication_successors_list;

   function get_asynchronous_communication_predecessors_list
     (my_dependencies : in tasks_dependencies_ptr;
      my_task         : in generic_task_ptr) return tasks_set
   is
      result   : tasks_set;
      new_task : generic_task_ptr;

      my_iterator1, my_iterator2 : tasks_dependencies_iterator;
      a_half_dep, a_half_dep2    : dependency_ptr;

      a_message : generic_message_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency =
              asynchronous_communication_dependency
            then
               if
                 (a_half_dep.asynchronous_communication_dependent_task.name =
                  my_task.name)
               then
                  if
                    (a_half_dep.asynchronous_communication_orientation =
                     from_object_to_task)
                  then

                     a_message :=
                       a_half_dep.asynchronous_communication_dependency_object;
                     reset_iterator (my_dependencies.depends, my_iterator2);

                     loop
                        current_element
                          (my_dependencies.depends,
                           a_half_dep2,
                           my_iterator2);

                        if a_half_dep2.type_of_dependency =
                          asynchronous_communication_dependency
                        then
                           if
                             (a_half_dep2
                                .asynchronous_communication_dependency_object
                                .name =
                              a_message.name)
                           then
                              if
                                (a_half_dep2
                                   .asynchronous_communication_orientation =
                                 from_task_to_object)
                              then

                                 new_task :=
                                   Copy
                                     (a_half_dep2
                                        .asynchronous_communication_dependent_task);
                                 add (result, new_task);

                              end if;
                           end if;
                        end if;

                        exit when is_last_element
                            (my_dependencies.depends,
                             my_iterator2);
                        next_element (my_dependencies.depends, my_iterator2);
                     end loop;

                  end if;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      return result;
   end get_asynchronous_communication_predecessors_list;


------------------------------------------------------------------
-- Read subprograms for any dependencies
------------------------------------------------------------------


   function get_a_root_task
     (my_dependencies : in tasks_dependencies_ptr) return generic_task_ptr
   is
      is_root : Boolean;

      my_iterator2 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;
      my_iterator1 : tasks_iterator;
      a_task       : generic_task_ptr;

   begin

      if not is_empty (my_dependencies.dependent_tasks) then

         reset_iterator (my_dependencies.dependent_tasks, my_iterator1);

         loop
            current_element
              (my_dependencies.dependent_tasks,
               a_task,
               my_iterator1);

            reset_iterator (my_dependencies.depends, my_iterator2);

            is_root := True;
            loop
               current_element
                 (my_dependencies.depends,
                  a_half_dep,
                  my_iterator2);

               if a_half_dep.type_of_dependency =
                 queueing_buffer_dependency
               then
                  if (a_half_dep.buffer_orientation = from_object_to_task) and
                    (a_task.name = a_half_dep.buffer_dependent_task.name)
                  then
                     is_root := False;
                  end if;
               end if;

               if a_half_dep.type_of_dependency =
                 asynchronous_communication_dependency
               then
                  if
                    (a_half_dep.asynchronous_communication_orientation =
                     from_object_to_task) and
                    (a_task.name =
                     a_half_dep.asynchronous_communication_dependent_task.name)
                  then
                     is_root := False;
                  end if;
               end if;

               if a_half_dep.type_of_dependency = precedence_dependency then
                  if (a_half_dep.precedence_sink.name = a_task.name) then
                     is_root := False;
                  end if;
               end if;

               exit when is_last_element
                   (my_dependencies.depends,
                    my_iterator2);

               next_element (my_dependencies.depends, my_iterator2);
            end loop;

            if is_root then
               return a_task;
            end if;

            exit when is_last_element
                (my_dependencies.dependent_tasks,
                 my_iterator1);

            next_element (my_dependencies.dependent_tasks, my_iterator1);

         end loop;
      end if;

      raise dependency_not_found;
      return null;
   end get_a_root_task;

   function get_a_leaf_task
     (my_dependencies : in tasks_dependencies_ptr) return generic_task_ptr
   is
      is_leaf : Boolean;

      my_iterator2 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;
      my_iterator1 : tasks_iterator;
      a_task       : generic_task_ptr;

   begin

      if not is_empty (my_dependencies.dependent_tasks) then

         reset_iterator (my_dependencies.dependent_tasks, my_iterator1);

         loop
            current_element
              (my_dependencies.dependent_tasks,
               a_task,
               my_iterator1);

            reset_iterator (my_dependencies.depends, my_iterator2);

            is_leaf := True;
            loop
               current_element
                 (my_dependencies.depends,
                  a_half_dep,
                  my_iterator2);

               if a_half_dep.type_of_dependency =
                 queueing_buffer_dependency
               then
                  if (a_half_dep.buffer_orientation = from_task_to_object) and
                    (a_task.name = a_half_dep.buffer_dependent_task.name)
                  then
                     is_leaf := False;
                  end if;
               end if;

               if a_half_dep.type_of_dependency =
                 asynchronous_communication_dependency
               then
                  if
                    (a_half_dep.asynchronous_communication_orientation =
                     from_task_to_object) and
                    (a_task.name =
                     a_half_dep.asynchronous_communication_dependent_task.name)
                  then
                     is_leaf := False;
                  end if;
               end if;

               if a_half_dep.type_of_dependency = precedence_dependency then
                  if (a_half_dep.precedence_source.name = a_task.name) then
                     is_leaf := False;
                  end if;
               end if;

               exit when is_last_element
                   (my_dependencies.depends,
                    my_iterator2);

               next_element (my_dependencies.depends, my_iterator2);
            end loop;

            if is_leaf then
               return a_task;
            end if;

            exit when is_last_element
                (my_dependencies.dependent_tasks,
                 my_iterator1);

            next_element (my_dependencies.dependent_tasks, my_iterator1);

         end loop;
      end if;

      raise dependency_not_found;
      return null;
   end get_a_leaf_task;

   function get_leaf_tasks
     (my_dependencies : in tasks_dependencies_ptr) return tasks_set
   is
      result   : tasks_set;
      is_leaf  : Boolean;
      new_task : generic_task_ptr;

      my_iterator2 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;
      my_iterator1 : tasks_iterator;
      a_task       : generic_task_ptr;

   begin

      if not is_empty (my_dependencies.dependent_tasks) then

         reset_iterator (my_dependencies.dependent_tasks, my_iterator1);

         loop
            current_element
              (my_dependencies.dependent_tasks,
               a_task,
               my_iterator1);

            reset_iterator (my_dependencies.depends, my_iterator2);
            is_leaf := True;
            loop
               current_element
                 (my_dependencies.depends,
                  a_half_dep,
                  my_iterator2);

               if a_half_dep.type_of_dependency =
                 queueing_buffer_dependency
               then
                  if (a_half_dep.buffer_orientation = from_task_to_object) and
                    (a_task.name = a_half_dep.buffer_dependent_task.name)
                  then
                     is_leaf := False;
                  end if;
               end if;

               if a_half_dep.type_of_dependency =
                 asynchronous_communication_dependency
               then
                  if
                    (a_half_dep.asynchronous_communication_orientation =
                     from_task_to_object) and
                    (a_task.name =
                     a_half_dep.asynchronous_communication_dependent_task.name)
                  then
                     is_leaf := False;
                  end if;
               end if;

               if a_half_dep.type_of_dependency = precedence_dependency then
                  if (a_half_dep.precedence_source.name = a_task.name) then
                     is_leaf := False;
                  end if;
               end if;

               exit when is_last_element
                   (my_dependencies.depends,
                    my_iterator2);

               next_element (my_dependencies.depends, my_iterator2);
            end loop;

            if is_leaf then
               new_task := Copy (a_task);
               add (result, new_task);
            end if;

            exit when is_last_element
                (my_dependencies.dependent_tasks,
                 my_iterator1);

            next_element (my_dependencies.dependent_tasks, my_iterator1);

         end loop;
      end if;
      return result;
   end get_leaf_tasks;

   function get_root_tasks
     (my_dependencies : in tasks_dependencies_ptr) return tasks_set
   is
      result   : tasks_set;
      is_root  : Boolean;
      new_task : generic_task_ptr;

      my_iterator2 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;
      my_iterator1 : tasks_iterator;
      a_task       : generic_task_ptr;

   begin

      if not is_empty (my_dependencies.dependent_tasks) then

         reset_iterator (my_dependencies.dependent_tasks, my_iterator1);

         loop
            current_element
              (my_dependencies.dependent_tasks,
               a_task,
               my_iterator1);

            reset_iterator (my_dependencies.depends, my_iterator2);

            is_root := True;
            loop
               current_element
                 (my_dependencies.depends,
                  a_half_dep,
                  my_iterator2);

               if a_half_dep.type_of_dependency =
                 queueing_buffer_dependency
               then
                  if (a_half_dep.buffer_orientation = from_object_to_task) and
                    (a_task.name = a_half_dep.buffer_dependent_task.name)
                  then
                     is_root := False;
                  end if;
               end if;

               if a_half_dep.type_of_dependency =
                 asynchronous_communication_dependency
               then
                  if
                    (a_half_dep.asynchronous_communication_orientation =
                     from_object_to_task) and
                    (a_task.name =
                     a_half_dep.asynchronous_communication_dependent_task.name)
                  then
                     is_root := False;
                  end if;
               end if;

               if a_half_dep.type_of_dependency = precedence_dependency then
                  if (a_half_dep.precedence_sink.name = a_task.name) then
                     is_root := False;
                  end if;
               end if;

               exit when is_last_element
                   (my_dependencies.depends,
                    my_iterator2);

               next_element (my_dependencies.depends, my_iterator2);
            end loop;

            if is_root then
               new_task := Copy (a_task);
               add (result, new_task);
            end if;

            exit when is_last_element
                (my_dependencies.dependent_tasks,
                 my_iterator1);

            next_element (my_dependencies.dependent_tasks, my_iterator1);

         end loop;
      end if;
      return result;

   end get_root_tasks;

   -------------------------------------------------------------------

   -- Delete ALL dependencies  of an
   -- address space (parameter "An_Address_Space")
   --
   procedure delete_address_space_all_task_dependencies
     (my_dependencies  : in out tasks_dependencies_ptr;
      an_address_space : in     Unbounded_String)
   is

      my_iterator1  : tasks_dependencies_iterator;
      a_half_dep    : dependency_ptr;
      to_be_deleted : half_dep_set.set;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = precedence_dependency then
               if
                 (a_half_dep.precedence_source.address_space_name =
                  an_address_space) or
                 (a_half_dep.precedence_sink.address_space_name =
                  an_address_space)
               then
                  add (to_be_deleted, a_half_dep);
               end if;
            end if;

            if a_half_dep.type_of_dependency = queueing_buffer_dependency then
               if (a_half_dep.buffer_orientation = from_object_to_task) and
                 (an_address_space =
                  a_half_dep.buffer_dependent_task.address_space_name)
               then
                  add (to_be_deleted, a_half_dep);
               end if;
            end if;

            if a_half_dep.type_of_dependency =
              asynchronous_communication_dependency
            then
               if
                 (a_half_dep.asynchronous_communication_orientation =
                  from_object_to_task) and
                 (an_address_space =
                  a_half_dep.asynchronous_communication_dependent_task
                    .address_space_name)
               then
                  add (to_be_deleted, a_half_dep);
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      if not is_empty (to_be_deleted) then
         delete (my_dependencies.depends, to_be_deleted);
      end if;

   end delete_address_space_all_task_dependencies;

   -- Delete ALL dependencies  of a
   -- processor (parameter "A_Processor")
   --
   procedure delete_processor_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_processor     : in     Unbounded_String)
   is

      my_iterator1  : tasks_dependencies_iterator;
      a_half_dep    : dependency_ptr;
      to_be_deleted : half_dep_set.set;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = precedence_dependency then
               if (a_half_dep.precedence_source.cpu_name = a_processor) or
                 (a_half_dep.precedence_sink.cpu_name = a_processor)
               then
                  add (to_be_deleted, a_half_dep);
               end if;
            end if;

            if a_half_dep.type_of_dependency = queueing_buffer_dependency then
               if (a_half_dep.buffer_orientation = from_object_to_task) and
                 (a_processor = a_half_dep.buffer_dependent_task.cpu_name)
               then
                  add (to_be_deleted, a_half_dep);
               end if;
            end if;

            if a_half_dep.type_of_dependency =
              asynchronous_communication_dependency
            then
               if
                 (a_half_dep.asynchronous_communication_orientation =
                  from_object_to_task) and
                 (a_processor =
                  a_half_dep.asynchronous_communication_dependent_task
                    .cpu_name)
               then
                  add (to_be_deleted, a_half_dep);
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      if not is_empty (to_be_deleted) then
         delete (my_dependencies.depends, to_be_deleted);
      end if;

   end delete_processor_all_task_dependencies;

   -- Delete ALL dependencies :
   --  1) of a task (if My_Dep_Name is a Task_ptr)
   --  2) of a message  (if My_Dep_Name is a Message_ptr)
   --  3) of a buffer  (if My_Dep_Name is a Buffer_ptr)
   --
   procedure delete_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_task          : in     generic_task_ptr)
   is

      my_iterator1  : tasks_dependencies_iterator;
      a_half_dep    : dependency_ptr;
      to_be_deleted : half_dep_set.set;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = queueing_buffer_dependency then
               if (a_half_dep.buffer_dependent_task.name = a_task.name) then
                  add (to_be_deleted, a_half_dep);
               end if;
            end if;
            if a_half_dep.type_of_dependency =
              asynchronous_communication_dependency
            then
               if
                 (a_half_dep.asynchronous_communication_dependent_task.name =
                  a_task.name)
               then
                  add (to_be_deleted, a_half_dep);
               end if;
            end if;
            if a_half_dep.type_of_dependency = precedence_dependency then
               if (a_half_dep.precedence_source.name = a_task.name) or
                 (a_half_dep.precedence_sink.name = a_task.name)
               then
                  add (to_be_deleted, a_half_dep);
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      if not is_empty (to_be_deleted) then
         delete (my_dependencies.depends, to_be_deleted);
      end if;

   end delete_all_task_dependencies;

   procedure delete_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_buffer        : in     buffer_ptr)
   is

      my_iterator1  : tasks_dependencies_iterator;
      a_half_dep    : dependency_ptr;
      to_be_deleted : half_dep_set.set;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = queueing_buffer_dependency then
               if
                 (a_half_dep.buffer_dependency_object.name = a_buffer.name)
               then
                  add (to_be_deleted, a_half_dep);
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      if not is_empty (to_be_deleted) then
         delete (my_dependencies.depends, to_be_deleted);
      end if;

   end delete_all_task_dependencies;

   procedure delete_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_message       : in     generic_message_ptr)
   is

      my_iterator1  : tasks_dependencies_iterator;
      a_half_dep    : dependency_ptr;
      to_be_deleted : half_dep_set.set;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency =
              asynchronous_communication_dependency
            then
               if
                 (a_half_dep.asynchronous_communication_dependency_object
                    .name =
                  a_message.name)
               then
                  add (to_be_deleted, a_half_dep);
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      if not is_empty (to_be_deleted) then
         delete (my_dependencies.depends, to_be_deleted);
      end if;

   end delete_all_task_dependencies;

   -- Remove ONE precedence between two tasks
   --
   procedure delete_one_task_dependency_precedence
     (my_dependencies : in out tasks_dependencies_ptr;
      source          : in     generic_task_ptr;
      sink            : in     generic_task_ptr)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = precedence_dependency then

               if (a_half_dep.precedence_source.name = source.name) and
                 (a_half_dep.precedence_sink.name = sink.name)
               then
                  delete (my_dependencies.depends, a_half_dep);
                  delete_dependent_tasks (my_dependencies, source);
                  delete_dependent_tasks (my_dependencies, sink);
                  return;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;
      raise dependency_not_found;
   end delete_one_task_dependency_precedence;

   -- Remove ONE remote procedure call dependency between two tasks
   --
   procedure delete_one_task_dependency_remote_procedure_call
     (my_dependencies : in out tasks_dependencies_ptr;
      client          : in     generic_task_ptr;
      server          : in     generic_task_ptr)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency =
              remote_procedure_call_dependency
            then

               if
                 (a_half_dep.remote_procedure_call_client.name =
                  client.name) and
                 (a_half_dep.remote_procedure_call_server.name = server.name)
               then
                  delete (my_dependencies.depends, a_half_dep);
                  delete_dependent_tasks (my_dependencies, client);
                  delete_dependent_tasks (my_dependencies, server);
                  return;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;
      raise dependency_not_found;
   end delete_one_task_dependency_remote_procedure_call;

   -- Remove ONE time triggered dependency between two tasks
   --
   procedure delete_one_task_dependency_time_triggered
     (my_dependencies : in out tasks_dependencies_ptr;
      source          : in     generic_task_ptr;
      sink            : in     generic_task_ptr;
      timing_type     : in time_triggered_communication_timing_property_type)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency =
              time_triggered_communication_dependency
            then

               if
                 (a_half_dep.time_triggered_communication_source.name =
                  source.name) and
                 (a_half_dep.time_triggered_communication_sink.name =
                  sink.name) and
                 (a_half_dep.time_triggered_timing_property = timing_type)
               then
                  delete (my_dependencies.depends, a_half_dep);
                  delete_dependent_tasks (my_dependencies, source);
                  delete_dependent_tasks (my_dependencies, sink);
                  return;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;
      raise dependency_not_found;
   end delete_one_task_dependency_time_triggered;

   procedure delete_one_task_dependency_black_board_buffer
     (my_dependencies : in out tasks_dependencies_ptr;
      a_task          : in     generic_task_ptr;
      a_dep           : in     buffer_ptr;
      a_type          : in     orientation_dependency_type)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency =
              black_board_buffer_dependency
            then
               if (a_half_dep.buffer_dependent_task.name = a_task.name) and
                 (a_half_dep.buffer_dependency_object.name = a_dep.name) and
                 (a_half_dep.buffer_orientation = a_type)
               then
                  delete (my_dependencies.depends, a_half_dep);
                  return;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      raise dependency_not_found;
   end delete_one_task_dependency_black_board_buffer;

   -- Remove ONE dependency between a task and
   --   a buffer
   --
   procedure delete_one_task_dependency_queueing_buffer
     (my_dependencies : in out tasks_dependencies_ptr;
      a_task          : in     generic_task_ptr;
      a_buffer        : in     buffer_ptr;
      a_type          : in     orientation_dependency_type)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = queueing_buffer_dependency then
               if (a_half_dep.buffer_dependent_task.name = a_task.name) and
                 (a_half_dep.buffer_dependency_object.name = a_buffer.name) and
                 (a_half_dep.buffer_orientation = a_type)
               then
                  delete (my_dependencies.depends, a_half_dep);
                  return;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      raise dependency_not_found;
   end delete_one_task_dependency_queueing_buffer;

   -- Remove ONE dependency between a task and
   --   a message
   --
   procedure delete_one_task_dependency_asynchronous_communication
     (my_dependencies : in out tasks_dependencies_ptr;
      a_task          : in     generic_task_ptr;
      a_message       : in     generic_message_ptr;
      a_type          : in     orientation_dependency_type)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency =
              asynchronous_communication_dependency
            then
               if
                 (a_half_dep.asynchronous_communication_dependent_task.name =
                  a_task.name) and
                 (a_half_dep.asynchronous_communication_dependency_object
                    .name =
                  a_message.name) and
                 (a_half_dep.asynchronous_communication_orientation = a_type)

               then
                  delete (my_dependencies.depends, a_half_dep);
                  return;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      raise dependency_not_found;
   end delete_one_task_dependency_asynchronous_communication;

   procedure delete_one_task_dependency_resource
     (my_dependencies : in out tasks_dependencies_ptr;
      a_task          : in     generic_task_ptr;
      a_resource      : in     generic_resource_ptr)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = resource_dependency then
               if (a_half_dep.resource_dependency_task.name = a_task.name) and
                 (a_half_dep.resource_dependency_resource.name =
                  a_resource.name)
               then
                  delete (my_dependencies.depends, a_half_dep);
                  return;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      raise dependency_not_found;
   end delete_one_task_dependency_resource;

   -------------------------------------------------------------------

   procedure update_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_task          : in     generic_task_ptr)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            case a_half_dep.type_of_dependency is

               when time_triggered_communication_dependency =>
                  if
                    (a_half_dep.time_triggered_communication_source.name =
                     a_task.name)
                  then
                     a_half_dep.time_triggered_communication_source := a_task;
                  end if;
                  if
                    (a_half_dep.time_triggered_communication_sink.name =
                     a_task.name)
                  then
                     a_half_dep.time_triggered_communication_sink := a_task;
                  end if;

               when remote_procedure_call_dependency =>
                  if
                    (a_half_dep.remote_procedure_call_client.name =
                     a_task.name)
                  then
                     a_half_dep.precedence_source := a_task;
                  end if;
                  if
                    (a_half_dep.remote_procedure_call_server.name =
                     a_task.name)
                  then
                     a_half_dep.precedence_sink := a_task;
                  end if;

               when precedence_dependency =>
                  if (a_half_dep.precedence_source.name = a_task.name) then
                     a_half_dep.precedence_source := a_task;
                  end if;
                  if (a_half_dep.precedence_sink.name = a_task.name) then
                     a_half_dep.precedence_sink := a_task;
                  end if;

               when black_board_buffer_dependency =>
                  if
                    (a_half_dep.black_board_dependent_task.name = a_task.name)
                  then
                     a_half_dep.black_board_dependent_task := a_task;
                  end if;
               when queueing_buffer_dependency =>
                  if (a_half_dep.buffer_dependent_task.name = a_task.name) then
                     a_half_dep.buffer_dependent_task := a_task;
                  end if;

               when resource_dependency =>
                  if
                    (a_half_dep.resource_dependency_task.name = a_task.name)
                  then
                     a_half_dep.resource_dependency_task := a_task;
                  end if;

               when tdma_communication_dependency =>
                  if
                    (a_half_dep.tdma_communication_dependent_task
                       .name =
                     a_task.name)
                  then
                     a_half_dep.tdma_communication_dependent_task :=
                       a_task;
                  end if;

               when asynchronous_communication_dependency =>
                  if
                    (a_half_dep.asynchronous_communication_dependent_task
                       .name =
                     a_task.name)
                  then
                     a_half_dep.asynchronous_communication_dependent_task :=
                       a_task;
                  end if;

            end case;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

   end update_all_task_dependencies;

   procedure update_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_buffer        : in     buffer_ptr)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = queueing_buffer_dependency then
               if
                 (a_half_dep.buffer_dependency_object.name = a_buffer.name)
               then
                  a_half_dep.buffer_dependency_object := a_buffer;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

   end update_all_task_dependencies;

   procedure update_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_message       : in     generic_message_ptr)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency =
              asynchronous_communication_dependency
            then
               if
                 (a_half_dep.asynchronous_communication_dependency_object
                    .name =
                  a_message.name)
               then
                  a_half_dep.asynchronous_communication_dependency_object :=
                    a_message;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

   end update_all_task_dependencies;

   -------------------------------------------------------------------

   -- Check is a task dependencies is acyclic or not
   --
   function is_precedence_cyclic
     (my_dependencies : in tasks_dependencies_ptr) return Boolean
   is
   begin
      return not is_precedence_acyclic (my_dependencies);
   end is_precedence_cyclic;

   function is_precedence_acyclic
     (my_dependencies : in tasks_dependencies_ptr) return Boolean
   is
      type tasks_table_range is
        new Integer range 0 .. Framework_Config.Max_Tasks_Dependencies;
      type tasks_table is array (tasks_table_range'range) of generic_task_ptr;

      my_iterator1 : tasks_iterator;
      a_task       : generic_task_ptr;

      -- Stay true until we find a cycle
      --
      result : Boolean := True;

      --  Check backward arrows (cycle detection)
      --
      function has_backward_arrow
        (current, next_of_current : generic_task_ptr;
         number_of_arrows         : tasks_table_range;
         from, to                 : tasks_table) return Boolean
      is
      begin
         for k in 0 .. number_of_arrows - 1 loop
            if (current.name = from (k).name) and
              (next_of_current.name = to (k).name)
            then
               return True;
            end if;
         end loop;
         return False;
      end has_backward_arrow;

      -- Each task of the set has to be inspected
      --
      procedure scan_a_task
        (current          :    generic_task_ptr;
         number_of_arrows : in tasks_table_range;
         from, to         : in tasks_table)
      is

         next            : tasks_set;
         ite             : tasks_iterator;
         next_of_current : generic_task_ptr;

         tmp_to : tasks_table := to;

         tmp_from   : tasks_table                := from;
         tmp_number : constant tasks_table_range := number_of_arrows + 1;

      begin

         if has_precedence_successor (my_dependencies, current) then

            reset (next, False);
            next := get_precedence_successors_list (my_dependencies, current);

            -- Run for each task a cyclicity test
            --
            reset_iterator (next, ite);
            for j in 0 .. get_number_of_elements (next) - 1 loop
               current_element (next, next_of_current, ite);

               -- Memorize that we had check this arrow
               --
               if has_backward_arrow
                   (current,
                    next_of_current,
                    number_of_arrows,
                    from,
                    to)
               then
                  result := False;
               else
                  tmp_from (tmp_number - 1) := current;
                  tmp_to (tmp_number - 1)   := next_of_current;
                  scan_a_task (next_of_current, tmp_number, tmp_from, tmp_to);
               end if;
               next_element (next, ite);
            end loop;
         end if;

      end scan_a_task;

      -- Used to store backward arrows
      --
      from, to : tasks_table;
      m        : tasks_table_range := 0;

   begin

      -- Run for Each task A Cyclicity Test
      --
      if not is_empty (my_dependencies.dependent_tasks) then

         reset_iterator (my_dependencies.dependent_tasks, my_iterator1);

         loop
            current_element
              (my_dependencies.dependent_tasks,
               a_task,
               my_iterator1);

            if result then
               m := 0;
               scan_a_task (a_task, m, from, to);
            end if;

            exit when is_last_element
                (my_dependencies.dependent_tasks,
                 my_iterator1);

            next_element (my_dependencies.dependent_tasks, my_iterator1);

         end loop;
      end if;

      return result;

   end is_precedence_acyclic;

   function is_unique_precedence_dependency
     (my_dependencies : in tasks_dependencies_ptr;
      source_task     :    generic_task_ptr;
      sink_task       : in generic_task_ptr) return Boolean
   is
      my_iterator : tasks_dependencies_iterator;
      a_half_dep  : dependency_ptr;
   begin
      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator);

         loop
            current_element (my_dependencies.depends, a_half_dep, my_iterator);

            if a_half_dep.type_of_dependency = precedence_dependency then
               if
                 (a_half_dep.precedence_sink.name = sink_task.name and
                  a_half_dep.precedence_source.name = source_task.name)
               then
                  return False;
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator);

            next_element (my_dependencies.depends, my_iterator);
         end loop;
      end if;

      return True;
   end is_unique_precedence_dependency;

   -- Checks if creating a precedence dependency will result in a cycle
   -- TODO: Merge with (a)cyclic check
   --
   function no_precedence_dependency_deadlock
     (my_dependencies : in tasks_dependencies_ptr;
      source_task     :    generic_task_ptr;
      sink_task       : in generic_task_ptr) return Boolean
   is
      my_iterator         : tasks_iterator;
      source_predecessors : tasks_set;
      a_task              : generic_task_ptr;
      result              : Boolean;
   begin
      -- Stop condition
      if (source_task.name = sink_task.name) then
         return False;
      end if;

      result := True;

      source_predecessors :=
        get_precedence_predecessors_list (my_dependencies, source_task);

      if (not is_empty (source_predecessors)) then
         reset_iterator (source_predecessors, my_iterator);

         loop
            current_element (source_predecessors, a_task, my_iterator);

            result :=
              no_precedence_dependency_deadlock
                (my_dependencies,
                 a_task,
                 sink_task);

            exit when (is_last_element (source_predecessors, my_iterator)) or
              (result = False);
            next_element (source_predecessors, my_iterator);
         end loop;
      end if;

      return result;
   end no_precedence_dependency_deadlock;

   procedure delete_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_resource      : in     generic_resource_ptr)
   is

      my_iterator1  : tasks_dependencies_iterator;
      a_half_dep    : dependency_ptr;
      to_be_deleted : half_dep_set.set;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if a_half_dep.type_of_dependency = resource_dependency then
               if
                 (a_half_dep.resource_dependency_resource.name =
                  a_resource.name)
               then
                  add (to_be_deleted, a_half_dep);
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

      if not is_empty (to_be_deleted) then
         delete (my_dependencies.depends, to_be_deleted);
      end if;

   end delete_all_task_dependencies;

   procedure update_all_task_dependencies
     (my_dependencies : in out tasks_dependencies_ptr;
      a_resource      : in     generic_resource_ptr)
   is

   begin
      raise Constraint_Error;
   end update_all_task_dependencies;

   -- Search ALL dependencies  related to the
   -- processor "A_Processor"
   --
   procedure check_entity_referencing_processor
     (my_dependencies : in tasks_dependencies_ptr;
      a_processor     : in Unbounded_String)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            case a_half_dep.type_of_dependency is

               when time_triggered_communication_dependency =>
                  if
                    (a_half_dep.time_triggered_communication_sink.cpu_name =
                     a_processor) or
                    (a_half_dep.time_triggered_communication_source.cpu_name =
                     a_processor)
                  then
                     Raise_Exception
                       (processor_set.invalid_parameter'identity,
                        To_String
                          (lb_processor (Current_Language) &
                           " " &
                           a_processor &
                           " : time triggered dependencies " &
                           " : " &
                           lb_entity_referenced_elsewhere (Current_Language)));
                  end if;

               when precedence_dependency =>
                  if (a_half_dep.precedence_source.cpu_name = a_processor) or
                    (a_half_dep.precedence_sink.cpu_name = a_processor)
                  then
                     Raise_Exception
                       (processor_set.invalid_parameter'identity,
                        To_String
                          (lb_processor (Current_Language) &
                           " " &
                           a_processor &
                           " : " &
                           lb_precedencies (Current_Language) &
                           " : " &
                           lb_entity_referenced_elsewhere (Current_Language)));
                  end if;

               when remote_procedure_call_dependency =>
                  if
                    (a_half_dep.remote_procedure_call_client.cpu_name =
                     a_processor) or
                    (a_half_dep.remote_procedure_call_server.cpu_name =
                     a_processor)
                  then
                     Raise_Exception
                       (processor_set.invalid_parameter'identity,
                        To_String
                          (lb_processor (Current_Language) &
                           " " &
                           a_processor &
                           " : remote procedure call : " &
                           lb_entity_referenced_elsewhere (Current_Language)));
                  end if;

               when black_board_buffer_dependency =>
                  if
                    (a_processor =
                     a_half_dep.black_board_dependent_task.cpu_name) or
                    (a_processor =
                     a_half_dep.black_board_dependency_object.cpu_name)
                  then
                     Raise_Exception
                       (processor_set.invalid_parameter'identity,
                        To_String
                          (lb_processor (Current_Language) &
                           " " &
                           a_processor &
                           " : " &
                           lb_buffer (Current_Language) &
                           " : " &
                           lb_entity_referenced_elsewhere (Current_Language)));
                  end if;

               when queueing_buffer_dependency =>
                  if
                    (a_processor =
                     a_half_dep.buffer_dependent_task.cpu_name) or
                    (a_processor =
                     a_half_dep.buffer_dependency_object.cpu_name)
                  then
                     Raise_Exception
                       (processor_set.invalid_parameter'identity,
                        To_String
                          (lb_processor (Current_Language) &
                           " " &
                           a_processor &
                           " : " &
                           lb_buffer (Current_Language) &
                           " : " &
                           lb_entity_referenced_elsewhere (Current_Language)));
                  end if;

               when resource_dependency =>
                  if
                    (a_processor =
                     a_half_dep.resource_dependency_task.cpu_name) or
                    (a_processor =
                     a_half_dep.resource_dependency_resource.cpu_name)
                  then
                     Raise_Exception
                       (processor_set.invalid_parameter'identity,
                        To_String
                          (lb_processor (Current_Language) &
                           " " &
                           a_processor &
                           " : " &
                           lb_resource (Current_Language) &
                           " : " &
                           lb_entity_referenced_elsewhere (Current_Language)));
                  end if;

               when tdma_communication_dependency =>
                  if
                    (a_processor =
                     a_half_dep.tdma_communication_dependent_task
                       .cpu_name)
                  then
                     Raise_Exception
                       (processor_set.invalid_parameter'identity,
                        To_String
                          (lb_processor (Current_Language) &
                           " " &
                           a_processor &
                           " : " &
                           lb_message (Current_Language) &
                           " : " &
                           lb_entity_referenced_elsewhere (Current_Language)));
                  end if;

               when asynchronous_communication_dependency =>
                  if
                    (a_processor =
                     a_half_dep.asynchronous_communication_dependent_task
                       .cpu_name)
                  then
                     Raise_Exception
                       (processor_set.invalid_parameter'identity,
                        To_String
                          (lb_processor (Current_Language) &
                           " " &
                           a_processor &
                           " : " &
                           lb_message (Current_Language) &
                           " : " &
                           lb_entity_referenced_elsewhere (Current_Language)));
                  end if;

            end case;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

   end check_entity_referencing_processor;

   -- Search ALL dependencies  related to the
   -- resource "A_buffer"
   --
   procedure check_entity_referencing_buffer
     (my_dependencies : in tasks_dependencies_ptr;
      a_buffer        : in Unbounded_String)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if
              (a_half_dep.type_of_dependency = queueing_buffer_dependency)
            then
               if (a_buffer = a_half_dep.buffer_dependency_object.name) then
                  Raise_Exception
                    (buffer_set.invalid_parameter'identity,
                     To_String
                       (lb_buffer (Current_Language) &
                        " " &
                        a_buffer &
                        " : " &
                        lb_dependencies (Current_Language) &
                        " : " &
                        lb_entity_referenced_elsewhere (Current_Language)));
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

   end check_entity_referencing_buffer;

   -- Search ALL dependencies  related to the
   -- resource "A_resource"
   --
   procedure check_entity_referencing_resource
     (my_dependencies : in tasks_dependencies_ptr;
      a_resource      : in Unbounded_String)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if (a_half_dep.type_of_dependency = resource_dependency) then
               if
                 (a_resource = a_half_dep.resource_dependency_resource.name)
               then
                  Raise_Exception
                    (resource_set.invalid_parameter'identity,
                     To_String
                       (lb_resource (Current_Language) &
                        " " &
                        a_resource &
                        " : " &
                        lb_dependencies (Current_Language) &
                        " : " &
                        lb_entity_referenced_elsewhere (Current_Language)));
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

   end check_entity_referencing_resource;

   -- Search ALL dependencies  related to the
   -- message 'a_message'
   --
   procedure check_entity_referencing_message
     (my_dependencies : in tasks_dependencies_ptr;
      a_message       : in Unbounded_String)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            if
              (a_half_dep.type_of_dependency =
               asynchronous_communication_dependency)
            then
               if
                 (a_message =
                  a_half_dep.asynchronous_communication_dependent_task.name)
               then
                  Raise_Exception
                    (resource_set.invalid_parameter'identity,
                     To_String
                       (lb_message (Current_Language) &
                        " " &
                        a_message &
                        " : " &
                        lb_dependencies (Current_Language) &
                        " : " &
                        lb_entity_referenced_elsewhere (Current_Language)));
               end if;
            end if;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

   end check_entity_referencing_message;

   -- Search ALL dependencies  related to the
   -- task "A_task"
   --
   procedure check_entity_referencing_task
     (my_dependencies : in tasks_dependencies_ptr;
      a_task          : in Unbounded_String)
   is

      my_iterator1 : tasks_dependencies_iterator;
      a_half_dep   : dependency_ptr;

   begin

      if not is_empty (my_dependencies.depends) then

         reset_iterator (my_dependencies.depends, my_iterator1);

         loop
            current_element
              (my_dependencies.depends,
               a_half_dep,
               my_iterator1);

            case a_half_dep.type_of_dependency is

               when time_triggered_communication_dependency =>
                  if
                    (a_half_dep.time_triggered_communication_sink.name =
                     a_task) or
                    (a_half_dep.time_triggered_communication_source.name =
                     a_task)
                  then
                     Raise_Exception
                       (task_set.invalid_parameter'identity,
                        To_String
                          (lb_task (Current_Language) &
                           " " &
                           a_task &
                           " : time triggered dependencies " &
                           " : " &
                           lb_entity_referenced_elsewhere (Current_Language)));
                  end if;

               when remote_procedure_call_dependency =>
                  if (a_half_dep.remote_procedure_call_client.name = a_task) or
                    (a_half_dep.remote_procedure_call_server.name = a_task)
                  then
                     Raise_Exception
                       (task_set.invalid_parameter'identity,
                        To_String
                          (lb_task (Current_Language) &
                           " " &
                           a_task &
                           " : time triggered dependencies " &
                           " : " &
                           lb_entity_referenced_elsewhere (Current_Language)));
                  end if;

               when precedence_dependency =>
                  if (a_half_dep.precedence_source.name = a_task) or
                    (a_half_dep.precedence_sink.name = a_task)
                  then
                     Raise_Exception
                       (task_set.invalid_parameter'identity,
                        To_String
                          (lb_task (Current_Language) &
                           " " &
                           a_task &
                           " : " &
                           lb_precedencies (Current_Language) &
                           " : " &
                           lb_entity_referenced_elsewhere (Current_Language)));
                  end if;

               when black_board_buffer_dependency =>
                  if (a_task = a_half_dep.black_board_dependent_task.name) then
                     Raise_Exception
                       (task_set.invalid_parameter'identity,
                        To_String
                          (lb_task (Current_Language) &
                           " " &
                           a_task &
                           " : " &
                           lb_buffer (Current_Language) &
                           " : " &
                           lb_entity_referenced_elsewhere (Current_Language)));
                  end if;

               when queueing_buffer_dependency =>
                  if (a_task = a_half_dep.buffer_dependent_task.name) then
                     Raise_Exception
                       (task_set.invalid_parameter'identity,
                        To_String
                          (lb_task (Current_Language) &
                           " " &
                           a_task &
                           " : " &
                           lb_buffer (Current_Language) &
                           " : " &
                           lb_entity_referenced_elsewhere (Current_Language)));
                  end if;

               when resource_dependency =>
                  if (a_task = a_half_dep.resource_dependency_task.name) then
                     Raise_Exception
                       (task_set.invalid_parameter'identity,
                        To_String
                          (lb_task (Current_Language) &
                           " " &
                           a_task &
                           " : " &
                           lb_resource (Current_Language) &
                           " : " &
                           lb_entity_referenced_elsewhere (Current_Language)));
                  end if;

               when asynchronous_communication_dependency =>
                  if
                    (a_task =
                     a_half_dep.asynchronous_communication_dependent_task.name)
                  then
                     Raise_Exception
                       (task_set.invalid_parameter'identity,
                        To_String
                          (lb_task (Current_Language) &
                           " " &
                           a_task &
                           " : " &
                           lb_message (Current_Language) &
                           " : " &
                           lb_entity_referenced_elsewhere (Current_Language)));
                  end if;

               when tdma_communication_dependency =>
                  if
                    (a_task =
                     a_half_dep.tdma_communication_dependent_task.name)
                  then
                     Raise_Exception
                       (task_set.invalid_parameter'identity,
                        To_String
                          (lb_task (Current_Language) &
                           " " &
                           a_task &
                           " : " &
                           lb_message (Current_Language) &
                           " : " &
                           lb_entity_referenced_elsewhere (Current_Language)));
                  end if;

            end case;

            exit when is_last_element (my_dependencies.depends, my_iterator1);

            next_element (my_dependencies.depends, my_iterator1);
         end loop;
      end if;

   end check_entity_referencing_task;

end task_dependencies;
