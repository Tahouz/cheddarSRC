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

with audsley_opa_test;  		use audsley_opa_test;
with Ada.Strings.Unbounded; 		use Ada.Strings.Unbounded;
with Ada.Calendar; 			use Ada.Calendar;
with Ada.Calendar.Formatting;		use Ada.Calendar.Formatting;
with Ada.Directories;	 		use Ada.Directories;
with Ada.Text_IO; 			use Ada.Text_IO;
with Systems; 				use Systems;
with GNAT.Command_Line;
with GNAT.OS_Lib;                       use GNAT.OS_Lib;
with Ada.Float_Text_IO;		    	use Ada.Float_Text_IO;
with Ada.IO_Exceptions;
with audsley_opa_crpd_test;		use audsley_opa_crpd_test;
with cache_access_profile_util; 	use cache_access_profile_util;
with scheduling_simulation_util;	use scheduling_simulation_util;
with feasibility_interval_util; 	use feasibility_interval_util;
with wcrt_crpd_util; 			use wcrt_crpd_util;
with Framework_Config; 			use Framework_Config;
with architecture_factory;		use architecture_factory;
with unbounded_strings; 		use unbounded_strings;

procedure call_test_cache
is
   --Configuration for the task generator--------
   number_of_task 		: Integer := 5;
   processor_utilization 	: Float := 0.70;
   cache_utilization		: Float := 2.0;
   reuse_factor			: Float := 0.3;
   cache_size			: Integer := 256;
   ----------------------------------------------

   --Configuration for the scheduling simulator--
   default_Period		: Integer := 1000000;
   ----------------------------------------------
   H				: Integer := 0;
   Time_And_Date  		: TIME;
   filename 	  		: Unbounded_String;
   sim_id 			: Integer;
   sys				: System;
   ----------------------------------------------
   PU_String : Unbounded_String;
   RF_String : Unbounded_String;
   SP_String : Unbounded_String;
   NT_String : Unbounded_String;

   exp_dir : STRING := "/home/hntran/Dev/cheddar/trunk/src/framework_examples/cache_analysis_examples/xml/";
   ----------------------------------------------
   test_mode : Character := 'A';
begin
   loop
      case GNAT.Command_Line.Getopt ("u: n: c: t: h: d: i:") is
         when ASCII.NUL =>
            exit;
         when 'u' =>
            Put_Line("Processor Utilization: " & GNAT.Command_Line.Parameter);
            PU_String := To_Unbounded_String (GNAT.Command_Line.Parameter);
            processor_utilization := (Float'Value(To_String(PU_String))/100.0);
         when 'n' =>
            Put_Line("Number of tasks: " & GNAT.Command_Line.Parameter);
            NT_String := To_Unbounded_String (GNAT.Command_Line.Parameter);
            number_of_task := Integer'Value(GNAT.Command_Line.Parameter);
         when 'c' =>
            Put_Line("Cache reuse factor: " & GNAT.Command_Line.Parameter);
            RF_String := To_Unbounded_String (GNAT.Command_Line.Parameter);
            reuse_factor := (Float'Value(To_String(RF_String))/100.0);
         when 'h' =>
            Put_Line("Scheduling period: " & GNAT.Command_Line.Parameter);
            SP_String := To_Unbounded_String (GNAT.Command_Line.Parameter);
            default_Period := Integer'Value(To_String(SP_String));
         when 't' =>
            Put_Line("Test mode: " & GNAT.Command_Line.Parameter);
            test_mode := GNAT.Command_Line.Parameter(1);
         when 'd' =>
            Put_Line("Debug Level: " & GNAT.Command_Line.Parameter);
            Cheddar_Debug := No_Debug;
         when 'i' =>
            Put_Line("Sim ID: " & GNAT.Command_Line.Parameter);
            sim_id := Integer'Value(GNAT.Command_Line.Parameter);
         when others =>
            OS_Exit(0);
      end case;
   end loop;

   Time_And_Date := Clock;
   filename := To_Unbounded_String(Image(Date => Time_And_Date)) & "_" & suppress_space(sim_id'Img);

   if(test_mode = 'A') then
      Set_Directory(exp_dir);
      test_cache_aware_scheduling_simulator_with_case_study;
   elsif(test_mode = 'B') then
      begin
         Set_Directory(exp_dir & To_String(PU_String) & "/");
      exception
         when Ada.IO_Exceptions.Name_Error  =>
            Set_Directory(exp_dir);
            Create_Directory(New_Directory => To_String(PU_String));
            Set_Directory(exp_dir & To_String(PU_String) & "/");
      end;

      test_feasibility_interval(file_name => filename,
                                N         => number_of_task,
                                PU        => processor_utilization,
                                CU        => cache_utilization,
                                CS        => cache_size,
                                RF        => reuse_factor);
   elsif(test_mode = 'C') then
      Test_WCRT_CRPD;
   elsif(test_mode = 'D') then
      Test_Multiset_Intersection;
   elsif(test_mode = 'E') then
      begin
         Set_Directory(exp_dir & To_String(NT_String) & "/" & To_String(PU_String) & "/");
      exception
         when Ada.IO_Exceptions.Name_Error  =>
            Set_Directory(exp_dir);
            Create_Directory(New_Directory => To_String(NT_String));
            Set_Directory(exp_dir & To_String(NT_String) & "/");
            Create_Directory(New_Directory => To_String(PU_String));
            Set_Directory(exp_dir & To_String(NT_String) & "/" & To_String(PU_String) & "/");
      end;

      Test_Cache_Aware_Scheduling_Simulator_Computation_Time(file_name 		 => filename,
                                                             N         		 => number_of_task,
                                                             PU        		 => processor_utilization,
                                                             CU        		 => cache_utilization,
                                                             CS        		 => cache_size,
                                                             RF        		 => reuse_factor,
                                                             H         		 => 0,
                                                             With_Harmonic_Tasks => False);
   elsif(test_mode = 'F') then
      begin
         Set_Directory(exp_dir & To_String(NT_String) & "/");
      exception
         when Ada.IO_Exceptions.Name_Error  =>
            Set_Directory(exp_dir);
            Create_Directory(New_Directory => To_String(NT_String));
            Set_Directory(exp_dir & To_String(NT_String) & "/");
      end;

      begin
         Set_Directory(exp_dir & To_String(NT_String) & "/" & To_String(PU_String) & "/");
      exception
         when Ada.IO_Exceptions.Name_Error  =>
            Set_Directory(exp_dir);
            Create_Directory(New_Directory => To_String(NT_String) & "/" & To_String(PU_String));
            Set_Directory(exp_dir & To_String(NT_String) & "/" & To_String(PU_String) & "/");
      end;

      Test_Feasibility_Test_Computation_Time(file_name 		 => filename,
                                             N         		 => number_of_task,
                                             PU        		 => processor_utilization,
                                             CU        		 => cache_utilization,
                                             CS        		 => cache_size,
                                             RF        		 => reuse_factor,
                                             H         		 => 0,
                                             With_Harmonic_Tasks => False);
   elsif(test_mode = 'G') then
    	Process_Data(Exp_Dir,To_String(PU_String));
   end if;

end call_test_cache;
