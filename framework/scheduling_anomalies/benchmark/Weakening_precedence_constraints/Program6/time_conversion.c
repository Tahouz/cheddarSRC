


#include  <stdio.h>			
#include  <stdlib.h>			
#include  <string.h>			
#include  "time_conversion.h"			




long int ms_to_ns(int ms)
{
  long int result;
  
  result = ms * 1000000;
  
  return (result);
}



long int us_to_ns(int us)
{
  long int result;
  
  result = us * 1000;
  
  return (result);  
}


