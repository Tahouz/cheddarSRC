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
with unbounded_strings;     use unbounded_strings;
with Framework_Config;      use Framework_Config;
with cfg_edges;             use cfg_edges;

with sets;

package cfg_edge_set is

   ----------------------------------------------------
   -- In this package, we work with both CFG_Edge_Table and CFG_Edge_Set.
   -- The reason for that is because:
   -- + In the system, we use CFG_Edge_Set
   -- + In the task, we use CFG_Edge_Table
   -- We did by this way because this is the current implementation for other
   -- models of Cheddars such as processor and core_unit.
   ----------------------------------------------------

   ----------------------------------------------------------
   -- Definition of basic block set
   ----------------------------------------------------------

   package cfg_edge_set is new sets
     (max_element    => Framework_Config.Max_CFG_Edges,
      element        => cfg_edge_ptr,
      free           => free,
      copy           => copy,
      put            => put,
      xml_string     => xml_string,
      xml_ref_string => xml_ref_string);

   use cfg_edge_set;

   type cfg_edges_set is new cfg_edge_set.set with private;

   subtype cfg_edges_range is cfg_edge_set.element_range;
   subtype cfg_edges_iterator is cfg_edge_set.iterator;

   ----------------------------------------------------------
   -- Exceptions defined in the set package
   ----------------------------------------------------------

   -- Raised when a given CFG node is not in a CFG node set
   --
   cfg_edge_not_found : exception;

   -- Raised when parameters provided to Add_Basic_Block are wrong
   --
   invalid_parameter : exception;

   ----------------------------------------------------
   -- CHECK
   ----------------------------------------------------

   procedure check_cfg_edge
     (name      : in Unbounded_String;
      node      : in Unbounded_String;
      next_node : in Unbounded_String);

   ----------------------------------------------------
   -- ADD
   ----------------------------------------------------
   procedure add_cfg_edge
     (my_cfg_edges : in out cfg_edges_set;
      a_cfg_edge   : in out cfg_edge_ptr;
      name         : in     Unbounded_String;
      node         : in     Unbounded_String;
      next_node    : in     Unbounded_String);

   procedure add_cfg_edge
     (my_cfg_edges : in out cfg_edges_set;
      name         : in     Unbounded_String;
      node         : in     Unbounded_String;
      next_node    : in     Unbounded_String);

   ----------------------------------------------------
   -- UPDATE
   ----------------------------------------------------

   procedure update_cfg_edge
     (my_cfg_edges : in out cfg_edges_set;
      name         : in     Unbounded_String;
      node         : in     Unbounded_String;
      next_node    : in     Unbounded_String);

   ----------------------------------------------------
   -- SEARCH
   ----------------------------------------------------

   function search_cfg_edge
     (my_cfg_edges : in cfg_edges_set;
      name         : in Unbounded_String) return cfg_edge_ptr;

   --Search CFG Edge by cheddar_private_id
   function search_cfg_edge_by_id
     (my_cfg_edges : in cfg_edges_set;
      id           : in Unbounded_String) return cfg_edge_ptr;

   ----------------------------------------------------
   -- DELETE
   ----------------------------------------------------
   procedure delete_cfg_edge
     (my_cfg_edges : in out cfg_edges_set;
      name         : in     Unbounded_String);

private
   type cfg_edges_set is new cfg_edge_set.set with null record;

end cfg_edge_set;
