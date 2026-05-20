#ifndef __DEF_ROSACE_IO_H
#define __DEF_ROSACE_IO_H

#include "types.h"

typedef struct {
    struct aircraft_dynamics_outs_t sig_outputs;
    uint64_t t_simu;
    REAL_TYPE sig_delta_th_c;
    REAL_TYPE sig_delta_e_c;
} output_t;

void ROSACE_write_outputs(output_t* v);
void ROSACE_update_altitude_command(REAL_TYPE h_cons);

#endif
