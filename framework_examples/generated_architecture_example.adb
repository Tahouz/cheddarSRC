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
--    $Rev: 4663 $
--    $Date: 2023-12-04 14:46:08 +0100 (lun., 04 déc. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Generic_Graph; use Generic_Graph;

with Tasks; use Tasks;

with Task_Set; use Task_Set;

with Task_Groups; use Task_Groups;

with Task_Group_Set; use Task_Group_Set;

with Buffers; use Buffers;

with Messages; use Messages;

with Dependencies; use Dependencies;

with Resources; use Resources;
use Resources.Resource_Accesses;

with Systems; use Systems;

with Processors;        use Processors;
with Processor_Set;     use Processor_Set;
with Address_Spaces;    use Address_Spaces;
with Address_Space_Set; use Address_Space_Set;
with Caches;            use Caches;
use Caches.Caches_Table_Package;
with Message_Set;       use Message_Set;

with Buffer_Set; use Buffer_Set;

with Network_Set;        use Network_Set;
with Event_Analyzer_Set; use Event_Analyzer_Set;
with Resource_Set;       use Resource_Set;

with Task_Dependencies; use Task_Dependencies;

with Buffers; use Buffers;
use Buffers.Buffer_Roles_Package;

with Queueing_Systems; use Queueing_Systems;
with convert_strings;

with unbounded_strings; use unbounded_strings;

with convert_unbounded_strings;

with Text_IO; use Text_IO;

with Systems; use Systems;

with Objects; use Objects;

with Parameters.extended; use Parameters.extended;

with Scheduler_Interface; use Scheduler_Interface;

with Core_Units; use Core_Units;
use Core_Units.Core_Units_Table_Package;

with Ada.Finalization;

with unbounded_strings; use unbounded_strings;

use unbounded_strings.unbounded_string_list_package;

with Unchecked_Deallocation;

with sets;

with architecture_factory; use architecture_factory;

with Call_Framework;            use Call_Framework;
with Call_Framework_Interface;  use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with Call_Scheduling_Framework; use Call_Scheduling_Framework;

with Framework_Config; use Framework_Config;

procedure generated_architecture_example is

   sys               : System;
   a_core            : Core_Unit_Ptr;
   a_core_unit_table : Core_Units_Table;
   rt                : Resource_Accesses_Table;
   r                 : Critical_Section;
   item              : Resource_Accesses_Range;
   range_end         : Resource_Accesses_Range;

   re_pr1 : Integer;
begin

   -- Initialize the Cheddar framework
   --
   Call_Framework.initialize (False);

   -- Initialize the System
   --

   Initialize (sys);

   -- Adding Processor, core and address_space
   --

   Add_core_unit
     (sys.Core_units,
      a_core,
      To_Unbounded_String ("core1"),
      preemptive,
      0,
      1,
      101,
      102,
      103,
      To_Unbounded_String (""),
      Posix_1003_Highest_Priority_First_Protocol);
   Add (a_core_unit_table, a_core);

   Add_Processor
     (sys.Processors,
      To_Unbounded_String ("processor1"),
      a_core_unit_table);

   Add_Address_Space
     (sys.Address_Spaces,
      To_Unbounded_String ("addr1"),
      To_Unbounded_String ("processor1"),
      0,
      0,
      0,
      0);

   -- Adding Tasks
   --

   Add_Task_Deadline_equals_period_To_System
     (sys,
      To_Unbounded_String ("T1"),
      To_Unbounded_String ("processor1"),
      To_Unbounded_String ("addr1"),
      Periodic_Type);

   Add_Task_Deadline_equals_period_To_System
     (sys,
      To_Unbounded_String ("T2"),
      To_Unbounded_String ("processor1"),
      To_Unbounded_String ("addr1"),
      Periodic_Type);

   Add_Task_Deadline_equals_period_To_System
     (sys,
      To_Unbounded_String ("T3"),
      To_Unbounded_String ("processor1"),
      To_Unbounded_String ("addr1"),
      Periodic_Type);

 --put(sys.Tasks);

   r.task_begin := 1;
   r.task_end   := 1;
   add (rt, To_Unbounded_String ("T1"), r);
   add (rt, To_Unbounded_String ("T2"), r);

   Add_Time_Triggered_Communication_Dependency_To_System (sys);
   re_pr1 := Integer (10);
   Add_Resource
     (sys.Resources,
      To_Unbounded_String ("R1"),
      1,
      0,
      0,
      To_Unbounded_String ("processor1"),
      To_Unbounded_String ("addr1"),
      Priority_Inheritance_Protocol,
      rt,
      re_pr1,
      Automatic_Assignment);

   range_end :=
     Search_Resource
        (sys.Resources,
         suppress_space (To_Unbounded_String ("R1"))).critical_sections.
     nb_entries;
   item      := 0;
   loop
      Add_One_Task_Dependency_resource
        (sys.Dependencies,
         Search_Task
            (sys.Tasks,
             Search_Resource
                (sys.Resources,
                 suppress_space (To_Unbounded_String ("R1"))).
        critical_sections.entries (item).item),
         Search_Resource
            (sys.Resources,
             suppress_space (To_Unbounded_String ("R1"))));
      item := item + 1;
      exit when item >= range_end;
   end loop;

end generated_architecture_example;
