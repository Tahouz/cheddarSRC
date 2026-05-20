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

with Text_IO;               use Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with double_util;           use double_util;
with natural_util;          use natural_util;
with primitive_xml_strings; use primitive_xml_strings;
with Queueing_Systems;      use Queueing_Systems;
with Doubles;               use Doubles;

with Ada.Finalization;
with indexed_tables;


package queueing_system is

   not_implemented : exception;

   function qs_to_display_string
     (a_qs : in queueing_systems_type) return Unbounded_String;
   procedure display_string_to_qs
     (from : in     Unbounded_String;
      to   :    out queueing_systems_type;
      ok   :    out Boolean);

   arrival_rate_table_size       : constant Natural := 100;
   service_rate_table_size       : constant Natural := 100;
   resp_time_table_size          : constant Natural := 1000;
   resp_time_consumer_table_size : constant Natural := 1000;

   package a_arrival_rate is new indexed_tables
     (Double,
      Natural,
      arrival_rate_table_size,
      0,
      double_util.put,
      double_util.initialize,
      natural_util.put,
      format,
      xml_string,
      xml_ref_string);
   use a_arrival_rate;

   package a_service_rate is new indexed_tables
     (Double,
      Natural,
      service_rate_table_size,
      0,
      double_util.put,
      double_util.initialize,
      natural_util.put,
      format,
      xml_string,
      xml_ref_string);
   use a_service_rate;

   package a_resp_time is new indexed_tables
     (Double,
      Natural,
      resp_time_table_size,
      0,
      double_util.put,
      double_util.initialize,
      natural_util.put,
      format,
      xml_string,
      xml_ref_string);
   use a_resp_time;

   package a_resp_time_consumer is new indexed_tables
     (Double,
      Natural,
      resp_time_consumer_table_size,
      0,
      double_util.put,
      double_util.initialize,
      natural_util.put,
      format,
      xml_string,
      xml_ref_string);
   use a_resp_time_consumer;

   subtype arrival_rate_table is a_arrival_rate.indexed_table;
   subtype arrival_rate_range is a_arrival_rate.indexed_table_range;

   subtype service_rate_table is a_service_rate.indexed_table;
   subtype service_rate_range is a_service_rate.indexed_table_range;

   subtype resp_time_consumer_table is a_resp_time_consumer.indexed_table;
   subtype resp_time_consumer_table_ptr is
     a_resp_time_consumer.indexed_table_ptr;
   subtype resp_time_consumer_range is
     a_resp_time_consumer.indexed_table_range;

   subtype resp_time_table is a_resp_time.indexed_table;
   subtype resp_time_table_ptr is a_resp_time.indexed_table_ptr;
   subtype resp_time_range is a_resp_time.indexed_table_range;

   type generic_queueing_system is abstract new Ada.Finalization
     .Controlled with
   record
      queueing_system_type : queueing_systems_type;
      arrival_rate         : arrival_rate_table;
      service_rate         : service_rate_table;
      nb_of_messages       : Double;

      var_service : Double; -- variance service time for mg1
      avg_service : Double; -- average service time for mg1

      waiting_time : Double;
      utilisation  : Double;
      max_state    : Natural;

      nb_arrival : Double;  -- nb of producer or arrival flow
      nb_server  : Double;  -- nb of server or consumer
      harmonic   : Boolean; -- for PP1 qs

      -- mp1 criteria computation
      --
      consumer_resp_time     : resp_time_consumer_table_ptr;
      consumer_resp_time_cpt : resp_time_consumer_range;
   end record;

   type queueing_system_ptr is access all generic_queueing_system'class;

   procedure initialize (a_queueing_system : in out generic_queueing_system);

   -- Initialize a queueing system with a constant consumer response time
   --
   procedure set_constant_consumer_response_time
     (a_queueing_system : in out generic_queueing_system'class;
      response_time     : in     Double);

   -- reset queueing system values
   --
   procedure reset (a_queueing_system : in out generic_queueing_system);

   -- display all queueing system caracteristics
   --
   procedure put (a_queueing_system : in generic_queueing_system);

   -- get or set queueing system caracteristics
   --
   procedure set_qs_arrival_rate
     (a_queueing_system : in out generic_queueing_system'class;
      value             : in     Double);

   procedure set_qs_arrival_rate
     (a_queueing_system : in out generic_queueing_system'class;
      place             : in     arrival_rate_range;
      value             : in     Double);

   function get_qs_arrival_rate
     (a_queueing_system : in generic_queueing_system'class;
      place             : in arrival_rate_range) return Double;

   procedure set_qs_service_rate
     (a_queueing_system : in out generic_queueing_system'class;
      value             : in     Double);

   procedure set_qs_service_rate
     (a_queueing_system : in out generic_queueing_system'class;
      place             : in     service_rate_range;
      value             : in     Double);

   function get_qs_service_rate
     (a_queueing_system : in generic_queueing_system'class;
      place             : in service_rate_range) return Double;

   procedure set_qs_utilisation
     (a_queueing_system : in out generic_queueing_system'class;
      value             :        Double);

   function get_qs_utilisation
     (a_queueing_system : in generic_queueing_system'class) return Double;

   procedure set_qs_type
     (a_queueing_system : in out generic_queueing_system'class;
      qs_type           : in     queueing_systems_type);

   function get_qs_type
     (a_queueing_system : in generic_queueing_system'class)
      return queueing_systems_type;

   procedure set_qs_nb_of_messages
     (a_queueing_system : in out generic_queueing_system'class;
      value             :        Double);

   function get_qs_nb_of_messages
     (a_queueing_system : in generic_queueing_system'class) return Double;

   procedure set_qs_waiting_time
     (a_queueing_system : in out generic_queueing_system'class;
      value             :        Double);

   function get_qs_waiting_time
     (a_queueing_system : in generic_queueing_system'class) return Double;

   procedure set_qs_max_state
     (a_queueing_system : in out generic_queueing_system'class;
      value             :        Natural);

   function get_qs_max_state
     (a_queueing_system : in generic_queueing_system'class) return Natural;

   procedure set_qs_nb_arrival
     (a_queueing_system : in out generic_queueing_system'class;
      value             :        Double);

   function get_qs_nb_arrival
     (a_queueing_system : in generic_queueing_system'class) return Double;

   procedure set_qs_nb_server
     (a_queueing_system : in out generic_queueing_system'class;
      value             :        Double);

   function get_qs_nb_server
     (a_queueing_system : in generic_queueing_system'class) return Double;

   procedure set_qs_harmonic
     (a_queueing_system : in out generic_queueing_system'class;
      value             :        Boolean);

   function get_qs_harmonic
     (a_queueing_system : in generic_queueing_system'class) return Boolean;

   -- return the name of the queueing system
   --
   function get_name
     (a_queueing_system : in generic_queueing_system'class)
      return Unbounded_String;

   -- set queueing system caracteristics
   -- needed, for instance, if you want theoretical results after a simulation
   --
   procedure set_qs_basic_parameters
     (a_queueing_system        : in out generic_queueing_system'class;
      a_source_queueing_system : in     generic_queueing_system);

end queueing_system;
