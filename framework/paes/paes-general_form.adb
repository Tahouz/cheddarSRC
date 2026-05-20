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
--    $Rev: 3561 $
--    $Date: 2020-11-02 08:25:02 +0100 (Mon, 02 Nov 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Text_IO;              use Ada.Text_IO;
with Glib.Error;               use Glib.Error;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with debug;                    use debug;
with Gtk.Widget;               use Gtk.Widget;
with Gtk.Window;               use Gtk.Window;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with GNAT.Command_Line;        use GNAT.Command_Line;
with GNAT.OS_Lib;              use GNAT.OS_Lib;
with Ada.IO_Exceptions;        use Ada.IO_Exceptions;
with GNAT.Current_Exception;   use GNAT.Current_Exception;

with Gtk;                              use Gtk;
with Gtk.Menu_Item;                    use Gtk.Menu_Item;
with Gtk.Main;                         use Gtk.Main;
with Glib.Error;                       use Glib.Error;
with Gtk.Widget;                       use Gtk.Widget;
with Gtk.Window;                       use Gtk.Window;
with Ada.Strings.Unbounded;            use Ada.Strings.Unbounded;
with GNAT.Command_Line;                use GNAT.Command_Line;
with GNAT.OS_Lib;                      use GNAT.OS_Lib;
with unbounded_strings;                use unbounded_strings;
with unbounded_strings; use unbounded_strings.unbounded_string_list_package;
with Editor_Config;                    use Editor_Config;
with Framework_Config;                 use Framework_Config;
with Framework_Config.extended;        use Framework_Config.extended;
with framework;                        use framework;
with call_framework;                   use call_framework;
with version;                          use version;
with Ada.Text_IO;                      use Ada.Text_IO;
with Ada.IO_Exceptions;                use Ada.IO_Exceptions;
with GNAT.Current_Exception;           use GNAT.Current_Exception;
with xml_generic_parsers;              use xml_generic_parsers;
with xml_generic_parsers.architecture; use xml_generic_parsers.architecture;
with aadl_parsers;                     use aadl_parsers;
with systems;                          use systems;
with debug;                            use debug;
with Processors;                       use Processors;
with cache_set;                        use cache_set;
with cache_block_set;                  use cache_block_set;
with cache_access_profile_set;         use cache_access_profile_set;
with task_group_set;                   use task_group_set;
with message_set;                      use message_set;
with network_set;                      use network_set;
with event_analyzer_set;               use event_analyzer_set;
with systems;                          use systems;
with deployment_set;                   use deployment_set;
with cfg_set;                          use cfg_set;
with cfg_node_set;                     use cfg_node_set;
with cfg_edge_set;                     use cfg_edge_set;
with processor_set;                    use processor_set;
with buffer_set;                       use buffer_set;
with resource_set;                     use resource_set;
with address_space_set;                use address_space_set;
with Scheduler_Interface;              use Scheduler_Interface;
with task_set;                         use task_set;
with Gtk.Text_Buffer;                  use Gtk.Text_Buffer;
with Gtk.Text_Tag_Table;               use Gtk.Text_Tag_Table;
with Gtkada.Builder;                   use Gtkada.Builder;

with initialize_framework;     use initialize_framework;
with io_tools;                 use io_tools;
with Paes.objective_functions; use Paes.objective_functions;
with Paes.t2p_and_security;    use Paes.t2p_and_security;

with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

package body Paes.general_form is
   nb_rejectedsol : Integer;

   procedure sequential_general_form is
      best_solution_find : Boolean;
   begin
      Reset (G, 0); -- Initialise the float generator
      Append (Data3, "iteration");
      for i in 1 .. max_fitness loop
         if (fitnessfunctions (i).is_selected = 1) then
            Append (Data3, "       " & To_String (fitnessfunctions (i).name));
         end if;
      end loop;
      Append (Data3, ASCII.LF);
      init;

      for i in 1 .. iterations loop
         iter := i;
         put_debug ("==iter " & i'img);
         Put_Line ("==iter " & i'img);
         arc_random_sol := 0;
         if (i > last_nondominated_sol + 50) then
            while (arc_random_sol < 1) loop
               arc_random_sol := Integer (Float (arclength) * Random (G));
            end loop;
            put_debug ("arc_random_sol :" & arc_random_sol'img);
            Put_Line ("arc_random_sol :" & arc_random_sol'img);
            c.all := arc (arc_random_sol).all;
            update_grid (c);
         end if;
         --  copy the current solution
         m.all := c.all;
         -- in sequential:
         -- mutate (m, 0);
         -- in parallel, when deployed:
         -- run_mutate(m, i);
         -- for test of reentrant code
         mutate (m.all, 0); --sequential

         evaluate (m.all, 0);

         Put_Line ("solution m evaluated");

         for k in 1 .. objectives loop
            Put (m.obj (k)'img & "     ");
         end loop;
         New_Line;

         Append (Data3, i'img);
         best_solution_find := True;
         for k in 1 .. objectives loop
            Append (Data3, "              " & m.obj (k)'img);
            if (Float'value (m.obj (k)'img) /= 0.0) then
               best_solution_find := False;
            end if;
         end loop;
         Append (Data3, ASCII.LF);

         if (best_solution_find = True) then
            archive_soln (generic_solution_ptr (m));
            OS_Exit (0);
         end if;

         Selection_and_Archiving;

      end loop;

      nb_rejectedsol := nb_InitSol + iterations - arclength;
      Append (Data3, " " & ASCII.LF);
      Append (Data3, " " & ASCII.LF);
      Append
        (Data3,
         "Number of rejected solution during the archiving process : " &
         nb_rejectedsol'img &
         ASCII.LF);
      Append
        (Data3,
         "Number of non feasible solution during mutations : " &
         nb_NoFeasible_Sol'img &
         ASCII.LF);

   exception

      when address_space_not_found =>
         Put_Line
           ("cheddar.adb : address space not found ; " & Exception_Message);
         OS_Exit (0);
      when processor_not_found =>
         Put_Line ("cheddar.adb : processor not found ; " & Exception_Message);
         OS_Exit (0);
      when core_unit_not_found =>
         Put_Line ("cheddar.adb : core unit not found ; " & Exception_Message);
         OS_Exit (0);
      when task_not_found =>
         Put_Line ("cheddar.adb : task not found ; " & Exception_Message);
         OS_Exit (0);
      when systems.invalid_parameter =>
         Put_Line
           ("cheddar.adb : invalid system attribute ; " & Exception_Message);
         OS_Exit (0);
   end sequential_general_form;

   procedure parallel_general_form is

      -- for parallel execution
      --   type generic_solution_Access is access generic_solution'Class;
      -- a ToDo and a Done lists, protected by a mutex
      type array_of_solutions is
        array (0 .. MAX_SLAVES) of generic_solution_ptr;
      todosollist : array_of_solutions;
      --   todosollist    : array (0 .. max_slaves) of generic_solution'Class;
      todoindex   : Integer := 0;
      donesollist : array_of_solutions;
   --     donesollist    : array (0 .. max_slaves) of generic_solution'Class;
      doneindex : Integer := 0;

      task type mutex is
         entry p;
         entry v;
         entry e;
      end mutex;

      task body mutex is
         finished : Boolean := False;
      begin
         loop
            select
               accept p;
            or
               accept e do
                  finished := True; -- loop
               end e;
            end select;
            if (not finished) then
               accept v;
            else
               exit;
            end if;
         end loop;
      end mutex;

      donesolmutex : mutex;
      todosolmutex : mutex;

      task type slave_task;
      task body slave_task is
         found  : Integer;
         tomute : generic_solution_ptr;
         eidx   : Integer;
      begin
         loop
            loop
               found := 0;
               todosolmutex.p;
               if todoindex > 0 then
                  todoindex := todoindex - 1;
                  tomute    := todosollist (todoindex);
                  found     := 1;
               end if;
               todosolmutex.v;
               if found = 1 then
                  exit;
               end if;
               delay 0.5;
            end loop;
            eidx := tomute.grid_loc;

            if eidx < 0 then -- marked for ending task
               exit;
            end if;
            mutate (tomute.all, eidx);
            evaluate (tomute.all, eidx);

            donesolmutex.p;
            donesollist (doneindex) := tomute;
            doneindex               := doneindex + 1;
            donesolmutex.v;
         end loop;
      end slave_task;

      runningslaves : array (1 .. MAX_SLAVES) of slave_task;
      mfound        : Integer;

   begin

      -- Initializing the current solution c,
      -- the initial_system
      -- and the list of all possible Fitness functions
      for i in 1 .. MAX_SLAVES loop
         todosollist (i) := new solution_t2p;
      end loop;

      Append (Data3, "iteration");
      for i in 1 .. max_fitness loop
         if (fitnessfunctions (i).is_selected = 1) then
            Append (Data3, "       " & To_String (fitnessfunctions (i).name));
         end if;
      end loop;
      Append (Data3, ASCII.LF);
      init;
      -------------------------
      -- begin the main loop --
      -------------------------

      --Parallel running of first mutations
      --useless tasks are told to die
      if slaves > 0 then
         todosolmutex.p;
         for i in 0 .. MAX_SLAVES - 1 loop

            todosollist (i) := c;
            if i < slaves then
               todosollist (i).grid_loc := i;
            else
               todosollist (i).grid_loc := -1;
            end if;
         end loop;
         todoindex := MAX_SLAVES;
         todosolmutex.v;

      else --killing all tasks (except mutex)
         todosolmutex.p;

         for i in 0 .. MAX_SLAVES - 1 loop
            todosollist (i).grid_loc := -1;
         end loop;

         todoindex := MAX_SLAVES;
         todosolmutex.v;
      end if;

      for i in 1 .. iterations loop
         iter := i;
         put_debug ("==iter " & i'img);
         Put_Line ("==iter " & i'img);
         --  copy the current solution
         m := c;
         -- in sequential:
         -- mutate (m, 0);
         -- in parallel, when deployed:
         -- run_mutate(m, i);
         -- for test of reentrant code
         if slaves < 1 then
            mutate (m.all, 0); --sequential
            evaluate (m.all, 0);
            Append (Data3, i'img);

            for k in 1 .. objectives loop
               Append (Data3, "              " & m.obj (k)'img);
            end loop;
            Append (Data3, ASCII.LF);
         else
            mfound := 0;
            loop
               donesolmutex.p;
               if doneindex > 0 then
                  doneindex := doneindex - 1;
                  m         := donesollist (doneindex);
                  mfound    := 1;
               end if;
               donesolmutex.v;
               if mfound = 1 then
                  exit;
               end if;
               delay 0.5;
            end loop;

         end if;

         Selection_and_Archiving;

         if slaves > 1 then
            if i <= (iterations - slaves) then
               todosolmutex.p;
               todosollist (todoindex)          := c;
               todosollist (todoindex).grid_loc := slaves + i;
               todoindex                        := todoindex + 1;
               todosolmutex.v;
            end if;
         end if;

      end loop;

      nb_rejectedsol := nb_InitSol + iterations - arclength;
      Append (Data3, " " & ASCII.LF);
      Append (Data3, " " & ASCII.LF);
      Append
        (Data3,
         "Number of rejected solution during the archiving process : " &
         nb_rejectedsol'img &
         ASCII.LF);
      Append
        (Data3,
         "Number of non feasible solution during mutations : " &
         nb_NoFeasible_Sol'img &
         ASCII.LF);

      --send invalid task to end the slaves
      if slaves > 1 then
         todosolmutex.p;
         for i in 0 .. slaves - 1 loop
            todosollist (i)          := c;
            todosollist (i).grid_loc := -1;
         end loop;
         todoindex := slaves;
         todosolmutex.v;
      end if;
      -- end all tasks
      todosolmutex.e;
      donesolmutex.e;
   exception

      when address_space_not_found =>
         Put_Line
           ("cheddar.adb : address space not found ; " & Exception_Message);
         OS_Exit (0);
      when processor_not_found =>
         Put_Line ("cheddar.adb : processor not found ; " & Exception_Message);
         OS_Exit (0);
      when core_unit_not_found =>
         Put_Line ("cheddar.adb : core unit not found ; " & Exception_Message);
         OS_Exit (0);
      when task_not_found =>
         Put_Line ("cheddar.adb : task not found ; " & Exception_Message);
         OS_Exit (0);
      when systems.invalid_parameter =>
         Put_Line
           ("cheddar.adb : invalid system attribute ; " & Exception_Message);
         OS_Exit (0);

   end parallel_general_form;

end Paes.general_form;
