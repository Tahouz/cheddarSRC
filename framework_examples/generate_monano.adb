with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Command_Line;      use Ada.Command_Line;
with Ada.Numerics.Float_Random;
use Ada.Numerics.Float_Random;
with GNAT.Os_Lib;

with Objects;                   use Objects;
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



procedure Generate_monano is
   sys                  : System;
   a_core               : Core_Unit_Ptr;
   a_processor          : Generic_Processor_Ptr;

   msg                  : Unbounded_String;
   Feasibility_Interval : Double;
   validate             : Boolean;

   Actual_CPU_Usage      : Float   :=0.0;
   N_Tasks               : Integer :=0;
   Target_Cpu_Usage      : Float   :=0.0;
   


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
         Posix_1003_Highest_Priority_First_Protocol);
   
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
   
      
      --  Parse command line
      
      if Argument_Count /= 3 then
	 Put ("Usage: " & Command_Name & " ");
	 Put_Line ("N_Tasks Target_CPU_Usage Filename");
	 GNAT.OS_Lib.OS_Exit (1);
      else
	 N_Tasks := Natural'Value (Argument (1));
	 Target_Cpu_Usage := Float'Value (Argument (2))/100.0;
      end if;
      
     declare 
        period_values         : integer_array (1..N_tasks);
        priority_values       : integer_array (1..N_tasks);
        g                     : Ada.Numerics.Float_Random.Generator;
     
     begin
        Reset(g);

        for i in 1 .. N_tasks loop
   		period_values(i):=get_rand_parameter(500,10000,g);
   		priority_values(i):=get_rand_parameter(1,255,g);
        end loop;

         Create_Independant_Periodic_Taskset_System
	   (Sys,
	    Actual_CPU_Usage,
	    N_Tasks,
	    Target_Cpu_Usage,
	    period_values,
            priority_values);

     end;

      Calculate_feasibility_interval
        (sys,
         a_processor,
         validate,
         Feasibility_Interval,
         msg);


      Put_Line ("N_Tasks = " & N_Tasks'Img);
      Put_Line ("Target_Cpu_Usage = " & Target_Cpu_Usage'Img);
      Put_Line ("Actual_CPU_Usage    : " & Actual_CPU_Usage'Img);
      Put_Line ("Feasibility_Interval : " & Feasibility_Interval'Img);
      Put_Line ("");


      --
      declare 
        File_Name         : String := Argument (3);
      begin
        write_to_xml_file (sys, File_Name);
      end;

end Generate_monano;
