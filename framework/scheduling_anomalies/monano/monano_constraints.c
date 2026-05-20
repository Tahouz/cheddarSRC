#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> 
#include <pthread.h>
#include <string.h>
#include <sched.h>
#include <time.h>
#include <semaphore.h>
#include <stdbool.h>
#include "returncode.h"
#include "ts.h"

#include "monano.h"
#include "monano_data.h"
#include "configure.h"
#include "monano_constraints.h"


bool pthread_static_constraints_architecture1(pthread_monano_t* t)
{
  return (t->static_constraints[MONANO_STATIC_CONSTRAINTS_MONOCORE]&& 
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PARTITIONED]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_FIXED_PRIORITY]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PREEMPTIVE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PRECEDENCE_CONSTRAINTS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_EQUAL_PERIOD]);


}

bool pthread_static_constraints_architecture2(pthread_monano_t* t)
{
  return (t->static_constraints[MONANO_STATIC_CONSTRAINTS_MONOCORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PARTITIONED]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_FIXED_PRIORITY]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NON_PREEMPTIVE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_INDEPENDENT_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_EQUAL_PERIOD]);
}

bool pthread_static_constraints_architecture3(pthread_monano_t* t)
{
  return (t->static_constraints[MONANO_STATIC_CONSTRAINTS_MONOCORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PARTITIONED]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_MONOTONIC]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NON_PREEMPTIVE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SHARED_RESOURCES]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_SMALLER_PERIOD]);
}

bool pthread_static_constraints_architecture4(pthread_monano_t* t)
{
  return (t->static_constraints[MONANO_STATIC_CONSTRAINTS_MONOCORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PARTITIONED]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_EDF_SCHEDULING]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NON_PREEMPTIVE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_ASYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_INDEPENDENT_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_SMALLER_PERIOD]);
}

bool pthread_static_constraints_architecture5(pthread_monano_t* t)
{
  return (t->static_constraints[MONANO_STATIC_CONSTRAINTS_MONOCORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PARTITIONED]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_EDF_SCHEDULING]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PREEMPTIVE_DELAY]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_INDEPENDENT_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_EQUAL_PERIOD]);
}


bool pthread_static_constraints_architecture6(pthread_monano_t* t)
{
  return (t->static_constraints[MONANO_STATIC_CONSTRAINTS_MONOCORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PARTITIONED]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_MONOTONIC]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PREEMPTIVE_DELAY]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_INDEPENDENT_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_EQUAL_PERIOD]);
}

bool pthread_static_constraints_architecture7(pthread_monano_t* t)
{
  return (t->static_constraints[MONANO_STATIC_CONSTRAINTS_MONOCORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PARTITIONED]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_RATE_MONOTONIC]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PREEMPTIVE_DELAY]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_INDEPENDENT_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_EQUAL_PERIOD]);
}
bool pthread_static_constraints_architecture8(pthread_monano_t* t)
{
  return (t->static_constraints[MONANO_STATIC_CONSTRAINTS_MULTICORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_GLOBAL]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_FIXED_PRIORITY]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PREEMPTIVE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_INDEPENDENT_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_SMALLER_PERIOD]);
}

bool pthread_static_constraints_architecture9(pthread_monano_t* t)
{
  return ( t->static_constraints[MONANO_STATIC_CONSTRAINTS_MULTICORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_GLOBAL]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_FIXED_PRIORITY]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NON_PREEMPTIVE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PRECEDENCE_CONSTRAINTS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_SMALLER_PERIOD]);
}

bool pthread_static_constraints_architecture10(pthread_monano_t* t)
{
  return ( t->static_constraints[MONANO_STATIC_CONSTRAINTS_MULTICORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PARTITIONED]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_FIXED_PRIORITY]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NON_PREEMPTIVE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SHARED_RESOURCES]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_SMALLER_PERIOD]);
}

