%with Ada.strings.unbounded;
%use Ada.strings.unbounded;
%with Ada.numerics.aux;
%use Ada.numerics.aux;
%with Statements;
%use Statements;
%with Interpreter;
%use Interpreter;
%use Interpreter.Sets_Type_Package;
%with Expressions;
%use Expressions;
%use Expressions.Variables_Type_Package;
%with Simulations;
%use Simulations;
%with Section_Set;
%use Section_Set;
%use Section_Set.Package_Generic_Section_Set;
%with Sections;
%use Sections;
%with Automaton;
%use Automaton;
%with Automaton.Extended;
%use Automaton.Extended;
%use Automaton.State_Lists_Package;
%use Automaton.Transition_Lists_Package;


%Token Double_Type_Token Array_Token
%Token Integer_Type_Token Task_Token String_Type_Token Clock_Type_Token
%Token Boolean_Type_Token Of_Token
%Token Last_Token First_Token
%Token Double_Token Integer_Token Identifier_Token True_Token False_Token String_Token
%Token In_Token For_Token Is_Token Function_Token Procedure_Token Set_Token While_Token Loop_Token
%Token Task_Token Message_Token Processor_Token Buffer_Token Resource_Token Time_Unit_Token
%Token Tasks_Range_Token Messages_Range_Token Processors_Range_Token Buffers_Range_Token
%Token Resources_Range_Token Time_Units_Range_Token
%Token Return_Token Max_Token Min_Token Lcm_Token Put_Token Mod_Token Abs_Token
%Token Max_To_Index_Token Min_To_Index_Token To_Integer_Token To_Double_Token
%Token Then_Token End_Token Else_Token If_Token End_If_Token End_Loop_Token
%Token Random_Type_Token Uniform_Token Exponential_Token Laplace_Gauss_Token
%Token Get_Task_Index_Token Get_Buffer_Index_Token Get_Message_Index_Token
%Token Get_Resource_Index_Token Exit_Token
%Token State_Token Initial_State_Token End_Section_Token
%Token Automaton_Token Gather_Event_Analyzer_Token Display_Event_Analyzer_Token Start_Token Priority_Token Election_Token Activation_Token Check_Resource_Token Release_Resource_Token Allocate_Resource_Token
%Token Transition_Token Transition_Arrow_Token '?' '!' Delay_Token
%Token Add_Precedence_Token Delete_Precedence_Token

%Token '[' ']' '(' ')' '}' '{'
%right     Equal_Token
%left      '+' '-'
%left      '*' '/'
%right     Unary_Minus
%right     Unary_Plus
%nonassoc  Exp_Token
%Token ':' '|' ';' ','
%Token Inf_Token Sup_Token Inf_Equal_Token Sup_Equal_Token Not_Equal_Token Assign_Token
%Token Concat_Token Or_Token And_Token Not_Token

{

type Key_Type is (Cval, Ival, Noval);

type Yystype is record
  	String_Value 		     : Unbounded_String;
	Integer_Value 		     : Integer;
	Double_Value 		     : Double;
  	Expression	             : Generic_Expression_Ptr;
  	Statement 	     	     : Generic_Statement_Ptr;
  	Variable_Type_Value 	     : Simulation_Type;
        Table_Type_Value             : Table_Types;
        State                        : State_Ptr;
        Transition                   : Transition_Ptr;
        Synchronization              : Synchronization_Ptr;
end record;

}

%%

Entry :  sections;


sections : sections section  |;


section :
     Start_Section
   | Priority_Section
   | Election_Section
   | Activation_Section
   | Check_Resource_Section
   | Release_Resource_Section
   | Allocate_Resource_Section
   | Gather_Event_Analyzer_Section
   | Display_Event_Analyzer_Section
   | Automaton_Section;


Check_Resource_Section :
        {
	    Current_Section_Type:=Check_Resource_Type;
	    Current_Statement_Pointer:=null;
	}
	Check_Resource_Token Section_Name ':' Statements  End_Section_Token ';'
	{
            if Current_Computation_Section/=null
               then Current_Computation_Section.Name:=Current_Section_Name;
            end if;
	};

Release_Resource_Section :
        {
	    Current_Section_Type:=Release_Resource_Type;
	    Current_Statement_Pointer:=null;
	}
	Release_Resource_Token Section_Name ':' Statements  End_Section_Token ';'
	{
            if Current_Computation_Section/=null
               then Current_Computation_Section.Name:=Current_Section_Name;
            end if;
	};

Allocate_Resource_Section :
        {
	    Current_Section_Type:= Allocate_Resource_Type;
	    Current_Statement_Pointer:=null;
	}
	Allocate_Resource_Token Section_Name ':' Statements  End_Section_Token ';'
	{
            if Current_Computation_Section/=null
               then Current_Computation_Section.Name:=Current_Section_Name;
            end if;
	};

Start_Section :
        {
	    Current_Section_Type:=Start_Type;
	    Current_Statement_Pointer:=null;
	}
	Start_Token Section_Name ':' Statements End_Section_Token ';'
	{
            if Current_Computation_Section/=null
               then Current_Computation_Section.Name:=Current_Section_Name;
            end if;
	};

Gather_Event_Analyzer_Section :
      {
		Current_Section_Type:=Gather_Event_Analyzer_Type;
		Current_Statement_Pointer:=null;
	}
	Gather_Event_Analyzer_Token Section_Name ':' Statements  End_Section_Token ';'
	{
            if Current_Computation_Section/=null
               then Current_Computation_Section.Name:=Current_Section_Name;
            end if;
	};

Display_Event_Analyzer_Section :
      {
		Current_Section_Type:= Display_Event_Analyzer_Type;
		Current_Statement_Pointer:=null;
	}
	Display_Event_Analyzer_Token Section_Name ':' Statements  End_Section_Token ';'
	{
            if Current_Computation_Section/=null
               then Current_Computation_Section.Name:=Current_Section_Name;
            end if;
	};

Activation_Section :
      {
		Current_Section_Type:=Activation_Type;
		Current_Statement_Pointer:=null;
	}
	Activation_Token Section_Name ':' Statements  End_Section_Token ';'
	{
            if Current_Computation_Section/=null
               then Current_Computation_Section.Name:=Current_Section_Name;
            end if;
	};

