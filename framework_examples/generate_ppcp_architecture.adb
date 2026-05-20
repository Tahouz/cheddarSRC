with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Command_Line;      use Ada.Command_Line;
with Ada.Finalization;
with Ada.Unchecked_Deallocation;
with Ada.Containers.Hashed_Maps;
with Ada.Strings.Unbounded.Hash_Case_Insensitive;

with GNAT.Dynamic_Tables;
with GNAT.Os_Lib;

with Generic_Graph;      use Generic_Graph;
with Tasks;              use Tasks;
with Task_Set;           use Task_Set;
with Task_Groups;        use Task_Groups;
with Task_Group_Set;     use Task_Group_Set;
with Buffers;            use Buffers;
with Messages;           use Messages;
with Dependencies;       use Dependencies;
with Resources;          use Resources; use Resources.Resource_Accesses;
with Systems;            use Systems;
with Processors;         use Processors;
with Processor_Set;      use Processor_Set;
with Address_Spaces;     use Address_Spaces;
with Address_Space_Set;  use Address_Space_Set;
with Caches;             use Caches;    use Caches.Caches_Table_Package;
with Message_Set;        use Message_Set;
with Buffer_Set;         use Buffer_Set;
with Network_Set;        use Network_Set;
with Event_Analyzer_Set; use Event_Analyzer_Set;
with Resource_Set;       use Resource_Set;
with Task_Dependencies;  use Task_Dependencies;
with Buffers;            use Buffers;   use Buffers.Buffer_Roles_Package;
with Queueing_Systems;   use Queueing_Systems;
with convert_strings;
with unbounded_strings;        use unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
with convert_unbounded_strings;
with Objects;                   use Objects;
with Parameters.extended;       use Parameters.extended;
with Processor_Interface;       use Processor_Interface;
with Scheduler_Interface;       use Scheduler_Interface;
with Core_Units;                use Core_Units;
use Core_Units.Core_Units_Table_Package;
with sets;
with Random_Tools;              use Random_Tools;
with architecture_factory;      use architecture_factory;
with Call_Framework;            use Call_Framework;
with Call_Framework_Interface;  use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with Call_Scheduling_Framework; use Call_Scheduling_Framework;

with Framework_Config;          use Framework_Config;
with priority_assignment.RM;    use priority_assignment.RM;

procedure Generate_Ppcp_Architecture is
   sys               : System;
   a_core            : Core_Unit_Ptr;
   a_core_unit_table : Core_Units_Table;
   
   package Nghb_Table is new GNAT.Dynamic_Tables (Table_Component_Type => Unbounded_String,
						  Table_Index_Type     => Positive,
						  Table_Low_Bound      => 1,
						  Table_Initial        => 5,
						  Table_Increment      => 5);
   
   function "=" (Left, Right : Nghb_Table.Instance) return Boolean is 
      use type Nghb_Table.Table_Ptr;
   begin 
      return Left.Table = Right.Table;
   end "=";
   
   package Graph_Hm_Pkg is new Ada.Containers.Hashed_Maps
     (Key_Type        => Unbounded_String,
      Element_Type    => Nghb_Table.Instance,
      Hash            => Ada.Strings.Unbounded.Hash_Case_Insensitive,
      Equivalent_Keys => "=",
      "="             => "=");
   -- For a much faster search, the adjacency list of the indirected graph is a Hash Map
   
   procedure Insert (G : in out Graph_Hm_Pkg.Map; A : in Unbounded_String; B : Unbounded_String) is
      N : Nghb_Table.Instance;
   begin
      if Graph_Hm_Pkg.Contains (G, A) then
	 N := Graph_Hm_Pkg.Element (G, A);
	 Nghb_Table.Append (N, B);
	 Graph_Hm_Pkg.Replace (G, A, N);
      else
	 Nghb_Table.Init (N);
	 Nghb_Table.Append (N, B);
	 Graph_Hm_Pkg.Insert (G, A, N);
      end if;
   end Insert;
   
   function Has_Neighbors (G : in Graph_Hm_Pkg.Map; A : in Unbounded_String) return Boolean is
   begin
      return Graph_Hm_Pkg.Contains (G, A);
   end Has_Neighbors;
   
   function Get_Neighbors (G : in Graph_Hm_Pkg.Map; A : in Unbounded_String) return Nghb_Table.Instance
   is
   begin
      return Graph_Hm_Pkg.Element (G, A);
   end Get_Neighbors;
   
   package Graph_CC_Pkg is new Ada.Containers.Hashed_Maps
     (Key_Type        => Unbounded_String,
      Element_Type    => Positive, --  not existent => not visited, otherwise => CC number
      Hash            => Ada.Strings.Unbounded.Hash_Case_Insensitive,
      Equivalent_Keys => "=",
      "="             => "=");
   -- For a much faster search, the connected component list is a Hash Map
   
   procedure Compute_Connected_Components (G : in Graph_Hm_Pkg.Map;
					   CC : in out Graph_Cc_Pkg.Map)
   is
      Cc_Num : Natural := 1;
      
      procedure Explore (V : in Unbounded_String);
      --  Explore subroutine of the DFS algorithm
      
      procedure Explore (V : in Unbounded_String) is
	 N : Nghb_Table.Instance;
	 W : Unbounded_String;
      begin
	 Graph_Cc_Pkg.Insert (Cc, V, Cc_Num);
	 --  Implicitly mark as visited and set the CC number
	 
	 if Has_Neighbors (G, V) then
	    N := Get_Neighbors (G, V);
	    for I in Nghb_Table.First .. Nghb_Table.Last (N) loop
	       W := N.Table (I);
	       if not Graph_Cc_Pkg.Contains (CC, W) then
		  Explore (W);
	       end if;
	    end loop;
	 end if;
      end Explore;
      
      use type Graph_Hm_Pkg.Cursor;
      C : Graph_Hm_Pkg.Cursor := Graph_Hm_Pkg.First (G);
      V : Unbounded_String;
   begin
      while C /= Graph_Hm_Pkg.No_Element loop
	 V := Graph_Hm_Pkg.Key (C);
	 if not Graph_Cc_Pkg.Contains (CC, V) then
	    Put_Line ("Visiting " & To_String (V));
	    Explore (V);
	    CC_Num := CC_Num + 1;
	 end if;
	 C := Graph_Hm_Pkg.Next (C);
      end loop;
   end Compute_Connected_Components;
   
   Cores : array (0 .. 3) of Unbounded_String := 
     (To_Unbounded_String ("core1"), 
      To_Unbounded_String ("core2"),
      To_Unbounded_String ("core3"),
      To_Unbounded_String ("core4"));
