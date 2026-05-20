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

with xml_tag;           use xml_tag;
with double_util;       use double_util;
with translate;         use translate;
with unbounded_strings; use unbounded_strings;
with Doubles;           use Doubles;

package body scheduler.dynamic_priority.llf is

   procedure initialize (a_scheduler : in out llf_scheduler) is
   begin
      reset (a_scheduler);
      a_scheduler.parameters.scheduler_type := least_laxity_first_protocol;
   end initialize;

   function copy
     (a_scheduler : in llf_scheduler) return generic_scheduler_ptr
   is
      ptr : llf_scheduler_ptr;

   begin

      ptr := new llf_scheduler;

      ptr.parameters         := a_scheduler.parameters;
      ptr.previously_elected := a_scheduler.previously_elected;

      return generic_scheduler_ptr (ptr);

   end copy;

   procedure do_election
     (my_scheduler       : in out llf_scheduler;
      si                 : in out scheduling_information;
      result             : in out scheduling_sequence_ptr;
      msg                : in out Unbounded_String;
      current_time       : in     Natural;
      processor_name     : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      core_name          : in     Unbounded_String;
      options            : in     scheduling_option;
      event_to_generate  : in     time_unit_event_type_boolean_table;
      elected            : in out tasks_range;
      no_task            : in out Boolean)

   is

      smallest_laxity : Natural     := Natural'last;
      laxity          : Natural;
      i               : tasks_range := 0;
      is_ready        : Boolean     := False;
   begin

      loop

         if not si.tcbs (i).already_run_at_current_time then
            if (si.tcbs (i).tsk.cpu_name = processor_name) then
               if check_core_assignment (my_scheduler, si.tcbs (i)) then

                  laxity :=
                    dynamic_priority_tcb_ptr (si.tcbs (i)).tsk.deadline -
                    si.tcbs (i).rest_of_capacity;

                  if (si.tcbs (i).wake_up_time <= current_time) and
                    (laxity < smallest_laxity) and
                    (si.tcbs (i).rest_of_capacity /= 0)
                  then

                     if options.with_resources then

                        check_resource
                          (my_scheduler,
                           si,
                           result,
                           current_time,
                           si.tcbs (i),
                           is_ready,
                           event_to_generate);

                     else
                        is_ready := True;
                     end if;

                     if is_ready then

                        check_jitter
                          (si.tcbs (i),
                           current_time,
                           si.tcbs (i).is_jitter_ready);
                        if (options.with_jitters = False) or
                          (si.tcbs (i).is_jitter_ready)
                        then

                           if (options.with_offsets = False) or
                             check_offset (si.tcbs (i), current_time)
                           then
                              if (options.with_precedencies = False) or
                                check_precedencies
                                  (si,
                                   current_time,
                                   si.tcbs (i))
                              then

                                 smallest_laxity := laxity;
                                 elected         := i;
                              end if;
                           end if;
                        end if;
                     end if;
                  end if;
               end if;
            end if;
         end if;

         i := i + 1;
         exit when si.tcbs (i) = null;
      end loop;

      if smallest_laxity = Natural'last then
         no_task := True;
      else
         no_task := False;
      end if;

   end do_election;

end scheduler.dynamic_priority.llf;