Election_Section :
      {
		Current_Section_Type:=Election_Type;
		Current_Statement_Pointer:=null;
	}
	Election_Token Section_Name ':' Statements End_Section_Token ';'
	{
            if Current_Computation_Section/=null
               then Current_Computation_Section.Name:=Current_Section_Name;
            end if;
	};

Priority_Section :
      {
		Current_Section_Type:=Priority_Type;
		Current_Statement_Pointer:=null;
	}
	Priority_Token Section_Name ':' Statements End_Section_Token ';'
	{
            if Current_Computation_Section/=null
               then Current_Computation_Section.Name:=Current_Section_Name;
            end if;
	};


Automaton_Section :
      {
		Current_Section_Type:=Automaton_Type;
            Current_Synchronization_Section:=null;
	}
	Automaton_Token Section_Name ':' States Transitions  End_Section_Token ';'
	{
            if Current_Synchronization_Section/=null
               then Current_Synchronization_Section.Name:=Current_Section_Name;
            end if;
	};


Section_Name :
	Identifier_Data
	{
            Current_Section_Name:=$1.String_Value;
	}
	|
        {
            Current_Section_Name:=Empty_String;
	};



States : States State
	{
    		if $2.State/=null then
			if (Current_Synchronization_Section=null)   then
				Current_Synchronization_Section := new Synchronization_Section;
                        Current_Synchronization_Section.File_Name:=File_Name;
                        Current_Synchronization_Section.Section_Type:=Current_Section_Type;
				Add(Root_Statement_Pointer, Generic_Section_Ptr(Current_Synchronization_Section));
                  end if;
                  Add(Current_Synchronization_Section.State_List,$2.State);
            end if;

      }
      |;



Transitions : Transitions Transition
      {
        if $2.Transition/=null
         then
            Add(Current_Synchronization_Section.Transition_List,$2.Transition);
        end if;
      }
      |;


State : Identifier_Data ':' Initial_State_Token ';'
     {
        declare
		New_State : State_Ptr;
	  begin
            New_State := new State;
            New_State.Name := $1.String_Value;
            New_State.Is_Initial:=True;
            $$.State:=New_State;
        end;
      }
	| Identifier_Data ':' State_Token ';'
      {
        declare
		New_State : State_Ptr;
	  begin
            New_State := new State;
            New_State.Name := $1.String_Value;
            New_State.Is_Initial:=False;
            $$.State:=New_State;
        end;
       };

Transition_Expression : Expr
   {
      $$.Expression:=$1.Expression;
   }
   |
   {
      $$.Expression:=null;
   };


Transition_Statement :  Statement
   {
      $$.Statement:=$1.Statement;
   }
   |
   {
      $$.Statement:=null;
   };



Transition_Synchronization : Identifier_Data '?'
      {
      declare
         New_Sync : Synchronization_Ptr;
      begin
         New_Sync := new Synchronization;
         New_Sync.Name:=$1.String_Value;
         New_Sync.Synchronization_Type:=Receive;
         $$.Synchronization:=New_Sync;
      end;
      }
      | Identifier_Data '!'
      {
      declare
         New_Sync : Synchronization_Ptr;
      begin
         New_Sync := new Synchronization;
         New_Sync.Name:=$1.String_Value;
         New_Sync.Synchronization_Type:=Send;
         $$.Synchronization:=New_Sync;
      end;
      }
      |
      {
         $$.Synchronization:=null;
      };


Transition : Transition_Token Identifier_Data Transition_Arrow_Token '[' Transition_Expression ',' Transition_Statement ',' Transition_Synchronization ']' Transition_Arrow_Token Identifier_Data ';'
   {
   declare
      New_Transition : Transition_Ptr;
   begin
      New_Transition:= new Transition;
      New_Transition.Name:= $2.String_Value & To_Unbounded_String("==>") & $12.String_Value;

      begin
         New_Transition.From_State:=Search_State(Current_Synchronization_Section.State_List,$2.String_Value);
      exception
         when State_Not_found =>
                Raise_Exception(Expressions.Syntax_Error'Identity, "file " & To_String(File_Name) & " line " & Scheduler_Lex.Lines'Img &
               To_String(Lb_Comma & "State " & $2.String_Value &  " not found" ));
      end;

      begin
         New_Transition.To_State:=Search_State(Current_Synchronization_Section.State_List,$12.String_Value);
      exception
         when State_Not_found =>
                Raise_Exception(Expressions.Syntax_Error'Identity, "file " & To_String(File_Name) & " line " & Scheduler_Lex.Lines'Img &
               To_String(Lb_Comma & "State " & $12.String_Value &  " not found" ));
      end;

      New_Transition.Guards:=$5.Expression;
      New_Transition.Clocks:=$7.Statement;
      New_Transition.Synchronization:=$9.Synchronization;
      $$.Transition:=New_Transition;
   end;
   };



Statements : Statements Statement
	{
	  begin
     		if $2.Statement/=null then
			if (Current_Statement_Pointer=null)
                	then
                		Current_Statement_Pointer:=$2.Statement;
				Current_Computation_Section := new Computation_Section;
                        	Current_Computation_Section.File_Name:=File_Name;
                        	Current_Computation_Section.Section_Type:=Current_Section_Type;
				Current_Computation_Section.First_Statement:=$2.Statement;
                        	Add(Root_Statement_Pointer, Generic_Section_Ptr(Current_Computation_Section));
                	else
                        	Current_Statement_Pointer.Next_Statement:=$2.Statement;
                        	Current_Statement_Pointer:=$2.Statement;
          		end if;
             end if;
         end;
      }
      |;


Else_rule :  Else_Token Else_Included_Statements End_If_Token ';'
      {
                $$.Statement:=$2.Statement;
      }
      | End_If_Token ';'
      {
                $$.Statement:=null;
      };


Else_Included_Statements :  Statement Else_Included_Statements
      {
                $1.Statement.Next_Statement:=$2.Statement;
                $$.Statement:=$1.Statement;
      }
      | Statement
	 {
                $$.Statement:=$1.Statement;
      }
      |
      {
               $$.Statement:=null;
      };

Included_Statements :  Statement Included_Statements
      {
                $1.Statement.Next_Statement:=$2.Statement;
                $$.Statement:=$1.Statement;
      }
      | Statement
	 {
                $$.Statement:=$1.Statement;
      }
      |
      {
               $$.Statement:=null;
      };



