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
--    $Rev: 4589 $
--    $Date: 2023-09-29 16:02:19 +0200 (ven., 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Text_IO;                   	use Text_IO;
with Ada.Strings.Unbounded;     	use Ada.Strings.Unbounded;
with Tasks;				use Tasks;
with Task_Set;                  	use Task_Set;
with Offsets;				use Offsets;
with Offsets;				use Offsets.Offsets_Table_Package;
with Offsets.extended;			use Offsets.extended;
with Tasks; 				use Tasks;
with Systems; 				use Systems;
with CFG_Node_Set.Basic_Block_Set; 	use CFG_Node_Set.Basic_Block_Set;
with Tables;
with sets;

package test_case_generator is

   procedure generate_system_with_cache_and_cfg;

   procedure read_system_with_cache_and_cfg;

   procedure generate_system_with_harmonic_tasks_and_CAP
     (file_name                 : in Unbounded_String;
      N                		: in Integer	:= 10;
      PU 	       		: in Float	:= 0.70;
      CU 	       		: in Float	:= 5.0;
      CS       	       		: in Integer	:= 256;
      RF	       		: in Float	:= 0.3;
      a_system 			: out System);

   procedure generate_system_with_periodic_tasks_and_CAP
     (file_name                 : in Unbounded_String;
      Min_Period		: in Integer 	:= 10;
      Max_Period		: in Integer    := 500;
      N                		: in Integer	:= 10;
      PU 	       		: in Float	:= 0.70;
      CU 	       		: in Float	:= 5.0;
      CS       	       		: in Integer	:= 256;
      RF	       		: in Float	:= 0.3;
      a_system 			: out System);

end test_case_generator;
