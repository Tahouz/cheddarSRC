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

with task_set; use task_set;
use task_set.generic_task_set;
with time_unit_events; use time_unit_events;
use time_unit_events.time_unit_lists_package;
use time_unit_events.time_unit_package;
with Tasks.extended; use Tasks.extended;
with Buffers;        use Buffers;
use Buffers.Buffer_Roles_Package;
with event_analyzer_set; use event_analyzer_set;
use event_analyzer_set.generic_event_analyzer_set;
with queueing_system; use queueing_system;
use queueing_system.a_resp_time_consumer;
with resource_set; use resource_set;
use resource_set.generic_resource_set;
with tables;
with indexed_tables;
with access_lists;
with Unchecked_Deallocation;
with queueing_system; use queueing_system;
use queueing_system.a_resp_time_consumer;

package Scheduling_Analysis.extended.task_analysis is

   -- Compute number of task preemption from simulation
   --
   function number_of_preemption_from_simulation
     (sched    : in scheduling_sequence_ptr;
      my_tasks : in tasks_set) return Natural;

   -- Compute number of switch context from simulation
   --
   function number_of_switch_context_from_simulation
     (sched : in scheduling_sequence_ptr) return Natural;

   -- Compute number of overflow from simulation
   --
   function number_of_overflow_from_simulation
     (sched : in scheduling_sequence_ptr) return Natural;

   -- Compute number of underflow from simulation
   --
   function number_of_underflow_from_simulation
     (sched : in scheduling_sequence_ptr) return Natural;

   -- Compute the worst/best/average response time of a task from simulation
   --
   procedure response_time_by_simulation
     (my_task :        generic_task_ptr;
      sched   : in     scheduling_sequence_ptr;
      msg     : in out Unbounded_String;
      max     : in out Natural;
      min     : in out Natural;
      average : in out Double);

   -- Compute ALL response times of a task from simulation
   --
   procedure all_response_times_by_simulation
     (my_task : in     generic_task_ptr;
      sched   : in     scheduling_sequence_ptr;
      result  : in out task_occurence_table_ptr);

   -- Compute probability distribution of response time from simulation
   --
   procedure compute_response_time_distribution
     (my_tasks       : in     tasks_set;
      sched          : in     scheduling_sequence_ptr;
      processor_name :        Unbounded_String;
      result         : in out densities_table);

   -- Consumer of a buffer response from simulation
   -- (required for MP1 criteria computation)
   --
   procedure consumer_response_time
     (sched              : in     scheduling_sequence_ptr;
      consumer_resp_time : in out resp_time_consumer_table_ptr;
      my_consumer_task   : in     generic_task_ptr);

end Scheduling_Analysis.extended.task_analysis;
