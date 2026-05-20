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
--    $Rev: 4720 $
--    $Date: 2023-12-19 15:31:20 +0100 (mar., 19 déc. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with systems;                  use systems;
with Call_Framework_Interface; use Call_Framework_Interface;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package call_network_framework is

   procedure compute_noc_communication_delay
     (sys    : in System; result : in out Unbounded_String;
      output : in Output_Format := String_Output);

   procedure compute_noc_path_delay
     (sys    : in System; result : in out Unbounded_String;
      output : in Output_Format := String_Output);

   procedure compute_noc_direct_interference_delay
     (sys    : in System; result : in out Unbounded_String;
      output : in Output_Format := String_Output);

   procedure compute_noc_indirect_interference_delay
     (sys    : in System; result : in out Unbounded_String;
      output : in Output_Format := String_Output);

   procedure compute_ectm_saf_transformation
     (sys : in System; result : in out Unbounded_String; update : in Boolean;
      output : in Output_Format := String_Output);

   procedure compute_ectm_wormhole_transformation
     (sys : in System; result : in out Unbounded_String; update : in Boolean;
      output : in Output_Format := String_Output);

   procedure compute_wcctm_saf_transformation
     (sys : in System; result : in out Unbounded_String; update : in Boolean;
      output : in Output_Format := String_Output);

   procedure compute_wcctm_wormhole_transformation
     (sys : in System; result : in out Unbounded_String; update : in Boolean;
      output : in Output_Format := String_Output);

   procedure compute_spacewire_scm_transformation
     (sys    : in out System; result : in out Unbounded_String;
      update : in     Boolean; output : in Output_Format := String_Output);

end call_network_framework;
