
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
--    $Rev: 3477 $
--    $Date: 2020-07-13 11:43:48 +0200 (Mon, 13 Jul 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Containers.Vectors;
use Ada.Containers; use Ada.Containers;
with Ada.Directories; use Ada.Directories;
with Ada.text_IO; use Ada.text_IO;


with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with unbounded_strings;                 use unbounded_strings;
with Ada.strings; use Ada.strings;

with Chromosome_Data_Manipulation_mils; use Chromosome_Data_Manipulation_mils;
with Objective_Functions_and_Feasibility_Checks_mils;
use Objective_Functions_and_Feasibility_Checks_mils;
with Debug; use Debug;


with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;

with Paes_Utilities; use Paes_Utilities;

with Systems;               use Systems;

with sets; 

with Dependencies; 		use Dependencies;
with Task_Dependencies; 	use Task_Dependencies;
with Task_Dependencies; 	use Task_Dependencies.Half_Dep_Set;
with MILS_Security; use MILS_Security;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;

procedure Exhaustive_method_general_form_mils is

   package Solution_Container is new Vectors (Positive, solution);
   use Solution_Container;

   package Integer_Container is new Vectors (Positive, Integer);
   use Integer_Container;

   search_space_is_exhausted : boolean := false;
   search_space_is_exhausted_com : boolean := false;
   non : boolean := True;
   m                         : chrom_type;
   next_solution             : solution;

   normalized_solution       : solution;
   all_feasible_solutions    : Solution_Container.Vector;
   N_feasible_solutions      : integer := 0;

   a_table                   : Integer_container.Vector;
   Cursor1,Cursor2           : Solution_Container.Cursor;
   Cursor3                   : Integer_container.Cursor;
   k, j , i,l                 : integer;
   nb_rejectedSol        : Integer;
 --  ok                        : boolean;
  

   eidx                      : natural := 0;
   F                         : Ada.Text_IO.File_Type;

   My_iterator: Tasks_Dependencies_Iterator;
   Dep_Ptr: Dependency_Ptr;
   My_dependencies: Tasks_Dependencies_Ptr;
   
   type table is array(1..nb_partitions) of integer;
   nb : table;
   F6                    : Ada.Text_IO.File_Type;

begin
   
   Append (Data3, "iteration" & "       " & "Missed_deadline" &"               " &"bell" &"                     " & "biba" &" "& ASCII.LF);
   
   init_T2P;

   for i in 1..genes loop
      next_solution.chrom_task(i) := 0;
      m(i) := 1;
   end loop;
--      for i in 1..nb_partitions+1 loop
--        next_solution.chrom_partition_PU(i) := 1;
--     end loop;
   My_dependencies:= Initial_System.Dependencies;
   My_dependencies:= Initial_System.Dependencies;
   if is_empty( My_dependencies.Depends) then
      Put_Line("No dependencies");
   else
      j:= 1;
      reset_iterator(My_dependencies.Depends, My_iterator);
      loop
         current_element(My_dependencies.Depends, Dep_Ptr, My_iterator);
         if(Dep_Ptr.type_of_dependency=precedence_dependency)then
             if ( (Dep_Ptr.precedence_sink.mils_confidentiality_level=UnClassified)AND
              ((Dep_Ptr.precedence_source.mils_confidentiality_level= Secret)OR (Dep_Ptr.precedence_source.mils_confidentiality_level= Top_Secret)) )
              OR ( (Dep_Ptr.precedence_source.mils_integrity_level= Low ) AND 
                      (( Dep_Ptr.precedence_sink.mils_integrity_level=Medium) OR ( Dep_Ptr.precedence_sink.mils_integrity_level=High)) )then
               -- Resolve confidentiality constraints problem
               next_solution.chrom_com(j).mode := secure;
--               next_solution.chrom_com(j).link := tsk;
--                next_solution.chrom_com(j).link := communication;
               next_solution.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));

            
            else
               if(Dep_Ptr.precedence_sink.mils_confidentiality_level< Dep_Ptr.precedence_source.mils_confidentiality_level)
                 OR (Dep_Ptr.precedence_source.mils_integrity_level< Dep_Ptr.precedence_sink.mils_integrity_level)then
               
                  --                    next_solution.chrom_com(j).mode := emission;
                  --                    next_solution.chrom_com(j).link := tsk;

                  --                 next_solution.chrom_com(j).mode := emission;
                   next_solution.chrom_com(j).mode := undefined;
