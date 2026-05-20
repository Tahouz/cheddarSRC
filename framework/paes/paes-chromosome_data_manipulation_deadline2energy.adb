


with Paes.deadline2energy;      use Paes.deadline2energy;
with Systems;                    use Systems;
with Ada.Numerics.Float_Random ; use Ada.Numerics.Float_Random ;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with unbounded_strings;          use unbounded_strings;
with Tasks;                      use Tasks;
with Task_Set;                   use Task_Set;
with Resources;                  use Resources;
With Resource_set;               use Resource_set;
with Scheduler;                  use Scheduler;
with Scheduler_Interface;        use Scheduler_Interface;
with framework_config;           use framework_config;

--
package body paes.chromosome_Data_Manipulation_deadline2energy is


   function energy_consumption (s : in solution_energry)
	return integer is 
begin 
	return 0;
end energy_consumption;

   procedure init_f2e is 
begin
null;
end init_f2e;

   procedure mutate_f2e (s : in out generic_solution'Class; eidx : in Natural) is 
begin
null;
end mutate_f2e;

   procedure generate_next_element_f2e
     (s                         : in out solution_deadline2energy;
      i,j                         : in out Integer) is 
begin
null;
end generate_next_element_f2e;

   procedure generate_next_solution_f2e
     (s                         : in out solution_deadline2energy;
      space_search_is_exhausted : out boolean) is 
begin
null;
end generate_next_solution_f2e;

   
   procedure normalize(s : in out solution_deadline2energy) is 
begin
null;
end normalize;

   
   Procedure Transform_Chromosome_To_CheddarADL_Model
     (A_sys : in out systems.System;
      s     : in solution_deadline2energy) is 
begin
null;
end Transform_Chromosome_To_CheddarADL_Model;
    
     
   procedure Create_system (A_system : in out systems.System; s     : in solution_deadline2energy) is 
begin
null;
end Create_system;   


end paes.chromosome_Data_Manipulation_deadline2energy;




