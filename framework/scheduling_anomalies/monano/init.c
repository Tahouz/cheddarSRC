#include "pmacros.h"
#include "system.h"

#include <stdio.h>
#include <sched.h>
#include <stdlib.h>
#include <string.h>
#include <semaphore.h>
#include <errno.h>
#include <signal.h>
#include <time.h>
#include <pthread.h>


#include "returncode.h"
#include "monano.h"

void run_monano();

void* POSIX_Init(void *argument)
{

  run_monano();
  return 0;  
  
} 
  
