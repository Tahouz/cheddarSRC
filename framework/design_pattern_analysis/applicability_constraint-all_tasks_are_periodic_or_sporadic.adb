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

with Ada.IO_Exceptions;      use Ada.IO_Exceptions;
with GNAT.Current_Exception; use GNAT.Current_Exception;
with unbounded_strings;      use unbounded_strings;
with GNAT.Command_Line;      use GNAT.Command_Line;
with GNAT.OS_Lib;            use GNAT.OS_Lib;
with Text_IO;                use Text_IO;
with version;                use version;
with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;
with systems;                use systems;
with task_set;               use task_set;
use task_set.generic_task_set;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with address_space_set; use address_space_set;
use address_space_set.generic_address_space_set;
with resource_set; use resource_set;
use resource_set.generic_resource_set;
with buffer_set; use buffer_set;
use buffer_set.generic_buffer_set;
with call_framework;    use call_framework;
with Tasks;             use Tasks;
with unbounded_strings; use unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
with translate; use translate;

package body applicability_constraint.all_tasks_are_periodic_or_sporadic is

   --Beginning of first unvariant part
   function type_of (t : generic_task_ptr) return unbounded_string_list is
      list : unbounded_string_list;
      type elem_ptrs_range is range 1 .. 100;
      type unbounded_string_ptr_array is
        array (elem_ptrs_range) of unbounded_string_ptr;
      elem_ptrs : unbounded_string_ptr_array;
      i         : elem_ptrs_range := 1;
   begin
      initialize (list);
      --End of first unvariant part
      --For each entity's types and subtypes add :
      --the only part to modify is the to_unbounded_string(S:String) parameter
      elem_ptrs (i)     := new Unbounded_String;
      elem_ptrs (i).all := To_Unbounded_String ("OBJECTS.GENERIC_OBJECT");
      add (list, elem_ptrs (i));
      i := i + 1;

      elem_ptrs (i)     := new Unbounded_String;
      elem_ptrs (i).all := To_Unbounded_String ("TASKS.GENERIC_TASK");
      add (list, elem_ptrs (i));
      i := i + 1;

      elem_ptrs (i) := new Unbounded_String;

      case t.task_type is
         when periodic_type =>
            elem_ptrs (i).all := To_Unbounded_String ("TASKS.PERIODIC_TASK");
         when timed_type =>
            elem_ptrs (i).all := To_Unbounded_String ("TASKS.TIMED_TASK");
         when aperiodic_type =>
            elem_ptrs (i).all := To_Unbounded_String ("TASKS.APERIODIC_TASK");
         when sporadic_type =>
            elem_ptrs (i).all := To_Unbounded_String ("TASKS.SPORADIC_TASK");
         when sporadic_inner_periodic_type =>
            elem_ptrs (i).all :=
              To_Unbounded_String ("TASKS.SPORADIC_INNER_PERIODIC_TASK");
         when periodic_inner_periodic_type =>
            elem_ptrs (i).all :=
              To_Unbounded_String ("TASKS.PERIODIC_INNER_PERIODIC_TASK");
         when poisson_type =>
            elem_ptrs (i).all := To_Unbounded_String ("TASKS.POISSON_TASK");
         when scheduling_task_type =>
            elem_ptrs (i).all := To_Unbounded_String ("TASKS.SCHEDULING_TASK");
         when parametric_type =>
            elem_ptrs (i).all := To_Unbounded_String ("TASKS.PARAMETRIC_TASK");
         when frame_task_type =>
            null;
      end case;
      add (list, elem_ptrs (i));
      --Beginning of second unvariant part
      return list;
   end type_of;
   --End of second unvariant part

   function r8_query1_condition (t : generic_task_ptr) return Boolean is
   begin

      return not
        ((element_in_list
            (To_Unbounded_String ("TASKS.PERIODIC_TASK"),
             type_of (t))) or
         (element_in_list
            (To_Unbounded_String ("TASKS.SPORADIC_TASK"),
             type_of (t))));

   end r8_query1_condition;

   function r8 (sys : system) return Boolean is
   begin
      context := sys;
      return
        (get_number_of_elements
           (select_and_copy (sys.tasks, r8_query1_condition'access)) =
         generic_task_set.element_range (0));

   end r8;

   function r8_txt return Unbounded_String is
   begin

      return ("The constraint R8 is not met:") &
        unbounded_lf &
        ("tasks must be periodic or sporadic.") &
        unbounded_lf;

   end r8_txt;

end applicability_constraint.all_tasks_are_periodic_or_sporadic;
