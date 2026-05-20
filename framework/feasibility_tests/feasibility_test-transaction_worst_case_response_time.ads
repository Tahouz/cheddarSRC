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

with unbounded_strings; use unbounded_strings;
with Objects;           use Objects;
with systems;           use systems;

package feasibility_test.transaction_worst_case_response_time is

   max_response_time : Double := Double'last;

   procedure audsley_compute_offset_response_time
     (my_task_groups : in     task_groups_set;
      processor_name : in     Unbounded_String;
      msg            : in out Unbounded_String;
      response_time  :    out response_time_table);

   procedure tindell_compute_offset_response_time
     (my_task_groups : in     task_groups_set;
      processor_name : in     Unbounded_String;
      msg            : in out Unbounded_String;
      response_time  :    out response_time_table);

   procedure palencia_compute_offset_response_time
     (my_task_groups : in     task_groups_set;
      processor_name : in     Unbounded_String;
      msg            : in out Unbounded_String;
      response_time  :    out response_time_table);

   procedure wcdops_plus
     (my_system               : in out system;
      msg                     : in out Unbounded_String;
      response_times          : in out response_time_table;
      stop_on_deadline_missed : in     Boolean := False);

   procedure wcdops_plus_nimp
     (my_system               : in out system;
      msg                     : in out Unbounded_String;
      response_times          : in out response_time_table;
      stop_on_deadline_missed : in     Boolean := False);

end feasibility_test.transaction_worst_case_response_time;
