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

------------------------------------------------------------------------------


with Text_IO;               use Text_IO;
with unbounded_strings;     use unbounded_strings;
with Ada.Strings;           use Ada.Strings;
with Ada.Strings.Maps.Constants; use Ada.Strings.Maps.Constants;
with Ada.Finalization;      use Ada.Finalization;

with systems;               use systems;
with Tasks;                 use Tasks;
with Task_Groups;           use Task_Groups;
with Task_Set;              use Task_Set;
with Core_Units;            use Core_Units;
use core_units.Core_Units_Table_Package;
with Processor_Set;         use Processor_Set;
with Processors;            use Processors;
with processor_interface;   use processor_interface;
with Caches;                use Caches;
with architecture_analyzer; use architecture_analyzer;
with Cache_Set;             use Cache_Set;
with Networks;              use Networks;
with Network_Set;           use Network_Set;
use Network_Set.Generic_Network_Set;
with standards_io;          use standards_io;
use standards_io.natural_io;
use standards_io.double_io;

with lists; 

package body prolog_architecture_printer is


procedure put (e : in Software_DP_Ptr ) is
begin
	null;
end put;

procedure free (e : in out Software_DP_Ptr ) is 
begin
	null;
end free;

function  xml_string (e : in Software_DP_Ptr) return Unbounded_String is
	result : Unbounded_String := empty_string;
begin
	return result;
end xml_string;

      use  DP_List_Package;


--  pour tests van, à supprimer après écriture fonction Frank !!!!!!!!!!!
-- warning: all generated idents (in the ecl file) need to start with a lowercase letter (Prolog constant syntax)
function Trans(Litteral : in Unbounded_String) return Unbounded_String is
   Result : Unbounded_String;
   I : Natural;
begin
   Result := Translate(Litteral,Ada.Strings.Maps.Constants.Lower_Case_Map);
   loop
      I := Index(Result,".");
      if I = 0 
      then exit;
      else 
	 Replace_Element(Result,I,'_'); 
	 Insert(Result,I,"__dot_");
      end if;
   end loop;
   
   return Result;
end Trans;


function produce_system(my_system : in System; File_Name : in Unbounded_String) return unbounded_string is
   result : unbounded_string := empty_string;
   File_Name2 : String := To_String(File_Name);
   File_Name3 : Unbounded_String := Empty_String;
   Last_Point : Integer := 1 + File_Name2'length;
begin
   
   for I in File_Name2'Range loop
      if File_Name2(I) = '.'
      then Last_point := i;
      end if;
   end loop;
   for I in File_Name2'Range loop
      if File_Name2(I) = '/'
      then File_Name3 := Empty_String;
      else 
	 if I < Last_point
	 then File_Name3 := File_Name3 & File_Name2(I);
	 else exit;
	 end if;
      end if;
   end loop;
   result := "archi_model_spec(" & '"' & File_Name3 & '"' & ",L) :-" & unbounded_lf;
   
   result := result & "L = [ " & Produce_Sw_archi(my_system);
   result := result & produce_task(my_system.tasks);
   result := result & produce_Processing_elements(my_system.Core_units);
   result := result & Produce_DM_PE(my_system.Tasks, my_system.Processors);
   result := result & Produce_AM_time(my_system.Core_Units, my_system.Networks);
   result := result & Produce_A_type(my_system.Core_units, my_system.Caches, my_system.Networks);
   result := result & Produce_A_PE(my_system.Core_units);
   result := result & Produce_A_mem(my_system.Caches, my_system.Core_units, my_system.Processors);
   result := result & Produce_A_comm(my_system.Networks);
   result := result & "end_with_success ]." & unbounded_lf;

   return result;
end produce_system;

-- Stephane : the names of software pattern should be changed to 
--   replace LOGiciel par SoFtWare
function Produce_Sw_archi(my_system : in system) return unbounded_string is
   result 			: unbounded_string := empty_string;
   Software_Architectures	: DP_List; 
   Software_Architectures_Iter  : DP_List_Iterator; 
   Current_DP_Ptr		: Software_DP_Ptr;

