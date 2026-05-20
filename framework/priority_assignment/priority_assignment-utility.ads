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

with Text_IO;                  use Text_IO;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with Ada.Strings.Bounded;      use Ada.Strings.Bounded;
with Ada.Finalization;
with task_set;                 use task_set;
with Scheduling_Analysis;      use Scheduling_Analysis;
with Tasks;                    use Tasks;
with Tasks.extended;           use Tasks.extended;
with stacks;
with Unchecked_Deallocation;
with integer_arrays;           use integer_arrays;
with cache_set;                use cache_set;
with cache_block_set;          use cache_block_set;
with cache_access_profile_set; use cache_access_profile_set;

package priority_assignment.utility is
   --------------------------------------------
   --STEPS IN THE OPA
   --
   --------------------------------------------

   --Calculate the Pi - Hyper Period level i
   function calculate_pi
     (priority_level : in Integer;
      my_tasks       : in tasks_set) return Integer;

   --Calculate Hyper_Period
   function calculate_h (my_tasks : in tasks_set) return Integer;

   --Refine the offset following Theorem Refine in Audsley's paper
   procedure refine_offset
     (a_task        : in     generic_task_ptr;
      my_tasks      : in     tasks_set;
      refined_tasks :    out tasks_set);

   --Calculate the Beta, Eta Set for OPA
   procedure calculate_task_release_records_table
     (t_start                      : in     Integer;
      t_end                        : in     Integer;
      a_task                       : in out generic_task_ptr;
      my_tasks                     : in out tasks_set;
      a_task_release_records_table :    out task_release_records_table);
   --------------------------------------------
   -- A data structure to store UCBs and ECBs of task
   -- Converted from Cache Access Profile
   --------------------------------------------
   type task_ucb_ecb is record
      task_name  : Unbounded_String;
      task_index : Integer;
      ucbs       : integer_array;
      crpd_ucb   : Integer;
      ecbs       : integer_array;
      crpd_ecb   : Integer;
   end record;

   procedure initialize
     (my_task_ucb_ecb : in out task_ucb_ecb;
      task_name       : in     Unbounded_String;
      task_index      : in     Integer := 0;
      ucbs            : in     integer_array;
      crpd_ucb        : in     Integer := 0;
      ecbs            : in     integer_array;
      crpd_ecb        : in     Integer := 0);

   type task_ucb_ecb_array is array (Natural range <>) of task_ucb_ecb;
   type task_ucb_ecb_array_ptr is access task_ucb_ecb_array;

   --Calculate the Beta, Eta Set for OPA CRPD
   procedure calculate_task_release_records_table
     (t_start  : in     Integer;
      t_end    : in     Integer;
      a_task   : in     generic_task_ptr;
      my_tasks : in out tasks_set;
      a_tuea   : in     task_ucb_ecb_array_ptr;
      a_trrt   :    out task_release_records_table_ptr);

   function get_task_crpd_ecb
     (a_task_ucb_ecb_array_ptr : in task_ucb_ecb_array_ptr;
      task_name                : in Unbounded_String) return Integer;

   function get_task_crpd_ucb
     (a_task_ucb_ecb_array_ptr : in task_ucb_ecb_array_ptr;
      task_name                : in Unbounded_String) return Integer;

   procedure cap_to_tuea
     (my_tasks                 : in     tasks_set;
      my_cache_access_profiles : in     cache_access_profiles_set;
      a_task_ucb_ecb_array     : in out task_ucb_ecb_array_ptr);

   --------------------------------------------
   -- Data structure and functions to solve transitive closure problem
   --------------------------------------------
   type boolean_arr_2d is
     array (Integer range <>, Integer range <>) of Boolean;
   type boolean_arr_2d_ptr is access boolean_arr_2d;

   procedure free is new Unchecked_Deallocation
     (boolean_arr_2d,
      boolean_arr_2d_ptr);

   procedure warshall_algorithm
     (warshall_array : in out boolean_arr_2d_ptr;
      size           : in     Integer);

   --------------------------------------------
   -- Data structure and functions to solve binomial coefficient problem
   --------------------------------------------
   type ias is array (Natural range <>) of integer_array;
   type ias_ptr is access ias;

   procedure initialize (a_ias : in out ias_ptr);

   procedure add (a_ias : in out ias_ptr; a_ia : in integer_array);

   procedure free is new Unchecked_Deallocation (ias, ias_ptr);

   function compute_crpd_potential_preempted
     (sets : in ias_ptr;
      k    : in Integer;
      n    : in Integer) return Integer;

   --------------------------------------------
   -- Data structure and functions to solve binomial coefficient problem
   --------------------------------------------
   procedure get_eucbs
     (a_task_ucb_ecb_array : in     task_ucb_ecb_array_ptr;
      preempting_task      : in     Unbounded_String;
      preempted_task       : in     Unbounded_String;
      arr_eucbs            :    out integer_array);

   --Cache related preemption delay cache block
   procedure check_ccb
     (a_task_ucb_ecb_array : in     task_ucb_ecb_array_ptr;
      preempting_task      : in     Unbounded_String;
      preempted_task       : in     Unbounded_String;
      n_ccb                :    out Natural);

   function get_crpd_by_ncb (n_ucb_ecb : in Integer) return Integer;

   --------------------------------------------
   --
   --------------------------------------------
   type task_release_record_ext;
   type task_release_record_ext_ptr is
     access all task_release_record_ext'class;
   type task_release_record_ext is new task_release_record with record
      ucbs          : integer_array;
      ecbs          : integer_array;
      ucbs_in_cache : integer_array;
   end record;

   --------------------------------------------
   -- Function used to perform scheduling simulation
   --------------------------------------------
   procedure fill_tasks_ucbs_in_cache
     (a_trr : in out task_release_record_ext_ptr);

end priority_assignment.utility;
