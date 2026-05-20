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
--    $Rev: 3475 $
--    $Date: 2020-07-13 10:35:38 +0200 (lun. 13 juil. 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with systems;                  use systems;
with task_set;                 use task_set;
with Tasks;                    use Tasks;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with Ada.Exceptions;           use Ada.Exceptions;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with unbounded_strings;        use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with Framework_Config; use Framework_Config;

package kl_partitioning is

   parser_error : exception;

   INFTY : constant Integer := 999999;
   type matrice is array (1 .. Max_Tasks, 1 .. Max_Tasks) of Integer;
   type chrom_array is array (1 .. Max_Tasks) of Integer;

   function computesCosts
     (nbParts    : in     Integer;
      nb_nodes   : in     Integer;
      costs      : in out matrice;
      graph_sys  : in out matrice;
      chromosome : in out chrom_array) return Integer;

   function kl
     (nbParts    : in     Integer;
      nb_nodes   : in     Integer;
      costs      : in out matrice;
      graph_sys  : in out matrice;
      chromosome : in out chrom_array) return Integer;

   function genGraph
     (sys      : in     system;
      m        : in out matrice;
      nbParts  : in     Integer;
      nb_nodes : in     Integer) return Integer;

end kl_partitioning;
