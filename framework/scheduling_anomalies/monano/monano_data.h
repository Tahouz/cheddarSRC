
#ifndef  MONANO_DATA_H
#define  MONANO_DATA_H yes

#include <sched.h>
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> 
#include <pthread.h>
#include <string.h>
#include <sched.h>
#include <time.h>

#include "ts.h"
#include "returncode.h"


/* To store data on thread during the execution of the application */
typedef struct pthread_monano_list {
  pthread_monano_id_t id;
  struct pthread_monano_list* suivant;
}pthread_monano_list;


/* Containt a list of executed thread to find out if dependencies are respected */
extern struct pthread_monano_list *dependencies_list;

/* Containt a list of executed thread to find out if all wcet have been reduced */
extern struct pthread_monano_list *thread_execution_list_processor_speed;

/* containt a list of thread preemption */
extern struct pthread_monano_list *thread_preemption_list;




/* Add a thread in a list at the begin */
pthread_monano_list* pthread_monano_add_thread(pthread_monano_list* l, pthread_monano_id_t val);

/* To find if a thread is in a list */
int pthread_monano_search_thread(pthread_monano_list* l, pthread_monano_id_t val);

/* Remove  the thread at the top of the list */
pthread_monano_list* pthread_monano_remove_thread(pthread_monano_list* l);

/* Return the id of the thread at the top of the list */
pthread_monano_id_t pthread_monano_head_thread(pthread_monano_list* l);

/* To have the number of thread in the list */
int pthread_monano_count_thread(pthread_monano_list* l);



#endif

