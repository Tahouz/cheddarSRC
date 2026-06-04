with Ada.Command_Line;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
use  Ada.Strings.Unbounded;

with Text_IO;
use  Text_IO;

with GNAT.OS_Lib;
with cli_params;
use cli_params;
with cli_types;
use cli_types;

with Call_Framework_Interface;
use Call_Framework_Interface;
package body cli_parser is

procedure Display_Help is
   begin
      Put_Line("DETACH CLI v" & VERSION & " - Command Line Interface for Cheddar");
      New_Line;
      Put_Line("Usage: detach_cli [options]");
      New_Line;
      Put_Line("------------------------------------------------------OPTIONS------------------------------------------------------");
      Put_Line("  --file=<filename.xml>                                             Specify the system file to analyze");
      Put_Line("  --output=<type>[=<filename>]                                      Configure la sortie, où type est:");
      Put_Line("     stdout_analysis                                                         Sortie standard en texte (défaut)");
      Put_Line("     stdout_xml_sysmodel                                            Sortie XML du modèle système sur stdout");
      Put_Line("     stdout_xml_eventtable                                          Sortie XML de la table d'événements sur stdout");
      Put_Line("     file_analysis=<filename>                                   Sortie XML des analyses dans un fichier");
      Put_Line("     file_xml_sysmodel=<filename>                                   Sortie XML du modèle système dans un fichier");
      Put_Line("     file_xml_eventtable=<filename>                                 Sortie XML de la table d'événements dans un fichier");
      New_Line;
      Put_Line("------------------------------------------------------REQUESTS------------------------------------------------------");
      Put_Line("  --request=<type1>,<type2>,...                                    Liste des analyses (ex. simulation,feasibility)");
      Put_Line("     simulation                                                     Simulation temporelle");
      Put_Line("     feasibility                                                    Tests de faisabilité");
      Put_Line("     scheduling_simulation_time_line                                Génère une simulation temporelle");
      Put_Line("     scheduling_feasibility_basics                                  Exécute les tests de faisabilité théoriques");
      Put_Line("     scheduling_simulation_response_time                            Analyse des temps de réponse par simulation");
      Put_Line("     scheduling_set_priorities_according_to_rate_monotonic          Calcule les priorités selon RM");
      Put_Line("     scheduling_set_priorities_according_to_deadline_monotonic      Calcule les priorités selon DM");
      Put_Line("     scheduling_feasibility_first_fit                               Algorithme de placement First-Fit");
      Put_Line("     scheduling_feasibility_best_fit                                Algorithme de placement Best-Fit");
      Put_Line("     scheduling_feasibility_next_fit                                Algorithme de placement Next-Fit");
      Put_Line("     scheduling_feasibility_small_task                              Algorithme de placement Small-Task");
      Put_Line("     scheduling_feasibility_general_task                            Algorithme de placement General-Task");
      Put_Line("     scheduling_simulation_basics                            Analyse basique par simulation");
      Put_Line("     scheduling_simulation_blocking_time                            Analyse des temps de blocage par simulation");
      New_Line;
      Put_Line("------------------------------------------------------PARAMETERS------------------------------------------------------");
      Put_Line("  --param=period=<value>                                            Définir la période maximale de simulation");
      Put_Line("  --param=schedule_with_offsets=0|1                                 Activer/désactiver les offsets en simulation");
      Put_Line("  --param=schedule_with_resources=0|1                               Activer/désactiver les ressources en simulation");
      Put_Line("  --param=running_task=0|1                                          Activer/désactiver les événements de tâche");
      Put_Line("  --param=task_activation=0|1                                       Activer/désactiver les événements d'activation");
      Put_Line("  --help                                                            Afficher ce message d'aide");
      GNAT.OS_Lib.OS_Exit(0);
   end Display_Help;
