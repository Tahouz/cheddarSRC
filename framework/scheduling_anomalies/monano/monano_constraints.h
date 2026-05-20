

#ifndef  MONANO_CONSTRAINTS_H
#define  MONANO_CONSTRAINTS_H yes

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
#include <semaphore.h>
#include <stdbool.h>
#include "returncode.h"


bool pthread_static_constraints_architecture1(pthread_monano_t* t);
bool pthread_static_constraints_architecture2(pthread_monano_t* t);
bool pthread_static_constraints_architecture3(pthread_monano_t* t);
bool pthread_static_constraints_architecture4(pthread_monano_t* t);
bool pthread_static_constraints_architecture5(pthread_monano_t* t);
bool pthread_static_constraints_architecture6(pthread_monano_t* t);
bool pthread_static_constraints_architecture7(pthread_monano_t* t);
bool pthread_static_constraints_architecture8(pthread_monano_t* t);
bool pthread_static_constraints_architecture9(pthread_monano_t* t);
bool pthread_static_constraints_architecture10(pthread_monano_t* t);
bool pthread_static_constraints_architecture11(pthread_monano_t* t);
bool pthread_static_constraints_architecture12(pthread_monano_t* t);
bool pthread_static_constraints_architecture13(pthread_monano_t* t);
bool pthread_static_constraints_architecture14(pthread_monano_t* t);
bool pthread_static_constraints_architecture15(pthread_monano_t* t);
bool pthread_static_constraints_architecture16(pthread_monano_t* t);
bool pthread_static_constraints_architecture17(pthread_monano_t* t);
bool pthread_static_constraints_architecture18(pthread_monano_t* t);
bool pthread_static_constraints_architecture19(pthread_monano_t* t);
bool pthread_static_constraints_architecture20(pthread_monano_t* t);


int pthread_monano_verify_static_constraints_reduce_execution_time(pthread_monano_t* t);
int pthread_monano_verify_static_constraints_precedence_constraint_change(pthread_monano_t* t);
int pthread_monano_verify_static_constraints_processor_speed_increase(pthread_monano_t* t);
int pthread_monano_verify_static_constraints_period_change(pthread_monano_t* t);
int pthread_monano_verify_static_constraints_priority_change(pthread_monano_t* t);
int pthread_monano_verify_static_constraints_processor_number_increase(pthread_monano_t* t);
int pthread_monano_verify_static_constraints_delay_thread_execution(pthread_monano_t* t);
int pthread_monano_verify_static_constraints_reduce_preemption_delay(pthread_monano_t* t);
int pthread_monano_verify_static_constraints_deadline_increase(pthread_monano_t* t);
int pthread_monano_verify_static_constraints_reduce_self_suspension(pthread_monano_t* t);


int pthread_monano_verify_priority_change(pthread_monano_t* t, pthread_monano_id_t id);
int pthread_monano_verify_reduce_execution_time(pthread_monano_t* t, pthread_monano_id_t id);
int pthread_monano_verify_precedence_constraint_change(pthread_monano_t* t, pthread_monano_id_t id);
int pthread_monano_verify_processor_speed_increase(pthread_monano_t* t, pthread_monano_id_t id);
int pthread_monano_verify_period_change(pthread_monano_t* t, pthread_monano_id_t id);
int pthread_monano_verify_missed_deadline(pthread_monano_t* t, pthread_monano_id_t id);
int pthread_monano_verify_processor_number_increase(pthread_monano_t* t, pthread_monano_id_t id); 
int pthread_monano_verify_delay_thread_execution(pthread_monano_t* t, pthread_monano_id_t id);
int pthread_monano_verify_reduce_preemption_delay(pthread_monano_t* t, pthread_monano_id_t id);
int pthread_monano_verify_deadline_increase(pthread_monano_t* t, pthread_monano_id_t id);
int pthread_monano_verify_reduce_self_suspension(pthread_monano_t* t, pthread_monano_id_t id);


int pthread_monano_callback_event_anomaly(pthread_monano_t* t, int potential_anomaly);
#endif



