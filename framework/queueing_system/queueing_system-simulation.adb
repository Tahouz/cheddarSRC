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

with qs_tools; use qs_tools;

package body queueing_system.simulation is

   procedure simulate
     (a_queueing_system    : in out generic_queueing_system_simulation'class;
      simulation_time      : in     Double;
      consumer_nb_instance : in     resp_time_consumer_range)
   is

      package double_io is new Text_IO.Float_IO (Double);
      use double_io;

      function min (x : in Double; y : in Double) return Double is
      begin
         if x < y then
            return x;
         else
            return y;
         end if;
      end min;

      mtba : constant Double :=
        1.0 / a_queueing_system.arrival_rate.entries (0).data;
      mst : constant Double :=
        1.0 / a_queueing_system.service_rate.entries (0).data;
      rho : constant Double := mst / mtba;

      t_prev      : Double := 0.0;
      t_arr       : Double := 0.0;
      t_dep       : Double := 0.0;
      nbcustomers : Double := 0.0;

      -- mean inter arrival time computation
      nb_it   : Double := 0.0;
      tmp_it  : Double := 0.0;
      sim_mit : Double := 0.0;

      -- mean service time computation
      nb_st       : Double := 0.0;
      tmp_st      : Double := 0.0;
      tmp_ptr     : double_ptr;
      sim_mst     : Double := 0.0;
      sim_var_mst : Double := 0.0;

      -- mean queueing system waiting time computation
      arrival_date : generic_index_lst.list;
      sim_mwt      : Double := 0.0;
      tmp_wt       : Double := 0.0;
      nb_wt        : Double := 0.0;

      -- mean queueing system occupation computation
      sim_mnc : Double := 0.0;

      seed    : Generator;
      seed_rt : Generator;

   begin
      -- initialization
      Reset (seed, 0);
      Reset (seed_rt, 0);

      -- response time (MP1)
      a_queueing_system.consumer_resp_time.nb_entries := consumer_nb_instance;
      a_queueing_system.consumer_resp_time_cpt        := 0;
      for i in 0 .. a_queueing_system.consumer_resp_time.nb_entries - 1 loop
         a_queueing_system.consumer_resp_time.entries (i).data := --0.0;
           get_rand_parameter (0.0, mst, seed_rt);

         -- Put_Line("r" & I'Img & " " & Ri'Img);
      end loop;

      -- first arrival (obviously the first event)
      tmp_it := compute_inter_arrival_time (a_queueing_system, seed);
      nb_it  := nb_it + 1.0;

      t_arr   := tmp_it;
      sim_mit := sim_mit + tmp_it;
      t_prev  := tmp_it;
      --      Nbcustomers := 1.0;

      -- waiting time computation
      tmp_ptr     := new Double;
      tmp_ptr.all := t_arr;
      add (arrival_date, tmp_ptr);

      -- first departure
      -- a remettre (MP1)??      A_Queueing_System.T_Arr := Tmp_Wt;
      tmp_st      := compute_service_time (a_queueing_system, seed);
      nb_st       := nb_st + 1.0;
      sim_mst     := sim_mst + tmp_st;
      sim_var_mst := sim_var_mst + tmp_st * tmp_st;

      -- next departure date
      t_dep := t_arr + tmp_st;
      --      A_Queueing_System.Empty_Buffer := True;

      --      -- waiting time of 1 message in the system
      --      Tmp_Wt := Get_Tail(Arrival_Date).all;
      --      Delete(Arrival_Date,Get_Tail(Arrival_Date));
      --      Tmp_Wt := T_Dep - Tmp_Wt;
      --      Sim_Mwt := Sim_Mwt + Tmp_Wt;
      --      Nb_Wt := Nb_Wt + 1.0;

      --      -- new arrival
      --      Tmp_It := Compute_Arrival(A_Queueing_System,Seed);
      --      A_Queueing_System.T_Arr := A_Queueing_System.T_Arr + Tmp_It;
      --      Sim_Mit := Sim_Mit + Tmp_It;
      --      Nb_It := Nb_It + 1.0;

      --      -- waiting time computation
      --      Tmp_Ptr := new Double;
      --      Tmp_Ptr.All := A_Queueing_System.T_Arr;
      --      Add (Arrival_Date, Tmp_Ptr);

      while (min (t_arr, t_dep) < simulation_time) loop
         -- arrival
         if (t_arr < t_dep) then
            -- queueing system average occupation computation
            sim_mnc     := sim_mnc + nbcustomers * (t_arr - t_prev);
            nbcustomers := nbcustomers + 1.0;
            t_prev      := t_arr;

            -- new arrival date
            tmp_it  := compute_inter_arrival_time (a_queueing_system, seed);
            t_arr   := t_arr + tmp_it;
            sim_mit := sim_mit + tmp_it;
            nb_it   := nb_it + 1.0;

            -- waiting time computation
            tmp_ptr     := new Double;
            tmp_ptr.all := t_arr;
            add (arrival_date, tmp_ptr);

         -- departure
         else
            -- queueing system average occupation computation
            sim_mnc     := sim_mnc + nbcustomers * (t_dep - t_prev);
            nbcustomers := nbcustomers - 1.0;
            t_prev      := t_dep;

            tmp_wt := get_tail (arrival_date).all;
            if (nbcustomers > 0.0) then
               a_queueing_system.empty_buffer := False;
               t_arr                          := t_dep;
               tmp_st := compute_service_time (a_queueing_system, seed);
               t_dep                          := t_dep + tmp_st;

            else
               a_queueing_system.empty_buffer := True;
               t_arr                          := tmp_wt; -- oldest arrivale
               --date not computed
               tmp_st := compute_service_time (a_queueing_system, seed);
               t_dep  := t_arr + tmp_st;

            end if;

            nb_st       := nb_st + 1.0;
            sim_mst     := sim_mst + tmp_st;
            sim_var_mst := sim_var_mst + tmp_st * tmp_st;

            -- waiting time computation
            delete (arrival_date, get_tail (arrival_date));
            tmp_wt  := t_dep - tmp_wt;
            sim_mwt := sim_mwt + tmp_wt;
            nb_wt   := nb_wt + 1.0;
         end if;

      end loop;

      -- !! Simulation result !!
      -- utilisation
      a_queueing_system.utilisation := rho;

      -- Mean inter arrival time
      sim_mit                   := sim_mit / nb_it;
      a_queueing_system.sim_mit := sim_mit;

      -- Mean service time
      sim_mst                   := sim_mst / nb_st;
      a_queueing_system.sim_mst := sim_mst;

      -- Mean variance service time
      sim_var_mst                   := sim_var_mst / nb_st - sim_mst * sim_mst;
      a_queueing_system.sim_var_mst := sim_var_mst;

      -- mean waiting time
      sim_mwt                   := sim_mwt / nb_wt;
      a_queueing_system.sim_mwt := sim_mwt;

      -- mean number of customer
      sim_mnc := sim_mnc + nbcustomers * (simulation_time - t_prev);
      sim_mnc                   := sim_mnc / simulation_time;
      a_queueing_system.sim_mnc := sim_mnc;

      --      -- !! theoric results !!
      --      -- mg1
      --      New_Line;
      --      Put_Line("MG1");
      --      -- waiting time
      --      Tmp := Sim_Mst + Lambda * ( Sim_Mst * Sim_Mst + Sim_Var_Mst)
      --         /(2.0*(1.0 - Lambda * Mst)); -- Mst));

      --      --         Put_Line("Mean packet waiting time value : " &
      --Tmp'Img);
      --      Put_Line("AWMG1 " & Rho'Img & " " & Tmp'Img);

      --      -- average occupation
      --      Tmp := Tmp * Lambda;
      --      --         Put_Line("Mean packet number value : " & Tmp'Img);
      --      Put_Line("AOMG1 " & Rho'Img & " " & Tmp'Img);

      --      -- mp1
      --      New_Line;
      --      Put_Line("MP1");
      --      -- service time
      --      Mp1_Mst := Mst /(2.0 * (1.0 - Lambda * (Mst/2.0)));
      --      --         Put_Line("Mean service time value : " & Mp1_Mst'Img);
      --      Put_Line("ASTMP1 " & Rho'Img & " " & Mp1_Mst'Img);

      --      Rau := Lambda * Mp1_Mst;
      --      -- variance
      --      Nb_Rt := 0.0;
      --      Prev_Rt   := --10.0;
      --         A_Queueing_System.Consumer_Resp_Time.Entries
      --         (A_Queueing_System.Consumer_Resp_Time.Nb_Entries - 1).Data;
      --      for I in 0 .. A_Queueing_System.Consumer_Resp_Time.Nb_Entries-
      --            1 loop
      --         Next_Rt := --10.0;
      --            A_Queueing_System.Consumer_Resp_Time.Entries(I).Data;

      --         Wi := Next_Rt + Mst - Prev_Rt;
      --         --Wi := (1.0 - Rau)* (Wi*Wi) / 4.0 + Rau * Wi * Wi;
      --         -- compute the variance
      --         Mp1_Var := Mp1_Var + Wi * Wi;
      --         Mp1_Var_Ro := Mp1_Var_Ro + (Wi * Wi / 4.0);

      --         Prev_Rt := Next_Rt;
      --         Nb_Rt := Nb_Rt + 1.0;
      --      end loop;

      --      -- nouveaux tests
      --      Mp1_Var := Mp1_Var / Nb_Rt;
      --      Mp1_Var_Ro := Mp1_Var_Ro / Nb_Rt;
      --      Put_Line("Mp1_Var " & Rho'Img & " " & Mp1_Var'Img);
      --      Put_Line("Mp1_mst " & Rho'Img & " " & Mp1_Mst'Img);

      --      --1
      --      --     Mp1_Var := (1.0 + Lambda * Mst) * Mp1_Var - Mst * Mst;

      --      --2
      --      --Mp1_Var := ((1.0 + 3.0 * Lambda * Mp1_Mst) / (4.0)) * Mp1_Var -
      --      --Mst * Mst;

      --      --3
      --      --Mp1_Var := Mp1_Var - Mst * Mst;

      --      --4
      --      --      Mp1_Var := 0.0;

      --      --5
      --      --Mp1_Var := (1.0 - Rau) * Mst * Mst / 12.0 + Rau * (Mp1_Var -
      --Mst *
      --      --         Mst);

      --      --6 rho tends vers 0
      --      --Mp1_Var :=Mst * Mst / 12.0 ;

      --      --7 rho tends vers 1
      --      --Mp1_Var := Mp1_Var - Mst * Mst;

      --      -- 8 quelque soit rho
      --      Mp1_Var := (1.0 - Rau) * (Mst * Mst / 12.0) + Rau* (Mp1_Var -
      --Mst *
      --         Mst);

      --      --9
      --      --Mp1_Var := (1.0 - rau) * (Mp1_Var_ro - (Mst * Mst / 2.0)) +
      --rau* (Mp1_Var - Mst * Mst);

      --      -- fin nouveaux tests

      --      -- Mp1_Var := Mp1_Var / Nb_Rt - Mp1_Mst * Mp1_Mst;
      --      --         Mp1_Var :=
      --      --            (1.0 - Rau) * Mst * Mst / 12.0 + Rau * Mp1_Var;
      --      --         Mp1_Var :=
      --      --            ((1.0 + 3.0 * Lambda * Mp1_Mst) / (4.0 * Nb_Rt)) *
      --Mp1_Var -
      --      --            Mp1_Mst * Mp1_Mst;
      --      --                  Put_Line("Mean variance service time value :
      --" & Mp1_Var'Img);
      --      Put_Line("ASTVARMP1 " & Rho'Img & " " & Mp1_Var'Img);

      --      -- waiting time
      --      --         Tmp := Sim_Mst + Lambda * ( Sim_Mst * Sim_Mst +
      --Sim_Var_Mst)
      --      --            /(2.0*(1.0 - Lambda * Sim_Mst));

      --      --Mp1_Var := Sim_Var_Mst;
      --      Tmp := Mp1_Mst + Lambda * ( Mp1_Mst * Mp1_Mst + Mp1_Var)
      --         /(2.0*(1.0 - Lambda * Mst)); -- Mst));

      --      --         Put_Line("Mean packet waiting time value : " &
      --Tmp'Img);
      --      Put_Line("AWMP1 " & Rho'Img & " "  & Tmp'Img);

      --      -- average occupation
      --      Tmp := Tmp * Lambda;
      --      --         Put_Line("Mean packet number value : " & Tmp'Img);
      --      Put_Line("AOMP1 " & Rho'Img & " " & Tmp'Img);

      --      --Tmp := Mst* Mst / 12.0;
      --      --Put_Line("var " & Tmp'Img);

      --      -- mm1
      --      New_Line;
      --      Put_Line("MM1");
      --      -- waiting time
      --      --         Tmp :=  1.0/ (Mu * (1.0 - Lambda /Mu));
      --      Tmp :=  1.0/ (1.0/Sim_Mst * (1.0 - Lambda * Sim_Mst));

      --      --Put_Line("Mean packet waiting time value : " & Tmp'Img);
      --      Put_Line("AWMM1SIM " & Rho'Img & " " & Tmp'Img);

      --      Tmp :=  1.0/ (1.0/Mst * (1.0 - Lambda * Mst));

      --      Put_Line("AWMM1PCONS " & Rho'Img & " " & Tmp'Img);

      --      Tmp :=  1.0/ (1.0/ Mp1_Mst * (1.0 - Lambda * Mp1_Mst));

      --      Put_Line("AWMM1THEO " & Rho'Img & " " & Tmp'Img);

      --      -- average occupation
      --      --Tmp := Mst/(Mtba-Mst); -- system
      --      -- Put_Line("Mean packet number value : " & Tmp'Img);
      --      Tmp := Sim_Mst / (Mtba-Sim_Mst);
      --      Put_Line("AOMM1SIM " & Rho'Img & " " & Tmp'Img);

      --      Tmp := Mst / (Mtba-Mst);
      --      Put_Line("AOMM1PCONS " & Rho'Img & " " & Tmp'Img);

      --      Tmp := Mp1_Mst / (Mtba-Mp1_Mst);
      --      Put_Line("AOMM1THEO " & Rho'Img & " " & Tmp'Img);

      --      --         Tmp := (Lambda * Mst ) / (1.0 - Rau);
      --      --         Put_Line("Mean packet number value : " & Tmp'Img);
      --      --         Mm1_Var := Mst*Mst;
      --      --         Put("service time Variance : " );
      --      --         Put(Mm1_Var,Aft=>4, Exp => 0);
      --      --         New_Line;

      --      -- md1
      --      New_Line;
      --      Put_Line("MD1");
      --      -- waiting time
      --      --         Tmp := (2.0 - Rau) / (2.0* Mu *(1.0-Rau));
      --      --         Put_Line("Mean packet waiting time value : " &
      --Tmp'Img);

      --      Tmp :=
      --         (2.0 - Lambda*Sim_Mst) / ((2.0/Sim_Mst)
      --*(1.0-Lambda*Sim_Mst));
      --      Put_Line("AWMD1SIM " & Rho'Img & " " & Tmp'Img);

      --      Tmp :=
      --         (2.0 - Lambda*Mst) / ((2.0/Mst) *(1.0-Lambda*Mst));
      --      Put_Line("AWMD1PCONS " & Rho'Img & " " & Tmp'Img);

      --      Tmp :=
      --         (2.0 - Lambda*Mp1_Mst) / ((2.0/Mp1_Mst)
      --*(1.0-Lambda*Mp1_Mst));
      --      Put_Line("AWMD1THEO " & Rho'Img & " " & Tmp'Img);

      --      -- average occupation
      --      --         Tmp := (2.0*Rau - Rau*Rau)/(2.0*(1.0-Rau));
      --      --         Put_Line("Mean packet number value : " & Tmp'Img);
      --      Tmp :=
      --         (2.0*Lambda*Sim_Mst - Lambda*Sim_Mst*Lambda*Sim_Mst)/(2.0*(
      --            1.0-Lambda*Sim_Mst));
      --      Put_Line("AOMD1SIM " & Rho'Img & " " & Tmp'Img);

      --      Tmp :=
      --         (2.0*Lambda*Mst - Lambda*Mst*Lambda*Mst)/(2.0*(
      --            1.0-Lambda*Mst));
      --      Put_Line("AOMD1PCONS " & Rho'Img & " " & Tmp'Img);

      --      Tmp :=
      --         (2.0*Lambda*Mp1_Mst - Lambda*Mp1_Mst*Lambda*Mp1_Mst)/(2.0*(
      --            1.0-Lambda*Mp1_Mst));
      --      Put_Line("AOMD1THEO " & Rho'Img & " " & Tmp'Img);

   end simulate;

   procedure simulation_results
     (a_queueing_system : in generic_queueing_system_simulation'class)
   is

   begin
      Put_Line ("Simulation Result");
      New_Line;
      Put_Line
        ("AIT " &
         a_queueing_system.utilisation'img &
         " " &
         a_queueing_system.sim_mit'img);
      Put_Line
        ("AST " &
         a_queueing_system.utilisation'img &
         " " &
         a_queueing_system.sim_mst'img);
      Put_Line
        ("ASTVAR " &
         a_queueing_system.utilisation'img &
         " " &
         a_queueing_system.sim_var_mst'img);
      Put_Line
        ("AW " &
         a_queueing_system.utilisation'img &
         " " &
         a_queueing_system.sim_mwt'img);
      Put_Line
        ("AO " &
         a_queueing_system.utilisation'img &
         " " &
         a_queueing_system.sim_mnc'img);
      New_Line;
   end simulation_results;

   procedure initialize
     (a_queueing_system : in out generic_queueing_system_simulation)
   is

   begin
      initialize (generic_queueing_system (a_queueing_system));

      if a_queueing_system.service_resp_time /= null then
         free (a_queueing_system.service_resp_time);
      end if;

      a_queueing_system.service_resp_time            := new resp_time_table;
      a_queueing_system.service_resp_time.nb_entries := 0;

      a_queueing_system.avg_service := 0.0;
      a_queueing_system.var_service := 0.0;

   end initialize;

   procedure reset
     (a_queueing_system : in out generic_queueing_system_simulation)
   is

   begin
      initialize (generic_queueing_system_simulation (a_queueing_system));
   end reset;

   procedure generate_arrival_and_service_rate
     (a_queueing_system : in out generic_queueing_system_simulation'class;
      utilization       : in     Double;
      seed              : in     Generator;
      max_mu            : in     Natural := 4000)
   is

      tmp_inter_time : Double;

   begin
      -- initialisation
      a_queueing_system.arrival_rate.nb_entries := 1;
      a_queueing_system.service_rate.nb_entries := 1;

      -- arrival rate random generation
      tmp_inter_time := get_rand_parameter (100.0, -- 1000
      Double (max_mu), seed);

      a_queueing_system.arrival_rate.entries (0).data := 1.0 / tmp_inter_time;

      -- compute the departure rate
      a_queueing_system.service_rate.entries (0).data :=
        a_queueing_system.arrival_rate.entries (0).data / utilization;

      -- queueing system utilization
      a_queueing_system.utilisation :=
        a_queueing_system.arrival_rate.entries (0).data /
        a_queueing_system.service_rate.entries (0).data;

   end generate_arrival_and_service_rate;

end queueing_system.simulation;
