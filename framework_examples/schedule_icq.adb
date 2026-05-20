with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Command_Line;      use Ada.Command_Line;
with Ada.Strings.Fixed;     use Ada.Strings.Fixed;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
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

with Ada.Strings.Fixed; use Ada.Strings.Fixed;

with ipc_analysis; use ipc_analysis;

procedure schedule_icq is

   sys : System;

   my_iterator       : core_units_iterator;
   a_core_unit       : core_unit_ptr;
   a_core_unit_table : core_units_set;

   my_buffer_iterator : buffers_iterator;
   a_buffer           : buffer_ptr;

   disp_name : Unbounded_String;
   disp      : Generic_task_ptr;

   disp_WCET : Integer;
   disp_BCET : Integer;
   disp_WCRT : Integer;
   disp_BCRT : Integer;
   disp_WST  : Integer;
   disp_BST  : Integer;
   disp_WSHT : Integer;
   disp_BSHT : Integer;

   output_file_name : Unbounded_String;
   output_file      : File_Type;

   task_deadline : Integer;

   is_feasible : Natural := 1;

begin

   if Argument_Count < 1 then
      Put ("Usage: " & Command_Name & " ");
      Put_Line ("system_cheddar_File");
      GNAT.OS_Lib.OS_Exit (1);
   end if;

   Call_Framework.initialize (False);

   read_from_xml_File (sys, Argument (1));

   output_file_name :=
     To_Unbounded_String (Argument (1) (1 .. Argument (1)'Length - 6));
   Create
     (output_file, Out_File, To_String (output_file_name & "_result.txt"));

   Put_Line
     (output_file,
      "Tasks;CH_BCET;CH_WCET;CH_BCRT;CH_WCRT;CH_BST;CH_WST;CH_BSHT;CH_WSHT;CH_BICL;CH_WICL");

   if not is_empty (sys.core_units) then

      reset_iterator (sys.core_units, my_iterator);
      loop
         current_element (sys.core_units, a_core_unit, my_iterator);

         disp_name :=
           To_Unbounded_String
             ("disp" & To_String (a_core_unit.name) (5 .. 5));

         disp := get_dispatcher (sys, a_core_unit.name);

         if disp /= null then

            disp_WCET := compute_dispatcher_WCET (sys, a_core_unit.name);

            disp_BCET := compute_dispatcher_BCET (sys, a_core_unit.name);

            disp_WCRT := compute_dispatcher_WCRT (sys, a_core_unit.name);

            disp_BCRT := compute_dispatcher_BCRT (sys, a_core_unit.name);
            disp_WST  := compute_dispatcher_WSAT (sys, a_core_unit.name);
            disp_BST  := 0;
            disp_WSHT :=
              compute_dispatcher_WSHT (sys, a_core_unit.name) - disp_BST;
            disp_BSHT :=
              compute_dispatcher_BSHT (sys, a_core_unit.name) - disp_BST;

            Put_Line
              (To_STRING (disp.name) & " BCET=" & disp_BCET'Image & " WCET=" &
               disp_WCET'Image & " BCRT=" & disp_BCRT'Image & " WCRT=" &
               disp_WCRT'Image & " BST=" & disp_BST'Image & " WST=" &
               disp_WST'Image & " BSHT=" & disp_BSHT'Image & " WSHT=" &
               disp_WSHT'Image & "");

            task_deadline := get (sys.Tasks, disp.name, deadline);
            if disp_WCRT > task_deadline then

               Put_Line
                 (To_STRING (disp.name) & ": " & disp_WCRT'Image & "-" &
                  task_deadline'Image);
               is_feasible := 0;

            end if;

         else

            disp_WCET := 0;
            disp_BCET := 0;
            disp_WCRT := 0;
            disp_BCRT := 0;
            disp_WST  := 0;
            disp_BST  := 0;
            disp_WSHT := 0;
            disp_BSHT := 0;

         end if;

         declare

            disp_file_name : Unbounded_String;

         begin

            disp_file_name :=
              a_core_unit.name & "::disp" &
              To_String (a_core_unit.name)
                (To_String (a_core_unit.name)'Length ..
                     To_String (a_core_unit.name)'Length);

            Put_Line
              (output_file,
               To_String (disp_file_name) & ";" &
               Trim (disp_BCET'Image, Ada.Strings.Left) & ";" &
               Trim (disp_WCET'Image, Ada.Strings.Left) & ";" &
               Trim (disp_BCRT'Image, Ada.Strings.Left) & ";" &
               Trim (disp_WCRT'Image, Ada.Strings.Left) & ";" &
               Trim (disp_BST'Image, Ada.Strings.Left) & ";" &
               Trim (disp_WST'Image, Ada.Strings.Left) & ";" &
               Trim (disp_BSHT'Image, Ada.Strings.Left) & ";" &
               Trim (disp_WSHT'Image, Ada.Strings.Left) & ";0;0");

         end;
         exit when is_last_element (sys.core_units, my_iterator);
         next_element (sys.core_units, my_iterator);
      end loop;

   end if;

   if not is_empty (sys.Buffers) then

      reset_iterator (sys.Buffers, my_buffer_iterator);
      loop
         current_element (sys.Buffers, a_buffer, my_buffer_iterator);

         declare

            IndexB        : Natural := Index (To_String (a_buffer.name), "B");
            sender_name   : Unbounded_String;
            receiver_name : Unbounded_String;

            sender   : Generic_Task_Ptr;
            receiver : Generic_Task_Ptr;

            sender_core      : Unbounded_String;
            sender_file_name : Unbounded_String;

            sender_WCET : Integer := 0;
            sender_BCET : Integer := 0;
            sender_WCRT : Integer := 0;
            sender_BCRT : Integer := 0;
            sender_BST  : Integer := 0;
            sender_WST  : Integer := 0;
            sender_WSHT : Integer := 0;
            sender_BSHT : Integer := 0;
            sender_WICL : Integer := 0;
            sender_BICL : Integer := 0;

         begin

            sender_name :=
              To_Unbounded_String
                (To_String (a_buffer.name) (1 .. IndexB - 1));
            sender := get (sys, sender_name);

            receiver_name :=
              To_Unbounded_String
                (To_String (a_buffer.name)
                   (IndexB + 1 .. To_String (a_buffer.name)'Last));
            receiver := get (sys, receiver_name);

            sender_core := get (sys.Tasks, sender_name, core_name);

            sender_file_name := sender_core & "::" & sender_name;

            sender_WCET := compute_task_WCET (sys, sender);

            sender_BCET := compute_sender_BCET (sys, sender);
            sender_WCRT := compute_sender_WCRT (sys, sender);

            sender_BCRT := compute_sender_BCRT (sys, sender);
            sender_BST  := 0;
            sender_WST  := compute_sender_WSAT (sys, sender);

            sender_WSHT := get_read_write_delay (sys, sender);
            sender_BSHT := get_read_write_delay (sys, sender);

            sender_WICL := compute_WICL (sys, sender, receiver);

            sender_BICL := compute_BICL (sys, receiver, sender);

            Put_Line
              (To_STRING (sender.name) & " BCET=" & sender_BCET'Image &
               " WCET=" & sender_WCET'Image & " BCRT=" & sender_BCRT'Image &
               " WCRT=" & sender_WCRT'Image & " BST=" & sender_BST'Image &
               " WST=" & sender_WST'Image & " BSHT=" & sender_BSHT'Image &
               " WSHT=" & sender_WSHT'Image & "");

            task_deadline := get (sys.Tasks, sender.name, deadline);
            if sender_WCRT > task_deadline then

               Put_Line
                 (To_String (sender_name) & ": " & sender_WCRT'Image & "-" &
                  task_deadline'Image);
               is_feasible := 0;

            end if;

            Put_Line
              (output_file,
               To_String (sender_file_name) & ";" &
               Trim (sender_BCET'Image, Ada.Strings.Left) & ";" &
               Trim (sender_WCET'Image, Ada.Strings.Left) & ";" &
               Trim (sender_BCRT'Image, Ada.Strings.Left) & ";" &
               Trim (sender_WCRT'Image, Ada.Strings.Left) & ";" &
               Trim (sender_BST'Image, Ada.Strings.Left) & ";" &
               Trim (sender_WST'Image, Ada.Strings.Left) & ";" &
               Trim (sender_BSHT'Image, Ada.Strings.Left) & ";" &
               Trim (sender_WSHT'Image, Ada.Strings.Left) & ";" &
               Trim (sender_BICL'Image, Ada.Strings.Left) & ";" &
               Trim (sender_WICL'Image, Ada.Strings.Left));

         end;
         exit when is_last_element (sys.Buffers, my_buffer_iterator);
         next_element (sys.Buffers, my_buffer_iterator);
      end loop;

   end if;

   Close (output_file);
   Set_Exit_Status (Exit_Status (is_feasible));

end schedule_icq;
