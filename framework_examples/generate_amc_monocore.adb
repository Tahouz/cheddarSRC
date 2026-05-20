with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Command_Line;      use Ada.Command_Line;
with GNAT.Os_Lib;

with Objects;                   use Objects;
with Memories;              use Memories;
use Memories.Memories_Table_Package;
with Memory_set;              use Memory_set;
with Tasks;              use Tasks;
with Task_Set;           use Task_Set;
with Systems;            use Systems;
with Processors;         use Processors;
with Processor_Set;      use Processor_Set;
with Address_Spaces;     use Address_Spaces;
with Address_Space_Set;  use Address_Space_Set;
with Core_Units;         use Core_Units;
use Core_Units.Core_Units_Table_Package;
with batteries;          use batteries;
with battery_set;        use battery_set;
with Processor_Interface;      use Processor_Interface;
with Scheduler_Interface;      use Scheduler_Interface;

with Random_Tools;             use Random_Tools;
with architecture_factory;     use architecture_factory;
with unbounded_strings;        use unbounded_strings;
with call_framework;           use call_framework;
with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;
with doubles; use doubles;
with priority_assignment.rm;
use priority_assignment.rm;
with Ada.Numerics;
with Ada.Numerics.Float_Random;

procedure Generate_amc_monocore is
   sys                  : System;
   a_core               : Core_Unit_Ptr;
   a_processor          : Generic_Processor_Ptr;

   msg                  : Unbounded_String;
   Feasibility_Interval : Double;
   validate             : Boolean;

   -- parameters arguments
   Actual_CPU_Usage      	: Float   :=0.0;
   N_Tasks               	: Integer := Natural'Value(Argument(1));
   N_Different_Periods   	: Integer :=8;
   Threshold_Quality	 	: Natural :=0;
   N_High_Tasks		: Natural := 0;
   N_Medium_Tasks	 	: Natural := 0;
   N_percentage_LO_tasks	: Natural := 0;
   nb_iteration		: Natural := 0;
   nb_taskset			: Natural := 0;
   protocol_recovery		: Natural := 0;
   protocol_improvement_quality : Natural := 0;
   period_reduction		: Boolean;
   
   first_time			: Boolean	:= True;
   
   cpu_utilization_values	: float_array(1 .. 8)			:= (20.0,30.0,40.0,50.0,60.0,70.0,80.0,90.0);
   Target_Cpu_Usage		: float 				:= 70.0;
   coefficients		: array (1 .. 3) of coefficient 	:= (75,50,25);
   coef			: coefficient				:= 50;
   seed			: Natural				:= 0;
   cpu_used_factor		: Float				:= 1.0;
   
   percentage_periods		: integer_array(1 .. 4) := (1,2,4,8);
   
   -- variables to write into the name file
   file1			: Unbounded_string;
   file2			: Unbounded_string;
   file3			: Unbounded_string;
   file4			: Unbounded_string;
   file5			: Unbounded_string;
   file6			: Unbounded_string;
   file7			: Unbounded_string;
   file8			: Unbounded_string;
   file9			: Unbounded_string;
   file10			: Unbounded_string;
   
   ---------- RANDOM FUNCTION ---------
   ------------------------------------
   -- randomly shuflle an array
   procedure shuffle_an_array (to_shuffle : in out integer_array) is

         use Ada.Numerics.Float_Random;

         n                 : Integer;
         g                 : Ada.Numerics.Float_Random.Generator;
         a_random_position : Integer := 0;
         a_value           : Integer;
      begin

         n := to_shuffle'length;
         Reset (g);
         while n > 1 loop
            a_random_position := 0;
            while (a_random_position < 1) or (a_random_position > n) loop
               a_random_position := Integer (Random (g) * Float (n));
            end loop;

            n                              := n - 1;
            a_value                        := to_shuffle (a_random_position);
            to_shuffle (a_random_position) := to_shuffle (n);
            to_shuffle (n)                 := a_value;

         end loop;
      end shuffle_an_array;
      
   -- randomly shuffle criticality values with 50% of HI and LO
   function compute_criticality(NT: integer) return integer_array
	   is
	   	tab_criticality : integer_array (1 .. NT);
	   begin
	   	for i in 1 .. NT loop
	   		if (i mod 2) = 0 then
	   			tab_criticality(i) := 2;
	   		else
	   			tab_criticality(i) := 0;
	   		end if;
	   	end loop;
	   	
	   	-- randomly shuffle the criticality tab
	   	shuffle_an_array(tab_criticality);
	return tab_criticality;
   end compute_criticality;
   
   --randomly shuffle criticality values with a parameter of percentage
   function compute_criticality(NT: integer; percentage_HI: Natural) return integer_array
   	is
	   	tab_criticality : integer_array (1 .. NT);
	   	nbLO		: Natural;
	   begin
	   	-- compute the number of LO tasks
	   	nbLO := Natural(((100-percentage_HI) * NT)/ 100);
	   	--put_line("nbLO :"&nbLO'img);
	   	for i in 1 .. NT loop
	   		if ((nbLO - i)>=0) then
	   			tab_criticality(i) := 0;
	   		else
	   			tab_criticality(i) := 2;
	   		end if;
	   	end loop;
	   	shuffle_an_array(tab_criticality);
	return tab_criticality;
   end compute_criticality;
	   
   -- randomly shuffle periods values
   function compute_period(NT	: integer) return integer_array
   is
   	tab_period 		: integer_array (1 .. NT);
   	var			: Natural := 1;
   	counter		: Natural := NT;
   	t_values           	: random_tools.integer_array (1 .. 8) := (2000,2500,1500,3000,3750,5000,10000,6000);
   begin
   	while counter /= 0 loop
 		if (var mod 9) = 0 then
 			var := 1;
 		end if;
   		tab_period(counter) := t_values(var);
   		counter := counter - 1;
   		var := var + 1;
   	end loop;
   	
   	-- shuffle period array
   	shuffle_an_array(tab_period);
   	return tab_period;
   end compute_period;
   
   
   procedure reduce_LO_period(tab_period : in out integer_array; pp : in integer)
   is
   begin
   	for i in tab_period'Range loop
   		tab_period(i) := tab_period(i)/pp;
   	end loop;
   
   end reduce_LO_period;
   
   
   
   
------ main programm --------
-----------------------------
	   
begin
	--  Parse command line
		      
      if Argument_Count /= 9 then
	 Put ("Usage: " & Command_Name & " ");
	 Put_Line ("N_Tasks threshold N_Percentage_LO_Tasks nb_iteration nb_taskset Protocol_recovery_mode period_reduction protocol_improvement_quality Filename");
	 GNAT.OS_Lib.OS_Exit (1);
      else
	 N_Tasks			:= Natural'Value(Argument(1));
	 Threshold_Quality		:= Natural'Value(Argument(2));
	 N_Percentage_LO_Tasks		:= Natural'Value(Argument(3));
	 nb_iteration			:= Natural'Value(Argument(4));
	 nb_taskset			:= Natural'Value(Argument(5));
	 protocol_recovery		:= Natural'Value(Argument(6));
	 period_reduction		:= Boolean'Value(Argument(7));
	 protocol_improvement_quality  := Natural'Value(Argument(8));
      end if;
		
	declare
		tab_criticality	: integer_array (1 .. N_Tasks);
   		tab_period	 	: integer_array (1 .. N_Tasks);
   		u_values         	: random_tools.float_array (0 .. N_Tasks-1);
   	begin
	
	-- calculate the number of HI and ME tasks
	N_High_Tasks := Natural(((100-N_Percentage_LO_Tasks) * N_Tasks)/ 100);
	
	-- randomize criticality 
	tab_criticality := compute_criticality(N_Tasks,100-N_Percentage_LO_Tasks);
	
	cpu_used_factor := 1.0;
	
	-- Initialize the System and the Cheddar framework
	   --
	   Call_Framework.initialize (False);
	   Initialize (sys);	   
	      
	   Actual_CPU_Usage := 0.0;
	      
	   -- Adding Cores, Processor and address_space
	   --
	   Add_core_unit
		(sys.Core_units,
		 a_core,
		 to_unbounded_string("c1"),
		 preemptive,
		 0,
		 1,
		 0,
		 0,
		 0,
		 To_Unbounded_String (""),
		 To_Unbounded_String (""),
		 MIXED_CRITICALITY_QUALITY_AMC_PROTOCOL,
		 no_memories,
		 empty_string,
		 empty_string,
		 0,
		 Threshold_Quality);   
		 	   
	   Add_Processor
	     (sys.Processors,
	      a_processor,
	      To_Unbounded_String ("processor1"),
	      A_Core);

	   Add_Address_Space
	     (sys.Address_Spaces,
	      To_Unbounded_String ("addr1"),
	      To_Unbounded_String ("processor1"),
	      0,
	      0,
	      0,
	      0);
				      
	--===========================================================================================
	--=============================== Version wihtout period reduction ==========================
	--===========================================================================================
	if not period_reduction then
	
		--******** LOOP on number of different taskset *******
		for i in 1..nb_taskset loop		
		
			-- Generate T values
			--tab_period := generate_period_set_with_limited_hyperperiod(N_Tasks,N_Tasks);
			tab_period := compute_period(N_Tasks);
			
			-- Generate U values
			u_values := gen_uunifast_with_limited_utilization(N_Tasks, Target_Cpu_Usage/100.0);
			
									
			-- initialize the seed value
			seed := 0;
				
			--********** LOOP on CPU utilization ********
			for Target_Cpu_Usage of cpu_utilization_values loop
							
				--******** LOOP on seed values *******
				for iter in 1 .. nb_iteration loop
				   			    

				    Create_Mixedcriticality_Independant_Periodic_Taskset_System
					(Sys,
					 Actual_CPU_Usage,
					 N_Tasks,
					 Target_Cpu_Usage,
					 1.0,1.0, true, 
					 N_Different_Periods,
					 N_High_Tasks,
					 N_Medium_Tasks,
					 coef,
					 Sched_Fifo,
					 first_time,
					 u_values,
					 tab_criticality,
					 tab_period,
					 cpu_used_factor,
					 False,
					 protocol_recovery,
					 protocol_improvement_quality,
					 seed);
				     
				     first_time := false;

				     set_priority_mixedcriticality_rm(sys.tasks, to_unbounded_string("processor1"));	

				      

				      -----------------------------------------------------
				      ------------ FILE MANAGEMENT ------------------------
				      -----------------------------------------------------
				      -- Remove the space in front of the value
				      file3 := To_Unbounded_String(integer(iter)'img);
				      file4 := To_Unbounded_String(integer(Target_Cpu_Usage)'img);
				      file2 := To_Unbounded_String(integer(protocol_recovery)'img);
				      file5 := To_Unbounded_String(integer(i)'img);
				      file1 := To_Unbounded_String(integer(coef)'img);
				      file6 := To_Unbounded_String(integer(N_percentage_LO_tasks)'img);
				      file7 := To_Unbounded_String(integer(N_Tasks)'img);
				      file8 := To_Unbounded_String(integer(Threshold_Quality)'img);
				      file9 := To_Unbounded_String(integer(protocol_improvement_quality)'img);
				      
				      Delete(file1,1,1);
				      Delete(file2,1,1);
				      Delete(file4,1,1);
				      Delete(file5,1,1);
				      Delete(file6,1,1);
				      Delete(file7,1,1);
				      Delete(file8,1,1);
				      Delete(file9,1,1);
				      if iter < 10 then
				      	Replace_Element(file3,1,'0');			      	
				      else 
				      	Delete(file3,1,1);			      	
				      end if;
				      			    			  
				      --
				      declare 
					File_Name   : String := Argument(9) & To_String(file2) & "_quality_" &To_String(file9) & "_coef_" & To_String(file1) & "_cpu_"& to_String(file4) & "_taskset"& To_String(file5) & "_nbtask"&To_String(file7)&"_PLO"&To_String(file6)&"_threshold"&To_String(file8)&"_iter" & To_String(file3) & ".xmlv3";
				      begin
					write_to_xml_file(sys, File_Name);
				      end;
				      ------------------------------------------------------
				      ------------------------------------------------------
				      
				      
				      seed := seed + 1;
				end loop; -- iteration
				cpu_used_factor := cpu_used_factor + 0.5;
			end loop; -- cpu utilization
		end loop; -- taskset
	--end loop;
	
	--===========================================================================================
	--================================= Version wih period reduction ============================
	--===========================================================================================
	else
			
		--******** LOOP on number of different taskset *******
		for i in 1..nb_taskset loop
										
			-- Generate U values
			u_values := gen_uunifast_with_limited_utilization(N_Tasks, Target_Cpu_Usage/100.0);
									
			

			--********** LOOP on period reduction  ********
			for pp of percentage_periods loop
			
				-- Generate T values	
				if pp = 1 then		
					tab_period := compute_period(N_Tasks);
				else
					reduce_LO_period(tab_period,pp);
				end if;
	
				-- initialize the seed value
				seed := 0;
			
				--******** LOOP on seed values *******
				for iter in 1 .. nb_iteration loop

				   -- Initialize the System and the Cheddar framework
				   --
				   Call_Framework.initialize (False);
				   Initialize (sys);	   
				      
				   Actual_CPU_Usage := 0.0;
				      
				   -- Adding Cores, Processor and address_space
				   --
				   Add_core_unit
					(sys.Core_units,
					 a_core,
					 to_unbounded_string("c1"),
					 preemptive,
					 0,
					 1,
					 0,
					 0,
					 0,
					 To_Unbounded_String (""),
					 To_Unbounded_String (""),
					 MIXED_CRITICALITY_AMC_PROTOCOL,
					 no_memories,
					 empty_string,
					 empty_string,
					 0,
					 Threshold_Quality);   
					 	   
				   Add_Processor
				     (sys.Processors,
				      a_processor,
				      To_Unbounded_String ("processor1"),
				      A_Core);

				   Add_Address_Space
				     (sys.Address_Spaces,
				      To_Unbounded_String ("addr1"),
				      To_Unbounded_String ("processor1"),
				      0,
				      0,
				      0,
				      0);
				    
				     
				    Create_Mixedcriticality_Independant_Periodic_Taskset_System
					(Sys,
					 Actual_CPU_Usage,
					 N_Tasks,
					 Target_Cpu_Usage,
					 1.0,1.0, true, 
					 N_Different_Periods,
					 N_High_Tasks,
					 N_Medium_Tasks,
					 coef,
					 Sched_Fifo,
					 first_time,
					 u_values,
					 tab_criticality,
					 tab_period,
					 cpu_used_factor,
					 False,
					 protocol_recovery,
					 protocol_improvement_quality,
					 seed);
				     
				     first_time := false;

				     set_priority_mixedcriticality_rm(sys.tasks, to_unbounded_string("processor1"));	

				      

				      -----------------------------------------------------
				      ------------ FILE MANAGEMENT ------------------------
				      -----------------------------------------------------
				      -- Remove the space in front of the value
				      file3 := To_Unbounded_String(integer(iter)'img);
				      file4 := To_Unbounded_String(integer(Target_Cpu_Usage)'img);
				      file2 := To_Unbounded_String(integer(protocol_recovery)'img);
				      file5 := To_Unbounded_String(integer(i)'img);
				      file1 := To_Unbounded_String(integer(coef)'img);
				      file6 := To_Unbounded_String(integer(N_percentage_LO_tasks)'img);
				      file7 := To_Unbounded_String(integer(N_Tasks)'img);
				      file8 := To_Unbounded_String(integer(Threshold_Quality)'img);
				      file9 := To_Unbounded_String(integer(pp)'img);
				      
				      Delete(file1,1,1);
				      Delete(file2,1,1);
				      Delete(file4,1,1);
				      Delete(file5,1,1);
				      Delete(file6,1,1);
				      Delete(file7,1,1);
				      Delete(file8,1,1);
				      Delete(file9,1,1);
				      if iter < 10 then
				      	Replace_Element(file3,1,'0');			      	
				      else 
				      	Delete(file3,1,1);			      	
				      end if;
				      			    			  
				      --
				      declare 
					File_Name   : String := Argument(9) & To_String(file2) & "_coef_" & To_String(file1) & "_cpu_"& to_String(file4) & "_taskset"& To_String(file5) & "_nbtask"&To_String(file7)&"_PP"&To_String(file9)&"_PLO"&To_String(file6)&"_threshold"&To_String(file8)&"_iter" & To_String(file3) & ".xmlv3";
				      begin
					write_to_xml_file(sys, File_Name);
				      end;
				      ------------------------------------------------------
				      ------------------------------------------------------
				      
				      
				      seed := seed + 1;
				end loop;
			end loop;
		end loop;
	
	end if;
	
	end;
end Generate_amc_monocore;
