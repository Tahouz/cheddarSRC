/* ---------------------------------------------------------
   communication with the hardware monitor
   ---------------------------------------------------------
   02/03/18	SR	creation
   ---------------------------------------------------------
*/
#include "sched_mon.h"

#if SCHEDMON>0L
// SR from Xilinx project
void Xil_Out32(int32_t * Addr, int32_t Value)
{
        volatile int32_t *LocalAddr = (volatile int32_t *)Addr;
        *LocalAddr = Value;
}
void Xil_In32(int32_t * Addr, int32_t *Value)
{
        volatile int32_t *LocalAddr = (volatile int32_t *)Addr;
        *Value=*LocalAddr;
}
#endif

