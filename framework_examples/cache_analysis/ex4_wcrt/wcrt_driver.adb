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
--    $Rev: 6232 $
--    $Date: 2026-01-29 17:36:40 +0100 (jeu., 29 janv. 2026) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Text_IO;			use Ada.Text_IO;
with Cache_Access_Profile_Util;		use Cache_Access_Profile_Util;
with Scheduler.Fixed_Priority.Hpf; 	use Scheduler.Fixed_Priority.Hpf;
with Task_Set; 				use Task_Set;
with Ada.Strings.Unbounded; 		use Ada.Strings.Unbounded;
with Call_Framework_Interface; 		use Call_Framework_Interface;
with Cache_Access_Profile_Set; 		use Cache_Access_Profile_Set;
with Caches; 				use Caches;
with Scheduling_Analysis; 		use Scheduling_Analysis;
with initialize_framework; 		use initialize_framework;
with Caches;				use Caches.Cache_Blocks_Table_Package;
with Cache_Block_Set;			use Cache_Block_Set;
with Tasks; 				use Tasks;
with Feasibility_Test; 			use Feasibility_Test;
with Caches;				use Caches.Cache_Blocks_Table_Package;
with Scheduling_Analysis;		use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with feasibility_test.periodic_task_worst_case_response_time_fixed_priority;
use feasibility_test.periodic_task_worst_case_response_time_fixed_priority;

procedure wcrt_driver
   is
      my_scheduler 		: Hpf_Scheduler;
      my_tasks			: Tasks_Set;
      processor_name 		: Unbounded_String;
      msg 			: Unbounded_String;
      --response_time 		: Response_Time_Table;
      CRPD_Computation_Approach : CRPD_Computation_Approach_Type := ECB_Union_Multiset;
      Block_Reload_Time 	: Natural := 1;
      My_CAPs 			: Cache_Access_Profiles_Set;

      cap_1 			: Cache_Access_Profile_Ptr;
      cap_2 			: Cache_Access_Profile_Ptr;
      cap_3 			: Cache_Access_Profile_Ptr;

      a_cache_block	 	: Cache_Block_Ptr;
      a_cache_block_tbl	: Cache_Blocks_Table;

      response_time		: Response_Time_Table;
   begin
      Set_Initialize;

      for i in 0..3 loop
         a_cache_block := new Cache_Block;
         a_cache_block.cache_block_number := i+1;
         Add(a_cache_block_tbl,a_cache_block);
      end loop;

      cap_1 := new Cache_Access_Profile;
      cap_1.name := To_Unbounded_String("CAP_1");
      Add(cap_1.ECBs, a_cache_block_tbl.Entries(0));
      Add(cap_1.ECBs, a_cache_block_tbl.Entries(1));
      Add(cap_1.ECBs, a_cache_block_tbl.Entries(2));

      cap_2 := new Cache_Access_Profile;
      cap_2.name := To_Unbounded_String("CAP_2");
      Add(cap_2.UCBs, a_cache_block_tbl.Entries(2));
      --
      Add(cap_2.ECBs, a_cache_block_tbl.Entries(2));
      Add(cap_2.ECBs, a_cache_block_tbl.Entries(3));

      cap_3 := new Cache_Access_Profile;
      cap_3.name := To_Unbounded_String("CAP_3");
      Add(cap_3.UCBs, a_cache_block_tbl.Entries(0));
      Add(cap_3.UCBs, a_cache_block_tbl.Entries(1));
      Add(cap_3.UCBs, a_cache_block_tbl.Entries(2));
      Add(cap_3.UCBs, a_cache_block_tbl.Entries(3));
      --
      Add(cap_3.ECBs, a_cache_block_tbl.Entries(0));
      Add(cap_3.ECBs, a_cache_block_tbl.Entries(1));
      Add(cap_3.ECBs, a_cache_block_tbl.Entries(2));
      Add(cap_3.ECBs, a_cache_block_tbl.Entries(3));

      Add(My_CAPs,cap_1);
      Add(My_CAPs,cap_2);
      Add(My_CAPs,cap_3);

      Add_Task(My_Tasks                  => my_tasks,
               Name                      => To_Unbounded_String("Task_1"),
               Cpu_Name                  => To_Unbounded_String("CPU_A"),
               Address_Space_Name        => To_Unbounded_String("ADDR_A"),
               Task_Type                 => Periodic_Type,
               Start_Time                => 0,
               Capacity                  => 1,
               Period                    => 40,
               Deadline                  => 40,
               Jitter                    => 0,
               Blocking_Time             => 0,
               Priority                  => 3,
               Criticality               => 0,
               Policy                    => Sched_Fifo,
               Cache_Access_Profile_Name => To_Unbounded_String("CAP_1"));

      Add_Task(My_Tasks                  => my_tasks,
               Name                      => To_Unbounded_String("Task_2"),
               Cpu_Name                  => To_Unbounded_String("CPU_A"),
               Address_Space_Name        => To_Unbounded_String("ADDR_A"),
               Task_Type                 => Periodic_Type,
               Start_Time                => 0,
               Capacity                  => 2,
               Period                    => 40,
               Deadline                  => 40,
               Jitter                    => 0,
               Blocking_Time             => 0,
               Priority                  => 2,
               Criticality               => 0,
               Policy                    => Sched_Fifo,
               Cache_Access_Profile_Name => To_Unbounded_String("CAP_2"));

      Add_Task(My_Tasks                  => my_tasks,
               Name                      => To_Unbounded_String("Task_3"),
               Cpu_Name                  => To_Unbounded_String("CPU_A"),
               Address_Space_Name        => To_Unbounded_String("ADDR_A"),
               Task_Type                 => Periodic_Type,
               Start_Time                => 0,
               Capacity                  => 2,
               Period                    => 40,
               Deadline                  => 40,
               Jitter                    => 0,
               Blocking_Time             => 0,
               Priority                  => 1,
               Criticality               => 0,
               Policy                    => Sched_Fifo,
               Cache_Access_Profile_Name => To_Unbounded_String("CAP_3"));

      periodic_task_worst_case_response_time_fixed_priority.Compute_Response_Time
        (My_Scheduler              => my_scheduler,
         My_Tasks                  => my_tasks,
         Processor_Name            => To_Unbounded_String("CPU_A"),
         Msg                       => msg,
         Response_Time             => response_time,
         With_CRPD                 => True,
         CRPD_Computation_Approach => CRPD_Computation_Approach,
         Block_Reload_Time         => Block_Reload_Time,
         My_Cache_Access_Profiles  => My_CAPs);

      for i in 0..Response_Time.nb_entries-1 loop
         Put_Line(Integer(Response_Time.entries(i).data)'Img);
      end loop;

end wcrt_driver;
