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
-- Cheddar has been published in the "Agence de Protection des
-- Programmes/France" in 2008.
-- Since 2008, Ellidiss technologies also contributes to the development of
-- Cheddar and provides industrial support.
--
-- The full list of contributors and sponsors can be found in README.md
-- SPONSORS.txt
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
--    $Rev: 4689 $
--    $Date: 2023-12-13 18:07:22 +0100 (mer., 13 déc. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Tags;              use Ada.Tags;
with Text_IO;               use Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with xml_tag;               use xml_tag;
with double_util;           use double_util;
with translate;             use translate;
with unbounded_strings;     use unbounded_strings;
with systems;               use systems;
with Scheduling_Analysis;   use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with systems;               use systems;
with task_set;              use task_set;
use task_set.generic_task_set;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Periodic_Tasks_Table_Package;
use Multiprocessor_Services_Interface.Run_Servers_Table_Package;
with id_generators;         use id_generators;
with debug;                 use debug;
with Framework_Config;      use Framework_Config;
with Doubles;               use Doubles;

package run_trees is

   procedure put_run_server
     (indent    : Natural;
      server    : run_server_primal_ptr;
      recursive : Boolean := True);
   procedure put_run_server
     (indent    : Natural;
      server    : run_server_dual_ptr;
      recursive : Boolean := True);
   procedure put_run_server (indent : Natural; server : run_server_ptr);

   procedure compute_deadlines (primal : run_server_primal_ptr);

   procedure pack_first_fit
     (dual_servers : in     run_servers_table_ptr;
      pack_servers :    out run_servers_table_ptr);

   function reduce
     (dual_servers : in run_servers_table_ptr) return run_servers_table_ptr;

   procedure dual
     (primal_server : in     run_server_primal_ptr;
      dual_server   :    out run_server_dual_ptr);
   procedure dual
     (primal_servers : in     run_servers_table_ptr;
      dual_servers   :    out run_servers_table_ptr);

   function create (primal : run_server_primal_ptr) return run_server_dual_ptr;

   function create (dual : run_server_dual_ptr) return run_server_primal_ptr;

end run_trees;
