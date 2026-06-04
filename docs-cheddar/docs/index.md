# CHEDDAR CLI

The **CHEDDAR CLI** is a command-line interface built on top of the *CHEDDAR Framework*.  
It allows users to perform scheduling analysis, simulations, and ouput or export system models , event tables and analysis directly from the terminal.

It is designed to simplify and automate real-time system analysis without requiring a graphical interface.


---

## Usage

```bash
cheddar_cli [options]
```

---

## Options

## Input

| Option                  | Description                            |
| ----------------------- | -------------------------------------- |
| `--file=<filename.xml>` | Specify the XML system file to analyze |

---

## Output

| Option                                    | Description                                          |
| ----------------------------------------- | ---------------------------------------------------- |
| `--output=stdout_analysis`                | Output analysis results to standard output (default) |
| `--output=stdout_xml_sysmodel`            | Output system model in XML format to stdout          |
| `--output=stdout_xml_eventtable`          | Output event table in XML format to stdout           |
| `--output=file_xml_analysis=<filename>`       | Save analysis results to a file                      |
| `--output=file_xml_sysmodel=<filename>`   | Save system model in XML format to a file            |
| `--output=file_xml_eventtable=<filename>` | Save event table in XML format to a file             |

---

## Target

| Option                                    | Description                                          |
| ----------------------------------------- | ---------------------------------------------------- |
| `--target=<cpu name>`                | Specify processor name to run analysis on |

---
## Request

| Option                  | Description                            |
| ----------------------- | -------------------------------------- |
| `--request=request1<,request2>` | Specify requests too run  |

### Simulation
| Request                                         | Description                              |
| ----------------------------------------------- | ---------------------------------------- |
| `simulation or scheduling_simulation_time_line` | Run a full temporal simulation           |

> Note : This request generates a simulation timeline that you can export as event table 

### Simulation Analysis

| Request                                         | Description                              |
| ----------------------------------------------- | ---------------------------------------- |
| `scheduling_simulation_response_time`           | Get tasks response time from simulation            |
| `scheduling_simulation_blocking_time`           | Get tasks blocking time from simulation                  |
| `scheduling_simulation_basics`                  | Basic simulation analysis                |
| `scheduling_simulation_preemption_number`       | Get number of preemptions from simulation           |
| `scheduling_simulation_context_switch_number`   | Get number of context switches from simulation      |
| `scheduling_simulation_all_response_times`      | Compute all response times               |
| `scheduling_simulation_priority_inversion`      | Get priority inversion situations from simulation    |
| `scheduling_simulation_deadlock`                | Get deadlocks from simulation                        |
| `scheduling_simulation_run_event_handler`       |  |

> Note : These requests should be called after a simulation request

---

### Priority Assignment

| Request                                                         | Description                                                 |
| --------------------------------------------------------------- | ----------------------------------------------------------- |
| `scheduling_set_priorities_according_to_rate_monotonic`         | Assign priorities using Rate Monotonic (RM)                 |
| `scheduling_set_priorities_according_to_deadline_monotonic`     | Assign priorities using Deadline Monotonic (DM)             |
| `scheduling_set_priorities_according_to_audsley_opa`            | Assign priorities using Audsley Optimal Priority Assignment |
| `scheduling_set_priorities_according_to_opa_crpd_pt`            | OPA with CRPD PT analysis                                   |
| `scheduling_set_priorities_according_to_opa_crpd_pt_simplified` | Simplified OPA with CRPD PT                                 |
| `scheduling_set_priorities_according_to_opa_crpd_tree`          | OPA using CRPD Tree approach                                |

---

### Scheduling Feasibility

