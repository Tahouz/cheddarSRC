=========SUMMARY=========
- Running of PAES method and Exhaustive method. Both use callCheddar_securityAnalysis to perform scheduling and security analysis of solutions


#Input of callCheddar_securityAnalysis
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
- make callCheddar_securityAnalysis
- make T2P_and_security_paes

INSTRUCTION FOR PAES METHOD WITH AN INITIAL SYSTEM MODEL
- ./T2P_and_security_paes 
	+ -n :Number of the tasks in the initial system

	+ -i :input initial system model 
	
	+ -nb_partitions :  Maximum number of partitions

	+ -iter : number of iterations

	+ -sched : Scheduling policy
	
	+ -select : PAES strategy 
	
	+ -fitness : List of fitness

	+ -nb_app  : number of applications in the model

	+ -exploration_version : exploration based on app_grain (1), mix_grain (2) or task_grain (3) algorithms
	
	+ -intra_partition_safe : assumption if all the intra partition communications are attackable by assumption (1) or not (0) 

				  intra_partition_safe=0 -- the intra partition communications are not attackable
				  intra_partition_safe=1 -- the intra partition communications  can be attacked (no hypothesis or there is a 					  memory protection between tasks inside a partition) 

Example: Running PAES on the ROSACE and JPEG study case with a maximum of 2 partitions; hyperperiod = 4125; 
time_unit of partition = duration of a partition = 125; the schedulability of partitions are defined in partition_scheduling_paes1.xmlv3 and partition_scheduling_paes2.xmlv3 in folder ./architecture_eploration_tools/example_partition_scheduling;
DW_capacity_encrypt(Rosace)= DW_capacity_decrypt(Rosace)=1; DW_capacity_encrypt(JPEG)= DW_capacity_decrypt(JPEG)=1683; Key_capacity_DW=9

./T2P_and_security_paes -i test_Rosace_Jpeg -n 22 -nb_partitions 2 -nb_app 2 -iter 10 -sched HOP -fitness "f12 f13 f14" -select local -exploration_version 1 -intra_partition_safe 1



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
- make callCheddar_securityAnalysis
- make T2P_and_security_exhaustive

INSTRUCTION FOR EXHAUSTIVE METHOD WITH AN INITIAL SYSTEM MODEL

- ./T2P_and_security_exhaustive 
	+ -n :Number of the tasks in the initial system

	+ -i :input initial system model 
	
	+ -nb_partitions :  Maximum number of partitions

	+ -sched : Scheduling policy
	
	+ -fitness : List of fitness

	+ -nb_app  : number of applications in the model

	+ -intra_partition_safe : assumption if all the intra partition communications are attackable by assumption (1) or not (0) 

				  intra_partition_safe=0 -- the intra partition communications are not attackable
				  intra_partition_safe=1 -- the intra partition communications  can be attacked (no hypothesis or there is a 					  memory protection between tasks inside a partition) 


	

Example: Running Exhaustive on the ROSACE and JPEG study case with a maximum of 2 partitions; hyperperiod = 4125; 
time_unit of partition = duration of a partition = 125; the schedulability of partitions are defined in partition_scheduling_paes1.xmlv3 and partition_scheduling_paes2.xmlv3 in folder ./architecture_eploration_tools/example_partition_scheduling; 
DW_capacity_encrypt(Rosace)= DW_capacity_decrypt(Rosace)=1; DW_capacity_encrypt(JPEG)= DW_capacity_decrypt(JPEG)=1683; Key_capacity_DW=9

	

./T2P_and_security_exhaustive -i test_Rosace_Jpeg -n 22 -nb_partitions 2 -nb_app 2  -sched HOP -fitness "f12 f13 f14" -intra_partition_safe 1

