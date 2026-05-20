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
with translate;            use translate;
with Objects;              use Objects;
with Objects.extended;     use Objects.extended;
with unbounded_strings;    use unbounded_strings;
with initialize_framework; use initialize_framework;
with debug;                use debug;

package body buffer_set is

   procedure add_buffer
     (my_buffers         : in out buffers_set;
      name               : in     Unbounded_String;
      size               : in     Integer;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      a_qs               : in     queueing_systems_type;
      roles              : in     buffer_roles_table;
      initial_data       : in     Integer := 0)
   is

      dummy : buffer_ptr;

   begin
      add_buffer
        (my_buffers,
         dummy,
         name,
         size,
         cpu_name,
         address_space_name,
         a_qs,
         roles,
         initial_data);
   end add_buffer;

   procedure check_buffer
     (my_buffers         : in buffers_set;
      name               : in Unbounded_String;
      size               : in Integer;
      cpu_name           : in Unbounded_String;
      address_space_name : in Unbounded_String)
   is

   begin

      if (name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_buffer_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_buffer (Current_Language) &
               " " &
               name &
               " : " &
               lb_buffer_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if (cpu_name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_buffer (Current_Language) &
               " " &
               name &
               " : " &
               lb_processor_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (cpu_name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_buffer (Current_Language) &
               " " &
               name &
               " : " &
               lb_processor_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if (address_space_name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_buffer (Current_Language) &
               " " &
               name &
               " : " &
               lb_address_space_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (address_space_name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_buffer (Current_Language) &
               " " &
               name &
               " : " &
               lb_address_space_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if (size <= 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_buffer (Current_Language) &
               " " &
               name &
               " : " &
               lb_size (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_than (Current_Language) &
               "0"));
      end if;

   end check_buffer;

   procedure add_buffer
     (my_buffers         : in out buffers_set;
      a_buffer           : in out buffer_ptr;
      name               : in     Unbounded_String;
      size               : in     Integer;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      a_qs               : in     queueing_systems_type;
      roles              : in     buffer_roles_table;
      initial_data       : in     Integer := 0)
   is

      my_iterator : iterator;

   begin

      check_initialize;

      check_buffer (my_buffers, name, size, cpu_name, address_space_name);

      if (get_number_of_elements (my_buffers) > 0) then

         reset_iterator (my_buffers, my_iterator);

         loop
            current_element (my_buffers, a_buffer, my_iterator);
            if (name = a_buffer.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_buffer (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_buffer_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;

            exit when is_last_element (my_buffers, my_iterator);

            next_element (my_buffers, my_iterator);
         end loop;
      end if;

      a_buffer                          := new buffer;
      a_buffer.name                     := name;
      a_buffer.cpu_name                 := cpu_name;
      a_buffer.address_space_name       := address_space_name;
      a_buffer.buffer_size              := size;
      a_buffer.roles                    := roles;
      a_buffer.queueing_system_type     := a_qs;
      a_buffer.buffer_initial_data_size := initial_data;
      add (my_buffers, a_buffer);

   exception
      when full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_buffers (Current_Language)));

   end add_buffer;

   procedure update_buffer
     (my_buffers         : in out buffers_set;
      name               : in     Unbounded_String;
      new_name           : in     Unbounded_String;
      size               : in     Integer;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      roles              : in     buffer_roles_table;
      initial_data       : in     Integer := 0)
   is
      the_buffer : buffer_ptr;
   begin
      the_buffer                          := search_buffer (my_buffers, name);
      the_buffer.name                     := new_name;
      the_buffer.address_space_name       := address_space_name;
      the_buffer.cpu_name                 := cpu_name;
      the_buffer.buffer_size              := size;
      the_buffer.roles                    := roles;
      the_buffer.buffer_initial_data_size := initial_data;
   end update_buffer;

   function get
     (my_buffers  : in buffers_set;
      buffer_name : in Unbounded_String;
      param_name  : in buffer_parameters) return Natural
   is
      a_buffer    : buffer_ptr;
      my_iterator : iterator;

   begin

      if (param_name /= size) then
         raise invalid_parameter;
      end if;

      reset_iterator (my_buffers, my_iterator);

      loop
         current_element (my_buffers, a_buffer, my_iterator);

         if (a_buffer.name = buffer_name) then
            exit;
         end if;

         exit when is_last_element (my_buffers, my_iterator);

         next_element (my_buffers, my_iterator);

      end loop;

      return a_buffer.buffer_size;

   end get;

   function get
     (my_buffers  : in buffers_set;
      buffer_name : in Unbounded_String;
      param_name  : in buffer_parameters) return Unbounded_String
   is
      a_buffer    : buffer_ptr;
      my_iterator : iterator;

   begin

      if (param_name /= cpu_name) and (param_name /= address_space_name) then
         raise invalid_parameter;
      end if;

      reset_iterator (my_buffers, my_iterator);

      loop
         current_element (my_buffers, a_buffer, my_iterator);

         if (a_buffer.name = buffer_name) then
            exit;
         end if;

         exit when is_last_element (my_buffers, my_iterator);

         next_element (my_buffers, my_iterator);

      end loop;

      if (param_name /= cpu_name) then
         return a_buffer.cpu_name;
      else
         return a_buffer.address_space_name;
      end if;

   end get;

   procedure set
     (my_buffers  : in out buffers_set;
      buffer_name : in     Unbounded_String;
      param_name  : in     buffer_parameters;
      param_value : in     Natural)
   is
      a_buffer    : buffer_ptr;
      my_iterator : iterator;

   begin

      if (param_name /= size) then
         raise invalid_parameter;
      end if;

      reset_iterator (my_buffers, my_iterator);

      loop
         current_element (my_buffers, a_buffer, my_iterator);

         if (a_buffer.name = buffer_name) then
            a_buffer.buffer_size := param_value;
            exit;
         end if;

         exit when is_last_element (my_buffers, my_iterator);

         next_element (my_buffers, my_iterator);

      end loop;
   end set;

   procedure set
     (my_buffers  : in out buffers_set;
      buffer_name : in     Unbounded_String;
      param_name  : in     buffer_parameters;
      param_value : in     Unbounded_String)
   is
      a_buffer    : buffer_ptr;
      my_iterator : iterator;

   begin

      if (param_name /= cpu_name) and (param_name /= address_space_name) then
         raise invalid_parameter;
      end if;

      reset_iterator (my_buffers, my_iterator);

      loop
         current_element (my_buffers, a_buffer, my_iterator);

         if (a_buffer.name = buffer_name) then
            if (param_name /= cpu_name) then
               a_buffer.cpu_name := param_value;
            else
               a_buffer.address_space_name := param_value;
            end if;
            exit;
         end if;

         exit when is_last_element (my_buffers, my_iterator);

         next_element (my_buffers, my_iterator);

      end loop;
   end set;

   function search_buffer_by_id
     (my_buffers : in buffers_set;
      id         : in Unbounded_String) return buffer_ptr
   is
      my_iterator : iterator;
      a_buffer    : buffer_ptr;
      result      : buffer_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_buffers) then

         reset_iterator (my_buffers, my_iterator);

         loop
            current_element (my_buffers, a_buffer, my_iterator);

            if (a_buffer.cheddar_private_id = id) then
               found  := True;
               result := a_buffer;
            end if;

            exit when is_last_element (my_buffers, my_iterator);

            next_element (my_buffers, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (buffer_not_found'identity,
            To_String (lb_buffer_id (Current_Language) & "=" & id));
      end if;

      return result;

   end search_buffer_by_id;

   function search_buffer
     (my_buffers : in buffers_set;
      name       : in Unbounded_String) return buffer_ptr
   is
      my_iterator : iterator;
      a_buffer    : buffer_ptr;
      result      : buffer_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_buffers) then

         reset_iterator (my_buffers, my_iterator);

         loop
            current_element (my_buffers, a_buffer, my_iterator);

            if (a_buffer.name = name) then
               found  := True;
               result := a_buffer;
            end if;

            exit when is_last_element (my_buffers, my_iterator);

            next_element (my_buffers, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (buffer_not_found'identity,
            To_String (lb_buffer_name (Current_Language) & "=" & name));
      end if;

      return result;

   end search_buffer;

   procedure delete_task
     (my_buffers : in out buffers_set;
      a_task     : in     Unbounded_String)
   is

      a_buffer    : buffer_ptr;
      my_iterator : buffers_iterator;
      nb_entries  : buffer_roles_range;

   begin

      if (get_number_of_elements (my_buffers) > 0) then

         reset_iterator (my_buffers, my_iterator);
         loop
            current_element (my_buffers, a_buffer, my_iterator);

            -- Looking for a_task in roles
            --
            nb_entries := a_buffer.roles.nb_entries;
            for index in 0 .. nb_entries - 1 loop
               if (a_buffer.roles.entries (index).item = a_task) then
                  a_buffer.roles.entries (index) :=
                    a_buffer.roles.entries (a_buffer.roles.nb_entries - 1);

                  a_buffer.roles.nb_entries := a_buffer.roles.nb_entries - 1;
               end if;
            end loop;

            exit when is_last_element (my_buffers, my_iterator);
            next_element (my_buffers, my_iterator);
         end loop;

      end if;

   end delete_task;

   procedure delete_address_space
     (my_buffers : in out buffers_set;
      a_addr     : in     Unbounded_String)
   is

      tmp         : buffers_set;
      a_buffer    : buffer_ptr;
      my_iterator : buffers_iterator;

   begin

      if (get_number_of_elements (my_buffers) > 0) then

         reset_iterator (my_buffers, my_iterator);
         loop
            current_element (my_buffers, a_buffer, my_iterator);

            if (a_buffer.address_space_name = a_addr) then
               add (tmp, a_buffer);
            end if;

            exit when is_last_element (my_buffers, my_iterator);
            next_element (my_buffers, my_iterator);
         end loop;

         if not is_empty (tmp) then
            reset_iterator (tmp, my_iterator);
            loop
               current_element (tmp, a_buffer, my_iterator);

               delete (my_buffers, a_buffer);

               exit when is_last_element (tmp, my_iterator);
               next_element (tmp, my_iterator);
            end loop;
         end if;

      end if;
   end delete_address_space;

   function get_number_of_buffer_from_processor
     (my_buffers     : in buffers_set;
      processor_name : in Unbounded_String) return buffers_range
   is
      number      : buffers_range := 0;
      a_buffer    : buffer_ptr;
      my_iterator : iterator;

   begin

      if is_empty (my_buffers) then
         return 0;
      end if;

      reset_iterator (my_buffers, my_iterator);

      loop
         current_element (my_buffers, a_buffer, my_iterator);

         if (a_buffer.cpu_name = processor_name) then
            number := number + 1;
         end if;

         exit when is_last_element (my_buffers, my_iterator);

         next_element (my_buffers, my_iterator);

      end loop;

      return number;
   end get_number_of_buffer_from_processor;

   procedure delete_processor
     (my_buffers  : in out buffers_set;
      a_processor : in     Unbounded_String)
   is

      tmp         : buffers_set;
      a_buffer    : buffer_ptr;
      my_iterator : buffers_iterator;

   begin

      if (get_number_of_elements (my_buffers) > 0) then

         reset_iterator (my_buffers, my_iterator);
         loop
            current_element (my_buffers, a_buffer, my_iterator);

            if (a_buffer.cpu_name = a_processor) then
               add (tmp, a_buffer);
            end if;

            exit when is_last_element (my_buffers, my_iterator);
            next_element (my_buffers, my_iterator);
         end loop;

         if not is_empty (tmp) then
            reset_iterator (tmp, my_iterator);
            loop
               current_element (tmp, a_buffer, my_iterator);

               delete (my_buffers, a_buffer);

               exit when is_last_element (tmp, my_iterator);
               next_element (tmp, my_iterator);
            end loop;

            reset (tmp, False);
         end if;
      end if;

   end delete_processor;

   function export_aadl_implementations
     (my_buffers : in buffers_set) return Unbounded_String
   is
      result : Unbounded_String := empty_string;

   begin

      return result;

   end export_aadl_implementations;

   procedure check_entity_referencing_processor
     (my_buffers  : in buffers_set;
      a_processor : in Unbounded_String)
   is

      a_buffer    : buffer_ptr;
      my_iterator : buffers_iterator;

   begin
      if (get_number_of_elements (my_buffers) > 0) then

         reset_iterator (my_buffers, my_iterator);
         loop
            current_element (my_buffers, a_buffer, my_iterator);

            if (a_buffer.cpu_name = a_processor) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_processor (Current_Language) &
                     " " &
                     a_processor &
                     " : " &
                     lb_buffer (Current_Language) &
                     " " &
                     a_buffer.name &
                     " : " &
                     lb_entity_referenced_elsewhere (Current_Language)));
            end if;

            exit when is_last_element (my_buffers, my_iterator);
            next_element (my_buffers, my_iterator);
         end loop;

      end if;
   end check_entity_referencing_processor;

   procedure check_entity_referencing_address_space
     (my_buffers : in buffers_set;
      a_addr     : in Unbounded_String)
   is

      a_buffer    : buffer_ptr;
      my_iterator : buffers_iterator;

   begin
      if (get_number_of_elements (my_buffers) > 0) then

         reset_iterator (my_buffers, my_iterator);
         loop
            current_element (my_buffers, a_buffer, my_iterator);

            if (a_buffer.address_space_name = a_addr) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_address_space (Current_Language) &
                     " " &
                     a_addr &
                     " : " &
                     lb_buffer (Current_Language) &
                     " " &
                     a_buffer.name &
                     " : " &
                     lb_entity_referenced_elsewhere (Current_Language)));
            end if;

            exit when is_last_element (my_buffers, my_iterator);
            next_element (my_buffers, my_iterator);
         end loop;

      end if;
   end check_entity_referencing_address_space;

   procedure check_entity_referencing_task
     (my_buffers : in buffers_set;
      a_task     : in Unbounded_String)
   is

      a_buffer    : buffer_ptr;
      my_iterator : buffers_iterator;

   begin
      if (get_number_of_elements (my_buffers) > 0) then

         reset_iterator (my_buffers, my_iterator);
         loop
            current_element (my_buffers, a_buffer, my_iterator);

            for i in 0 .. a_buffer.roles.nb_entries - 1 loop
               if a_buffer.roles.entries (i).item = a_task then
                  Raise_Exception
                    (invalid_parameter'identity,
                     To_String
                       (lb_task (Current_Language) &
                        " " &
                        a_task &
                        " : " &
                        lb_buffer (Current_Language) &
                        " " &
                        a_buffer.name &
                        " : " &
                        lb_entity_referenced_elsewhere (Current_Language)));
               end if;
            end loop;

            exit when is_last_element (my_buffers, my_iterator);
            next_element (my_buffers, my_iterator);
         end loop;

      end if;
   end check_entity_referencing_task;

end buffer_set;
