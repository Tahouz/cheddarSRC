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
--    $Rev: 4714 $
--    $Date: 2023-12-18 00:07:26 +0100 (lun., 18 déc. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Doubles;  use Doubles;
with xml_tag;  use xml_tag;
with Tasks;    use Tasks;
with task_set; use task_set;
use task_set.generic_task_set;
with resource_set; use resource_set;
use resource_set.generic_resource_set;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with translate;                    use translate;
with unbounded_strings;            use unbounded_strings;
with Framework_Config;             use Framework_Config;
with Scheduler_Interface;          use Scheduler_Interface;
with scheduler;                    use scheduler;
with scheduler.fixed_priority;     use scheduler.fixed_priority;
with Scheduling_Analysis;          use Scheduling_Analysis;
with Scheduling_Analysis.extended; use Scheduling_Analysis.extended;
use Scheduling_Analysis.Deadlock_Package;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
use Scheduling_Analysis.Priority_Inversion_List_Package;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with call_scheduling_framework; use call_scheduling_framework;
with double_util;               use double_util;
with debug;                     use debug;
with architecture_analyzer;     use architecture_analyzer;
with scheduling_anomalies_services.offline;
use scheduling_anomalies_services.offline;

package body call_design_pattern_framework is

   procedure select_feasibility_tests_simple_system
     (sys    : in out System; result : in out Unbounded_String;
      output : in     Output_Format := String_Output)
   is
   begin
      result :=
        result & analyze (sys) & unbounded_lf & unbounded_lf & unbounded_lf;
   end select_feasibility_tests_simple_system;

   procedure select_feasibility_tests_compositional_system
     (sys    : in out System; result : in out Unbounded_String;
      output : in     Output_Format := String_Output)
   is
   begin
      result :=
        To_Unbounded_String ("     This Call is not functionnal yet     ");
   end select_feasibility_tests_compositional_system;

   procedure check_scheduling_anomalies
     (sys    : in out System; result : in out Unbounded_String;
      output : in     Output_Format := String_Output)
   is

      msg : Unbounded_String := empty_string;

   begin
      scheduling_anomalies_analyzer (sys, msg);
      result := result & msg;
   end check_scheduling_anomalies;

end call_design_pattern_framework;
