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

with unbounded_strings; use unbounded_strings;

package scheduler.user_defined is

   type user_defined_scheduler is abstract new generic_scheduler with private;
   type user_defined_scheduler_ptr is access all user_defined_scheduler'class;

   procedure check_before_scheduling
     (my_scheduler   : in user_defined_scheduler;
      my_tasks       : in tasks_set;
      processor_name : in Unbounded_String);

   procedure set_behavior_file_name
     (my_scheduler : in out user_defined_scheduler;
      to_set       : in     Unbounded_String);

   function get_behavior_file_name
     (my_scheduler : in user_defined_scheduler) return Unbounded_String;

   procedure set_string_behavior
     (my_scheduler : in out user_defined_scheduler;
      to_set       : in     Unbounded_String);

   function get_string_behavior
     (my_scheduler : in user_defined_scheduler) return Unbounded_String;

private

   type user_defined_scheduler is abstract new generic_scheduler with
   null record;

end scheduler.user_defined;
