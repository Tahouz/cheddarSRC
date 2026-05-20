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

with paes_utilities;           use paes_utilities;
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
with editor_config;                    use editor_config;
with framework_config;                 use framework_config;
with framework_config.extended;        use framework_config.extended;
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
with processors;                       use processors;
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
with scheduler_interface;              use scheduler_interface;
with task_set;                         use task_set;
with Gtk.Text_Buffer;                  use Gtk.Text_Buffer;
with Gtk.Text_Tag_Table;               use Gtk.Text_Tag_Table;
with Gtkada.Builder;                   use Gtkada.Builder;

with initialize_framework; use initialize_framework;
with io_tools;             use io_tools;
with paes_general_form;

procedure paes_general_form_mils is

   -- for parallel execution
   -- a ToDo and a Done lists, protected by a mutex
   todosollist    : array (0 .. max_slaves) of solution;
   todoindex      : Integer := 0;
   donesollist    : array (0 .. max_slaves) of solution;
   doneindex      : Integer := 0;
   f6             : Ada.Text_IO.File_Type;
   nb_rejectedsol : Integer;

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
      tomute : solution;
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
         mutate (tomute, eidx);
         evaluate (tomute, eidx);

         donesolmutex.p;
         donesollist (doneindex) := tomute;
         doneindex               := doneindex + 1;
         donesolmutex.v;
      end loop;
      --Put_Line("I am dead");
   end slave_task;

   runningslaves : array (1 .. max_slaves) of slave_task;
   mfound        : Integer;

begin

   -- Initializing the current solution c,
   -- the initial_system
   -- and the list of all possible Fitness functions
   Append
     (data3,
      "iteration" &
        "       " &
        "Missed_deadline" &
        "               " &
        "bell" &
        "                     " &
        "biba" &
        "       " &
        "security Implementation" &
        " " &
        ASCII.LF);
   init;

   -------------------------
   -- begin the main loop --
   -------------------------

   --Parallel running of first mutations
   --useless tasks are told to die
   if slaves > 0 then
      todosolmutex.p;
      for i in 0 .. max_slaves - 1 loop

         todosollist (i) := c;
         if i < slaves then
            todosollist (i).grid_loc := i;
         else
            todosollist (i).grid_loc := -1;
         end if;
      end loop;
      todoindex := max_slaves;
      todosolmutex.v;

   else --killing all tasks (except mutex)
      todosolmutex.p;
      for i in 0 .. max_slaves - 1 loop
         todosollist (i).grid_loc := -1;
      end loop;
      todoindex := max_slaves;
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
         mutate (m, 0); --sequential
         evaluate (m, 0);
         Append
           (data3,
            i'img &
              "              " &
              m.obj (1)'img &
              "              " &
              m.obj (2)'img &
              "              " &
              m.obj (3)'img &
              "              " &
              m.security_config'Img &
              "              " &
              ASCII.LF);
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

      selection_and_archiving;

      if slaves > 0 then
         if i <= (iterations - slaves) then
            todosolmutex.p;
            todosollist (todoindex)          := c;
            todosollist (todoindex).grid_loc := slaves + i;
            todoindex                        := todoindex + 1;
            todosolmutex.v;
         end if;
      end if;

   end loop;

   nb_rejectedsol := nb_initsol + iterations - arclength;
   Append (data3, " " & ASCII.LF);
   Append (data3, " " & ASCII.LF);
   Append
     (data3,
      "Number of rejected solution during the archiving process : " &
      nb_rejectedsol'img &
      ASCII.LF);
   Append
     (data3,
      "Number of non feasible solution during mutations : " &
      nb_nofeasible_sol'img &
      ASCII.LF);
   for n in 1 .. 15 loop
      Append
        (data3,
         "Number of choice of security architecture" &
         n'img &
         " : " &
         nb_secu_conf_choice (n)'img &
         ASCII.LF);
   end loop;

   Create (f6, Ada.Text_IO.Out_File, "PAES_Execution_iter.dat");
   Unbounded_IO.Put_Line (f6, data3);
   Close (f6);

   --send invalid task to end the slaves
   if slaves > 0 then
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
end paes_general_form_mils;
