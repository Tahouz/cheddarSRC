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
--    $Rev: 3477 $
--    $Date: 2020-07-13 11:43:48 +0200 (Mon, 13 Jul 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with random_tools; use random_tools;
with Ada.Float_Text_IO;

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
with convert_unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
use unbounded_strings.strings_table_package;
with Ada.Strings;              use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;

with architecture_factory; use architecture_factory;

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO;   use Ada.Float_Text_IO;

with task_set;            use task_set;
with Tasks;               use Tasks;
with systems;             use systems;
with Processors;          use Processors;
with processor_set;       use processor_set;
with Processor_Interface; use Processor_Interface;

with Core_Units; use Core_Units;
use Core_Units.Core_Units_Table_Package;
with Scheduler_Interface; use Scheduler_Interface;

with Address_Spaces;    use Address_Spaces;
with address_space_set; use address_space_set;

with call_framework;           use call_framework;
with Call_Framework_Interface; use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with call_scheduling_framework; use call_scheduling_framework;

with natural_util; use natural_util;
with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;

with pipe_commands;            use pipe_commands;
with Ada.Text_IO;              use Ada.Text_IO;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with unbounded_strings;        use unbounded_strings;
with convert_unbounded_strings;
with Ada.Directories;          use Ada.Directories;

with debug; use debug;

with integer_util; use integer_util;

with Resources; use Resources;
use Resources.Resource_Accesses;
with float_util;        use float_util;
with Dependencies;      use Dependencies;
with task_dependencies; use task_dependencies;
with task_dependencies; use task_dependencies.half_dep_set;

with MILS_Security; use MILS_Security;
with result_parser; use result_parser;
with mils_analysis; use mils_analysis;
package body Paes.objective_functions is

   procedure initialize_fitnessfunctions is

   begin
      -- Initialize the list of all possible fitness functions
      --
      for i in 1 .. max_fitness loop
         fitnessfunctions (i).is_selected := 0;
      end loop;

      fitnessfunctions (1).name :=
        To_Unbounded_String ("f1 = preemptions");       -- To Min
      fitnessfunctions (2).name :=
        To_Unbounded_String ("f2 = contextSwitches");   -- To Min
      fitnessfunctions (3).name :=
        To_Unbounded_String ("f3 = tasks");             -- To Min
      fitnessfunctions (4).name :=
        To_Unbounded_String ("f4 = sum(Li) = sum(Di-Ri)");-- To Max --
      fitnessfunctions (5).name :=
        To_Unbounded_String ("f5 = sum(Ri/Di)");        -- To Min
      fitnessfunctions (6).name :=
        To_Unbounded_String ("f6 = min(Li)");           -- To Max --
      fitnessfunctions (7).name :=
        To_Unbounded_String ("f7 = sum(Ri)");           -- To Min
      fitnessfunctions (8).name :=
        To_Unbounded_String ("f8 = max(Ri)");           -- To Min
      fitnessfunctions (9).name :=
        To_Unbounded_String ("f9 = sum(Bi)");           -- To Min
      fitnessfunctions (10).name :=
        To_Unbounded_String ("f10 = max(Bi)");                 -- To Min
      fitnessfunctions (11).name :=
        To_Unbounded_String ("f11 = sharedResources");         -- To Min

      fitnessfunctions (12).name :=
        To_Unbounded_String ("f12 = missedDeadlines");         -- To Min
      fitnessfunctions (13).name :=
        To_Unbounded_String ("f13 = bellViolations");          -- To Min
      fitnessfunctions (14).name :=
        To_Unbounded_String ("f14 = bibaViolations");  -- To Min
      fitnessfunctions (15).name :=
        To_Unbounded_String ("f15 = energy");  -- To Min
      fitnessfunctions (16).name :=
        To_Unbounded_String ("f16 = nb_cores");        -- To Min

   end initialize_fitnessfunctions;

end Paes.objective_functions;
