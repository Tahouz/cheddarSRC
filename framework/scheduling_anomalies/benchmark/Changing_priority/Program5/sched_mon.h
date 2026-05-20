/* ---------------------------------------------------------
   communication with the hardware monitor
   ---------------------------------------------------------
   02/03/18	SR	creation
   ---------------------------------------------------------
*/
#ifndef _SCHED_MON_H
#define _SCHED_MON_H
// 0L   monitoring disabled (no trace collected)
// > 0L monitoring enabled  
#define SCHEDMON 0L

#include <unistd.h>

#if SCHEDMON>0L
void Xil_Out32(int32_t * Addr, int32_t Value);
void Xil_In32(int32_t * Addr, int32_t *Value);

#define SCHEDMON_S00_AXI_SLV_REG0_OFFSET 0
#define SCHEDMON_S00_AXI_SLV_REG1_OFFSET 4
#define SCHEDMON_S00_AXI_SLV_REG2_OFFSET 8
#define SCHEDMON_S00_AXI_SLV_REG3_OFFSET 12

#define SCHEDMON_mWriteReg(BaseAddress, RegOffset, Data) \
        Xil_Out32((int32_t*)((BaseAddress) + (RegOffset)), (int32_t)(Data))
#define SCHEDMON_mReadReg(BaseAddress, RegOffset, Data) \
        Xil_In32((int32_t*)((BaseAddress) + (RegOffset)), (int32_t *)(&Data))

#endif

#endif

