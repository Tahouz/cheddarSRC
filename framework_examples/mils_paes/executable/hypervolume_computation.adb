
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
--    $Date: 2020-07-13 11:43:48 +0200 (lun. 13 juil. 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.text_IO; use Ada.text_IO;
with Pipe_Commands; use Pipe_Commands;
with Ada.Strings.Unbounded;             use Ada.Strings.Unbounded;
with unbounded_strings;                 use unbounded_strings;
with Ada.Strings; use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; 		use Ada.Text_IO.Unbounded_IO;
with Ada.Directories; 			use Ada.Directories;
--with task_clustering_rules; use task_clustering_rules;

package body Hypervolume_computation is

   procedure Normalize_Archive_outpoints (arc : in arc_type; min1: out Float; min2: out Float; max1: out Float; max2: out Float) is

      obj1_norm, obj2_norm           : float;
      F                              : Ada.Text_IO.File_Type;
      Data,line                      : unbounded_string;

   begin

      min1 := arc(1).obj(1);
      max1 := arc(1).obj(1);
      
      min2 := arc(1).obj(2);
      max2 := arc(1).obj(2);

      for i in 2 .. arclength loop
         if arc(i).obj(1) > max1 then
            max1 := arc(i).obj(1);
         end if;

         if arc(i).obj(1) < min1 then
            min1 := arc(i).obj(1);
         end if;
		
         if arc(i).obj(2) > max2 then
            max2 := arc(i).obj(2);
         end if;

         if arc(i).obj(2) < min2 then
            min2 := arc(i).obj(2);
         end if;
      end loop;

      for i in 1 .. arclength loop
         obj1_norm := (arc(i).obj(1) - min1) / (max1 - min1);
         obj2_norm := (arc(i).obj(2) - min2) / (max2 - min2);
         Append (Data, obj1_norm'img & " " & obj2_norm'img & ASCII.LF);
      end loop;

      Create(F,Ada.Text_IO.Out_File,"Normalized_Archive_");
      Unbounded_IO.Put_Line(F, Data);
      Close(F);

   end Normalize_Archive_outpoints;
   
     procedure Normalize_Archive_with_points (arc : in arc_type; min1: in Float; min2: in Float; max1: in Float; max2: in Float) is

      obj1_norm, obj2_norm           : float;
      F                              : Ada.Text_IO.File_Type;
      Data,line                      : unbounded_string;

   begin

      for i in 1 .. arclength loop
         obj1_norm := (arc(i).obj(1) - min1) / (max1 - min1);
         obj2_norm := (arc(i).obj(2) - min2) / (max2 - min2);
         Append (Data, obj1_norm'img & " " & obj2_norm'img & ASCII.LF);
      end loop;

      Create(F,Ada.Text_IO.Out_File,"Normalized_Archive_");
      Unbounded_IO.Put_Line(F, Data);
      Close(F);

   end Normalize_Archive_with_points;

   function Call_hv return float is
        
      FileStream : stream;
      -- command    : constant string := "./../../../../../../required_packages/hypervolume/hv " 
      
        command    : constant string := "./../../../../required_packages/hypervolume/hv "
        & "-r ""1.0 1.0"""
        & " Normalized_Archive_ -s Hypervolume.txt";
      F1         : Ada.Text_IO.File_Type;
      line       : unbounded_String;
      Buffer     : unbounded_String;  
    	
   begin

      FileStream := execute(command, read_file);
      loop
         begin
            Buffer := read_next(FileStream);
         exception
            when Pipe_Commands.End_of_file => 
               exit;
         end;
      end loop;
             
      close(FileStream);

      Open(F1, Ada.Text_IO.In_File,"Normalized_Archive_Hypervolume.txt");
      line := To_Unbounded_String(get_line(F1));
      Put_Line ("The hypervolume =" & To_string(line));
      return float'Value(To_string(line));

   end Call_hv;

end Hypervolume_computation;
