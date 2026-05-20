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

with Ada.Exceptions;   use Ada.Exceptions;
with Objects.extended; use Objects.extended;
with translate;        use translate;
with Framework_Config; use Framework_Config;

package body Parameters.extended is

   procedure check_parameters
     (param          : in user_defined_parameters_table;
      component_name :    Unbounded_String)
   is

   begin
      for i in 0 .. param.nb_entries - 1 loop

         if param.entries (i).parameter_name = "" then
            Raise_Exception
              (invalid_parameter'identity,
               To_String
                 (component_name &
                  " : " &
                  lb_user_defined_parameter (Current_Language) &
                  " " &
                  lb_name (Current_Language) &
                  " " &
                  lb_mandatory (Current_Language)));
         end if;

         if not is_a_valid_identifier (param.entries (i).parameter_name) then
            Raise_Exception
              (invalid_parameter'identity,
               To_String
                 (component_name &
                  " : " &
                  lb_user_defined_parameter (Current_Language) &
                  " " &
                  lb_name (Current_Language) &
                  lb_colon &
                  lb_invalid_identifier (Current_Language)));
         end if;

      end loop;

   end check_parameters;

end Parameters.extended;
