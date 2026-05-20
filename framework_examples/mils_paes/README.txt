=========SUMMARY=========
- Running of PAES method and Exhaustive method. Both use callcheddar to perform scheduling and security analysis of solutions


#Input of Call cheddar
- Hyperperiod of the system (we use hyperperiod = max(offset of partitions) + number of partitions * PPCM(tasks periods)
- A xml file containing a system (set of processors, tasks, dependencies ...)
#Output of Call cheddar
- Output .txt: the result of the schedulability and security analysis of the candidate solution as well as values of potential fitness functions
- Output2 .txt: This file contains the result of scheduling simulation of the candidate solution


#Input of PAES method
- Number of tasks in the initial system
- A xml file containing a system (set of processors, tasks, dependencies ...): the initial system
- Maximum number of partitions 
- Number of iterations of the PAES method (generation of candidate solutions, their evaluation, archive updating, etc...)
- Scheduling policy
- PAES strategy : global(compare the mutate solution to the archive) or local (compare mutate solution to the current solution)
- List of objectives fitness



#Output of PAES method
- Execution_trace.txt : shows the list of non-dominated solutions and the values of their objectives fitness
- Front.dat : show on each line, the list of the values of objectives fitness of a non-dominated solution
- PAES_execution_iter.dat : shows the values of objectives fitness of each feasible candidate solution, the number of rejected solution during archiving process, the number of rejected solutions during mutations(non feasible solutions)
- runtime.txt : show the runtime of the PAES method
- Solution"i".xmlv3: representes the "i"th non-dominated solutions

=========INSTRUCTION FOR PAES METHOD=========

- cd {Cheddar Directory}/trunk/src
- source ../compilelinux64.bash
- make callCheddar2
- make F2T_paes_method2

INSTRUCTION FOR PAES METHOD WITH AN INITIAL SYSTEM MODEL
- ./F2T_paes_method2 
	+ -n :Number of the tasks in the initial system

	+ -i :input initial system model 
	
	+ -nb_partitions :  Maximum number of partitions

	+ -iter : number of iterations

	+ -sched : Scheduling policy
	
	+ -select : PAES strategy 
	
	+ -fitness : List of fitness

	+ -DW_capacity : Capacity of downgraders 

Example: Running PAES on the ROSACE study case; hyperperiod = 4250; time_unit of partition = duration of partition = 250

./F2T_paes_method2 -n 15 -i test_Rosace_initial -nb_partitions 2 -iter 5000 -sched HOP -select global -fitness "f1 f2 f3" -DW_capacity 166
	




INSTRUCTION FOR PAES METHOD WITHOUT AN INITIAL SYSTEM MODEL (We generate an initial system model by using Unifast)

- ./F2T_paes_method2 
	+ -n :Number of the tasks to generate
	
	+ -nb_partitions :  Maximum number of partitions

	+ -iter : number of iterations

	+ -sched : Scheduling policy
	
	+ -select : PAES strategy 
	
	+ -fitness : List of fitness

	+ -u       : Total CPU utilization

	+ -n_diff_periods : number of maximum different periods

	+ -DW_capacity : Capacity of downgraders 

Example: Running PAES on the ROSACE study case; hyperperiod = 4250; time_unit of partition = duration of partition = 250

./F2T_paes_method2 -n 15 -nb_partitions 2 -iter 2  -sched HOP -select global -fitness "f1 f2 f3" -u 90  -n_diff_periods 2 -DW_capacity 166



#Input of Exhaustive method
- Number of tasks in the initial system
- A xml file containing a system (set of processors, tasks, dependencies ...): the initial system
- Maximum number of partitions 
- Scheduling policy
- List of objectives fitness

#Output of Exhaustive method
- solutions_exact_front.txt : shows the list of non-dominated solutions and the values of their objectives fitness
- front_optimal.dat : shows on each line, the list of the values of objectives fitness of a non-dominated solution
- Exhaustive_Execution_iter.dat : shows the values of objectives fitness of each generated solution, the number of rejected solution during archiving process
- runtime_exhaustive_method.txt : shows the runtime of the Exhaustive method
- Solution"i".xmlv3: representes the "i"th non-dominated solutions



=========INSTRUCTION EXHAUSTIVE METHOD=========

- cd {Cheddar Directory}/trunk/src
- source ../compilelinux64.bash
- make callCheddar2
- make F2T_exhaustive_method2

INSTRUCTION FOR EXHAUSTIVE METHOD WITH AN INITIAL SYSTEM MODEL

- ./F2T_exhaustive_method2 
	+ -n :Number of the tasks in the initial system

	+ -i :input initial system model 
	
	+ -nb_partitions :  Maximum number of partitions

	+ -sched : Scheduling policy
	
	+ -fitness : List of fitness

	+ -DW_capacity : Capacity of downgraders 

Example: Running Exhaustive on the ROSACE study case; hyperperiod = 4250; time_unit of partition = duration of partition = 250

	./F2T_exhaustive_method2 -n 15 -i test_Rosace_initial -nb_partitions 2 -sched HOP -fitness "f1 f2 f3" -DW_capacity 166
	

INSTRUCTION FOR EXHAUSTIVE METHOD WITHOUT AN INITIAL SYSTEM MODEL (We generate an initial system model by using Unifast)

- ./F2T_exhaustive_method2 
	+ -n :Number of the tasks in the initial system
	
	+ -nb_partitions :  Maximum number of partitions

	+ -sched : Scheduling policy
	
	+ -fitness : List of fitness

	+ -u       : Total CPU utilization

	+ -n_diff_periods : number of maximum different periods

	+ -DW_capacity : Capacity of downgraders 

Example: Running Exhaustive on the ROSACE study case; hyperperiod = 4250; time_unit of partition = duration of partition = 250

	./F2T_exhaustive_method2 -n 15 -nb_partitions 2 -sched HOP -fitness "f1 f2 f3" -u 90  -n_diff_periods 2 -DW_capacity 166
	


