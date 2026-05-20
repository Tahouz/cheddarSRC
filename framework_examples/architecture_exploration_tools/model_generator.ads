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
--    $Rev: 3542 $
--    $Date: 2020-10-02 10:33:28 +0200 (Fri, 02 Oct 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Paes.t2p_and_security;     use Paes.t2p_and_security;
with systems;                   use systems;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with unbounded_strings;         use unbounded_strings;
with Tasks;                     use Tasks;
with task_set;                  use task_set;
with Resources;                 use Resources;
with resource_set;              use resource_set;
with scheduler;                 use scheduler;
with Scheduler_Interface;       use Scheduler_Interface;
with Framework_Config;          use Framework_Config;

-- This package defines subprograms needed
-- to instanciate PAES for the Functions-to-Tasks (F2T)
-- architecture exploration problem
--
package model_generator is

   procedure generator_model_Uunifast
     (a_solution            : in solution_t2p;
      nb_partitions         : in Integer;
      N_diff_periods        : in Integer;
      Total_cpu_utilization : in Float);
   -- This procedure duplicate the system in order to ensure safety
   -- by assigning two instance of the same partition to different partitions
   procedure Task_duplicate;
end model_generator;
