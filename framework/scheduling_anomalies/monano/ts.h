

#ifndef  TS_H		
#define  TS_H  yes

/* Add two timespec */
extern  struct  timespec ts_add (struct timespec time1, struct timespec time2);

/* substract two timespec */
extern  struct  timespec  ts_substract (struct timespec time1, struct timespec time2);

/* Compare two timespec */
extern  int  ts_compare (struct timespec time1, struct timespec time2);

/* divide a timespec with an integer */
extern  struct  timespec ts_divide (struct timespec time, int n);



#endif				


