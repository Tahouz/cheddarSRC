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

with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Text_IO;                   use Text_IO;

with Tasks;                     use Tasks;
with Doubles;                   use Doubles;
with task_set;                  use task_set;
use task_set.generic_task_set;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with buffer_set;                use buffer_set;
use buffer_set.generic_buffer_set;
with Processors;                use Processors;
with random_tools;              use random_tools;
with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;
with Buffers;                   use Buffers;
use Buffers.Buffer_Roles_Package;
with fixed_strings;             use fixed_strings;
with natural_util;              use natural_util;
with double_util;               use double_util;

with Ada.Sequential_IO;

package body random_scheduling is

   -- display an array of respone time table
   procedure put
     (res_time_set    : in response_table_set;
      nb_res_time_set : in Natural)
   is

   begin
      for J in 1 .. nb_res_time_set loop
         for I in 0 .. res_time_set (J).nb_entries - 1 loop
            Put_Line
              ("Task " &
               To_String (res_time_set (J).entries (I).item.name) &
               ", r = " &
               res_time_set (J).entries (I).data'img);
         end loop;
      end loop;
   end put;

   procedure random_buff_size_plot
     (nb_rand_scheduling : Natural;
      nb_base_period     : Natural;
      save_response      : Boolean;
      save_buff_response : Natural;
      save_file_name     : Unbounded_String;
      sys                : system)
   is

      type save_descriptor is record
         Task_Name : fixed_string;
         Eol1      : Character := ASCII.LF;
         Resp_Time : fixed_string;
         Deadline  : fixed_string;
         Buff_Size : fixed_string;
      end record;

      package Save_File is new Ada.Sequential_IO (save_descriptor);
      use Save_File;

      -- types
      type natural_tab is array (tasks_range range <>) of Natural;
      type natural_tab_ptr is access natural_tab;

      -- variables
      A_Buffer         : buffer_ptr;
      A_Task           : generic_task_ptr;
      A_Processor      : generic_processor_ptr;
      My_Iterator_Task : tasks_iterator;
      My_Iterator_Buf  : buffers_iterator;
      My_Iterator_Proc : processors_iterator;
      Res_Time         : response_time_table;
      -- array of random response time
      Buff_Size       : Natural;             -- size of the buffer
      Seed            : Generator;
      I_Min_Resp_Time : response_time_range;
      Cnt_Final       : natural_tab_ptr;
      -- array of the maximum number of response time generation
      Continu       : Boolean;
      Max_Buff_Size : Natural;
      Buff_Bound    : constant Natural := 0;
      -- maximum size of the buffer
      Lcm               : Natural;             -- study period
      Min_Resp          : Natural;
      Max_Resp          : Natural;
      Nb_Max_Activation : Natural;
      Nb_Tasks          : tasks_range;
      L                 : tasks_range;
      K                 : response_time_range;
      F_Desc            : Save_File.file_type;
      Desc              : save_descriptor;
      File_Name         : Unbounded_String;
      Cnt_File          : Natural;

      -- return the index of the minimum response time
      function Min_Res_Time
        (Min : in response_time_table) return response_time_range
      is
         Minimum : response_time_range;
      begin
         Minimum := 0;
         for I in 1 .. (Min.nb_entries - 1) loop
            if (Min.entries (I).data < Min.entries (Minimum).data) then
               Minimum := I;
            end if;
         end loop;

         return Minimum;
      end Min_Res_Time;

   begin

      -- !!! INIT !!!

      -- control : one processor, one buffer and only producer and consumer

      reset_iterator (sys.processors, My_Iterator_Proc);
      current_element (sys.processors, A_Processor, My_Iterator_Proc);

      reset_iterator (sys.buffers, My_Iterator_Buf);
      current_element (sys.buffers, A_Buffer, My_Iterator_Buf);

      Lcm := scheduling_period (sys.tasks, A_Processor.name);

      K                   := 0;
      L                   := 0;
      Res_Time.nb_entries := 0;
      Nb_Tasks            :=
        get_number_of_task_from_processor (sys.tasks, A_Processor.name);
      Cnt_Final := new natural_tab (0 .. Nb_Tasks);
      reset_iterator (sys.tasks, My_Iterator_Task);
      loop
         -- take a task
         current_element (sys.tasks, A_Task, My_Iterator_Task);

         -- number of response time generation for each task
         Cnt_Final (L) :=
           Lcm /
           periodic_task_ptr (A_Task).period *
           nb_base_period *
           nb_rand_scheduling;

         -- intialization of the response time table
         Res_Time.entries (K).data := Double'last;
         Res_Time.entries (K).item := A_Task;
         Res_Time.nb_entries       := Res_Time.nb_entries + 1;

         -- display the information
         Put_Line
           ("#" &
            To_String (A_Task.name) &
            " P = " &
            periodic_task_ptr (A_Task).period'img &
            ", D = " &
            A_Task.deadline'img);

         -- next task
         L := L + 1;
         K := K + 1;
         exit when is_last_element (sys.tasks, My_Iterator_Task);
         next_element (sys.tasks, My_Iterator_Task);
      end loop;
      Reset (Seed);
      Cnt_File := 0;

      Put_Line ("# Buffer bound = " & Buff_Bound'img);

      -- plot the buffer size
      for T in 0 .. (nb_rand_scheduling - 1) loop

         -- init
         Buff_Size     := 0;
         Max_Buff_Size := 0;

         if (save_response) then
            File_Name :=
              save_file_name &
              To_Unbounded_String ("_") &
              format (Cnt_File) &
              To_Unbounded_String (".sav");
            -- Put_Line(File_name);
            Create (F_Desc, Mode => out_file, Name => To_String (File_Name));
         end if;

         -- start random response time generation
         Continu := True;
         while (Continu) loop

            Continu := False;
            -- if the buffer size doesn't change, stop the program
            K := 0;
            L := 0;

            reset_iterator (sys.tasks, My_Iterator_Task);
            loop
               -- take a task
               current_element (sys.tasks, A_Task, My_Iterator_Task);

               -- number maximum of activation during base period
               Nb_Max_Activation :=
                 Lcm / periodic_task_ptr (A_Task).period * nb_base_period;

               -- generate a response time if needed
               if
                 (Res_Time.entries (K).data = Double'last and
                  Cnt_Final (L) >
                    (nb_rand_scheduling - T - 1) * Nb_Max_Activation)
               then
                  Min_Resp :=
                    (Nb_Max_Activation * (nb_rand_scheduling - T) -
                     Cnt_Final (L)) *
                    periodic_task_ptr (A_Task).period;
                  Max_Resp := Min_Resp + A_Task.deadline - 1;

                  Res_Time.entries (K).data :=
                    Double (get_rand_parameter (Min_Resp, Max_Resp, Seed));
                  Cnt_Final (L) := Cnt_Final (L) - 1;

                  -- save data
                  if (save_response) then
                     Desc.Task_Name :=
                       To_Bounded_String (To_String (A_Task.name));
                     Desc.Resp_Time :=
                       To_Bounded_String
                         (To_String (format (Res_Time.entries (K).data)));
                     Desc.Deadline :=
                       To_Bounded_String
                         (To_String (To_Unbounded_String (Max_Resp'img)));
                     Desc.Buff_Size :=
                       To_Bounded_String
                         (To_String (To_Unbounded_String (Buff_Size'img)));

                     -- save the tasks response time in a file for further
                     --studies
                     Write (F_Desc, Desc);
                  end if;

               end if;

               -- next task
               L := L + 1;
               K := K + 1;
               exit when is_last_element (sys.tasks, My_Iterator_Task);
               next_element (sys.tasks, My_Iterator_Task);
            end loop;

            -- find the minimum response time
            I_Min_Resp_Time := Min_Res_Time (Res_Time);

            -- the task
            A_Task := Res_Time.entries (I_Min_Resp_Time).item;

            -- Put_Line("min " & A_Task.Name & ", r=" &
            --Res_Time.Entries(I_Min_Resp_Time).Data'img);
            -- search for the type of the task which has the minimum response
            --time
            -- (if equalitie, worst case if consumption before production)
            for J in 0 .. buffer_roles_range (Nb_Tasks - 1) loop

               if (Res_Time.entries (I_Min_Resp_Time).data < Double'last) then

                  if (A_Buffer.roles.entries (J).item = A_Task.name) then
                     if
                       (A_Buffer.roles.entries (J).data.the_role =
                        queuing_consumer)
                     then
                        if (Buff_Size > 0) then
                           Buff_Size := Buff_Size - 1;
                        end if;
                        Continu := True;
                        -- new response time generation
                        Res_Time.entries (I_Min_Resp_Time).data := Double'last;

                     -- Put_Line(To_Unbounded_String("Buffer size = ") &
                     --Buff_Size'img);
                     else
                        if
                          (A_Buffer.roles.entries (J).data.the_role =
                           queuing_producer)
                        then
                           Buff_Size := Buff_Size + 1;

                           if (Buff_Size > Max_Buff_Size) then
                              Max_Buff_Size := Buff_Size;
                           end if;
                           Continu := True;
                           -- new response time generation
                           Res_Time.entries (I_Min_Resp_Time).data :=
                             Double'last;
                           -- Put_Line(To_Unbounded_String("Buffer size = ") &
                           --Buff_Size'img);
                        end if;
                     end if;
                  end if;
               end if;
            end loop; -- end for

            -- Put_Line(To_Unbounded_String("Buffer size = ") & Buff_Size'img);

         end loop; -- end while
         -- Put_Line("Maximum buffer size = " & Max_Buff_Size'img);

         if (Max_Buff_Size >= save_buff_response) then
            Cnt_File := Cnt_File + 1;

         end if;
         if (Max_Buff_Size > Buff_Bound) then
            Put_Line
              ("# WARNING !!! max occupation = " &
               Max_Buff_Size'img &
               "Bound = " &
               Buff_Bound'img);
         end if;
         if (save_response) then
            Close (F_Desc); -- close the old file
         end if;

         -- use with gnuplot
         Put_Line (T'img & " " & Max_Buff_Size'img);

      end loop; -- end for nb tasks set generation

   end random_buff_size_plot;

end random_scheduling;
