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

with Text_IO;                           use Text_IO;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with Systems;                           use Systems;
with Call_Scheduling_Framework;         use Call_Scheduling_Framework;
with Multiprocessor_Services;           use Multiprocessor_Services;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with Ada.Exceptions;                    use Ada.Exceptions;
with Scheduler_Interface;               use Scheduler_Interface;
with scheduler_interface.extended; use scheduler_interface.extended;
with Processor_Set;                     use Processor_Set;
use Processor_Set.Generic_Processor_Set;
with Processors;                        use Processors;
with processor_interface;               use processor_interface;
with Core_Units;                        use Core_Units;
use Core_Units.Core_Units_Table_Package;
with Caches;                            use Caches;
use Caches.Caches_Table_Package;
with Parameters;                        use Parameters;
with Parameters.extended;               use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;
with Tasks;                             use Tasks;
use Tasks.Generic_Task_List_Package;
with Task_Groups;                       use Task_Groups;
with Task_Set;                          use Task_Set;
use Task_Set.Generic_Task_Set;
with Task_Group_Set;                    use Task_Group_Set;
use Task_Group_Set.Generic_Task_Group_Set;
with Resources;                         use Resources;
use Resources.Resource_Accesses;
with Resource_Set;                      use Resource_Set;
use Resource_Set.Generic_Resource_Set;
with Address_Space_Set;                 use Address_Space_Set;
use Address_Space_Set.Generic_Address_Space_Set;
with Offsets;                           use Offsets;
use Offsets.Offsets_Table_Package;
with Offsets.extended;                  use Offsets.extended;
with Buffer_Set;                        use Buffer_Set;
with Buffers;                           use Buffers;
use Buffers.Buffer_Roles_Package;
with Queueing_Systems;                  use Queueing_Systems;
with Message_Set;                       use Message_Set;
with Messages;                          use Messages;
with Network_Set;                       use Network_Set;
with Networks;                          use Networks;
use Networks.Positions_Table_Package;
with Task_Dependencies;                 use Task_Dependencies;
with Dependencies;                      use Dependencies;
with Objects;                           use Objects;
use Objects.Generic_Object_Set_Package;
with Parameters;                        use Parameters;
use Parameters.User_Defined_Parameters_Table_Package;

with memories; use memories;
use memories.memories_table_package;
with memory_set; use memory_set;

