with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with System; use System;


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
--    $Rev: 3477 $
--    $Date: 2020-07-13 11:43:48 +0200 (Mon, 13 Jul 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- This program is the Ada implementation of (1+1)-PAES.
-- The original code of (1+1)-PAES is implemented in C
-- available from: http://www.cs.man.ac.uk/~jknowles/multi/
--
------------------------------------------------------------------------------
------------------------------------------------------------------------------




package Paes_Utilities is

   ---------------------
   --    Constants    --
   ---------------------

   MAX_GENES  : constant integer := 1000;  -- change as necessary
   MAX_GENES_TASK  : constant integer := 1000;  -- change as necessary
   MAX_GENES_COM  : constant integer := 1000;  -- change as necessary
   MAX_OBJ    : constant integer := 10;    -- change as necessary
   MAX_ARC    : constant integer := 11000;   -- change as necessary
   MAX_LOC    : constant integer := 1000000;--32768; -- number of locations in grid (set for a three-objective problem using depth 5)
   MAX_SLAVES : constant integer := 40;--for the parallel algorithm
   LARGE      : constant integer := 2000000000; -- should be about the maximum size of an integer for your compiler


   ---------------------
   --      Types      --
   ---------------------

   -- This type used to define a chromosome of a solution
   type chrom_type is array(1..MAX_GENES) of integer;

   -- This type used to define objectives of a solution
   type obj_type is array(1..MAX_OBJ) of float;

   type string_type is new string(1..50);



   -- This type used to define a chromosome of a solution (define tasks representation)
   -- type chrom_task_type is array(1..MAX_GENES) of integer;

   -- This type used to define if there is a downgrader; and if it is at emission or recepetion
   type chrom_com_elmt1 is (emission, reception, noDW , secure, nosecure, undefined, norisk) ;

   -- This type used to define if there is a downgrader; and if it is linked to task, communication, partition ...
   type chrom_com_elmt2 is (communication, tsk, partition, typeW_TSS, typeR_STS,typeW_MH , typeR_HM, noDW, undefined ) ;
   -- typeW_TSS: added downgrader between task_i and task_j is associated to the communication type "Top-secret to secret" and the violation between task_i and task_j is a writing violation

   type com_type is
      record
       --  elemt1 : chrom_com_elmt1;
         mode : chrom_com_elmt1;
         link : chrom_com_elmt2;
         source_sink : Unbounded_String; -- to identify the source and the sink of the communication
      end record;
   -- This type used to define a chromosome of a solution (define com representation)
   type chrom_com_type is array(1..MAX_GENES) of com_type;


      -- This is the main type used to define solutions
   type solution is
      record
         chrom_task : chrom_type; -- task to partitions assignement
         obj   : obj_type;
         grid_loc : integer;
--         chrom_partition_PU : chrom_type; -- partition to processor unit
--         chrom_task_core: chrom_type; -- task to core assignement
         chrom_com : chrom_com_type;  --communications in the chromosome
         security_config : integer:=1; --reflect how to secure communications
         -- version of exploration
         -- version=1: all tasks of an application in the same partition (applications mutation)
         -- version=2:  Tasks of an application can be on different partitions (tasks mutation)

         exploration_version: integer:=2; -- version of exploration
         hyperperiod:Integer;

      end record;

   -- This is the main type used to define solutions
--     type solution is
--        record
--           chrom : chrom_type;
--           obj   : obj_type;
--           grid_loc : integer;
--        end record;

    nb_secu_conf_choice:chrom_type;
   type Com_non_secure_list is array (1..MAX_GENES_COM) of Natural;
   -- This array is used to select communications for which confidentiality or integrity violation may be accepted
   NonSecure_list : Com_non_secure_list;
   -- number of communication for which confidentiality or integrity violation may be accepted
   Nb_NonSecure_low : integer ;

   -- This array is used to specify number of tasks per application
   nb_task_per_app:chrom_type;
   -- This array is used to specify the application number of each task
   task_to_app: chrom_type;
   sol_init1, sol_init2, sol_init3, sol_init4, sol_init5, sol_init6 : solution;


   -- This type is used to define the archive of solutions
   type arc_type is array(1..MAX_ARC) of solution;

   -- The selection strategy is either :
   --  *) Local strategy : the PAES original one, rule
   --     for admitting the matuted solution as current solution
   --     or to keep current solution for the next iteration
   --  *) Global strategy : that picks a new current
   --     individual from the archive at each iteration (NextSelect function).
   --
   type SelectionStrategy is (local, global);

   ----------------------
   -- Global variables --
   ----------------------

   -- current solution
   c                   : solution;
   -- mutant solution
   m                   : solution;
   -- archive of solutions
   arc                 : arc_type;
   tmp           : arc_type;
   -- the selection strategy
   --By default is set to the original selection strategy of PAES
   A_SelectionStrategy : SelectionStrategy := local;
   -- slaves correspond to the number of process that can be run in parallel
   -- it depends on the parallel machine capacity
   -- the number of slaves, By default is set to 0 (i.e. sequantial run)
   slaves              : natural := 0;
   -- set to 0 (zero) for minimization problems, 1 for maximization problems.
   -- By default is set to a minimization problem
   minmax              : integer := 0;

   -- Intrapartition overheads
   display_blackboard_time_values: chrom_type;
   read_blackboard_time_values: chrom_type;
   display_blackboard_time: Natural:=1;
   read_blackboard_time: Natural:=1;
   -- Interpartition overheads
   write_sampling_port_time_values : chrom_type;
   read_sampling_port_time_values : chrom_type;

   write_sampling_port_time: Natural:=28;
   read_sampling_port_time: Natural:=28;

   encrypter_values : chrom_type;
   decrypter_values : chrom_type;
   Hash_values      : chrom_type;

   ------------------------------------------------------------------------------------------------------
   -- depth: this is the number of recursive subdivisions of the objective space carried out in order to
   --        divide the objective space into a grid for the purposes of diversity maintenance. Values of
   --        between 3 and 6 are useful, depending on number of objectives.
   -- objectives: the number of objectives to the problem.
   -- genes: the number of genes in the chromosome of tasks. (Only integer genes can be accepted).
   -- genes_com: the number of genes in the chromosome of communication. (Only integer genes can be accepted).
   -- alleles: the number of values that each gene can take.
   -- archive: the maximum number of solutions to be held in the nondominated solutions archive.
   -- iterations: the program terminates after this number of iterations.
    -- genes_com: the number of genes in the chromosome of communication representation. (Only integer genes can be accepted).
   -- genes_init: the number of genes in the chromosome before its mutation
   -- partition_period: period of partitions
   -- nb_partitions: number of partitions
   -- nb_app: number of applications
   -- nb_proc: number of processor units
    -- nb_InitSol: number of initial solutions
    -- nb_sol_Exhaus: nombre de solutions generées par la méthode exhaustive
   -- nb_NoFeasible_Sol : number of non feasible solutions generate during the mutation
   -- DW_capacity: capacity for real time application
    -- DW_capacity2: capacity for multimedia application

   -- minmax:
   ------------------------------------------------------------------------------------------------------
   depth,  objectives, genes, genes_init, genes_com, archive, iterations, nb_partitions, nb_app, nb_proc, iter, partition_period, nb_InitSol, nb_NoFeasible_Sol, DW_capacity_encrypt, DW_capacity_decrypt, Key_capacity_DW,UP_capacity , UP_capacity2, UP_capacity3, DW_capacity_encrypt2,DW_capacity_decrypt2, DW_capacity_encrypt3,DW_capacity_decrypt3  : integer;
   nb_bell_resolved, nb_biba_resolved : integer;

   arclength  : integer := 0; -- current length of the archive

   gl_offset  : obj_Type;   -- the range, offset etc of the grid
   gl_range   : obj_Type;
   gl_largest : obj_Type;
   grid_pop   : array(1..MAX_LOC) of integer;  -- the array holding the population residing in each grid location

   change     : integer := 0;

   nb_sol_Exhaus: Integer :=0;
   Data3                   : Unbounded_String;

   function compare_min(first : obj_type; second : obj_type; n : integer) return integer;
   function compare_max(first : obj_type; second : obj_type; n : integer) return integer;
   function equal(first : obj_type; second : obj_type; n : integer) return integer;
   procedure print_genome(s : solution);
   procedure print_eval(s : solution);
   procedure print_debug_genome(s : solution);
   procedure print_debug_eval(s : solution);
   procedure add_to_archive(s : solution);
   function compare_to_archive(s : solution) return integer;
   procedure update_grid(s : in out solution);
   procedure archive_soln(s : solution);
   function find_loc(eval : obj_type) return integer;
   function selectNext return solution;
   Procedure Selection_and_Archiving;

end Paes_utilities;
