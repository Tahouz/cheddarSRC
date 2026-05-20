#include <stdio.h> 
#include <unistd.h> 
#include <pthread.h>
#include <string.h>
#include <semaphore.h>
#include "types.h"
#include "ts.h"
#include "assemblage_includes.h"
#include "assemblage.h"
#include "threads.h"
#include "returncode.h"
#include "time_conversion.h"
// SR for monitoring
#include "sched_mon.h"
#include "monano.h"

#define NTHREAD 2

/*  Critical instant : start time 
    of the application  */
struct timespec critical_instant, finaltime;




// Task set
struct nonencoded_task_params* tasks;

// I/O
output_t outs;

/*semaphore for manage shared resources  
    between engine and elevator */
pthread_mutex_t  shared_resources_engine_elevator;


// simulation length
//long max_step_simu;
struct pthread_monano_t my_monano;
struct pthread_monano_attr_t my_monano_attr;
pthread_monano_id_t my_monano_id [NTHREAD];



// Output variables
extern double aircraft_dynamics495_Va_Va_filter_100449_Va[2];
extern double aircraft_dynamics495_az_az_filter_100458_az[2];
extern double aircraft_dynamics495_Vz_Vz_filter_100452_Vz[2];
extern double aircraft_dynamics495_q_q_filter_100455_q[2];
extern double aircraft_dynamics495_h_h_filter_100446_h[2];
extern double Va_control_50474_delta_th_c_delta_th_c;
extern double Vz_control_50483_delta_e_c_delta_e_c;

void copy_output_vars(output_t* v, uint64_t step)
{
  v->sig_outputs.Va 	= aircraft_dynamics495_Va_Va_filter_100449_Va[step%2];
  v->sig_outputs.Vz 	= aircraft_dynamics495_Vz_Vz_filter_100452_Vz[step%2];
  v->sig_outputs.q  	= aircraft_dynamics495_q_q_filter_100455_q[step%2];
  v->sig_outputs.az 	= aircraft_dynamics495_az_az_filter_100458_az[step%2];
  v->sig_outputs.h  	= aircraft_dynamics495_h_h_filter_100446_h[step%2];
  v->sig_delta_th_c	= Va_control_50474_delta_th_c_delta_th_c;
  v->sig_delta_e_c	= Vz_control_50483_delta_e_c_delta_e_c;
}

int val (int id)
{
  int v;
  switch (id)
  {
    case 0: v=3; break; 
    case 1: v=13; break;     
    default: v=-1;
  }
  return v;
}

void* my_callback(int anomaly_number, pthread_monano_id_t id)
{
  switch (anomaly_number){
    case 0: printf("Type Anomaly : REDUCE_WCET_ANOMALIE on thread number %d \n", id); break;
    case 1: printf("Type Anomaly : PRIORITY_ANOMALIE on thread number %d \n", id); break;
    case 2: printf("Type Anomaly : DEPENDENCY_ANOMALIE on thread number %d \n", id); break;
    case 3: printf("Type Anomaly : SPEED_PROCESSOR_ANOMALIE on all thread \n"); break;
    case 4: printf("Type Anomaly : DELAY_WCET_ANOMALIE on thread number %d \n", id); break;
    default : printf("Not a type Anomaly \n");
  }
  
  return 0;
}



