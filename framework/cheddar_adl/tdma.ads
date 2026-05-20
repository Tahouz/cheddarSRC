
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
--    $Rev: 5132 $
--    $Date: 2024-08-27 00:52:35 +0200 (mar., 27 août 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with ada.strings.unbounded; use ada.strings.unbounded;

with Objects;  use Objects;
with Tasks;    use Tasks;
with Task_Set; use Task_Set;
use task_set.generic_task_set;

with version;           use version;
with unbounded_strings; use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with doubles; use doubles;
with sets;
with natural_util; use natural_util; 
with discrete_util; 



package tdma is


  procedure display_set (my_task : in Generic_Task_Ptr);
  procedure free_set (my_task : in out Generic_Task_Ptr);
  function  copy_set (my_task : in Generic_Task_Ptr) return Generic_Task_Ptr;
  function  xml_string (my_task : in Generic_Task_Ptr) return unbounded_string;
  function  xml_ref_string (my_task : in Generic_Task_Ptr) return unbounded_string;
   

  package tdma_set is new sets(100,Generic_Task_Ptr,display_set,free_set,copy_set,xml_string,xml_ref_string);
  use tdma_set;

  maximum_slot_number : constant integer := 64;

  type slot_id_type is new integer range 1..maximum_slot_number;

  type slot_type is record
          start_time : Natural :=0;
          duration : Natural   :=0;
          Slot_id  : slot_id_type :=1;
          emitters : tdma_set.set;
  end record;

  -- TDMA frame
  --
  type tdma_frame_type is array (slot_id_type'range) of slot_type;   



  -- is the TDMA frame empty ?
  --
  function is_empty(my_frame : in tdma_frame_type) return boolean;

  -- Check if a task is present in a TDMA slot
  --
  function is_emitter_present
     (my_frame : in tdma_frame_type;
      slot_id  : in slot_id_type;
      name     : in Unbounded_String) return boolean;

  -- Initialize a TDMA frame
  --
  procedure initialize(my_frame : out tdma_frame_type);



end tdma;