| Request                                                                       | Description                                    |
| ----------------------------------------------------------------------------- | ---------------------------------------------- |
| `feasibility or scheduling_feasibility_basics`  | Basic feasibility checks  |
| `scheduling_feasibility_periodic_task_worst_case_response_time`               | Compute WCRT for periodic tasks                |
| `scheduling_feasibility_transaction_worst_case_response_time_audsley`         | Transaction WCRT using Audsley method          |
| `scheduling_feasibility_transaction_worst_case_response_time_tindell`         | Transaction WCRT using Tindell method          |
| `scheduling_feasibility_transaction_worst_case_response_time_palencia`        | Transaction WCRT using Palencia method         |
| `scheduling_feasibility_transaction_worst_case_response_time_wcdops_plus`     | Transaction WCRT using WCDOPS+                 |
| `scheduling_feasibility_transaction_worst_case_response_time_wcdops_plus_nim` | Transaction WCRT using WCDOPS+ NIM             |
| `scheduling_feasibility_cpu_utilization`                                      | Compute CPU utilization                        |
| `scheduling_feasibility_compute_worst_case_blocking_time`                     | Compute worst-case blocking time               |
| `scheduling_feasibility_compute_and_set_worst_case_blocking_time`             | Compute and assign blocking time               |
| `scheduling_feasibility_compute_resource_ceiling_priority`                    | Compute resource ceiling priorities            |
| `scheduling_feasibility_compute_and_set_resource_ceiling_priority`            | Compute and assign resource ceiling priorities |
| `scheduling_feasibility_tests_compositional`                                  | Run compositional feasibility tests            |
| `scheduling_feasibility_demand_bound_function`                                | Compute demand bound function                  |
| `scheduling_feasibility_interval`                                             | Perform interval-based feasibility analysis    |

---

### Partitioning Algorithms

| Request                               | Description                         |
| ------------------------------------- | ----------------------------------- |
| `scheduling_feasibility_first_fit`    | First-Fit Partitioning algorithm    |
| `scheduling_feasibility_best_fit`     | Best-Fit Partitioning algorithm     |
| `scheduling_feasibility_next_fit`     | Next-Fit Partitioning algorithm     |
| `scheduling_feasibility_small_task`   | Small-task Partitioning algorithm   |
| `scheduling_feasibility_general_task` | General-task Partitioning algorithm |

---



### Selection / Analysis

| Request                                   | Description                     |
| ----------------------------------------- | ------------------------------- |
| `select_feasibility_tests_simple`         | Select simple feasibility tests |
| `select_feasibility_test_by_name`         | Select feasibility test by name |
| `scheduling_compute_scheduling_anomalies` | Compute scheduling anomalies    |

---

### Memory Analysis

| Request                                | Description                         |
| -------------------------------------- | ----------------------------------- |
| `memory_set_footprint_analysis`        | Configure memory footprint analysis |
| `memory_compute_footprint_analysis`    | Compute memory footprint analysis   |
| `memory_analysis_interferences_delays` | Analyze memory interference delays  |

---

### Buffer Analysis

| Request                        | Description                  |
| ------------------------------ | ---------------------------- |
| `buffer_feasibility_tests`     | Run buffer feasibility tests |
| `buffer_scheduling_simulation` | Simulate buffer scheduling   |

---

### Random / Statistical Analysis

| Request                        | Description                                |
| ------------------------------ | ------------------------------------------ |
| `random_response_time_density` | Compute response time density distribution |

---

### Dependency Analysis

| Request                                                 | Description                                           |
| ------------------------------------------------------- | ----------------------------------------------------- |
| `dependency_compute_end_to_end_response_time_one_step`  | Compute one-step end-to-end response time             |
| `dependency_set_end_to_end_response_time_one_step`      | Compute and assign one-step end-to-end response time  |
| `dependency_compute_end_to_end_response_time_all_steps` | Compute all-step end-to-end response times            |
| `dependency_set_end_to_end_response_time_all_steps`     | Compute and assign all-step end-to-end response times |
| `dependency_compute_chetto_blazewicz_priority`          | Compute Chetto-Blazewicz priorities                   |
| `dependency_compute_chetto_blazewicz_deadline`          | Compute Chetto-Blazewicz deadlines                    |
| `dependency_set_chetto_blazewicz_priority`              | Compute and assign Chetto-Blazewicz priorities        |
| `dependency_set_chetto_blazewicz_deadline`              | Compute and assign Chetto-Blazewicz deadlines         |

