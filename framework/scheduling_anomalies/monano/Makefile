#
#  Makefile
#

CC 	  = sparc-gaisler-rtems5-gcc 
CFLAGS    = -qbsp=leon3 -O2 -g 
LD	  = $(CC)
CINCLUDE  = 
LIBS	  = 

COMPILE   = $(CC) $(CFLAGS) $(CINCLUDE) -c
.c.o:
	$(COMPILE) $<
####################################################

TARGET = returncode.c monano_data.c monano_constraints.c monano_attr.c monano_core.c init.c ts.c time_conversion.c processor_speed.c program1.c

all:	$(TARGET:.c=.o)
	$(CC) $(TARGET:.c=.o) $(CFLAGS) $(LIBS) -o monano.exe

clean:
	$(RM)  *.a *.o *.bak core *.exe
