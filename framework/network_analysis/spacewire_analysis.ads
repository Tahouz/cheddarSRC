
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
--    $Rev: 5248 $
--    $Date: 2024-11-06 13:44:23 +0100 (mer., 06 nov. 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Exceptions;        use Ada.Exceptions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Command_Line;      use Ada.Command_Line;
with GNAT.Command_Line;
with GNAT.OS_Lib;           use GNAT.OS_Lib;
with Ada.Real_Time;         use Ada.Real_Time;

with call_framework;           use call_framework;
with call_framework_interface; use call_framework_interface;
use call_framework_interface.framework_response_package;
use call_framework_interface.framework_request_package;
with framework;                         use framework;
with call_scheduling_framework;         use call_scheduling_framework;
with multiprocessor_services;           use multiprocessor_services;
with multiprocessor_services_interface; use multiprocessor_services_interface;
use multiprocessor_services_interface.scheduling_result_per_processor_package;
with Objects;  use Objects;
with Tasks;    use Tasks;
with Task_Set; use Task_Set;
use task_set.generic_task_set;
with Systems;           use Systems;
with Processors;        use Processors;
with Processor_Set;     use Processor_Set;
with Messages;     use Messages;
with Message_Set;     use Message_Set;
with Dependencies;    use Dependencies;
with networks;        use networks;
with Address_Spaces;    use Address_Spaces;
with Address_Space_Set; use Address_Space_Set;
with Core_Units;        use Core_Units;
use Core_Units.Core_Units_Table_Package;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with parameters;          use parameters;
with parameters.extended; use parameters.extended;
use parameters.framework_parameters_table_package;
with systems;             use systems;
with Processor_Interface; use Processor_Interface;
with Scheduler_Interface; use Scheduler_Interface;

with version;           use version;
with unbounded_strings; use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with Random_Tools;         use Random_Tools;
with architecture_factory; use architecture_factory;
with unbounded_strings;    use unbounded_strings;
with call_framework;       use call_framework;
with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;
with doubles; use doubles;

with scheduling_analysis;          use scheduling_analysis;
with scheduling_analysis.extended; use scheduling_analysis.extended;
with scheduling_analysis.extended.task_analysis;
use scheduling_analysis.extended.task_analysis;
use scheduling_analysis.extended.task_occurence_table_package;


with time_unit_events; use time_unit_events;
use time_unit_events.time_unit_lists_package;
use time_unit_events.time_unit_package;
with tdma; use tdma;
use tdma.tdma_set;
with natural_util ; use natural_util ; 
with discrete_util; 



package spacewire_analysis is


  procedure display_scheduled_task;
  procedure compute_worst_execution_time (sys : in system);
  function  task_wakeup_compute (sys : in system; a_task : in Generic_task_Ptr) return double;
  procedure ppcm_compute (sys : in system; PPCM  : out Natural);
  procedure ppcm_compute (sys : in system; PPCM  : out double);
  procedure compute_scheduling (sys : in out system; processor_name : in unbounded_string; Feasibility_Interval : in integer);
  procedure apply_chetto(sys : in out system);


  procedure create_tdma_frame(sys : in system; frame : in out tdma_frame_type);
  procedure display_tdma_frame(frame : in tdma_frame_type);


end spacewire_analysis;
