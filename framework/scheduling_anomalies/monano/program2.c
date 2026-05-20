#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> 
#include <pthread.h>
#include <string.h>
#include <sched.h>
#include <time.h>
#include "ts.h"
#include <semaphore.h>
#include "returncode.h"
#include "time_conversion.h"

#include "monano.h"
#include "monano_data.h"

#define NTHREAD 2 


struct pthread_monano_t my_monano;
struct pthread_monano_attr_t my_monano_attr;
pthread_monano_id_t my_monano_id [NTHREAD];



void* my_callback(int anomaly_number, pthread_monano_id_t id)
{
 	printf("Type anomaly : %d Anomaly is detected of thread number %d\n", anomaly_number, id);
	
	exit(0);
	return 0;
}


void* periodic_activation(void* arg){

	int ego = *(int*)arg, status;
	

	
	/* Called by a thread to signal to MONANO that the thread has started its execution */	
	status=pthread_monano_signal_departure_time(&my_monano, my_monano_id[ego]);
	if(status<0)
	  returncode("pthread_monano_signal_departure_time",status);
	    
	/* Simulate an execution of code*/	
	
	status=pthread_monano_thread_execution(&my_monano, my_monano_id[ego]);
	if(status<0)
	  returncode("thread_execution",status);
	
	/* Called by a thread to signal to MONANO that  the thread has completed its execution */
	status=pthread_monano_signal_end_time(&my_monano, my_monano_id[ego]);
	if(status<0)
	  returncode("pthread_monano_signal_end_time",status);

	
	
	return 0;
	
		
}

void run_monano()
{
  
  
  int status, i, nb;
  int* ego;
  struct sched_param param;

  //struct timespec P1, WCET1, D1, P2, WCET2, D2;
  struct pthread_monano_attr_t tparam []={{99,{2,0},{3,0},{3,0}},{98,{2,0},{9,0},{9,0}}}; 


   /* Upgrade main thread priority */
  param.sched_priority=100;
  status=pthread_setschedparam(pthread_self(), SCHED_FIFO, &param);
  if(status<0)
    returncode("pthread_attr_setschedparam",status);



  /* Monano init and register */
  pthread_monano_init(&my_monano);
  pthread_monano_attr_init(&my_monano_attr);
  
  nb=sizeof(tparam)/sizeof(tparam[0]);
  
  pthread_monano_register_anomaly_callback(&my_monano, my_callback);

  for(i=0; i<nb;i++){
    pthread_monano_attr_setperiod(&my_monano_attr, tparam[i].period);
    pthread_monano_attr_setwcet(&my_monano_attr, tparam[i].wcet);
    pthread_monano_attr_setdeadline(&my_monano_attr, tparam[i].deadline);
    pthread_monano_attr_setpriority(&my_monano_attr, tparam[i].priority);
    
    printf("period P%d=%d:%d wcet%d=%d:%d\n",i+1, (int)my_monano_attr.period.tv_sec, (int)my_monano_attr.period.tv_nsec,i+1, (int)my_monano_attr.wcet.tv_sec, (int)my_monano_attr.wcet.tv_nsec);
    

    /* create a monano periodic thread */
    ego=(int*)malloc(sizeof(int));
    *ego=i;
    status=pthread_monano_periodic_thread_create (&my_monano, my_monano_attr, periodic_activation, &my_monano_id[i], ego);
    if(status<0){
      returncode("pthread_monano_pthread_create",status);
    }

  }

  
  pthread_exit(NULL);
  
}

