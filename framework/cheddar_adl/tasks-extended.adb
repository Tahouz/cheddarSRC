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

package body Tasks.extended is

   procedure put (my_task_occurence : in task_occurence) is

   begin

      Put ("Arrival_time : " & my_task_occurence.arrival_time'img & " ; ");
      Put ("Absolute_Deadline : " & my_task_occurence.absolute_deadline'img);
      Put ("Response_Time : " & my_task_occurence.response_time'img);
   end put;

   procedure initialize
     (my_task_occurence : in out task_occurence;
      a_task            : in     generic_task_ptr;
      arrival_time      : in     Natural := 0)
   is
   begin
      my_task_occurence.analyzed_task     := a_task;
      my_task_occurence.arrival_time      := arrival_time;
      my_task_occurence.completion_time   := 0;
      my_task_occurence.absolute_deadline :=
        my_task_occurence.arrival_time + a_task.deadline;

   end initialize;

   function xml_ref_string (e : in task_occurence) return Unbounded_String is
   begin
      raise xml_ref_string_error;
      return To_Unbounded_String ("");
   end xml_ref_string;

   function xml_string (e : in task_occurence) return Unbounded_String is
   begin
      raise xml_string_error;
      return To_Unbounded_String ("");
   end xml_string;

   function copy (obj : in extended_periodic_task) return generic_task_ptr is
      new_extended_periodic_task : extended_periodic_task_ptr;
   begin
      new_extended_periodic_task := new extended_periodic_task'(obj);
      return generic_task_ptr (new_extended_periodic_task);
   end copy;

   function copy
     (obj : in extended_periodic_task_ptr) return generic_task_ptr
   is
   begin
      return copy (obj.all);
   end copy;

end Tasks.extended;