package body architecture_models is

   procedure model0 (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem               : memories_table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol
      );
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

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         7,
         29,
         29,
         0,
         0,
         1,
         0,
         Sched_Fifo);

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         3,
         10,
         10,
         0,
         0,
         2,
         0,
         Sched_Fifo);

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         5,
         5,
         0,
         0,
         3,
         0,
         Sched_Fifo);

   end model0;

   procedure model1 (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem               : memories_table;

   begin

      Initialize (sys);
      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol
      );
      Add (a_core_unit_table, a_core);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core2"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol
      );
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

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         7,
         29,
         29,
         0,
         0,
         1,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         3,
         10,
         10,
         0,
         0,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         2,
         5,
         5,
         0,
         0,
         3,
         0,
         Sched_Fifo);

      Put_Line (To_String (XML_String (sys, 0)));

   end model1;

   procedure model2 (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem		: memories_table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol
      );
      Add (a_core_unit_table, a_core);
      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core2"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol
      );
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

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         2,
         10,
         10,
         0,
         10,
         1,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         7,
         20,
         20,
         0,
         10,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         5,
         5,
         0,
         10,
         3,
         0,
         Sched_Fifo);

      Put_Line (To_String (XML_String (sys, 0)));

   end model2;

   procedure model3 (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem		: memories_table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol
      );
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

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         7,
         29,
         29,
         0,
         0,
         1,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         3,
         10,
         10,
         0,
         0,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         5,
         5,
         0,
         0,
         3,
         0,
         Sched_Fifo);

      Put_Line (To_String (XML_String (sys, 0)));

   end model3;

   procedure polling1 (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem		: memories_table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 4,
	period		=> 18,
	priority	=> 255,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Hierarchical_Polling_Aperiodic_Server_Protocol
      );

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

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         4,
         20,
         20,
         0,
         0,
         1,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         12,
         30,
         30,
         0,
         0,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("A"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Aperiodic_Type,
         4,
         3,
         0,
         20,
         0,
         0,
         3,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("B"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Aperiodic_Type,
         9,
         4,
         0,
         20,
         0,
         0,
         3,
         0,
         Sched_Fifo);

   end polling1;

   procedure polling2 (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem		: memories_table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 1,
	period		=> 5,
	priority	=> 255,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Hierarchical_Polling_Aperiodic_Server_Protocol
      );
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

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("TA"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         4,
         10,
         10,
         0,
         0,
         1,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("TB"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         8,
         20,
         20,
         0,
         0,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("AperiodicRequest1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Aperiodic_Type,
         5,
         1,
         0,
         20,
         0,
         0,
         3,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("AperiodicRequest2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Aperiodic_Type,
         12,
         1,
         0,
         20,
         0,
         0,
         3,
         0,
         Sched_Fifo);

      Put_Line (To_String (XML_String (sys, 0)));

   end polling2;

   procedure Deferrable1 (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem		: memories_table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 4,
	period		=> 18,
	priority	=> 255,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Hierarchical_Deferrable_Aperiodic_Server_Protocol
      );
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

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         4,
         20,
         20,
         0,
         0,
         1,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         12,
         30,
         30,
         0,
         0,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("A"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Aperiodic_Type,
         4,
         3,
         0,
         20,
         0,
         0,
         3,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("B"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Aperiodic_Type,
         9,
         4,
         0,
         20,
         0,
         0,
         3,
         0,
         Sched_Fifo);

   end Deferrable1;

   procedure Deferrable2 (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem		: memories_table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 1,
	period		=> 5,
	priority	=> 255,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Hierarchical_Deferrable_Aperiodic_Server_Protocol
      );
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

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("TA"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         4,
         10,
         10,
         0,
         0,
         1,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("TB"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         8,
         20,
         20,
         0,
         0,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("AperiodicRequest1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Aperiodic_Type,
         5,
         1,
         0,
         20,
         0,
         0,
         3,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("AperiodicRequest2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Aperiodic_Type,
         12,
         1,
         0,
         20,
         0,
         0,
         3,
         0,
         Sched_Fifo);

      Put_Line (To_String (XML_String (sys, 0)));

   end Deferrable2;

   procedure PF1 (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem		: memories_table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Proportionate_Fair_PF_Protocol
      );
      Add (a_core_unit_table, a_core);
      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core2"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Proportionate_Fair_PF_Protocol
      );
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

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         2,
         2,
         0,
         0,
         1,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         3,
         3,
         0,
         0,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         2,
         9,
         9,
         0,
         0,
         1,
         0,
         Sched_Fifo);

      Put_Line (To_String (XML_String (sys, 0)));

   end PF1;

   procedure global_DM_with_job_level_migration_scheduling
     (sys : out System)
   is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem		: memories_table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Deadline_Monotonic_Protocol
      );
      Add (a_core_unit_table, a_core);
      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core2"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Deadline_Monotonic_Protocol
      );
      Add (a_core_unit_table, a_core);
      Add_Processor
        (sys.Processors,
         To_Unbounded_String ("processor1"),
         a_core_unit_table,
         Job_Level_Migration_Type);

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
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         2,
         4,
         4,
         0,
         10,
         1,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         3,
         5,
         5,
         0,
         10,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         7,
         20,
         20,
         0,
         10,
         3,
         0,
         Sched_Fifo);

   end global_DM_with_job_level_migration_scheduling;

   procedure global_DM_with_time_unit_level_migration_scheduling
     (sys : out System)
   is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem		: memories_table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Deadline_Monotonic_Protocol
      );
      Add (a_core_unit_table, a_core);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core2"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Deadline_Monotonic_Protocol
      );
      Add (a_core_unit_table, a_core);
      Add_Processor
        (sys.Processors,
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
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         2,
         4,
         4,
         0,
         10,
         1,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         3,
         5,
         5,
         0,
         10,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         7,
         20,
         20,
         0,
         10,
         3,
         0,
         Sched_Fifo);

   end global_DM_with_time_unit_level_migration_scheduling;

   procedure cache1 (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      rt                : Resource_Accesses_Table;
      r                 : Critical_Section;
      mem		: memories_table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol);
      
      Add (a_core_unit_table, a_core);
      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core2"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol
      );
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

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         2,
         2,
         0,
         0,
         1,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         3,
         3,
         0,
         0,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         2,
         9,
         9,
         0,
         0,
         1,
         0,
         Sched_Fifo);

      r.task_begin := 1;
      r.task_end   := 1;
      add (rt, To_Unbounded_String ("T1"), r);
      add (rt, To_Unbounded_String ("T2"), r);

      Add_Resource
        (sys.Resources,
         To_Unbounded_String ("R1"),
         1,
         0,
         0,
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         No_Protocol,
         rt,
         1,
         Automatic_Assignment);

      Put_Line (To_String (XML_String (sys, 0)));

   end cache1;

   procedure test1_xml (sys : out System) is

   begin

      Initialize (sys);

   end test1_xml;

   procedure test2_xml (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem		: memories_table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 100,
	speed		=> 1,
	capacity	=> 101,
	period		=> 102,
	priority	=> 103,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Posix_1003_Highest_Priority_First_Protocol
      );
      Add (a_core_unit_table, a_core);
      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core2"),
        is_preemptive	=> preemptive,
	quantum        	=> 100,
	speed		=> 1,
	capacity	=> 101,
	period		=> 102,
	priority	=> 103,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Posix_1003_Highest_Priority_First_Protocol
      );
      Add (a_core_unit_table, a_core);

   end test2_xml;

   procedure test3_xml (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem		: memories_table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 100,
	speed		=> 1,
	capacity	=> 101,
	period		=> 102,
	priority	=> 103,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Posix_1003_Highest_Priority_First_Protocol
      );
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

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         2,
         4,
         4,
         0,
         10,
         1,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         3,
         5,
         5,
         0,
         10,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         7,
         20,
         20,
         0,
         10,
         3,
         0,
         Sched_Fifo);

   end test3_xml;

   procedure test4_xml (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem		: memories_table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 100,
	speed		=> 1,
	capacity	=> 101,
	period		=> 102,
	priority	=> 103,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Posix_1003_Highest_Priority_First_Protocol
      );
      Add (a_core_unit_table, a_core);
      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core2"),
        is_preemptive	=> preemptive,
	quantum        	=> 100,
	speed		=> 1,
	capacity	=> 101,
	period		=> 102,
	priority	=> 103,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Posix_1003_Highest_Priority_First_Protocol
      );
      Add (a_core_unit_table, a_core);

      Add_Processor
        (sys.Processors,
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
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         2,
         4,
         4,
         0,
         10,
         1,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         3,
         5,
         5,
         0,
         10,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         7,
         20,
         20,
         0,
         10,
         3,
         0,
         Sched_Fifo);

   end test4_xml;

   procedure test5_xml (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem		: memories_table;

      Offs : Offsets_Table;
      Off  : Offset_Type;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 100,
	speed		=> 1,
	capacity	=> 101,
	period		=> 102,
	priority	=> 103,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Posix_1003_Highest_Priority_First_Protocol
      );
      Add (a_core_unit_table, a_core);

      Add_Processor
        (sys.Processors,
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

      Off.offset_value := 10;
      Off.activation   := 11;
      Add (Offs, Off);
      Off.offset_value := 12;
      Off.activation   := 13;
      Add (Offs, Off);

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         2,
         4,
         4,
         0,
         10,
         1,
         0,
         Sched_Fifo,
         Offs);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         3,
         5,
         5,
         0,
         10,
         2,
         0,
         Sched_Fifo,
         Offs);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         7,
         20,
         20,
         0,
         10,
         3,
         0,
         Sched_Fifo,
         Offs);

   end test5_xml;

   procedure test6_xml (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem		: memories_table;

      rt                : Resource_Accesses_Table;
      r                 : Critical_Section;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol
      );
      Add (a_core_unit_table, a_core);
      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core2"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol
      );
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

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         2,
         2,
         0,
         0,
         1,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         3,
         3,
         0,
         0,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         2,
         9,
         9,
         0,
         0,
         1,
         0,
         Sched_Fifo);

      r.task_begin := 1;
      r.task_end   := 1;
      add (rt, To_Unbounded_String ("T1"), r);
      add (rt, To_Unbounded_String ("T2"), r);

      Add_Resource
        (sys.Resources,
         To_Unbounded_String ("R1"),
         1,
         0,
         0,
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         No_Protocol,
         rt,
         1,
         Automatic_Assignment);

   end test6_xml;

   procedure test7_xml (sys : out System) is

      a_core                 : Core_Unit_Ptr;
      a_core_unit_table      : Core_Units_Table;
      mem		: memories_table;

      bt                     : Buffer_Roles_Table;
      b                      : Buffer_Role;
      T1_ref, T2_ref, T3_ref : Generic_Task_Ptr;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol
      );
      Add (a_core_unit_table, a_core);
      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core2"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol
      );
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

      Add_Task
        (sys.Tasks,
         T1_ref,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         2,
         2,
         0,
         0,
         1,
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
         1,
         3,
         3,
         0,
         0,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         T3_ref,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         2,
         9,
         9,
         0,
         0,
         1,
         0,
         Sched_Fifo);

      b.the_role := Queuing_Producer;
      b.size     := 1;
      b.time     := 1;
      b.timeout  := 1;
      add (bt, To_Unbounded_String ("T1"), b);
      b.the_role := Queuing_Consumer;
      b.size     := 2;
      b.time     := 2;
      b.timeout  := 2;
      add (bt, To_Unbounded_String ("T2"), b);

      Add_Buffer
        (sys.Buffers,
         To_Unbounded_String ("B1"),
         1,
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         Qs_Mm1,
         bt);

   end test7_xml;

   procedure csg_xml (sys : out System) is

      a_core                 : Core_Unit_Ptr;
      a_core_unit_table      : Core_Units_Table;
      mem		      : memories_table;

      P1_ref                 : Generic_Processor_Ptr;
      T1_ref, T2_ref, T3_ref : Generic_Task_Ptr;
      M1_ref, M2_ref         : Generic_Message_Ptr;
      pt                     : User_Defined_Parameters_Table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Posix_1003_Highest_Priority_First_Protocol
      );
      Add (a_core_unit_table, a_core);
      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core2"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Posix_1003_Highest_Priority_First_Protocol
      );
      Add (a_core_unit_table, a_core);

      Add_Processor
        (sys.Processors,
         P1_ref,
         To_Unbounded_String ("cpu0"),
         a_core_unit_table,
         Time_Unit_Migration_Type);

      Add_Address_Space
        (sys.Address_Spaces,
         To_Unbounded_String ("as"),
         To_Unbounded_String ("cpu0"),
         0,
         0,
         0,
         0);

      Add_Task
        (sys.Tasks,
         T1_ref,
         To_Unbounded_String ("io"),
         To_Unbounded_String ("cpu0"),
         To_Unbounded_String (""),
         To_Unbounded_String ("as"),
         Periodic_Type,
         0,
         4,
         20,
         20,
         0,
         0,
         10,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         T2_ref,
         To_Unbounded_String ("sharp"),
         To_Unbounded_String ("cpu0"),
         To_Unbounded_String (""),
         To_Unbounded_String ("as"),
         Periodic_Type,
         0,
         12,
         20,
         20,
         0,
         0,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         T3_ref,
         To_Unbounded_String ("edge"),
         To_Unbounded_String ("cpu0"),
         To_Unbounded_String (""),
         To_Unbounded_String ("as"),
         Periodic_Type,
         20,
         12,
         20,
         20,
         0,
         0,
         2,
         0,
         Sched_Fifo);

      Add_Message
        (sys.Messages,
         M1_ref,
         To_Unbounded_String ("camera_frame"),
         1,
         1,
         1,
         0,
         pt,
         1,
         1);
      Add_Message
        (sys.Messages,
         M2_ref,
         To_Unbounded_String ("sharp_frame"),
         1,
         1,
         1,
         0,
         pt,
         1,
         1);

      Add_One_Task_Dependency_asynchronous_communication
        (sys.Dependencies,
         T1_ref,
         M1_ref,
         From_Task_To_Object);
      Add_One_Task_Dependency_asynchronous_communication
        (sys.Dependencies,
         T2_ref,
         M1_ref,
         From_Object_To_Task);
      Add_One_Task_Dependency_asynchronous_communication
        (sys.Dependencies,
         T2_ref,
         M2_ref,
         From_Task_To_Object);
      Add_One_Task_Dependency_asynchronous_communication
        (sys.Dependencies,
         T3_ref,
         M2_ref,
         From_Object_To_Task);

   end csg_xml;

   procedure csp_xml (sys : out System) is

      a_core1, a_core2                       : Core_Unit_Ptr;
      a_core_unit_table1, a_core_unit_table2 : Core_Units_Table;
      mem		      : memories_table;

      --P1_ref, P2_ref : generic_processor_ptr;
      T1_ref, T2_ref, T3_ref : Generic_Task_Ptr;
      --M1_ref, M2_ref : Generic_Message_ptr;
      --pt : User_Defined_Parameters_Table;
      bt             : Buffer_Roles_Table;
      b              : Buffer_Role;
      B1_ref, B2_ref : Buffer_Ptr;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core1,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Posix_1003_Highest_Priority_First_Protocol
      );
      Add (a_core_unit_table1, a_core1);
      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core2,
        name		=> To_Unbounded_String ("core2"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Posix_1003_Highest_Priority_First_Protocol
      );

      Add_Processor
        (sys.Processors,
         To_Unbounded_String ("cpu0"),
         a_core_unit_table1);
      Add_Processor
        (sys.Processors,
         To_Unbounded_String ("cpu1"),
         a_core_unit_table2);

      Add_Address_Space
        (sys.Address_Spaces,
         To_Unbounded_String ("as"),
         To_Unbounded_String ("cpu0"),
         0,
         0,
         0,
         0);

      Add_Task
        (sys.Tasks,
         T1_ref,
         To_Unbounded_String ("io"),
         To_Unbounded_String ("cpu0"),
         To_Unbounded_String (""),
         To_Unbounded_String ("as"),
         Periodic_Type,
         0,
         4,
         50,
         10,
         0,
         0,
         10,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         T2_ref,
         To_Unbounded_String ("sharp"),
         To_Unbounded_String ("cpu1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("as"),
         Periodic_Type,
         1,
         12,
         50,
         50,
         0,
         0,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         T3_ref,
         To_Unbounded_String ("edge"),
         To_Unbounded_String ("cpu1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("as"),
         Periodic_Type,
         1,
         12,
         50,
         50,
         0,
         0,
         1,
         0,
         Sched_Fifo);

      --Add_Message(sys.Messages, M1_ref, to_unbounded_string("camera_frame"),
      --1, 1, 1, 0, pt, 1, 1);
      --Add_Message(sys.Messages, M2_ref, to_unbounded_string("sharp_frame"),
      --1, 1, 1, 0, pt, 1, 1);

      b.the_role := Queuing_Producer;
      b.size     := 1;
      b.time     := 4;
      b.timeout  := 1000;
      add (bt, To_Unbounded_String ("io"), b);
      b.the_role := Queuing_Consumer;
      b.size     := 1;
      b.time     := 1;
      b.timeout  := 1000;
      add (bt, To_Unbounded_String ("sharp"), b);
      Add_Buffer
        (sys.Buffers,
         B1_ref,
         To_Unbounded_String ("camera_frame"),
         5,
         To_Unbounded_String ("cpu0"),
         To_Unbounded_String ("as"),
         Qs_Mm1,
         bt);

      b.the_role := Queuing_Producer;
      b.size     := 1;
      b.time     := 12;
      b.timeout  := 1000;
      add (bt, To_Unbounded_String ("sharp"), b);
      b.the_role := Queuing_Consumer;
      b.size     := 1;
      b.time     := 1;
      b.timeout  := 1000;
      add (bt, To_Unbounded_String ("edge"), b);
      Add_Buffer
        (sys.Buffers,
         B2_ref,
         To_Unbounded_String ("sharp_frame"),
         5,
         To_Unbounded_String ("cpu1"),
         To_Unbounded_String ("as"),
         Qs_Mm1,
         bt);

      Add_One_Task_Dependency_queueing_buffer
        (sys.Dependencies,
         T1_ref,
         B1_ref,
         From_Task_To_Object);
      Add_One_Task_Dependency_queueing_buffer
        (sys.Dependencies,
         T2_ref,
         B1_ref,
         From_Object_To_Task);
      Add_One_Task_Dependency_queueing_buffer
        (sys.Dependencies,
         T2_ref,
         B2_ref,
         From_Task_To_Object);
      Add_One_Task_Dependency_queueing_buffer
        (sys.Dependencies,
         T3_ref,
         B2_ref,
         From_Object_To_Task);

   end csp_xml;

   procedure test8_xml (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem		      : memories_table;

      T1_ref, T2_ref    : Generic_Task_Ptr;
      bt                : Buffer_Roles_Table;
      pt                : User_Defined_Parameters_Table;
      b                 : Buffer_Role;
      B1_ref            : Buffer_Ptr;
      R1_ref            : Generic_Resource_Ptr;
      rt                : Resource_Accesses_Table;
      r                 : Critical_Section;
      M1_ref            : Generic_Message_Ptr;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol
      );
      Add (a_core_unit_table, a_core);
      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core2"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol
      );
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

      Add_Task
        (sys.Tasks,
         T1_ref,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         2,
         2,
         0,
         0,
         1,
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
         1,
         3,
         3,
         0,
         0,
         2,
         0,
         Sched_Fifo);

      r.task_begin := 1;
      r.task_end   := 1;
      add (rt, To_Unbounded_String ("T1"), r);
      add (rt, To_Unbounded_String ("T2"), r);

      Add_Resource
        (sys.Resources,
         R1_ref,
         To_Unbounded_String ("R1"),
         1,
         0,
         0,
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         No_Protocol,
         rt,
         1,
         Automatic_Assignment);

      Add_Message
        (sys.Messages,
         M1_ref,
         To_Unbounded_String ("M1"),
         1,
         1,
         1,
         1,
         pt,
         1,
         1);

      b.the_role := Queuing_Producer;
      b.size     := 1;
      b.time     := 1;
      b.timeout  := 1;
      add (bt, To_Unbounded_String ("T1"), b);
      b.the_role := Queuing_Consumer;
      b.size     := 2;
      b.time     := 2;
      b.timeout  := 2;
      add (bt, To_Unbounded_String ("T2"), b);

      Add_Buffer
        (sys.Buffers,
         B1_ref,
         To_Unbounded_String ("B1"),
         1,
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         Qs_Mm1,
         bt);

      Add_All_Task_Dependencies (sys.Dependencies, sys.Tasks, B1_ref);
      Add_All_Task_Dependencies (sys.Dependencies, sys.Tasks, R1_ref);
      Add_One_Task_Dependency_asynchronous_communication
        (sys.Dependencies,
         T1_ref,
         M1_ref,
         From_Object_To_Task);
      Add_One_Task_Dependency_asynchronous_communication
        (sys.Dependencies,
         T2_ref,
         M1_ref,
         From_Task_To_Object);
      Add_One_Task_Dependency_precedence (sys.Dependencies, T2_ref, T1_ref);
      Add_One_Task_Dependency_Time_Triggered
        (sys.Dependencies,
         T2_ref,
         T1_ref,
         Sampled_Timing);
      Add_One_Task_Dependency_Time_Triggered
        (sys.Dependencies,
         T2_ref,
         T1_ref,
         Delayed_Timing);
      Add_One_Task_Dependency_Time_Triggered
        (sys.Dependencies,
         T2_ref,
         T1_ref,
         Immediate_Timing);

   end test8_xml;

   -- Add_Task(Sys.tasks, ^M
   --      Name, Cpu_Name, Address_Space_Name,^M
   --      Task_Type,^M
   --      Start_Time, Capacity, Period, Deadline, Jitter, Blocking_Time,^M
   --      Priority,^M
   --      Criticality,^M
   --      Policy,^M
   -- argument of Add_Task with a default value :^M
   --      Offset:=No_offset,^M
   --      Stack_Memory_Size:=0,^M
   --      Text_Memory_Size:=0,^M
   --      Param:=No_User_Defined_Parameter,^M
   --      Parametric_Rule_Name:=Empty_String,^M
   --      Seed_Value:=0,^M
   --      Predictable:=True,^M
   --      context_switch_overhead:=0);^M
   --

   -- To add a core unit, the following subprogram can be used :^M
   --^M
   -- Add_Core_Unit(My_core_units,^M
   --      A_Core_Unit, Name,^M
   --      Is_Preemptive,^M
   --      Quantum, Speed, Capacity, Period, Priority, File_Name,
   --A_Scheduler,^M
   -- argument of Add_Core_Unit with a default value :^M
   --      Automaton_Name:= Empty_String);^M

   -- 1 core with tasks and users defined schedulers/user defined tasks
   -- and user defined parameters
   procedure test9_xml (sys : out System) is

      a_core  : Core_Unit_Ptr;
      mem     : memories_table;
      a_param : Parameter_Ptr;
      Params  : User_Defined_Parameters_Table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,       -- 0, 0, 0, 1, 1, 0,     ??
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> To_Unbounded_String ("edf.sc"),
        scheduling_protocol_name =>  To_Unbounded_String ("my automaton"),
      	a_scheduler 	=> Pipeline_User_Defined_Protocol
      );

      Add_Processor
        (sys.Processors,
         To_Unbounded_String ("processor1"),
         a_core);

      Add_Address_Space
        (sys.Address_Spaces,
         To_Unbounded_String ("addr1"),
         To_Unbounded_String ("processor1"),
         0,
         0,
         0,
         0);

      --   procedure Add_Task
      --     (My_Tasks                : in out Tasks_Set;
      --      Name                    : in Unbounded_String;
      --      Cpu_Name                : in Unbounded_String;
      --      Address_Space_Name      : in Unbounded_String;
      --      Task_Type               : in Tasks_Type;
      --      Start_Time              : in Integer;
      --      Capacity                : in Integer;
      --      Period                  : in Integer;
      --      Deadline                : in Integer;
      --      Jitter                  : in Integer;
      --      Blocking_Time           : in Integer;
      --      Priority                : in Integer;
      --      Criticality             : in Integer;
      --      Policy                  : in Policies;
      --      Offset                  : in Offsets_Table                 :=
      --No_Offset;
      --      Stack_Memory_Size       : in Integer                       := 0;
      --      Text_Memory_Size        : in Integer                       := 0;
      --      Param                   : in User_Defined_Parameters_Table :=
      --No_User_Defined_Parameter;
      --      Parametric_Rule_Name    : in Unbounded_String              :=
      --empty_string;
      --      Seed_Value              : in Integer                       := 0;
      --      Predictable             : in Boolean                       :=
      --True;
      --      context_switch_overhead : in Integer                       := 0);

      Initialize (Params);
      a_param                := new Parameter (Boolean_Parameter);
      a_param.boolean_value  := False;
      a_param.parameter_name := To_Unbounded_String ("param1");
      Add (Params, a_param);
      a_param                := new Parameter (Integer_Parameter);
      a_param.integer_value  := 100;
      a_param.parameter_name := To_Unbounded_String ("param2");
      Add (Params, a_param);
      a_param                := new Parameter (Double_Parameter);
      a_param.double_value   := 100.5;
      a_param.parameter_name := To_Unbounded_String ("param3");
      Add (Params, a_param);
      a_param                := new Parameter (String_Parameter);
      a_param.string_value   := To_Unbounded_String ("a_parameter_value");
      a_param.parameter_name := To_Unbounded_String ("param4");
      Add (Params, a_param);

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Parametric_Type,
         0,
         1,
         2,
         2,
         0,
         0,
         1,
         0,
         Sched_Fifo,
         No_Offset,
         0,
         0,
         Params,
         To_Unbounded_String ("activation_rule"),
         10,
         False,
         10);

   end test9_xml;

   procedure test10_xml (sys : out System) is

      a_core                 : Core_Unit_Ptr;
      a_core_unit_table      : Core_Units_Table;
      mem     		     : memories_table;

      pt                     : User_Defined_Parameters_Table;
      T1_ref, T2_ref, T3_ref : Generic_Task_Ptr;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol
      );
      Add (a_core_unit_table, a_core);
      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core2"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol
      );
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

      Add_Task
        (sys.Tasks,
         T1_ref,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         2,
         2,
         0,
         0,
         1,
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
         1,
         3,
         3,
         0,
         0,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         T3_ref,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         2,
         9,
         9,
         0,
         0,
         1,
         0,
         Sched_Fifo);

      Add_Message
        (sys.Messages,
         To_Unbounded_String ("M1"),
         1,
         1,
         1,
         1,
         pt,
         1,
         1);

   end test10_xml;

   procedure test13_xml (sys : out System) is

      core1_ref, core2_ref   : Core_Unit_Ptr;
      mem     		     : memories_table;
      T1_ref, T2_ref, T3_ref : Generic_Task_Ptr;
      P_ref                  : Generic_Processor_Ptr;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> core1_ref,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 100,
	speed		=> 1,
	capacity	=> 101,
	period		=> 102,
	priority	=> 103,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Posix_1003_Highest_Priority_First_Protocol
      );
      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> core2_ref,
        name		=> To_Unbounded_String ("core2"),
        is_preemptive	=> preemptive,
	quantum        	=> 100,
	speed		=> 1,
	capacity	=> 101,
	period		=> 102,
	priority	=> 103,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Posix_1003_Highest_Priority_First_Protocol
      );

      Add_Processor
        (sys.Processors,
         P_ref,
         To_Unbounded_String ("processor1"),
         core1_ref);
      Add_Processor
        (sys.Processors,
         P_ref,
         To_Unbounded_String ("processor2"),
         core2_ref);

      Add_Address_Space
        (sys.Address_Spaces,
         To_Unbounded_String ("addr1"),
         To_Unbounded_String ("processor1"),
         0,
         0,
         0,
         0);
      Add_Address_Space
        (sys.Address_Spaces,
         To_Unbounded_String ("addr2"),
         To_Unbounded_String ("processor2"),
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
         2,
         4,
         4,
         0,
         10,
         1,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         T2_ref,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor2"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr2"),
         Periodic_Type,
         0,
         3,
         5,
         5,
         0,
         10,
         2,
         0,
         Sched_Fifo);
      Add_Task
        (sys.Tasks,
         T3_ref,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         7,
         20,
         20,
         0,
         10,
         3,
         0,
         Sched_Fifo);

   end test13_xml;

