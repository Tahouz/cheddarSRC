#include <stdlib.h>
#include "threads.h"

/* The only purpose of this file is to do 
 * some configuration if required before
 * calling the actual rosace main function
 */

int main(int argc, char* argv[]){
  long tsimu=300*200;
  if (argc>1) {
    tsimu = atoi(argv[1])*200;
  }
  // SR max_step_simu = tsimu;
  
  // SR return run_rosace();
  // run_rosace returns nothing
  run_rosace();
  return 0;
}

