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
--    $Rev: 5538 $
--    $Date: 2025-04-09 12:58:25 +0200 (mer., 09 avril 2025) $
--    $Author: leboudec $
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

package Scheduling_Analysis.extended.mixed_criticality_analysis is

   -- Compute number of mode change number from simulation
   --
   procedure number_of_mode_change_from_simulation
     (sched    : in scheduling_sequence_ptr;
      nb_mode  : in out Natural;
      time_mode: in out Natural);
    
   procedure compute_quality_from_simulation
     (sched    : in scheduling_sequence_ptr;
      quality  : in out Natural);
      
   procedure compute_missed_deadline_from_simulation
     (sched    : in scheduling_sequence_ptr;
      nb_missed_deadline  : in out Natural);
      
   procedure number_of_ending_tasks_from_simulation
   	(sched	: in scheduling_sequence_ptr;
   	 nb_job_stopped	: in out Natural);
   	 
end Scheduling_Analysis.extended.mixed_criticality_analysis;



