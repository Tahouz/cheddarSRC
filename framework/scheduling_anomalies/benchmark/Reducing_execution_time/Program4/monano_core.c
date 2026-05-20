#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> 
#include <pthread.h>
#include <string.h>
#include <sched.h>
#include <time.h>
#include "ts.h"
#include <semaphore.h>
#include "monano.h"
#include "returncode.h"

typedef struct pthread_list {
  pthread_monano_id_t id;
  struct pthread_list* suivant;
}pthread_list;

struct pthread_list *list=NULL, *list1=NULL;


//create a list of thread executed
pthread_list* add_thread(pthread_list* l, pthread_monano_id_t val)
{
  pthread_list* n=malloc(sizeof(pthread_list));
  
  n->id=val;
  n->suivant=l;
  
  return n;
  
}

// to find if a thread is in list of executed thread
pthread_list* search_thread(pthread_list* l, pthread_monano_id_t val)
{
  pthread_list* n=l;
  while(n != NULL)
  {
    if (n->id==val)
      return  n;
    
    n=n->suivant;   
     
  }
  
  return NULL; 
  
}

/*to have the number of thread in the list */
int count_thread(pthread_list* l){
 pthread_list* n=l;
 int nb=0;
  while(n != NULL)
  {
    nb++;    
    n=n->suivant;   
     
  }  
 return nb;
}

int pthread_monano_verify_static_constraint(pthread_monano_t *t)
{ 
  return 0;  
}

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
    t->static_constraints[i]=0;
  
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
  struct timespec nexttime=a->a_monano->critical_instant;
  struct timespec waittime;
  struct timespec currenttime;
  
  int status;
  
  while(a->a_monano->stop==1)
  {
    printf("Thread %x : period = %d:%d\n",pthread_self(), (int)a->a_monano->attr[a->ego].period.tv_sec, (int)a->a_monano->attr[a->ego].period.tv_nsec);

    
    /* Call user function */
    a->a_monano->periodic_func[a->ego](a->a_monano->periodic_func_arg[a->ego]);
    
    /* Compute the next release time */
    status=clock_gettime(CLOCK_REALTIME, &currenttime);
    if(status<0)
      returncode("clock_gettime",status);
    
    nexttime=ts_add(a->a_monano->attr[a->ego].period, nexttime);
    
    /* wait for the next release time */
    waittime=ts_substract(nexttime, currenttime);
    nanosleep(&waittime, NULL);
    
  }
  pthread_exit(NULL);
  return 0;
}


int pthread_monano_periodic_thread_create (pthread_monano_t* t, pthread_monano_attr_t attr, thread_function_t func, pthread_monano_id_t* id, void* monano_thread_arg)
{
  struct sched_param param;  
  pthread_t pthread_id;
  int status;
  pthread_attr_t scheduling_attr;
  monano_thread_argument_t* a_thread_arg;
  
  status=pthread_mutex_lock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_lock",status);

  pthread_attr_init(&scheduling_attr);
  status=pthread_attr_setinheritsched(&scheduling_attr,PTHREAD_EXPLICIT_SCHED);
  if(status<0)
    returncode("pthread_attr_setinheritsched",status);
  status=pthread_attr_setschedpolicy(&scheduling_attr,SCHED_FIFO);
  if(status<0)
    returncode("pthread_attr_setschedpolicy",status);
  
  t->attr[t->nb_thread]=attr;
  t->periodic_func_arg[t->nb_thread]=monano_thread_arg;
  t->periodic_func[t->nb_thread]=func;

  *id=t->nb_thread;  
  
  param.sched_priority=t->attr[t->nb_thread].priority;
  status=pthread_attr_setschedparam(&scheduling_attr,&param);
  if(status<0)
    returncode("pthread_attr_setschedparam",status);
    
  /* allocate thread argument */
  a_thread_arg = (struct monano_thread_argument_t*)malloc(sizeof(struct monano_thread_argument_t));
  a_thread_arg->ego=*id;
  a_thread_arg->a_monano=t;

  
  /* create thread */
  status=pthread_create(&pthread_id, &scheduling_attr, periodic_thread, a_thread_arg);
  if(status<0)
  {
    returncode("pthread_monano_periodic_create",status);
    return status;    
  }
  
  t->nb_thread++;
  
  status=pthread_mutex_unlock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_unlock",status);

    
  return 0;
   
}



