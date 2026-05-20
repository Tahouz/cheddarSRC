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
--    $Author: $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Exceptions;       use Ada.Exceptions;
with translate;            use translate;
with Objects;              use Objects;
with Objects.extended;     use Objects.extended;
with unbounded_strings;    use unbounded_strings;
with initialize_framework; use initialize_framework;
with debug;                use debug;

package body memory_set is

   procedure check_memory
     (my_memories     : in memories_set;
      name            : in Unbounded_String;
      a_memory_record : in memory_record)
   is
   begin
      if (name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_memory_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_memory (Current_Language) &
               " " &
               name &
               " : " &
               lb_memory_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

   end check_memory;

   procedure add_memory
     (my_memories     : in out memories_set;
      name            : in     Unbounded_String;
      a_memory_record : in     memory_record)
   is
      dummy : generic_memory_ptr;
   begin
      add_memory (my_memories, dummy, name, a_memory_record);
   end add_memory;

   procedure add_memory
     (my_memories     : in out memories_set;
      a_memory        : in out generic_memory_ptr;
      name            : in     Unbounded_String;
      a_memory_record : in     memory_record)
   is
      my_iterator     : iterator;
      a_dram_memory   : dram_memory_ptr;
      a_kalray_memory : kalray_memory_ptr;
   begin

      check_initialize;

      check_memory (my_memories, name, a_memory_record);

      if (get_number_of_elements (my_memories) > 0) then

         reset_iterator (my_memories, my_iterator);

         loop
            current_element (my_memories, a_memory, my_iterator);
            if (name = a_memory.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_memory (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_memory_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;

            exit when is_last_element (my_memories, my_iterator);

            next_element (my_memories, my_iterator);
         end loop;
      end if;

      if (a_memory_record.memory_category = generic_memory_type) then
         a_memory := new generic_memory;
      elsif (a_memory_record.memory_category = dram_type) then
         a_dram_memory                       := new dram_memory;
         a_dram_memory.memory_category       := dram_type;
         a_dram_memory.shared_access_latency :=
           a_memory_record.shared_access_latency;
         a_dram_memory.private_access_latency :=
           a_memory_record.private_access_latency;
         a_dram_memory.l_act_inter := a_memory_record.l_act_inter;
         a_dram_memory.l_rw_inter  := a_memory_record.l_rw_inter;
         a_dram_memory.l_pre_inter := a_memory_record.l_pre_inter;
         a_dram_memory.l_conf      := a_memory_record.l_conf;
         a_dram_memory.n_reorder   := a_memory_record.n_reorder;
         a_dram_memory.l_conhit    := a_memory_record.l_conhit;

         a_memory := generic_memory_ptr (a_dram_memory);
      elsif (a_memory_record.memory_category = kalray_type) then
         a_kalray_memory                := new kalray_memory;
         a_kalray_memory.nb_bank        := a_memory_record.nb_bank;
         a_kalray_memory.partition_mode := a_memory_record.partition_mode;

         a_memory := generic_memory_ptr (a_kalray_memory);
      end if;

      a_memory.name            := name;
      a_memory.access_latency  := a_memory_record.access_latency;
      a_memory.memory_category := a_memory_record.memory_category;
      add (my_memories, a_memory);
   exception
      when full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_memories (Current_Language)));

   end add_memory;

   function search_memory
     (my_memories : in memories_set;
      name        : in Unbounded_String) return generic_memory_ptr
   is
      my_iterator : iterator;
      a_memory    : generic_memory_ptr;
      result      : generic_memory_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_memories) then

         reset_iterator (my_memories, my_iterator);

         loop
            current_element (my_memories, a_memory, my_iterator);

            if (a_memory.name = name) then
               found  := True;
               result := a_memory;
            end if;

            exit when is_last_element (my_memories, my_iterator);

            next_element (my_memories, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (memory_not_found'identity,
            To_String (lb_memory_name (Current_Language) & "=" & name));
      end if;

      return result;

   end search_memory;

   function search_memory_by_id
     (my_memories : in memories_set;
      id          : in Unbounded_String) return generic_memory_ptr
   is
      my_iterator : memories_iterator;
      a_memory    : generic_memory_ptr;
      result      : generic_memory_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_memories) then

         reset_iterator (my_memories, my_iterator);

         loop
            current_element (my_memories, a_memory, my_iterator);

            if (a_memory.cheddar_private_id = id) then
               found  := True;
               result := a_memory;
            end if;

            exit when is_last_element (my_memories, my_iterator);

            next_element (my_memories, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (memory_not_found'identity,
            To_String (lb_memory_id (Current_Language) & "=" & id));
      end if;

      return result;

   end search_memory_by_id;

end memory_set;
