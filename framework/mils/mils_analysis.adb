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

with Ada.Text_IO;           use Ada.Text_IO;
with systems;               use systems;
with Dependencies;          use Dependencies;
with task_dependencies;     use task_dependencies;
with task_dependencies;     use task_dependencies.half_dep_set;
with Tasks;                 use Tasks;
with task_set;              use task_set;
with message_set;           use message_set;
with Messages;              use Messages;
with MILS_Security;         use MILS_Security;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with debug;                 use debug;
with sets;

package body mils_analysis is

   --   num_tasks: Tasks_Range:=0;

   function bell_lapadula (sys : system) return tasks_dependencies_ptr is
      my_iterator        : tasks_dependencies_iterator;
      dep_ptr            : dependency_ptr;
      my_dependencies    : tasks_dependencies_ptr;
      risky_dependencies : tasks_dependencies_ptr;
   begin

      risky_dependencies := new tasks_dependencies;
      my_dependencies    := sys.dependencies;

      if is_empty (my_dependencies.depends) then
         --           return 0;
         Put_Line ("NO dependencies");
         return risky_dependencies;
      else
         reset_iterator (my_dependencies.depends, my_iterator);
         loop
            current_element (my_dependencies.depends, dep_ptr, my_iterator);
            if
              (dep_ptr.type_of_dependency =
               asynchronous_communication_dependency)
            then
               if
                 ((dep_ptr.asynchronous_communication_dependent_task
                     .mils_task /=
                   downgrader) and
                  (dep_ptr.asynchronous_communication_dependent_task
                     .mils_task /=
                   upgrader))
               then

                  if
                    ((dep_ptr.asynchronous_communication_dependent_task
                        .mils_confidentiality_level <
                      dep_ptr.asynchronous_communication_dependency_object
                        .mils_confidentiality_level) and
                     ((dep_ptr.asynchronous_communication_orientation =
                       from_object_to_task) or
                      (dep_ptr.asynchronous_communication_orientation =
                       from_object_to_task)))
                  then
                     add_one_task_dependency_asynchronous_communication
                       (my_dependencies => risky_dependencies,
                        a_task          =>
                          dep_ptr.asynchronous_communication_dependent_task,
                        a_dep =>
                          dep_ptr.asynchronous_communication_dependency_object,
                        a_type =>
                          dep_ptr.asynchronous_communication_orientation,
                        protocol_property => first_message);
                  elsif
                    ((dep_ptr.asynchronous_communication_dependency_object
                        .mils_confidentiality_level <
                      dep_ptr.asynchronous_communication_dependent_task
                        .mils_confidentiality_level) and
                     (dep_ptr.asynchronous_communication_orientation =
                      from_task_to_object))
                  then
                     add_one_task_dependency_asynchronous_communication
                       (my_dependencies => risky_dependencies,
                        a_task          =>
                          dep_ptr.asynchronous_communication_dependent_task,
                        a_dep =>
                          dep_ptr.asynchronous_communication_dependency_object,
                        a_type =>
                          dep_ptr.asynchronous_communication_orientation,
                        protocol_property => first_message);
                  end if;
               end if;

            elsif (dep_ptr.type_of_dependency = precedence_dependency) then
               if
                 (dep_ptr.precedence_sink.mils_confidentiality_level <
                  dep_ptr.precedence_source.mils_confidentiality_level)
               then
                  if
                    ((dep_ptr.precedence_source.mils_task /= downgrader) and
                     (dep_ptr.precedence_source.mils_task /= upgrader) and
                     (dep_ptr.precedence_sink.mils_task /= downgrader) and
                     (dep_ptr.precedence_sink.mils_task /= upgrader))
                  then

                     add_one_task_dependency_precedence
                       (my_dependencies => risky_dependencies,
                        source          => dep_ptr.precedence_source,
                        sink            => dep_ptr.precedence_sink);
                  end if;
               end if;

            end if;
            exit when is_last_element (my_dependencies.depends, my_iterator);
            next_element (my_dependencies.depends, my_iterator);
         end loop;
         return risky_dependencies;
      end if;
   end bell_lapadula;

   function bell_lapadula (sys : system) return Integer is
      my_dependencies : tasks_dependencies_ptr;
   begin
      my_dependencies := bell_lapadula (sys);
      if is_empty (my_dependencies.depends) then
         return 0;
      else
         return Integer (get_number_of_elements (my_dependencies.depends));
      end if;
   end bell_lapadula;

   function bell_lapadula (sys : system) return Boolean is
      nb_violations : Integer := bell_lapadula (sys);
   begin
      put_debug
        ("Number of bell_lapadula rules violations :" & nb_violations'img);
      if (nb_violations = 0) then
         return True;
      else
         return False;
      end if;

   end bell_lapadula;

   function biba (sys : system) return tasks_dependencies_ptr is
      my_iterator        : tasks_dependencies_iterator;
      dep_ptr            : dependency_ptr;
      my_dependencies    : tasks_dependencies_ptr;
      risky_dependencies : tasks_dependencies_ptr;
   begin

      risky_dependencies := new tasks_dependencies;
      my_dependencies    := sys.dependencies;

      if is_empty (my_dependencies.depends) then
         --           return 0;
         Put_Line ("NO dependencies");
         return risky_dependencies;
      else
         reset_iterator (my_dependencies.depends, my_iterator);
         loop
            current_element (my_dependencies.depends, dep_ptr, my_iterator);

            if
              (dep_ptr.type_of_dependency =
               asynchronous_communication_dependency)
            then

               if
                 ((dep_ptr.asynchronous_communication_dependent_task
                     .mils_task /=
                   downgrader) and
                  (dep_ptr.asynchronous_communication_dependent_task
                     .mils_task /=
                   upgrader))
               then

                  if
                    ((dep_ptr.asynchronous_communication_dependency_object
                        .mils_integrity_level <
                      dep_ptr.asynchronous_communication_dependent_task
                        .mils_integrity_level) and
                     (dep_ptr.asynchronous_communication_orientation =
                      from_object_to_task))
                  then
                     add_one_task_dependency_asynchronous_communication
                       (my_dependencies => risky_dependencies,
                        a_task          =>
                          dep_ptr.asynchronous_communication_dependent_task,
                        a_dep =>
                          dep_ptr.asynchronous_communication_dependency_object,
                        a_type =>
                          dep_ptr.asynchronous_communication_orientation,
                        protocol_property => first_message);
                  elsif
                    ((dep_ptr.asynchronous_communication_dependent_task
                        .mils_integrity_level <
                      dep_ptr.asynchronous_communication_dependency_object
                        .mils_integrity_level) and
                     (dep_ptr.asynchronous_communication_orientation =
                      from_task_to_object))
                  then
                     add_one_task_dependency_asynchronous_communication
                       (my_dependencies => risky_dependencies,
                        a_task          =>
                          dep_ptr.asynchronous_communication_dependent_task,
                        a_dep =>
                          dep_ptr.asynchronous_communication_dependency_object,
                        a_type =>
                          dep_ptr.asynchronous_communication_orientation,
                        protocol_property => first_message);
                  end if;
               end if;

            elsif
              (dep_ptr.type_of_dependency = remote_procedure_call_dependency)
            then
               if
                 ((dep_ptr.remote_procedure_call_server.mils_task /=
                   downgrader) and
                  (dep_ptr.remote_procedure_call_server.mils_task /=
                   upgrader) and
                  (dep_ptr.remote_procedure_call_client.mils_task /=
                   downgrader) and
                  (dep_ptr.remote_procedure_call_client.mils_task /= upgrader))
               then

                  if
                    (dep_ptr.remote_procedure_call_server
                       .mils_integrity_level <
                     dep_ptr.remote_procedure_call_client.mils_integrity_level)
                  then

                     add_one_task_dependency_remote_procedure_call
                       (my_dependencies => risky_dependencies,
                        client => dep_ptr.remote_procedure_call_client,
                        server => dep_ptr.remote_procedure_call_server);
                  end if;
               end if;

            elsif (dep_ptr.type_of_dependency = precedence_dependency) then
               if
                 (dep_ptr.precedence_source.mils_integrity_level <
                  dep_ptr.precedence_sink.mils_integrity_level)
               then
                  if
                    ((dep_ptr.precedence_source.mils_task /= downgrader) and
                     (dep_ptr.precedence_source.mils_task /= upgrader) and
                     (dep_ptr.precedence_sink.mils_task /= downgrader) and
                     (dep_ptr.precedence_sink.mils_task /= upgrader))
                  then
                     add_one_task_dependency_precedence
                       (my_dependencies => risky_dependencies,
                        source          => dep_ptr.precedence_source,
                        sink            => dep_ptr.precedence_sink);
                  end if;
               end if;
            end if;
            exit when is_last_element (my_dependencies.depends, my_iterator);
            next_element (my_dependencies.depends, my_iterator);
         end loop;
         return risky_dependencies;
      end if;

   end biba;

   function biba (sys : system) return Integer is
      my_dependencies : tasks_dependencies_ptr;
   begin
      my_dependencies := biba (sys);
      if is_empty (my_dependencies.depends) then
         return 0;
      else
         return Integer (get_number_of_elements (my_dependencies.depends));
      end if;
   end biba;

   function biba (sys : system) return Boolean is
      nb_violations : Integer := biba (sys);
   begin
      put_debug ("Number of Biba rules violations :" & nb_violations'img);
      if (nb_violations = 0) then
         return True;
      else
         return False;
      end if;

   end biba;

   procedure warshall (sys : system; m : in out matrice) is
      my_iterator      : tasks_dependencies_iterator;
      my_iterator1     : tasks_dependencies_iterator;
      dep_ptr          : dependency_ptr;
      dep_ptr1         : dependency_ptr;
      my_dependencies  : tasks_dependencies_ptr;
      my_dependencies2 : tasks_dependencies_ptr;
      num_tasks        : tasks_range := 0;

   begin
      for i in 1 .. Max_Tasks loop
         for j in 1 .. Max_Tasks loop
            m (i, j) := 0;
         end loop;
      end loop;
      num_tasks :=
        get_number_of_task_from_processor
          (my_tasks       => sys.tasks,
           processor_name => To_Unbounded_String ("Processor"));
      my_dependencies := sys.dependencies;
      reset_iterator (my_dependencies.depends, my_iterator);
      loop
         current_element (my_dependencies.depends, dep_ptr, my_iterator);
         if
           (dep_ptr.type_of_dependency = asynchronous_communication_dependency)
         then
            if
              (dep_ptr.asynchronous_communication_orientation =
               from_task_to_object)
            then
               my_dependencies2 := sys.dependencies;
               reset_iterator (my_dependencies2.depends, my_iterator1);
               loop
                  current_element
                    (my_dependencies2.depends,
                     dep_ptr1,
                     my_iterator1);
                  if
                    (dep_ptr1.type_of_dependency =
                     asynchronous_communication_dependency)
                  then
                     if
                       ((dep_ptr.asynchronous_communication_dependency_object
                           .name =
                         dep_ptr1.asynchronous_communication_dependency_object
                           .name) and
                        (dep_ptr1.asynchronous_communication_orientation =
                         from_object_to_task))
                     then
                        m (Integer'value
                             (To_String
                                (dep_ptr
                                   .asynchronous_communication_dependent_task
                                   .name)),
                           Integer'value
                             (To_String
                                (dep_ptr1
                                   .asynchronous_communication_dependent_task
                                   .name))) :=
                          1;

                     end if;
                  end if;
                  exit when is_last_element
                      (my_dependencies2.depends,
                       my_iterator1);
                  next_element (my_dependencies2.depends, my_iterator1);
               end loop;
            end if;
         elsif
           (dep_ptr.type_of_dependency = remote_procedure_call_dependency)
         then
            m (Integer'value
                 (To_String (dep_ptr.remote_procedure_call_server.name)),
               Integer'value
                 (To_String (dep_ptr.remote_procedure_call_client.name))) :=
              1;

         elsif (dep_ptr.type_of_dependency = precedence_dependency) then
            m (Integer'value (To_String (dep_ptr.precedence_source.name)),
               Integer'value (To_String (dep_ptr.precedence_sink.name))) :=
              1;

         elsif (dep_ptr.type_of_dependency = queueing_buffer_dependency) then
            if (dep_ptr.buffer_orientation = from_task_to_object) then
               my_dependencies2 := sys.dependencies;
               reset_iterator (my_dependencies2.depends, my_iterator1);
               loop
                  current_element
                    (my_dependencies2.depends,
                     dep_ptr1,
                     my_iterator1);
                  if
                    (dep_ptr1.type_of_dependency = queueing_buffer_dependency)
                  then
                     if
                       ((dep_ptr.buffer_dependency_object.name =
                         dep_ptr1.buffer_dependency_object.name) and
                        (dep_ptr1.buffer_orientation = from_object_to_task))
                     then
                        m (Integer'value
                             (To_String (dep_ptr.buffer_dependent_task.name)),
                           Integer'value
                             (To_String
                                (dep_ptr1.buffer_dependent_task.name))) :=
                          1;
                     end if;
                  end if;
                  exit when is_last_element
                      (my_dependencies2.depends,
                       my_iterator1);
                  next_element (my_dependencies2.depends, my_iterator1);
               end loop;
            end if;
         end if;
         exit when is_last_element (my_dependencies.depends, my_iterator);
         next_element (my_dependencies.depends, my_iterator);
      end loop;
      for a in 1 .. Natural (num_tasks) loop
         for i in 1 .. Natural (num_tasks) loop
            for j in 1 .. Natural (num_tasks) loop
               for k in 1 .. Natural (num_tasks) loop
                  if (m (i, k) * m (k, j) = 1) then
                     m (i, j) := 1;
                  end if;
               end loop;
            end loop;
         end loop;
      end loop;

   end warshall;

   function chinese_wall
     (sys  :        system;
      cois :        array_tasks_set;
      m    : in out matrice) return Integer
   is
      my_coi_tasks  : tasks_set;
      tasks_ptr     : generic_task_ptr;
      tasks_ptr1    : generic_task_ptr;
      my_iterator   : tasks_iterator;
      my_iterator1  : tasks_iterator;
      num_tasks     : tasks_range := 0;
      nb_violations : Integer     := 0;
   begin
      warshall (sys, m);
      num_tasks :=
        get_number_of_task_from_processor
          (my_tasks       => sys.tasks,
           processor_name => To_Unbounded_String ("Processor"));
      Put_Line ("Tasks_Number " & num_tasks'img);
      for i in 1 .. Natural (num_tasks) loop
         for j in 1 .. Natural (num_tasks) loop
            Put_Line (" " & m (i, j)'img);
         end loop;
      end loop;
      for i in cois'range loop
         my_coi_tasks := cois (i);
         reset_iterator (cois (i), my_iterator);
         loop
            current_element (cois (i), tasks_ptr, my_iterator);
            reset_iterator (my_coi_tasks, my_iterator1);
            loop
               current_element (my_coi_tasks, tasks_ptr1, my_iterator1);
               if
                 ((tasks_ptr.name /= tasks_ptr1.name) and
                  (m (Integer'value (To_String (tasks_ptr.name)),
                      Integer'value (To_String (tasks_ptr1.name))) =
                   1))
               then
                  nb_violations := nb_violations + 1;
               end if;
               exit when is_last_element (my_coi_tasks, my_iterator1);
               next_element (my_coi_tasks, my_iterator1);
            end loop;
            exit when is_last_element (cois (i), my_iterator);
            next_element (cois (i), my_iterator);
         end loop;
      end loop;
      return nb_violations;
   end chinese_wall;

   function chinese_wall
     (sys  : system;
      cois : array_tasks_set) return Boolean
   is

      i : Integer := 0;
      m : matrice;
   begin

      i := chinese_wall (sys, cois, m);
      put_debug ("Number of chinese_wall violations:" & i'img);
      if (i = 0) then
         return True;
      else
         return False;
      end if;

   end chinese_wall;

end mils_analysis;
