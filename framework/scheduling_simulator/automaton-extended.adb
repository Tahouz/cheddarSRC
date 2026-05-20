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

package body Automaton.extended is

   function search_transition
     (a_list : in transition_lists;
      name   : in Unbounded_String) return transition_ptr
   is
      result       : transition_ptr := null;
      a_transition : transition_ptr;
      list_ite     : transition_lists_iterator;

   begin

      if not is_empty (a_list) then

         reset_head_iterator (a_list, list_ite);
         loop
            current_element (a_list, a_transition, list_ite);

            if a_transition.name = name then
               result := a_transition;
            end if;

            if is_tail_element (a_list, list_ite) then
               exit;
            end if;
            next_element (a_list, list_ite);
         end loop;

      end if;

      if result /= null then
         return result;
      else
         raise transition_not_found;
      end if;

   end search_transition;

   function search_state
     (a_list : in state_lists;
      name   : in Unbounded_String) return state_ptr
   is
      result   : state_ptr := null;
      a_state  : state_ptr;
      list_ite : state_lists_iterator;

   begin

      if not is_empty (a_list) then

         reset_head_iterator (a_list, list_ite);
         loop
            current_element (a_list, a_state, list_ite);

            if a_state.name = name then
               result := a_state;
            end if;

            if is_tail_element (a_list, list_ite) then
               exit;
            end if;
            next_element (a_list, list_ite);
         end loop;

      end if;

      if result /= null then
         return result;
      else
         raise state_not_found;
      end if;

   end search_state;

   function search_initial_state (a_list : in state_lists) return state_ptr is
      result   : state_ptr := null;
      a_state  : state_ptr;
      list_ite : state_lists_iterator;

   begin

      if not is_empty (a_list) then

         reset_head_iterator (a_list, list_ite);
         loop
            current_element (a_list, a_state, list_ite);

            if a_state.is_initial then
               result := a_state;
            end if;

            if is_tail_element (a_list, list_ite) then
               exit;
            end if;
            next_element (a_list, list_ite);
         end loop;

      end if;

      if result /= null then
         return result;
      else
         raise state_not_found;
      end if;

   end search_initial_state;

end Automaton.extended;
