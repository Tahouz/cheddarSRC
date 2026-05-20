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
with Tasks;				            use Tasks;
with Task_Set;                  	use Task_Set;
with Systems;                       use Systems;

package Buffer_Test_Case_Generator is

   procedure Add_Channel
     (Name           : in String;
      ProdRate       : in Integer;
      ConsRate       : in Integer;
      Source         : in String;
      Target         : in String;
      InitialToken   : in Integer;
      MaxSize        : in Integer;
      Sys            : in out System);
      
   procedure Case_Study_01;

   procedure Case_Study_02_Buffer_Initial_Data;

   procedure Case_Study_03_Buffer_Underflow;

   procedure Case_Study_04_Buffer_Overflow;

   procedure Case_Study_05_Discrete_Cosine_Transform;

   procedure Case_Study_06_Multi_Processor;

   procedure Case_Study_07_USCDF;

end Buffer_Test_Case_Generator;
