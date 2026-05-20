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
with pipe_commands;            use pipe_commands;
with Ada.Strings.Unbounded;    use Ada.Strings.Unbounded;
with unbounded_strings;        use unbounded_strings;
with Ada.Strings;              use Ada.Strings;
with Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO;
with Ada.Directories;          use Ada.Directories;
with task_clustering_rules;    use task_clustering_rules;

package body paes.hypervolume_computation is

   procedure normalize_archive (arc : in arc_type) is

      obj1_norm, obj2_norm : Float;
      f                    : Ada.Text_IO.File_Type;
      data, line           : Unbounded_String;

   begin

      z1_ideal := arc (1).obj (1);
      z2_ideal := arc (1).obj (2);

      for i in 2 .. arclength loop

         if arc (i).obj (1) < z1_ideal then
            z1_ideal := arc (i).obj (1);
         end if;

         if arc (i).obj (2) < z2_ideal then
            z2_ideal := arc (i).obj (2);
         end if;
      end loop;

      for i in 1 .. arclength loop
         obj1_norm :=
           (arc (i).obj (1) - z1_ideal) / (z1_anti_ideal - z1_ideal);
         obj2_norm :=
           (arc (i).obj (2) - z2_ideal) / (z2_anti_ideal - z2_ideal);
         Append (data, obj1_norm'img & " " & obj2_norm'img & ASCII.LF);
      end loop;

      Create (f, Ada.Text_IO.Out_File, "Normalized_Archive_");
      Unbounded_IO.Put_Line (f, data);
      Close (f);

   end normalize_archive;

   function call_hv return Float is

      filestream : stream;
      command    : constant String :=
        "./../../../../../../required_packages/hypervolume/hv " &
        "-r ""1.0 1.0""" &
        " Normalized_Archive_ -s Hypervolume.txt";
      f1     : Ada.Text_IO.File_Type;
      line   : Unbounded_String;
      buffer : Unbounded_String;

   begin

      filestream := execute (command, read_file);
      loop
         begin
            buffer := read_next (filestream);
         exception
            when pipe_commands.end_of_file =>
               exit;
         end;
      end loop;

      close (filestream);

      Open (f1, Ada.Text_IO.In_File, "Normalized_Archive_Hypervolume.txt");
      line := To_Unbounded_String (Get_Line (f1));
      Put_Line ("The hypervolume =" & To_String (line));
      return Float'value (To_String (line));

   end call_hv;

end paes.hypervolume_computation;
