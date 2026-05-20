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

with systems; use systems;

package architecture_models is

   -- Monocore model, preemptive scheduler, solution of exercise 1
   --
   procedure model0 (sys : out system);

   -- Monocore model, non preemptive scheduler, solution of exercise 1
   --
   procedure model3 (sys : out system);

   -- Multicore models
   --
   procedure model1 (sys : out system);
   procedure model2 (sys : out system);

   -- DM global/multiprocessor scheduling
   -- to test job level task migration and time unit task migration
   -- example from the real time scheduling course of F. Singhoff
   --
   procedure global_dm_with_job_level_migration_scheduling (sys : out system);
   procedure global_dm_with_time_unit_level_migration_scheduling
     (sys : out system);

   -- Polling server
   --
   procedure polling1 (sys : out system);
   procedure polling2 (sys : out system);

   -- Deferrable server
   --
   procedure deferrable1 (sys : out system);
   procedure deferrable2 (sys : out system);

   -- Pfair scheduling
   -- example from the real time scheduling course of F. Singhoff
   procedure pf1 (sys : out system);

   ----------------------------------------------------
   -- Large tast set to stress Cheddar
   ----------------------------------------------------

   -- 100 tasks but one processor/core
   procedure task100 (sys : out system);

   -- 200 tasks and several processors/cores
   procedure task200 (sys : out system);

   ----------------------------------------------------
   -- Set of architecture to test XML printer/parser
   ----------------------------------------------------

   -- empty XML file
   procedure test1_xml (sys : out system);

   -- 2 cores only
   procedure test2_xml (sys : out system);

   -- 1 core/1 address space/several tasks
   procedure test3_xml (sys : out system);

   -- 2 core/1 address space/several tasks
   procedure test4_xml (sys : out system);

   -- 1 core/1 address space/several tasks with offsets
   procedure test5_xml (sys : out system);

   -- 2 cores with tasks and shared resources
   procedure test6_xml (sys : out system);

   -- 2 cores with tasks and buffers
   procedure test7_xml (sys : out system);

   -- 2 cores with tasks various task dependency
   procedure test8_xml (sys : out system);

   -- 1 core with tasks and users defined schedulers/user defined tasks
   -- and user defined parameters
   procedure test9_xml (sys : out system);

   -- 2 cores with tasks and messages
   procedure test10_xml (sys : out system);

   -- 2 mono core processors with tasks
   procedure test13_xml (sys : out system);

   -- csg example
   procedure csg_xml (sys : out system);

   -- csp example
   procedure csp_xml (sys : out system);

   -- network examples
   procedure test_network1_xml (sys : out system);
   procedure test_network2_xml (sys : out system);

   ----------------------------------------------------
   -- Set of architecture to test scheduling with offset
   ----------------------------------------------------

   -- Audsley set
   procedure offset_test1 (sys : out system);

   -- Audsley set with 3 transactions
   procedure offset_test2 (sys : out system);

   -- Audsley, same set as test2 but with 1 transaction after task
   --transformation
   procedure offset_test3 (sys : out system);

   ----------------------------------------------------
   -- Architectures to test cache behavior
   ----------------------------------------------------

   -- 2 cores with tasks and shared resources to test data cache access
   procedure cache1 (sys : out system);

   ----------------------------------------------------
   -- Architectures to handle ARINC 653 systems
   ----------------------------------------------------

   -- Cyclic hierarchical scheduler : each partition is activated one during a
   --given
   -- quantum
   --
   procedure arinc653_cyclic (sys : out system);

   -- off-line partition scheduling hierarchical scheduler : partitions are
   --activated
   -- according to a event table (off line scheduling)
   --
   procedure arinc653_offline (sys : out system);

end architecture_models;
