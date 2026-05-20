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
--    $Date: 2023-09-29 16:02:19 +0200 (ven. 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with translate;  use translate;
with buffer_set; use buffer_set;
use buffer_set.generic_buffer_set;
with Resources;    use Resources;
with resource_set; use resource_set;
use resource_set.generic_resource_set;
with natural_util;   use natural_util;
with Tasks.extended; use Tasks.extended;
with task_set;       use task_set;
use task_set.generic_task_set;
with time_unit_events; use time_unit_events;
use time_unit_events.time_unit_lists_package;
use time_unit_events.time_unit_package;
with event_analyzer_set; use event_analyzer_set;
use event_analyzer_set.generic_event_analyzer_set;
with natural_util; use natural_util;
with tables;
with indexed_tables;
with Unchecked_Deallocation;
with translate;    use translate;
with natural_util; use natural_util;

package body Scheduling_Analysis.extended.mixed_criticality_analysis is

   -- 1. Compute the number of mode change
   -- 2. Measure time spent in a mode 
   --
   procedure number_of_mode_change_from_simulation
     (sched    : in scheduling_sequence_ptr;
      nb_mode  : in out Natural;
      time_mode: in out Natural)
   is
   begin
      for i in 0 .. sched.nb_entries - 1 loop
         if (sched.entries (i).data.type_of_event = mode_change)
         then
         	nb_mode := nb_mode + 1;
         	time_mode := sched.entries(i).item;           
         end if;
      end loop;
      
      -- The last mode change is for save the values
      nb_mode := nb_mode - 1;
   end number_of_mode_change_from_simulation;
   
   -- 3. Compute the quality for each task
   --
   procedure compute_quality_from_simulation
     (sched    : in scheduling_sequence_ptr;
      quality  : in out Natural)
   is
   begin
      for i in 0 .. sched.nb_entries - 1 loop
         if (sched.entries (i).data.type_of_event = mode_change)
         then
         	quality := sched.entries(i).item;  
         end if;
      end loop;
   end compute_quality_from_simulation;
   
   -- 4. Compute the number of missed deadline
   --
   procedure compute_missed_deadline_from_simulation
     (sched    : in scheduling_sequence_ptr;
      nb_missed_deadline  : in out Natural)
   is
   begin
      for i in 0 .. sched.nb_entries - 1 loop
         if (sched.entries (i).data.type_of_event = mode_change)
         then
         	nb_missed_deadline := sched.entries(i).item;
	 	put_line("missed deadline : "&sched.entries(i).item'img);
               
         end if;
      end loop;
   end compute_missed_deadline_from_simulation;
   
   
   
   -- 5. Compute the number ending tasks
   --
   procedure number_of_ending_tasks_from_simulation
   (sched    : in scheduling_sequence_ptr;
    nb_job_stopped	      : in out Natural)
   is
   begin
      nb_job_stopped := 0;
      for i in 0 .. sched.nb_entries - 1 loop
         if (sched.entries (i).data.type_of_event = mode_change)
         then
         	nb_job_stopped := sched.entries(i).item;  
         end if;
      end loop;
   end number_of_ending_tasks_from_simulation;
   
   
   


end Scheduling_Analysis.extended.mixed_criticality_analysis;



