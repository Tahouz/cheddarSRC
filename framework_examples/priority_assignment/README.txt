=========SUMMARY=========
- Run OPA on case study in Audsley, 1991
- Run CPA-ECB, CPA-PT, CPA-PT-Simplified, CPA-Tree

=========INSTRUCTION=========
- cd (Cheddar Directory)/trunk/src
- source ../compile.bash
- make priorityAssignment
- ./priority assignment -t A

=========RESULT=========
- Results are displayed on the command line.


=========PACKAGE DESCRIPTION=========
- call_test_pa.adb 				: entry point
- audsley_opa_test.adb/ads 			: test and case study in Audsley, 1991
- audsley_opa_crpd_test.adb/ads 		: test and case study for CPA algorithms (Nam's thesis)
- efficiency_test.adb/ads 			: test for schedulability task set coverage
- priority_assignment_test_printer.adb/ads 	: printing methods (not important)