begin
   Software_Architectures := Get_Software_Architecture_type(my_system); 
   reset_head_iterator (Software_Architectures, Software_Architectures_Iter);
   if not is_empty (Software_Architectures) then
        loop
              	current_element (Software_Architectures, current_DP_Ptr, Software_Architectures_Iter);
		result := result & "sw_archi(" & current_DP_Ptr.Name & ")," & unbounded_lf;
           	exit when is_tail_element (Software_Architectures, Software_Architectures_Iter);
		next_element (Software_Architectures, Software_Architectures_Iter);
	end loop;
   end if;

--    case A_Sw_Archi_Type is
--       when Sfw_Sync => result := "sw_archi(log_sync)," & unbounded_lf;
--       when Sfw_Rav => result := "sw_archi(log_rav)," & unbounded_lf;
--       when Sfw_Bb => result := "sw_archi(log_bb)," & unbounded_lf;
--       when Sfw_Qb => result := "sw_archi(log_qb)," & unbounded_lf;
--       when Sfw_Upg => result := "sw_archi(log_upg)," & unbounded_lf;
--       when Sfw_Other => result := "sw_archi(log_other)," & unbounded_lf;
--    end case;
   
   return result;
end Produce_Sw_archi;


function produce_task(my_task : in tasks_set) return unbounded_string is
     result : unbounded_string := empty_string;
     My_Iterator : Tasks_Iterator;
     A_Task      : Generic_Task_Ptr;
   begin

      reset_iterator (My_Task, My_Iterator);
      loop
         current_element (My_Task, A_Task, My_Iterator);

         if (result /= empty_string)
           then  result := result & ", ";
         end if;
         result := result & A_Task.Name; 

         exit when is_last_element (My_Task, My_Iterator);
         next_element (My_Task, My_Iterator);
      end loop;

      result := "tasks([" & Result & "])," & unbounded_lf;
      Result := Trans(Result);

      return result;
end produce_task;


function Produce_Processing_elements(My_Core_unit : in Core_units_set) return unbounded_string is
   result : unbounded_string := empty_string;
   result2 : unbounded_string := empty_string;
   result3 : unbounded_string := empty_string;
   My_Iterator : Core_units_Iterator;
   A_Core_unit : Core_Unit_ptr;
begin

     reset_iterator (My_Core_unit, My_Iterator);
      loop
         current_element (My_Core_unit, A_Core_unit, My_Iterator);

         if (result /= empty_string)
           then  result := ", " & result;
                 result3 := "," & result3;
         end if;

         result := A_Core_unit.Name & result;

         result2 := "pe_use_res(" & A_Core_unit.Name & ",["& A_Core_unit.L1_Cache_System_Name & "])," & Unbounded_Lf & result2;

         result3 := "(" & A_Core_unit.Name & ",["& A_Core_unit.L1_Cache_System_Name & "])" & result3;

         exit when is_last_element (My_Core_unit, My_Iterator);
         next_element (My_Core_unit, My_Iterator);
      end loop;

      result := "processing_elements([" & result & "])," & unbounded_lf;
      result3 := "pe_use_res_list([" & result3 & "])," & unbounded_lf;
      result := result & result2 & result3;
      Result := Trans(Result);

      return result;
end Produce_Processing_elements;


function Produce_DM_PE(my_task : in Tasks_Set; My_Processors : in Processors_Set)
                      return unbounded_string is
   result : unbounded_string := empty_string;
   result2 : unbounded_string := empty_string;
   result2b : unbounded_string := empty_string;
   result3 : unbounded_string := empty_string;
   My_Iterator : Tasks_Iterator;
   A_Task      : Generic_Task_Ptr;
   A_Processor : Generic_Processor_Ptr;
   A_Core : Core_Unit_Ptr;
   My_Core_Table : Core_Units_Table;
   My_Scheduling : Scheduling_Parameters;
