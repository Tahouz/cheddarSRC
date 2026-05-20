------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Cheddar is a GNU GPL real-time scheduling analysis tool.
-- This program provides services to automatically check schedulability and
-- other performance criteria of real-time architecture models.
--
-- Copyright (C) 2002-2016, Frank Singhoff, Alain Plantec, Jerome Legrand
--
-- The Cheddar project was started in 2002 by
-- Frank Singhoff, Lab-STICC UMR 6285 laboratory, Université de Bretagne Occidentale
--
-- Cheddar has been published in the "Agence de Protection des Programmes/France" in 2008.
-- Since 2008, Ellidiss technologies also contributes to the development of
-- Cheddar and provides industrial support.
--
-- The full list of contributors and sponsors can be found in README.md
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

with Ada.Text_IO;              use Ada.Text_IO;
with Ada.Integer_Text_IO;      use Ada.Integer_Text_IO;
with Ada.Command_Line;         use Ada.Command_Line;
with AADL_Config;              use AADL_Config;
with unbounded_strings;        use unbounded_strings;
with Text_IO;                  use Text_IO;
with Ada.Exceptions;           use Ada.Exceptions;
with translate;                use translate;
with processor_set;            use processor_set;
with Text_IO;                  use Text_IO;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with unbounded_strings;        use unbounded_strings;
with Dependencies;             use Dependencies;
with task_dependencies;        use task_dependencies;
with task_dependencies;        use task_dependencies.half_dep_set;
with sets;
with Tasks;                    use Tasks;
with task_set;                 use task_set;
with message_set;              use message_set;
with Messages;                 use Messages;
with systems;                  use systems;
with framework;                use framework;
with call_framework;           use call_framework;
with Call_Framework_Interface; use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with call_scheduling_framework;         use call_scheduling_framework;
with multiprocessor_services;           use multiprocessor_services;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
with Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with GNAT.Command_Line;
with GNAT.OS_Lib; use GNAT.OS_Lib;
with version;     use version;
with Parameters;  use Parameters;
use Parameters.User_Defined_Parameters_Table_Package;
with Parameters.extended; use Parameters.extended;
with mesh_analysis;       use mesh_analysis;

package body mesh_analysis.delays is

   -----------------------------
   -- subprograms --
   -----------------------------

-- FS virer put ou put_debug

------------------------------
---Path_delay-----------------
------------------------------
--compute the path delay for each message
------------------------------

   procedure compute_path_delay
     (packet_size    : in     Integer;
      injection_time : in     Integer;
      path_delay     : in out integer_table)
   is

   begin
      --put_Line ("======-----Path_delay------======") ;

      for i in 1 .. Max_Messages loop

         path_delay (i) :=
           (8 + Integer (link_table_size (i)) * 5) +
           (packet_size - 1) * injection_time;
         --put_Line ("") ;
         --put("Message");
         --put(i) ;
         --put (":") ;
         --put (Path_delay(i)) ;

      end loop;

   end compute_path_delay;

