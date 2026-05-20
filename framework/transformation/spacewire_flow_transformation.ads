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

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Tasks;        use Tasks;
with task_set;     use task_set;
with Dependencies; use Dependencies;
with Resources;    use Resources;
use Resources.Resource_Accesses;

with systems; use systems;

with Processors;        use Processors;
with processor_set;     use processor_set;
with Address_Spaces;    use Address_Spaces;
with address_space_set; use address_space_set;
with Caches;            use Caches;
with Caches;            use Caches.Cache_Blocks_Table_Package;
with Messages;          use Messages;
with message_set;       use message_set;

with network_set;  use network_set;
with resource_set; use resource_set;

with task_dependencies; use task_dependencies;

with buffer_set; use buffer_set;
with Buffers;    use Buffers;
use Buffers.Buffer_Roles_Package;

with convert_strings;
with unbounded_strings;   use unbounded_strings;
with convert_unbounded_strings;
with Text_IO;             use Text_IO;
with systems;             use systems;
with Objects;             use Objects;
with Parameters.extended; use Parameters.extended;
with Scheduler_Interface; use Scheduler_Interface;
with Ada.Finalization;
with unbounded_strings;   use unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
with Unchecked_Deallocation;
with sets;
with Framework_Config;     use Framework_Config;
with Ada.Float_Text_IO;
with random_tools;         use random_tools;
with initialize_framework; use initialize_framework;
with random_tools;         use random_tools;
with Ada.Numerics.Float_Random;
with Core_Units;           use Core_Units;
with Networks;             use Networks;
use Networks.Positions_Table_Package;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Networks;                  use Networks;
with mesh_analysis;             use mesh_analysis;
with mesh_analysis.delays;      use mesh_analysis.delays;

package spacewire_flow_transformation is

-----------------------------------------------------
-- this procedure compute the transformation of SCM (spacewire communication model).
-- It generates a DAG system (Result) from the design system (Sys).
-- It includes 4 steps :
-----------------------------------------------------
   -- 1- compute_source_destination_task
   -- 2- compute_spw_source_destination_task_position
   -- 3- generate_links_spw
   -- 4- flow_to_task_spw
-----------------------------------------------------

   procedure compute_spacewire_transformation
     (sys       : in     system;
      a_network : in     spacewire_network_ptr;
      result    :    out system);

-----------------------------------------------------
-- This procedure compute DAG system (Result) from attributes of Sys (input model) following
-- the transformation of SCM (spacewire communication model).
-- In this procedure, we must provide :
   -- destination_tasks and source_tasks : two tables which describe source and destination tasks of Sys
   -- A_link_matrice : matrice includes used links by message of Sys,
   -------- to compute A_link_matrice, we need compute task_position of source and destination tasks, then
   -------- we need to compute used links in the network by messages of Sys.
------------------------------------------------------

   procedure flow_to_task_spw
     (sys               : in     system;
      a_link_mat        : in     links_mat;
      destination_tasks : in     tasks_set;
      source_tasks      : in     tasks_set;
      a_network         : in     spacewire_network_ptr;
      result            : in out system);

end spacewire_flow_transformation;
