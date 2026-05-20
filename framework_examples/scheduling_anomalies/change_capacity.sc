

start_section :
end section;  

priority_section :
   put(tasks.capacity(0));
   if(simulation_time<11) then
	tasks.capacity(0):=2;
	tasks.rest_of_capacity(0):=0;
   end if;
end section;  
   
   
election_section :
   return min_to_index(tasks.priority);
end section;  
   
