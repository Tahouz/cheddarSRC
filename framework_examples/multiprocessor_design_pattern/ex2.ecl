

archi_model_spec("ETR17ex1model",L) :- 
        L = [ sw_archi(log_upg),  % ajout VAN
                                             
              tasks([t0,t1,t2,t3]),

              processing_elements([c0,c1]),

              dm_PE_allowed(t0,[c0,c1]),
              dm_PE_allowed(t1,[c0,c1]),
              dm_PE_allowed(t2,[c0,c1]),
              dm_PE_allowed(t3,[c0,c1]),
              
              dm_PE_scheduling(c0, t0, sched(pfair,preemptive,time_unit_migration)),
              dm_PE_scheduling(c0, t1, sched(pfair,preemptive,time_unit_migration)),
              dm_PE_scheduling(c0, t2, sched(pfair,preemptive,time_unit_migration)),
              dm_PE_scheduling(c0, t3, sched(pfair,preemptive,time_unit_migration)),
              dm_PE_scheduling(c1, t0, sched(pfair,preemptive,time_unit_migration)),
              dm_PE_scheduling(c1, t1, sched(pfair,preemptive,time_unit_migration)),
              dm_PE_scheduling(c1, t2, sched(pfair,preemptive,time_unit_migration)),
              dm_PE_scheduling(c1, t3, sched(pfair,preemptive,time_unit_migration)),
              
              ha_independent(c0),
              ha_independent(c1),
                
              %a_type(c0,pe).  devrait-on avoir ces 2 lignes comme sur ex2 ?
              %a_type(c1,pe).
                
              a_PE_isa(c0,powerPC),
              a_PE_isa(c1,powerPC),
              
              a_PE_speed(c0,100e6,100e6),
              a_PE_speed(c1,100e6,100e6)
            ].