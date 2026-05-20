#include <sched.h>
#include <semaphore.h>

#ifndef  MONANO_H
#define  MONANO_H yes


/* RTEMS like configuration constants */

#define CONFIGURE_MAXIMUM_MONANO_THREAD_NUMBER    			25
#define CONFIGURE_MAXIMUM_MONANO_THREAD_PRECEDENCIES_NUMBER   		10
#define CONFIGURE_MAXIMUM_MONANO_THREAD_SHARED_RESOURCES_NUMBER		10
#define CONFIGURE_MAXIMUM_MONANO_THREAD_STATIC_CONSTRAINTS		17


/* Types of anomalies detected by MONANO */
#define REDUCE_WCET_ANOMALY		0
#define PRIORITY_ANOMALY		1 
#define DEPENDENCY_ANOMALY		2
#define SPEED_PROCESSOR_ANOMALY		3
#define DELAY_WCET_ANOMALY		4
#define PERIOD_ANOMALY			5
#define NUMBER_PROCESSOR_ANOMALY	6


/* Static constraints on the execution platform */
#define MONANO_STATIC_CONSTRAINTS_MONOCORE			0
#define MONANO_STATIC_CONSTRAINTS_MULTICORE			1
#define MONANO_STATIC_CONSTRAINTS_PARTITIONED			2
#define MONANO_STATIC_CONSTRAINTS_GLOBAL			3
#define MONANO_STATIC_CONSTRAINTS_FIXED_PRIORITY		4
#define MONANO_STATIC_CONSTRAINTS_EDF_SCHEDULING		5
#define MONANO_STATIC_CONSTRAINTS_DEADLINE_MONOTONIC		6
#define MONANO_STATIC_CONSTRAINTS_PREEMPTIVE			7
#define MONANO_STATIC_CONSTRAINTS_NON_PREEMPTIVE		8

/* Static constraints on the tasks */
#define MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE		9
#define MONANO_STATIC_CONSTRAINTS_ASYNCHRONOUS_RELEASE 		10
#define MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS		11
#define MONANO_STATIC_CONSTRAINTS_INDEPENDENT_TASKS		12
#define MONANO_STATIC_CONSTRAINTS_SUSPENDED_TASKS		13
#define MONANO_STATIC_CONSTRAINTS_PRECEDENCE_CONSTRAINTS	14
#define MONANO_STATIC_CONSTRAINTS_SHARED_RESOURCES		15
#define MONANO_STATIC_CONSTRAINTS_APERIODIC_TASKS		16

/*Define a type for static constraints */
typedef int pthread_monano_static_constraints_t;

/* Define what a monano pthread id is */
typedef int pthread_monano_id_t;

/* Function to indicate the type of anomaly and the thread involved in the anomaly */
/* This type is the type of MONANO callback */
typedef void* (*callback_func_t) (int number_of_anomalie, pthread_monano_id_t id);


/* Type of function run by any MONANO thread */
/* As POSIX thread, arg is an argument given when threads are created 
   and pass to the code of the thread at each periodic release */
typedef void* (*thread_function_t) (void* arg);


/* Store data on precedence constraint */
typedef struct pthread_monano_precedency_t {
  pthread_monano_id_t source;
  pthread_monano_id_t destination;
} pthread_monano_precedency_t;


/* Store all parameters of a MONANO thread */
typedef struct pthread_monano_attr_t {

  /* Static architecture parameters */
  int priority;
  struct timespec wcet;
  struct timespec deadline;
  struct timespec period;
  struct timespec departure;
  struct timespec delay;

  /* Dynamic runtime parameters */
  struct timespec start_time;
  struct timespec end_time; 
  struct timespec current_execution_time; 
} pthread_monano_attr_t;



// All data of the MONANO monitor
typedef struct pthread_monano_t {

  /* Functions (and their arguments) run by each thread */
  thread_function_t periodic_func [CONFIGURE_MAXIMUM_MONANO_THREAD_NUMBER];
  void* periodic_func_arg [CONFIGURE_MAXIMUM_MONANO_THREAD_NUMBER];

  /* Data to store static and dynamic thread data */
  struct pthread_monano_attr_t attr [CONFIGURE_MAXIMUM_MONANO_THREAD_NUMBER];

  /* Data to store dependencies between the threads */ 
  struct pthread_monano_precedency_t pthread_precedencies [CONFIGURE_MAXIMUM_MONANO_THREAD_PRECEDENCIES_NUMBER];
  
  /* Data to store static constraints  */
  pthread_monano_static_constraints_t  static_constraints [CONFIGURE_MAXIMUM_MONANO_THREAD_STATIC_CONSTRAINTS];
  
  /* Number of the precedence constraint of the program */
  int nb_precedencies; 
 
  /* Callback to call when an anomaly occurs */
  callback_func_t callback;

  /* Private data under this line */
  
  /* To protect pthread_monano_t data when several threads access it */
  pthread_mutex_t sc;

  /* Start time of the applicatio, */
  struct timespec critical_instant; 
  
  /* Counter to pthread id assignment, i.e. number of MONANO created threads */
  int nb_thread; 

  /* Boolean to stop MONANO */
  int stop;
  
} pthread_monano_t;



