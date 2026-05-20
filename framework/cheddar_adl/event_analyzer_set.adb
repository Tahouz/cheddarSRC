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

with Ada.Exceptions;           use Ada.Exceptions;
with Objects;                  use Objects;
with Objects.extended;         use Objects.extended;
with translate;                use translate;
with unbounded_strings;        use unbounded_strings;
with initialize_framework;     use initialize_framework;
with event_analyzers.extended; use event_analyzers.extended;

package body event_analyzer_set is

   procedure check_event_analyzer
     (my_event_analyzers : in event_analyzers_set;
      name               : in Unbounded_String;
      file_name          : in Unbounded_String)
   is

   begin

      if name = "" then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_event_analyzer_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_event_analyzer (Current_Language) &
               " " &
               name &
               " : " &
               lb_event_analyzer_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if file_name = "" then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_event_analyzer_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (file_name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_event_analyzer_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

   end check_event_analyzer;

   procedure add_event_analyzer
     (my_event_analyzers : in out event_analyzers_set;
      name               : in     Unbounded_String;
      file_name          : in     Unbounded_String)
   is

      an_event_analyzer : event_analyzer_ptr;
      my_iterator       : iterator;

   begin

      check_initialize;

      check_event_analyzer (my_event_analyzers, name, file_name);

      if (get_number_of_elements (my_event_analyzers) > 0) then

         reset_iterator (my_event_analyzers, my_iterator);

         loop
            current_element
              (my_event_analyzers,
               an_event_analyzer,
               my_iterator);
            if (name = an_event_analyzer.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_event_analyzer (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_event_analyzer_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;

            exit when is_last_element (my_event_analyzers, my_iterator);

            next_element (my_event_analyzers, my_iterator);

         end loop;

      end if;

      an_event_analyzer := new extended_event_analyzer;
      an_event_analyzer.event_analyzer_source_file_name := file_name;
      an_event_analyzer.name                            := name;

      add (my_event_analyzers, an_event_analyzer);

   exception
      when full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_can_not_define_more_event_analyzers (Current_Language)));

   end add_event_analyzer;

   function search_event_analyzer
     (my_event_analyzers : in event_analyzers_set;
      name               : in Unbounded_String) return event_analyzer_ptr
   is
      my_iterator       : iterator;
      an_event_analyzer : event_analyzer_ptr;
      result            : event_analyzer_ptr;

      found : Boolean := False;

   begin
      if not is_empty (my_event_analyzers) then
         reset_iterator (my_event_analyzers, my_iterator);

         loop
            current_element
              (my_event_analyzers,
               an_event_analyzer,
               my_iterator);

            if (an_event_analyzer.name = name) then
               found  := True;
               result := an_event_analyzer;
            end if;

            exit when is_last_element (my_event_analyzers, my_iterator);

            next_element (my_event_analyzers, my_iterator);

         end loop;
      end if;

      if not found then
         Raise_Exception
           (event_analyzer_not_found'identity,
            To_String
              (lb_event_analyzer_name (Current_Language) & "=" & name));
      end if;

      return result;
   end search_event_analyzer;

   function export_aadl_properties
     (my_event_analyzers : in event_analyzers_set;
      number_of_ht       : in Natural) return Unbounded_String
   is
      an_event_analyzer : event_analyzer_ptr;
      my_iterator       : event_analyzers_iterator;

      result : Unbounded_String := empty_string;

   begin

      if not is_empty (my_event_analyzers) then

         reset_iterator (my_event_analyzers, my_iterator);

         for i in 1 .. number_of_ht loop
            result := result & ASCII.HT;
         end loop;
         result :=
           result &
           To_Unbounded_String ("Cheddar_Properties::Source_Text => ") &
           """";

         loop
            current_element
              (my_event_analyzers,
               an_event_analyzer,
               my_iterator);

            result :=
              result &
              To_String (an_event_analyzer.event_analyzer_source_file_name);

            exit when is_last_element (my_event_analyzers, my_iterator);

            next_element (my_event_analyzers, my_iterator);

            result := result & ",";

         end loop;

         result := result & """" & ";" & unbounded_lf;

      end if;

      return result;

   end export_aadl_properties;

end event_analyzer_set;
