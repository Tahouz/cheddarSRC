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

with applicability_constraint.unsimultaneous_release_time_constraint;
use applicability_constraint.unsimultaneous_release_time_constraint;
with applicability_constraint.simultaneous_release_time_constraint;
use applicability_constraint.simultaneous_release_time_constraint;
with applicability_constraint.period_equal_deadline_constraint;
use applicability_constraint.period_equal_deadline_constraint;
with applicability_constraint.period_smaller_than_deadline_constraint;
use applicability_constraint.period_smaller_than_deadline_constraint;
with applicability_constraint.period_larger_than_deadline_constraint;
use applicability_constraint.period_larger_than_deadline_constraint;
with applicability_constraint.arbitrary_deadlines;
use applicability_constraint.arbitrary_deadlines;
with applicability_constraints_main_structure;
use applicability_constraints_main_structure;
with applicability_constraints_main_structure.extended;
use applicability_constraints_main_structure.extended;
with feasibility_tests_for_time_triggered_communication;
use feasibility_tests_for_time_triggered_communication;
with feasibility_tests_for_unplugged;
with feasibility_tests_for_ravenscar;
with debug; use debug;

package body feasibility_tests_main_structure_factory is

   procedure time_triggered_communication_feasibility_tests_main_structure
     (all_cases :    out all_cases_structure;
      sys       : in     system)
   is

      constraint_temp : applicability_constraints_main_structure
        .applicability_constraint_ptr;
      constraint_case_temp : applicability_constraint_case_ptr;

   begin

      initialize (all_cases);
      initialize (constraint_temp);
      initialize (constraint_case_temp);

      --CASE_1
      --("CASE 1");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_1");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String
          ("Test_S1 ; Test_R1 ; Test_R2 ; Test_C7 ; Test_C1 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;
      put_debug ("added ref to constraint function");

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_1_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_1_Constraint");
      constraint_temp.all.corresponding_function := function_case_1'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_1 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_2
      --("CASE 2");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_2");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_2_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_2_Constraint");
      constraint_temp.all.corresponding_function := function_case_2'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_2 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_3
      --("CASE 3");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_3");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1 ; Test_R1 ; Test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_3_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_3_Constraint");
      constraint_temp.all.corresponding_function := function_case_3'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_3 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_4
      --("CASE 4");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_4");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_4_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_4_Constraint");
      constraint_temp.all.corresponding_function := function_case_4'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_4 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_5
      --("CASE 5");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_5");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_5_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_5_Constraint");
      constraint_temp.all.corresponding_function := function_case_5'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_5 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_6
      --("CASE 6");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_6");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_6_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_6_Constraint");
      constraint_temp.all.corresponding_function := function_case_6'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_6 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_7
      --("CASE 7");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_7");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R2");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --arbitrary_deadlines_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("arbitrary_deadlines_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.arbitrary_deadlines.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_7_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_7_Constraint");
      constraint_temp.all.corresponding_function := function_case_7'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_7 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_8
      --("CASE 8");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_8");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_8_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_8_Constraint");
      constraint_temp.all.corresponding_function := function_case_8'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_8 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_9
      --("CASE 9");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_9");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_C3, test_C4, test_R4  ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_9_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_9_Constraint");
      constraint_temp.all.corresponding_function := function_case_9'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_9 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_10
      --("CASE 10");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_10");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_10_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_10_Constraint");
      constraint_temp.all.corresponding_function := function_case_10'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_10 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_11
      --("CASE 11");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_11");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R4 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_11_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_11_Constraint");
      constraint_temp.all.corresponding_function := function_case_11'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_11 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_12
      --("CASE 12");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_12");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_12_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_12_Constraint");
      constraint_temp.all.corresponding_function := function_case_12'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_12 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_13
      --("CASE 13");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_13");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_13_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_13_Constraint");
      constraint_temp.all.corresponding_function := function_case_13'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_13 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_14
      --("CASE 14");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_14");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_14_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_14_Constraint");
      constraint_temp.all.corresponding_function := function_case_14'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_14 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_15
      --("CASE 15");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_15");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_15_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_15_Constraint");
      constraint_temp.all.corresponding_function := function_case_15'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_15 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_16
      --("CASE 16");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_16");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_16_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_16_Constraint");
      constraint_temp.all.corresponding_function := function_case_16'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_16 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_17
      --("CASE 17");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_17");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_C5, test_C7, test_R1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_17_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_17_Constraint");
      constraint_temp.all.corresponding_function := function_case_17'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_17 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_18
      --("CASE 18");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_18");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_18_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_18_Constraint");
      constraint_temp.all.corresponding_function := function_case_18'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_18 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_19
      --("CASE 19");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_19");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_C5, test_R1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_19_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_19_Constraint");
      constraint_temp.all.corresponding_function := function_case_19'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_19 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_20
      --("CASE 20");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_20");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_20_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_20_Constraint");
      constraint_temp.all.corresponding_function := function_case_20'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_20 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_21
      --("CASE 21");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_21");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_21_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_21_Constraint");
      constraint_temp.all.corresponding_function := function_case_21'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_21 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_22
      --("CASE 22");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_22");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_22_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_22_Constraint");
      constraint_temp.all.corresponding_function := function_case_22'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_22 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_23
      --("CASE 23");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_23");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_23_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_23_Constraint");
      constraint_temp.all.corresponding_function := function_case_23'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_23 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_24
      --("CASE 24");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_24");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_24_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_24_Constraint");
      constraint_temp.all.corresponding_function := function_case_24'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_24 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_25
      --("CASE 25");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_25");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R4 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_25_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_25_Constraint");
      constraint_temp.all.corresponding_function := function_case_25'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_25 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_26
      --("CASE 26");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_26");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_26_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_26_Constraint");
      constraint_temp.all.corresponding_function := function_case_26'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_26 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_27
      --("CASE 27");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_27");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R4 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_27_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_27_Constraint");
      constraint_temp.all.corresponding_function := function_case_27'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_27 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_28
      --("CASE 28");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_28");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_28_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_28_Constraint");
      constraint_temp.all.corresponding_function := function_case_28'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_28 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_29
      --("CASE 29");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_29");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_29_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_29_Constraint");
      constraint_temp.all.corresponding_function := function_case_29'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_29 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_30
      --("CASE 30");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_30");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_30_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_30_Constraint");
      constraint_temp.all.corresponding_function := function_case_30'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_30 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_31
      --("CASE 31");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_31");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_31_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_31_Constraint");
      constraint_temp.all.corresponding_function := function_case_31'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_31 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_32
      --("CASE 32");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_32");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_32_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_32_Constraint");
      constraint_temp.all.corresponding_function := function_case_32'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_32 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_33
      --("CASE 33");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_33");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_C7, test_R1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_33_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_33_Constraint");
      constraint_temp.all.corresponding_function := function_case_33'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_33 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_34
      --("CASE 34");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_34");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_34_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_34_Constraint");
      constraint_temp.all.corresponding_function := function_case_34'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_34 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_35
      --("CASE 35");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_35");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1 ; Test_R1 ; Test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_35_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_35_Constraint");
      constraint_temp.all.corresponding_function := function_case_35'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_35 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_36
      --("CASE 36");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_36");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_36_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_36_Constraint");
      constraint_temp.all.corresponding_function := function_case_36'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_36 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_37
      --("CASE 37");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_37");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_37_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_37_Constraint");
      constraint_temp.all.corresponding_function := function_case_37'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_37 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_38
      --("CASE 38");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_38");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_38_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_38_Constraint");
      constraint_temp.all.corresponding_function := function_case_38'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_38 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_39
      --("CASE 39");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_39");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1, Test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_39_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_39_Constraint");
      constraint_temp.all.corresponding_function := function_case_39'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_39 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_40
      --("CASE 40");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_40");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_40_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_40_Constraint");
      constraint_temp.all.corresponding_function := function_case_40'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_40 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_41
      --("CASE 41");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_41");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R4  ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_41_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_41_Constraint");
      constraint_temp.all.corresponding_function := function_case_41'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_41 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_42
      --("CASE 42");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_42");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_42_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_42_Constraint");
      constraint_temp.all.corresponding_function := function_case_42'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_42 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_43
      --("CASE 43");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_43");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R4 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_43_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_43_Constraint");
      constraint_temp.all.corresponding_function := function_case_43'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_43 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_44
      --("CASE 44");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_44");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_44_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_44_Constraint");
      constraint_temp.all.corresponding_function := function_case_44'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_44 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_45
      --("CASE 45");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_45");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_45_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_45_Constraint");
      constraint_temp.all.corresponding_function := function_case_45'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_45 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_46
      --("CASE 46");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_46");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_46_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_46_Constraint");
      constraint_temp.all.corresponding_function := function_case_46'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_46 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_47
      --("CASE 47");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_47");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_47_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_47_Constraint");
      constraint_temp.all.corresponding_function := function_case_47'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_47 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_48
      --("CASE 48");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_48");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_48_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_48_Constraint");
      constraint_temp.all.corresponding_function := function_case_48'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_48 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_49
      --("CASE 49");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_49");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String
          (" test_S1, test_C1, test_C8, test_C9, test_C10, test_R1, test_R3");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_49_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_49_Constraint");
      constraint_temp.all.corresponding_function := function_case_49'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_49 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_50
      --("CASE 50");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_50");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S2, test_C8, test_C9, test_C10, test_R3");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_50_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_50_Constraint");
      constraint_temp.all.corresponding_function := function_case_50'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_50 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_51
      --("CASE 51");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_51");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_C9, test_R3 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_3_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_51_Constraint");
      constraint_temp.all.corresponding_function := function_case_51'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_51 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_52
      --("CASE 52");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_52");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S2, test_C9, test_R3 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_52_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_52_Constraint");
      constraint_temp.all.corresponding_function := function_case_52'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_52 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_53
      --("CASE 53");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_53");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_C8, test_C10, test_R3 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_53_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_53_Constraint");
      constraint_temp.all.corresponding_function := function_case_53'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_53 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_54
      --("CASE 54");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_54");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S2, test_C8, test_C10, test_R3 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_54_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_54_Constraint");
      constraint_temp.all.corresponding_function := function_case_54'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_54 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_55
      --("CASE 55");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_55");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R3 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_55_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_55_Constraint");
      constraint_temp.all.corresponding_function := function_case_55'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_55 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_56
      --("CASE 56");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_56");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S2, test_R3");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_56_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_56_Constraint");
      constraint_temp.all.corresponding_function := function_case_56'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_56 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_57
      --("CASE 57");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_57");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_C6, test_R5 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_57_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_57_Constraint");
      constraint_temp.all.corresponding_function := function_case_57'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_57 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_58
      --("CASE 58");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_58");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S2, test_R5 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_58_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_58_Constraint");
      constraint_temp.all.corresponding_function := function_case_58'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_58 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_59
      --("CASE 59");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_59");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R5 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_59_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_59_Constraint");
      constraint_temp.all.corresponding_function := function_case_59'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_59 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_60
      --("CASE 60");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_60");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S2, test_R5 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_60_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_60_Constraint");
      constraint_temp.all.corresponding_function := function_case_60'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_60 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_61
      --("CASE 61");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_61");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R5 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_5_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_61_Constraint");
      constraint_temp.all.corresponding_function := function_case_61'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_61 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_62
      --("CASE 62");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_62");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S2, test_R5 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_62_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_62_Constraint");
      constraint_temp.all.corresponding_function := function_case_62'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_62 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_63
      --("CASE 63");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_63");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R5 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_63_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_63_Constraint");
      constraint_temp.all.corresponding_function := function_case_63'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_63 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_64
      --("CASE 64");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_64");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S2, test_R5 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_64_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_64_Constraint");
      constraint_temp.all.corresponding_function := function_case_64'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_64 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

   end time_triggered_communication_feasibility_tests_main_structure;

   procedure ravenscar_feasibility_tests_main_structure
     (all_cases : out all_cases_structure;
      sys       :     system)
   is

      constraint_temp : applicability_constraints_main_structure
        .applicability_constraint_ptr;
      constraint_case_temp : applicability_constraint_case_ptr;

   begin

      initialize (all_cases);
      initialize (constraint_temp);
      initialize (constraint_case_temp);

      --CASE_1
      --("CASE 1");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_1");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_s1, test_R1, test_R2, test_C3, test_C4");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_1_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_1_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_1'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_1 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_2
      --("CASE 2");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_2");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S2");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_2_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_2_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_2'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_2 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_3
      --("CASE 3");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_3");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1 ; Test_R1 ; Test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_3_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_3_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_3'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_3 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_4
      --("CASE 4");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_4");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_4_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_4_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_4'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_4 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_5
      --("CASE 5");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_5");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_5_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_5_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_5'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_5 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_6
      --("CASE 6");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_6");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_6_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_6_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_6'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_6 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_7
      --("CASE 7");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_7");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R2");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_7_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_7_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_7'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_7 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_8
      --("CASE 8");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_8");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_8_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_8_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_8'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_8 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_9
      --("CASE 9");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_9");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_C3, test_C4, test_R4  ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_9_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_9_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_9'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_9 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_10
      --("CASE 10");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_10");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_10_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_10_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_10'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_10 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_11
      --("CASE 11");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_11");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R4 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_11_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_11_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_11'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_11 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_12
      --("CASE 12");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_12");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_12_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_12_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_12'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_12 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_13
      --("CASE 13");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_13");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_13_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_13_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_13'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_13 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_14
      --("CASE 14");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_14");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_14_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_14_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_14'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_14 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_15
      --("CASE 15");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_15");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_15_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_15_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_15'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_15 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_16
      --("CASE 16");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_16");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_16_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_16_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_16'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_16 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_17
      --("CASE 17");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_17");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_17_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_17_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_17'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_17 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_18
      --("CASE 18");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_18");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_18_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_18_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_18'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_18 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_19
      --("CASE 19");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_19");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_19_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_19_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_19'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_19 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_20
      --("CASE 20");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_20");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_20_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_20_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_20'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_20 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_21
      --("CASE 21");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_21");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_21_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_21_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_21'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_21 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_22
      --("CASE 22");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_22");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_22_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_22_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_22'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_22 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_23
      --("CASE 23");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_23");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_23_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_23_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_23'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_23 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_24
      --("CASE 24");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_24");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_24_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_24_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_24'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_24 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_25
      --("CASE 25");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_25");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R4 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_25_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_25_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_25'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_25 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_26
      --("CASE 26");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_26");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_26_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_26_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_26'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_26 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_27
      --("CASE 27");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_27");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R4 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_27_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_27_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_27'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_27 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_28
      --("CASE 28");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_28");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_28_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_28_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_28'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_28 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_29
      --("CASE 29");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_29");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_29_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_29_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_29'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_29 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_30
      --("CASE 30");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_30");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_30_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_30_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_30'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_30 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_31
      --("CASE 31");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_31");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_31_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_31_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_31'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_31 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_32
      --("CASE 32");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_32");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_32_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_32_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_32'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_32 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_33
      --("CASE 33");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_33");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_33_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_33_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_33'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_33 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_34
      --("CASE 34");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_34");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_34_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_34_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_34'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_34 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_35
      --("CASE 35");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_35");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1 ; Test_R1 ; Test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_35_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_35_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_35'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_35 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_36
      --("CASE 36");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_36");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_36_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_36_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_36'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_36 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_37
      --("CASE 37");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_37");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_37_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_37_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_37'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_37 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_38
      --("CASE 38");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_38");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_38_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_38_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_38'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_38 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_39
      --("CASE 39");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_39");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1, Test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_39_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_39_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_39'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_39 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_40
      --("CASE 40");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_40");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_40_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_40_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_40'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_40 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_41
      --("CASE 41");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_41");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R4  ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_41_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_41_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_41'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_41 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_42
      --("CASE 42");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_42");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_42_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_42_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_42'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_42 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_43
      --("CASE 43");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_43");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R4 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_43_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_43_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_43'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_43 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_44
      --("CASE 44");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_44");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_44_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_44_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_44'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_44 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_45
      --("CASE 45");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_45");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_45_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_45_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_45'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_45 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_46
      --("CASE 46");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_46");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_46_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_46_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_46'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_46 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_47
      --("CASE 47");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_47");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_47_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_47_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_47'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_47 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_48
      --("CASE 48");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_48");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_48_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_48_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_48'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_48 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_49
      --("CASE 49");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_49");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_49_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_49_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_49'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_49 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_50
      --("CASE 50");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_50");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_50_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_50_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_50'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_50 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_51
      --("CASE 51");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_51");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_3_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_51_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_51'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_51 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_52
      --("CASE 52");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_52");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_52_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_52_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_52'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_52 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_53
      --("CASE 53");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_53");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_53_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_53_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_53'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_53 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_54
      --("CASE 54");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_54");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S2");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_54_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_54_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_54'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_54 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_55
      --("CASE 55");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_55");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_55_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_55_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_55'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_55 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_56
      --("CASE 56");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_56");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S2");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_56_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_56_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_56'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_56 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_57
      --("CASE 57");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_57");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_C6, test_R5 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_57_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_57_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_57'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_57 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_58
      --("CASE 58");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_58");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S2, test_R5 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_58_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_58_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_58'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_58 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_59
      --("CASE 59");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_59");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R5 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_59_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_59_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_59'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_59 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_60
      --("CASE 60");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_60");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S2, test_R5 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_60_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_60_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_60'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_60 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_61
      --("CASE 61");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_61");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R5 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_5_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_61_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_61'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_61 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_62
      --("CASE 62");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_62");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S2, test_R5 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_62_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_62_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_62'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_62 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_63
      --("CASE 63");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_63");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R5 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_63_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_63_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_63'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_63 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_64
      --("CASE 64");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_64");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S2, test_R5 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_64_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_64_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_ravenscar.function_case_64'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_64 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

   end ravenscar_feasibility_tests_main_structure;

   procedure unplugged_feasibility_tests_main_structure
     (all_cases : out all_cases_structure;
      sys       :     system)
   is

      constraint_temp : applicability_constraints_main_structure
        .applicability_constraint_ptr;
      constraint_case_temp : applicability_constraint_case_ptr;

   begin

      initialize (all_cases);
      initialize (constraint_temp);
      initialize (constraint_case_temp);

      --CASE_1
      --("CASE 1");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_1");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String
          ("Test_S1 ; Test_R1 ; Test_R2 ; Test_C7 ; Test_C1 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_1_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_1_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_1'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_1 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_2
      --("CASE 2");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_2");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_2_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_2_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_2'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_2 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_3
      --("CASE 3");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_3");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1 ; Test_R1 ; Test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_3_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_3_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_3'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_3 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_4
      --("CASE 4");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_4");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_4_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_4_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_4'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_4 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_5
      --("CASE 5");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_5");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_5_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_5_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_5'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_5 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_6
      --("CASE 6");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_6");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_6_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_6_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_6'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_6 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_7
      --("CASE 7");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_7");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R2");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_7_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_7_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_7'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_7 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_8
      --("CASE 8");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_8");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_8_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_8_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_8'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_8 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_9
      ----("CASE 9");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_9");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_C3, test_C4, test_R4  ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_9_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_9_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_9'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_9 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_10
      --("CASE 10");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_10");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_10_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_10_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_10'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_10 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_11
      --("CASE 11");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_11");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R4 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_11_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_11_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_11'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_11 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_12
      --("CASE 12");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_12");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_12_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_12_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_12'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_12 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_13
      --("CASE 13");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_13");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_13_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_13_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_13'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_13 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_14
      --("CASE 14");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_14");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_14_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_14_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_14'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_14 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_15
      --("CASE 15");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_15");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_15_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_15_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_15'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_15 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_16
      --("CASE 16");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_16");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_16_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_16_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_16'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_16 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_17
      --("CASE 17");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_17");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_C5, test_C7, test_R1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_17_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_17_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_17'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_17 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_18
      --("CASE 18");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_18");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_18_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_18_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_18'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_18 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_19
      --("CASE 19");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_19");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_C5, test_R1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_19_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_19_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_19'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_19 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_20
      --("CASE 20");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_20");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_20_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_20_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_20'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_20 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_21
      --("CASE 21");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_21");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_21_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_21_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_21'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_21 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_22
      --("CASE 22");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_22");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_22_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_22_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_22'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_22 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_23
      --("CASE 23");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_23");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_23_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_23_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_23'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_23 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_24
      --("CASE 24");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_24");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_24_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_24_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_24'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_24 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_25
      --("CASE 25");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_25");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R4 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_25_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_25_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_25'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_25 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_26
      --("CASE 26");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_26");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_26_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_26_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_26'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_26 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_27
      --("CASE 27");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_27");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R4 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_27_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_27_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_27'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_27 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_28
      --("CASE 28");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_28");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_28_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_28_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_28'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_28 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_29
      --("CASE 29");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_29");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_29_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_29_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_29'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_29 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_30
      --("CASE 30");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_30");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_30_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_30_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_30'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_30 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_31
      --("CASE 31");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_31");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_31_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_31_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_31'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_31 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_32
      --("CASE 32");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_32");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_32_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_32_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_32'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_32 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_33
      --("CASE 33");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_33");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_C7, test_R1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_33_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_33_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_33'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_33 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_34
      --("CASE 34");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_34");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_34_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_34_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_34'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_34 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_35
      --("CASE 35");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_35");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1 ; Test_R1 ; Test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_35_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_35_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_35'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_35 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_36
      --("CASE 36");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_36");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_36_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_36_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_36'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_36 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_37
      --("CASE 37");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_37");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_37_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_37_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_37'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_37 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_38
      --("CASE 38");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_38");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_38_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_38_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_38'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_38 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_39
      --("CASE 39");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_39");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1, Test_R2 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_39_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_39_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_39'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_39 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_40
      --("CASE 40");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_40");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_40_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_40_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_40'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_40 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_41
      --("CASE 41");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_41");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R4  ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_41_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_41_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_41'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_41 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_42
      --("CASE 42");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_42");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_42_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_42_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_42'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_42 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_43
      --("CASE 43");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_43");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R4 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_43_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_43_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_43'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_43 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_44
      --("CASE 44");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_44");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_44_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_44_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_44'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_44 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_45
      --("CASE 45");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_45");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S1 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_45_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_45_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_45'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_45 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_46
      --("CASE 46");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_46");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_46_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_46_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_46'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_46 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_47
      --("CASE 47");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_47");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_47_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_47_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_47'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_47 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_48
      --("CASE 48");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_48");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("Test_S2 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_48_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_48_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_48'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_48 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_49
      --("CASE 49");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_49");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String
          (" test_S1, test_C1, test_C8, test_C9, test_C10, test_R1, test_R3");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_49_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_49_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_49'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_49 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_50
      --("CASE 50");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_50");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S2, test_C8, test_C9, test_C10, test_R3");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_50_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_50_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_50'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_50 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_51
      --("CASE 51");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_51");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_C9, test_R3 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_3_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_51_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_51'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_51 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_52
      --("CASE 52");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_52");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S2, test_C9, test_R3 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_52_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_52_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_52'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_52 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_53
      --("CASE 53");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_53");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_C8, test_C10, test_R3 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_53_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_53_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_53'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_53 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_54
      --("CASE 54");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_54");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S2, test_C8, test_C10, test_R3 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_54_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_54_Constraint");
      constraint_temp.all.corresponding_function := function_case_54'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_54 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_55
      --("CASE 55");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_55");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R3 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_55_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_55_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_55'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_55 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_56
      --("CASE 56");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_56");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S2, test_R3");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_56_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_56_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_56'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_56 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_57
      --("CASE 57");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_57");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_C6, test_R5 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_57_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_57_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_57'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_57 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_58
      --("CASE 58");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_58");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S2, test_R5 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Equal_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_equal_deadline_constraint.apply'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_58_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_58_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_58'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_58 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_59
      --("CASE 59");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_59");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R5 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_59_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_59_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_59'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_59 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_60
      --("CASE 60");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_60");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S2, test_R5 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Larger_Than_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Larger_Than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_larger_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_60_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_60_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_60'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_60 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_61
      --("CASE 61");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_61");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S1, test_R5 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_5_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_61_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_61'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_61 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_62
      --("CASE 62");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_62");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S2, test_R5 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --Period_Equal_Deadline_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Period_Smaller_than_Deadline_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.period_smaller_than_deadline_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));
      --CASE_62_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_62_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_62'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_62 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_63
      --("CASE 63");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_63");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String ("test_S1, test_R5 ");
      --Simultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Simultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.simultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_63_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_63_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_63'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_63 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

      --CASE_64
      --("CASE 64");
      constraint_case_temp.all.name := To_Unbounded_String ("Case_64");
      constraint_case_temp.all.feasibility_test_names :=
        To_Unbounded_String (" test_S2, test_R5 ");
      --Unsimultaneous_Release_Time_Constraint
      constraint_temp.all.name :=
        To_Unbounded_String ("Unsimultaneous_Release_Time_Constraint");
      constraint_temp.all.corresponding_function :=
        applicability_constraint.unsimultaneous_release_time_constraint.apply'
          access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --CASE_64_Constraint
      constraint_temp.all.name := To_Unbounded_String ("CASE_64_Constraint");
      constraint_temp.all.corresponding_function :=
        feasibility_tests_for_unplugged.function_case_64'access;

      applicability_constraints_list_package.add
        (constraint_case_temp.all.applicability_constraints,
         duplicate (constraint_temp));

      --adding to CASE_64 to All_Cases
      applicability_constraint_cases_list_package.add
        (all_cases.cases,
         duplicate (constraint_case_temp));
      applicability_constraints_list_package.initialize
        (constraint_case_temp.all.applicability_constraints);

   end unplugged_feasibility_tests_main_structure;

end feasibility_tests_main_structure_factory;