begin

      reset_iterator (My_Task, My_Iterator);
      loop
         current_element (My_Task, A_Task, My_Iterator);
         A_Processor := Search_Processor(My_Processors,A_Task.Cpu_Name);
         if A_Processor.Processor_Type = Monocore_type
	 then
	    A_Core := Mono_Core_Processor_Ptr(A_Processor).Core;
	    result := result & "dm_PE_actual(" & A_Task.Name & "," & A_core.name & ")," & unbounded_lf;
	    
	    result2 := result2 & "dm_PE_allowed(" & A_Task.Name & ",[" & A_core.name & "])," & unbounded_lf;
	    
	    My_Scheduling := A_Core.Scheduling;
	    result3 := result3 & "dm_PE_scheduling(" & A_core.Name & "," & A_task.name & ", sched(" & My_Scheduling.Scheduler_type'img & "," & My_Scheduling.preemptive_type'img & "))," & unbounded_lf;
	 else 
	    My_Core_Table := Multi_Cores_Processor_Ptr(A_Processor).Cores;
	    for i in 0..My_Core_Table.nb_entries-1 loop
	       A_Core := my_Core_Table.Entries(i);
	       if (result2b /= empty_string)
	       then  result2b := result2b & ", ";
	       end if;
	       result2b := result2b & A_core.name;
	       My_Scheduling := A_Core.Scheduling;
	       result3 := result3 & "dm_PE_scheduling(" & A_core.Name & "," & A_task.name & ", sched(" & My_Scheduling.Scheduler_type'img & "," & My_Scheduling.preemptive_type'img & "," & A_Processor.Migration_Type'Img & "))," & unbounded_lf;   
	    end loop;
	    Result2 := result2 & "dm_PE_allowed(" & A_Task.Name & ",[" & result2b & "])," & unbounded_lf;
	 end if;
	 Result2b := Empty_String;
	 
         exit when is_last_element (My_Task, My_Iterator);
         next_element (My_Task, My_Iterator);
      end loop;

      result := result & Result2 & result3;
      Result := Trans(Result);
      return result;
end Produce_DM_PE;


function Produce_AM_time(My_Core_unit : in Core_units_set; My_Network : in Networks_set) return Unbounded_String is 
   result : unbounded_string := empty_string;
   My_Bus_Iterator : Networks_Iterator;
   Mb : Generic_Network_Ptr; 
   My_Iterator : Core_units_Iterator;
   A_Core_unit : Core_Unit_ptr;
   ti : timing_interval;
begin  
   if not is_empty(My_network) then
      reset_iterator (My_Network, My_Bus_Iterator);
      loop
	 current_element (My_Network, mb, My_Bus_Iterator);
	 
	 reset_iterator (My_Core_unit, My_Iterator);
	 loop
	    current_element (My_Core_unit, A_Core_unit, My_Iterator);
	    
	    ti := produce_bus_timing_intervals(mb,A_Core_unit);
	    result := result & "am_time(" & A_Core_unit.Name & "," & Mb.Name & "," & "interval(" & integer'Image(ti.Offset) & "," & integer'Image(ti.End_Time) & "," & integer'Image(ti.Period) & "))," & unbounded_lf;
	    
	    exit when is_last_element (My_Core_unit, My_Iterator);
	    next_element (My_Core_unit, My_Iterator);
	 end loop;
	 
	 exit when is_last_element (My_Network, My_Bus_Iterator);
	 next_element (My_Network, My_Bus_Iterator);
      end loop;
   end if;
   
   Result := Trans(Result);
   return Result;
end Produce_AM_time;


function Produce_A_type(My_Core_unit : in Core_units_set; My_Caches : in Caches_Set; My_Network : in Networks_set)
                          return unbounded_string is
   result : unbounded_string := empty_string;
   result2 : unbounded_string := empty_string;
   result3 : unbounded_string := empty_string;
   My_Iterator : Core_units_Iterator;
   A_Core_unit : Core_Unit_ptr;
   My_Iterator2 : Caches_Iterator;
   A_Cache : Generic_Cache_Ptr;
   My_Iterator3 : Networks_Iterator;
   A_Network : generic_network_ptr;
