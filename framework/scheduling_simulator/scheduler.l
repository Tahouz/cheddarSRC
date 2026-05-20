
%% 
"--!TRACE".*	{ 
	           Trace := not Trace;
	           if Trace 
		          then Put_Line("--!TRACE is activated");
		          else Put_Line("--!TRACE is deactivated");
                end if; 
	}
"--".*	{ 
		      Print_Trace;
	}
"function" {
                Print_Trace;
                return Function_Token;
        }
"procedure" {
                Print_Trace;
                return Procedure_Token;
        }
"is"    {
                Print_Trace;
                return Is_Token;
        }
"array"	{
		Print_Trace; 
		return Array_Token;
	}
"double"	{
		Print_Trace; 
		return Double_Type_Token;
	}
"of"	{
		Print_Trace; 
		return Of_Token;
	}
"in"    {
		Print_Trace; 
          	return In_Token;
	}
"task"	{
		Print_Trace; 
		return Task_Token;
	}
"time_unit"	{
		Print_Trace; 
		return Time_Unit_Token;
	}
"processor"	{
		Print_Trace; 
		return Processor_Token;
	}
"message"	{
		Print_Trace; 
		return Message_Token;
	}
"buffer"	{
		Print_Trace; 
		return Buffer_Token;
	}
"resource"       {
		Print_Trace; 
          	return Resource_Token;
	}
"tasks_range"  {
		Print_Trace; 
          	return Tasks_Range_Token;
	}
"time_units_range"     {
		Print_Trace; 
          	return Time_Units_Range_Token;
	}
"processors_range"     {
		Print_Trace; 
          	return Processors_Range_Token;
	}
"messages_range"       {
		Print_Trace; 
		return Message_Token;
	}
"buffers_range"        {
		Print_Trace; 
          	return Buffers_Range_Token;
	}
"resources_range"       {
		Print_Trace; 
          	return Resources_Range_Token;
	}
"string"	{
		Print_Trace; 
		return String_Type_Token;
	}
"integer"	{
		Print_Trace; 
		return Integer_Type_Token;
      }
"clock"	{
		Print_Trace; 
		return Clock_Type_Token;
	}
"boolean"	{
		Print_Trace; 
		return Boolean_Type_Token;
	}
"last"   {
		Print_Trace; 
          	return Last_Token;
	}
"first"   {
		Print_Trace; 
          	return First_Token;
	}
"delay"   {
		Print_Trace; 
          	return Delay_Token;
	}
"add_precedence"  {
		Print_Trace; 
          	return Add_Precedence_Token;
	}
"delete_precedence" {
		Print_Trace; 
          	return Delete_Precedence_Token;
	}
"uniform"   {
		Print_Trace; 
          	return Uniform_Token;
	}
"random"   {
		Print_Trace; 
            	return Random_Type_Token;
	}
"exponential"   {
		Print_Trace; 
            	return Exponential_Token;
}
"laplace_gauss"   {
		Print_Trace; 
            	return Laplace_Gauss_Token;
      }
"exit"	{
		Print_Trace; 
            	return Exit_Token;
	}
"set"	{
		Print_Trace; 
            	return Set_Token;
	}
"for"        {
		Print_Trace; 
            	return For_Token;
	}
"return"	{
		Print_Trace; 
		return Return_Token;
        }
"max_to_index"           {
		Print_Trace; 
          	return Max_To_Index_Token;
	}
"min_to_index"           {
		Print_Trace; 
          	return Min_To_Index_Token;
	}
"max"		{
		Print_Trace; 
		return Max_Token;
	}
"min"		{
		Print_Trace; 
		return Min_Token;
	}
"lcm"		{
		Print_Trace; 
		return Lcm_Token;
	}
"put"		{
		Print_Trace; 
		return Put_Token;
	}
"if"		{
		Print_Trace; 
		return If_Token;
	}
"to_integer"       {
		Print_Trace; 
          	return To_Integer_Token;
	}
"to_double"       {
		Print_Trace; 
          	return To_Double_Token;
	}
"abs"       {
		Print_Trace; 
          	return Abs_Token;
	}
"mod"       {
		Print_Trace; 
		return Mod_Token;
	}
"end"[ \r\t]+"section"		{
		Print_Trace; 
		return End_Section_Token;
	}
"end"[ \r\t]+"loop"		{
		Print_Trace; 
		return End_Loop_Token;
	}
"end"[ \r\t]+"if"		{
		Print_Trace; 
		return End_If_Token;
	}
"then"		{
		Print_Trace; 
		return Then_Token;
	}
"end"		{
		Print_Trace; 
		return End_Token;
	}
"else"		{
		Print_Trace; 
		return Else_Token;
	}
"while"          {
		Print_Trace; 
          	return While_Token;
	}
"loop"          {
		Print_Trace; 
          	return Loop_Token;
	}
"or"         {
		Print_Trace;
		return Or_Token; 
	}
"and"         { 
		Print_Trace;
		return And_Token; 
	}
"not"         { 
		Print_Trace;
		return Not_Token; 
	}
"false"         { 
		Print_Trace;
		return False_Token; 
	}
