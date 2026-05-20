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
--    $Rev: 4322 $
--    $Date: 2023-02-16 16:37:00 +0100 (lun. 06 févr. 2023) $
--    $Author: Levieux $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Text_IO;                           use Text_IO;
with ada.integer_text_IO;		  use ada.integer_text_IO; 
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with Input_sources.File; 	use Input_Sources.File;



with cnn_pmml;	use cnn_pmml;

procedure cnn is

   	quote : Character := Character'Val(39);
	guil : Character := Character'Val(34);
	tab : Character := Character'Val(9);
   
	MyFile	: File_type;
	
	KernelSize : ParamVal2D;
	PoolSize : ParamVal2D;
	
	--NbFmap_prec : ParamVal;
	NbFmap : Natural;
	
	--ImageSize_prec : ParamVal;
	ImageSize : ParamVal3D;
	
	Padding : ParamVal2D;
	Stride : ParamVal2D;

   begin

	--Set_Public_Id(Input, "UNet_model");
	--Set_System_Id(Input, "UNet_model.pmml");

	
	Put("Kernel Size ? (2 valeurs) : ");
	Get(KernelSize(0));
	Get(KernelSize(1));
	
	Put("Pool Size ? (2 valeurs) : ");
	Get(PoolSize(0));
	Get(PoolSize(1));
	
	Put("Number of Feature map on the First Convolution ? (1 valeur) : ");
	Get(NbFmap);
	
	
	Put("Image size ? (3 valeurs) : ");
	Get(ImageSize(0));
	Get(ImageSize(1));
	Get(ImageSize(2));
	
	
	Put("Padding ? (2 valeurs) : ");
	Get(Padding(0));
	Get(Padding(1));
	
	Put("Stride ? (2 valeurs) : ");
	Get(Stride(0));
	Get(Stride(1));
	
	
	
	Initialization_PMML("unet_model.pmml", MyFile);
	
	Create_InputLayer
	(MyFile,
	To_Unbounded_String("input1"),
	ImageSize
	);
	
	
	Create_Conv2D
	(MyFile, 
	To_Unbounded_String("conv1"), 
	To_Unbounded_String("input1"), 
	KernelSize, 
	Padding, 					-- Padding = DilationRate ?
	Stride, 
	NbFmap
	); 
	
	
	Create_Conv2D
	(MyFile, 
	To_Unbounded_String("conv2"), 
	To_Unbounded_String("conv1"), 
	KernelSize, 
	Padding, 
	Stride, 
	NbFmap
	);
	
	
	Create_MaxPooling2D
	(MyFile,		
	To_Unbounded_String("maxpool1"),	       	
	To_Unbounded_String("conv2"), 	
	PoolSize,
	Stride,
	NbFmap	       
	);
	
	
	Create_Conv2D
	(MyFile, 
	To_Unbounded_String("conv3"), 
	To_Unbounded_String("maxpool1"), 
	KernelSize, 
	Padding, 					-- Padding = DilationRate ?
	Stride, 
	NbFmap
	);
	
	
	Create_Conv2D
	(MyFile, 
	To_Unbounded_String("conv4"), 
	To_Unbounded_String("conv3"), 
	KernelSize, 
	Padding, 					-- Padding = DilationRate ?
	Stride, 
	NbFmap
	);
	
	
	Create_TransposedConv2D
	(MyFile, 
	To_Unbounded_String("Transpo"), 
	To_Unbounded_String("conv4"), 
	KernelSize, 
	Padding, 					-- Padding = DilationRate ?
	Stride, 
	NbFmap
	);
	

	Create_Concatenate
	(MyFile, 
	To_Unbounded_String("concat1"), 
	To_Unbounded_String("Transpo"),
	To_Unbounded_String("conv2")
	);
	
	
	Create_Conv2D
	(MyFile, 
	To_Unbounded_String("conv5"), 
	To_Unbounded_String("concat1"), 
	KernelSize, 
	Padding, 					-- Padding = DilationRate ?
	Stride, 
	NbFmap
	);
	
	
	Create_Conv2D
	(MyFile, 
	To_Unbounded_String("conv6"), 
	To_Unbounded_String("conv5"), 
	KernelSize, 
	Padding, 					-- Padding = DilationRate ?
	Stride, 
	NbFmap
	);
	
	
	--Last Layer
	Create_Conv2D
	(MyFile, 
	To_Unbounded_String("EndConv"), 
	To_Unbounded_String("conv6"), 
	KernelSize, 
	Padding, 					-- Padding = DilationRate ?
	Stride, 
	1
	);
	
	
	Terminate_PMML(MyFile);
	
	
	
	
	
	

end cnn;