/* pthread_monano_attr */
/* pthread_monano_attr attribute accessor functions  */
extern int pthread_monano_attr_setpriority(pthread_monano_attr_t* attr, int prio);
extern int pthread_monano_attr_setwcet(pthread_monano_attr_t* attr, struct timespec  w);
extern int pthread_monano_attr_setdeadline(pthread_monano_attr_t* attr, struct timespec  d);
extern int pthread_monano_attr_setperiod(pthread_monano_attr_t* attr, struct timespec  p);
extern int pthread_monano_attr_setdeparture(pthread_monano_attr_t* attr, struct timespec  dep);
extern int pthread_monano_attr_setdelay(pthread_monano_attr_t* attr, struct timespec  del);
extern int pthread_monano_attr_setstart_time(pthread_monano_attr_t*, struct timespec stime);
extern int pthread_monano_attr_setend_time(pthread_monano_attr_t*, struct timespec etime);

/* pthread_monano_attr attribute modifier functions */
extern int pthread_monano_attr_getpriority(pthread_monano_attr_t attr);
extern struct timespec pthread_monano_attr_getwcet(pthread_monano_attr_t attr);
extern struct timespec pthread_monano_attr_getdeadline(pthread_monano_attr_t attr);
extern struct timespec pthread_monano_attr_getperiod(pthread_monano_attr_t attr);
extern struct timespec pthread_monano_attr_getdeparture(pthread_monano_attr_t attr);
extern struct timespec pthread_monano_attr_getdelay(pthread_monano_attr_t attr);
extern struct timespec pthread_monano_attr_getstart_time(pthread_monano_attr_t attr);
extern struct timespec pthread_monano_attr_getend_time(pthread_monano_attr_t attr);


/* pthread_monano_static constraints attribute accessors functions */
extern int pthread_monano_attr_getstatic_constraints(pthread_monano_t* t, int staticconstraint);
extern int pthread_monano_attr_setstatic_constraints(pthread_monano_t* t, int staticconstraint);


/* pthread_monano_precedency */
/* pthread_monano_precedency attribute accessors functions */
extern int pthread_monano_precedency_attr_setsource(pthread_monano_precedency_t* pred, pthread_monano_id_t s);
extern int pthread_monano_precedency_attr_setdestination(pthread_monano_precedency_t* pred, pthread_monano_id_t d);

/* pthread_monano_precedency attribute modifiers functions */
extern pthread_monano_id_t pthread_monano_precedency_attr_getsource(pthread_monano_precedency_t pred);
extern pthread_monano_id_t pthread_monano_precedency_attr_getdestination(pthread_monano_precedency_t pred);


/* Initialize precedence constraint data in the monitor */
extern int pthread_monano_add_pthread_precedencies(pthread_monano_t *t, pthread_monano_precedency_t pred);


/* Initialize thread parameters */
extern int pthread_monano_attr_init(pthread_monano_attr_t *attr);


/*  Initialize MONANO services */
extern int pthread_monano_init (pthread_monano_t* t );


/*  Stop MONANO and all created threads */
extern int pthread_monano_stop (pthread_monano_t* t );


/* Create a thread in MONANO */ 
extern int pthread_monano_periodic_thread_create (pthread_monano_t* t, pthread_monano_attr_t attr, thread_function_t func, pthread_monano_id_t* id, void* monano_thread_arg);


/* Register the callback (a C function) called by monano when a scheduling anomaly is detected */
extern int pthread_monano_register_anomaly_callback(pthread_monano_t* t, callback_func_t a_func);



/* Called by the monitored thread to signal to MONANO that the thread has started its execution */
extern int pthread_monano_signal_departure_time(pthread_monano_t* t, pthread_monano_id_t id);

/* Called by the monitored thread to signal to MONANO that the thread has completed its execution */
extern int pthread_monano_signal_end_time(pthread_monano_t* t, pthread_monano_id_t id);

/* Called by the monitored thread to signal to MONANO that the thread will run a blocking statement */
extern int pthread_monano_signal_block_time(pthread_monano_t* t, pthread_monano_id_t id);

/* Called by the monitored thread to signal to MONANO that the thread just completed n a blocking statement */
extern int pthread_monano_signal_unblock_time(pthread_monano_t* t, pthread_monano_id_t id);



#endif

