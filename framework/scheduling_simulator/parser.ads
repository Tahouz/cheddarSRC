with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Interpreter;           use Interpreter;
use Interpreter.Sets_Type_Package;
with expressions; use expressions;
use expressions.variables_type_package;
with section_set; use section_set;
use section_set.package_generic_section_set;

package Parser is

   -- Function to parse a scheduler behavior
   --
   procedure Yyparse;

   -- Initialize parser Data
   -- First_file prepars the parser to read the first file.
   -- Next_file prepars to read all other files
   --
   procedure First_File (A_File_Name : in Unbounded_String);
   procedure Next_File (A_File_Name : in Unbounded_String);

   -- Stores the set of sections with their code
   --
   Root_Statement_Pointer : sections_set;

   -- Table to store the list of Variables of
   -- a parametric scheduler
   --
   Variables_Table : variables_table_type;

   -- Table to store the list of "set" statements
   -- in a parametric scheduler
   --
   Sets_Table : sets_table_type;

end Parser;
