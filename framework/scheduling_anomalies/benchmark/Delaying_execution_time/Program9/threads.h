#ifndef __DEF_ROSACE_THREADS_H
#define __DEF_ROSACE_THREADS_H
#include <pthread.h>
#include <semaphore.h>
#include <time.h>
#include "assemblage_includes.h"
#include "configure.h"

#define CALL(val)       tasks[(val)].ne_t_body(NULL)


/* List of argument  with thread are started */
typedef struct thread_parameter  {
        struct timespec period;
        int val;
        // SR char* name  [100];
        char name  [100];
        int driving_thread;
} thread_parameter ;


/* simulation time */
extern long max_step_simu;


extern pthread_mutex_t shared_resources_engine_elevator;


/* code of the threads */
void* periodic_thread(void* parameter);

/* initialize the benchmark */
void rosace_init();

/* start the benchmark */
void run_rosace(void);



#endif

