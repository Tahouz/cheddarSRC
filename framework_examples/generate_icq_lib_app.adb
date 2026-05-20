with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Command_Line;      use Ada.Command_Line;
with Ada.Directories;       use Ada.Directories;
with Ada.Strings.Fixed;     use Ada.Strings.Fixed;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with GNAT.OS_Lib;

with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

with Objects;  use Objects;
with Memories; use Memories;
use Memories.Memories_Table_Package;
with Memory_set;        use Memory_set;
with Tasks;             use Tasks;
with Task_Set;          use Task_Set;
with Systems;           use Systems;
with Processors;        use Processors;
with Processor_Set;     use Processor_Set;
with Address_Spaces;    use Address_Spaces;
with Address_Space_Set; use Address_Space_Set;
with Buffers;           use Buffers;
with Buffer_set;        use Buffer_set;
use Buffers.Buffer_Roles_Package;
with Queueing_Systems; use Queueing_Systems;
with Core_Units;       use Core_Units;
use Core_Units.Core_Units_Table_Package;
with batteries;           use batteries;
with battery_set;         use battery_set;
with Processor_Interface; use Processor_Interface;
with Scheduler_Interface; use Scheduler_Interface;

with Random_Tools;         use Random_Tools;
with architecture_factory; use architecture_factory;
with unbounded_strings;    use unbounded_strings;
with call_framework;       use call_framework;
with feasibility_test.feasibility_interval;
use feasibility_test.feasibility_interval;
with doubles;                use doubles;
with priority_assignment.rm; use priority_assignment.rm;
with Ada.Numerics;
with Ada.Numerics.Float_Random;

with Buffers;          use Buffers;
with Buffer_Set;       use Buffer_Set;
with Tasks;            use Tasks;
with Task_Set;         use Task_Set;
with Queueing_Systems; use Queueing_Systems;
with Buffer_Set;
use Buffers.Buffer_Roles_Package;
with Dependencies;      use Dependencies;
with task_dependencies; use task_dependencies;

