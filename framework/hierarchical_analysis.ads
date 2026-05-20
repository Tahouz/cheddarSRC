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

with Text_IO;             use Text_IO;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

with Framework_Config;    use Framework_Config;
with translate;           use translate;
with unbounded_strings;   use unbounded_strings;
with scheduler;           use scheduler;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with Deployments;    use Deployments;
with deployment_set; use deployment_set;
use deployment_set.generic_deployment_set;
with systems;                   use systems;
with Tasks;                     use Tasks;
with Core_Units;                use Core_Units;
with Doubles;                   use Doubles;

package hierarchical_analysis is

   function compute_partition_internal_busy_period
     (deployment    : in generic_deployment_ptr;
      priority      :    priority_range;
      window        :    Double;
      bounded_tasks : in Boolean) return Double;

   function compute_partition_internal_gaps
     (deployment    : in generic_deployment_ptr;
      priority      :    priority_range;
      window        :    Double;
      bounded_tasks : in Boolean) return Double;

   function compute_server_interference
     (my_deployments : in deployments_set;
      taski_ptr      :    generic_task_ptr;
      window         :    Double;
      bounded_tasks  : in Boolean) return Double;

   function compute_wcrt
     (my_sys        : in system;
      taski_ptr     :    generic_task_ptr;
      bounded_tasks : in Boolean) return Double;

end hierarchical_analysis;