---------------------------
--procedure compute_DI-----
---------------------------
---calculate Direct_interference_delay
--1) calculate the number of shared physical link
--2) check if the source and/or the destination is also shared with other message
--3) calculate the delay.
---------------------------

   procedure compute_direct_interference
     (a_link_mat   : in     links_mat;
      shared_links : in out integer_table)
   is

      a_link_table1 : links_tab;
      a_link_table2 : links_tab;
      a_link1       : mesh_links;
      a_link2       : mesh_links;

   begin

      for i in 1 .. Max_Messages loop
         shared_links (i) := 0;

         a_link_table1 := a_link_mat (i);

         for i1 in 1 .. Integer (link_table_size (i)) loop
            a_link1 := a_link_table1 (i1);

            for j in 1 .. Max_Messages loop
               a_link_table2 := a_link_mat (j);

               for j1 in 1 .. Integer (link_table_size (j)) loop
                  a_link2 := a_link_table2 (j1);

                  if (a_link1 = a_link2) then

                     shared_links (i) := shared_links (i) + 1;

                  end if;

               end loop;

            end loop;

         end loop;

      end loop;

      --put_line("") ;
      --put_Line ("======-----Direct_interference------======") ;

      for i in 1 .. Max_Messages loop
         --put_Line ("") ;
         --put("Message");
         --put(i) ;
         --put (":") ;
         shared_links (i) := shared_links (i) - Integer (link_table_size (i));
         --put(shared_links(i)) ;
      end loop;

   end compute_direct_interference;

   ------------------------------
   ---Check_Indirect_Interference
   ------------------------------

   procedure check_indirect_interference
     (a_link_mat   : in     links_mat;
      shared_links : in out integer_table)
   is

      a_link_table1, a_link_table2, a_link_table3 : links_tab;
      a_link1, a_link2, a_link3                   : mesh_links;

   begin

      Put_Line ("");
      Put_Line ("======-----Indirecte Interference ------======");

      for i in 1 .. Max_Messages loop
         shared_links (i) := 0;

         Put_Line ("");
         Put ("Message: M");
         Put (i);
         Put ("      :  ");
         Put ("have indirect interference with Message");

         a_link_table1 := a_link_mat (i);

         for i1 in 1 .. Integer (link_table_size (i)) loop
            a_link1 := a_link_table1 (i1);

            for j in 1 .. Max_Messages loop
               a_link_table2 := a_link_mat (j);

               for j1 in 1 .. Integer (link_table_size (j)) loop
                  a_link2 := a_link_table2 (j1);

                  if (a_link1 = a_link2) then

                     if (i /= j) then

                        for z in 1 .. Max_Messages loop
                           a_link_table3 := a_link_mat (z);
                           for z1 in 1 .. Integer (link_table_size (z)) loop
                              a_link3 := a_link_table3 (z1);

                              if (a_link2 = a_link3) then
                                 if (z /= i) and (z /= j) then

                                    Put (j);
                                 end if;
                              end if;
                           end loop;

                        end loop;

                     end if;

                  end if;

               end loop;

            end loop;

         end loop;

      end loop;

   end check_indirect_interference;

   --------------------------------
   ---Compute_Communication_Time---
   --------------------------------

   procedure compute_communication_time_saf
     (my_messages                : in     messages_set;
      path_delay                 : in     integer_table;
      shared_links               : in     integer_table;
      communication_time         : in out integer_table;
      one_link_transmission_time : in     Integer)
   is
      i            : Integer;
      my_iterator2 : messages_iterator;
      a_message    : generic_message_ptr;

   begin

      Put_Line ("");
      -- put_Line ("======-----Communication_time------======") ;

      i := 1;
      reset_iterator (my_messages, my_iterator2);
      loop
         current_element (my_messages, a_message, my_iterator2);
         --put_Line ("") ;
         --Put("Message: ") ;
         --put(To_String(A_Message.name));
         --put("      :  ") ;
         communication_time (i) :=
           Integer (link_table_size (i)) * one_link_transmission_time +
           shared_links (i) * one_link_transmission_time;
         --put(communication_time(i)) ;
         --put("    ns         cheddar ") ;

         exit when is_last_element (my_messages, my_iterator2);

         next_element (my_messages, my_iterator2);
         i := i + 1;

      end loop;

   end compute_communication_time_saf;

   procedure compute_communication_time_wormhole
     (my_messages                : in     messages_set;
      path_delay                 : in     integer_table;
      shared_links               : in     integer_table;
      communication_time         : in out integer_table;
      one_link_transmission_time : in     Integer;
      packet_size                : in     Integer)
   is
      i            : Integer;
      my_iterator2 : messages_iterator;
      a_message    : generic_message_ptr;

   begin

      Put_Line ("");
      -- put_Line ("======-----Communication_time------======") ;

      i := 1;
      reset_iterator (my_messages, my_iterator2);
      loop
         current_element (my_messages, a_message, my_iterator2);
         --put_Line ("") ;
         --Put("Message: ") ;
         --put(To_String(A_Message.name));
         --put("      :  ") ;
         communication_time (i) :=
           (Integer (link_table_size (i)) + 1) *
           (one_link_transmission_time / packet_size) +
           shared_links (i) * (one_link_transmission_time / packet_size);
         --put(communication_time(i)) ;
         --put("    ns         cheddar ") ;

         exit when is_last_element (my_messages, my_iterator2);

         next_element (my_messages, my_iterator2);
         i := i + 1;

      end loop;

   end compute_communication_time_wormhole;

end mesh_analysis.delays;
