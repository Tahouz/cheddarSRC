with Text_IO;                           use Text_IO;
with ada.integer_text_IO;		  use ada.integer_text_IO; 
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Text_IO;             use Ada.Strings.Unbounded.Text_IO;
with unbounded_strings;                 use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with Input_sources.File; 	use Input_Sources.File;
with Ada.Directories;		use Ada.Directories;
with Ada.Long_Long_Integer_Text_IO; 	use Ada.Long_Long_Integer_Text_IO;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

package body cnn_pmml is

	quote : Character := Character'Val(39);
	guil : Character := Character'Val(34);
	tab : Character := Character'Val(9);


	procedure Initialization_PMML
	(Filename		: in String;
	 FileDescriptor	: out File_Type;
	 Description		: in Unbounded_String := To_Unbounded_string("");
 	 Timestamp		: in Unbounded_String := To_Unbounded_string("2023-13-02 00:00:00");
 	 NbLayer		: in Integer
	)
	is
	
	Default_Integer_Width : Integer := Ada.Integer_Text_IO.Default_Width;
	
	begin
		
		Ada.Integer_Text_IO.Default_Width := 0;
		
		if(Exists(Filename)=True) then
			Open(FileDescriptor, Out_File, Filename);
		else
			Create(FileDescriptor, Out_File, Filename);
		end if;
	
		
		
		Put_Line(FileDescriptor, "<?xml version=" & guil & "1.0" & guil & " encoding=" & guil & "UTF-8" & guil & "?>");
		
		Put_Line(FileDescriptor, "<PMML version=" & guil & "4.5" & guil & " xmlns=" & guil & "http://www.dmg.org/PMML-4_5" & guil & ">");
		
		Put_Line(FileDescriptor, tab & "<Header copyright=" & guil & "Lab-Sticc" & guil & " description=" & guil & Description & guil & ">");
		Put_Line(FileDescriptor, tab & tab & "<Timestamp>" & Timestamp & "</Timestamp>");
		Put_Line(FileDescriptor, tab & "</Header>");
		
		
		--Warning NOT GENERIC
		
		Put_Line(FileDescriptor, tab & "<DataDictionary numberOfFields=" & guil & "2" & guil & ">");
		Put_Line(FileDescriptor, tab & tab & "<DataField channels=" & guil & "3" & guil & " dataType=" & guil & "tensor" & guil & " height=" &  guil & "300" & guil & " name=" & guil & "I" & guil & " optype=" & guil & "categorical" & guil &  " width=" & guil & "300" & guil & "/>");
		Put_Line(FileDescriptor, tab & tab & "<DataField dataType=" & guil & "string" & guil & " name=" & guil & "class" & guil & " optype=" & guil & "categorical" & guil & ">");
		Put_Line(FileDescriptor, tab & tab & tab & "<Value value=" & guil & "Zero" & guil & "/>");
		Put_Line(FileDescriptor, tab & tab & "</DataField>");
		Put_Line(FileDescriptor, tab & "</DataDictionary>");
		
		
		Put(FileDescriptor, tab & "<DeepNetwork modelName=" & guil & "Deep Neural Network" & guil & "  functionName=" & guil & "classification" & guil & " numberOfLayers=" & guil);
		Put(FileDescriptor, NbLayer);
		Put_Line(FileDescriptor, guil & ">");
		Put_Line(FileDescriptor, tab & tab & "<MiningSchema>");
		Put_Line(FileDescriptor, tab & tab & tab & "<MiningField name=" & guil & "image" & guil & " usageType=" & guil & "active" & guil & "/>");
		Put_Line(FileDescriptor, tab & tab & tab & "<MiningField name=" & guil & "class" & guil & " usageType=" & guil & "predicted" & guil & "/>");
		Put_Line(FileDescriptor, tab & tab & "</MiningSchema>");
		Put_Line(FileDescriptor, tab & tab & "<Outputs>");
		Put_Line(FileDescriptor, tab & tab & tab & "<OutputField dataType=" & guil & "string" & guil & "  feature=" & guil & "topClass" & guil & "/>");
		Put_Line(FileDescriptor, tab & tab & "</Outputs>");
  		
		Ada.Integer_Text_IO.Default_Width := Default_Integer_Width;
	end Initialization_PMML;
	
	
	procedure Terminate_PMML
	(FileDescriptor		: in File_Type
	)
	is
	begin
		--Warning not generic
	
		Put_Line(FileDescriptor, tab & tab & "<Weights encoding=" & guil & "hdf5" & guil & " href=" & guil & "small_model.h5" & guil & "/>");
		Put_Line(FileDescriptor, tab & "</DeepNetwork>");
	
  
		Put_Line(FileDescriptor, "</PMML>");
		
		--close(FileDescriptor); FileDescriptor Should be a variable ?
	end Terminate_PMML;



