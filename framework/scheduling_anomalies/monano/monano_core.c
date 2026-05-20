#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> 
#include <pthread.h>
#include <string.h>
#include <sched.h>
#include <time.h>
#include <semaphore.h>
#include <stdbool.h>
#include "ts.h"
#include "returncode.h"

#include "monano.h"
#include "monano_data.h"
#include "monano_constraints.h"
#include "configure.h"



int pthread_monano_add_pthread_precedencies(pthread_monano_t *t, pthread_monano_precedency_t pred)
{
  int status;
  
  status=pthread_mutex_lock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_lock",status);
  
  t->pthread_precedencies[t->nb_precedencies] = pred;
  t->nb_precedencies++;
  
  printf("t->nb_precedencies = %d \n", t->nb_precedencies);
  
  status=pthread_mutex_unlock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_unlock",status);

  return 0;
}

/* initialize MONANO services */
int pthread_monano_init (pthread_monano_t* t ){

  int status, i;
  
  t->stop=1;
  t->nb_thread=0;
  t->nb_precedencies=0;
   
  /*initialise static constraint of the application */
  for(i=0;i<CONFIGURE_MAXIMUM_MONANO_THREAD_STATIC_CONSTRAINTS;i++)
    t->static_constraints[i]=false;
    
  /*initialise dynamic constraint of the application */
  for(i=0;i<CONFIGURE_MAXIMUM_MONANO_THREAD_DYNAMIC_CONSTRAINTS;i++)
    t->dynamic_constraints[i]=false;
  
  /* Measure and store start time of the application */
  status=clock_gettime(CLOCK_REALTIME, &t->critical_instant);
  if(status<0)
    returncode("clock_gettime",status);

  status=pthread_mutex_init(&t->sc, NULL);
  if(status<0)
    returncode("pthread_mutex_init",status);

  return 0;
}



typedef struct monano_thread_argument_t {
        int ego;
        struct pthread_monano_t* a_monano;
} monano_thread_argument_t;



void* periodic_thread(void* arg)
{
        
  struct monano_thread_argument_t* a = (monano_thread_argument_t*)arg;

  a->a_monano->attr[a->ego].last_release_time=a->a_monano->critical_instant;
  struct timespec waittime;
  struct timespec currenttime;
  
  int status;
  
  while(a->a_monano->stop==1)
  {
    printf("Thread %x : period = %d:%d\n",pthread_self(), (int)a->a_monano->attr[a->ego].period.tv_sec, (int)a->a_monano->attr[a->ego].period.tv_nsec);

    
    /* Call user function */
    a->a_monano->periodic_func[a->ego](a->a_monano->periodic_func_arg[a->ego]);
        
    a->a_monano->attr[a->ego].last_release_time=
	    ts_add(a->a_monano->attr[a->ego].period, a->a_monano->attr[a->ego].last_release_time);
	    
    /* Compute the next release time */
    status=clock_gettime(CLOCK_REALTIME, &currenttime);
    if(status<0)
      returncode("clock_gettime",status);
    
    /* wait for the next release time */
    waittime=ts_substract(a->a_monano->attr[a->ego].last_release_time, currenttime);
    nanosleep(&waittime, NULL);
    
  }
  pthread_exit(NULL);
  return 0;
}


