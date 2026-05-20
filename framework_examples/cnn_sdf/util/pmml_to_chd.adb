with Ada.Text_IO; 			use Ada.Text_IO;
with Ada.Integer_Text_IO;		use Ada.Integer_Text_IO;
with Systems; use Systems;
with Processors;        use Processors;
with Processor_Set;     use Processor_Set;
with Buffers;                          use Buffers;
with Buffer_Set;                       use Buffer_Set;
with Core_Units; use Core_Units;
use Core_Units.Core_Units_Table_Package;


with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Text_IO;             use Ada.Strings.Unbounded.Text_IO;

with Generic_Graph; use Generic_Graph;

with Tasks; use Tasks;

with Task_Set; use Task_Set;

with Task_Groups; use Task_Groups;

with Task_Group_Set; use Task_Group_Set;

with Buffers; use Buffers;

with Messages; use Messages;

with Dependencies; use Dependencies;

with Resources; use Resources;
use Resources.Resource_Accesses;

with Systems; use Systems;

with Processors;        use Processors;
with Processor_Set;     use Processor_Set;
with Address_Spaces;    use Address_Spaces;
with Address_Space_Set; use Address_Space_Set;
with Caches;            use Caches;
use Caches.Caches_Table_Package;
with Message_Set;       use Message_Set;

with Buffer_Set; use Buffer_Set;

with Network_Set;        use Network_Set;
with Event_Analyzer_Set; use Event_Analyzer_Set;
with Resource_Set;       use Resource_Set;

with Task_Dependencies; use Task_Dependencies;

with Buffers; use Buffers;
use Buffers.Buffer_Roles_Package;

with Queueing_Systems; use Queueing_Systems;
with convert_strings;

with unbounded_strings; use unbounded_strings;

with convert_unbounded_strings;

with Text_IO; use Text_IO;
with Ada.integer_text_io; use Ada.integer_text_io;

with Systems; use Systems;

with Objects; use Objects;

with Parameters.extended; use Parameters.extended;

with Scheduler_Interface; use Scheduler_Interface;

with Core_Units; use Core_Units;
use Core_Units.Core_Units_Table_Package;

with Ada.Finalization;

with unbounded_strings; use unbounded_strings;

use unbounded_strings.unbounded_string_list_package;

with Unchecked_Deallocation;

with sets;

with architecture_factory; use architecture_factory;

with Call_Framework;            use Call_Framework;
with Call_Framework_Interface;  use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with Call_Scheduling_Framework; use Call_Scheduling_Framework;

with Framework_Config; use Framework_Config;


with Sax.Locators;
with Sax.Exceptions;
with Sax.Attributes;	use Sax.Attributes;
with Sax.Models;
with Sax.Symbols;
with Sax.Readers;
with Sax.Utils;            use Sax.Utils;
with Unicode;
with Unicode.CES;
with Sax.HTable;

