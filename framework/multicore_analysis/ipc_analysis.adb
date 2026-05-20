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
--    $Rev: 3657 $
--    $Date: 2020-12-13 13:25:49 +0100 (dim., 13 déc. 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with systems;  use systems;
with tasks;    use tasks;
with task_set; use task_set;
use task_set.generic_task_set;
with dependencies;      use dependencies;
with task_dependencies; use task_dependencies;
use task_dependencies.half_dep_set;
with processors;    use processors;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with parameters;          use parameters;
with parameters.extended; use parameters.extended;
use parameters.framework_parameters_table_package;

with framework;                use framework;
with call_framework;           use call_framework;
with call_framework_interface; use call_framework_interface;
use call_framework_interface.framework_response_package;
use call_framework_interface.framework_request_package;
with call_scheduling_framework;         use call_scheduling_framework;
with multiprocessor_services;           use multiprocessor_services;
with multiprocessor_services_interface; use multiprocessor_services_interface;
use multiprocessor_services_interface.scheduling_result_per_processor_package;
with Ada.Containers.Hashed_Maps;
with Ada.Strings.Hash;

with GNAT.Command_Line;
with GNAT.OS_Lib;           use GNAT.OS_Lib;
with debug;                 use debug;
with io_tools;              use io_tools;
with Text_IO;               use Text_IO;
with version;               use version;
with Ada.Exceptions;        use Ada.Exceptions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;

with Buffers;    use Buffers;
with Buffer_set; use Buffer_set;
use Buffers.Buffer_Roles_Package;

with sets;

with Scheduling_Analysis; use Scheduling_Analysis;
with Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with Feasibility_Test; use Feasibility_Test;
--with feasibility_test.periodic_task_worst_case_response_time_fixed_priority;
--use feasibility_test.periodic_task_worst_case_response_time_fixed_priority;

with Scheduler.Fixed_Priority.Hpf; use Scheduler.Fixed_Priority.Hpf;

with feasibility_test.periodic_task_worst_case_response_time;
use feasibility_test.periodic_task_worst_case_response_time;

package body ipc_analysis is

   function Hash_Unbounded
     (Key : Unbounded_String) return Ada.Containers.Hash_Type
   is
   begin
      return Ada.Strings.Hash (To_String (Key));
   end Hash_Unbounded;

   package cpu_spinning_map is new Ada.Containers.Hashed_Maps
     (Key_Type => Unbounded_String, Element_Type => Natural,
      Hash     => Hash_Unbounded, Equivalent_Keys => "=");

   function get
     (a_system : in System; task_name : in Unbounded_String)
      return Generic_task_ptr
   is

      my_iterator : tasks_iterator;
      a_task      : Generic_task_ptr;

   begin

      reset_iterator (a_system.Tasks, my_iterator);
      loop
         current_element (a_system.Tasks, a_task, my_iterator);

         if To_String (a_task.name) = To_String (task_name) then

            return a_task;

         end if;

         exit when is_last_element (a_system.Tasks, my_iterator);
         next_element (a_system.Tasks, my_iterator);
      end loop;

      return null;

   end get;

   function get_dispatcher
     (a_system : in System; the_core_name : in Unbounded_String)
      return Generic_task_ptr
   is

      my_iterator : tasks_iterator;
      a_task      : Generic_task_ptr;

   begin

      --pour chaque tâche du même coeur et de priorité égale ou supérieur ajouter le WCET + temps de spinning
      reset_iterator (a_system.Tasks, my_iterator);
      loop
         current_element (a_system.Tasks, a_task, my_iterator);

         if To_String (get (a_system.Tasks, a_task.name, core_name)) =
           To_String (the_core_name)
         then

            if (To_String (a_task.name)'Length >= 4) then
               if To_String (a_task.name) (1 .. 4) = "disp" then

                  return a_task;

               end if;

            end if;

         end if;

         exit when is_last_element (a_system.Tasks, my_iterator);
         next_element (a_system.Tasks, my_iterator);
      end loop;

      return null;

   end get_dispatcher;

   function get_dispatcher_receiver
     (a_system : in System; the_receiver : in Generic_task_ptr)
      return Generic_task_ptr
   is

      task_core_name : Unbounded_String;

      my_iterator : tasks_iterator;
      a_task      : Generic_task_ptr;

   begin

      task_core_name := get (a_system.Tasks, the_receiver.name, core_name);

      reset_iterator (a_system.Tasks, my_iterator);
      loop
         current_element (a_system.Tasks, a_task, my_iterator);

         if To_String (get (a_system.Tasks, a_task.name, core_name)) =
           To_String (task_core_name)
         then

            if (To_String (a_task.name)'Length >= 4) then

               if To_String (a_task.name) (1 .. 4) = "disp" then
                  if To_String (a_task.name)
                      (To_String (a_task.name)'Length - 1 ..
                           To_String (a_task.name)'Length) =
                    the_receiver.name
                  then

                     return a_task;
                  end if;
               end if;

            end if;

         end if;

         exit when is_last_element (a_system.Tasks, my_iterator);
         next_element (a_system.Tasks, my_iterator);
      end loop;

      return null;

   end get_dispatcher_receiver;

   function get_root_dispatcher
     (a_system : in System; the_dispatcher : in Generic_task_ptr)
      return Generic_task_ptr
   is

      root_dispatcher : Generic_task_ptr;
   begin

      root_dispatcher := the_dispatcher;

      while has_precedence_predecessor (a_system.Dependencies, root_dispatcher)
      loop

         root_dispatcher :=
           get_a_precedence_predecessor
             (a_system.Dependencies, the_dispatcher);

      end loop;

      return root_dispatcher;

   end get_root_dispatcher;

   function get_read_write_delay
     (a_system : in System; the_task : in Generic_task_ptr) return Natural
   is

      my_buffer_iterator : buffers_iterator;
      a_buffer           : buffer_ptr;

   begin

      --pour chaque buffer on récupère le temps d'écriture du sender et on l'ajoute au WSAT
      reset_iterator (a_system.Buffers, my_buffer_iterator);
      loop
         current_element (a_system.Buffers, a_buffer, my_buffer_iterator);

         if To_String (a_buffer.roles.entries (0).item) = the_task.name then

            return a_buffer.roles.entries (0).data.size;

         elsif To_String (a_buffer.roles.entries (1).item) = the_task.name then

            return a_buffer.roles.entries (1).data.size;

         end if;

         exit when is_last_element (a_system.Buffers, my_buffer_iterator);
         next_element (a_system.Buffers, my_buffer_iterator);
      end loop;

      --retour de la valeur
      return 1;

   end get_read_write_delay;

   function get_nb_spinlock
     (a_system : in System; the_dispatcher : in Generic_task_ptr)
      return Natural
   is

      nb_spinlock : Natural := 0;

      my_buffer_iterator : buffers_iterator;
      a_buffer           : buffer_ptr;

   begin

      --pour chaque buffer du système
      reset_iterator (a_system.Buffers, my_buffer_iterator);
      loop
         current_element (a_system.Buffers, a_buffer, my_buffer_iterator);

         --si il est lié \C3  dispatcher alors nb_spinlock +1
         if To_String (a_buffer.roles.entries (0).item) =
           the_dispatcher.name or
           To_String (a_buffer.roles.entries (1).item) = the_dispatcher.name
         then
            nb_spinlock := nb_spinlock + 1;
         end if;

         exit when is_last_element (a_system.Buffers, my_buffer_iterator);
         next_element (a_system.Buffers, my_buffer_iterator);
      end loop;

      --retourner nb_spinlock
      return nb_spinlock;

   end get_nb_spinlock;

   function compute_dispatcher_receiver_BMPT
     (a_system : in System; the_dispatcher : in Generic_task_ptr)
      return Natural
   is

      the_bpmt : Natural := 0;

      dispatcher_period : Natural;

      dispatcher_read_delay : Natural;

      my_buffer_iterator : buffers_iterator;
      a_buffer           : buffer_ptr;

   begin

      dispatcher_period := get (a_system.Tasks, the_dispatcher.name, period);

      --pour chaque buffer du système
      reset_iterator (a_system.Buffers, my_buffer_iterator);
      loop
         current_element (a_system.Buffers, a_buffer, my_buffer_iterator);

         declare

            a_sender_name : Unbounded_String;
            sender_period : Natural;
            find          : Natural := 0;

         begin

            --si il est lié \C3  dispatcher récupérer la tâche sender associé et le temps de lecture du dispatcher
            if To_String (a_buffer.roles.entries (0).item) =
              the_dispatcher.name
            then

               a_sender_name         := a_buffer.roles.entries (1).item;
               dispatcher_read_delay := a_buffer.roles.entries (0).data.size;
               find                  := 1;

            elsif To_String (a_buffer.roles.entries (1).item) =
              the_dispatcher.name
            then

               a_sender_name         := a_buffer.roles.entries (0).item;
               dispatcher_read_delay := a_buffer.roles.entries (1).data.size;
               find                  := 1;

            end if;

            if not (dispatcher_read_delay = 0) and find = 1 then

               --récupérer la période du sender
               sender_period := get (a_system.Tasks, a_sender_name, period);

               --ajouter au bpmt (période du dispatcher / période du sender(arrondi \C3  l'inférieur)) * le temps de lecture du dispatcher
               the_bpmt :=
                 the_bpmt +
                 ((dispatcher_period / sender_period) * dispatcher_read_delay);

               if sender_period <= dispatcher_period and
                 dispatcher_period mod sender_period = 0
               then

                  the_bpmt := the_bpmt - 1;

               end if;

            end if;

         end;

         exit when is_last_element (a_system.Buffers, my_buffer_iterator);
         next_element (a_system.Buffers, my_buffer_iterator);
      end loop;

      --retourner valeur
      return the_bpmt;

   end compute_dispatcher_receiver_BMPT;

   function compute_dispatcher_receiver_BCET
     (a_system : in System; the_dispatcher : in Generic_task_ptr)
      return Natural
   is

      dispatcher_bcet : Natural := 0;

   begin

      --ajouter le bmpt de chaque sous tâche
      dispatcher_bcet :=
        dispatcher_bcet +
        compute_dispatcher_receiver_BMPT (a_system, the_dispatcher);

      --retour de la valeur
      return dispatcher_bcet;

   end compute_dispatcher_receiver_BCET;

   function compute_dispatcher_BCET
     (a_system : in System; the_core_name : in Unbounded_String) return Natural
   is

      the_dispatcher : Generic_task_ptr;

      dispatcher_bcet : Natural := 0;

   begin

      --Récupérer la tâche dispatcher du core the_core_name
      the_dispatcher := get_dispatcher (a_system, the_core_name);
      if the_dispatcher /= null then
         the_dispatcher  := get_root_dispatcher (a_system, the_dispatcher);
         dispatcher_bcet :=
           dispatcher_bcet +
           compute_dispatcher_receiver_bcet (a_system, the_dispatcher);

         while has_precedence_successor (a_system.Dependencies, the_dispatcher)
         loop

            --ajouter le locking de chaque sous tâche
            the_dispatcher :=
              get_a_precedence_successor
                (a_system.Dependencies, the_dispatcher);
            dispatcher_bcet :=
              dispatcher_bcet +
              compute_dispatcher_receiver_bcet (a_system, the_dispatcher);

         end loop;

      end if;

      --retour de la valeur
      return dispatcher_bcet;

   end compute_dispatcher_BCET;

-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------

--Calcul de L_j
   function compute_previous_dispatcher_receiver_delay
     (a_system : in System; the_dispatcher : in Generic_task_ptr)
      return Natural
   is

      a_dispatcher : Generic_task_ptr;

      L : Natural := 0;

   begin

      a_dispatcher := the_dispatcher;

      while has_precedence_predecessor (a_system.Dependencies, a_dispatcher)
      loop

         a_dispatcher :=
           get_a_precedence_predecessor (a_system.Dependencies, a_dispatcher);

         L :=
           L + compute_dispatcher_receiver_WCRT (a_system, a_dispatcher);

      end loop;

      --First dispatcher iteration
      if a_dispatcher /= the_dispatcher then
         L :=
           L + compute_dispatcher_receiver_WCRT (a_system, a_dispatcher);
      end if;

      return L;

   end compute_previous_dispatcher_receiver_delay;

--CHANGER le nom pour WSHT
--ne prends pas en compte différetens taille de messages (dans les expés pas de soucis pour le moment mais \C3  faire)
   function compute_dispatcher_receiver_WMPT
     (a_system : in System; the_dispatcher : in Generic_task_ptr)
      return Natural
   is

      the_wpmt : Natural := 0;

      delay_previous_dispatcher : Natural := 0;

      dispatcher_period : Natural;

      dispatcher_read_delay : Natural := 0;

      my_buffer_iterator : buffers_iterator;
      a_buffer           : buffer_ptr;

   begin

      delay_previous_dispatcher :=
        compute_previous_dispatcher_receiver_delay (a_system, the_dispatcher);

      dispatcher_period := get (a_system.Tasks, the_dispatcher.name, period);

      --pour chaque buffer du système
      reset_iterator (a_system.Buffers, my_buffer_iterator);
      loop
         current_element (a_system.Buffers, a_buffer, my_buffer_iterator);

         declare

            a_sender_name : Unbounded_String;
            sender_period : Natural;

            find : Natural := 0;

         begin

            --si il est lié a  dispatcher récupérer la tâche sender associé et son temps d'écriture
            if To_String (a_buffer.roles.entries (0).item) =
              the_dispatcher.name
            then

               a_sender_name         := a_buffer.roles.entries (1).item;
               dispatcher_read_delay := a_buffer.roles.entries (0).data.size;
               find                  := 1;

            elsif To_String (a_buffer.roles.entries (1).item) =
              the_dispatcher.name
            then

               a_sender_name         := a_buffer.roles.entries (0).item;
               dispatcher_read_delay := a_buffer.roles.entries (1).data.size;
               find                  := 1;

            end if;

            if not (dispatcher_read_delay = 0) and find = 1 then
               --récupérer la période du sender
               sender_period := get (a_system.Tasks, a_sender_name, period);

               --ajouter au wpmt ((période du dispatcher + delay_previous_dispatcher) / période du sender (arrondi au supérieuur)) * le temps de lecture du dispatcher
               the_wpmt :=
                 the_wpmt +
                 ((
                   ((dispatcher_period +
                     delay_previous_dispatcher + 1) +
                    (sender_period - 1)) /
                   sender_period) *
                  dispatcher_read_delay);

            end if;

         end;

         exit when is_last_element (a_system.Buffers, my_buffer_iterator);
         next_element (a_system.Buffers, my_buffer_iterator);
      end loop;

      --retourner valeur
      return the_wpmt;

   end compute_dispatcher_receiver_WMPT;

   function compute_dispatcher_receiver_WCET
     (a_system : in System; the_dispatcher : in Generic_task_ptr)
      return Natural
   is

      dispatcher_wcet : Natural := 0;

   begin

      --ajouter le wmpt de chaque sous tâche

      dispatcher_wcet :=
        dispatcher_wcet +
        compute_dispatcher_receiver_WMPT (a_system, the_dispatcher);

      --retour de la valeur
      return dispatcher_wcet;

   end compute_dispatcher_receiver_WCET;

   function compute_dispatcher_WCET
     (a_system : in System; the_core_name : in Unbounded_String) return Natural
   is

      the_dispatcher : Generic_task_ptr;

      dispatcher_wcet : Natural := 0;

   begin

      --Récupérer la tâche dispatcher du core the_core_name
      the_dispatcher := get_dispatcher (a_system, the_core_name);
      if the_dispatcher /= null then

         the_dispatcher  := get_root_dispatcher (a_system, the_dispatcher);
         dispatcher_wcet :=
           dispatcher_wcet +
           compute_dispatcher_receiver_WCET (a_system, the_dispatcher);

         while has_precedence_successor (a_system.Dependencies, the_dispatcher)
         loop
            the_dispatcher :=
              get_a_precedence_successor
                (a_system.Dependencies, the_dispatcher);

            dispatcher_wcet :=
              dispatcher_wcet +
              compute_dispatcher_receiver_WCET (a_system, the_dispatcher);

         end loop;

      end if;

      --retour de la valeur
      return dispatcher_wcet;

   end compute_dispatcher_WCET;

   function compute_dispatcher_receiver_WSAT
     (a_system : in System; the_dispatcher : in Generic_task_ptr)
      return Natural
   is

      dispatcher_wsat : Natural := 0;

      my_buffer_iterator : buffers_iterator;
      a_buffer           : buffer_ptr;

      sender_post_delay : Natural;
      a_sender          : Generic_Task_Ptr;
      a_sender_cpu      : Unbounded_String;

      mapping_cpu_spinning_delay : cpu_spinning_map.Map;
   begin

      reset_iterator (a_system.Buffers, my_buffer_iterator);
      loop
         current_element (a_system.Buffers, a_buffer, my_buffer_iterator);

         if To_String (a_buffer.roles.entries (0).item) =
           To_String (the_dispatcher.name)
         then

            a_sender := get (a_system, a_buffer.roles.entries (1).item);

            sender_post_delay := a_buffer.roles.entries (1).data.size;

            if dispatcher_wsat < sender_post_delay then
               dispatcher_wsat := sender_post_delay;
            end if;

         elsif To_String (a_buffer.roles.entries (1).item) =
           To_String (the_dispatcher.name)
         then

            a_sender := get (a_system, a_buffer.roles.entries (0).item);

            sender_post_delay := a_buffer.roles.entries (0).data.size;

            if dispatcher_wsat < sender_post_delay then
               dispatcher_wsat := sender_post_delay;
            end if;

         end if;

         exit when is_last_element (a_system.Buffers, my_buffer_iterator);
         next_element (a_system.Buffers, my_buffer_iterator);
      end loop;

      return dispatcher_wsat*2;

   end compute_dispatcher_receiver_WSAT;

   function compute_dispatcher_WSAT
     (a_system : in System; the_core_name : in Unbounded_String) return Natural
   is

      the_dispatcher : Generic_task_ptr;

      dispatcher_wsat : Natural := 0;

   begin

      --Récupérer la tâche dispatcher du core the_core_name
      the_dispatcher := get_dispatcher (a_system, the_core_name);
      if the_dispatcher /= null then
         the_dispatcher := get_root_dispatcher (a_system, the_dispatcher);

         while has_precedence_successor (a_system.Dependencies, the_dispatcher)
         loop

            --ajouter le locking de chaque sous tâche
            dispatcher_wsat :=
              dispatcher_wsat +
              compute_dispatcher_receiver_wsat (a_system, the_dispatcher);

            the_dispatcher :=
              get_a_precedence_successor
                (a_system.Dependencies, the_dispatcher);
         end loop;

      end if;

      dispatcher_wsat :=
        dispatcher_wsat +
        compute_dispatcher_receiver_wsat (a_system, the_dispatcher);

      return dispatcher_wsat;

   end compute_dispatcher_WSAT;

   function compute_dispatcher_receiver_WCRT
     (a_system : in System; the_dispatcher : in Generic_task_ptr)
      return Natural
   is

      dispatcher_wcrt : Natural := 0;

   begin

      dispatcher_wcrt :=
        dispatcher_wcrt +
        compute_dispatcher_receiver_WCET (a_system, the_dispatcher) +
        compute_dispatcher_receiver_WSAT (a_system, the_dispatcher);

      return dispatcher_wcrt;

   end compute_dispatcher_receiver_WCRT;

   function compute_dispatcher_BCRT
     (a_system : in System; the_core_name : in Unbounded_String) return Natural
   is

      dispatcher_bcrt : Natural;

   begin

      --Récupérer le BCET du coeur
      dispatcher_bcrt := compute_dispatcher_BCET (a_system, the_core_name);

      --retourner la valeur
      return dispatcher_bcrt;

   end compute_dispatcher_BCRT;

   function compute_dispatcher_WCRT
     (a_system : in System; the_core_name : in Unbounded_String) return Natural
   is

      the_dispatcher : Generic_task_ptr;

      dispatcher_wcrt : Natural := 0;

   begin

      the_dispatcher := get_dispatcher (a_system, the_core_name);

      if the_dispatcher /= null then

         the_dispatcher := get_root_dispatcher (a_system, the_dispatcher);

         dispatcher_wcrt :=
           dispatcher_wcrt +
           compute_dispatcher_receiver_WCRT (a_system, the_dispatcher);

         while has_precedence_successor (a_system.Dependencies, the_dispatcher)
         loop
            the_dispatcher :=
              get_a_precedence_successor
                (a_system.Dependencies, the_dispatcher);

            dispatcher_wcrt :=
              dispatcher_wcrt +
              compute_dispatcher_receiver_WCRT (a_system, the_dispatcher);

         end loop;

      end if;

      return dispatcher_wcrt;

   end compute_dispatcher_WCRT;

   function compute_dispatcher_WSHT
     (a_system : in System; the_core_name : in Unbounded_String) return Natural
   is

      the_dispatcher : Generic_task_ptr;

      dispatcher_wsht : Natural := 0;

   begin

      --Récupérer la tâche dispatcher du core the_core_name
      the_dispatcher := get_dispatcher (a_system, the_core_name);
      if the_dispatcher /= null then
         the_dispatcher  := get_root_dispatcher (a_system, the_dispatcher);
         dispatcher_wsht :=
           compute_dispatcher_receiver_WCET (a_system, the_dispatcher);

         while has_precedence_successor (a_system.Dependencies, the_dispatcher)
         loop
            the_dispatcher :=
              get_a_precedence_successor
                (a_system.Dependencies, the_dispatcher);
            --ajouter le locking de chaque sous tâche

            dispatcher_wsht :=
              dispatcher_wsht +
              compute_dispatcher_receiver_WCET (a_system, the_dispatcher);

         end loop;

      end if;

      --retour de la valeur
      return dispatcher_wsht;
   end compute_dispatcher_WSHT;

   function compute_dispatcher_BSHT
     (a_system : in System; the_core_name : in Unbounded_String) return Natural
   is

      the_dispatcher : Generic_task_ptr;

      dispatcher_bsht : Natural := 0;

   begin

      --Récupérer la tâche dispatcher du core the_core_name
      the_dispatcher := get_dispatcher (a_system, the_core_name);
      if the_dispatcher /= null then
         the_dispatcher  := get_root_dispatcher (a_system, the_dispatcher);
         dispatcher_bsht :=
           compute_dispatcher_receiver_BCET (a_system, the_dispatcher);

         while has_precedence_successor (a_system.Dependencies, the_dispatcher)
         loop
            the_dispatcher :=
              get_a_precedence_successor
                (a_system.Dependencies, the_dispatcher);
            --ajouter le locking de chaque sous tâche

            dispatcher_bsht :=
              dispatcher_bsht +
              compute_dispatcher_receiver_BCET (a_system, the_dispatcher);

         end loop;

      end if;

      --retour de la valeur
      return dispatcher_bsht;
   end compute_dispatcher_BSHT;

---------------------------------------------
----------SENDER TASK------------------------
---------------------------------------------
   function get_sender_dispatcher_core_destination
     (a_system : in System; the_task : in Generic_task_ptr)
      return Generic_task_ptr
   is

      my_buffer_iterator : buffers_iterator;
      a_buffer           : buffer_ptr;

   begin

      reset_iterator (a_system.Buffers, my_buffer_iterator);
      loop
         current_element (a_system.Buffers, a_buffer, my_buffer_iterator);

         if To_String (a_buffer.roles.entries (1).item) = the_task.name then

            return get (a_system, a_buffer.roles.entries (0).item);

         elsif To_String (a_buffer.roles.entries (0).item) = the_task.name then

            return get (a_system, a_buffer.roles.entries (1).item);

         end if;

         exit when is_last_element (a_system.Buffers, my_buffer_iterator);
         next_element (a_system.Buffers, my_buffer_iterator);
      end loop;

      return null;

   end get_sender_dispatcher_core_destination;

   function get_hp_tasks
     (a_system : in System; the_task : in Generic_task_ptr) return Tasks_set
   is

      hp_tasks_set : Tasks_set;

      the_task_core_name     : Unbounded_String;
      the_task_core_priority : Natural;

      a_task_core_name     : Unbounded_String;
      a_task_core_priority : Natural;

      my_iterator : tasks_iterator;
      a_task      : Generic_task_ptr;

   begin

      the_task_core_name     := get (a_system.Tasks, the_task.name, core_name);
      the_task_core_priority := get (a_system.Tasks, the_task.name, priority);

      reset_iterator (a_system.Tasks, my_iterator);
      loop
         current_element (a_system.Tasks, a_task, my_iterator);

         a_task_core_name     := get (a_system.Tasks, a_task.name, core_name);
         a_task_core_priority := get (a_system.Tasks, a_task.name, priority);
         if a_task /= the_task and the_task_core_name = a_task_core_name and
           the_task_core_priority >= a_task_core_priority
         then
            Put_line ("ajout de " & TO_STRING (a_task.name));
            Add (hp_tasks_set, a_task);

         end if;

         exit when is_last_element (a_system.Tasks, my_iterator);
         next_element (a_system.Tasks, my_iterator);
      end loop;

      return hp_tasks_set;

   end get_hp_tasks;

   function compute_sender_WSAT
     (a_system : in System; the_sender : in Generic_task_ptr) return Natural
   is

      hp_tasks_set : Tasks_set;

      my_iterator : tasks_iterator;

	sender_deadline : Natural;

      a_task          : Generic_task_ptr;
      a_task_capacity : Natural;
      a_task_period   : Natural;

      the_dispatcher        : Generic_task_ptr;
      the_dispatcher_wcrt   : Natural;
      the_dispatcher_period : Natural;

      sender_wsat     : Natural := 0;
      new_sender_wsat : Natural := 0;

   begin

      hp_tasks_set := get_hp_tasks (a_system, the_sender);

      the_dispatcher :=
        get_sender_dispatcher_core_destination (a_system, the_sender);

      the_dispatcher_wcrt :=
        compute_dispatcher_receiver_WCRT (a_system, the_dispatcher);
      the_dispatcher_period :=
        get (a_system.Tasks, the_dispatcher.name, period);

	sender_deadline := get (a_system.Tasks, the_sender.name, deadline);

      sender_wsat     := 1;
      new_sender_wsat := sender_wsat;

      Put_Line
        (To_String (the_dispatcher.name) & "==>" & the_dispatcher_wcrt'Image);
      loop

         sender_wsat := new_sender_wsat;

         new_sender_wsat := 1;

         if not Is_Empty (hp_tasks_set) then

            reset_iterator (hp_tasks_set, my_iterator);
            loop
               current_element (hp_tasks_set, a_task, my_iterator);

               Put_Line
                 (TO_STRING (a_task.name) & " more prio than " &
                  TO_STRING (the_sender.name));

               a_task_capacity := get (a_system.Tasks, a_task.name, capacity);
               a_task_period   := get (a_system.Tasks, a_task.name, period);

               new_sender_wsat :=
                 new_sender_wsat +
                 (((sender_wsat + (a_task_period - 1)) / a_task_period) *
                  a_task_capacity);

               exit when is_last_element (hp_tasks_set, my_iterator);
               next_element (hp_tasks_set, my_iterator);
            end loop;

            Put_Line (new_sender_wsat'Image);

         end if;

         new_sender_wsat :=
           new_sender_wsat +
           (((sender_wsat + (the_dispatcher_period - 1)) /
             the_dispatcher_period) *
            the_dispatcher_wcrt);

         exit when new_sender_wsat = sender_wsat or sender_deadline < new_sender_wsat;
      end loop;

      sender_wsat := new_sender_wsat;

      return sender_wsat;

   end compute_sender_WSAT;

   function compute_task_WCET
     (a_system : in System; the_task : in Generic_task_ptr) return Natural
   is
   begin

      --retourner le compute time
      return get (a_system.Tasks, the_task.name, capacity);

   end compute_task_WCET;

   --Joseph & Pandya method
   function compute_hp_tasks
     (a_system : in System; the_task : in Generic_task_ptr) return Natural
   is

      hp_tasks_set : Tasks_set;

      my_iterator : tasks_iterator;
      a_task      : Generic_task_ptr;

      a_task_capacity : Natural;
      a_task_period   : Natural;
      
      the_task_deadline : Natural;

      reponse_time     : Natural := 0;
      new_reponse_time : Natural := 0;

   begin

      hp_tasks_set := get_hp_tasks (a_system, the_task);

      reponse_time     := get (a_system.Tasks, the_task.name, capacity);
      new_reponse_time := reponse_time;

	the_task_deadline := get (a_system.Tasks, the_task.name, deadline);

      loop

         reponse_time := new_reponse_time;

         new_reponse_time := get (a_system.Tasks, the_task.name, capacity);

         if not Is_Empty (hp_tasks_set) then

            reset_iterator (hp_tasks_set, my_iterator);
            loop
               current_element (hp_tasks_set, a_task, my_iterator);

               a_task_capacity :=
                 get (a_system.Tasks, the_task.name, capacity);
               a_task_period := get (a_system.Tasks, the_task.name, period);

               new_reponse_time :=
                 new_reponse_time +
                 (((reponse_time + (a_task_period - 1)) / a_task_period) *
                  a_task_capacity);

               exit when is_last_element (hp_tasks_set, my_iterator);
               next_element (hp_tasks_set, my_iterator);
            end loop;

         end if;

         exit when new_reponse_time = reponse_time or new_reponse_time > the_task_deadline;
      end loop;

      reponse_time := new_reponse_time;

      Put_Line
        (TO_STRING (the_task.name) & " compute_hp_task=" & reponse_time'Image);

      return reponse_time;

   end compute_hp_tasks;

   --Joseph & Pandya method adapted
   function compute_hp_and_dispatcher_tasks
     (a_system : in System; the_task : in Generic_task_ptr) return Natural
   is

      hp_tasks_set : Tasks_set;
      
      the_task_deadline : Natural;

      my_iterator : tasks_iterator;

      a_task          : Generic_task_ptr;
      a_task_capacity : Natural;
      a_task_period   : Natural;

      the_dispatcher        : Generic_task_ptr;
      the_dispatcher_wcrt   : Natural;
      the_dispatcher_period : Natural;

      reponse_time     : Natural := 0;
      new_reponse_time : Natural := 0;

   begin

      hp_tasks_set := get_hp_tasks (a_system, the_task);

      the_dispatcher :=
        get_sender_dispatcher_core_destination (a_system, the_task);

      the_dispatcher_wcrt :=
        compute_dispatcher_receiver_WCRT (a_system, the_dispatcher);
      the_dispatcher_period :=
        get (a_system.Tasks, the_dispatcher.name, period);

	the_task_deadline := get (a_system.Tasks, the_task.name, deadline);

      reponse_time     := get (a_system.Tasks, the_task.name, capacity);
      new_reponse_time := reponse_time;

      Put_Line
        (To_String (the_dispatcher.name) & "==>" & the_dispatcher_wcrt'Image);
      loop

         reponse_time := new_reponse_time;

         new_reponse_time := get (a_system.Tasks, the_task.name, capacity);

         if not Is_Empty (hp_tasks_set) then

            reset_iterator (hp_tasks_set, my_iterator);
            loop
               current_element (hp_tasks_set, a_task, my_iterator);

               Put_Line
                 (TO_STRING (a_task.name) & " more prio than " &
                  TO_STRING (the_task.name));

               a_task_capacity := get (a_system.Tasks, a_task.name, capacity);
               a_task_period   := get (a_system.Tasks, a_task.name, period);

               new_reponse_time :=
                 new_reponse_time +
                 (((reponse_time + (a_task_period - 1)) / a_task_period) *
                  a_task_capacity);

               exit when is_last_element (hp_tasks_set, my_iterator);
               next_element (hp_tasks_set, my_iterator);
            end loop;

            Put_Line (new_reponse_time'Image);

         end if;

         new_reponse_time :=
           new_reponse_time +
           (((reponse_time + (the_dispatcher_period - 1)) /
             the_dispatcher_period) *
            the_dispatcher_wcrt);

         exit when new_reponse_time = reponse_time or new_reponse_time > the_task_deadline;
      end loop;

      reponse_time := new_reponse_time;

      return reponse_time;

   end compute_hp_and_dispatcher_tasks;

   function compute_sender_BCET
     (a_system : in System; the_sender : in Generic_task_ptr) return Natural
   is
   begin

      --retourner le compute time/2
      return (get (a_system.Tasks, the_sender.name, capacity) + (2 - 1)) / 2;

   end compute_sender_BCET;

   function compute_sender_BCRT
     (a_system : in System; the_sender : in Generic_task_ptr) return Natural
   is

      sender_bcrt : Natural;

   begin

      --récupérer le BCET
      sender_bcrt := compute_sender_BCET (a_system, the_sender);

      --retour de la valeur
      return sender_bcrt;

   end compute_sender_BCRT;

   function compute_sender_WCRT
     (a_system : in System; the_sender : in Generic_task_ptr) return Natural
   is

      sender_wcrt : Natural;

   begin

      --Ajouter le temps d'exécution des tâche de priorité supérieur et du dispatcher tu coeur vers lequel il émet
      sender_wcrt := compute_hp_and_dispatcher_tasks (a_system, the_sender);

      --retour de la valeur
      return sender_wcrt;

   end compute_sender_WCRT;

---------------------------------------------
----------RECEIVER TASK----------------------
---------------------------------------------

   function compute_receiver_BCET
     (a_system : in System; the_receiver : in Generic_task_ptr) return Natural
   is

   begin

      --retourne la valeur de compute time/2
      return get (a_system.Tasks, the_receiver.name, capacity) / 2;

   end compute_receiver_BCET;

   function compute_receiver_WCET
     (a_system : in System; the_receiver : in Generic_task_ptr) return Natural
   is

   begin

      --retourne la valeur de compute time
      return get (a_system.Tasks, the_receiver.name, capacity);

   end compute_receiver_WCET;

   function compute_receiver_BCRT
     (a_system : in System; the_receiver : in Generic_task_ptr) return Natural
   is

      receiver_bcrt : Natural;

   begin

      --récupérer le BCET
      receiver_bcrt := compute_receiver_BCET (a_system, the_receiver);

      --retour de la valeur
      return receiver_bcrt;

   end compute_receiver_BCRT;

   function compute_receiver_WCRT
     (a_system : in System; the_receiver : in Generic_task_ptr) return Natural
   is

      receiver_wcrt : Natural;

   begin

      --Ajouter le temps d'exécution des tâche plus prioritaire
      receiver_wcrt := compute_hp_tasks (a_system, the_receiver);

      --retourner la valeur
      return receiver_wcrt;

   end compute_receiver_WCRT;

---------------------------------------------
----------INTER-CORE LATENCY-----------------
---------------------------------------------

   function compute_dispatcher_receiver_BCRT
     (a_system : in System; the_dispatcher : in Generic_task_ptr)
      return Natural
   is
   begin

      --retour de la valeur
      return compute_dispatcher_receiver_BCET (a_system, the_dispatcher);

   end compute_dispatcher_receiver_BCRT;

   function compute_BICL
     (a_system   : in System; the_receiver : in Generic_task_ptr;
      the_sender : in Generic_task_ptr) return Natural
   is

      bicl : Natural;

   begin



         bicl := 2 * get_read_write_delay (a_system, the_sender);


      return bicl;

   end compute_BICL;




   function compute_WICL
     (a_system     : in System; the_sender : in Generic_task_ptr;
      the_receiver : in Generic_task_ptr) return Natural
   is

      the_dispatcher          : Generic_task_ptr;
      the_dispatcher_period   : Natural;
      
      
      wicl : Natural;


   begin


	the_dispatcher := get_dispatcher_receiver(a_system, the_receiver);
	the_dispatcher_period := get(a_system.Tasks, the_dispatcher.name, period);

        wicl := compute_sender_WSAT(a_system, the_sender) + the_dispatcher_period + compute_previous_dispatcher_receiver_delay(a_system, the_dispatcher) + compute_dispatcher_receiver_wcrt(a_system, the_receiver);

      return wicl;

   end compute_WICL;

end ipc_analysis;
