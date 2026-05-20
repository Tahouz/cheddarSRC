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
with Efficiency_Test; 			use Efficiency_Test;
with Framework_Config; 			use Framework_Config;

procedure call_test_pa
is
   --Configuration for the task generator--------
   number_of_task 		: Integer := 5;
   processor_utilization 	: Float := 0.00;
   cache_utilization		: Float := 5.0;
   reuse_factor			: Float := 0.6;
   cache_size			: Integer := 256;
   ----------------------------------------------

   --Configuration for the scheduling simulator--
   default_Period		: Integer := 1000;
   ----------------------------------------------
   H				: Integer := 0;
   Time_And_Date  		: TIME;
   filename 	  		: Unbounded_String;
   C		  		: Character;
   sys				: System;
   ----------------------------------------------
   Dir_String : String := "/home/namtran/CHEDDAR/trunk/src/framework_examples/priority_assignment_examples/log/efficiency/";
   PU_String : Unbounded_String;
   PA_String : Unbounded_String;
   Input_Filename : Unbounded_String;
begin
   loop
      case GNAT.Command_Line.Getopt ("f: u: n: t: p: d:") is
         when ASCII.NUL =>
            exit;
         when 'f' =>
            Input_Filename := To_Unbounded_String (GNAT.Command_Line.Parameter);
            Put_Line(To_String(Input_Filename));
         when 'u' =>
            PU_String := To_Unbounded_String (GNAT.Command_Line.Parameter);
            processor_utilization := (Float'Value(To_String(PU_String))/100.0);
         when 'n' =>
            Put_Line("Number of tasks: " & GNAT.Command_Line.Parameter);
            number_of_task := Integer'Value(GNAT.Command_Line.Parameter);
         when 't' =>
            Put_Line("Test mode: " & GNAT.Command_Line.Parameter);
            C := GNAT.Command_Line.Parameter(1);
         when 'p' =>
            Put_Line("Priority Assignment Algorithm: " & GNAT.Command_Line.Parameter);
            PA_String := To_Unbounded_String (GNAT.Command_Line.Parameter);
         when 'd' =>
            Put_Line("Debug Level: " & GNAT.Command_Line.Parameter);
            Cheddar_Debug := No_Debug;
         when others =>
            OS_Exit(0);
      end case;
   end loop;

   --     if (processor_utilization = 0.00 AND number_of_task = 5) then
   --        Put_Line("Choose test: ");
   --        Get(c);
   --        Put_Line("");
   --     end if;

   if(c =  'A')then
      test_OPA;
   elsif (c = 'B') then
      begin
         Set_Directory("framework_examples/priority_assignment_examples/log/efficiency/" & To_String(PU_String) & "/");
      exception
         when Ada.IO_Exceptions.Name_Error  =>
            Set_Directory("framework_examples/priority_assignment_examples/log/efficiency/");
            Create_Directory(New_Directory => To_String(PU_String));
            Set_Directory("framework_examples/priority_assignment_examples/log/efficiency/" & To_String(PU_String) & "/");
      end;

      Time_And_Date := Clock;
      filename := To_Unbounded_String(Image(Date => Time_And_Date));
      Create_Directory(To_String(filename));
      Set_Directory(To_String(filename));

      Delay(0.5);
   elsif (c = 'C') then
         begin
            Set_Directory("framework_examples/priority_assignment_examples/log/efficiency/" & To_String(PU_String) & "/");
         exception
            when Ada.IO_Exceptions.Name_Error  =>
               Set_Directory("framework_examples/priority_assignment_examples/log/efficiency/");
               Create_Directory(New_Directory => To_String(PU_String));
               Set_Directory("framework_examples/priority_assignment_examples/log/efficiency/" & To_String(PU_String) & "/");
         end;

         Time_And_Date := Clock;
         filename := To_Unbounded_String(Image(Date => Time_And_Date));
         Create_Directory(To_String(filename));
         Set_Directory(To_String(filename));

         generate_test_cases(filename  	=> filename,
                             N         	=> number_of_task,
                             PU       	=> processor_utilization,
                             CU        	=> cache_utilization,
                             CS        	=> cache_size,
                             RF        	=> reuse_factor,
                             PU_String  => To_String(PU_String));

      Delay(1.0);
   elsif (c='D') then
      Set_Directory(Dir_String
                    & To_String(PU_String) & "/"
                    & To_String(Input_Filename) & "/");
      assign_priority(To_String(Input_Filename),To_String(PU_String), To_String(PA_String), Dir_String);
   elsif (c='E') then
      Cheddar_Debug := No_Debug;
      Set_Directory("framework_examples/priority_assignment_examples/error/");
      error_checker(Filename  => "2016-01-19 10:32:39",
                    PA_String => "OPA_CRPD_PT_Binomial_Coefficient");
   end if;

end call_test_pa;
