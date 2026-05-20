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

with Ada.Text_IO;                       use Ada.Text_IO;
with Cache_Access_Profile_Util;         use Cache_Access_Profile_Util;
with Scheduler.Fixed_Priority.Hpf;      use Scheduler.Fixed_Priority.Hpf;
with Task_Set;                          use Task_Set;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with Call_Framework_Interface;          use Call_Framework_Interface;
with Cache_Access_Profile_Set;          use Cache_Access_Profile_Set;
with Caches;                            use Caches;
with Scheduling_Analysis;               use Scheduling_Analysis;
with initialize_framework;              use initialize_framework;
with Caches;                            use Caches.Cache_Blocks_Table_Package;
with Cache_Block_Set;                   use Cache_Block_Set;
with Tasks;                             use Tasks;
with Feasibility_Test;                  use Feasibility_Test;
with Caches;                            use Caches.Cache_Blocks_Table_Package;
with Scheduling_Analysis;               use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with Feasibility_Interval_Util;         use Feasibility_Interval_Util;

procedure feasibility_interval_driver
is
    --Configuration for the task generator--------
    number_of_task        : Integer := 5;
    processor_utilization : Float := 0.70;
    cache_utilization     : Float := 2.0;
    reuse_factor          : Float := 0.3;
    cache_size            : Integer := 256;
begin
    test_feasibility_interval (file_name => To_Unbounded_String ("input.xml"),
			       N         => number_of_task,
			       PU        => processor_utilization,
			       CU        => cache_utilization,
			       CS        => cache_size,
			       RF        => reuse_factor);
end feasibility_interval_driver;
