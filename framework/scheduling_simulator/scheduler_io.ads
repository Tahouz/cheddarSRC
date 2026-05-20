with scheduler_dfa;         use scheduler_dfa;
with Text_IO;               use Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package scheduler_io is
   user_input_file  : File_Type;
   user_output_file : File_Type;
   NULL_IN_INPUT : exception;
   AFLEX_INTERNAL_ERROR : exception;
   UNEXPECTED_LAST_MATCH : exception;
   PUSHBACK_OVERFLOW : exception;
   AFLEX_SCANNER_JAMMED : exception;
   type eob_action_type is
     (eob_act_restart_scan, eob_act_end_of_file, eob_act_last_match);
   YY_END_OF_BUFFER_CHAR : constant Character := ASCII.NUL;
   yy_n_chars : Integer;       -- number of characters read into yy_ch_buf

-- true when we've seen an EOF for the current input file
   yy_eof_has_been_seen : Boolean;

   procedure YY_INPUT
     (buf      :    out unbounded_character_array;
      result   :    out Integer;
      max_size : in     Integer);
   function yy_get_next_buffer return eob_action_type;
   procedure yyunput (c : Character; yy_bp : in out Integer);
   procedure unput (c : Character);
   function input return Character;
   procedure output (c : Character);
   function yywrap return Boolean;
   procedure Open_Input (fname : in Unbounded_String);
   procedure Close_Input;
   procedure Create_Output (fname : in String := "");
   procedure Close_Output;

end scheduler_io;