function Is_Option (Arg : String) return Boolean is
   begin
      return Arg'Length >= 2 and then Arg(Arg'First .. Arg'First+1) = "--";
   end Is_Option;



   function Extract_Option_Name (Arg : String) return String is
      Eq_Pos : Natural;
   begin
      Eq_Pos := Ada.Strings.Fixed.Index(Arg, "=");

      if Eq_Pos = 0 then
         return Arg(Arg'First+2 .. Arg'Last);
      else
         return Arg(Arg'First+2 .. Eq_Pos-1);
      end if;
   end Extract_Option_Name;



   function Extract_Value (Arg : String) return String is
      Eq_Pos : Natural;
   begin
      Eq_Pos := Ada.Strings.Fixed.Index(Arg, "=");

      if Eq_Pos = 0 or else Eq_Pos = Arg'Last then
         return "";
      end if;

      return Arg(Eq_Pos+1 .. Arg'Last);
   end Extract_Value;

   function Parse_Boolean (S : String) return Boolean is
   begin
      if S = "1" then
         return True;
      elsif S = "0" then
         return False;
      else
         Put_Line("Error: boolean must be 0 or 1");
         GNAT.OS_Lib.OS_Exit(1);
         return False;
      end if;
   end Parse_Boolean;
      function String_To_Framework_Statement (S : String) return Framework_Statement_Type is
begin
   -- =========================
   -- Scheduling Simulation
   -- =========================
   if S = "scheduling_simulation_basics" then
      return Scheduling_Simulation_Basics;

   elsif S = "scheduling_simulation_time_line" or S = "simulation" then
      return Scheduling_Simulation_Time_Line;

   elsif S = "scheduling_simulation_preemption_number" then
      return Scheduling_Simulation_Preemption_Number;

   elsif S = "scheduling_simulation_context_switch_number" then
      return Scheduling_Simulation_Context_Switch_Number;

   elsif S = "scheduling_simulation_response_time" then
      return Scheduling_Simulation_Response_Time;

   elsif S = "scheduling_simulation_all_response_times" then
      return Scheduling_Simulation_All_Response_Times;

   elsif S = "scheduling_simulation_blocking_time" then
      return Scheduling_Simulation_Blocking_Time;

   elsif S = "scheduling_simulation_priority_inversion" then
      return Scheduling_Simulation_Priority_Inversion;

   elsif S = "scheduling_simulation_deadlock" then
      return Scheduling_Simulation_Deadlock;

   elsif S = "scheduling_simulation_run_event_handler" then
      return Scheduling_Simulation_Run_Event_Handler;


   -- =========================
   -- Scheduling Feasibility
   -- =========================
   elsif S = "scheduling_feasibility_basics" or S = "feasibility" then
      return Scheduling_Feasibility_Basics;

   elsif S = "scheduling_feasibility_periodic_task_worst_case_response_time" then
      return Scheduling_Feasibility_Periodic_Task_Worst_Case_Response_Time;

   elsif S = "scheduling_feasibility_transaction_worst_case_response_time_audsley" then
      return Scheduling_Feasibility_Transaction_Worst_Case_Response_Time_Audsley;

   elsif S = "scheduling_feasibility_transaction_worst_case_response_time_tindell" then
      return Scheduling_Feasibility_Transaction_Worst_Case_Response_Time_Tindell;

   elsif S = "scheduling_feasibility_transaction_worst_case_response_time_palencia" then
      return Scheduling_Feasibility_Transaction_Worst_Case_Response_Time_Palencia;

   elsif S = "scheduling_feasibility_transaction_worst_case_response_time_wcdops_plus" then
      return Scheduling_Feasibility_Transaction_Worst_Case_Response_Time_WCDOPS_Plus;

   elsif S = "scheduling_feasibility_transaction_worst_case_response_time_wcdops_plus_nim" then
      return Scheduling_Feasibility_Transaction_Worst_Case_Response_Time_WCDOPS_Plus_NIM;

   elsif S = "scheduling_feasibility_cpu_utilization" then
      return Scheduling_Feasibility_Cpu_Utilization;

   elsif S = "scheduling_feasibility_compute_worst_case_blocking_time" then
      return Scheduling_Feasibility_Compute_Worst_Case_Blocking_Time;

   elsif S = "scheduling_feasibility_compute_and_set_worst_case_blocking_time" then
      return Scheduling_Feasibility_Compute_And_Set_Worst_Case_Blocking_Time;

   elsif S = "scheduling_feasibility_compute_resource_ceiling_priority" then
      return Scheduling_Feasibility_Compute_Resource_Ceiling_Priority;

   elsif S = "scheduling_feasibility_compute_and_set_resource_ceiling_priority" then
      return Scheduling_Feasibility_Compute_And_Set_Resource_Ceiling_Priority;

   elsif S = "scheduling_feasibility_tests_compositional" then
      return Scheduling_Feasibility_Tests_Compositional;

   elsif S = "scheduling_feasibility_demand_bound_function" then
      return Scheduling_Feasibility_Demand_Bound_Function;

   elsif S = "scheduling_feasibility_interval" then
      return Scheduling_Feasibility_Interval;

   elsif S = "scheduling_feasibility_first_fit" then
      return Scheduling_Feasibility_First_Fit;

   elsif S = "scheduling_feasibility_next_fit" then
      return Scheduling_Feasibility_Next_Fit;

   elsif S = "scheduling_feasibility_best_fit" then
      return Scheduling_Feasibility_Best_Fit;

   elsif S = "scheduling_feasibility_small_task" then
      return Scheduling_Feasibility_Small_Task;

   elsif S = "scheduling_feasibility_general_task" then
      return Scheduling_Feasibility_General_Task;


   -- =========================
   -- Priority Assignment
   -- =========================
   elsif S = "scheduling_set_priorities_according_to_deadline_monotonic" then
      return Scheduling_Set_Priorities_According_To_Deadline_Monotonic;

   elsif S = "scheduling_set_priorities_according_to_rate_monotonic" then
      return Scheduling_Set_Priorities_According_To_Rate_Monotonic;

   elsif S = "scheduling_set_priorities_according_to_audsley_opa" then
      return Scheduling_Set_Priorities_According_To_Audsley_OPA;

   elsif S = "scheduling_set_priorities_according_to_opa_crpd_pt" then
      return Scheduling_Set_Priorities_According_To_OPA_CRPD_PT;

   elsif S = "scheduling_set_priorities_according_to_opa_crpd_pt_simplified" then
      return Scheduling_Set_Priorities_According_To_OPA_CRPD_PT_Simplified;

   elsif S = "scheduling_set_priorities_according_to_opa_crpd_tree" then
      return Scheduling_Set_Priorities_According_To_OPA_CRPD_Tree;


   -- =========================
   -- Selection / Analysis
   -- =========================
   elsif S = "select_feasibility_tests_simple" then
      return Select_Feasibility_Tests_Simple;

   elsif S = "select_feasibility_test_by_name" then
      return Select_Feasibility_Test_By_Name;

   elsif S = "scheduling_compute_scheduling_anomalies" then
      return Scheduling_Compute_Scheduling_Anomalies;


   -- =========================
   -- Memory
   -- =========================
   elsif S = "memory_set_footprint_analysis" then
      return Memory_Set_Footprint_Analysis;

   elsif S = "memory_compute_footprint_analysis" then
      return Memory_Compute_Footprint_Analysis;

   elsif S = "memory_analysis_interferences_delays" then
      return Memory_Analysis_Interferences_Delays;


   -- =========================
   -- Buffer
   -- =========================
   elsif S = "buffer_feasibility_tests" then
      return Buffer_Feasibility_Tests;

   elsif S = "buffer_scheduling_simulation" then
      return Buffer_Scheduling_Simulation;


   -- =========================
   -- Random / Response Time
   -- =========================
   elsif S = "random_response_time_density" then
      return Random_Response_Time_Density;


   -- =========================
   -- Dependency Analysis
   -- =========================
   elsif S = "dependency_compute_end_to_end_response_time_one_step" then
      return Dependency_Compute_End_To_End_Response_Time_One_Step;

   elsif S = "dependency_set_end_to_end_response_time_one_step" then
      return Dependency_Set_End_To_End_Response_Time_One_Step;

   elsif S = "dependency_compute_end_to_end_response_time_all_steps" then
      return Dependency_Compute_End_To_End_Response_Time_All_Steps;

   elsif S = "dependency_set_end_to_end_response_time_all_steps" then
      return Dependency_Set_End_To_End_Response_Time_All_Steps;

   elsif S = "dependency_compute_chetto_blazewicz_priority" then
      return Dependency_Compute_Chetto_Blazewicz_Priority;

   elsif S = "dependency_compute_chetto_blazewicz_deadline" then
      return Dependency_Compute_Chetto_Blazewicz_Deadline;

   elsif S = "dependency_set_chetto_blazewicz_priority" then
      return Dependency_Set_Chetto_Blazewicz_Priority;

   elsif S = "dependency_set_chetto_blazewicz_deadline" then
      return Dependency_Set_Chetto_Blazewicz_Deadline;


   -- =========================
   -- Cache Analysis
   -- =========================
   elsif S = "cache_analysis_compute_cache_access_profile" then
      return Cache_Analysis_Compute_Cache_Access_Profile;

   elsif S = "cache_analysis_import_cfg" then
      return Cache_Analysis_Import_CFG;

   elsif S = "cache_analysis_import_cfg_and_compute_cache_access_profile" then
      return Cache_Analysis_Import_CFG_And_Compute_Cache_Access_Profile;


   -- =========================
   -- Network / NoC
   -- =========================
   elsif S = "network_noc_compute_communication_delay" then
      return Network_NoC_Compute_Communication_Delay;

   elsif S = "network_noc_compute_path_delay" then
      return Network_NoC_Compute_Path_Delay;

   elsif S = "network_noc_compute_direct_interference_delay" then
      return Network_NoC_Compute_Direct_Interference_Delay;

   elsif S = "network_noc_compute_indirect_interference_delay" then
      return Network_NoC_Compute_Indirect_Interference_Delay;


   elsif S = "network_compute_noc_transformation_ectm_saf" then
      return Network_Compute_NoC_Transformation_ECTM_SAF;

   elsif S = "network_set_noc_transformation_ectm_saf" then
      return Network_Set_NoC_Transformation_ECTM_SAF;

   elsif S = "network_compute_noc_transformation_ectm_wormhole" then
      return Network_Compute_NoC_Transformation_ECTM_Wormhole;

   elsif S = "network_set_noc_transformation_ectm_wormhole" then
      return Network_Set_NoC_Transformation_ECTM_Wormhole;

   elsif S = "network_compute_noc_transformation_wcctm_saf" then
      return Network_Compute_NoC_Transformation_WCCTM_SAF;

   elsif S = "network_set_noc_transformation_wcctm_saf" then
      return Network_Set_NoC_Transformation_WCCTM_SAF;

   elsif S = "network_compute_noc_transformation_wcctm_wormhole" then
      return Network_Compute_NoC_Transformation_WCCTM_Wormhole;

   elsif S = "network_set_noc_transformation_wcctm_wormhole" then
      return Network_Set_NoC_Transformation_WCCTM_Wormhole;

   elsif S = "network_compute_spacewire_transformation_scm" then
      return Network_Compute_Spacewire_Transformation_SCM;

   elsif S = "network_set_spacewire_transformation_scm" then
      return Network_Set_Spacewire_Transformation_SCM;


   -- =========================
   -- MILS Security
   -- =========================
   elsif S = "mils_compute_security_chinese_wall" then
      return MILS_Compute_security_chinese_wall;

   elsif S = "mils_compute_security_warshall" then
      return MILS_Compute_security_Warshall;

   elsif S = "mils_compute_security_bell_lapadula" then
      return MILS_Compute_security_bell_lapadula;

   elsif S = "mils_compute_security_biba" then
      return MILS_Compute_security_biba;


   else
      raise Constraint_Error with "Type de requête non reconnu: " & S;
   end if;
end String_To_Framework_Statement;

   procedure Parse_Request_List(Config : in out Cli_Config;Arg : String ) is
      Start, Stop : Natural := Arg'First;
      Temp : String(1..100);
      Len : Natural;
      F_statement:Framework_Statement_Type;
   begin
      Config.Request_Count := 0;
      while Start <= Arg'Last and Config.Request_Count < Config.Request_Types'Length loop
         Stop := Ada.Strings.Fixed.Index(Source => Arg, Pattern => ",", From => Start);
         if Stop = 0 then Stop := Arg'Last + 1; end if;
         Len := Stop - Start;
         if Len = 0 then
            Put_Line("Error: Empty request type in list");
            GNAT.OS_Lib.OS_Exit(1);
         end if;
         Temp(1..Len) := Arg(Start..Stop-1);
         F_statement:=String_To_Framework_Statement(Temp(1..Len));
         Config.Request_Count := Config.Request_Count + 1;
         Config.Request_Types(Config.Request_Count) := F_statement;
         Start := Stop + 1;
      end loop;
      if Config.Request_Count = 0 then
         Put_Line("Error: No valid request types specified");
         GNAT.OS_Lib.OS_Exit(1);
      end if;
   exception
      when Constraint_Error =>
         Put_Line("Error: Invalid request type in list: " & Arg);
         GNAT.OS_Lib.OS_Exit(1);
   end Parse_Request_List;

   
procedure Parse_Parameter(Param_Str : String) is
      Eq_Pos : Natural;
      Name, Value : String(1..100);
      Name_Len, Value_Len : Natural;
      Period:Integer;
      
   begin
      Eq_Pos := Ada.Strings.Fixed.Index(Source => Param_Str, Pattern => "=");
      if Eq_Pos = 0 then
         Put_Line("Error: Parameter format should be name=value");
         GNAT.OS_Lib.OS_Exit(1);
      end if;
      Name := (others => ' ');
      Value := (others => ' ');
      Name_Len := Eq_Pos - 1;
      Value_Len := Param_Str'Last - Eq_Pos;
      Name(1..Name_Len) := Param_Str(Param_Str'First..Eq_Pos-1);
      Value(1..Value_Len) := Param_Str(Eq_Pos+1..Param_Str'Last);
      if Name(1..Name_Len) = "period" then
         begin
            Period := Integer'Value(Value(1..Value_Len));
            if Period > 0 then
               cli_params.Add_Int(cli_params.period,Period);
            end if;
         exception
            when Constraint_Error =>
               Put_Line("Error: Invalid period value: " & Value(1..Value_Len));
               GNAT.OS_Lib.OS_Exit(1);
         end;
      elsif Name(1..Name_Len) = "seed_value" then
      declare
         Seed : Integer;
      begin
         Seed := Integer'Value(Value(1..Value_Len));
         cli_params.Add_Int(cli_params.seed_value, Seed);

      exception
         when Constraint_Error =>
            Put_Line("Error: Invalid seed_value: " & Value(1..Value_Len));
            GNAT.OS_Lib.OS_Exit(1);
      end;

      elsif Name(1..Name_Len) = "schedule_with_offsets" then
         cli_params.Add_Bool(cli_params.schedule_with_offsets,Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "schedule_with_resources" then
         cli_params.Add_Bool(cli_params.schedule_with_resources,Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "running_task" then
         cli_params.Add_Bool(cli_params.running_task,Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "task_activation" then
         cli_params.Add_Bool(cli_params.task_activation,Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "minimize_preemption" then
         cli_params.Add_Bool(cli_params.minimize_preemption,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "task_specific_seed" then
         cli_params.Add_Bool(cli_params.task_specific_seed,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "predictable" then
         cli_params.Add_Bool(cli_params.predictable,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "start_of_task_capacity" then
         cli_params.Add_Bool(cli_params.start_of_task_capacity,
                           Parse_Boolean(Value(1..Value_Len)));

      elsif Name(1..Name_Len) = "end_of_task_capacity" then
         cli_params.Add_Bool(cli_params.end_of_task_capacity,
                           Parse_Boolean(Value(1..Value_Len)));

      elsif Name(1..Name_Len) = "write_to_buffer" then
         cli_params.Add_Bool(cli_params.write_to_buffer,
                           Parse_Boolean(Value(1..Value_Len)));

      elsif Name(1..Name_Len) = "read_from_buffer" then
         cli_params.Add_Bool(cli_params.read_from_buffer,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "discard_missed_deadline" then
         cli_params.Add_Bool(cli_params.discard_missed_deadline,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "send_message" then
         cli_params.Add_Bool(cli_params.send_message,
                           Parse_Boolean(Value(1..Value_Len)));

      elsif Name(1..Name_Len) = "receive_message" then
         cli_params.Add_Bool(cli_params.receive_message,
                           Parse_Boolean(Value(1..Value_Len)));

      elsif Name(1..Name_Len) = "allocate_resource" then
         cli_params.Add_Bool(cli_params.allocate_resource,
                           Parse_Boolean(Value(1..Value_Len)));

      elsif Name(1..Name_Len) = "release_resource" then
         cli_params.Add_Bool(cli_params.release_resource,
                           Parse_Boolean(Value(1..Value_Len)));

      elsif Name(1..Name_Len) = "wait_for_resource" then
         cli_params.Add_Bool(cli_params.wait_for_resource,
                           Parse_Boolean(Value(1..Value_Len)));

      elsif Name(1..Name_Len) = "address_space_activation" then
         cli_params.Add_Bool(cli_params.address_space_activation,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "schedule_with_jitters" then
         cli_params.Add_Bool(cli_params.schedule_with_jitters,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "context_switch_overhead" then
         cli_params.Add_Bool(cli_params.context_switch_overhead,
                           Parse_Boolean(Value(1..Value_Len)));

      elsif Name(1..Name_Len) = "schedule_with_task_groups" then
         cli_params.Add_Bool(cli_params.schedule_with_task_groups,
                           Parse_Boolean(Value(1..Value_Len)));

      elsif Name(1..Name_Len) = "anomaly_detection" then
         cli_params.Add_Bool(cli_params.anomaly_detection,
                           Parse_Boolean(Value(1..Value_Len)));

      elsif Name(1..Name_Len) = "dvfs" then
         cli_params.Add_Bool(cli_params.dvfs,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "preemption" then
         cli_params.Add_Bool(cli_params.preemption,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "wait_for_memory" then
         cli_params.Add_Bool(cli_params.wait_for_memory,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "buffer_underflow" then
         cli_params.Add_Bool(cli_params.buffer_underflow,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "buffer_overflow" then
         cli_params.Add_Bool(cli_params.buffer_overflow,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "mode_change" then
         cli_params.Add_Bool(cli_params.mode_change,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "schedule_with_precedencies" then
         cli_params.Add_Bool(cli_params.schedule_with_precedencies,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "tdma_slot" then
         cli_params.Add_Bool(cli_params.tdma_slot,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "schedule_with_crpd" then
         cli_params.Add_Bool(cli_params.schedule_with_crpd,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "schedule_with_discard_missed_deadlines" then
         cli_params.Add_Bool(cli_params.schedule_with_discard_missed_deadlines,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "energy" then
         cli_params.Add_Bool(cli_params.energy,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "r_worst_case" then
         cli_params.Add_Bool(cli_params.r_worst_case,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "r_best_case" then
         cli_params.Add_Bool(cli_params.r_best_case,
                           Parse_Boolean(Value(1..Value_Len)));  
      elsif Name(1..Name_Len) = "r_average_case" then
         cli_params.Add_Bool(cli_params.r_average_case,
                           Parse_Boolean(Value(1..Value_Len)));    
      elsif Name(1..Name_Len) = "b_worst_case" then
         cli_params.Add_Bool(cli_params.b_worst_case,
                           Parse_Boolean(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "b_best_case" then
         cli_params.Add_Bool(cli_params.b_best_case,
                           Parse_Boolean(Value(1..Value_Len)));  
      elsif Name(1..Name_Len) = "b_average_case" then
         cli_params.Add_Bool(cli_params.b_average_case,
                           Parse_Boolean(Value(1..Value_Len)));     
      elsif Name(1..Name_Len) = "feasibility_test_name" then
         cli_params.Add_Str(cli_params.feasibility_test_name,
                           To_Unbounded_String(Value(1..Value_Len)));
      elsif Name(1..Name_Len) = "wcrt_crpd" then
         cli_params.Add_wcrt_crpd_options(Integer'Value(Value(1..Value_Len))); 
      elsif Name(1..Name_Len) = "wcrt_memory_interferences" then
         cli_params.Add_wcrt_memory_interferences_options(Integer'Value(Value(1..Value_Len)));                                      
      else
         Put_Line("Warning: Unknown parameter: " & Name(1..Name_Len));
      end if;
   end Parse_Parameter;



procedure Parse_Command_Line (Config : in out Cli_Config) is
   I : Positive := 1;

   Arg : String (1 .. 1024);
   Arg_Len : Natural;

   Option_Name : String (1 .. 1024);
   Option_Name_Len : Natural;

   Value : String (1 .. 1024);
   Value_Len : Natural;

   Arg_Count : Natural := Ada.Command_Line.Argument_Count;
begin

   while I <= Arg_Count loop

      Arg := (others => ' ');
      Arg_Len := Ada.Command_Line.Argument(I)'Length;
      Arg(1 .. Arg_Len) := Ada.Command_Line.Argument(I);

      if Is_Option(Arg(1 .. Arg_Len)) then

         Option_Name := (others => ' ');
         Option_Name_Len := Extract_Option_Name(Arg(1 .. Arg_Len))'Length;
         Option_Name(1 .. Option_Name_Len) :=
            Extract_Option_Name(Arg(1 .. Arg_Len));



         if Option_Name(1 .. Option_Name_Len) = "help" then
            Display_Help ;
         -- =====================
         -- FILE
         -- =====================
         elsif Option_Name(1 .. Option_Name_Len) = "file" then

            Value := (others => ' ');
            Value_Len := Extract_Value(Arg(1 .. Arg_Len))'Length;
            Value(1 .. Value_Len) := Extract_Value(Arg(1 .. Arg_Len));

            if Value_Len = 0 then
               Put_Line("Error: --file needs filename");
               GNAT.OS_Lib.OS_Exit(1);
            end if;

            Config.Input_File := To_Unbounded_String(Value(1 .. Value_Len));

         -- =====================
         -- OUTPUT
         -- =====================
         elsif Option_Name(1 .. Option_Name_Len) = "output" then

            Value := (others => ' ');
            Value_Len := Extract_Value(Arg(1 .. Arg_Len))'Length;
            Value(1 .. Value_Len) := Extract_Value(Arg(1 .. Arg_Len));

            declare
               Equal_Pos : constant Natural :=
                  Ada.Strings.Fixed.Index(Value(1 .. Value_Len), "=");
            begin

               if Equal_Pos = 0 then
                  if Value(1 .. Value_Len) = "stdout_analysis" then
                     Config.Print_Mode := cli_types.analysis;
                     Config.Format := String_Output;
                  elsif Value(1 .. Value_Len) = "stdout_xml_analysis" then
                     Config.Print_Mode := cli_types.analysis;
                     Config.Format := Xml_Output;
                  elsif Value(1 .. Value_Len) = "stdout_xml_sysmodel" then
                     Config.Print_Mode := cli_types.system;
                  elsif Value(1 .. Value_Len) = "stdout_xml_eventtable" then
                     Config.Print_Mode := cli_types.event_table;

                  end if;
               else
                  declare
                     Type_Str : constant String :=
                        Value(1 .. Equal_Pos - 1);
                     File_Str : constant String :=
                        Value(Equal_Pos + 1 .. Value_Len);
                  begin
                     if Type_Str = "file_analysis" then
                        Config.Print_Mode := analysis;
                        Config.Format := Call_Framework_Interface.String_Output;
                        Put ("Fomat is String");
                     elsif Type_Str = "file_xml_analysis" then
                        Config.Print_Mode := cli_types.analysis;
                        Config.Format := Call_Framework_Interface.Xml_Output;
                        Put ("Fomat is Xml");
                     elsif Type_Str = "file_xml_sysmodel" then
                        Config.Print_Mode := cli_types.system;
                     elsif Type_Str = "file_xml_eventtable" then
                        Config.Print_Mode := event_table;
                     end if;
                     Config.Output_File :=To_Unbounded_String(File_Str);
                     Config.Output_To_File := True;
                  end;
               end if;
            end;

         -- =====================
         -- TARGET
         -- =====================
         elsif Option_Name(1 .. Option_Name_Len) = "target" then

            Value := (others => ' ');
            Value_Len := Extract_Value(Arg(1 .. Arg_Len))'Length;
            Value(1 .. Value_Len) := Extract_Value(Arg(1 .. Arg_Len));

            Config.Target :=
               To_Unbounded_String(Value(1 .. Value_Len));

         -- =====================
         -- REQUEST
         -- =====================
         elsif Option_Name(1 .. Option_Name_Len) = "request" then

            Value := (others => ' ');
            Value_Len := Extract_Value(Arg(1 .. Arg_Len))'Length;
            Value(1 .. Value_Len) := Extract_Value(Arg(1 .. Arg_Len));

            Parse_Request_List(
               Config,
               Value(1 .. Value_Len)
            );
         elsif Option_Name(1..Option_Name_Len) = "param" then
            Value := (others => ' ');
            Value_Len := Extract_Value(Arg(1..Arg_Len))'Length;
            Value(1..Value_Len) := Extract_Value(Arg(1..Arg_Len));
            if Value_Len = 0 then
              Put_Line("Error: --param switch needs a name=value pair");
              GNAT.OS_Lib.OS_Exit(1);
           end if;
           Parse_Parameter(Value(1..Value_Len));
         else
            Put_Line("Unknown option: --" &
               Option_Name(1 .. Option_Name_Len));
            GNAT.OS_Lib.OS_Exit(1);
         end if;

      else
         Put_Line("Unknown argument: " & Arg(1 .. Arg_Len));
         GNAT.OS_Lib.OS_Exit(1);
      end if;

      I := I + 1;
   end loop;

end Parse_Command_Line;



end cli_parser;