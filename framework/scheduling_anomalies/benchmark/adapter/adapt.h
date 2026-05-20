#ifndef  ADAPT_H
#define  ADAPT_H yes

#include <sched.h>
#include <semaphore.h>
#include <pthread.h>



/*to initialize mutex or semaphore used */
extern int adapt_init();

/* start for a non preemptive execution of all thread of the system */
extern int adapt_start_non_preemptive_execution ();

/* end for a non preemptive execution of all thread of the system */
extern int adapt_end_non_preemptive_execution ();

/* start of asynchronous release execution of a thread of the system */
extern int adapt_start_asynchronous_release_execution();

/* end of asynchronous release execution of a thread of the system */
extern int adapt_end_asynchronous_release_execution();

/* start of thread suspension during its running time for a specific duration */
extern int adapt_start_suspended_threads_execution();

/* end of thread suspension during its running time for a specific duration */
extern int adapt_end_suspended_threads_execution();

/* start of execution of a schared resource by a thread during its running time for a specific duration */
extern int adapt_start_shared_resource_execution();

/* end of execution of a schared resource by a thread during its running time for a specific duration */
extern int adapt_end_shared_resource_execution();

#endif