void rosace_init() 
{
  // Initial values
  outs.sig_outputs.Va = 0;
  outs.sig_outputs.Vz = 0;
  outs.sig_outputs.q  = 0;
  outs.sig_outputs.az = 0;
  outs.sig_outputs.h  = 0;
  outs.t_simu         = 0;
  
  // Get the task set (required for CALL() macro)
  int tmp;
  get_task_set(&tmp, &tasks);
  
  #if SCHEDMON>0L
  {
    int read_back;
    SCHEDMON_mWriteReg(0x50000000, SCHEDMON_S00_AXI_SLV_REG0_OFFSET, 0x01000000);
    SCHEDMON_mWriteReg(0x50000000, SCHEDMON_S00_AXI_SLV_REG0_OFFSET, 0x03000000+100000);
    SCHEDMON_mReadReg(0x50000000, SCHEDMON_S00_AXI_SLV_REG0_OFFSET, read_back);
    printf("%x --\r\n", read_back);
    SCHEDMON_mWriteReg(0x50000000, SCHEDMON_S00_AXI_SLV_REG0_OFFSET, 0x02000000);
    
    //SCHEDMON_mReadReg(0x50000000, SCHEDMON_S00_AXI_SLV_REG0_OFFSET, read_back);
    //printf("%x --\r\n", read_back);
    
  }
  #endif
  #if SCHEDMON>1L
  SCHEDMON_mWriteReg(0x50000000, SCHEDMON_S00_AXI_SLV_REG1_OFFSET, 0x00000101);
  #endif

}

void*  periodic_activation(void* arg)
{
  int ego = *(int*)arg;
  
#ifdef CONFIGURE_MONANO_RTEMS48
 #ifdef CONFIGURE_MONANO_ASYNCHRONOUS_THREADS 
  //wait for his departure time
  if (my_monano.attr[my_monano_id[ego]].departure.tv_sec != 0)
  { 
    /* wait for his departure time */ 
    nanosleep(&my_monano.attr[my_monano_id[ego]].departure, NULL);
    
  }
 #endif
#endif 
  /* Called by a thread to signal to MONANO that the thread has started its execution */	
  pthread_monano_signal_departure_time(&my_monano, my_monano_id[ego]);
  
  CALL(val(my_monano_id[ego]));
  
  /* Called by a thread to signal to MONANO that  the thread has completed its execution */
  pthread_monano_signal_end_time(&my_monano, my_monano_id[ego]);


  return 0;
}


void run_rosace(void)
{
  struct sched_param param;
  struct pthread_monano_attr_t tparam []={{99,{6,0},{9,0},{24,0},{2,0}},
					  {98,{16,0},{24,0},{24,0},{0,0}}}; 
  int status, i;
  int *ego;

  /* initialize benchmark */
  rosace_init();
  ROSACE_update_altitude_command(11000.0);

  // Initialize the Semaphore for shared resources betweenengine and elevator
  status=pthread_mutex_init(&shared_resources_engine_elevator,NULL);
  if(status<0)
    returncode("pthread_mutex_init ",status);
  
  /* Monano init and register */
  pthread_monano_init(&my_monano);
  pthread_monano_attr_init(&my_monano_attr);
  
  pthread_monano_register_anomaly_callback(&my_monano, my_callback);
  
  /* Upgrade main thread priority */
  param.sched_priority=100;
  status=pthread_setschedparam(pthread_self(), SCHED_FIFO, &param);
  if(status<0)
    returncode("pthread_attr_setschedparam",status);

  for(i=0; i<NTHREAD;i++)
  {
    pthread_monano_attr_setperiod(&my_monano_attr, tparam[i].period);
    pthread_monano_attr_setwcet(&my_monano_attr, tparam[i].wcet);
    pthread_monano_attr_setdeadline(&my_monano_attr, tparam[i].deadline);
    pthread_monano_attr_setpriority(&my_monano_attr, tparam[i].priority);
    pthread_monano_attr_setdeparture(&my_monano_attr, tparam[i].departure);
    
    pthread_monano_register_anomaly_callback(&my_monano, my_callback); 

    /* create a monano periodic thread */
    ego=(int*)malloc(sizeof(int));
    *ego=i;

    status=pthread_monano_periodic_thread_create (&my_monano, my_monano_attr, periodic_activation, &my_monano_id[i], ego);
    if(status<0)
      returncode("pthread_monano_pthread_create",status);
	  
    
  }
  
  printf("run_rosace is completed, start running the periodic tasks\n");

}

