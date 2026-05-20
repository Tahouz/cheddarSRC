


#include  <stdio.h>			
#include  <stdlib.h>			
#include  <string.h>			
#include  "ts.h"
			



struct timespec ts_add (struct timespec time1, struct timespec time2)
{    
    struct  timespec  result ;

    result.tv_sec = time1.tv_sec + time2.tv_sec ;
    result.tv_nsec = time1.tv_nsec + time2.tv_nsec ;
    if (result.tv_nsec >= 1000000000L) {		/* Carry? */
        result.tv_sec++ ;  result.tv_nsec = result.tv_nsec - 1000000000L ;
    }

    return (result) ;

}


int ts_compare (struct timespec time1, struct timespec time2)
{
    if (time1.tv_sec < time2.tv_sec)
        return (-1) ;				/* Less than. */
    else if (time1.tv_sec > time2.tv_sec)
        return (1) ;				/* Greater than. */
    else if (time1.tv_nsec < time2.tv_nsec)
        return (-1) ;				/* Less than. */
    else if (time1.tv_nsec > time2.tv_nsec)
        return (1) ;				/* Greater than. */
    else
        return (0) ;				/* Equal. */

}


struct  timespec  ts_substract ( struct  timespec  time1, struct  timespec  time2)
{    
    struct  timespec  result ;
	
	
/* Subtract the second time from the first. */

    if ((time1.tv_sec < time2.tv_sec) ||
        ((time1.tv_sec == time2.tv_sec) &&
         (time1.tv_nsec <= time2.tv_nsec))) {		/* TIME1 <= TIME2? */
        result.tv_sec = result.tv_nsec = 0 ;
    } else {						/* TIME1 > TIME2 */
        result.tv_sec = time1.tv_sec - time2.tv_sec ;
        if (time1.tv_nsec < time2.tv_nsec) {
            result.tv_nsec = time1.tv_nsec + 1000000000L - time2.tv_nsec ;
            result.tv_sec-- ;				/* Borrow a second. */
        } else {
            result.tv_nsec = time1.tv_nsec - time2.tv_nsec ;
        }
    }

    return (result) ;

}

struct timespec ts_divide (struct timespec time, int n)
{    
    struct  timespec  result ;

    result.tv_sec = time.tv_sec / n ;
    result.tv_nsec = (time.tv_sec % n)+ (time.tv_nsec / n) ;

    return (result) ;

}


