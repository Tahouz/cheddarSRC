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

with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;

with Tasks;                     use Tasks;
with task_set;                  use task_set;
use task_set.generic_task_set;
with Task_Groups;               use Task_Groups;
with task_group_set;            use task_group_set;
with Resources;                 use Resources;
use Resources.Resource_Accesses;
with resource_set;              use resource_set;
use resource_set.generic_resource_set;
with Buffers;                   use Buffers;
use Buffers.Buffer_Roles_Package;
with buffer_set;                use buffer_set;
use buffer_set.generic_buffer_set;
with Messages;                  use Messages;
with message_set;               use message_set;
use message_set.generic_message_set;
with unbounded_strings;         use unbounded_strings;
with Framework_Config;          use Framework_Config;
with time_unit_events;          use time_unit_events;
use time_unit_events.time_unit_package;
with Scheduling_Analysis;       use Scheduling_Analysis;
with task_dependencies;         use task_dependencies;
use task_dependencies.half_dep_set;
with primitive_xml_strings;     use primitive_xml_strings;
with Scheduler_Interface;       use Scheduler_Interface;
with Processor_Interface;       use Processor_Interface;
with scheduler;                 use scheduler;
with doubles;                   use doubles;

with Unchecked_Deallocation;
with Ada.Finalization;
with indexed_tables;
with natural_util;
with access_lists;


package feasibility_test is

-- Exception raised when a feasibility test take too much computation time
--
   computation_time_exceeded : exception;

end feasibility_test;
