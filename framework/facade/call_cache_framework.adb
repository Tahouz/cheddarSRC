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
--    $Rev: 5117 $
--    $Date: 2019-08-27 15:21:33+02:00
--    $Author: nam $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Tasks;                        use Tasks;
with Caches;                       use Caches;
with CFGs;                         use CFGs;
with Core_Units;                   use Core_Units;
with task_set;                     use task_set;
with cfg_set;                      use cfg_set;
with cache_set;                    use cache_set;
with cache_block_set;              use cache_block_set;
with cache_access_profile_set;     use cache_access_profile_set;
with Caches;                       use Caches.Cache_Blocks_Table_Package;
with basic_block_analysis;         use basic_block_analysis;
with systems;                      use systems;
with debug;                        use debug;
with unbounded_strings;            use unbounded_strings;
with xml_tag;                      use xml_tag;
with GNAT.Current_Exception;       use GNAT.Current_Exception;
with Framework_Config;             use Framework_Config;
with translate;                    use translate;
with CFG_Nodes;                    use CFG_Nodes;
with basic_blocks;                 use basic_blocks;
with CFG_Nodes;                    use CFG_Nodes.CFG_Nodes_Table_Package;
with CFG_Nodes.extended;           use CFG_Nodes.extended;
with cfg_node_set;                 use cfg_node_set;
with cfg_node_set.basic_block_set; use cfg_node_set.basic_block_set;
with cfg_edge_set;                 use cfg_edge_set;
with cfg_edges;                    use cfg_edges.cfg_edges_table_package;
with CFGs;                         use CFGs;
with cfg_set;                      use cfg_set;
with xml_generic_parsers;          use xml_generic_parsers;
with sets;
with Ada.Exceptions;               use Ada;