begin
   
   reset_iterator (My_Core_unit, My_Iterator);
   loop
      current_element (My_Core_unit, A_Core_unit, My_Iterator);
      
      result := result & "a_type(" & A_Core_unit.Name & ",processing)," & unbounded_lf;
      
      exit when is_last_element (My_Core_unit, My_Iterator);
      next_element (My_Core_unit, My_Iterator);
   end loop;
   
   if not is_empty(My_Caches) then
      reset_iterator (My_Caches, My_Iterator2);
      loop
	 current_element (My_Caches, A_Cache, My_Iterator2);
	 
	 Result2 := result2 & "a_type(" & A_Cache.Name & ",memory)," & unbounded_lf;
	 
	 exit when is_last_element (My_Caches, My_Iterator2);
	 next_element (My_Caches, My_Iterator2);
      end loop;
   end if;
   
   if not is_empty(My_network) then
      reset_iterator (My_Network, My_Iterator3);
      loop
	 current_element (My_Network, A_Network, My_Iterator3);
	 
	 result3 := result3 & "a_type(" & A_Network.Name & ",interconnection)," & unbounded_lf;
	 
	 exit when is_last_element (My_Network, My_Iterator3);
	 next_element (My_Network, My_Iterator3);
      end loop;
   end if;
   
   result := result & result2 & result3;
   Result := Trans(Result);
   
   return result;
end Produce_A_type;


function Produce_A_PE(My_Core_unit : in Core_units_set) return unbounded_string is
   result : unbounded_string := empty_string;
   result2 : unbounded_string := empty_string;
   My_Iterator : Core_units_Iterator;
   A_Core_unit : Core_Unit_ptr;
begin

   reset_iterator (My_Core_unit, My_Iterator);
   loop
      current_element (My_Core_unit, A_Core_unit, My_Iterator);

      result := "a_PE_isa(" & A_Core_unit.Name & "," & A_Core_unit.Isa'img & ")," & Unbounded_Lf & result;

      result2 := "a_PE_speed(" & A_Core_unit.Name & "," & A_Core_unit.Speed'img & ")," & Unbounded_Lf & result2;

      exit when is_last_element (My_Core_unit, My_Iterator);
      next_element (My_Core_unit, My_Iterator);
   end loop;

   result := result & result2;
   Result := Trans(Result);
   
   return result;
end Produce_A_PE;


function Produce_A_mem(My_Caches : in Caches_Set; My_Core_unit : in Core_units_set; My_Processors : in Processors_Set)
                      return unbounded_string is
   result : unbounded_string := empty_string;
   result2 : unbounded_string := empty_string;
   result3 : unbounded_string := empty_string;
   result4 : unbounded_string := empty_string;
   result5 : unbounded_string := empty_string;
   result6 : unbounded_string := empty_string;
   My_Iterator : Caches_Iterator;
   A_Cache : Generic_Cache_Ptr;
   My_Iterator_core : Core_units_Iterator;
   A_Core_unit : Core_Unit_ptr;
   My_Iterator_processor : processors_Iterator;
   A_Processor : Generic_Processor_Ptr;
   A_Multicore_processor : Multi_Cores_Processor_Ptr;
begin
   
   if not is_empty(My_Caches) then
      reset_iterator (My_Core_unit, My_Iterator_core);
      loop
	 current_element (My_Core_unit, A_Core_unit, My_Iterator_core);
	 
	 result3 := result3 & "a_mem_cache_level(" & A_Core_unit.L1_Cache_System_Name & ",1)," & unbounded_lf;
	 
	 exit when is_last_element (My_Core_unit, My_Iterator_core);
	 next_element (My_Core_unit, My_Iterator_core);
      end loop;
      
      reset_iterator (My_processors, My_Iterator_processor);
      loop
	 current_element (My_processors, A_processor, My_Iterator_processor);
	 
	 if (A_Processor.processor_type /= Monocore_type)
	 then
	    A_Multicore_processor := Multi_Cores_Processor_Ptr(A_Processor);
	    
	    result3 := result3 & "a_mem_cache_level(" & A_Multicore_processor.L2_Cache_System_Name & ",2)," & unbounded_lf;
	 end if;
	 
	 exit when is_last_element (My_processors, My_Iterator_processor);
	 next_element (My_processors, My_Iterator_processor);
      end loop;
      
      reset_iterator (My_Caches, My_Iterator);
      loop
	 current_element (My_Caches, A_Cache, My_Iterator);
	 result := result & "a_mem_type(" & A_Cache.Name & "," & A_Cache.cache_category'img & ")," & unbounded_lf;
	 
	 result2 := result2 & "a_mem_cache_associativity(" & A_Cache.Name & "," & Integer'Image(A_Cache.Associativity) & ")," & unbounded_lf;
	 
	 result4 := result4 & "a_mem_cache_size(" & A_Cache.Name & "," & Integer'Image(A_Cache.Cache_Size) & ")," & unbounded_lf;
	 
	 result5 := result5 & "a_mem_cache_line_size(" & A_Cache.Name & "," & Integer'Image(A_Cache.Line_Size) & ")," & unbounded_lf;
	 
	 result6 := result6 & "a_mem_cache_miss_time(" & A_Cache.Name & "," & Integer'Image(A_Cache.Block_Reload_Time) & ")," & unbounded_lf;
	 
	 exit when is_last_element (My_Caches, My_Iterator);
	 next_element (My_Caches, My_Iterator);
      end loop;
   end if;
   
   result := result & Result2 & Result3 & Result4 & Result5 & result6;
   Result := Trans(Result);
   
   return result;