bool pthread_static_constraints_architecture11(pthread_monano_t* t)
{
  return ( t->static_constraints[MONANO_STATIC_CONSTRAINTS_MONOCORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PARTITIONED]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_FIXED_PRIORITY]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PREEMPTIVE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SHARED_RESOURCES]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_SMALLER_PERIOD]);
}

bool pthread_static_constraints_architecture12(pthread_monano_t* t)
{
  return ( t->static_constraints[MONANO_STATIC_CONSTRAINTS_MONOCORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PARTITIONED]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_FIXED_PRIORITY]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NON_PREEMPTIVE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PRECEDENCE_CONSTRAINTS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_SMALLER_PERIOD]);
}

bool pthread_static_constraints_architecture13(pthread_monano_t* t)
{
  return ( t->static_constraints[MONANO_STATIC_CONSTRAINTS_MONOCORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PARTITIONED]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_FIXED_PRIORITY]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PREEMPTIVE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_INDEPENDENT_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_EQUAL_PERIOD]);
}

bool pthread_static_constraints_architecture14(pthread_monano_t* t)
{
  return ( t->static_constraints[MONANO_STATIC_CONSTRAINTS_MULTICORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_GLOBAL]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_MONOTONIC]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PREEMPTIVE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_INDEPENDENT_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_SMALLER_PERIOD]);
}
bool pthread_static_constraints_architecture15(pthread_monano_t* t)
{
  return ( t->static_constraints[MONANO_STATIC_CONSTRAINTS_MULTICORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PARTITIONED]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_FIXED_PRIORITY]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PREEMPTIVE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_INDEPENDENT_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_EQUAL_PERIOD]);
}

bool pthread_static_constraints_architecture16(pthread_monano_t* t)
{
  return ( t->static_constraints[MONANO_STATIC_CONSTRAINTS_MULTICORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_GLOBAL]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_EDF_SCHEDULING]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PREEMPTIVE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_ASYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_INDEPENDENT_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_EQUAL_PERIOD]);
}

bool pthread_static_constraints_architecture17(pthread_monano_t* t)
{
  return ( t->static_constraints[MONANO_STATIC_CONSTRAINTS_MONOCORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PARTITIONED]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_FIXED_PRIORITY]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NON_PREEMPTIVE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_ASYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_INDEPENDENT_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_SMALLER_PERIOD]);
}

bool pthread_static_constraints_architecture18(pthread_monano_t* t)
{
  return ( t->static_constraints[MONANO_STATIC_CONSTRAINTS_MONOCORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PARTITIONED]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_EDF_SCHEDULING]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PREEMPTIVE_DELAY]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_INDEPENDENT_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_SMALLER_PERIOD]);
}
bool pthread_static_constraints_architecture19(pthread_monano_t* t)
{
  return (t->static_constraints[MONANO_STATIC_CONSTRAINTS_MULTICORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_GLOBAL]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_FIXED_PRIORITY]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PREEMPTIVE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_SYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_INDEPENDENT_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_EQUAL_PERIOD]);
}

bool pthread_static_constraints_architecture20(pthread_monano_t* t)
{
  return (t->static_constraints[MONANO_STATIC_CONSTRAINTS_MULTICORE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_GLOBAL]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_RATE_MONOTONIC]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PREEMPTIVE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_ASYNCHRONOUS_RELEASE]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_PERIODIC_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_INDEPENDENT_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_NO_SELF_SUSPENSION_TASKS]&&
	t->static_constraints[MONANO_STATIC_CONSTRAINTS_DEADLINE_EQUAL_PERIOD]);
}


int pthread_monano_verify_static_constraints_reduce_execution_time(pthread_monano_t* t)
{ 
   return ( pthread_static_constraints_architecture1(t)|| pthread_static_constraints_architecture2(t)||
       pthread_static_constraints_architecture3(t)|| pthread_static_constraints_architecture4(t)||
       pthread_static_constraints_architecture5(t)|| pthread_static_constraints_architecture6(t)|| 
       pthread_static_constraints_architecture7(t)|| pthread_static_constraints_architecture8(t) || 
       pthread_static_constraints_architecture9(t)|| pthread_static_constraints_architecture10(t));
            
}

