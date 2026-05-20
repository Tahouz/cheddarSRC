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

with hierarchical_analysis;
use  hierarchical_analysis;
with Text_IO;                                 use Text_IO;
with Ada.Strings.Unbounded;                   use Ada.Strings.Unbounded;
with unbounded_strings;                       use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with Systems;                                 use Systems;
with Call_Scheduling_Framework;               use Call_Scheduling_Framework;
with Multiprocessor_Services;                 use Multiprocessor_Services;
with Multiprocessor_Services_Interface;       use
  Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with Ada.Exceptions;                          use Ada.Exceptions;
with Scheduler_Interface;                     use Scheduler_Interface;

with Processor_Set;        use Processor_Set;
use Processor_Set.Generic_Processor_Set;
with Processors;           use Processors;
with processor_interface;  use processor_interface;
with Caches;               use Caches;
use Caches.Caches_Table_Package;
with Core_Units;           use Core_Units;
use Core_Units.Core_Units_Table_Package;
with Parameters;           use Parameters;
with Parameters.extended;  use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;
with Tasks;                use Tasks;
with Task_Set;             use Task_Set;
use Task_Set.Generic_Task_Set;
with Resources;            use Resources;
with Resource_Set;         use Resource_Set;
use Resource_Set.Generic_Resource_Set;
with Address_Space_Set;    use Address_Space_Set;
use Address_Space_Set.Generic_Address_Space_Set;
with Offsets;              use Offsets;
use Offsets.Offsets_Table_Package;
with Buffer_Set;           use Buffer_Set;
with Buffers;              use Buffers;
use Buffers.Buffer_Roles_Package;
with Queueing_Systems;     use Queueing_Systems;
with Message_Set;          use Message_Set;
with Messages;             use Messages;
with Task_Dependencies;    use Task_Dependencies;
with Dependencies;         use Dependencies;
with Objects;              use Objects;
use Objects.Generic_Object_Set_Package;
with deployment_Set;       use deployment_Set;
with Deployments;          use Deployments;
with initialize_framework; use initialize_framework;

procedure hierarchical_edf_schedulability_analysis is

   sys                                      : System;
   deployment_test                          : Generic_Deployment_Ptr;
   deployment_test2                         : Generic_Deployment;
   a_core                                   : Core_Unit_Ptr;
   a_core_unit_table                        : Core_Units_Table;
   T1_ref, T2_ref, HP_Serv_ref, LP_Serv_ref : Generic_Task_Ptr;
   P1_ref                                   : Generic_Processor_Ptr;
   sink, source, sink_L, source_L           : Generic_Objects_Set;

begin

   Set_Initialize;
   Initialize (sys);

   Add_core_unit
     (sys.Core_units,
      a_core,
      To_Unbounded_String ("core1"),
      preemptive,
      100,
      1,
      101,
      102,
      103,
      To_Unbounded_String (""),
      Posix_1003_Highest_Priority_First_Protocol);
   Add (a_core_unit_table, a_core);

   Add_Processor
     (sys.Processors,
      P1_ref,
      To_Unbounded_String ("processor1"),
      a_core_unit_table,
      Time_Unit_Migration_Type);

   Add_Address_Space
     (sys.Address_Spaces,
      To_Unbounded_String ("addr1"),
      To_Unbounded_String ("processor1"),
      0,
      0,
      0,
      0);

   Add_Task
     (sys.Tasks,
      T1_ref,
      To_Unbounded_String ("T1"),
      To_Unbounded_String ("processor1"),
      To_Unbounded_String (""),
      To_Unbounded_String ("addr1"),
      Periodic_Type,
      0,
      10,
      50,
      50,
      0,
      0,
      3,
      0,
      Sched_Fifo);
   Add_Task
     (sys.Tasks,
      T2_ref,
      To_Unbounded_String ("T2"),
      To_Unbounded_String ("processor1"),
      To_Unbounded_String (""),
      To_Unbounded_String ("addr1"),
      Periodic_Type,
      0,
      8,
      100,
      100,
      0,
      0,
      4,
      0,
      Sched_Fifo);
   Add_Task
     (sys.Tasks,
      HP_Serv_ref,
      To_Unbounded_String ("HP_Server"),
      To_Unbounded_String ("processor1"),
      To_Unbounded_String (""),
      To_Unbounded_String ("addr1"),
      Scheduling_Task_Type,
      0,
      2,
      5,
      5,
      3,
      0,
      1,
      0,
      Sched_Fifo);
   Add_Task
     (sys.Tasks,
      LP_Serv_ref,
      To_Unbounded_String ("LP_Server"),
      To_Unbounded_String ("processor1"),
      To_Unbounded_String (""),
      To_Unbounded_String ("addr1"),
      Scheduling_Task_Type,
      0,
      8,
      20,
      20,
      12,
      0,
      2,
      0,
      Sched_Fifo);

   initialize (source_L);
   initialize (sink_L);
   add (sink, Generic_Object_Ptr (T1_ref));
   add (sink, Generic_Object_Ptr (T2_ref));
   add (source, Generic_Object_Ptr (LP_Serv_ref));
   Add_deployment
     (sys.deployments,
      To_Unbounded_String ("Low_Priority_Deferrable_Server"),
      source,
      sink,
      To_Unbounded_String ("scheduling_sequence.xml"));
   deployment_test := get_random_element (sys.deployments);

   initialize (source);
   initialize (sink);
   add (sink, Generic_Object_Ptr (HP_Serv_ref));
   add (sink, Generic_Object_Ptr (LP_Serv_ref));
   add (source, Generic_Object_Ptr (P1_ref));
   Add_deployment
     (sys.deployments,
      To_Unbounded_String ("static_example"),
      source,
      sink,
      To_Unbounded_String ("scheduling_sequence.xml"));

end hierarchical_edf_schedulability_analysis;
