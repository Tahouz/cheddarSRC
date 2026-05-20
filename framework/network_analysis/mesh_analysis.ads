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
--
------------------------------------------------------------------------------
-- Last update :
--    $Rev: 4589 $
--    $Date: 2023-09-29 16:02:19 +0200 (ven., 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

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
with network_set;         use network_set;
with Networks;            use Networks;
with indexed_tables;
with Framework_Config;    use Framework_Config;

package mesh_analysis is

   ---------------------
   --    Constants    --
   ---------------------

   max_mesh_links_per_message : constant Integer :=
     6;  -- max_dim is the maximum number of possible links used by one packet

   one_hope_delay : constant Integer :=
     8;  --one_hope_delay presents the transmission delay of the packet for one hope ( between two routers) (cycle)

   max_mesh_x_size : constant Integer := 4;
   max_mesh_y_size : constant Integer := 4;

   ---------------------
   --      Types      --
   ---------------------

   type processor_rank is
     new Integer range 0 .. (max_mesh_x_size * max_mesh_y_size);

   type processor_ranks is array (1 .. Max_Messages) of processor_rank;

   type mesh_links is record
      source      : processor_rank;
      destination : processor_rank;
   end record;

   type links_tab is array (1 .. max_mesh_links_per_message) of mesh_links;

   type links_mat is array (1 .. Max_Messages) of links_tab;

   type tab_position is array (1 .. Max_Messages) of position;

   type integer_table is array (1 .. Max_Messages) of Integer;

   ----------------------
   -- Global variables --
   ----------------------

   link_table_size : processor_ranks;

   -----------------------------
   -- subprograms --
   -----------------------------

   -----------------------
   --compute_source_destination_task--
   -----------------------

   -- generate destination tasks set and source task set from sys.tasks and sys.dependencies--
   -- source task set and destination task set help us to define the nodeS and nodeD which are parameters of our flow model --------------
   -- nodeS and nodeD are the nodes running the source task and the destination task; those two parameters helps us to compute used physical links ---

   procedure compute_source_destination_task
     (my_tasks          : in     tasks_set;
      my_messages       : in     messages_set;
      my_dep            : in     tasks_dependencies_ptr;
      destination_tasks : in out tasks_set;
      source_tasks      : in out tasks_set);

   ----------------------------------
   ----display_source_destination_task
   ----------------------------------

   procedure display_source_destination_task
     (my_messages                    : in     messages_set;
      destination_tasks              : in     tasks_set;
      source_tasks                   : in     tasks_set;
      sourcetask_position_table      : in     tab_position;
      destinationtask_position_table : in     tab_position;
      sourcetask_rank_table          : in out processor_ranks;
      destinationtask_rank_table     : in out processor_ranks);

   ----------------------------------------------
   ---compute_source_destination_task_position---
   ----------------------------------------------

   --select position of each souce and destination task in order to compute the used links for each flow---
   --which the destination and source task positions are parameters of our flow model----------------------

   procedure compute_noc_source_destination_task_position
     (sourcetask_position_table      : in out tab_position;
      destinationtask_position_table : in out tab_position;
      sourcetask_rank_table          : in out processor_ranks;
      destinationtask_rank_table     : in out processor_ranks;
      source_tasks                   : in out tasks_set;
      destination_tasks              : in out tasks_set;
      my_messages                    : in     messages_set;
      my_noc                         : in     networks_set);

   procedure compute_spw_source_destination_task_position
     (sourcetask_position_table      : in out tab_position;
      destinationtask_position_table : in out tab_position;
      sourcetask_rank_table          : in out processor_ranks;
      destinationtask_rank_table     : in out processor_ranks;
      source_tasks                   : in     tasks_set;
      destination_tasks              : in     tasks_set;
      my_messages                    : in     messages_set;
      a_network                      : in     spacewire_network_ptr);

   -------------------------
   ---procedure gen_links---
   -------------------------

   --generate used links for each message

   procedure generate_links_noc
     (a_link_mat                     : in out links_mat;
      my_messages                    : in     messages_set;
      sourcetask_position_table      : in     tab_position;
      destinationtask_position_table : in     tab_position;
      sourcetask_rank_table          : in     processor_ranks);

   procedure generate_links_spw
     (a_link_mat                     : in out links_mat;
      my_messages                    : in     messages_set;
      sourcetask_position_table      : in     tab_position;
      destinationtask_position_table : in     tab_position;
      sourcetask_rank_table          : in     processor_ranks;
      a_network                      : in     spacewire_network_ptr);

   procedure display_used_links
     (my_messages : in messages_set;
      a_link_mat  : in links_mat);

end mesh_analysis;