int pthread_monano_verify_static_constraints_precedence_constraint_change(pthread_monano_t* t)
{ 
   return ( pthread_static_constraints_architecture9(t) || pthread_static_constraints_architecture12(t) );
         
}

int pthread_monano_verify_static_constraints_processor_speed_increase(pthread_monano_t* t)
{ 
    return ( pthread_static_constraints_architecture11(t) || pthread_static_constraints_architecture17(t) );
         
}

int pthread_monano_verify_static_constraints_period_change(pthread_monano_t* t)
{ 
    return ( pthread_static_constraints_architecture8(t)|| pthread_static_constraints_architecture14(t)||
       pthread_static_constraints_architecture15(t)|| pthread_static_constraints_architecture16(t) || 
	   pthread_static_constraints_architecture19(t) || pthread_static_constraints_architecture20(t));
         
}

int pthread_monano_verify_static_constraints_priority_change(pthread_monano_t* t)
{ 
    return ( pthread_static_constraints_architecture9(t));
         
}

int pthread_monano_verify_static_constraints_processor_number_increase(pthread_monano_t* t)
{ 
    return ( pthread_static_constraints_architecture9(t) );
         
}

int pthread_monano_verify_static_constraints_delay_thread_execution(pthread_monano_t* t)
{ 
   return ( pthread_static_constraints_architecture11(t)|| pthread_static_constraints_architecture13(t));
         
}

int pthread_monano_verify_static_constraints_reduce_preemption_delay(pthread_monano_t* t)
{ 
   return ( pthread_static_constraints_architecture5(t)|| pthread_static_constraints_architecture6(t)
        || pthread_static_constraints_architecture7(t));
         
}

int pthread_monano_verify_static_constraints_deadline_increase(pthread_monano_t* t)
{ 
   return ( pthread_static_constraints_architecture18(t));
         
}

int pthread_monano_verify_static_constraints_reduce_self_suspension(pthread_monano_t* t)
{ 
 return ( pthread_static_constraints_architecture4(t));
         
}

int pthread_monano_callback_event_anomaly(pthread_monano_t* t, int event_anomaly){
     
     if (event_anomaly==MONANO_CALLBACK_EVENT_MISSED_DEADLINE) return 1;
     else {
        if (event_anomaly==MONANO_CALLBACK_EVENT_STATIC_CONSTRAINTS_VALIDATED) 
            printf("Static constraints of the system is validated \n");
            else if (event_anomaly==MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY) 
                printf("Alert, the system can lead to potential anomaly \n");
                else if (event_anomaly==MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY) 
                    printf("The system have exit from the potential anomaly \n");
        return 0;
        }
}

/* Called by the monitored application to verify if the thread have miss its deadline */
int pthread_monano_verify_missed_deadline(pthread_monano_t* t, pthread_monano_id_t id){

  if (ts_compare(ts_substract(t->attr[id].end_time, t->attr[id].last_release_time),t->attr[id].deadline)==1){
    printf("missed deadline of thread number %d \n", id);
    return 1;
  } else 
    return 0;
}

/* Called by the monitored application to verify if execution time of a thread have been  reduce  */
int pthread_monano_verify_reduce_execution_time(pthread_monano_t* t, pthread_monano_id_t id){
  int status;
  //verify static constraints for reduce execution time anomaly
  if (ts_compare(t->attr[id].current_execution_time, t->attr[id].wcet) <0){
            pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
            status=pthread_monano_verify_missed_deadline(t,id);
            if (status<0) returncode("pthread_monano_verify_missed_deadline",status);
                else if (status==pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_MISSED_DEADLINE)){
                        t->dynamic_constraints[MONANO_DYNAMIC_CONSTRAINTS_REDUCE_EXECUTION_TIME]=true;
                        t->callback(REDUCE_WCET_ANOMALY,id); 
                        }
                    else if(status==0) pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
        } else {
            pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
            }
      
  return 0; 
  }

