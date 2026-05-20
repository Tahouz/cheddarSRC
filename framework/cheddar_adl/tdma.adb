
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
--    $Date: 2023-09-29 16:02:19 +0200 (ven. 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with text_io; use text_io;

package body tdma is

  procedure display_set (my_task : in Generic_Task_Ptr) is
  begin
           put(to_string(my_task.name));
  end display_set;

  procedure  free_set (my_task : in out Generic_Task_Ptr) is
  begin
          null;
  end free_set;

  function copy_set(my_task : in Generic_Task_Ptr) return Generic_Task_Ptr  is
  begin
           return my_task;
  end copy_set;

  function xml_string (my_task : in Generic_Task_Ptr) return unbounded_string is
  begin
           return to_unbounded_string("");
  end xml_string;

  function xml_ref_string (my_task : in Generic_Task_Ptr) return unbounded_string is
  begin
           return to_unbounded_string("");
  end xml_ref_string;



  -- is it an empty TDMA frame ?
  --
  function is_empty(my_frame : in tdma_frame_type) return boolean is 
  not_empty : boolean:=false;
  begin
	for i in slot_id_type'range loop
		if (my_frame(i).duration/=0)
			then not_empty:=true;
		end if;
	end loop;
	return not not_empty;
  end is_empty;


procedure initialize(my_frame : out tdma_frame_type) is
begin
        for i in slot_id_type'range loop
                my_frame(i).start_time:=0;
                my_frame(i).duration:=0;
                my_frame(i).slot_id:=i;
      		initialize(my_frame(i).emitters);
        end loop;
end initialize;

function is_emitter_present
     (my_frame : in tdma_frame_type;
      slot_id  : in slot_id_type;
      name     : in Unbounded_String) return boolean is 

   my_iterator : tdma_set.iterator;
   a_task      : generic_task_ptr;

   begin

      if not is_empty (my_frame(slot_id).emitters) then

         reset_iterator (my_frame(slot_id).emitters, my_iterator);

         loop
            current_element (my_frame(slot_id).emitters, a_task, my_iterator);

            if (a_task.name = name) then
               return true;
            end if;

            exit when is_last_element (my_frame(slot_id).emitters, my_iterator);

            next_element (my_frame(slot_id).emitters, my_iterator);

         end loop;

      end if;

      return False;

end is_emitter_present;



end tdma;