---

### Cache Analysis

| Request                                                      | Description                          |
| ------------------------------------------------------------ | ------------------------------------ |
| `cache_analysis_compute_cache_access_profile`                | Compute cache access profile         |
| `cache_analysis_import_cfg`                                  | Import CFG for cache analysis        |
| `cache_analysis_import_cfg_and_compute_cache_access_profile` | Import CFG and compute cache profile |

---

### Network / NoC Analysis

| Request                                             | Description                                      |
| --------------------------------------------------- | ------------------------------------------------ |
| `network_noc_compute_communication_delay`           | Compute NoC communication delay                  |
| `network_noc_compute_path_delay`                    | Compute NoC path delay                           |
| `network_noc_compute_direct_interference_delay`     | Compute direct interference delay                |
| `network_noc_compute_indirect_interference_delay`   | Compute indirect interference delay              |
| `network_compute_noc_transformation_ectm_saf`       | Compute ECTM SAF transformation                  |
| `network_set_noc_transformation_ectm_saf`           | Compute and assign ECTM SAF transformation       |
| `network_compute_noc_transformation_ectm_wormhole`  | Compute ECTM Wormhole transformation             |
| `network_set_noc_transformation_ectm_wormhole`      | Compute and assign ECTM Wormhole transformation  |
| `network_compute_noc_transformation_wcctm_saf`      | Compute WCCTM SAF transformation                 |
| `network_set_noc_transformation_wcctm_saf`          | Compute and assign WCCTM SAF transformation      |
| `network_compute_noc_transformation_wcctm_wormhole` | Compute WCCTM Wormhole transformation            |
| `network_set_noc_transformation_wcctm_wormhole`     | Compute and assign WCCTM Wormhole transformation |
| `network_compute_spacewire_transformation_scm`      | Compute SpaceWire SCM transformation             |
| `network_set_spacewire_transformation_scm`          | Compute and assign SpaceWire SCM transformation  |

---

### MILS Security Analysis

| Request                               | Description                          |
| ------------------------------------- | ------------------------------------ |
| `mils_compute_security_chinese_wall`  | Compute Chinese Wall security policy |
| `mils_compute_security_warshall`      | Compute Warshall security analysis   |
| `mils_compute_security_bell_lapadula` | Compute Bell-LaPadula security model |
| `mils_compute_security_biba`          | Compute Biba integrity model         |


## Parameters

| Parameter                              | Description                              |
| -------------------------------------- | ---------------------------------------- |
| `--param=parameter=<value>`               | execute request with this parameter                   |




### 1. Scheduling Simulation Time Line Parameters

**These Parameters are used for :** `simulation or scheduling_simulation_time_line` 

| Parameter | Values | Description |
|----------|--------|-------------|
| preemption | `0` or `1`  |  |
| wait_for_memory | `0` or `1` |  |
| buffer_overflow | `0` or `1` |  |
| buffer_underflow | `0` or `1` |  |
| period | Integer |  |
| seed_value | Integer |  |
| schedule_with_offsets | `0` or `1` |  |
| schedule_with_precedencies | `0` or `1` |  |
| schedule_with_resources | `0` or `1` |  |
| minimize_preemption | `0` or `1` |  |
| schedule_with_jitters | `0` or `1` |  |
| predictable | `0` or `1` |  |
| start_of_task_capacity | `0` or `1` |  |
| end_of_task_capacity | `0` or `1` |  |
| write_to_buffer | `0` or `1` |  |
| read_from_buffer | `0` or `1` |  |
| running_task | `0` or `1` |  |
| task_activation | `0` or `1` |  |
| send_message | `0` or `1` |  |
| receive_message | `0` or `1` |  |
| allocate_resource | `0` or `1` |  |
| release_resource | `0` or `1` |  |
| wait_for_resource | `0` or `1` |  |
| discard_missed_deadline | `0` or `1` |  |
| address_space_activation | `0` or `1` |  |
| context_switch_overhead | `0` or `1` |  |
| schedule_with_task_groups | `0` or `1` |  |
| anomaly_detection | `0` or `1` |  |
| task_specific_seed | `0` or `1` |  |
| dvfs | `0` or `1` |  |
| mode_change | `0` or `1` |  |
| tdma_slot | `0` or `1` |  |
| energy | `0` or `1` |  |
| schedule_with_crpd | `0` or `1` |  |
| schedule_with_discard_missed_deadlines | `0` or `1` |  |

