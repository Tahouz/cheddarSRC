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

with Ada.Numerics.Aux;                  use Ada.Numerics.Aux;
with Text_IO;                           use Text_IO;
with Framework_Config;                  use Framework_Config;
with Processor_Set;                     use Processor_Set;
use Processor_Set.Generic_Processor_Set;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with Parameters;                        use Parameters;
with Parameters.extended;               use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;
with Scheduler_Interface;               use Scheduler_Interface;
with Processor_Set;                     use Processor_Set;
use Processor_Set.Generic_Processor_Set;
with Processors;                        use Processors;
with processor_interface;               use processor_interface;
with Caches;                            use Caches;
use Caches.Caches_Table_Package;
with Core_Units;                        use Core_Units;
use Core_Units.Core_Units_Table_Package;
with Address_Space_Set;                 use Address_Space_Set;
use Address_Space_Set.Generic_Address_Space_Set;
with Task_Set;                          use Task_Set;
use Task_Set.Generic_Task_Set;
with Systems;                           use Systems;
with Call_Framework;                    use Call_Framework;
with Call_Framework_Interface;          use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with framework;                         use framework;
with Call_Scheduling_Framework;         use Call_Scheduling_Framework;
with Multiprocessor_Services;           use Multiprocessor_Services;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with GNAT.Command_Line;
with GNAT.OS_Lib;                       use GNAT.OS_Lib;
with Version;                           use Version;
with Ada.Exceptions;                    use Ada.Exceptions;

with Task_Groups;          use Task_Groups;
with Task_Group_Set;       use Task_Group_Set;
with Tasks;                use Tasks;
with Task_Dependencies;    use Task_Dependencies;
with architecture_factory; use architecture_factory;

with Task_Group_Transformation; use Task_Group_Transformation;
with Comprehensive_Call;

procedure DGMF_Merge is
   Sys_Multiframe  : System;
   Sys_Transaction : System;

   A_core : Core_Unit_Ptr;
   Cores  : Core_Units_Table;
