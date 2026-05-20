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
-- Frank Singhoff, Lab-STICC UMR CNRS 6285, Universite de Bretagne Occidentale
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
--    $Rev: 3546 $
--    $Date: 2020-10-19 08:01:15 +0200 (lun. 19 oct. 2020) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Text_IO; use Ada.Text_IO;
with debug;       use debug;

package body result_parser is

   function parse_task_response_time
     (sys            : in system;
      Processor_name : in Unbounded_String;
      input          : in Unbounded_String) return Integer
   is

      start, finish : Integer;

      sub_str  : Unbounded_String;
      str1     : Unbounded_String;
      str2     : Unbounded_String;
      Nb_tasks : Integer;

      response_time : Integer;
      num_echeance  : Integer;

      sum_response_time : Integer := 0;
      Processor_num     : Integer := 0;
      Tasks_Ptr         : generic_task_ptr;
      My_iterator       : tasks_iterator;
      laxity            : Integer;
      sum_laxity        : Integer := 0;
      T_name            : Unbounded_String;
      k, l              : Integer := 0;
   begin
      Put_Line ("Processor_name: " & To_String (Processor_name));
      Nb_tasks :=
        Integer
          (get_number_of_task_from_processor (sys.tasks, Processor_name));
      Put_Line ("Nb_tasks" & Nb_tasks'img);
      if (Nb_tasks = 0) then
         raise parser_error;
      end if;

      str1 := input;
      str2 := input;
--        Put_Line("input" & input);
--        Put_Line("--------------------");

      num_echeance := 0;

      for i in 1 .. Nb_tasks loop

         if (i = 1) then
            start :=
              2 +
              Index (str2, "Task response time computed from simulation :") +
              Length
                (To_Unbounded_String
                   ("Task response time computed from simulation : "));
            finish := Index (str2, " => ");
            T_name := suppress_space (Unbounded_Slice (str2, start, finish));

--            Put_Line("T_name: " & T_name);
            str2 :=
              Unbounded_Slice
                (str2,
                 2 +
                 Index (str2, "/worst") +
                 Length (To_Unbounded_String ("/worst")),
                 Length (str2));
            if
              (To_String (suppress_space (Unbounded_Slice (str2, 2, 10))) =
               "response")
            then
               str2 :=
                 Unbounded_Slice
                   (str2,
                    2 +
                    Index (str2, "capacity") +
                    Length (To_Unbounded_String ("capacity")),
                    Length (str2));
            else
               while
                 (suppress_space (To_String (Unbounded_Slice (str2, 2, 9))) =
                  "missed")
               loop
                  k    := 1;
                  str2 :=
                    Unbounded_Slice
                      (str2,
                       1 + Index (str2, ")"),
                       Length (str2));
               end loop;
               if (k = 1) then
                  k    := 0;
                  str2 := Unbounded_Slice (str2, 2, Length (str2));
               end if;

            end if;
         else
            finish := Index (str2, " => ");

            T_name := suppress_space (Unbounded_Slice (str2, 1, finish));

            str2 :=
              Unbounded_Slice
                (str2,
                 2 +
                 Index (str2, "/worst") +
                 Length (To_Unbounded_String ("/worst")),
                 Length (str2));
            if
              (To_String (suppress_space (Unbounded_Slice (str2, 2, 10))) =
               "response")
            then
               str2 :=
                 Unbounded_Slice
                   (str2,
                    2 +
                    Index (str2, "capacity") +
                    Length (To_Unbounded_String ("capacity")),
                    Length (str2));

            else

               while
                 (suppress_space (To_String (Unbounded_Slice (str2, 2, 9))) =
                  "missed")
               loop
                  k    := 1;
                  str2 :=
                    Unbounded_Slice
                      (str2,
                       1 + Index (str2, ")"),
                       Length (str2));
               end loop;
               if (k = 1) then
                  k    := 0;
                  str2 := Unbounded_Slice (str2, 2, Length (str2));
               end if;
            end if;

         end if;
         -- str1:=input;

         start := Index (str1, "=> ") + Length (To_Unbounded_String ("=> "));

         finish := Index (str1, "/worst") - 1;

         response_time :=
           Integer'value (To_String (Unbounded_Slice (str1, start, finish)));

         sum_response_time := sum_response_time + response_time;

         str1 :=
           Unbounded_Slice
             (str1,
              Index (str1, "/worst") + Length (To_Unbounded_String ("/worst")),
              Length (str1));
         --       Put_Line("tttttttttttttttt" & To_String(T_name));
         --        Put_Debug("tttttttttttttttt" & To_String(T_name));
         Tasks_Ptr := search_task (sys.tasks, T_name);
         laxity    := Tasks_Ptr.deadline - response_time;
         --         Put_Debug("laxityyyyyyy" & laxity'Img);
         --         Put_Debug("response_time" & response_time'Img);
         if ((laxity < 0) or (response_time = 0)) then
            num_echeance := num_echeance + 1;
            --           Put_Debug("num_echeanceeeeeee: "&num_echeance'Img);
         end if;
--           sum_laxity:=sum_laxity+laxity;
--           if (response_time /=0) Then
--              Append (Result, "<laxity>"& laxity'Img &"<\laxity>" & ASCII.LF);
--           end if;

      end loop;

      ----------------------

      --   else
      --      raise parser_error;
      --   end if;
      return num_echeance;

   end parse_task_response_time;

   function parse_task_context_switch
     (sys            : in system;
      Processor_name : in Unbounded_String;
      input          : in Unbounded_String) return Integer
   is
      start, finish       : Integer;
      task_exist          : Integer;
      Nb_tasks            : Integer;
      Nb_context_switches : Integer;

      sub_str : Unbounded_String;
      str1    : Unbounded_String;
   begin
      --     str1 := input;
      start :=
        Index
          (input,
           "Scheduling simulation, Processor " & To_String (Processor_name));
      str1 := suppress_space (Unbounded_Slice (input, start, Length (input)));

      task_exist := Index (str1, "/worst");

      while task_exist /= 0 loop

         str1 :=
           Unbounded_Slice
             (str1,
              Index (str1, "/worst") + Length (To_Unbounded_String ("/worst")),
              Length (str1));

         task_exist := Index (str1, "/worst");

      end loop;
      sub_str  := Unbounded_Slice (str1, Index (str1, "-"), 8);
      Nb_tasks :=
        Integer
          (get_number_of_task_from_processor (sys.tasks, Processor_name));
      if (Nb_tasks = 0) then
         raise parser_error;
      end if;

      --   if sub_str = To_Unbounded_String("- No d") then
      -- In this case, the task set is schedulable
      -- Then we exctract from the results of the simulation,
      -- values of fitness functions of the candidate solution
      -- i.e : context switches, number of preemptions, laxity of tasks
--      str1 := input;

      start :=
        Index
          (input,
           "Scheduling simulation, Processor " & To_String (Processor_name));
      str1 := suppress_space (Unbounded_Slice (input, start, Length (input)));

      start :=
        Index (input, "- Number of context switches :  ") +
        Length (To_Unbounded_String ("- Number of context switches :  "));

      finish :=
        start +
        Index (Unbounded_Slice (input, start, Length (input)), ASCII.LF & "") -
        2;

      Nb_context_switches :=
        Integer'value (To_String (Unbounded_Slice (input, start, finish)));

      return Nb_context_switches;
      --    else
      --        raise parser_error;
      --   end if;

   end parse_task_context_switch;

   function parse_task_preemption
     (sys            : in system;
      Processor_name : in Unbounded_String;
      input          : in Unbounded_String) return Integer
   is
      start, finish : Integer;
      task_exist    : Integer;
      Nb_tasks      : Integer;

      sub_str        : Unbounded_String;
      str1           : Unbounded_String;
      Nb_preemptions : Integer;

   begin
      --      str1 := input;

      start :=
        Index
          (input,
           "Scheduling simulation, Processor " & To_String (Processor_name));
      str1 := suppress_space (Unbounded_Slice (input, start, Length (input)));

      task_exist := Index (str1, "/worst");

      while task_exist /= 0 loop

         str1 :=
           Unbounded_Slice
             (str1,
              Index (str1, "/worst") + Length (To_Unbounded_String ("/worst")),
              Length (str1));

         task_exist := Index (str1, "/worst");

      end loop;
      sub_str  := Unbounded_Slice (str1, Index (str1, "-"), 8);
      Nb_tasks :=
        Integer
          (get_number_of_task_from_processor (sys.tasks, Processor_name));
      if (Nb_tasks = 0) then
         raise parser_error;
      end if;
      --     if sub_str = To_Unbounded_String("- No d") then
      -- In this case, the task set is schedulable
      -- Then we exctract from the results of the simulation,
      -- values of fitness functions of the candidate solution
      -- i.e : context switches, number of preemptions, laxity of tasks
--      str1 := input;

      start :=
        Index
          (input,
           "Scheduling simulation, Processor " & To_String (Processor_name));
      str1 := suppress_space (Unbounded_Slice (input, start, Length (input)));

      start :=
        Index (input, "- Number of preemptions :  ") +
        Length (To_Unbounded_String ("- Number of preemptions :  "));

      finish :=
        start +
        Index (Unbounded_Slice (input, start, Length (input)), ASCII.LF & "") -
        2;

      Nb_preemptions :=
        Integer'value (To_String (Unbounded_Slice (input, start, finish)));

      return Nb_preemptions;

      --    else
      --     raise parser_error;
      --    end if;

   end parse_task_preemption;

end result_parser;
