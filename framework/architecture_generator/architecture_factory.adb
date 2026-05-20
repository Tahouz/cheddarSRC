------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Cheddar is a GNU GPL real-time scheduling analysis tool.
-- This program provides services to automatically check schedulability and
-- other performance criteria of real-time architecture models.
--
-- Copyright (C) 2002-2023, Frank Singhoff, Alain Plantec, Jerome Legrand,
--                          Hai Nam Tran, Stephane Rubini
--
-- The Cheddar project was started in 2002 by
-- Frank Singhoff, Lab-STICC UMR 6285, Université de Bretagne Occidentale
--
-- Cheddar has been published in the "Agence de Protection des Programmes/France" in 2008.
-- Since 2008, Ellidiss technologies also contributes to the development of
-- Cheddar and provides industrial support.
--
-- The full list of contributors and sponsors can be found in README.md
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
--
--
-- Contact : cheddar@listes.univ-brest.fr
--
------------------------------------------------------------------------------
-- Last update :
--    $Rev: 5537 $
--    $Date: 2025-04-09 08:57:25 +0200 (mer., 09 avril 2025) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------
with execution_units; use execution_units;
with execution_units.extended; use execution_units.extended;

with Generic_Graph; use Generic_Graph;
with Tasks;         use Tasks;

with task_set; use task_set;

with Task_Groups; use Task_Groups;

with task_group_set; use task_group_set;

with Buffers; use Buffers;

with Messages; use Messages;

with Dependencies; use Dependencies;

with Resources; use Resources;
use Resources.Resource_Accesses;

with systems; use systems;

with Processors;        use Processors;
with processor_set;     use processor_set;
with Address_Spaces;    use Address_Spaces;
with address_space_set; use address_space_set;
with Caches;            use Caches;
with Caches;            use Caches.Cache_Blocks_Table_Package;
with message_set;       use message_set;

with buffer_set; use buffer_set;

with network_set;        use network_set;
with event_analyzer_set; use event_analyzer_set;
with resource_set;       use resource_set;

with task_dependencies; use task_dependencies;

with Buffers; use Buffers;
use Buffers.Buffer_Roles_Package;

with Queueing_Systems; use Queueing_Systems;

with unbounded_strings; use unbounded_strings;
with convert_strings;
with convert_unbounded_strings;

with Text_IO;             use Text_IO;
with systems;             use systems;
with Objects;             use Objects;
with Parameters.extended; use Parameters.extended;
with Scheduler_Interface; use Scheduler_Interface;

with Ada.Finalization;
with Ada.Float_Text_IO;
with Ada.Numerics.Float_Random;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;



with unbounded_strings; use unbounded_strings;
use unbounded_strings.unbounded_string_list_package;

with architecture_factory; use architecture_factory;

with Memories; use Memories;
use Memories.Memories_Table_Package;

with Unchecked_Deallocation;

with sets;

with Framework_Config; use Framework_Config;

with Offsets;              use Offsets;
with Offsets;              use Offsets.Offsets_Table_Package;
with random_tools;         use random_tools;
with initialize_framework; use initialize_framework;

with GNAT.Os_Lib;

