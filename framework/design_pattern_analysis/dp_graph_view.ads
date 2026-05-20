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

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Generic_Graph; use Generic_Graph;

with Generic_Graph.extended; use Generic_Graph.extended;

with DP_Graph; use DP_Graph;

with DP_Graph.extended; use DP_Graph.extended;

with Tasks; use Tasks;

with Buffers; use Buffers;

with Messages; use Messages;

with Dependencies; use Dependencies;

with Resources; use Resources;

with systems; use systems;

with Processors; use Processors;

with convert_strings;

with convert_unbounded_strings;

with lists;

with Text_IO; use Text_IO;

with Ada.Finalization;

with unbounded_strings; use unbounded_strings;

use unbounded_strings.unbounded_string_list_package;

with Unchecked_Deallocation;

package dp_graph_view is

   undetected_graph_construction_error_exception : exception;

   unrecognized_design_pattern : exception;

   --Design patterns enumeration
   --
   type design_pattern is (time_triggered_communication, ravenscar, unplugged);

   --Graph list
   --

   package graph_list_package is new lists (graph_ptr, Put, Free, XML_String);
   use graph_list_package;
   subtype graph_list is graph_list_package.list;
   subtype graph_list_iterator is graph_list_package.iterator;

   --Views based on Dependency types
   --

   function time_triggered_communication_view (obj : in graph) return graph;
   function communication_view (obj : in graph) return graph;
   function resource_view (obj : in graph) return graph;

   --View of Graph connex components
   --

   function connexity_view (obj : in graph) return graph_list;

   --View based on processors's names
   --

   function processor_view (obj : in graph) return graph_list;
   function processor_view
     (obj            : in graph;
      processor_name : in Unbounded_String) return graph;

   --Sub-System from Original system and a view
   --

   function get_subsystem_from_graph
     (obj      : in graph;
      original : in system) return system;

   --Annex functionnalities
   --

   procedure get_task_node_by_task_name
     (obj       : in     graph_ptr;
      task_name : in     Unbounded_String;
      succeed   :    out Boolean;
      res       :    out task_node_ptr);
   procedure get_task_node_by_task_name
     (obj       : in     graph;
      task_name : in     Unbounded_String;
      succeed   :    out Boolean;
      res       :    out task_node_ptr);

   function task_node_in_graph
     (obj       : in graph;
      task_name : in Unbounded_String) return Boolean;
   function dependency_edge_in_graph
     (obj       : in graph;
      edge_name : in Unbounded_String) return Boolean;

   --Binary Operators
   --

   function graph_minus (graph_a : in graph; graph_b : in graph) return graph;

   function graph_union (graph_a : in graph; graph_b : in graph) return graph;
   function graph_union
     (graph_a : in graph_ptr;
      graph_b : in graph_ptr) return graph_ptr;

   --Composition Analysis
   --

   function potential_design_pattern (g : in graph) return design_pattern;
   function compose (g_list : in graph_list) return design_pattern;
   function compose_aux
     (dp : in design_pattern;
      g  : in graph_ptr) return design_pattern;

end dp_graph_view;
