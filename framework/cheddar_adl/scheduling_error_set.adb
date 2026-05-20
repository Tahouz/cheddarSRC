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
--    $Rev: 3477 $
--    $Date: 2020-07-13 11:43:48 +0200 (lun., 13 juil. 2020) $
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

package body scheduling_error_set is

   procedure check_scheduling_error
     (my_scheduling_errors      : in scheduling_errors_set;
      name                      : in Unbounded_String;
      a_scheduling_error_record : in scheduling_error_record)
   is
      a_scheduling_error : scheduling_error_ptr;
      my_iterator        : scheduling_errors_iterator;
   begin
      if (get_number_of_elements (my_scheduling_errors) > 0) then

         reset_iterator (my_scheduling_errors, my_iterator);

         loop
            current_element
              (my_scheduling_errors,
               a_scheduling_error,
               my_iterator);
            if (name = a_scheduling_error.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_scheduling_error (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_scheduling_error_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;

            exit when is_last_element (my_scheduling_errors, my_iterator);

            next_element (my_scheduling_errors, my_iterator);
         end loop;
      end if;

      if (name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_scheduling_error_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_scheduling_error (Current_Language) &
               " " &
               name &
               " : " &
               lb_scheduling_error_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

   end check_scheduling_error;

   procedure add_scheduling_error
     (my_scheduling_errors      : in out scheduling_errors_set;
      name                      : in     Unbounded_String;
      a_scheduling_error_record : in     scheduling_error_record)
   is
      dummy : scheduling_error_ptr;
   begin
      add_scheduling_error
        (my_scheduling_errors,
         dummy,
         name,
         a_scheduling_error_record);
   end add_scheduling_error;

   procedure add_scheduling_error
     (my_scheduling_errors      : in out scheduling_errors_set;
      a_scheduling_error        : in out scheduling_error_ptr;
      name                      : in     Unbounded_String;
      a_scheduling_error_record : in     scheduling_error_record)
   is
      my_iterator : iterator;

   begin
      check_initialize;
      check_scheduling_error
        (my_scheduling_errors,
         name,
         a_scheduling_error_record);

      a_scheduling_error              := new scheduling_error;
      a_scheduling_error.name         := name;
      a_scheduling_error.error_type   := a_scheduling_error_record.error_type;
      a_scheduling_error.time         := a_scheduling_error_record.time;
      a_scheduling_error.error_action :=
        a_scheduling_error_record.error_action;
      a_scheduling_error.user_defined_action :=
        a_scheduling_error_record.user_defined_action;

      add (my_scheduling_errors, a_scheduling_error);
   exception
      when full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_can_not_define_more_scheduling_errors (Current_Language)));
   end add_scheduling_error;

   function search_scheduling_error
     (my_scheduling_errors : in scheduling_errors_set;
      name                 : in Unbounded_String) return scheduling_error_ptr
   is
      my_iterator        : iterator;
      a_scheduling_error : scheduling_error_ptr;
      result             : scheduling_error_ptr;

      found : Boolean := False;
   begin
      if not is_empty (my_scheduling_errors) then

         reset_iterator (my_scheduling_errors, my_iterator);

         loop
            current_element
              (my_scheduling_errors,
               a_scheduling_error,
               my_iterator);

            if (a_scheduling_error.name = name) then
               found  := True;
               result := a_scheduling_error;
            end if;

            exit when is_last_element (my_scheduling_errors, my_iterator);

            next_element (my_scheduling_errors, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (scheduling_error_not_found'identity,
            To_String
              (lb_scheduling_error_name (Current_Language) & "=" & name));
      end if;

      return result;
   end search_scheduling_error;

   function search_scheduling_error_by_id
     (my_scheduling_errors : in scheduling_errors_set;
      id                   : in Unbounded_String) return scheduling_error_ptr
   is
      my_iterator        : iterator;
      a_scheduling_error : scheduling_error_ptr;
      result             : scheduling_error_ptr;

      found : Boolean := False;
   begin
      if not is_empty (my_scheduling_errors) then

         reset_iterator (my_scheduling_errors, my_iterator);

         loop
            current_element
              (my_scheduling_errors,
               a_scheduling_error,
               my_iterator);

            if (a_scheduling_error.cheddar_private_id = id) then
               found  := True;
               result := a_scheduling_error;
            end if;

            exit when is_last_element (my_scheduling_errors, my_iterator);

            next_element (my_scheduling_errors, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (scheduling_error_not_found'identity,
            To_String (lb_scheduling_error_id (Current_Language) & "=" & id));
      end if;

      return result;
   end search_scheduling_error_by_id;

end scheduling_error_set;
