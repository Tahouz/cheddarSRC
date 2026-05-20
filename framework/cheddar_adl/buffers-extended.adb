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

with Tasks;            use Tasks;
with time_unit_events; use time_unit_events;
with time_unit_events; use time_unit_events.time_unit_package;
with double_util;      use double_util;
with debug;            use debug;
with Ada.Strings.Fixed;
with GNAT.String_Split;

package body Buffers.extended is

   procedure buffer_flow_control
     (my_buff   : in     buffer_ptr;
      my_tasks  : in     tasks_set;
      flow_cons : in out Double;
      flow_prod : in out Double)
   is

      a_task : generic_task_ptr;

   begin
      --init
      flow_prod := 0.0;
      flow_cons := 0.0;

      -- compute data flow
      for i in 0 .. (my_buff.roles.nb_entries - 1) loop

         -- compute producers data flow
         if (my_buff.roles.entries (i).data.the_role = queuing_producer) then
            a_task := search_task (my_tasks, my_buff.roles.entries (i).item);

            case a_task.task_type is
               when periodic_type =>
                  flow_prod :=
                    flow_prod +
                    Double (my_buff.roles.entries (i).data.size) /
                      Double (periodic_task_ptr (a_task).period);

               when poisson_type =>
                  flow_prod :=
                    flow_prod +
                    Double (my_buff.roles.entries (i).data.size) /
                      Double (poisson_task_ptr (a_task).period);
               when others =>
                  raise flow_constraint_not_respected;
            end case;

         end if;

         -- Compute consumers data flow
         --
         if (my_buff.roles.entries (i).data.the_role = queuing_consumer) then
            a_task := search_task (my_tasks, my_buff.roles.entries (i).item);

            case a_task.task_type is
               when periodic_type =>
                  flow_cons :=
                    flow_cons +
                    Double (my_buff.roles.entries (i).data.size) /
                      Double (periodic_task_ptr (a_task).period);
               when poisson_type =>
                  flow_cons :=
                    flow_cons +
                    Double (my_buff.roles.entries (i).data.size) /
                      Double (poisson_task_ptr (a_task).period);
               when others =>
                  raise flow_constraint_not_respected;
            end case;
         end if;

      end loop;

      if (not equal (flow_prod, flow_cons)) and (flow_prod > flow_cons) then
         raise flow_constraint_not_respected;
      end if;
   end buffer_flow_control;

   function is_cons_prod_harmonic
     (my_buff  : in buffer_ptr;
      my_tasks : in tasks_set) return Boolean
   is
      a_task1, a_task2 : generic_task_ptr;
      result           : Boolean := True;
      tmp_mod          : Natural;

   begin

      for i in 0 .. (my_buff.roles.nb_entries - 1) loop
         a_task1 := search_task (my_tasks, my_buff.roles.entries (i).item);
         for j in i .. (my_buff.roles.nb_entries - 1) loop
            a_task2 := search_task (my_tasks, my_buff.roles.entries (j).item);

            if a_task1.task_type = periodic_type then

               if
                 (periodic_task_ptr (a_task1).period >
                  periodic_task_ptr (a_task2).period)
               then
                  tmp_mod :=
                    periodic_task_ptr (a_task1).period mod
                    periodic_task_ptr (a_task2).period;
               else
                  tmp_mod :=
                    periodic_task_ptr (a_task2).period mod
                    periodic_task_ptr (a_task1).period;
               end if;

            else
               if a_task1.task_type = poisson_type then

                  if
                    (poisson_task_ptr (a_task1).period >
                     poisson_task_ptr (a_task2).period)
                  then
                     tmp_mod :=
                       poisson_task_ptr (a_task1).period mod
                       poisson_task_ptr (a_task2).period;
                  else
                     tmp_mod :=
                       poisson_task_ptr (a_task2).period mod
                       poisson_task_ptr (a_task1).period;
                  end if;
               end if;
            end if;

            if (tmp_mod /= 0) then
               result := False;
            end if;
         end loop;
      end loop;
      return result;
   end is_cons_prod_harmonic;

   function get_amplitude_function
     (str : in String) return amplitude_function_ptr
   is
      af_ptr : amplitude_function_ptr;
      u_part : Unbounded_String;
      v_part : Unbounded_String;

      subs : GNAT.String_Split.Slice_Set;
      sub  : Unbounded_String;
   begin
      GNAT.String_Split.Create
        (subs,
         str,
         "(",
         Mode => GNAT.String_Split.Multiple);

      u_part := To_Unbounded_String (GNAT.String_Split.Slice (subs, 1));
      v_part := To_Unbounded_String (GNAT.String_Split.Slice (subs, 2));
      v_part :=
        To_Unbounded_String
          (Ada.Strings.Fixed.Delete
             (Source  => To_String (v_part),
              From    => To_String (v_part)'length,
              Through => To_String (v_part)'length));
      af_ptr := new amplitude_function;
      initialize (af_ptr.u_array, To_String (u_part), "_");
      initialize (af_ptr.v_array, To_String (v_part), "_");
      return af_ptr;
   end get_amplitude_function;

   function get_data_size
     (amplitude_function_str : in String;
      activation_number      : in Integer) return Integer
   is
      data_size : Integer := 0;
      af_ptr    : amplitude_function_ptr;
      u_size    : Integer := 0;
      v_size    : Integer := 0;
      v_index   : Integer := 0;
   begin
      af_ptr := get_amplitude_function (amplitude_function_str);
      u_size := af_ptr.u_array.size;
      v_size := af_ptr.v_array.size;

      if (activation_number - 1 < u_size) then
         data_size := af_ptr.u_array.elements (activation_number - 1);
      else
         v_index   := (activation_number - 1 - u_size) mod v_size;
         data_size := af_ptr.v_array.elements (v_index);
      end if;

      put_debug
        ("Activation number: " &
         activation_number'img &
         " - Data size: " &
         data_size'img);
      return data_size;
   end get_data_size;

end Buffers.extended;
