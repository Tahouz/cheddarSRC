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

with Ada.Exceptions;       use Ada.Exceptions;
with CFG_Nodes;            use CFG_Nodes;
with CFG_Nodes;            use CFG_Nodes.CFG_Nodes_Table_Package;
with Objects;              use Objects;
with Objects.extended;     use Objects.extended;
with Text_IO;              use Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;
with integer_arrays;       use integer_arrays;
with translate;            use translate;
with CFG_Nodes.extended;   use CFG_Nodes.extended;
with initialize_framework; use initialize_framework;
with tables;
with sets;

package body cfg_node_set is

   -- In this package, we work with both CFG_Node_Table and CFG_Node_Set.
   -- The reason for that is because:
   -- + In the system, we use CFG_Node_Set
   -- + In the task, we use CFG_Node_Table
   -- We did by this way because this is the current implementation for other
   -- models of Cheddars such as processor and core_unit.

   ----------------------------------------------------
   -- CHECK
   ----------------------------------------------------

   procedure check_cfg_node
     (name       : in Unbounded_String;
      node_type  : in cfg_node_type;
      graph_type : in cfg_graph_type)
   is
   begin
      if (name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cfg_node (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cfg_node (Current_Language) &
               name &
               " : " &
               lb_cfg_node_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

   end check_cfg_node;

   ----------------------------------------------------
   -- ADD
   ----------------------------------------------------
   procedure add_cfg_node
     (my_cfg_nodes : in out cfg_nodes_set;
      a_cfg_node   : in out cfg_node_ptr;
      name         : in     Unbounded_String;
      node_type    : in     cfg_node_type;
      graph_type   : in     cfg_graph_type)
   is
      my_iterator : cfg_nodes_iterator;
   begin
      check_initialize;

      check_cfg_node (name, node_type, graph_type);

      if (get_number_of_elements (my_cfg_nodes) > 0) then
         reset_iterator (my_cfg_nodes, my_iterator);
         loop
            current_element (my_cfg_nodes, a_cfg_node, my_iterator);
            if (name = a_cfg_node.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_cfg_node (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_cfg_node_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;
            exit when is_last_element (my_cfg_nodes, my_iterator);
            next_element (my_cfg_nodes, my_iterator);
         end loop;
      end if;

      a_cfg_node            := new cfg_node;
      a_cfg_node.name       := name;
      a_cfg_node.node_type  := node_type;
      a_cfg_node.graph_type := graph_type;

      add (my_cfg_nodes, a_cfg_node);

   exception
      when full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_cfg_node (Current_Language)));
   end add_cfg_node;

   procedure add_cfg_node
     (my_cfg_nodes : in out cfg_nodes_set;
      name         : in     Unbounded_String;
      node_type    : in     cfg_node_type;
      graph_type   : in     cfg_graph_type)
   is
      a_cfg_node : cfg_node_ptr;
   begin
      add_cfg_node
        (my_cfg_nodes => my_cfg_nodes,
         a_cfg_node   => a_cfg_node,
         name         => name,
         node_type    => node_type,
         graph_type   => graph_type);
   end add_cfg_node;

   ------------------------------------------------------
   -- SEARCH
   ------------------------------------------------------
   function search_cfg_node
     (my_cfg_nodes : in cfg_nodes_set;
      name         : in Unbounded_String) return cfg_node_ptr

   is
      my_iterator : cfg_nodes_iterator;
      a_cfg_node  : cfg_node_ptr;
      result      : cfg_node_ptr;
      found       : Boolean := False;
   begin
      if not is_empty (my_cfg_nodes) then
         reset_iterator (my_cfg_nodes, my_iterator);
         loop
            current_element (my_cfg_nodes, a_cfg_node, my_iterator);
            if (a_cfg_node.name = name) then
               found  := True;
               result := a_cfg_node;
            end if;

            exit when is_last_element (my_cfg_nodes, my_iterator);
            next_element (my_cfg_nodes, my_iterator);
         end loop;

      end if;

      if not found then
         Raise_Exception
           (cfg_node_not_found'identity,
            To_String (lb_cfg_node_name (Current_Language) & "=" & name));
      end if;

      return result;

   end search_cfg_node;

   function search_cfg_node_by_id
     (my_cfg_nodes : in cfg_nodes_set;
      id           : in Unbounded_String) return cfg_node_ptr

   is
      my_iterator : cfg_nodes_iterator;
      a_cfg_node  : cfg_node_ptr;
      result      : cfg_node_ptr;
      found       : Boolean := False;
   begin
      if not is_empty (my_cfg_nodes) then
         reset_iterator (my_cfg_nodes, my_iterator);
         loop
            current_element (my_cfg_nodes, a_cfg_node, my_iterator);
            if (a_cfg_node.cheddar_private_id = id) then
               found  := True;
               result := a_cfg_node;
            end if;

            exit when is_last_element (my_cfg_nodes, my_iterator);
            next_element (my_cfg_nodes, my_iterator);
         end loop;
      end if;

      if not found then
         Raise_Exception
           (cfg_node_not_found'identity,
            To_String (lb_cfg_node_id (Current_Language) & "=" & id));
      end if;

      return result;

   end search_cfg_node_by_id;

   ------------------------------------------------------
   -- DELETE
   ------------------------------------------------------
   procedure delete_cfg_node
     (my_cfg_nodes : in out cfg_nodes_set;
      name         : in     Unbounded_String)
   is
      a_cfg_node : cfg_node_ptr;
   begin
      a_cfg_node := search_cfg_node (my_cfg_nodes, name);
      delete (my_cfg_nodes, a_cfg_node);
   end delete_cfg_node;

   ------------------------------------------------------
   -- UPDATE
   ------------------------------------------------------
   procedure update_cfg_node
     (my_cfg_nodes : in out cfg_nodes_set;
      name         : in     Unbounded_String;
      node_type    : in     cfg_node_type;
      graph_type   : in     cfg_graph_type)
   is
      a_cfg_node : cfg_node_ptr;
   begin
      check_cfg_node
        (name       => name,
         node_type  => node_type,
         graph_type => graph_type);

      a_cfg_node := search_cfg_node (my_cfg_nodes, name);

      delete (my_cfg_nodes, a_cfg_node);

      add_cfg_node
        (my_cfg_nodes => my_cfg_nodes,
         a_cfg_node   => a_cfg_node,
         name         => name,
         node_type    => node_type,
         graph_type   => graph_type);

   end update_cfg_node;

   ------------------------------------------------------
   -- NEXT, PREVIOUS
   ------------------------------------------------------
   procedure add_next_cfg_node
     (my_cfg_nodes   : in out cfg_nodes_set;
      name           : in     Unbounded_String;
      next_node_name : in     Unbounded_String)
   is
      a_cfg_node      : cfg_node_ptr;
      a_next_cfg_node : cfg_node_ptr;
   begin
      a_cfg_node      := search_cfg_node (my_cfg_nodes, name);
      a_next_cfg_node := search_cfg_node (my_cfg_nodes, next_node_name);

      add (cfg_node_ext_ptr (a_cfg_node).next_nodes, a_next_cfg_node);
   end add_next_cfg_node;

   procedure add_next_cfg_node_by_id
     (my_cfg_nodes : in out cfg_nodes_set;
      a_cfg_node   : in out cfg_node_ptr;
      next_node_id : in     Unbounded_String)
   is
      a_next_cfg_node : cfg_node_ptr;
   begin
      a_next_cfg_node := search_cfg_node_by_id (my_cfg_nodes, next_node_id);
      add (cfg_node_ext_ptr (a_cfg_node).next_nodes, a_next_cfg_node);
   end add_next_cfg_node_by_id;

   procedure add_previous_cfg_node
     (my_cfg_nodes       : in out cfg_nodes_set;
      name               : in     Unbounded_String;
      previous_node_name : in     Unbounded_String)
   is
      a_cfg_node      : cfg_node_ptr;
      a_next_cfg_node : cfg_node_ptr;
   begin
      a_cfg_node      := search_cfg_node (my_cfg_nodes, name);
      a_next_cfg_node := search_cfg_node (my_cfg_nodes, previous_node_name);

      add (cfg_node_ext_ptr (a_cfg_node).previous_nodes, a_next_cfg_node);
   end add_previous_cfg_node;

   procedure add_previous_cfg_node_by_id
     (my_cfg_nodes     : in out cfg_nodes_set;
      a_cfg_node       : in out cfg_node_ptr;
      previous_node_id : in     Unbounded_String)
   is
      a_next_cfg_node : cfg_node_ptr;
   begin
      a_next_cfg_node :=
        search_cfg_node_by_id (my_cfg_nodes, previous_node_id);
      add (cfg_node_ext_ptr (a_cfg_node).previous_nodes, a_next_cfg_node);
   end add_previous_cfg_node_by_id;

   procedure set_previous_cfg_nodes (my_cfg_nodes : in out cfg_nodes_set) is
      my_iterator : cfg_nodes_iterator;
      a_cfg_node  : cfg_node_ptr;
   begin
      reset_iterator (my_cfg_nodes, my_iterator);
      loop
         current_element (my_cfg_nodes, a_cfg_node, my_iterator);

         for i in 0 .. cfg_node_ext_ptr (a_cfg_node).next_nodes.nb_entries - 1
         loop

            add_previous_cfg_node
              (my_cfg_nodes => my_cfg_nodes,
               name         =>
                 cfg_node_ext_ptr (a_cfg_node).next_nodes.entries (i).name,
               previous_node_name => a_cfg_node.name);
         end loop;

         exit when is_last_element (my_cfg_nodes, my_iterator);
         next_element (my_cfg_nodes, my_iterator);
      end loop;

   end set_previous_cfg_nodes;

end cfg_node_set;
