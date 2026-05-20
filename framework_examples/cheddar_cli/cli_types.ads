with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;

with Call_Framework_Interface;
use Call_Framework_Interface;

package cli_types is

   type Print_Type is (analysis, system, event_table);
   type F_S_T_Array is array(1 .. 50) of Call_Framework_Interface.Framework_Statement_Type;
   type Cli_Config is record
      Input_File     : Unbounded_String := Null_Unbounded_String;
      Output_To_File : Boolean := False;
      Output_File    : Unbounded_String := Null_Unbounded_String;

      Target         : Unbounded_String := Null_Unbounded_String;

      Format         : Output_Format := String_Output;

      Print_Mode     : Print_Type := analysis;

      Request_Types  : F_S_T_Array;
      Request_Count  : Natural := 0;
      
   end record;
   Version : constant String := "0.2";
end cli_types;