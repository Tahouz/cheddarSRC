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
--    $Rev: 4714 $
--    $Date: 2023-12-18 00:07:26 +0100 (lun., 18 déc. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Call_Framework_Interface; use Call_Framework_Interface;
with Processors;               use Processors;
with processor_set;            use processor_set;
use processor_set.generic_processor_set;
with systems;               use systems;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package call_dependency_framework is

   procedure chetto_parameter_modifications
     (sys                : in out System; result : in out Unbounded_String;
      a_processor : in generic_processor_ptr; compute_deadlines : in Boolean;
      compute_priorities : in     Boolean; update_tasks_set : in Boolean;
      output             : in     Output_Format := String_Output);

   procedure compute_end_to_end_response_time
     (sys              : in out System; result : in out Unbounded_String;
      update_tasks_set : in     Boolean; one_step : in Boolean;
      output           : in     Output_Format := String_Output);

end call_dependency_framework;