/* Called by a thread to verify if the thread had change its priority level  */
  int pthread_monano_verify_priority_change(pthread_monano_t* t, pthread_monano_id_t id) {
  int policy, status;
  struct sched_param param;
  
  status=pthread_getschedparam(pthread_self(), &policy, &param);
  if (status<0)
    returncode("pthread_getschedparam",status);
  
  if (t->attr[id].priority!=param.sched_priority){
            pthread_monano_callback_event_anomaly(t, MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
            status=pthread_monano_verify_missed_deadline(t,id);
            if (status<0) returncode("pthread_monano_verify_missed_deadline",status);
                else if (status==pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_MISSED_DEADLINE)){
                        t->dynamic_constraints[MONANO_DYNAMIC_CONSTRAINTS_PRIORITY_CHANGE]=true;
                        t->callback(PRIORITY_ANOMALY,id); 
                        }
                    else if(status==0) pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
        } else {
            pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
            }

 
  return 0;
}

  
/* Called by the monitored application to signal if the precedence constraint of thread has been modified  */
int pthread_monano_verify_precedence_constraint_change(pthread_monano_t* t, pthread_monano_id_t id){
  int i, status, dependency_anomaly=-1;  
  
  for(i=0; i<t->nb_precedencies; i++){
    if(t->pthread_precedencies[i].destination==id){ 
        if(pthread_monano_search_thread(dependencies_list,t->pthread_precedencies[i].source)== 0){ 
            dependency_anomaly=i;  
            }
     }
   }
     if (dependency_anomaly!=-1){
         pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
         status=pthread_monano_verify_missed_deadline(t,id);
         if (status<0) returncode("pthread_monano_verify_missed_deadline",status);
          else if (status==pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_MISSED_DEADLINE)){
                t->dynamic_constraints[MONANO_DYNAMIC_CONSTRAINTS_PRECEDENCY_DEPENDENCY_WEAKNESS]=true;
                t->callback(DEPENDENCY_ANOMALY,dependency_anomaly); 
                }
                    else if(status==0) pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
        } else {
            pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
            }  
      
  return 0;
}


/* Called by the monitored application to signal to MONANO that the processor speed has change  */
int pthread_monano_verify_processor_speed_increase(pthread_monano_t* t, pthread_monano_id_t id)
{
    int status;

  /*verified if the ratio of real execution time to WCET is more than 2 for all threads in the system */
  if (pthread_monano_count_thread(thread_execution_list_processor_speed)==t->nb_thread ){
         pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
         status=pthread_monano_verify_missed_deadline(t,id);
         if (status<0) returncode("pthread_monano_verify_missed_deadline",status);
          else if (status==pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_MISSED_DEADLINE)){
                t->dynamic_constraints[MONANO_DYNAMIC_CONSTRAINTS_SPEED_PROCESSOR_INCREASE]=true;
                t->callback(SPEED_PROCESSOR_ANOMALY, id); 
                }
                    else if(status==0) pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
        } else {
            pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
            }  
 return 0;
  
}

/* Called by the monitored application to verify if the thread had change its period  */
int pthread_monano_verify_period_change(pthread_monano_t* t, pthread_monano_id_t id)
{   int status;
  if((t->attr[id].change_period ==1)){
    pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
    status=pthread_monano_verify_missed_deadline(t,id);
    if (status<0) 
        returncode("pthread_monano_verify_missed_deadline",status);
     else if (status==pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_MISSED_DEADLINE)){
                t->dynamic_constraints[MONANO_DYNAMIC_CONSTRAINTS_PERIOD_CHANGE]=true;
                t->callback(PERIOD_ANOMALY,id); 
                }
        else if(status==0) 
            pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
        }
   else {
        pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
        }      
  return 0;
}


