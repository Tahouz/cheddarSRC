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
--    $Rev: 5147 $
--    $Date: 2024-09-02 15:36:37 +0200 (lun., 02 sept. 2024) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with translate;           use translate;
with unbounded_strings;   use unbounded_strings;
with Scheduling_Analysis; use Scheduling_Analysis;
use Scheduling_Analysis.Double_Tasks_Parameters_Package;
with feasibility_test.processor_utilization;
use feasibility_test.processor_utilization;
with systems;   use systems;
with scheduler; use scheduler;
with Text_IO;   use Text_IO;

with processor_set; use processor_set;
with Processors;    use Processors;
with Core_Units;    use Core_Units;
use Core_Units.Core_Units_Table_Package;

package body feasibility_test
  .periodic_task_worst_case_response_time_dynamic_priority
is

    function compute_wi_a_t
      (my_tasks : in tasks_set;
       taski    : in generic_task_ptr;
       a        : in Integer;
       t        : in Double) return Double
    is
        result   : Double := 0.0;
        min      : Double := 0.0;
        iterator : tasks_iterator;
        taskj    : generic_task_ptr;
    begin

        reset_iterator (my_tasks, iterator);
        loop
            current_element (my_tasks, taskj, iterator);

            if
              ((taskj.name /= taski.name) and
                   (taskj.deadline <= a + taski.deadline))
            then
                min :=
                  1.0 +
                    Double'floor
                      ((Double (a) +
                         Double (taski.deadline) -
                         Double (taskj.deadline)) /
                         Double (periodic_task_ptr (taskj).period));

                if
                  (Double'ceiling (t / Double (periodic_task_ptr (taskj).period)) <
                       min)
                then
                    min :=
                      Double'ceiling
                        (t / Double (periodic_task_ptr (taskj).period));
                end if;
                result := result + min * Double (taskj.capacity);
            end if;

            -- exit loop when there is no more task
            --
            exit when is_last_element (my_tasks, iterator);
            next_element (my_tasks, iterator);
        end loop;

        return result;
    end compute_wi_a_t;

    function compute_li_a
      (my_scheduler : in dynamic_priority_scheduler;
       my_tasks     : in tasks_set;
       taski        : in generic_task_ptr;
       a            : in Integer) return Double
    is
        li_a     : Double  := 0.1;
        li_a_1   : Double  := 0.0;
        iterator : tasks_iterator;
        taskj    : generic_task_ptr;
        max_cj   : Natural := 0;
        tmp      : Double  := 0.0;
        min      : Double  := 0.0;
        min1     : Double  := 0.0;
        min2     : Double  := 0.0;
    begin

        if (my_scheduler.parameters.preemptive_type = preemptive) then
            -- preemptive case
            --
            while li_a_1 /= li_a loop

                li_a := li_a_1;

                li_a_1 := compute_wi_a_t (my_tasks, taski, a, li_a);

                case taski.task_type is
                when periodic_type =>
                    li_a_1 :=
                      li_a_1 +
                        (1.0 +
                           Double'floor
                             (Double (a) /
                                    Double (periodic_task_ptr (taski).period))) *
                      Double (taski.capacity);
                when others =>
                    raise task_model_error;
                end case;
            end loop;

        else
            -- non preemptive case
            --
            while li_a_1 /= li_a loop

                li_a := li_a_1;
                tmp  := 0.0;
                reset_iterator (my_tasks, iterator);
                loop
                    current_element (my_tasks, taskj, iterator);

                    if ((a + taski.deadline) < taskj.deadline) then
                        if (taskj.capacity > max_cj) then
                            max_cj := taskj.capacity;
                        end if;
                    end if;

                    if
                      ((taskj.name /= taski.name) and
                           (taskj.deadline <= a + taski.deadline))
                    then
                        min1 :=
                          1.0 +
                            Double'floor
                              (li_a / Double (periodic_task_ptr (taskj).period));

                        min2 :=
                          1.0 +
                            Double'floor
                              (Double (a) +
                                       Double (taski.deadline) -
                                       Double (taskj.deadline)) /
                                Double (periodic_task_ptr (taskj).period);

                        min := min1;
                        if (min2 < min) then
                            min := min2;
                        end if;

                        tmp :=
                          tmp +
                            min * Double (taskj.capacity) +
                          Double'floor
                            (Double (a) /
                                   Double (periodic_task_ptr (taskj).period)) *
                          Double (taski.capacity);
                    end if;

                    -- exit loop when there is no more task
                    --
                    exit when is_last_element (my_tasks, iterator);
                    next_element (my_tasks, iterator);
                end loop;

                li_a_1 := Double (max_cj) + tmp;
            end loop;

        end if;

        return li_a;
    end compute_li_a;

    -- This function may present an infinite loop for non-preemptive case
    -- It may come from the upper bound for a: (exit when a >= Li(a))
    --
    procedure compute_response_time
      (my_scheduler   : in     dynamic_priority_scheduler;
       my_sys         : in     system;
       processor_name : in     Unbounded_String;
       msg            : in out Unbounded_String;
       response_time  :    out response_time_table)
    is

        tmp       : tasks_set;
        iterator1 : tasks_iterator;
        taski     : generic_task_ptr;
        iterator2 : tasks_iterator;
        taskj     : generic_task_ptr;
        i         : response_time_range := 0;

        a : Integer := 0;

        b_sup    : Double  := 0.0;
        li_a     : Double  := 0.0;
        k        : Natural := 0;
        rt       : Double  := 0.0;
        converge : Natural;

        the_cores       : core_units_table;
        a_processor     : generic_processor_ptr;
        processor_bound : Double := 1.0;

    begin

        -- Bibliographical references
        --
        if (my_scheduler.parameters.preemptive_type = not_preemptive) then
            -- Non preemptive case
            --
            msg :=
              To_Unbounded_String (" (") &
              lb_see (Current_Language) &
              To_Unbounded_String ("[1], page 13)");
        else
            -- Preemptive case
            --
            msg :=
              To_Unbounded_String (" (") &
              lb_see (Current_Language) &
              To_Unbounded_String ("[1], page 23)");
        end if;

        initialize (response_time);

        -- check if tasks are periodics
        --
        periodic_control (my_sys.tasks, processor_name);

        -- check start time
        --
        start_time_control (my_sys.tasks, processor_name);

        -- check offset
        --
        offset_control (my_sys.tasks, processor_name);

        -- Check processor utilization first
        --
        a_processor := search_processor (my_sys.processors, processor_name);
        the_cores   := build_core_table (a_processor);

        processor_bound := processor_bound * Double (the_cores.nb_entries);

        if
          (processor_utilization_over_period (my_sys.tasks, processor_name) >
               processor_bound)
        then
            raise processor_utilization_exceeded;
        end if;

        -- Select task to proceed
        --
        current_processor_name := processor_name;

        -- get the task set of the processor processor_name in the monoproc case
        if a_processor.processor_type = monocore_type or
          a_processor.migration_type /= no_migration_type
        then
            select_and_copy (my_sys.tasks, tmp, select_cpu'access);
        end if;

        for core_index in 0 .. the_cores.nb_entries - 1 loop
            reset_iterator (tmp, iterator1);

            if a_processor.processor_type /= monocore_type and
              a_processor.migration_type = no_migration_type
            then
                current_core_name := the_cores.entries (core_index).name;

                reset (tmp);
                select_and_copy (my_sys.tasks, tmp, select_core'access);
            end if;

            loop
                -- selection of the current task
                --
                current_element (tmp, taski, iterator1);

                -- initialize response time for current task
                --
                response_time.entries (i).data := 0.0;
                response_time.entries (i).item := taski;
                response_time.nb_entries       := response_time.nb_entries + 1;

                if (my_scheduler.parameters.preemptive_type = preemptive) then
                    response_time.entries (i).data := Double (taski.capacity);
                end if;

                -- compute S "on the fly"
                --
                reset_iterator (tmp, iterator2);

                loop
                    current_element (tmp, taskj, iterator2);

                    k        := 0;
                    converge := 0;
                    loop
                        case taskj.task_type is
                        when periodic_type =>

                            a :=
                              (k * periodic_task_ptr (taskj).period) +
                                taskj.deadline -
                                  taski.deadline;

                        when others =>
                            raise task_model_error;
                        end case;

                        li_a := compute_li_a (my_scheduler, tmp, taski, a);

                        if
                          ((li_a - Double (a)) > response_time.entries (i).data)
                        then
                            response_time.entries (i).data := li_a - Double (a);
                        end if;

                        if rt = response_time.entries (i).data then
                            converge := converge + 1;
                        else
                            converge := 0;
                        end if;

                        rt := response_time.entries (i).data;

                        if
                          (my_scheduler.parameters.preemptive_type = preemptive)
                        then
                            b_sup := li_a;
                        else
                            b_sup := li_a;
                        end if;

                        exit when (a >= Integer (b_sup));

                        -- PROBLEM : the lines below try yo fix an endless loop
                        -- The exit statements bellow
                        -- are not part of the response time
                        -- computation : it's just a way to be sure that the response
                        -- time computation never loop for ever ....
                        --
                        exit when Natural (response_time.entries (i).data) >
                          taski.deadline;
                        exit when converge > 1000;

                        k := k + 1;
                    end loop;

                    exit when is_last_element (tmp, iterator2);
                    -- go to the next task
                    --
                    next_element (tmp, iterator2);
                end loop;

                i := i + 1;

                exit when is_last_element (tmp, iterator1);

                -- go to the next task
                --
                next_element (tmp, iterator1);
            end loop;
        end loop;

    end compute_response_time;

end feasibility_test.periodic_task_worst_case_response_time_dynamic_priority;
