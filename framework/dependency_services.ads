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

with processor_set; use processor_set;
use processor_set.generic_processor_set;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with task_set; use task_set;
use task_set.generic_task_set;
with task_dependencies;     use task_dependencies;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Buffers;               use Buffers;
with Tasks;                 use Tasks;
with systems;               use systems;

package dependency_services is

   -- Raised when tasks in a DAG have differents
   -- value of period
   --
   dependencies_period_error : exception;

   -- Raised when tasks in a DAG are of different types
   --
   task_model_error : exception;

   -- Raised when a method do not permit a cyclic graph
   --
   cyclic_graph_error : exception;

   -- Raised if periodic producer/consumer tasks are expected
   --
   task_must_be_periodic : exception;

   -- Raised when deadlines are two small to apply Chetto algorithm
   --
   deadline_exhausted : exception;

   -- Compute task parameters of a DAG organized tasks
   -- according to Chetto/Blazewicz method
   --
   procedure set_parameters_according_to_chetto
     (my_dependencies    : in     tasks_dependencies_ptr;
      my_tasks           : in out tasks_set;
      compute_deadlines  : in     Boolean;
      compute_priorities : in     Boolean);

   -- Compute end to end response time by the Holistic
   -- method
   --
   procedure compute_end_to_end_response_time
     (my_sys           : in out system;
      one_step         : in     Boolean;
      update_tasks_set : in     Boolean;
      msg              : in out Unbounded_String;
      rt               : in out response_time_table);

   -- Test is two tables of response time are equals
   --
   function is_equal
     (rtn  : in response_time_table;
      rtn1 : in response_time_table) return Boolean;

   -- Test is all deadlines are missed when we compute
   -- end to end response time
   -- In this case, we stop the computing
   --
   function all_deadlines_missed (rtn : in response_time_table) return Boolean;

   -- Check that all task of a dependency graph have the same period
   -- If "Processor_Name" is an empty string, do this check
   -- on all processors
   --
   procedure dependencies_same_periods_control
     (my_tasks       : in tasks_set;
      my_deps        : in tasks_dependencies_ptr;
      processor_name : in Unbounded_String);

   -- Check that all task of a dependency graph have harmonic period
   -- If "Processor_Name" is an empty string, do this check
   -- on all processors
   --
   procedure dependencies_harmonic_periods_control
     (my_tasks       : in tasks_set;
      my_deps        : in tasks_dependencies_ptr;
      processor_name : in Unbounded_String);

   -- Check that all task of a dependency graph have the same type
   -- If "Processor_Name" is an empty string, do this check
   -- on all processors
   --
   procedure dependencies_task_models_control
     (my_tasks       : in tasks_set;
      my_deps        : in tasks_dependencies_ptr;
      processor_name : in Unbounded_String);

   -- Check if producers/consumers are periodic
   --
   procedure periodic_buffer_control
     (my_tasks : in tasks_set;
      a_buffer : in buffer_ptr);

end dependency_services;
