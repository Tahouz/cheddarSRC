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
use Generic_Graph.Edge_Lists_Package;
use Generic_Graph.Node_Lists_Package;

with DP_Graph;          use DP_Graph;
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

with Text_IO; use Text_IO;

with Ada.Finalization;

with unbounded_strings; use unbounded_strings;

use unbounded_strings.unbounded_string_list_package;

with debug; use debug;

with Unchecked_Deallocation;

package body dp_graph_view is

   --Views based on Dependency types
   --

   function time_triggered_communication_view (obj : in graph) return graph is
      res                 : graph;
      e_iterator          : edge_lists_iterator;
      current_edge        : generic_edge_ptr;
      succeed             : Boolean;
      temporary_task_node : task_node_ptr;

   begin

      Initialize (res);
      initialize (temporary_task_node);

      reset_head_iterator (obj.Edges, e_iterator);
      if not is_empty (obj.Edges) then
         current_element (obj.Edges, current_edge, e_iterator);

         while (not is_tail_element (obj.Edges, e_iterator)) loop

            if element_in_list
                (To_Unbounded_String
                   ("DP_GRAPH.Time_Triggered_Communication_EDGE"),
                 type_of (current_edge))
            then

               add_generic_edge (res, Copy (current_edge), succeed);

               get_task_node_by_task_name
                 (obj,
                  current_edge.all.Node_1,
                  succeed,
                  temporary_task_node);
               if succeed then

                  if not task_node_in_graph (res, current_edge.all.Node_1) then
                     add_node
                       (res,
                        Copy (task_node_ptr (temporary_task_node)),
                        succeed);
                  end if;
               else
                  raise undetected_graph_construction_error_exception;
               end if;

               get_task_node_by_task_name
                 (obj,
                  current_edge.all.Node_2,
                  succeed,
                  temporary_task_node);
               if succeed then
                  if not task_node_in_graph (res, current_edge.all.Node_2) then
                     add_node
                       (res,
                        Copy (task_node_ptr (temporary_task_node)),
                        succeed);
                  end if;
               else
                  raise undetected_graph_construction_error_exception;
               end if;

            end if;
            next_element (obj.Edges, e_iterator);
            current_element (obj.Edges, current_edge, e_iterator);
         end loop;
         if element_in_list
             (To_Unbounded_String
                ("DP_GRAPH.Time_Triggered_Communication_EDGE"),
              type_of (current_edge))
         then

            add_generic_edge (res, Copy (current_edge), succeed);

            get_task_node_by_task_name
              (obj,
               current_edge.all.Node_1,
               succeed,
               temporary_task_node);
            if succeed then
               if not task_node_in_graph (res, current_edge.all.Node_1) then
                  add_node
                    (res,
                     Copy (task_node_ptr (temporary_task_node)),
                     succeed);
               end if;
            else
               raise undetected_graph_construction_error_exception;
            end if;
            get_task_node_by_task_name
              (obj,
               current_edge.all.Node_2,
               succeed,
               temporary_task_node);
            if succeed then
               if not task_node_in_graph (res, current_edge.all.Node_2) then
                  add_node
                    (res,
                     Copy (task_node_ptr (temporary_task_node)),
                     succeed);
               end if;
            else
               raise undetected_graph_construction_error_exception;
            end if;

         end if;

      end if;
      return res;

   end time_triggered_communication_view;

   function resource_view (obj : in graph) return graph is
      res                 : graph;
      e_iterator          : edge_lists_iterator;
      current_edge        : generic_edge_ptr;
      succeed             : Boolean;
      temporary_task_node : task_node_ptr;

   begin

      Initialize (res);
      initialize (temporary_task_node);

      reset_head_iterator (obj.Edges, e_iterator);
      if not is_empty (obj.Edges) then
         current_element (obj.Edges, current_edge, e_iterator);

         while (not is_tail_element (obj.Edges, e_iterator)) loop

            if element_in_list
                (To_Unbounded_String ("DP_GRAPH.RESOURCE_EDGE"),
                 type_of (current_edge))
            then

               add_generic_edge (res, Copy (current_edge), succeed);

               get_task_node_by_task_name
                 (obj,
                  current_edge.all.Node_1,
                  succeed,
                  temporary_task_node);
               if succeed then

                  if not task_node_in_graph (res, current_edge.all.Node_1) then
                     add_node
                       (res,
                        Copy (task_node_ptr (temporary_task_node)),
                        succeed);
                  end if;
               else
                  raise undetected_graph_construction_error_exception;
               end if;

               get_task_node_by_task_name
                 (obj,
                  current_edge.all.Node_2,
                  succeed,
                  temporary_task_node);
               if succeed then
                  if not task_node_in_graph (res, current_edge.all.Node_2) then
                     add_node
                       (res,
                        Copy (task_node_ptr (temporary_task_node)),
                        succeed);
                  end if;
               else
                  raise undetected_graph_construction_error_exception;
               end if;

            end if;
            next_element (obj.Edges, e_iterator);
            current_element (obj.Edges, current_edge, e_iterator);
         end loop;
         if element_in_list
             (To_Unbounded_String ("DP_GRAPH.RESOURCE_EDGE"),
              type_of (current_edge))
         then

            add_generic_edge (res, Copy (current_edge), succeed);

            get_task_node_by_task_name
              (obj,
               current_edge.all.Node_1,
               succeed,
               temporary_task_node);
            if succeed then
               if not task_node_in_graph (res, current_edge.all.Node_1) then
                  add_node
                    (res,
                     Copy (task_node_ptr (temporary_task_node)),
                     succeed);
               end if;
            else
               raise undetected_graph_construction_error_exception;
            end if;
            get_task_node_by_task_name
              (obj,
               current_edge.all.Node_2,
               succeed,
               temporary_task_node);
            if succeed then
               if not task_node_in_graph (res, current_edge.all.Node_2) then
                  add_node
                    (res,
                     Copy (task_node_ptr (temporary_task_node)),
                     succeed);
               end if;
            else
               raise undetected_graph_construction_error_exception;
            end if;

         end if;

      end if;
      return res;

   end resource_view;

   function communication_view (obj : in graph) return graph is
   begin

      return obj;

   end communication_view;

   --View of Graph connex components
   --

   function connexity_view (obj : in graph) return graph_list is
      res               : graph_list;
      g_iterator        : graph_list_iterator;
      current_graph     : graph_ptr;
      temp_connex_graph : graph_ptr;
      succeed_source    : Boolean;
      succeed_sink      : Boolean;
      succeed_add       : Boolean;
      connex            : Boolean;

      e_iterator          : edge_lists_iterator;
      current_edge        : generic_edge_ptr;
      n_iterator          : node_lists_iterator;
      current_node        : generic_node_ptr;
      current_node_source : task_node_ptr;
      current_node_sink   : task_node_ptr;

   begin
      put_debug ("Connexity view");
      put_debug
        (To_Unbounded_String ("Nodes:    ") &
         To_Unbounded_String (get_number_of_elements (obj.Nodes)'img));
      put_debug
        (To_Unbounded_String ("Edges:    ") &
         To_Unbounded_String (get_number_of_elements (obj.Edges)'img));
      initialize (res);
      put_debug ("Tag1");
      reset_head_iterator (obj.Edges, e_iterator);
      if not is_empty (obj.Edges) then
         current_element (obj.Edges, current_edge, e_iterator);
         connex := False;
         put_debug ("Tag2");
         -- Browsing Graph's Edges
         while (not is_tail_element (obj.Edges, e_iterator)) loop
            --
            put_debug ("Tag2bis");
            reset_head_iterator (res, g_iterator);
            put_debug ("Tag2ter");
            -- begin res not empty
            if not is_empty (res) then
               put_debug ("Tag3");
               current_element (res, current_graph, g_iterator);
               connex := False;
               --Browsing Connex instances
               while (not is_tail_element (res, g_iterator)) loop

                  get_task_node_by_task_name
                    (current_graph,
                     current_edge.all.Node_1,
                     succeed_source,
                     current_node_source);
                  get_task_node_by_task_name
                    (current_graph,
                     current_edge.all.Node_2,
                     succeed_sink,
                     current_node_sink);
                  -- not connex : adding edge
                  if (succeed_source or succeed_sink) and not connex then
                     add_generic_edge
                       (current_graph,
                        current_edge,
                        succeed_add);
                     put_debug ("Tag4");
                     connex            := True;
                     temp_connex_graph := current_graph;
                     -- connex : adding node 1 if necessary
                     if not succeed_source then
                        get_task_node_by_task_name
                          (obj,
                           current_edge.all.Node_1,
                           succeed_source,
                           current_node_source);
                        put_debug ("Tag5");
                        add_generic_node
                          (current_graph,
                           generic_node_ptr (Copy (current_node_source)),
                           succeed_add);
                     end if;
                     -- connex : adding node 2 if necessary
                     if not succeed_sink then
                        get_task_node_by_task_name
                          (obj,
                           current_edge.all.Node_2,
                           succeed_sink,
                           current_node_sink);
                        put_debug ("Tag6");
                        add_generic_node
                          (current_graph,
                           generic_node_ptr (Copy (current_node_sink)),
                           succeed_add);
                     end if;
                  else
                     -- connex : adding edge only
                     if (succeed_source or succeed_sink) then

                        add
                          (res,
                           graph_union (temp_connex_graph, current_graph));
                        delete (res, temp_connex_graph);
                        put_debug ("Tag7");
                        delete (res, current_graph);
                     end if;
                  end if;
                  next_element (res, g_iterator);
                  current_element (res, current_graph, g_iterator);
                  put_debug ("Tag8");
               end loop;
               put_debug ("Tag8bis");
               --detecting connexity for last element
               get_task_node_by_task_name
                 (current_graph,
                  current_edge.all.Node_1,
                  succeed_source,
                  current_node_source);
               put_debug ("Tag8ter");
               get_task_node_by_task_name
                 (current_graph,
                  current_edge.all.Node_2,
                  succeed_sink,
                  current_node_sink);
               put_debug ("Tag9");
               if (succeed_source or succeed_sink) and not connex then
                  --
                  -- not connex : adding edge
                  add_generic_edge (current_graph, current_edge, succeed_add);
                  connex            := True;
                  temp_connex_graph := current_graph;
                  put_debug ("Tag10");
                  -- connex : adding node1 if necessary
                  if not succeed_source then
                     get_task_node_by_task_name
                       (obj,
                        current_edge.all.Node_1,
                        succeed_source,
                        current_node_source);
                     add_generic_node
                       (current_graph,
                        generic_node_ptr (Copy (current_node_source)),
                        succeed_add);
                     put_debug ("Tag11");
                  end if;
                  -- connex : adding node2 if necessary
                  if not succeed_sink then
                     get_task_node_by_task_name
                       (obj,
                        current_edge.all.Node_2,
                        succeed_sink,
                        current_node_sink);
                     put_debug ("Tag12");
                     add_generic_node
                       (current_graph,
                        generic_node_ptr (Copy (current_node_sink)),
                        succeed_add);
                  end if;
               else
                  put_debug ("Tag13");
                  -- connex : adding edge only
                  if (succeed_source or succeed_sink) then
                     add (res, graph_union (temp_connex_graph, current_graph));
                     put_debug ("Tag14");
                     delete (res, temp_connex_graph);
                     delete (res, current_graph);
                  end if;
               end if;

            end if;
            -- creating a connex graph instance from dependency
            put_debug ("creating a connex graph instance from dependency");
            if not connex then
               initialize (current_graph);
               add_generic_edge (current_graph, current_edge, succeed_add);
               get_task_node_by_task_name
                 (obj,
                  current_edge.all.Node_1,
                  succeed_source,
                  current_node_source);
               add_generic_node
                 (current_graph,
                  generic_node_ptr (Copy (current_node_source)),
                  succeed_add);
               get_task_node_by_task_name
                 (obj,
                  current_edge.all.Node_2,
                  succeed_sink,
                  current_node_sink);
               add_generic_node
                 (current_graph,
                  generic_node_ptr (Copy (current_node_sink)),
                  succeed_add);
               add (res, current_graph);
            end if;

            next_element (obj.Edges, e_iterator);
            current_element (obj.Edges, current_edge, e_iterator);
            put_debug ("next dependency");
            -- CHANGE False -> True
            connex := False;
            --Put_Debug ("connex := true");
         end loop;
         reset_head_iterator (res, g_iterator);
         -- Dealing with last dependency
         put_debug ("Dealing with last dependency");
         put_debug
           ("G_list size :" &
            To_Unbounded_String (get_number_of_elements (res)'img));
         if not is_empty (res) then
            current_element (res, current_graph, g_iterator);

            while (not is_tail_element (res, g_iterator)) loop
               -- Browsing connex graph instances
               put_debug ("Browsing connex graph instances");
               get_task_node_by_task_name
                 (current_graph,
                  current_edge.all.Node_1,
                  succeed_source,
                  current_node_source);
               get_task_node_by_task_name
                 (current_graph,
                  current_edge.all.Node_2,
                  succeed_sink,
                  current_node_sink);

               if (succeed_source or succeed_sink) and not connex then
                  add_generic_edge (current_graph, current_edge, succeed_add);
                  connex            := True;
                  temp_connex_graph := current_graph;

                  if not succeed_source then
                     get_task_node_by_task_name
                       (obj,
                        current_edge.all.Node_1,
                        succeed_source,
                        current_node_source);
                     add_generic_node
                       (current_graph,
                        generic_node_ptr (Copy (current_node_source)),
                        succeed_add);
                  end if;
                  if not succeed_sink then
                     get_task_node_by_task_name
                       (obj,
                        current_edge.all.Node_2,
                        succeed_sink,
                        current_node_sink);
                     add_generic_node
                       (current_graph,
                        generic_node_ptr (Copy (current_node_sink)),
                        succeed_add);
                  end if;
               else
                  if (succeed_source or succeed_sink) then
                     add (res, graph_union (temp_connex_graph, current_graph));
                     delete (res, temp_connex_graph);
                     delete (res, current_graph);
                  end if;
               end if;
               next_element (res, g_iterator);
               current_element (res, current_graph, g_iterator);
            end loop;
            -- Dealing with last graph instance and last dependency
            put_debug ("Dealing with last graph instance and last dependency");
            put_debug ("Dependency");
            put_debug ("Graph");
            Put (current_graph);
            get_task_node_by_task_name
              (current_graph,
               current_edge.all.Node_1,
               succeed_source,
               current_node_source);
            get_task_node_by_task_name
              (current_graph,
               current_edge.all.Node_2,
               succeed_sink,
               current_node_sink);
            put_debug
              ("succeed_source :" & To_Unbounded_String (succeed_source'img));
            put_debug
              ("succeed_sink :" & To_Unbounded_String (succeed_sink'img));
            if (succeed_source or succeed_sink) and not connex then
               add_generic_edge (current_graph, current_edge, succeed_add);
               connex            := True;
               temp_connex_graph := current_graph;

               if not succeed_source then
                  get_task_node_by_task_name
                    (obj,
                     current_edge.all.Node_1,
                     succeed_source,
                     current_node_source);
                  add_generic_node
                    (current_graph,
                     generic_node_ptr (Copy (current_node_source)),
                     succeed_add);
               end if;
               if not succeed_sink then
                  get_task_node_by_task_name
                    (obj,
                     current_edge.all.Node_2,
                     succeed_sink,
                     current_node_sink);
                  add_generic_node
                    (current_graph,
                     generic_node_ptr (Copy (current_node_sink)),
                     succeed_add);
               end if;
            else
               if (succeed_source or succeed_sink) then
                  add (res, graph_union (temp_connex_graph, current_graph));
                  delete (res, temp_connex_graph);
                  delete (res, current_graph);
               end if;
            end if;

         end if;
         if not connex then
            -- creating a new graph for last dependency
            put_debug ("creating a new graph for last dependency");
            initialize (current_graph);
            add_generic_edge (current_graph, current_edge, succeed_add);
            get_task_node_by_task_name
              (obj,
               current_edge.all.Node_1,
               succeed_source,
               current_node_source);
            add_generic_node
              (current_graph,
               generic_node_ptr (Copy (current_node_source)),
               succeed_add);
            get_task_node_by_task_name
              (obj,
               current_edge.all.Node_2,
               succeed_sink,
               current_node_sink);
            add_generic_node
              (current_graph,
               generic_node_ptr (Copy (current_node_sink)),
               succeed_add);
            add (res, current_graph);

         end if;

      end if;

      -- adding unplugged nodes

      reset_head_iterator (obj.Nodes, n_iterator);
      if not is_empty (obj.Nodes) then
         current_element (obj.Nodes, current_node, n_iterator);

         while (not is_tail_element (obj.Nodes, n_iterator)) loop
            put_debug ("adding unplugged node");
            connex := False;

            reset_head_iterator (res, g_iterator);
            if not is_empty (res) then
               current_element (res, current_graph, g_iterator);
               connex := False;
               while (not is_tail_element (res, g_iterator)) loop

                  get_task_node_by_task_name
                    (current_graph,
                     current_node.cheddar_private_id,
                     succeed_add,
                     current_node_source);
                  connex := succeed_add or connex;
                  next_element (res, g_iterator);
                  current_element (res, current_graph, g_iterator);
               end loop;
               get_task_node_by_task_name
                 (current_graph,
                  current_node.cheddar_private_id,
                  succeed_add,
                  current_node_source);
               connex := succeed_add or connex;
            end if;
            if not connex then
               put_debug ("Failed to recognize node");
               initialize (current_graph);
               add_generic_node
                 (current_graph,
                  generic_node_ptr (Copy (current_node)),
                  succeed_add);
               add (res, current_graph);
            end if;
            next_element (obj.Nodes, n_iterator);
            current_element (obj.Nodes, current_node, n_iterator);
         end loop;
         connex := False;
         reset_head_iterator (res, g_iterator);
         if not is_empty (res) then
            current_element (res, current_graph, g_iterator);
            connex := False;
            while (not is_tail_element (res, g_iterator)) loop
               get_task_node_by_task_name
                 (current_graph,
                  current_node.cheddar_private_id,
                  succeed_add,
                  current_node_source);
               connex := succeed_add or connex;
               next_element (res, g_iterator);
               current_element (res, current_graph, g_iterator);
            end loop;
            get_task_node_by_task_name
              (current_graph,
               current_node.cheddar_private_id,
               succeed_add,
               current_node_source);
            connex := succeed_add or connex;
         end if;
         if not connex then
            put_debug ("adding unplugged node");
            initialize (current_graph);
            add_generic_node
              (current_graph,
               generic_node_ptr (Copy (current_node)),
               succeed_add);
            add (res, current_graph);
         end if;

      end if;

      return res;

   end connexity_view;

   --View based on processors's names
   --

   function processor_view (obj : in graph) return graph_list is
      res : graph_list;

   begin

      initialize (res);

      return res;

   end processor_view;

   function processor_view
     (obj            : in graph;
      processor_name : in Unbounded_String) return graph
   is
   begin

      return obj;

   end processor_view;

   --Sub-System from Original system and a view
   --

   function get_subsystem_from_graph
     (obj      : in graph;
      original : in system) return system
   is
   begin

      return original;

   end get_subsystem_from_graph;

   --Annex functionnalities
   --

   procedure get_task_node_by_task_name
     (obj       : in     graph_ptr;
      task_name : in     Unbounded_String;
      succeed   :    out Boolean;
      res       :    out task_node_ptr)
   is

      n_iterator   : node_lists_iterator;
      current_node : generic_node_ptr;

   begin

      initialize (res);

      if not is_empty (obj.all.Nodes) then
         reset_head_iterator (obj.all.Nodes, n_iterator);
         current_element (obj.all.Nodes, current_node, n_iterator);

         while (not is_tail_element (obj.all.Nodes, n_iterator)) and
           not (current_node.cheddar_private_id = task_name)
         loop
            next_element (obj.all.Nodes, n_iterator);
            current_element (obj.all.Nodes, current_node, n_iterator);
         end loop;
      else
         succeed := False;
      end if;

      if (current_node.cheddar_private_id = task_name) then
         succeed := True;

         res := Copy (task_node_ptr (current_node));

      else
         succeed := False;
      end if;

   end get_task_node_by_task_name;

   procedure get_task_node_by_task_name
     (obj       : in     graph;
      task_name : in     Unbounded_String;
      succeed   :    out Boolean;
      res       :    out task_node_ptr)
   is

      n_iterator   : node_lists_iterator;
      current_node : generic_node_ptr;

   begin

      initialize (res);

      reset_head_iterator (obj.Nodes, n_iterator);
      if not is_empty (obj.Nodes) then
         current_element (obj.Nodes, current_node, n_iterator);

         while (not is_tail_element (obj.Nodes, n_iterator)) and
           not (current_node.cheddar_private_id = task_name)
         loop

            next_element (obj.Nodes, n_iterator);
            current_element (obj.Nodes, current_node, n_iterator);
         end loop;
      else
         succeed := False;
      end if;

      if (current_node.cheddar_private_id = task_name) then
         succeed := True;

         res := Copy (task_node_ptr (current_node));

      else
         succeed := False;
      end if;

   end get_task_node_by_task_name;

   function task_node_in_graph
     (obj       : in graph;
      task_name : in Unbounded_String) return Boolean
   is
      n_iterator   : node_lists_iterator;
      current_node : generic_node_ptr;
      res          : Boolean;

   begin
      put_debug
        (To_Unbounded_String ("Nodes:    ") &
         To_Unbounded_String (get_number_of_elements (obj.Nodes)'img));
      put_debug
        (To_Unbounded_String ("Edges:    ") &
         To_Unbounded_String (get_number_of_elements (obj.Edges)'img));
      res := False;

      reset_head_iterator (obj.Nodes, n_iterator);
      if not is_empty (obj.Nodes) then
         current_element (obj.Nodes, current_node, n_iterator);

         while (not is_tail_element (obj.Nodes, n_iterator)) and
           not (current_node.cheddar_private_id = task_name)
         loop
            next_element (obj.Nodes, n_iterator);
            current_element (obj.Nodes, current_node, n_iterator);
         end loop;
      else
         return res;
      end if;

      if (current_node.cheddar_private_id = task_name) then
         res := True;
      else
         res := False;
      end if;
      return res;

   end task_node_in_graph;

   function dependency_edge_in_graph
     (obj       : in graph;
      edge_name : in Unbounded_String) return Boolean
   is
      e_iterator   : edge_lists_iterator;
      current_edge : generic_edge_ptr;
      res          : Boolean;

   begin
      put_debug
        (To_Unbounded_String ("Nodes:    ") &
         To_Unbounded_String (get_number_of_elements (obj.Nodes)'img));
      put_debug
        (To_Unbounded_String ("Edges:    ") &
         To_Unbounded_String (get_number_of_elements (obj.Edges)'img));
      res := False;

      reset_head_iterator (obj.Edges, e_iterator);
      if not is_empty (obj.Edges) then
         current_element (obj.Edges, current_edge, e_iterator);

         while (not is_tail_element (obj.Edges, e_iterator)) and
           not (current_edge.cheddar_private_id = edge_name)
         loop
            next_element (obj.Edges, e_iterator);
            current_element (obj.Edges, current_edge, e_iterator);
         end loop;
      else
         return res;
      end if;

      if (current_edge.cheddar_private_id = edge_name) then
         res := True;
      else
         res := False;
      end if;
      return res;

   end dependency_edge_in_graph;

   --Binary Operators
   --

   function graph_minus
     (graph_a : in graph;
      graph_b : in graph) return graph
   is
      res          : graph;
      e_iterator   : edge_lists_iterator;
      current_edge : generic_edge_ptr;
      n_iterator   : node_lists_iterator;
      current_node : generic_node_ptr;
      succeed      : Boolean;
   begin

      Initialize (res);

      reset_head_iterator (graph_a.Edges, e_iterator);
      if not is_empty (graph_a.Edges) then
         current_element (graph_a.Edges, current_edge, e_iterator);

         while (not is_tail_element (graph_a.Edges, e_iterator)) loop
            succeed :=
              dependency_edge_in_graph
                (graph_b,
                 current_edge.cheddar_private_id);

            if not succeed then
               add_generic_edge (res, current_edge, succeed);
            end if;
            next_element (graph_a.Edges, e_iterator);
            current_element (graph_a.Edges, current_edge, e_iterator);
         end loop;

         succeed :=
           dependency_edge_in_graph (graph_b, current_edge.cheddar_private_id);

         if not succeed then
            add_generic_edge (res, current_edge, succeed);
         end if;

      end if;

      reset_head_iterator (graph_b.Edges, e_iterator);
      if not is_empty (graph_b.Edges) then
         current_element (graph_b.Edges, current_edge, e_iterator);

         while (not is_tail_element (graph_b.Edges, e_iterator)) loop
            succeed :=
              dependency_edge_in_graph
                (graph_a,
                 current_edge.cheddar_private_id);

            if not succeed then
               add_generic_edge (res, current_edge, succeed);
            end if;
            next_element (graph_b.Edges, e_iterator);
            current_element (graph_b.Edges, current_edge, e_iterator);
         end loop;

         succeed :=
           dependency_edge_in_graph (graph_a, current_edge.cheddar_private_id);

         if not succeed then
            add_generic_edge (res, current_edge, succeed);
         end if;

      end if;

      reset_head_iterator (graph_a.Nodes, n_iterator);
      if not is_empty (graph_a.Nodes) then
         current_element (graph_a.Nodes, current_node, n_iterator);

         while (not is_tail_element (graph_a.Nodes, n_iterator)) loop
            succeed :=
              task_node_in_graph (graph_b, current_node.cheddar_private_id);
            if not succeed then
               add_generic_node (res, current_node, succeed);
            end if;
            next_element (graph_a.Nodes, n_iterator);
            current_element (graph_a.Nodes, current_node, n_iterator);
         end loop;

         succeed :=
           task_node_in_graph (graph_b, current_node.cheddar_private_id);
         if not succeed then
            add_generic_node (res, current_node, succeed);
         end if;

      end if;

      reset_head_iterator (graph_b.Nodes, n_iterator);
      if not is_empty (graph_b.Nodes) then
         current_element (graph_b.Nodes, current_node, n_iterator);

         while (not is_tail_element (graph_b.Nodes, n_iterator)) loop
            succeed :=
              task_node_in_graph (graph_a, current_node.cheddar_private_id);
            if not succeed then
               add_generic_node (res, current_node, succeed);
            end if;
            next_element (graph_b.Nodes, n_iterator);
            current_element (graph_b.Nodes, current_node, n_iterator);
         end loop;

         succeed :=
           task_node_in_graph (graph_a, current_node.cheddar_private_id);
         if not succeed then
            add_generic_node (res, current_node, succeed);
         end if;

      end if;

      return res;

   end graph_minus;

   function graph_union
     (graph_a : in graph;
      graph_b : in graph) return graph
   is
      res          : graph;
      e_iterator   : edge_lists_iterator;
      current_edge : generic_edge_ptr;
      n_iterator   : node_lists_iterator;
      current_node : generic_node_ptr;
      succeed      : Boolean;
   begin

      Initialize (res);
      duplicate (graph_b.Nodes, res.Nodes, False);
      duplicate (graph_b.Edges, res.Edges, False);
      --Edge union

      reset_head_iterator (graph_a.Edges, e_iterator);
      if not is_empty (graph_a.Edges) then
         current_element (graph_a.Edges, current_edge, e_iterator);

         while (not is_tail_element (graph_a.Edges, e_iterator)) loop
            succeed :=
              dependency_edge_in_graph
                (graph_b,
                 current_edge.cheddar_private_id);

            if not succeed then
               add_generic_edge (res, current_edge, succeed);
            end if;
            next_element (graph_a.Edges, e_iterator);
            current_element (graph_a.Edges, current_edge, e_iterator);
         end loop;

         succeed :=
           dependency_edge_in_graph (graph_b, current_edge.cheddar_private_id);

         if not succeed then
            add_generic_edge (res, current_edge, succeed);
         end if;

      end if;

      --Node union

      reset_head_iterator (graph_a.Nodes, n_iterator);
      if not is_empty (graph_a.Nodes) then
         current_element (graph_a.Nodes, current_node, n_iterator);

         while (not is_tail_element (graph_a.Nodes, n_iterator)) loop
            succeed :=
              task_node_in_graph (graph_b, current_node.cheddar_private_id);
            if not succeed then
               add_generic_node (res, current_node, succeed);
            end if;
            next_element (graph_a.Nodes, n_iterator);
            current_element (graph_a.Nodes, current_node, n_iterator);
         end loop;

         succeed :=
           task_node_in_graph (graph_b, current_node.cheddar_private_id);
         if not succeed then
            add_generic_node (res, current_node, succeed);
         end if;

      end if;

      return res;

   end graph_union;

   function graph_union
     (graph_a : in graph_ptr;
      graph_b : in graph_ptr) return graph_ptr
   is
      res          : graph_ptr;
      e_iterator   : edge_lists_iterator;
      current_edge : generic_edge_ptr;
      n_iterator   : node_lists_iterator;
      current_node : generic_node_ptr;
      succeed      : Boolean;
   begin

      initialize (res);
      duplicate (graph_b.all.Nodes, res.Nodes, False);
      duplicate (graph_b.all.Edges, res.Edges, False);
      --Edge union

      reset_head_iterator (graph_a.all.Edges, e_iterator);
      if not is_empty (graph_a.all.Edges) then
         current_element (graph_a.all.Edges, current_edge, e_iterator);

         while (not is_tail_element (graph_a.all.Edges, e_iterator)) loop
            succeed := edge_in_graph (current_edge, graph_b);
            if not succeed then
               add_generic_edge (res, current_edge, succeed);
            end if;
            next_element (graph_a.all.Edges, e_iterator);
            current_element (graph_a.all.Edges, current_edge, e_iterator);
         end loop;

         succeed := edge_in_graph (current_edge, graph_b);
         if not succeed then
            add_generic_edge (res, current_edge, succeed);
         end if;

      end if;

      --Node union

      reset_head_iterator (graph_a.all.Nodes, n_iterator);
      if not is_empty (graph_a.all.Nodes) then
         current_element (graph_a.all.Nodes, current_node, n_iterator);

         while (not is_tail_element (graph_a.all.Nodes, n_iterator)) loop
            succeed := node_in_graph (current_node, graph_b);
            if not succeed then
               add_generic_node (res, current_node, succeed);
            end if;
            next_element (graph_a.all.Nodes, n_iterator);
            current_element (graph_a.all.Nodes, current_node, n_iterator);
         end loop;

         succeed := node_in_graph (current_node, graph_b);
         if not succeed then
            add_generic_node (res, current_node, succeed);
         end if;

      end if;

      return res;

   end graph_union;

   --Composition Analysis
   --

   function potential_design_pattern (g : in graph) return design_pattern is
      g2 : graph;
      g3 : graph;
   begin
      put_debug ("compo analysis begin");

      if (get_number_of_elements (g.Edges) = 0) then
         put_debug ("compo analysis Unplugged");
         return unplugged;
      end if;
      g2 := time_triggered_communication_view (g);
--      if ((Get_Number_Of_Elements (graph_minus (g, G2).Nodes) = 0) and
--             (Get_Number_Of_Elements (graph_minus (g, G2).Edges) = 0))
      if
        ((get_number_of_elements (graph_minus (g, g).Nodes) = 0) and
         (get_number_of_elements (graph_minus (g, g).Edges) = 0))
      then
         put_debug ("compo analysis Time Triggered");
         return time_triggered_communication;
      end if;
      g3 := resource_view (g);
      if
        ((get_number_of_elements (graph_minus (g, g3).Nodes) = 0) and
         (get_number_of_elements (graph_minus (g, g3).Edges) = 0))
      then
         put_debug ("compo analysis ravenscar");
         return ravenscar;
      end if;
      put_debug ("compo analysis end");
      raise unrecognized_design_pattern;

   end potential_design_pattern;

   function compose (g_list : in graph_list) return design_pattern is
      g_iterator            : graph_list_iterator;
      current_graph         : graph_ptr;
      global_design_pattern : design_pattern;
   begin

      global_design_pattern := unplugged;
      reset_head_iterator (g_list, g_iterator);
      if not is_empty (g_list) then

         loop
            current_element (g_list, current_graph, g_iterator);

            global_design_pattern :=
              compose_aux (global_design_pattern, current_graph);
            exit when is_tail_element (g_list, g_iterator);
            next_element (g_list, g_iterator);

         end loop;
         global_design_pattern :=
           compose_aux (global_design_pattern, current_graph);

      end if;

      return global_design_pattern;
   end compose;

   function compose_aux
     (dp : in design_pattern;
      g  : in graph_ptr) return design_pattern
   is
      dp2 : design_pattern;

   begin

      dp2 := potential_design_pattern (get_value (g));

      case dp is
         when unplugged =>
            case dp2 is
               when unplugged =>
                  return unplugged;

               when time_triggered_communication =>
                  return time_triggered_communication;

               when ravenscar =>
                  return ravenscar;
               when others =>
                  raise unrecognized_design_pattern;
            end case;
         when time_triggered_communication =>
            case dp2 is
               when unplugged =>
                  return time_triggered_communication;

               when time_triggered_communication =>
                  return time_triggered_communication;

               when ravenscar =>
                  return ravenscar;
               when others =>
                  raise unrecognized_design_pattern;
            end case;
         when ravenscar =>
            case dp2 is
               when unplugged =>
                  return ravenscar;

               when time_triggered_communication =>
                  return ravenscar;

               when ravenscar =>
                  return ravenscar;
               when others =>
                  raise unrecognized_design_pattern;
            end case;
         when others =>
            raise unrecognized_design_pattern;
      end case;

   end compose_aux;

end dp_graph_view;