Statement  :
       Put_Token '(' Expr Put_Parameter Put_Parameter ')' ';'
	  {
	  declare
		New_Put : Put_Statement_Ptr;
	  begin

		-- Firstly, the Put_Parameter
		--
          if (($4.Expression/=null) and ($5.Expression=null))
              or (($4.Expression=null) and ($5.Expression/=null))
          then
             Raise_Exception(Expressions.Syntax_Error'Identity, "file " & To_String(File_Name) & " line " & Scheduler_Lex.Lines'Img &
                 To_String(Lb_Comma & "0 or 2 parameters should be given" ));
          end if;

          New_Put:= new Put_Statement;
          New_Put.Expression_To_Be_Displayed:=$3.Expression;
          New_Put.Put_From:=$4.Expression;
          New_Put.Put_To:=$5.Expression;
          New_Put.Line_Number:=Scheduler_Lex.Lines;
          New_Put.File_Name:=File_Name;
          $$.Statement:=Generic_Statement_Ptr(New_Put);
	  end;
	  }

      | Delete_Precedence_Token   String_Data  ';'
	{
	declare
        	New_Delete_Precedence : Delete_Precedence_Statement_Ptr;
   		Pos : Natural;
                Parameter : unbounded_string :=$2.String_Value;
                Task1, Task2 :  unbounded_string;

	begin
                Pos:=Index(Parameter, "/", 1);
                Task1:=unbounded_slice(Parameter,1,Pos-1);
                Task2:=unbounded_slice(Parameter,Pos+1,Length(Parameter));

                New_Delete_Precedence:= new Delete_Precedence_Statement;
                New_Delete_Precedence.Delete_Source:=Task1;
                New_Delete_Precedence.Delete_Sink:=Task2;

                New_Delete_Precedence.Line_Number:=Scheduler_Lex.Lines;
                New_Delete_Precedence.File_Name:=File_Name;

                $$.Statement:=Generic_Statement_Ptr(New_Delete_Precedence);
	end;
      }

      | Add_Precedence_Token  String_Data  ';'
	{
	declare
        	New_Add_Precedence : Add_Precedence_Statement_Ptr;
   		Pos : Natural;
                Parameter : unbounded_string :=$2.String_Value;
                Task1, Task2 :  unbounded_string;

	begin
                Pos:=Index(Parameter, "/", 1);
                Task1:=unbounded_slice(Parameter,1,Pos-1);
                Task2:=unbounded_slice(Parameter,Pos+1,Length(Parameter));

                New_Add_Precedence:= new Add_Precedence_Statement;
                New_Add_Precedence.Add_Source:=Task1;
                New_Add_Precedence.Add_Sink:=Task2;

                New_Add_Precedence.Line_Number:=Scheduler_Lex.Lines;
                New_Add_Precedence.File_Name:=File_Name;

                $$.Statement:=Generic_Statement_Ptr(New_Add_Precedence);
	end;
      }


	  | Identifier_Data ':' User_Type Assign ';'
	  {
	  declare
         New_Assign     : Assign_Statement_Ptr;
         New_Var      	: Variable_Record_Ptr;
         New_Array_Expr : Array_Variable_Expression_Ptr;
         New_Var_Expr   : Variable_Expression_Ptr;

	  begin

            -- Is the Variable already exists ?
		--
		for I in 0..Variables_Table.Nb_Entries-1 loop
			if (Variables_Table.Entries(i).Variable.Name=$1.String_Value)
				then
					Raise_Exception(Expressions.Syntax_Error'Identity, "file " & To_String(File_Name) & " line " & Scheduler_Lex.Lines'Img &
                           To_String(Lb_Comma & $1.String_Value & Lb_Comma & Lb_Identifier_Already_Declared(Current_Language) ));
			end if;
		end loop;



		-- Create the Variable (Array or not)
		--
		New_Var:= new Variable_Record;

            if ($3.Variable_Type_Value=Simulation_Array_Double)
                	or ($3.Variable_Type_Value=Simulation_Array_Integer)
                	or ($3.Variable_Type_Value=Simulation_Array_Boolean)
	            or ($3.Variable_Type_Value=Simulation_Array_Clock)
                	or ($3.Variable_Type_Value=Simulation_Array_String)
                  or ($3.Variable_Type_Value=Simulation_Array_Random)
                	or ($3.Variable_Type_Value=Simulation_Time_Unit_Array_Double)
                	or ($3.Variable_Type_Value=Simulation_Time_Unit_Array_Integer)
                	or ($3.Variable_Type_Value=Simulation_Time_Unit_Array_Boolean)
                	or ($3.Variable_Type_Value=Simulation_Time_Unit_Array_String)
			then

                		New_Array_Expr:= new Array_Variable_Expression;
                        New_Array_Expr.Variable_Type:=$3.Variable_Type_Value;
                        New_Array_Expr.Name:=$1.String_Value;
                        New_Var.Variable:=Variable_Expression_Ptr(New_Array_Expr);
                  else
      	            New_Var_Expr := new Variable_Expression;
                        New_Var_Expr.Variable_Type:=$3.Variable_Type_Value;
                        New_Var_Expr.Name:=$1.String_Value;
                        New_Var.Variable:=New_Var_Expr;
		end if;



          Add(Variables_Table, New_Var);

          -- Create simulation data
          --
          Variables_Table.Entries(Variables_Table.Nb_Entries-1).Simulation
                       :=new Simulation_Value(
          Variable_Expression_Ptr(Variables_Table.Entries(Variables_Table.Nb_Entries-1).
                       Variable).Variable_Type);


		-- If Assignement is not null, we should register
		-- a new Assignement
		--
		if $4.Expression /= null
			then
				New_Assign:= new Assign_Statement;
				New_Assign.Lvalue:=Generic_Expression_Ptr(New_Var_Expr);
                   	New_Assign.Rvalue:=$4.Expression;
				New_Assign.Line_Number:=Scheduler_Lex.Lines;
                        New_Assign.File_Name:=File_Name;
				$$.Statement:=Generic_Statement_Ptr(New_Assign);

              	else
                        $$.Statement:=null;
		end if;
	end;
	}

      | Delay_Token Expr  ';'
	{
      declare
          New_Clock  : Clock_Statement_Ptr;
      begin
                 New_Clock:= new Clock_Statement;
                 New_Clock.Line_Number:=Scheduler_Lex.Lines;
                 New_Clock.File_Name:=File_Name;
                 New_Clock.Lvalue:=$2.Expression;
                 $$.Statement:=Generic_Statement_Ptr(New_Clock);
       end;
	}

	| Expr Assign_Token Expr ';'
	{
      declare
          New_Assign : Assign_Statement_Ptr;
      begin
          New_Assign:= new Assign_Statement;
          New_Assign.Line_Number:=Scheduler_Lex.Lines;
          New_Assign.File_Name:=File_Name;
          New_Assign.Lvalue:=$1.Expression;
          New_Assign.Rvalue:=$3.Expression;

          $$.Statement:=Generic_Statement_Ptr(New_Assign);
       end;
	}


      | If_Token Expr Then_Token Included_Statements Else_Rule
	{
	declare 
        New_If                : If_Statement_Ptr;

	begin
 	    New_If:= new If_Statement;
  	    New_If.Line_Number:=Scheduler_Lex.Lines;
          New_If.File_Name:=File_Name;
          New_If.Bool_Expression:=$2.Expression;
          New_If.Then_Statement:=$4.Statement;
          New_If.Else_Statement:=$5.Statement;

	    $$.Statement:=Generic_Statement_Ptr(New_If);
	end;
     }


	| Return_Token Return_Expr
	{
	declare
	    New_Return : Return_Statement_Ptr;

	begin
          New_Return:= new Return_Statement;
          New_Return.Return_Value:=$2.Expression;
          New_Return.Line_Number:=Scheduler_Lex.Lines;
          New_Return.File_Name:=File_Name;
          $$.Statement:=Generic_Statement_Ptr(New_Return);
	end;
	}



	| Exit_Token ';'
	{
	declare
          New_Exit : Exit_Statement_Ptr;

	begin
          New_Exit:= new Exit_Statement;
          New_Exit.Line_Number:=Scheduler_Lex.Lines;
          New_Exit.File_Name:=File_Name;
          $$.Statement:=Generic_Statement_Ptr(New_Exit);
	end;
	}

      | For_Token Expr In_Token Table_Type Loop_Token Included_Statements End_Loop_Token ';'
	{
	declare
        	New_For : For_Statement_Ptr;

	begin
                New_For:= new For_Statement;
                New_For.For_Type:=$4.Table_Type_Value;
                New_For.For_Index:=Variable_Expression_Ptr($2.Expression);
                New_For.Line_Number:=Scheduler_Lex.Lines;
                New_For.File_Name:=File_Name;
                New_For.Included_Statement:=$6.Statement;

                $$.Statement:=Generic_Statement_Ptr(New_For);
	end;
      }


      | While_Token Expr Loop_Token Included_Statements End_Loop_Token ';'
      {
	declare
        	New_While : While_Statement_Ptr;

	begin
                New_While:= new While_Statement;
                New_While.Condition:=$2.Expression;
                New_While.Line_Number:=Scheduler_Lex.Lines;
                New_While.File_Name:=File_Name;
                New_While.Included_Statement:=$4.Statement;

                $$.Statement:=Generic_Statement_Ptr(New_While);
	end;

    }


    | Exponential_Token  '(' Identifier_Data ',' Expr ')' ';'
    {
    declare
                New_Random : Random_Initialize_Statement_Ptr;
	begin
                New_Random:= new Random_Initialize_Statement;
                New_Random.Line_Number:=Scheduler_Lex.Lines;
                New_Random.File_Name:=File_Name;
                New_Random.Lvalue:=$3.String_Value;
                New_Random.Law:=Exponential_Law_Type;
                New_Random.Parameter1:=$5.Expression;
                $$.Statement:=Generic_Statement_Ptr(New_Random);
	end;
     }



      | Laplace_Gauss_Token '(' Identifier_Data ',' Expr ',' Expr ')' ';'
	{
	declare
                New_Random : Random_Initialize_Statement_Ptr;
	begin
                New_Random:= new Random_Initialize_Statement;
                New_Random.Line_Number:=Scheduler_Lex.Lines;
                New_Random.File_Name:=File_Name;
                New_Random.Lvalue:=$3.String_Value;
                New_Random.Law:=Laplace_Gauss_Law_Type;
                New_Random.Parameter1:=$5.Expression;
                New_Random.Parameter2:=$7.Expression;
                $$.Statement:=Generic_Statement_Ptr(New_Random);
	end;
	}


      | Uniform_Token '(' Identifier_Data ',' Expr ',' Expr ')' ';'
	{
	declare
                New_Random : Random_Initialize_Statement_Ptr;
	begin
                New_Random:= new Random_Initialize_Statement;
                New_Random.Line_Number:=Scheduler_Lex.Lines;
                New_Random.File_Name:=File_Name;
                New_Random.Lvalue:=$3.String_Value;
                New_Random.Law:=Uniform_Law_Type;
                New_Random.Parameter1:=$5.Expression;
                New_Random.Parameter2:=$7.Expression;
                $$.Statement:=Generic_Statement_Ptr(New_Random);
	end;
	}


      | Set_Token Identifier_Data Expr  ';'
	{
     declare
                New_Set : Set_Statement_Ptr;
     begin
                -- Is the Variable already exists ?
                --
                for I in 0..Sets_Table.Nb_Entries-1 loop
                        if (Sets_Table.Entries(i).Set_Id=$2.String_Value)
                                then
                                     Raise_Exception(Expressions.Syntax_Error'Identity, "file " & To_String(File_Name) & " line " & Scheduler_Lex.Lines'Img &
                                       To_String(Lb_Comma & $2.String_Value & Lb_Comma & Lb_Identifier_Already_Declared(Current_Language) ));
                        end if;
                end loop;

                New_Set := new Set_Statement;
                New_Set.Set_Value:= $3.Expression;
                New_Set.Set_Id := $2.String_Value;
                New_Set.Line_Number := Scheduler_Lex.Lines;
                New_Set.File_Name:=File_Name;
                Add(Sets_Table, New_Set);

                $$.Statement:= Generic_Statement_Ptr(New_Set);
      end;
      };






