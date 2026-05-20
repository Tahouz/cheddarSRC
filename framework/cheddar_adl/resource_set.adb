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
--    $Rev: 4589 $
--    $Date: 2023-09-29 16:02:19 +0200 (ven., 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with time_unit_events; use time_unit_events;
use time_unit_events.time_unit_package;
with unbounded_strings;    use unbounded_strings;
with Ada.Exceptions;       use Ada.Exceptions;
with translate;            use translate;
with Objects;              use Objects;
with Objects.extended;     use Objects.extended;
with initialize_framework; use initialize_framework;

package body resource_set is

   procedure update_resource
     (my_resources        : in out resources_set;
      name                : in     Unbounded_String;
      state               : in     Integer;
      address             : in     Integer;
      size                : in     Integer;
      cpu_name            : in     Unbounded_String;
      address_space_name  : in     Unbounded_String;
      protocol            : in     resources_type;
      affected_tasks      : in     resource_accesses_table;
      priority            : in     Integer;
      priority_assignment : in     priority_assignment_type)
   is

      the_resource : generic_resource_ptr;

   begin

      the_resource := search_resource (my_resources, name);

      check_resource
        (my_resources,
         name,
         state,
         address,
         size,
         cpu_name,
         address_space_name,
         protocol,
         priority);
      delete (my_resources, the_resource);
      add_resource
        (my_resources,
         name,
         state,
         address,
         size,
         cpu_name,
         address_space_name,
         protocol,
         affected_tasks,
         priority,
         priority_assignment);

   end update_resource;

   procedure add_resource
     (my_resources        : in out resources_set;
      name                : in     Unbounded_String;
      state               : in     Integer;
      address             : in     Integer;
      size                : in     Integer;
      cpu_name            : in     Unbounded_String;
      address_space_name  : in     Unbounded_String;
      protocol            : in     resources_type;
      affected_tasks      : in     resource_accesses_table;
      priority            : in     Integer;
      priority_assignment : in     priority_assignment_type)
   is

      a_resource_ptr : generic_resource_ptr;

   begin

      add_resource
        (my_resources,
         a_resource_ptr,
         name,
         state,
         address,
         size,
         cpu_name,
         address_space_name,
         protocol,
         affected_tasks,
         priority,
         priority_assignment);

   end add_resource;

   procedure check_resource
     (my_resources       : in resources_set;
      name               : in Unbounded_String;
      state              : in Integer;
      address            : in Integer;
      size               : in Integer;
      cpu_name           : in Unbounded_String;
      address_space_name : in Unbounded_String;
      protocol           : in resources_type;
      priority           : in Integer)
   is

   begin

      if name = "" then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_resource_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_resource (Current_Language) &
               " " &
               name &
               " : " &
               lb_resource_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if cpu_name = "" then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_resource (Current_Language) &
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
              (lb_resource (Current_Language) &
               name &
               " : " &
               lb_processor_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if address_space_name = "" then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_resource (Current_Language) &
               " " &
               name &
               " : " &
               lb_address_space_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (cpu_name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_resource (Current_Language) &
               name &
               " : " &
               lb_address_space_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if (protocol /= no_protocol) and
        (protocol /= priority_ceiling_protocol) and
        (protocol /= pool_based_priority_ceiling_protocol) and
        (protocol /= priority_inheritance_protocol) and
        (protocol /= immediate_priority_ceiling_protocol)
      then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_resource (Current_Language) &
               " " &
               name &
               " : " &
               lb_invalid_protocol (Current_Language)));
      end if;

      if (size < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_resource (Current_Language) &
               " " &
               name &
               " ; " &
               lb_size (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               To_Unbounded_String ("0")));
      end if;

      if (state < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_resource (Current_Language) &
               " " &
               name &
               " ; " &
               lb_state (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               To_Unbounded_String ("0")));
      end if;

      if (address < 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_resource (Current_Language) &
               " " &
               name &
               " ; " &
               lb_address (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               To_Unbounded_String ("0")));
      end if;

      if (priority < Integer (priority_range'first)) or
        (priority > Integer (priority_range'last))
      then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_resource (Current_Language) &
               " " &
               name &
               " : " &
               lb_invalid_priority (Current_Language)));
      end if;

   end check_resource;

   procedure add_resource
     (my_resources        : in out resources_set;
      a_resource          : in out generic_resource_ptr;
      name                : in     Unbounded_String;
      state               : in     Integer;
      address             : in     Integer;
      size                : in     Integer;
      cpu_name            : in     Unbounded_String;
      address_space_name  : in     Unbounded_String;
      protocol            : in     resources_type;
      affected_tasks      : in     resource_accesses_table;
      priority            : in     Integer;
      priority_assignment : in     priority_assignment_type)
   is

      new_protocol      : resources_type;
      new_pcp_resource  : pcp_resource_ptr;
      new_ppcp_resource  : ppcp_resource_ptr;
      new_pip_resource  : pip_resource_ptr;
      new_np_resource   : np_resource_ptr;
      new_ipcp_resource : ipcp_resource_ptr;

      my_iterator : iterator;

   begin

      check_initialize;

      check_resource
        (my_resources,
         name,
         state,
         address,
         size,
         cpu_name,
         address_space_name,
         protocol,
         priority);

      -- Resource already exist ?
      --
      if (get_number_of_elements (my_resources) > 0) then

         reset_iterator (my_resources, my_iterator);

         loop
            current_element (my_resources, a_resource, my_iterator);

            if (name = a_resource.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_resource (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_resource_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;

            exit when is_last_element (my_resources, my_iterator);

            next_element (my_resources, my_iterator);

         end loop;

      end if;

      if (protocol = priority_ceiling_protocol) then
         new_pcp_resource          := new pcp_resource;
         new_pcp_resource.priority := priority_range (priority);
         new_protocol              := priority_ceiling_protocol;
         a_resource                := generic_resource_ptr (new_pcp_resource);
      else
      if (protocol = pool_based_priority_ceiling_protocol) then
         new_ppcp_resource          := new ppcp_resource;
         new_ppcp_resource.priority := priority_range (priority);
         new_protocol              := pool_based_priority_ceiling_protocol;
         a_resource                := generic_resource_ptr (new_ppcp_resource);
        else
         if (protocol = priority_inheritance_protocol) then
            new_pip_resource := new pip_resource;
            new_protocol     := priority_inheritance_protocol;
            a_resource       := generic_resource_ptr (new_pip_resource);
         else
            if (protocol = no_protocol) then
               new_np_resource := new np_resource;
               new_protocol    := no_protocol;
               a_resource      := generic_resource_ptr (new_np_resource);
            else
               new_ipcp_resource          := new ipcp_resource;
               new_ipcp_resource.priority := priority_range (priority);
               new_protocol := immediate_priority_ceiling_protocol;
               a_resource := generic_resource_ptr (new_ipcp_resource);
            end if;
         end if;
        end if;
      end if;

      a_resource.name               := name;
      a_resource.state              := state;
      a_resource.size               := size;
      a_resource.address            := address;
      a_resource.cpu_name           := cpu_name;
      a_resource.address_space_name := address_space_name;
      a_resource.protocol           := new_protocol;

      a_resource.priority            := priority_range (priority);
      a_resource.priority_assignment := priority_assignment;

      a_resource.critical_sections := affected_tasks;

      add (my_resources, a_resource);

   exception
      when full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String (lb_can_not_define_more_resources (Current_Language)));

   end add_resource;

   function search_resource_by_id
     (my_resources : in resources_set;
      id           : in Unbounded_String) return generic_resource_ptr
   is
      my_iterator : iterator;
      a_resource  : generic_resource_ptr;
      result      : generic_resource_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_resources) then

         reset_iterator (my_resources, my_iterator);

         loop
            current_element (my_resources, a_resource, my_iterator);

            if (a_resource.cheddar_private_id = id) then
               found  := True;
               result := a_resource;
            end if;

            exit when is_last_element (my_resources, my_iterator);

            next_element (my_resources, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (resource_not_found'identity,
            To_String (lb_resource_id (Current_Language) & "=" & id));
      end if;

      return result;

   end search_resource_by_id;

   -- SR append
   function resource_is_present
     (my_resources : in resources_set;
      name         : in Unbounded_String) return Boolean
   is
      my_iterator : resources_iterator;
      a_resource  : generic_resource_ptr;

      found : Boolean := False;

   begin

      if is_empty (my_resources) then
         return False;
      else
         reset_iterator (my_resources, my_iterator);

         loop
            current_element (my_resources, a_resource, my_iterator);

            if (a_resource.name = name) then
               found := True;
            end if;

            exit when is_last_element (my_resources, my_iterator);

            next_element (my_resources, my_iterator);

         end loop;

         return found;
      end if;

   end resource_is_present;

   function search_resource
     (my_resources : in resources_set;
      name         : in Unbounded_String) return generic_resource_ptr
   is
      my_iterator : iterator;
      a_resource  : generic_resource_ptr;
      result      : generic_resource_ptr;

      found : Boolean := False;

   begin

      if not is_empty (my_resources) then

         reset_iterator (my_resources, my_iterator);

         loop
            current_element (my_resources, a_resource, my_iterator);

            if (a_resource.name = name) then
               found  := True;
               result := a_resource;
            end if;

            exit when is_last_element (my_resources, my_iterator);

            next_element (my_resources, my_iterator);

         end loop;

      end if;

      if not found then
         Raise_Exception
           (resource_not_found'identity,
            To_String (lb_resource_name (Current_Language) & "=" & name));
      end if;

      return result;

   end search_resource;

   procedure delete_task
     (my_resources : in out resources_set;
      a_task       : in     Unbounded_String)
   is

      a_resource  : generic_resource_ptr;
      my_iterator : resources_iterator;
      index       : resource_accesses_range := 1;

   begin

      if (get_number_of_elements (my_resources) > 0) then

         reset_iterator (my_resources, my_iterator);
         loop
            current_element (my_resources, a_resource, my_iterator);

            -- Looking for a_task in the task_list and delete it
            --
            index := 0;
            while (index < a_resource.critical_sections.nb_entries) loop
               if
                 (a_resource.critical_sections.entries (index).item = a_task)
               then
                  a_resource.critical_sections.entries (index) :=
                    a_resource.critical_sections.entries
                      (a_resource.critical_sections.nb_entries - 1);

                  a_resource.critical_sections.nb_entries :=
                    a_resource.critical_sections.nb_entries - 1;
               end if;
               index := index + 1;
            end loop;

            exit when is_last_element (my_resources, my_iterator);
            next_element (my_resources, my_iterator);
         end loop;
      end if;

   end delete_task;

   procedure delete_address_space
     (my_resources : in out resources_set;
      a_addr       : in     Unbounded_String)
   is

      tmp         : resources_set;
      a_resource  : generic_resource_ptr;
      my_iterator : resources_iterator;

   begin
      if (get_number_of_elements (my_resources) > 0) then

         reset_iterator (my_resources, my_iterator);
         loop
            current_element (my_resources, a_resource, my_iterator);

            if (a_resource.address_space_name = a_addr) then
               add (tmp, a_resource);
            end if;

            exit when is_last_element (my_resources, my_iterator);
            next_element (my_resources, my_iterator);
         end loop;

         if not is_empty (tmp) then
            reset_iterator (tmp, my_iterator);
            loop
               current_element (tmp, a_resource, my_iterator);

               delete (my_resources, a_resource);

               exit when is_last_element (tmp, my_iterator);
               next_element (tmp, my_iterator);
            end loop;
         end if;

      end if;
   end delete_address_space;

   procedure delete_processor
     (my_resources : in out resources_set;
      a_processor  : in     Unbounded_String)
   is

      tmp         : resources_set;
      a_resource  : generic_resource_ptr;
      my_iterator : resources_iterator;

   begin

      if (get_number_of_elements (my_resources) > 0) then

         reset_iterator (my_resources, my_iterator);
         loop
            current_element (my_resources, a_resource, my_iterator);

            if (a_resource.cpu_name = a_processor) then
               add (tmp, a_resource);
            end if;

            exit when is_last_element (my_resources, my_iterator);
            next_element (my_resources, my_iterator);
         end loop;

         if not is_empty (tmp) then
            reset_iterator (tmp, my_iterator);
            loop
               current_element (tmp, a_resource, my_iterator);

               delete (my_resources, a_resource);

               exit when is_last_element (tmp, my_iterator);
               next_element (tmp, my_iterator);
            end loop;

            reset (tmp, False);
         end if;
      end if;

   end delete_processor;

   procedure same_protocol_control
     (my_resources : in resources_set;
      a_task       : in Unbounded_String)
   is

      a_protocol : resources_type;
      is_first   : Boolean := True;
      iterator1  : resources_iterator;
      resource1  : generic_resource_ptr;

   begin

      reset_iterator (my_resources, iterator1);

      loop
         current_element (my_resources, resource1, iterator1);

         -- Looking for task user in the task_list index_table
         --
         for i in 0 .. resource1.critical_sections.nb_entries - 1 loop
            if a_task = resource1.critical_sections.entries (i).item then
               if is_first then
                  is_first   := False;
                  a_protocol := resource1.protocol;
               else
                  if a_protocol /= resource1.protocol then
                     raise can_not_used_different_protocol;
                  end if;
               end if;
            end if;
         end loop;

         exit when is_last_element (my_resources, iterator1);
         next_element (my_resources, iterator1);

      end loop;

   end same_protocol_control;

   function export_aadl_implementations
     (my_resources : in resources_set) return Unbounded_String
   is
      my_iterator : resources_iterator;
      a_resource  : generic_resource_ptr;

      result : Unbounded_String := empty_string;

   begin

      if not is_empty (my_resources) then

         reset_iterator (my_resources, my_iterator);

         loop
            current_element (my_resources, a_resource, my_iterator);

            result :=
              result &
              To_Unbounded_String ("data " & To_String (a_resource.name)) &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String
                ("end " & To_String (a_resource.name) & ";") &
              unbounded_lf &
              unbounded_lf;

            result :=
              result &
              To_Unbounded_String
                ("data implementation " &
                 To_String (a_resource.name) &
                 ".Impl") &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String (ASCII.HT & "properties ") &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String
                (ASCII.HT &
                 ASCII.HT &
                 "Cheddar_Properties::Data_Concurrency_State => " &
                 a_resource.state'img &
                 ";") &
              unbounded_lf;
            result :=
              result &
              To_Unbounded_String
                (ASCII.HT &
                 ASCII.HT &
                 "Concurrency_Control_Protocol => " &
                 a_resource.protocol'img &
                 ";") &
              unbounded_lf;

            result :=
              result &
              To_Unbounded_String
                ("end " & To_String (a_resource.name) & ".Impl;") &
              unbounded_lf &
              unbounded_lf;

            exit when is_last_element (my_resources, my_iterator);

            next_element (my_resources, my_iterator);

         end loop;

      end if;

      return result;

   end export_aadl_implementations;

   function export_aadl_declarations
     (my_resources       : in resources_set;
      address_space_name :    Unbounded_String;
      number_of_ht       : in Natural) return Unbounded_String
   is
      my_iterator : resources_iterator;
      a_resource  : generic_resource_ptr;

      result : Unbounded_String := empty_string;

   begin

      if not is_empty (my_resources) then

         reset_iterator (my_resources, my_iterator);

         loop
            current_element (my_resources, a_resource, my_iterator);

            if a_resource.address_space_name = address_space_name then
               for i in 1 .. number_of_ht loop
                  result := result & ASCII.HT;
               end loop;
               result :=
                 result &
                 To_Unbounded_String
                   ("instancied_" &
                    To_String (a_resource.name) &
                    " : data " &
                    To_String (a_resource.name) &
                    ".Impl;") &
                 unbounded_lf;
            end if;

            exit when is_last_element (my_resources, my_iterator);

            next_element (my_resources, my_iterator);

         end loop;
      end if;

      return result;

   end export_aadl_declarations;

   function export_aadl_connections
     (my_resources : in resources_set;
      a_task_name  : in Unbounded_String;
      number_of_ht : in Natural) return Unbounded_String
   is
      my_iterator : resources_iterator;
      a_resource  : generic_resource_ptr;

      result : Unbounded_String := empty_string;

   begin
      if not is_empty (my_resources) then

         reset_iterator (my_resources, my_iterator);

         loop
            current_element (my_resources, a_resource, my_iterator);

            if a_resource.critical_sections.nb_entries /= 0 then
               for i in 0 .. a_resource.critical_sections.nb_entries - 1 loop
                  if a_resource.critical_sections.entries (i).item =
                    a_task_name
                  then
                     for j in 1 .. number_of_ht loop
                        result := result & ASCII.HT;
                     end loop;
                     result :=
                       result &
                       To_Unbounded_String
                         ("data access " &
                          To_String
                            ("instancied_" &
                             To_String (a_resource.name) &
                             " -> " &
                             "instancied_" &
                             a_task_name &
                             "." &
                             a_resource.name &
                             "_features") &
                          ";") &
                       unbounded_lf;
                  end if;
               end loop;
            end if;

            exit when is_last_element (my_resources, my_iterator);

            next_element (my_resources, my_iterator);

         end loop;
      end if;

      return result;

   end export_aadl_connections;

   function get_number_of_resource_from_processor
     (my_resources   : in resources_set;
      processor_name : in Unbounded_String) return resources_range
   is
      number      : resources_range := 0;
      a_resource  : generic_resource_ptr;
      my_iterator : iterator;

   begin

      if is_empty (my_resources) then
         return 0;
      end if;

      reset_iterator (my_resources, my_iterator);

      loop
         current_element (my_resources, a_resource, my_iterator);

         if (a_resource.cpu_name = processor_name) then
            number := number + 1;
         end if;

         exit when is_last_element (my_resources, my_iterator);

         next_element (my_resources, my_iterator);

      end loop;

      return number;
   end get_number_of_resource_from_processor;

   procedure check_entity_referencing_processor
     (my_resources : in resources_set;
      a_processor  : in Unbounded_String)
   is

      a_resource  : generic_resource_ptr;
      my_iterator : resources_iterator;

   begin
      if (get_number_of_elements (my_resources) > 0) then

         reset_iterator (my_resources, my_iterator);
         loop
            current_element (my_resources, a_resource, my_iterator);

            if (a_resource.cpu_name = a_processor) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_processor (Current_Language) &
                     " " &
                     a_processor &
                     " : " &
                     lb_resource (Current_Language) &
                     " " &
                     a_resource.name &
                     " : " &
                     lb_entity_referenced_elsewhere (Current_Language)));
            end if;

            exit when is_last_element (my_resources, my_iterator);
            next_element (my_resources, my_iterator);
         end loop;

      end if;
   end check_entity_referencing_processor;

   procedure check_entity_referencing_address_space
     (my_resources : in resources_set;
      a_addr       : in Unbounded_String)
   is

      a_resource  : generic_resource_ptr;
      my_iterator : resources_iterator;

   begin
      if (get_number_of_elements (my_resources) > 0) then

         reset_iterator (my_resources, my_iterator);
         loop
            current_element (my_resources, a_resource, my_iterator);

            if (a_resource.address_space_name = a_addr) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_address_space (Current_Language) &
                     " " &
                     a_addr &
                     " : " &
                     lb_resource (Current_Language) &
                     " " &
                     a_resource.name &
                     " : " &
                     lb_entity_referenced_elsewhere (Current_Language)));
            end if;

            exit when is_last_element (my_resources, my_iterator);
            next_element (my_resources, my_iterator);
         end loop;

      end if;
   end check_entity_referencing_address_space;

   procedure check_entity_referencing_task
     (my_resources : in resources_set;
      a_task       : in Unbounded_String)
   is

      a_resource  : generic_resource_ptr;
      my_iterator : resources_iterator;

   begin
      if (get_number_of_elements (my_resources) > 0) then

         reset_iterator (my_resources, my_iterator);
         loop
            current_element (my_resources, a_resource, my_iterator);

            for i in 0 .. a_resource.critical_sections.nb_entries - 1 loop
               if a_resource.critical_sections.entries (i).item = a_task then
                  Raise_Exception
                    (invalid_parameter'identity,
                     To_String
                       (lb_task (Current_Language) &
                        " " &
                        a_task &
                        " : " &
                        lb_resource (Current_Language) &
                        " " &
                        a_resource.name &
                        " : " &
                        lb_entity_referenced_elsewhere (Current_Language)));
               end if;
            end loop;

            exit when is_last_element (my_resources, my_iterator);
            next_element (my_resources, my_iterator);
         end loop;

      end if;
   end check_entity_referencing_task;

end resource_set;
