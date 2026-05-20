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

with applicability_constraint.all_tasks_are_periodic;
use applicability_constraint.all_tasks_are_periodic;
with applicability_constraint.all_tasks_are_periodic_or_sporadic;
use applicability_constraint.all_tasks_are_periodic_or_sporadic;
with applicability_constraint.no_shared_cpu;
use applicability_constraint.no_shared_cpu;
with applicability_constraint.allowed_protocol;
use applicability_constraint.allowed_protocol;
with applicability_constraint.pip_no_deadlock;
use applicability_constraint.pip_no_deadlock;
with applicability_constraint.no_buffer;
use applicability_constraint.no_buffer;
with applicability_constraint.no_dependencies;
use applicability_constraint.no_dependencies;
with applicability_constraint.ceiling_priority_assignment;
use applicability_constraint.ceiling_priority_assignment;
with applicability_constraint.at_least_one_data;
use applicability_constraint.at_least_one_data;
with applicability_constraint.no_shared_resources;
use applicability_constraint.no_shared_resources;
with applicability_constraint.data_sharing_protocol;
use applicability_constraint.data_sharing_protocol;
with applicability_constraint.data_connectivity;
use applicability_constraint.data_connectivity;
with applicability_constraint.unsimultaneous_release_time_constraint;
use applicability_constraint.unsimultaneous_release_time_constraint;
with applicability_constraint.simultaneous_release_time_constraint;
use applicability_constraint.simultaneous_release_time_constraint;
with applicability_constraint.period_equal_deadline_constraint;
use applicability_constraint.period_equal_deadline_constraint;
with applicability_constraint.period_smaller_than_deadline_constraint;
use applicability_constraint.period_smaller_than_deadline_constraint;
with applicability_constraint.period_larger_than_deadline_constraint;
use applicability_constraint.period_larger_than_deadline_constraint;
with feasibility_tests_for_time_triggered_communication;
use feasibility_tests_for_time_triggered_communication;
with applicability_constraints_main_structure;
use applicability_constraints_main_structure;
with feasibility_tests_main_structure_factory;
use feasibility_tests_main_structure_factory;
with Generic_Graph;          use Generic_Graph;
with Dependencies;           use Dependencies;
with Ada.IO_Exceptions;      use Ada.IO_Exceptions;
with GNAT.Current_Exception; use GNAT.Current_Exception;
with unbounded_strings;      use unbounded_strings;
with GNAT.Command_Line;      use GNAT.Command_Line;
with GNAT.OS_Lib;            use GNAT.OS_Lib;
with Text_IO;                use Text_IO;
with version;                use version;
with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;
with systems;                use systems;
with task_set;               use task_set;
with task_dependencies;      use task_dependencies;
use task_dependencies.half_dep_set;
with processor_set;     use processor_set;
with address_space_set; use address_space_set;
with resource_set;      use resource_set;
with buffer_set;        use buffer_set;
with call_framework;    use call_framework;
with Tasks;             use Tasks;
use task_set.generic_task_set;
with debug;         use debug;
with Generic_Graph; use Generic_Graph;
use Generic_Graph.Edge_Lists_Package;
use Generic_Graph.Node_Lists_Package;
with DP_Graph;      use DP_Graph;
with dp_graph_view; use dp_graph_view;
use dp_graph_view.graph_list_package;
with architecture_factory; use architecture_factory;

package architecture_analyzer is

   function analyze (sys : system) return Unbounded_String;

   function time_triggered_communication_txt
     (sys : system) return Unbounded_String;
   function ravenscar_txt (sys : system) return Unbounded_String;
   function unplugged_txt (sys : system) return Unbounded_String;
   function blackboard_txt (sys : system) return Unbounded_String;
   function environment_uni_processor_txt
     (sys : system) return Unbounded_String;

   function time_triggered_communication_bool (sys : system) return Boolean;
   function ravenscar_bool (sys : system) return Boolean;
   function unplugged_bool (sys : system) return Boolean;
   function blackboard_bool (sys : system) return Boolean;
   function queuedbuffer_bool (sys : system) return Boolean;
   function environment_uni_processor_bool (sys : system) return Boolean;

   procedure write_result_to_file
     (res       : in Unbounded_String;
      file_name : in Unbounded_String);
end architecture_analyzer;