--DIFFERENT TYPE OF LAYERS


--------------------------------------------------------------------------------------------
--
--                                 CREATE INPUT LAYER
--
--------------------------------------------------------------------------------------------

	procedure Create_InputLayer
	(MyFile		: in File_Type;
	LayerName	        : in Unbounded_string;
	Size	  	 	: in ParamVal3D;
	OutboundToken		: out Token 
	)
	is
	
	Default_Integer_Width : Integer := Ada.Integer_Text_IO.Default_Width;
	Default_Long_Long_Integer_Width : Integer := Ada.Long_Long_Integer_Text_IO.Default_Width;
	begin
		Ada.Long_Long_Integer_Text_IO.Default_Width := 0;
		Ada.Integer_Text_IO.Default_Width := 0;
		
		
		OutboundToken := Size(0)*Size(1)*Size(2);
		
	
		Put_Line(MyFile, tab & tab & "<NetworkLayer");
		Put_Line(MyFile, tab & tab & "layerType=" & guil & "InputLayer" & guil);
		Put_Line(MyFile, tab & tab & "name=" & guil & LayerName & guil & ">");
		
		Put_Line(MyFile, tab & tab & tab & "<InputSize>");
		
		Put(MyFile, tab & tab & tab & tab & "<Array n=" & guil & "3" & guil & " type=" & guil & "int" & guil & ">");	
		Put(MyFile, Size(0));
		Put(MyFile, " ");
		Put(MyFile, Size(1));
		Put(MyFile, " ");
		Put(MyFile, Size(2));
		Put_Line(MyFile, "</Array>"); 
	
		Put_Line(MyFile, tab & tab & tab & "</InputSize>");
		
		Put_Line(MyFile, tab & tab & tab & "<OutboundTokens>");
		
		Put(MyFile, tab & tab & tab & tab & "<Array n=" & guil & "1" & guil & " type=" & guil & "int" & guil & ">");	
		Put(MyFile, OutboundToken);
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & "</OutboundTokens>");
		
		Put_Line(MyFile, tab & tab & "</NetworkLayer>");
		
		Ada.Long_Long_Integer_Text_IO.Default_Width := Default_Long_Long_Integer_Width;
		Ada.Integer_Text_IO.Default_Width := Default_Integer_Width;
	
	end Create_InputLayer;