Put_Parameter :   ',' Expr
	{
          $$.Expression:=$2.Expression;
	}
     |
     {
          $$.Expression:=null;
     };





Return_Expr : Expr ';'
	{
		$$.Expression:=$1.Expression;
	}
	| ';'
	{
		$$.Expression:=null;
	};




User_Type : Double_Type_Token
	{
	    $$.Variable_Type_Value:=Simulation_Double;
	}
      | Array_Token '(' Table_Type ')' Of_Token Double_Type_Token
	{
          if $3.Table_Type_Value=Time_Unit_Table_Type
               then
                  $$.Variable_Type_Value:=Simulation_Time_Unit_Array_Double;
               else
                  $$.Variable_Type_Value:=Simulation_Array_Double;
          end if;
       }
       | Integer_Type_Token
	 {
          $$.Variable_Type_Value:=Simulation_Integer;
	 }
       | Array_Token '(' Table_Type ')' Of_Token Integer_Type_Token
	 {
           if $3.Table_Type_Value=Time_Unit_Table_Type
                then
                   $$.Variable_Type_Value:=Simulation_Time_Unit_Array_Integer;
                else
                   $$.Variable_Type_Value:=Simulation_Array_Integer;
           end if;
	}
 	| Clock_Type_Token
	{
          $$.Variable_Type_Value:=Simulation_Clock;
	}
      | Array_Token '(' Table_Type ')' Of_Token Clock_Type_Token
           {
            if $3.Table_Type_Value=Time_Unit_Table_Type
              then
                   Raise_Exception(Expressions.Syntax_Error'Identity, "file " & To_String(File_Name) & " line " & Scheduler_Lex.Lines'Img &
                     To_String(Lb_Comma &
                     "can not define a Time_Unit array of Clock type."));
              else
                   $$.Variable_Type_Value:=Simulation_Array_Clock;
           end if;
	}
      | Random_Type_Token
	{
           $$.Variable_Type_Value:=Simulation_Random;
	}
      | Array_Token '(' Table_Type ')' Of_Token Random_Type_Token
	{
            if $3.Table_Type_Value=Time_Unit_Table_Type
              then
                   Raise_Exception(Expressions.Syntax_Error'Identity, "file " & To_String(File_Name) & " line " & Scheduler_Lex.Lines'Img &
                     To_String(Lb_Comma &
                     "can not define a Time_Unit array of Random type."));
              else
                   $$.Variable_Type_Value:=Simulation_Array_Clock;
           end if;
	}
      | Boolean_Type_Token
	{
            $$.Variable_Type_Value:=Simulation_Boolean;
	}
      | Array_Token '(' Table_Type ')' Of_Token Boolean_Type_Token
	{
             if $3.Table_Type_Value=Time_Unit_Table_Type
                 then
                    $$.Variable_Type_Value:=Simulation_Time_Unit_Array_Boolean;
                 else
                    $$.Variable_Type_Value:=Simulation_Array_Boolean;
             end if;
	}
      | Array_Token '(' Table_Type ')' Of_Token String_Type_Token
	{
              if $3.Table_Type_Value=Time_Unit_Table_Type
                   then
                      $$.Variable_Type_Value:=Simulation_Time_Unit_Array_String;
                   else
                      $$.Variable_Type_Value:=Simulation_Array_String;
              end if;
	}
      | String_Type_Token
	{
               $$.Variable_Type_Value:=Simulation_String;
	}
	;



