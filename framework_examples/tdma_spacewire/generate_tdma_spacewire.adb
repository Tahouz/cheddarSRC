with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Command_Line;      use Ada.Command_Line;
with Ada.Numerics.Float_Random;
use Ada.Numerics.Float_Random;
with GNAT.Os_Lib;

with Objects;                   use Objects;
with Tasks;              use Tasks;
with Task_Set;           use Task_Set;
use task_set.generic_task_set;
with Systems;            use Systems;
with Processors;         use Processors;
with Processor_Set;      use Processor_Set;
with Address_Spaces;     use Address_Spaces;
with Address_Space_Set;  use Address_Space_Set;
with Core_Units;         use Core_Units;
use Core_Units.Core_Units_Table_Package;
with messages; use messages;
with message_set; use message_set;
with dependencies; use dependencies;
with task_dependencies; use task_dependencies;
with parameters; use parameters;
with parameters.extended; use parameters.extended;
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



procedure Generate_tdma_spacewire is
   sys                  : System;
   receivers            : System;
   a_core               : Core_Unit_Ptr;
   processor1           : Generic_Processor_Ptr;
   processor2           : Generic_Processor_Ptr;
   my_iterator          : tasks_iterator;
   source_task          : Generic_task_ptr;
   sink_task            : Generic_task_ptr;
   my_task              : Generic_task_ptr;

   msg                  : Unbounded_String;
   Feasibility_Interval : Double;
   validate             : Boolean;

   Actual_CPU_Usage      : Float   :=0.0;
   N_Emitter_Tasks       : Integer :=0;
   Target_Cpu_Usage      : Float   :=0.0;
   Generate_Precedence   : Boolean :=False;
   m1                    : Generic_Message_Ptr;


begin

   -- Initialize the System and the Cheddar framework
   --
   Call_Framework.initialize (False);
   Initialize (sys);
   
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
         Earliest_Deadline_First_Protocol);
   
   Add_Processor
     (sys.Processors,
      processor1,
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
   
   Add_Processor
     (sys.Processors,
      processor2,
      To_Unbounded_String ("processor2"),
      A_Core);
   Add_Address_Space
     (sys.Address_Spaces,
      To_Unbounded_String ("addr2"),
      To_Unbounded_String ("processor2"),
      0,
      0,
      0,
      0);
   

      -- Create message M1
      --
      Add_Message(sys.messages, m1, to_unbounded_string("m1"), 1, 10, 10, 
	0, no_user_defined_parameter, 0, 0);


      
      --  Parse command line
      
      if Argument_Count /= 4 then
	 Put ("Usage: " & Command_Name & " ");
	 Put_Line ("N_Emitter_Tasks Target_CPU_Usage Generate_Precedence Filename");
	 GNAT.OS_Lib.OS_Exit (1);
      else
	 N_Emitter_Tasks := Natural'Value (Argument (1));
	 Target_Cpu_Usage := Float'Value (Argument (2))/100.0;
         Generate_Precedence := Boolean'Value(Argument(3));
      end if;
      
     declare 
        period_values         : integer_array (1..N_Emitter_Tasks);
        priority_values       : integer_array (1..N_Emitter_Tasks);
        g                     : Ada.Numerics.Float_Random.Generator;
     
     begin
        Reset(g);

        for i in 1 .. N_Emitter_Tasks loop
   		period_values(i):=get_rand_parameter(10,500,g);
   		priority_values(i):=get_rand_parameter(1,255,g);
        end loop;

        -- Create emitter tasks
        --
        Create_Independant_Periodic_Taskset_System
	   (Sys,
	    Actual_CPU_Usage,
	    N_Emitter_Tasks,
	    Target_Cpu_Usage/2.0,
	    period_values,
            priority_values);

     end;

     -- Create receiver tasks
     --
     Initialize (receivers);
     reset_iterator (sys.tasks, my_iterator);

     loop
         current_element (sys.tasks, my_task, my_iterator);

         add_task
           (receivers.tasks,
            suppress_space (my_task.name  & "_receiver"),
            To_Unbounded_String ("processor2"),
            To_Unbounded_String ("addr2"),
            empty_string,
            periodic_type,
            my_task.start_time,
            my_task.capacity,
            periodic_task_ptr(my_task).period,
            periodic_task_ptr(my_task).deadline,
            0,
            0,
            integer(my_task.priority),
            0,
            my_task.policy);

           exit when is_last_element (sys.tasks, my_iterator);
           next_element (sys.tasks, my_iterator);
     end loop;

     add_all(sys.tasks, receivers.tasks);



     -- Add precedence dependency for model without TDMA
     -- or asynchronous message instead
     --
       reset_iterator (sys.tasks, my_iterator);

       loop
         current_element (sys.tasks, source_task, my_iterator);
    
         if (source_task.cpu_name = to_unbounded_string("processor1")) then
           sink_task:=search_task(sys.tasks, suppress_space (source_task.name  & "_receiver"));
           if Generate_Precedence then
	      add_one_task_dependency_precedence(sys.dependencies,
		source_task, sink_task);
              else
	      add_one_task_dependency_tdma_communication(
		sys.dependencies, source_task, m1, from_task_to_object);
	      add_one_task_dependency_tdma_communication(
		sys.dependencies, sink_task, m1, from_object_to_task);
           end if;
         end if;

         exit when is_last_element (sys.tasks, my_iterator);
         next_element (sys.tasks, my_iterator);
       end loop;


     -- Compute feasibility interval and display parameters
     --
     Calculate_feasibility_interval
        (sys,
         processor1,
         validate,
         Feasibility_Interval,
         msg);


      Put_Line ("N_Emitter_Tasks = " & N_Emitter_Tasks'Img);
      Put_Line ("Target_Cpu_Usage = " & Target_Cpu_Usage'Img);
      Put_Line ("Actual_CPU_Usage    : " & Actual_CPU_Usage'Img);
      Put_Line ("Generate_Precedence : " & Generate_Precedence'Img);
      Put_Line ("Feasibility_Interval processor : " & Feasibility_Interval'Img);
      Put_Line ("");

      --
      declare 
        File_Name         : String := Argument (4);
      begin
        write_to_xml_file (sys, File_Name);
      end;

end Generate_tdma_spacewire;
