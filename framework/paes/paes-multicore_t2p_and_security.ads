with Paes; use Paes;

package Paes.multicore_t2p_and_security is

   ---------------------
   --    Constants    --
   ---------------------
   MAX_GENES_COM : constant Integer := 1000;  -- change as necessary

   ---------------------
   --      Types      --
   ---------------------

   -- This type used to define a chromosome of a solution (tasks to partitions assignment)
   type chrom_task_type is array (1 .. MAX_GENES) of Integer;

   -- This type used to define if the communication is secure
   -- nosecure : the communication has security violations not fixed
   -- norisk : the communication has no security violation
   -- secure : the communication has security violations; and they are fixed
   type com_type_elmt1 is (undefined, nosecure, norisk, secure);

   type com_type is record
      mode        : com_type_elmt1;
      source_sink : Unbounded_String; -- to identify the source and the sink of the communication
   end record;

   -- This type used to define the communications in a chromosome of a solution
   type chrom_com_type is array (1 .. MAX_GENES_COM) of com_type;

   type solution_t2p_t2c is new generic_solution with record
      chrom_t2p : chrom_task_type;  -- task to partitions assignement
      chrom_t2c : chrom_task_type;  -- task to core assignement
      chrom_com : chrom_com_type;  --communications in the chromosome
   end record;

   type solution_t2p_t2c_ptr is access all solution_t2p_t2c;

   -- This array is used to select communications
   -- for which confidentiality or integrity violation may be accepted (communications low)
   type com_non_secure_list is array (1 .. MAX_GENES_COM) of Natural;

   procedure print_genome (s : solution_t2p_t2c);
   procedure print_debug_genome (s : solution_t2p_t2c);

   -- This array is used to specify the application of each task
   task_to_app : chrom_task_type;
   -- This array is used to select communications for which confidentiality or integrity violation may be accepted
   nb_secu_conf_choice : chrom_task_type;
   -- Array of communications low
   NonSecure_list : com_non_secure_list;
   -- number of communication for which confidentiality or integrity violation may be accepted
   Nb_NonSecure_low : Integer;

   --to specify the 3 instances of a task
   type t_safety is array (1 .. 2, 1 .. MAX_GENES) of Integer;
   Task_instances : t_safety; -- i, T(i,1) and T(i,2) are  the 2nd and 3rd instances of task i

   -- Intrapartition overheads
   display_blackboard_time_values : chrom_task_type;
   read_blackboard_time_values    : chrom_task_type;

   -- Interpartition overheads
   write_sampling_port_time_values : chrom_task_type;
   read_sampling_port_time_values  : chrom_task_type;

   --Intercore overheads
   write_intercore_overhead_values : chrom_task_type;
   read_intercore_overhead_values  : chrom_task_type;

   -- This array are used for encryption, decryption, hash values
   -- Each application has different values depending on the data size
   encrypter_values : chrom_task_type;
   decrypter_values : chrom_task_type;
   Hash_values      : chrom_task_type;

   sol_init1,
   sol_init2,
   sol_init3,
   sol_init4,
   sol_init5,
   sol_init6,
   sol_init7,
   sol_init8,
   sol_init9,
   sol_init10,
   sol_init11,
   sol_init12,
   sol_init13 : solution_t2p_t2c_ptr;

   -- genes_com: the number of communications in the chromosome representation.
   -- partition_period: period of partitions
   -- nb_partitions: number of partitions
   -- nb_app: number of applications
   -- key_value: encryption set up key value
   -- nb_bell_resolved : number of confidentiality rules violations solved for a solution
   -- nb_biba_resolved : number of integrity rules violations solved for a solution
   -- version of exploration t2p_exploration_version (resp. t2c_exploration_version)
   -- -- version=1: all tasks of an application in the same partition (App-grain algorithm: applications mutation)
   -- -- version=2: Tasks of an application can be on different partitions (Task-grain algorithm: tasks mutation)
   -- -- version=3: version 1 for some iterations and version 2 for the remaining iterations (mix-grain mutation)
   -- intra_partition_safe : assumption if all the intra partition communications are not attackable by assumption
   -- -- intra_partition_safe=0 -- the intra partition communications are not attackable
   -- -- intra_partition_safe=1 -- the intra partition communications  can be attacked (no hypothesis or
   -- -- there is a memory protection between tasks inside a partition
   nb_cores,
   genes_com,
   nb_partitions,
   nb_app,
   partition_period,
   Key_value,
   t2p_exploration_version,
   t2c_exploration_version                                  : Integer;
   nb_bell_resolved, nb_biba_resolved, intra_partition_safe : Integer;

end Paes.multicore_t2p_and_security;
