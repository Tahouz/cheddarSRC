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

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Tasks;                 use Tasks;
with Task_Groups;           use Task_Groups;
with systems;               use systems;
with resource_set;          use resource_set;
with Framework_Config;      use Framework_Config;
with Processor_Interface;   use Processor_Interface;
with Parameters;            use Parameters;
with Parameters.extended;   use Parameters.extended;
use Parameters.User_Defined_Parameters_Table_Package;
with Offsets;               use Offsets;
with Offsets.extended;      use Offsets.extended;
use Offsets.Offsets_Table_Package;
with unbounded_strings;     use unbounded_strings;
with Processors;            use Processors;
with Doubles;               use Doubles;

with sets;

------------------------------------------------------------------------
-- Purpose:
-- This package computes feasibility intervals for simulation.
-- It encapsulates multiples algorithms which are designed to
-- calculate various feasibility intervals depending on the
-- considered system characteristics as well as providing
-- the validity of the calculation.
-- Effects:
-- - The expected usage is:
-- 1. Call Calculate_Feasibility_Interval to obtain the feasibility
--    interval of the considered system in multi_int type(Big Integers) type.
-- 2. Call Calculate_Feasibility_Interval_Top to obtain the
--    feasibility interval of the considered system in Double type.
-- - The others functions are supposed to be called within 1. and 2.
--
--
-- By the past, this package was implemented with a big number unit.
-- This implementation was unstable ... and actually, a Double is
-- enought to handle this into Cheddar
--
----------------------------------------------------------

package feasibility_test.feasibility_interval is

   ---------------------------------------------------------------------
   -- Is_Fixed_Task_Scheduler
   -- Purpose:
   -- This function determine if the scheduler use a fixed-task
   -- scheduling algorithm.
   ---------------------------------------------------------------------
   function is_fixed_task_scheduler
     (scheduler_type : in schedulers_type) return Boolean;

   ---------------------------------------------------------------------
   -- Is_Fixed_Job_Scheduler
   -- Purpose:
   -- This function determine if the scheduler use a fixed-job
   -- scheduling algorithm.
   ---------------------------------------------------------------------
   function is_fixed_job_scheduler
     (scheduler_type : in schedulers_type) return Boolean;

   ---------------------------------------------------------------------
   -- Is_Work_Conserving_Scheduler
   -- Purpose:
   -- This function determine if the scheduler use a work-conserving
   -- scheduling algorithm.
   ---------------------------------------------------------------------
   function is_work_conserving_scheduler
     (scheduler_type : in schedulers_type) return Boolean;

   ---------------------------------------------------------------------
   -- Max_Start_Time_Of_TaskSet
   -- Purpose:
   -- This function determine the hightest starting time of a task in
   -- the provided tasks set.
   ---------------------------------------------------------------------
   function max_start_time_of_taskset
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Natural;

   ---------------------------------------------------------------------
   -- Calculate_Feasibility_Interval_Top
   -- Purpose:
   -- This procedure calculate the feasibility interval of the system
   -- in Double type and provide a boolean information
   -- stating true if the feasibility interval can be used as
   -- schedulability proof else false.
   ---------------------------------------------------------------------

   procedure calculate_feasibility_interval
     (sys         : in     system;
      a_processor : in     generic_processor_ptr;
      validate    :    out Boolean;
      interval    :    out Double;
      msg         :    out Unbounded_String);

   ---------------------------------------------------------------------
   -- Scheduling_Period_1997
   -- Purpose: Calculation of simulation interval based on Goossens and
   -- Devillers paper from 1997 as well as 2006, 2011 and 2007 papers.
   --  *Used for independents and constrained tasks systems with:
   --     Uniprocessor with fixed-job priority. (1997)
   --     Uniform and Unrelated processors resp.(2006) and (2011)
   --     with Global fixed-task priority.
   --  *Identical processors with arbitrary deadlines, independent tasks
   --   with global fixed-task priority algorithm. (2007)
   -- The simulation interval of (2007) paper beeing slightly different,
   -- a boolean AddPeriod provide information for the calculation:
   -- If true, 2007 paper interval used else others.
   ---------------------------------------------------------------------
   function scheduling_period_1997
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String;
      addperiod      : in Boolean) return Double;

   ---------------------------------------------------------------------
   -- Scheduling_Period_2012_2013
   -- Purpose: Calculation of simulation interval based on Baro et al. (2012)
   -- and Nélis et al. (2013) papers.
   --   Used for identical processor with constrained deadlines and
   --   independent or simple precedencies tasks systems with any scheduling
   --   algorithm.
   ---------------------------------------------------------------------
   function scheduling_period_2012_2013
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Double;

   ---------------------------------------------------------------------
   -- Scheduling_Period_2016
   -- Purpose: Calculation of simulation interval based on Goossens
   -- and Grolleau, Cucu-Grosjean (2016) paper.
   --   Used for identical processor with structural constraint and arbitrary
   --   deadlines with any scheduling algorithm.
   ---------------------------------------------------------------------
   function scheduling_period_2016
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Double;

   ---------------------------------------------------------------------
   -- Scheduling_Period_With_Offset
   -- Purpose: Calculation of simulation interval based on Leung and Merill
   -- (1980) and Goossens and Devillers (1999) papers.
   --   Used for monoprocessor with constrained deadlines, independent tasks
   --   and fixed-task priority schheduling algorithm. (1980)
   --   Used for monoprocessor with arbitrary deadlines, independent tasks and
   --   fixed-job priority scheduling algorithm. (1999)
   -- Extra: Modification of the already implemented function but improved
   -- with handling of big integers calculation.
   ---------------------------------------------------------------------
   function scheduling_period_with_offset
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Double;

-----------------------------------------------------------------------------
   function scheduling_period
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Natural;

   function scheduling_period
     (my_tasks       : in tasks_set;
      processor_name : in Unbounded_String) return Double;

end feasibility_test.feasibility_interval;
