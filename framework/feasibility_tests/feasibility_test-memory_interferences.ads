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

with Memories;   use Memories;
with memory_set; use memory_set;
use memory_set.generic_memory_set;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with Processors; use Processors;
with systems;    use systems;

package feasibility_test.memory_interferences is

-- Entry point of the package
-- Compute global interfernces of the memory banks
-- Compute min_delay, equation 10
--
   procedure memory_interferences_delay
     (min_delay   :    out Double;
      t           : in     Double;
      task_i      : in     generic_task_ptr;
      my_sys      : in     system;
      a_processor : in     Unbounded_String);

-- Compute rdp_inter, equation  1
--
   procedure maximum_interbank_interferences_memory_delay
     (rdp_inter   :    out Double;
      t           : in     Double;
      my_tasks    : in     tasks_set;
      a_processor : in     generic_processor_ptr;
      my_memory   : in     dram_memory_ptr);

-- Compute rdp_intra, equation  3
--
   procedure maximum_intrabank_interferences_memory_delay
     (rdp_intra   :    out Double;
      t           : in     Double;
      my_tasks    : in     tasks_set;
      a_processor : in     generic_processor_ptr;
      my_memory   : in     dram_memory_ptr);

-- Compute reorder_p, equation 4
   procedure queued_memory_request
     (reorder_p   :    out Double;
      t           : in     Double;
      my_tasks    : in     tasks_set;
      a_processor : in     generic_processor_ptr;
      my_memory   : in     dram_memory_ptr);

-- Compute rdp, equation 5
--
   procedure worst_case_per_request_interference_delay
     (rdp         :    out Double;
      t           : in     Double;
      my_tasks    : in     tasks_set;
      a_processor : in     generic_processor_ptr;
      my_memory   : in     dram_memory_ptr);

-- Compute apt, equation 6
--
   procedure maximum_number_of_memory_request
     (apt         :    out Double;
      t           : in     Double;
      my_tasks    : in     tasks_set;
      a_processor : in     generic_processor_ptr);

-- Compute jd_inter, equation 7
--
   procedure worst_case_interbank_interferences_delay
     (jd_inter    :    out Double;
      t           : in     Double;
      my_tasks    : in     tasks_set;
      a_processor : in     generic_processor_ptr;
      my_memory   : in     dram_memory_ptr);

-- Compute jd_intra, equation 8
--
   procedure worst_case_intrabank_interferences_delay
     (jd_intra    :    out Double;
      t           : in     Double;
      my_tasks    : in     tasks_set;
      a_processor : in     generic_processor_ptr;
      my_memory   : in     dram_memory_ptr);

-- Compute jd, equation 9
--
   procedure worst_case_interferences_delay
     (jd          :    out Double;
      t           : in     Double;
      my_tasks    : in     tasks_set;
      a_processor : in     generic_processor_ptr;
      my_memory   : in     dram_memory_ptr);

end feasibility_test.memory_interferences;