--------------------------------------------------------------------------------------------
--
--                                 CREATE CONVOLUTION 2D LAYER
--
--------------------------------------------------------------------------------------------

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
	)
	is
	
	Default_Integer_Width : Integer := Ada.Integer_Text_IO.Default_Width;
	Default_Long_Long_Integer_Width : Integer := Ada.Long_Long_Integer_Text_IO.Default_Width;
	
	Temp : Token;
	Temp1 : Long_Long_Integer;
	Temp2 : Long_Long_Integer;
	Temp3 : Long_Long_Integer;
	
	begin
		Ada.Long_Long_Integer_Text_IO.Default_Width := 0;
		Ada.Integer_Text_IO.Default_Width := 0;
		
		Temp := Token(Sqrt(Float(InboundToken)));
		
		--Temp1 := Token(Sqrt(Float(KernelSize(0))));
		--OutboundToken := (((Temp - Temp1)+2*DilationRate(0)/KernelStrides(0))+1)**2;
		
		Temp1 := Long_Long_Integer(Sqrt(Float(KernelSize(0)*KernelSize(1))));
		Temp2 := DilationRate(0)*DilationRate(1);
		Temp3 := KernelStrides(0)*KernelStrides(1);
		
		
		OutboundToken := (((Temp - Temp1)+2*(Temp2)/(Temp3))+1)**2;
		
	
		Put_Line(MyFile, tab & tab & "<NetworkLayer");
		Put_Line(MyFile, tab & tab & "layerType=" & guil & "Conv2D" & guil);
		Put_Line(MyFile, tab & tab & "activation =" & guil & "relu" & guil);
		Put_Line(MyFile, tab & tab & "name=" & guil & LayerName & guil);
		Put_Line(MyFile, tab & tab & "padding=" & guil & "same" & guil & " use_bias=" & guil & "True" & guil & ">");
		
		Put_Line(MyFile, tab & tab & tab & "<InboundNodes>");
		Put_Line(MyFile, tab & tab & tab & tab & "<Array n=" & guil & "1" & guil & " type=" & guil & "string" & guil & ">" & NameInboundNode & "</Array>");
		Put_Line(MyFile, tab & tab & tab & "</InboundNodes>");
		
		
		Put_Line(MyFile, tab & tab & tab & "<InboundTokens>");
		
		Put(MyFile, tab & tab & tab & tab & "<Array n=" & guil & "1" & guil & " type=" & guil & "int" & guil & ">");	
		Put(MyFile, InboundToken);
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & "</InboundTokens>");
		Put_Line(MyFile, tab & tab & tab & "<OutboundTokens>");
		
		Put(MyFile, tab & tab & tab & tab & "<Array n=" & guil & "1" & guil & " type=" & guil & "int" & guil & ">");	
		Put(MyFile, OutboundToken);
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & "</OutboundTokens>");
		
		Put(MyFile, tab & tab & tab & "<ConvolutionalKernel channels=" & guil); 
		Put(MyFile, ChannelSize);
		Put_Line(MyFile, guil & ">");
		
		Put_Line(MyFile, tab & tab & tab & tab & "<DilationRate>");
		Put(MyFile, tab & tab & tab & tab & tab & "<Array n=" & guil & "2" & guil & " type=" & guil & "int" & guil & ">");
		Put(MyFile, DilationRate(0));
		Put(MyFile, " ");
		Put(MyFile, DilationRate(1));
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & tab & "</DilationRate>");
		
		Put_Line(MyFile, tab & tab & tab & tab & "<KernelSize>");
		Put(MyFile, tab & tab & tab & tab & tab & "<Array n=" & guil & "2" & guil & " type=" & guil & "int" & guil & ">");
		Put(MyFile, KernelSize(0));
		Put(MyFile, " ");
		Put(MyFile, KernelSize(1));
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & tab & "</KernelSize>");
		
		Put_Line(MyFile, tab & tab & tab & tab & "<KernelStrides>");
		Put(MyFile, tab & tab & tab & tab & tab & "<Array n=" & guil & "2" & guil & " type=" & guil & "int" & guil & ">");
		Put(MyFile, KernelStrides(0));
		Put(MyFile, " ");
		Put(MyFile, KernelStrides(1));
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & tab & "</KernelStrides>");
		
		Put_Line(MyFile, tab & tab & tab & "</ConvolutionalKernel>");
		
		Put_Line(MyFile, tab & tab & "</NetworkLayer>");
		
		Ada.Long_Long_Integer_Text_IO.Default_Width := Default_Long_Long_Integer_Width;
		Ada.Integer_Text_IO.Default_Width := Default_Integer_Width;

	end Create_Conv2D;




--------------------------------------------------------------------------------------------
--
--                                 CREATE MAX POOLING LAYER
--
--------------------------------------------------------------------------------------------

	procedure Create_MaxPooling2D
	(MyFile		: in File_Type;
	LayerName	        : in Unbounded_string;
	NameInboundNode 	: in Unbounded_string;
	PoolSize	       : in ParamVal2D;
	PoolStrides	       : in ParamVal2D;
	ChannelSize		: in out Natural;
	InboundToken		: in Token := 1;
	OutboundToken		: out Token 
	)
	is
	
	Default_Integer_Width : Integer := Ada.Integer_Text_IO.Default_Width;
	Default_Long_Long_Integer_Width : Integer := Ada.Long_Long_Integer_Text_IO.Default_Width;
	
	begin
		Ada.Long_Long_Integer_Text_IO.Default_Width := 0;
		Ada.Integer_Text_IO.Default_Width := 0;
		
		
		OutboundToken := InboundToken/4;
		
	
		Put_Line(MyFile, tab & tab & "<NetworkLayer");
		Put_Line(MyFile, tab & tab & "layerType=" & guil & "MaxPooling2D" & guil);
		Put_Line(MyFile, tab & tab & "axis=" & guil & "3" & guil); --A verifier pour le 3
		Put_Line(MyFile, tab & tab & "name=" & guil & LayerName & guil & ">");
		
		Put_Line(MyFile, tab & tab & tab & "<InboundNodes>");
		Put_Line(MyFile, tab & tab & tab & tab & "<Array n=" & guil & "1" & guil & " type=" & guil & "string" & guil & ">" & NameInboundNode & "</Array>");
		Put_Line(MyFile, tab & tab & tab & "</InboundNodes>");
		
		Put_Line(MyFile, tab & tab & tab & "<InboundTokens>");
		
		Put(MyFile, tab & tab & tab & tab & "<Array n=" & guil & "1" & guil & " type=" & guil & "int" & guil & ">");	
		Put(MyFile, InboundToken);
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & "</InboundTokens>");
		Put_Line(MyFile, tab & tab & tab & "<OutboundTokens>");
		
		Put(MyFile, tab & tab & tab & tab & "<Array n=" & guil & "1" & guil & " type=" & guil & "int" & guil & ">");	
		Put(MyFile, OutboundToken);
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & "</OutboundTokens>");
		
		

		Put_Line(MyFile, tab & tab & tab & "<PoolSize>");
		Put(MyFile, tab & tab & tab & tab & "<Array n=" & guil & "2" & guil & " type=" & guil & "int" & guil & ">");
		Put(MyFile, PoolSize(0)); 
		Put(MyFile, " ");
		Put(MyFile, PoolSize(1));
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & "</PoolSize>");
		
		Put_Line(MyFile, tab & tab & tab & "<PoolStrides>");
		Put(MyFile, tab & tab & tab & tab & "<Array n=" & guil & "2" & guil & " type=" & guil & "int" & guil & ">");
		Put(MyFile, PoolStrides(0));
		Put(MyFile, " ");
		Put(MyFile, PoolStrides(1));
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & "</PoolStrides>");

		
		Put_Line(MyFile, tab & tab & "</NetworkLayer>");
		
		ChannelSize := ChannelSize*2;
		
		Ada.Long_Long_Integer_Text_IO.Default_Width := Default_Long_Long_Integer_Width;
		Ada.Integer_Text_IO.Default_Width := Default_Integer_Width;

	end Create_MaxPooling2D;
	
	

