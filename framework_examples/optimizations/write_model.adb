
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

with Ada.Text_IO;		use Ada.Text_IO;
with Ada.Strings.Unbounded; 	use Ada.Strings.Unbounded;
with Statements;                        use Statements;
with Expressions;                       use Expressions;
with Systems; use Systems;
with Ada.Strings; use Ada.Strings;
with Task_Set; use Task_Set;
use Task_Set;
with Processors; use Processors;
with Processor_Set; use Processor_Set;
with Atomic_Operations; use Atomic_Operations;
with Partitioning_Algorithm_Set; use Partitioning_Algorithm_Set;
with optimization_services; use  optimization_services;
with partitioning_algorithms_model; use partitioning_algorithms_model;
with initialize_framework; use initialize_framework;
with Call_Framework; use Call_Framework;
with partitioning_Services; use partitioning_Services;



procedure write_model
   is
   output, sys			: System;
   My_Partitioning_Algorithms	: Partitioning_Algorithms_Set;
   My_Tasks			: Tasks_Set;
   Result_Task   		: Tasks_Set;
   My_Processors		: Processors_Set;
 --  A_Partitioning_Algorithm 	: Partitioning_Algorithm_ptr;
   New_Processor		: Integer :=1;
   New_Core			: Integer :=1;
   My_Core	   		: Core_Units_Set;
   msg				: Unbounded_String;


   begin
      Put_line ("=============================================");
      Put_line ("Export xml result from a test partitioning model");
      Put_line ("=============================================");
      Put_line("");
   Call_Framework.initialize (False);
   Initialize(sys);
   initialize(output);
	msg:= to_unbounded_string("Hello");
 	--  Input Task Set
   	build_tasks_set (output.Tasks);
   	build_processors_set(sys.Processors, sys.Core_units,New_Processor,New_Core);
   	Partition_Next_Fit(sys.Processors, output.Tasks, Msg, sys.Tasks);

	--  Partitioning Algorithm Model
  	--partitioning_first_fit(My_Partitioning_Algorithms ,A_Partitioning_Algorithm);

	--  Run Partitioning Algorithm with defined Model;
	--run_model (sys.Processors,My_Core,New_Processor,New_Core, sys.Tasks, output.Tasks, A_Partitioning_Algorithm);

      Write_To_Xml_File(sys,"model.xml");


      Put_line("");
      Put_line ("=============================================");
      Put_line ("Finish Running Algorithm");
      Put_line ("=============================================");
      Put_line("");

   end write_model;
