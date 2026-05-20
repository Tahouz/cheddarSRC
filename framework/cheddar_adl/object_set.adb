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
--    $Rev: 1249 $
--    $Date: 2014-08-28 07:02:15 +0200 (Fri, 28 Aug 2014) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Exceptions; use Ada.Exceptions;
with translate;      use translate;

package body object_set is

   function search_object
     (my_objects : in objects_set;
      name       : in Unbounded_String) return generic_object_ptr
   is

      my_iterator : iterator;
      an_object   : generic_object_ptr;
      result      : generic_object_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_objects) then

         reset_iterator (my_objects, my_iterator);

         loop
            current_element (my_objects, an_object, my_iterator);

            if (named_object_ptr (an_object).name = name) then
               found  := True;
               result := an_object;
            end if;

            exit when is_last_element (my_objects, my_iterator);

            next_element (my_objects, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (object_not_found'identity,
            To_String (lb_object_name (Current_Language) & "=" & name));
      end if;

      return result;

   end search_object;

   function search_object_by_id
     (my_objects : in objects_set;
      id         : in Unbounded_String) return generic_object_ptr
   is

      my_iterator : objects_iterator;
      an_object   : generic_object_ptr;
      result      : generic_object_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_objects) then

         reset_iterator (my_objects, my_iterator);

         loop
            current_element (my_objects, an_object, my_iterator);

            if (an_object.cheddar_private_id = id) then
               found  := True;
               result := an_object;
            end if;

            exit when is_last_element (my_objects, my_iterator);

            next_element (my_objects, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (object_not_found'identity,
            To_String (lb_object_id (Current_Language) & "=" & id));
      end if;

      return result;

   end search_object_by_id;

end object_set;
