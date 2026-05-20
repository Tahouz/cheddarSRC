
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
--    $Rev: 3657 $
--    $Date: 2020-12-13 13:25:49 +0100 (dim., 13 déc. 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with GNAT.Command_Line;
with GNAT.OS_Lib;      use GNAT.OS_Lib;
with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Exceptions;   use Ada.Exceptions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Doubles;             use Doubles;
with systems;             use systems;
with Tasks;               use Tasks;
with task_set;            use task_set;
use task_set.generic_task_set;
with Dependencies;        use Dependencies;
with Parameters;          use Parameters;
with Parameters.extended; use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;
with framework;                use framework;
with call_framework;           use call_framework;
with Call_Framework_Interface; use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with call_scheduling_framework;         use call_scheduling_framework;
with multiprocessor_services;           use multiprocessor_services;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with time_unit_events;      use time_unit_events;
with Core_Units;          use Core_Units;
with Scheduler_Interface; use Scheduler_Interface;
with Processor_Interface; use Processor_Interface;
with Processors;          use Processors;
with processor_set;       use processor_set;
with task_dependencies;   use task_dependencies;
with Scheduler_Interface; use Scheduler_Interface;
with version;          use version;
with io_tools;         use io_tools;
with debug;            use debug;

with Ada.Containers.Ordered_Maps;


package voltage_scaling is

   -- Config variable
   --True for static algorithm
   --False for dynamic algorithm
   only_static_algorithm : Boolean := False;

   --True for look ahead algorithm
   --False for cycle_conserving algorithm
   look_ahead_algorithm : Boolean := True;

   -- variable global
   -- EDF or RM
   scheduler_type : schedulers_type;

   -- Frequency table
   type tabfreq is array (0 .. 3) of Double;
   freqs     : tabfreq := (0.25, 0.5, 0.75, 1.0);
   curr_freq : Integer := 100;

   -- Last current time of a task execution
   curr_time_task_exec : Natural := 0;

   fj : Double := 1.0;

   -- Hashmap
   type dvs_hashmap_type_element is record
      c_left       : Double;
      a_task       : generic_task_ptr;
      element      : Double;
      release_time : Natural;
   end record;
   package DVS_map_package is new Ada.Containers.Ordered_Maps
     (Element_Type => dvs_hashmap_type_element,
      Key_Type     => Unbounded_String);
   subtype dvs_map_subtype is DVS_map_package.map;
   DVS_map : dvs_map_subtype;

   -- init
   procedure dvfs_init_voltage_scaling
     (a_processor : in generic_processor_ptr);

   -- static voltage scaling
   function select_frequency_static_voltage_scaling
     (my_tasks : dvs_map_subtype) return Double;

   function EDF_test_static_voltage_scaling
     (my_tasks : dvs_map_subtype;
      freq     : Double) return Boolean;
   function RM_test_static_voltage_scaling
     (my_tasks : dvs_map_subtype;
      freq     : Double;
      pi       : Natural) return Boolean;

   -- Cycle conserving EDF
   function select_frequency_cycle_conserving_edf
     (a_task_Ui : dvs_map_subtype) return Double;
   procedure cycle_conserving_task_release_edf
     (a_task        :     generic_task_ptr;
      new_frequency : out Double);
   procedure cycle_conserving_task_completion_edf
     (a_task        :     generic_task_ptr;
      new_frequency : out Double);

   -- Cycle conserving RM
   function select_frequency_cycle_conserving_rm
     (a_task_Ui       : dvs_map_subtype;
      current_time    : Natural;
      task_is_release : Boolean) return Double;
   procedure cycle_conserving_task_release_rm
     (a_task        :     generic_task_ptr;
      current_time  :     Natural;
      new_frequency : out Double);
   procedure cycle_conserving_task_completion_rm
     (a_task        :     generic_task_ptr;
      current_time  :     Natural;
      new_frequency : out Double);
   procedure cycle_conserving_task_execution_rm (a_task : generic_task_ptr);
   procedure cycle_conserving_task_allocate_cycles (ki : Double);

   -- Look ahead
   function select_frequency_look_ahead (x : Double) return Double;
   procedure look_ahead_task_release
     (a_task        :        generic_task_ptr;
      current_time  : in     Natural;
      new_frequency :    out Double);
   procedure look_ahead_task_completion
     (a_task        :        generic_task_ptr;
      current_time  : in     Natural;
      new_frequency :    out Double);
   procedure look_ahead_task_execution (a_task : generic_task_ptr);
   procedure look_ahead_task_defer
     (a_task_Ui     :        dvs_map_subtype;
      current_time  : in     Natural;
      new_frequency :    out Double);

   -- Other
   function max_cycles_until_next_deadline
     (a_task_Ui    : in dvs_map_subtype;
      current_time : in Natural) return Natural;
   procedure new_frequency_double_to_integer
     (new_frequency_double : in     Double;
      new_frequency        :    out Integer);

   -- Procedure call by scheduler.adb
   procedure dvfs_upon_running_task
     (an_event      : in     time_unit_event_ptr;
      current_time  : in     Natural;
      new_frequency :    out Integer);
   procedure dvfs_upon_task_release
     (an_event      : in     time_unit_event_ptr;
      current_time  : in     Natural;
      new_frequency :    out Integer);
   procedure dvfs_upon_task_completion
     (an_event      : in     time_unit_event_ptr;
      current_time  : in     Natural;
      new_frequency :    out Integer);

end voltage_scaling;
