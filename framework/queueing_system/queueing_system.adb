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

with natural_util; use natural_util;

package body queueing_system is

   procedure set_constant_consumer_response_time
     (a_queueing_system : in out generic_queueing_system'class;
      response_time     : in     Double)
   is
   begin
      a_queueing_system.consumer_resp_time.entries (0).data := response_time;
      a_queueing_system.consumer_resp_time.nb_entries       := 1;
   end set_constant_consumer_response_time;

   function qs_to_display_string
     (a_qs : in queueing_systems_type) return Unbounded_String
   is
      s : Unbounded_String;
   begin

      case a_qs is
         when qs_pp1 =>
            s := To_Unbounded_String ("P/P/1");
         when qs_mm1 =>
            s := To_Unbounded_String ("M/M/1");
         when qs_md1 =>
            s := To_Unbounded_String ("M/D/1");
         when qs_mp1 =>
            s := To_Unbounded_String ("M/P/1");
         when qs_mg1 =>
            s := To_Unbounded_String ("M/G/1");
         when qs_mms =>
            s := To_Unbounded_String ("M/M/s");
         when qs_mds =>
            s := To_Unbounded_String ("M/D/s");
         when qs_mps =>
            s := To_Unbounded_String ("M/P/s");
         when qs_mgs =>
            s := To_Unbounded_String ("M/G/s");
         when qs_mm1n =>
            s := To_Unbounded_String ("M/M/1/n");
         when qs_md1n =>
            s := To_Unbounded_String ("M/D/1/n");
         when qs_mp1n =>
            s := To_Unbounded_String ("M/P/1/n");
         when qs_mg1n =>
            s := To_Unbounded_String ("M/G/1/n");
         when qs_mmsn =>
            s := To_Unbounded_String ("M/M/s/n");
         when qs_mdsn =>
            s := To_Unbounded_String ("M/D/s/n");
         when qs_mpsn =>
            s := To_Unbounded_String ("M/P/s/n");
         when qs_mgsn =>
            s := To_Unbounded_String ("M/G/s/n");
      end case;
      return s;
   end qs_to_display_string;

   procedure display_string_to_qs
     (from : in     Unbounded_String;
      to   :    out queueing_systems_type;
      ok   :    out Boolean)
   is
   begin
      ok := False;

      if from = To_Unbounded_String ("P/P/1") then
         to := qs_pp1;
         ok := True;
      end if;

      if from = To_Unbounded_String ("M/M/1") then
         to := qs_mm1;
         ok := True;
      end if;

      if from = To_Unbounded_String ("M/D/1") then
         to := qs_md1;
         ok := True;
      end if;

      if from = To_Unbounded_String ("M/P/1") then
         to := qs_mp1;
         ok := True;
      end if;

      if from = To_Unbounded_String ("M/G/1") then
         to := qs_mg1;
         ok := True;
      end if;

      if from = To_Unbounded_String ("M/M/s") then
         to := qs_mms;
         ok := True;
      end if;

      if from = To_Unbounded_String ("M/D/s") then
         to := qs_mds;
         ok := True;
      end if;

      if from = To_Unbounded_String ("M/P/s") then
         to := qs_mps;
         ok := True;
      end if;

      if from = To_Unbounded_String ("M/G/s") then
         to := qs_mgs;
         ok := True;
      end if;

      if from = To_Unbounded_String ("M/M/1/n") then
         to := qs_mm1n;
         ok := True;
      end if;

      if from = To_Unbounded_String ("M/D/1/n") then
         to := qs_md1n;
         ok := True;
      end if;

      if from = To_Unbounded_String ("M/P/1/n") then
         to := qs_mp1n;
         ok := True;
      end if;

      if from = To_Unbounded_String ("M/G/1/n") then
         to := qs_mg1n;
         ok := True;
      end if;

      if from = To_Unbounded_String ("M/M/s/n") then
         to := qs_mmsn;
         ok := True;
      end if;

      if from = To_Unbounded_String ("M/D/s/n") then
         to := qs_mdsn;
         ok := True;
      end if;

      if from = To_Unbounded_String ("M/P/s/n") then
         to := qs_mpsn;
         ok := True;
      end if;

      if from = To_Unbounded_String ("M/G/s/n") then
         ok := True;
         to := qs_mgsn;
      end if;

   end display_string_to_qs;

   procedure set_qs_type
     (a_queueing_system : in out generic_queueing_system'class;
      qs_type           : in     queueing_systems_type)
   is
   begin
      a_queueing_system.queueing_system_type := qs_type;
   end set_qs_type;

   function get_qs_type
     (a_queueing_system : in generic_queueing_system'class)
      return queueing_systems_type
   is
   begin
      return a_queueing_system.queueing_system_type;
   end get_qs_type;

   procedure set_qs_arrival_rate
     (a_queueing_system : in out generic_queueing_system'class;
      value             :        Double)
   is
   begin
      a_queueing_system.arrival_rate.entries
        (a_queueing_system.arrival_rate.nb_entries)
        .data :=
        value;
      a_queueing_system.arrival_rate.nb_entries :=
        a_queueing_system.arrival_rate.nb_entries + 1;
   end set_qs_arrival_rate;

   procedure set_qs_arrival_rate
     (a_queueing_system : in out generic_queueing_system'class;
      place             :        arrival_rate_range;
      value             :        Double)
   is
   begin
      a_queueing_system.arrival_rate.entries (place).data := value;
   end set_qs_arrival_rate;

   function get_qs_arrival_rate
     (a_queueing_system : in generic_queueing_system'class;
      place             :    arrival_rate_range) return Double
   is
   begin
      return a_queueing_system.arrival_rate.entries (place).data;
   end get_qs_arrival_rate;

   procedure set_qs_service_rate
     (a_queueing_system : in out generic_queueing_system'class;
      value             :        Double)
   is
   begin
      a_queueing_system.service_rate.entries
        (a_queueing_system.service_rate.nb_entries)
        .data :=
        value;
      a_queueing_system.service_rate.nb_entries :=
        a_queueing_system.service_rate.nb_entries + 1;
   end set_qs_service_rate;

   procedure set_qs_service_rate
     (a_queueing_system : in out generic_queueing_system'class;
      place             :        service_rate_range;
      value             :        Double)
   is
   begin
      a_queueing_system.service_rate.entries (place).data := value;
   end set_qs_service_rate;

   function get_qs_service_rate
     (a_queueing_system : in generic_queueing_system'class;
      place             :    service_rate_range) return Double
   is
   begin
      return a_queueing_system.service_rate.entries (place).data;
   end get_qs_service_rate;

   procedure set_qs_utilisation
     (a_queueing_system : in out generic_queueing_system'class;
      value             :        Double)
   is
   begin
      a_queueing_system.utilisation := value;
   end set_qs_utilisation;

   function get_qs_utilisation
     (a_queueing_system : in generic_queueing_system'class) return Double
   is
   begin
      return a_queueing_system.utilisation;
   end get_qs_utilisation;

   procedure set_qs_nb_of_messages
     (a_queueing_system : in out generic_queueing_system'class;
      value             :        Double)
   is
   begin
      a_queueing_system.nb_of_messages := value;
   end set_qs_nb_of_messages;

   function get_qs_nb_of_messages
     (a_queueing_system : in generic_queueing_system'class) return Double
   is
   begin
      return a_queueing_system.nb_of_messages;
   end get_qs_nb_of_messages;

   procedure set_qs_waiting_time
     (a_queueing_system : in out generic_queueing_system'class;
      value             :        Double)
   is
   begin
      a_queueing_system.waiting_time := value;
   end set_qs_waiting_time;

   function get_qs_waiting_time
     (a_queueing_system : in generic_queueing_system'class) return Double
   is
   begin
      return a_queueing_system.waiting_time;
   end get_qs_waiting_time;

   procedure set_qs_max_state
     (a_queueing_system : in out generic_queueing_system'class;
      value             :        Natural)
   is
   begin
      a_queueing_system.max_state := value;
   end set_qs_max_state;

   function get_qs_max_state
     (a_queueing_system : in generic_queueing_system'class) return Natural
   is
   begin
      return a_queueing_system.max_state;
   end get_qs_max_state;

   procedure set_qs_nb_arrival
     (a_queueing_system : in out generic_queueing_system'class;
      value             :        Double)
   is

   begin
      a_queueing_system.nb_arrival := value;
   end set_qs_nb_arrival;

   function get_qs_nb_arrival
     (a_queueing_system : in generic_queueing_system'class) return Double
   is
   begin
      return a_queueing_system.nb_arrival;
   end get_qs_nb_arrival;

   procedure set_qs_nb_server
     (a_queueing_system : in out generic_queueing_system'class;
      value             :        Double)
   is

   begin
      a_queueing_system.nb_server := value;
   end set_qs_nb_server;

   function get_qs_nb_server
     (a_queueing_system : in generic_queueing_system'class) return Double
   is
   begin
      return a_queueing_system.nb_server;
   end get_qs_nb_server;

   procedure set_qs_harmonic
     (a_queueing_system : in out generic_queueing_system'class;
      value             :        Boolean)
   is

   begin
      a_queueing_system.harmonic := value;
   end set_qs_harmonic;

   function get_qs_harmonic
     (a_queueing_system : in generic_queueing_system'class) return Boolean
   is
   begin
      return a_queueing_system.harmonic;
   end get_qs_harmonic;

   procedure initialize (a_queueing_system : in out generic_queueing_system) is
   begin
      initialize (a_queueing_system.arrival_rate);
      initialize (a_queueing_system.service_rate);
      a_queueing_system.nb_of_messages := 0.0;
      a_queueing_system.waiting_time   := 0.0;
      a_queueing_system.utilisation    := 0.0;
      a_queueing_system.max_state      := 0;

      a_queueing_system.var_service := 0.0;
      a_queueing_system.avg_service := 0.0;

      a_queueing_system.nb_arrival := 0.0;
      a_queueing_system.nb_server  := 0.0;
      a_queueing_system.harmonic   := False;

      a_queueing_system.consumer_resp_time     := new resp_time_consumer_table;
      a_queueing_system.consumer_resp_time_cpt := 0;
   end initialize;

   procedure reset (a_queueing_system : in out generic_queueing_system) is
   begin
      initialize (a_queueing_system);
   end reset;

   procedure put (a_queueing_system : in generic_queueing_system) is

      arrival_period : constant Double :=
        1.0 / a_queueing_system.arrival_rate.entries (0).data;
      service_period : constant Double :=
        1.0 / a_queueing_system.service_rate.entries (0).data;
      rho : constant Double := a_queueing_system.utilisation;

      package double_io is new Text_IO.Float_IO (Double);
      use double_io;

   begin
      Put_Line ("# Name " & To_String (get_name (a_queueing_system)));

      Put ("# Arrival rate (lambda) = 1/");
      Put (arrival_period, Aft => 4, Exp => 0);
      New_Line;

      Put ("# Service rate (mu) = 1/");
      Put (service_period, Aft => 4, Exp => 0);
      New_Line;

      Put ("# Utilisation (rho) = ");
      Put (rho, Aft => 4, Exp => 0);
      New_Line;
      New_Line;

   end put;

   function get_name
     (a_queueing_system : in generic_queueing_system'class)
      return Unbounded_String
   is
      result : Unbounded_String;
   begin
      if a_queueing_system.queueing_system_type = qs_pp1 then
         result := To_Unbounded_String ("PP1");
      else
         if a_queueing_system.queueing_system_type = qs_mm1 then
            result := To_Unbounded_String ("MM1");
         else
            if a_queueing_system.queueing_system_type = qs_md1 then
               result := To_Unbounded_String ("MD1");
            else
               if a_queueing_system.queueing_system_type = qs_mp1 then
                  result := To_Unbounded_String ("MP1");
               else
                  if a_queueing_system.queueing_system_type = qs_mg1 then
                     result := To_Unbounded_String ("MG1");
                  else
                     if a_queueing_system.queueing_system_type = qs_mms then
                        result := To_Unbounded_String ("MMS");
                     else
                        if a_queueing_system.queueing_system_type = qs_mds then
                           result := To_Unbounded_String ("MDS");
                        else
                           if a_queueing_system.queueing_system_type =
                             qs_mps
                           then
                              result := To_Unbounded_String ("MPS");
                           else
                              if a_queueing_system.queueing_system_type =
                                qs_mgs
                              then
                                 result := To_Unbounded_String ("MGS");
                              else
                                 if a_queueing_system.queueing_system_type =
                                   qs_mm1n
                                 then
                                    result := To_Unbounded_String ("MM1N");
                                 else
                                    if a_queueing_system.queueing_system_type =
                                      qs_md1n
                                    then
                                       result := To_Unbounded_String ("MD1N");
                                    else
                                       if a_queueing_system
                                           .queueing_system_type =
                                         qs_mp1n
                                       then
                                          result :=
                                            To_Unbounded_String ("MP1N");
                                       else
                                          if a_queueing_system
                                              .queueing_system_type =
                                            qs_mg1n
                                          then
                                             result :=
                                               To_Unbounded_String ("MG1N");
                                          else
                                             if a_queueing_system
                                                 .queueing_system_type =
                                               qs_mmsn
                                             then
                                                result :=
                                                  To_Unbounded_String ("MMSN");
                                             else
                                                if a_queueing_system
                                                    .queueing_system_type =
                                                  qs_mdsn
                                                then
                                                   result :=
                                                     To_Unbounded_String
                                                       ("MDSN");
                                                else
                                                   if a_queueing_system
                                                       .queueing_system_type =
                                                     qs_mpsn
                                                   then
                                                      result :=
                                                        To_Unbounded_String
                                                          ("MPSN");
                                                   else
                                                      if a_queueing_system
                                                          .queueing_system_type =
                                                        qs_mgsn
                                                      then
                                                         result :=
                                                           To_Unbounded_String
                                                             ("MGSN");
                                                      else
                                                         result :=
                                                           To_Unbounded_String
                                                             ("?");
                                                      end if;
                                                   end if;
                                                end if;
                                             end if;
                                          end if;
                                       end if;
                                    end if;
                                 end if;
                              end if;
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end if;
      end if;
      return result;
   end get_name;

   procedure set_qs_basic_parameters
     (a_queueing_system        : in out generic_queueing_system'class;
      a_source_queueing_system : in     generic_queueing_system)
   is

   begin

      set_qs_arrival_rate
        (a_queueing_system,
         0,
         get_qs_arrival_rate (a_source_queueing_system, 0));

      set_qs_service_rate
        (a_queueing_system,
         0,
         get_qs_service_rate (a_source_queueing_system, 0));

      set_qs_utilisation
        (a_queueing_system,
         get_qs_utilisation (a_source_queueing_system));

      set_qs_nb_arrival
        (a_queueing_system,
         get_qs_nb_arrival (a_source_queueing_system));

      set_qs_nb_server
        (a_queueing_system,
         get_qs_nb_server (a_source_queueing_system));

      set_qs_max_state
        (a_queueing_system,
         get_qs_max_state (a_source_queueing_system));

      set_qs_nb_of_messages
        (a_queueing_system,
         get_qs_nb_of_messages (a_source_queueing_system));

   end set_qs_basic_parameters;

end queueing_system;
