
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

with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Text_IO;                   use Text_IO;

with Tasks;                     use Tasks;
with Systems; use Systems;
with Task_Set;                  use Task_Set;
use Task_Set.Generic_Task_Set;
with Scheduler_Interface;       use Scheduler_Interface;
with unbounded_strings;         use unbounded_strings;
with Random_Tools;              use Random_Tools;
with processors; use processors;
with core_units;  use core_units;
with Processor_Set;             use Processor_Set;
use Processor_Set.Generic_Processor_Set;
with Buffer_Set;                use Buffer_Set;
use Buffer_Set.Generic_Buffer_Set;
with Buffers; use Buffers;
use Buffers.Buffer_Roles_Package;
with natural_util;              use natural_util;
with double_util;               use double_util;
with Queueing_Systems;          use Queueing_Systems;
with Doubles;                   use Doubles;

package body Random_Project is

   procedure Random_Project_1_N
     (Nb_Prod      : in Buffer_Roles_Range;
      Per_Max_Prod : in Natural;
      Per_Cons     : in Natural;
      Dea_Max      : in Natural;
      Max_Base_Per : in Natural;
      Sys          : out System)
   is

   begin

      Random_Project
        (Nb_Prod,
         1,
         Per_Max_Prod,
         Per_Cons,
         Per_Cons,
         Dea_Max,
         Max_Base_Per,
         Sys);

   end Random_Project_1_N;

   procedure Random_Project
     (Nb_Prod      : in Buffer_Roles_Range;
      Nb_Cons      : in Buffer_Roles_Range;
      Per_Max_Prod : in Natural;
      Per_Max_Cons : in Natural;
      Per_Min_Cons : in Natural;
      Dea_Max      : in Natural;
      Max_Base_Per : in Natural;
      Sys          : out System)
   is

      -- variables
      Offset                        : Offsets_Table;
      Roles                         : Buffer_Roles_Table;
      Tptr                          : Generic_Task_Ptr;
      Cpu                           : Unbounded_String :=
        To_Unbounded_String ("cpu");
      Ea                            : Unbounded_String :=
        To_Unbounded_String ("ea");
      Per_Prod                      : Natural;
      Per_Cons                      : Natural;
      Seed                          : Generator;
      Aux_Prod, Flow_Aux, Flow_Prod : Double;
      Min, Max                      : Natural;
      Deadline                      : Natural;
      Lcm                           : Natural;
	core1 : core_unit_ptr;

   begin

      Lcm := Max_Base_Per + 1;
      while (Lcm > Max_Base_Per) loop

         -- initialization
         initialize (Roles);
         initialize (Offset);
         Reset (Seed);
         Initialize (Sys);
         Aux_Prod  := 0.0;
         Flow_Prod := 0.0;

         -- consumers generation
         for I in 1 .. Nb_Cons loop
            Per_Cons := Get_Rand_Parameter (Per_Min_Cons, Per_Max_Cons, Seed);

            Deadline :=
               Get_Rand_Parameter (Per_Cons, Dea_Max * Per_Cons, Seed);
	    Add_Task (
        	My_Tasks               => Sys.Tasks,
		A_Task		       => Tptr,
         	Name                   => To_Unbounded_String ("Cons"),
         	Cpu_Name               => Cpu,
		core_name		=> To_Unbounded_String (""),
         	Address_Space_Name     => Ea,
         	Task_Type              => Periodic_Type,
         	Start_Time             => 0,
         	Capacity               => 1,
         	Period                 => Per_Cons,
         	Deadline               => Deadline,
         	Jitter                 => 0,
         	Blocking_Time          => 0,
         	Priority               => 1,
         	Criticality            => 0,
         	Policy                 => Sched_Fifo,
                Offset		       => offset
            );

            Roles.entries (0).item          := Tptr.name;
            Roles.entries (0).data.size     := 1;
            Roles.entries (0).data.the_role := Queuing_Consumer;

            Roles.nb_entries := Nb_Prod + 1;

            Aux_Prod := Aux_Prod + 1.0 / Double (Per_Cons);

         end loop;

         -- Per_Prod := Per_Cons;

         Max      := Per_Max_Prod;
         Flow_Aux := Aux_Prod - Double (Nb_Prod - 1) / Double (Max);

         -- test of the maximum
         if (Flow_Aux < 0.0) then

            -- new maximum calculation
            Max      := Natural (Nb_Prod) * Per_Cons;
            Flow_Aux := 1.0 / Double (Per_Cons) -
                        Double (Nb_Prod - 1) / Double (Max);
            Put_Line ("No solution with period maximum :" & Per_Max_Prod'Img);
            Put_Line ("new  maximum :" & Max'Img);

         end if;

         -- Producers generation
         for J in 1 .. Nb_Prod loop
            -- period of producers is based on the respect of the conservative
            --data flow : the data produce is egal to the data consum
            if (J = Nb_Prod) -- last producer
            then
               Per_Prod := Natural (Double'Ceiling (1.0 / Aux_Prod));
            --Put_Line ("Period = " & Per_Prod'Img);
            else
               Min      := Natural (Double'Ceiling (1.0 / Flow_Aux));
               Per_Prod := Get_Rand_Parameter (Min, Max, Seed);
               --Put_Line ("Period = " & Per_Prod'Img);

            end if;

            -- last producer period calculation
            Aux_Prod := Aux_Prod - 1.0 / Double (Per_Prod);

            -- bandswith for next producers
            Flow_Aux := Flow_Aux -
                        1.0 / Double (Per_Prod) +
                        1.0 / Double (Max);

            -- intermediary calculation of total data flow of the producers
            Flow_Prod := Flow_Prod + 1.0 / Double (Per_Prod);

            -- add the tasks to the system
            Deadline :=
               Get_Rand_Parameter (Per_Prod, Dea_Max * Per_Prod, Seed);
	    Add_Task (
                My_Tasks               => Sys.Tasks,
                A_Task                 => Tptr,
                Name                   => (To_Unbounded_String ("Prod") & format (Natural (J))),
                Cpu_Name               => Cpu,
		core_name		=> To_Unbounded_String (""),
                Address_Space_Name     => Ea,
                Task_Type              => Periodic_Type,
                Start_Time             => 0,
                Capacity               => 1,
                Period                 => Per_Prod,
                Deadline               => Deadline,
                Jitter                 => 0,
                Blocking_Time          => 0,
                Priority               => 1,
                Criticality            => 0,
                Policy                 => Sched_Fifo,
                Offset                 => Offset
            );

            -- array of maximum generation
            Roles.entries (J).item          := Tptr.name;
            Roles.entries (J).data.size     := 1;
            Roles.entries (J).data.the_role := Queuing_Producer;

         end loop;

         -- add the processor
         Add_core_unit
           (Sys.core_units,
 	    core1,
            Cpu & to_unbounded_string("_core"),
            preemptive,
            0,
            0.0,
            0,
            0,
            0,
            empty_string,
            Posix_1003_Highest_Priority_First_Protocol,
            empty_string);

         Add_Processor
           (Sys.Processors,
            Cpu,
            empty_string,
            core1);

         -- add the buffer
         Add_Buffer
           (Sys.Buffers,
            To_Unbounded_String ("Buffer"),
            1,
            Cpu,
            Ea,
            Qs_Pp1,
            Roles);

         -- display the total data of producers : checking
         -- Put_Line ("Producers data flow = " & Flow_Prod'Img);

         Lcm := Scheduling_Period (Sys.Tasks, Cpu);
         if (Max_Base_Per = 0) then
            Lcm := 0;
         end if;

         --Put_Line("LCM = " & LCM'img);

      end loop;

   end Random_Project;

   procedure Random_Project_1_N_Harmonic
     (Nb_Prod       : in Buffer_Roles_Range;
      Coef_Max_Prod : in Natural;
      Per_Cons      : in Natural;
      Dea_Max       : in Natural;
      Sys           : out System)
   is

      -- variables
core1 : core_unit_ptr;
      Offset      : Offsets_Table;
      Roles       : Buffer_Roles_Table;
      Tptr        : Generic_Task_Ptr;
      Cpu         : Unbounded_String := To_Unbounded_String ("cpu");
      Ea          : Unbounded_String := To_Unbounded_String ("ea");
      Per_Prod    : Natural;
      Seed        : Generator;
      Flow_Aux    : Double;
      Flow_Prod   : Double;
      Min, Max    : Natural;
      Last_Period : Natural;
      Deadline    : Natural;

   begin

      -- initialization
      initialize (Roles);
      initialize (Offset);
      Reset (Seed);
      Initialize (Sys);

      -- add the consumer
      Deadline := Get_Rand_Parameter (Per_Cons, Dea_Max * Per_Cons, Seed);
      Add_Task (
                My_Tasks               => Sys.Tasks,
                A_Task                 => Tptr,
                Name                   => To_Unbounded_String ("Cons"),
                Cpu_Name               => Cpu,
		core_name		=> To_Unbounded_String (""),
                Address_Space_Name     => Ea,
                Task_Type              => Periodic_Type,
                Start_Time             => 0,
                Capacity               => 1,
                Period                 => Per_Cons,
                Deadline               => Deadline,
                Jitter                 => 0,
                Blocking_Time          => 0,
                Priority               => 1,
                Criticality            => 0,
                Policy                 => Sched_Fifo,
                Offset                 => Offset
      );

      Roles.entries (0).item          := Tptr.name;
      Roles.entries (0).data.size     := 1;
      Roles.entries (0).data.the_role := Queuing_Consumer;
      Roles.nb_entries                := Nb_Prod + 1;

      -- variables initialization
      Last_Period := Per_Cons;
      Flow_Aux    := 1.0 / Double (Per_Cons);
      Min         := 2;
      Max         := Coef_Max_Prod;

      -- Put_Line("consumer flow = " & Flow_Aux'img);

      -- first producer
      Per_Prod := Last_Period * Get_Rand_Parameter (Min, Max, Seed);

      Add_Task (
                My_Tasks               => Sys.Tasks,
                A_Task                 => Tptr,
                Name                   => To_Unbounded_String ("Prod1"),
                Cpu_Name               => Cpu,
		core_name		=> To_Unbounded_String (""),
                Address_Space_Name     => Ea,
                Task_Type              => Periodic_Type,
                Start_Time             => 0,
                Capacity               => 1,
                Period                 => Per_Prod,
                Deadline               => Per_Prod,
                Jitter                 => 0,
                Blocking_Time          => 0,
                Priority               => 1,
                Criticality            => 0,
                Policy                 => Sched_Fifo,
                Offset                 => Offset
      );

      Roles.entries (1).item          := Tptr.name;
      Roles.entries (1).data.size     := 1;
      Roles.entries (1).data.the_role := Queuing_Producer;

      Last_Period := Per_Prod;
      Flow_Aux    := Flow_Aux - 1.0 / Double (Per_Prod);
      Flow_Prod   := 1.0 / Double (Per_Prod);
      -- Put_Line("P 1" & " = " & Per_Prod'img);

      -- Producers generation
      for J in 2 .. Nb_Prod loop
         if (J /= Nb_Prod) -- not the last producer
         then
            if (equal (Flow_Aux, 1.0 / Double (Last_Period))) then
               Min := 2;
            else
               Min := 1;
            end if;

            -- new producer period
            Per_Prod    := Last_Period * Get_Rand_Parameter (Min, Max, Seed);
            Last_Period := Per_Prod;

            -- data flow still available
            Flow_Aux := Flow_Aux - 1.0 / Double (Per_Prod);
         else
            Per_Prod := Last_Period;
         end if;

         Flow_Prod := Flow_Prod + 1.0 / Double (Per_Prod);

         -- Put_Line("P" & J'Img & " = " & Per_Prod'Img);

         -- add the tasks to the system
         Deadline := Get_Rand_Parameter (Per_Prod, Dea_Max * Per_Prod, Seed);
         Add_Task (
                My_Tasks               => Sys.Tasks,
                A_Task                 => Tptr,
                Name                   => (To_Unbounded_String ("Prod") & format (Natural (J))),
                Cpu_Name               => Cpu,
		core_name		=> To_Unbounded_String (""),
                Address_Space_Name     => Ea,
                Task_Type              => Periodic_Type,
                Start_Time             => 0,
                Capacity               => 1,
                Period                 => Per_Prod,
                Deadline               => Deadline,
                Jitter                 => 0,
                Blocking_Time          => 0,
                Priority               => 1,
                Criticality            => 0,
                Policy                 => Sched_Fifo,
                Offset                 => Offset
         );

         Roles.entries (J).item          := Tptr.name;
         Roles.entries (J).data.size     := 1;
         Roles.entries (J).data.the_role := Queuing_Producer;

      end loop;

      -- Put_Line("producer flow = " & Flow_prod'Img);

      -- add the processor
         Add_core_unit
           (Sys.core_units,
 	    core1,
            Cpu & to_unbounded_string("_core"),
            preemptive,
            0,
            0.0,
            0,
            0,
            0,
            empty_string,
            Posix_1003_Highest_Priority_First_Protocol,
            empty_string);

         Add_Processor
           (Sys.Processors,
            Cpu,
            empty_string,
            core1);


      -- add the buffer
      Add_Buffer
        (Sys.Buffers,
         To_Unbounded_String ("Buffer"),
         1,
         Cpu,
         Ea,
         Qs_Pp1,
         Roles);

   end Random_Project_1_N_Harmonic;

end Random_Project;
