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

with Ada.Exceptions;      use Ada.Exceptions;
with CFG_Nodes;           use CFG_Nodes;
with CFG_Nodes;           use CFG_Nodes.CFG_Nodes_Table_Package;
with cfg_node_set;        use cfg_node_set;
with basic_blocks;        use basic_blocks;
with basic_blocks;        use basic_blocks.basic_blocks_table_package;
with Objects;             use Objects;
with Objects.extended;    use Objects.extended;
with Text_IO;             use Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with integer_arrays;      use integer_arrays;
with translate;           use translate;
with tables;
with sets;
with cfg_edge_set;        use cfg_edge_set;
with cfg_edges;           use cfg_edges;

package body cfg_node_set.basic_block_set is

   ----------------------------------------------------
   -- CHECK - BASIC_BLOCK
   ----------------------------------------------------
   procedure check_basic_block
     (name                 : in Unbounded_String;
      node_type            : in cfg_node_type;
      graph_type           : in cfg_graph_type;
      instruction_offset   : in Integer;
      instruction_capacity : in Integer;
      data_offset          : in Integer;
      data_capacity        : in Integer;
      loop_bound           : in Integer)
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

      if instruction_offset < 0 then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cfg_node (Current_Language) &
               " " &
               name &
               " : " &
               lb_instruction_offset (Current_Language) &
               lb_must_be (Current_Language) &
               To_Unbounded_String (" >= 1")));
      end if;

      if instruction_capacity < 0 then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cfg_node (Current_Language) &
               " " &
               name &
               " : " &
               lb_instruction_capacity (Current_Language) &
               lb_must_be (Current_Language) &
               To_Unbounded_String (" >= 1")));
      end if;

      if data_offset < 0 then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cfg_node (Current_Language) &
               " " &
               name &
               " : " &
               lb_data_offset (Current_Language) &
               lb_must_be (Current_Language) &
               To_Unbounded_String (" >= 1")));
      end if;

      if data_capacity < 0 then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cfg_node (Current_Language) &
               " " &
               name &
               " : " &
               lb_data_capacity (Current_Language) &
               lb_must_be (Current_Language) &
               To_Unbounded_String (" >= 1")));
      end if;

   end check_basic_block;

   ----------------------------------------------------
   -- ADD - BASIC_BLOCK
   ----------------------------------------------------
   procedure add_basic_block
     (my_basic_blocks      : in out basic_blocks_set;
      a_basic_block        : in out basic_block_ptr;
      name                 : in     Unbounded_String;
      node_type            : in     cfg_node_type;
      graph_type           : in     cfg_graph_type;
      instruction_offset   : in     Integer;
      instruction_capacity : in     Integer;
      data_offset          : in     Integer;
      data_capacity        : in     Integer;
      loop_bound           : in     Integer := 0)
   is
      my_iterator : basic_blocks_iterator;
   begin

      check_basic_block
        (name,
         node_type,
         graph_type,
         instruction_offset,
         instruction_capacity,
         data_offset,
         data_capacity,
         loop_bound);

      if (get_number_of_elements (my_basic_blocks) > 1) then
         reset_iterator (my_basic_blocks, my_iterator);
         loop
            current_element (my_basic_blocks, a_basic_block, my_iterator);
            if name = a_basic_block.name then
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
            exit when is_last_element (my_basic_blocks, my_iterator);
            next_element (my_basic_blocks, my_iterator);
         end loop;
      end if;

      a_basic_block                      := new basic_block;
      a_basic_block.instruction_offset   := instruction_offset;
      a_basic_block.instruction_capacity := instruction_capacity;
      a_basic_block.data_offset          := data_offset;
      a_basic_block.data_capacity        := data_capacity;
      a_basic_block.loop_bound           := loop_bound; -- SR instead 0

      a_basic_block.name := name;
      --        a_basic_block.previous_nodes            := previous_nodes;
      --        a_basic_block.next_nodes                        := next_nodes;
      a_basic_block.node_type  := node_type;
      a_basic_block.graph_type := graph_type;

      add (my_basic_blocks, a_basic_block);

   exception
      when cfg_node_set.full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_cfg_node (Current_Language)));
   end add_basic_block;

   procedure add_basic_block
     (my_basic_blocks      : in out basic_blocks_set;
      name                 : in     Unbounded_String;
      node_type            : in     cfg_node_type;
      graph_type           : in     cfg_graph_type;
      instruction_offset   : in     Integer;
      instruction_capacity : in     Integer;
      data_offset          : in     Integer;
      data_capacity        : in     Integer;
      loop_bound           : in     Integer := 0)
   is
      a_basic_block : basic_block_ptr;
   begin
      add_basic_block
        (my_basic_blocks      => my_basic_blocks,
         a_basic_block        => a_basic_block,
         name                 => name,
         node_type            => node_type,
         graph_type           => graph_type,
         instruction_offset   => instruction_offset,
         instruction_capacity => instruction_capacity,
         data_offset          => data_offset,
         data_capacity        => data_capacity,
         loop_bound           => loop_bound);
   exception
      when cfg_node_set.full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_cfg_node (Current_Language)));
   end add_basic_block;

   ------------------------------------------------------
   -- UPDATE - BASIC_BLOCK
   ------------------------------------------------------
   procedure update_basic_block
     (my_basic_blocks      : in out basic_blocks_set;
      name                 : in     Unbounded_String;
      node_type            : in     cfg_node_type;
      graph_type           : in     cfg_graph_type;
      instruction_offset   : in     Integer;
      instruction_capacity : in     Integer;
      data_offset          : in     Integer;
      data_capacity        : in     Integer;
      loop_bound           : in     Integer)
   is
      a_basic_block : basic_block_ptr;
   begin
      a_basic_block := search_basic_block (my_basic_blocks, name);

      delete_basic_block (my_basic_blocks, a_basic_block);

      add_basic_block
        (my_basic_blocks      => my_basic_blocks,
         a_basic_block        => a_basic_block,
         name                 => name,
         node_type            => node_type,
         graph_type           => graph_type,
         instruction_offset   => instruction_offset,
         instruction_capacity => instruction_capacity,
         data_offset          => data_offset,
         data_capacity        => data_capacity,
         loop_bound           => loop_bound);

   end update_basic_block;

   ----------------------------------------------------
   -- ADD - (CFG_NODE) BASIC_BLOCK
   ----------------------------------------------------
   procedure add_cfg_node
     (my_cfg_nodes         : in out cfg_nodes_set;
      a_cfg_node           : in out cfg_node_ptr;
      name                 : in     Unbounded_String;
      node_type            : in     cfg_node_type;
      graph_type           : in     cfg_graph_type;
      instruction_offset   : in     Integer;
      instruction_capacity : in     Integer;
      data_offset          : in     Integer;
      data_capacity        : in     Integer;
      loop_bound           : in     Integer := 0)
   is
      my_iterator     : cfg_nodes_iterator;
      new_basic_block : basic_block_ptr;
   begin

      check_basic_block
        (name,
         node_type,
         graph_type,
         instruction_offset,
         instruction_capacity,
         data_offset,
         data_capacity,
         loop_bound);

      if (get_number_of_elements (my_cfg_nodes) > 1) then
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

      new_basic_block                      := new basic_block;
      new_basic_block.instruction_offset   := instruction_offset;
      new_basic_block.instruction_capacity := instruction_capacity;
      new_basic_block.data_offset          := data_offset;
      new_basic_block.data_capacity        := data_capacity;
      new_basic_block.loop_bound           := loop_bound;

      a_cfg_node      := cfg_node_ptr (new_basic_block);
      a_cfg_node.name := name;
      --        a_cfg_node.previous_nodes       := previous_nodes;
      --        a_cfg_node.next_nodes           := next_nodes;
      a_cfg_node.node_type  := node_type;
      a_cfg_node.graph_type := graph_type;

      add (my_cfg_nodes, a_cfg_node);

   exception
      when cfg_node_set.full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_cfg_node (Current_Language)));
   end add_cfg_node;

   procedure add_cfg_node
     (my_cfg_nodes         : in out cfg_nodes_set;
      name                 : in     Unbounded_String;
      node_type            : in     cfg_node_type;
      graph_type           : in     cfg_graph_type;
      instruction_offset   : in     Integer;
      instruction_capacity : in     Integer;
      data_offset          : in     Integer;
      data_capacity        : in     Integer;
      loop_bound           : in     Integer := 0)
   is
      a_cfg_node : cfg_node_ptr;
   begin
      add_cfg_node
        (my_cfg_nodes         => my_cfg_nodes,
         a_cfg_node           => a_cfg_node,
         name                 => name,
         node_type            => node_type,
         graph_type           => graph_type,
         instruction_offset   => instruction_offset,
         instruction_capacity => instruction_capacity,
         data_offset          => data_offset,
         data_capacity        => data_capacity,
         loop_bound           => loop_bound);
   exception
      when cfg_node_set.full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_cfg_node (Current_Language)));
   end add_cfg_node;

   ------------------------------------------------------
   -- SEARCH
   ------------------------------------------------------
   function search_basic_block
     (my_basic_blocks : in basic_blocks_set;
      name            : in Unbounded_String) return basic_block_ptr
   is
      my_iterator   : basic_blocks_iterator;
      a_basic_block : basic_block_ptr;
      result        : basic_block_ptr;
      found         : Boolean := False;
   begin
      if not is_empty (my_basic_blocks) then

         reset_iterator (my_basic_blocks, my_iterator);
         loop
            current_element (my_basic_blocks, a_basic_block, my_iterator);
            if (a_basic_block.name = name) then
               found  := True;
               result := a_basic_block;
            end if;

            exit when is_last_element (my_basic_blocks, my_iterator);
            next_element (my_basic_blocks, my_iterator);
         end loop;
      end if;

      if not found then
         Raise_Exception
           (cfg_node_not_found'identity,
            To_String (lb_cfg_node_name (Current_Language) & "=" & name));
      end if;

      return result;

   end search_basic_block;

   function search_basic_block_by_id
     (my_basic_blocks : in basic_blocks_set;
      id              : in Unbounded_String) return basic_block_ptr
   is
      my_iterator   : basic_blocks_iterator;
      a_basic_block : basic_block_ptr;
      result        : basic_block_ptr;
      found         : Boolean := False;
   begin
      if not is_empty (my_basic_blocks) then
         reset_iterator (my_basic_blocks, my_iterator);
         loop
            current_element (my_basic_blocks, a_basic_block, my_iterator);
            if (a_basic_block.cheddar_private_id = id) then
               found  := True;
               result := a_basic_block;
            end if;

            exit when is_last_element (my_basic_blocks, my_iterator);
            next_element (my_basic_blocks, my_iterator);
         end loop;
      end if;

      if not found then
         Raise_Exception
           (cfg_node_not_found'identity,
            To_String (lb_cfg_node_name (Current_Language) & "=" & id));
      end if;

      return result;

   end search_basic_block_by_id;

   ------------------------------------------------------
   -- DELETE
   ------------------------------------------------------
   procedure delete_basic_block
     (my_basic_blocks : in out basic_blocks_set;
      a_basic_block   : in out basic_block_ptr)
   is
   begin
      delete (my_basic_blocks, a_basic_block);
   end delete_basic_block;

   procedure delete_basic_block
     (my_basic_blocks : in out basic_blocks_set;
      name            : in     Unbounded_String)
   is
      a_basic_block : basic_block_ptr;
   begin
      a_basic_block := search_basic_block (my_basic_blocks, name);
      delete (my_basic_blocks, a_basic_block);
   end delete_basic_block;
   ------------------------------------------------------
   -- NEXT, PREVIOUS
   ------------------------------------------------------
   procedure add_next_basic_block
     (my_basic_blocks : in out basic_blocks_set;
      name            : in     Unbounded_String;
      next_block_name : in     Unbounded_String)
   is
      a_basic_block      : basic_block_ptr;
      a_next_basic_block : basic_block_ptr;
   begin
      a_basic_block      := search_basic_block (my_basic_blocks, name);
      a_next_basic_block :=
        search_basic_block (my_basic_blocks, next_block_name);

      add
        (basic_block_ext_ptr (a_basic_block).next_nodes,
         cfg_node_ptr (a_next_basic_block));
   end add_next_basic_block;

   procedure add_next_basic_block_by_id
     (my_basic_blocks : in out basic_blocks_set;
      a_basic_block   : in out basic_block_ptr;
      next_block_id   : in     Unbounded_String)
   is
      a_next_basic_block : basic_block_ptr;
   begin
      a_next_basic_block :=
        search_basic_block_by_id (my_basic_blocks, next_block_id);
      add
        (basic_block_ext_ptr (a_basic_block).next_nodes,
         cfg_node_ptr (a_next_basic_block));
   end add_next_basic_block_by_id;

   procedure add_previous_basic_block
     (my_basic_blocks     : in out basic_blocks_set;
      name                : in     Unbounded_String;
      previous_block_name : in     Unbounded_String)
   is
      a_basic_block          : basic_block_ptr;
      a_previous_basic_block : basic_block_ptr;
   begin
      a_basic_block          := search_basic_block (my_basic_blocks, name);
      a_previous_basic_block :=
        search_basic_block (my_basic_blocks, previous_block_name);

      add
        (basic_block_ext_ptr (a_basic_block).previous_nodes,
         cfg_node_ptr (a_previous_basic_block));
   end add_previous_basic_block;

   procedure add_previous_basic_block_by_id
     (my_basic_blocks   : in out basic_blocks_set;
      a_basic_block     : in out basic_block_ptr;
      previous_block_id : in     Unbounded_String)
   is
      a_previous_basic_block : basic_block_ptr;
   begin
      a_previous_basic_block :=
        search_basic_block_by_id (my_basic_blocks, previous_block_id);
      add
        (basic_block_ext_ptr (a_basic_block).previous_nodes,
         cfg_node_ptr (a_previous_basic_block));
   end add_previous_basic_block_by_id;

   procedure set_previous_basic_blocks
     (my_basic_blocks : in out basic_blocks_set)
   is
      my_iterator   : basic_blocks_iterator;
      a_basic_block : basic_block_ptr;
   begin
      reset_iterator (my_basic_blocks, my_iterator);
      loop
         current_element (my_basic_blocks, a_basic_block, my_iterator);

         for i in
           0 .. basic_block_ext_ptr (a_basic_block).next_nodes.nb_entries - 1
         loop

            add_previous_basic_block
              (my_basic_blocks => my_basic_blocks,
               name            =>
                 basic_block_ext_ptr (a_basic_block).next_nodes.entries (i)
                   .name,
               previous_block_name => a_basic_block.name);
         end loop;

         exit when is_last_element (my_basic_blocks, my_iterator);
         next_element (my_basic_blocks, my_iterator);
      end loop;

   end set_previous_basic_blocks;
   ----------------------------------------------------
   -- CONVERT
   ----------------------------------------------------
   procedure convert_to_basic_block_ucb_set
     (my_cfg_nodes : in out cfg_nodes_set;
      my_cfg_edges : in out cfg_edges_set;
      size         : in     Integer)
   is
      a_cfg_node_ucb    : basic_block_ptr;
      a_cfg_basic_block : basic_block_ptr;

      cfg_ucb_basic_blocks_set : cfg_nodes_set;
      new_basic_block_ucb      : basic_block_ucb_ptr;

      my_iterator : cfg_nodes_iterator;

      a_cfg_node    : cfg_node_ptr;
      temp_cfg_node : cfg_node_ptr;

   begin
      reset_iterator (my_cfg_nodes, my_iterator);
      loop
         current_element (my_cfg_nodes, a_cfg_node, my_iterator);

         new_basic_block_ucb                 := new basic_block_ucb;
         new_basic_block_ucb.gencbr.elements :=
           new integer_arr (0 .. size - 1);
         new_basic_block_ucb.gencbr.size     := size;
         new_basic_block_ucb.gencbl.elements :=
           new integer_arr (0 .. size - 1);
         new_basic_block_ucb.gencbl.size         := size;
         new_basic_block_ucb.rmbin := new basic_block_ucb_arr (0 .. size - 1);
         new_basic_block_ucb.rmbout := new basic_block_ucb_arr (0 .. size - 1);
         new_basic_block_ucb.lmbin := new basic_block_ucb_arr (0 .. size - 1);
         new_basic_block_ucb.lmbout := new basic_block_ucb_arr (0 .. size - 1);
         new_basic_block_ucb.numberofusefulblock := 0;

         for i in 0 .. size - 1 loop
            new_basic_block_ucb.rmbin (i).size      := 0;
            new_basic_block_ucb.rmbin (i).elements := new integer_arr (0 .. 0);
            new_basic_block_ucb.rmbout (i).size     := 0;
            new_basic_block_ucb.rmbout (i).elements :=
              new integer_arr (0 .. 0);
            new_basic_block_ucb.lmbin (i).size      := 0;
            new_basic_block_ucb.lmbin (i).elements := new integer_arr (0 .. 0);
            new_basic_block_ucb.lmbout (i).size     := 0;
            new_basic_block_ucb.lmbout (i).elements :=
              new integer_arr (0 .. 0);
         end loop;

         a_cfg_basic_block := basic_block_ptr (a_cfg_node);

         a_cfg_node_ucb := basic_block_ptr (new_basic_block_ucb);
         a_cfg_node_ucb.data_offset        := a_cfg_basic_block.data_offset;
         a_cfg_node_ucb.data_capacity      := a_cfg_basic_block.data_capacity;
         a_cfg_node_ucb.instruction_offset :=
           a_cfg_basic_block.instruction_offset;
         a_cfg_node_ucb.instruction_capacity :=
           a_cfg_basic_block.instruction_capacity;
         a_cfg_node_ucb.loop_bound := a_cfg_basic_block.loop_bound;

         temp_cfg_node                    := cfg_node_ptr (a_cfg_node_ucb);
         temp_cfg_node.cheddar_private_id :=
           a_cfg_basic_block.cheddar_private_id;
         temp_cfg_node.name := a_cfg_basic_block.name;
         --           temp_cfg_node.previous_nodes                      := a_cfg_basic_block.previous_nodes;
         --           temp_cfg_node.next_nodes                  := a_cfg_basic_block.next_nodes;
         temp_cfg_node.graph_type := a_cfg_basic_block.graph_type;
         temp_cfg_node.node_type  := a_cfg_basic_block.node_type;

         add (cfg_ucb_basic_blocks_set, temp_cfg_node);

         exit when is_last_element (my_cfg_nodes, my_iterator);
         next_element (my_cfg_nodes, my_iterator);
      end loop;

      my_cfg_nodes := cfg_ucb_basic_blocks_set;

   end convert_to_basic_block_ucb_set;

   procedure convert_to_basic_block_ucb_set
     (my_basic_blocks : in out basic_blocks_set;
      my_cfg_edges    : in out cfg_edges_set;
      size            : in     Integer)
   is
      a_basic_block_ucb : basic_block_ptr;
      ucb_basic_blocks  : basic_blocks_set;

      my_iterator         : basic_blocks_iterator;
      my_iterator_edg     : cfg_edges_iterator;
      a_basic_block       : basic_block_ptr;
      a_cfg_edge          : cfg_edge_ptr;
      new_basic_block_ucb : basic_block_ucb_ptr;

      bl1 : basic_block_ptr;
      bl2 : basic_block_ptr;

   begin
      reset_iterator (my_basic_blocks, my_iterator);
      loop
         current_element (my_basic_blocks, a_basic_block, my_iterator);

         new_basic_block_ucb                 := new basic_block_ucb;
         new_basic_block_ucb.gencbr.elements :=
           new integer_arr (0 .. size - 1);
         new_basic_block_ucb.gencbr.size     := size;
         new_basic_block_ucb.gencbl.elements :=
           new integer_arr (0 .. size - 1);
         new_basic_block_ucb.gencbl.size         := size;
         new_basic_block_ucb.rmbin := new basic_block_ucb_arr (0 .. size - 1);
         new_basic_block_ucb.rmbout := new basic_block_ucb_arr (0 .. size - 1);
         new_basic_block_ucb.lmbin := new basic_block_ucb_arr (0 .. size - 1);
         new_basic_block_ucb.lmbout := new basic_block_ucb_arr (0 .. size - 1);
         new_basic_block_ucb.numberofusefulblock := 0;
         initialize (new_basic_block_ucb.ucbs);

         for i in 0 .. size - 1 loop
            new_basic_block_ucb.rmbin (i).size      := 0;
            new_basic_block_ucb.rmbin (i).elements := new integer_arr (0 .. 0);
            new_basic_block_ucb.rmbout (i).size     := 0;
            new_basic_block_ucb.rmbout (i).elements :=
              new integer_arr (0 .. 0);
            new_basic_block_ucb.lmbin (i).size      := 0;
            new_basic_block_ucb.lmbin (i).elements := new integer_arr (0 .. 0);
            new_basic_block_ucb.lmbout (i).size     := 0;
            new_basic_block_ucb.lmbout (i).elements :=
              new integer_arr (0 .. 0);
         end loop;

         a_basic_block_ucb := basic_block_ptr (new_basic_block_ucb);

         a_basic_block_ucb.cheddar_private_id :=
           a_basic_block.cheddar_private_id;
         a_basic_block_ucb.name := a_basic_block.name;

         a_basic_block_ucb.data_offset        := a_basic_block.data_offset;
         a_basic_block_ucb.data_capacity      := a_basic_block.data_capacity;
         a_basic_block_ucb.instruction_offset :=
           a_basic_block.instruction_offset;
         a_basic_block_ucb.instruction_capacity :=
           a_basic_block.instruction_capacity;
         a_basic_block_ucb.loop_bound := a_basic_block.loop_bound;
         a_basic_block_ucb.node_type  := a_basic_block.node_type;
         a_basic_block_ucb.graph_type := a_basic_block.graph_type;

         add (ucb_basic_blocks, a_basic_block_ucb);

         exit when is_last_element (my_basic_blocks, my_iterator);
         next_element (my_basic_blocks, my_iterator);
      end loop;

      reset_iterator (my_cfg_edges, my_iterator_edg);
      loop
         current_element (my_cfg_edges, a_cfg_edge, my_iterator_edg);

         bl1 :=
           search_basic_block
             (my_basic_blocks => ucb_basic_blocks,
              name            => a_cfg_edge.node);
         bl2 :=
           search_basic_block
             (my_basic_blocks => ucb_basic_blocks,
              name            => a_cfg_edge.next_node);

         add (basic_block_ucb_ptr (bl1).next_nodes, cfg_node_ptr (bl2));
         add (basic_block_ucb_ptr (bl2).previous_nodes, cfg_node_ptr (bl1));

         exit when is_last_element (my_cfg_edges, my_iterator_edg);
         next_element (my_cfg_edges, my_iterator_edg);
      end loop;

      my_basic_blocks := ucb_basic_blocks;

   end convert_to_basic_block_ucb_set;

end cfg_node_set.basic_block_set;