int pthread_monano_periodic_thread_create (pthread_monano_t* t, pthread_monano_attr_t attr, pthread_monano_function_t func, pthread_monano_id_t* id, void* monano_thread_arg)
{
  struct sched_param param;  
  int status;
  pthread_t pthread_id;
  pthread_attr_t scheduling_attr;
  monano_thread_argument_t* a_thread_arg;
  
  status=pthread_mutex_lock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_lock",status);

  t->attr[t->nb_thread]=attr;
  t->periodic_func_arg[t->nb_thread]=monano_thread_arg;
  t->periodic_func[t->nb_thread]=func;
  
  pthread_attr_init(&scheduling_attr);
  status=pthread_attr_setinheritsched(&scheduling_attr,PTHREAD_EXPLICIT_SCHED);
  if(status<0)
    returncode("pthread_attr_setinheritsched",status);
  status=pthread_attr_setschedpolicy(&scheduling_attr,SCHED_FIFO);
  if(status<0)
    returncode("pthread_attr_setschedpolicy",status);
  
  param.sched_priority=t->attr[t->nb_thread].priority;
  status=pthread_attr_setschedparam(&scheduling_attr,&param);
  if(status<0)
    returncode("pthread_attr_setschedparam",status);

    
  /* allocate thread argument */
  a_thread_arg = (struct monano_thread_argument_t*)malloc(sizeof(struct monano_thread_argument_t));
  a_thread_arg->ego=t->nb_thread;  
  a_thread_arg->a_monano=t;

  printf("sizeof de monano_thread_argument_t %d \n", sizeof(a_thread_arg));
  
  /* create thread */
  status=pthread_create(&pthread_id, &scheduling_attr, periodic_thread, a_thread_arg);
  if(status<0)
  {
    returncode("pthread_monano_periodic_create",status);
    return status;    
  }

 
  *id=t->nb_thread;
  t->nb_thread++;
    
  status=pthread_mutex_unlock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_unlock",status);

    
  return 0;
   
}



/* Register the C function called by monano when a scheduling anamaly is detected by monano */
int pthread_monano_register_anomaly_callback(pthread_monano_t* t, pthread_monano_callback_func_t a_func) 
{
  int status;
  
  status=pthread_mutex_lock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_lock",status);  
  
  t->callback=a_func;
  
  status=pthread_mutex_unlock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_unlock",status);
  
  return 0;
}


/* Called by a thread to signal to MONANO that the thread has started its execution */
int pthread_monano_signal_departure_time(pthread_monano_t* t, pthread_monano_id_t id) 
{
  // register in t the start time of the thread
  int status;

  status=pthread_mutex_lock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_lock",status);  

  status=clock_gettime(CLOCK_REALTIME, &t->attr[id].start_time);
  if(status<0)
    returncode("clock_gettime",status);
  
#ifdef CONFIGURE_MONANO_RTEMS48
 #ifdef CONFIGURE_MONANO_COMPUTE_MANY_INSTANCE_TASKS_EXECUTION_TIME
  
  thread_preemption_list = pthread_monano_add_thread(thread_preemption_list, id);
  
//verify static_constraints of scheduling anomaly precedence constraint weakness
if (pthread_monano_verify_static_constraints_precedence_constraint_change(t)){
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_STATIC_CONSTRAINTS_VALIDATED);
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
        status = pthread_monano_verify_precedence_constraint_change(t, id);
        if(status<0) returncode("pthread_monano_verify_precedence_constraint",status);
     }

//verify static_constraints of scheduling anomaly delay thread execution
if (pthread_monano_verify_static_constraints_delay_thread_execution(t)){
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_STATIC_CONSTRAINTS_VALIDATED);
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
        status = pthread_monano_verify_delay_thread_execution(t, id);
        if(status<0) returncode("pthread_monano_verify_delay_thread_execution",status);
     }
    
 #endif
#endif
  
  status=pthread_mutex_unlock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_unlock",status);
  
  return 0;
	
}