-------------------------------------------------
--  Network examples
-------------------------------------------------


   procedure test_network1_xml (sys : out System) is

      core1_ref      : Core_Unit_Ptr;
      mem     	     : memories_table;
      P_ref          : Generic_Processor_Ptr;
      T1_ref, T2_ref : Generic_Task_Ptr;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> core1_ref,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 100,
	speed		=> 1,
	capacity	=> 101,
	period		=> 102,
	priority	=> 103,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Posix_1003_Highest_Priority_First_Protocol
      );
      Add_Processor
        (sys.Processors,
         P_ref,
         To_Unbounded_String ("processor1"),
         core1_ref);
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
         2,
         4,
         4,
         0,
         10,
         1,
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
         3,
         5,
         5,
         0,
         10,
         2,
         0,
         Sched_Fifo);
      Add_Network
        (sys.Networks,
         To_Unbounded_String ("a_network"),
         Shared_Bus);

   end test_network1_xml;


   procedure test_network2_xml (sys : out System) is

      core1_ref      : Core_Unit_Ptr;
      mem     	     : memories_table;
      P_ref          : Generic_Processor_Ptr;
      positions : positions_table;
      a_position : position;

   begin

      Initialize (sys);
      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> core1_ref,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 100,
	speed		=> 1,
	capacity	=> 101,
	period		=> 102,
	priority	=> 103,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Posix_1003_Highest_Priority_First_Protocol
      );

      Add_Processor
        (sys.Processors,
         P_ref,
         To_Unbounded_String ("processor1"),
         core1_ref);
        
	a_position.x:=1;
	a_position.y:=1;
	add(positions, To_Unbounded_String ("processor1"), a_position);

	a_position.x:=2;
	a_position.y:=2;
	add(positions, To_Unbounded_String ("processor1"), a_position);
	
	Add_network(sys.networks, To_Unbounded_String ("net1"), NOC,
		 Mesh_Topology, 1, 4, 2, 2, 2, 1, bounded_delay, Wormwole, XY, positions);

   end test_network2_xml;

   ----------------------------------------------------
   -- Set of architecture to test scheduling with offset
   ----------------------------------------------------

   -- Audsley
   procedure offset_test1 (sys : out System) is

      a_core                  : Core_Unit_Ptr;
      a_core_unit_table       : Core_Units_Table;
      mem     	     	      : memories_table;
      A, B, C, D, E           : Generic_Task_Ptr;
      ofa, ofb, ofc, ofd, ofe : Offsets_Table;
      off                     : Offset_Type;
      TransP                  : Transaction_Task_Group_Ptr;

   begin
      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Deadline_Monotonic_Protocol
      );
      Add (a_core_unit_table, a_core);
      Add_Processor
        (sys.Processors,
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

      off.offset_value := 51;
      off.activation   := 0;
      Add (ofa, off);

      off.offset_value := 11;
      off.activation   := 0;
      Add (ofb, off);

      off.offset_value := 60;
      off.activation   := 0;
      Add (ofc, off);

      off.offset_value := 41;
      off.activation   := 0;
      Add (ofd, off);

      off.offset_value := 90;
      off.activation   := 0;
      Add (ofe, off);

      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (A),
         To_Unbounded_String ("A"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         30,
         161,
         110,
         0,
         0,
         5,
         0,
         Sched_Fifo,
         ofa);
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (B),
         To_Unbounded_String ("B"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         30,
         161,
         40,
         0,
         0,
         1,
         0,
         Sched_Fifo,
         ofb);
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (C),
         To_Unbounded_String ("C"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         30,
         161,
         30,
         0,
         0,
         3,
         0,
         Sched_Fifo,
         ofc);
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (D),
         To_Unbounded_String ("D"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         10,
         161,
         59,
         0,
         0,
         2,
         0,
         Sched_Fifo,
         ofd);
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (E),
         To_Unbounded_String ("E"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         50,
         161,
         50,
         0,
         0,
         4,
         0,
         Sched_Fifo,
         ofe);

      Add_Task_Group
        (sys.Task_Groups,
         Generic_Task_Group_Ptr (TransP),
         To_Unbounded_String ("TransP"),
         Transaction_Type);

      TransP.period := 161;

      add (TransP.task_list, Generic_Task_Ptr (A));
      add (TransP.task_list, Generic_Task_Ptr (B));
      add (TransP.task_list, Generic_Task_Ptr (C));
      add (TransP.task_list, Generic_Task_Ptr (D));
      add (TransP.task_list, Generic_Task_Ptr (E));
   end offset_test1;

   -- Audsley, with 3 transactions
   procedure offset_test2 (sys : out System) is

      a_core                       : Core_Unit_Ptr;
      a_core_unit_table            : Core_Units_Table;
      mem     	     	      : memories_table;
      A, B, C, D, E, F             : Generic_Task_Ptr;
      ofa, ofb, ofc, ofd, ofe, off : Offsets_Table;
      offt                         : Offset_Type;
      Trans10, Trans20, Trans40    : Transaction_Task_Group_Ptr;

   begin
      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Deadline_Monotonic_Protocol
      );
      Add (a_core_unit_table, a_core);
      Add_Processor
        (sys.Processors,
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

      offt.offset_value := 51;
      offt.activation   := 0;
      Add (ofa, offt);

      offt.offset_value := 11;
      offt.activation   := 0;
      Add (ofb, offt);

      offt.offset_value := 60;
      offt.activation   := 0;
      Add (ofc, offt);

      offt.offset_value := 41;
      offt.activation   := 0;
      Add (ofd, offt);

      offt.offset_value := 90;
      offt.activation   := 0;
      Add (ofe, offt);

      offt.offset_value := 90;
      offt.activation   := 0;
      Add (off, offt);

      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (A),
         To_Unbounded_String ("A"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         10,
         1,
         0,
         0,
         1,
         0,
         Sched_Fifo,
         ofa);
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (B),
         To_Unbounded_String ("B"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         10,
         2,
         0,
         0,
         4,
         0,
         Sched_Fifo,
         ofb);
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (C),
         To_Unbounded_String ("C"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         5,
         20,
         6,
         0,
         0,
         2,
         0,
         Sched_Fifo,
         ofc);
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (D),
         To_Unbounded_String ("D"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         8,
         40,
         9,
         0,
         0,
         3,
         0,
         Sched_Fifo,
         ofd);
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (E),
         To_Unbounded_String ("E"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         8,
         40,
         14,
         0,
         0,
         6,
         0,
         Sched_Fifo,
         ofe);
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (F),
         To_Unbounded_String ("F"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         6,
         40,
         30,
         0,
         0,
         5,
         0,
         Sched_Fifo,
         off);

      Add_Task_Group
        (sys.Task_Groups,
         Generic_Task_Group_Ptr (Trans10),
         To_Unbounded_String ("Trans10"),
         Transaction_Type);

      Add_Task_Group
        (sys.Task_Groups,
         Generic_Task_Group_Ptr (Trans20),
         To_Unbounded_String ("Trans20"),
         Transaction_Type);

      Add_Task_Group
        (sys.Task_Groups,
         Generic_Task_Group_Ptr (Trans40),
         To_Unbounded_String ("Trans40"),
         Transaction_Type);

      Trans10.period := 10;
      Trans20.period := 20;
      Trans40.period := 40;

      add (Trans10.task_list, Generic_Task_Ptr (A));
      add (Trans10.task_list, Generic_Task_Ptr (B));
      add (Trans20.task_list, Generic_Task_Ptr (C));
      add (Trans40.task_list, Generic_Task_Ptr (D));
      add (Trans40.task_list, Generic_Task_Ptr (E));
      add (Trans40.task_list, Generic_Task_Ptr (F));
   end offset_test2;

   -- Audsley, same set as test2 but with 1 transaction after task
   --transformation
   procedure offset_test3 (sys : out System) is

      a_core                       : Core_Unit_Ptr;
      a_core_unit_table            : Core_Units_Table;
      mem     	     	      : memories_table;
      A, B, C, D, E, F             : Generic_Task_Ptr;
      ofa, ofb, ofc, ofd, ofe, off : Offsets_Table;
      offt                         : Offset_Type;
      TransP                       : Transaction_Task_Group_Ptr;

   begin
      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Deadline_Monotonic_Protocol
      );
      Add (a_core_unit_table, a_core);
      Add_Processor
        (sys.Processors,
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

      offt.offset_value := 51;
      offt.activation   := 0;
      Add (ofa, offt);

      offt.offset_value := 11;
      offt.activation   := 0;
      Add (ofb, offt);

      offt.offset_value := 60;
      offt.activation   := 0;
      Add (ofc, offt);

      offt.offset_value := 41;
      offt.activation   := 0;
      Add (ofd, offt);

      offt.offset_value := 90;
      offt.activation   := 0;
      Add (ofe, offt);

      offt.offset_value := 90;
      offt.activation   := 0;
      Add (off, offt);

      Add_Task_Group
        (sys.Task_Groups,
         Generic_Task_Group_Ptr (TransP),
         To_Unbounded_String ("TransP"),
         Transaction_Type);

      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (A),
         To_Unbounded_String ("A1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         10,
         1,
         0,
         0,
         1,
         0,
         Sched_Fifo,
         ofa);
      add (TransP.task_list, Generic_Task_Ptr (A));
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (A),
         To_Unbounded_String ("A2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         10,
         1,
         0,
         0,
         1,
         0,
         Sched_Fifo,
         ofa);
      add (TransP.task_list, Generic_Task_Ptr (A));
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (A),
         To_Unbounded_String ("A3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         10,
         1,
         0,
         0,
         1,
         0,
         Sched_Fifo,
         ofa);
      add (TransP.task_list, Generic_Task_Ptr (A));
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (A),
         To_Unbounded_String ("A4"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         10,
         1,
         0,
         0,
         1,
         0,
         Sched_Fifo,
         ofa);
      add (TransP.task_list, Generic_Task_Ptr (A));
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (B),
         To_Unbounded_String ("B1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         10,
         2,
         0,
         0,
         4,
         0,
         Sched_Fifo,
         ofb);
      add (TransP.task_list, Generic_Task_Ptr (B));
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (B),
         To_Unbounded_String ("B2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         10,
         2,
         0,
         0,
         4,
         0,
         Sched_Fifo,
         ofb);
      add (TransP.task_list, Generic_Task_Ptr (B));
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (B),
         To_Unbounded_String ("B3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         10,
         2,
         0,
         0,
         4,
         0,
         Sched_Fifo,
         ofb);
      add (TransP.task_list, Generic_Task_Ptr (B));
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (B),
         To_Unbounded_String ("B4"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         1,
         10,
         2,
         0,
         0,
         4,
         0,
         Sched_Fifo,
         ofb);
      add (TransP.task_list, Generic_Task_Ptr (B));
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (C),
         To_Unbounded_String ("C1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         5,
         20,
         6,
         0,
         0,
         2,
         0,
         Sched_Fifo,
         ofc);
      add (TransP.task_list, Generic_Task_Ptr (C));
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (C),
         To_Unbounded_String ("C2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         5,
         20,
         6,
         0,
         0,
         2,
         0,
         Sched_Fifo,
         ofc);
      add (TransP.task_list, Generic_Task_Ptr (C));
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (D),
         To_Unbounded_String ("D"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         8,
         40,
         9,
         0,
         0,
         3,
         0,
         Sched_Fifo,
         ofd);
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (E),
         To_Unbounded_String ("E"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         8,
         40,
         14,
         0,
         0,
         6,
         0,
         Sched_Fifo,
         ofe);
      Add_Task
        (sys.Tasks,
         Generic_Task_Ptr (F),
         To_Unbounded_String ("F"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("addr1"),
         Periodic_Type,
         0,
         6,
         40,
         30,
         0,
         0,
         5,
         0,
         Sched_Fifo,
         off);

      add (TransP.task_list, Generic_Task_Ptr (D));
      add (TransP.task_list, Generic_Task_Ptr (E));
      add (TransP.task_list, Generic_Task_Ptr (F));
   end offset_test3;

   procedure arinc653_cyclic (sys : out System) is

      a_core            : Core_Unit_Ptr;
      a_core_unit_table : Core_Units_Table;
      mem     	     	      : memories_table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Hierarchical_Cyclic_Protocol
      );
      Add (a_core_unit_table, a_core);

      Add_Processor
        (sys.Processors,
         To_Unbounded_String ("processor1"),
         a_core_unit_table);

      Add_Address_Space
        (sys.Address_Spaces,
         To_Unbounded_String ("partition1"),
         To_Unbounded_String ("processor1"),
         0,
         0,
         0,
         0,
         preemptive,
         2,
         empty_string,
         Rate_Monotonic_Protocol);
      Add_Address_Space
        (sys.Address_Spaces,
         To_Unbounded_String ("partition2"),
         To_Unbounded_String ("processor1"),
         0,
         0,
         0,
         0,
         preemptive,
         4,
         empty_string,
         Rate_Monotonic_Protocol);

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("partition1"),
         Periodic_Type,
         0,
         7,
         29,
         29,
         0,
         0,
         1,
         0,
         Sched_Fifo);

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("partition1"),
         Periodic_Type,
         0,
         3,
         10,
         10,
         0,
         0,
         2,
         0,
         Sched_Fifo);

      Add_Task
        (sys.Tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
         To_Unbounded_String ("partition2"),
         Periodic_Type,
         0,
         1,
         5,
         5,
         0,
         0,
         3,
         0,
         Sched_Fifo);

   end arinc653_cyclic;

   procedure arinc653_offline (sys : out System) is
   begin
      null;
   end arinc653_offline;

   procedure task100 (sys : out System) is

      a_core : Core_Unit_Ptr;
      mem     	     	      : memories_table;

   begin

      Initialize (sys);

      Add_core_unit (
	my_core_units  	=> sys.Core_units,
        a_core_unit	=> a_core,
        name		=> To_Unbounded_String ("core1"),
        is_preemptive	=> preemptive,
	quantum        	=> 0,
	speed		=> 1,
	capacity	=> 0,
	period		=> 0,
	priority	=> 0,
	file_name	=> empty_string,
        scheduling_protocol_name =>  empty_string,
      	a_scheduler 	=> Rate_Monotonic_Protocol
      );
      Add_Processor
        (sys.Processors,
         To_Unbounded_String ("processor1"),
         a_core);

      Add_Address_Space
        (sys.Address_Spaces,
         To_Unbounded_String ("addr1"),
         To_Unbounded_String ("processor1"),
         0,
         0,
         0,
         0);

      for i in 1 .. 100 loop
         Add_Task
           (sys.Tasks,
            suppress_space (To_Unbounded_String ("T" & i'Img)),
            To_Unbounded_String ("processor1"),
         To_Unbounded_String (""),
            To_Unbounded_String ("addr1"),
            Periodic_Type,
            0,
            1,
            10 + i,
            10 + i,
            0,
            0,
            1,
            0,
            Sched_Fifo);
      end loop;

   end task100;

-- 200 tasks and several processors/cores
   procedure task200 (sys : out System) is

      a_core 		: Core_Unit_Ptr;
      mem     	        : memories_table;

   begin

      Initialize (sys);

      for i in 1 .. 5 loop
      	Add_core_unit (
		my_core_units  	=> sys.Core_units,
        	a_core_unit	=> a_core,
        	name		=> suppress_space (To_Unbounded_String ("core" & i'Img)),
        	is_preemptive	=> preemptive,
		quantum        	=> 0,
		speed		=> 1,
		capacity	=> 0,
		period		=> 0,
		priority	=> 0,
		file_name	=> empty_string,
        	scheduling_protocol_name =>  empty_string,
      		a_scheduler 	=> Rate_Monotonic_Protocol
      	 );
         Add_Processor
           (sys.Processors,
            suppress_space (To_Unbounded_String ("processor" & i'Img)),
            a_core);

         Add_Address_Space
           (sys.Address_Spaces,
            suppress_space (To_Unbounded_String ("addr" & i'Img)),
            suppress_space (To_Unbounded_String ("processor" & i'Img)),
            0,
            0,
            0,
            0);
      end loop;

      for i in 1 .. 200 loop
         Add_Task
           (sys.Tasks,
            suppress_space (To_Unbounded_String ("T" & i'Img)),
            suppress_space
               (To_Unbounded_String
                   ("processor" & Integer'Image ((i mod 5) + 1))),
         To_Unbounded_String (""),
            suppress_space
               (To_Unbounded_String
                   ("addr" & Integer'Image ((i mod 5) + 1))),
            Periodic_Type,
            0,
            1,
            10 * i / 3 + 1,
            10 * i / 3 + 1,
            0,
            0,
            1,
            0,
            Sched_Fifo);
      end loop;

   end task200;

end architecture_models;