begin
   Call_Framework.initialize (False);

   -- Platform entities

   Initialize (Sys_Multiframe);

   Add_core_unit
     (Sys_Multiframe.Core_units,
      A_core,
      To_Unbounded_String ("core1"),
      preemptive,
      100,
      1,
      101,
      102,
      103,
      To_Unbounded_String (""),
      Posix_1003_Highest_Priority_First_Protocol);
   Add (Cores, A_core);

   Add_Processor
     (Sys_Multiframe.Processors,
      To_Unbounded_String ("cpu1"),
      Cores);

   Add_Address_Space
     (Sys_Multiframe.Address_Spaces,
      To_Unbounded_String ("addr1"),
      To_Unbounded_String ("cpu1"),
      0,
      0,
      0,
      0);

   -- Task Groups
   Add_Task_Group
     (Sys_Multiframe.Task_Groups,
      To_Unbounded_String ("G1"),
      Multiframe_Type);
   Add_Task_Group
     (Sys_Multiframe.Task_Groups,
      To_Unbounded_String ("G2"),
      Multiframe_Type);
   Add_Task_Group
     (Sys_Multiframe.Task_Groups,
      To_Unbounded_String ("G3"),
      Multiframe_Type);
   Add_Task_Group
     (Sys_Multiframe.Task_Groups,
      To_Unbounded_String ("G4"),
      Multiframe_Type);
   Add_Task_Group
     (Sys_Multiframe.Task_Groups,
      To_Unbounded_String ("G5"),
      Multiframe_Type);

   Add_Task_Group
     (Sys_Multiframe.Task_Groups,
      To_Unbounded_String ("G6"),
      Multiframe_Type);

   -- Tasks

   Add_Task
     (Sys_Multiframe.Tasks,
      Sys_Multiframe.Task_Groups,
      To_Unbounded_String ("G1"),
      To_Unbounded_String ("T11"),
      To_Unbounded_String ("cpu1"),
      To_Unbounded_String ("addr1"),
      Frame_Task_Type,
      2, -- start_time
      1, -- capacity
      5, -- min_separation
      20, -- deadline
      0, -- jitter
      0, -- blocking
      5, -- priority
      0, -- criticality
      Sched_Fifo);

   Add_Task
     (Sys_Multiframe.Tasks,
      Sys_Multiframe.Task_Groups,
      To_Unbounded_String ("G2"),
      To_Unbounded_String ("T21"),
      To_Unbounded_String ("cpu1"),
      To_Unbounded_String ("addr1"),
      Frame_Task_Type,
      0, -- start_time
      2, -- capacity
      5, -- min_separation
      20, -- deadline
      0, -- jitter
      0, -- blocking
      1, -- priority
      0, -- criticality
      Sched_Fifo);

   Add_Task
     (Sys_Multiframe.Tasks,
      Sys_Multiframe.Task_Groups,
      To_Unbounded_String ("G3"),
      To_Unbounded_String ("T31"),
      To_Unbounded_String ("cpu1"),
      To_Unbounded_String ("addr1"),
      Frame_Task_Type,
      0, -- start_time
      2, -- capacity
      5, -- min_separation
      20, -- deadline
      0, -- jitter
      0, -- blocking
      1, -- priority
      0, -- criticality
      Sched_Fifo);

   Add_Task
     (Sys_Multiframe.Tasks,
      Sys_Multiframe.Task_Groups,
      To_Unbounded_String ("G1"),
      To_Unbounded_String ("T12"),
      To_Unbounded_String ("cpu1"),
      To_Unbounded_String ("addr1"),
      Frame_Task_Type,
      0, -- start_time
      2, -- capacity
      5, -- min_separation
      20, -- deadline
      0, -- jitter
      0, -- blocking
      5, -- priority
      0, -- criticality
      Sched_Fifo);

   Add_Task
     (Sys_Multiframe.Tasks,
      Sys_Multiframe.Task_Groups,
      To_Unbounded_String ("G2"),
      To_Unbounded_String ("T22"),
      To_Unbounded_String ("cpu1"),
      To_Unbounded_String ("addr1"),
      Frame_Task_Type,
      0, -- start_time
      1, -- capacity
      5, -- min_separation
      20, -- deadline
      0, -- jitter
      0, -- blocking
      1, -- priority
      0, -- criticality
      Sched_Fifo);

   Add_Task
     (Sys_Multiframe.Tasks,
      Sys_Multiframe.Task_Groups,
      To_Unbounded_String ("G3"),
      To_Unbounded_String ("T32"),
      To_Unbounded_String ("cpu1"),
      To_Unbounded_String ("addr1"),
      Frame_Task_Type,
      0, -- start_time
      1, -- capacity
      5, -- min_separation
      20, -- deadline
      0, -- jitter
      0, -- blocking
      1, -- priority
      0, -- criticality
      Sched_Fifo);

   Add_Task
     (Sys_Multiframe.Tasks,
      Sys_Multiframe.Task_Groups,
      To_Unbounded_String ("G4"),
      To_Unbounded_String ("T41"),
      To_Unbounded_String ("cpu1"),
      To_Unbounded_String ("addr1"),
      Frame_Task_Type,
      4, -- start_time
      2, -- capacity
      10, -- min_separation
      10, -- deadline
      0, -- jitter
      0, -- blocking
      2, -- priority
      0, -- criticality
      Sched_Fifo);

   Add_Task
     (Sys_Multiframe.Tasks,
      Sys_Multiframe.Task_Groups,
      To_Unbounded_String ("G5"),
      To_Unbounded_String ("T51"),
      To_Unbounded_String ("cpu1"),
      To_Unbounded_String ("addr1"),
      Frame_Task_Type,
      0, -- start_time
      1, -- capacity
      10, -- min_separation
      10, -- deadline
      0, -- jitter
      0, -- blocking
      1, -- priority
      0, -- criticality
      Sched_Fifo);

   Add_Task
     (Sys_Multiframe.Tasks,
      Sys_Multiframe.Task_Groups,
      To_Unbounded_String ("G6"),
      To_Unbounded_String ("T61"),
      To_Unbounded_String ("cpu1"),
      To_Unbounded_String ("addr1"),
      Frame_Task_Type,
      0, -- start_time
      1, -- capacity
      10, -- min_separation
      10, -- deadline
      0, -- jitter
      0, -- blocking
      1, -- priority
      0, -- criticality
      Sched_Fifo);

   -- Dependencies

   Add_One_Task_Dependency_precedence
     (Sys_Multiframe.Dependencies,
      Search_Task (Sys_Multiframe.Tasks, To_Unbounded_String ("T11")),
      Search_Task (Sys_Multiframe.Tasks, To_Unbounded_String ("T21")));

   Add_One_Task_Dependency_precedence
     (Sys_Multiframe.Dependencies,
      Search_Task (Sys_Multiframe.Tasks, To_Unbounded_String ("T11")),
      Search_Task (Sys_Multiframe.Tasks, To_Unbounded_String ("T31")));

   Add_One_Task_Dependency_precedence
     (Sys_Multiframe.Dependencies,
      Search_Task (Sys_Multiframe.Tasks, To_Unbounded_String ("T12")),
      Search_Task (Sys_Multiframe.Tasks, To_Unbounded_String ("T22")));

   Add_One_Task_Dependency_precedence
     (Sys_Multiframe.Dependencies,
      Search_Task (Sys_Multiframe.Tasks, To_Unbounded_String ("T12")),
      Search_Task (Sys_Multiframe.Tasks, To_Unbounded_String ("T32")));

   Add_One_Task_Dependency_precedence
     (Sys_Multiframe.Dependencies,
      Search_Task (Sys_Multiframe.Tasks, To_Unbounded_String ("T22")),
      Search_Task (Sys_Multiframe.Tasks, To_Unbounded_String ("T32")));

   Add_One_Task_Dependency_precedence
     (Sys_Multiframe.Dependencies,
      Search_Task (Sys_Multiframe.Tasks, To_Unbounded_String ("T41")),
      Search_Task (Sys_Multiframe.Tasks, To_Unbounded_String ("T51")));

   -- Task_Groups

   -- IO

   Write_To_Xml_File (Sys_Multiframe, To_Unbounded_String ("merge_dgmf.xml"));
   Multiframe_To_Transaction_Sys_Crossref
     (Sys_Multiframe,
      Sys_Transaction,
      True);
   Write_To_Xml_File
     (Sys_Transaction,
      To_Unbounded_String ("merge_transaction.xml"));
end DGMF_Merge;
