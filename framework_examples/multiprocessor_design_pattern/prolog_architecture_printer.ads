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
--    $Rev: 4589 $
--    $Date: 2023-09-29 16:02:19 +0200 (ven., 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------


with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
with Messages;              use Messages;
with Message_Set;           use Message_Set;
use Message_Set.Generic_Message_Set;
with Buffers;               use Buffers;
with Buffer_Set;            use Buffer_Set;
use Buffer_Set.Generic_Buffer_Set;
with Tasks;                 use Tasks;
with Task_Groups;           use Task_Groups;
with Task_Set;              use Task_Set;
use Task_Set.Generic_Task_Set;
with Task_Group_Set;              use Task_Group_Set;
use Task_Group_Set.Generic_Task_Group_Set;
with Task_Dependencies;     use Task_Dependencies;
use Task_Dependencies.Half_Dep_Set;
with Core_Units;            use Core_Units;
with Processor_Set;         use Processor_Set;
with Processors;            use Processors;
use Processor_Set.Generic_Processor_Set;
use Processor_Set.Generic_core_unit_Set;
with scheduler_interface;            use scheduler_interface;
with Caches;                            use Caches;
with Cache_Set;                         use Cache_Set;
with Cache_Block_Set;                   use Cache_Block_Set;
with Cache_Access_Profile_Set;          use Cache_Access_Profile_Set;
with networks;   use networks;
with Network_Set;           use Network_Set;
use Network_Set.Generic_Network_Set;
with Address_Spaces;        use Address_Spaces;
with Address_Space_Set;     use Address_Space_Set;
use Address_Space_Set.Generic_Address_Space_Set;
with Resource_Set;          use Resource_Set;
use Resource_Set.Generic_Resource_Set;
with Resources;          use Resources;
with systems;            use systems;
with framework_config; use framework_config;
with lists;
with Ada.Finalization;


package prolog_architecture_printer is

      function produce_system(my_system : in System; File_Name : in Unbounded_String)  return unbounded_string;
      function Produce_Sw_archi(my_system : in system) return Unbounded_String;
      function produce_task(my_task : in tasks_set) return unbounded_string;
      function Produce_Processing_elements(My_Core_unit : in Core_units_set) return Unbounded_String;
      function Produce_DM_PE(my_task : in Tasks_Set; My_Processors : in Processors_Set) return Unbounded_String;
      function Produce_AM_time(My_Core_unit : in Core_units_set; My_Network : in Networks_set) return Unbounded_String;
      function Produce_A_type(My_Core_unit : in Core_units_set; My_Caches : in Caches_Set; My_Network : in Networks_set) return Unbounded_String;
      function Produce_A_PE(My_Core_unit : in Core_units_set) return Unbounded_String;
      function Produce_A_mem(My_Caches : in Caches_set; My_Core_unit : in Core_units_set; My_Processors : in Processors_Set) return Unbounded_String;
      function Produce_A_comm(My_Network : in Networks_set) return Unbounded_String;
      
      function Trans(Litteral : in Unbounded_String) return Unbounded_String;
      
      
      type Software_Architecture_type is (
	Sfw_Sync,	-- Synchronous data-flow
	Sfw_Rav,	-- Ravensar
	Sfw_Bb,		-- Bloackboard
	Sfw_Qb,		-- Queued Buffer
	Sfw_Upg,	-- Unplugged
	Sfw_Other	-- Non-standard software architecture
	); 

      type timing_interval is record
	offset : natural;
	end_time : natural;
	period : natural;
      end record;
      
      
      -- travail pour flm
      type Software_DP is	
      record
	 Name 			: Unbounded_String;
	 Software_Architecture  : Software_Architecture_type;
      end record;

      type Software_DP_Ptr is access all Software_DP;
      procedure put (e : in Software_DP_Ptr );
      procedure free (e : in out Software_DP_Ptr );
      function  xml_string (e : in Software_DP_Ptr) return Unbounded_String;

      package DP_List_Package is new lists (Software_DP_Ptr, put, free, xml_string);
      use  DP_List_Package;
      subtype DP_List is DP_List_Package.List;
      subtype DP_List_Ptr is DP_List_Package.List_Ptr;
      subtype DP_List_Iterator is DP_List_Package.Iterator;
      subtype DP_List_Iterator_Ptr is DP_List_Package.Iterator_Ptr;



      
     function Get_Software_Architecture_type (
	     	my_system : in system 
	     	) return DP_List;

     function produce_bus_timing_intervals(a_network : in Generic_Network_Ptr; a_core : Core_Unit_Ptr) return timing_interval;


end prolog_architecture_printer;