Table_Type :  Tasks_Range_Token
	{
                $$.Table_Type_Value:=Task_Table_Type;
	}
      | Buffers_Range_Token
	{
                $$.Table_Type_Value:=Buffer_Table_Type;
	}
      | Messages_Range_Token
	{
                $$.Table_Type_Value:=Message_Table_Type;
	}
      | Time_Units_Range_Token
	{
                $$.Table_Type_Value:=Time_Unit_Table_Type;
	}
      | Processors_Range_Token
	{
                $$.Table_Type_Value:=Processor_Table_Type;
	}
      | Resources_Range_Token
	{
                $$.Table_Type_Value:=Resource_Table_Type;
	}
	;



Assign : Assign_Token Expr
	{
        	$$.Expression:=$2.Expression;
	}
	|
	{
		$$.Expression:=null;
	};


Expr  :
	Expr And_Token Expr
	{
	declare
          New_Expr : Binary_Expression_Ptr;
	begin
          New_Expr:= new Binary_Expression;
          New_Expr.Ope:=Logic_And_Type;
          New_Expr.Lvalue:=$1.Expression;
          New_Expr.Rvalue:=$3.Expression;
          $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

      | Expr Mod_Token Expr
	{
	declare
           New_Expr : Binary_Expression_Ptr;
	begin
           New_Expr:= new Binary_Expression;
           New_Expr.Ope:=Modulo_Type;
           New_Expr.Lvalue:=$1.Expression;
           New_Expr.Rvalue:=$3.Expression;
           $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

	| Expr Inf_Token Expr
	{
	declare
           New_Expr : Binary_Expression_Ptr;
	begin
           New_Expr:= new Binary_Expression;
           New_Expr.Ope:=Inferior_Type;
           New_Expr.Lvalue:=$1.Expression;
           New_Expr.Rvalue:=$3.Expression;
           $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

	| Expr Sup_Token Expr
	{
	declare
            New_Expr : Binary_Expression_Ptr;
	begin
            New_Expr:= new Binary_Expression;
            New_Expr.Ope:=Superior_Type;
            New_Expr.Lvalue:=$1.Expression;
            New_Expr.Rvalue:=$3.Expression;
            $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

	| Expr Inf_Equal_Token Expr
	{
	declare
            New_Expr : Binary_Expression_Ptr;
	begin
            New_Expr:= new Binary_Expression;
            New_Expr.Ope:=Equal_Less_Type;
            New_Expr.Lvalue:=$1.Expression;
            New_Expr.Rvalue:=$3.Expression;
            $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

	| Expr Sup_Equal_Token Expr
	{
	declare
            New_Expr : Binary_Expression_Ptr;
	begin
            New_Expr:= new Binary_Expression;
            New_Expr.Ope:=Equal_Greater_Type;
            New_Expr.Lvalue:=$1.Expression;
            New_Expr.Rvalue:=$3.Expression;
            $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

	| Expr Not_Equal_Token Expr
	{
	declare
            New_Expr : Binary_Expression_Ptr;
	begin
            New_Expr:= new Binary_Expression;
            New_Expr.Ope:=Not_Equal_Type;
            New_Expr.Lvalue:=$1.Expression;
            New_Expr.Rvalue:=$3.Expression;
            $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

	| Expr Equal_Token Expr
	{
	declare
            New_Expr : Binary_Expression_Ptr;
	begin
            New_Expr:= new Binary_Expression;
            New_Expr.Ope:=Equal_Type;
            New_Expr.Lvalue:=$1.Expression;
            New_Expr.Rvalue:=$3.Expression;
            $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

	| Expr Or_Token Expr
	{
	declare
            New_Expr : Binary_Expression_Ptr;
	begin
            New_Expr:= new Binary_Expression;
            New_Expr.Ope:=Logic_Or_Type;
            New_Expr.Lvalue:=$1.Expression;
            New_Expr.Rvalue:=$3.Expression;
            $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

	| Not_Token Expr
	{
	declare
            New_Expr : Unary_Expression_Ptr;
	begin
            New_Expr:= new Unary_Expression;
            New_Expr.Ope:=Logic_Not_Type;
            New_Expr.Value:=$2.Expression;
            $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

      | '(' Expr ')'
	{
        	  $$.Expression:=$2.Expression;
	}

      | True_Token
	{
	declare
		New_Expr : Constant_Expression_Ptr;
	begin
		New_Expr:= new Constant_Expression;
		New_Expr.Value:= new Simulation_Value'(Simulation_Boolean, True);
		$$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

      | False_Token
	{
	declare
		New_Expr : Constant_Expression_Ptr;
	begin
		New_Expr:= new Constant_Expression;
		New_Expr.Value:= new Simulation_Value'(Simulation_Boolean, False);
		$$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

      | Expr '+' Expr
	{
	declare
          New_Expr : Binary_Expression_Ptr;
	begin
          New_Expr:= new Binary_Expression;
          New_Expr.Ope:=Plus_Type;
          New_Expr.Lvalue:=$1.Expression;
          New_Expr.Rvalue:=$3.Expression;
          $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

	| Expr '-' Expr
	{
	declare
          New_Expr : Binary_Expression_Ptr;
	begin
          New_Expr:= new Binary_Expression;
          New_Expr.Ope:=Minus_Type;
          New_Expr.Lvalue:=$1.Expression;
          New_Expr.Rvalue:=$3.Expression;
          $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

	| Expr '*' Expr
	{
	declare
          New_Expr : Binary_Expression_Ptr;
	begin
          New_Expr:= new Binary_Expression;
          New_Expr.Ope:=Multiply_Type;
          New_Expr.Lvalue:=$1.Expression;
          New_Expr.Rvalue:=$3.Expression;
          $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

	| Expr '/' Expr
	{
	declare
          New_Expr : Binary_Expression_Ptr;
	begin
          New_Expr:= new Binary_Expression;
          New_Expr.Ope:=Divide_Type;
          New_Expr.Lvalue:=$1.Expression;
          New_Expr.Rvalue:=$3.Expression;
          $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

      | Lcm_Token '(' Expr ',' Expr ')'
	{
	declare
          New_Expr : Binary_Expression_Ptr;
	begin
          New_Expr:= new Binary_Expression;
          New_Expr.Ope:=Lcm_Type;
          New_Expr.Lvalue:=$1.Expression;
          New_Expr.Rvalue:=$3.Expression;
          $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

     | To_Double_Token '(' Expr ')'
     {
     declare
           New_Expr : Unary_Expression_Ptr;
     begin
           New_Expr:= new Unary_Expression;
           New_Expr.Value:=$3.Expression;
           New_Expr.ope:=To_Double_Type;
           $$.Expression:=Generic_Expression_Ptr(New_Expr);
     end;
     }

     | To_Integer_Token '(' Expr ')'
     {
     declare
           New_Expr : Unary_Expression_Ptr;
     begin
           New_Expr:= new Unary_Expression;
           New_Expr.Value:=$3.Expression;
           New_Expr.ope:=To_Integer_Type;
           $$.Expression:=Generic_Expression_Ptr(New_Expr);
     end;
     }

     | Abs_Token '(' Expr ')'
     {
     declare
           New_Expr : Unary_Expression_Ptr;
     begin
           New_Expr:= new Unary_Expression;
           New_Expr.Value:=$3.Expression;
           New_Expr.ope:=Abs_Type;
           $$.Expression:=Generic_Expression_Ptr(New_Expr);
     end;
     }


     | Concat_Token '(' Expr ',' Expr ')'
     {
     declare
            New_Expr : Binary_Expression_Ptr;
     begin
            New_Expr:= new Binary_Expression;
            New_Expr.Ope:=Concatenate_Type;
            New_Expr.Lvalue:=$1.Expression;
            New_Expr.Rvalue:=$3.Expression;
            $$.Expression:=Generic_Expression_Ptr(New_Expr);
     end;
	}

      | Max_Token '(' Expr ',' Expr ')'
	{
	declare
            New_Expr : Binary_Expression_Ptr;
	begin
            New_Expr:= new Binary_Expression;
            New_Expr.Ope:=Max_Operator_Type;
            New_Expr.Lvalue:=$3.Expression;
            New_Expr.Rvalue:=$5.Expression;
            $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

      | Min_Token '(' Expr ',' Expr  ')'
	{
	declare
            New_Expr : Binary_Expression_Ptr;
	begin
            New_Expr:= new Binary_Expression;
            New_Expr.Ope:=Min_Operator_Type;
            New_Expr.Lvalue:=$3.Expression;
            New_Expr.Rvalue:=$5.Expression;
            $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

	| Expr Exp_Token Expr
	{
	declare
             New_Expr : Binary_Expression_Ptr;
	begin
             New_Expr:= new Binary_Expression;
             New_Expr.Ope:=Exponential_Type;
             New_Expr.Lvalue:=$1.Expression;
             New_Expr.Rvalue:=$3.Expression;
             $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

	| '-' Expr  %prec Unary_Minus
	{
	declare
             New_Expr1 : Binary_Expression_Ptr;
             New_Expr2 : Constant_Expression_Ptr;

	begin
             New_Expr2:= new Constant_Expression;
             if Get_Type($2.Expression.all) = Simulation_Double
                then
                        New_Expr2.Value:= new Simulation_Value'(Simulation_Double,
                                        -1.0);
                else
                        New_Expr2.Value:= new Simulation_Value'(Simulation_Integer,
                                        -1);
              end if;
              New_Expr1:= new Binary_Expression;
              New_Expr1.Ope:=Multiply_Type;
              New_Expr1.Lvalue:=Generic_Expression_Ptr(New_Expr2);
              New_Expr1.Rvalue:=$2.Expression;
              $$.Expression:=Generic_Expression_Ptr(New_Expr1);
	end;
	}

      | '+' Expr  %prec Unary_Plus
      {
      declare
              New_Expr1 : Binary_Expression_Ptr;
              New_Expr2 : Constant_Expression_Ptr;

      begin
              New_Expr2:= new Constant_Expression;
              if Get_Type($2.Expression.all) = Simulation_Double
                then
                        New_Expr2.Value:= new Simulation_Value'(Simulation_Double,
                                        1.0);
                else
                        New_Expr2.Value:= new Simulation_Value'(Simulation_Integer,
                                        1);
              end if;
              New_Expr1:= new Binary_Expression;
              New_Expr1.Ope:=Multiply_Type;
              New_Expr1.Lvalue:=Generic_Expression_Ptr(New_Expr2);
              New_Expr1.Rvalue:=$2.Expression;
              $$.Expression:=Generic_Expression_Ptr(New_Expr1);
      end;
      }

      | Max_To_Index_Token '(' Expr ')'
	{
	declare
              New_Expr : Unary_Expression_Ptr;
	begin

              if  (Current_Section_Type /= Election_Type)
                then
                   Raise_Exception(Expressions.Syntax_Error'Identity, "file " & To_String(File_Name) & " line " & Scheduler_Lex.Lines'Img &
                     To_String(Lb_Comma &
                     "min_to_index and max_to_index operators can only be used in election_section."));
              end if;

              New_Expr := new Unary_Expression;
              New_Expr.Value:=$3.Expression;
              New_Expr.Ope:=Max_To_Index_Type;
              $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

      | Min_To_Index_Token '(' Expr ')'
	{
	declare
              New_Expr : Unary_Expression_Ptr;
	begin
              if  (Current_Section_Type /= Election_Type)
                then
                   Raise_Exception(Expressions.Syntax_Error'Identity, "file " & To_String(File_Name) & " line " & Scheduler_Lex.Lines'Img &
                     To_String(Lb_Comma &
                     "min_to_index and max_to_index operators can only be used in election_section."));
              end if;

              New_Expr := new Unary_Expression;
              New_Expr.value:=$3.Expression;
              New_Expr.Ope:=Min_To_Index_Type;
              $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}


      | Get_Task_Index_Token '(' Expr ')'
	{
	declare
              New_Expr : Unary_Expression_Ptr;
	begin
              New_Expr := new Unary_Expression;
              New_Expr.value:=$3.Expression;
              New_Expr.Ope:=Get_Task_Index_Type;
              $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

      | Get_Resource_Index_Token '(' Expr ')'
	{
	declare
              New_Expr : Unary_Expression_Ptr;
	begin
              New_Expr := new Unary_Expression;
              New_Expr.value:=$3.Expression;
              New_Expr.Ope:=Get_Resource_Index_Type;
              $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

      | Get_Buffer_Index_Token '(' Expr ')'
	{
	declare
              New_Expr : Unary_Expression_Ptr;
	begin
              New_Expr := new Unary_Expression;
              New_Expr.Value:=$3.Expression;
              New_Expr.Ope:=Get_Buffer_Index_Type;
              $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

      | Get_Message_Index_Token '(' Expr ')'
	{
	declare
              New_Expr : Unary_Expression_Ptr;
	begin
              New_Expr := new Unary_Expression;
              New_Expr.Value:=$3.Expression;
              New_Expr.Ope:=Get_Message_Index_Type;
              $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

	| Double_Type_Token ''' Last_Token
	{
	declare
              New_Expr : Constant_Expression_Ptr;
	begin
              New_Expr:= new Constant_Expression;
              New_Expr.Value:= new Simulation_Value'(Simulation_Double,Double'Last);
              $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}
	| Double_Type_Token ''' First_Token
	{
	declare
               New_Expr : Constant_Expression_Ptr;
	begin
               New_Expr:= new Constant_Expression;
               New_Expr.value:= new Simulation_Value'(Simulation_Double,Double'First);
               $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}
	| Integer_Type_Token ''' Last_Token
	{
	declare
              New_Expr : Constant_Expression_Ptr;
	begin
              New_Expr:= new Constant_Expression;
              New_Expr.value:= new Simulation_Value'(Simulation_Integer,Integer'Last);
              $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}
	| Integer_Type_Token ''' First_Token
	{
	declare
              New_Expr : Constant_Expression_Ptr;
	begin
              New_Expr:= new Constant_Expression;
              New_Expr.value:=new Simulation_Value'(Simulation_Integer,Integer'First);
              $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}
      | Identifier_Data '(' Expr ')'
	{
	declare
             New_Expr : Array_Variable_Expression_Ptr;
	begin
             -- Find the type of the $1 Variable
             --
             $$.Expression:=Generic_Expression_Ptr(Variables_Table.Entries(
             Find_Variable(Variables_Table, $1.String_Value, Scheduler_Lex.Lines, file_name)).Variable);

             New_Expr := new Array_Variable_Expression;
             New_Expr.Variable_Type:=Variable_Expression_Ptr($$.Expression).Variable_Type;
             New_Expr.Name:=$1.String_Value;
             New_Expr.Array_index:=$3.Expression;
             $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}
      | Identifier_Data
	{
             -- Find the type of the Variable before
             -- instanciation
             --
             $$.Expression:=Generic_Expression_Ptr(Variables_Table.Entries(
             Find_Variable(Variables_Table, $1.String_Value, Scheduler_Lex.Lines, file_name)).Variable);
	}
      | String_Data
	{
	declare
              New_Expr : Constant_Expression_Ptr;
	begin
              New_Expr:= new Constant_Expression;
              New_Expr.Value:= new Simulation_Value'(Simulation_String,$1.String_Value);
              $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}
	| Double_Data
	{
	declare
              New_Expr : Constant_Expression_Ptr;
	begin
              New_Expr:= new Constant_Expression;
              New_Expr.Value:= new Simulation_Value'(Simulation_Double,$1.Double_Value);
		  $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	}

	| Integer_Data
	{
	declare
              New_Expr : Constant_Expression_Ptr;
	begin
              New_Expr:= new Constant_Expression;
              New_Expr.value:= new Simulation_Value'(Simulation_Integer,$1.Integer_Value);
              $$.Expression:=Generic_Expression_Ptr(New_Expr);
	end;
	};





Identifier_Data :  Identifier_Token
     {
		$$.String_Value := To_Unbounded_String(Scheduler_Dfa.Yytext);
     };


Double_Data     : Double_Token
	{
	declare
		Ok : boolean;

	begin
		To_Double(To_Unbounded_String(Scheduler_Dfa.Yytext),$$.Double_Value,Ok);
         	if not Ok
               then
				Raise_Exception(Expressions.Syntax_Error'Identity, "file " & To_String(File_Name) & " line " & Scheduler_Lex.Lines'Img &
                     To_String(Lb_Comma & To_Unbounded_String(Scheduler_Dfa.Yytext) & Lb_Comma & Lb_Double_Conversion_Error(Current_Language) ));
         	end if;
     end;
	};


String_Data : String_Token
	{
	declare
              Tmp : Unbounded_String;
	begin
              Tmp:=To_Unbounded_String(Scheduler_Dfa.Yytext);
              Tmp:=To_Unbounded_String(Slice(Tmp, 2, Length(Tmp)-1));
              $$.String_Value:=Tmp;
	end;
     };

Integer_Data     : Integer_Token
	{
	declare
		Ok : boolean;

	begin
		To_Integer(To_Unbounded_String(Scheduler_Dfa.Yytext),$$.Integer_Value,Ok);
		if not Ok
			then
				Raise_Exception(Expressions.Syntax_Error'Identity, "file " & To_String(File_Name) & " line " & Scheduler_Lex.Lines'Img &
                     To_String(Lb_Comma & To_Unbounded_String(Scheduler_Dfa.Yytext) & Lb_Comma & Lb_Integer_Conversion_Error(Current_Language) ));
         	end if;
	end;
	};



%%
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
with Interpreter;
use Interpreter;
use Interpreter.Sets_Type_Package;
with Expressions;
use  Expressions;
use  Expressions.Variables_Type_Package;
with Section_Set; use Section_Set;
use Section_Set.Package_Generic_Section_Set;


package Parser is




	-- Function to parse a scheduler behavior
	--
	procedure Yyparse;


	-- Initialize parser Data
	-- First_file prepars the parser to read the first file.
        -- Next_file prepars to read all other files
	--
        procedure First_File(A_File_Name : in Unbounded_String);
        procedure Next_File(A_File_Name : in Unbounded_String);


     	-- Stores the set of sections with their code
     	--
	Root_Statement_Pointer : Sections_Set;


	-- Table to store the list of Variables of
	-- a parametric scheduler
	--
	Variables_Table : Variables_Table_Type;


	-- Table to store the list of "set" statements
	-- in a parametric scheduler
	--
	Sets_Table : Sets_Table_Type;


end Parser;




with Text_Io;
use Text_Io;
with Framework_Config;
use Framework_Config;
with Scheduler_Lex;
use Scheduler_Lex;
with Scheduler_Dfa;
use Scheduler_Dfa;
with Scheduler_Goto;
use Scheduler_Goto;
with Scheduler_Tokens;
use Scheduler_Tokens;
with Scheduler_Shift_Reduce;
use Scheduler_Shift_Reduce;
with Doubles;
use ADoubles;
with Translate;
use Translate;
with Unbounded_Strings;
use Unbounded_Strings;
with Ada.Exceptions;
use Ada.Exceptions;
with Simulations;
use Simulations;
with Simulations.extended;
use Simulations.extended;
with Parameters;
use Parameters;
use Parameters.User_Defined_Parameters_Table_Package;
with Task_Set;
use Task_Set;
use Task_Set.Generic_Task_Set;
with Statements;
use  Statements;
with Sections;
use Sections;
with Laws;
use Laws;
with Automaton;
use Automaton;
with Automaton.Extended;
use Automaton.Extended;
use Automaton.State_Lists_Package;
use Automaton.Transition_Lists_Package;

package body Parser is


        -- These variables store statements of inner blocks of code
        --
        Else_Inner_Statement_Ptr   : Array (0..Max_Block_Level) of Generic_Statement_Ptr;
        Else_Inner_Statement_Index : Natural :=0;
        Then_Inner_Statement_Ptr   : Array (0..Max_Block_Level) of Generic_Statement_Ptr;
        Then_Inner_Statement_Index : Natural :=0;
        Loop_Inner_Statement_Ptr   : Array (0..Max_Block_Level) of Generic_Statement_Ptr;
        Loop_Inner_Statement_Index : Natural :=0;



        -- File name that we are currently treating
        --
        File_Name : Unbounded_string;


        procedure Yyerror(S: String) is
        begin
                Raise_Exception(Expressions.Syntax_Error'Identity, "file " & To_String(File_Name) & " token """ & To_String( To_Unbounded_String(Yytext) & """" & Lb_Comma & " line" & positive'image(Lines) & Lb_Comma & To_Unbounded_String(S) ));
        end Yyerror;

	-- This variables stores the data related
	-- to the section we currently parse
        --
        Current_Section_Type : Sections_type;
        Current_Statement_Pointer : Generic_Statement_Ptr := null;
        Current_Synchronization_Section : Synchronization_Section_Ptr := null;
        Current_Computation_Section : Computation_Section_Ptr;
        Current_Section_Name : Unbounded_String;

        procedure First_File(A_File_Name : in Unbounded_String)  is
           begin
                Else_Inner_Statement_Index:=0;
                Then_Inner_Statement_Index:=0;
                Loop_Inner_Statement_Index:=0;

                Initialize(Sets_Table);
                Initialize(Root_Statement_Pointer);

                Scheduler_Lex.Lines:=1;
                File_Name:=A_File_Name;
           end First_file;

        procedure Next_File(A_File_Name : in Unbounded_String)  is
           begin
                Scheduler_Lex.Lines:=1;
                File_Name:=A_File_Name;
           end Next_file;





##



end Parser;


