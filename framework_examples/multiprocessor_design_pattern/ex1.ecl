
archi_model_spec("ETR17ex2model",L) :- 
        L = [ sw_archi(log_upg),  % ajout VAN

              tasks([t0,t1,t2,t3]),

              processing_elements([c0,c1]),

              pe_use_res(c0,[ic0]),  % ajout VAN pour concept de la fig 2 p. 4
              pe_use_res(c1,[ic1]),  % ajout VAN pour concept de la fig 2 p. 4
              
              dm_PE_allowed(t0,[c0]),  % ajout VAN : a entrer par l'utilisateur ou a generer a partir de dm_PE_actual ?
              dm_PE_allowed(t1,[c0]),  % ajout VAN
              dm_PE_allowed(t2,[c1]),  % ajout VAN
              dm_PE_allowed(t3,[c1]),  % ajout VAN

              dm_PE_actual(t0,c0),
              dm_PE_actual(t1,c0), 
              dm_PE_actual(t2,c1), 
              dm_PE_actual(t3,c1), 
              
              dm_PE_scheduling(c0, t0, sched(fp,preemptive)),
              dm_PE_scheduling(c0, t1, sched(fp,preemptive)),
              dm_PE_scheduling(c1, t2, sched(fp,preemptive)),
              dm_PE_scheduling(c1, t3, sched(fp,preemptive)),
              
              ha_independent(c0),
              ha_independent(c1),
              
              am_time(c0,mb,interval(0,1000,500,1000)),    %{[0+1000.k, 500+1000.k[ tq k>= 0}
              am_time(c1,mb,interval(500,1000,1000,1000)), %{[500+1000.k, 1000.(k+1)[ tq k>= 0}
              
              a_type(c0,pe),
              a_type(c1,pe),
              a_type(ic0,memory),
              a_type(ic1,memory),
              a_type(mb,communication),
              
              a_PE_isa(c0,sparc_V8),
              a_PE_isa(c1,sparc_V8),
              
              a_PE_speed(c0,100e6,100e6),
              a_PE_speed(c1,100e6,100e6),
              
              a_mem_type(ic0,icache),
              a_mem_type(ic1,icache),
              
              a_mem_cache_associativity(ic0,1),  % ajout VAN
              a_mem_cache_associativity(ic1,1),  % ajout VAN
              
              a_mem_cache_level(ic0,1),
              a_mem_cache_level(ic1,1),
              
              a_mem_cache_size(ic0,2^10),
              a_mem_cache_size(ic1,2^10),

              a_mem_cache_line_size(ic0,16),
              a_mem_cache_line_size(ic1,16),
              
              a_mem_cache_miss_time(ic0,1000),  % 1000 = 500 + 500
              a_mem_cache_miss_time(ic1,1000),
              
              a_comm_type(mb,bus)              
            ].
