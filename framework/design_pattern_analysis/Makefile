include ../../Makefile.vars

SRC_ADS = applicability_constraint.ads\
	applicability_constraint-allowed_protocol.ads\
	applicability_constraint-all_tasks_are_periodic.ads\
	applicability_constraint-all_tasks_are_periodic_or_sporadic.ads\
	applicability_constraint-at_least_one_data.ads\
	applicability_constraint-uniprocessor_scheduling_protocol.ads\
	applicability_constraint-uniprocessor_quantum.ads\
	applicability_constraint-ceiling_priority_assignment.ads\
	applicability_constraint-data_connectivity.ads\
	applicability_constraint-data_sharing_protocol.ads\
	applicability_constraint-no_buffer.ads\
	applicability_constraint-no_dependencies.ads\
	applicability_constraint-no_shared_cpu.ads\
	applicability_constraint-no_shared_resources.ads\
	applicability_constraint-pip_no_deadlock.ads\
	applicability_constraint-period_equal_deadline_constraint.ads\
	applicability_constraint-period_larger_than_deadline_constraint.ads\
	applicability_constraint-period_smaller_than_deadline_constraint.ads\
	applicability_constraint-simultaneous_release_time_constraint.ads\
	applicability_constraint-unsimultaneous_release_time_constraint.ads\
	applicability_constraints_main_structure.ads\
	feasibility_tests_for_ravenscar.ads\
	feasibility_tests_for_time_triggered_communication.ads\
	feasibility_tests_for_unplugged.ads\
	feasibility_tests_main_structure_factory.ads\
	generic_graph.ads\
	dp_graph.ads\
	dp_graph_view.ads\
	architecture_analyzer.ads


SRC_ADB = applicability_constraint-allowed_protocol.adb\
	applicability_constraint-all_tasks_are_periodic.adb\
	applicability_constraint-all_tasks_are_periodic_or_sporadic.adb\
	applicability_constraint-at_least_one_data.adb\
	applicability_constraint-at_least_one_buffer.adb\
	applicability_constraint-uniprocessor_scheduling_protocol.adb\
	applicability_constraint-uniprocessor_quantum.adb\
	applicability_constraint-ceiling_priority_assignment.adb\
	applicability_constraint-data_connectivity.adb\
	applicability_constraint-data_sharing_protocol.adb\
	applicability_constraint-no_buffer.adb\
	applicability_constraint-no_dependencies.adb\
	applicability_constraint-no_shared_cpu.adb\
	applicability_constraint-no_shared_resources.adb\
	applicability_constraint-pip_no_deadlock.adb\
	applicability_constraint-period_equal_deadline_constraint.adb\
	applicability_constraint-period_larger_than_deadline_constraint.adb\
	applicability_constraint-period_smaller_than_deadline_constraint.adb\
	applicability_constraint-simultaneous_release_time_constraint.adb\
	applicability_constraint-unsimultaneous_release_time_constraint.adb\
	applicability_constraints_main_structure.adb\
	feasibility_tests_for_ravenscar.adb\
	feasibility_tests_for_time_triggered_communication.adb\
	feasibility_tests_for_unplugged.adb\
	feasibility_tests_main_structure_factory.adb\
	generic_graph.adb\
	dp_graph.adb\
	dp_graph_view.adb\
	applicability_constraint.adb\
	architecture_analyzer.adb



all::  $(SRC_ADB:.adb=.o)  

prettyprint::
	@for file in ${SRC_ADB} ${SRC_ADS}; do \
		echo $(PRETTY_PRINTER) $${file}; \
		$(PRETTY_PRINTER) $${file}; \
	done



