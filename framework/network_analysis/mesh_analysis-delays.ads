------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Cheddar is a GNU GPL real-time scheduling analysis tool.
-- This program provides services to automatically check schedulability and
-- other performance criteria of real-time architecture models.
--
-- Copyright (C) 2002-2023, Frank Singhoff, Alain Plantec, Jerome Legrand,
--                          Hai Nam Tran, Stephane Rubini
--
-- The Cheddar project was started in 2002 by
-- Frank Singhoff, Lab-STICC UMR 6285, Université de Bretagne Occidentale
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
--
--
-- Contact : cheddar@listes.univ-brest.fr

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

package mesh_analysis.delays is

   ------------------------------
   ---Path_delay-----------------
   ------------------------------
   -- compute the path delay for each message
   -- the path delay depends on the message size (nbr_packet) and the path (used physical links)

   procedure compute_path_delay
     (packet_size    : in     Integer;
      injection_time : in     Integer;
      path_delay     : in out integer_table);

   ---------------------------
   ---compute_Direct_Interference -----
   ---------------------------
   -- calculate Direct_interference_delay
   --1) calculate the number of shared physical link
   --2) check if the source and/or the destination is also shared with other message
   --3) calculate the delay.

   procedure compute_direct_interference
     (a_link_mat   : in     links_mat;
      shared_links : in out integer_table);

   ---------------------------
   ---Check_Indirect_Interference
   ---------------------------
   -- check if there is indirect interference in the network

   procedure check_indirect_interference
     (a_link_mat   : in     links_mat;
      shared_links : in out integer_table);

   -----------------------------
   ---Compute_Communication_Time
   -----------------------------
   -- Compute and display the worst case communication time for each flow

   procedure compute_communication_time_saf
     (my_messages                : in     messages_set;
      path_delay                 : in     integer_table;
      shared_links               : in     integer_table;
      communication_time         : in out integer_table;
      one_link_transmission_time : in     Integer);

   procedure compute_communication_time_wormhole
     (my_messages                : in     messages_set;
      path_delay                 : in     integer_table;
      shared_links               : in     integer_table;
      communication_time         : in out integer_table;
      one_link_transmission_time : in     Integer;
      packet_size                : in     Integer);

end mesh_analysis.delays;
