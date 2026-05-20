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
--    $Rev: 3477 $
--    $Date: 2020-07-13 11:43:48 +0200 (Mon, 13 Jul 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with paes_utilities; use paes_utilities;

procedure paes_general_form is

   -- for parallel execution
   -- a ToDo and a Done lists, protected by a mutex
   todosollist : array (0 .. max_slaves) of solution;
   todoindex   : Integer := 0;
   donesollist : array (0 .. max_slaves) of solution;
   doneindex   : Integer := 0;

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
   init;

   add_to_archive (c);
   update_grid (c);

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

   for i in 0 .. iterations - 1 loop

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

end paes_general_form;
