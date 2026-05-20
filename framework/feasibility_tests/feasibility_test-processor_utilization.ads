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
--    $Rev: 4621 $
--    $Date: 2023-11-10 17:20:51 +0100 (ven., 10 nov. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;

with unbounded_strings;                 use unbounded_strings;
with Framework_Config;                  use Framework_Config;
with resource_set;                      use resource_set;
with Tasks;                             use Tasks;
with Task_Groups;                       use Task_Groups;
with Parameters;                        use Parameters;
with Parameters.extended;               use Parameters.extended;
use Parameters.User_Defined_Parameters_Table_Package;
with Offsets;                           use Offsets;
with Offsets.extended;                  use Offsets.extended;
use Offsets.Offsets_Table_Package;
with scheduler.fixed_priority;          use scheduler.fixed_priority;
with scheduler.fixed_priority.rm;       use scheduler.fixed_priority.rm;
with scheduler.fixed_priority.dm;       use scheduler.fixed_priority.dm;
with scheduler.fixed_priority.hpf;      use scheduler.fixed_priority.hpf;
with scheduler.dynamic_priority;        use scheduler.dynamic_priority;
with scheduler.dynamic_priority.edf;    use scheduler.dynamic_priority.edf;
with scheduler.dynamic_priority.llf;    use scheduler.dynamic_priority.llf;
with scheduler.dynamic_priority.d_over; use scheduler.dynamic_priority.d_over;
with scheduler.dynamic_priority.muf;    use scheduler.dynamic_priority.muf;
with doubles;                           use doubles;

with sets;

with call_framework_interface;          use call_framework_interface;

package feasibility_test.processor_utilization is

   function processor_utilization_over_deadline
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String;
      core_unit_name : in Unbounded_String := empty_string) return Double;

   function processor_utilization_over_period
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String;
      core_unit_name : in Unbounded_String := empty_string) return Double;

   procedure bound_on_processor_utilization
     (my_scheduler   : in     generic_scheduler_ptr;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Double;
      msg            : in out Unbounded_String);

   procedure bound_on_processor_utilization
     (my_scheduler   : in     dynamic_priority_scheduler;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Double;
      msg            : in out Unbounded_String);

   procedure bound_on_processor_utilization
     (my_scheduler   : in     fixed_priority_scheduler;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Double;
      msg            : in out Unbounded_String);

   procedure utilization_factor_feasibility_test
     (my_scheduler   : in     generic_scheduler_ptr;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Unbounded_String;
      output         : in     output_format := string_output);

   procedure utilization_factor_feasibility_test
     (my_scheduler   : in     d_over_scheduler;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Unbounded_String;
      output         : in     output_format := string_output);

   procedure utilization_factor_feasibility_test
     (my_scheduler   : in     edf_scheduler;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Unbounded_String;
      output         : in     output_format := string_output);

   procedure utilization_factor_feasibility_test
     (my_scheduler   : in     llf_scheduler;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Unbounded_String;
      output         : in     output_format := string_output);

   procedure utilization_factor_feasibility_test
     (my_scheduler   : in     muf_scheduler;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Unbounded_String;
      output         : in     output_format := string_output);

   procedure utilization_factor_feasibility_test
     (my_scheduler   : in     dm_scheduler;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Unbounded_String;
      output         : in     output_format := string_output);

   procedure utilization_factor_feasibility_test
     (my_scheduler   : in     rm_scheduler;
      my_tasks       : in     tasks_set;
      processor_name : in     Unbounded_String;
      result         : in out Unbounded_String;
      output         : in     output_format := string_output);

end feasibility_test.processor_utilization;
