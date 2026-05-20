with Text_IO;                           use Text_IO;
with ada.integer_text_IO;		  use ada.integer_text_IO; 
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with Input_sources.File; 	use Input_Sources.File;
with Ada.Long_Long_Integer_Text_IO; 	use Ada.Long_Long_Integer_Text_IO;

package cnn_pmml is

	type ParamVal3D is array(0..2) of Long_Long_Integer;
	type ParamVal2D is array(0..1) of Long_Long_Integer;
	
	subtype Token is Long_Long_Integer;

	procedure Initialization_PMML
	(Filename		: in String;
	 FileDescriptor	: out File_Type;
	 Description		: in Unbounded_String := To_Unbounded_string("");
 	 Timestamp		: in Unbounded_String := To_Unbounded_string("2023-13-02 00:00:00");
 	 NbLayer		: in Integer
	);
	
	procedure Terminate_PMML
	(FileDescriptor	: in File_Type
	);


	procedure Create_InputLayer
	(MyFile		: in File_Type;
	LayerName	        : in Unbounded_string;
	Size	       	: in ParamVal3D;
	OutboundToken		: out Token 
	);

	procedure Create_Conv2D
	(MyFile		: in File_Type;
	LayerName	        : in Unbounded_string;
	NameInboundNode 	: in Unbounded_string;
	KernelSize	        : in ParamVal2D;
	DilationRate	        : in ParamVal2D;
	KernelStrides	        : in ParamVal2D;
	ChannelSize		: in Natural;
	InboundToken		: in Token := 1;
	OutboundToken		: out Token 
	);
	
	procedure Create_MaxPooling2D
	(MyFile		: in File_Type;
	LayerName	        : in Unbounded_string;
	NameInboundNode 	: in Unbounded_string;
	PoolSize	        : in ParamVal2D;
	PoolStrides	        : in ParamVal2D;
	ChannelSize		: in out Natural;
	InboundToken		: in Token := 1;
	OutboundToken		: out Token 
	);
	
	procedure Create_Concatenate
	(MyFile		: in File_Type;
	LayerName	        : in Unbounded_string;
	NameInboundNode1 	: in Unbounded_string;
	NameInboundNode2 	: in Unbounded_string;
	InboundToken1		: in Token := 1;
	InboundToken2		: in Token := 1;
	OutboundToken		: out Token 
	);
	
	procedure Create_TransposedConv2D
	(MyFile		: in File_Type;
	LayerName	        : in Unbounded_string;
	NameInboundNode 	: in Unbounded_string;
	KernelSize	        : in ParamVal2D := (2,2);
	DilationRate	        : in ParamVal2D := (4,4);
	KernelStrides	        : in ParamVal2D := (2,2);
	ChannelSize		: in out Natural;
	InboundToken		: in Token := 1;
	OutboundToken		: out Token 
	);


end cnn_pmml;



