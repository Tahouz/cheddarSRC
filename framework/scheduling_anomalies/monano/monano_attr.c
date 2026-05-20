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

 /* pthread_monano_attr */
/* pthread_monano_attr attribute accessor functions  */
int pthread_monano_attr_setpriority(pthread_monano_attr_t* attr,int prio)
{
  attr->priority=prio;
  return 0;
}

int pthread_monano_attr_setwcet(pthread_monano_attr_t* attr, struct timespec w)
{
  attr->wcet=w;
  return 0;
}

int pthread_monano_attr_setdeadline(pthread_monano_attr_t* attr, struct timespec d)
{
  if (ts_compare(attr->deadline,d)==-1)
	attr->change_deadline=1;

  attr->deadline=d;
  return 0;
}

int pthread_monano_attr_setperiod(pthread_monano_attr_t* attr, struct timespec p)
{
	if (ts_compare(attr->period, p)==-1)
	  attr->change_period=1;
	  
  attr->period=p;
  return 0;
}

int pthread_monano_attr_setdeparture(pthread_monano_attr_t* attr, struct timespec dep)
{
  attr->departure=dep;
  return 0;
}

int pthread_monano_attr_setselfsuspension(pthread_monano_attr_t* attr, struct timespec susp)
{
  attr->selfsuspension=susp;
  return 0;
}

int pthread_monano_attr_setstart_time(pthread_monano_attr_t* attr, struct timespec stime)
{
  attr->start_time = stime;
  return 0;
}

int pthread_monano_attr_setend_time(pthread_monano_attr_t* attr, struct timespec etime)
{
  attr->end_time = etime;
  return 0;
}

int pthread_monano_attr_setpreemption_time(pthread_monano_attr_t* attr, struct timespec ptime)
{
  attr->preemption_time=ptime;
  return 0;
}
int pthread_monano_attr_setpreemption_delay(pthread_monano_attr_t* attr, struct timespec pdtime)
{
  attr->preemption_time=pdtime;
  return 0;
}
int pthread_monano_attr_setnb_processors(pthread_monano_attr_t* attr, int processornumber)
{
	if (attr->nb_processors < processornumber)
		  attr->change_nb_processors = 1;
	  
  attr->nb_processors = processornumber;

  return 0;
}


/* pthread_monano_attr attribute modifier functions */
int pthread_monano_attr_getpriority(pthread_monano_attr_t attr)
{
  return attr.priority;
}

struct timespec pthread_monano_attr_getwcet(pthread_monano_attr_t attr)
{
  return attr.wcet;
}

struct timespec pthread_monano_attr_getdeadline(pthread_monano_attr_t attr)
{
  return attr.deadline;
}

struct timespec pthread_monano_attr_getperiod(pthread_monano_attr_t attr)
{
  return attr.period;
}

struct timespec pthread_monano_attr_getdeparture(pthread_monano_attr_t attr)
{
  return attr.departure;
}

struct timespec pthread_monano_attr_getselfsuspension(pthread_monano_attr_t attr)
{
  return attr.selfsuspension;
}
struct timespec pthread_monano_attr_getstart_time(pthread_monano_attr_t attr)
{
  return attr.start_time;
}

struct timespec pthread_monano_attr_getend_time(pthread_monano_attr_t attr)
{
  return attr.end_time;
}

struct timespec pthread_monano_attr_getpreemption_time(pthread_monano_attr_t attr)
{
  return attr.preemption_time;
}
struct timespec pthread_monano_attr_getpreemption_delay(pthread_monano_attr_t attr)
{
  return attr.preemption_delay;
}

/* pthread_monano_processor_number attribute accessors and modifiers functions */
int pthread_monano_attr_getnb_processors(pthread_monano_attr_t attr)
{
  return attr.nb_processors;
}




/* pthread_monano_precedency attribute Accessors functions*/
int pthread_monano_precedency_attr_setsource(pthread_monano_precedency_t* pred, pthread_monano_id_t s)
{
  pred->source = s;
  return 0;
}

int pthread_monano_precedency_attr_setdestination(pthread_monano_precedency_t* pred, pthread_monano_id_t d)
{
  pred->destination =d;
  return 0;
}

/* pthread_monano_precedency attribute modifiers functions*/
pthread_monano_id_t pthread_monano_precedency_attr_getsource(pthread_monano_precedency_t pred)
{
  return pred.source;
}
pthread_monano_id_t pthread_monano_precedency_attr_getdestination(pthread_monano_precedency_t pred)
{
  return pred.destination;
}


/* pthread_monano_static constraints attribute accessors and modifiers functions */
bool pthread_monano_attr_getstatic_constraints(pthread_monano_t* t, int staticconstraint)
{
  return t->static_constraints[staticconstraint];
}

int pthread_monano_attr_setstatic_constraints(pthread_monano_t* t, int staticconstraint)
{
  t->static_constraints[staticconstraint]=true;
  return 0;
}


/* pthread_monano_dynamic constraints attribute accessors and modifiers functions */
bool pthread_monano_attr_getdynamic_constraints(pthread_monano_t* t, int dynamicconstraint)
{
  return t->dynamic_constraints[dynamicconstraint];
}

int pthread_monano_attr_setdynamic_constraints(pthread_monano_t* t, int dynamicconstraint)
{
  t->dynamic_constraints[dynamicconstraint]=true;
  return 0;
}




/* initialize monano thread attribute */
int pthread_monano_attr_init(pthread_monano_attr_t *attr){
  
  struct timespec init;
  init.tv_sec=0;
  init.tv_nsec=0;

  attr->priority=0;
  attr->change_period=0;
  attr->change_deadline=0;
  attr->period=init;
  attr->wcet=init;
  attr->deadline=init;
  attr->departure=init;
  attr->selfsuspension=init;
  attr->preemption_delay=init;
  attr->start_time=init;
  attr->end_time=init;
  attr->last_remaining_preempted=init;
  attr->blocking_time=init;
  attr->start_blocking_time=init;
  attr->current_execution_time=init;
  attr->preemption_time=init;
  attr->selfsuspending_time=init;
  attr->start_selfsuspending_time=init;
  attr->nb_processors=1;
  attr->change_nb_processors=0;
  return 0;
  
}