package body pmml_to_chd is


	function Find_Cheddar_Data(
	Handler : in out Reader;
	TaskName : Unbounded_String
	) 
	return Integer 
	is
	begin
		for i in Handler.Cheddar_Tasks'range loop
			if Handler.Cheddar_Tasks(i).Name = TaskName then
				return i;
			end if;
		end loop;
		
		return -1;
	end Find_Cheddar_Data;

	procedure Init_System
	(Handler       : in out Reader;
	CoreName  	: Unbounded_String := To_Unbounded_string("core1");
	CpuName 	: Unbounded_String := To_Unbounded_string("processor1");
	AddrName  	: Unbounded_String := To_Unbounded_string("addr1")
	)
	is
	begin
		--Basic System
		Add_core_unit (
		my_core_units   => Handler.Current_sys.Core_units,
		a_core_unit => Handler.Current_a_core,
		name    => CoreName,
		is_preemptive => preemptive,
		quantum         => 0,
		speed   => 1,
		capacity  => 1,
		period    => 1,
		priority  => 1,
		file_name => empty_string,
		scheduling_protocol_name =>  empty_string,
		a_scheduler   => Rate_Monotonic_Protocol
		);

		Add (Handler.Current_a_core_unit_table, Handler.Current_a_core);

		Add_Processor
		(Handler.Current_sys.Processors,
		 CpuName,
		 Handler.Current_a_core_unit_table);

		Add_Address_Space
		(Handler.Current_sys.Address_Spaces,
		 AddrName,
		 CpuName,
		 1024,
		 1024,
		 1024,
		 1024);
		 
		 Handler.In_InboundNodes := False;
		 Handler.In_InboundTokens := False;
		 Handler.In_OutboundTokens := False;

		  
	end Init_System;


	procedure Start_Element
	(Handler       : in out Reader;
	Namespace_URI : Unicode.CES.Byte_Sequence := "";
	Local_Name    : Unicode.CES.Byte_Sequence := "";
	Qname         : Unicode.CES.Byte_Sequence := "";
	Atts          : Sax.Attributes.Attributes'Class)
	is
		
		
	
	begin
		Handler.Current_Pref := To_Unbounded_String(Local_name);
	
		if Local_name = "NetworkLayer" then
			
			Handler.Cheddar_Tasks(Handler.Index_Current_Task).Name := To_Unbounded_String(Get_Value(Atts, "name")); 
			Handler.Cheddar_Tasks(Handler.Index_Current_Task).LayerType := To_Unbounded_String(Get_Value(Atts, "layerType")); 
		elsif Local_Name = "Array" then
		
			
				declare
			
				n : Integer := Integer'value((Get_Value(Atts, "n"))); 
				
				begin
					if Handler.In_InboundNodes = True then
						Handler.Cheddar_Tasks(Handler.Index_Current_Task).InboundNodes := new Tab_Inbound_Node(1..n);
						Handler.Cheddar_Tasks(Handler.Index_Current_Task).InboundBuffers := new Tab_Inbound_Buffer(1..n);
					elsif Handler.In_InboundTokens = True then
					
						New_Line;
						Handler.Cheddar_Tasks(Handler.Index_Current_Task).InboundTokens := new Tab_Token(1..n);
					end if;
				end;
			
			
			
		elsif Local_Name = "InboundNodes" then
		
			Handler.In_InboundNodes := True;
			
		elsif Local_Name = "InboundTokens" then
	
			Handler.In_InboundTokens := True;
		
		elsif Local_Name = "OutboundTokens" then
	
			Handler.In_OutboundTokens := True;
			
		elsif Local_Name = "DeepNetwork" then
			declare
			
			n : Integer := Integer'value((Get_Value(Atts, "numberOfLayers")));
			
			begin
				Handler.NbLayer := n;
				Handler.Cheddar_Tasks := new Tab_Cheddar_Task(1..n);
				Handler.Index_Current_Task := 1;
			end;
		end if;
		
		

	end Start_Element;





	procedure End_Element
	(Handler       : in out Reader;
	Namespace_URI : Unicode.CES.Byte_Sequence := "";
	Local_Name    : Unicode.CES.Byte_Sequence := "";
	Qname         : Unicode.CES.Byte_Sequence := "")
	is
	
	task_i              : Generic_Task_Ptr;
	
	NB_Buffer 		: Integer := 1;
	NB_TokenProduce	: Integer := 1;
	
	Buffer_Name	 	: Unbounded_String;
	
	Current_LayerType		: Unbounded_String := empty_string;
	
	begin

		if Local_name = "NetworkLayer" then
			
			Current_LayerType := Handler.Cheddar_Tasks(Handler.Index_Current_Task).LayerType;
			
			if Current_LayerType = "Conv2D" then
				Add_Task(My_Tasks          => Handler.Current_sys.Tasks,
				   Name                    => Handler.Cheddar_Tasks(Handler.Index_Current_Task).Name,
				   Cpu_Name                => To_Unbounded_String("processor1"),
				   core_name               => empty_string,
				   Address_Space_Name      => To_Unbounded_String("addr1"),
				   Task_Type               => Periodic_Type,
				   Start_Time              => 0,
				   Capacity                => 6,
				   Period                  => 40,
				   Deadline                => 30,
				   Jitter                  => 0,
				   Blocking_Time           => 0,
				   Priority                => 7,
				   Criticality             => 0,
				   Policy                  => SCHED_FIFO);
				
			elsif Current_LayerType = "MaxPooling2D" then
				Add_Task(My_Tasks          => Handler.Current_sys.Tasks,
				   Name                    => Handler.Cheddar_Tasks(Handler.Index_Current_Task).Name,
				   Cpu_Name                => To_Unbounded_String("processor1"),
				   core_name               => empty_string,
				   Address_Space_Name      => To_Unbounded_String("addr1"),
				   Task_Type               => Periodic_Type,
				   Start_Time              => 0,
				   Capacity                => 6,
				   Period                  => 40,
				   Deadline                => 30,
				   Jitter                  => 0,
				   Blocking_Time           => 0,
				   Priority                => 7,
				   Criticality             => 0,
				   Policy                  => SCHED_FIFO);
				   
			elsif Current_LayerType = "TransposedConv2D" then
				Add_Task(My_Tasks          => Handler.Current_sys.Tasks,
				   Name                    => Handler.Cheddar_Tasks(Handler.Index_Current_Task).Name,
				   Cpu_Name                => To_Unbounded_String("processor1"),
				   core_name               => empty_string,
				   Address_Space_Name      => To_Unbounded_String("addr1"),
				   Task_Type               => Periodic_Type,
				   Start_Time              => 0,
				   Capacity                => 6,
				   Period                  => 40,
				   Deadline                => 30,
				   Jitter                  => 0,
				   Blocking_Time           => 0,
				   Priority                => 7,
				   Criticality             => 0,
				   Policy                  => SCHED_FIFO);
				   
			elsif Current_LayerType = "Concatenate" then
				Add_Task(My_Tasks          => Handler.Current_sys.Tasks,
				   Name                    => Handler.Cheddar_Tasks(Handler.Index_Current_Task).Name,
				   Cpu_Name                => To_Unbounded_String("processor1"),
				   core_name               => empty_string,
				   Address_Space_Name      => To_Unbounded_String("addr1"),
				   Task_Type               => Periodic_Type,
				   Start_Time              => 0,
				   Capacity                => 6,
				   Period                  => 40,
				   Deadline                => 30,
				   Jitter                  => 0,
				   Blocking_Time           => 0,
				   Priority                => 7,
				   Criticality             => 0,
				   Policy                  => SCHED_FIFO);
			
			elsif Current_LayerType = "InputLayer" then
				Add_Task(My_Tasks          => Handler.Current_sys.Tasks,
				   Name                    => Handler.Cheddar_Tasks(Handler.Index_Current_Task).Name,
				   Cpu_Name                => To_Unbounded_String("processor1"),
				   core_name               => empty_string,
				   Address_Space_Name      => To_Unbounded_String("addr1"),
				   Task_Type               => Periodic_Type,
				   Start_Time              => 0,
				   Capacity                => 6,
				   Period                  => 40,
				   Deadline                => 30,
				   Jitter                  => 0,
				   Blocking_Time           => 0,
				   Priority                => 7,
				   Criticality             => 0,
				   Policy                  => SCHED_FIFO);
			end if;
			
			
			
			

			Handler.Index_Current_Task := Handler.Index_Current_Task+1;
			
			
		elsif Local_name = "InboundNodes" then
			Handler.In_InboundNodes := False;
		elsif Local_name = "InboundTokens" then
			Handler.In_InboundTokens := False;
		elsif Local_name = "OutboundTokens" then
			Handler.In_OutboundTokens := False;
		elsif Local_Name = "PMML" then
		
			if Handler.Index_Current_Task-1 /= Handler.NbLayer then
				Put_Line("The Number of Task does not match with the number write in the specifications");
				Put_Line("The system was not exported");
			else
		
				for i in Handler.Cheddar_Tasks'range loop
					Put_Line("______________________");
					Put("Task ");
					Put(i);
					Put_Line(": ");				
					Put("Name : ");
					Put_Line(Handler.Cheddar_Tasks(i).Name);
					Put("Layer Type : ");
					Put_Line(Handler.Cheddar_Tasks(i).LayerType);
					Put_Line("InboundNodes : ");
				

					
					if Handler.Cheddar_Tasks(i).LayerType /= "InputLayer" then
								
						for j in Handler.Cheddar_Tasks(i).InboundBuffers'range loop
							
							NB_TokenProduce := Handler.Cheddar_Tasks(Find_Cheddar_Data(Handler, Handler.Cheddar_Tasks(i).InboundNodes(j))).OutboundTokens;
							
							Buffer_Name := To_Unbounded_String("Buffer") & Slice(To_Unbounded_String(Integer'Image(NB_Buffer)),2,Integer'Image(NB_Buffer)'length);
	    						
	    						Put("   -");
							Put(Handler.Cheddar_Tasks(i).InboundNodes(j));
							Put(" (");
							Put(Buffer_Name);
							Put(" :");
							Put(Handler.Cheddar_Tasks(Find_Cheddar_Data(Handler, Handler.Cheddar_Tasks(i).InboundNodes(j))).OutboundTokens); 
							Put_Line(")");
	    						
							--Create buffer role
							Handler.Cheddar_Tasks(i).InboundBuffers(j).role_Inbound.the_role := Queuing_Producer;
							Handler.Cheddar_Tasks(i).InboundBuffers(j).role_Inbound.size     := NB_TokenProduce; 
							Handler.Cheddar_Tasks(i).InboundBuffers(j).role_Inbound.time     := 6; 
							Handler.Cheddar_Tasks(i).InboundBuffers(j).role_Inbound.timeout  := 3;  


							Add(Handler.Cheddar_Tasks(i).InboundBuffers(j).BufferTbl, Handler.Cheddar_Tasks(i).InboundNodes(j), Handler.Cheddar_Tasks(i).InboundBuffers(j).role_Inbound);


							
							--Create buffer role
							Handler.Cheddar_Tasks(i).InboundBuffers(j).role_Task.the_role := Queuing_Consumer;
							Handler.Cheddar_Tasks(i).InboundBuffers(j).role_Task.size     := Handler.Cheddar_Tasks(i).InboundTokens(j); 
							Handler.Cheddar_Tasks(i).InboundBuffers(j).role_Task.time     := 6; 
							Handler.Cheddar_Tasks(i).InboundBuffers(j).role_Task.timeout  := 3; -- 


							Add(Handler.Cheddar_Tasks(i).InboundBuffers(j).BufferTbl, Handler.Cheddar_Tasks(i).Name, Handler.Cheddar_Tasks(i).InboundBuffers(j).role_Task);

							
							
			

							-- Add a buffer
							Add_Buffer(My_Buffers   => Handler.Current_sys.Buffers, 
							     A_Buffer           => Handler.Cheddar_Tasks(i).InboundBuffers(j).Buffer,
							     Name               => Buffer_Name,
							     Size               => Handler.Cheddar_Tasks(i).InboundTokens(j),
							     Cpu_Name           => To_Unbounded_String("processor1"),
							     Address_Space_Name => To_Unbounded_String("addr1"),
							     A_Qs               => Qs_Pp1,
							     Roles              => Handler.Cheddar_Tasks(i).InboundBuffers(j).BufferTbl, 
							     Initial_Data       => 0); 
							     
							NB_Buffer := NB_Buffer+1;


							task_i := Search_Task(Handler.Current_sys.Tasks,Handler.Cheddar_Tasks(i).InboundNodes(j));    
							Add_One_Task_Dependency_queueing_buffer(My_Dependencies => Handler.Current_sys.Dependencies,
											  A_Task            => task_i,
											  A_Dep             => Handler.Cheddar_Tasks(i).InboundBuffers(j).Buffer,
											  A_Type            => From_Task_To_Object);
											  

							task_i := Search_Task(Handler.Current_sys.Tasks,Handler.Cheddar_Tasks(i).Name);
							Add_One_Task_Dependency_queueing_buffer(My_Dependencies => Handler.Current_sys.Dependencies,
											  A_Task            => task_i,
											  A_Dep             => Handler.Cheddar_Tasks(i).InboundBuffers(j).Buffer,
											  A_Type            => From_Object_To_Task); 


						end loop;
					end if;
					
				end loop;
				
				
------------------------------------------------CHEDDAR OUTPUT----------------------------------------------------

				    Handler.Current_sys.Write_To_Xml_File("output.xmlv3");
				    New_Line;
				    Put_Line("Export system to output.xmlv3");
				    
--------------------------------------------------------------------------------------------------------------------
			end if;
		end if;
		
	end End_Element;


	procedure Characters
	(Handler : in out Reader;
	Ch      : Unicode.CES.Byte_Sequence)
	is
	
	Current_Index : Integer := 1;
	Word_Begin_i : Integer := 1;
	
	begin
		if Handler.Current_Pref = "Array" then
		
		
			if Handler.In_InboundNodes = True then
				
				for i in 1..Ch'length loop
					if(Ch(i) = ' ') then
					
						Handler.Cheddar_Tasks(Handler.Index_Current_Task).InboundNodes(Current_Index) := To_Unbounded_String(Ch(Word_Begin_i..i-1));
						Current_Index := Current_Index + 1;
						Word_Begin_i := i+1;
					end if;
				end loop; 
				
				Handler.Cheddar_Tasks(Handler.Index_Current_Task).InboundNodes(Current_Index) := To_Unbounded_String(Ch(Word_Begin_i..Ch'last));
			
			elsif Handler.In_InboundTokens= True then
				
				for i in 1..Ch'length loop
					if(Ch(i) = ' ') then
					
					
						Handler.Cheddar_Tasks(Handler.Index_Current_Task).InboundTokens(Current_Index) := Integer'value(Ch(Word_Begin_i..i-1));
						Current_Index := Current_Index + 1;
						Word_Begin_i := i+1;
					end if;
				end loop; 
				
				Handler.Cheddar_Tasks(Handler.Index_Current_Task).InboundTokens(Current_Index) := Integer'value(Ch(Word_Begin_i..Ch'last));
				
			elsif Handler.In_OutboundTokens= True then
			
				Handler.Cheddar_Tasks(Handler.Index_Current_Task).OutboundTokens := Integer'value(Ch);
			
			end if;
		
		end if;
	
		
	end Characters;


end pmml_to_chd;