/* Called by the monitored application to verify if the thread had change its deadline  */
int pthread_monano_verify_deadline_increase(pthread_monano_t* t, pthread_monano_id_t id)
{   int status;
  if((t->attr[id].change_deadline ==1)){
    pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
    status=pthread_monano_verify_missed_deadline(t,id);
    if (status<0) 
        returncode("pthread_monano_verify_missed_deadline",status);
     else if (status==pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_MISSED_DEADLINE)){
                t->dynamic_constraints[MONANO_DYNAMIC_CONSTRAINTS_DEADLINE_INCREASE]=true;
                t->callback(DEADLINE_ANOMALY,id); 
                }
        else if(status==0) 
            pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
        }
   else {
        pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
        }      
  return 0;
}



/* Called by the monitored application to determine if the thread can self-suspend 
   by checking if the suspension duration  is within the task's time constraints */
int pthread_monano_verify_delay_thread_execution(pthread_monano_t* t, pthread_monano_id_t id)
{   int status;
  if(ts_compare(ts_substract(t->attr[id].end_time, t->attr[id].start_time),(ts_add(t->attr[id].wcet,t->attr[id].preemption_time)))==1){
    pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
    status=pthread_monano_verify_missed_deadline(t,id);
    if (status<0) 
        returncode("pthread_monano_verify_missed_deadline",status);
     else if (status==pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_MISSED_DEADLINE)){
                t->dynamic_constraints[MONANO_DYNAMIC_CONSTRAINTS_THREAD_DELAY]=true;
                t->callback(DELAY_WCET_ANOMALY,id); 
                }
        else if(status==0) 
            pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
        }
   else {
        pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
        }      
  return 0;
}

/* Called by the monitored application to determine if the thread has established a time limit for latency
   after preemption and if that latency has been reduced */
int pthread_monano_verify_reduce_preemption_delay(pthread_monano_t* t, pthread_monano_id_t id)
{   int status;
  if(ts_compare(ts_substract(t->attr[id].end_time, t->attr[id].start_time),ts_add(ts_add(t->attr[id].wcet,t->attr[id].preemption_time),t->attr[id].preemption_delay))==-1){
    pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
    status=pthread_monano_verify_missed_deadline(t,id);
    if (status<0) 
        returncode("pthread_monano_verify_missed_deadline",status);
     else if (status==pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_MISSED_DEADLINE)){
                t->dynamic_constraints[MONANO_DYNAMIC_CONSTRAINTS_REDUCE_PREEMPTION_DELAY]=true;
                t->callback(THREAD_PREEMPTION_DELAY,id); 
                }
        else if(status==0) 
            pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
        }
   else {
        pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
        }      
  return 0;
}

/* Called by the monitored application to verify if its of number of processor  has been increase */
int pthread_monano_verify_processor_number_increase(pthread_monano_t* t, pthread_monano_id_t id)
{
	int status;
  if(t->attr[id].change_nb_processors ==1)
    t->callback(NUMBER_PROCESSOR_ANOMALY, t->attr[id].change_nb_processors);
    
  return 0;
  
}



/* Called by the monitored application to determine if the thread can self-suspend 
   by checking if this suspension duration  have been reduced */
int pthread_monano_verify_reduce_self_suspension(pthread_monano_t* t, pthread_monano_id_t id)
{   int status;
  if (ts_compare(ts_substract(t->attr[id].end_time, t->attr[id].start_time),ts_add(ts_add(t->attr[id].wcet,t->attr[id].preemption_time),t->attr[id].selfsuspension))==-1){
    pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_ENTER_POTENTIAL_ANOMALY);
    status=pthread_monano_verify_missed_deadline(t,id);
    if (status<0) 
        returncode("pthread_monano_verify_missed_deadline",status);
     else if (status==pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_MISSED_DEADLINE)){
                t->dynamic_constraints[MONANO_DYNAMIC_CONSTRAINTS_REDUCE_SELF_SUSPENSION_TIME]=true;
                t->callback(THREAD_SELF_SUSPENSION_TIME,id); 
                }
        else if(status==0) 
            pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
        }
   else {
        pthread_monano_callback_event_anomaly(t,MONANO_CALLBACK_EVENT_EXIT_POTENTIAL_ANOMALY);
        }      
  return 0;
}