/* Register the C function called by monano when a scheduling anamaly is detected by monano */
int pthread_monano_register_anomaly_callback(pthread_monano_t* t, callback_func_t a_func) {
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

/* Called by a thread to verify if the thread had change its priority level  */
int pthread_monano_verify_priority_change(pthread_monano_t* t, pthread_monano_id_t id) {
  
  int policy, status;
  struct sched_param param;

    status=pthread_getschedparam(pthread_self(), &policy, &param);
    if (status<0)
      returncode("pthread_getschedparam",status);
    
    if (t->attr[id].priority!=param.sched_priority)
      t->callback(PRIORITY_ANOMALY, id);
    
  
  
  return 0;
}


/* Called by the monitored application to verify if execution time of a thread have been  reduce  */
int pthread_monano_verify_reduce_execution_time(pthread_monano_t* t, pthread_monano_id_t id){

  if (ts_compare(ts_substract(t->attr[id].end_time,t->attr[id].start_time), t->attr[id].wcet) < 0)
    t->callback(REDUCE_WCET_ANOMALY, id);   

    return 0; 
  }

  
/* Called by the monitored application to signal if the precedence constraint of thread has been modified  */
int pthread_monano_verify_precedence_constraint_change(pthread_monano_t* t, pthread_monano_id_t id){
  int i;  
  
    for(i=0; i<t->nb_precedencies; i++)
      if(t->pthread_precedencies[i].destination==id)  
	if(search_thread(list,t->pthread_precedencies[i].source)==NULL)
	  t->callback(DEPENDENCY_ANOMALY, i);       

  return 0;
}


/* Called by the monitored application to signal to MONANO that the processor speed has change  */
int pthread_monano_verify_processor_speed_increase(pthread_monano_t* t, pthread_monano_id_t id)
{
    if (ts_compare(ts_substract(t->attr[id].end_time,t->attr[id].start_time), ts_divide(t->attr[id].wcet, 2)) < 0)
      list1= add_thread(list1,id);   
    
    if (count_thread(list1)==t->nb_thread)
    t->callback(SPEED_PROCESSOR_ANOMALY, id); 
  
  
  return 0;
  
}

/* Called by the monitored application to verify if the thread had change its period  */
int pthread_monano_verify_period_change(pthread_monano_t* t, pthread_monano_attr_t attr, pthread_monano_id_t id)
{
    
    if(ts_compare(t->attr[id].period, attr.period)!=0)
      t->callback(PERIOD_ANOMALY, id);
    
  return 0;
}


/* Called by a thread to signal to MONANO that the thread has started its execution */
int pthread_monano_signal_departure_time(pthread_monano_t* t, pthread_monano_id_t id) {
  // register in t the start time of the thread
  int status;

  status=pthread_mutex_lock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_lock",status);  

  status=clock_gettime(CLOCK_REALTIME, &t->attr[id].start_time);
  if(status<0)
    returncode("clock_gettime",status);
    
  status=pthread_monano_verify_priority_change(t, id);
  if (status<0)
    returncode("pthread_monano_verify_priority_change",status);
 
  status=pthread_monano_verify_precedence_constraint_change(t, id);
  if (status<0)
    returncode("pthread_monano_verify_precedence_constraint_change",status);  

  
  status=pthread_mutex_unlock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_unlock",status);
  
  return 0;
	
}


/* Called by a thread to signal to MONANO that  the thread has completed its execution */
int pthread_monano_signal_end_time(pthread_monano_t* t, pthread_monano_id_t id) 
{
  int status;
  
  status=pthread_mutex_lock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_lock",status);
  
  status=clock_gettime(CLOCK_REALTIME, &t->attr[id].end_time);
  if(status<0)
    returncode("clock_gettime",status);
  
  status=pthread_monano_verify_reduce_execution_time(t, id);
  if(status<0)
    returncode("pthread_monano_verify_reduce_execution_time",status);
  
  status=pthread_monano_verify_priority_change(t, id);
  if (status<0)
    returncode("pthread_monano_verify_priority_change",status);
  
  status=pthread_monano_verify_processor_speed_increase(t, id);
  if (status<0)
    returncode("pthread_monano_verify_processor_speed_increase",status);       

  if(t->nb_precedencies !=0)
    list= add_thread(list, id);   

  
  
  status=pthread_mutex_unlock(&t->sc);
  if(status<0)
    returncode("pthread_mutex_unlock",status);
  return 0;
}



int pthread_monano_stop (pthread_monano_t* t ) {
	
  t->stop=0;
  
  return 0;
	
}



int pthread_monano_signal_unblock_time(pthread_monano_t* t, pthread_monano_id_t id) 
{
  return 0;
}


int pthread_monano_signal_block_time(pthread_monano_t* t, pthread_monano_id_t id) 
{
  return 0;
}


