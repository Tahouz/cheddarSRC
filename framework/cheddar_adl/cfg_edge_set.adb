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
with cfg_edges;            use cfg_edges;
with cfg_edges;            use cfg_edges.cfg_edges_table_package;
with Objects;              use Objects;
with Objects.extended;     use Objects.extended;
with Text_IO;              use Text_IO;
with Ada.Integer_Text_IO;  use Ada.Integer_Text_IO;
with integer_arrays;       use integer_arrays;
with initialize_framework; use initialize_framework;
with translate;            use translate;
with tables;
with sets;

package body cfg_edge_set is

   ----------------------------------------------------
   -- CHECK
   ----------------------------------------------------

   procedure check_cfg_edge
     (name      : in Unbounded_String;
      node      : in Unbounded_String;
      next_node : in Unbounded_String)
   is
   begin
      if (name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cfg_edge_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cfg_edge (Current_Language) &
               name &
               " : " &
               lb_cfg_edge_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if (node = "" or next_node = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cfg_node_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (node) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cfg_node (Current_Language) &
               node &
               " : " &
               lb_cfg_node_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if not is_a_valid_identifier (next_node) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cfg_node (Current_Language) &
               next_node &
               " : " &
               lb_cfg_node_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

   end check_cfg_edge;

   ----------------------------------------------------
   -- ADD
   ----------------------------------------------------
   procedure add_cfg_edge
     (my_cfg_edges : in out cfg_edges_set;
      a_cfg_edge   : in out cfg_edge_ptr;
      name         : in     Unbounded_String;
      node         : in     Unbounded_String;
      next_node    : in     Unbounded_String)
   is
      my_iterator : cfg_edges_iterator;
   begin
      check_initialize;

      check_cfg_edge (name, node, next_node);

      a_cfg_edge           := new cfg_edge;
      a_cfg_edge.name      := name;
      a_cfg_edge.node      := node;
      a_cfg_edge.next_node := next_node;
      add (my_cfg_edges, a_cfg_edge);
   exception
      when full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_cfg_edge (Current_Language)));
   end add_cfg_edge;

   procedure add_cfg_edge
     (my_cfg_edges : in out cfg_edges_set;
      name         : in     Unbounded_String;
      node         : in     Unbounded_String;
      next_node    : in     Unbounded_String)
   is
      a_cfg_edge : cfg_edge_ptr;
   begin
      add_cfg_edge
        (my_cfg_edges => my_cfg_edges,
         a_cfg_edge   => a_cfg_edge,
         name         => name,
         node         => node,
         next_node    => next_node);
   end add_cfg_edge;

   procedure update_cfg_edge
     (my_cfg_edges : in out cfg_edges_set;
      name         : in     Unbounded_String;
      node         : in     Unbounded_String;
      next_node    : in     Unbounded_String)
   is
      a_cfg_edge : cfg_edge_ptr;
   begin
      check_cfg_edge (name => name, node => node, next_node => next_node);

      a_cfg_edge :=
        search_cfg_edge (my_cfg_edges => my_cfg_edges, name => name);

      delete (my_cfg_edges, a_cfg_edge);

      add_cfg_edge
        (my_cfg_edges => my_cfg_edges,
         name         => name,
         node         => node,
         next_node    => next_node);

   end update_cfg_edge;

   ------------------------------------------------------
   -- SEARCH
   ------------------------------------------------------
   function search_cfg_edge
     (my_cfg_edges : in cfg_edges_set;
      name         : in Unbounded_String) return cfg_edge_ptr

   is
      my_iterator : cfg_edges_iterator;
      a_cfg_edge  : cfg_edge_ptr;
      result      : cfg_edge_ptr;
      found       : Boolean := False;
   begin

      if not is_empty (my_cfg_edges) then

         reset_iterator (my_cfg_edges, my_iterator);
         loop
            current_element (my_cfg_edges, a_cfg_edge, my_iterator);
            if (a_cfg_edge.name = name) then
               found  := True;
               result := a_cfg_edge;
            end if;

            exit when is_last_element (my_cfg_edges, my_iterator);
            next_element (my_cfg_edges, my_iterator);
         end loop;
      end if;

      if not found then
         Raise_Exception
           (cfg_edge_not_found'identity,
            To_String (lb_cfg_edge_name (Current_Language) & "=" & name));
      end if;

      return result;

   end search_cfg_edge;

   function search_cfg_edge_by_id
     (my_cfg_edges : in cfg_edges_set;
      id           : in Unbounded_String) return cfg_edge_ptr

   is
      my_iterator : cfg_edges_iterator;
      a_cfg_edge  : cfg_edge_ptr;
      result      : cfg_edge_ptr;
      found       : Boolean := False;
   begin
      if not is_empty (my_cfg_edges) then

         reset_iterator (my_cfg_edges, my_iterator);
         loop
            current_element (my_cfg_edges, a_cfg_edge, my_iterator);
            if (a_cfg_edge.cheddar_private_id = id) then
               found  := True;
               result := a_cfg_edge;
            end if;

            exit when is_last_element (my_cfg_edges, my_iterator);
            next_element (my_cfg_edges, my_iterator);
         end loop;

      end if;

      if not found then
         Raise_Exception
           (cfg_edge_not_found'identity,
            To_String (lb_cfg_edge_id (Current_Language) & "=" & id));
      end if;

      return result;

   end search_cfg_edge_by_id;

   ------------------------------------------------------
   -- SEARCH
   ------------------------------------------------------
   procedure delete_cfg_edge
     (my_cfg_edges : in out cfg_edges_set;
      name         : in     Unbounded_String)
   is
      a_cfg_edge : cfg_edge_ptr;
   begin
      a_cfg_edge := search_cfg_edge (my_cfg_edges, name);
      delete (my_cfg_edges, a_cfg_edge);
   end delete_cfg_edge;

end cfg_edge_set;