--------------------------------------------------------------------------------------------
--
--                                 CREATE CONCATENATE LAYER
--
--------------------------------------------------------------------------------------------	

	procedure Create_Concatenate
	(MyFile		: in File_Type;
	LayerName	        : in Unbounded_string;
	NameInboundNode1 	: in Unbounded_string;
	NameInboundNode2 	: in Unbounded_string;
	InboundToken1		: in Token := 1;
	InboundToken2		: in Token := 1;
	OutboundToken		: out Token 
	)
	is
	
	Default_Integer_Width : Integer := Ada.Integer_Text_IO.Default_Width;
	Default_Long_Long_Integer_Width : Integer := Ada.Long_Long_Integer_Text_IO.Default_Width;
	
	begin
		Ada.Long_Long_Integer_Text_IO.Default_Width := 0;
		Ada.Integer_Text_IO.Default_Width := 0;
	
	
		
		OutboundToken := InboundToken1;
		
		
		
		Put_Line(MyFile, tab & tab & "<NetworkLayer");
		Put_Line(MyFile, tab & tab & "layerType=" & guil & "Concatenate" & guil);
		Put_Line(MyFile, tab & tab & "axis=" & guil & "3" & guil); --A verifier pour le 3
		Put_Line(MyFile, tab & tab & "name=" & guil & LayerName & guil & ">");
		
		Put_Line(MyFile, tab & tab & tab & "<InboundNodes>");
		
		Put_Line(MyFile, tab & tab & tab & tab & "<Array n=" & guil & "2" & guil & " type=" & guil & "string" & guil & ">" & NameInboundNode1 & " " & NameInboundNode2 & "</Array>");
		Put_Line(MyFile, tab & tab & tab & "</InboundNodes>");
		
		Put_Line(MyFile, tab & tab & tab & "<InboundTokens>");
		
		Put(MyFile, tab & tab & tab & tab & "<Array n=" & guil & "2" & guil & " type=" & guil & "int" & guil & ">");	
		Put(MyFile, InboundToken1);
		Put(MyFile, " ");
		Put(MyFile, InboundToken2);
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & "</InboundTokens>");
		Put_Line(MyFile, tab & tab & tab & "<OutboundTokens>");
		
		Put(MyFile, tab & tab & tab & tab & "<Array n=" & guil & "1" & guil & " type=" & guil & "int" & guil & ">");	
		Put(MyFile, OutboundToken);
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & "</OutboundTokens>");
		
		Put_Line(MyFile, tab & tab & "</NetworkLayer>");
		
		Ada.Long_Long_Integer_Text_IO.Default_Width := Default_Long_Long_Integer_Width;
		Ada.Integer_Text_IO.Default_Width := Default_Integer_Width;

	end Create_Concatenate;
	
	
	
