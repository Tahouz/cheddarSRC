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



WITH Ada.Strings.Unbounded; USE Ada.Strings.Unbounded;

WITH Unbounded_Strings;     USE  Unbounded_Strings;
with Doubles;               use Doubles;
WITH framework_Config;      USE framework_Config;
WITH Dependencies;          USE Dependencies;
USE Dependencies.Dep_Set;
WITH Task_Dependencies;     USE Task_Dependencies;
WITH Tasks;                 USE Tasks;
WITH Task_Set;              USE Task_Set;
USE Task_Set.Generic_Task_Set;
WITH Messages;              USE Messages;
WITH Message_Set;           USE Message_Set;
USE Message_Set.Generic_Message_Set;
WITH Scheduler;             USE Scheduler;
USE Scheduler.Double_Tasks_Parameters;
WITH Processors;            USE Processors;
WITH Processor_Set;         USE Processor_Set;
USE Processor_Set.Generic_Processor_Set;




PACKAGE BODY Distributed_Scheduling IS


   PROCEDURE Tindell (
         My_Tasks      : IN OUT Tasks_Set;
         My_Messages   : IN OUT Messages_Set;
         My_Deps       : IN     Tasks_Dependencies;
         My_Processors : IN     Processors_Set;
         Response_Time :    OUT Scheduler.Response_Table) IS


      Rtn,
      Rtn1        : Scheduler.Response_Table;
      Rt_Messages : Network.Response_Table;



      FUNCTION Get_Response_Time (
            A_Message : Message_Ptr)
        RETURN Double IS
      BEGIN
         FOR I IN Network.Response_Range LOOP
            IF (Rt_Messages.Entries(I).Item.Name = A_Message.Name)
                  THEN
               RETURN Rt_Messages.Entries(I).Data;
            END IF;
         END LOOP;

         RAISE Internal_Error;
      END Get_Response_Time;


      FUNCTION Get_Response_Time (
            A_Task : Generic_Task_Ptr)
        RETURN Double IS
      BEGIN
         FOR I IN Scheduler.Response_Range LOOP
            IF (Rtn.Entries(I).Item.Name = A_Task.Name)
                  THEN
               RETURN Rtn.Entries(I).Data;
            END IF;
         END LOOP;

         RAISE Internal_Error;
      END Get_Response_Time;


      PROCEDURE Inject_Jitter_Into_Successors (
            Task1 : IN     Tasks_Set;
            Msg1  : IN     Depends_Set) IS

         Max_Jitter : Double           := 0.0;
         Ite1       : Depends_Iterator;
         Ite2       : Tasks_Iterator;
         M1         : Dependency_Ptr;
         T1         : Generic_Task_Ptr;

      BEGIN
         -- find maximum response time of all messages
         --
         Reset_Iterator(Ite1);
         LOOP
            Current_Element(Msg1, M1, Ite1);

            Max_Jitter:=Double'Max(Max_Jitter,
               Get_Response_Time(Message_Ptr(M1)));

            EXIT WHEN Is_Last_Element(Msg1, Ite1) = True;
            Next_Element(Msg1, Ite1);
         END LOOP;

         -- set jitter with max_jitter
         --
         Reset_Iterator(Ite2);
         LOOP
            Current_Element(Task1, T1, Ite2);

            Task_Set.Set(My_Tasks, T1.Name,
               Task_Set.Jitter, Natural(Max_Jitter));

            EXIT WHEN Is_Last_Element(Task1, Ite2) = True;
            Next_Element(Task1, Ite2);
         END LOOP;

      END Inject_Jitter_Into_Successors;



      PROCEDURE Inject_Jitter_Into_Messages (
            Msg1 : IN     Depends_Set;
            T1   : IN     Generic_Task_Ptr) IS

         Ite       : Depends_Iterator;
         M1        : Dependency_Ptr;
         T1_Jitter : Double;
      BEGIN

         T1_Jitter:=Get_Response_Time(T1);

         Reset_Iterator(Ite);
         LOOP
            Current_Element(Msg1, M1, Ite);

            -- look for response time of t1 in rtn1
            --
            Message_Set.Set(My_Messages, Message_Ptr(M1).Name,
               Message_Set.Jitter,
               Natural(T1_Jitter));

            EXIT WHEN Is_Last_Element(Msg1, Ite) = True;
            Next_Element(Msg1, Ite);
         END LOOP;
      END Inject_Jitter_Into_Messages;


      PROCEDURE Compute IS

         I     : Natural;
         Dummy : Unbounded_String := Empty_String;

         K,
         J           : Scheduler.Response_Range;
         A_Processor : Generic_Processor_Ptr;
         My_Iterator : Processor_Set.Generic_Processor_Set.Iterator;

         TYPE Rt IS ARRAY (0 .. Max_Processors - 1) OF Scheduler.Response_Table;
         Rt_By_Processor : Rt;

      BEGIN
         -- Compute tasks and messages response time
         I:=0;
         Reset_Iterator(My_Iterator);

         LOOP
            Current_Element(My_Processors, A_Processor, My_Iterator);

            Compute_Response_Time(A_Processor.Scheduler.All, My_Tasks,
               A_Processor.Name, Dummy, Rt_By_Processor(I));

            EXIT WHEN Is_Last_Element(My_Processors, My_Iterator) = True;

            Next_Element(My_Processors, My_Iterator);
            I:=I+1;
         END LOOP;

         Compute_Transmission_Delay(My_Network,My_Messages,Rt_Messages);

         -- gather response time information
         --
         Reset_Iterator(My_Iterator);

         I:=0;
         K:=0;

         LOOP
            J:=0;
            Current_Element(My_Processors, A_Processor, My_Iterator);

            FOR L IN 0 .. (Get_Number_Of_Task_From_Processor(My_Tasks,
                     A_Processor.Name)-1) LOOP
               Rtn.Entries(K):=Rt_By_Processor(I).Entries(J);
               K:=K+1;
               J:=J+1;
            END LOOP;

            EXIT WHEN Is_Last_Element(My_Processors, My_Iterator) = True;

            Next_Element(My_Processors, My_Iterator);
            I:=I+1;


         END LOOP;

      END Compute;




      PROCEDURE Inject_Jitter IS


         T1,
         T2    : Generic_Task_Ptr;
         Task2 : Tasks_Set;
         Msg1  : Depends_Set;
         Ite1,
         Ite2  : Tasks_Iterator;

      BEGIN
         -- for each task, look for its successor and insert jitter of messages and
         -- successors
         --
         Reset_Iterator(Ite1);

         LOOP
            Current_Element(My_Tasks, T1, Ite1);

            -- has successors ?
            --
            IF Has_Successor(My_Deps, T1)
                  THEN
               Task2:=Get_Successors_List(My_Deps, T1);

               -- set messages jitter
               --
               Reset_Iterator(Ite2);
               LOOP
                  Current_Element(Task2, T2, Ite2);
                  Msg1:=Get_Dependencies(My_Deps, T1, T2);
                  Inject_Jitter_Into_Messages(Msg1, T1);

                  EXIT WHEN Is_Last_Element(Task2, Ite2) = True;
                  Next_Element(Task2, Ite2);
               END LOOP;

               -- set task jitter
               Inject_Jitter_Into_Successors(Task2, Msg1);
            END IF;

            EXIT WHEN Is_Last_Element(My_Tasks, Ite1) = True;
            Next_Element(My_Tasks, Ite1);
         END LOOP;



      END Inject_Jitter;



   BEGIN

      Initialize(Rtn);
      Initialize(Rtn1);

      Compute;


      -- Now, loop until convergence. Insert response time as jitter
      WHILE (Rtn /= Rtn1) LOOP

         Rtn1:=Rtn;

         Inject_Jitter;

         Compute;

      END LOOP;


      Response_Time:=Rtn1;


   END Tindell;



END Distributed_Scheduling;
