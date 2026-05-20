How to detect dynamic constraints?

FAIT Changing priority
- Event to detect             : a thread of ROSACE has changed its priority 
- How to create the event     : the ROSACE thread call pthread_setschedparam
                    (see source code with CONFIGURE_MONANO_CHANGE_PRIORITY)
- How monano detect the event : monano call pthread_getschedparam when threads calls 
				monano_signal_departure and compare with values stored in monano_t. 
				If the 2 values are different,the callback is called.

FAIT Weakening precedence constraints
- Event to detect             : thread depencency are not met during execution time 
- How to create the event     : the application runs the threads without precedence constraint                                 (see source code with CONFIGURE_MONANO_WEAKENING_PRECEDENCE_CONSTRAINTS
- How monano detect the event : monano_t containt a list. When a thread calls 
                                monano_signal_end_time, the thread is stored in the list.
                                when a thread calls monano_signal_departure_time, monano
                                checks with the list if the dependencies are met according to the 
				precedence constraint store in monano_t
				if not, the callback is called, otherwise the list is updated. 

A FAIRE Increasing period
- Event to detect             : a thread has changed its period  
- How to create the event     : the application call monano_setperiod to change the period thread
                    (see source code with CONFIGURE_MONANO_INCREASE_PERIOD)
- How to detect the event     : monano check if the static constraint are true and 
				compares the period value given when a thread calls
                                monano_setperiod with the one store in monano_t.
			        If the 2 values are different, the callback is called.
 
A FAIRE : verifier comment lire frequence processeur sur RTEMS et LINUX Increasing processor speed
- Event to detect             : a thread sees its execution strongly reduced, for example, divide by 2
- How to create the event     : the application simulates/runs a shorter execution time
                    (see source code with CONFIGURE_MONANO_INCREASE_PROCESSOR_SPEED)
- How to detect the event     : monano stores in monano_t the thread departure time when the thread 
			      	calls monano_signal_departure_time. When the thread calls 
		                monano_signal_end_time compute the actual execution time is computed.
		                If all threads see their execution time divide by a same value,
                		the callback is called.

A FAIRE : regarder affinity pour LINUX et RTEMS Increasing processor number
- Event to detect   	      : thread affinity are changed 
- How to create the event     : the application has threads affined to specific cores/processor
                    (see source code with CONFIGURE_MONANO_CHANGE_PRIORITY)
- How to detect the event     : monano stores in monano_t the thread affinity.
                            	each time a thread call a monano function, the affinity is check.
                            If the number of processors/cores used by the application is 
                            increased, then callback is called. 

A FAIRE Delaying execution time
- Event to detect             : a thread using a critical resource is delay during its execution
- How to create the event     : 
                    (see source code with CONFIGURE_MONANO_DELAYING_EXECUTION)
- How to detect the event : 


A REVOIR  Reducing execution time    
- Event to detect             : a thread sees its execution reduced
- How to create the event     : the application simulates/runs a different execution time
                    (see source code with CONFIGURE_MONANO_REDUCE_EXECUTION)
- How to detect the event     : monano stores in monano_t the thread departure time when 
                  		thread i calls monano_signal_departure_time. When thread i calls 
                  		monano_signal_end_time compute the actual execution time is computed.
				and if it is different from the one initially specified in monano_t
				the callback is called. Thread i may be preempted between signal_departure_time and signal_end_time by several threads j which has a higher priority level. To account for the time thread i did not run during such preemption, when computing  the actual execution of thread i, we substract recursively the execution of time of all j threads that started after departure time of thread i. 

-------------------------------------------------

How to implement static constraints in ROSACE with a uniprocessor RTEMS?

Suspended threads (see code CONFIGURE_MONANO_SUSPENDED_TASKS)
  We use nanosleep to suspend a thread during a given time 

Non preemptive scheduling  
  We Use a globally shared pthread_mutex used by all threads. 
  We Call mutex_lock just after monano_signal_departure_time 
     and call mutex_unlok just before monano_signal_end_time

Deadline monotonic priority assignment
  We use pthread_setschedparam to assign thread priority according to
     Deadline monotonic

Threads asynchronously released
  We use nanosleep to delay its first release

Shared resources
  we use pthread_mutex_t to implement shared resources into ROSACE

Precedence constraints 
  We use a counting semaphore (sem_t) to change the execution
     order of the threads, ??



