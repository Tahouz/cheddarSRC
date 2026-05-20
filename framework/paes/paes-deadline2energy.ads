with Paes; use Paes;

package Paes.deadline2energy is

   ---------------------
   --    Constants    --
   ---------------------
   MAX_GENES_COM : constant Integer := 1000;  -- change as necessary

   ---------------------
   --      Types      --
   ---------------------

   type optional_function is (on, off);

   type allowed_frequency is
     (frequency_0_9, frequency_1_6, frequency_2_4, frequency_4);

   type solution_deadline2energy is new generic_solution with
   record  -- definition of embedded functions
      frequency           : allowed_frequency;
      power_conversion    : optional_function;
      processor           : optional_function;
      lights              : optional_function;
      thrusters           : optional_function;
      VLC                 : optional_function;
      ultrasound_comm     : optional_function;
      ultrasound_position : optional_function;
      CAS                 : optional_function;
      sensors             : optional_function;
      camera              : optional_function;
      object_recognition  : optional_function;
   end record;

   type solution_deadline2energy_ptr is access all solution_deadline2energy;

   procedure print_genome (s : solution_deadline2energy);
   procedure print_debug_genome (s : solution_deadline2energy);

   sol_init1,
   sol_init2,
   sol_init3,
   sol_init4,
   sol_init5,
   sol_init6 : solution_deadline2energy_ptr;

   type rov_consumption is record
      power_conversion    : Integer := 3;
      processor           : Integer := 28;
      lights              : Integer := 40;
      thrusters           : Integer := 30;
      VLC                 : Integer := 50;
      ultrasound_comm     : Integer := 10;
      ultrasound_position : Integer := 5;
      CAS                 : Integer := 10;
      sensors             : Integer := 10;
      camera              : Integer := 12;
      object_recognition  : Integer := 40;
   end record;

   function compute_consumption
     (s : in solution_deadline2energy;
      r : in rov_consumption) return Integer;

end Paes.deadline2energy;