"true"         { 
		Print_Trace;
		return True_Token;
               }
"state"         { 
		Print_Trace;
		return State_Token;
               }
"initial_state"         { 
            Print_Trace;
            return Initial_State_Token;
               }
"transition"         { 
		Print_Trace;
		return Transition_Token;
               }
"get_task_index"  { 
		Print_Trace;
          	return Get_Task_Index_Token; 
        }
"get_buffer_index" {
		Print_Trace;
          	return Get_Buffer_Index_Token; 
	}
"get_message_index" {
		Print_Trace;
          	return Get_Message_Index_Token; 
	}
"get_resource_index"  { 
		Print_Trace;
          	return Get_Resource_Index_Token; 
	}
"gather_event_analyzer_section"              {
		Print_Trace; 
          	return Gather_Event_Analyzer_Token;
	}
"display_event_analyzer_section"              {
		Print_Trace; 
          	return Display_Event_Analyzer_Token;
	}
"start_section"              {
		Print_Trace; 
		return Start_Token;
	}
"priority_section"		{
		Print_Trace; 
		return Priority_Token;
	}
"election_section"		{
		Print_Trace; 
		return Election_Token;
	}
"task_activation_section"		{
		Print_Trace; 
		return Activation_Token;
	}
"check_resource_section"		{
		Print_Trace; 
		return Check_Resource_Token;
	}
"release_resource_section"		{
		Print_Trace; 
		return Release_Resource_Token;
	}
"allocate_resource_section"		{
		Print_Trace; 
		return Allocate_Resource_Token;
	}
"automaton_section"		{
		Print_Trace; 
		return Automaton_Token;
	}
"]"        {
		Print_Trace; 
		return ']'; 
	}
"["        {
		Print_Trace; 
		return '['; 
	}
"==>"        {
		Print_Trace; 
		return Transition_Arrow_Token; 
	}
"**"        {
		Print_Trace; 
		return Exp_Token; 
	}
":="         {
		Print_Trace; 
		return Assign_Token; 
	}
","         {
		Print_Trace; 
		return ','; 
	}
"'"         {
		Print_Trace; 
		return '''; 
	}
":"         {
		Print_Trace; 
		return ':'; 
	}
"|"		{
		Print_Trace; 
		return '|';
	}
";"         {
		Print_Trace; 
		return ';'; 
	}
"("         {
		Print_Trace; 
		return '('; 
	}
")"         {
		Print_Trace; 
		return ')'; 
	}
"{"         {
		Print_Trace; 
		return '{'; 
	}
"}"         {
		Print_Trace; 
		return '}'; 
	}
"+"         {
		Print_Trace; 
		return '+'; 
	}
"/"         {
		Print_Trace; 
		return '/'; 
	}
"*"         {
		Print_Trace; 
		return '*'; 
	}
"-"         {
		Print_Trace; 
		return '-'; 
	}
"<="         {
		Print_Trace; 
		return Inf_Equal_Token; 
	}
">="         {
		Print_Trace; 
		return Sup_Equal_Token; 
	}
"<"         {
		Print_Trace; 
		return Inf_Token; 
	}
"&"         {
		Print_Trace; 
		return Concat_Token; 
	}
">"         {
		Print_Trace; 
		return Sup_Token; 
	}
"/="         {
		Print_Trace; 
		return Not_Equal_Token; 
	}
"="         {
		Print_Trace; 
		return Equal_Token; 
	}
"?"         {
		Print_Trace; 
		return '?'; 
	}
"!"         {
		Print_Trace; 
		return '!'; 
	}
\".*\"      {
		Print_Trace; 
		return String_Token; 
	}
[a-zA-Z]([_|"."]?[a-zA-Z0-9])*      {
		Print_Trace; 
		return Identifier_Token; 
	}
[0-9]+"."[0-9]+      {
		Print_Trace; 
		return Double_Token; 
	}
[0-9]+      {
		Print_Trace; 
		return Integer_Token; 
	}
\n          { 
		Linenum; 
		Print_Trace;
	}
[ \r\t\f]+ {
		Print_Trace;
	}
%%

with Scheduler_Tokens; 
use  Scheduler_Tokens;

package Scheduler_Lex is
 
  Lines          : Positive := 1;
  Num_Errors     : Natural  := 0;
  Trace          : Boolean  := False;

  procedure Print_Trace;
  procedure Linenum;

  function Yylex return Token;


end Scheduler_Lex;

----------------------------------------------------------------


with Text_Io;
use Text_Io;


package body Scheduler_Lex is


  procedure Print_Trace is
  begin
	if Trace then
		Text_Io.Put(Yytext);
	end if;
  end Print_Trace;


  procedure Linenum is
	Line_Number_String : constant String := Integer'Image (Lines);
  begin
	Lines := Lines + 1;
	if Trace then
       Put("L"); 
       Put(Line_Number_String);
       for i in 1 .. 5 - Integer(Line_Number_String'Length )
        loop
          Text_Io.Put(" ");
        end loop;
     end if;
  end Linenum;




##

end Scheduler_Lex;

