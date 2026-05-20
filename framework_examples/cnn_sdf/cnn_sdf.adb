with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with convert_unbounded_strings;

with Text_IO; use Text_IO;

with Systems; use Systems;

with Call_Framework;            use Call_Framework;
with Call_Framework_Interface;  use Call_Framework_Interface;


with Framework_Config; use Framework_Config;





with Sax.Readers; 			use Sax.Readers;
with Input_sources.File; 		use Input_Sources.File;
with pmml_to_chd;			use pmml_to_chd;
with Ada.Text_IO; 			use Ada.Text_IO;

procedure cnn_sdf is

	MyReader	: pmml_to_chd.Reader;
	Input 		: File_Input;



	begin

	   -- Initialize the Cheddar framework
	   --
	   Call_Framework.initialize (False);

	   -- Initialize the System
	   --

	   Initialize (MyReader.Current_sys);


		Init_System(MyReader);

		--Init le Parser et ele fichier xml

		--Set_Public_Id(Input, "Preferences file");
		--Set_System_Id(Input, "./framework_examples/cnn_test.xml");
		
		Open("unet_model.pmml", Input);

		Set_Feature(MyReader, Namespace_Prefixes_Feature, False);
		Set_Feature(MyReader, Namespace_Feature, False);
		Set_Feature(MyReader, Validation_Feature, False);

		Parse(MyReader, Input);


	    Close (Input);

	    Put_line("Job Done! Parsing Done");


end cnn_sdf;
