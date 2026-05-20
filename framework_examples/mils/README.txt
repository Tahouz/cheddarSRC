=========SUMMARY=========
- Example of MILS evaluation running  both scheduling analysis and security analysis of a MILS Cheddar ADL model

#Input
- A xml file containing a system (set of processors, tasks, dependencies ...)
- Period of scheduling analysis
- The name of the processor containing the tasks on which the analysis (scheduling and security) will be made

#Output
- A string in xml format that show the results of scheduling analysis (wcrt for each task, Nb_premptions, Nb_context_switches) and security analysis (Nb_violations when applying security algorithms)

=========INSTRUCTION=========

- cd {Cheddar Directory}/trunk/src
- source ../compilelinux64.bash
- make mils
- ./mils_evaluation 
	+ -i :input system model (.xmlv3)
	
	+  scheduling duration
	
	+ Processor_name

Example: analyse a MILS Cheddar ADL model; scheduling period= 100; processor_name= processor

	./mils_evaluation -i  framework_examples/mils/xml/simulation0.xmlv3    100   processor
	



