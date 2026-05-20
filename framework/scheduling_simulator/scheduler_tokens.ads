with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Doubles;               use Doubles;
with Statements;            use Statements;
with Interpreter;           use Interpreter;
use Interpreter.Sets_Type_Package;
with expressions; use expressions;
use expressions.variables_type_package;
with Simulations; use Simulations;
with section_set; use section_set;
use section_set.package_generic_section_set;
with Sections;           use Sections;
with Automaton;          use Automaton;
with Automaton.extended; use Automaton.extended;
use Automaton.State_Lists_Package;
use Automaton.Transition_Lists_Package;
package Scheduler_Tokens is

   type key_type is (cval, ival, noval);

   type yystype is record
      String_Value        : Unbounded_String;
      Integer_Value       : Integer;
      Double_Value        : Double;
      Expression          : generic_expression_ptr;
      Statement           : generic_statement_ptr;
      Variable_Type_Value : simulation_type;
      Table_Type_Value    : table_types;
      State               : state_ptr;
      Transition          : transition_ptr;
      Synchronization     : synchronization_ptr;
   end record;

   YYLVal, YYVal : yystype;
   type token is
     (end_of_input,
      error,
      double_type_token,
      array_token,
      integer_type_token,
      task_token,
      string_type_token,
      clock_type_token,
      boolean_type_token,
      of_token,
      last_token,
      first_token,
      double_token,
      integer_token,
      identifier_token,
      true_token,
      false_token,
      string_token,
      in_token,
      for_token,
      is_token,
      function_token,
      procedure_token,
      set_token,
      while_token,
      loop_token,
      message_token,
      processor_token,
      buffer_token,
      resource_token,
      time_unit_token,
      tasks_range_token,
      messages_range_token,
      processors_range_token,
      buffers_range_token,
      resources_range_token,
      time_units_range_token,
      return_token,
      max_token,
      min_token,
      lcm_token,
      put_token,
      mod_token,
      abs_token,
      max_to_index_token,
      min_to_index_token,
      to_integer_token,
      to_double_token,
      then_token,
      end_token,
      else_token,
      if_token,
      end_if_token,
      end_loop_token,
      random_type_token,
      uniform_token,
      exponential_token,
      laplace_gauss_token,
      get_task_index_token,
      get_buffer_index_token,
      get_message_index_token,
      get_resource_index_token,
      exit_token,
      state_token,
      initial_state_token,
      end_section_token,
      automaton_token,
      gather_event_analyzer_token,
      display_event_analyzer_token,
      start_token,
      priority_token,
      election_token,
      activation_token,
      check_resource_token,
      release_resource_token,
      allocate_resource_token,
      transition_token,
      transition_arrow_token,
      '?',
      '!',
      delay_token,
      add_precedence_token,
      delete_precedence_token,
      '[',
      ']',
      '(',
      ')',
      '}',
      '{',
      equal_token,
      '+',
      '-',
      '*',
      '/',
      unary_minus,
      unary_plus,
      exp_token,
      ':',
      '|',
      ';',
      ',',
      inf_token,
      sup_token,
      inf_equal_token,
      sup_equal_token,
      not_equal_token,
      assign_token,
      concat_token,
      or_token,
      and_token,
      not_token,
      ''');

   Syntax_Error : exception;

end Scheduler_Tokens;