begin
   -- Initialize the Cheddar framework
   --
   Call_Framework.initialize (False);

   -- Initialize the System
   --

   Initialize (sys);
   
   -- Adding Cores, Processor and address_space
   --
   
   for C in Cores'Range loop
      Add_core_unit
	(sys.Core_units,
	 a_core,
	 Cores (C),
	 preemptive,
	 0,
	 1,
	 0,
	 0,
	 0,
	 To_Unbounded_String (""),
	 To_Unbounded_String (""),
	 Posix_1003_Highest_Priority_First_Protocol);
      Add (a_core_unit_table, a_core);
   end loop;
   
   Add_Processor
     (sys.Processors,
      To_Unbounded_String ("processor1"),
      A_Core_Unit_Table,
      No_Migration_Type);

   Add_Address_Space
     (sys.Address_Spaces,
      To_Unbounded_String ("addr1"),
      To_Unbounded_String ("processor1"),
      0,
      0,
      0,
      0);
   
   -- Generate a task set and resources
   declare
      Ratio                   : Float;
      N_Tasks                 : Integer := 12;
      N_D_Tasks               : Integer := 6;
      N_Resources             : Integer := 4;
      Resource_Sharing_Factor : Float := 0.33;
      Critical_Section_Ratio  : Float := 0.0;
      Global_Cpu_Usage        : Float := 0.2;
      a_task       : generic_task_ptr;
      my_iterator  : tasks_iterator;
      a_resource   : generic_resource_ptr;
      Res_Iterator : Resources_Iterator;
      Rt           : Resource_Accesses_Table;
      
      G    : Graph_Hm_Pkg.Map;
      Cc   : Graph_Cc_Pkg.Map;
      A_Cc : Graph_Cc_Pkg.Cursor;
      use type Graph_Cc_Pkg.Cursor;
   begin
      --  Parse command line
      
      if Argument_Count /= 7 then
	 Put ("Usage: " & Command_Name & " ");
	 Put_Line ("N_Tasks N_Diff_Tasks N_Resources Res_Sh_Factor Crit_Sec_Ratio G_CPU_Usage Filename");
	 GNAT.OS_Lib.OS_Exit (1);
      else
	 N_Tasks := Natural'Value (Argument (1));
	 N_D_Tasks := Natural'Value (Argument (2));
	 N_Resources :=  Natural'Value (Argument (3));
	 Resource_Sharing_Factor := Float'Value (Argument (4))/100.0;
	 Critical_Section_Ratio := Float'Value (Argument (5))/100.0;
	 Global_Cpu_Usage := Float'Value (Argument (6))/100.0;
	 
	 Put_Line ("N_Tasks = " & N_Tasks'Img);
	 Put_Line ("N_D_Tasks = " & N_D_Tasks'Img);
         Put_Line ("N_Resources = " & N_Resources'Img);
         Put_Line ("Resource_Sharing_Factor = " & Resource_Sharing_Factor'Img);
         Put_Line ("Critical_Section_Ratio = " & Critical_Section_Ratio'Img);
         Put_Line ("Global_Cpu_Usage = " & Global_Cpu_Usage'Img);
      end if;
      
      --Generate_A_Customized_Ravenscar_System
      --(Sys,
      --N_Tasks,
      --Global_Cpu_Usage,
      --Ratio,
      --N_D_Tasks,
      --N_Resources,
      --Resource_Sharing_Factor,
      --Critical_Section_Ratio,
      --Sched_Fifo);

      Create_Independant_Periodic_Taskset_System
	(Sys,
	 Ratio,
	 N_Tasks,
	 Global_Cpu_Usage,
	 N_Different_Periods => N_D_Tasks,
	 A_Sched_Policy => Sched_Fifo);
      
      Set_Priority_According_To_RM 
	(Sys.Tasks,
	 To_Unbounded_String ("processor1"));
      
      if N_Resources > 0 then
	 Add_Resource_Set_To_System
	   (Sys,
	    N_Resources,
	    Resource_Sharing_Factor,
	    Critical_Section_Ratio);
	 
	 
	 -- Build an undirected graph where the vertices are the
	 -- tasks and the edges reflect the relation "shares a resource
	 -- with". This is be done by looping on all the resources of
	 -- the system, then for each resource looping on all critical
	 -- sections and mark the tasks in the same crtical_sections list
	 -- of a resource as connected in the graph.
	 
	 Reset_Iterator (Sys.Resources, Res_Iterator);
	 
	 loop
	    Current_Element (Sys.Resources, A_Resource, Res_Iterator);
	    
	    Put_Line ("Resource: " & To_String (A_Resource.Name));
	    Rt := A_Resource.Critical_Sections;
	    
	    for Z in 0 .. Rt.Nb_Entries - 1 loop
	       for T in Z + 1 .. Rt.Nb_Entries - 1 loop
		  Put_Line ("  Linking " & To_String (Rt.Entries (Z).Item) & 
			      " and " & To_String (Rt.Entries (T).Item));
		  Insert (G, Rt.Entries (Z).Item, Rt.Entries (T).Item);
		  Insert (G, Rt.Entries (T).Item, Rt.Entries (Z).Item);
	       end loop;
	    end loop;
	    
	    exit when is_last_element (Sys.Resources, Res_iterator);
	    next_element (Sys.Resources, Res_iterator);
	 end loop;
	 
	 --  Loop over the task and give the tasks that have no
	 --  neighbors and empty list of neighbors.
	 
	 reset_iterator (Sys.Tasks, my_iterator);
	 
	 loop
	    current_element (Sys.Tasks, a_task, my_iterator);
	    
	    if not Has_Neighbors (G, A_Task.Name) then
	       declare
		  N : Nghb_Table.Instance;
	       begin
		  Nghb_Table.Init (N);
		  Graph_Hm_Pkg.Insert (G, A_Task.Name, N);
	       end;
	    end if;
	    
	    exit when is_last_element (Sys.Tasks, my_iterator);
	    next_element (Sys.Tasks, my_iterator);
	 end loop;
	 
	 -- Compute the connected compnent of the graph
	 
	 Compute_Connected_Components (G, Cc);
	 A_Cc := Graph_CC_Pkg.First (Cc);
	 
	 while A_Cc /= Graph_CC_Pkg.No_Element loop
	    Put (To_String (Graph_CC_Pkg.Key (A_Cc)) & " => " & Graph_CC_Pkg.Element (A_Cc)'Img);
	    
	    --  Affect the task to CC mod cores_number to guarantee tasks
	    --  from same CC are affected to the same core.
	    
	    Set (Sys.Tasks,
		 Graph_CC_Pkg.Key (A_Cc), 
		 Core_Name, 
		 Cores (Graph_CC_Pkg.Element (A_Cc) mod Cores'Length));
	    
	    Put_Line (". core => " & To_String (Cores (Graph_CC_Pkg.Element (A_Cc) mod Cores'Length)));
	    A_Cc := Graph_CC_Pkg.Next (A_Cc);
	 end loop;
      else
	 --  In case of no resource, affect tasks on cores arbitrarily
	 
	 declare
	    Num_Task : Natural := 0;
	 begin
	    reset_iterator (Sys.Tasks, my_iterator);
	    Num_Task := 0;
	    
	    loop
	       current_element (Sys.Tasks, a_task, my_iterator);
	       
	       --  Affect the task to CC mod cores_number to guarantee tasks
	       --  from same CC are affected to the same core.
	       
	       Set (Sys.Tasks,
		    A_Task.Name, 
		    Core_Name, 
		    Cores (Num_Task mod Cores'Length));
	       
	       exit when is_last_element (Sys.Tasks, my_iterator);
	       next_element (Sys.Tasks, my_iterator);
	       Num_Task := Num_Task + 1;
	    end loop;
	 end;
      end if;
      
      Put_Line ("Current CPU Usage: " & Ratio'Img);
   end;
   
   declare
      File_Name : String := Argument (7);
   begin
      -- Export the system in an XML file
      --
      write_to_xml_file (sys, File_Name);
   end;
end Generate_Ppcp_Architecture;