/* Called by a thread to signal to MONANO that  the thread has completed its execution */
int pthread_monano_signal_end_time(pthread_monano_t* t, pthread_monano_id_t id) 
{ 
// register in t the end time of the thread
  int status;
  status=pthread_mutex_lock(&t->sc);
  if(status<0)    
    returncode("pthread_mutex_lock",status);
  
  status=clock_gettime(CLOCK_REALTIME, &t->attr[id].end_time);
  if(status<0)
    returncode("clock_gettime",status);

#ifndef CONFIGURE_MONANO_RTEMS48
 #ifdef CONFIGURE_MONANO_COMPUTE_ONE_INSTANCE_TASKS_EXECUTION_TIME

  t->attr[id].current_execution_time = ts_substract(ts_substract(t->attr[id].end_time,t->attr[id].start_time),t->attr[id].blocking_time);
  int i;
  for (i=0; i<t->nb_thread; i++){
    if (i!=id){
      if ((ts_compare(t->attr[i].start_time, t->attr[id].start_time)>=0) && (ts_compare(t->attr[id].end_time, t->attr[i].end_time)>=0))
	t->attr[id].current_execution_time = ts_substract(t->attr[id].current_execution_time, ts_substract(t->attr[i].end_time, t->attr[i].start_time));
    }
  }

 #endif
#endif 

#ifdef CONFIGURE_MONANO_RTEMS48
 #ifdef CONFIGURE_MONANO_COMPUTE_MANY_INSTANCE_TASKS_EXECUTION_TIME
 
  pthread_monano_id_t id_thread;

  t->attr[id].current_execution_time = ts_substract(ts_substract(ts_substract(ts_substract(t->attr[id].end_time,t->attr[id].start_time),t->attr[id].blocking_time), t->attr[id].preemption_time),t->attr[id].selfsuspension);

  //verify if one or more other threads have preempted a thread and compute the preemption time of this thread
  thread_preemption_list = pthread_monano_remove_thread(thread_preemption_list);
  if (thread_preemption_list !=NULL){
    id_thread=pthread_monano_head_thread(thread_preemption_list);

    t->attr[id_thread].preemption_time= ts_add(ts_add(ts_substract(t->attr[id].end_time,t->attr[id].start_time),t->attr[id].blocking_time),t->attr[id_thread].preemption_time);
  
  }
  //Store all threads whose ratio of real execution time to their WCET is more than 2
  if (ts_compare(ts_substract(t->attr[id].wcet,t->attr[id].current_execution_time),t->attr[id].current_execution_time)==1){
    if(pthread_monano_search_thread(thread_execution_list_processor_speed,id)==0)
        thread_execution_list_processor_speed=pthread_monano_add_thread(thread_execution_list_processor_speed, id); 
  }
  
  t->attr[id].preemption_time.tv_sec=0;
  t->attr[id].preemption_time.tv_nsec=0;


 #endif
#endif

//  printf("avant verify reduce execution_time de %x : id = %d: %d:%d \n", pthread_self(), id, (int)t->attr[id].current_execution_time.tv_sec, (int)t->attr[id].current_execution_time.tv_nsec);

//verify static_constraints of scheduling anomaly reduce execution time
if (pthread_monano_verify_static_constraints_reduce_execution_time(t)){
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_STATIC_CONSTRAINTS_VALIDATED);
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
        status = pthread_monano_verify_reduce_execution_time(t, id);
        if(status<0) returncode("pthread_monano_verify_reduce_execution_time",status);
     }
 
//verify static_constraints of scheduling anomaly priority change
if (pthread_monano_verify_static_constraints_priority_change(t)){
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_STATIC_CONSTRAINTS_VALIDATED);
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
        status = pthread_monano_verify_priority_change(t,id);
        if(status<0) returncode("pthread_monano_verify_priority_change",status);
     }


//verify static_constraints of scheduling anomaly processor speed
if (pthread_monano_verify_static_constraints_processor_speed_increase(t)){
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_STATIC_CONSTRAINTS_VALIDATED);
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
        status = pthread_monano_verify_processor_speed_increase(t,id);
        if(status<0) returncode("pthread_monano_verify_processor_speed_increase",status);
     }

//verify static_constraints of scheduling anomaly period change
if (pthread_monano_verify_static_constraints_period_change(t)){
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_STATIC_CONSTRAINTS_VALIDATED);
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
        status = pthread_monano_verify_period_change(t,id);
        if(status<0) returncode("pthread_monano_verify_period_change",status);
     }

//verify static_constraints of scheduling anomaly deadline increase
if (pthread_monano_verify_static_constraints_deadline_increase(t)){
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_STATIC_CONSTRAINTS_VALIDATED);
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
        status = pthread_monano_verify_deadline_increase(t,id);
        if(status<0) returncode("pthread_monano_verify_deadline_increase",status);
     }

//verify static_constraints of scheduling anomaly reduce preemption delay
if (pthread_monano_verify_static_constraints_reduce_preemption_delay(t)){
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_STATIC_CONSTRAINTS_VALIDATED);
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
        status = pthread_monano_verify_reduce_preemption_delay(t,id);
        if(status<0) returncode("pthread_monano_verify_reduce_preemption_delay",status);
     }


