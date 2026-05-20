
with cli_parser;
with Framework_Config;

with Text_IO;                     use Text_IO;
with Ada.Strings.Unbounded;       use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;           
with Ada.Exceptions;              use Ada.Exceptions;
with Ada.Directories;             use Ada.Directories;
with Ada.Command_Line;            use Ada.Command_Line;
with GNAT.OS_Lib;                 
with cli_params;
use cli_params;
-- Packages Cheddar
with task_set;
use task_set;

with Systems;                     use Systems;
with Framework;                   use Framework;
with Call_Framework;              use Call_Framework;
with Call_Framework_Interface;    use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with Parameters;                  use Parameters;
use Parameters.Framework_Parameters_Table_Package;
with unbounded_strings;           use unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
with scheduling_simulation_util;  use scheduling_simulation_util;
with multiprocessor_services;use multiprocessor_services;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with call_scheduling_framework;   use call_scheduling_framework;
with Processors;                  use Processors;
with processor_set;               use processor_set;
with time_unit_events;            use time_unit_events;
with scheduler_interface;         use scheduler_interface;


with cli_types;
use cli_types;
procedure cheddar_cli is
   -- Version
   Config : cli_types.Cli_Config;
   -- Variables de travail utilisées pendant l'exécution du programme
   Sys : systems.system;
   Project_File_Dir_List : unbounded_string_list;
   --  Results : Unbounded_String := Null_Unbounded_String;
   Result_File : File_Type;
   --Tableau de Requete de la CLI 
   Cli_Resquest_List:Call_Framework_Interface.Framework_Request_Table;
   --Tableau de Résponse de la CLI
   response_list:Call_Framework_Interface.Framework_Response_Table;



-- function crée une requete avec les paramètres qu'elle accepte et que l'utilisateur a fourni 
   function build_request
  (request_statement : Call_Framework_Interface.Framework_Statement_Type)
   return Framework_Request
is
   a_request : Call_Framework_Interface.Framework_Request;
begin
   initialize(a_request);
   a_request.target    := Config.target;
   a_request.statement := request_statement;

   -- Scheduling Simulation Timeline
   if request_statement = Scheduling_Simulation_Time_Line then
      if cli_params.getValue(cli_params.period) = null then 
         cli_params.Add_Int (cli_params.period, compute_hyperperiod(Sys.tasks));
      end if;
      for K in simulation_time_line_range loop
         declare
            a_param : Parameters.Parameter_Ptr;
         begin
            a_param := cli_params.getValue(K);
            if a_param /= null then
            Add(a_request.param, a_param);
            end if;
         end;
      end loop;
   -- Feasibility Response Time
   elsif request_statement = scheduling_feasibility_periodic_task_worst_case_response_time then
      for K in feasibility_response_time_range loop
         declare
            a_param : Parameters.Parameter_Ptr;
         begin
            a_param := cli_params.getValue(K);
            if a_param /= null then
               Add(a_request.param, a_param);
            end if;
         end;
      end loop;
   -- Feasibility Test By Name
   elsif request_statement = select_feasibility_test_by_name then
      for K in feasibility_test_by_name_range loop
         declare
            a_param : Parameters.Parameter_Ptr;
         begin
            a_param := cli_params.getValue(K);
            if a_param /= null then
               Add(a_request.param, a_param);
            end if;
         end;
      end loop;


   -- Simulation Response Time 
   elsif request_statement = Scheduling_Simulation_Response_Time
      
   then
      for K in simulation_response_time_range loop
         declare
            a_param : Parameters.Parameter_Ptr;
         begin
            a_param := cli_params.getValue(K);
            if a_param /= null then
               Add(a_request.param, a_param);
            end if;
         end;
      end loop;
   --  Simulation Blocking Time
   elsif request_statement = Scheduling_Simulation_Blocking_Time
   then 
      for K in simulation_blocking_time_range loop
         declare
            a_param : Parameters.Parameter_Ptr;
         begin
            a_param := cli_params.getValue(K);
            if a_param /= null then
               Add(a_request.param, a_param);
            end if;
         end;
      end loop;
   end if;
   return a_request;
end build_request;

procedure build_request_list is
begin 
   for I in 1..Config.Request_Count loop
   declare
   request :Call_Framework_Interface.Framework_Request;
   begin 
      request:=build_request(Config.Request_Types(I));
      add(Cli_Resquest_List,request);
   end;
   end loop;
