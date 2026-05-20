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

with unbounded_strings;    use unbounded_strings;
with Ada.Exceptions;       use Ada.Exceptions;
with Objects;              use Objects;
with Objects.extended;     use Objects.extended;
with translate;            use translate;
with initialize_framework; use initialize_framework;

package body section_set is

   procedure add_section
     (my_sections  : in out sections_set;
      name         : in     Unbounded_String;
      section_type : in     sections_type)
   is

      dummy : generic_section_ptr;

   begin
      add_section (my_sections, dummy, name, section_type);
   end add_section;

   procedure check_section
     (my_sections  : in sections_set;
      name         : in Unbounded_String;
      section_type : in sections_type)
   is

   begin

      if name = "" then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_section_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_section (Current_Language) &
               " " &
               name &
               " : " &
               lb_section_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

   end check_section;

   procedure add_section
     (my_sections  : in out sections_set;
      a_section    : in out generic_section_ptr;
      name         : in     Unbounded_String;
      section_type : in     sections_type)
   is

      my_iterator                 : iterator;
      new_synchronization_section : synchronization_section_ptr;
      new_computation_section     : computation_section_ptr;

   begin

      check_initialize;

      check_section (my_sections, name, section_type);

      if (get_number_of_elements (my_sections) > 0) then

         reset_iterator (my_sections, my_iterator);

         loop
            current_element (my_sections, a_section, my_iterator);
            if (name = a_section.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_section (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_section_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;
            exit when is_last_element (my_sections, my_iterator);
            next_element (my_sections, my_iterator);
         end loop;
      end if;

      case section_type is
         when automaton_type =>
            new_synchronization_section := new synchronization_section;
            a_section := generic_section_ptr (new_synchronization_section);
         when others =>
            new_computation_section := new computation_section;
            a_section := generic_section_ptr (new_computation_section);
      end case;

      a_section.name         := name;
      a_section.section_type := section_type;

      add (my_sections, a_section);

   exception
      when full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_sections (Current_Language)));

   end add_section;

   function search_section
     (my_sections : in sections_set;
      type_name   : in sections_type) return generic_section_ptr
   is
      my_iterator : iterator;
      a_section   : generic_section_ptr;
      result      : generic_section_ptr;

      found : Boolean := False;

   begin

      reset_iterator (my_sections, my_iterator);

      loop
         current_element (my_sections, a_section, my_iterator);

         if (a_section.section_type = type_name) then
            found  := True;
            result := a_section;
         end if;

         exit when is_last_element (my_sections, my_iterator);

         next_element (my_sections, my_iterator);

      end loop;

      if not found then
         Raise_Exception
           (section_not_found'identity,
            To_String (lb_section (Current_Language) & "=" & type_name'img));
      end if;

      return result;
   end search_section;

   function search_section
     (my_sections : in sections_set;
      name        : in Unbounded_String) return generic_section_ptr
   is
      my_iterator : iterator;
      a_section   : generic_section_ptr;
      result      : generic_section_ptr;

      found : Boolean := False;

   begin

      reset_iterator (my_sections, my_iterator);

      loop
         current_element (my_sections, a_section, my_iterator);

         if (a_section.name = name) then
            found  := True;
            result := a_section;
         end if;

         exit when is_last_element (my_sections, my_iterator);

         next_element (my_sections, my_iterator);

      end loop;

      if not found then
         Raise_Exception
           (section_not_found'identity,
            To_String (lb_section_name (Current_Language) & "=" & name));
      end if;

      return result;
   end search_section;

   function export_aadl_implementations
     (my_sections : in sections_set) return Unbounded_String
   is
   begin
      return empty_string;
   end export_aadl_implementations;

   function export_aadl_declarations
     (my_sections  : in sections_set;
      number_of_ht : in Natural) return Unbounded_String
   is
   begin
      return empty_string;
   end export_aadl_declarations;

end section_set;
