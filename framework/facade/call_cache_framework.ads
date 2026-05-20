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
--    $Rev: 4714 $
--    $Date: 2019-08-27 15:21:33+02:00
--    $Author: nam $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with systems;                  use systems;
with Call_Framework_Interface; use Call_Framework_Interface;
with Processors;               use Processors;
with processor_set;            use processor_set;
with processor_set;            use processor_set.generic_processor_set;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with sets;

package call_cache_framework is

   -------------------------------------
   -- Compute the cache access profile of tasks in the systems
   -- - Set of UCBs of a task
   -- - Set of ECBs of a task
   -- Add: a Cache_Acess_Profile to System.Cache_Access_Profiles with name: "task_name_cap"
   -- Modify: a_task.cache_access_profile_name --> "task_name_cap".
   -- If Import_CFG: CFGs are read from external files specified by the attribute task.cfg_name
   -------------------------------------
   procedure compute_tasks_cache_access_profile
     (sys    : in out System; a_processor : in generic_processor_ptr;
      result : in out Unbounded_String;
      output : in     Output_Format := String_Output);

   -------------------------------------
   -- Import CFGs from external sources
   -- A CFG is specified by a task's attribute: cfg_name
   -------------------------------------
   procedure import_cfg
     (sys    : in out System; a_processor : in generic_processor_ptr;
      result : in out Unbounded_String;
      output : in     Output_Format := String_Output);

end call_cache_framework;
