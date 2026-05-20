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

with Ada.IO_Exceptions;      use Ada.IO_Exceptions;
with GNAT.Current_Exception; use GNAT.Current_Exception;
with unbounded_strings;      use unbounded_strings;
with GNAT.Command_Line;      use GNAT.Command_Line;
with GNAT.OS_Lib;            use GNAT.OS_Lib;
with Text_IO;                use Text_IO;
with version;                use version;
with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;
with systems;                use systems;
with Dependencies;           use Dependencies;
with task_dependencies;      use task_dependencies;
with task_set;               use task_set;
use task_set.generic_task_set;
use task_dependencies.half_dep_set;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with address_space_set; use address_space_set;
use address_space_set.generic_address_space_set;
with resource_set; use resource_set;
use resource_set.generic_resource_set;
with buffer_set; use buffer_set;
use buffer_set.generic_buffer_set;
with call_framework;    use call_framework;
with Tasks;             use Tasks;
with Address_Spaces;    use Address_Spaces;
with unbounded_strings; use unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
with debug; use debug;

package body applicability_constraint.data_sharing_protocol is

   function r6_query1_condition (d1 : dependency_ptr) return Boolean is
   begin

      return
        (not
         (d1.type_of_dependency = time_triggered_communication_dependency));

   end r6_query1_condition;

   function r6_query2_condition (d2 : dependency_ptr) return Boolean is
   begin

      return
        (not
         ((d2.time_triggered_timing_property = sampled_timing) or
-- SR       (d2.time_triggered_timing_property = immediate_timing) or
          (d2.time_triggered_timing_property = delayed_timing)));

   end r6_query2_condition;

   function r6_query3_condition (d3 : dependency_ptr) return Boolean is
   begin

      return (d3.type_of_dependency = time_triggered_communication_dependency);

   end r6_query3_condition;

   function r6 (sys : system) return Boolean is
   begin
      context := sys;
      return
        (get_number_of_elements
           (select_and_copy
              (context.dependencies.depends,
               r6_query1_condition'access)) =
         tasks_dependencies_range (0)) and
        (get_number_of_elements
           (select_and_copy
              ((select_and_copy
                  (context.dependencies.depends,
                   r6_query3_condition'access)),
               r6_query2_condition'access)) =
         tasks_dependencies_range (0));

   end r6;
   function r6_txt return Unbounded_String is
   begin

      return ("The constraint R6 is not met:") &
        unbounded_lf &
      -- SR ("data sharing protocol : port connections with sample, immediate or delayed timing.") &
        ("data sharing protocol : port connections with sample or delayed timing.") &
        unbounded_lf;

   end r6_txt;

end applicability_constraint.data_sharing_protocol;
