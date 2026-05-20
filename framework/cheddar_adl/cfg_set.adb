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
-----------------------------------------------------------------------------
-- Last update :
--    $Rev: 4589 $
--    $Date: 2023-09-29 16:02:19 +0200 (ven., 29 sept. 2023) $
--    $Author: nam $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Exceptions;      use Ada.Exceptions;
with CFG_Nodes;           use CFG_Nodes;
with CFG_Nodes;           use CFG_Nodes.CFG_Nodes_Table_Package;
with Objects;             use Objects;
with Objects.extended;    use Objects.extended;
with Text_IO;             use Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with integer_arrays;      use integer_arrays;
with translate;           use translate;
with tables;
with CFG_Nodes.extended;  use CFG_Nodes.extended;
with sets;
with cfg_edges;           use cfg_edges;

package body cfg_set is

   -- In this package, we work with both CFG_Node_Table and CFG_Node_Set.
   -- The reason for that is because:
   -- + In the system, we use CFG_Node_Set
   -- + In the task, we use CFG_Node_Table
   -- We did by this way because this is the current implementation for other
   -- models of Cheddars such as processor and core_unit.

   ----------------------------------------------------
   -- CHECK
   ----------------------------------------------------

   procedure check_cfg
     (name          : in Unbounded_String;
      cfg_nodes_tbl : in cfg_nodes_table;
      cfg_edges_tbl : in cfg_edges_table)
   is
   begin
      if (name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cfg (Current_Language) & lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cfg (Current_Language) &
               name &
               " : " &
               lb_cfg_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

   end check_cfg;

   ----------------------------------------------------
   -- ADD
   ----------------------------------------------------

   procedure add_cfg (my_cfgs : in out cfgs_set; a_cfg : in out cfg_ptr) is
   begin
      add (my_cfgs, a_cfg);
   end add_cfg;

   procedure add_cfg
     (my_cfgs       : in out cfgs_set;
      a_cfg         : in out cfg_ptr;
      name          : in     Unbounded_String;
      cfg_nodes_tbl : in     cfg_nodes_table;
      cfg_edges_tbl : in     cfg_edges_table)
   is
      my_iterator : cfgs_iterator;
   begin
      check_cfg (name, cfg_nodes_tbl, cfg_edges_tbl);

      if (get_number_of_elements (my_cfgs) > 0) then
         reset_iterator (my_cfgs, my_iterator);
         loop
            current_element (my_cfgs, a_cfg, my_iterator);
            if (name = a_cfg.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_cfg (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_cfg_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;
            exit when is_last_element (my_cfgs, my_iterator);
            next_element (my_cfgs, my_iterator);
         end loop;
      end if;

      a_cfg       := new cfg;
      a_cfg.name  := name;
      a_cfg.nodes := cfg_nodes_tbl;
      a_cfg.edges := cfg_edges_tbl;

      add (my_cfgs, a_cfg);

   exception
      when full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_cfg (Current_Language)));
   end add_cfg;

   procedure add_cfg
     (my_cfgs       : in out cfgs_set;
      name          : in     Unbounded_String;
      cfg_nodes_tbl : in     cfg_nodes_table;
      cfg_edges_tbl : in     cfg_edges_table)
   is
      a_cfg : cfg_ptr;
   begin
      add_cfg
        (my_cfgs       => my_cfgs,
         a_cfg         => a_cfg,
         name          => name,
         cfg_nodes_tbl => cfg_nodes_tbl,
         cfg_edges_tbl => cfg_edges_tbl);
   end add_cfg;

   ------------------------------------------------------
   -- SEARCH
   ------------------------------------------------------
   function search_cfg
     (my_cfgs : in cfgs_set;
      name    : in Unbounded_String) return cfg_ptr

   is
      my_iterator : cfgs_iterator;
      a_cfg       : cfg_ptr;
      result      : cfg_ptr;
      found       : Boolean := False;
   begin
      if not is_empty (my_cfgs) then
         reset_iterator (my_cfgs, my_iterator);
         loop
            current_element (my_cfgs, a_cfg, my_iterator);
            if (a_cfg.name = name) then
               found  := True;
               result := a_cfg;
            end if;

            exit when is_last_element (my_cfgs, my_iterator);
            next_element (my_cfgs, my_iterator);
         end loop;
      end if;

      if not found then
         Raise_Exception
           (cfg_not_found'identity,
            To_String (lb_cfg_name (Current_Language) & "=" & name));
      end if;

      return result;

   end search_cfg;

   function search_cfg_by_id
     (my_cfgs : in cfgs_set;
      id      : in Unbounded_String) return cfg_ptr

   is
      my_iterator : cfgs_iterator;
      a_cfg       : cfg_ptr;
      result      : cfg_ptr;
      found       : Boolean := False;
   begin
      if not is_empty (my_cfgs) then
         reset_iterator (my_cfgs, my_iterator);
         loop
            current_element (my_cfgs, a_cfg, my_iterator);
            if (a_cfg.cheddar_private_id = id) then
               found  := True;
               result := a_cfg;
            end if;

            exit when is_last_element (my_cfgs, my_iterator);
            next_element (my_cfgs, my_iterator);
         end loop;
      end if;

      if not found then
         Raise_Exception
           (cfg_not_found'identity,
            To_String (lb_cfg_node_name (Current_Language) & "=" & id));
      end if;

      return result;

   end search_cfg_by_id;

end cfg_set;
