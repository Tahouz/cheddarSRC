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

with Ada.Exceptions;                    use Ada.Exceptions;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Text_IO;                           use Text_IO;

with Resources;                         use Resources;
use Resources.Resource_Accesses;
with time_unit_events;                  use time_unit_events;
use time_unit_events.time_unit_package;
with natural_util;                      use natural_util;
with double_util;                       use double_util;
with integer_util;                      use integer_util;
with Objects;                           use Objects;
with Objects.extended;                  use Objects.extended;
with initialize_framework;              use initialize_framework;
with translate;                         use translate;
with unbounded_strings;                 use unbounded_strings;
with scheduler;                         use scheduler;
with Scheduling_Analysis;               use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with scheduler.dynamic_priority.edf;    use scheduler.dynamic_priority.edf;

with priority_assignment.rm;            use priority_assignment.rm;
with priority_assignment.dm;            use priority_assignment.dm;
with systems;                           use systems;
with xml_tag;                           use xml_tag;
with translate;                         use translate;
with Doubles;                           use Doubles;


package feasibility_test.processor_demand is

   type feasibility_test_motivation is
     (unknown, by_dbf, by_processor_utilization_factor);

   type feasibility_test_report is record
      feasible                    : Boolean;
      motivation                  : feasibility_test_motivation;
      processor_utilization       : Double;
      processor_utilization_bound : Double;
      check_interval              : Natural;
      overrun_time                : Natural;
   end record;

   procedure sporadic_periodic_task_set_feasibility_test
     (my_scheduler   : in     generic_scheduler_ptr;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out feasibility_test_report);

   function processor_utilization_over_period_without_periodic_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Double;

   function compute_hyperperiod_without_periodic_control
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String := empty_string) return Integer;

   function has_a_deadline_less_than_period
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Boolean;

   function max_deadline_of_taskset
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Natural;

   procedure update_demand_bound_function
     (my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      t              : in     Natural;
      dbf            : in out Natural);

end feasibility_test.processor_demand;
