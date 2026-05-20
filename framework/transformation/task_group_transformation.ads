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

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with unbounded_strings;     use unbounded_strings;
with Framework_Config;      use Framework_Config;
with resource_set;          use resource_set;
with Tasks;                 use Tasks;
with Task_Groups;           use Task_Groups;
with task_set;              use task_set;
with Parameters;            use Parameters;
with Parameters.extended;   use Parameters.extended;
use Parameters.User_Defined_Parameters_Table_Package;
with Offsets;               use Offsets;
with Offsets.extended;      use Offsets.extended;
use Offsets.Offsets_Table_Package;
with systems;               use systems;
with Doubles;               use Doubles;

with sets;

package task_group_transformation is
   -- Exceptions
   deadline_violated : exception;

   ----------------------------------------------------------
   -- Transformation procedures
   ----------------------------------------------------------

   procedure multiframe_to_transaction
     (my_multiframe : in     multiframe_task_group_ptr;
      a_system      : in out system);

   procedure merge_transactions (a_system : in out system);

   procedure modify_offsets (a_system : in out system);

   procedure multiframe_to_transaction_sys
     (my_system : in out system;
      a_system  : in out system);

   procedure multiframe_to_transaction_sys_crossref
     (my_system : in out system;
      a_system  : in out system;
      merge     : in     Boolean := False);

   procedure add_delta_tasks (my_system : in out system);

   procedure delete_delta_tasks (my_system : in out system);

   procedure add_root_tasks (my_system : in out system);

end task_group_transformation;
