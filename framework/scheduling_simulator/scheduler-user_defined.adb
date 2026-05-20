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

with translate;  use translate;
with Parameters; use Parameters;
use Parameters.User_Defined_Parameters_Table_Package;

package body scheduler.user_defined is

   procedure set_behavior_file_name
     (my_scheduler : in out user_defined_scheduler;
      to_set       : in     Unbounded_String)
   is
   begin
      my_scheduler.parameters.user_defined_scheduler_source_file_name :=
        to_set;
   end set_behavior_file_name;

   function get_behavior_file_name
     (my_scheduler : in user_defined_scheduler) return Unbounded_String
   is
   begin
      return my_scheduler.parameters.user_defined_scheduler_source_file_name;
   end get_behavior_file_name;

   procedure set_string_behavior
     (my_scheduler : in out user_defined_scheduler;
      to_set       : in     Unbounded_String)
   is
   begin
      my_scheduler.parameters.user_defined_scheduler_source := to_set;
   end set_string_behavior;

   function get_string_behavior
     (my_scheduler : in user_defined_scheduler) return Unbounded_String
   is
   begin
      return my_scheduler.parameters.user_defined_scheduler_source;
   end get_string_behavior;

   procedure check_before_scheduling
     (my_scheduler   : in user_defined_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String)
   is

   begin
      null;
   end check_before_scheduling;

end scheduler.user_defined;
