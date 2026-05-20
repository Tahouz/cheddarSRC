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

with Ada.IO_Exceptions;      use Ada.IO_Exceptions;
with GNAT.Current_Exception; use GNAT.Current_Exception;
with unbounded_strings;      use unbounded_strings;
with GNAT.Command_Line;      use GNAT.Command_Line;
with GNAT.OS_Lib;            use GNAT.OS_Lib;
with Text_IO;                use Text_IO;
with version;                use version;
with Ada.Strings.Unbounded;  use Ada.Strings.Unbounded;
with systems;                use systems;
with task_set;               use task_set;
with processor_set;          use processor_set;
with address_space_set;      use address_space_set;
with resource_set;           use resource_set;
with buffer_set;             use buffer_set;
with call_framework;         use call_framework;
with Tasks;                  use Tasks;
use task_set.generic_task_set;

package feasibility_tests_for_time_triggered_communication is

   function function_case_1 (sys : system) return Boolean;
   function function_case_2 (sys : system) return Boolean;
   function function_case_3 (sys : system) return Boolean;
   function function_case_4 (sys : system) return Boolean;
   function function_case_5 (sys : system) return Boolean;
   function function_case_6 (sys : system) return Boolean;
   function function_case_7 (sys : system) return Boolean;
   function function_case_8 (sys : system) return Boolean;
   function function_case_9 (sys : system) return Boolean;
   function function_case_10 (sys : system) return Boolean;
   function function_case_11 (sys : system) return Boolean;
   function function_case_12 (sys : system) return Boolean;
   function function_case_13 (sys : system) return Boolean;
   function function_case_14 (sys : system) return Boolean;
   function function_case_15 (sys : system) return Boolean;
   function function_case_16 (sys : system) return Boolean;
   function function_case_17 (sys : system) return Boolean;
   function function_case_18 (sys : system) return Boolean;
   function function_case_19 (sys : system) return Boolean;
   function function_case_20 (sys : system) return Boolean;
   function function_case_21 (sys : system) return Boolean;
   function function_case_22 (sys : system) return Boolean;
   function function_case_23 (sys : system) return Boolean;
   function function_case_24 (sys : system) return Boolean;
   function function_case_25 (sys : system) return Boolean;
   function function_case_26 (sys : system) return Boolean;
   function function_case_27 (sys : system) return Boolean;
   function function_case_28 (sys : system) return Boolean;
   function function_case_29 (sys : system) return Boolean;
   function function_case_30 (sys : system) return Boolean;
   function function_case_31 (sys : system) return Boolean;
   function function_case_32 (sys : system) return Boolean;
   function function_case_33 (sys : system) return Boolean;
   function function_case_34 (sys : system) return Boolean;
   function function_case_35 (sys : system) return Boolean;
   function function_case_36 (sys : system) return Boolean;
   function function_case_37 (sys : system) return Boolean;
   function function_case_38 (sys : system) return Boolean;
   function function_case_39 (sys : system) return Boolean;
   function function_case_40 (sys : system) return Boolean;
   function function_case_41 (sys : system) return Boolean;
   function function_case_42 (sys : system) return Boolean;
   function function_case_43 (sys : system) return Boolean;
   function function_case_44 (sys : system) return Boolean;
   function function_case_45 (sys : system) return Boolean;
   function function_case_46 (sys : system) return Boolean;
   function function_case_47 (sys : system) return Boolean;
   function function_case_48 (sys : system) return Boolean;
   function function_case_49 (sys : system) return Boolean;
   function function_case_50 (sys : system) return Boolean;
   function function_case_51 (sys : system) return Boolean;
   function function_case_52 (sys : system) return Boolean;
   function function_case_53 (sys : system) return Boolean;
   function function_case_54 (sys : system) return Boolean;
   function function_case_55 (sys : system) return Boolean;
   function function_case_56 (sys : system) return Boolean;
   function function_case_57 (sys : system) return Boolean;
   function function_case_58 (sys : system) return Boolean;
   function function_case_59 (sys : system) return Boolean;
   function function_case_60 (sys : system) return Boolean;
   function function_case_61 (sys : system) return Boolean;
   function function_case_62 (sys : system) return Boolean;
   function function_case_63 (sys : system) return Boolean;
   function function_case_64 (sys : system) return Boolean;

end feasibility_tests_for_time_triggered_communication;
