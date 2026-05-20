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

with task_set;         use task_set;
with task_set;         use task_set.generic_task_set;
with integer_arrays;   use integer_arrays;
with Doubles;          use Doubles;

package Buffers.extended is

   function is_cons_prod_harmonic
     (my_buff  : in buffer_ptr;
      my_tasks : in tasks_set) return Boolean;

   flow_constraint_not_respected : exception;
   task_model_error : exception;

   procedure buffer_flow_control
     (my_buff   : in     buffer_ptr;
      my_tasks  : in     tasks_set;
      flow_cons : in out Double;
      flow_prod : in out Double);

   ----------------------------------------------------
   --
   ----------------------------------------------------
   type amplitude_function;
   type amplitude_function_ptr is access all amplitude_function'class;
   type amplitude_function is tagged record
      u_array : integer_array;
      v_array : integer_array;
   end record;

   function get_amplitude_function
     (str : in String) return amplitude_function_ptr;

   function get_data_size
     (amplitude_function_str : in String;
      activation_number      : in Integer) return Integer;

end Buffers.extended;
