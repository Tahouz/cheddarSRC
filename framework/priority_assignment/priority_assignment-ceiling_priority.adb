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

with Framework_Config; use Framework_Config;
with Tasks;            use Tasks;
with Resources;        use Resources;
with resource_set;     use resource_set;
use resource_set.generic_resource_set;
use Resources.Resource_Accesses;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Ceiling_Priority_Table_Package;

package body priority_assignment.ceiling_priority is

   procedure compute_ceiling_priority
     (my_tasks           : in out tasks_set;
      my_resources       : in out resources_set;
      processor_name     : in     Unbounded_String := empty_string;
      msg                : in out Unbounded_String;
      ceiling_priorities :    out ceiling_priority_table)
   is

      a_task                    : generic_task_ptr;
      a_resource                : generic_resource_ptr;
      my_iterator               : resources_iterator;
      a_priority_ceiling        : priority_range;
      a_ceiling_priority_record : ceiling_priority_record_ptr;

   begin
      if (get_number_of_elements (my_resources) > 0) then

         reset_iterator (my_resources, my_iterator);
         loop
            current_element (my_resources, a_resource, my_iterator);

            a_priority_ceiling := priority_range'first;
            for i in 0 .. a_resource.critical_sections.nb_entries - 1 loop
               a_task :=
                 search_task
                   (my_tasks,
                    a_resource.critical_sections.entries (i).item);
               a_priority_ceiling :=
                 priority_range'max (a_task.priority, a_priority_ceiling);
            end loop;

            a_ceiling_priority_record := new ceiling_priority_record;
            a_ceiling_priority_record.resource_name    := a_resource.name;
            a_ceiling_priority_record.ceiling_priority := a_priority_ceiling;
            add (ceiling_priorities, a_ceiling_priority_record);

            exit when is_last_element (my_resources, my_iterator);
            next_element (my_resources, my_iterator);
         end loop;

      end if;

   end compute_ceiling_priority;

end priority_assignment.ceiling_priority;