end;


   procedure  output_Result(ouput_type : Print_Type ; Response_List:Framework_Response_Table ) 
   is 
   result :Unbounded_String :=To_unbounded_String("");
   begin
   case ouput_type is
   when cli_types.system =>
      if Config.Output_To_File then
         write_to_xml_file(Sys,Config.Output_File & ".xml");
         --  put("System File exported to file : " & To_String(Output_File) & ".xml");
      else
         put_xml (Sys);
      end if;
      
   when cli_types.event_table  =>
      if Framework.sched /= null then 
         get_xml_event_table(Framework.sched,sys,result);

         if Config.Output_To_File then
            write_to_xml_file(Framework.sched,sys,Config.Output_File & ".xml");
            --  put("Event Table exported to file : " & To_String(Output_File) & ".xml");
         else
         put(To_string(result));
         end if;
      else
         put("No simulation is Data Available Can't Output EventTable");
      end if;

   when others =>
      for i in 0 .. Response_List.nb_entries - 1 loop
            if Config.format = Call_Framework_Interface.String_Output then 
               Result:= Result & response_list.entries(i).title;
            end if;
            Result := Result & Response_List.entries(i).text;
      end loop;
      if Config.Output_To_File then
         if Config.Format = Call_Framework_Interface.String_Output then
            Config.Output_File := Config.Output_File & ".txt";
         elsif Config.Format = Call_Framework_Interface.Xml_Output then
               Config.Output_File := Config.Output_File & ".xml";
         end if;
         Create(Result_File, Out_File, To_String(Config.Output_File));
         Put(Result_File, To_String(Result));
         Close(Result_File);
         put("Analysis exported to file : " & To_String(Config.Output_File));
      else
      put(To_string(result));
      end if;
      
   end case;
   -- put(  ASCII.LF & "=========================================" & ASCII.LF);
   end output_Result;

 procedure Execute
   is 
      Result:Unbounded_String:=empty_string;
   begin
   Result := Result & "DETACH CLI v" & VERSION & " - Analysis Results" & ASCII.LF;
   Result := Result & "=========================================" & ASCII.LF;
   Result := Result & "Input file: " & To_String(Config.Input_File) & ASCII.LF;
   initialize(response_list);
   build_request_list;
   call_framework.sequential_framework_request (Sys, Cli_Resquest_List, response_list,Total_Order,Config.Format);
   Put (To_String(Result));
   output_Result (Config.Print_Mode ,response_list);
   end Execute;
begin
   cli_params.initialize;
   Call_Framework.initialize(False);
   initialize(Project_File_Dir_List);
   cli_parser.Parse_Command_Line (Config);
  
  if Config.Input_File = Null_Unbounded_String then
     Put_Line("Error: Input file must be specified with --file");
     GNAT.OS_Lib.OS_Exit(1);
  end if;
  
  if not Exists(To_String(Config.Input_File)) then
     Put_Line("Error: Input file does not exist: " & To_String(Config.Input_File));
     GNAT.OS_Lib.OS_Exit(1);
  end if;
  
  if Config.Request_Count = 0 then
     Put_Line("Error: At least one request must be specified with --request");
     GNAT.OS_Lib.OS_Exit(1);
  end if;
  
  begin
     if Extension(To_String(Config.Input_File)) = "xml" then
        Systems.read_from_xml_file(
           Sys,
           Project_File_Dir_List,
           Config.Input_File);
     elsif Extension(To_String(Config.Input_File)) = "xmlv3" then
        Systems.read_from_v2_xml_file(
           Sys,
           Project_File_Dir_List,
           Config.Input_File);
     else
        Put_Line("Error: Input file must have .xml or .xmlv3 extension");
        GNAT.OS_Lib.OS_Exit(1);
     end if;
  exception
     when others =>
        Put_Line("Error: Cannot read system file: " & To_String(Config.Input_File));
        GNAT.OS_Lib.OS_Exit(1);
  end;
   Execute;  
  GNAT.OS_Lib.OS_Exit(0);
exception
  when E : others =>
     Put_Line("Error: " & Exception_Message(E));
     GNAT.OS_Lib.OS_Exit(1);
end cheddar_cli;