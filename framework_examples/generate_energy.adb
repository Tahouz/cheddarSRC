with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Command_Line;      use Ada.Command_Line;
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



procedure Generate_energy is
   sys                  : System;
   a_core               : Core_Unit_Ptr;
   a_processor          : Generic_Processor_Ptr;
   msg                  : Unbounded_String;
   Feasibility_Interval : Double;
   validate             : Boolean;

   Actual_CPU_Usage      : Float   :=0.0;
   N_Tasks               : Integer :=0;
   N_Different_Periods   : Integer :=0;
   Target_Cpu_Usage      : Float   :=0.0;
   Initial_Battery_Level : Integer :=0;
   Initial_Battery_Value : Integer :=0;
   Rechargeable_Power    : Integer :=0;
   Battery_Capacity      : Integer :=0;
   E_Average             : Float   :=0.0;
   E_Max                 : Integer :=0;
   E_Min                 : Integer :=0;
   
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
         Earliest_Deadline_First_Energy_To_Time_Protocol);
   
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
      
      if Argument_Count /= 6 then
	 Put ("Usage: " & Command_Name & " ");
	 Put_Line ("N_Tasks N_Different_Periods Initial_Battery_Level Target_CPU_Usage E_Average Filename");
	 GNAT.OS_Lib.OS_Exit (1);
      else
	 N_Tasks := Natural'Value (Argument (1));
	 N_Different_Periods := Natural'Value (Argument (2));
	 Initial_Battery_Level := Integer'Value(Argument (3));
	 Target_Cpu_Usage := Float'Value (Argument (4))/100.0;
	 E_Average := Float'Value (Argument (5));
      end if;
      

      Create_Independant_Periodic_Taskset_System
	(Sys,
	 Actual_CPU_Usage,
	 N_Tasks,
	 Target_Cpu_Usage,
         1.0,1.0, true, 
	 N_Different_Periods,
	 Sched_Fifo);

      Calculate_feasibility_interval
        (sys, 
         a_processor,
         validate, 
         Feasibility_Interval,
         msg);

      Rechargeable_Power:=Integer(float'ceiling(float(Actual_Cpu_Usage)*float(E_Average)));

      Initial_Battery_Value:=Integer( 
	    float(Initial_Battery_Level)*float(Feasibility_Interval)*float(Rechargeable_Power) );
     
IBL = Initial_Battery_Level * Rechargeable_Power * ;
 
      Battery_Capacity:=Initial_Battery_Value*2;

      E_Max:=Integer(E_Average*2.0);
      E_Min:=0;
      
      Put_Line ("N_Tasks = " & N_Tasks'Img);
      Put_Line ("N_Different_Periods = " & N_Different_Periods'Img);
      Put_Line ("Initial_Battery_Level = " & Initial_Battery_Level'Img);
      Put_Line ("E_Average  : " & E_Average'Img);
      Put_Line ("Rechargeable_Power  : " & Rechargeable_Power'Img);
      Put_Line ("Feasibility_Interval : " & Feasibility_Interval'Img);
      Put_Line ("Initial_Battery_Value = " & Initial_Battery_Level'Img);
      Put_Line ("Battery_Capacity = " & Battery_Capacity'Img);
      Put_Line ("Target_Cpu_Usage = " & Target_Cpu_Usage'Img);
      Put_Line ("Actual_CPU_Usage    : " & Actual_CPU_Usage'Img);
      Put_Line ("E_Max  : " & E_Max'Img);
      Put_Line ("E_Min  : " & E_Min'Img);

      add_battery
              (sys.batteries,
               to_unbounded_string("B1"),
               to_unbounded_string("processor1"),
               Battery_Capacity,
               E_Max,
               E_Min,
               Initial_Battery_Value,
               Rechargeable_Power);



      -- Export the system in an XML file
      --
      declare 
        File_Name         : String := Argument (6);
      begin
        write_to_xml_file (sys, File_Name);
      end;

end Generate_energy;
