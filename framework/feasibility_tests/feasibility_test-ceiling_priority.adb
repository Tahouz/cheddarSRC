
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

package body feasibility_test.ceiling_priority is 


 procedure Compute_Ceiling_Of_Resources
     (My_Scheduler       : in Fixed_Priority_Scheduler;
      Processor_Name     : in Unbounded_String;
      My_Tasks           : in out Tasks_Set;
      My_Resources       : in out Resources_Set;
      Msg            : in out Unbounded_String;
      Blocking_Time  : out Blocking_Time_Table)
   is

   begin

      -- Set priority ceiling of resources : only for PCP and IPCP resources and
      -- only if Automatic_Assignment is requested
      --
      for K in 0 .. Si.Number_Of_Resources - 1 loop

         if (Si.Shared_Resources (K).Shared.protocol =
             Priority_Ceiling_Protocol) or
            (Si.Shared_Resources (K).Shared.protocol =
             Immediate_Priority_Ceiling_Protocol)
         then
       if si.shared_resources(k).shared.priority_assignment = manual_assignment
            then
               Fixed_Priority_Resource_Ptr (Si.Shared_Resources (K)).
                 Priority_Ceiling := si.shared_resources(k).shared.Priority;

                else

               Fixed_Priority_Resource_Ptr (Si.Shared_Resources (K)).
                 Priority_Ceiling := Priority_Range'First;

               for I in 0 ..  Si.Shared_Resources (K).Shared.critical_sections.nb_entries - 1 loop
                  for J in 0 .. Si.Number_Of_Tasks - 1 loop
                        if Si.Shared_Resources (K).Shared.critical_sections.entries (I).
                             item =
                           Si.Tcbs (J).Tsk.name
                        then
                           Fixed_Priority_Resource_Ptr (Si.Shared_Resources (K)
).Priority_Ceiling :=
                              Priority_Range'Max
                                (Fixed_Priority_Tcb_Ptr (Si.Tcbs (J)).
                             Current_Priority,
                                 Fixed_Priority_Resource_Ptr (
                             Si.Shared_Resources (K)).Priority_Ceiling);
                        end if;
                  end loop;
               end loop;
            end if;
       end if;
      end loop;

   end Compute_Ceiling_Of_Resources;


end feasibility_test.ceiling_priority;


