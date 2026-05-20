
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
--    $Rev: 3657 $
--    $Date: 2020-12-13 13:25:49 +0100 (dim., 13 déc. 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with GNAT.Command_Line;
with GNAT.OS_Lib;      use GNAT.OS_Lib;
with Text_IO;          use Text_IO;
with Ada.Exceptions;   use Ada.Exceptions;

with systems;  use systems;
with Tasks;    use Tasks;
with task_set; use task_set;
use task_set.generic_task_set;
with Dependencies;        use Dependencies;
with Parameters;          use Parameters;
with Parameters.extended; use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;
with framework;                use framework;
with call_framework;           use call_framework;
with Call_Framework_Interface; use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with call_scheduling_framework;         use call_scheduling_framework;
with multiprocessor_services;           use multiprocessor_services;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with Core_Units;          use Core_Units;
with Scheduler_Interface; use Scheduler_Interface;
with Processor_Interface; use Processor_Interface;
with Processors;          use Processors;
with processor_set;       use processor_set;
with task_dependencies;   use task_dependencies;
with Scheduler_Interface; use Scheduler_Interface;
with debug;            use debug;
with io_tools;         use io_tools;
with version;          use version;


package body voltage_scaling is

-- Init voltage scaling
   procedure dvfs_init_voltage_scaling
     (a_processor : in generic_processor_ptr)
   is
      processor_type : processors_type;
      a_core         : core_unit_ptr;
   begin
      processor_type := a_processor.processor_type;
      if (processor_type = monocore_type) then
         a_core := mono_core_processor_ptr (a_processor).core;
      else
         a_core := multi_cores_processor_ptr (a_processor).cores.entries (0);
      end if;

      scheduler_type := a_core.scheduling.scheduler_type;

-- reset global variable
      curr_freq           := 100;
      curr_time_task_exec := 0;

      if DVS_map_package.Is_Empty (DVS_map) = False then
         DVS_map_package.Clear (DVS_map);
      end if;

   end dvfs_init_voltage_scaling;

-- Select Frequency
   function select_frequency_static_voltage_scaling
     (my_tasks : dvs_map_subtype) return Double
   is

      resEDF    : Boolean;
      resRM     : Boolean;
      res       : Double;
      pi        : Natural;
      my_Cursor : DVS_map_package.cursor;

   begin
--init
      pi     := 0;
      resEDF := False;
      res    := -1.0;

--Début algo select
      my_Cursor := DVS_map_package.First (my_tasks);
      while DVS_map_package.Has_Element (my_Cursor) loop
         if pi <
           periodic_task_ptr (DVS_map_package.Element (my_Cursor).a_task)
             .period
         then
            pi :=
              periodic_task_ptr (DVS_map_package.Element (my_Cursor).a_task)
                .period;
         end if;
         DVS_map_package.Next (my_Cursor);
      end loop;

      if scheduler_type = earliest_deadline_first_protocol then
         for i in freqs'first .. freqs'last loop
            resEDF :=
              EDF_test_static_voltage_scaling
                (my_tasks,
                 freqs (i) / freqs (freqs'last));
            res := freqs (i);
            if resEDF then
               res := freqs (i);
            end if;
            exit when resEDF;
         end loop;
      else
         if scheduler_type = rate_monotonic_protocol then
            for i in freqs'first .. freqs'last loop
               resRM :=
                 RM_test_static_voltage_scaling
                   (my_tasks,
                    freqs (i) / freqs (freqs'last),
                    pi);
               res := freqs (i);
               if resRM then
                  res := freqs (i);
               end if;
               exit when resRM;
            end loop;
         end if;
      end if;
      return res;
   end select_frequency_static_voltage_scaling;

-- EDF
   function EDF_test_static_voltage_scaling
     (my_tasks : dvs_map_subtype;
      freq     : Double) return Boolean
   is
      a_task    : generic_task_ptr;
      my_Cursor : DVS_map_package.cursor;
      somme     : Double;
      tmp       : Double;
      tmp2      : Double;
   begin
      somme     := 0.0;
      my_Cursor := DVS_map_package.First (my_tasks);
      while DVS_map_package.Has_Element (my_Cursor) loop
         a_task := DVS_map_package.Element (my_Cursor).a_task;
         tmp    := Double (a_task.capacity) / 100.0;
         tmp2   := Double (periodic_task_ptr (a_task).period);
         somme  := somme + (tmp / tmp2);
         DVS_map_package.Next (my_Cursor);
      end loop;
      if somme <= freq then
         return True;
      else
         return False;
      end if;
   end EDF_test_static_voltage_scaling;

-- RM
   function RM_test_static_voltage_scaling
     (my_tasks : dvs_map_subtype;
      freq     : Double;
      pi       : Natural) return Boolean
   is
      a_task    : generic_task_ptr;
      my_Cursor : DVS_map_package.cursor;
      somme     : Double;
      tmp       : Double;
      tmp2      : Double;
      tmp3      : Double;

      type tab_period_type is
        array
        (0 ..
             Natural (DVS_map_package.Length (my_tasks)) -
             1) of dvs_hashmap_type_element;
      tab_period : tab_period_type;
      tmp_period : dvs_hashmap_type_element;
      i          : Natural;
   begin
      i         := 0;
      my_Cursor := DVS_map_package.First (my_tasks);
      while DVS_map_package.Has_Element (my_Cursor) loop
         tab_period (i) := DVS_map_package.Element (my_Cursor);
         i              := i + 1;
         DVS_map_package.Next (my_Cursor);
      end loop;
-- table order P1 <= P2 <= .... <= Pi
      if Natural (DVS_map_package.Length (my_tasks)) >= 2 then
         i := 0;
         while i <= tab_period'length - 2 loop
            if (periodic_task_ptr (tab_period (i).a_task).period) >
              (periodic_task_ptr (tab_period (i + 1).a_task).period)
            then
               tmp_period         := tab_period (i);
               tab_period (i)     := tab_period (i + 1);
               tab_period (i + 1) := tmp_period;
               i                  := 0;
            else
               i := i + 1;
            end if;
         end loop;
      end if;
      tmp3 := Double (pi);
      for i in 0 .. tab_period'length - 1 loop
         somme := 0.0;
         for j in 0 .. i loop
            a_task := tab_period (j).a_task;
            tmp    := Double (a_task.capacity) / 100.0;
            tmp2   := Double (periodic_task_ptr (a_task).period);
            somme  := somme + (tmp * (Double'ceiling (tmp3 / tmp2)));

         end loop;
         if somme > (freq * tmp3) then
            return False;
         end if;
      end loop;
      return True;
   end RM_test_static_voltage_scaling;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Cycle Conserving
--EDF
   function select_frequency_cycle_conserving_edf
     (a_task_Ui : dvs_map_subtype) return Double
   is

      tmp       : Boolean;
      res       : Double;
      my_Cursor : DVS_map_package.cursor;

   begin
      res       := 0.0;
      tmp       := False;
      my_Cursor := DVS_map_package.First (a_task_Ui);
      while DVS_map_package.Has_Element (my_Cursor) loop
         res := res + DVS_map_package.Element (my_Cursor).element;
         DVS_map_package.Next (my_Cursor);
      end loop;

      for i in freqs'first .. freqs'last loop
         if res <= (freqs (i) / freqs (freqs'last)) then
            tmp := True;
            res := freqs (i);
         end if;
         exit when tmp;
      end loop;

      return res;
   end select_frequency_cycle_conserving_edf;

   procedure cycle_conserving_task_release_edf
     (a_task        :     generic_task_ptr;
      new_frequency : out Double)
   is
      tmp             : Double;
      tmp1            : Double;
      tmp2            : Double;
      DVS_EDF_element : dvs_hashmap_type_element;
   begin
      tmp1            := Double (a_task.capacity) / 100.0;
      tmp2            := Double (periodic_task_ptr (a_task).period);
      DVS_EDF_element :=
        (c_left       => 0.0,
         element      => tmp1 / tmp2,
         a_task       => a_task,
         release_time =>
           DVS_map_package.Element (DVS_map, a_task.name).release_time);
      DVS_map_package.Replace (DVS_map, a_task.name, DVS_EDF_element);

      tmp           := select_frequency_cycle_conserving_edf (DVS_map);
      new_frequency := tmp;
   end cycle_conserving_task_release_edf;

   procedure cycle_conserving_task_completion_edf
     (a_task        :     generic_task_ptr;
      new_frequency : out Double)
   is
      tmp             : Double;
      tmp1            : Double;
      tmp2            : Double;
      DVS_EDF_element : dvs_hashmap_type_element;
   begin
      tmp1 := (DVS_map_package.Element (DVS_map, a_task.name).c_left);
      tmp2            := Double (periodic_task_ptr (a_task).period);
      DVS_EDF_element :=
        (c_left => (DVS_map_package.Element (DVS_map, a_task.name).c_left),
         element      => tmp1 / tmp2,
         a_task       => a_task,
         release_time =>
           (DVS_map_package.Element (DVS_map, a_task.name).release_time));
      DVS_map_package.Replace (DVS_map, a_task.name, DVS_EDF_element);

      tmp           := select_frequency_cycle_conserving_edf (DVS_map);
      new_frequency := tmp;
   end cycle_conserving_task_completion_edf;

--RM
   function select_frequency_cycle_conserving_rm
     (a_task_Ui       : dvs_map_subtype;
      current_time    : Natural;
      task_is_release : Boolean) return Double
   is

      tmp            : Boolean;
      element        : Double;
      res            : Double;
      sm             : Natural;
      my_Cursor      : DVS_map_package.cursor;
      DVS_RM_element : dvs_hashmap_type_element;
   begin
      element := 0.0;
      tmp     := False;
      sm      := max_cycles_until_next_deadline (DVS_map, current_time);
      if task_is_release = False then
         sm := sm - 1;
      end if;
      my_Cursor := DVS_map_package.First (a_task_Ui);
      while DVS_map_package.Has_Element (my_Cursor) loop
         DVS_RM_element := DVS_map_package.Element (my_Cursor);
         element        := element + DVS_RM_element.element;
         DVS_map_package.Next (my_Cursor);
      end loop;
      res := element / Double (sm);

      for i in freqs'first .. freqs'last loop
         if res <= (freqs (i) / freqs (freqs'last)) then
            tmp := True;
            res := freqs (i);
         end if;
         exit when tmp;
      end loop;
      return res;
   end select_frequency_cycle_conserving_rm;

   function max_cycles_until_next_deadline
     (a_task_Ui    : in dvs_map_subtype;
      current_time : in Natural) return Natural
   is
      my_Cursor : DVS_map_package.cursor;
      res       : Natural;
      tmp1      : Natural;
      tmp2      : Natural;
   begin
      my_Cursor := DVS_map_package.First (a_task_Ui);
      res       := DVS_map_package.Element (my_Cursor).a_task.deadline;
      while DVS_map_package.Has_Element (my_Cursor) loop
         tmp1 :=
           (current_time /
            DVS_map_package.Element (my_Cursor).a_task.deadline) +
           1;
         tmp2 :=
           (tmp1 * DVS_map_package.Element (my_Cursor).a_task.deadline -
            current_time);
         if (res > tmp2) then
            res := tmp2;
         end if;
         DVS_map_package.Next (my_Cursor);
      end loop;
      return res;
   end max_cycles_until_next_deadline;

   procedure cycle_conserving_task_release_rm
     (a_task        :     generic_task_ptr;
      current_time  :     Natural;
      new_frequency : out Double)
   is
      DVS_RM_element : dvs_hashmap_type_element;
      sm             : Natural;
      sj             : Double;
   begin
      DVS_RM_element :=
        (c_left       => Double (a_task.capacity) / 100.0,
         element      => 0.0,
         a_task       => a_task,
         release_time =>
           DVS_map_package.Element (DVS_map, a_task.name).release_time);
      DVS_map_package.Replace (DVS_map, a_task.name, DVS_RM_element);
      sm := max_cycles_until_next_deadline (DVS_map, current_time);
      sj := Double (sm) * (fj / (freqs (freqs'last)));
      cycle_conserving_task_allocate_cycles (sj);
      new_frequency :=
        select_frequency_cycle_conserving_rm (DVS_map, current_time, True);
   end cycle_conserving_task_release_rm;

   procedure cycle_conserving_task_completion_rm
     (a_task        :     generic_task_ptr;
      current_time  :     Natural;
      new_frequency : out Double)
   is
      DVS_RM_element : dvs_hashmap_type_element;
   begin
      DVS_RM_element :=
        (c_left       => 0.0,
         element      => 0.0,
         a_task       => a_task,
         release_time =>
           DVS_map_package.Element (DVS_map, a_task.name).release_time);
      DVS_map_package.Replace (DVS_map, a_task.name, DVS_RM_element);
      new_frequency :=
        select_frequency_cycle_conserving_rm (DVS_map, current_time, False);
   end cycle_conserving_task_completion_rm;

   procedure cycle_conserving_task_execution_rm (a_task : generic_task_ptr) is
      DVS_RM_element : dvs_hashmap_type_element;
      tmp_c_left     : Double;
      tmp_d          : Double;
   begin
      tmp_c_left :=
        DVS_map_package.Element (DVS_map, a_task.name).c_left -
        (1.0 * Double (curr_freq) / 100.0);
      if tmp_c_left < 0.0 then
         tmp_c_left := 0.0;
      end if;
      tmp_d :=
        DVS_map_package.Element (DVS_map, a_task.name).element -
        (1.0 * Double (curr_freq) / 100.0);
      if tmp_d < 0.0 then
         tmp_d := 0.0;
      end if;
      DVS_RM_element :=
        (c_left       => tmp_c_left,
         element      => tmp_d,
         a_task       => a_task,
         release_time =>
           DVS_map_package.Element (DVS_map, a_task.name).release_time);

      DVS_map_package.Replace (DVS_map, a_task.name, DVS_RM_element);
   end cycle_conserving_task_execution_rm;

   procedure cycle_conserving_task_allocate_cycles (ki : Double) is
      my_Cursor      : DVS_map_package.cursor;
      DVS_RM_element : dvs_hashmap_type_element;
      k              : Double;

      type type_tab_period is
        array
        (0 ..
             Natural (DVS_map_package.Length (DVS_map)) -
             1) of dvs_hashmap_type_element;
      Tab_Period : type_tab_period;
      tmp_period : dvs_hashmap_type_element;
      i          : Natural;
   begin
      k := ki;
      i := 0;

      my_Cursor := DVS_map_package.First (DVS_map);
      while DVS_map_package.Has_Element (my_Cursor) loop
         Tab_Period (i) := DVS_map_package.Element (my_Cursor);
         i              := i + 1;
         DVS_map_package.Next (my_Cursor);
      end loop;

      if Natural (DVS_map_package.Length (DVS_map)) >= 2 then
         i := 0;
         while i <= Tab_Period'length - 2 loop
            if periodic_task_ptr (Tab_Period (i).a_task).period >
              periodic_task_ptr (Tab_Period (i + 1).a_task).period
            then
               tmp_period         := Tab_Period (i);
               Tab_Period (i)     := Tab_Period (i + 1);
               Tab_Period (i + 1) := tmp_period;
               i                  := 0;
            else
               i := i + 1;
            end if;
         end loop;
      end if;

      my_Cursor := DVS_map_package.First (DVS_map);
      for I in 0 .. Tab_Period'length - 1 loop
         if Tab_Period (I).c_left < k then
            DVS_RM_element :=
              (c_left       => Tab_Period (I).c_left,
               element      => Tab_Period (I).c_left,
               a_task       => Tab_Period (I).a_task,
               release_time => Tab_Period (I).release_time);

            k := k - Tab_Period (I).c_left;
         else
            DVS_RM_element :=
              (c_left       => Tab_Period (I).c_left,
               element      => k,
               a_task       => Tab_Period (I).a_task,
               release_time => Tab_Period (I).release_time);

            k := 0.0;
         end if;
         Tab_Period (I) := DVS_RM_element;
         DVS_map_package.Replace
           (DVS_map,
            Tab_Period (I).a_task.name,
            DVS_RM_element);
      end loop;

   end cycle_conserving_task_allocate_cycles;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Look-Ahead DVFS
   function select_frequency_look_ahead (x : Double) return Double is
      res : Double;
      tmp : Boolean;
   begin
      res := 0.0;
      tmp := False;

      for i in freqs'first .. freqs'last loop
         if x <= (freqs (i) / freqs (freqs'last)) then
            tmp := True;
            res := freqs (i) / freqs (freqs'last);
         end if;
         exit when tmp;
      end loop;
      return res;
   end select_frequency_look_ahead;

   procedure look_ahead_task_release
     (a_task        :        generic_task_ptr;
      current_time  : in     Natural;
      new_frequency :    out Double)
   is
      DVS_Look_Ahead_EDF_element : dvs_hashmap_type_element;
   begin
      if current_time /= 0 then
         DVS_Look_Ahead_EDF_element :=
           (c_left  => Double (a_task.capacity) / 100.0,
            a_task  => a_task,
            element =>
              (DVS_map_package.Element (DVS_map, a_task.name).element) +
              Double
                ((periodic_task_ptr
                    (DVS_map_package.Element (DVS_map, a_task.name).a_task)
                    .period)),
            release_time =>
              DVS_map_package.Element (DVS_map, a_task.name).release_time
);
         DVS_map_package.Replace
           (DVS_map,
            a_task.name,
            DVS_Look_Ahead_EDF_element);

      end if;
      look_ahead_task_defer (DVS_map, current_time, new_frequency);
   end look_ahead_task_release;

   procedure look_ahead_task_completion
     (a_task        :        generic_task_ptr;
      current_time  : in     Natural;
      new_frequency :    out Double)
   is
      DVS_Look_Ahead_EDF_element : dvs_hashmap_type_element;

   begin

      DVS_Look_Ahead_EDF_element :=
        (c_left       => 0.0,
         a_task       => a_task,
         element => DVS_map_package.Element (DVS_map, a_task.name).element,
         release_time =>
           DVS_map_package.Element (DVS_map, a_task.name).release_time);
      DVS_map_package.Replace
        (DVS_map,
         a_task.name,
         DVS_Look_Ahead_EDF_element);

      look_ahead_task_defer (DVS_map, current_time, new_frequency);
   end look_ahead_task_completion;

   procedure look_ahead_task_execution (a_task : generic_task_ptr) is
      DVS_Look_Ahead_EDF_element : dvs_hashmap_type_element;
      tmp_c_left                 : Double;
   begin
      if DVS_map_package.Element (DVS_map, a_task.name).c_left = 0.0 then
         DVS_Look_Ahead_EDF_element :=
           (c_left  => 0.0,
            a_task  => a_task,
            element =>
              Double
                ((DVS_map_package.Element (DVS_map, a_task.name).element)),
            release_time =>
              DVS_map_package.Element (DVS_map, a_task.name).release_time);
      else
         tmp_c_left :=
           (DVS_map_package.Element (DVS_map, a_task.name).c_left) -
           (1.0 * Double (curr_freq) / 100.0);
         if tmp_c_left < 0.0 then
            tmp_c_left := 0.0;
         end if;
         DVS_Look_Ahead_EDF_element :=
           (c_left  => tmp_c_left,
            a_task  => a_task,
            element =>
              Double
                ((DVS_map_package.Element (DVS_map, a_task.name).element)),
            release_time =>
              DVS_map_package.Element (DVS_map, a_task.name).release_time);
      end if;
      DVS_map_package.Replace
        (DVS_map,
         a_task.name,
         DVS_Look_Ahead_EDF_element);
   end look_ahead_task_execution;

   procedure look_ahead_task_defer
     (a_task_Ui     :        dvs_map_subtype;
      current_time  : in     Natural;
      new_frequency :    out Double)
   is
      u         : Double;
      res       : Double;
      s         : Double;
      x         : Double;
      my_Cursor : DVS_map_package.cursor;
      tmp1      : Double;
      tmp2      : Double;

      type testtabdeadline is
        array
        (0 ..
             Natural (DVS_map_package.Length (a_task_Ui)) -
             1) of dvs_hashmap_type_element;
      TabDeadline : testtabdeadline;
      tmpdealine  : dvs_hashmap_type_element;
      i           : Natural;
   begin
      res := 0.0;
      u   := 0.0;
      i   := 0;

      my_Cursor := DVS_map_package.First (a_task_Ui);
      while DVS_map_package.Has_Element (my_Cursor) loop
         tmp1 :=
           Double (DVS_map_package.Element (my_Cursor).a_task.capacity) /
           100.0;
         tmp2 :=
           Double
             (periodic_task_ptr (DVS_map_package.Element (my_Cursor).a_task)
                .period);
         u               := u + (tmp1 / tmp2);
         TabDeadline (i) := DVS_map_package.Element (my_Cursor);

         i := i + 1;
         DVS_map_package.Next (my_Cursor);
      end loop;
      s := 0.0;
      if Natural (DVS_map_package.Length (a_task_Ui)) >= 2 then
         i := 0;
         while i <= TabDeadline'length - 2 loop
            if TabDeadline (i).element < TabDeadline (i + 1).element then
               tmpdealine          := TabDeadline (i);
               TabDeadline (i)     := TabDeadline (i + 1);
               TabDeadline (i + 1) := tmpdealine;
               i                   := 0;
            else
               i := i + 1;
            end if;
         end loop;
      end if;
      for I in 0 .. TabDeadline'length - 1 loop
         u :=
           u -
           (Double (TabDeadline (I).a_task.capacity) / 100.0) /
             Double ((periodic_task_ptr (TabDeadline (I).a_task).period));
         x :=
           Double'max
             (0.0,
              TabDeadline (I).c_left -
              (1.0 - u) *
                Double
                  ((TabDeadline (I).element -
                    TabDeadline (TabDeadline'length - 1).element)));
         if TabDeadline (I).element /=
           TabDeadline (TabDeadline'length - 1).element
         then
            u :=
              u +
              (TabDeadline (I).c_left - x) /
                Double
                  ((TabDeadline (I).element -
                    TabDeadline (TabDeadline'length - 1).element));
         end if;
         s := s + x;

      end loop;
      if
        (TabDeadline (TabDeadline'length - 1).element -
         Double (current_time)) =
        0.0
      then
         s := 1.0;
      else
         s :=
           s /
           (TabDeadline (TabDeadline'length - 1).element -
            Double (current_time));
      end if;
      res           := select_frequency_look_ahead (s);
      new_frequency := res;
   end look_ahead_task_defer;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   procedure new_frequency_double_to_integer
     (new_frequency_double : in     Double;
      new_frequency        :    out Integer)
   is
   begin
      if new_frequency_double = 1.0 then
         new_frequency := 100;
      else
         if new_frequency_double = 0.75 then
            new_frequency := 75;
         else
            if new_frequency_double = 0.50 then
               new_frequency := 50;
            else
               if new_frequency_double = 0.25 then
                  new_frequency := 25;
               else
                  new_frequency := curr_freq;
               end if;
            end if;
         end if;
      end if;
      curr_freq := new_frequency;
   end new_frequency_double_to_integer;

   procedure dvfs_upon_running_task
     (an_event      : in     time_unit_event_ptr;
      current_time  : in     Natural;
      new_frequency :    out Integer)
   is
      my_Cursor            : DVS_map_package.cursor;
      new_frequency_double : Double := 0.0;
      DVS_element          : dvs_hashmap_type_element;
   begin
      if only_static_algorithm = False then
         -- Check if the current time correspond to a task release
         curr_time_task_exec := current_time;
         if scheduler_type = earliest_deadline_first_protocol then

            my_Cursor := DVS_map_package.First (DVS_map);
            while DVS_map_package.Has_Element (my_Cursor) loop
               if DVS_map_package.Element (my_Cursor).release_time =
                 current_time
               then
                  if look_ahead_algorithm = True then
                     look_ahead_task_release
                       (DVS_map_package.Element (my_Cursor).a_task,
                        current_time,
                        new_frequency_double);
                  else
                     cycle_conserving_task_release_edf
                       (DVS_map_package.Element (my_Cursor).a_task,
                        new_frequency_double);
                  end if;
                  new_frequency_double_to_integer
                    (new_frequency_double,
                     new_frequency);
               end if;
               DVS_map_package.Next (my_Cursor);
            end loop;
            if look_ahead_algorithm = True then
               look_ahead_task_execution (an_event.running_task);
            else
               DVS_element :=
                 (c_left =>
                    (DVS_map_package.Element
                       (DVS_map,
                        an_event.running_task.name)
                       .c_left) +
                    (1.0 * Double (curr_freq) / 100.0),
                  a_task  => an_event.running_task,
                  element =>
                    (DVS_map_package.Element
                       (DVS_map,
                        an_event.running_task.name)
                       .element),
                  release_time =>
                    (DVS_map_package.Element
                       (DVS_map,
                        an_event.running_task.name)
                       .release_time));
               DVS_map_package.Replace
                 (DVS_map,
                  an_event.running_task.name,
                  DVS_element);
            end if;
         else
            if scheduler_type = rate_monotonic_protocol then
               my_Cursor := DVS_map_package.First (DVS_map);
               while DVS_map_package.Has_Element (my_Cursor) loop
                  if DVS_map_package.Element (my_Cursor).release_time =
                    current_time
                  then
                     cycle_conserving_task_release_rm
                       (DVS_map_package.Element (my_Cursor).a_task,
                        current_time,
                        new_frequency_double);
                     new_frequency_double_to_integer
                       (new_frequency_double,
                        new_frequency);
                  end if;
                  DVS_map_package.Next (my_Cursor);
               end loop;
               cycle_conserving_task_execution_rm (an_event.running_task);
            end if;
         end if;
      end if;
      new_frequency_double_to_integer (new_frequency_double, new_frequency);
   end dvfs_upon_running_task;

   procedure dvfs_upon_task_release
     (an_event      : in     time_unit_event_ptr;
      current_time  : in     Natural;
      new_frequency :    out Integer)
   is
      new_frequency_double : Double := 0.0;
      DVS_element          : dvs_hashmap_type_element;
   begin
      if only_static_algorithm = True then
         if current_time = 0 then
            if DVS_map_package.Contains
                (DVS_map,
                 an_event.activation_task.name)
            then
               DVS_element :=
                 (c_left       => 0.0,
                  a_task       => an_event.activation_task,
                  element      => 0.0,
                  release_time => current_time);
               DVS_map_package.Replace
                 (DVS_map,
                  an_event.activation_task.name,
                  DVS_element);
            else
               DVS_element :=
                 (c_left       => 0.0,
                  a_task       => an_event.activation_task,
                  element      => 0.0,
                  release_time => current_time);
               DVS_map_package.Insert
                 (DVS_map,
                  an_event.activation_task.name,
                  DVS_element);
            end if;
            new_frequency_double :=
              select_frequency_static_voltage_scaling (DVS_map);
         end if;

      else
         if scheduler_type = earliest_deadline_first_protocol then
            if look_ahead_algorithm = True then
               if DVS_map_package.Contains
                   (DVS_map,
                    an_event.activation_task.name)
               then
                  DVS_element :=
                    (c_left =>
                       (DVS_map_package.Element
                          (DVS_map,
                           an_event.activation_task.name)
                          .c_left),
                     a_task  => an_event.activation_task,
                     element =>
                       (DVS_map_package.Element
                          (DVS_map,
                           an_event.activation_task.name)
                          .element),
                     release_time => current_time);
                  DVS_map_package.Replace
                    (DVS_map,
                     an_event.activation_task.name,
                     DVS_element);
                  look_ahead_task_completion
                    (an_event.activation_task,
                     curr_time_task_exec + 1,
                     new_frequency_double);
               else
                  DVS_element :=
                    (c_left =>
                       Double (an_event.activation_task.capacity) / 100.0,
                     a_task       => an_event.activation_task,
                     element => Double (an_event.activation_task.deadline),
                     release_time => current_time);
                  DVS_map_package.Insert
                    (DVS_map,
                     an_event.activation_task.name,
                     DVS_element);
                  look_ahead_task_release
                    (an_event.activation_task,
                     current_time,
                     new_frequency_double);
               end if;

            else
               if DVS_map_package.Contains
                   (DVS_map,
                    an_event.activation_task.name)
               then
                  DVS_map_package.Replace
                    (DVS_map,
                     an_event.activation_task.name,
                     DVS_element);
                  cycle_conserving_task_completion_edf
                    (an_event.activation_task,
                     new_frequency_double);
               else
                  DVS_element :=
                    (c_left       => 0.0,
                     a_task       => an_event.activation_task,
                     element => Double (an_event.activation_task.deadline),
                     release_time => current_time);
                  DVS_map_package.Insert
                    (DVS_map,
                     an_event.activation_task.name,
                     DVS_element);
                  cycle_conserving_task_release_edf
                    (an_event.activation_task,
                     new_frequency_double);
               end if;

            end if;

         else

            if scheduler_type = rate_monotonic_protocol then
               if DVS_map_package.Contains
                   (DVS_map,
                    an_event.activation_task.name)
               then
                  DVS_element :=
                    (c_left  => 0.0,
                     element => 0.0,
                     a_task  =>
                       (DVS_map_package.Element
                          (DVS_map,
                           an_event.activation_task.name)
                          .a_task),
                     release_time => current_time);
                  DVS_map_package.Replace
                    (DVS_map,
                     an_event.activation_task.name,
                     DVS_element);
                  cycle_conserving_task_completion_rm
                    (an_event.activation_task,
                     curr_time_task_exec,
                     new_frequency_double);
               else
                  DVS_element :=
                    (c_left =>
                       Double (an_event.activation_task.capacity) / 100.0,
                     element =>
                       Double (an_event.activation_task.capacity) / 100.0,
                     a_task       => an_event.activation_task,
                     release_time => current_time);
                  DVS_map_package.Insert
                    (DVS_map,
                     an_event.activation_task.name,
                     DVS_element);
                  fj := select_frequency_static_voltage_scaling (DVS_map);
                  cycle_conserving_task_release_rm
                    (an_event.activation_task,
                     curr_time_task_exec,
                     new_frequency_double);
               end if;
            end if;
         end if;
      end if;
      new_frequency_double_to_integer (new_frequency_double, new_frequency);
   end dvfs_upon_task_release;

   procedure dvfs_upon_task_completion
     (an_event      : in     time_unit_event_ptr;
      current_time  : in     Natural;
      new_frequency :    out Integer)
   is
      new_frequency_double : Double := 0.0;
   begin
      null;
   end dvfs_upon_task_completion;

end voltage_scaling;