package body architecture_factory is

   cpt : Integer;
   procedure initialize_cpt is
   begin
      cpt := Integer (0);
   end initialize_cpt;

   -- 0 --------= System =--------
   procedure create_time_triggered_communication_system
     (s                     : in out system;
      number_tasks          : in     Integer;
      number_resources      : in     Integer;
      number_messages       : in     Integer;
      number_dependencies   : in     Integer;
      number_core_units     : in     Integer;
      number_processors     : in     Integer;
      number_buffers        : in     Integer;
      number_address_spaces : in     Integer)
   is
      i       : Integer;
      preempt : preemptives_type;
      sched   : schedulers_type;
   begin
      initialize (s);

      initialize_cpt;

      preempt := random_preemptivity;
      sched   := restrained_random_scheduler;

      i := 0;

      while (i < number_core_units) loop
         add_core_unit_to_system (s);
         i := i + 1;
      end loop;
      i := 0;
      while (i < number_processors) loop
         add_mono_core_processor_to_system (s, preempt, sched);
         i := i + 1;
      end loop;
      i := 0;
      while (i < number_address_spaces) loop
         add_address_space_to_system
           (s,
            get_random_element (s.processors).name);
         i := i + 1;
      end loop;
      i := 0;
      while (i < number_buffers) loop
         add_buffer_to_system (s);
         i := i + 1;
      end loop;
      i := 0;
      while (i < number_messages) loop
         i := i + 1;
      end loop;

      add_multiple_tasks_to_system (s, number_tasks, periodic_type);
      i := 0;
      while (i < number_resources) loop
         add_resource_to_system (s, 2);
         i := i + 1;
      end loop;
      i := 0;
      while (i < number_dependencies) loop
         add_time_triggered_communication_dependency_to_system (s);
         i := i + 1;
      end loop;

   end create_time_triggered_communication_system;

   procedure create_ravenscar_system
     (s                     : in out system;
      number_tasks          : in     Integer;
      number_resources      : in     Integer;
      number_messages       : in     Integer;
      number_dependencies   : in     Integer;
      number_core_units     : in     Integer;
      number_processors     : in     Integer;
      number_buffers        : in     Integer;
      number_address_spaces : in     Integer)
   is
      i       : Integer;
      preempt : preemptives_type;
      sched   : schedulers_type;
   begin
      initialize (s);
      initialize_cpt;

      preempt := random_preemptivity;
      sched   := restrained_random_scheduler;

      i := 0;

      while (i < number_core_units) loop
         add_core_unit_to_system (s);
         i := i + 1;
      end loop;
      i := 0;
      while (i < number_processors) loop
         add_mono_core_processor_to_system (s, preempt, sched);
         i := i + 1;
      end loop;

      i := 0;
      while (i < number_address_spaces) loop
         add_address_space_to_system
           (s,
            get_random_element (s.processors).name);
         i := i + 1;
      end loop;
      i := 0;
      while (i < number_buffers) loop
         add_buffer_to_system (s);
         i := i + 1;
      end loop;
      i := 0;
      while (i < number_messages) loop
         --Add_Message_To_System (S);
         i := i + 1;
      end loop;

      add_multiple_tasks_to_system (s, number_tasks, periodic_type);
      i := 0;
      while (i < number_resources) loop
         add_resource_to_system (s, 0);
         i := i + 1;
      end loop;
      i := 0;
      while (i < number_dependencies) loop
         add_time_triggered_communication_dependency_to_system (s);
         i := i + 1;
      end loop;

   end create_ravenscar_system;

   -- -------------------------------------------------------------------------
   --------------------
   -- This procedure creates X multiframes and adds frames to them.
   -- It first adds one frame to each at least
   -- Then it adds frames randomly to any multiframe
   -- X% of frames are added with respect to mf_period
   -- X% is computed according to sync_ratio (ratio of multiframes that have
   --the same mf_period)
   -- Synched multiframes have their tail frame's interarrival modified to
   --match mf_period
   -- Prec_Deps are added by going through synched multiframes.
   -- For each frame, a Prec_Dep is added with a probability of prec_prob
   -- The Prec_Dep is from the current multiframe's frame to the next
   --multiframe's random frame
   ----------------------------------------------------------------------------
   --------------------
   procedure create_mf_system
     (s                               : in out system;
      number_groups                   : in     Integer;
      number_frames                   : in     Integer;
      number_resources                : in     Integer;
      number_resource_usages          : in     Integer;
      number_core_units_per_processor : in     Integer;
      number_processors               : in     Integer;
      number_address_spaces           : in     Integer;
      sched                           : in     schedulers_type;
      mf_period                       : in     Integer := 0;
      sync_ratio                      : in     Double  := 0.0;
      number_precedences              : in     Integer := 0)
   is

      preempt : preemptives_type;
      i       : Integer;

   begin
      initialize (s);
      initialize_cpt;

      preempt := preemptive;

      -- ***** Processors generation *****
      add_multiple_processors_to_system
        (s,
         number_processors,
         number_core_units_per_processor,
         sched,
         preempt);

      -- ***** Address_Spaces generation *****
      add_multiple_address_spaces_consistently_to_system
        (s,
         number_processors,
         number_address_spaces);

      -- ***** Task Groups generation *****
      add_multiple_task_groups_to_system (s, number_groups, multiframe_type);

      -- ***** Tasks generation *****
      add_multiple_frame_tasks_to_system
        (s,
         number_frames,
         mf_period,
         sync_ratio);

      -- ***** Resources generation *****
      i := 0;
      while (i < number_resources) loop
         add_resource_to_system (s, number_resource_usages);
         i := i + 1;
      end loop;

      -- ***** Precedence Dependencies generation *****
      add_multiple_mf_precedence_dependencies_to_system
        (s,
         number_precedences,
         number_groups,
         sync_ratio);

   end create_mf_system;

   --------------------------------------------
   -- Generate_A_Customized_Ravenscar_System --
   --------------------------------------------

   procedure generate_a_customized_ravenscar_system
     (my_system               : in out system;
      n                       : in     Integer; -- number of tasks
      target_cpu_utilization  : in     Float; -- desired cpu utilization
      current_cpu_utilization : out Float; -- cpu utilization of the generated system
      n_diff_periods : in     Integer; -- number of maximum different periods
      n_resources             : in     Integer; -- number of resources
      rsf                     : in     Float; -- resource sharing factor
      csr                     : in     Float; -- critical section ratio
      a_sched_policy          : in     policies)

   is

      use Ada.Float_Text_IO;

      my_resources : resources_set;
      my_tasks     : tasks_set;

      suited_current_cpu_utilization : Boolean := False;
      schedulable                    : Boolean := False;
      variation_percentage           : Float   :=
        0.09;   -- Tolerated percentage of variation from the target cpu_utilization

   begin

      while not suited_current_cpu_utilization loop

         suited_current_cpu_utilization := False;

         current_cpu_utilization := 0.0;

         create_independant_periodic_taskset_system
           (s                       => my_system,
            current_cpu_utilization => current_cpu_utilization,
            n_tasks                 => n,
            target_cpu_utilization  => target_cpu_utilization,
            d_min                   => 1.0,
            d_max                   => 1.0,
            is_synchronous          => True,
            n_different_periods     => n_diff_periods, --10,
            a_sched_policy          => a_sched_policy);

         add_resource_set_to_system
           (s                       => my_system,
            n_resources             => n_resources,
            resource_sharing_factor => rsf,
            critical_section_ratio  => csr);

         if abs (target_cpu_utilization - current_cpu_utilization) <=
           variation_percentage
         then
            suited_current_cpu_utilization := True;
         end if;

      end loop;

   end generate_a_customized_ravenscar_system;

   ------------------------------------------------
   -- Create_Independant_Periodic_TaskSet_System --
   ------------------------------------------------

   procedure create_independant_periodic_taskset_system
     (s                       : in out system;
      current_cpu_utilization : in out Float;
      n_tasks                 : in     Integer;
      target_cpu_utilization  : in     Float;
      d_min                   : in     Float   := 1.0;
      d_max                   : in     Float   := 1.0;
      is_synchronous          : in     Boolean := True;
      n_different_periods     : in     Integer;
      a_sched_policy          : in     policies)

   is
      use Ada.Numerics.Float_Random;

      a_factor          : Integer;
      u_values          : random_tools.float_array (0 .. n_tasks - 1);
      t_values          : random_tools.integer_array (1 .. n_tasks);
      a_capacity        : Natural := 0;
      a_period          : Natural := 0;
      a_deadline        : Natural := 0;
      a_start_time      : Natural := 0;
      a_random_deadline : Float;
      omin              : Float := 0.0;
      omax              : Float := 0.0;
      a_random_offset   : Float;
      my_resources      : resources_set;
      my_tasks          : tasks_set;
      a_task_priority   : Integer;
      g                 : Ada.Numerics.Float_Random.Generator;

   begin

      if a_sched_policy = sched_fifo then
         a_task_priority := 1;
      else
         a_task_priority := 0;
      end if;

      a_factor := 1;--N_Tasks;
      Reset (g);

      u_values := gen_uunifast (n_tasks, target_cpu_utilization);

      t_values :=
        generate_period_set_with_limited_hyperperiod
          (n_tasks,
           n_different_periods);

      initialize (my_tasks);
      for i in 1 .. n_tasks loop

         a_period :=
           Natural
             (t_values (i) *
              a_factor); -- A_factor inflates the periods to avoid too much execution times
         -- equal to zero due to integer rounding
	
         a_capacity :=
           Integer (Float'rounding (Float (a_period) * u_values (i - 1)));
         if a_capacity = 0 then
            a_capacity := 1;
         end if;

         a_random_deadline := d_min + Random (g) * (d_max - d_min);
         while (a_random_deadline > d_max) or (a_random_deadline < d_min) loop
            a_random_deadline := d_min + Random (g) * (d_max - d_min);
         end loop;

         a_deadline :=
           Integer
             (Float'rounding
                (Float (a_period - a_capacity) * a_random_deadline)) +
           a_capacity;

         omin := 0.0;
         omax := Float (a_period);

         if (not is_synchronous) then
            a_random_offset := omin + Random (g) * (omax - omin);
            while (a_random_offset > omax) or (a_random_offset < omin) loop
               a_random_offset := omin + Random (g) * (omax - omin);
            end loop;
            a_start_time := Integer (Float'rounding (a_random_offset));
         else
            a_start_time := 0;
         end if;

         current_cpu_utilization :=
           current_cpu_utilization + Float (a_capacity) / Float (a_period);
          

         add_task
           (my_tasks           => my_tasks,
            name => suppress_space (To_Unbounded_String ("Task" & i'img)),
            cpu_name           => To_Unbounded_String ("processor1"),
            address_space_name => To_Unbounded_String ("addr1"),
            core_name          => empty_string,
            task_type          => periodic_type,
            start_time         => a_start_time,
            capacity           => a_capacity,
            period             => a_period,
            deadline           => a_deadline,
            jitter             => 0,
            blocking_time      => 0,
            priority           => a_task_priority,
            criticality        => 0,
            policy             => a_sched_policy);

      end loop;
      s.tasks := my_tasks;

   end create_independant_periodic_taskset_system;
   
   
   -- function to find the good c values for mixed criticality models
   --
   procedure compute_criticality_by_CPU_Utilization
   (n_tasks : in Integer; 
    t_values : in random_tools.integer_array;
    u_values :  in out random_tools.float_array; 
    criticality_tab : in out integer_array;
    cpu_used	: in float)
   
   is
   
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
     
      -- U values we looking for
      u_hi	: float 	:= 0.0;
      u_me	: float		:= 0.0;
      u_lo	: float 	:= 0.0;
      
      c_values  : integer_array(1 .. n_tasks);
      
      find 	: Boolean := False;
      j		: Natural := 0;
      u_temp_values : random_tools.float_array(0 .. 7);
      
   begin
      
      for i in 1 .. n_tasks loop
      	c_values(i) := Integer(Float'rounding(Float(t_values(i)) * u_values(i-1)));
      end loop;
      	  	
      while not find loop
      	  u_hi := 0.0;
      	  u_me := 0.0;
      	  u_lo := 0.0;
      	  
      	  if j = 10 then
      	  	u_temp_values := gen_uunifast_with_limited_utilization(n_tasks, cpu_used);
      	  	j := 0;
      	  	
      	  	for i in 1 .. n_tasks loop
      	  		c_values(i) := Integer(Float'rounding(Float(t_values(i)) * u_temp_values(i-1)));
      	  	end loop;
      	  end if;
      	  
          -- shuffle criticality array
          shuffle_an_array(criticality_tab);
          
          -- loop over the values
          for i in 1 .. n_tasks loop    	  
		  -- compute u_values for medium
		  if criticality_tab(i) >= 1 then
		  	u_me := u_me + (1.5 * float(c_values(i)))/float(t_values(i));
		  end if;
		  if criticality_tab(i) = 2 then
		  	u_hi := u_hi + float(2*c_values(i))/float(t_values(i));
		  end if;		  
		  if criticality_tab(i) >= 0 then
		  	u_lo := u_lo + float(c_values(i))/float(t_values(i));
		  end if;
          end loop;
          
          u_hi := u_hi * 100.0;
          u_me := u_me * 100.0;
          u_lo := u_lo * 100.0;
          
          if u_me >= u_lo-1.0 and u_me <= u_lo+1.0 then
		  if u_hi >= u_lo-1.0 and u_hi <= u_lo+1.0 then
		  	find := true;
		  end if;
	  end if;
	  
	  j := j + 1 ;
       end loop;
       u_values := u_temp_values;
   
   end compute_criticality_by_CPU_Utilization;

   
   ------------------------------------------------
   -- Create_Mixedcriticality_Independant_Periodic_TaskSet_System --
   ------------------------------------------------

   procedure create_Mixedcriticality_independant_periodic_taskset_system
     (s                       	: in out system;
      current_cpu_utilization 	: in out Float;
      n_tasks                 	: in     Integer;
      target_cpu_utilization  	: in     Float;
      d_min                   	: in     Float   := 1.0;
      d_max                   	: in     Float   := 1.0;
      is_synchronous          	: in     Boolean := True;
      n_different_periods     	: in     Integer;
      p_high_tasks	      		: in     Natural;
      p_medium_tasks          	: in     Natural;
      coef				: in	 coefficient;
      a_sched_policy          	: in     policies)

   is
      use Ada.Numerics.Float_Random;

      a_factor           : Integer;
      u_values           : random_tools.float_array (0 .. n_tasks - 1);
      t_values           : random_tools.integer_array (1 .. n_tasks);
      a_capacity         : Natural := 0;
      a_capacities	  : execution_units_table;
      a_qualities	  : execution_units_table;
      a_criticality	  : Integer;
      a_period           : Natural := 0;
      a_deadline         : Natural := 0;
      a_start_time       : Natural := 0;
      a_random_deadline  : Float;
      omin               : Float := 0.0;
      omax               : Float := 0.0;
      a_random_offset    : Float;
      my_resources       : resources_set;
      my_tasks           : tasks_set;
      a_task_priority    : Integer;
      a_model		  : Execution_Unit_Model_Type := MixedCriticality_Execution_Unit;
      
      n_high_tasks	  : Natural;
      n_medium_tasks	  : Natural;
      RandomNumber	  : Float;
      E		  : Natural := 0;
      u_vise_high        : Float := 0.0;
      u_vise_medium	  : Float := 0.0;		        
      g                  : Ada.Numerics.Float_Random.Generator;
      criticality_tab	  : integer_array(1 .. n_tasks);

   begin
      a_factor := 1;--N_Tasks;
      Reset (g);
      RandomNumber := Random(g);
       
      if a_sched_policy = sched_fifo then
         a_task_priority := 1;
      else
         a_task_priority := 0;
      end if;
      
      --u_values := gen_uunifast (n_tasks, target_cpu_utilization);
      u_values := gen_uunifast_with_limited_utilization(n_tasks, target_cpu_utilization);
      initialize (my_tasks);
      
      --t_values := generate_period_set_with_limited_hyperperiod (n_tasks, n_different_periods);
      t_values := (2000,2500,1500,3000,3750,5000,10000,6000);
           
      -- compute the criticality of each task
      -- in the aim to ahve a good cpu tuilization representation
      compute_criticality_by_CPU_Utilization(n_tasks,t_values,u_values,criticality_tab,target_cpu_utilization);
      
      -- Compute number of HI, ME and LO tasks
      -- Default value => pHI : 0.5 and pME : 0.25
      n_high_tasks := (n_tasks * p_high_tasks) / 100;
      n_medium_tasks := n_tasks - n_high_tasks;
      n_medium_tasks := (n_medium_tasks * p_medium_tasks * 2) / 100;
         
      for i in 1 .. n_tasks loop
         a_period := Natural(t_values (i) * a_factor); -- A_factor inflates the periods to avoid too much execution times
         -- equal to zero due to integer rounding
         
         a_capacity := Integer (Float'rounding (Float (a_period) * u_values (i - 1)));
         if a_capacity = 0 then
         	put_line("erreur capacité = 0");
         end if;
         put_line("u_values"&u_values(i-1)'img);

         if a_capacity = 0 then
            a_capacity := 1;
         end if;
        
	 
      	 -- interference model defined by a coefficient between 0 and 1
      	 --
	 E := Natural((a_capacity * coef)/100);      

         a_random_deadline := d_min + Random (g) * (d_max - d_min);
         while (a_random_deadline > d_max) or (a_random_deadline < d_min) loop
            a_random_deadline := d_min + Random (g) * (d_max - d_min);
         end loop;

         a_deadline := Integer(Float'rounding(Float (a_period - a_capacity) * a_random_deadline)) + a_capacity;
         omin := 0.0;
         omax := Float (a_period);
         
         
         
         a_capacities.nb_entries:=3;
         a_capacities.entries(0) := new execution_unit;
         a_capacities.entries(1) := new execution_unit;
         a_capacities.entries(2) := new execution_unit;
         
         a_qualities.nb_entries:=3;
         a_qualities.entries(0) := new execution_unit;
         a_qualities.entries(1) := new execution_unit;
         a_qualities.entries(2) := new execution_unit;
         
         if a_capacity = 1 then
         	a_capacities.entries(0).values_eu := a_capacity;
	 	a_capacities.entries(1).values_eu := 2;
	 	a_capacities.entries(2).values_eu := 3;
	 end if;
	 a_capacities.entries(0).values_eu := a_capacity;
	 a_capacities.entries(1).values_eu := Integer(Float'rounding(1.5 * Float(a_capacity)));
	 a_capacities.entries(2).values_eu := 2 * a_capacity;
	 
	 -- Define the criticality
	 a_criticality := criticality_tab(i);
	 if a_criticality = 2 then 	
         	u_vise_high := u_vise_high + Float (a_capacities.entries(2).values_eu) / Float (a_period);
         	--u_vise_medium := u_vise_medium + Float (a_capacities.entries(1).values_eu) / Float (a_period);
	 end if;
	 if a_criticality = 1 then 	
         	u_vise_medium := u_vise_medium + Float (a_capacities.entries(1).values_eu) / Float (a_period);
	 end if;
	 	
	 
	 a_qualities.entries(0).values_eu := 4;
	 a_qualities.entries(1).values_eu := E;
	 a_qualities.entries(2).values_eu := coef;
	 
         if (not is_synchronous) then
            a_random_offset := omin + Random (g) * (omax - omin);
            while (a_random_offset > omax) or (a_random_offset < omin) loop
               a_random_offset := omin + Random (g) * (omax - omin);
            end loop;
            a_start_time := Integer (Float'rounding (a_random_offset));
         else
            a_start_time := 0;
         end if;

         current_cpu_utilization :=
           current_cpu_utilization + Float (a_capacity) / Float (a_period);

         add_task
           (my_tasks			=> my_tasks,
            name 			=> suppress_space (To_Unbounded_String ("Task" & i'img)),
            cpu_name           	=> To_Unbounded_String ("processor1"),
            address_space_name 	=> To_Unbounded_String ("addr1"),
            core_name          	=> empty_string,
            task_type          	=> periodic_type,
            start_time         	=> a_start_time,
            capacity           	=> E,
            capacities			=> a_capacities,
            qualities			=> a_qualities,
            period             	=> a_period,
            deadline           	=> a_deadline,
            jitter             	=> 0,
            blocking_time      	=> 0,
            priority           	=> a_task_priority,
            criticality        	=> a_criticality,
            policy             	=> a_sched_policy,
            capacity_model		=> a_model
            );

      end loop;
	--put_line("utilisation souhaité :"&integer(target_cpu_utilization*100.0)'img);
	--put_line("utilisation réel C(LO):"&integer(current_cpu_utilization*100.0)'img);
	--put_line("utilisation réel en mode HI:"&integer(u_vise_high*100.0)'img);
	--put_line("utilisation réel en mode ME:"&integer(u_vise_medium*100.0)'img);
	
      s.tasks := my_tasks;
	--put_line("generate taskset");
   end create_Mixedcriticality_independant_periodic_taskset_system;
   
   
   ------------------------------------------------
   -- Create_Mixedcriticality_Independant_Periodic_TaskSet_System --
   ------------------------------------------------

   procedure create_Mixedcriticality_independant_periodic_taskset_system
     (s                         : in out system;
      current_cpu_utilization 	: in out Float;
      n_tasks                 	: in     Integer;
      target_cpu_utilization  	: in out Float;
      d_min                   	: in     Float   := 1.0;
      d_max                   	: in     Float   := 1.0;
      is_synchronous          	: in     Boolean := True;
      n_different_periods     	: in     Integer;
      p_high_tasks	      	: in     Natural;
      p_medium_tasks          	: in     Natural;
      coef			: in	 coefficient;
      a_sched_policy          	: in     policies;
      first_time		: in	 Boolean;
      u_values			: in out random_tools.float_array;
      tab_criticality		: in out random_tools.integer_array;
      tab_period		: in out random_tools.integer_array;
      cpu_used_factor		: in	 Float;
      multicore		: in 	Boolean;
      protocol_recovery	: in Natural;
      protocol_improvement_quality : in Natural;
      a_seed			: in out Natural)

   is
      use Ada.Numerics.Float_Random;

      a_factor           : Integer;
      t_values           : random_tools.integer_array (1 .. n_tasks);
      a_capacity         : Natural := 0;
      a_capacities	 : execution_units_table;
      a_qualities	 : execution_units_table;
      a_criticality	 : Integer;
      a_period           : Natural := 0;
      a_deadline         : Natural := 0;
      a_start_time       : Natural := 0;
      a_random_deadline  : Float;
      omin               : Float := 0.0;
      omax               : Float := 0.0;
      a_random_offset    : Float;
      my_resources       : resources_set;
      my_tasks           : tasks_set;
      a_task_priority    : Integer;
      a_model		 : Execution_Unit_Model_Type := MixedCriticality_Execution_Unit;
      
      n_high_tasks	 : Natural;
      n_medium_tasks	 : Natural;
      RandomNumber	 : Float;
      E		 	 : Natural := 0;
      u_vise_high        : Float := 0.0;
      u_vise_medium	 : Float := 0.0;		        
      g                  : Ada.Numerics.Float_Random.Generator;
      core_name	       	 : Unbounded_string;
      
      

   begin
      a_factor := 2;--N_Tasks;
      Reset (g);
      RandomNumber := Random(g);

      if a_sched_policy = sched_fifo then
         a_task_priority := 1;
      else
         a_task_priority := 0;
      end if;
      
      t_values	:= tab_period;
      
      -- check if the first that we call this procedure
      --
      initialize (my_tasks);
      

      -- Compute number of HI, ME and LO tasks
      -- Default value => pHI : 0.5 and pME : 0.25
      n_high_tasks := (n_tasks * p_high_tasks) / 100;
      n_medium_tasks := n_tasks - n_high_tasks;
      n_medium_tasks := (n_medium_tasks * p_medium_tasks * 2) / 100;
 
      for i in 1 .. n_tasks loop
         a_period := Natural(t_values (i) * a_factor); 	-- A_factor inflates the periods to avoid too much execution times
         							-- equal to zero due to integer rounding
         
         -- Compute LO capacity
         a_capacity := Integer (Float'rounding (Float (a_period) * u_values (i - 1))); 				
         -- normally we multiply the value of CPU utilization but is too small
         -- to have a good representation of CPU utilization, so we use capacity				      
         a_capacity := Integer(Float(a_capacity) * cpu_used_factor);
         
         if a_capacity < 4 then
         	--put_line("erreur capacité = 0");
         	--GNAT.OS_Lib.OS_Exit (1);
         	a_capacity := 4;
         end if;
         
	 
      	 -- Compute the representation of CNN execution time (fixed value)
	 E := Natural((a_capacity * coef)/100);  

         a_random_deadline := d_min + Random (g) * (d_max - d_min);
         while (a_random_deadline > d_max) or (a_random_deadline < d_min) loop
            a_random_deadline := d_min + Random (g) * (d_max - d_min);
         end loop;
         
         a_deadline := a_period;
         
         -- Compute the different execution budgets for each critical level
         a_capacities.nb_entries:=3;
         a_capacities.entries(0) := new execution_unit;
         a_capacities.entries(1) := new execution_unit;
         a_capacities.entries(2) := new execution_unit;
         
         if a_capacity = 1 then
         	a_capacities.entries(0).values_eu := a_capacity;
	 	a_capacities.entries(1).values_eu := 2;
	 	a_capacities.entries(2).values_eu := 3;
	 end if;
	
	 a_capacities.entries(0).values_eu := a_capacity;
	 a_capacities.entries(1).values_eu := Integer(Float'rounding(1.5 * Float(a_capacity)));
	 a_capacities.entries(2).values_eu := 2 * a_capacity;
	 
	  -- Compute the different qualities for each CNN output
	 a_qualities.nb_entries:=3;
         a_qualities.entries(0) := new execution_unit;
         a_qualities.entries(1) := new execution_unit;
         a_qualities.entries(2) := new execution_unit;
         
         -- First value is the current quality level exit of the task
	 a_qualities.entries(0).values_eu := 4;	 
	 -- Used for quality improvement protocol
	 a_qualities.entries(1).values_eu := protocol_improvement_quality;
	 -- Third value is the recovery mode protocol
	 a_qualities.entries(2).values_eu := protocol_recovery;
	 
	 -- Define the criticality
	 a_criticality := tab_criticality(i);
	 
	 -- Measure the actual cpu utilization rate for each mode
	 if a_criticality = 2 then 	
         	u_vise_high := u_vise_high + Float (a_capacities.entries(2).values_eu) / Float (a_period);
         	--u_vise_medium := u_vise_medium + Float (a_capacities.entries(2).values_eu) / Float (a_period);
	 end if;
	 if a_criticality = 1 then 	
         	u_vise_medium := u_vise_medium + Float (a_capacities.entries(2).values_eu) / Float (a_period);
	 end if;
	 
	 
         if (not is_synchronous) then
            a_random_offset := omin + Random (g) * (omax - omin);
            while (a_random_offset > omax) or (a_random_offset < omin) loop
               a_random_offset := omin + Random (g) * (omax - omin);
            end loop;
            a_start_time := Integer (Float'rounding (a_random_offset));
         else
            a_start_time := 0;
         end if;

         current_cpu_utilization :=
           current_cpu_utilization + Float (a_capacities.entries(0).values_eu) / Float (a_period);

	 if not multicore then
         add_task
           (my_tasks			=> my_tasks,
            name 			=> suppress_space (To_Unbounded_String ("Task" & i'img)),
            cpu_name           	=> To_Unbounded_String ("processor1"),
            address_space_name 	=> To_Unbounded_String ("addr1"),
            core_name          	=> empty_string,
            task_type          	=> periodic_type,
            start_time         	=> a_start_time,
            capacity           	=> E,
            capacities			=> a_capacities,
            qualities			=> a_qualities,
            period             	=> a_period,
            deadline           	=> a_deadline,
            jitter             	=> 0,
            blocking_time      	=> 0,
            priority           	=> a_task_priority,
            criticality        	=> a_criticality,
            policy             	=> a_sched_policy,
            capacity_model		=> a_model,
            seed_value			=> a_seed
            );
         
         else
         	if (i mod 2) /= 0 then
         		core_name := To_Unbounded_String ("c1");
         	else
         		core_name := To_Unbounded_String ("c2");
         	end if;
		 add_task
		   (my_tasks		=> my_tasks,
		    name 		=> suppress_space (To_Unbounded_String ("Task" & i'img)),
		    cpu_name           	=> To_Unbounded_String ("processor1"),
		    core_name			=> core_name,
		    address_space_name 	=> To_Unbounded_String ("addr1"),
		    task_type          	=> periodic_type,
		    start_time         	=> a_start_time,
		    capacity           	=> E,
		    capacities		=> a_capacities,
		    qualities		=> a_qualities,
		    period             	=> a_period,
		    deadline           	=> a_deadline,
		    jitter             	=> 0,
		    blocking_time      	=> 0,
		    priority           	=> a_task_priority,
		    criticality        	=> a_criticality,
		    policy             	=> a_sched_policy,
		    capacity_model	=> a_model,
		    seed_value		=> a_seed
		    );
      end if;
      	
      end loop;
	--put_line("utilisation souhaité :"&integer(target_cpu_utilization)'img);
	--put_line("utilisation réel avec C(LO):"&integer(current_cpu_utilization*100.0)'img);
	--put_line("utilisation réel en mode HI:"&integer(u_vise_high*100.0)'img);
	--put_line("utilisation réel en mode ME:"&integer(u_vise_medium*100.0)'img);
	
      	s.tasks := my_tasks;
	current_cpu_utilization := 0.0;
	
   end create_Mixedcriticality_independant_periodic_taskset_system;


  
   ------------------------------------------------
   -- Create_Independant_Periodic_TaskSet_System by generating only capacity--
   -- Periods are given by the t_values parameter !
   -- 
   ------------------------------------------------

   procedure create_independant_periodic_taskset_system
     (s                       : in out system;
      current_cpu_utilization : in out Float;
      n_tasks                 : in     Integer;
      target_cpu_utilization  : in     Float;
      t_values                : in     integer_array;
      priority_values         : in     integer_array)

   is
      use Ada.Numerics.Float_Random;

      u_values        : random_tools.float_array (0 .. n_tasks - 1);
      a_capacity      : Natural := 0;
      a_period        : Natural := 0;
      a_deadline      : Natural := 0;
      a_start_time    : Natural := 0;
      my_resources    : resources_set;
      my_tasks        : tasks_set;
      a_task_priority : Integer;
      g               : Ada.Numerics.Float_Random.Generator;

   begin

      Reset (g);

      u_values := gen_uunifast (n_tasks, target_cpu_utilization);

      initialize (my_tasks);
      for i in 1 .. n_tasks loop

         a_task_priority := priority_values (i);
         a_period        := t_values (i);
         a_deadline      := a_period;
         a_capacity      :=
           Integer (Float'rounding (Float (a_period) * u_values (i - 1)));
         if a_capacity = 0 then
            a_capacity := 1;
         end if;

         current_cpu_utilization :=
           current_cpu_utilization + Float (a_capacity) / Float (a_period);

         add_task
           (my_tasks           => my_tasks,
            name => suppress_space (To_Unbounded_String ("Task" & i'img)),
            cpu_name           => To_Unbounded_String ("processor1"),
            address_space_name => To_Unbounded_String ("addr1"),
            core_name          => empty_string,
            task_type          => periodic_type,
            start_time         => a_start_time,
            capacity           => a_capacity,
            period             => a_period,
            deadline           => a_deadline,
            jitter             => 0,
            blocking_time      => 0,
            priority           => a_task_priority,
            criticality        => 0,
            policy             => sched_fifo);

      end loop;

      s.tasks := my_tasks;

   end create_independant_periodic_taskset_system;

   -- 8 --------= Tasks_Set =--------

   procedure add_task_deadline_equals_period_to_system
     (s                  : in out system;
      name               : in     Unbounded_String;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      task_type          : in     tasks_type)
   is
      i : Integer;

   begin

      i := random_integer (64);
      add_task
        (my_tasks           => s.tasks,
         name               => name,
         cpu_name           => cpu_name,
         address_space_name => address_space_name,
         core_name          => empty_string,
         task_type          => task_type,
         start_time         => 0,
         capacity           => 1,
         period             => i,
         deadline           => i,
         jitter             => 0,
         blocking_time      => 0,
         priority           => (cpt mod 230) + 10,
         criticality        => 1,
         policy             => sched_fifo);
   end add_task_deadline_equals_period_to_system;

   procedure add_task_deadline_larger_than_period_to_system
     (s                  : in out system;
      name               : in     Unbounded_String;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      task_type          : in     tasks_type)
   is
   begin
      add_task
        (my_tasks           => s.tasks,
         name               => name,
         cpu_name           => cpu_name,
         address_space_name => address_space_name,
         core_name          => empty_string,
         task_type          => task_type,
         start_time         => 0,
         capacity           => 1,
         period             => cpt,
         deadline           => cpt + 1,
         jitter             => 0,
         blocking_time      => 0,
         priority           => (cpt mod 230) + 10,
         criticality        => 1,
         policy             => sched_fifo);

      cpt := cpt + 1;
   end add_task_deadline_larger_than_period_to_system;

   procedure add_task_deadline_smaller_than_period_to_system
     (s                  : in out system;
      name               : in     Unbounded_String;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String;
      task_type          : in     tasks_type)
   is
   begin
      add_task
        (my_tasks           => s.tasks,
         name               => name,
         cpu_name           => cpu_name,
         address_space_name => address_space_name,
         core_name          => empty_string,
         task_type          => task_type,
         start_time         => 0,
         capacity           => 1,
         period             => cpt + 1,
         deadline           => cpt,
         jitter             => 0,
         blocking_time      => 0,
         priority           => (cpt mod 230) + 10,
         criticality        => 1,
         policy             => sched_fifo);
      cpt := cpt + 1;
   end add_task_deadline_smaller_than_period_to_system;

   procedure add_aperiodic_task_to_system
     (s                  : in out system;
      name               : in     Unbounded_String;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String)
   is
   begin
      add_task
        (my_tasks           => s.tasks,
         name               => name,
         cpu_name           => cpu_name,
         address_space_name => address_space_name,
         core_name          => empty_string,
         task_type          => aperiodic_type,
         start_time         => 0,
         capacity           => 1,
         period             => 0,
         deadline           => cpt,
         jitter             => 0,
         blocking_time      => 0,
         priority           => (cpt mod 230) + 10,
         criticality        => 1,
         policy             => sched_fifo);
   end add_aperiodic_task_to_system;

   procedure add_parametic_task_to_system
     (s                  : in out system;
      name               : in     Unbounded_String;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String)
   is
   begin
      add_task
        (my_tasks           => s.tasks,
         name               => name,
         cpu_name           => cpu_name,
         address_space_name => address_space_name,
         core_name          => empty_string,
         task_type          => parametric_type,
         start_time         => 0,
         capacity           => 1,
         period             => 0,
         deadline           => cpt,
         jitter             => 0,
         blocking_time      => 0,
         priority           => (cpt mod 230) + 10,
         criticality        => 1,
         policy             => sched_fifo);
   end add_parametic_task_to_system;

   procedure add_poisson_task_to_system
     (s                  : in out system;
      name               : in     Unbounded_String;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String)
   is
   begin
      add_task
        (my_tasks           => s.tasks,
         name               => name,
         cpu_name           => cpu_name,
         address_space_name => address_space_name,
         core_name          => empty_string,
         task_type          => poisson_type,
         start_time         => 0,
         capacity           => 1,
         period             => 0,
         deadline           => cpt,
         jitter             => 0,
         blocking_time      => 0,
         priority           => (cpt mod 230) + 10,
         criticality        => 1,
         policy             => sched_fifo);
   end add_poisson_task_to_system;

   procedure add_periodic_task_to_system
     (s                  : in out system;
      name               : in     Unbounded_String;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String)
   is
      i : Integer;

   begin

      i := random_integer (3);

      case i is
         when 0 =>
            add_task_deadline_smaller_than_period_to_system
              (s,
               name,
               cpu_name,
               address_space_name,
               periodic_type);
         when 1 =>
            add_task_deadline_larger_than_period_to_system
              (s,
               name,
               cpu_name,
               address_space_name,
               periodic_type);
         when others =>
            add_task_deadline_equals_period_to_system
              (s,
               name,
               cpu_name,
               address_space_name,
               periodic_type);
      end case;

   end add_periodic_task_to_system;

   procedure add_frame_task_to_system
     (s                  : in out system;
      name               : in     Unbounded_String;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String)
   is
      i : Integer;

   begin
      -- TODO MF logic to respect
      i := random_integer (3);

      case i is
         when 0 =>
            add_task_deadline_smaller_than_period_to_system
              (s,
               name,
               cpu_name,
               address_space_name,
               frame_task_type);
         when 1 =>
            add_task_deadline_larger_than_period_to_system
              (s,
               name,
               cpu_name,
               address_space_name,
               frame_task_type);
         when others =>
            add_task_deadline_equals_period_to_system
              (s,
               name,
               cpu_name,
               address_space_name,
               frame_task_type);
      end case;

   end add_frame_task_to_system;

   procedure add_multiple_tasks_to_system
     (s         : in out system;
      n         :        Integer;
      task_type : in     tasks_type)
   is

      i : Integer;

   begin

      i := 0;

      while (i < n) loop

         case task_type is
            when periodic_type =>
               add_periodic_task_to_system
                 (s,
                  suppress_space (To_Unbounded_String ("Task" & cpt'img)),
                  get_random_element (s.processors).name,
                  get_random_element (s.address_spaces).name);
            when aperiodic_type =>
               add_aperiodic_task_to_system
                 (s,
                  suppress_space (To_Unbounded_String ("Task" & cpt'img)),
                  get_random_element (s.processors).name,
                  get_random_element (s.address_spaces).name);
            when frame_task_type =>
               add_frame_task_to_system
                 (s,
                  suppress_space (To_Unbounded_String ("Task" & cpt'img)),
                  get_random_element (s.processors).name,
                  get_random_element (s.address_spaces).name);
            when others =>
               add_periodic_task_to_system
                 (s,
                  suppress_space (To_Unbounded_String ("Task" & cpt'img)),
                  get_random_element (s.processors).name,
                  get_random_element (s.address_spaces).name);
         end case;

         i   := i + 1;
         cpt := cpt + 1;
      end loop;

   end add_multiple_tasks_to_system;

   procedure add_multiple_frame_tasks_to_system
     (s             : in out system;
      number_frames : in     Integer;
      mf_period     : in     Integer;
      sync_ratio    : in     Double)
   is

      use generic_task_group_set;
      use Generic_Task_List_Package;

      number_groups : constant task_groups_range :=
        get_number_of_elements (s.task_groups);

      sync_number        : Integer;
      remaining_period   : Integer;
      interarrival       : Integer;
      remaining_frames   : Integer;
      group_tasks_number : Natural;
      j                  : task_groups_range;

      a_task_group    : generic_task_group_ptr;
      a_multiframe    : multiframe_task_group_ptr;
      tail_frame_task : frame_task_ptr;

      an_address_space   : address_space_ptr;
      address_space_name : Unbounded_String;
      cpu_name           : Unbounded_String;

   begin

      -- Sync_Number: The first "sync_number" multiframes have the same
      --mf_period
      sync_number := Integer (Double (number_groups) * sync_ratio);  -- TODO:
      --Round
      --up or
      --down?

      for i in 0 .. (number_groups - 1) loop
         get_element_number (s.task_groups, a_task_group, i);

         if (is_empty (a_task_group.task_list)) then
            -- First frame so a random interarrival no matter the sync_number
            interarrival := random_integer (mf_period / 2) + 1;

            -- Get random addr and cpu
            an_address_space   := get_random_element (s.address_spaces);
            address_space_name := an_address_space.name;
            cpu_name           := an_address_space.cpu_name;
         end if;

         group_tasks_number :=
           get_number_of_elements (a_task_group.task_list) + 1;

         add_task
           (my_tasks        => s.tasks,
            my_task_groups  => s.task_groups,
            task_group_name => a_task_group.name,
            name            =>
              suppress_space
                (a_task_group.name &
                 To_Unbounded_String ("_") &
                 group_tasks_number'img),
            cpu_name           => cpu_name,
            address_space_name => address_space_name,
            task_type          => frame_task_type,
            start_time         => 0,
            capacity           => random_integer (mf_period / 2) + 1,
            period             => interarrival, -- period ~ interarrival
            deadline           => 99999,
            jitter             => 0,
            blocking_time      => 0,
            priority           => 1,
            criticality        => 0,
            policy             => sched_fifo);

      end loop;

      remaining_frames := number_frames - Integer (number_groups);
      while (remaining_frames > 0) loop
         j := task_groups_range (random_integer (Integer (number_groups)));
         get_element_number (s.task_groups, a_task_group, j);

         tail_frame_task := frame_task_ptr (get_tail (a_task_group.task_list));

         -- Addr and CPU must match for all frames
         address_space_name := tail_frame_task.address_space_name;
         cpu_name           := tail_frame_task.cpu_name;

         if (Integer (j) < sync_number) then
            -- Compute allowed random value of interarrival (in interval
            --between last interarrival and mf_period)
            remaining_period := mf_period - tail_frame_task.period;

            if (remaining_period > 0) then
               interarrival := random_integer (remaining_period) + 1;
            else
               interarrival := 0;
            end if;
         else
            interarrival := random_integer (mf_period / 2) + 1;
         end if;

         group_tasks_number :=
           get_number_of_elements (a_task_group.task_list) + 1;

         add_task
           (my_tasks        => s.tasks,
            my_task_groups  => s.task_groups,
            task_group_name => a_task_group.name,
            name            =>
              suppress_space
                (a_task_group.name &
                 To_Unbounded_String ("_") &
                 group_tasks_number'img),
            cpu_name           => cpu_name,
            address_space_name => address_space_name,
            task_type          => frame_task_type,
            start_time         => 0,
            capacity           => random_integer (mf_period / 2) + 1,
            period             => interarrival, -- period ~ interarrival
            deadline           => 99999,
            jitter             => 0,
            blocking_time      => 0,
            priority           => 1,
            criticality        => 0,
            policy             => sched_fifo);

         remaining_frames := remaining_frames - 1;
      end loop;

      -- Modify synched multiframes' tail_task interarrival, so the
      --multiframe's period matches mf_period
      for i in 0 .. (sync_number - 1) loop
         j := task_groups_range (i);

         -- Get the multiframe
         get_element_number (s.task_groups, a_task_group, j);
         a_multiframe := multiframe_task_group_ptr (a_task_group);

         -- Get tail task
         tail_frame_task := frame_task_ptr (get_tail (a_task_group.task_list));

         -- Compute allowed random value of interarrival (in interval between
         --last interarrival and mf_period)
         interarrival :=
           tail_frame_task.interarrival + mf_period - tail_frame_task.period;
         set_interarrival (tail_frame_task, a_multiframe, interarrival);
      end loop;

      -- Set precedence dependencies between frames of a same multiframe group
      set_multiframe_precedences (s.task_groups, s.dependencies);

   end add_multiple_frame_tasks_to_system;

   -- 9 --------= Resources_Set =--------

   procedure add_resource_to_system
     (s                 : in out system;
      n_dependent_tasks :        Integer)
   is
      use generic_task_set;

      local_affected_tasks : resource_accesses_table;
      res                  : critical_section;
      i                    : Integer;
      item                 : resource_accesses_range;
      range_end            : resource_accesses_range;
      name1                : Unbounded_String;
      name2                : Unbounded_String;
      protocol             : resources_type;
      resource_priority    : Integer := 10;
      a_task               : generic_task_ptr;

   begin
      i        := 1;
      protocol := restrained_random_resource_type;
      a_task   := get_random_element (s.tasks);
      name1    := a_task.name;
      Initialize (res);
      loop
         name2 := get_random_element (s.tasks).name;
         exit when name1 /= name2 or get_number_of_elements (s.tasks) = 1;
      end loop;

      add (local_affected_tasks, name2, Copy (res).all);
      add (local_affected_tasks, name1, Copy (res).all);

      initialize (local_affected_tasks);
      for i in 1 .. (n_dependent_tasks - 2) loop
         -- Note: scheduler considers resource usages start at 1 instead of 0
         --in a task's execution interval,
         --       but end at task's execution interval upper bound. I.e. shift
         --+1 start but keep end.
         res.task_begin := random_integer (a_task.capacity) + 1;  -- start in
         --[1 ;
         --task.capaci
         --ty]
         res.task_end := random_integer (res.task_begin, a_task.capacity);
         -- end in [start ; task.capacity]

         add
           (local_affected_tasks,
            get_random_element (s.tasks).name,
            Copy (res).all);
      end loop;

      add_resource
        (s.resources,
         suppress_space (To_Unbounded_String ("resource_" & cpt'img)),
         0,
         0,
         1,
         get_random_element (s.processors).name,
         get_random_element (s.address_spaces).name,
         protocol,
         local_affected_tasks,
         resource_priority,
         automatic_assignment);

      range_end :=
        search_resource
          (s.resources,
           suppress_space (To_Unbounded_String ("resource_" & cpt'img)))
          .critical_sections
          .nb_entries;
      item := 0;
      loop
         add_one_task_dependency_resource
           (s.dependencies,
            search_task
              (s.tasks,
               search_resource
                 (s.resources,
                  suppress_space (To_Unbounded_String ("resource_" & cpt'img)))
                 .critical_sections
                 .entries
                 (item)
                 .item),
            search_resource
              (s.resources,
               suppress_space (To_Unbounded_String ("resource_" & cpt'img))));
         item := item + 1;

         exit when item >= range_end;
      end loop;

      if (protocol = priority_ceiling_protocol) or
        (protocol = immediate_priority_ceiling_protocol)
      then
         --Priority_Constrained_Resource_Ptr (Search_Resource
         --                                    (S.Resources,
         --                                   Suppress_Space
         --                                    (To_Unbounded_String
         --                                      ("resource_" &
         --                                     cpt'Img)))).
         --  ceiling_priority := 254;
         generic_resource_ptr
           (search_resource
              (s.resources,
               suppress_space (To_Unbounded_String ("resource_" & cpt'img))))
           .priority :=
           254;
      end if;

      cpt := cpt + 1;
   end add_resource_to_system;

   procedure add_resource_to_system
     (s                 : in out system;
      name              : in     Unbounded_String;
      n_dependent_tasks :        Integer)
   is
      local_affected_tasks : resource_accesses_table;
      res                  : critical_section;
      i                    : Integer;
      item                 : resource_accesses_range;
      range_end            : resource_accesses_range;
      name1                : Unbounded_String;
      name2                : Unbounded_String;
      resource_priority    : Integer := 10;

   begin
      i := 1;

      name1 := get_random_element (s.tasks).name;
      loop
         name2 := get_random_element (s.tasks).name;
         exit when name1 /= name2;
      end loop;
      for i in 1 .. n_dependent_tasks loop
         initialize (local_affected_tasks);
         res.task_begin := 0;
         res.task_end   := 1;
         add
           (local_affected_tasks,
            get_random_element (s.tasks).name,
            Copy (res).all);
      end loop;
      add_resource
        (s.resources,
         name,
         0,
         0,
         1,
         get_random_element (s.processors).name,
         get_random_element (s.address_spaces).name,
         restrained_random_resource_type,
         local_affected_tasks,
         resource_priority,
         automatic_assignment);

      range_end :=
        search_resource
          (s.resources,
           suppress_space (To_Unbounded_String ("resource_" & cpt'img)))
          .critical_sections
          .nb_entries;
      item := 0;
      loop
         add_one_task_dependency_resource
           (s.dependencies,
            search_task
              (s.tasks,
               search_resource
                 (s.resources,
                  suppress_space (To_Unbounded_String ("resource_" & cpt'img)))
                 .critical_sections
                 .entries
                 (item)
                 .item),
            search_resource
              (s.resources,
               suppress_space (To_Unbounded_String ("resource_" & cpt'img))));
         item := item + 1;
         exit when item >= range_end;
      end loop;

      cpt := cpt + 1;
   end add_resource_to_system;

   procedure add_multiple_resources_to_system
     (s : in out system;
      n :        Integer)
   is
   begin
      null;
   end add_multiple_resources_to_system;

   procedure add_resource_set_to_system
     (s                       : in out system;
      n_resources             : in     Integer;
      resource_sharing_factor : in     Float;
      critical_section_ratio  : in     Float := 0.0)

   is

      n_tasks : tasks_range :=
        get_number_of_task_from_processor
          (s.tasks,
           To_Unbounded_String ("processor1"));
      max_accessed_tasks : Integer :=
        Integer (Float'ceiling (Float (n_tasks) * resource_sharing_factor));
      max_all_sc : Integer := max_accessed_tasks * n_resources;
      type array_of_integer is array (1 .. 1500) of Integer;
      --type array_of_integer is array (1 .. Max_all_sc) of integer;
      affected_tasks_tab : array_of_integer;
      -- Resource_tab is an array where each element represents the number of
      -- of critical sections per resource
      resource_tab                   : array (1 .. n_resources) of Integer;
      k, h                           : Integer;
      n_critical_sections            : Integer;
      a_task_index, n_accessed_tasks : Integer;
      is_used                        : Boolean;
      critical_sections_tab          : array (1 .. 1500) of critical_section;
      --Critical_sections_tab              : array (1 .. Max_all_sc) of critical_section;
      length_a_cs                  : Integer;
      cs                           : critical_section;
      critical_section_ratio_final : Float;
      task_capacity                : Natural;
      a_resource_set               : resources_set;
      rt                           : resource_accesses_table;
      n_cs_of_a_resource           : Integer;
      a_task_name                  : Unbounded_String;
      rnd                          : Integer;
      function find_an_element
        (an_array    : in array_of_integer;
         element     : in Integer;
         start_index : in Integer;
         last_index  : in Integer) return Boolean
      is
         is_found : Boolean := False;
         k        : Integer;
      begin

         k := start_index;
         while (not is_found) and (k <= last_index) loop
            if an_array (k) = element then
               is_found := True;
            end if;
            k := k + 1;
         end loop;

         return is_found;

      end find_an_element;

   begin

      -- 2) Each resource Rj is accessed by a number of different functions
      --    randomly chosen from the set of functions.
      --    This number is randomly chosen in the range [2 , Resource_sharing_factor * N_tasks]
      --
      k                         := 0;
      affected_tasks_tab (1500) := 0;
      for i in 1 .. n_resources loop
         if max_accessed_tasks > 2 then
            n_accessed_tasks := random_integer (2, max_accessed_tasks);
         else
            n_accessed_tasks := 2;
         end if;
         h                := k + 1;
         resource_tab (i) := n_accessed_tasks;
         for j in 1 .. n_accessed_tasks loop
            is_used := True;
            while is_used loop
               a_task_index := random_integer (1, Integer (n_tasks));
               is_used      :=
                 find_an_element (affected_tasks_tab, a_task_index, h, k);
            end loop;
            k                      := k + 1;
            affected_tasks_tab (k) := a_task_index;
         end loop;
      end loop;

      n_critical_sections := k;

      -- 3) Each Task Task_i that accesses a given resource Rj,
      --    issues only a single request of Rj per a job
      --    with a critical section Length:
      --       • The length of each critical section CS executed by a Task Task_j , is set as follows:
      --              Length(CS) = Integer(Float'Ceiling(critical_section_ratio * float(capacity(Task_j)))
      --          If the critical section ratio = 0.0 then
      --                it will be chosen randomly from the set {0.1, 0.3, 0.5}
      --            else (i.e the critical section ratio is given by user)
      --                we use the given value
      --
      --       • CS.task_begin : randomly generated in the range [1, capacity(Task_j) – Length(CS) + 1 ]
      --       • CS.task_end = CS.task_begin + Length(CS) – 1
      --
      for i in 1 .. n_critical_sections loop

         if critical_section_ratio = 0.0 then
            -- The critical section ratio is chosen
            -- randomly from the set {0.1, 0.3, 0.5}
            rnd := random_integer (1, 3);
            if rnd = 1 then
               critical_section_ratio_final := 0.1;
            elsif rnd = 2 then
               critical_section_ratio_final := 0.3;
            else
               critical_section_ratio_final := 0.5;
            end if;

         else
            critical_section_ratio_final := critical_section_ratio;
         end if;

         task_capacity :=
           get
             (my_tasks  => s.tasks,
              task_name =>
                suppress_space
                  (To_Unbounded_String
                     ("Task" & Integer'image (affected_tasks_tab (i)))),
              param_name => capacity);

         length_a_cs :=
           Integer
             (Float'ceiling
                (critical_section_ratio_final * Float (task_capacity)));
	 Initialize (cs);
         cs.task_begin :=
           Natural (random_integer (1, task_capacity - length_a_cs + 1));
         cs.task_end := cs.task_begin + Natural (length_a_cs) - 1;
         critical_sections_tab (i) := cs;
      end loop;

      -- Assign to each resource its critical sections
      --
      for i in 1 .. n_resources loop

         n_cs_of_a_resource := resource_tab (i);

         initialize (rt);

         k := 0;
         for l in 1 .. i - 1 loop
            k := k + resource_tab (l);
         end loop;
         k := k + 1;

         for j in 1 .. n_cs_of_a_resource loop

            a_task_name :=
              suppress_space
                (To_Unbounded_String
                   ("Task" & Integer'image (affected_tasks_tab (k))));
            cs := critical_sections_tab (k);
            -- Add the computed critical_section_j to the table of
            -- critical sections of the Resource_i
            --
            add (rt, a_task_name, cs);
            k := k + 1;
         end loop;

         -- Add the resource Ri to the set of resources
         --
         add_resource
           (a_resource_set,
            suppress_space (To_Unbounded_String ("R" & i'img)),
            1,
            0,
            0,
            To_Unbounded_String ("processor1"),
            To_Unbounded_String ("addr1"),
            priority_ceiling_protocol,
            rt,
            0,
            automatic_assignment);
      end loop;

      -- Assign the resource set to the system
      --
      s.resources := a_resource_set;

   end add_resource_set_to_system;

   -- 3 --------= Messages_Set =--------

   procedure add_message_to_system (s : in out system) is
   begin

      add_message
        (s.messages,
         suppress_space (To_Unbounded_String ("message" & cpt'img)),
         1,
         0,
         0,
         0,
         no_user_defined_parameter,
         0,
         0);
      cpt := cpt + 1;
   end add_message_to_system;

   procedure add_message_to_system
     (s    : in out system;
      name : in     Unbounded_String)
   is
   begin

      add_message
        (s.messages,
         name,
         1,
         0,
         0,
         0,
         no_user_defined_parameter,
         0,
         0);
      cpt := cpt + 1;
   end add_message_to_system;

   procedure add_multiple_messages_to_system
     (s : in out system;
      n :        Integer)
   is
      i : Integer;

   begin

      i := 0;

      while (i < n) loop
         add_message_to_system (s);
         i := i + 1;
      end loop;
   end add_multiple_messages_to_system;

   -- 10 --------= Dependecies =--------

   procedure add_time_triggered_communication_dependency_to_system
     (s : in out system)
   is
      src, dest : generic_task_ptr;

   begin
      -- SR Src and Dest Tasks must be different
      src := get_random_element (s.tasks);
      loop
         dest := get_random_element (s.tasks);
         exit when src /= dest;
      end loop;

      add_one_task_dependency_time_triggered
        (s.dependencies,
         src,
         dest,
         sampled_timing);
   end add_time_triggered_communication_dependency_to_system;

   procedure add_dependency_to_system
     (s    : in out system;
      name : in     Unbounded_String)
   is
   begin
      null;
   end add_dependency_to_system;

   procedure add_multiple_dependencies_to_system
     (s : in out system;
      n :        Integer)
   is
   begin
      null;
   end add_multiple_dependencies_to_system;

   procedure add_multiple_mf_precedence_dependencies_to_system
     (s                  : in out system;
      number_precedences : in     Integer;
      number_groups      : in     Integer;
      sync_ratio         : in     Double)
   is

      use generic_task_group_set;
      use Generic_Task_List_Package;

      a, b, i, sync_number, max_precs : Integer;
      task_group_a, task_group_b      : generic_task_group_ptr;
      task_a, task_b                  : generic_task_ptr;

   begin
      -- Sync_Number: The first "sync_number" multiframes have the same
      --mf_period
      sync_number := Integer (Double (number_groups) * sync_ratio);  -- TODO:
      --Round
      --up or
      --down?*

      -- Only on group is synched
      if (sync_number <= 1 or number_groups = 1) then
         return;
      end if;

      max_precs :=
        get_no_deadlocks_precedences_number (s.task_groups, sync_number);

      i := 0;
      while (i < number_precedences and i < max_precs) loop
         loop
            loop
               a := random_integer (sync_number);
               b := random_integer (sync_number);
               --             a := Random_Integer(sync_number - 1);
               --             b := Random_Integer(a, sync_number);

               get_element_number
                 (s.task_groups,
                  task_group_a,
                  task_groups_range (a));
               get_element_number
                 (s.task_groups,
                  task_group_b,
                  task_groups_range (b));

               exit when (task_group_a.name /= task_group_b.name);
            end loop;

            task_a := get_random_element (task_group_a.task_list);
            task_b := get_random_element (task_group_b.task_list);

            exit when
              (is_unique_precedence_dependency
                 (s.dependencies,
                  task_a,
                  task_b) and
               no_precedence_dependency_deadlock
                 (s.dependencies,
                  task_a,
                  task_b));
         end loop;

         add_one_task_dependency_precedence
           (s.dependencies,
            search_task (s.tasks, task_a.name),
            search_task (s.tasks, task_b.name));

         i := i + 1;
      end loop;

   end add_multiple_mf_precedence_dependencies_to_system;

   -- 11 --------= Task_Groups_Set =--------

   procedure add_task_group_to_system
     (s               : in out system;
      task_group_type : in     task_groups_type)
   is

   begin

      add_task_group_to_system
        (s,
         suppress_space (To_Unbounded_String ("TaskGroup" & cpt'img)),
         task_group_type);

      cpt := cpt + 1;

   end add_task_group_to_system;

   procedure add_task_group_to_system
     (s               : in out system;
      name            : in     Unbounded_String;
      task_group_type : in     task_groups_type)
   is

   begin

      add_task_group (s.task_groups, name, task_group_type);

   end add_task_group_to_system;

   procedure add_multiple_task_groups_to_system
     (s               : in out system;
      n               :        Integer;
      task_group_type : in     task_groups_type)
   is

      i : Integer;

   begin

      i := 0;

      while (i < n) loop

         case task_group_type is
            when multiframe_type =>
               add_task_group_to_system (s, multiframe_type);
            when transaction_type =>
               add_task_group_to_system (s, transaction_type);
            when others =>
               null;
         end case;

         i := i + 1;
      end loop;

   end add_multiple_task_groups_to_system;

   -- 1 --------= Core_Units_Set =--------

   procedure add_core_unit_to_system (s : in out system) is
      mem : memories_table;
   begin

      add_core_unit
        (s.core_units,
         suppress_space (To_Unbounded_String ("core_unit" & cpt'img)),
         preemptive,
         0,
         0,
         0,
         0,
         0,
         empty_string,
         empty_string,
         earliest_deadline_first_protocol,
         mem);
      cpt := cpt + 1;

   end add_core_unit_to_system;

   procedure add_core_unit_to_system
     (s     : in out system;
      sched : in     schedulers_type)
   is
      mem : memories_table;
   begin

      add_core_unit
        (s.core_units,
         suppress_space (To_Unbounded_String ("core_unit" & cpt'img)),
         preemptive,
         0,
         1,
         0,
         0,
         0,
         empty_string,
         empty_string,
         sched,
         mem);
      cpt := cpt + 1;

   end add_core_unit_to_system;

   procedure add_core_unit_to_system
     (s    : in out system;
      name : in     Unbounded_String)
   is
      mem : memories_table;
   begin
      add_core_unit
        (s.core_units,
         name,
         preemptive,
         0,
         0,
         0,
         0,
         0,
         empty_string,
         empty_string,
         earliest_deadline_first_protocol,
         mem);
      cpt := cpt + 1;
   end add_core_unit_to_system;

   procedure add_core_unit_to_system
     (s                       : in out system;
      a_multi_cores_processor : in     multi_cores_processor_ptr;
      sched                   : in     schedulers_type;
      preempt                 : in     preemptives_type)
   is

      a_core_unit    : core_unit_ptr;
      name_core_unit : Unbounded_String;
      mem            : memories_table;

   begin

      name_core_unit :=
        suppress_space (To_Unbounded_String ("core_unit" & cpt'img));
      add_core_unit
        (s.core_units,
         a_core_unit,
         name_core_unit,
         preempt,
         0,
         1,
         0,
         0,
         0,
         empty_string,
         empty_string,
         sched,
         mem);

      --        Put_Line ("after adding core unit to system");
      --        Put (Sched'Img);

      add
        (a_multi_cores_processor.all.cores,
         search_core_unit (s.core_units, name_core_unit));
      --        Put(Search_core_unit (S.Core_units, name_core_unit));
      --        Put_Line ("after adding core unit to processor");
      cpt := cpt + 1;

   end add_core_unit_to_system;

   -- 2 --------= Processors_Set =--------
   -- SR to obtain the id fo the new CPU
--procedure Add_Mono_Core_Processor_To_System
--  (S            : in out System;
--  Id_Cpu       : in out Unbounded_String;
-- Preemptivity : in Preemptives_Type;
--   Sched        : in Schedulers_Type)
-- is
--     Id_Cpt   : Integer;
--   begin
--      Id_Cpt := Cpt + 1;
--      Id_Cpu := suppress_space (To_Unbounded_String ("cpu" & Id_Cpt'Img)) ;
--      Add_Mono_Core_Processor_To_System (S, Preemptivity,  Sched );
--   end Add_Mono_Core_Processor_To_System;

   procedure add_mono_core_processor_to_system
     (s            : in out system;
      preemptivity : in     preemptives_type;
      sched        : in     schedulers_type)
   is
      obj            : mono_core_processor_ptr;
      a_core_unit    : core_unit_ptr;
      name_core_unit : Unbounded_String;
      mem            : memories_table;
   begin

      name_core_unit :=
        suppress_space (To_Unbounded_String ("core_unit" & cpt'img));
      add_core_unit
        (s.core_units,
         a_core_unit,
         name_core_unit,
         preemptivity,
         0,
         0,
         0,
         0,
         0,
         empty_string,
         empty_string,
         sched,
         mem);

      --        Put_Line ("after adding core unit to system");
      --        Put (Sched'Img);
      obj          := new mono_core_processor;
      obj.all.core := search_core_unit (s.core_units, name_core_unit);
      --        Put(Search_core_unit (S.Core_units, name_core_unit));
      --        Put_Line ("after adding core unit to processor");
      cpt := cpt + 1;
      add_processor
        (s.processors,
         suppress_space (To_Unbounded_String ("cpu" & cpt'img)),
         a_core_unit);
      cpt := cpt + 1;
   end add_mono_core_processor_to_system;

   procedure add_mono_core_processor_to_system
     (s            : in out system;
      preemptivity : in     preemptives_type;
      sched        : in     schedulers_type;
      core         :        core_unit_ptr)
   is
      obj : mono_core_processor_ptr;
   -- SR obj2 : Core_Unit_Ptr;
   begin

      obj := new mono_core_processor;
      -- SR Core parameter seems to be unused... remove Add_Core
      -- obj.all.core := Core;
      -- cpt          := cpt + 1;
      --Add_core_unit
      --  (S.Core_units,
      --   obj2,
      --   suppress_space (To_Unbounded_String ("core" & cpt'Img)),
      --   Preemptivity,
      --   0,
      --   0.0,
      --   1,
      --   1,
      --   0,
      --   empty_string,
      --   Sched,
      --   empty_string);
      add_processor
        (s.processors,
         generic_processor_ptr (obj),
         suppress_space (To_Unbounded_String ("core" & cpt'img)),
         core);                         -- SR previously obj2;
      cpt := cpt + 1;
   end add_mono_core_processor_to_system;

   procedure add_mono_core_processor_to_system
     (s            : in out system;
      name         : in     Unbounded_String;
      preemptivity : in     preemptives_type;
      sched        : in     schedulers_type)
   is
      obj : mono_core_processor_ptr;
      mem : memories_table;
   begin

      add_core_unit
        (s.core_units,
         suppress_space (To_Unbounded_String ("core_unit" & cpt'img)),
         preemptive,
         0,
         0,
         0,
         0,
         0,
         empty_string,
         empty_string,
         sched,
         mem);

      -- SR    cpt := cpt + 1;
      add_processor
        (s.processors,
         generic_processor_ptr (obj),
         name,
         search_core_unit
           (s.core_units,
            suppress_space (To_Unbounded_String ("core_unit" & cpt'img))));

   end add_mono_core_processor_to_system;

   procedure add_multiple_mono_core_processors_to_system
     (s : in out system;
      n :        Integer)
   is

      i : Integer;

   begin

      i := 0;

      while (i < n) loop
         add_mono_core_processor_to_system
           (s,
            To_Unbounded_String ("cpu" & i'img),
            random_preemptivity,
            random_scheduler);
         i := i + 1;
      end loop;

   end add_multiple_mono_core_processors_to_system;

   procedure add_multi_cores_processor_to_system
     (s                 : in out system;
      number_core_units : in     Integer;
      preemptivity      : in     preemptives_type;
      sched             : in     schedulers_type)
   is

      a_core_unit        : core_unit_ptr;
      name_core_unit     : Unbounded_String;
      a_core_units_table : core_units_table;
      i                  : Integer;
      mem                : memories_table;

   begin

      if (number_core_units > 1) then
         i := 0;
         while (i < number_core_units) loop
            name_core_unit :=
              suppress_space (To_Unbounded_String ("core_unit_" & cpt'img));

            add_core_unit
              (s.core_units,
               a_core_unit,
               name_core_unit,
               preemptivity,
               0,
               1,
               0,
               0,
               0,
               empty_string,
               empty_string,
               sched,
               mem);

            add (a_core_units_table, a_core_unit);

            cpt := cpt + 1;
            i   := i + 1;
         end loop;
      end if;

      add_processor
        (s.processors,
         To_Unbounded_String ("cpu" & cpt'img),
         a_core_units_table);

      cpt := cpt + 1;

   end add_multi_cores_processor_to_system;

   procedure add_multiple_processors_to_system
     (s                               : in out system;
      number_processors               : in     Integer;
      number_core_units_per_processor : in     Integer;
      sched                           : in     schedulers_type;
      preempt                         : in     preemptives_type)
   is

      i : Integer;

   begin

      if (number_core_units_per_processor = 1) then -- Only monocores
         i := 0;
         while (i < number_processors) loop
            add_mono_core_processor_to_system (s, preempt, sched);
            i := i + 1;
         end loop;
      else
         i := 0;
         while (i < number_processors) loop
            add_multi_cores_processor_to_system
              (s,
               number_core_units_per_processor,
               preempt,
               sched);
            i := i + 1;
         end loop;
      end if;

   end add_multiple_processors_to_system;

   -- 7 --------= Buffers_Set =--------

   procedure add_buffer_to_system (s : in out system) is
      addr_name : Unbounded_String;
   begin
      addr_name := get_random_element (s.address_spaces).name;
      add_buffer_to_system
        (s,
         search_address_space (s.address_spaces, addr_name).cpu_name,
         addr_name);

   end add_buffer_to_system;

   procedure add_buffer_to_system
     (s                  : in out system;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String)
   is
      roles : buffer_roles_table;
   begin
      initialize (roles);
      add_buffer
        (s.buffers,
         suppress_space (To_Unbounded_String ("buffer" & cpt'img)),
         5,
         cpu_name,
         address_space_name,
         qs_pp1,
         roles);
      cpt := cpt + 1;
   end add_buffer_to_system;

   procedure add_buffer_to_system
     (s                  : in out system;
      name               : in     Unbounded_String;
      cpu_name           : in     Unbounded_String;
      address_space_name : in     Unbounded_String)
   is
      roles : buffer_roles_table;
   begin
      initialize (roles);
      add_buffer
        (s.buffers,
         name,
         1,
         cpu_name,
         address_space_name,
         qs_pp1,
         roles);
      cpt := cpt + 1;
   end add_buffer_to_system;

   procedure add_multiple_buffers_to_system (s : in out system; n : Integer) is
      i : Integer;

   begin

      i := 0;

      while (i < n) loop
         add_buffer_to_system (s);
         i := i + 1;
      end loop;
   end add_multiple_buffers_to_system;

   -- 4 --------= Networks_Set =--------

   -- 5 --------= Event_Analyzers_Set =--------

   -- 6 --------= Address_Spaces_Set =--------

   procedure add_address_space_to_system
     (s        : in out system;
      cpu_name :        Unbounded_String)
   is
   begin
      add_address_space
        (s.address_spaces,
         suppress_space (To_Unbounded_String ("addr" & cpt'img)),
         cpu_name,
         0,
         0,
         0,
         0);
      cpt := cpt + 1;
   end add_address_space_to_system;

   procedure add_address_space_to_system
     (s        : in out system;
      name     : in     Unbounded_String;
      cpu_name :        Unbounded_String)
   is
   begin
      add_address_space (s.address_spaces, name, cpu_name, 0, 0, 0, 0);
      cpt := cpt + 1;
   end add_address_space_to_system;

   procedure add_multiple_address_spaces_to_system
     (s : in out system;
      n :        Integer)
   is

      i : Integer;

   begin

      i := 0;

      while (i < n) loop
         add_address_space_to_system
           (s,
            get_random_element (s.processors).name);
         i := i + 1;
      end loop;
   end add_multiple_address_spaces_to_system;

   procedure add_multiple_address_spaces_consistently_to_system
     (s                     : in out system;
      number_processors     : in     Integer;
      number_address_spaces : in     Integer)
   is

      processor_iterator : processors_iterator;
      a_processor        : generic_processor_ptr;

      address_spaces_left : Integer;

   begin

      -- Add at least an ADDR to each CPU
      reset_iterator (s.processors, processor_iterator);
      loop
         current_element (s.processors, a_processor, processor_iterator);
         add_address_space_to_system (s, a_processor.name);
         exit when is_last_element (s.processors, processor_iterator);
         next_element (s.processors, processor_iterator);
      end loop;

      -- Fill remaining ADDRs randomly if there are more ADDRs than CPUs
      address_spaces_left := number_address_spaces - number_processors;
      while (address_spaces_left > 0) loop
         add_address_space_to_system
           (s,
            get_random_element (s.processors).name);
         address_spaces_left := address_spaces_left - 1;
      end loop;

   end add_multiple_address_spaces_consistently_to_system;

   -- X --------= Random Functionnalities =--------

   function random_preemptivity return preemptives_type is
      type preempt_range is range 0 .. 1;
      package rand is new Ada.Numerics.Discrete_Random (preempt_range);
      use rand;
      p : preempt_range;
      g : generator;
   begin
      Reset (g);
      p := Random (g);
      case p is
         when preempt_range (0) =>
            return preemptive;
         when others =>
            return not_preemptive;
      end case;
   end random_preemptivity;

   function random_scheduler return schedulers_type is
      type sched_range is range 0 .. 22;
      package rand is new Ada.Numerics.Discrete_Random (sched_range);
      use rand;
      p : sched_range;
      g : generator;
   begin
      Reset (g);
      p := Random (g);
      case p is
         when sched_range (0) =>
            return compiled_user_defined_protocol;
         when sched_range (1) =>
            return automata_user_defined_protocol;
         when sched_range (2) =>
            return pipeline_user_defined_protocol;
         when sched_range (3) =>
            return user_defined_protocol;
         when sched_range (4) =>
            return earliest_deadline_first_protocol;
         when sched_range (5) =>
            return least_laxity_first_protocol;
         when sched_range (6) =>
            return rate_monotonic_protocol;
         when sched_range (7) =>
            return deadline_monotonic_protocol;
         when sched_range (8) =>
            return round_robin_protocol;
         when sched_range (9) =>
            return time_sharing_based_on_wait_time_protocol;
         when sched_range (10) =>
            return posix_1003_highest_priority_first_protocol;
         when sched_range (11) =>
            return d_over_protocol;
         when sched_range (12) =>
            return maximum_urgency_first_based_on_laxity_protocol;
         when sched_range (13) =>
            return maximum_urgency_first_based_on_deadline_protocol;
         when sched_range (14) =>
            return time_sharing_based_on_cpu_usage_protocol;
         when sched_range (15) =>
            return no_scheduling_protocol;
         when sched_range (16) =>
            return hierarchical_cyclic_protocol;
         when sched_range (17) =>
            return hierarchical_round_robin_protocol;
         when sched_range (18) =>
            return hierarchical_fixed_priority_protocol;
         when sched_range (19) =>
            return hierarchical_polling_aperiodic_server_protocol;
         when sched_range (20) =>
            return hierarchical_priority_exchange_aperiodic_server_protocol;
         when sched_range (21) =>
            return hierarchical_sporadic_aperiodic_server_protocol;
         when others =>
            return hierarchical_deferrable_aperiodic_server_protocol;
      end case;
   end random_scheduler;

   function restrained_random_scheduler return schedulers_type is
      type sched_range is range 0 .. 3;
      package rand is new Ada.Numerics.Discrete_Random (sched_range);
      use rand;
      p : sched_range;
      g : generator;
   begin
      Reset (g);
      p := Random (g);
      case p is
         when sched_range (0) =>
            return earliest_deadline_first_protocol;
         when sched_range (1) =>
            return rate_monotonic_protocol;
         when sched_range (2) =>
            return deadline_monotonic_protocol;
         when others =>
            return posix_1003_highest_priority_first_protocol;
      end case;
   end restrained_random_scheduler;

   function random_dependency_type return dependency_type is
      type depend_range is range 0 .. 4;
      package rand is new Ada.Numerics.Discrete_Random (depend_range);
      use rand;
      p : depend_range;
      g : generator;
   begin
      Reset (g);
      p := Random (g);
      case p is
         when depend_range (0) =>
            return precedence_dependency;
         when depend_range (1) =>
            return queueing_buffer_dependency;
         when depend_range (2) =>
            return asynchronous_communication_dependency;
         when depend_range (3) =>
            return time_triggered_communication_dependency;
         when others =>
            return resource_dependency;
      end case;
   end random_dependency_type;

   function random_resource_type return resources_type is
      type resource_range is range 0 .. 3;
      package rand is new Ada.Numerics.Discrete_Random (resource_range);
      use rand;
      p : resource_range;
      g : generator;
   begin
      Reset (g);
      p := Random (g);
      case p is
         when resource_range (0) =>
            return no_protocol;
         when resource_range (1) =>
            return priority_ceiling_protocol;
         when resource_range (2) =>
            return priority_inheritance_protocol;
         when others =>
            return immediate_priority_ceiling_protocol;
      end case;
   end random_resource_type;

   function restrained_random_resource_type return resources_type is
      use rand_res;
      p : resource_range;
      g : generator;
   begin
      Reset (g_res);
      p := Random (g_res);
      case p is
         when resource_range (0) =>
            return priority_ceiling_protocol;
         when resource_range (1) =>
            return priority_inheritance_protocol;
         when others =>
            return immediate_priority_ceiling_protocol;
      end case;
   end restrained_random_resource_type;

   function random_task_type return tasks_type is
      type task_range is range 0 .. 4;
      package rand is new Ada.Numerics.Discrete_Random (task_range);
      use rand;
      p : task_range;
      g : generator;
   begin
      Reset (g);
      p := Random (g);
      case p is
         when task_range (0) =>
            return periodic_type;
         when task_range (1) =>
            return aperiodic_type;
         when task_range (2) =>
            return sporadic_type;
         when task_range (3) =>
            return poisson_type;
         when others =>
            return parametric_type;
      end case;
   end random_task_type;

   function random_integer (n : Integer) return Integer is
      use rand_int;
      p : int_range;
   begin
      p := Random (g_int);
      return Integer (p) mod n;
   end random_integer;

   function random_integer (n1 : Integer; n2 : Integer) return Integer is
      use rand_int;
      n : Integer;
      p : int_range;
   begin
      if (n1 = n2) then
         return n1;
      end if;

      p := Random (g_int);

      if (n1 > n2) then
         n := n1 - n2;
         return (Integer (p) mod n) + n2;
      end if;

      n := n2 - n1;

      return (Integer (p) mod n) + n1;
   end random_integer;

   procedure compliant_time_triggered_communication (sys : out system) is
      a_core            : core_unit_ptr;
      a_core_unit_table : core_units_table;
      mem               : memories_table;

   begin

      initialize (sys);
      add_core_unit
        (sys.core_units,
         a_core,
         To_Unbounded_String ("core1"),
         preemptive,
         0,
         1,
         101,
         102,
         103,
         To_Unbounded_String (""),
         To_Unbounded_String (""),
         rate_monotonic_protocol,
         mem);
      add (a_core_unit_table, a_core);

      add_processor
        (sys.processors,
         To_Unbounded_String ("processor1"),
         a_core_unit_table);

      add_address_space
        (sys.address_spaces,
         To_Unbounded_String ("addr1"),
         To_Unbounded_String ("processor1"),
         0,
         0,
         0,
         0);

      add_task
        (sys.tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         2,
         4,
         4,
         0,
         10,
         1,
         0,
         sched_fifo);
      add_task
        (sys.tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         3,
         5,
         5,
         0,
         10,
         2,
         0,
         sched_fifo);
      add_task
        (sys.tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         7,
         20,
         20,
         0,
         10,
         3,
         0,
         sched_fifo);

      add_one_task_dependency_time_triggered
        (sys.dependencies,
         search_task (sys.tasks, To_Unbounded_String ("T1")),
         search_task (sys.tasks, To_Unbounded_String ("T2")),
         sampled_timing);
      add_one_task_dependency_time_triggered
        (sys.dependencies,
         search_task (sys.tasks, To_Unbounded_String ("T2")),
         search_task (sys.tasks, To_Unbounded_String ("T3")),
         sampled_timing);

   end compliant_time_triggered_communication;

   procedure uncompliant_time_triggered_communication (sys : out system) is
      a_core            : core_unit_ptr;
      a_core_unit_table : core_units_table;
      mem               : memories_table;
   begin

      initialize (sys);
      add_core_unit
        (sys.core_units,
         a_core,
         To_Unbounded_String ("core1"),
         preemptive,
         0,
         1,
         101,
         102,
         103,
         To_Unbounded_String (""),
         To_Unbounded_String (""),
         rate_monotonic_protocol,
         mem);
      add (a_core_unit_table, a_core);

      add_processor
        (sys.processors,
         To_Unbounded_String ("processor1"),
         a_core_unit_table);

      add_address_space
        (sys.address_spaces,
         To_Unbounded_String ("addr1"),
         To_Unbounded_String ("processor1"),
         0,
         0,
         0,
         0);

      add_task
        (sys.tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         sporadic_type,
         0,
         2,
         4,
         4,
         0,
         10,
         1,
         0,
         sched_fifo);
      add_task
        (sys.tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         3,
         5,
         5,
         0,
         10,
         2,
         0,
         sched_fifo);
      add_task
        (sys.tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         7,
         20,
         20,
         0,
         10,
         3,
         0,
         sched_fifo);

      add_one_task_dependency_time_triggered
        (sys.dependencies,
         search_task (sys.tasks, To_Unbounded_String ("T1")),
         search_task (sys.tasks, To_Unbounded_String ("T2")),
         sampled_timing);
      add_one_task_dependency_time_triggered
        (sys.dependencies,
         search_task (sys.tasks, To_Unbounded_String ("T2")),
         search_task (sys.tasks, To_Unbounded_String ("T3")),
         sampled_timing);
   end uncompliant_time_triggered_communication;

   procedure compliant_unplugged (sys : out system) is
      a_core            : core_unit_ptr;
      a_core_unit_table : core_units_table;
      mem               : memories_table;

   begin

      initialize (sys);
      add_core_unit
        (sys.core_units,
         a_core,
         To_Unbounded_String ("core1"),
         preemptive,
         0,
         1,
         101,
         102,
         103,
         To_Unbounded_String (""),
         To_Unbounded_String (""),
         earliest_deadline_first_protocol,
         mem);
      add (a_core_unit_table, a_core);

      add_processor
        (sys.processors,
         To_Unbounded_String ("processor1"),
         a_core_unit_table);

      add_address_space
        (sys.address_spaces,
         To_Unbounded_String ("addr1"),
         To_Unbounded_String ("processor1"),
         0,
         0,
         0,
         0);

      add_task
        (sys.tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         2,
         4,
         4,
         0,
         10,
         1,
         0,
         sched_fifo);
      add_task
        (sys.tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         3,
         5,
         5,
         0,
         10,
         2,
         0,
         sched_fifo);
      add_task
        (sys.tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         7,
         20,
         20,
         0,
         10,
         3,
         0,
         sched_fifo);

   end compliant_unplugged;

   procedure uncompliant_unplugged (sys : out system) is
      a_core            : core_unit_ptr;
      a_core_unit_table : core_units_table;
      mem               : memories_table;

   begin

      initialize (sys);
      add_core_unit
        (sys.core_units,
         a_core,
         To_Unbounded_String ("core1"),
         preemptive,
         0,
         1,
         101,
         102,
         103,
         To_Unbounded_String (""),
         To_Unbounded_String (""),
         earliest_deadline_first_protocol,
         mem);
      add (a_core_unit_table, a_core);

      add_processor
        (sys.processors,
         To_Unbounded_String ("processor1"),
         a_core);

      add_address_space
        (sys.address_spaces,
         To_Unbounded_String ("addr1"),
         To_Unbounded_String ("processor1"),
         0,
         0,
         0,
         0);

      add_task
        (sys.tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         2,
         4,
         4,
         0,
         10,
         1,
         0,
         sched_fifo);
      add_task
        (sys.tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         3,
         5,
         5,
         0,
         10,
         2,
         0,
         sched_fifo);
      add_task
        (sys.tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         7,
         20,
         20,
         0,
         10,
         3,
         0,
         sched_fifo);
      add_task
        (sys.tasks,
         To_Unbounded_String ("A"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         aperiodic_type,
         4,
         3,
         0,
         20,
         0,
         0,
         3,
         0,
         sched_fifo);

   end uncompliant_unplugged;

   procedure compliant_ravenscar (sys : out system) is
      a_core            : core_unit_ptr;
      a_core_unit_table : core_units_table;
      rt                : resource_accesses_table;
      r                 : critical_section;
      item              : resource_accesses_range;
      range_end         : resource_accesses_range;

      re_pr1 : Integer := 10; -- for resource priority
      mem    : memories_table;

   begin

      initialize (sys);
      add_core_unit
        (sys.core_units,
         a_core,
         To_Unbounded_String ("core1"),
         preemptive,
         0,
         1,
         101,
         102,
         103,
         To_Unbounded_String (""),
         To_Unbounded_String (""),
         posix_1003_highest_priority_first_protocol,
         mem);
      add (a_core_unit_table, a_core);

      add_processor
        (sys.processors,
         To_Unbounded_String ("processor1"),
         a_core_unit_table);

      add_address_space
        (sys.address_spaces,
         To_Unbounded_String ("addr1"),
         To_Unbounded_String ("processor1"),
         0,
         0,
         0,
         0);

      add_task
        (sys.tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         2,
         4,
         4,
         0,
         10,
         1,
         0,
         sched_fifo);
      add_task
        (sys.tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         3,
         5,
         5,
         0,
         10,
         2,
         0,
         sched_fifo);
      add_task
        (sys.tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         7,
         20,
         20,
         0,
         10,
         3,
         0,
         sched_fifo);

      r.task_begin := 1;
      r.task_end   := 1;
      add (rt, To_Unbounded_String ("T1"), r);
      add (rt, To_Unbounded_String ("T2"), r);

      add_resource
        (sys.resources,
         To_Unbounded_String ("R1"),
         1,
         0,
         0,
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         priority_inheritance_protocol,
         rt,
         re_pr1,
         automatic_assignment);

      range_end :=
        search_resource
          (sys.resources,
           suppress_space (To_Unbounded_String ("R1")))
          .critical_sections
          .nb_entries;
      item := 0;
      loop
         add_one_task_dependency_resource
           (sys.dependencies,
            search_task
              (sys.tasks,
               search_resource
                 (sys.resources,
                  suppress_space (To_Unbounded_String ("R1")))
                 .critical_sections
                 .entries
                 (item)
                 .item),
            search_resource
              (sys.resources,
               suppress_space (To_Unbounded_String ("R1"))));
         item := item + 1;
         exit when item >= range_end;
      end loop;

   end compliant_ravenscar;

   procedure uncompliant_ravenscar (sys : out system) is
      a_core            : core_unit_ptr;
      a_core_unit_table : core_units_table;
      rt                : resource_accesses_table;
      r                 : critical_section;
      item              : resource_accesses_range;
      range_end         : resource_accesses_range;

      --re_pr1   : integer; -- for resource_priority
      mem : memories_table;

   begin

      initialize (sys);
      add_core_unit
        (sys.core_units,
         a_core,
         To_Unbounded_String ("core1"),
         preemptive,
         0,
         1,
         101,
         102,
         103,
         To_Unbounded_String (""),
         To_Unbounded_String (""),
         posix_1003_highest_priority_first_protocol,
         mem);
      add (a_core_unit_table, a_core);

      add_processor
        (sys.processors,
         To_Unbounded_String ("processor1"),
         a_core_unit_table);

      add_address_space
        (sys.address_spaces,
         To_Unbounded_String ("addr1"),
         To_Unbounded_String ("processor1"),
         0,
         0,
         0,
         0);

      add_task
        (sys.tasks,
         To_Unbounded_String ("T1"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         2,
         4,
         4,
         0,
         10,
         1,
         0,
         sched_fifo);
      add_task
        (sys.tasks,
         To_Unbounded_String ("T2"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         3,
         5,
         5,
         0,
         10,
         2,
         0,
         sched_fifo);
      add_task
        (sys.tasks,
         To_Unbounded_String ("T3"),
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         To_Unbounded_String (""),
         periodic_type,
         0,
         7,
         20,
         20,
         0,
         10,
         3,
         0,
         sched_fifo);

      r.task_begin := 1;
      r.task_end   := 1;
      add (rt, To_Unbounded_String ("T1"), r);
      add (rt, To_Unbounded_String ("T2"), r);

      add_resource
        (sys.resources,
         To_Unbounded_String ("R1"),
         1,
         0,
         0,
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         no_protocol,
         rt,
         1,
         automatic_assignment);

      range_end :=
        search_resource
          (sys.resources,
           suppress_space (To_Unbounded_String ("R1")))
          .critical_sections
          .nb_entries;
      item := 0;
      loop
         add_one_task_dependency_resource
           (sys.dependencies,
            search_task
              (sys.tasks,
               search_resource
                 (sys.resources,
                  suppress_space (To_Unbounded_String ("R1")))
                 .critical_sections
                 .entries
                 (item)
                 .item),
            search_resource
              (sys.resources,
               suppress_space (To_Unbounded_String ("R1"))));
         item := item + 1;
         exit when item >= range_end;
      end loop;

   end uncompliant_ravenscar;

   procedure uncompliant_buffer (sys : out system) is
      a_core                 : core_unit_ptr;
      a_core_unit_table      : core_units_table;
      bt                     : buffer_roles_table;
      b                      : buffer_role;
      t1_ref, t2_ref, t3_ref : generic_task_ptr;
      mem                    : memories_table;
   begin

      initialize (sys);
      add_core_unit
        (sys.core_units,
         a_core,
         To_Unbounded_String ("core1"),
         preemptive,
         0,
         1,
         101,
         102,
         103,
         To_Unbounded_String (""),
         To_Unbounded_String (""),
         posix_1003_highest_priority_first_protocol,
         mem);
      add (a_core_unit_table, a_core);

      add_processor
        (sys.processors,
         To_Unbounded_String ("processor1"),
         a_core_unit_table);

      add_address_space
        (sys.address_spaces,
         To_Unbounded_String ("addr1"),
         To_Unbounded_String ("processor1"),
         0,
         0,
         0,
         0);

      add_task
        (my_tasks           => sys.tasks,
         a_task             => t1_ref,
         name               => To_Unbounded_String ("T1"),
         cpu_name           => To_Unbounded_String ("processor1"),
         address_space_name => To_Unbounded_String ("addr1"),
         core_name          => empty_string,
         task_type          => periodic_type,
         start_time         => 0,
         capacity           => 1,
         period             => 2,
         deadline           => 2,
         jitter             => 0,
         blocking_time      => 0,
         priority           => 1,
         criticality        => 0,
         policy             => sched_fifo);

      add_task
        (my_tasks           => sys.tasks,
         a_task             => t2_ref,
         name               => To_Unbounded_String ("T2"),
         cpu_name           => To_Unbounded_String ("processor1"),
         address_space_name => To_Unbounded_String ("addr1"),
         core_name          => empty_string,
         task_type          => periodic_type,
         start_time         => 0,
         capacity           => 1,
         period             => 3,
         deadline           => 3,
         jitter             => 0,
         blocking_time      => 0,
         priority           => 2,
         criticality        => 0,
         policy             => sched_fifo);

      add_task
        (my_tasks           => sys.tasks,
         a_task             => t3_ref,
         name               => To_Unbounded_String ("T3"),
         cpu_name           => To_Unbounded_String ("processor1"),
         address_space_name => To_Unbounded_String ("addr1"),
         core_name          => empty_string,
         task_type          => periodic_type,
         start_time         => 0,
         capacity           => 2,
         period             => 9,
         deadline           => 9,
         jitter             => 0,
         blocking_time      => 0,
         priority           => 1,
         criticality        => 0,
         policy             => sched_fifo);

      b.the_role := queuing_producer;
      b.size     := 1;
      b.time     := 1;
      add (bt, To_Unbounded_String ("T1"), b);
      b.the_role := queuing_consumer;
      b.size     := 2;
      b.time     := 2;
      add (bt, To_Unbounded_String ("T2"), b);

      add_buffer
        (sys.buffers,
         To_Unbounded_String ("B1"),
         1,
         To_Unbounded_String ("processor1"),
         To_Unbounded_String ("addr1"),
         qs_mm1,
         bt);

      add_one_task_dependency_time_triggered
        (sys.dependencies,
         search_task (sys.tasks, To_Unbounded_String ("T1")),
         search_task (sys.tasks, To_Unbounded_String ("T2")),
         sampled_timing);
      add_one_task_dependency_time_triggered
        (sys.dependencies,
         search_task (sys.tasks, To_Unbounded_String ("T2")),
         search_task (sys.tasks, To_Unbounded_String ("T3")),
         sampled_timing);

      Put_Line (To_String (xml_string (sys, 0)));

   end uncompliant_buffer;

   procedure add_multiple_periodic_tasks_to_set_uunifast
     (my_tasks : in out tasks_set;
      n        : in     Integer;
      u        : in     Float)
   is
      use Ada.Float_Text_IO;
      i          : Integer;
      capacity   : Integer := 0;
      period     : Integer := 0;
      deadline   : Integer := 0;
      start_time : Integer := 0;

      a_offset   : offset_type;
      offset_t_a : offsets_table;

      u_array : random_tools.float_array (0 .. n - 1);
      flag    : Boolean := True;
   begin
      i := 0;
      while (flag) loop
         u_array := gen_uunifast (n => n, u => u);

         flag := False;

         for i in 0 .. n - 1 loop
            if (u_array (i) < 0.03) then
               flag := True;
            end if;
         end loop;
      end loop;

      while (i < n) loop

         Initialize (a_offset);
         initialize (offset_t_a);

         capacity := 0;
         period   := 0;
         deadline := 0;

         while (capacity <= 0 or period <= 0 or a_offset.offset_value <= 0)
         loop
            capacity   := random_integer (n1 => 10, n2 => 15);
            period := Integer (Float'ceiling (Float (capacity) / u_array (i)));
            start_time := random_integer (n1 => 1, n2 => 30);
            deadline   := period;
         end loop;

         add_task
           (my_tasks           => my_tasks,
            name => suppress_space (To_Unbounded_String ("Task" & i'img)),
            cpu_name           => To_Unbounded_String ("processor1"),
            address_space_name => To_Unbounded_String ("addr1"),
            core_name          => empty_string,
            task_type          => periodic_type,
            start_time         => start_time,
            capacity           => capacity,
            period             => period,
            deadline           => deadline,
            jitter             => 0,
            blocking_time      => 0,
            priority           => 1,
            criticality        => 0,
            policy             => sched_fifo);
         i := i + 1;
      end loop;

   end add_multiple_periodic_tasks_to_set_uunifast;

   procedure add_multiple_periodic_tasks_harmonic_with_direct_mapped_instruction_cache_utilization_to_set_uunifast
     (my_tasks                 : in out tasks_set;
      n                        : in     Integer;
      pu                       : in     Float;
      cu                       : in     Float;
      cs                       : in     Integer;
      rf                       : in     Float;
      my_instruction_cache     : in     instruction_cache_ptr;
      my_cache_access_profiles :    out cache_access_profiles_set)
   is
      use Ada.Float_Text_IO;
      i          : Integer;
      capacity   : Integer := 0;
      period     : Integer := 0;
      deadline   : Integer := 0;
      start_time : Integer := 0;

      pu_array               : random_tools.float_array (0 .. n - 1);
      flag                   : Boolean := True;
      a_task                 : generic_task_ptr;
      a_cache_access_profile : cache_access_profile_ptr;
      ------------------------------------------
      cu_array : random_tools.float_array (0 .. n - 1);

      start_set : Integer := 0;
      end_set   : Integer := 0;
      ecb       : Integer := 0;
      ucb       : Integer := 0;

      ucb_counter : Integer := 0;

      periods : array (0 .. 6) of Integer :=
        (1250, 2500, 3125, 6250, 12500, 15625, 31250);
   --Periods : array (0..6) of Integer := (10,15,20,30,40,60,120);
   begin
      set_initialize;
      i := 0;

      --GENERATE PROCESSOR UTILIZATION
      pu_array := gen_uunifast (n => n, u => pu);
      --GENERATE CACHE UTILIZATION
      cu_array := gen_uunifast (n => n, u => cu);

      while (i < n) loop
         capacity := 0;
         period   := 0;
         deadline := 0;

         start_time := random_integer (n1 => 1, n2 => 50) * 10;

         --start_time:= Random_Integer(n1 => 1, n2 => 20);

         period := periods (random_integer (n1 => 0, n2 => 6));

         deadline := period;
         capacity := Integer (Float'floor (Float (period) * pu_array (i)));

         if (capacity <= 0) then
            capacity := 1;
         end if;

         a_cache_access_profile      := new cache_access_profile;
         a_cache_access_profile.name :=
           suppress_space (To_Unbounded_String ("CAP_" & i'img));
         ----------------------------------------------------------------

         ecb := Integer (Float'floor (Float (cs) * cu_array (i)));
         ucb := Integer (Float'floor (Float (ecb) * rf));

         end_set := (start_set + ecb) mod cs;

         ucb_counter := 0;

         if (start_set < end_set and ecb < cs) then
            for j in start_set .. end_set - 1 loop
               add
                 (a_cache_access_profile.ECBs,
                  my_instruction_cache.cache_blocks.entries
                    (Caches.cache_blocks_range (j)));
               if (ucb_counter <= ucb) then
                  add
                    (a_cache_access_profile.UCBs,
                     my_instruction_cache.cache_blocks.entries
                       (Caches.cache_blocks_range (j)));
                  ucb_counter := ucb_counter + 1;
               end if;
            end loop;
         end if;

         if (start_set > end_set and ecb < cs) then
            for j in start_set .. cs - 1 loop
               add
                 (a_cache_access_profile.ECBs,
                  my_instruction_cache.cache_blocks.entries
                    (Caches.cache_blocks_range (j)));
               if (ucb_counter <= ucb) then
                  add
                    (a_cache_access_profile.UCBs,
                     my_instruction_cache.cache_blocks.entries
                       (Caches.cache_blocks_range (j)));
                  ucb_counter := ucb_counter + 1;
               end if;
            end loop;
            for j in 0 .. end_set - 1 loop
               add
                 (a_cache_access_profile.ECBs,
                  my_instruction_cache.cache_blocks.entries
                    (Caches.cache_blocks_range (j)));
               if (ucb_counter <= ucb) then
                  add
                    (a_cache_access_profile.UCBs,
                     my_instruction_cache.cache_blocks.entries
                       (Caches.cache_blocks_range (j)));
                  ucb_counter := ucb_counter + 1;
               end if;
            end loop;
         end if;

         if (ecb > cs) then
            for j in 0 .. cs - 1 loop
               add
                 (a_cache_access_profile.ECBs,
                  my_instruction_cache.cache_blocks.entries
                    (Caches.cache_blocks_range (j)));
               if (ucb_counter <= ucb) then
                  add
                    (a_cache_access_profile.UCBs,
                     my_instruction_cache.cache_blocks.entries
                       (Caches.cache_blocks_range (j)));
                  ucb_counter := ucb_counter + 1;
               end if;
            end loop;
         end if;

         start_set := end_set;
         add (my_cache_access_profiles, a_cache_access_profile);
         ----------------------------------------------------------------

         add_task
           (my_tasks                  => my_tasks,
            a_task                    => a_task,
            name => suppress_space (To_Unbounded_String ("Task" & i'img)),
            cpu_name                  => To_Unbounded_String ("CPU_01"),
            address_space_name => To_Unbounded_String ("Address_Space_01"),
            core_name                 => empty_string,
            task_type                 => periodic_type,
            start_time                => start_time,
            capacity                  => capacity,
            period                    => period,
            deadline                  => deadline,
            jitter                    => 0,
            blocking_time             => 0,
            priority                  => 1,
            criticality               => 0,
            policy                    => sched_fifo,
            cache_access_profile_name => a_cache_access_profile.name);
         i := i + 1;
      end loop;
   end add_multiple_periodic_tasks_harmonic_with_direct_mapped_instruction_cache_utilization_to_set_uunifast;

   procedure add_multiple_periodic_tasks_no_offset_with_direct_mapped_instruction_cache_utilization_to_set_uunifast
     (my_tasks                 : in out tasks_set;
      min_period               : in     Integer;
      max_period               : in     Integer;
      n                        : in     Integer;
      pu                       : in     Float;
      cu                       : in     Float;
      cs                       : in     Integer;
      rf                       : in     Float;
      my_instruction_cache     : in     instruction_cache_ptr;
      my_cache_access_profiles :    out cache_access_profiles_set)
   is
      use Ada.Float_Text_IO;
      i          : Integer;
      capacity   : Integer := 0;
      period     : Integer := 0;
      deadline   : Integer := 0;
      start_time : Integer := 0;

      pu_array               : random_tools.float_array (0 .. n - 1);
      flag                   : Boolean := True;
      a_task                 : generic_task_ptr;
      a_cache_access_profile : cache_access_profile_ptr;
      ------------------------------------------
      cu_array : random_tools.float_array (0 .. n - 1);

      start_set : Integer := 0;
      end_set   : Integer := 0;
      ecb       : Integer := 0;
      ucb       : Integer := 0;

      ucb_counter : Integer := 0;

      periods : array (0 .. 6) of Integer :=
        (1250, 2500, 3125, 6250, 12500, 15625, 31250);
   --Periods : array (0..6) of Integer := (10,15,20,30,40,60,120);
   begin
      set_initialize;
      i := 0;

      --GENERATE PROCESSOR UTILIZATION
      pu_array := gen_uunifast (n => n, u => pu);
      --GENERATE CACHE UTILIZATION
      cu_array := gen_uunifast (n => n, u => cu);

      while (i < n) loop
         capacity := 0;
         period   := 0;
         deadline := 0;

         start_time := 0;
         period     :=
           (random_integer (n1 => min_period, n2 => max_period) / 10) * 10;

         deadline := period;
         capacity := Integer (Float'floor (Float (period) * pu_array (i)));

         if (capacity <= 0) then
            capacity := 1;
         end if;

         a_cache_access_profile      := new cache_access_profile;
         a_cache_access_profile.name :=
           suppress_space (To_Unbounded_String ("CAP_" & i'img));
         ----------------------------------------------------------------

         ecb := Integer (Float'floor (Float (cs) * cu_array (i)));
         ucb := Integer (Float'floor (Float (ecb) * rf));

         if (ecb <= 0) then
            ecb := 1;
            ucb := 1;
         end if;

         end_set := (start_set + ecb) mod cs;

         ucb_counter := 0;

         if (start_set < end_set and ecb < cs) then
            for j in start_set .. end_set - 1 loop
               add
                 (a_cache_access_profile.ECBs,
                  my_instruction_cache.cache_blocks.entries
                    (Caches.cache_blocks_range (j)));
               if (ucb_counter <= ucb) then
                  add
                    (a_cache_access_profile.UCBs,
                     my_instruction_cache.cache_blocks.entries
                       (Caches.cache_blocks_range (j)));
                  ucb_counter := ucb_counter + 1;
               end if;
            end loop;
         end if;

         if (start_set > end_set and ecb < cs) then
            for j in start_set .. cs - 1 loop
               add
                 (a_cache_access_profile.ECBs,
                  my_instruction_cache.cache_blocks.entries
                    (Caches.cache_blocks_range (j)));
               if (ucb_counter <= ucb) then
                  add
                    (a_cache_access_profile.UCBs,
                     my_instruction_cache.cache_blocks.entries
                       (Caches.cache_blocks_range (j)));
                  ucb_counter := ucb_counter + 1;
               end if;
            end loop;
            for j in 0 .. end_set - 1 loop
               add
                 (a_cache_access_profile.ECBs,
                  my_instruction_cache.cache_blocks.entries
                    (Caches.cache_blocks_range (j)));
               if (ucb_counter <= ucb) then
                  add
                    (a_cache_access_profile.UCBs,
                     my_instruction_cache.cache_blocks.entries
                       (Caches.cache_blocks_range (j)));
                  ucb_counter := ucb_counter + 1;
               end if;
            end loop;
         end if;

         if (ecb > cs) then
            for j in 0 .. cs - 1 loop
               add
                 (a_cache_access_profile.ECBs,
                  my_instruction_cache.cache_blocks.entries
                    (Caches.cache_blocks_range (j)));
               if (ucb_counter <= ucb) then
                  add
                    (a_cache_access_profile.UCBs,
                     my_instruction_cache.cache_blocks.entries
                       (Caches.cache_blocks_range (j)));
                  ucb_counter := ucb_counter + 1;
               end if;
            end loop;
         end if;

         start_set := end_set;
         add (my_cache_access_profiles, a_cache_access_profile);
         ----------------------------------------------------------------

         add_task
           (my_tasks                  => my_tasks,
            a_task                    => a_task,
            name => suppress_space (To_Unbounded_String ("Task" & i'img)),
            cpu_name                  => To_Unbounded_String ("CPU_01"),
            address_space_name => To_Unbounded_String ("Address_Space_01"),
            core_name                 => empty_string,
            task_type                 => periodic_type,
            start_time                => start_time,
            capacity                  => capacity,
            period                    => period,
            deadline                  => deadline,
            jitter                    => 0,
            blocking_time             => 0,
            priority                  => 1,
            criticality               => 0,
            policy                    => sched_fifo,
            cache_access_profile_name => a_cache_access_profile.name);
         i := i + 1;
      end loop;
   end add_multiple_periodic_tasks_no_offset_with_direct_mapped_instruction_cache_utilization_to_set_uunifast;
begin

   rand_int.Reset (g_int);
   rand_res.Reset (g_res);

end architecture_factory;
