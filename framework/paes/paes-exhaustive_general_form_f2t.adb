
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

with Ada.Containers.Vectors;
use Ada.Containers; use Ada.Containers;
with Ada.Directories; use Ada.Directories;
with Ada.text_IO; use Ada.text_IO;

procedure paes.exhaustive_general_form_f2t is

   package Solution_Container is new Vectors (Positive, solution_f2t);
   use Solution_Container;

   package Integer_Container is new Vectors (Positive, Integer);
   use Integer_Container;

   search_space_is_exhausted : boolean := false;
   m                         : chrom_type;
   next_solution             : solution_f2t;
   normalized_solution       : solution_f2t;
   all_feasible_solutions    : Solution_Container.Vector;
   N_feasible_solutions      : integer := 0;

   a_table                   : Integer_container.Vector;
   Cursor1,Cursor2           : Solution_Container.Cursor;
   Cursor3                   : Integer_container.Cursor;
   h,k, j                    : integer;
   ok                        : boolean;

   eidx                      : natural := 0;
   F                         : Ada.Text_IO.File_Type;

begin


   for i in 1..genes loop
      next_solution.chrom_task(i) := 1;
      m(i) := 1;
   end loop;

   -- 2) enumerate and evaluate all feasible solutions
   --
   loop

      eidx := eidx + 1;
      generate_next_solution (next_solution, m, search_space_is_exhausted);

      normalized_solution := next_solution;
      normalize (normalized_solution);

      if Check_Feasibility (normalized_solution,eidx) then

         evaluate (normalized_solution,eidx);

         all_feasible_solutions.Append (normalized_solution);
         N_feasible_solutions := N_feasible_solutions + 1;

      end if;

      exit when search_space_is_exhausted;

   end loop;


   -- 2) Compute the Pareto front from all the feasible solutions

   for i in 1 .. N_feasible_solutions loop
      Integer_container.Append(a_table, -1);
   end loop;

   Cursor1 := Solution_Container.First(all_feasible_solutions);

   k := 1;

   while Solution_Container.Has_Element(Cursor1) loop

      Cursor2 := Solution_Container.First(all_feasible_solutions);
      j := 1;

      while Solution_Container.Has_Element(Cursor2) loop
         if (k /= j) then

            h := 1;
            ok := true;
            while (h <= objectives) and ok loop

               if (Solution_Container.Element(Cursor1).obj(h) >= Solution_Container.Element(Cursor2).obj(h)) then
                  ok := true;
               else
                  ok := false;
               end if;
               h := h + 1;
            end loop;

            if  (ok) then
               h := 1;
               ok := false;
               while (h <= objectives) and (Not ok) loop

                  if (Solution_Container.Element(Cursor1).obj(h) > Solution_Container.Element(Cursor2).obj(h)) then
                     ok := true;
                  end if;
                  h := h + 1;
               end loop;

               if ok then
                  Integer_container.Replace_Element (Container => a_table,
                                                     Index     => k,
                                                     New_Item  => 1);
               end if;

            end if;

         end if;

         Solution_Container.Next(Cursor2);
         j := j + 1;
      end loop;

      k := k + 1;
      Solution_Container.Next(Cursor1);
   end loop;

   k := 1;
   Cursor3 := Integer_container.First(a_table);
   while Integer_container.Has_Element(Cursor3) loop
      if (Integer_container.Element(Cursor3) = -1) then

         add_to_archive (Solution_Container.Element(all_feasible_solutions,k));

      end if;
      k := k + 1;
      Integer_container.Next(Cursor3);
   end loop;


end paes.exhaustive_general_form_f2t;
