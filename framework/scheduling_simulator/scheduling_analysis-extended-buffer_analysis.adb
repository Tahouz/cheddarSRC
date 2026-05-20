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

with translate;  use translate;
with buffer_set; use buffer_set;
use buffer_set.generic_buffer_set;
with Resources; use Resources;

package body Scheduling_Analysis.extended.buffer_analysis is

   function compute_average_buffer_size_from_simulation
     (buff : in buffer_size_table_ptr) return Double
   is
      sum : Double := 0.0;

   begin

      for i in 0 .. buff.nb_entries - 1 loop
         sum := sum + Double (buff.entries (i).size);
      end loop;

      if (buff.nb_entries > 0) then
         return sum / Double (buff.nb_entries);
      else
         return 0.0;
      end if;

   end compute_average_buffer_size_from_simulation;

   function compute_maximum_buffer_size_from_simulation
     (buff : in buffer_size_table_ptr) return Natural
   is
      max : Natural := 0;
   begin

      for i in 0 .. buff.nb_entries - 1 loop
         if buff.entries (i).size > max then
            max := buff.entries (i).size;
         end if;
      end loop;

      return max;

   end compute_maximum_buffer_size_from_simulation;

   procedure compute_buffer_size_from_simulation
     (sched   : in     scheduling_sequence_ptr;
      my_buff : in     buffer_ptr;
      buff    : in out buffer_size_table_ptr)
   is

      current_size : Natural := 0;
      a_buff_size  : buffer_size_item;

   begin

      for i in 0 .. sched.nb_entries - 1 loop

         if (sched.entries (i).data.type_of_event = read_from_buffer) then
            if (sched.entries (i).data.read_buffer.name = my_buff.name) then
               a_buff_size.time := sched.entries (i).item;

               -- If the requested number of data to read is higher
               -- than the buffer size, we read what we can and size
               -- becomes zero
               --
               if (current_size < sched.entries (i).data.read_size) then
                  current_size := 0;
               else
                  current_size :=
                    current_size - sched.entries (i).data.read_size;
               end if;
               a_buff_size.size := current_size;
               add (buff.all, a_buff_size);
            end if;
         end if;

         if (sched.entries (i).data.type_of_event = write_to_buffer) then
            if (sched.entries (i).data.write_buffer.name = my_buff.name) then
               a_buff_size.time := sched.entries (i).item;
               current_size     :=
                 current_size + sched.entries (i).data.write_size;
               a_buff_size.size := current_size;
               add (buff.all, a_buff_size);
            end if;
         end if;

      end loop;
   end compute_buffer_size_from_simulation;

   function compute_maximum_waiting_time_from_simulation
     (buff                    : in buffer_size_table_ptr;
      average_consumer_period : in Double) return Double
   is
      max : Double := 0.0;
   begin

      for i in 0 .. buff.nb_entries - 1 loop
         if Double (buff.entries (i).size) > max then
            max := Double (buff.entries (i).size);
         end if;
      end loop;

      return (max * average_consumer_period);

   end compute_maximum_waiting_time_from_simulation;

   function compute_average_waiting_time_from_simulation
     (buff                    : in buffer_size_table_ptr;
      average_consumer_period : in Double) return Double
   is
      sum : Double := 0.0;

   begin

      for i in 0 .. buff.nb_entries - 1 loop
         sum := sum + Double (buff.entries (i).size);
      end loop;

      if (buff.nb_entries > 0) and (average_consumer_period > 0.0) then
         return ((sum / Double (buff.nb_entries)) * average_consumer_period);
      else
         return 0.0;
      end if;

   end compute_average_waiting_time_from_simulation;

end Scheduling_Analysis.extended.buffer_analysis;
