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
--    $Rev: 1249 $
--    $Date: 2014-08-28 07:02:15 +0200 (Fri, 28 Aug 2014) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

package scheduling_options is

   type scheduling_option is record
      with_offsets                  : Boolean := True;
      with_precedencies             : Boolean := True;
      with_resources                : Boolean := True;
      with_jitters                  : Boolean := True;
      with_crpd                     : Boolean := False;
      with_minimize_preemption      : Boolean := False;
      with_anomaly_detection        : Boolean := False;
      with_dvfs                     : Boolean := False;
      with_task_specific_seed       : Boolean := True;
      with_task_groups              : Boolean := False;
      global_seed_value             : Integer := 0;
      predictable_global_seed       : Boolean := True;
      with_discard_missed_deadlines : Boolean := False;
      with_energy                   : Boolean := True;
      with_mode_change              : Boolean := True;
      with_tdma_slot                : Boolean := True;
   end record;

end scheduling_options;
