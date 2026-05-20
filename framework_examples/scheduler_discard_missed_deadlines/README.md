#Summary
- Test the missed deadline discard option in a scheduler (feature orginally requested by Janette Cardoso)

#Note
- Parameters are hard-coded in the adb file

#Implementation Detail
- When a task misses its deadline, its remaining capacity is set to 0
- in scheduler.adb:
        if (options.discard_missed_deadline_tasks) then
            declare
                abs_deadline : integer := 0;
            begin
                for i in 0 .. si.number_of_tasks - 1 loop
                    abs_deadline := si.tcbs (i).wake_up_time + si.tcbs (i).tsk.deadline;
                    if (current_time > abs_deadline) then 
                        si.tcbs (i).rest_of_capacity := 0;
                    end if;
                end loop; 
            end;
        end if;
- A missed deadline event is generated.
- The event table analysis is not working with this feature.

#Test (Janette's email)
1. Model prodcons: prod_cons_critical_section_miss
Consider RM: critical section: prod [1,1] and cons [2, 20]

Task 	Period 	WCET 	Prio
prod 	10ms 	1ms 	7
cons 	200ms 	50ms 	5

Task 'prod' will be blocked by 1 whole period.
When the mutex is released by 'cons',  the VM Xenomai 2.4.3 (quite old...) and Cheddar have different behavior: 

- When using the VM Xenomai, 'prod' executes *only* once. So, it do only one "count=count +1".

- When using Cheddar, 'prod' executes *twice* (we can see in simulation): the one activated at t=21, and the missed one in the interval [10,20[.


