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

with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with primitive_xml_strings;     use primitive_xml_strings;
with access_lists;

package queueing_system.simulation is

   package generic_index_lst is new access_lists
     (put         => put,
      element     => Double,
      element_ptr => double_ptr,
      free        => double_util.free,
      copy        => double_util.copy,
      xml_string  => xml_string);

   use generic_index_lst;

   type generic_queueing_system_simulation is abstract new generic_queueing_system with
   record
      service_resp_time : resp_time_table_ptr;

      -- simulation result
      sim_mit     : Double; -- mean interarrival time
      sim_mst     : Double; -- Mean service time
      sim_var_mst : Double; -- Mean variance service time
      sim_mwt     : Double; -- Mean waiting time
      sim_mnc     : Double; -- Mean number of customer
      rho         : Double; -- utilisation of the qs

      -- service time computation variable during simulation (MP1)
      t_arr        : Double;
      empty_buffer : Boolean;
   end record;

   type queueing_system_simulation_ptr is
     access all generic_queueing_system_simulation'class;

   procedure initialize
     (a_queueing_system : in out generic_queueing_system_simulation);

   -- reset caracteristics of the qs (has to be done each time a qs is used)
   --
   procedure reset
     (a_queueing_system : in out generic_queueing_system_simulation);

   -- return the next service time
   --
   function compute_service_time
     (a_queueing_system : in generic_queueing_system_simulation;
      seed              : in Generator) return Double is abstract;

   -- return the next customer arrival date
   --
   function compute_inter_arrival_time
     (a_queueing_system : in generic_queueing_system_simulation;
      seed              : in Generator) return Double is abstract;

   -- simulation of a queueing system : next arrival, next departure and
   -- compute st has to be defined for each QS
   -- * Simulation_Time : date of end of simulation relative to 0
   -- * Consumer_Nb_Instance : number of consumer task job in an hyper period
   --( ex : MP1 simulation)
   --
   procedure simulate
     (a_queueing_system    : in out generic_queueing_system_simulation'class;
      simulation_time      : in     Double;
      consumer_nb_instance : in     resp_time_consumer_range);

   -- display the simulation results (mean service time, mean waiting time,
   --...)
   --
   procedure simulation_results
     (a_queueing_system : in generic_queueing_system_simulation'class);

   -- generate arrival rate and service rate of a qs :
   -- * Utilization : the utilization ot the qs
   -- * Max_Mu : the maximum service rate
   --
   procedure generate_arrival_and_service_rate
     (a_queueing_system : in out generic_queueing_system_simulation'class;
      utilization       : in     Double;
      seed              : in     Generator;
      max_mu            : in     Natural := 4000);

end queueing_system.simulation;
