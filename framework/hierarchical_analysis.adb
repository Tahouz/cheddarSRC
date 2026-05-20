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

with Text_IO;               use Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

with unbounded_strings;     use unbounded_strings;
use unbounded_strings.strings_table_package;
use unbounded_strings.unbounded_string_list_package;
with systems;                           use systems;
with call_scheduling_framework;         use call_scheduling_framework;
with multiprocessor_services;           use multiprocessor_services;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;
with Ada.Exceptions;      use Ada.Exceptions;
with Scheduler_Interface; use Scheduler_Interface;
with processor_set;       use processor_set;
use processor_set.generic_processor_set;
with Processors;          use Processors;
with Processor_Interface; use Processor_Interface;
with Caches;              use Caches;
use Caches.Caches_Table_Package;
with Parameters;          use Parameters;
with Parameters.extended; use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;
with Tasks;    use Tasks;
with task_set; use task_set;
use task_set.generic_task_set;
with Resources;    use Resources;
with resource_set; use resource_set;
use resource_set.generic_resource_set;
with address_space_set; use address_space_set;
use address_space_set.generic_address_space_set;
with Offsets; use Offsets;
use Offsets.Offsets_Table_Package;
with buffer_set; use buffer_set;
with Buffers;    use Buffers;
use Buffers.Buffer_Roles_Package;
with Queueing_Systems;  use Queueing_Systems;
with message_set;       use message_set;
with Messages;          use Messages;
with task_dependencies; use task_dependencies;
with Dependencies;      use Dependencies;
with Objects;           use Objects;
use Objects.Generic_Object_Set_Package;
with Framework_Config;          use Framework_Config;
with Doubles; use Doubles;