--------------------------------------------------------------------------------------------
--
--                                 CREATE TransposedConv2D LAYER
--
--------------------------------------------------------------------------------------------

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
	)
	is
	
	Default_Integer_Width : Integer := Ada.Integer_Text_IO.Default_Width;
	Default_Long_Long_Integer_Width : Integer := Ada.Long_Long_Integer_Text_IO.Default_Width;
	
	Temp : Token;
	Temp1 : Long_Long_Integer;
	Temp11 : Long_Long_Integer;
	Temp2 : Long_Long_Integer;
	Temp3 : Long_Long_Integer;
	
	begin
		Ada.Long_Long_Integer_Text_IO.Default_Width := 0;
		Ada.Integer_Text_IO.Default_Width := 0;
		
		
		Temp := Token(Sqrt(Float(InboundToken)));
		Temp1 := Long_Long_Integer(Sqrt(Float(KernelSize(0)*KernelSize(1))));
		Temp11 := KernelSize(0)*KernelSize(1);
		Temp2 := DilationRate(0)*DilationRate(1);
		Temp3 := KernelStrides(0);
		
		
		
		OutboundToken := InboundToken * 2;
		
		ChannelSize := ChannelSize/2;
	
		Put_Line(MyFile, tab & tab & "<NetworkLayer");
		Put_Line(MyFile, tab & tab & "layerType=" & guil & "TransposedConv2D" & guil);
		Put_Line(MyFile, tab & tab & "name=" & guil & LayerName & guil);
		Put_Line(MyFile, tab & tab & "padding=" & guil & "same" & guil & " use_bias=" & guil & "True" & guil & ">");
		
		Put_Line(MyFile, tab & tab & tab & "<InboundNodes>");
		Put_Line(MyFile, tab & tab & tab & tab & "<Array n=" & guil & "1" & guil & " type=" & guil & "string" & guil & ">" & NameInboundNode & "</Array>");
		Put_Line(MyFile, tab & tab & tab & "</InboundNodes>");
		
		
		Put_Line(MyFile, tab & tab & tab & "<InboundTokens>");
		
		Put(MyFile, tab & tab & tab & tab & "<Array n=" & guil & "1" & guil & " type=" & guil & "int" & guil & ">");	
		Put(MyFile, InboundToken);
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & "</InboundTokens>");
		Put_Line(MyFile, tab & tab & tab & "<OutboundTokens>");
		
		Put(MyFile, tab & tab & tab & tab & "<Array n=" & guil & "1" & guil & " type=" & guil & "int" & guil & ">");	
		Put(MyFile, OutboundToken);
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & "</OutboundTokens>");
		
		Put(MyFile, tab & tab & tab & "<ConvolutionalKernel channels=" & guil); 
		Put(MyFile, ChannelSize);
		Put_Line(MyFile, guil & ">");
		
		Put_Line(MyFile, tab & tab & tab & tab & "<DilationRate>");
		Put(MyFile, tab & tab & tab & tab & tab & "<Array n=" & guil & "2" & guil & " type=" & guil & "int" & guil & ">");
		Put(MyFile, DilationRate(0));
		Put(MyFile, " ");
		Put(MyFile, DilationRate(1));
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & tab & "</DilationRate>");
		
		Put_Line(MyFile, tab & tab & tab & tab & "<KernelSize>");
		Put(MyFile, tab & tab & tab & tab & tab & "<Array n=" & guil & "2" & guil & " type=" & guil & "int" & guil & ">");
		Put(MyFile, KernelSize(0));
		Put(MyFile, " ");
		Put(MyFile, KernelSize(1));
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & tab & "</KernelSize>");
		
		Put_Line(MyFile, tab & tab & tab & tab & "<KernelStrides>");
		Put(MyFile, tab & tab & tab & tab & tab & "<Array n=" & guil & "2" & guil & " type=" & guil & "int" & guil & ">");
		Put(MyFile, KernelStrides(0));
		Put(MyFile, " ");
		Put(MyFile, KernelStrides(1));
		Put_Line(MyFile, "</Array>"); 
		Put_Line(MyFile, tab & tab & tab & tab & "</KernelStrides>");
		
		Put_Line(MyFile, tab & tab & tab & "</ConvolutionalKernel>");
		
		Put_Line(MyFile, tab & tab & "</NetworkLayer>");
		
		
		Ada.Long_Long_Integer_Text_IO.Default_Width := Default_Long_Long_Integer_Width;
		Ada.Integer_Text_IO.Default_Width := Default_Integer_Width;

	end Create_TransposedConv2D;

   


end cnn_pmml;
