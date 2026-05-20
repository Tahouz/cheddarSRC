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
--    $Rev: 4589 $
--    $Date: 2023-09-29 16:02:19 +0200 (ven., 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Strings.Maps;    use Ada.Strings.Maps;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;    use Ada.Text_IO;

with Sax.Readers;    use Sax.Readers;
with Sax.Exceptions; use Sax.Exceptions;
with Sax.Locators;   use Sax.Locators;
with Sax.Attributes; use Sax.Attributes;
with Unicode.CES;    use Unicode.CES;
with Unicode;        use Unicode;

with Offsets;        use Offsets;
use Offsets.Offsets_Table_Package;
with Parameters; use Parameters;
use Parameters.User_Defined_Parameters_Table_Package;
with strings;               use strings;
with unbounded_strings;     use unbounded_strings;
with Dependencies;          use Dependencies;
with Resources;             use Resources;
use Resources.Resource_Accesses;
with resource_set; use resource_set;
use resource_set.generic_resource_set;
with Messages;    use Messages;
with message_set; use message_set;
use message_set.generic_message_set;
with event_analyzer_set; use event_analyzer_set;
use event_analyzer_set.generic_event_analyzer_set;
with Tasks;    use Tasks;
with task_set; use task_set;
use task_set.generic_task_set;
with address_space_set; use address_space_set;
use address_space_set.generic_address_space_set;
with Buffers; use Buffers;
use Buffers.Buffer_Roles_Package;
with buffer_set; use buffer_set;
use buffer_set.generic_buffer_set;
with Processors; use Processors;
with Core_Units; use Core_Units;
use Core_Units.Core_Units_Table_Package;
with Queueing_Systems; use Queueing_Systems;
with time_unit_events; use time_unit_events;
use time_unit_events.time_unit_package;
with Scheduling_Analysis; use Scheduling_Analysis;
with Scheduler_Interface; use Scheduler_Interface;
with task_dependencies;   use task_dependencies;
with network_set;         use network_set;
with Networks;            use Networks;
with Objects;             use Objects;
with Memories;            use Memories;
use Memories.Memories_Table_Package;
with Framework_Config; use Framework_Config;


package body v2_xml_parsers is

   -------------------------------------------------------------
   -------------------------------------------------------------
   --    Generic XML parser
   -------------------------------------------------------------
   -------------------------------------------------------------

   -- Status information (store parameters of each tag)
   --
   current_parameter      : Integer;
   max_xml_tag_parameters : constant Natural := 10000;
   parameter_list : array (1 .. max_xml_tag_parameters) of Unbounded_String;

   procedure characters
     (handler : in out xml_generic_parser;
      ch      :        Unicode.CES.byte_sequence)
   is

      -- A pair of index objects to keep track of the beginning and
      -- ending of the tokens isolated from the string
      --
      first            : Natural;
      last             : Positive;
      index            : Positive;
      find_first_space : Boolean;

      -- A character set consisting of the "whitespace" characters
      -- that separate the tokens:
      --
      whitespace : constant Ada.Strings.Maps.Character_Set :=
        Ada.Strings.Maps.To_Set (" ");

      -- The string to split
      --
      the_line : Unbounded_String;

   begin

      -- suppress extra blank and unprintable characters before splitting
      --parameters
      --
      find_first_space := False;
      index            := ch'first;
      while index <= ch'last loop

         if (ch (index) /= ASCII.CR) and
           (ch (index) /= ASCII.LF) and
           (ch (index) /= ASCII.HT)
         then
            if (ch (index) = ' ') then
               if (not find_first_space) then
                  the_line := the_line & ch (index);
               end if;
               find_first_space := True;
            else
               the_line         := the_line & ch (index);
               find_first_space := False;
            end if;
         end if;

         index := index + 1;
      end loop;

      -- Remove blank in the beginnning/end of the string
      --
      if Slice (the_line, 1, 1) = " " then
         the_line :=
           To_Unbounded_String (Slice (the_line, 2, Length (the_line)));
      end if;
      if Slice (the_line, Length (the_line), Length (the_line)) = " " then
         the_line :=
           To_Unbounded_String (Slice (the_line, 1, Length (the_line) - 1));
      end if;

      -- Split parameters
      --
      loop
         Find_Token
           (the_line,
            Set   => whitespace,
            Test  => Ada.Strings.Outside,
            First => first,
            Last  => last);

         parameter_list (current_parameter) :=
           To_Unbounded_String (Slice (the_line, first, last));
         current_parameter := current_parameter + 1;

         the_line :=
           To_Unbounded_String (Slice (the_line, last + 1, Length (the_line)));

         exit when Length (the_line) = 0;

      end loop;

   end characters;

   procedure warning
     (handler : in out xml_generic_parser;
      except  :        Sax.Exceptions.sax_parse_exception'class)
   is
   begin
      Put_Line
        ("Xml warning (" &
           Get_Message (except) &
           ", at " &
           To_String (Get_Location (except)) &
        ')');
   end warning;

   procedure error
     (handler : in out xml_generic_parser;
      except  :        Sax.Exceptions.sax_parse_exception'class)
   is
   begin
      Put_Line
        ("Xml parser error (" &
           Get_Message (except) &
           ", at " &
           To_String (Get_Location (except)) &
        ')');
   end error;

   procedure fatal_error
     (handler : in out xml_generic_parser;
      except  :        Sax.Exceptions.sax_parse_exception'class)
   is
   begin
      Put_Line ("Xml parser fatal error (" & Get_Message (except) & ')');
      Fatal_Error (reader (handler), except);
   end fatal_error;

   -------------------------------------------------------------
   -------------------------------------------------------------
   --    XML project file parser
   -------------------------------------------------------------
   -------------------------------------------------------------

   -- Information retrieved from the xml parser
   --
   name                    : Unbounded_String;
   x, y                    : Natural;
   deadline                : Integer;
   start_time              : Integer;
   blocking_time           : Integer;
   state                   : Integer;
   address                 : Integer;
   period                  : Integer;
   context_switch_overhead : Integer;
   every                   : Integer;
   criticality             : Integer;
   capacity                : Integer;
   cpu_name                : Unbounded_String;
   address_space_name      : Unbounded_String;
   allocation_description  : Unbounded_String;
   jitter                  : Natural;
   policy                  : policies;
   task_type               : tasks_type;
   parametric_rule         : Unbounded_String;
   automaton_name          : Unbounded_String;
   seed                    : Integer;
   predictable             : Boolean;
   quantum                 : Integer;
   priority                : Integer;
   priority_assignment     : priority_assignment_type;
   a_scheduler             : schedulers_type;
   a_network               : Unbounded_String;
   a_core                  : core_unit_ptr;
   size                    : Natural;
   protocol                : resources_type;
   is_preemptive           : preemptives_type;
   file_name               : Unbounded_String;
   response_time           : Natural;
   communication_time      : Natural;
   a_qs                    : queueing_systems_type;
   empty_mem               : memories_table;

   text_memory_size          : Integer;
   text_memory_start_address : Integer;
   heap_memory_size          : Integer;
   data_memory_size          : Integer;
   stack_memory_size         : Integer;

   roles  : buffer_roles_table;
   a_role : buffer_role;

   offset   : offsets_table;
   a_offset : offset_type;

   a_task_lists_entry : critical_section;
   a_task_lists       : resource_accesses_table;

   param   : user_defined_parameters_table;
   a_param : parameter_ptr;

   --ne pas oublier de gerer ceci des que le name passe ..
   resource_entities : generic_objects_set;
   consumer_entities : generic_objects_set;

   from_type : Unbounded_String;
   to_type   : Unbounded_String;

   ok : Boolean;

   -- Initialize all data
   --
   procedure initialize_project_parser (handler : in out xml_project_parser) is
   begin

      current_parameter := 1;

      x                       := 0;
      y                       := 0;
      state                   := 0;
      address                 := 0;
      task_type               := aperiodic_type;
      parametric_rule         := To_Unbounded_String ("");
      automaton_name          := To_Unbounded_String ("");
      seed                    := 0;
      predictable             := True;
      priority                := 1;
      priority_assignment     := automatic_assignment;
      name                    := To_Unbounded_String ("");
      deadline                := 0;
      criticality             := 0;
      period                  := 0;
      context_switch_overhead := 0;
      every                   := 0;
      protocol                := no_protocol;

      cpu_name               := To_Unbounded_String ("");
      address_space_name     := To_Unbounded_String ("");
      allocation_description := To_Unbounded_String ("");
      jitter                 := 0;
      initialize (offset);
      initialize (param);
      quantum       := 0;
      a_scheduler   := no_scheduling_protocol;
      a_network     := To_Unbounded_String ("");
      is_preemptive := preemptive;
      file_name     := To_Unbounded_String ("");
      size          := 0;
      initialize (roles);
      a_role.the_role := queuing_consumer;
      Initialize (a_task_lists_entry);
      initialize (a_task_lists);
      text_memory_size  := 0;
      heap_memory_size  := 0;
      data_memory_size  := 0;
      stack_memory_size := 0;
      a_qs              := qs_mm1;
   end initialize_project_parser;

   procedure start_document (handler : in out xml_project_parser) is
   begin
      initialize_project_parser (handler);
      initialize (handler.parsed_system);
   end start_document;

   procedure start_element
     (handler       : in out xml_project_parser;
      namespace_uri :        Unicode.CES.byte_sequence := "";
      local_name    :        Unicode.CES.byte_sequence := "";
      qname         :        Unicode.CES.byte_sequence := "";
      atts          :        Sax.Attributes.attributes'class)
   is
   begin

      current_parameter := 1;

      -- Store attributes
      --
      if Get_Length (atts) > 0 then

         if qname = "scheduler" then

            for j in 0 .. Get_Length (atts) - 1 loop

               if Get_Qname (atts, j) = "quantum" then
                  to_integer (Get_Value (atts, j), quantum, ok);
                  if not ok then
                     Put_Line
                       ("Warning : Error on data type. From " &
                          To_String (handler.locator));
                  end if;
               end if;

               if Get_Qname (atts, j) = "is_preemptive" then
                  To_Preemptives_Type (Get_Value (atts, j), is_preemptive, ok);
                  if not ok then
                     Put_Line
                       ("Warning : Error on data type. From " &
                          To_String (handler.locator));
                  end if;
               end if;

               if Get_Qname (atts, j) = "parametric_file_name" then
                  file_name := To_Unbounded_String (Get_Value (atts, j));
               end if;

               if Get_Qname (atts, j) = "automaton_name" then
                  automaton_name := To_Unbounded_String (Get_Value (atts, j));
               end if;

            end loop;

         else
            if qname = "task" then

               for j in 0 .. Get_Length (atts) - 1 loop

                  if Get_Qname (atts, j) = "task_type" then
                     To_Tasks_Type (Get_Value (atts, j), task_type, ok);
                     if not ok then
                        Put_Line
                          ("Warning : Error on data type. From " &
                             To_String (handler.locator));
                     end if;
                  end if;

                  if Get_Qname (atts, j) = "x" then
                     to_natural (Get_Value (atts, j), x, ok);
                     if not ok then
                        Put_Line
                          ("Warning : Error on data type. From " &
                             To_String (handler.locator));
                     end if;
                  end if;

                  if Get_Qname (atts, j) = "y" then
                     to_natural (Get_Value (atts, j), y, ok);
                     if not ok then
                        Put_Line
                          ("Warning : Error on data type. From " &
                             To_String (handler.locator));
                     end if;
                  end if;
               end loop;

            else
               if qname = "event_analyzer" then

                  for j in 0 .. Get_Length (atts) - 1 loop

                     if Get_Qname (atts, j) = "parametric_file_name" then
                        file_name := To_Unbounded_String (Get_Value (atts, j));
                     end if;

                  end loop;

               else
                  if qname = "buffer" then

                     for j in 0 .. Get_Length (atts) - 1 loop

                        if Get_Qname (atts, j) = "x" then
                           to_natural (Get_Value (atts, j), x, ok);
                           if not ok then
                              Put_Line
                                ("Warning : Error on data type. From " &
                                   To_String (handler.locator));
                           end if;
                        end if;

                        if Get_Qname (atts, j) = "y" then
                           to_natural (Get_Value (atts, j), y, ok);
                           if not ok then
                              Put_Line
                                ("Warning : Error on data type. From " &
                                   To_String (handler.locator));
                           end if;
                        end if;

                     end loop;

                  else
                     if qname = "message" then

                        for j in 0 .. Get_Length (atts) - 1 loop

                           if Get_Qname (atts, j) = "x" then
                              to_natural (Get_Value (atts, j), x, ok);
                              if not ok then
                                 Put_Line
                                   ("Warning : Error on data type. From " &
                                      To_String (handler.locator));
                              end if;
                           end if;

                           if Get_Qname (atts, j) = "y" then
                              to_natural (Get_Value (atts, j), y, ok);
                              if not ok then
                                 Put_Line
                                   ("Warning : Error on data type. From " &
                                      To_String (handler.locator));
                              end if;
                           end if;

                        end loop;

                     else
                        if qname = "buffer_user" then

                           for j in 0 .. Get_Length (atts) - 1 loop

                              if Get_Qname (atts, j) = "buffer_role" then
                                 if (Get_Value (atts, j) /= "consumer") and
                                   (Get_Value (atts, j) /= "producer")
                                 then
                                    Put_Line
                                      ("Warning : Error on data type. From " &
                                         To_String (handler.locator));
                                 end if;
                                 if Get_Value (atts, j) = "consumer" then
                                    a_role.the_role := queuing_consumer;
                                 else
                                    a_role.the_role := queuing_producer;
                                 end if;
                              end if;

                           end loop;

                        else
                           if qname = "parameter" then

                              for j in 0 .. Get_Length (atts) - 1 loop

                                 if Get_Qname (atts, j) = "parameter_type" then

                                    if (Get_Value (atts, j) /= "integer") and
                                      (Get_Value (atts, j) /= "double") and
                                      (Get_Value (atts, j) /= "string") and
                                      (Get_Value (atts, j) /= "boolean")
                                    then
                                       Put_Line
                                         ("Warning : Error on data type. From " &
                                            To_String (handler.locator));
                                    end if;

                                    if Get_Value (atts, j) = "integer" then
                                       a_param :=
                                         new parameter (integer_parameter);
                                    end if;
                                    if Get_Value (atts, j) = "boolean" then
                                       a_param :=
                                         new parameter (boolean_parameter);
                                    end if;
                                    if Get_Value (atts, j) = "string" then
                                       a_param :=
                                         new parameter (string_parameter);
                                    end if;
                                    if Get_Value (atts, j) = "double" then
                                       a_param :=
                                         new parameter (double_parameter);
                                    end if;
                                 end if;

                              end loop;

                           else
                              if qname = "dependency" then

                                 for j in 0 .. Get_Length (atts) - 1 loop

                                    if Get_Qname (atts, j) = "from_type" then
                                       if (Get_Value (atts, j) /= "buffer") and
                                         (Get_Value (atts, j) /= "message") and
                                         (Get_Value (atts, j) /= "task")
                                       then
                                          Put_Line
                                            ("Warning : Error on data type. From " &
                                               To_String (handler.locator));
                                       end if;
                                       from_type :=
                                         To_Unbounded_String
                                           (Get_Value (atts, j));
                                    end if;

                                    if Get_Qname (atts, j) = "to_type" then
                                       if (Get_Value (atts, j) /= "buffer") and
                                         (Get_Value (atts, j) /= "message") and
                                         (Get_Value (atts, j) /= "task")
                                       then
                                          Put_Line
                                            ("Warning : Error on data type. From " &
                                               To_String (handler.locator));
                                       end if;
                                       to_type :=
                                         To_Unbounded_String
                                           (Get_Value (atts, j));
                                    end if;

                                 end loop;

                              end if;
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end if;
      end if;

   end start_element;

   procedure end_element
     (handler       : in out xml_project_parser;
      namespace_uri :        Unicode.CES.byte_sequence := "";
      local_name    :        Unicode.CES.byte_sequence := "";
      qname         :        Unicode.CES.byte_sequence := "")
   is

      buff_iterator : buffers_iterator;
      mess_iterator : messages_iterator;
      a_buff        : buffer_ptr;
      a_mess        : generic_message_ptr;
      task1, task2  : generic_task_ptr;

   begin

      -----------------------------------
      -- Element with one parameter
      -----------------------------------

      if qname = "name" then
         name := parameter_list (1);
      end if;

      if qname = "address_space_name" then
         address_space_name := parameter_list (1);
      end if;

      if qname = "allocation_description" then
         allocation_description := parameter_list (1);
      end if;

      if qname = "cpu_name" then
         cpu_name := parameter_list (1);
      end if;

      if qname = "network_link" then
         a_network := parameter_list (1);
      end if;

      if qname = "scheduler" then
         To_Schedulers_Type (parameter_list (1), a_scheduler, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "activation_rule" then
         parametric_rule := parameter_list (1);
      end if;

      if qname = "period" then
         to_integer (parameter_list (1), period, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "context_switch_overhead" then
         to_integer (parameter_list (1), context_switch_overhead, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "every" then
         to_integer (parameter_list (1), every, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "size" then
         to_natural (parameter_list (1), size, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "criticality" then
         to_integer (parameter_list (1), criticality, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "response_time" then
         to_natural (parameter_list (1), response_time, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "communication_time" then
         to_natural (parameter_list (1), communication_time, ok);
         if not ok then
            Put_Line
              ("warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "deadline" then
         to_integer (parameter_list (1), deadline, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "state" then
         to_integer (parameter_list (1), state, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "seed" then
         to_integer (parameter_list (1), seed, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "predictable_seed" then
         to_boolean (parameter_list (1), predictable, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "protocol" then
         To_Resources_Type (parameter_list (1), protocol, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;

      end if;

      if qname = "priority_assignment" then
         To_Priority_Assignment_Type
           (parameter_list (1),
            priority_assignment,
            ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;

      end if;

      if qname = "qs" then
         To_Queueing_Systems_Type (parameter_list (1), a_qs, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "policy" then
         To_Policies (parameter_list (1), policy, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "jitter" then
         to_integer (parameter_list (1), jitter, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "capacity" then
         to_integer (parameter_list (1), capacity, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "priority" then
         to_integer (parameter_list (1), priority, ok);
         if not ok then
            priority := 1;
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "start_time" then
         to_integer (parameter_list (1), start_time, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "blocking_time" then
         to_integer (parameter_list (1), blocking_time, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "text_memory_size" then
         to_integer (parameter_list (1), text_memory_size, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      --SR 08/2019
      if qname = "text_memory_start_address" then
         to_integer (parameter_list (1), text_memory_start_address, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;
      --

      if qname = "heap_memory_size" then
         to_integer (parameter_list (1), heap_memory_size, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "data_memory_size" then
         to_integer (parameter_list (1), data_memory_size, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      if qname = "stack_memory_size" then
         to_integer (parameter_list (1), stack_memory_size, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
      end if;

      -----------------------------------
      -- Element with several parameters
      -----------------------------------

      if qname = "resource_user" then
         to_natural (parameter_list (2), a_task_lists_entry.task_begin, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
         to_natural (parameter_list (3), a_task_lists_entry.task_end, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
         add (a_task_lists, parameter_list (1), a_task_lists_entry);
      end if;

      if qname = "buffer_user" then
         to_natural (parameter_list (2), a_role.size, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;

         to_natural (parameter_list (3), a_role.time, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;

         add (roles, parameter_list (1), a_role);
      end if;

      if qname = "offset" then
         to_natural (parameter_list (1), a_offset.activation, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
         to_natural (parameter_list (2), a_offset.offset_value, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
         add (offset, a_offset);
      end if;

      if qname = "parameter" then
         a_param.parameter_name := parameter_list (2);

         if a_param.type_of_parameter = string_parameter then
            a_param.string_value := parameter_list (1);
         end if;
         if a_param.type_of_parameter = boolean_parameter then
            to_boolean (parameter_list (1), a_param.boolean_value, ok);
            if not ok then
               Put_Line
                 ("Warning : Error on data type. From " &
                    To_String (handler.locator));
            end if;
         end if;
         if a_param.type_of_parameter = integer_parameter then
            to_integer (parameter_list (1), a_param.integer_value, ok);
            if not ok then
               Put_Line
                 ("Warning : Error on data type. From " &
                    To_String (handler.locator));
            end if;
         end if;
         if a_param.type_of_parameter = double_parameter then
            to_double (parameter_list (1), a_param.double_value, ok);
            if not ok then
               Put_Line
                 ("Warning : Error on data type. From " &
                    To_String (handler.locator));
            end if;
         end if;
         add (param, a_param);
      end if;

      ----------------------------------------
      -- End of Element is the end of an objet
      ----------------------------------------

      if qname = "address_space" then
         add_address_space
           (handler.parsed_system.address_spaces,
            name,
            cpu_name,
            text_memory_size,
            stack_memory_size,
            data_memory_size,
            heap_memory_size,
            is_preemptive,
            quantum,
            file_name,
            a_scheduler,
            automaton_name);
         initialize_project_parser (handler);
      end if;

      if qname = "event_analyzer" then
         add_event_analyzer
           (handler.parsed_system.event_analyzers,
            file_name,
            file_name);
         initialize_project_parser (handler);
      end if;

      if qname = "processor" then
         add_core_unit
           (handler.parsed_system.core_units,
            a_core,
            To_Unbounded_String ("core_unit_") & name,
            is_preemptive,
            quantum,
            1,
            0,
            0,
            0,
            file_name,
            empty_string,
            a_scheduler,
            empty_mem,
            automaton_name);
         add_processor (handler.parsed_system.processors, name, a_core);

         initialize_project_parser (handler);
      end if;

      if qname = "buffer" then
         add_buffer
           (handler.parsed_system.buffers,
            a_buff,
            name,
            size,
            cpu_name,
            address_space_name,
            a_qs,
            roles);
         initialize_project_parser (handler);
      end if;

      if qname = "message" then
         add_message
           (handler.parsed_system.messages,
            a_mess,
            name,
            size,
            period,
            deadline,
            jitter,
            param,
            response_time,
            communication_time);
         initialize_project_parser (handler);
      end if;

      if qname = "resource" then
         add_resource
           (handler.parsed_system.resources,
            name,
            state,
            size,
            address,
            cpu_name,
            address_space_name,
            protocol,
            a_task_lists,
            priority,
            priority_assignment);
         initialize_project_parser (handler);
      end if;


      if qname = "task" then

         add_task
           (my_tasks                => handler.parsed_system.tasks,
            a_task                  => task1,
            name                    => name,
            cpu_name                => cpu_name,
            address_space_name      => address_space_name,
            core_name               => empty_string,
            task_type               => task_type,
            start_time              => start_time,
            capacity                => capacity,
            period                  => period,
            deadline                => deadline,
            jitter                  => jitter,
            blocking_time           => blocking_time,
            priority                => priority,
            criticality             => criticality,
            policy                  => policy,
            offset                  => offset,
            stack_memory_size       => stack_memory_size,
            text_memory_size        => text_memory_size,
            param                   => param,
            parametric_rule_name    => parametric_rule,
            seed_value              => seed,
            predictable             => predictable,
            context_switch_overhead => context_switch_overhead,
            every                   => every);

         initialize_project_parser (handler);
      end if;

      if qname = "dependency" then
         if (from_type = To_Unbounded_String ("task")) and
           (to_type = To_Unbounded_String ("task"))
         then
            task1 :=
              search_task (handler.parsed_system.tasks, parameter_list (1));
            task2 :=
              search_task (handler.parsed_system.tasks, parameter_list (2));
            add_one_task_dependency_precedence
              (handler.parsed_system.dependencies,
               task1,
               task2);
         else
            if (from_type = To_Unbounded_String ("buffer")) or
              (to_type = To_Unbounded_String ("buffer"))
            then

               reset_iterator (handler.parsed_system.buffers, buff_iterator);

               loop
                  current_element
                    (handler.parsed_system.buffers,
                     a_buff,
                     buff_iterator);

                  if a_buff.name = parameter_list (1) then
                     task2 :=
                       search_task
                         (handler.parsed_system.tasks,
                          parameter_list (2));
                     add_one_task_dependency_queueing_buffer
                       (handler.parsed_system.dependencies,
                        task2,
                        a_buff,
                        from_object_to_task);
                     exit;
                  end if;

                  if a_buff.name = parameter_list (2) then
                     task1 :=
                       search_task
                         (handler.parsed_system.tasks,
                          parameter_list (1));
                     add_one_task_dependency_queueing_buffer
                       (handler.parsed_system.dependencies,
                        task1,
                        a_buff,
                        from_task_to_object);
                     exit;
                  end if;

                  if is_last_element
                    (handler.parsed_system.buffers,
                     buff_iterator)
                  then
                     raise buffer_set.buffer_not_found;
                  end if;

                  next_element (handler.parsed_system.buffers, buff_iterator);
               end loop;

            else
               if (from_type = To_Unbounded_String ("message")) or
                 (to_type = To_Unbounded_String ("message"))
               then

                  reset_iterator
                    (handler.parsed_system.messages,
                     mess_iterator);

                  loop
                     current_element
                       (handler.parsed_system.messages,
                        a_mess,
                        mess_iterator);

                     if a_mess.name = parameter_list (1) then
                        task2 :=
                          search_task
                            (handler.parsed_system.tasks,
                             parameter_list (2));
                        add_one_task_dependency_asynchronous_communication
                          (handler.parsed_system.dependencies,
                           task2,
                           a_mess,
                           from_object_to_task);
                        exit;
                     end if;

                     if a_mess.name = parameter_list (2) then
                        task1 :=
                          search_task
                            (handler.parsed_system.tasks,
                             parameter_list (1));
                        add_one_task_dependency_asynchronous_communication
                          (handler.parsed_system.dependencies,
                           task1,
                           a_mess,
                           from_task_to_object);
                        exit;
                     end if;

                     if is_last_element
                       (handler.parsed_system.messages,
                        mess_iterator)
                     then
                        raise message_set.message_not_found;
                     end if;

                     next_element
                       (handler.parsed_system.messages,
                        mess_iterator);
                  end loop;

               end if;
            end if;
         end if;
         initialize_project_parser (handler);
      end if;

   end end_element;

   function get_parsed_system
     (handler : in xml_project_parser) return system
   is
   begin
      return handler.parsed_system;
   end get_parsed_system;

   -------------------------------------------------------------
   -------------------------------------------------------------
   --    XML event table parser
   -------------------------------------------------------------
   -------------------------------------------------------------

   processor_name       : Unbounded_String;
   task_name            : Unbounded_String;
   resource_name        : Unbounded_String;
   message_name         : Unbounded_String;
   buffer_name          : Unbounded_String;
   number               : Natural;
   time_value           : Natural;
   new_processor_events : scheduling_result_ptr;
   new_event            : time_unit_event_ptr;

   function get_parsed_event_table
     (handler : in xml_event_table_parser) return scheduling_table_ptr
   is
   begin
      return handler.parsed_event_table;
   end get_parsed_event_table;

   procedure set_scheduled_system
     (handler          : in out xml_event_table_parser;
      scheduled_system : in     system)
   is
   begin
      handler.scheduled_system := scheduled_system;
   end set_scheduled_system;

   procedure initialize_event_table_parser
     (handler : in out xml_event_table_parser)
   is
   begin
      current_parameter := 1;
   end initialize_event_table_parser;

   procedure start_document (handler : in out xml_event_table_parser) is
   begin
      initialize_event_table_parser (handler);
      handler.parsed_event_table := new scheduling_table;
   end start_document;

   procedure start_element
     (handler       : in out xml_event_table_parser;
      namespace_uri :        Unicode.CES.byte_sequence := "";
      local_name    :        Unicode.CES.byte_sequence := "";
      qname         :        Unicode.CES.byte_sequence := "";
      atts          :        Sax.Attributes.attributes'class)
   is
   begin
      current_parameter := 1;
   end start_element;

   procedure read_time_value (handler : in out xml_event_table_parser) is
   begin
      to_natural (parameter_list (1), number, ok);
      if not ok then
         Put_Line
           ("Warning : Error on data type. From " &
              To_String (handler.locator));
      end if;
      time_value := number;
   end read_time_value;

   procedure end_element
     (handler       : in out xml_event_table_parser;
      namespace_uri :        Unicode.CES.byte_sequence := "";
      local_name    :        Unicode.CES.byte_sequence := "";
      qname         :        Unicode.CES.byte_sequence := "")
   is

      a_buffer    : buffer_ptr;
      a_message   : generic_message_ptr;
      a_task      : generic_task_ptr;
      a_resource  : generic_resource_ptr;
      a_processor : generic_processor_ptr;

   begin

      if qname = "name" then
         processor_name := parameter_list (1);
         a_processor    :=
           search_processor
             (handler.scheduled_system.processors,
              processor_name);
         new_processor_events                := new scheduling_result;
         new_processor_events.has_error      := False;
         new_processor_events.scheduling_msg := empty_string;
         new_processor_events.error_msg      := empty_string;
         new_processor_events.result         := new scheduling_sequence;
         add
           (handler.parsed_event_table.all,
            a_processor,
            new_processor_events.all);

         initialize_event_table_parser (handler);
      end if;

      if qname = "write_to_buffer" then
         buffer_name := parameter_list (2);
         task_name   := parameter_list (3);
         a_task := search_task (handler.scheduled_system.tasks, task_name);
         a_buffer    :=
           search_buffer (handler.scheduled_system.buffers, buffer_name);
         to_natural (parameter_list (4), number, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
         read_time_value (handler);

         new_event              := new time_unit_event (write_to_buffer);
         new_event.write_buffer := a_buffer;
         new_event.write_task   := a_task;
         new_event.write_size   := number;
         add (new_processor_events.result.all, time_value, new_event);

         initialize_event_table_parser (handler);
      end if;

      if qname = "read_from_buffer" then
         buffer_name := parameter_list (2);
         task_name   := parameter_list (3);
         a_task := search_task (handler.scheduled_system.tasks, task_name);
         a_buffer    :=
           search_buffer (handler.scheduled_system.buffers, buffer_name);
         to_natural (parameter_list (4), number, ok);
         if not ok then
            Put_Line
              ("Warning : Error on data type. From " &
                 To_String (handler.locator));
         end if;
         read_time_value (handler);

         new_event             := new time_unit_event (read_from_buffer);
         new_event.read_buffer := a_buffer;
         new_event.read_task   := a_task;
         new_event.read_size   := number;
         add (new_processor_events.result.all, time_value, new_event);

         initialize_event_table_parser (handler);
      end if;

      if qname = "send_message" then
         message_name := parameter_list (2);
         task_name    := parameter_list (3);
         a_message    :=
           search_message (handler.scheduled_system.messages, message_name);
         a_task := search_task (handler.scheduled_system.tasks, task_name);
         read_time_value (handler);

         new_event              := new time_unit_event (send_message);
         new_event.send_task    := a_task;
         new_event.send_message := a_message;
         add (new_processor_events.result.all, time_value, new_event);

         initialize_event_table_parser (handler);
      end if;

      if qname = "receive_message" then
         message_name := parameter_list (2);
         task_name    := parameter_list (3);
         a_message    :=
           search_message (handler.scheduled_system.messages, message_name);
         a_task := search_task (handler.scheduled_system.tasks, task_name);
         read_time_value (handler);

         new_event                 := new time_unit_event (receive_message);
         new_event.receive_task    := a_task;
         new_event.receive_message := a_message;
         add (new_processor_events.result.all, time_value, new_event);

         initialize_event_table_parser (handler);
      end if;

      if qname = "allocate_resource" then
         resource_name := parameter_list (2);
         task_name     := parameter_list (3);
         a_resource    :=
           search_resource (handler.scheduled_system.resources, resource_name);
         a_task := search_task (handler.scheduled_system.tasks, task_name);
         read_time_value (handler);

         new_event := new time_unit_event (allocate_resource);
         new_event.allocate_task     := a_task;
         new_event.allocate_resource := a_resource;
         add (new_processor_events.result.all, time_value, new_event);

         initialize_event_table_parser (handler);
      end if;

      if qname = "release_resource" then
         resource_name := parameter_list (2);
         task_name     := parameter_list (3);
         a_resource    :=
           search_resource (handler.scheduled_system.resources, resource_name);
         a_task := search_task (handler.scheduled_system.tasks, task_name);
         read_time_value (handler);

         new_event                  := new time_unit_event (release_resource);
         new_event.release_task     := a_task;
         new_event.release_resource := a_resource;
         add (new_processor_events.result.all, time_value, new_event);

         initialize_event_table_parser (handler);
      end if;

      if qname = "wait_for_resource" then
         resource_name := parameter_list (2);
         task_name     := parameter_list (3);
         a_resource    :=
           search_resource (handler.scheduled_system.resources, resource_name);
         a_task := search_task (handler.scheduled_system.tasks, task_name);
         read_time_value (handler);

         new_event := new time_unit_event (wait_for_resource);
         new_event.wait_for_resource_task := a_task;
         new_event.wait_for_resource      := a_resource;
         add (new_processor_events.result.all, time_value, new_event);

         initialize_event_table_parser (handler);
      end if;

      if qname = "task_activation" then
         task_name := parameter_list (2);
         a_task    := search_task (handler.scheduled_system.tasks, task_name);
         read_time_value (handler);

         new_event                 := new time_unit_event (task_activation);
         new_event.activation_task := a_task;
         add (new_processor_events.result.all, time_value, new_event);

         initialize_event_table_parser (handler);
      end if;

      if qname = "running_task" then
         task_name := parameter_list (2);
         a_task    := search_task (handler.scheduled_system.tasks, task_name);
         read_time_value (handler);

         new_event              := new time_unit_event (running_task);
         new_event.running_task := a_task;
         add (new_processor_events.result.all, time_value, new_event);

         initialize_event_table_parser (handler);
      end if;

      if qname = "start_of_task_capacity" then
         task_name := parameter_list (2);
         a_task    := search_task (handler.scheduled_system.tasks, task_name);
         read_time_value (handler);

         new_event            := new time_unit_event (start_of_task_capacity);
         new_event.start_task := a_task;
         add (new_processor_events.result.all, time_value, new_event);

         initialize_event_table_parser (handler);
      end if;

      if qname = "end_of_task_capacity" then
         task_name := parameter_list (2);
         a_task    := search_task (handler.scheduled_system.tasks, task_name);
         read_time_value (handler);

         new_event          := new time_unit_event (end_of_task_capacity);
         new_event.end_task := a_task;
         add (new_processor_events.result.all, time_value, new_event);

         initialize_event_table_parser (handler);
      end if;

   end end_element;

end v2_xml_parsers;
