with Paes.deadline2energy;      use Paes.deadline2energy;
with systems;                   use systems;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with unbounded_strings;         use unbounded_strings;
with Tasks;                     use Tasks;
with task_set;                  use task_set;
with Resources;                 use Resources;
with resource_set;              use resource_set;
with scheduler;                 use scheduler;
with Scheduler_Interface;       use Scheduler_Interface;
with Framework_Config;          use Framework_Config;

--
package Paes.chromosome_Data_Manipulation_deadline2energy is

   -------------------------
   --   Global variables  --
   -------------------------
   --
   --
   -- Initial_System is the Cheddar-ADL model
   -- of the initial design
   Initial_System : systems.system;

   -- Hyperperiod_of_Initial_Taskset is the hyperperiod
   -- of the initial design
   --
   Hyperperiod_of_Initial_Taskset : Integer;

   -- The_Scheduler is the priority assignment
   -- policy used in the scheduling simulation
   The_Scheduler : schedulers_type;

   -- values of Task_priority and Sched_policy varaibles
   -- depend of the The_Scheduler value
   -- for example:
   -- *) The_Scheduler = Rate_Monotonic_Protocol
   --    =>> Task_priority = 1  || Sched_policy = SCHED_FIFO
   -- *) The_Scheduler = Earliest_Deadline_First_Protocol
   --    =>> Task_priority = 0  || Sched_policy = SCHED_OTHERS
   --
   Task_priority : Integer;
   Sched_policy  : policies;

   -- This variable represents the maximum hyperperiod
   -- of the explored solutions
   --
   Max_hyperperiod : Integer;

   -- This variable is used to differentiate the cases:
   -- when Using_preprocessed_initial_sol = false; i.e. the initial
   -- solution is 1-1 fcts-tasks mapping
   -- otherwise, we use the preprocessed initial solution
   --
   Using_preprocessed_initial_sol : Boolean := False;

   One_to_one_mapping_solution : solution_deadline2energy;

   -- These subprograms are the specific implementation
   -- of PAES generic subprograms, that will be used
   -- in order to instanciate PAES_method/Exhaustive_method
   --
   procedure init_deadline2energy;
   procedure mutate_deadline2energy
     (s    : in out generic_solution'class;
      eidx : in     Natural);
   procedure generate_next_element_deadline2energy
     (s    : in out solution_deadline2energy;
      i, j : in out Integer);
   procedure generate_next_solution_deadline2energy
     (s                         : in out solution_deadline2energy;
      space_search_is_exhausted :    out Boolean);

   -- This procedure is used to normalize a mutated solution
   -- exemple to normalize a solution:
   -- [5 2 5 3 4 5 2] => after normalization [1 2 1 3 4 1 2]
   --

   procedure normalize (s : in out solution_deadline2energy);

   procedure Transform_Chromosome_To_CheddarADL_Model
     (A_sys : in out systems.system;
      s     : in     solution_deadline2energy);

   procedure Create_system
     (A_system : in out systems.system;
      s        : in     solution_deadline2energy);

end Paes.chromosome_Data_Manipulation_deadline2energy;