//verify static_constraints of scheduling anomaly reduce selfsuspension time
if (pthread_monano_verify_static_constraints_reduce_self_suspension(t)){
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_STATIC_CONSTRAINTS_VALIDATED);
        pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
        status = pthread_monano_verify_reduce_self_suspension(t,id);
        if(status<0) returncode("pthread_monano_verify_reduce_preemption_delay",status);
     }
       


  t->attr[id].blocking_time.tv_sec=0;
  t->attr[id].blocking_time.tv_nsec=0;

#ifdef CONFIGURE_MONANO_RTEMS48
 #ifdef CONFIGURE_MONANO_PRECEDENCE_CONSTRAINTS
  
  if(t->nb_precedencies !=0)
    dependencies_list= pthread_monano_add_thread(dependencies_list, id);   
  
 #endif
#endif
  
  
  
  status=pthread_mutex_unlock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_unlock",status);
  
  
  
  return 0;
}


int pthread_monano_stop (pthread_monano_t* t ) 
{
  int status;

  status=pthread_mutex_lock(&t->sc);
  if(status<0)    
    returncode("pthread_mutex_lock",status);
  
  t->stop=0;
  
  status=pthread_mutex_unlock(&t->sc);
  if(status<0)    
    returncode("pthread_mutex_unlock",status);

  exit(0);

  return 0;
	
}


int pthread_monano_signal_unblock_time(pthread_monano_t* t, pthread_monano_id_t id) 
{
  struct timespec currenttime;
  int status; 
  
  status=pthread_mutex_lock(&t->sc);
  if(status<0)    
    returncode("pthread_mutex_lock",status);
  
  status=clock_gettime(CLOCK_REALTIME, &currenttime);
  if(status<0)
    returncode("clock_gettime",status);
  
  
  t->attr[id].blocking_time = ts_add(t->attr[id].blocking_time, ts_substract(currenttime, t->attr[id].start_blocking_time));

  
  
  status=pthread_mutex_unlock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_unlock",status);


  return 0;
}


int pthread_monano_signal_block_time(pthread_monano_t* t, pthread_monano_id_t id) 
{
  struct timespec init;
  int status; 
  
  init.tv_sec=0;
  init.tv_nsec=0;
  
  status=pthread_mutex_lock(&t->sc);
  if(status<0)    
    returncode("pthread_mutex_lock",status);
  

  status=clock_gettime(CLOCK_REALTIME, &t->attr[id].start_blocking_time);
  if(status<0)
    returncode("clock_gettime",status);

 
  status=pthread_mutex_unlock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_unlock",status);


  return 0;
}

int pthread_monano_signal_departure_selfsuspending_time(pthread_monano_t* t, pthread_monano_id_t id) 
{
  struct timespec init;
  int status; 
  
  init.tv_sec=0;
  init.tv_nsec=0;
  
  status=pthread_mutex_lock(&t->sc);
  if(status<0)    
    returncode("pthread_mutex_lock",status);
  

  status=clock_gettime(CLOCK_REALTIME, &t->attr[id].start_selfsuspending_time);
  if(status<0)
    returncode("clock_gettime",status);

 
  status=pthread_mutex_unlock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_unlock",status);


  return 0;
}

int pthread_monano_signal_end_selfsuspending_time(pthread_monano_t* t, pthread_monano_id_t id) 
{
  struct timespec init, currenttime;
  int status; 
  
  init.tv_sec=0;
  init.tv_nsec=0;
  
  status=pthread_mutex_lock(&t->sc);
  if(status<0)    
    returncode("pthread_mutex_lock",status);
  
status=clock_gettime(CLOCK_REALTIME, &currenttime);
  if(status<0)
    returncode("clock_gettime",status);
    
  t->attr[id].selfsuspending_time = ts_substract(currenttime, t->attr[id].start_selfsuspending_time);  
 
  status=pthread_mutex_unlock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_unlock",status);


  return 0;
}

pthread_monano_attr_t pthread_monano_get_attribute(pthread_monano_t* t, pthread_monano_id_t id) {

  struct pthread_monano_attr_t res;
  int status;
  
  status=pthread_mutex_lock(&t->sc);
  if(status<0)    
    returncode("pthread_mutex_lock",status);
  
  res=t->attr[id];
 
  status=pthread_mutex_unlock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_unlock",status);

  return res;
}




