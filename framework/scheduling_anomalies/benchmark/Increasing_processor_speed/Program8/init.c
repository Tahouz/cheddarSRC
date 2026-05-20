#define CONFIGURE_INIT
#include "system.h"
#include <signal.h>
#include <errno.h>
#include <stdlib.h>
#include <assert.h>
#include <stdio.h>
#include <sched.h>
#include "ts.h"
#include "returncode.h"
#include "threads.h"



void* POSIX_Init(void *argument)
{

  max_step_simu = 1;
  run_rosace();

  printf("init.c is completed, start running the periodic tasks\n");
  pthread_exit(NULL);
  return 0; 
}