---

### 2. Compute Feasibility Response Time Parameter

**These Parameters are used for :** `compute_feasibility_response_time`

| Parameter | Values | Description |
| :--- | :--- | :--- |
| `wcrt_crpd` | `1` to `5` | Specifies the algorithm configuration for Cache-Related Preemption Delays (CRPD):<br>• **1**: `wcrt_without_crpd`<br>• **2**: `wcrt_with_crpd_ECB_only`<br>• **3**: `wcrt_with_crpd_ECB_union_multiset`<br>• **4**: `wcrt_with_crpd_UCB_union_multiset`<br>• **5**: `wcrt_with_crpd_combined_multiset` |
| `wcrt_memory_interferences` | `1` to `3` | Specifies the bus arbitration and memory interference model used in calculations:<br>• **1**: `wcrt_without_memory_interferences`<br>• **2**: `wcrt_with_DRAM_single_arbiter`<br>• **3**: `wcrt_with_kalray_multi_arbiter` |


---

### 3. Compute Feasibility Test By Name

**These Parameters are used for :** `compute_feasibility_test_by_name`

| Parameter | Values | Description |
|----------|--------|-------------|
| feasibility_test_name | String |  |

---

### 4. Scheduling Simulation Response Time Parameters
**These Parameters are used for :** `scheduling_simulation_response_time`

| Parameter | Values | Description |
|----------|--------|-------------|
| r_worst_case | `0` or `1` | worst response time from simulation |
| r_best_case | `0` or `1` | best response time from simulation |
| r_average_case | `0` or `1` | average response time from simulation |

---

### 5. Scheduling Simulation Blocking Time Parameters
**These Parameters are used for :** `scheduling_simulation_blocking_time`

| Parameter | Values | Description |
|----------|--------|-------------|
| b_worst_case | `0` or `1` | worst blocking time from simulation |
| b_best_case | `0` or `1` | best blocking time from simulation |
| b_average_case | `0` or `1` | average blocking time from simulation |


---

## Help

```bash
cheddar_cli --help
```

Displays the full help message.

---

## How DETACH CLI Works

### Sequential Execution

When multiple requests are provided using `--request`, they are executed **one after another in the order they are declared**.

Example:

```bash
--request=simulation,feasibility,scheduling_simulation_response_time
```

Execution flow:

1. `simulation`
2. `feasibility`
3. `scheduling_simulation_response_time`

Each request is fully completed before the next one starts.

---

### Parameter Handling

Parameters passed via `--param` are **not globally applied blindly**.

Instead, they are:

* Parsed once at startup
* Stored in a shared configuration context
* Applied **only to requests that require them**
---

### Example

```bash
detach_cli \
  --file=system.xml \
  --request=simulation,scheduling_simulation_response_time \
  --param=period=100 \
  --param=schedule_with_resources=0
```

### What happens:

* `simulation`
    * uses `period`
    * uses `schedule_with_resources`

* `scheduling_simulation_response_time`

> If a parameter is not relevant to a request, it is simply ignored for that step.

In this example we execute a simulation with a period of 100 time units and not considering resources , then we retreive reponse time of tasks from the simulation that we executed .