package body hierarchical_analysis is

   function compute_partition_internal_busy_period
     (deployment    : in generic_deployment_ptr;
      priority      :    priority_range;
      window        :    Double;
      bounded_tasks : in Boolean) return Double
   is
      Iterator : Generic_Object_Set_Package.iterator;
      Taskj    : generic_object_ptr;
      Li_w     : Double;
   begin
      reset_iterator (deployment.consumer_entities, Iterator);
      Li_w := 0.0;
      loop
         current_element (deployment.consumer_entities, Taskj, Iterator);
         -- If Taskj is in hp(Taski)
         if (periodic_task_ptr (Taskj).priority < priority) then
            if (bounded_tasks) then
               Li_w :=
                 Li_w +
                 Double'ceiling
                     (window / Double (periodic_task_ptr (Taskj).period)) *
                   Double (periodic_task_ptr (Taskj).capacity);
            else
               Li_w :=
                 Li_w +
                 Double'ceiling
                     ((window +
                       (Double
                          (periodic_task_ptr
                             (get_random_element
                                (deployment.resource_entities))
                             .period)) -
                       (Double
                          (periodic_task_ptr
                             (get_random_element
                                (deployment.resource_entities))
                             .capacity))) /
                      Double (periodic_task_ptr (Taskj).period)) *
                   Double (periodic_task_ptr (Taskj).capacity);

            end if;
         -- Add the capacity of the concerned task
         else
            if (periodic_task_ptr (Taskj).priority = priority) then
               Li_w := Li_w + Double (periodic_task_ptr (Taskj).capacity);
            end if;
         end if;
         -- exit loop when there is no more task
         exit when is_last_element (deployment.consumer_entities, Iterator);
         next_element (deployment.consumer_entities, Iterator);

      end loop;
      return Li_w;
   end compute_partition_internal_busy_period;

   function compute_partition_internal_gaps
     (deployment    : in generic_deployment_ptr;
      priority      :    priority_range;
      window        :    Double;
      bounded_tasks : in Boolean) return Double
   is
      gap  : Double;
      gap2 : Double;
      gap3 : Double;
      gap4 : Double;
   begin
      gap :=
        (Double'ceiling
           (compute_partition_internal_busy_period
              (deployment,
               priority,
               window,
               bounded_tasks) /
            (Double
               (periodic_task_ptr
                  (get_random_element (deployment.resource_entities))
                  .capacity))) -
         1.0) *
        ((Double
            (periodic_task_ptr
               (get_random_element (deployment.resource_entities))
               .period)) -
         (Double
            (periodic_task_ptr
               (get_random_element (deployment.resource_entities))
               .capacity)));

      gap2 :=
        (Double'ceiling
           (compute_partition_internal_busy_period
              (deployment,
               priority,
               window,
               bounded_tasks) /
            (Double
               (periodic_task_ptr
                  (get_random_element (deployment.resource_entities))
                  .capacity))) -
         1.0);
      gap3 :=
        ((Double
            (periodic_task_ptr
               (get_random_element (deployment.resource_entities))
               .period)) -
         (Double
            (periodic_task_ptr
               (get_random_element (deployment.resource_entities))
               .capacity)));
      gap4 :=
        (Double
           (periodic_task_ptr
              (get_random_element (deployment.resource_entities))
              .period));

      Put_Line
        ("Gap Internal L(w)" &
         (Double'ceiling
            (compute_partition_internal_busy_period
               (deployment,
                priority,
                window,
                bounded_tasks))'
            img));
      Put_Line ("Gap Internal Cs" & (gap2'img));
      Put_Line ("Gap Internal Ts-Cs" & (gap3'img));
      Put_Line ("Gap Internal Ts" & (gap4'img));
      Put_Line
        ("**************************************************************");
      put (deployment.resource_entities);
      Put_Line
        ("**************************************************************");
      Put_Line
        ("**************************************************************");
      put (deployment.consumer_entities);
      Put_Line
        ("**************************************************************");
      return gap;

   end compute_partition_internal_gaps;

   function Max (d1 : Double; d2 : Double) return Double is
   begin
      if d1 > d2 then
         return d1;
      else
         return d2;
      end if;
   end Max;

   function compute_server_interference
     (my_deployments : in deployments_set;
      taski_ptr      :    generic_task_ptr;
      window         :    Double;
      bounded_tasks  : in Boolean) return Double
   is
      ServerS          : periodic_task_ptr;
      ServerX          : generic_object_ptr;
      deploymentS      : generic_deployment_ptr;
      deploymentGlobal : generic_deployment_ptr;
      Iterator         : Generic_Object_Set_Package.iterator;
      I                : Double;
   begin
      I                := 0.0;
      deploymentGlobal :=
        search_deployment_by_processor_name
          (my_deployments,
           taski_ptr.cpu_name);
      deploymentS :=
        search_deployment_by_consumer_task_name
          (my_deployments,
           taski_ptr.name);
      ServerS :=
        (periodic_task_ptr
           (get_random_element (deploymentS.resource_entities)));
      reset_iterator (deploymentGlobal.consumer_entities, Iterator);
      loop
         current_element
           (deploymentGlobal.consumer_entities,
            ServerX,
            Iterator);

         -- If ServerX is in hp(ServerS)
         if (periodic_task_ptr (ServerX).priority < ServerS.priority) then
            I :=
              I +
              (Double'ceiling
                   ((Max
                       (0.0,
                        window -
                        (Double'ceiling
                             (compute_partition_internal_busy_period
                                (deploymentS,
                                 taski_ptr.priority,
                                 window,
                                 bounded_tasks) /
                              (Double (ServerS.capacity))) -
                           1.0) *
                          (Double (ServerS.period))) --end of max
                          +
                     (Double (periodic_task_ptr (ServerX).jitter))) /
                    (Double (periodic_task_ptr (ServerX).period))) --end of
                    --first
            --Ceiling
            ) *
                (Double (periodic_task_ptr (ServerX).capacity));
         end if;
         next_element (deploymentGlobal.consumer_entities, Iterator);
         exit when is_last_element
             (deploymentGlobal.consumer_entities,
              Iterator);

      end loop;

      return I;
   end compute_server_interference;

   function compute_wcrt
     (my_sys        : in system;
      taski_ptr     :    generic_task_ptr;
      bounded_tasks : in Boolean) return Double
   is
      deploymentS             : generic_deployment_ptr;
      window, window_plus_one : Double;
      ServerS                 : periodic_task_ptr;
   begin
      deploymentS :=
        search_deployment_by_consumer_task_name
          (my_sys.deployments,
           taski_ptr.name);
      ServerS :=
        (periodic_task_ptr
           (get_random_element (deploymentS.resource_entities)));
      window :=
        Double (taski_ptr.capacity) +
        (Double'ceiling
             (Double (taski_ptr.capacity) / Double (ServerS.capacity)) -
           1.0) *
          (Double (ServerS.period - ServerS.capacity));

      loop

         window_plus_one :=
           compute_partition_internal_busy_period
             (deploymentS,
              taski_ptr.priority,
              window,
              bounded_tasks) +
           compute_partition_internal_gaps
             (deploymentS,
              taski_ptr.priority,
              window,
              bounded_tasks) +
           compute_server_interference
             (my_sys.deployments,
              taski_ptr,
              window,
              bounded_tasks);

         exit when (window = window_plus_one) or
           (window_plus_one >
            Double
              (taski_ptr.deadline - periodic_task_ptr (taski_ptr).jitter));
         window := window_plus_one;
      end loop;
      if (window = window_plus_one) then
         return window + Double (ServerS.jitter);
      else
         return -1.0;
      end if;
   end compute_wcrt;

end hierarchical_analysis;
