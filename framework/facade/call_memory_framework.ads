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
--    $Rev: 4720 $
--    $Date: 2023-12-19 15:31:20 +0100 (mar., 19 déc. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Call_Framework_Interface; use Call_Framework_Interface;
with Framework_Config;         use Framework_Config;
with systems;                  use systems;
with Processors;               use Processors;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with Buffers;                  use Buffers;
with Scheduling_Analysis;          use Scheduling_Analysis;
use Scheduling_Analysis.Buffer_Size_Package;
with indexed_tables;

package call_memory_framework is

   package buffer_result_package is new indexed_tables
     (buffer_size_table, buffer_ptr, Framework_Config.Max_Buffers, 0, put,
      initialize, Buffers.Put_Name, Get_Name, xml_root_string, xml_string);
   use buffer_result_package;

   subtype buffer_result_table is buffer_result_package.indexed_table;
   subtype buffer_result_range is buffer_result_package.indexed_table_range;

   -- Last computed buffer size
   --
   buff : buffer_result_table;

   -- Compute global memory requirement (stack, buffer, text, ....)
   --
   procedure compute_memory_requirement_analysis
     (sys                       : in system; result : in out Unbounded_String;
      update_address_spaces_set : in Boolean;
      output                    : in output_format := string_output);

   -- Perform analysis on buffer requirement from a scheduling
   -- simulation
   --
   procedure compute_buffer_scheduling_simulation
     (sys         : in system; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr;
      output      : in output_format := string_output);

   -- Perform analysis on buffer requirement from analytical
   -- equation
   --
   procedure compute_buffer_feasibility_tests
     (sys         : in system; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr;
      output      : in output_format := string_output);

   procedure compute_memory_interferences_delays
     (sys    : in     system; a_processor : in generic_processor_ptr;
      result : in out Unbounded_String;
      output : in     output_format := string_output);

end call_memory_framework;
