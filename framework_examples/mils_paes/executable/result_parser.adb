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
--    $Rev: 4589 $
--    $Date: 2023-09-29 16:02:19 +0200 (ven., 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Text_IO;  use Ada.Text_IO;


package body result_parser is 

   function parse_task_response_time( sys : in System; Processor_name : in Unbounded_String; input : in unbounded_string) return Integer is
      
      start,finish          : integer;      

      sub_str               : unbounded_string;
      str1	            : unbounded_string;
      str2                  : unbounded_string;
      Nb_tasks              : integer;
        	 
      response_time         : integer;
      num_echeance          : integer;

      sum_response_time     : integer:=0;
      Processor_num: integer:=0;
      Tasks_Ptr             : Generic_Task_Ptr; 
      My_iterator           :Tasks_Iterator;
      laxity                : integer;
      sum_laxity            : integer:=0;
      T_name                : unbounded_string;
      k,l                     : integer:=0;
   begin
     Put_line ("Processor_name: " & To_String(Processor_name));
      Nb_tasks  := Integer (Get_Number_Of_Task_From_Processor (sys.Tasks, Processor_name));
      Put_Line("Nb_tasks" & Nb_tasks'Img);
      if (Nb_tasks=0) then 
         raise parser_error;
      end if;
      
      str1 := input;
        str2:= input;
--        Put_Line("input" & input);
--        Put_Line("--------------------");

       
      num_echeance :=0;

      for i in 1 ..Nb_tasks loop
        
         if (i=1) Then
            start :=2+ index (str2, "Task response time computed from simulation :") + length(To_Unbounded_String("Task response time computed from simulation : "));
            finish := index (str2, " => ");
            T_name := Suppress_Space(Unbounded_Slice(str2,start,finish));
            
            Put_Line("T_name: " & T_name);
            str2 := Unbounded_Slice(str2,
                                 2+ index (str2, "/worst")+length(To_Unbounded_String("/worst")),
                                    length(str2));
            if (To_String(Suppress_Space(Unbounded_Slice(str2,2,10)))="response") Then
               str2 := Unbounded_Slice(str2,2+index (str2, "capacity")+length(To_Unbounded_String("capacity")),length(str2));
            else                
               While (Suppress_Space(To_String(Unbounded_Slice(str2,2,9)))="missed") loop
                  k:=1;
                     str2 :=  Unbounded_Slice(str2,1+index (str2, ")"),length(str2));
               end loop;
               if(k=1) Then
                  k:=0;
                     str2 :=  Unbounded_Slice(str2,2,length(str2));
               end if; 

           end if; 
         else
            finish := index (str2, " => ");

            T_name := Suppress_Space(Unbounded_Slice(str2,1,finish));
                        
            
            str2 := Unbounded_Slice(str2,2+index (str2, "/worst")+length(To_Unbounded_String("/worst")),length(str2));
            if (To_String(Suppress_Space(Unbounded_Slice(str2,2,10)))="response") Then
               str2 := Unbounded_Slice(str2,2+index (str2, "capacity")+length(To_Unbounded_String("capacity")),length(str2));
               
            else 
               
               While (Suppress_Space(To_String(Unbounded_Slice(str2,2,9)))="missed") loop
                  k:=1;
                     str2 :=  Unbounded_Slice(str2,1+index (str2, ")"),length(str2));
               end loop;
               if(k=1) Then
                  k:=0;
                     str2 :=  Unbounded_Slice(str2,2,length(str2));
                  end if; 
                  end if;
                 
           end if;
         str1:=input;

         start := index (str1, "=> ") + length(To_Unbounded_String("=> "));

         finish := index (str1, "/worst") - 1;
         
         response_time := integer'Value (to_string(Unbounded_Slice(str1,start,finish)));

         sum_response_time := sum_response_time + response_time;

         str1 := Unbounded_Slice(str1,
                                 index (str1, "/worst") + length(To_Unbounded_String("/worst")),
                                 length(str1));
 --       Put_Line("tttttttttttttttt" & To_String(T_name));
         Tasks_Ptr:=Search_Task (sys.Tasks, T_name);
         laxity:=Tasks_Ptr.deadline-response_time;
         if ((laxity<0)OR (response_time=0))Then
            num_echeance := num_echeance+1;
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


function parse_task_context_switch( sys : in System;Processor_name : in Unbounded_String;  input : in unbounded_string) return Integer is
      start,finish          : integer;
      task_exist            : integer;
      Nb_tasks              : integer;
      Nb_context_switches   : integer;


      sub_str               : unbounded_string;
      str1	            : unbounded_string;
begin
 --     str1 := input;
      start:= index(input, "Scheduling simulation, Processor "& To_String(Processor_name));
      str1 :=  Suppress_Space(Unbounded_Slice(input,start,length(input)));
     
      task_exist := index (str1, "/worst");

      while task_exist /= 0 loop

         str1 := Unbounded_Slice(
             str1,
             index (str1, "/worst") + length(To_Unbounded_String("/worst")),
             length(str1));

         task_exist := index (str1, "/worst");

      end loop;
      sub_str := Unbounded_Slice(str1, index (str1, "-"), 8);
      Nb_tasks  := Integer (Get_Number_Of_Task_From_Processor (sys.Tasks, Processor_name));
      if (Nb_tasks=0) then 
         raise parser_error;
      end if;

   --   if sub_str = To_Unbounded_String("- No d") then
      -- In this case, the task set is schedulable
      -- Then we exctract from the results of the simulation,
      -- values of fitness functions of the candidate solution
      -- i.e : context switches, number of preemptions, laxity of tasks
--      str1 := input;
      
       start:= index(input, "Scheduling simulation, Processor "& To_String(Processor_name));
      str1 :=  Suppress_Space(Unbounded_Slice(input,start,length(input)));
         
         start := index (input, "- Number of context switches :  ") 
                + length(To_Unbounded_String("- Number of context switches :  "));

         finish := start + index (Unbounded_Slice(input, start, length(input)), ASCII.LF&"") - 2;

         Nb_context_switches := integer'Value
           (to_string(Unbounded_Slice(input,start,finish)));
         
         return Nb_context_switches;
  --    else
 --        raise parser_error;
   --   end if;
      
end parse_task_context_switch;
  
  
   function parse_task_preemption( sys : in System;Processor_name : in Unbounded_String; 
                                    input : in unbounded_string ) return Integer is
      start,finish          : integer;
      task_exist            : integer;
      Nb_tasks              : integer;


      sub_str               : unbounded_string;
      str1	            : unbounded_string;
      Nb_preemptions   	    : integer;

   begin
 --      str1 := input;
 
      start:= index(input, "Scheduling simulation, Processor "& To_String(Processor_name));
      str1 :=  Suppress_Space(Unbounded_Slice(input,start,length(input)));
     
      
      task_exist := index (str1, "/worst");

      while task_exist /= 0 loop

         str1 := Unbounded_Slice(
             str1,
             index (str1, "/worst") + length(To_Unbounded_String("/worst")),
             length(str1));

         task_exist := index (str1, "/worst");

      end loop;
      sub_str := Unbounded_Slice(str1, index (str1, "-"), 8);
      Nb_tasks  := Integer (Get_Number_Of_Task_From_Processor (sys.Tasks, Processor_name));
      if (Nb_tasks=0) then 
         raise parser_error;
      end if;
 --     if sub_str = To_Unbounded_String("- No d") then
      -- In this case, the task set is schedulable
      -- Then we exctract from the results of the simulation,
      -- values of fitness functions of the candidate solution
      -- i.e : context switches, number of preemptions, laxity of tasks
--      str1 := input;
      
      start:= index(input, "Scheduling simulation, Processor "& To_String(Processor_name));
      str1 :=  Suppress_Space(Unbounded_Slice(input,start,length(input)));

      start := index (input, "- Number of preemptions :  ") 
        + length(To_Unbounded_String("- Number of preemptions :  "));

      finish := start + index (Unbounded_Slice(input, start, length(input)), ASCII.LF&"") - 2;
    

      Nb_preemptions := integer'Value(to_string(Unbounded_Slice(input,start,finish)));
      
      return Nb_preemptions;
         
  --    else 
    --     raise parser_error;
  --    end if;
         

end parse_task_preemption;


  
end  result_parser ;

