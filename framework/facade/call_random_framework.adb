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

with Framework_Config; use Framework_Config;
with translate;        use translate;
with resource_set;     use resource_set;
use resource_set.generic_resource_set;
with task_set; use task_set;
use task_set.generic_task_set;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Densities_Table_Package;
use Scheduling_Analysis.Density_Package;
with Scheduling_Analysis.extended.task_analysis;
use Scheduling_Analysis.extended.task_analysis;
with buffer_set; use buffer_set;
use buffer_set.generic_buffer_set;
with double_util;       use double_util;
with unbounded_strings; use unbounded_strings;
with message_set;       use message_set;
use message_set.generic_message_set;
with framework;                         use framework;
with call_scheduling_framework;         use call_scheduling_framework;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with xml_tag; use xml_tag;
with debug;   use debug;

package body call_random_framework is

   procedure compute_response_time_density
     (sys         : in System; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr;
      output      : in Output_Format := String_Output)
   is

      proba : densities_table;

   begin

      put_debug ("Call Compute_Response_Time_Density");

      result := To_Unbounded_String ("");

      for i in 0 .. sched.nb_entries - 1 loop

         if sched.entries (i).item = a_processor then

            initialize (proba);
            compute_response_time_distribution
              (sys.tasks, sched.entries (i).data.result,
               sched.entries (i).item.name, proba);
            for i in 0 .. proba.nb_entries - 1 loop
               result :=
                 result & lb_minus & lb_task (Current_Language) &
                 unbounded_sp & To_String (proba.entries (i).item.name) &
                 lb_colon & unbounded_lf;
               for k in 0 .. proba.entries (i).data.nb_entries - 1 loop
                  result :=
                    result & To_Unbounded_String ("   ") &
                    To_Unbounded_String ("P(") &
                    lb_response_time (Current_Language) & lb_equal &
                    To_Unbounded_String
                      (proba.entries (i).data.entries (k).response_time'Img) &
                    To_Unbounded_String (")=") &
                    format (proba.entries (i).data.entries (k).probability) &
                    unbounded_lf;
               end loop;
            end loop;

         end if;

      end loop;

   exception
      when task_set.task_must_be_periodic =>
         result :=
           result & lb_minus &
           lb_compute_scheduling_error_5 (Current_Language) & unbounded_lf;
      when task_set.task_model_error =>
         result :=
           result & lb_minus &
           lb_compute_scheduling_error_6 (Current_Language) & unbounded_lf;

   end compute_response_time_density;

end call_random_framework;
