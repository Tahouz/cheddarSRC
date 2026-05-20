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
  attr->deadline=d;
  return 0;
}

int pthread_monano_attr_setperiod(pthread_monano_attr_t* attr, struct timespec p)
{
  attr->period=p;
  return 0;
}

int pthread_monano_attr_setdeparture(pthread_monano_attr_t* attr, struct timespec dep)
{
  attr->departure=dep;
  return 0;
}

int pthread_monano_attr_setdelay(pthread_monano_attr_t* attr, struct timespec del)
{
  attr->delay=del;
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

struct timespec pthread_monano_attr_getdelay(pthread_monano_attr_t attr)
{
  return attr.delay;
}
struct timespec pthread_monano_attr_getstart_time(pthread_monano_attr_t attr)
{
  return attr.start_time;
}

struct timespec pthread_monano_attr_getend_time(pthread_monano_attr_t attr)
{
  return attr.end_time;
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


int pthread_monano_attr_getstatic_constraints(pthread_monano_t* t, int staticconstraint)
{
  return t->static_constraints[staticconstraint];
}

int pthread_monano_attr_setstatic_constraints(pthread_monano_t* t, int staticconstraint)
{
  t->static_constraints[staticconstraint]=1;
  return 0;
}


/* initialize monano thread attribute */
int pthread_monano_attr_init(pthread_monano_attr_t *attr){
  
  struct timespec init;
  init.tv_sec=0;
  init.tv_nsec=0;

  attr->priority=0;
  attr->period=init;
  attr->wcet=init;
  attr->deadline=init;
  attr->departure=init;
  attr->delay=init;
  attr->start_time=init;
  attr->end_time=init;
  
  return 0;
  
}











