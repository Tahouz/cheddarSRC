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
with processor_set;          use processor_set;
with address_space_set;      use address_space_set;
with resource_set;           use resource_set;
with buffer_set;             use buffer_set;
with call_framework;         use call_framework;
with Tasks;                  use Tasks;
with debug;                  use debug;
use task_set.generic_task_set;

package body applicability_constraint.period_equal_deadline_constraint is

   function apply_query1_condition (t1 : generic_task_ptr) return Boolean is
   begin

      return (t1.task_type = periodic_type);

   end apply_query1_condition;

   function apply_query3_condition (t3 : generic_task_ptr) return Boolean is
   begin

      return (t3.task_type = periodic_type);

   end apply_query3_condition;

   function apply_query2_condition (t2 : generic_task_ptr) return Boolean is
      ptr : periodic_task_ptr;
   begin
      ptr := periodic_task_ptr (t2);
      return (t2.task_type = periodic_type) and
        (not (ptr.period = ptr.deadline));

   end apply_query2_condition;

   function apply (sys : system) return Boolean is
   begin
      context := sys;

      return
        (task_set.get_number_of_elements
           (select_and_copy (context.tasks, apply_query1_condition'access)) <
         tasks_range (2)) or
        (get_number_of_elements
           (select_and_copy
              ((select_and_copy
                  (context.tasks,
                   apply_query3_condition'access)),
               apply_query2_condition'access)) =
         tasks_range (0));

   end apply;

end applicability_constraint.period_equal_deadline_constraint;