end Produce_A_mem;


function Produce_A_comm(My_Network : in Networks_set) return unbounded_string is
   result : unbounded_string := empty_string;
   My_Iterator : Networks_Iterator;
   A_Network : generic_network_ptr;
begin
   if not is_empty(My_network) then
      reset_iterator (My_Network, My_Iterator);
      loop
      	 current_element (My_Network, A_Network, My_Iterator);
	 
	 result := result & "a_comm_type(" & A_Network.Name & "," & A_Network.Network_Architecture_Type'Img & ")," & unbounded_lf;
	 
      	 exit when is_last_element (My_Network, My_Iterator);
      	 next_element (My_Network, My_Iterator);
      end loop;
   end if;
   
   Result := Trans(Result);
   return result;
end Produce_A_comm;


function Get_Software_Architecture_type(my_system : in system) return DP_list is
   Software_Architectures 	: DP_List; 
   A_Software_Architecture 	: Software_DP_Ptr;
   DP_found 			: Boolean := false;
begin
   if ravenscar_bool(my_system) then
	A_Software_Architecture := new Software_DP;
	A_Software_Architecture.name := to_unbounded_string("SFW_RAV");
	A_Software_Architecture.Software_Architecture := Sfw_Rav;
	Add( Software_Architectures, A_Software_Architecture );
	DP_found := true;
   end if;
   if unplugged_bool(my_system) then
	A_Software_Architecture := new Software_DP;
	A_Software_Architecture.name := to_unbounded_string("SFW_UPG");
	A_Software_Architecture.Software_Architecture := Sfw_Upg;
	Add( Software_Architectures, A_Software_Architecture );
	DP_found := true;
   end if;
   if time_triggered_communication_bool(my_system) then
	A_Software_Architecture := new Software_DP;
	A_Software_Architecture.name := to_unbounded_string("SFW_SYNC");
	A_Software_Architecture.Software_Architecture := Sfw_Sync;
	Add( Software_Architectures, A_Software_Architecture );
	DP_found := true;
   end if;
   if queuedbuffer_bool(my_system) then
	A_Software_Architecture := new Software_DP;
	A_Software_Architecture.name := to_unbounded_string("SFW_QB");
	A_Software_Architecture.Software_Architecture := Sfw_Qb;
	Add( Software_Architectures, A_Software_Architecture );
	DP_found := true;
   end if;
   if blackboard_bool(my_system) then
	A_Software_Architecture := new Software_DP;
	A_Software_Architecture.name := to_unbounded_string("SFW_BB");
	A_Software_Architecture.Software_Architecture := Sfw_Bb;
	Add( Software_Architectures, A_Software_Architecture );
	DP_found := true;
   end if;
   if not DP_Found then
	A_Software_Architecture := new Software_DP;
	A_Software_Architecture.name := to_unbounded_string("SFW_OTHER");
	A_Software_Architecture.Software_Architecture := Sfw_Other;
	Add( Software_Architectures, A_Software_Architecture );
   end if;
   return Software_Architectures;
end Get_Software_Architecture_Type;





function produce_bus_timing_intervals(a_network : in Generic_Network_Ptr; a_core : Core_Unit_Ptr ) return  timing_interval is
   ti : timing_interval;
begin
	ti.offset:=0;
        ti.period:=1000;
        ti.end_time:=500;
	return ti;
end produce_bus_timing_intervals; 



end prolog_architecture_printer;