--                  next_solution.chrom_com(j).link := undefined;
                  next_solution.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
               else
                  --                 next_solution.chrom_com(j).mode := noDW;
                  next_solution.chrom_com(j).mode := nosecure;
   --               next_solution.chrom_com(j).link := noDW;
                  next_solution.chrom_com(j).source_sink := suppress_space(To_String(Dep_Ptr.precedence_source.name) & "_" & To_String(Dep_Ptr.precedence_sink.name));
               end if;

            end if;
            j := j+1;
         end if;
         exit when is_last_element (My_Dependencies.Depends, My_Iterator);
         next_element (My_Dependencies.Depends, My_Iterator);
      end loop;
    
   end if;
   
   -- 2) enumerate and evaluate all feasible solutions
   --
   --  loop

   --   eidx := eidx + 1;
      
   i := 1;
   j := 1;
   k:=1;
   l:=1;
   ---------------------------------------------------------------------------------------
   for i in 1..nb_partitions loop
      nb(i):=0;
   end loop;
   
   i := 1;
   j:= 1;
   nb_sol_Exhaus:=0;
    
 while(True) loop
   
      search_space_is_exhausted:= False;
      if (i>1) then
         if (next_solution.chrom_task(i) >=1) and (next_solution.chrom_task(i)<nb_partitions+1) then
            nb(next_solution.chrom_task(i)):= nb(next_solution.chrom_task(i))-1;
            if(nb(next_solution.chrom_task(i)) = 0 ) then
               next_solution.chrom_task(i) := 0; 
               i:=i-1;
               search_space_is_exhausted:= True;
            end if;
         end if;
       
      end if;
      
       
      if (search_space_is_exhausted= False) then
         
         next_solution.chrom_task(i) := next_solution.chrom_task(i) +1;
         
         if ( next_solution.chrom_task(i)>nb_partitions) then
            next_solution.chrom_task(i):= 0;
            i:=i-1;
         
         else
    
            if (next_solution.chrom_task(i)<=nb_partitions) then
               nb(next_solution.chrom_task(i)):= nb(next_solution.chrom_task(i))+1;
            end if;
                         
            --         if (A_solution.chrom_task(i)<= i) and (i<nb_partitions) then
            if (next_solution.chrom_task(i)<= i)  and (i<genes) then
               i:=i+1;
               
               --         elsif (A_solution.chrom_task(i)<= i) and (i=nb_partitions) then
               
            elsif (next_solution.chrom_task(i)<= i) and (i=genes) then           
               
               j:= 1;
               New_Line;
               
              while(search_space_is_exhausted_com=False) loop
            --      eidx := eidx + 1;                                         
                  if j<=Nb_NonSecure_low then
       
--                     next_solution.chrom_com(NonSecure_list(j)).mode:= emission;
--                     if (next_solution.chrom_com(NonSecure_list(j)).link= undefined) then
                        if (next_solution.chrom_com(NonSecure_list(j)).mode= undefined) then
 --                       next_solution.chrom_com(NonSecure_list(j)).link:= noDW;
                        next_solution.chrom_com(NonSecure_list(j)).mode:= nosecure;
            
--                       elsif (next_solution.chrom_com(NonSecure_list(j)).link= noDW) then
--                          next_solution.chrom_com(NonSecure_list(j)).link:= tsk;
--              
--                       elsif(next_solution.chrom_com(NonSecure_list(j)).link= tsk) then
--                          next_solution.chrom_com(NonSecure_list(j)).link:= communication;
                        
                     elsif (next_solution.chrom_com(NonSecure_list(j)).mode= nosecure) then
                        next_solution.chrom_com(NonSecure_list(j)).mode:= secure;
            
                     elsif(next_solution.chrom_com(NonSecure_list(j)).mode= secure) then
                        next_solution.chrom_com(NonSecure_list(j)).mode:= undefined;
  --                      next_solution.chrom_com(NonSecure_list(j)).link:= undefined;
            
                     end if;
                  end if;            
                  
                  if (next_solution.chrom_com(NonSecure_list(j)).mode/=undefined) and (j<Nb_NonSecure_low) then
                     j:=j+1;
                  elsif (next_solution.chrom_com(NonSecure_list(j)).mode/=undefined) and(j=Nb_NonSecure_low) then
                     
                     for l in 1..15 loop
                        nb_sol_Exhaus:= nb_sol_Exhaus+1; 
                        Put_Line("iteration: " & nb_sol_Exhaus'Img);
                        Put_Line("security config" & l'Img);
                        next_solution.security_config:=l;
                        print_genome(next_solution);
                        normalized_solution := next_solution;
                        normalize (normalized_solution);
                                                  
                        if Check_Feasibility (normalized_solution,eidx) then

                           evaluate (normalized_solution,eidx);
                           all_feasible_solutions.Append (normalized_solution);
                           N_feasible_solutions := N_feasible_solutions + 1;
                      
                           archive_soln(normalized_solution);
                           Append (Data3, N_feasible_solutions'img & "              " & normalized_solution.obj(1)'img &"              " &normalized_solution.obj(2)'img &"              " & normalized_solution.obj(3)'img &"              "& ASCII.LF);

                        end if;
                     end loop;
        
                  elsif(next_solution.chrom_com(NonSecure_list(j)).mode=undefined) and (j>1) then
                 --    next_solution.chrom_com(NonSecure_list(j)).mode:= noDW;
                 --    next_solution.chrom_com(NonSecure_list(j)).link:=undefined;
                     j:=j-1;
                  elsif (next_solution.chrom_com(NonSecure_list(j)).mode=undefined) and (j=1) then
                     search_space_is_exhausted_com:=True; 
                  end if;
               end loop;
               search_space_is_exhausted_com:=False; 
               
            elsif (next_solution.chrom_task(i)> i) and (i>1) then
               next_solution.chrom_task(i):= 0;
               i:=i-1;
            else 
               exit;
            end if;
         end if;
         
      end if;
         
        
     
   end loop;
   nb_rejectedSol := nb_InitSol+ N_feasible_solutions - arclength; -- solutions add in the archive during the init process + N_feasible_solutions+iterations+ arclength
   Append (Data3," " & ASCII.LF);
   Append (Data3," " & ASCII.LF);
   Append (Data3,"Number of rejected solution during the archiving process : " & nb_rejectedSol'img & ASCII.LF);
   Append (Data3,"Number of solutions generate during the exhaustive research : " & nb_sol_Exhaus'img & ASCII.LF);
   Create(F6,Ada.Text_IO.Out_File,"Exhaustive_Execution_iter.dat");
   Unbounded_IO.Put_Line(F6, Data3);
   Close(F6);
end Exhaustive_method_general_form_mils;
