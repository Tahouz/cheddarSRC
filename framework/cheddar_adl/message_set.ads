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

with Messages;              use Messages;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Framework_Config;      use Framework_Config;
with MILS_Security;         use MILS_Security;
with Parameters;            use Parameters;
use Parameters.User_Defined_Parameters_Table_Package;
with Parameters.extended; use Parameters.extended;
with Offsets;             use Offsets;
use Offsets.Offsets_Table_Package;
with sets;

package message_set is

   ----------------------------------------------------------
   -- Definition of a set
   ----------------------------------------------------------

   package generic_message_set is new sets
     (max_element    => Framework_Config.Max_Messages,
      element        => generic_message_ptr,
      free           => Free,
      copy           => Copy,
      put            => Put,
      xml_string     => XML_String,
      xml_ref_string => XML_Ref_String);

   use generic_message_set;

   type messages_set is new generic_message_set.set with private;

   subtype messages_range is generic_message_set.element_range;
   subtype messages_iterator is generic_message_set.iterator;

   ----------------------------------------------------------
   -- Exceptions defined in the set package
   ----------------------------------------------------------

   -- Raised when a given message is not in a message set
   --
   message_not_found : exception;

   -- Raised when parameters provided to Add_message are wrong
   --
   invalid_parameter : exception;

   -- Raised if a message has a wrong type
   --
   message_model_error : exception;

   ----------------------------------------------------------
   -- I/O operations
   ----------------------------------------------------------

   function export_aadl_user_defined_properties
     (my_messages : in messages_set) return Unbounded_String;

   function export_aadl_implementations
     (my_messages : in messages_set) return Unbounded_String;

   ----------------------------------------------------------
   -- Procedure to proceed modification on a set
   ----------------------------------------------------------

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
      mils_integrity_level : mils_integrity_level_type := high);

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
      mils_integrity_level : mils_integrity_level_type := high);

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
      mils_confidentiality_level : in     mils_confidentiality_level_type :=
        top_secret;
      mils_integrity_level : in mils_integrity_level_type := high);

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
      communication_time : in     Natural);

   ------------------------------------------------------
   -- Read information from a set
   ------------------------------------------------------

   procedure get_global_message_type
     (my_messages     : in     messages_set;
      has_global_type :    out Boolean;
      global_type     :    out messages_type);

   function search_message
     (my_messages : in messages_set;
      name        : in Unbounded_String) return generic_message_ptr;

   function search_message_by_id
     (my_messages : in messages_set;
      id          : in Unbounded_String) return generic_message_ptr;

   ----------------------------------------------------------
   -- List of parameters the user can set of get directly
   -- throught the set
   ----------------------------------------------------------

   type message_parameters is
     (size,
      period,
      deadline,
      jitter,
      response_time,
      communication_time,
      send_time);

   function get
     (my_messages  : in messages_set;
      message_name : in Unbounded_String;
      param_name   : in message_parameters) return Natural;

   procedure set
     (my_messages  : in out messages_set;
      message_name : in     Unbounded_String;
      param_name   : in     message_parameters;
      param_value  : in     Natural);

   --------------------------------------------------------
   -- Functions to proceed sort on a set
   --------------------------------------------------------

   function increasing_deadline
     (op1 : in generic_message_ptr;
      op2 : in generic_message_ptr) return Boolean;

   function decreasing_deadline
     (op1 : in generic_message_ptr;
      op2 : in generic_message_ptr) return Boolean;

   function increasing_period
     (op1 : in generic_message_ptr;
      op2 : in generic_message_ptr) return Boolean;

   function decreasing_period
     (op1 : in generic_message_ptr;
      op2 : in generic_message_ptr) return Boolean;

   ----------------------------------------------------
   -- Control sub-programs
   ----------------------------------------------------

   function have_deadlines_equal_than_periods
     (my_messages : in messages_set) return Boolean;

private

   type messages_set is new generic_message_set.set with null record;

end message_set;
