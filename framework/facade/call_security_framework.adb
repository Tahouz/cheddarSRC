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
--    $Rev: 4714 $
--    $Date: 2023-12-18 00:07:26 +0100 (lun., 18 déc. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with GNAT.Current_Exception; use GNAT.Current_Exception;
with Text_IO;                use Text_IO;

with Doubles;           use Doubles;
with task_set;          use task_set;
with unbounded_strings; use unbounded_strings;
with xml_tag;           use xml_tag;
with double_util;       use double_util;
with translate;         use translate;
with Framework_Config;  use Framework_Config;
with mils_analysis;     use mils_analysis;
with debug;             use debug;
with task_dependencies; use task_dependencies;
use task_dependencies.half_dep_set;
with Dependencies; use Dependencies;

package body call_security_framework is

   procedure compute_mils_security_biba
     (sys    : in System; result : in out Unbounded_String;
      output : in Output_Format := String_Output)
   is

      violation   : tasks_dependencies_ptr;
      number      : Integer := 0;
      my_iterator : tasks_dependencies_iterator;
      a_half_dep  : dependency_ptr;

   begin

      put_debug ("Call Compute_MILS_security_biba");

      result := empty_string;

      violation := biba (sys);
      if (violation /= null) then
         number := Integer (get_number_of_elements (violation.depends));
      end if;

      result :=
        To_Unbounded_String ("- Biba analysis has detected ") & number'Img;

      if (number > 1) then
         result :=
           result & To_Unbounded_String (" violations in the model [25] :") &
           unbounded_lf;

         reset_iterator (violation.depends, my_iterator);

         loop
            current_element (violation.depends, a_half_dep, my_iterator);

            if a_half_dep.type_of_dependency = precedence_dependency then
               result :=
                 result & "   " & a_half_dep.precedence_source.name & "=>" &
                 a_half_dep.precedence_sink.name & ASCII.LF;
            end if;

            exit when is_last_element (violation.depends, my_iterator);

            next_element (violation.depends, my_iterator);
         end loop;

      else
         result :=
           result & To_Unbounded_String (" violation in the model [25].") &
           unbounded_lf;
      end if;

   end compute_mils_security_biba;

   procedure compute_mils_security_bell_lapadula
     (sys    : in System; result : in out Unbounded_String;
      output : in Output_Format := String_Output)
   is

      violation   : tasks_dependencies_ptr;
      number      : Integer := 0;
      my_iterator : tasks_dependencies_iterator;
      a_half_dep  : dependency_ptr;

   begin

      put_debug ("Call Compute_MILS_security_bel_lapadula");

      result := empty_string;

      violation := bell_lapadula (sys);
      if (violation /= null) then
         number := Integer (get_number_of_elements (violation.depends));
      end if;

      result :=
        To_Unbounded_String ("- Bell/La Padula analysis has detected ") &
        number'Img;

      if (number > 1) then
         result :=
           result & To_Unbounded_String (" violations in the model [24] :") &
           unbounded_lf;

         reset_iterator (violation.depends, my_iterator);

         loop
            current_element (violation.depends, a_half_dep, my_iterator);

            if a_half_dep.type_of_dependency = precedence_dependency then
               result :=
                 result & "   " & a_half_dep.precedence_source.name & "=>" &
                 a_half_dep.precedence_sink.name & ASCII.LF;
            end if;

            exit when is_last_element (violation.depends, my_iterator);

            next_element (violation.depends, my_iterator);
         end loop;

      else
         result :=
           result & To_Unbounded_String (" violation in the model [24].") &
           unbounded_lf;
      end if;

   end compute_mils_security_bell_lapadula;

   procedure compute_mils_security_chinese_wall
     (sys    : in System; result : in out Unbounded_String;
      output : in Output_Format := String_Output)
   is
   begin
      null;
   end compute_mils_security_chinese_wall;

   procedure compute_mils_security_warshall
     (sys    : in System; result : in out Unbounded_String;
      output : in Output_Format := String_Output)
   is
   begin
      null;
   end compute_mils_security_warshall;

end call_security_framework;
