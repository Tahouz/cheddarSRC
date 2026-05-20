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

package body scheduler.user_defined.generated is

   procedure run_priority_section
     (my_scheduler   : in out generated_user_defined_scheduler;
      si             : in out scheduling_information;
      current_time   : in     Natural;
      processor_name : in     Unbounded_String;
      msg            : in out Unbounded_String)
   is

   begin
      null;
   end run_priority_section;

   procedure run_start_section
     (my_scheduler   : in out generated_user_defined_scheduler;
      processor_name : in     Unbounded_String;
      msg            : in out Unbounded_String)
   is
   begin
      null;
   end run_start_section;

   procedure run_election_section
     (my_scheduler   : in out generated_user_defined_scheduler;
      si             : in out scheduling_information;
      current_time   : in     Natural;
      processor_name : in     Unbounded_String;
      options        : in     scheduling_option;
      elected        : in out tasks_range;
      no_task        : in out Boolean)
   is

   begin
      no_task := True;
   end run_election_section;

end scheduler.user_defined.generated;
