
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h> 
#include <pthread.h>
#include <string.h>
#include <sched.h>
#include <time.h>
#include <semaphore.h>

#include "returncode.h"
#include "ts.h"

#include "monano.h"
#include "monano_data.h"



struct pthread_monano_list *dependencies_list=NULL;
//struct pthread_monano_list *processor_speed_list=NULL;
struct pthread_monano_list *thread_preemption_list=NULL;
struct pthread_monano_list *thread_execution_list_processor_speed=NULL;


//add a thread in a list at the begin
pthread_monano_list* pthread_monano_add_thread(pthread_monano_list* l, pthread_monano_id_t val)
{
  pthread_monano_list* n=malloc(sizeof(pthread_monano_list));
  
 printf("sizeof pthread_monano_list,%d\n", sizeof(pthread_monano_list));
  
  n->id=val;
  n->suivant=l;
  
  return n;
  
}

// to find if a thread is in a list
int pthread_monano_search_thread(pthread_monano_list* l, pthread_monano_id_t val)
{
  pthread_monano_list* n=l;
  while(n != NULL)
  {
    if (n->id==val)
      return  1;
    
    n=n->suivant;   
     
  }
  
  return 0; 
  
}
//remove  a thread in a list 
pthread_monano_list* pthread_monano_remove_thread(pthread_monano_list* l)
{
  if(l!=NULL){
    pthread_monano_list* n =l->suivant;
    free(l);
    return n;
  }
  else
    return NULL;
  
}

pthread_monano_id_t pthread_monano_head_thread(pthread_monano_list* l)
{
  return l->id;
}

/*to have the number of thread in the list */
int pthread_monano_count_thread(pthread_monano_list* l){
 pthread_monano_list* n=l;
 int nb=0;
  while(n != NULL)
  {
    nb++;    
    n=n->suivant;   
     
  }  
 return nb;
}


