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
with Caches;               use Caches;
with Objects;              use Objects;
with Objects.extended;     use Objects.extended;
with Text_IO;              use Text_IO;
with translate;            use translate;
with sets;
with initialize_framework; use initialize_framework;
with Caches;               use Caches.Cache_Blocks_Table_Package;

package body cache_access_profile_set is
   ------------------------------------------------------
   -- CACHE ACCESS PROFILE
   ------------------------------------------------------
   procedure check_cache_access_profile
     (my_cache_access_profiles : in out cache_access_profiles_set;
      a_cache_access_profile   : in out cache_access_profile_ptr;
      name                     : in     Unbounded_String;
      ucbs                     : in     cache_blocks_table;
      ecbs                     : in     cache_blocks_table)
   is
   begin
      if (name = "") then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cache_access_profile_name (Current_Language) &
               lb_mandatory (Current_Language)));
      end if;

      if not is_a_valid_identifier (name) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cache_access_profile (Current_Language) &
               name &
               " : " &
               lb_cache_access_profile_name (Current_Language) &
               lb_colon &
               lb_invalid_identifier (Current_Language)));
      end if;

      if (ecbs.nb_entries <= 0) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cache_access_profile (Current_Language) &
               name &
               " : " &
               lb_ecbs_nb_entries (Current_Language) &
               lb_must_be (Current_Language) &
               lb_greater_or_equal_than (Current_Language) &
               "0"));
      end if;

      if (ucbs.nb_entries > ecbs.nb_entries) then
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_cache_access_profile (Current_Language) &
               name &
               " : " &
               lb_ecbs_nb_entries (Current_Language) &
               lb_must_be (Current_Language) &
               lb_ucbs_nb_entries (Current_Language)));
      end if;

   end check_cache_access_profile;

   procedure add_cache_access_profile
     (my_cache_access_profiles : in out cache_access_profiles_set;
      a_cache_access_profile   : in out cache_access_profile_ptr;
      name                     : in     Unbounded_String;
      ucbs                     : in     cache_blocks_table;
      ecbs                     : in     cache_blocks_table)
   is
      my_iterator : cache_access_profiles_iterator;
   begin
      check_initialize;

      check_cache_access_profile
        (my_cache_access_profiles => my_cache_access_profiles,
         a_cache_access_profile   => a_cache_access_profile,
         name                     => name,
         ucbs                     => ucbs,
         ecbs                     => ecbs);

      if (get_number_of_elements (my_cache_access_profiles) > 0) then
         reset_iterator (my_cache_access_profiles, my_iterator);
         loop
            current_element
              (my_cache_access_profiles,
               a_cache_access_profile,
               my_iterator);
            if (name = a_cache_access_profile.name) then
               Raise_Exception
                 (invalid_parameter'identity,
                  To_String
                    (lb_cache_access_profile (Current_Language) &
                     " " &
                     name &
                     " : " &
                     lb_cache_access_profile_name (Current_Language) &
                     lb_already_defined (Current_Language)));
            end if;
            exit when is_last_element (my_cache_access_profiles, my_iterator);
            next_element (my_cache_access_profiles, my_iterator);
         end loop;
      end if;

      a_cache_access_profile      := new cache_access_profile;
      a_cache_access_profile.name := name;
      a_cache_access_profile.UCBs := ucbs;
      a_cache_access_profile.ECBs := ecbs;

      add (my_cache_access_profiles, a_cache_access_profile);

   exception
      when cache_access_profile_set.full_set =>
         Raise_Exception
           (invalid_parameter'identity,
            To_String
              (lb_can_not_define_more_cache_access_profiles
                 (Current_Language)));
   end add_cache_access_profile;

   procedure add_cache_access_profile
     (my_cache_access_profiles : in out cache_access_profiles_set;
      name                     : in     Unbounded_String;
      ucbs                     : in     cache_blocks_table;
      ecbs                     : in     cache_blocks_table)
   is
      a_cache_access_profile : cache_access_profile_ptr;
   begin
      add_cache_access_profile
        (my_cache_access_profiles => my_cache_access_profiles,
         a_cache_access_profile   => a_cache_access_profile,
         name                     => name,
         ucbs                     => ucbs,
         ecbs                     => ecbs);

   end add_cache_access_profile;

   procedure update_cache_access_profile
     (my_cache_access_profiles : in out cache_access_profiles_set;
      name                     : in     Unbounded_String;
      ucbs                     : in     cache_blocks_table;
      ecbs                     : in     cache_blocks_table)
   is
      a_cache_access_profile : cache_access_profile_ptr;
   begin
      check_cache_access_profile
        (my_cache_access_profiles => my_cache_access_profiles,
         a_cache_access_profile   => a_cache_access_profile,
         name                     => name,
         ucbs                     => ucbs,
         ecbs                     => ecbs);

      a_cache_access_profile :=
        search_cache_access_profile (my_cache_access_profiles, name);

      delete (my_cache_access_profiles, a_cache_access_profile);

      add_cache_access_profile
        (my_cache_access_profiles => my_cache_access_profiles,
         a_cache_access_profile   => a_cache_access_profile,
         name                     => name,
         ucbs                     => ucbs,
         ecbs                     => ecbs);
   end update_cache_access_profile;

   procedure delete_cache_access_profile
     (my_cache_access_profiles : in out cache_access_profiles_set;
      name                     : in     Unbounded_String)
   is
      a_cache_access_profile : cache_access_profile_ptr;
   begin
      a_cache_access_profile :=
        search_cache_access_profile (my_cache_access_profiles, name);
      delete (my_cache_access_profiles, a_cache_access_profile);
   end delete_cache_access_profile;

   function search_cache_access_profile
     (my_cache_access_profiles : in cache_access_profiles_set;
      name : in Unbounded_String) return cache_access_profile_ptr
   is
      my_iterator            : cache_access_profiles_iterator;
      a_cache_access_profile : cache_access_profile_ptr;
      result                 : cache_access_profile_ptr;
      found                  : Boolean := False;
   begin

      if not is_empty (my_cache_access_profiles) then

         reset_iterator (my_cache_access_profiles, my_iterator);

         loop
            current_element
              (my_cache_access_profiles,
               a_cache_access_profile,
               my_iterator);
            if (a_cache_access_profile.name = name) then
               found  := True;
               result := a_cache_access_profile;
            end if;

            exit when is_last_element (my_cache_access_profiles, my_iterator);

            next_element (my_cache_access_profiles, my_iterator);
         end loop;

      end if;

      if not found then
         Raise_Exception
           (cache_access_profile_not_found'identity,
            To_String
              (lb_cache_access_profile (Current_Language) & "=" & name));
      end if;

      return result;
   end search_cache_access_profile;

end cache_access_profile_set;
