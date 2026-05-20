
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
-- Frank Singhoff, Lab-STICC UMR 6285, UniversitÃ© de Bretagne Occidentale
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
--    $Rev: 3542 $
--    $Date: 2020-10-02 10:33:28 +0200 (Fri, 02 Oct 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------


with Paes_Utilities;             use Paes_Utilities;
with Systems;                    use Systems;
with Ada.Numerics.Float_Random ; use Ada.Numerics.Float_Random ;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with unbounded_strings;          use unbounded_strings;
with Tasks;                      use Tasks;
with Task_Set;                   use Task_Set;
with Resources;                  use Resources;
With Resource_set;               use Resource_set;
with Scheduler;                  use Scheduler;
with Scheduler_Interface;        use Scheduler_Interface;
with framework_config;           use framework_config;

-- This package defines subprograms needed
-- to instanciate PAES for the Functions-to-Tasks (F2T)
-- architecture exploration problem
--
package Chromosome_Data_Manipulation_mils is

   ---------------------
   --      Types      --
   ---------------------
   -- This type used for communication cost 
   type com_cost_type is array (1..5) of Float;
     
   --   1 nb_display_blackboard_com (number of emission intra)
   --   2 nb_read_blackboard_com (réception intra)
   --   3 nb_write_sampling_com (émission inter)
   --   4 nb_read_sampling_com (réception inter)
   --   5 communication cost considering feasibility interval
  
   -------------------------
   --   Global variables  --
   -------------------------
   -- 
   --
   -- Initial_System is the Cheddar-ADL model
   -- of the initial design
   Initial_System                 : System;

   -- Hyperperiod_of_Initial_Taskset is the hyperperiod
   -- of the initial design
   --
   Hyperperiod_of_Initial_Taskset : integer;

   -- The_Scheduler is the priority assignment
   -- policy used in the scheduling simulation
   The_Scheduler                  : Schedulers_Type;

   -- values of Task_priority and Sched_policy varaibles
   -- depend of the The_Scheduler value
   -- for example:
   -- *) The_Scheduler = Rate_Monotonic_Protocol
   --    =>> Task_priority = 1  || Sched_policy = SCHED_FIFO
   -- *) The_Scheduler = Earliest_Deadline_First_Protocol
   --    =>> Task_priority = 0  || Sched_policy = SCHED_OTHERS
   --
   Task_priority                  : Integer;
   Sched_policy                   : Policies;

   -- This variable represents the maximum hyperperiod
   -- of the explored solutions
   --
   Max_hyperperiod                : integer;

   -- This variable is used to differentiate the cases:
   -- when Using_preprocessed_initial_sol = false; i.e. the initial
   -- solution is 1-1 fcts-tasks mapping
   -- otherwise, we use the preprocessed initial solution
   --
   Using_preprocessed_initial_sol : boolean := false;

   One_to_one_mapping_solution : solution;
   
   

   -- These subprograms are the specific implementation
   -- of PAES generic subprograms, that will be used
   -- in order to instanciate PAES_method/Exhaustive_method
   -- for the F2T architecture exploration problem
   --
   procedure init_T2P;
   procedure mutate_T2P (s : in out solution; eidx : in Natural);
   procedure generate_next_element_T2P
     (s                         : in out solution;
      i,j                         : in out Integer);
   procedure generate_next_solution_T2P
     (s                         : in out solution;
      space_search_is_exhausted : out boolean);

   -- This procedure is used to normalize a mutated solution
   -- exemple to normalize a solution:
   -- [5 2 5 3 4 5 2] => after normalization [1 2 1 3 4 1 2]
   --
   
   
   
   procedure normalize(s : in out solution);




   -- This function returns the number of tasks from a given
   -- candidate solution "s"
   --
   --function Number_of_tasks (s : in solution) return integer;

   -- This function returns the number of partitions from a given
   -- candidate solution "s"
   function Number_of_partitions (s : in solution) return integer;
   
   -- This function returns the number of processors from a given
   -- candidate solution "s"
 --  function Number_of_processors (s : in solution) return integer;
   -- This procedure applies F2T rules on a given candidate solution "S"
   -- in order to generate the corresponding CheddarADL model
   --
   --Procedure Appling_clustering_rules (A_sys : in out System;
   --                                    s     : in solution);
   
   Procedure Transform_Chromosome_To_CheddarADL_Model
     (A_sys : in out System;
      s     : in solution);
    
     
   procedure Create_system (A_system : in out System; s     : in solution);   
   -- Overheads communication (inter and intra)
   Procedure com_overhead(A_sys : in out System);
   --communication cost
   Procedure communication_cost(sys: in system; com_cost: out com_cost_type);

end Chromosome_Data_Manipulation_mils;
