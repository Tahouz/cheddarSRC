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

with Ada.Exceptions;   use Ada.Exceptions;
with time_unit_events; use time_unit_events;
use time_unit_events.time_unit_package;
with double_util;          use double_util;
with unbounded_strings;    use unbounded_strings;
with translate;            use translate;
with initialize_framework; use initialize_framework;
with Objects;              use Objects;
with Objects.extended;     use Objects.extended;
with Parameters.extended;  use Parameters.extended;

package body message_set is

   procedure add_message
     (my_messages                : in out messages_set;
      name                       : in     Unbounded_String;
      size                       : in     Natural;
      period                     : in     Natural;
      deadline                   : in     Natural;
      jitter                     : in     Natural;
      param : in user_defined_parameters_table   := no_user_defined_parameter;
      response_time              : in     Natural;
      communication_time         : in     Natural;
      mils_confidentiality_level :        mils_confidentiality_level_type :=
        top_secret;
      mils_integrity_level : mils_integrity_level_type := high)
   is

      dummy : generic_message_ptr;
   begin
      add_message
        (my_messages,
         dummy,
         name,
         size,
         period,
         deadline,
         jitter,
         param,
         response_time,
         communication_time,
         mils_confidentiality_level,
         mils_integrity_level);
   end add_message;

   procedure check_message
     (my_messages                : in messages_set;
      name                       : in Unbounded_String;
      size                       : in Natural;
      period                     : in Natural;
      deadline                   : in Natural;
      jitter                     : in Natural;
      param : in user_defined_parameters_table   := no_user_defined_parameter;
      response_time              : in Natural;
      communication_time         : in Natural;
      mils_confidentiality_level :    mils_confidentiality_level_type :=
        top_secret;
      mils_integrity_level : mils_integrity_level_type := high)
   is

      my_iterator : iterator;

   begin

      if (name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_message_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_message (Current_Language) &
               " " &
               name &
               " : " &
               lb_message_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if (size < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_message (Current_Language) &
               " " &
               name &
               " ; " &
               lb_size (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               To_Unbounded_String ("0")));
      end if;

      if (deadline < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_message (Current_Language) &
               " " &
               name &
               " ; " &
               lb_deadline (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               To_Unbounded_String ("0")));
      end if;

      if (jitter > deadline) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_message (Current_Language) &
               " " &
               name &
               " : " &
               lb_deadline (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_than (Current_Language) &
               lb_jitter (Current_Language)));
      end if;

      -- User defined integrity checks
      --
      check_parameters (param, lb_message (Current_Language) & " " & name);

   end check_message;

   procedure add_message
     (my_messages                : in out messages_set;
      a_message                  : in out generic_message_ptr;
      name                       : in     Unbounded_String;
      size                       : in     Natural;
      period                     : in     Natural;
      deadline                   : in     Natural;
      jitter                     : in     Natural;
      param : in user_defined_parameters_table   := no_user_defined_parameter;
      response_time              : in     Natural;
      communication_time         : in     Natural;
      mils_confidentiality_level :        mils_confidentiality_level_type :=
        top_secret;
      mils_integrity_level : mils_integrity_level_type := high)
   is

      new_periodic_message  : periodic_message_ptr;
      new_aperiodic_message : aperiodic_message_ptr;

      my_iterator     : iterator;
      current_message : generic_message_ptr;

   begin

      check_initialize;

      check_message
        (my_messages,
         name,
         size,
         period,
         deadline,
         jitter,
         param,
         response_time,
         communication_time,
         mils_confidentiality_level,
         mils_integrity_level);

      if (period /= 0) then
         new_periodic_message        := new periodic_message;
         new_periodic_message.jitter := jitter;
         new_periodic_message.period := period;
         a_message := generic_message_ptr (new_periodic_message);

      else
         new_aperiodic_message := new aperiodic_message;
         a_message             := generic_message_ptr (new_aperiodic_message);
      end if;

      if (get_number_of_elements (my_messages) > 0) then

         reset_iterator (my_messages, my_iterator);

         loop
            current_element (my_messages, current_message, my_iterator);
            if (name = current_message.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_message (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_message_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;

            exit when is_last_element (my_messages, my_iterator);

            next_element (my_messages, my_iterator);
         end loop;
      end if;

      a_message.name                       := name;
      a_message.size                       := size;
      a_message.response_time              := response_time;
      a_message.communication_time         := communication_time;
      a_message.deadline                   := deadline;
      a_message.parameters                 := param;
      a_message.mils_confidentiality_level := mils_confidentiality_level;
      a_message.mils_integrity_level       := mils_integrity_level;

      add (my_messages, a_message);

   end add_message;

   procedure update_message
     (my_messages        : in out messages_set;
      name               : in     Unbounded_String;
      new_name           : in     Unbounded_String;
      size               : in     Natural;
      period             : in     Natural;
      deadline           : in     Natural;
      jitter             : in     Natural;
      param : in user_defined_parameters_table := no_user_defined_parameter;
      response_time      : in     Natural;
      communication_time : in     Natural)
   is

      a_message          : generic_message_ptr;
      a_periodic_message : periodic_message_ptr;
   begin
      a_message                    := search_message (my_messages, name);
      a_message.name               := new_name;
      a_message.size               := size;
      a_message.deadline           := deadline;
      a_message.parameters         := param;
      a_message.response_time      := response_time;
      a_message.communication_time := communication_time;
      if (a_message.message_type = periodic_type) then
         a_periodic_message        := periodic_message_ptr (a_message);
         a_periodic_message.period := period;
         a_periodic_message.jitter := jitter;
      end if;

   end update_message;

   function have_deadlines_equal_than_periods
     (my_messages : in messages_set) return Boolean
   is
      equal_than  : Boolean := True;
      a_message   : generic_message_ptr;
      my_iterator : iterator;

   begin

      reset_iterator (my_messages, my_iterator);

      loop
         current_element (my_messages, a_message, my_iterator);

         if (a_message.message_type /= periodic_type) then
            return False;
         end if;

         if
           (periodic_message_ptr (a_message).deadline =
            periodic_message_ptr (a_message).period)
         then
            equal_than := False;
         end if;

         exit when is_last_element (my_messages, my_iterator);

         next_element (my_messages, my_iterator);

      end loop;

      return equal_than;

   end have_deadlines_equal_than_periods;

   procedure get_global_message_type
     (my_messages     : in     messages_set;
      has_global_type :    out Boolean;
      global_type     :    out messages_type)
   is

      a_message   : generic_message_ptr;
      my_iterator : iterator;

   begin

      has_global_type := True;
      reset_iterator (my_messages, my_iterator);

      -- Find the first message of the processor
      --
      current_element (my_messages, a_message, my_iterator);

      global_type := a_message.message_type;
      if is_last_element (my_messages, my_iterator) then
         return;
      else
         next_element (my_messages, my_iterator);
      end if;

      loop
         current_element (my_messages, a_message, my_iterator);

         if (global_type /= a_message.message_type) then
            has_global_type := False;
            return;
         end if;

         exit when is_last_element (my_messages, my_iterator);

         next_element (my_messages, my_iterator);

      end loop;

   end get_global_message_type;

   function search_message_by_id
     (my_messages : in messages_set;
      id          : in Unbounded_String) return generic_message_ptr
   is
      my_iterator : iterator;
      a_message   : generic_message_ptr;
      result      : generic_message_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_messages) then

         reset_iterator (my_messages, my_iterator);

         loop
            current_element (my_messages, a_message, my_iterator);
            if (a_message.cheddar_private_id = id) then
               found  := True;
               result := a_message;
            end if;

            exit when is_last_element (my_messages, my_iterator);

            next_element (my_messages, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (message_not_found'identity,
            To_String (lb_message_id (Current_Language) & "=" & id));
      end if;

      return result;
   end search_message_by_id;

   function search_message
     (my_messages : in messages_set;
      name        : in Unbounded_String) return generic_message_ptr
   is
      my_iterator : iterator;
      a_message   : generic_message_ptr;
      result      : generic_message_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_messages) then

         reset_iterator (my_messages, my_iterator);

         loop
            current_element (my_messages, a_message, my_iterator);

            if (a_message.name = name) then
               found  := True;
               result := a_message;
            end if;

            exit when is_last_element (my_messages, my_iterator);

            next_element (my_messages, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (message_not_found'identity,
            To_String (lb_message_name (Current_Language) & "=" & name));
      end if;

      return result;
   end search_message;

   function increasing_period
     (op1 : in generic_message_ptr;
      op2 : in generic_message_ptr) return Boolean
   is
   begin
      return
        (periodic_message_ptr (op1).period <=
         periodic_message_ptr (op2).period);
   end increasing_period;

   function decreasing_period
     (op1 : in generic_message_ptr;
      op2 : in generic_message_ptr) return Boolean
   is
   begin
      return
        (periodic_message_ptr (op1).period >=
         periodic_message_ptr (op2).period);
   end decreasing_period;

   function increasing_deadline
     (op1 : in generic_message_ptr;
      op2 : in generic_message_ptr) return Boolean
   is
   begin
      return
        (periodic_message_ptr (op1).deadline <=
         periodic_message_ptr (op2).deadline);
   end increasing_deadline;

   function decreasing_deadline
     (op1 : in generic_message_ptr;
      op2 : in generic_message_ptr) return Boolean
   is
   begin
      return
        (periodic_message_ptr (op1).deadline >=
         periodic_message_ptr (op2).deadline);
   end decreasing_deadline;

   function get
     (my_messages  : in messages_set;
      message_name : in Unbounded_String;
      param_name   : in message_parameters) return Natural
   is
      a_message   : generic_message_ptr;
      my_iterator : iterator;

   begin

      if
        ((param_name /= size) and
         (param_name /= period) and
         (param_name /= deadline) and
         (param_name /= response_time) and
         (param_name /= jitter))
      then
         raise invalid_parameter;
      end if;

      reset_iterator (my_messages, my_iterator);

      loop
         current_element (my_messages, a_message, my_iterator);

         if (a_message.name = message_name) then
            exit;
         end if;

         exit when is_last_element (my_messages, my_iterator);

         next_element (my_messages, my_iterator);

      end loop;

      if (param_name = size) then
         return a_message.size;
      else
         if (param_name = deadline) then
            return periodic_message_ptr (a_message).deadline;
         else
            if (param_name = response_time) then
               return a_message.response_time;
            else
               if (param_name = communication_time) then
                  return a_message.communication_time;
               else
                  if (param_name = period) then
                     return periodic_message_ptr (a_message).period;
                  else
                     return periodic_message_ptr (a_message).jitter;
                  end if;
               end if;
            end if;
         end if;
      end if;
   end get;

   procedure set
     (my_messages  : in out messages_set;
      message_name : in     Unbounded_String;
      param_name   : in     message_parameters;
      param_value  : in     Natural)
   is
      a_message   : generic_message_ptr;
      my_iterator : iterator;

   begin

      if
        ((param_name /= size) and
         (param_name /= period) and
         (param_name /= deadline) and
         (param_name /= jitter)) and
        (param_name /= response_time) and
        (param_name /= communication_time)
      then
         raise invalid_parameter;
      end if;

      reset_iterator (my_messages, my_iterator);

      loop
         current_element (my_messages, a_message, my_iterator);

         if (a_message.name = message_name) then
            if (param_name = size) then
               a_message.size := param_value;
            else
               if (param_name = response_time) then
                  a_message.response_time := param_value;
               else
                  if (param_name = communication_time) then
                     a_message.communication_time := param_value;
                     exit;
                  end if;
               end if;
            end if;
         end if;
         if (param_name = deadline) then
            periodic_message_ptr (a_message).deadline := param_value;
         end if;
         if (param_name = period) then
            periodic_message_ptr (a_message).period := param_value;
            exit;
         end if;
         if (param_name = jitter) then
            periodic_message_ptr (a_message).jitter := param_value;
            exit;
         end if;
         exit when is_last_element (my_messages, my_iterator);

         next_element (my_messages, my_iterator);

      end loop;
   end set;

   function export_aadl_user_defined_properties
     (my_messages : in messages_set) return Unbounded_String
   is
      result : Unbounded_String := empty_string;

   begin
      return result;
   end export_aadl_user_defined_properties;

   function export_aadl_implementations
     (my_messages : in messages_set) return Unbounded_String
   is
      result : Unbounded_String := empty_string;

   begin
      return result;
   end export_aadl_implementations;

end message_set;
