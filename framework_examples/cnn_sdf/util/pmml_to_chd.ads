with Ada.Unchecked_Deallocation;
with Input_Sources;
with Interfaces;
with Sax.Locators;
with Sax.Exceptions;
with Sax.Attributes;
with Sax.Models;
with Sax.Symbols;
with Sax.Readers;
with Sax.Utils;            use Sax.Utils;
with Unicode;
with Unicode.CES;
with Sax.HTable;
with Ada.Text_IO; 			use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Systems; use Systems;
with Core_Units; use Core_Units;
use Core_Units.Core_Units_Table_Package;
with Buffers;                          use Buffers;
with Buffer_Set;                       use Buffer_Set;

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;



package pmml_to_chd is

	type String_Access is access String;
	
		

	type Tab_Inbound_Node is array (integer range <>) of Unbounded_string ;
	type Ptr_Inbound_Nodes is access Tab_Inbound_Node;
	
	
	type Tab_Token is array (integer range <>) of Integer ;
	type Ptr_Inbound_Tokens is access Tab_Token;
	type Ptr_Outbound_Tokens is access Tab_Token;
	
	
	
	type Inbound_Buffer is record

		Buffer           : Buffer_Ptr;
		BufferTbl        : Buffer_Roles_Table;

		role_Inbound	  : Buffer_Role;
		role_Task	  : Buffer_Role;

	end record;
	type Tab_Inbound_Buffer is array (integer range <>) of Inbound_Buffer ;
	type Ptr_Inbound_Buffers is access Tab_Inbound_Buffer;
	
	
	
	
	type Cheddar_Task is record

		Name : Unbounded_string;
		LayerType : Unbounded_string;
		InboundNodes : Ptr_Inbound_Nodes;
		
		InboundBuffers : Ptr_Inbound_Buffers;
		
		InboundTokens	: Ptr_Inbound_Tokens;
		OutboundTokens	: Integer;

	end record;
	type Tab_Cheddar_Task is array (integer range <>) of Cheddar_Task ;
	type Ptr_Cheddar_Tasks is access Tab_Cheddar_Task;

	
	
	


	type Reader is new Sax.Readers.Reader with record
		Current_Pref  : Unbounded_String;
		Current_Value : Unbounded_String;
		
		In_InboundNodes : Boolean;
		In_InboundTokens : Boolean;
		In_OutboundTokens : Boolean;

		---------------------------------------------------

		Cheddar_Tasks : Ptr_Cheddar_Tasks;
		Index_Current_Task : Integer;
		NbLayer : Integer;
		
		
		---------------------------------------------------
		
		Current_a_core            : Core_Unit_Ptr;
		Current_a_core_unit_table : Core_Units_Table;

		Current_sys : System;

	end record;


	procedure Init_System
	(Handler       	: in out Reader;
	CoreName  	: Unbounded_String := To_Unbounded_string("core1");
	CpuName 	 	: Unbounded_String := To_Unbounded_string("processor1");
	AddrName  	: Unbounded_String := To_Unbounded_string("addr1")
	);



	procedure Start_Element
	(Handler       : in out Reader;
	Namespace_URI : Unicode.CES.Byte_Sequence := "";
	Local_Name    : Unicode.CES.Byte_Sequence := "";
	Qname         : Unicode.CES.Byte_Sequence := "";
	Atts          : Sax.Attributes.Attributes'Class);

	procedure End_Element
	(Handler       : in out Reader;
	Namespace_URI : Unicode.CES.Byte_Sequence := "";
	Local_Name    : Unicode.CES.Byte_Sequence := "";
	Qname         : Unicode.CES.Byte_Sequence := "");

	procedure Characters
	(Handler : in out Reader;
	Ch      : Unicode.CES.Byte_Sequence);

end pmml_to_chd;



