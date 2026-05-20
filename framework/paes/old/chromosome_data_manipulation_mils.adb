
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
--
--
-- Contact : cheddar@listes.univ-brest.fr
--           
------------------------------------------------------------------------------
-- Last update : 
--    $Rev: 3561 $
--    $Date: 2020-11-02 08:25:02 +0100 (Mon, 02 Nov 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Numerics.Elementary_Functions;
use Ada.Numerics.Elementary_Functions;

with Ada.Strings;               use Ada.Strings;
with Ada.Strings.Fixed;         use Ada.Strings.Fixed;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random ;
with unbounded_strings;        use unbounded_strings;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
with Ada.Strings; use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Directories; 			use Ada.Directories;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Unbounded_Strings; use Unbounded_Strings;
with convert_unbounded_strings;
use unbounded_strings.unbounded_string_list_package;
use unbounded_strings.strings_table_package;
with Ada.Strings; use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;

with Ada.text_IO; use Ada.text_IO;
with Ada.Integer_text_IO; use Ada.Integer_text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;


with Dependencies; 		use Dependencies; 
with Task_Dependencies; 	use Task_Dependencies; 
with Task_Dependencies; 	use Task_Dependencies.Half_Dep_Set;
with Message_Set ; 		use Message_Set; 
with Messages; 			use Messages; 

with Tasks; use Tasks;
with Task_Set; use Task_Set;
with Resources; use Resources;
with Resource_Set; use Resource_Set;
with Objects; use Objects;
with convert_unbounded_strings;
use unbounded_strings.unbounded_string_list_package;


with Scheduler_Interface; use Scheduler_Interface;
with Address_Spaces;      use Address_Spaces;
with Address_Space_Set;   use Address_Space_Set;


with Call_Framework;                    use Call_Framework;
with Call_Framework_Interface;          use Call_Framework_Interface;
use Call_Framework_Interface.Framework_Response_Package;
use Call_Framework_Interface.Framework_Request_Package;
with Call_Scheduling_Framework;         use Call_Scheduling_Framework;

with Pipe_Commands; use Pipe_Commands;
with Ada.Text_IO; use Ada.Text_IO;

with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Directories; use Ada.Directories;

with GNAT.OS_Lib;  use GNAT.OS_Lib;
with Debug; use Debug;

with Random_Tools; use Random_Tools;


use unbounded_strings.strings_table_package;

with architecture_factory; use architecture_factory;

with Ada.Integer_text_IO; use Ada.Integer_text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;


with Systems;  use Systems;
with Processors;          use Processors;
with Processor_Set;       use Processor_Set;
with processor_interface; use processor_interface;
use Processor_Set.Generic_Processor_Set;

with Core_Units; use Core_Units;
use Core_Units.Core_Units_Table_Package;

with natural_util; 		use natural_util;
with feasibility_test.feasibility_interval; use feasibility_test.feasibility_interval;


with integer_util; use integer_util;

use Resources.Resource_Accesses;
with float_util; use float_util;

with Ada.Characters.Latin_1;
use Ada.Characters;
with Ada.Text_IO;  use Ada.Text_IO;
with GNAT.String_Split; use GNAT;
with MILS_Security; use MILS_Security;

with Random_Tools; 	use Random_Tools;
with Memories; use Memories;
with Objective_Functions_and_Feasibility_Checks_mils; use Objective_Functions_and_Feasibility_Checks_mils;
with security_implementation_old; use security_implementation_old;
package body Chromosome_Data_Manipulation_mils is

   --------------
   -- init_T2P --
   --------------
   
   procedure init_T2P
   is
      F         : Ada.Text_IO.File_Type;
      gene_i    : unbounded_String;
      gene_task_i    : unbounded_String;
      gene_com_i    : unbounded_String;
      chrom_str : unbounded_String;
      --  Subs is populated by the actual substrings.
      Subs      : String_Split.Slice_Set;
      --  just an arbitrary simple set of whitespace.
      Seps : constant String := " " & Latin_1.HT;
      j, k, m,l, itr, part, full  : Integer;
      My_iterator: Tasks_Dependencies_Iterator;
      Dep_Ptr: Dependency_Ptr;
      My_dependencies: Tasks_Dependencies_Ptr;
      A_task_i :  Generic_Task_Ptr; 
      Sys1,Sys2, Sys3, Sys4, Sys5, Sys6, Sys7  : System;
  --    app_limit,num_app: Integer;
   begin

      if Using_preprocessed_initial_sol then
         -- Initialize the current solution c with the preprocessed
         -- initial solution

         -- 1/ get the chromosome of the preprocessed initial solution
         -- from the file chrom_preprocessed_initial_solution.txt
         Open (File => F,
               Mode => Ada.Text_IO.In_File,
               Name => "chrom_preprocessed_initial_solution.txt");

         loop
            exit when Ada.Text_IO.End_Of_File (F);
            Ada.Strings.Unbounded.Append (chrom_str, To_Unbounded_String(Get_Line (File => F)));
         end loop;
         close (F);
         Put_Debug ("chrom_str: " & To_string (chrom_str));
         -- 2/ extract gene values from chrom_str to initialize the
         -- initial current solution
         -- The following code is inspired from:
         -- http://wiki.ada-dk.org/gnat.string_split_basic_usage_example
         String_Split.Create (S        => Subs,
                              From            => To_String(chrom_str),
                              Separators      => Seps,
                              Mode            => String_Split.Multiple);
         for i in 1 .. genes loop
            c.chrom_task (i) := Integer'Value(String_Split.Slice (Subs, String_Split.Slice_Number(i+1)));
         end loop;
         Put ("The initial preprocessed solution: ");
         print_genome(c);

      else
         for n in 1..15 loop
            nb_secu_conf_choice(n):=0;
         end loop;

         
      
         nb_InitSol:=0;
         nb_NoFeasible_Sol := 0;
        
         --sol_init2: split equally the tasks into nb_partitions--
         full:=genes;
         l:=1;
         m:=0;
         itr:=0;
         for i in 0..nb_partitions-1 loop
            part:= full/(nb_partitions-i);
            full:= full-part;
            for m in itr+1 .. itr+part loop
               sol_init2.chrom_task(m):=l;
            end loop;
            l:=l+1;
            itr:=itr+part;
            
         end loop;
         
         
         for i in 1 .. genes loop

            c.chrom_task(i) := 1;    --All the tasks in the same partition
            sol_init1.chrom_task(i) := 1;  --All the tasks in the same partition
 
            A_task_i := Search_Task (Initial_System.Tasks, Suppress_Space (i'Img)) ;

            -- all tasks with the same confidentiality level should be put in the same partition
            if(A_task_i.mils_confidentiality_level= Top_Secret) then
               sol_init3.chrom_task(i):= 1;
               sol_init4.chrom_task(i):= 1;
            elsif (A_task_i.mils_confidentiality_level= Secret) then
               sol_init3.chrom_task(i):= 2;
               sol_init4.chrom_task(i):= 2;
            elsif (A_task_i.mils_confidentiality_level= Classified)then
               sol_init3.chrom_task(i):= 3;
               sol_init4.chrom_task(i):= 3;
            else
               sol_init3.chrom_task(i):= 4;
               sol_init4.chrom_task(i):= 4;
            end if;
            
            -- all tasks with the same integrity level should be put in the same partition
            
            if(A_task_i.mils_integrity_level= High) then
               sol_init5.chrom_task(i):= 1;
               sol_init6.chrom_task(i):= 1;
            elsif (A_task_i.mils_integrity_level= Medium) then
               sol_init5.chrom_task(i):= 2;
               sol_init6.chrom_task(i):= 2;
            else
               sol_init5.chrom_task(i):= 3;
               sol_init6.chrom_task(i):= 3;
            end if;
            
   
         end loop;
         
         New_Line;
        
        
         My_dependencies:= Initial_System.Dependencies;
         if is_empty( My_dependencies.Depends) then
            Put_Debug("No dependencies");
         else 
            j:= 1;
            k:= 1;
            reset_iterator(My_dependencies.Depends, My_iterator);
            loop
               current_element(My_dependencies.Depends, Dep_Ptr, My_iterator);
               if(Dep_Ptr.type_of_dependency=precedence_dependency)then                
                  if ( (Dep_Ptr.precedence_sink.mils_confidentiality_level=UnClassified)AND
                        ((Dep_Ptr.precedence_source.mils_confidentiality_level= Secret)OR (Dep_Ptr.precedence_source.mils_confidentiality_level= Top_Secret)) )
                    OR ( (Dep_Ptr.precedence_source.mils_integrity_level= Low ) AND 
                            (( Dep_Ptr.precedence_sink.mils_integrity_level=Medium) OR ( Dep_Ptr.precedence_sink.mils_integrity_level=High)) )then
                     -- Resolve confidentiality and integrity constraints problem
                        
                     c.chrom_com(j).mode := secure;
            --         c.chrom_com(j).link := communication;
                     c.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                         
                     sol_init1.chrom_com(j).mode := secure ;
             --        sol_init1.chrom_com(j).link := communication; 
                     sol_init1.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                         
                     sol_init2.chrom_com(j).mode := emission;
                     sol_init2.chrom_com(j).link := communication; 
                     sol_init2.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                      
                     sol_init3.chrom_com(j).mode := secure;
                  --   sol_init3.chrom_com(j).link := communication;
                     sol_init3.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                      
                     sol_init4.chrom_com(j).mode := secure;
              --       sol_init4.chrom_com(j).link := communication;
                     sol_init4.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                         
                     sol_init5.chrom_com(j).mode := secure;
                --     sol_init5.chrom_com(j).link := communication;
                     sol_init5.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                         
                     sol_init6.chrom_com(j).mode := secure;
                 --    sol_init6.chrom_com(j).link := communication;
                     sol_init6.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                         
                  else 
                     if(Dep_Ptr.precedence_sink.mils_confidentiality_level< Dep_Ptr.precedence_source.mils_confidentiality_level)
                       OR (Dep_Ptr.precedence_source.mils_integrity_level< Dep_Ptr.precedence_sink.mils_integrity_level)then
                        -- resolve all security problems              
                        k := k+1;
                    
                       c.chrom_com(j).mode := secure;
                    --    c.chrom_com(j).link := communication;
                        c.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                    
                        sol_init4.chrom_com(j).mode := secure;
                     --   sol_init4.chrom_com(j).link := communication;
                        sol_init4.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                    
                        sol_init6.chrom_com(j).mode := secure;
                  --      sol_init6.chrom_com(j).link := communication;
                        sol_init6.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                    
                     else 
                        c.chrom_com(j).mode := nosecure;
                    --    c.chrom_com(j).link := noDW;
                        c.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                                     
                        sol_init4.chrom_com(j).mode := nosecure;
                   --     sol_init4.chrom_com(j).link := noDW;
                        sol_init4.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                    
                        sol_init6.chrom_com(j).mode := nosecure;
                    --    sol_init6.chrom_com(j).link := noDW;
                        sol_init6.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                    
                        
                     end if;
                     
                     sol_init1.chrom_com(j).mode := nosecure;
                 --    sol_init1.chrom_com(j).link := noDW; 
                     sol_init1.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                         
                     sol_init2.chrom_com(j).mode := nosecure;
                --     sol_init2.chrom_com(j).link := noDW; 
                     sol_init2.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                     
                     sol_init3.chrom_com(j).mode := nosecure;
                 --    sol_init3.chrom_com(j).link := noDW; 
                     sol_init3.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                         
                     sol_init5.chrom_com(j).mode := nosecure;
                   --  sol_init5.chrom_com(j).link := noDW; 
                     sol_init5.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
                         
                  end if;
                  j := j+1;
               end if;
               exit when is_last_element (My_Dependencies.Depends, My_Iterator);
               next_element (My_Dependencies.Depends, My_Iterator);
            end loop;

            
         end if;
      end if;
      normalize(sol_init3);
      normalize(sol_init4);
      normalize(sol_init5);
      normalize(sol_init6);
      Put_Debug("===============c================");
      print_genome(c);
      Put_Debug("===============sol_init1================");
      print_genome(sol_init1);
      Put_Debug("===============sol_init2================");
      print_genome(sol_init2);
      Put_Debug("===============sol_init3================");
      print_genome(sol_init3);
      Put_Debug("===============sol_init4================");
      print_genome(sol_init4);
      Put_Debug("===============sol_init5================");
      print_genome(sol_init5);
      Put_Debug("===============sol_init6================");
      print_genome(sol_init6);
      
      If Check_Feasibility_of_A_Solution (sol_init1, 0)  then
         Put_Line("===============sol_init1 evaluation ================");
      
         Objective_Functions_and_Feasibility_Checks_mils.evaluate_T2P (sol_init1, 0);
         archive_soln(sol_init1);
         update_grid(sol_init1);
         Append (Data3, " 0" & "              " & sol_init1.obj(1)'img &"              " &sol_init1.obj(2)'img &"              " & sol_init1.obj(3)'img &"              " & sol_init1.security_config'img &"              "& ASCII.LF);
         Put_Debug ("sol1" & "              " & sol_init1.obj(1)'img &"              " &sol_init1.obj(2)'img &"              " & sol_init1.obj(3)'img &"              "& ASCII.LF);
         Put_Line ("sol1" & "              " & sol_init1.obj(1)'img &"              " &sol_init1.obj(2)'img &"              " & sol_init1.obj(3)'img &"              "& ASCII.LF);

         nb_InitSol:=nb_InitSol+1;
         
         Create_system (Sys1, sol_init1);
         Transform_Chromosome_To_CheddarADL_Model(Sys1 ,sol_init1);

         Write_To_Xml_File (A_System  => Sys1,
                            File_Name => To_string (Suppress_Space (To_Unbounded_String ("sol_init1" & ".xmlv3"))));
         Put_Debug("=============== end sol_init1 evaluation ================");
      end if;
      --Just for version 3-------
            
      --        If Check_Feasibility_of_A_Solution (sol_init2, 0)  then
      --           Put_Line("===============sol_init2 evaluation ================");
      --           Put_Debug("===============sol_init2 evaluation ================");
      --           evaluate_T2P (sol_init2, 0);        
      --           archive_soln(sol_init2);
      --           update_grid(sol_init2);
      --           Append (Data3, " 0" & "              " & sol_init2.obj(1)'img &"              " &sol_init2.obj(2)'img &"              " & sol_init2.obj(3)'img &"              "& sol_init2.security_config'img &"              "&ASCII.LF);
      --           Put_Debug ("sol2" & "              " & sol_init2.obj(1)'img &"              " &sol_init2.obj(2)'img &"              " & sol_init2.obj(3)'img &"              "& ASCII.LF);
      --  
      --           nb_InitSol:=nb_InitSol+1;
      --           
      --           Create_system (Sys2, sol_init2);
      --           Transform_Chromosome_To_CheddarADL_Model(Sys2 ,sol_init2);
      --           Write_To_Xml_File (A_System  => Sys2,
      --                              File_Name => To_string (Suppress_Space (To_Unbounded_String ("sol_init2" & ".xmlv3")))); 
      --   
      --        end if;
      --        
      --        If Check_Feasibility_of_A_Solution (sol_init3, 0)  then
      --           Put_Debug("===============sol_init3 evaluation ================");
      --           evaluate_T2P (sol_init3, 0);        
      --           archive_soln(sol_init3);
      --           update_grid(sol_init3);
      --           Append (Data3, " 0" & "              " & sol_init3.obj(1)'img &"              " &sol_init3.obj(2)'img &"              " & sol_init3.obj(3)'img &"              "&sol_init3.security_config'img &"              "& ASCII.LF);
      --           Put_Debug ("sol3" & "              " & sol_init3.obj(1)'img &"              " &sol_init3.obj(2)'img &"              " & sol_init3.obj(3)'img &"              "& ASCII.LF);
      --           nb_InitSol:=nb_InitSol+1;
      --           
      --           Create_system (Sys3, sol_init3);
      --           Transform_Chromosome_To_CheddarADL_Model(Sys3 ,sol_init3);
      --           Write_To_Xml_File (A_System  => Sys3,
      --                              File_Name => To_string (Suppress_Space (To_Unbounded_String ("sol_init3" & ".xmlv3"))));
      --  
      --           
      --        end if;
      --        
      --        If Check_Feasibility_of_A_Solution (sol_init4, 0)  then
      --           Put_Debug("===============sol_init4 evaluation ================");
      --           evaluate_T2P (sol_init4, 0);  
      --           archive_soln(sol_init4);
      --           update_grid(sol_init4);
      --           Append (Data3, " 0" & "              " & sol_init4.obj(1)'img &"              " &sol_init4.obj(2)'img &"              " & sol_init4.obj(3)'img &"              "& sol_init4.security_config'img &"              "& ASCII.LF);
      --           Put_Debug ("sol4" & "              " & sol_init4.obj(1)'img &"              " &sol_init4.obj(2)'img &"              " & sol_init4.obj(3)'img &"              "& ASCII.LF);
      --  
      --           nb_InitSol:=nb_InitSol+1;
      --           
      --           Create_system (Sys4, sol_init4);
      --           Transform_Chromosome_To_CheddarADL_Model(Sys4 ,sol_init4);
      --           Write_To_Xml_File (A_System  => Sys4,
      --                              File_Name => To_string (Suppress_Space (To_Unbounded_String ("sol_init4" & ".xmlv3"))));
      --  
      --           
      --        end if;
      --        
      --        If Check_Feasibility_of_A_Solution (sol_init5, 0)  then
      --           Put_Debug("===============sol_init5 evaluation ================");
      --           evaluate_T2P (sol_init5, 0);        
      --           archive_soln(sol_init5);
      --           update_grid(sol_init5);
      --           Append (Data3, " 0" & "              " & sol_init5.obj(1)'img &"              " &sol_init5.obj(2)'img &"              " & sol_init5.obj(3)'img &"              "& sol_init5.security_config'img &"              "&ASCII.LF);   
      --           Put_Debug ("sol5" & "              " & sol_init5.obj(1)'img &"              " &sol_init5.obj(2)'img &"              " & sol_init5.obj(3)'img &"              "& ASCII.LF);   
      --  
      --           nb_InitSol:=nb_InitSol+1;
      --           
      --           Create_system (Sys5, sol_init5);
      --           Transform_Chromosome_To_CheddarADL_Model(Sys5 ,sol_init5);
      --           Write_To_Xml_File (A_System  => Sys5,
      --                              File_Name => To_string (Suppress_Space (To_Unbounded_String ("sol_init5" & ".xmlv3"))));
      --  
      --           
      --           
      --        end if;
      --        If Check_Feasibility_of_A_Solution (sol_init6, 0)  then
      --           Put_Debug("===============sol_init6 evaluation ================");
      --           evaluate_T2P (sol_init6, 0);        
      --           archive_soln(sol_init6);
      --           update_grid(sol_init6);
      --           Append (Data3, " 0" & "              " & sol_init6.obj(1)'img &"              " &sol_init6.obj(2)'img &"              " & sol_init6.obj(3)'img &"              "& sol_init6.security_config'img &"              "& ASCII.LF);
      --           Put_Debug ("sol6" & "              " & sol_init6.obj(1)'img &"              " &sol_init6.obj(2)'img &"              " & sol_init6.obj(3)'img &"              "& ASCII.LF);
      --  
      --           nb_InitSol:=nb_InitSol+1;
      --           
      --           Create_system (Sys6, sol_init6);
      --           Transform_Chromosome_To_CheddarADL_Model(Sys6 ,sol_init6);
      --           Write_To_Xml_File (A_System  => Sys6,
      --                              File_Name => To_string (Suppress_Space (To_Unbounded_String ("sol_init6" & ".xmlv3"))));
      --  
      --        end if;
      --        
      
      --     If Check_Feasibility_of_A_Solution (One_to_one_mapping_solution, 0) then
      If Check_Feasibility_of_A_Solution (c, 0) then
         evaluate_T2P (c, 0);

         Put_Debug("===============c evaluation finish================");
         
         if (Float'Value(c.obj(1)'img)=0.0) and (Float'Value(c.obj(2)'img)=0.0) and (Float'Value(c.obj(3)'img)=0.0) then
            Put_debug("MissedDeadlines" & c.obj(1)'img &"          Bell    " & c.obj(2)'img  &"          Biba    " & c.obj(2)'img );
            Put_Debug("Simple design: no need for optimization");
           
            archive_soln(c);
            Create_system (Sys7, c);
            Transform_Chromosome_To_CheddarADL_Model(Sys7 ,c);
            Write_To_Xml_File (A_System  => Sys7,
                               File_Name => To_string (Suppress_Space (To_Unbounded_String ("c" & ".xmlv3"))));

            OS_Exit(0);
         else
            archive_soln(c);
            update_grid(c);
            Append (Data3, " 0" & "              " & c.obj(1)'img &"              " &c.obj(2)'img &"              " & c.obj(3)'img &"              "& c.security_config'img &"              "& ASCII.LF);
            nb_InitSol:=nb_InitSol+1;
            
            Create_system (Sys7, c);
            Transform_Chromosome_To_CheddarADL_Model(Sys7 ,c);
            Write_To_Xml_File (A_System  => Sys7,
                               File_Name => To_string (Suppress_Space (To_Unbounded_String ("c" & ".xmlv3"))));

            
         end if;
      else  -- if c (that is supposed to be the first current solution) is non feasible
         if arclength>0 then -- if the archive is not empty
            c:=arc(1); --the first element of the archive becomes the first current solution
         else
            Put_Debug("All the initial solutions are non feasible");
            return;
         end if;
         
      end if;
      
   end init_T2P;

   ----------------
   -- mutate_T2P --
   ----------------

   procedure mutate_T2P (s : in out solution; eidx : in Natural) is

      random_partition, random_app, tn, x, half_iter, cn, finish,sol_config : integer;
      --      random_proc: integer;
      --      DW_link: integer;
      l:integer:=0;
      A_system : System;
      A_Task_set, New_Task_set : Tasks_Set;
      --      Nb_partitions : integer;
      --      period_fn, period_j : natural;

      --      harmonic_tasks : chrom_type;
      counter : integer;
      --      is_harmonic, exist : boolean;

      Sol_is_mutated : boolean;

      A_sol : solution;
      --    Nb_harmonic_tasks : integer;


      G : Ada.Numerics.Float_Random.Generator;
      New_resource_set : Resources_Set;
      
      A_task_source :  Generic_Task_Ptr; 
      A_task_sink :  Generic_Task_Ptr;
      
      
   begin

      Create_system (A_system, s);
      sol_is_mutated := false;
      reset(G); -- Initialise the float generator
      half_iter:=iterations/2;
      --    half_iter:=3*iterations/4;
      Put_Line("half_iter: " & half_iter'Img);
      --   genes_init := genes;

      -- I think, we should add a counter, if this counter reach a threashold
      -- and it failed to generate a mutated solution then we stop

      counter := 1;
      --        Put_Line("task to app");
      --          New_Line;
      --        for i in 1..genes loop
      --           Put (task_to_app(i)'Img & " ");
      --        end loop;
      --        New_Line;
      while (not sol_is_mutated) and (counter <= 100000) loop

         Put_Debug ("................................................................");
         Put_Debug ("The " & counter'img & " attempt of the mutation procedure ");
         Put_Debug ("................................................................");
         
         Put_Debug ("................................................................");
         Put_Debug ("The " & counter'img & " attempt of the mutation procedure ");
         Put_Debug ("................................................................");

         A_sol := s;
    
         Put_Debug ("The randomly chosen version is : " &  A_sol.exploration_version'img);
         Put_Line ("The randomly chosen version is : " &  A_sol.exploration_version'img);
         
         random_partition := 0;
         -- generate a random number of partition comprised between 1 and nb_partitions
         --         reset(G); -- Initialise the float generator
         while (random_partition > nb_partitions) OR (random_partition < 1) loop
            random_partition := integer (float(nb_partitions) * random(G));
         end loop;
         Put_Debug ("The randomly chosen partition is : " & random_partition'img);
         Put_Line ("The randomly chosen partition is : " & random_partition'img);
         Put_Line("iterrrrrrrrrrr :" & iter'Img);
         If ( A_sol.exploration_version=1) OR (( A_sol.exploration_version=2) AND (iter<half_iter)) then
            random_app:=0;
            while (random_app > nb_app) OR (random_app < 1) loop
               random_app := integer (float(nb_app) * random(G));
            end loop;
            Put_Debug ("The randomly chosen application is : " & random_app'img);
            Put_Line ("The randomly chosen application is : " & random_app'img);
            
            for l in 1..genes loop
               --               if (task_to_app(l)=random_app) and (A_sol.chrom_task(l)/=random_partition) then
               if (task_to_app(l)=random_app) then
                  A_sol.chrom_task(l):=random_partition;
               end if;
               sol_is_mutated := true; 
            end loop;           
         elsif (A_sol.exploration_version=3) OR ((A_sol.exploration_version=2) AND (iter>=half_iter)) then
            -- exploration_version=1:  Tasks of an application can be on different partitions (tasks mutation)
        
            --  choose randomly an index of a task between 1 and genes
            tn := 0;
            while (tn > genes) or (tn < 1) loop
               tn := integer (float(genes) * random(G));
            end loop;
                 
            Put_Debug ("The randomly chosen task is : " & tn'img);
            --           Put_Line ("The randomly chosen task is : " & tn'img);
            --      the task "tn" is not intially in the partition "random_partition" then "tn" is moved
            -- to the partition "random_partition"
            if (random_partition /= A_sol.chrom_task(tn)) then
               A_sol.chrom_task(tn) := random_partition;
               sol_is_mutated := true; 
               --           elsif not (is_isolated (tn, A_sol)) then
               --              --    if coincidentally the task "tn" is initially in the task "random_partition"
               --              -- then if the task "tn" is not initially isolated, we create a new partition
               --              -- in which we isolate it
               --              A_sol.chrom_task(tn) := Nb_partitions + 1;
               --              sol_is_mutated := true;
            end if;
             
         end if;
         --- We are using one processor unit
         -- then we assigned all the partitions to that single processor unit
         --         for i in 1..nb_partitions loop
         --         for i in 1..Number_of_partitions(A_sol) loop
         -- Assign all the tasks to the same core
         --           for i in 1..genes loop
         --             A_sol.chrom_task_core(i):=1;
         --           end loop;
         --           
         --Assign all the partitions to the same core
         --           for i in 1..nb_partitions+1 loop
         --              A_solution.chrom_partition_PU(i) := 1;
         --           end loop;
         --           
         --  choose randomly the configuration to secure communications
         sol_config:=0;
         reset(G); -- Initialise the float generator
         while (sol_config > 15) or (sol_config  < 1) loop
            sol_config := integer (15.0 * random(G));
         end loop;
         A_sol.security_config:=sol_config;
          
         Put_Debug ("The chosen configuration is : " & sol_config'img);
         Put ("The chosen configuration is : " & sol_config'img);
        
                     
         -- communication mutation  
         -- choose randomly an index of a task between 1 and genes_com between risky communications
         
         x:=0;
         while (x > Nb_NonSecure_low) or (x < 1) loop
            x := Integer(float(Nb_NonSecure_low) * random(G));
         end loop;
         cn := NonSecure_list(x);
         
        
         Put_Debug ("The randomly chosen communication is : " & cn'img);
         --         Put_Line ("The randomly chosen communication is : " & cn'img);
         Put_Debug ("This chosen communication is : " & To_String(s.chrom_com(cn).source_sink));
         --        Put_Line ("This chosen communication is : " & To_String(s.chrom_com(cn).source_sink));
         finish := index(A_sol.chrom_com(cn).source_sink,"_");
         
         A_task_source := Search_Task (Initial_System.Tasks, Suppress_Space (Unbounded_Slice(s.chrom_com(cn).source_sink,1,finish-1))) ;
         A_task_sink := Search_Task (Initial_System.Tasks, Suppress_Space (Unbounded_Slice(s.chrom_com(cn).source_sink,finish+1,Length(s.chrom_com(cn).source_sink))));
                 
         if  (A_task_sink.mils_confidentiality_level< A_task_source.mils_confidentiality_level) 
           OR (A_task_source.mils_integrity_level< A_task_sink.mils_integrity_level)then
            if ((A_task_sink.mils_task/=Downgrader) AND (A_task_sink.mils_task/=Upgrader)AND
                  (A_task_source.mils_task/=Downgrader)AND (A_task_source.mils_task/=Upgrader)) then
               if (A_sol.chrom_com(cn).mode = nosecure) then
                  
                  A_sol.chrom_com(cn).mode := secure; -- DW at emission (we suppose that a DW should always be at the emission) 
              
                  -- DW linked to the communication 
             --     A_sol.chrom_com(cn).link := communication;
                 
                  sol_is_mutated := true; 
               
                  --               elsif (A_sol.chrom_com(cn).mode = emission) or (A_sol.chrom_com(cn).mode = reception) then
               elsif ( A_sol.chrom_com(cn).mode = secure) then
                  A_sol.chrom_com(cn).mode := nosecure;
                 -- A_sol.chrom_com(cn).link := noDW;
                  sol_is_mutated := true;
               end if;
            end if;
         end if;
                 
                      
         --  
         --       elsif (not is_isolated (tn, A_sol)) then
         --                 -- if coincidentally the task "tn" is intially in the task "random_task"
         --                 -- then if the task "tn" is not initially isolated, we create a new task
         --                 -- in which we isolate it
         --                 -- else i.e the function "fn" is alone then we repeat the procedure with another function
         --                 -- chosen randomly
         --                 A_sol.chrom(fn) := nb_tasks + 1;
         --                 sol_is_mutated := true;
         --              end if;
         --  
         --           end if;

         if sol_is_mutated then

            Put_Debug(" ");
            Put_Debug ("The mutated solution is : ");
            print_debug_genome(A_sol);
            Put_Debug(" ");
            -- normalize the mutate solution
            normalize(A_sol);
            Put_Debug(" ");
            Put_Debug ("After normalization the candidate solution is : ");
            Put_Line("After normalization the candidate solution is : ");
            print_debug_genome(A_sol);
            Put_Debug(" ");

            -- After generating a mutate solution, we shoud verify
            -- if it is feasible else we must regenerate a new candidate solution:
            --

            If Check_Feasibility_of_A_Solution (A_sol,eidx) then
               
               Put_Debug (" The candidate solution is feasible");

               --              New_nb_tasks := Number_of_tasks (A_sol);

               sol_is_mutated := true;
               s := A_sol;
               nb_secu_conf_choice(sol_config):=nb_secu_conf_choice(sol_config)+1;
            else
              
               Put_Debug (" The candidate solution is NOt Feasible " &
                            " we should regenerate another candidate solution");
               sol_is_mutated := false;
               counter := counter + 1;
               nb_NoFeasible_Sol := nb_NoFeasible_Sol+1;
               
               --         genes := genes_init;
            end if;

         end if;

      end loop;

      if counter > 100000 then
         Put_Debug(" ");--New_Line;
         Put_Debug(" ");--New_Line;
         Put_Debug("Exit the program, there is no schedulable candidate solution !");
         Put_Debug(" ");--New_Line;
         Put_Debug(" ");--New_Line;
         OS_Exit (0);
      end if;
     
        
   end mutate_T2P;
   
   
   
   
   procedure generate_next_element_T2P
     (s                         : in out solution;
      i, j                         : in out Integer)
   is 
   begin
      if (i<=genes) then
         if ( s.chrom_task(i) = 0) then
            s.chrom_task(i) := 1;
         else
            s.chrom_task(i):= s.chrom_task(i)+1;
            --              if (s.chrom_task(i) > i)  then
            --                 s.chrom_task(i) := 0;              
            --              end if;
         end if;
      end if;
 
      if j<=Nb_NonSecure_low then
       
         s.chrom_com(NonSecure_list(j)).mode:= emission;
         if (s.chrom_com(NonSecure_list(j)).mode= undefined) then
        -- if (s.chrom_com(NonSecure_list(j)).link= undefined) then
        --     s.chrom_com(NonSecure_list(j)).link:= noDW;
            s.chrom_com(NonSecure_list(j)).mode:= nosecure;
            
            --           elsif (s.chrom_com(NonSecure_list(j)).link= noDW) then
            --              s.chrom_com(NonSecure_list(j)).link:= tsk;
            --              
            --           elsif(s.chrom_com(NonSecure_list(j)).link= tsk) then
            --              s.chrom_com(NonSecure_list(j)).link:= communication;

         elsif (s.chrom_com(NonSecure_list(j)).mode= nosecure) then
             s.chrom_com(NonSecure_list(j)).mode:= secure;
            
         elsif(s.chrom_com(NonSecure_list(j)).mode= secure) then
           s.chrom_com(NonSecure_list(j)).mode:= nosecure;
            
         elsif(s.chrom_com(NonSecure_list(j)).mode= nosecure) then
            s.chrom_com(NonSecure_list(j)).link:= undefined;
         end if;
      
      end if;
                
   end generate_next_element_T2P;
   

   --------------------------------
   -- generate_next_solution_T2P --
   --------------------------------

   procedure generate_next_solution_T2P
     (s                         : in out solution;
      --      m                         : in out chrom_task_type;
      --    n                         : in out chrom_com_type;
      space_search_is_exhausted : out boolean)
   is

      i,j,k : integer;
      g : solution;
      non: boolean:= True;
   begin

      i := 1;
      j := 1;
      k:=1;
      
      space_search_is_exhausted := False;
      while (space_search_is_exhausted = False) loop

         generate_next_element_T2P(s,i,j);
         if (s.chrom_task(i) <= nb_partitions) AND (i<genes) then
            i := i+1;
            --    j := j+1;
         elsif (s.chrom_task(i) <= nb_partitions) AND (i=genes) then
            --              for k in 1..genes loop
            --                 if s.chrom_task(k) > k then
            --                    non := False;
            --                 end if;
            --              end loop;
            --              if  non = True then
            nb_sol_Exhaus := nb_sol_Exhaus+1;
            --               Put_Line("non normalized");
            print_genome(s);
            g:=s;
            -- Put_Line(" normalized");
            -- normalize(g);
            -- print_genome(g);
            --          end if;
            --evaluer
         elsif (s.chrom_task(i) > nb_partitions)  AND (i>1) then
            s.chrom_task(i):=0;
            i := i-1;
            --       j:= j-1;
         elsif (s.chrom_task(i) > nb_partitions) AND (i=1) then
            space_search_is_exhausted := True;
         end if;
               
      end loop;
          

   end generate_next_solution_T2P;

  

   ---------------
   -- Normalize --
   ---------------


   procedure normalize(s : in out solution)
   is
      
      nb_partitions : integer := 1;
      --   nb_proc: Integer:=1;
      --  the vector var is used to know if a gene is normalized or not yet
      var : chrom_Type;
   begin
      --  initialization of the vector var.
      for i in 1..genes loop
         var(i) := 0;
         --         var2(i) :=0;
      end loop;

      ------------------------------------------------------------
      --  if var(i) = 0   ==>  s.chrom(i) is not yet normalized
      --  if var(i) = 1   ==>  s.chrom(i) is normalized
      ------------------------------------------------------------

      for i in 1..genes loop

         if (var(i) = 0) then

            for j in i+1..genes loop
               if (s.chrom_task(j) = s.chrom_task(i)) and then (var(j) = 0) then
                  var(j) := 1;
                  --  if s.chrom(i) is not normalized then all s.chrom(j) (which egal s.all.chrom(i))
                  --  are not normalized
                  if (s.chrom_task(i) /= nb_partitions) then
                     s.chrom_task(j) := nb_partitions;
                  end if;
               end if;
            end loop;

            -- we normalize s.chrom(i)
            if (s.chrom_task(i) /= nb_partitions) then
               s.chrom_task(i) := nb_partitions;
            end if;
            var(i) := 1;
            nb_partitions := nb_partitions + 1;
         end if;
      end loop;
        
   end normalize;



   ---------------------
   -- Number_of_partitions --
   ---------------------

   function Number_of_partitions (s : in solution) return integer is
      permutation : integer := 1;
      var : chrom_type;
      nb_partitions, tmp : integer;
   begin
      --  assignment of the table var with elements of s.chrom
      for i in 1..genes loop
         var(i) := s.chrom_task(i);
      end loop;

      --  sorting elements of var in the increasing order
      while permutation = 1 loop
         permutation := 0;
         for i in 1..genes-1 loop
            if (var(i) > var(i+1)) then
               tmp := var(i);
               var(i) := var(i+1);
               var(i+1) := tmp;
               permutation := 1;
            end if;
         end loop;
      end loop;

      nb_partitions := genes;

      for i in 1..genes-1 loop
         if (var(i) = var(i+1)) then
            nb_partitions := nb_partitions - 1;
         end if;
      end loop;

      return nb_partitions;

   end Number_of_partitions;

   --     function Number_of_processors (s : in solution) return integer is
   --        permutation : integer := 1;
   --        var : chrom_type;
   --        nb_processors, tmp : integer;
   --        nb_partitions: Integer;
   --     begin
   --        nb_partitions:=Number_of_partitions(s);
   --        --  assignment of the table var with elements of s.chrom
   --        for i in 1..nb_partitions loop
   --           var(i) := s.chrom_partition_PU(i);
   --        end loop;
   --        while permutation = 1 loop
   --           permutation := 0;
   --           for i in 1..nb_partitions-1 loop
   --              if (var(i) > var(i+1)) then
   --                 tmp := var(i);
   --                 var(i) := var(i+1);
   --                 var(i+1) := tmp;
   --                 permutation := 1;
   --              end if;
   --           end loop;
   --        end loop;
   --        nb_processors := nb_partitions;
   --  
   --        for i in 1..nb_partitions-1 loop
   --           if (var(i) = var(i+1)) then
   --              nb_processors := nb_processors - 1;
   --           end if;
   --        end loop;
   --  
   --        return nb_processors;
   --        
   --     end Number_of_processors;
   ----------------------------------------------
   -- Transform_Chromosome_To_CheddarADL_Model --
   ----------------------------------------------

   procedure Transform_Chromosome_To_CheddarADL_Model (A_sys : in out System; s : in solution) is
      
      A_Tasks_set                        : Tasks_Set;
      A_Task                	 	: Periodic_Task;
      
      k   	: integer;
      --      A_function_index : integer;
      period_i                  	 	: natural;
      capacity_i	                	: natural;
      deadline_i  	                	: natural;
      priority_i  	                	: natural;
      criticality_i                             : natural;
      confidentiality_i, integrity_i                      : Unbounded_String;
     
   begin

          
      
      -- 1) Generate the tasks set from the solution s
      --
      --     nb_tasks := number_of_tasks(s);
       
      Initialize (A_sys.Tasks);
      Initialize(A_sys.Dependencies.Depends);
      for i in 1..genes loop
         k := s.chrom_task(i); 
         --         l:= s.chrom_partition_PU(k);
         period_i   := Get(My_Tasks   => Initial_system.Tasks,
                           Task_Name  => Suppress_Space (To_Unbounded_String ("" & i'Img)),
                           Param_Name => Period);

         capacity_i := Get(My_Tasks   => Initial_system.Tasks,
                           Task_Name  => Suppress_Space (To_Unbounded_String ("" & i'Img)),
                           Param_Name => Capacity);
         deadline_i := Get(My_Tasks   => Initial_system.Tasks,
                           Task_Name  => Suppress_Space (To_Unbounded_String ("" & i'Img)),
                           Param_Name => Deadline);
         priority_i:= Get(My_Tasks   => Initial_system.Tasks,
                          Task_Name  => Suppress_Space (To_Unbounded_String ("" & i'Img)),
                          Param_Name => Priority);
         criticality_i:= Get(My_Tasks   => Initial_system.Tasks,
                             Task_Name  => Suppress_Space (To_Unbounded_String ("" & i'Img)),
                             Param_Name => Criticality);
         confidentiality_i := Get(My_Tasks   => Initial_system.Tasks,
                                  Task_Name  => Suppress_Space (To_Unbounded_String ("" & i'Img)),
                                  Param_Name => mils_confidentiality_level);
         integrity_i       := Get(My_Tasks   => Initial_system.Tasks,
                                  Task_Name  => Suppress_Space (To_Unbounded_String ("" & i'Img)),
                                  Param_Name => mils_integrity_level);
         Add_Task(My_Tasks                => A_sys.Tasks,
                  Name                    => Suppress_Space (To_Unbounded_String ("" & i'Img)),
                  Cpu_Name                => Suppress_Space (To_Unbounded_String("processor1")),
                  Address_Space_Name      => Suppress_Space (To_Unbounded_String ("addr" & k'Img)),
                  core_name               => Suppress_Space (To_Unbounded_String("")),
                  Task_Type               => Periodic_Type,
                  Start_Time              => 0,
                  Capacity                => capacity_i,
                  Period                  => period_i,
                  Deadline                => deadline_i,
                  Jitter                  => 0,
                  Blocking_Time           => 0,
                  Priority                => priority_i,
                  Criticality             => criticality_i,
                  Policy                  => Sched_policy,
                  mils_confidentiality_level => MILS_Confidentiality_Level_Type'value( To_String(confidentiality_i)),
                  mils_integrity_level => MILS_Integrity_Level_Type'value( To_String(integrity_i))
                 );
         
         New_Line;
        

      end loop;
      

      
      
      -- 2) Generate the dependencies and secure the system depending on the choosen security configuration
      --
      nb_bell_resolved:=0;
      nb_biba_resolved:=0;
      if (s.security_config = 1)then
         security_configuration1(A_sys, s); 
      elsif (s.security_config = 2)then
         security_configuration2(A_sys, s); 
      elsif (s.security_config = 3)then
         security_configuration3(A_sys, s);
      elsif (s.security_config = 4)then
         security_configuration4(A_sys, s);
      elsif (s.security_config =5)then
         security_configuration5(A_sys, s);
      elsif (s.security_config = 6)then
         security_configuration6(A_sys, s); 
      elsif (s.security_config = 7)then
         security_configuration7(A_sys, s);
      elsif (s.security_config = 8)then
         security_configuration8(A_sys, s);
      elsif (s.security_config =9)then
         security_configuration9(A_sys, s);
      elsif (s.security_config = 10)then
         security_configuration10(A_sys, s);
      elsif (s.security_config =11)then
         security_configuration11(A_sys, s);
      elsif (s.security_config = 12)then
         security_configuration12(A_sys, s); 
      elsif (s.security_config = 13)then
         security_configuration13(A_sys, s);
      elsif (s.security_config = 14)then
         security_configuration14(A_sys, s);
      elsif (s.security_config =15)then
         security_configuration15(A_sys, s);

      end if;
      
      -- consider inter and intra communications overheads
      com_overhead(A_sys);
      Put_Debug("end_transform");  
   end Transform_Chromosome_To_CheddarADL_Model;
         
   -------------------------------------------
   -- consider inter and intra partition --
   -------------------------------------------
   Procedure com_overhead(A_sys : in out System) is
      My_iterator: Tasks_Dependencies_Iterator;
      Dep_Ptr: Dependency_Ptr;
      My_dependencies: Tasks_Dependencies_Ptr;
      i: Integer;
   begin
      My_dependencies:=A_sys.Dependencies;
      if is_empty( My_dependencies.Depends) then 
         Put_Line("NO dependencies");
      else 
         reset_iterator(My_dependencies.Depends, My_iterator);
         loop
            current_element(My_dependencies.Depends, Dep_Ptr, My_iterator);
            i:= Integer'Value(To_String(Dep_Ptr.precedence_source.name));
            if (Dep_Ptr.precedence_source.address_space_name=Dep_Ptr.precedence_sink.address_space_name)then
                                 
               Dep_Ptr.precedence_source.capacity:= Dep_Ptr.precedence_source.capacity+display_blackboard_time_values(i);
               Dep_Ptr.precedence_sink.capacity:= Dep_Ptr.precedence_source.capacity+display_blackboard_time_values(i);
            else
             
               Dep_Ptr.precedence_source.capacity:=  Dep_Ptr.precedence_source.capacity+write_sampling_port_time_values(i);
               Dep_Ptr.precedence_sink.capacity:= Dep_Ptr.precedence_sink.capacity+read_sampling_port_time_values(i);
               
            end if;
            exit when is_last_element (My_Dependencies.Depends, My_Iterator);
            next_element (My_Dependencies.Depends, My_Iterator);
         end loop;
      end if;
   end com_overhead;
   
   -- communication_cost --
   -------------------
   Procedure communication_cost(sys: in system; com_cost: out com_cost_type)is 
      My_iterator: Tasks_Dependencies_Iterator;
      Dep_Ptr: Dependency_Ptr;
      My_dependencies: Tasks_Dependencies_Ptr;
      i: Integer;
   begin 
      My_dependencies:=sys.Dependencies;
      if is_empty( My_dependencies.Depends) then 
         Put_Line("NO dependencies");
      else 
         for i in 1..5 loop
            com_cost(i):=0.0;
         end loop;
         reset_iterator(My_dependencies.Depends, My_iterator);
         loop
            current_element(My_dependencies.Depends, Dep_Ptr, My_iterator); 
            i:= Integer'Value(To_String(Dep_Ptr.precedence_source.name));
            if (Dep_Ptr.precedence_source.address_space_name=Dep_Ptr.precedence_sink.address_space_name)then 
               com_cost(1):=com_cost(1)+1.0;
               com_cost(2):=com_cost(2)+1.0; 
               com_cost(5):=com_cost(5)+Float (display_blackboard_time_values(i)*(Hyperperiod_of_Initial_Taskset/Dep_Ptr.precedence_source.deadline)+read_blackboard_time_values(i)*(Hyperperiod_of_Initial_Taskset/Dep_Ptr.precedence_sink.deadline));  
            else
               com_cost(3):=com_cost(3)+1.0;
               com_cost(4):=com_cost(4)+1.0; 
               com_cost(5):=com_cost(5)+Float (write_sampling_port_time_values(i)*(Hyperperiod_of_Initial_Taskset/Dep_Ptr.precedence_source.deadline)+read_sampling_port_time_values(i)*(Hyperperiod_of_Initial_Taskset/Dep_Ptr.precedence_sink.deadline));
            end if;
            exit when is_last_element (My_Dependencies.Depends, My_Iterator);
            next_element (My_Dependencies.Depends, My_Iterator);
         end loop;
      end if;
   end communication_cost;
     
   -- Create_system --
   -------------------

   Procedure Create_system (A_system     : in out System; s     : in solution) is

      a_core : core_unit_ptr;
      a_core_unit_table : Core_Units_Table;
      mem : Memories_Table;
      partition_sched_file_name: Unbounded_String;
      nb_part: integer;
      
   begin

      Initialize(A_System);
      
     
      
      --        Put_Line("nb_proc : " & nb_proc'Img);
      --        Put_Line("nb_partitions : " & nb_partitions'Img);
      
      --     for j in 1..nb_proc loop
      -- Generate partitions
      for i in 1..Number_of_partitions(s) loop
         --    for i in 1.. nb_partitions loop
         --            if (s.chrom_partition_PU(i)=j) then
         Add_Address_Space
           (My_Address_Spaces => A_system.address_spaces,
            Name              => Suppress_Space (To_Unbounded_String ("addr" & i'Img)),
            Cpu_Name          => Suppress_Space(To_unbounded_string("processor1")),
            Text_Memory_Size  => 0,
            Stack_Memory_Size => 0,
            Data_Memory_Size  => 0,
            Heap_Memory_Size  => 0,
            A_Scheduler       => POSIX_1003_HIGHEST_PRIORITY_FIRST_PROTOCOL);
         --           end if;
      end loop;
        
      if (s.security_config<10) then
         nb_part:=Number_of_partitions(s);
      else
         nb_part:=Number_of_partitions(s)+1;
      end if;
      partition_sched_file_name:=Suppress_Space(to_unbounded_string("partition_scheduling_paes"& nb_part'Img &".xml"));
      Add_core_unit(My_core_units        => A_System.core_units,
                    A_core_unit          => a_core,
                    Name                 => Suppress_Space(to_unbounded_string("core1")),
                    Is_Preemptive        => preemptive,
                    Quantum              => 0,
                    speed                => 1,
                    capacity             => 0,
                    period               => 0,
                    Priority             => 0,
                    File_Name            => partition_sched_file_name,
                    A_Scheduler          => The_scheduler,
                    mem                  => mem);

      Add (a_core_unit_table, a_core);

      Add_Processor(My_Processors => A_System.processors,
                    Name          => Suppress_Space(to_unbounded_string("processor1")),
                    a_Core        => a_core);
      --         initialize(A_Table => a_core_unit_table);
      --           initialize(mem);
      --           initialize(a_core);

      --     end loop;
      
          
   end Create_system; 
   

end Chromosome_Data_Manipulation_mils;
