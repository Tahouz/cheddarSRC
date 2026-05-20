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

with Text_IO;           use Text_IO;
with Ada.Exceptions;    use Ada.Exceptions;
with unbounded_strings; use unbounded_strings;

package body Scheduler_Interface.extended is

   function export_aadl_properties
     (my_scheduler : in scheduling_parameters;
      number_of_ht : in Natural) return Unbounded_String
   is
      result : Unbounded_String := empty_string;

   begin

      for i in 1 .. number_of_ht loop
         result := result & ASCII.HT;
      end loop;

      result :=
        result &
        To_Unbounded_String
          ("Scheduling_Protocol => " & my_scheduler.scheduler_type'img & ";") &
        unbounded_lf;

      for i in 1 .. number_of_ht loop
         result := result & ASCII.HT;
      end loop;

      result :=
        result &
        To_Unbounded_String
          ("Cheddar_Properties::Scheduler_Quantum => " &
           my_scheduler.quantum'img &
           " ms ;") &
        unbounded_lf;

      for i in 1 .. number_of_ht loop
         result := result & ASCII.HT;
      end loop;

      if my_scheduler.preemptive_type = preemptive then
         result :=
           result &
           To_Unbounded_String
             ("Cheddar_Properties::Preemptive_Scheduler => True;") &
           unbounded_lf;
      else
         result :=
           result &
           To_Unbounded_String
             ("Cheddar_Properties::Preemptive_Scheduler => False;") &
           unbounded_lf;
      end if;

      for i in 1 .. number_of_ht loop
         result := result & ASCII.HT;
      end loop;

      result :=
        result &
        To_Unbounded_String
          ("Cheddar_Properties::Automaton_Name => """ &
           To_String (my_scheduler.automaton_name) &
           """;") &
        unbounded_lf;

      for i in 1 .. number_of_ht loop
         result := result & ASCII.HT;
      end loop;

      result :=
        result &
        To_Unbounded_String
          ("Cheddar_Properties::Source_Text => """ &
           To_String (my_scheduler.user_defined_scheduler_source_file_name) &
           """;") &
        unbounded_lf;

      return result;

   end export_aadl_properties;

end Scheduler_Interface.extended;