procedure Generate_icq_lib_app is

   sys : System;

   a_task            : Generic_task_ptr;
   my_tasks          : Tasks_set;
   my_tasks_iterator : Tasks_iterator;

   a_buffer            : Buffer_ptr;
   my_buffers          : Buffers_set;
   my_buffers_iterator : Buffers_iterator;
   a_buffer_roles      : Buffer_roles_table;

   dispatchers_period_sec : Natural := 1;
   dispatchers_period_ms  : Natural := 0;
   dispatch_delay         : Natural := 1;
   dispatch_priority      : Natural := 1;

   post_delay : Natural := 10;
   post_delay_sec : Natural := post_delay / 1000;
   post_delay_ms  : Natural := post_delay mod 1000;

   tasks_set_periodic : Tasks_set;
   sys_hyperperiod    : Natural := 30_000;

   sys_hyperperiod_sec : Natural;
   sys_hyperperiod_ms  : Natural;

   Tab : constant Character := Character'Val (9);  -- ASCII code for tabulation

   src_file : Unbounded_String := To_Unbounded_String (Argument (2));

   package String_Vectors is new Ada.Containers.Vectors
     (Index_Type => Natural, Element_Type => Unbounded_String);

   Receiver_processed : String_Vectors.Vector := String_Vectors.Empty_Vector;

   function Receiver_Already_Processed (rec : Unbounded_String) return Boolean
   is
   begin
      for r of Receiver_processed loop
         if To_String (rec) = r then
            return True;
         end if;
      end loop;
      return False;
   end Receiver_Already_Processed;

   function Is_Receiver
     (a_system : System; a_task_name : String) return Boolean
   is
   begin

      my_buffers := sys.Buffers;

      reset_iterator (my_buffers, my_buffers_iterator);
      loop
         current_element (my_buffers, a_buffer, my_buffers_iterator);

         a_buffer_roles := a_buffer.roles;

         declare

            IndexB        : Natural := Index (To_String (a_buffer.name), "B");
            sender_name   : Unbounded_String;
            receiver_name : Unbounded_String;
         begin

            sender_name :=
              To_Unbounded_String
                (To_String (a_buffer.name) (1 .. IndexB - 1));
            receiver_name :=
              To_Unbounded_String
                (To_String (a_buffer.name)
                   (IndexB + 1 .. To_String (a_buffer.name)'Last));

            if receiver_name = a_task_name then

               return True;
            end if;

         end;

         exit when is_last_element (my_buffers, my_buffers_iterator);
         next_element (my_buffers, my_buffers_iterator);
      end loop;

      return False;

   end Is_Receiver;

begin

   if Argument_Count < 1 then
      Put ("Usage: " & Command_Name & " ");
      Put_Line ("system_cheddar_file");
      GNAT.OS_Lib.OS_Exit (1);
   end if;

   Call_Framework.initialize (False);

   read_from_xml_file (sys, Argument (1));

   if not Exists (Containing_Directory (Argument (1)) & "/GR740") then
      Create_Directory (Containing_Directory (Argument (1)) & "/GR740");
   end if;   
   
  declare

      sys_core_file : File_Type;
      
        a_core            : Core_Unit_ptr;
   	my_cores          : Core_Units_set;
   	my_cores_iterator : Core_Units_iterator;
   	
   	a_core_speed	: Natural;

   begin

	my_cores := sys.core_units;

      reset_iterator (my_cores, my_cores_iterator);
      loop
         current_element (my_cores, a_core, my_cores_iterator);
         	
         	a_core_speed := a_core.speed;
         	if not Exists (Containing_Directory (Argument (1)) & "/GR740/" & To_String(a_core.name)) then
               	Create_Directory (Containing_Directory (Argument (1)) & "/GR740/" & To_String(a_core.name));
   		end if; 

         	
         	---Begin Generation Main File---
	   declare

	      core_file : File_Type;

	      task_capacity : Natural;

	      task_BCET_sec : Natural;
	      task_BCET_ms  : Natural;

	      task_WCET_sec : Natural;
	      task_WCET_ms  : Natural;
	      
	      task_core     : Unbounded_String;

	   begin

		Create
		(core_file, Out_File,
		 Containing_Directory (Argument (1)) & "/GR740/" & To_String(a_core.name) & "/app_" & To_String(a_core.name) & ".c");

	      Put_Line (core_file, "#include <stdio.h>");
	      Put_Line (core_file, "#include <stdlib.h>");
	      Put_Line (core_file, "#include <string.h>");
	      Put_Line (core_file, "");
	      Put_Line (core_file, "#include ""../praicc_configuration.h""");
	      Put_Line (core_file, "#include ""system.h""");
	      Put_Line (core_file, "#include ""praicc.h""");
	      Put_Line (core_file, "");

	      my_tasks := sys.Tasks;

	      reset_iterator (my_tasks, my_tasks_iterator);
	      loop
		 current_element (my_tasks, a_task, my_tasks_iterator);

		 if (a_task.task_type = Periodic_Type) then
		    add (tasks_set_periodic, a_task);
		 end if;

		 if To_String (a_task.name)'Length >= 4 then
		    if To_String (a_task.name) (1 .. 4) = "disp" then

		       dispatchers_period_sec :=
			 get (sys.Tasks, a_task.name, period) / 1_000;
		       dispatchers_period_ms :=
			 get (sys.Tasks, a_task.name, period) mod 1_000;
		       dispatch_priority := get (sys.Tasks, a_task.name, priority);
		       goto Next_Iteration_1;

		    end if;

		 end if;

		 task_core := get (sys.Tasks, a_task.name, core_name);

		 if(task_core = To_String(a_core.name)) then
			 my_buffers := sys.Buffers;

			 reset_iterator (my_buffers, my_buffers_iterator);
			 loop
			    current_element (my_buffers, a_buffer, my_buffers_iterator);

			    a_buffer_roles := a_buffer.roles;

			    declare

			       IndexB : Natural := Index (To_String (a_buffer.name), "B");
			       sender_name   : Unbounded_String;
			       receiver_name : Unbounded_String;
			    begin

			       sender_name :=
				 To_Unbounded_String
				   (To_String (a_buffer.name) (1 .. IndexB - 1));
			       receiver_name :=
				 To_Unbounded_String
				   (To_String (a_buffer.name)
				      (IndexB + 1 .. To_String (a_buffer.name)'Last));

			       if sender_name = a_task.name then

				  task_capacity :=
				    get (sys.Tasks, a_task.name, capacity) - post_delay;

				  task_BCET_sec := 1 / 1_000;
				  task_BCET_ms  := 1 mod 1_000;

				  task_WCET_sec := task_capacity / 1_000;
				  task_WCET_ms  := task_capacity mod 1_000;

				  Put_Line
				    (core_file,
				     "void " & To_String (a_task.name) &
				     "_process(praicc_process_arg* arg){");

				  Put_Line
				    (core_file,
				     Tab & "struct timespec " & To_String (a_task.name) &
				     "_bcet;");
				  Put_Line
				    (core_file,
				     Tab & To_String (a_task.name) & "_bcet.tv_sec  = " &
				     task_BCET_sec'Image & ";");
				  Put_Line
				    (core_file,
				     Tab & To_String (a_task.name) & "_bcet.tv_nsec = " &
				     task_BCET_ms'Image & "000000;");
				  Put_Line (core_file, "");

				  Put_Line
				    (core_file,
				     Tab & "struct timespec " & To_String (a_task.name) &
				     "_wcet;");
				  Put_Line
				    (core_file,
				     Tab & To_String (a_task.name) & "_wcet.tv_sec  = " &
				     task_WCET_sec'Image & ";");
				  Put_Line
				    (core_file,
				     Tab & To_String (a_task.name) & "_wcet.tv_nsec = " &
				     task_WCET_ms'Image & "000000;");
				  Put_Line (core_file, "");

				  Put_Line
				    (core_file,
				     Tab & "praicc_task_simulate_execution(" &
				     To_String (a_task.name) & "_bcet," &
				     To_String (a_task.name) & "_wcet);");
				  Put_Line (core_file, "");

				  Put_Line (core_file, Tab & "praicc_message_t msg;");
				  Put_Line
				    (core_file,
				     Tab & "strcpy(msg.sender_name, """ &
				     To_String (a_task.name) & """);");
				  Put_Line
				    (core_file, Tab & "strcpy(msg.content, ""a message"");");
				  Put_Line
				    (core_file, Tab & "msg.size = sizeof(msg.content);");
				  Put_Line
				    (core_file,
				     Tab & "int ret = praicc_task_send_message(""" &
				     To_String (receiver_name) & """, msg);");
				  Put_Line
				    (core_file,
				     Tab &
				     "if(ret==-1){fprintf(stderr, ""FAILED: praicc_task_send_message failed\n"");}");

				  Put_Line (core_file, "}");
				  Put_Line (core_file, "");

			       elsif receiver_name = a_task.name and
				 not Receiver_Already_Processed (receiver_name)
			       then
				  task_capacity := get (sys.Tasks, a_task.name, capacity);

				  task_BCET_sec := 1 / 1_000;
				  task_BCET_ms  := 1 mod 1_000;

				  task_WCET_sec := task_capacity / 1_000;
				  task_WCET_ms  := task_capacity mod 1_000;

				  Put_Line
				    (core_file,
				     "void " & To_String (a_task.name) &
				     "_process(praicc_process_arg* arg){");

				  Put_Line
				    (core_file,
				     Tab & "struct timespec " & To_String (a_task.name) &
				     "_bcet;");
				  Put_Line
				    (core_file,
				     Tab & To_String (a_task.name) & "_bcet.tv_sec  = " &
				     task_BCET_sec'Image & ";");
				  Put_Line
				    (core_file,
				     Tab & To_String (a_task.name) & "_bcet.tv_nsec = " &
				     task_BCET_ms'Image & "000000;");
				  Put_Line (core_file, "");

				  Put_Line
				    (core_file,
				     Tab & "struct timespec " & To_String (a_task.name) &
				     "_wcet;");
				  Put_Line
				    (core_file,
				     Tab & To_String (a_task.name) & "_wcet.tv_sec  = " &
				     task_WCET_sec'Image & ";");
				  Put_Line
				    (core_file,
				     Tab & To_String (a_task.name) & "_wcet.tv_nsec = " &
				     task_WCET_ms'Image & "000000;");
				  Put_Line (core_file, "");

				  Put_Line
				    (core_file,
				     Tab & "praicc_task_simulate_execution(" &
				     To_String (a_task.name) & "_bcet," &
				     To_String (a_task.name) & "_wcet);");
				  Put_Line (core_file, "}");
				  Put_Line (core_file, "");

				  String_Vectors.Append (Receiver_processed, receiver_name);
			       end if;

			       for i in 0 .. a_buffer_roles.nb_entries loop

				  if To_String (a_buffer_roles.entries (i).item) = sender_name
				  then
				     post_delay := a_buffer_roles.entries (i).data.size;
				  else
				     dispatch_delay := a_buffer_roles.entries (i).data.size;
				  end if;

			       end loop;

			    end;

			    exit when is_last_element (my_buffers, my_buffers_iterator);
			    next_element (my_buffers, my_buffers_iterator);
			 end loop;
		   end if;

		 <<Next_Iteration_1>>

		 exit when is_last_element (my_tasks, my_tasks_iterator);
		 next_element (my_tasks, my_tasks_iterator);
	      end loop;

	      Put_Line (core_file, "int main(void){");
	      Put_Line (core_file, "");
	      if To_String(a_core.name) = "core0" then
		      Put_Line (core_file,"/* Initialize PrAICC environment */");
		      Put_Line (core_file, Tab & "praicc_init();");
		      Put_Line (core_file, "");
		end if;

	      Put_Line (core_file,"int ret = 0;");
	      Put_Line (core_file, "");

		if To_String(a_core.name) = "core0" then
		      Put_Line (core_file,"/* Initialize/set inter-core connections */");

		my_buffers := sys.Buffers;

				 reset_iterator (my_buffers, my_buffers_iterator);
				 loop
				    current_element (my_buffers, a_buffer, my_buffers_iterator);

				    a_buffer_roles := a_buffer.roles;

				    declare

				       IndexB : Natural := Index (To_String (a_buffer.name), "B");
				       sender_name   : Unbounded_String;
				       receiver_name : Unbounded_String;
				    begin

				       sender_name :=
					 To_Unbounded_String
					   (To_String (a_buffer.name) (1 .. IndexB - 1));
				       receiver_name :=
					 To_Unbounded_String
					   (To_String (a_buffer.name)
					      (IndexB + 1 .. To_String (a_buffer.name)'Last));

					 Put_Line (core_file,"ret = praicc_task_init_connection(""" & To_String(sender_name) & """, """ & To_String(receiver_name) & """);");
					 Put_Line (core_file,"if(ret==-1){fprintf(stderr, ""FATAL: praicc_task_init_connection failed\n"");_exit(EXIT_FAILURE);}");

				    end;		  
					
				    exit when is_last_element (my_buffers, my_buffers_iterator);
				    next_element (my_buffers, my_buffers_iterator);
				 end loop;

		      Put_Line (core_file, "");
		end if;
	      Put_Line (core_file,"/* Initialize/set " & To_String(a_core.name) & " tasks */");

	      my_tasks := sys.Tasks;

	      reset_iterator (my_tasks, my_tasks_iterator);
	      loop
		 current_element (my_tasks, a_task, my_tasks_iterator);

		 declare

		    task_name       : String  := To_String (a_task.name);
		    task_period_sec : Natural :=
		      get (sys.Tasks, a_task.name, period) / 1_000;
		    task_period_ms : Natural :=
		      get (sys.Tasks, a_task.name, period) mod 1_000;
		    task_priority : Natural :=
		      250 - get (sys.Tasks, a_task.name, priority);
		    task_core_name : String :=
		      To_String (get (sys.Tasks, a_task.name, core_name));
		    task_core_id : Natural :=
		      Integer'Value
			(task_core_name
			   (task_core_name'Length .. task_core_name'Length));

		 begin

		     if task_core_name = To_String(a_core.name) then
			    if To_String (a_task.name)'Length >= 4 then
			       if To_String (a_task.name) (1 .. 4) = "disp" then

				  goto Next_Iteration_2;

			       end if;
			    end if;

			    Put_Line
			      (core_file, Tab & "struct timespec " & task_name & "_period;");
			    Put_Line
			      (core_file,
			       Tab & task_name & "_period.tv_sec  = " & task_period_sec'Image &
			       ";");
			    Put_Line
			      (core_file,
			       Tab & task_name & "_period.tv_nsec = " & task_period_ms'Image &
			       "000000;");

			    if Is_Receiver (sys, task_name) then
			       Put_Line
				 (core_file,
				  Tab & "praicc_task_t* " & task_name &
				  " = praicc_task_init(""" & task_name & """, " & task_name &
				  "_period, " & task_priority'Image & ", PRAICC_RECEIVER, " & task_name &
				  "_process);");
			    else
			       Put_Line
				 (core_file,
				  Tab & "praicc_task_t*" & task_name &
				  " = praicc_task_init(""" & task_name & """, " & task_name &
				  "_period, " & task_priority'Image & ", PRAICC_SENDER, " & task_name &
				  "_process);");
			    end if;

			    Put_Line
			      (core_file,
			       Tab & "if(" & task_name &
			       "==NULL){fprintf(stderr, ""FATAL: praicc_task_init failed\n"");_exit(EXIT_FAILURE);}");

			    Put_Line (core_file, "");
			    <<Next_Iteration_2>>
		      end if;
		    end;

		 exit when is_last_element (my_tasks, my_tasks_iterator);
		 next_element (my_tasks, my_tasks_iterator);
	      end loop;
	      
	      if To_String(a_core.name) = "core0" then
		      Put_Line (core_file,"/* It Activates core 1 using multiprocessor status register of interrupt controller 3. */");
		      Put_Line (core_file,"*((volatile unsigned int *) 0xff905010) = (1<<1);");
		      Put_Line (core_file,"*((volatile unsigned int *) 0xff905010) = (1<<2);");
		      Put_Line (core_file,"*((volatile unsigned int *) 0xff905010) = (1<<3);");

		      Put_Line (core_file,"/* Give to other cores enough time for their initialization */");
		      Put_Line (core_file," struct timespec execution_time;");
		      Put_Line (core_file," execution_time.tv_sec = 5;");
		      Put_Line (core_file," execution_time.tv_nsec  = 0;");
		      Put_Line (core_file," ret = clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &execution_time, NULL);");
		      Put_Line (core_file,"");
		      Put_Line (core_file,"/* Launch the application */");
		      Put_Line (core_file,"praicc_task_launch_application();");
	      else
	      
	      	      Put_Line (core_file,"");
      			Put_Line (core_file,"/* Launch the application */");
		      Put_Line (core_file,"praicc_task_finish_initialization();");
		      Put_Line (core_file,"");
	      end if;
	      
	      Put_Line (core_file,"");
	      Put_Line (core_file,"return 0;");
	      Put_Line (core_file,"}");

	      Close (core_file);

	      Put_Line ("./GR740/" & To_String(a_core.name) & "/app_" & To_String(a_core.name) & ".c generated");
	      
	   end;
         	
		Create
		(sys_core_file, Out_File,
		Containing_Directory (Argument (1)) & "/GR740/" & To_String(a_core.name) & "/system.h");

		Put_Line (sys_core_file, "#ifndef SYSTEM_H");
		Put_Line (sys_core_file, "#define SYSTEM_H");
		Put_Line (sys_core_file, "");
		Put_Line (sys_core_file, "#include SYSTEM_FILE");
		Put_Line (sys_core_file, "");
		Put_Line (sys_core_file, "");
		Put_Line (sys_core_file, "#include ""tmacros.h""");
		Put_Line (sys_core_file, "#include <bsp.h> /* for device driver prototypes */");
		Put_Line (sys_core_file, "");
		Put_Line (sys_core_file, "");
		Put_Line (sys_core_file, "/* GR740 defualt frequency */");
		Put_Line (sys_core_file, "#ifndef CPU_FREQ_MHZ");
		Put_Line (sys_core_file, "#define CPU_FREQ_MHZ " & a_core_speed'Image);
		Put_Line (sys_core_file, "#endif");
		Put_Line (sys_core_file, "");
		Put_Line (sys_core_file, "#define CORE_ID " & Element(a_core.name, Length(a_core.name)));
		Put_Line (sys_core_file, "");
		Put_Line (sys_core_file, "/* system configuration */");
		Put_Line (sys_core_file, "#define RTEMS");
		Put_Line (sys_core_file, "#include <rtems.h>");
		Put_Line (sys_core_file, "");
		Put_Line (sys_core_file, "#define CONFIGURE_APPLICATION_NEEDS_CLOCK_DRIVER");
		Put_Line (sys_core_file, "#define CONFIGURE_APPLICATION_NEEDS_CONSOLE_DRIVER");
		Put_Line (sys_core_file, "");
		Put_Line (sys_core_file, "#define CONFIGURE_MAXIMUM_PROCESSORS   1");
		Put_Line (sys_core_file, "");
		Put_Line (sys_core_file, "#define CONFIGURE_MAXIMUM_TASKS      20");
		Put_Line (sys_core_file, "#define CONFIGURE_MAXIMUM_SEMAPHORES 3");
		Put_Line (sys_core_file, "#define CONFIGURE_MAXIMUM_BARRIER    1");
		Put_Line (sys_core_file, "#define CONFIGURE_MAXIMUM_WAITERS    0");
		Put_Line (sys_core_file, "");
		Put_Line (sys_core_file, "#define CONFIGURE_MAXIMUM_USER_EXTENSIONS 5");
		Put_Line (sys_core_file, "");
		Put_Line (sys_core_file, "#define CONFIGURE_RTEMS_INIT_TASKS_TABLE");
		Put_Line (sys_core_file, "");
		Put_Line (sys_core_file, "#include <rtems/confdefs.h>");
		Put_Line (sys_core_file, "");
		Put_Line (sys_core_file, "#endif");

		Close (sys_core_file);

		Put_Line ("./GR740/" & To_String(a_core.name) & "/system.h generated");


		declare

		      make_core_file : File_Type;

		   begin

		      Create
			(make_core_file, Out_File,
			 Containing_Directory (Argument (1)) & "/GR740/" & To_String(a_core.name) & "/Makefile");

		      Put_Line (make_core_file, "include /opt/rcc-1.3-rc9-gcc/src/samples/config.mk");
		      Put_Line (make_core_file, "");
		      Put_Line (make_core_file, "CURRENT_DIR=$(shell pwd)");
		      Put_Line (make_core_file, "PRAICC_SRC_DIR=$(PRAICC_DIR)/src");
		      Put_Line (make_core_file, "PRAICC_SRC_FILES = $(wildcard $(PRAICC_SRC_DIR)/*.c)");
		      Put_Line (make_core_file, "PRAICC_INC_DIR=$(PRAICC_DIR)/include");
		      Put_Line (make_core_file, "PRAICC_INC_FILES = $(wildcard $(PRAICC_INC_DIR)/*.h)");
		      Put_Line (make_core_file, "APP_OBJ_DIR=$(CURRENT_DIR)/obj");
		      Put_Line (make_core_file, "APP_OBJ_FILES=$(PRAICC_SRC_FILES:$(PRAICC_SRC_DIR)/%.c=$(APP_OBJ_DIR)/%.o)");
		      Put_Line (make_core_file, "APP_LIB_DIR=$(CURRENT_DIR)/lib");
		      Put_Line (make_core_file, "APP_LIB_FILE=$(APP_LIB_DIR)/libicq.a");
		      Put_Line (make_core_file, "APP_SOURCE=$(CURRENT_DIR)/init.c");
		      Put_Line (make_core_file, "TARGET=$(APP_SOURCE:.c=.exe)");
		      Put_Line (make_core_file, "PRAICC_CONFIG_FILE=$(CURRENT_DIR)/../praicc_configuration.h");
		      Put_Line (make_core_file, "SYSTEM_FILE=$(CURRENT_DIR)/system.h");
		      Put_Line (make_core_file, "");
		      Put_Line (make_core_file, "LIBS = ");
		      Put_Line (make_core_file, "PRAICC_LIB_FLAGS = -L$(APP_LIB_DIR) -licq -lm");
		      Put_Line (make_core_file, "");


		      Put_Line (make_core_file, "override CFLAGS= -mcpu=leon3 -g -msoft-float -I$(PRAICC_INC_DIR) -I/opt/rcc-1.3-rc9-gcc/src/rcc-1.3-rc9/testsuites/support/include -DPRAICC_CONFIG_FILE=\""$(PRAICC_CONFIG_FILE)\"" -DSYSTEM_FILE=\""$(SYSTEM_FILE)\"" -O2 ");
		      Put_Line (make_core_file, "");
		      Put_Line (make_core_file, "SP0FLAGS=-qbsp=gr740_mp -Wl,-Ttext,0x0" & Element(a_core.name, Length(a_core.name)) & "000000");
		      Put_Line (make_core_file, "");
		      Put_Line (make_core_file, "#Compilation Options");
		      Put_Line (make_core_file, "CC = sparc-gaisler-rtems5-gcc");
		      Put_Line (make_core_file, "AR = ar");
		      Put_Line (make_core_file, "");

		      Put_Line (make_core_file, "all: app_" & To_String(a_core.name));


		      Put_Line (make_core_file, "app_" & To_String(a_core.name) & " : $(APP_LIB_FILE)");
		      Put_Line (make_core_file, Tab & "$(CC) app_" & To_String(a_core.name) & ".c $(SP0FLAGS) $(CFLAGS) $< -o $@  $(LIBS) $(PRAICC_LIB_FLAGS)");
		      Put_Line (make_core_file, "");
		      Put_Line (make_core_file, "$(APP_LIB_FILE): $(APP_LIB_DIR) $(APP_OBJ_FILES)");
		      Put_Line (make_core_file, Tab & "$(AR) rcs $(APP_LIB_FILE) $(APP_OBJ_FILES) $(LIBS)");
		      Put_Line (make_core_file, "$(APP_LIB_DIR):");
		      Put_Line (make_core_file, Tab & "mkdir -p $(APP_LIB_DIR)");
		      Put_Line (make_core_file, "$(APP_OBJ_DIR)/%.o: $(PRAICC_SRC_DIR)/%.c $(PRAICC_INC_FILES) $(APP_OBJ_DIR) $(PRAICC_CONFIG_FILE) $(SYSTEM_FILE) ");
		      Put_Line (make_core_file, Tab & "$(CC) $(CFLAGS) -qbsp=gr740  -c $< -o $@");
		      Put_Line (make_core_file, "$(APP_OBJ_DIR):");
		      Put_Line (make_core_file, Tab & "mkdir -p $(APP_OBJ_DIR)");
		      Put_Line (make_core_file, "");
		      Put_Line (make_core_file, "clean:");
		      Put_Line (make_core_file, Tab & "@rm -f app_" & To_String(a_core.name) & "");
		      Put_Line (make_core_file, Tab & "@rm -rf $(APP_LIB_DIR)");
		      Put_Line (make_core_file, Tab & "@rm -rf $(APP_OBJ_DIR)");

		      Put_Line (make_core_file, "include /opt/rcc-1.3-rc9-gcc/src/samples/targets.mk");

		      Close (make_core_file);

		      Put_Line ("./GR740/" & To_String(a_core.name) & "/Makefile generated");
		   end;


         exit when is_last_element (my_cores, my_cores_iterator);
         next_element (my_cores, my_cores_iterator);
      end loop;
      
   end;
   
   ---Begin Generation ICQ Configuration File---
   declare

      praicc_configuration_file : File_Type;

   begin

      sys_hyperperiod :=
        compute_hyperperiod (tasks_set_periodic) *
        2;
        
      if sys_hyperperiod < 20000 then
      	sys_hyperperiod := 20000;
      end if;

      sys_hyperperiod_sec := sys_hyperperiod / 1_000;
      sys_hyperperiod_ms  := sys_hyperperiod mod 1_000;

	post_delay_sec :=
	 post_delay / 1_000;
       post_delay_ms :=
	 post_delay mod 1_000;

      Create
        (praicc_configuration_file, Out_File,
         Containing_Directory (Argument (1)) &
         "/GR740/praicc_configuration.h");

      Put_Line (praicc_configuration_file, "#ifndef PRAICC_CONFIGURATION_H");
      Put_Line (praicc_configuration_file, "#define PRAICC_CONFIGURATION_H");
      Put_Line (praicc_configuration_file, "");
      Put_Line (praicc_configuration_file, "#define PRAICC_ONE_QUEUE_PER_SENDER_TASK");
      Put_Line (praicc_configuration_file, "");
      Put_Line (praicc_configuration_file, "/* TIMESPEC */");
      Put_Line (praicc_configuration_file, "#define CONFIGURE_PRAICC_EXECUTION_TIME_SEC     " & sys_hyperperiod_sec'Image);
      Put_Line (praicc_configuration_file, "#define CONFIGURE_PRAICC_EXECUTION_TIME_NSEC    " & sys_hyperperiod_ms'Image & "000000");
      Put_Line (praicc_configuration_file, "");
      Put_Line (praicc_configuration_file, "#define CONFIGURE_PRAICC_DISPATCHER_PERIOD_SEC  " & dispatchers_period_sec'Image);
      Put_Line (praicc_configuration_file, "#define CONFIGURE_PRAICC_DISPATCHER_PERIOD_NSEC " & dispatchers_period_ms'Image & "000000");
      Put_Line (praicc_configuration_file, "");
      Put_Line (praicc_configuration_file, "#define CONFIGURE_PRAICC_POST_DELAY_SEC         " & post_delay_sec'Image);
      Put_Line (praicc_configuration_file, "#define CONFIGURE_PRAICC_POST_DELAY_NSEC        " & post_delay_ms'Image & "000000");
      Put_Line (praicc_configuration_file, "");
      Put_Line (praicc_configuration_file, "/* PRAICC PARAMATERS */");
      Put_Line (praicc_configuration_file, "#define CONFIGURE_PRAICC_NB_INTERCOREQUEUE 18");
      Put_Line (praicc_configuration_file, "#define CONFIGURE_PRAICC_INTERCOREQUEUE_SIZE 100");
      Put_Line (praicc_configuration_file, "");
      Put_Line (praicc_configuration_file, "#define CONFIGURE_PRAICC_INTERCOREQUEUE_MESSAGE_SIZE 256");
      Put_Line (praicc_configuration_file, "");
      Put_Line (praicc_configuration_file, "#define CONFIGURE_PRAICC_NB_MAX_RECEIVER_PER_CORE 3");
      Put_Line (praicc_configuration_file, "");
      Put_Line (praicc_configuration_file, "#define CONFIGURE_PRAICC_NB_MAX_RECEIVER_FOR_SENDER 1");
      Put_Line (praicc_configuration_file, "#define CONFIGURE_PRAICC_NB_MAX_SENDER_FOR_RECEIVER 6");
      Put_Line (praicc_configuration_file, "");
      Put_Line (praicc_configuration_file, "#define CONFIGURE_PRAICC_DISPATCHER_PRIORITY (sched_get_priority_max(SCHED_FIFO)-1)");
      Put_Line (praicc_configuration_file, "");
      Put_Line (praicc_configuration_file, "#define CONFIGURE_PRAICC_TASK_MESSAGEQUEUE_SIZE 100");
      Put_Line (praicc_configuration_file, "");
      Put_Line (praicc_configuration_file, "/* INTERCOREQUEUES SHARED AREA */");
      Put_Line (praicc_configuration_file, "#define PRAICC_SHARED_AREA_BASE 0x04000000");
      Put_Line (praicc_configuration_file, "#define PRAICC_SHARED_AREA ((praicc_shared_area_t *) PRAICC_SHARED_AREA_BASE)");
      Put_Line (praicc_configuration_file, "");
      Put_Line (praicc_configuration_file, "#endif");

      Close (praicc_configuration_file);

      Put_Line ("./GR740/praicc_configuration.h generated");
   end;

   
   ---Begin Generation GRMON File---
   declare

      grmon_file : File_Type;

   begin
      Create
        (grmon_file, Out_File,
         Containing_Directory (Argument (1)) & "/GR740/grmon_gdb.cmd");

      Put_Line (grmon_file, "wash");
      Put_Line (grmon_file, "");
      Put_Line (grmon_file, "l2cache disable");
      Put_Line (grmon_file, "l2cache");
      Put_Line (grmon_file, "");
      Put_Line (grmon_file, "");
      Put_Line (grmon_file, "batch setup_AMP.tcl");
      Put_Line (grmon_file, "bp praicc_task_print_all_tasks_timing_execution_trace");
      Put_Line (grmon_file, "run");
      Put_Line (grmon_file, "");
      Put_Line (grmon_file, "cctrl flush cpu0");
      Put_Line (grmon_file, "cctrl flush cpu1");
      Put_Line (grmon_file, "cctrl flush cpu2");
      Put_Line (grmon_file, "cctrl flush cpu3");
      Put_Line (grmon_file, "");
      Put_Line (grmon_file, "gdb 2233");
      Put_Line (grmon_file, "");
      Put_Line (grmon_file, "while {[lindex [gdb status] 0] != 1} {after 100}");
      Put_Line (grmon_file, "while {[lindex [gdb status] 0] == 1} {after 100}");
      Put_Line (grmon_file, "");
      Put_Line (grmon_file, "quit");

      Close (grmon_file);

      Put_Line ("./GR740/grmon.cmd generated");
   end;

   ---Begin Generation Makefile File---
   declare

      makefile_file : File_Type;

   begin
      Create
        (makefile_file, Out_File,
         Containing_Directory (Argument (1)) & "/GR740/Makefile");

      Put_Line (makefile_file, "all:");
      Put_Line (makefile_file, Tab & "make -C core0");
      Put_Line (makefile_file, Tab & "make -C core1");
      Put_Line (makefile_file, Tab & "make -C core2");
      Put_Line (makefile_file, Tab & "make -C core3");
      Put_Line (makefile_file, "");
      Put_Line (makefile_file, "clean:");
      Put_Line (makefile_file, Tab & "make -C core0 clean");
      Put_Line (makefile_file, Tab & "make -C core1 clean");
      Put_Line (makefile_file, Tab & "make -C core2 clean");
      Put_Line (makefile_file, Tab & "make -C core3 clean");

      Close (makefile_file);

      Put_Line ("./GR740/Makefile generated");
   end;

   ---Begin Generation launcher.sh File---
   declare

      launcher_file : File_Type;

   begin
      Create
        (launcher_file, Out_File,
         Containing_Directory (Argument (1)) & "/GR740/launcher.sh");

      Put_Line (launcher_file, "#!/bin/bash");
	Put_Line (launcher_file, "");      
      Put_Line (launcher_file, "sed -i ""s/gdb [0-9][0-9]*/gdb $3/"" grmon_gdb.cmd");
      Put_Line (launcher_file, "sed -i ""s/target extended-remote localhost:[0-9][0-9]*/target extended-remote localhost:$3/"" execution_trace.gdb");
	Put_Line (launcher_file, "");
      Put_Line (launcher_file, "# Start GRMON through a GR740 board (non-blocking)");
      Put_Line
        (launcher_file,
         "$1 grmon_gdb.cmd . > grmon3.log &");
      Put_Line (launcher_file, "WRAPPER_PID=$!");
      Put_Line (launcher_file, "");
      Put_Line
        (launcher_file,
         "echo ""Waiting for GRMON GDB server to be available on port ""$3""...""");
      Put_Line (launcher_file, "while ! netstat -tuln | grep -q ':'$3; do");
      Put_Line (launcher_file, Tab & "sleep 0.5");
      Put_Line (launcher_file, "done");
      Put_Line (launcher_file, "");
      Put_Line
        (launcher_file,
         "echo ""GRMON GDB server detected. Launching GDB...""");
      Put_Line (launcher_file, "");
      Put_Line (launcher_file, "# Launch GDB with the associated script");
      Put_Line
        (launcher_file,
         "/opt/sparc-bcc-2.3.1-gcc/bin/sparc-gaisler-elf-gdb $2 -x execution_trace.gdb");

      Close (launcher_file);

      Put_Line ("./GR740/launcher.sh generated");
   end;

   ---Begin Generation gdb File---
   declare

      gdb_file : File_Type;

   begin
      Create
        (gdb_file, Out_File,
         Containing_Directory (Argument (1)) & "/GR740/execution_trace.gdb");

      Put_Line (gdb_file, "define print_all_entries");
      Put_Line (gdb_file, Tab & "set $task = 0");
      Put_Line (gdb_file, Tab & "set $ntasks = $shared.tasks_table.tasks_counter");
      Put_Line (gdb_file, Tab & "while ($task < $ntasks)");
      Put_Line (gdb_file, Tab & Tab & "set $nentries = $shared.tasks_table.tasks[$task]->task_report.timing_execution_trace.entryCount");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, Tab & Tab & "set $task_name = $shared.tasks_table.tasks[$task]->name");
      Put_Line (gdb_file, Tab & Tab & "set $cpu = $shared.tasks_table.tasks[$task]->core_id");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, Tab & Tab & "printf ""\n>>>>>>>>>>>> core%d::%sTimingExecutionEntries"", $cpu, $task_name");
      Put_Line (gdb_file, Tab & Tab & "printf "" - 0x%x\n"", $shared.tasks_table.tasks[$task]->task_report.timing_execution_trace.timingExecutionEntries");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, Tab & Tab & "if ($nentries > 0)");
      Put_Line (gdb_file, Tab & Tab & Tab & "p *$shared.tasks_table.tasks[$task]->task_report.timing_execution_trace.timingExecutionEntries@($nentries)");
      Put_Line (gdb_file, Tab & Tab & "end");
      Put_Line (gdb_file, Tab & "set $task = $task + 1");
      Put_Line (gdb_file, Tab & "end");
      Put_Line (gdb_file, "end");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, "define print_all_traceId");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, Tab & "set $task = 0");
      Put_Line (gdb_file, Tab & "set $ntasks = $shared.tasks_table.tasks_counter");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, Tab & "while ($task < $ntasks)");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, Tab & Tab & "set $task_name = $shared.tasks_table.tasks[$task]->name");
      Put_Line (gdb_file, Tab & Tab & "set $cpu = $shared.tasks_table.tasks[$task]->core_id");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, Tab & Tab & "set $task_report_id = $shared.tasks_table.tasks[$task]->task_report_id");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, Tab & Tab & "set $rec_task = 0");
      Put_Line (gdb_file, Tab & Tab & "set $nrec_tasks = $shared.tasks_table.tasks[$task]->sending_queues_counter");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, Tab & Tab & Tab & "while ($rec_task < $nrec_tasks)");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, Tab & Tab & Tab & "set $rec_task_name = $shared.tasks_table.tasks[$task]->sending_queues[$rec_task]->receiver_name");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, Tab & Tab & Tab & "set $spinlockId = $shared.tasks_table.tasks[$task]->sending_queues[$rec_task].task_report_id");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, Tab & Tab & Tab & "printf ""\n>>>>>> core%d::%sIcq%s.traceId"", $cpu, $task_name, $rec_task_name");
      Put_Line (gdb_file, Tab & Tab & Tab & "printf "" = %d\n"",  $spinlockId");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, Tab & Tab & Tab & "set $rec_task = $rec_task + 1");
      Put_Line (gdb_file, Tab & Tab & "end");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, Tab & Tab & "printf ""\n>>>>>> core%d::%s.traceId"", $cpu, $task_name");
      Put_Line (gdb_file, Tab & Tab & "printf "" = %d\n"",  $task_report_id");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, Tab & Tab & "set $task = $task + 1");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, Tab & "end");
      Put_Line (gdb_file, "end");

	Put_Line (gdb_file, "");
      Put_Line (gdb_file, "set pagination off");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, "add-symbol-file core1/app_core1");
      Put_Line (gdb_file, "add-symbol-file core2/app_core2");
      Put_Line (gdb_file, "add-symbol-file core3/app_core3");
      Put_Line (gdb_file, "set $shared=(praicc_shared_area_t*)0x04000000");
      Put_Line (gdb_file, "printf ""PrAICC shared area set at 0x04000000\n""");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, "set print pretty on");
      Put_Line (gdb_file, "set print array on");
      Put_Line (gdb_file, "set print elements 0");
      Put_Line (gdb_file, "set max-value-size unlimited");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, "target extended-remote localhost:2233");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, "printf ""GRMON connected. Ready to retreive execution events\n""");
      Put_Line (gdb_file, "shell sleep 2");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, "printf ""\n\t<<<--- TimingExecutionEntries --->>>\n""");
      Put_Line (gdb_file, Tab & "print_all_entries");
      Put_Line (gdb_file, "printf ""\n\t<<<--- trace ID --->>>\n""");
      Put_Line (gdb_file, Tab & "print_all_traceId");
      Put_Line (gdb_file, "printf ""\n\t<<<--- Stub --->>>\n""");
      Put_Line (gdb_file, "printf ""\n\t<<<--- Stub Messages --->>>\n""");
      Put_Line (gdb_file, "");
      Put_Line (gdb_file, "disconnect");
      Put_Line (gdb_file, "printf ""GRMON disconnected. GDB run is completed succesfully\n""");
      Put_Line (gdb_file, "q");

      Close (gdb_file);

      Put_Line ("./GR740/execution_trace.gdb generated");
   end;

   ---Begin Generation setup_AMP File---
   declare

      setup_AMP_file : File_Type;

   begin
      Create
        (setup_AMP_file, Out_File,
         Containing_Directory (Argument (1)) & "/GR740/setup_AMP.tcl");

      Put_Line (setup_AMP_file, Tab & Tab & Tab & "if {[regexp -inline {[^.]*} $grmon_version] == 3} {");
      Put_Line (setup_AMP_file, Tab & Tab & Tab & Tab & "interp alias {} install_exec_hook {} grmon::execsh eval ");
      Put_Line (setup_AMP_file, "} else {");
      Put_Line (setup_AMP_file, Tab & Tab & Tab & Tab & "interp alias {} install_exec_hook {} namespace eval :: ");
      Put_Line (setup_AMP_file, "}");
      Put_Line (setup_AMP_file, "");
      Put_Line (setup_AMP_file, "# Enable UART1");
      Put_Line (setup_AMP_file, "grcg enable 8");

      Put_Line (setup_AMP_file, "after 200");
      Put_Line (setup_AMP_file, "bp del");
      Put_Line (setup_AMP_file, "reset");
      Put_Line (setup_AMP_file, "# Forget any old symbols");
      Put_Line (setup_AMP_file, "foreach c {cpu0 cpu1 cpu2 cpu3} {");
      Put_Line (setup_AMP_file, Tab & "silent load clear $c");
      Put_Line (setup_AMP_file, Tab & "silent symbols clear $c");
      Put_Line (setup_AMP_file, "}");
      Put_Line (setup_AMP_file, "");
      Put_Line (setup_AMP_file, "# CPU0: RTEMS SMP");
      Put_Line (setup_AMP_file, "# First 16 MiB");
      Put_Line (setup_AMP_file, "# APBUART1, GPTIMER1");
      Put_Line (setup_AMP_file, "load core0/app_core0 cpu0");
      Put_Line (setup_AMP_file, "silent stack 0x00fffff0 cpu0");
      Put_Line (setup_AMP_file, "silent ep 0x00000000 cpu0");
      Put_Line (setup_AMP_file, "");
      Put_Line (setup_AMP_file, "# CPU1: BCC");
      Put_Line (setup_AMP_file, "# Second 16 MiB");
      Put_Line (setup_AMP_file, "# APBUART0, GPTIMER0");
      Put_Line (setup_AMP_file, "load core1/app_core1 cpu1");
      Put_Line (setup_AMP_file, "silent stack 0x01fffff0 cpu1");
      Put_Line (setup_AMP_file, "silent ep 0x01000000 cpu1");
      Put_Line (setup_AMP_file, "");
      Put_Line (setup_AMP_file, "# CPU2: BCC");
      Put_Line (setup_AMP_file, "# Second 16 MiB");
      Put_Line (setup_AMP_file, "# APBUART0, GPTIMER0");
      Put_Line (setup_AMP_file, "load core2/app_core2 cpu2");
      Put_Line (setup_AMP_file, "silent stack 0x02fffff0 cpu2");
      Put_Line (setup_AMP_file, "silent ep 0x02000000 cpu2");
      Put_Line (setup_AMP_file, "");
      Put_Line (setup_AMP_file, "# CPU3: BCC");
      Put_Line (setup_AMP_file, "# Second 16 MiB");
      Put_Line (setup_AMP_file, "# APBUART0, GPTIMER0");
      Put_Line (setup_AMP_file, "load core3/app_core3 cpu3");
      Put_Line (setup_AMP_file, "silent stack 0x03fffff0 cpu3");
      Put_Line (setup_AMP_file, "silent ep 0x03000000 cpu3");
      Put_Line (setup_AMP_file, "");
      Put_Line (setup_AMP_file, "silent forward disable uart0");
      Put_Line (setup_AMP_file, "silent forward enable uart0");
      Put_Line (setup_AMP_file, "silent forward disable uart1");
      Put_Line (setup_AMP_file, "silent forward enable uart1");
      Put_Line (setup_AMP_file, "");
      Put_Line (setup_AMP_file, "if {[info exists ::hooks::preexec]} {");
      Put_Line (setup_AMP_file, Tab & "set ::hooks::preexec [lsearch -inline -not -all -exact $::hooks::preexec ::irq_setup]");
      Put_Line (setup_AMP_file, "}");
      Put_Line (setup_AMP_file, "");
      Put_Line (setup_AMP_file, "if {[info exists ::hooks::postexec]} {");
      Put_Line (setup_AMP_file, Tab & "set ::hooks::postexec [lsearch -inline -not -all -exact $::hooks::postexec ::remove_irq_setup]");
      Put_Line (setup_AMP_file, "}");
      Put_Line (setup_AMP_file, "");
      Put_Line (setup_AMP_file, "proc irq_setup {} {");
      Put_Line (setup_AMP_file, Tab & "puts ""Configuring interrupt controller""");
      Put_Line (setup_AMP_file, Tab & "set ::irqmp0::0::actrl 0");
      Put_Line (setup_AMP_file, Tab & "# Make the instance use separate IRQ controllers");
      Put_Line (setup_AMP_file, Tab & "set ::irqmp0::0::select1 0x01110000");
      Put_Line (setup_AMP_file, Tab & "set ::irqmp0::0::select2 0");
      Put_Line (setup_AMP_file, Tab & "# Lock out other CPUs");
      Put_Line (setup_AMP_file, Tab & "set ::irqmp0::0::actrl 1");
      Put_Line (setup_AMP_file, "");
      Put_Line (setup_AMP_file, Tab & "# Clear mask for all interrupt controllers. It prevents CPU power up");
      Put_Line (setup_AMP_file, Tab & "# by pending interrupt at GRMON run.");
      Put_Line (setup_AMP_file, Tab & "set ::irqmp0::0::cpumask0 0");
      Put_Line (setup_AMP_file, Tab & "set ::irqmp0::1::cpumask1 0");
      Put_Line (setup_AMP_file, Tab & "set ::irqmp0::2::cpumask2 0");
      Put_Line (setup_AMP_file, Tab & "set ::irqmp0::3::cpumask3 0");
      Put_Line (setup_AMP_file, Tab & "irq routing");
      Put_Line (setup_AMP_file, "}");
      Put_Line (setup_AMP_file, "");
      Put_Line (setup_AMP_file, "proc remove_irq_setup {} {");
      Put_Line (setup_AMP_file, Tab & "set ::hooks::preexec [lsearch -inline -not -all -exact $::hooks::preexec ::irq_setup]");
      Put_Line (setup_AMP_file, "}");
      Put_Line (setup_AMP_file, "");
      Put_Line (setup_AMP_file, "lappend ::hooks::preexec ::irq_setup");
      Put_Line (setup_AMP_file, "lappend ::hooks::postexec ::remove_irq_setup");
      Put_Line (setup_AMP_file, "");
      Put_Line (setup_AMP_file, "");
      Put_Line (setup_AMP_file, "cpu active 0");
      Put_Line (setup_AMP_file, "");
      Put_Line (setup_AMP_file, "puts """"");
      Put_Line (setup_AMP_file, "forward");
      Put_Line (setup_AMP_file, "ep");
      Put_Line (setup_AMP_file, "stack");
      Put_Line (setup_AMP_file, "");
      Put_Line (setup_AMP_file, "puts ""use 'run' to start example""");

      Close (setup_AMP_file);

      Put_Line ("./GR740/setup_AMP.tcl generated");
   end;


end Generate_icq_lib_app;


