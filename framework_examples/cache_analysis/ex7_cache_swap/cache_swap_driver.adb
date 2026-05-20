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
--    $Date: 2020-07-13 10:35:38 +0200 (lun., 13 juil. 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Text_IO;                   use Ada.Text_IO;
with Cache_Access_Profile_Util;	    use Cache_Access_Profile_Util;
with Systems;                       use Systems;
with scheduling_simulation_util;    use scheduling_simulation_util;
with Ada.Strings.Unbounded;         use Ada.Strings.Unbounded;
with task_set;                      use task_set;
with Tasks;                         use Tasks;
with Caches;                        use Caches;
with cache_access_profile_set;      use cache_access_profile_set;
with cache_set;                     use cache_set;
with cache_utility;                 use cache_utility;
with unbounded_strings;             use unbounded_strings;


procedure cache_swap_driver
is
    a_system : System;
    a_task : Generic_Task_Ptr;   
    a_cache : Generic_Cache_ptr;
    my_tasks : Tasks_Set;
    my_iterator : Tasks_Iterator;
begin
    build_case_study_CAP(a_system);
    my_tasks := a_system.tasks;
    
    reset_iterator (a_system.tasks, my_iterator);
    loop
        current_element (a_system.tasks, a_task, my_iterator);

        Print_Task_CAP(a_task,a_system);
        Put_Line("");
      
        exit when is_last_element (a_system.tasks, my_iterator);
        next_element (a_system.tasks, my_iterator);
    end loop;
    
    a_cache := cache_set.search_cache(a_system.caches,To_Unbounded_String("Cache_01"));
    
    swap_tasks_cache_location(a_task       => Search_Task(a_system.Tasks,Suppress_Space(To_Unbounded_String("Task_1"))),
                              b_task       => Search_Task(a_system.Tasks,Suppress_Space(To_Unbounded_String("Task_3 "))),
                              CAPs         => a_system.Cache_Access_Profiles,
                              cache_blocks => a_cache.cache_blocks,
                              CS           => a_cache.cache_size);
    
    Put_Line("===");
    
    reset_iterator (a_system.tasks, my_iterator);
    loop
        current_element (a_system.tasks, a_task, my_iterator);

        Print_Task_CAP(a_task,a_system);
        Put_Line("");
      
        exit when is_last_element (a_system.tasks, my_iterator);
        next_element (a_system.tasks, my_iterator);
    end loop;
    
end cache_swap_driver;