package body call_cache_framework is

   procedure import_cfg
     (sys    : in out System; a_processor : in generic_processor_ptr;
      result : in out Unbounded_String;
      output : in     Output_Format := String_Output)
   is
      a_task                : generic_task_ptr;
      my_iterator           : tasks_iterator;
      sys_cfg               : System;
      project_file_list     : unbounded_string_list;
      project_file_dir_list : unbounded_string_list;
      a_cfg                 : cfg_ptr;
   begin
      result := To_Unbounded_String ("");

      reset_iterator (sys.tasks, my_iterator);
      loop
         current_element (sys.tasks, a_task, my_iterator);

         result :=
           result & lb_minus & lb_task (Current_Language) & " " & a_task.name &
           ": " & unbounded_lf;
         if (a_task.cfg_name /= empty_string) then
            begin
               systems.read_from_xml_file
                 (sys_cfg, project_file_dir_list, a_task.cfg_name);
               result :=
                 result & ASCII.HT & lb_minus &
                 lb_cfg_imported (Current_Language) & a_task.cfg_name &
                 unbounded_lf;

               --If a cfg is imported previously, remove all nodes and edges
               --This is done after we know that an external CFG file exist
               --
               begin
                  a_cfg := search_cfg (sys.cfgs, a_task.cfg_name);
                  for i in 0 .. a_cfg.nodes.nb_entries - 1 loop
                     delete (sys.cfg_nodes, a_cfg.nodes.entries (i));
                  end loop;
                  for i in 0 .. a_cfg.edges.nb_entries - 1 loop
                     delete (sys.cfg_edges, a_cfg.edges.entries (i));
                  end loop;
                  result :=
                    result & ASCII.HT & lb_minus &
                    "Removing the existing CFG and import one from a file with file_name=" &
                    a_task.cfg_name & unbounded_lf;
               exception
                  when cfg_not_found =>
                     result :=
                       result & ASCII.HT & lb_minus &
                       "No CFG specified, import one from a file with file_name=" &
                       a_task.cfg_name & unbounded_lf;
               end;

               a_cfg := search_cfg (sys_cfg.cfgs, a_task.cfg_name);
               add (sys.cfgs, a_cfg);

               for i in 0 .. a_cfg.nodes.nb_entries - 1 loop
                  add (sys.cfg_nodes, a_cfg.nodes.entries (i));
               end loop;
               for i in 0 .. a_cfg.edges.nb_entries - 1 loop
                  add (sys.cfg_edges, a_cfg.edges.entries (i));
               end loop;
            exception
               when ex : others =>
                  result :=
                    result & ASCII.HT & lb_minus &
                    "ERROR: CFG is not imported" & " (" &
                    Exceptions.Exception_Name (ex) & ") " & unbounded_lf;
            end;
         else
            result :=
              result & ASCII.HT & lb_minus &
              "WARNING: No CFG specified for this task" & unbounded_lf;
         end if;

         exit when is_last_element (sys.tasks, my_iterator);
         next_element (sys.tasks, my_iterator);
      end loop;

   exception
      when basic_block_analysis.invalid_input_data =>
         result := result & Exception_Message & unbounded_lf;
   end import_cfg;

   procedure compute_tasks_cache_access_profile
     (sys    : in out System; a_processor : in generic_processor_ptr;
      result : in out Unbounded_String;
      output : in     Output_Format := String_Output)
   is
      a_cache_access_profile : cache_access_profile_ptr;
      a_cap_search           : cache_access_profile_ptr;
      a_task                 : generic_task_ptr;
      my_iterator            : tasks_iterator;

      project_file_list     : unbounded_string_list;
      project_file_dir_list : unbounded_string_list;
   begin
      put_debug ("Call Compute_Task_Cache_Access_Profile");
      result := To_Unbounded_String ("");

      result :=
        result & lb_minus &
        lb_compute_cache_access_profile (Current_Language) &
        To_Unbounded_String (" ") &
        lb_compute_cache_access_profile_method (Current_Language) &
        To_Unbounded_String (" (") & To_Unbounded_String ("[20]") &
        To_Unbounded_String (")") & To_Unbounded_String (" : ") & unbounded_lf;

      -- Task Loop
      --
      reset_iterator (sys.tasks, my_iterator);
      loop
         a_cache_access_profile := new cache_access_profile;
         current_element (sys.tasks, a_task, my_iterator);
         if (a_task.cpu_name = a_processor.name) then
            begin
               result := result & ASCII.HT & a_task.name & unbounded_lf;

               if (a_task.cfg_name /= empty_string) then

      -- If a task has a CFG, always compute a new Cache Access Profile (CAP)
      -- The old Cache Access Profile is removed
                  --
                  begin
                     a_cap_search :=
                       search_cache_access_profile
                         (my_cache_access_profiles =>
                            sys.cache_access_profiles,
                          name => a_task.cache_access_profile_name);
                     delete (sys.cache_access_profiles, a_cap_search);
                     put_debug
                       ("Delete cache access profile with name " &
                        a_task.cache_access_profile_name & " of task: " &
                        a_task.name);
                  exception
                     when cache_access_profile_not_found =>
                        put_debug
                          ("No cache access profile with name " &
                           a_task.cache_access_profile_name & " found for: " &
                           a_task.name);
                  end;

                  compute_cache_access_profile
                    (sys                    => sys, task_name => a_task.name,
                     a_cache_access_profile => a_cache_access_profile);
                  result := result & ASCII.HT & ASCII.HT & "UCB: " & ASCII.HT;
                  for i in 0 .. a_cache_access_profile.UCBs.nb_entries - 1 loop
                     result :=
                       result &
                       a_cache_access_profile.UCBs.entries (i)
                         .cache_block_number'
                         Img &
                       " ";
                  end loop;
                  result := result & unbounded_lf;
                  result := result & ASCII.HT & ASCII.HT & "ECB: " & ASCII.HT;
                  for i in 0 .. a_cache_access_profile.ECBs.nb_entries - 1 loop
                     result :=
                       result &
                       a_cache_access_profile.ECBs.entries (i)
                         .cache_block_number'
                         Img &
                       " ";
                  end loop;

               elsif (a_task.cfg_name = empty_string) and
                 (a_task.cache_access_profile_name /= empty_string)
               then

                  -- If a task has no CFG but has an existing CAP.
                  -- Reuse the existing CAP
                  --
                  result :=
                    result & ASCII.HT & ASCII.HT &
                    "WARNING: No CFG specified for this task" & unbounded_lf;
                  begin
                     a_cap_search :=
                       search_cache_access_profile
                         (my_cache_access_profiles =>
                            sys.cache_access_profiles,
                          name => a_task.cache_access_profile_name);

                     result :=
                       result & ASCII.HT & ASCII.HT &
                       "WARNING: Found and reused an existing cache access profile" &
                       unbounded_lf;

                     result :=
                       result & ASCII.HT & ASCII.HT & "UCB: " & ASCII.HT;
                     for i in 0 .. a_cap_search.UCBs.nb_entries - 1 loop
                        result :=
                          result &
                          a_cap_search.UCBs.entries (i).cache_block_number'
                            Img &
                          " ";
                     end loop;
                     result := result & unbounded_lf;
                     result :=
                       result & ASCII.HT & ASCII.HT & "ECB: " & ASCII.HT;
                     for i in 0 .. a_cap_search.ECBs.nb_entries - 1 loop
                        result :=
                          result &
                          a_cap_search.ECBs.entries (i).cache_block_number'
                            Img &
                          " ";
                     end loop;
                  exception
                     when cache_access_profile_not_found =>
                        put_debug
                          ("No cache access profile found for: " &
                           a_task.name);
                  end;
               else
                  -- No CFG, no CAP
                  --
                  result :=
                    result & ASCII.HT & ASCII.HT &
                    "WARNING: No CFG and cache access profile specified for this task" &
                    unbounded_lf;
               end if;

               result := result & unbounded_lf;
            exception
               -- Task has a CFG but it is not found
               --
               when ex : cfg_not_found =>
                  result :=
                    result & ASCII.HT & ASCII.HT &
                    "ERROR: CFG Not Found (cfg_name=" & a_task.cfg_name & ")" &
                    unbounded_lf;
            end;
         end if;

         exit when is_last_element (sys.tasks, my_iterator);
         next_element (sys.tasks, my_iterator);
      end loop;
   exception
      when basic_block_analysis.invalid_input_data =>
         result := result & Exception_Message & unbounded_lf;
   end compute_tasks_cache_access_profile;

end call_cache_framework;
