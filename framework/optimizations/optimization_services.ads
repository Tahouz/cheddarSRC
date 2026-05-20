
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

with Ada.Numerics;                      use Ada.Numerics;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Statements;                        use Statements;
with Expressions;                       use Expressions;
use Expressions.Variables_Type_Package;
with Ada.Strings.Unbounded.Text_IO;     use Ada.Strings.Unbounded.Text_IO;
with unbounded_strings;                 use unbounded_strings;
with Ada.IO_Exceptions;                 use Ada.IO_Exceptions;
with Ada.Integer_Text_IO;       	use Ada.Integer_Text_IO;
with Ada.Exceptions;                    use Ada.Exceptions;
with Text_IO;                           use Text_IO;
with Integer_Arrays;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Task_Set; use Task_Set;
with Processor_Set; use Processor_Set;
with Processors; use Processors;
with Tasks; use Tasks;
with Multiprocessor_Services; use Multiprocessor_Services;
with Framework_Config; use Framework_Config;
with Translate; use Translate;
with Systems; use Systems;
with Partitioning_Algorithm_Set; use Partitioning_Algorithm_Set;
with Atomic_Operations; use Atomic_Operations;


package optimization_services is

--      procedure create_new_core
--       (My_Processors : in out Processors_Set;
--        My_Core	    : in out core_units_Set;
--        New_Core      : in out Integer);

    procedure create_New_Processors
     (My_Processors 	: in out Processors_Set;
      My_Core	    	: in out Core_Units_Set;
      New_Processor  	: in out Integer;
      New_Core		: in out Integer);

    Procedure run_model
     (My_Processors 		: in out Processors_Set;
      My_Core			: in out core_units_Set;
      New_Processor 		: in out integer;
      New_Core			: in out Integer;
      My_Result_Tasks   	: in out Tasks_Set;
      My_Tasks      		: in Tasks_Set;
      A_Partitioning_Algorithm	: Partitioning_Algorithm_Ptr);


end optimization_services;

