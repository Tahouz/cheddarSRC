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

with Text_IO;             use Text_IO;
with translate;           use translate;
with unbounded_strings;   use unbounded_strings;
with scheduler;           use scheduler;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with Tasks; use Tasks;
use Tasks.Generic_Task_List_Package;
with task_set;          use task_set;
with Offsets;           use Offsets;
with Offsets.extended;  use Offsets.extended;
with task_dependencies; use task_dependencies;
with Dependencies;      use Dependencies;

package body feasibility_test.generated_c2 is

   function processor_utilization_over_period_c2
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Double
   is
      taski       : generic_task_ptr;
      my_iterator : tasks_iterator;
      calcul      : Double := 0.0;
   begin
      periodic_control (my_tasks, processor_name);
      reset_iterator (my_tasks, my_iterator);
      loop
         current_element (my_tasks, taski, my_iterator);
         if (taski.task_type /= aperiodic_type) then
            calcul :=
              calcul +
              (Double (taski.capacity) /
               Double (periodic_task_ptr (taski).period));
         end if;
         exit when is_last_element (my_tasks, my_iterator);
         next_element (my_tasks, my_iterator);
      end loop;
      return calcul;
   end processor_utilization_over_period_c2;
   function compute_less_c2
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Boolean
   is
      rightvalue, leftvalue : Double;
   begin
      leftvalue :=
        processor_utilization_over_period_c2
          (my_tasks,
           To_Unbounded_String ("CPU_A"));
      rightvalue := 1.0;
      if leftvalue < rightvalue then
         return True;
      else
         return False;
      end if;
   end compute_less_c2;
end feasibility_test.generated_c2;
