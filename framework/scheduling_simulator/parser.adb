
with Text_IO;                use Text_IO;
with Ada.Exceptions;         use Ada.Exceptions;
with Framework_Config;       use Framework_Config;
with Scheduler_Lex;          use Scheduler_Lex;
with scheduler_dfa;          use scheduler_dfa;
with Scheduler_Goto;         use Scheduler_Goto;
with Scheduler_Tokens;       use Scheduler_Tokens;
with Scheduler_Shift_Reduce; use Scheduler_Shift_Reduce;
with translate;              use translate;
with unbounded_strings;      use unbounded_strings;
with Simulations;            use Simulations;
with Simulations.extended;   use Simulations.extended;
with Parameters;             use Parameters;
use Parameters.User_Defined_Parameters_Table_Package;
with task_set; use task_set;
use task_set.generic_task_set;
with Statements;         use Statements;
with Sections;           use Sections;
with Laws;               use Laws;
with doubles; use doubles;
with Automaton;          use Automaton;
with Automaton.extended; use Automaton.extended;
use Automaton.State_Lists_Package;
use Automaton.Transition_Lists_Package;

package body Parser is

   -- These variables store statements of inner blocks of code
   --
   Else_Inner_Statement_Ptr : array
   (0 .. Max_Block_Level) of generic_statement_ptr;
   Else_Inner_Statement_Index : Natural := 0;
   Then_Inner_Statement_Ptr   : array
   (0 .. Max_Block_Level) of generic_statement_ptr;
   Then_Inner_Statement_Index : Natural := 0;
   Loop_Inner_Statement_Ptr   : array
   (0 .. Max_Block_Level) of generic_statement_ptr;
   Loop_Inner_Statement_Index : Natural := 0;

   -- File name that we are currently treating
   --
   File_Name : Unbounded_String;

   procedure Yyerror (S : String) is
   begin
      Raise_Exception
        (expressions.syntax_error'identity,
         "file " &
         To_String (File_Name) &
         " token """ &
         To_String
           (To_Unbounded_String (YYText) &
            """" &
            lb_comma &
            " line" &
            Positive'image (Lines) &
            lb_comma &
            To_Unbounded_String (S)));
   end Yyerror;

   -- This variables stores the data related
   -- to the section we currently parse
   --
   Current_Section_Type            : sections_type;
   Current_Statement_Pointer       : generic_statement_ptr       := null;
   Current_Synchronization_Section : synchronization_section_ptr := null;
   Current_Computation_Section     : computation_section_ptr;
   Current_Section_Name            : Unbounded_String;

   procedure First_File (A_File_Name : in Unbounded_String) is
   begin
      Else_Inner_Statement_Index := 0;
      Then_Inner_Statement_Index := 0;
      Loop_Inner_Statement_Index := 0;

      initialize (Sets_Table);
      initialize (Root_Statement_Pointer);

      Scheduler_Lex.Lines := 1;
      File_Name           := A_File_Name;
   end First_File;

   procedure Next_File (A_File_Name : in Unbounded_String) is
   begin
      Scheduler_Lex.Lines := 1;
      File_Name           := A_File_Name;
   end Next_File;

   procedure Yyparse is

      -- Rename User Defined Packages to Internal Names.
      package yy_goto_tables renames Scheduler_Goto;
      package yy_shift_reduce_tables renames Scheduler_Shift_Reduce;
      package yy_tokens renames Scheduler_Tokens;

      use yy_tokens, yy_goto_tables, yy_shift_reduce_tables;

      procedure yyerrok;
      procedure yyclearin;

      package yy is

         -- the size of the value and state stacks
         stack_size : constant Natural := 300;

         -- subtype rule         is natural;
         subtype parse_state is Natural;
         -- subtype nonterminal  is integer;

         -- encryption constants
         default           : constant := -1;
         first_shift_entry : constant := 0;
         accept_code       : constant := -3001;
         error_code        : constant := -3000;

         -- stack data used by the parser
         tos         : Natural := 0;
         value_stack : array (0 .. stack_size) of yy_tokens.yystype;
         state_stack : array (0 .. stack_size) of parse_state;

         -- current input symbol and action the parser is on
         action       : Integer;
         rule_id      : rule;
         input_symbol : yy_tokens.token;

         -- error recovery flag
         error_flag : Natural := 0;
         -- indicates  3 - (number of valid shifts after an error occurs)

         look_ahead : Boolean := True;
         index      : Integer;

         -- Is Debugging option on or off
         DEBUG : constant Boolean := False;

      end yy;

      function goto_state
        (state : yy.parse_state;
         sym   : nonterminal) return yy.parse_state;

      function parse_action
        (state : yy.parse_state;
         t     : yy_tokens.token) return Integer;

      pragma inline (goto_state, parse_action);

      function goto_state
        (state : yy.parse_state;
         sym   : nonterminal) return yy.parse_state
      is
         index : Integer;
      begin
         index := GOTO_OFFSET (state);
         while Integer (Goto_Matrix (index).Nonterm) /= sym loop
            index := index + 1;
         end loop;
         return Integer (Goto_Matrix (index).Newstate);
      end goto_state;

      function parse_action
        (state : yy.parse_state;
         t     : yy_tokens.token) return Integer
      is
         index   : Integer;
         tok_pos : Integer;
         default : constant Integer := -1;
      begin
         tok_pos := yy_tokens.token'pos (t);
         index   := SHIFT_REDUCE_OFFSET (state);
         while Integer (Shift_Reduce_Matrix (index).T) /= tok_pos
           and then Integer (Shift_Reduce_Matrix (index).T) /= default
         loop
            index := index + 1;
         end loop;
         return Integer (Shift_Reduce_Matrix (index).Act);
      end parse_action;

-- error recovery stuff

      procedure handle_error is
         temp_action : Integer;
      begin

         if yy.error_flag = 3 then -- no shift yet, clobber input.
            if yy.DEBUG then
               Text_IO.Put_Line
                 ("Ayacc.YYParse: Error Recovery Clobbers " &
                  yy_tokens.token'image (yy.input_symbol));
            end if;
            if yy.input_symbol = yy_tokens.end_of_input then  -- don't discard,
               if yy.DEBUG then
                  Text_IO.Put_Line
                    ("Ayacc.YYParse: Can't discard END_OF_INPUT, quiting...");
               end if;
               raise yy_tokens.Syntax_Error;
            end if;

            yy.look_ahead := True;   -- get next token
            return;                  -- and try again...
         end if;

         if yy.error_flag = 0 then -- brand new error
            Yyerror ("Syntax Error");
         end if;

         yy.error_flag := 3;

         -- find state on stack where error is a valid shift --

         if yy.DEBUG then
            Text_IO.Put_Line
              ("Ayacc.YYParse: Looking for state with error as valid shift");
         end if;

         loop
            if yy.DEBUG then
               Text_IO.Put_Line
                 ("Ayacc.YYParse: Examining State " &
                  yy.parse_state'image (yy.state_stack (yy.tos)));
            end if;
            temp_action := parse_action (yy.state_stack (yy.tos), error);

            if temp_action >= yy.first_shift_entry then
               if yy.tos = yy.stack_size then
                  Text_IO.Put_Line (" Stack size exceeded on state_stack");
                  raise yy_tokens.Syntax_Error;
               end if;
               yy.tos                  := yy.tos + 1;
               yy.state_stack (yy.tos) := temp_action;
               exit;
            end if;

            Decrement_Stack_Pointer : begin
               yy.tos := yy.tos - 1;
            exception
               when Constraint_Error =>
                  yy.tos := 0;
            end Decrement_Stack_Pointer;

            if yy.tos = 0 then
               if yy.DEBUG then
                  Text_IO.Put_Line
                    ("Ayacc.YYParse: Error recovery popped entire stack, aborting...");
               end if;
               raise yy_tokens.Syntax_Error;
            end if;
         end loop;

         if yy.DEBUG then
            Text_IO.Put_Line
              ("Ayacc.YYParse: Shifted error token in state " &
               yy.parse_state'image (yy.state_stack (yy.tos)));
         end if;

      end handle_error;

      -- print debugging information for a shift operation
      procedure shift_debug
        (state_id : yy.parse_state;
         lexeme   : yy_tokens.token)
      is
      begin
         Text_IO.Put_Line
           ("Ayacc.YYParse: Shift " &
            yy.parse_state'image (state_id) &
            " on input symbol " &
            yy_tokens.token'image (lexeme));
      end shift_debug;

      -- print debugging information for a reduce operation
      procedure reduce_debug (rule_id : rule; state_id : yy.parse_state) is
      begin
         Text_IO.Put_Line
           ("Ayacc.YYParse: Reduce by rule " &
            rule'image (rule_id) &
            " goto state " &
            yy.parse_state'image (state_id));
      end reduce_debug;

      -- make the parser believe that 3 valid shifts have occured.
      -- used for error recovery.
      procedure yyerrok is
      begin
         yy.error_flag := 0;
      end yyerrok;

      -- called to clear input symbol that caused an error.
      procedure yyclearin is
      begin
         -- yy.input_symbol := yylex;
         yy.look_ahead := True;
      end yyclearin;

   begin
      -- initialize by pushing state 0 and getting the first input symbol
      yy.state_stack (yy.tos) := 0;

      loop

         yy.index := SHIFT_REDUCE_OFFSET (yy.state_stack (yy.tos));
         if Integer (Shift_Reduce_Matrix (yy.index).T) = yy.default then
            yy.action := Integer (Shift_Reduce_Matrix (yy.index).Act);
         else
            if yy.look_ahead then
               yy.look_ahead := False;

               yy.input_symbol := Yylex;
            end if;
            yy.action :=
              parse_action (yy.state_stack (yy.tos), yy.input_symbol);
         end if;

         if yy.action >= yy.first_shift_entry then  -- SHIFT

            if yy.DEBUG then
               shift_debug (yy.action, yy.input_symbol);
            end if;

            -- Enter new state
            if yy.tos = yy.stack_size then
               Text_IO.Put_Line (" Stack size exceeded on state_stack");
               raise yy_tokens.Syntax_Error;
            end if;
            yy.tos                  := yy.tos + 1;
            yy.state_stack (yy.tos) := yy.action;
            yy.value_stack (yy.tos) := YYLVal;

            if yy.error_flag > 0 then  -- indicate a valid shift
               yy.error_flag := yy.error_flag - 1;
            end if;

            -- Advance lookahead
            yy.look_ahead := True;

         elsif yy.action = yy.error_code then       -- ERROR

            handle_error;

         elsif yy.action = yy.accept_code then
            if yy.DEBUG then
               Text_IO.Put_Line ("Ayacc.YYParse: Accepting Grammar...");
            end if;
            exit;

         else -- Reduce Action

            -- Convert action into a rule
            yy.rule_id := -1 * yy.action;

            -- Execute User Action
            -- user_action(yy.rule_id);

            case yy.rule_id is

               when 14 =>
--#line  100

                  Current_Section_Type      := check_resource_type;
                  Current_Statement_Pointer := null;

               when 15 =>
--#line  105

                  if Current_Computation_Section /= null then
                     Current_Computation_Section.name := Current_Section_Name;
                  end if;

               when 16 =>
--#line  112

                  Current_Section_Type      := release_resource_type;
                  Current_Statement_Pointer := null;

               when 17 =>
--#line  117

                  if Current_Computation_Section /= null then
                     Current_Computation_Section.name := Current_Section_Name;
                  end if;

               when 18 =>
--#line  124

                  Current_Section_Type      := allocate_resource_type;
                  Current_Statement_Pointer := null;

               when 19 =>
--#line  129

                  if Current_Computation_Section /= null then
                     Current_Computation_Section.name := Current_Section_Name;
                  end if;

               when 20 =>
--#line  136

                  Current_Section_Type      := start_type;
                  Current_Statement_Pointer := null;

               when 21 =>
--#line  141

                  if Current_Computation_Section /= null then
                     Current_Computation_Section.name := Current_Section_Name;
                  end if;

               when 22 =>
--#line  148

                  Current_Section_Type      := gather_event_analyzer_type;
                  Current_Statement_Pointer := null;

               when 23 =>
--#line  153

                  if Current_Computation_Section /= null then
                     Current_Computation_Section.name := Current_Section_Name;
                  end if;

               when 24 =>
--#line  160

                  Current_Section_Type      := display_event_analyzer_type;
                  Current_Statement_Pointer := null;

               when 25 =>
--#line  165

                  if Current_Computation_Section /= null then
                     Current_Computation_Section.name := Current_Section_Name;
                  end if;

               when 26 =>
--#line  172

                  Current_Section_Type      := activation_type;
                  Current_Statement_Pointer := null;

               when 27 =>
--#line  177

                  if Current_Computation_Section /= null then
                     Current_Computation_Section.name := Current_Section_Name;
                  end if;

               when 28 =>
--#line  184

                  Current_Section_Type      := election_type;
                  Current_Statement_Pointer := null;

               when 29 =>
--#line  189

                  if Current_Computation_Section /= null then
                     Current_Computation_Section.name := Current_Section_Name;
                  end if;

               when 30 =>
--#line  196

                  Current_Section_Type      := priority_type;
                  Current_Statement_Pointer := null;

               when 31 =>
--#line  201

                  if Current_Computation_Section /= null then
                     Current_Computation_Section.name := Current_Section_Name;
                  end if;

               when 32 =>
--#line  209

                  Current_Section_Type            := automaton_type;
                  Current_Synchronization_Section := null;

               when 33 =>
--#line  214

                  if Current_Synchronization_Section /= null then
                     Current_Synchronization_Section.name :=
                       Current_Section_Name;
                  end if;

               when 34 =>
--#line  223

                  Current_Section_Name := yy.value_stack (yy.tos).String_Value;

               when 35 =>
--#line  227

                  Current_Section_Name := empty_string;

               when 36 =>
--#line  234

                  if yy.value_stack (yy.tos).State /= null then
                     if (Current_Synchronization_Section = null) then
                        Current_Synchronization_Section :=
                          new synchronization_section;
                        Current_Synchronization_Section.file_name := File_Name;
                        Current_Synchronization_Section.section_type :=
                          Current_Section_Type;
                        add
                          (Root_Statement_Pointer,
                           generic_section_ptr
                             (Current_Synchronization_Section));
                     end if;
                     add
                       (Current_Synchronization_Section.state_list,
                        yy.value_stack (yy.tos).State);
                  end if;

               when 38 =>
--#line  251

                  if yy.value_stack (yy.tos).Transition /= null then
                     add
                       (Current_Synchronization_Section.transition_list,
                        yy.value_stack (yy.tos).Transition);
                  end if;

               when 40 =>
--#line  261

                  declare
                     New_State : state_ptr;
                  begin
                     New_State      := new state;
                     New_State.name :=
                       yy.value_stack (yy.tos - 3).String_Value;
                     New_State.is_initial := True;

                     YYVal.State := New_State;
                  end;

               when 41 =>
--#line  272

                  declare
                     New_State : state_ptr;
                  begin
                     New_State      := new state;
                     New_State.name :=
                       yy.value_stack (yy.tos - 3).String_Value;
                     New_State.is_initial := False;

                     YYVal.State := New_State;
                  end;

               when 42 =>
--#line  284

                  YYVal.Expression := yy.value_stack (yy.tos).Expression;

               when 43 =>
--#line  288

                  YYVal.Expression := null;

               when 44 =>
--#line  294

                  YYVal.Statement := yy.value_stack (yy.tos).Statement;

               when 45 =>
--#line  298

                  YYVal.Statement := null;

               when 46 =>
--#line  305

                  declare
                     New_Sync : synchronization_ptr;
                  begin
                     New_Sync                      := new synchronization;
                     New_Sync.name := yy.value_stack (yy.tos - 1).String_Value;
                     New_Sync.synchronization_type := receive;

                     YYVal.Synchronization := New_Sync;
                  end;

               when 47 =>
--#line  316

                  declare
                     New_Sync : synchronization_ptr;
                  begin
                     New_Sync                      := new synchronization;
                     New_Sync.name := yy.value_stack (yy.tos - 1).String_Value;
                     New_Sync.synchronization_type := send;

                     YYVal.Synchronization := New_Sync;
                  end;

               when 48 =>
--#line  327

                  YYVal.Synchronization := null;

               when 49 =>
--#line  333

                  declare
                     New_Transition : transition_ptr;
                  begin
                     New_Transition      := new transition;
                     New_Transition.name :=
                       yy.value_stack (yy.tos - 11).String_Value &
                       To_Unbounded_String ("==>") &
                       yy.value_stack (yy.tos - 1).String_Value;

                     begin
                        New_Transition.from_state :=
                          search_state
                            (Current_Synchronization_Section.state_list,
                             yy.value_stack (yy.tos - 11).String_Value);
                     exception
                        when state_not_found =>
                           Raise_Exception
                             (expressions.syntax_error'identity,
                              "file " &
                              To_String (File_Name) &
                              " line " &
                              Scheduler_Lex.Lines'img &
                              To_String
                                (lb_comma &
                                 "State " &
                                 yy.value_stack (yy.tos - 11).String_Value &
                                 " not found"));
                     end;

                     begin
                        New_Transition.to_state :=
                          search_state
                            (Current_Synchronization_Section.state_list,
                             yy.value_stack (yy.tos - 1).String_Value);
                     exception
                        when state_not_found =>
                           Raise_Exception
                             (expressions.syntax_error'identity,
                              "file " &
                              To_String (File_Name) &
                              " line " &
                              Scheduler_Lex.Lines'img &
                              To_String
                                (lb_comma &
                                 "State " &
                                 yy.value_stack (yy.tos - 1).String_Value &
                                 " not found"));
                     end;

                     New_Transition.guards :=
                       yy.value_stack (yy.tos - 8).Expression;
                     New_Transition.clocks :=
                       yy.value_stack (yy.tos - 6).Statement;
                     New_Transition.synchronization :=
                       yy.value_stack (yy.tos - 4).Synchronization;

                     YYVal.Transition := New_Transition;
                  end;

               when 50 =>
--#line  366

                  begin
                     if yy.value_stack (yy.tos).Statement /= null then
                        if (Current_Statement_Pointer = null) then
                           Current_Statement_Pointer :=
                             yy.value_stack (yy.tos).Statement;
                           Current_Computation_Section :=
                             new computation_section;
                           Current_Computation_Section.file_name := File_Name;
                           Current_Computation_Section.section_type :=
                             Current_Section_Type;
                           Current_Computation_Section.first_statement :=
                             yy.value_stack (yy.tos).Statement;
                           add
                             (Root_Statement_Pointer,
                              generic_section_ptr
                                (Current_Computation_Section));
                        else
                           Current_Statement_Pointer.next_statement :=
                             yy.value_stack (yy.tos).Statement;
                           Current_Statement_Pointer :=
                             yy.value_stack (yy.tos).Statement;
                        end if;
                     end if;
                  end;

               when 52 =>
--#line  388

                  YYVal.Statement := yy.value_stack (yy.tos - 2).Statement;

               when 53 =>
--#line  392

                  YYVal.Statement := null;

               when 54 =>
--#line  398

                  yy.value_stack (yy.tos - 1).Statement.next_statement :=
                    yy.value_stack (yy.tos).Statement;

                  YYVal.Statement := yy.value_stack (yy.tos - 1).Statement;

               when 55 =>
--#line  403

                  YYVal.Statement := yy.value_stack (yy.tos).Statement;

               when 56 =>
--#line  407

                  YYVal.Statement := null;

               when 57 =>
--#line  412

                  yy.value_stack (yy.tos - 1).Statement.next_statement :=
                    yy.value_stack (yy.tos).Statement;

                  YYVal.Statement := yy.value_stack (yy.tos - 1).Statement;

               when 58 =>
--#line  417

                  YYVal.Statement := yy.value_stack (yy.tos).Statement;

               when 59 =>
--#line  421

                  YYVal.Statement := null;

               when 60 =>
--#line  429

                  declare
                     New_Put : put_statement_ptr;
                  begin

                     -- Firstly, the Put_Parameter
                     --
                     if
                       ((yy.value_stack (yy.tos - 3).Expression /= null) and
                        (yy.value_stack (yy.tos - 2).Expression = null)) or
                       ((yy.value_stack (yy.tos - 3).Expression = null) and
                        (yy.value_stack (yy.tos - 2).Expression /= null))
                     then
                        Raise_Exception
                          (expressions.syntax_error'identity,
                           "file " &
                           To_String (File_Name) &
                           " line " &
                           Scheduler_Lex.Lines'img &
                           To_String
                             (lb_comma & "0 or 2 parameters should be given"));
                     end if;

                     New_Put                            := new put_statement;
                     New_Put.expression_to_be_displayed :=
                       yy.value_stack (yy.tos - 4).Expression;
                     New_Put.put_from :=
                       yy.value_stack (yy.tos - 3).Expression;
                     New_Put.put_to := yy.value_stack (yy.tos - 2).Expression;
                     New_Put.line_number := Scheduler_Lex.Lines;
                     New_Put.file_name   := File_Name;

                     YYVal.Statement := generic_statement_ptr (New_Put);
                  end;

               when 61 =>
--#line  454

                  declare
                     New_Delete_Precedence : delete_precedence_statement_ptr;
                     Pos                   : Natural;
                     Parameter             : Unbounded_String :=
                       yy.value_stack (yy.tos - 1).String_Value;
                     Task1, Task2 : Unbounded_String;

                  begin
                     Pos   := Index (Parameter, "/", 1);
                     Task1 := Unbounded_Slice (Parameter, 1, Pos - 1);
                     Task2 :=
                       Unbounded_Slice
                         (Parameter,
                          Pos + 1,
                          Length (Parameter));

                     New_Delete_Precedence := new delete_precedence_statement;
                     New_Delete_Precedence.Delete_Source := Task1;
                     New_Delete_Precedence.Delete_Sink   := Task2;

                     New_Delete_Precedence.line_number := Scheduler_Lex.Lines;
                     New_Delete_Precedence.file_name   := File_Name;

                     YYVal.Statement :=
                       generic_statement_ptr (New_Delete_Precedence);
                  end;

               when 62 =>
--#line  478

                  declare
                     New_Add_Precedence : add_precedence_statement_ptr;
                     Pos                : Natural;
                     Parameter          : Unbounded_String :=
                       yy.value_stack (yy.tos - 1).String_Value;
                     Task1, Task2 : Unbounded_String;

                  begin
                     Pos   := Index (Parameter, "/", 1);
                     Task1 := Unbounded_Slice (Parameter, 1, Pos - 1);
                     Task2 :=
                       Unbounded_Slice
                         (Parameter,
                          Pos + 1,
                          Length (Parameter));

                     New_Add_Precedence := new add_precedence_statement;
                     New_Add_Precedence.Add_Source := Task1;
                     New_Add_Precedence.Add_Sink   := Task2;

                     New_Add_Precedence.line_number := Scheduler_Lex.Lines;
                     New_Add_Precedence.file_name   := File_Name;

                     YYVal.Statement :=
                       generic_statement_ptr (New_Add_Precedence);
                  end;

               when 63 =>
--#line  503

                  declare
                     New_Assign     : assign_statement_ptr;
                     New_Var        : variable_record_ptr;
                     New_Array_Expr : array_variable_expression_ptr;
                     New_Var_Expr   : variable_expression_ptr;

                  begin

                     -- Is the Variable already exists ?
                     --
                     for I in 0 .. Variables_Table.nb_entries - 1 loop
                        if
                          (Variables_Table.entries (I).variable.name =
                           yy.value_stack (yy.tos - 4).String_Value)
                        then
                           Raise_Exception
                             (expressions.syntax_error'identity,
                              "file " &
                              To_String (File_Name) &
                              " line " &
                              Scheduler_Lex.Lines'img &
                              To_String
                                (lb_comma &
                                 yy.value_stack (yy.tos - 4).String_Value &
                                 lb_comma &
                                 lb_identifier_already_declared
                                   (Current_Language)));
                        end if;
                     end loop;

                     -- Create the Variable (Array or not)
                     --
                     New_Var := new variable_record;

                     if
                       (yy.value_stack (yy.tos - 2).Variable_Type_Value =
                        simulation_array_double) or
                       (yy.value_stack (yy.tos - 2).Variable_Type_Value =
                        simulation_array_integer) or
                       (yy.value_stack (yy.tos - 2).Variable_Type_Value =
                        simulation_array_boolean) or
                       (yy.value_stack (yy.tos - 2).Variable_Type_Value =
                        simulation_array_clock) or
                       (yy.value_stack (yy.tos - 2).Variable_Type_Value =
                        simulation_array_string) or
                       (yy.value_stack (yy.tos - 2).Variable_Type_Value =
                        simulation_array_random) or
                       (yy.value_stack (yy.tos - 2).Variable_Type_Value =
                        simulation_time_unit_array_double) or
                       (yy.value_stack (yy.tos - 2).Variable_Type_Value =
                        simulation_time_unit_array_integer) or
                       (yy.value_stack (yy.tos - 2).Variable_Type_Value =
                        simulation_time_unit_array_boolean) or
                       (yy.value_stack (yy.tos - 2).Variable_Type_Value =
                        simulation_time_unit_array_string)
                     then

                        New_Array_Expr := new array_variable_expression;
                        New_Array_Expr.variable_type :=
                          yy.value_stack (yy.tos - 2).Variable_Type_Value;
                        New_Array_Expr.name :=
                          yy.value_stack (yy.tos - 4).String_Value;
                        New_Var.variable :=
                          variable_expression_ptr (New_Array_Expr);
                     else
                        New_Var_Expr               := new variable_expression;
                        New_Var_Expr.variable_type :=
                          yy.value_stack (yy.tos - 2).Variable_Type_Value;
                        New_Var_Expr.name :=
                          yy.value_stack (yy.tos - 4).String_Value;
                        New_Var.variable := New_Var_Expr;
                     end if;

                     add (Variables_Table, New_Var);

                     -- Create simulation data
                     --
                     Variables_Table.entries (Variables_Table.nb_entries - 1)
                       .simulation :=
                       new simulation_value
                       (variable_expression_ptr
                          (Variables_Table.entries
                             (Variables_Table.nb_entries - 1)
                             .variable)
                          .variable_type);

                     -- If Assignement is not null, we should register
                     -- a new Assignement
                     --
                     if yy.value_stack (yy.tos - 1).Expression /= null then
                        New_Assign        := new assign_statement;
                        New_Assign.lvalue :=
                          generic_expression_ptr (New_Var_Expr);
                        New_Assign.rvalue :=
                          yy.value_stack (yy.tos - 1).Expression;
                        New_Assign.line_number := Scheduler_Lex.Lines;
                        New_Assign.file_name   := File_Name;

                        YYVal.Statement := generic_statement_ptr (New_Assign);

                     else

                        YYVal.Statement := null;
                     end if;
                  end;

               when 64 =>
--#line  582

                  declare
                     New_Clock : clock_statement_ptr;
                  begin
                     New_Clock             := new clock_statement;
                     New_Clock.line_number := Scheduler_Lex.Lines;
                     New_Clock.file_name   := File_Name;
                     New_Clock.lvalue      :=
                       yy.value_stack (yy.tos - 1).Expression;

                     YYVal.Statement := generic_statement_ptr (New_Clock);
                  end;

               when 65 =>
--#line  595

                  declare
                     New_Assign : assign_statement_ptr;
                  begin
                     New_Assign             := new assign_statement;
                     New_Assign.line_number := Scheduler_Lex.Lines;
                     New_Assign.file_name   := File_Name;
                     New_Assign.lvalue      :=
                       yy.value_stack (yy.tos - 3).Expression;
                     New_Assign.rvalue :=
                       yy.value_stack (yy.tos - 1).Expression;

                     YYVal.Statement := generic_statement_ptr (New_Assign);
                  end;

               when 66 =>
--#line  611

                  declare
                     New_If : if_statement_ptr;

                  begin
                     New_If                 := new if_statement;
                     New_If.line_number     := Scheduler_Lex.Lines;
                     New_If.file_name       := File_Name;
                     New_If.bool_expression :=
                       yy.value_stack (yy.tos - 3).Expression;
                     New_If.then_statement :=
                       yy.value_stack (yy.tos - 1).Statement;
                     New_If.else_statement :=
                       yy.value_stack (yy.tos).Statement;

                     YYVal.Statement := generic_statement_ptr (New_If);
                  end;

               when 67 =>
--#line  629

                  declare
                     New_Return : return_statement_ptr;

                  begin
                     New_Return              := new return_statement;
                     New_Return.return_value :=
                       yy.value_stack (yy.tos).Expression;
                     New_Return.line_number := Scheduler_Lex.Lines;
                     New_Return.file_name   := File_Name;

                     YYVal.Statement := generic_statement_ptr (New_Return);
                  end;

               when 68 =>
--#line  645

                  declare
                     New_Exit : exit_statement_ptr;

                  begin
                     New_Exit             := new exit_statement;
                     New_Exit.line_number := Scheduler_Lex.Lines;
                     New_Exit.file_name   := File_Name;

                     YYVal.Statement := generic_statement_ptr (New_Exit);
                  end;

               when 69 =>
--#line  658

                  declare
                     New_For : for_statement_ptr;

                  begin
                     New_For          := new for_statement;
                     New_For.for_type :=
                       yy.value_stack (yy.tos - 4).Table_Type_Value;
                     New_For.for_index :=
                       variable_expression_ptr
                         (yy.value_stack (yy.tos - 6).Expression);
                     New_For.line_number        := Scheduler_Lex.Lines;
                     New_For.file_name          := File_Name;
                     New_For.included_statement :=
                       yy.value_stack (yy.tos - 2).Statement;

                     YYVal.Statement := generic_statement_ptr (New_For);
                  end;

               when 70 =>
--#line  676

                  declare
                     New_While : while_statement_ptr;

                  begin
                     New_While           := new while_statement;
                     New_While.condition :=
                       yy.value_stack (yy.tos - 4).Expression;
                     New_While.line_number        := Scheduler_Lex.Lines;
                     New_While.file_name          := File_Name;
                     New_While.included_statement :=
                       yy.value_stack (yy.tos - 2).Statement;

                     YYVal.Statement := generic_statement_ptr (New_While);
                  end;

               when 71 =>
--#line  694

                  declare
                     New_Random : random_initialize_statement_ptr;
                  begin
                     New_Random             := new random_initialize_statement;
                     New_Random.line_number := Scheduler_Lex.Lines;
                     New_Random.file_name   := File_Name;
                     New_Random.lvalue      :=
                       yy.value_stack (yy.tos - 4).String_Value;
                     New_Random.law        := exponential_law_type;
                     New_Random.parameter1 :=
                       yy.value_stack (yy.tos - 2).Expression;

                     YYVal.Statement := generic_statement_ptr (New_Random);
                  end;

               when 72 =>
--#line  711

                  declare
                     New_Random : random_initialize_statement_ptr;
                  begin
                     New_Random             := new random_initialize_statement;
                     New_Random.line_number := Scheduler_Lex.Lines;
                     New_Random.file_name   := File_Name;
                     New_Random.lvalue      :=
                       yy.value_stack (yy.tos - 6).String_Value;
                     New_Random.law        := laplace_gauss_law_type;
                     New_Random.parameter1 :=
                       yy.value_stack (yy.tos - 4).Expression;
                     New_Random.parameter2 :=
                       yy.value_stack (yy.tos - 2).Expression;

                     YYVal.Statement := generic_statement_ptr (New_Random);
                  end;

               when 73 =>
--#line  728

                  declare
                     New_Random : random_initialize_statement_ptr;
                  begin
                     New_Random             := new random_initialize_statement;
                     New_Random.line_number := Scheduler_Lex.Lines;
                     New_Random.file_name   := File_Name;
                     New_Random.lvalue      :=
                       yy.value_stack (yy.tos - 6).String_Value;
                     New_Random.law        := uniform_law_type;
                     New_Random.parameter1 :=
                       yy.value_stack (yy.tos - 4).Expression;
                     New_Random.parameter2 :=
                       yy.value_stack (yy.tos - 2).Expression;

                     YYVal.Statement := generic_statement_ptr (New_Random);
                  end;

               when 74 =>
--#line  745

                  declare
                     New_Set : set_statement_ptr;
                  begin
                     -- Is the Variable already exists ?
                     --
                     for I in 0 .. Sets_Table.nb_entries - 1 loop
                        if
                          (Sets_Table.entries (I).set_id =
                           yy.value_stack (yy.tos - 2).String_Value)
                        then
                           Raise_Exception
                             (expressions.syntax_error'identity,
                              "file " &
                              To_String (File_Name) &
                              " line " &
                              Scheduler_Lex.Lines'img &
                              To_String
                                (lb_comma &
                                 yy.value_stack (yy.tos - 2).String_Value &
                                 lb_comma &
                                 lb_identifier_already_declared
                                   (Current_Language)));
                        end if;
                     end loop;

                     New_Set           := new set_statement;
                     New_Set.set_value :=
                       yy.value_stack (yy.tos - 1).Expression;
                     New_Set.set_id :=
                       yy.value_stack (yy.tos - 2).String_Value;
                     New_Set.line_number := Scheduler_Lex.Lines;
                     New_Set.file_name   := File_Name;
                     add (Sets_Table, New_Set);

                     YYVal.Statement := generic_statement_ptr (New_Set);
                  end;

               when 75 =>
--#line  776

                  YYVal.Expression := yy.value_stack (yy.tos).Expression;

               when 76 =>
--#line  780

                  YYVal.Expression := null;

               when 77 =>
--#line  789

                  YYVal.Expression := yy.value_stack (yy.tos - 1).Expression;

               when 78 =>
--#line  793

                  YYVal.Expression := null;

               when 79 =>
--#line  801

                  YYVal.Variable_Type_Value := simulation_double;

               when 80 =>
--#line  805

                  if yy.value_stack (yy.tos - 3).Table_Type_Value =
                    time_unit_table_type
                  then

                     YYVal.Variable_Type_Value :=
                       simulation_time_unit_array_double;
                  else

                     YYVal.Variable_Type_Value := simulation_array_double;
                  end if;

               when 81 =>
--#line  814

                  YYVal.Variable_Type_Value := simulation_integer;

               when 82 =>
--#line  818

                  if yy.value_stack (yy.tos - 3).Table_Type_Value =
                    time_unit_table_type
                  then

                     YYVal.Variable_Type_Value :=
                       simulation_time_unit_array_integer;
                  else

                     YYVal.Variable_Type_Value := simulation_array_integer;
                  end if;

               when 83 =>
--#line  827

                  YYVal.Variable_Type_Value := simulation_clock;

               when 84 =>
--#line  831

                  if yy.value_stack (yy.tos - 3).Table_Type_Value =
                    time_unit_table_type
                  then
                     Raise_Exception
                       (expressions.syntax_error'identity,
                        "file " &
                        To_String (File_Name) &
                        " line " &
                        Scheduler_Lex.Lines'img &
                        To_String
                          (lb_comma &
                           "can not define a Time_Unit array of Clock type."));
                  else

                     YYVal.Variable_Type_Value := simulation_array_clock;
                  end if;

               when 85 =>
--#line  842

                  YYVal.Variable_Type_Value := simulation_random;

               when 86 =>
--#line  846

                  if yy.value_stack (yy.tos - 3).Table_Type_Value =
                    time_unit_table_type
                  then
                     Raise_Exception
                       (expressions.syntax_error'identity,
                        "file " &
                        To_String (File_Name) &
                        " line " &
                        Scheduler_Lex.Lines'img &
                        To_String
                          (lb_comma &
                           "can not define a Time_Unit array of Random type."));
                  else

                     YYVal.Variable_Type_Value := simulation_array_clock;
                  end if;

               when 87 =>
--#line  857

                  YYVal.Variable_Type_Value := simulation_boolean;

               when 88 =>
--#line  861

                  if yy.value_stack (yy.tos - 3).Table_Type_Value =
                    time_unit_table_type
                  then

                     YYVal.Variable_Type_Value :=
                       simulation_time_unit_array_boolean;
                  else

                     YYVal.Variable_Type_Value := simulation_array_boolean;
                  end if;

               when 89 =>
--#line  870

                  if yy.value_stack (yy.tos - 3).Table_Type_Value =
                    time_unit_table_type
                  then

                     YYVal.Variable_Type_Value :=
                       simulation_time_unit_array_string;
                  else

                     YYVal.Variable_Type_Value := simulation_array_string;
                  end if;

               when 90 =>
--#line  879

                  YYVal.Variable_Type_Value := simulation_string;

               when 91 =>
--#line  887

                  YYVal.Table_Type_Value := task_table_type;

               when 92 =>
--#line  891

                  YYVal.Table_Type_Value := buffer_table_type;

               when 93 =>
--#line  895

                  YYVal.Table_Type_Value := message_table_type;

               when 94 =>
--#line  899

                  YYVal.Table_Type_Value := time_unit_table_type;

               when 95 =>
--#line  903

                  YYVal.Table_Type_Value := processor_table_type;

               when 96 =>
--#line  907

                  YYVal.Table_Type_Value := resource_table_type;

               when 97 =>
--#line  915

                  YYVal.Expression := yy.value_stack (yy.tos).Expression;

               when 98 =>
--#line  919

                  YYVal.Expression := null;

               when 99 =>
--#line  926

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := logic_and_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 2).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 100 =>
--#line  939

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := modulo_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 2).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 101 =>
--#line  952

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := inferior_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 2).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 102 =>
--#line  965

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := superior_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 2).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 103 =>
--#line  978

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := equal_less_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 2).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 104 =>
--#line  991

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := equal_greater_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 2).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 105 =>
--#line  1004

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := not_equal_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 2).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 106 =>
--#line  1017

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := equal_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 2).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 107 =>
--#line  1030

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := logic_or_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 2).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 108 =>
--#line  1043

                  declare
                     New_Expr : unary_expression_ptr;
                  begin
                     New_Expr       := new unary_expression;
                     New_Expr.ope   := logic_not_type;
                     New_Expr.value := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 109 =>
--#line  1055

                  YYVal.Expression := yy.value_stack (yy.tos - 1).Expression;

               when 110 =>
--#line  1060

                  declare
                     New_Expr : constant_expression_ptr;
                  begin
                     New_Expr       := new constant_expression;
                     New_Expr.value :=
                       new simulation_value'(simulation_boolean, True);

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 111 =>
--#line  1071

                  declare
                     New_Expr : constant_expression_ptr;
                  begin
                     New_Expr       := new constant_expression;
                     New_Expr.value :=
                       new simulation_value'(simulation_boolean, False);

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 112 =>
--#line  1082

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := plus_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 2).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 113 =>
--#line  1095

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := minus_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 2).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 114 =>
--#line  1108

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := multiply_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 2).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 115 =>
--#line  1121

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := divide_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 2).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 116 =>
--#line  1134

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := lcm_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 5).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos - 3).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 117 =>
--#line  1147

                  declare
                     New_Expr : unary_expression_ptr;
                  begin
                     New_Expr       := new unary_expression;
                     New_Expr.value := yy.value_stack (yy.tos - 1).Expression;
                     New_Expr.ope   := to_double_type;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 118 =>
--#line  1159

                  declare
                     New_Expr : unary_expression_ptr;
                  begin
                     New_Expr       := new unary_expression;
                     New_Expr.value := yy.value_stack (yy.tos - 1).Expression;
                     New_Expr.ope   := to_integer_type;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 119 =>
--#line  1171

                  declare
                     New_Expr : unary_expression_ptr;
                  begin
                     New_Expr       := new unary_expression;
                     New_Expr.value := yy.value_stack (yy.tos - 1).Expression;
                     New_Expr.ope   := abs_type;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 120 =>
--#line  1184

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := concatenate_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 5).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos - 3).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 121 =>
--#line  1197

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := max_operator_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 3).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos - 1).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 122 =>
--#line  1210

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := min_operator_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 3).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos - 1).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 123 =>
--#line  1223

                  declare
                     New_Expr : binary_expression_ptr;
                  begin
                     New_Expr        := new binary_expression;
                     New_Expr.ope    := exponential_type;
                     New_Expr.lvalue := yy.value_stack (yy.tos - 2).Expression;
                     New_Expr.rvalue := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 124 =>
--#line  1236

                  declare
                     New_Expr1 : binary_expression_ptr;
                     New_Expr2 : constant_expression_ptr;

                  begin
                     New_Expr2 := new constant_expression;
                     if get_type (yy.value_stack (yy.tos).Expression.all) =
                       simulation_double
                     then
                        New_Expr2.value :=
                          new simulation_value'(simulation_double, -1.0);
                     else
                        New_Expr2.value :=
                          new simulation_value'(simulation_integer, -1);
                     end if;
                     New_Expr1        := new binary_expression;
                     New_Expr1.ope    := multiply_type;
                     New_Expr1.lvalue := generic_expression_ptr (New_Expr2);
                     New_Expr1.rvalue := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr1);
                  end;

               when 125 =>
--#line  1260

                  declare
                     New_Expr1 : binary_expression_ptr;
                     New_Expr2 : constant_expression_ptr;

                  begin
                     New_Expr2 := new constant_expression;
                     if get_type (yy.value_stack (yy.tos).Expression.all) =
                       simulation_double
                     then
                        New_Expr2.value :=
                          new simulation_value'(simulation_double, 1.0);
                     else
                        New_Expr2.value :=
                          new simulation_value'(simulation_integer, 1);
                     end if;
                     New_Expr1        := new binary_expression;
                     New_Expr1.ope    := multiply_type;
                     New_Expr1.lvalue := generic_expression_ptr (New_Expr2);
                     New_Expr1.rvalue := yy.value_stack (yy.tos).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr1);
                  end;

               when 126 =>
--#line  1284

                  declare
                     New_Expr : unary_expression_ptr;
                  begin

                     if (Current_Section_Type /= election_type) then
                        Raise_Exception
                          (expressions.syntax_error'identity,
                           "file " &
                           To_String (File_Name) &
                           " line " &
                           Scheduler_Lex.Lines'img &
                           To_String
                             (lb_comma &
                              "min_to_index and max_to_index operators can only be used in election_section."));
                     end if;

                     New_Expr       := new unary_expression;
                     New_Expr.value := yy.value_stack (yy.tos - 1).Expression;
                     New_Expr.ope   := max_to_index_type;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 127 =>
--#line  1304

                  declare
                     New_Expr : unary_expression_ptr;
                  begin
                     if (Current_Section_Type /= election_type) then
                        Raise_Exception
                          (expressions.syntax_error'identity,
                           "file " &
                           To_String (File_Name) &
                           " line " &
                           Scheduler_Lex.Lines'img &
                           To_String
                             (lb_comma &
                              "min_to_index and max_to_index operators can only be used in election_section."));
                     end if;

                     New_Expr       := new unary_expression;
                     New_Expr.value := yy.value_stack (yy.tos - 1).Expression;
                     New_Expr.ope   := min_to_index_type;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 128 =>
--#line  1324

                  declare
                     New_Expr : unary_expression_ptr;
                  begin
                     New_Expr       := new unary_expression;
                     New_Expr.value := yy.value_stack (yy.tos - 1).Expression;
                     New_Expr.ope   := get_task_index_type;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 129 =>
--#line  1336

                  declare
                     New_Expr : unary_expression_ptr;
                  begin
                     New_Expr       := new unary_expression;
                     New_Expr.value := yy.value_stack (yy.tos - 1).Expression;
                     New_Expr.ope   := get_resource_index_type;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 130 =>
--#line  1348

                  declare
                     New_Expr : unary_expression_ptr;
                  begin
                     New_Expr       := new unary_expression;
                     New_Expr.value := yy.value_stack (yy.tos - 1).Expression;
                     New_Expr.ope   := get_buffer_index_type;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 131 =>
--#line  1360

                  declare
                     New_Expr : unary_expression_ptr;
                  begin
                     New_Expr       := new unary_expression;
                     New_Expr.value := yy.value_stack (yy.tos - 1).Expression;
                     New_Expr.ope   := get_message_index_type;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 132 =>
--#line  1372

                  declare
                     New_Expr : constant_expression_ptr;
                  begin
                     New_Expr       := new constant_expression;
                     New_Expr.value :=
                       new simulation_value'(simulation_double, Double'last);

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 133 =>
--#line  1382

                  declare
                     New_Expr : constant_expression_ptr;
                  begin
                     New_Expr       := new constant_expression;
                     New_Expr.value :=
                       new simulation_value'(simulation_double, Double'first);

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 134 =>
--#line  1392

                  declare
                     New_Expr : constant_expression_ptr;
                  begin
                     New_Expr       := new constant_expression;
                     New_Expr.value :=
                       new simulation_value'(simulation_integer, Integer'last);

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 135 =>
--#line  1402

                  declare
                     New_Expr : constant_expression_ptr;
                  begin
                     New_Expr       := new constant_expression;
                     New_Expr.value :=
                       new simulation_value'
                         (simulation_integer, Integer'first);

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 136 =>
--#line  1412

                  declare
                     New_Expr : array_variable_expression_ptr;
                  begin
                     -- Find the type of the $1 Variable
                     --

                     YYVal.Expression :=
                       generic_expression_ptr
                         (Variables_Table.entries
                            (find_variable
                               (Variables_Table,
                                yy.value_stack (yy.tos - 3).String_Value,
                                Scheduler_Lex.Lines,
                                File_Name))
                            .variable);

                     New_Expr               := new array_variable_expression;
                     New_Expr.variable_type :=
                       variable_expression_ptr (YYVal.Expression)
                         .variable_type;
                     New_Expr.name := yy.value_stack (yy.tos - 3).String_Value;
                     New_Expr.array_index :=
                       yy.value_stack (yy.tos - 1).Expression;

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 137 =>
--#line  1429

                  -- Find the type of the Variable before
                  -- instanciation
                  --

                  YYVal.Expression :=
                    generic_expression_ptr
                      (Variables_Table.entries
                         (find_variable
                            (Variables_Table,
                             yy.value_stack (yy.tos).String_Value,
                             Scheduler_Lex.Lines,
                             File_Name))
                         .variable);

               when 138 =>
--#line  1437

                  declare
                     New_Expr : constant_expression_ptr;
                  begin
                     New_Expr       := new constant_expression;
                     New_Expr.value :=
                       new simulation_value'
                         (simulation_string,
                          yy.value_stack (yy.tos).String_Value);

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 139 =>
--#line  1447

                  declare
                     New_Expr : constant_expression_ptr;
                  begin
                     New_Expr       := new constant_expression;
                     New_Expr.value :=
                       new simulation_value'
                         (simulation_double,
                          yy.value_stack (yy.tos).Double_Value);

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 140 =>
--#line  1458

                  declare
                     New_Expr : constant_expression_ptr;
                  begin
                     New_Expr       := new constant_expression;
                     New_Expr.value :=
                       new simulation_value'
                         (simulation_integer,
                          yy.value_stack (yy.tos).Integer_Value);

                     YYVal.Expression := generic_expression_ptr (New_Expr);
                  end;

               when 141 =>
--#line  1473

                  YYVal.String_Value :=
                    To_Unbounded_String (scheduler_dfa.YYText);

               when 142 =>
--#line  1479

                  declare
                     Ok : Boolean;

                  begin
                     to_double
                       (To_Unbounded_String (scheduler_dfa.YYText),
                        YYVal.Double_Value,
                        Ok);
                     if not Ok then
                        Raise_Exception
                          (expressions.syntax_error'identity,
                           "file " &
                           To_String (File_Name) &
                           " line " &
                           Scheduler_Lex.Lines'img &
                           To_String
                             (lb_comma &
                              To_Unbounded_String (scheduler_dfa.YYText) &
                              lb_comma &
                              lb_double_conversion_error (Current_Language)));
                     end if;
                  end;

               when 143 =>
--#line  1495

                  declare
                     Tmp : Unbounded_String;
                  begin
                     Tmp := To_Unbounded_String (scheduler_dfa.YYText);
                     Tmp :=
                       To_Unbounded_String (Slice (Tmp, 2, Length (Tmp) - 1));

                     YYVal.String_Value := Tmp;
                  end;

               when 144 =>
--#line  1506

                  declare
                     Ok : Boolean;

                  begin
                     to_integer
                       (To_Unbounded_String (scheduler_dfa.YYText),
                        YYVal.Integer_Value,
                        Ok);
                     if not Ok then
                        Raise_Exception
                          (expressions.syntax_error'identity,
                           "file " &
                           To_String (File_Name) &
                           " line " &
                           Scheduler_Lex.Lines'img &
                           To_String
                             (lb_comma &
                              To_Unbounded_String (scheduler_dfa.YYText) &
                              lb_comma &
                              lb_integer_conversion_error (Current_Language)));
                     end if;
                  end;

               when others =>
                  null;
            end case;

            -- Pop RHS states and goto next state
            yy.tos := yy.tos - Rule_Length (yy.rule_id) + 1;
            if yy.tos > yy.stack_size then
               Text_IO.Put_Line (" Stack size exceeded on state_stack");
               raise yy_tokens.Syntax_Error;
            end if;
            yy.state_stack (yy.tos) :=
              goto_state
                (yy.state_stack (yy.tos - 1),
                 Get_LHS_Rule (yy.rule_id));

            yy.value_stack (yy.tos) := YYVal;

            if yy.DEBUG then
               reduce_debug
                 (yy.rule_id,
                  goto_state
                    (yy.state_stack (yy.tos - 1),
                     Get_LHS_Rule (yy.rule_id)));
            end if;

         end if;

      end loop;

   end Yyparse;

end Parser;
