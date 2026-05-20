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
-- Frank Singhoff, Lab-STICC UMR CNRS 6285, Universite de Bretagne Occidentale
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
--    $Rev: 3546 $
--    $Date: 2020-10-19 08:01:15 +0200 (lun. 19 oct. 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Text_IO;           use Ada.Text_IO;
with systems;               use systems;
with Dependencies;          use Dependencies;
with task_dependencies;     use task_dependencies;
with task_dependencies;     use task_dependencies.half_dep_set;
with Tasks;                 use Tasks;
with task_set;              use task_set;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with debug;                 use debug;
with sets;
package body kl_partitioning is

   function computesCosts
     (nbParts    : in     Integer;
      nb_nodes   : in     Integer;
      costs      : in out matrice;
      graph_sys  : in out matrice;
      chromosome : in out chrom_array) return Integer
   is
      cut : Integer := 0;

   begin

      --BZERO
      for i in 1 .. nb_nodes loop
         for j in i + 1 .. nb_nodes loop
            costs (i, chromosome (j)) :=
              costs (i, chromosome (j)) + graph_sys (i, j);
            costs (j, chromosome (i)) :=
              costs (i, chromosome (j)) + graph_sys (i, j);
         end loop;
      end loop;
      for i in 1 .. nb_nodes loop
         for k in 1 .. nbParts loop
            if (chromosome (i) /= k) then
               cut := cut + costs (i, k);
            end if;
         end loop;
      end loop;
      return cut / 2;
   end computesCosts;

   function kl
     (nbParts    : in     Integer;
      nb_nodes   : in     Integer;
      costs      : in out matrice;
      graph_sys  : in out matrice;
      chromosome : in out chrom_array) return Integer
   is

      cut, bestPair, bestCut, pair, a, b, tmp, gain, g : Integer := 0;
      locked                                           : chrom_array;
      klstack                                          : matrice;

   begin
      --random init
      for i in 1 .. nb_nodes loop
         chromosome (i) := i mod nbParts;
      end loop;
      cut := computesCosts (nbParts, nb_nodes, costs, graph_sys, chromosome);
      put_debug ("initial cut : " & cut'img);

      while (True) loop

         bestCut := INFTY;
         --BZERO
         for i in 1 .. nb_nodes loop
            locked (i) := 0;
         end loop;

         put_debug ("cut at the begining of phase : " & cut'img);
         for pair in 1 .. nb_nodes / 2 loop
            --find best unlocked pair
            gain := -INFTY;
            for i in 1 .. nb_nodes - 1 loop
               for j in i + 1 .. nb_nodes loop
                  if (locked (i) /= 1) and (locked (j) /= 1) then
                     g :=
                       costs (i, chromosome (j)) +
                       costs (j, chromosome (i)) -
                       costs (i, chromosome (i)) -
                       costs (j, chromosome (j)) -
                       2 * graph_sys (i, j);
                     if g > gain then
                        gain := g;
                        a    := i;
                        b    := j;
                     end if;
                  end if;

               end loop;
            end loop;

            --swap the best pair, lock nodes, and compute new cut
            tmp               := chromosome (a);
            chromosome (a)    := chromosome (b);
            chromosome (b)    := tmp;
            locked (a)        := 1;
            locked (b)        := 1;
            klstack (pair, 1) := a; -- first exchanged node
            klstack (pair, 2) := b; -- second exchanged node
            klstack (pair, 3) :=
              computesCosts
                (nbParts,
                 nb_nodes,
                 costs,
                 graph_sys,
                 chromosome); -- new cut value
            if (klstack (pair, 3) < bestCut) then
               bestPair := pair;
               bestCut  := klstack (pair, 3);
            end if;

         end loop;

         put_debug
           ("best pair " &
            bestPair'img &
            " ->" &
            klstack (bestPair, 1)'img &
            " " &
            klstack (bestPair, 2)'img &
            " " &
            klstack (bestPair, 3)'img);
         if (bestCut < cut) then
            --we got a gain
            for pair in bestPair + 1 .. nb_nodes / 2 loop
               --invalidate last exchanges
               a              := klstack (bestPair, 1);
               b              := klstack (bestPair, 2);
               tmp            := chromosome (a);
               chromosome (a) := chromosome (b);
               chromosome (b) := tmp;
            end loop;
            cut :=
              computesCosts
                (nbParts,
                 nb_nodes,
                 costs,
                 graph_sys,
                 chromosome); -- = bestCut, we need to update Dval()
         else
            exit;
         end if;
      end loop;
      return cut;
   end kl;

   function genGraph
     (sys      : in     system;
      m        : in out matrice;
      nbParts  : in     Integer;
      nb_nodes : in     Integer) return Integer
   is

      my_dependencies : tasks_dependencies_ptr;
      dep_ptr         : dependency_ptr;
      my_iterator     : tasks_dependencies_iterator;
      e               : Integer := 0;
   begin

      my_dependencies := sys.dependencies;
      if is_empty (my_dependencies.depends) then
         put_debug ("No dependencies");
      else

         reset_iterator (my_dependencies.depends, my_iterator);
         loop
            current_element (my_dependencies.depends, dep_ptr, my_iterator);
            if (dep_ptr.type_of_dependency = precedence_dependency) then
               m (Integer'value (To_String (dep_ptr.precedence_source.name)),
                  Integer'value (To_String (dep_ptr.precedence_sink.name))) :=
                 1;
               e := e + 1;
            elsif
              (dep_ptr.type_of_dependency = remote_procedure_call_dependency)
            then
               m (Integer'value
                    (To_String (dep_ptr.remote_procedure_call_server.name)),
                  Integer'value
                    (To_String (dep_ptr.remote_procedure_call_client.name))) :=
                 1;
               e := e + 1;
               exit when is_last_element
                   (my_dependencies.depends,
                    my_iterator);
               next_element (my_dependencies.depends, my_iterator);
            end if;
         end loop;
      end if;
      return e;

   end genGraph;

end kl_partitioning;
