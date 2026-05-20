# DETACH CLI - Command Line Interface for Cheddar

**DETACH** (**DE**sign and implemenTAtion of a command-line interface for **CH**eddar scheduling analyzer) is a command-line interface for the real-time scheduling analysis tool Cheddar.

## Description

DETACH CLI enables automation of Cheddar scheduling analysis via a command line interface. By using the same analysis engine as the Cheddar GUI, it ensures identical results.

### Features

- **Automation**: Bash scripts processing of Cheddar XML files
- **Compatibility**: Uses native Cheddar API
- **Configuration**: Precisious analysis parameters
- **Multiple formats**: Text or XML output

## Installation

### Prerequisites

- Cheddar Framework installed
- Ada compiler

### Compilation

```bash
gprbuild -p detach.gpr
```

## Usage

### Syntax

```bash
./detach_cli --file=<file> --request=<request> [options]
```

### CLI files structure

![DETACH CLI file structure](../image/detach_cli_file_structure.jpg)

```
detach/
├── detach_cli                    # Main executable
├── detach_cli.ali                # Ada library info
├── detach_cli.o                  # Object file
├── detach.gpr                    # GNAT project file
├── note.txt                      # Documentation notes
├── bin/                          # Compilation artifacts
├── examples/                     # Example system files
│   ├── exemple.xmlv3
│   └── multiprocessor.xmlv3
├── results/                      # Analysis results
│   └── simulation.txt
├── parametric_results/           # Parametric analysis results
│   ├── test_period24.txt
│   ├── test_period48.txt
│   ├── test_period72.txt
│   ├── test_period96.txt
│   └── test_period120.txt
├── scripts/                      # Automation scripts
│   └── detach_script_tool.sh
└── src/                          # Source code
    └── detach_cli.adb
```

## Options

### Required options

| Option              | Description                  | Example                         |
| ------------------- | ---------------------------- | ------------------------------- |
| `--file=<filename>` | System file (.xml or .xmlv3) | `--file=examples/exemple.xmlv3` |
| `--request=<types>` | Analysis types               | `--request=simulation`          |

### Output options

| Option                              | Description               |
| ----------------------------------- | ------------------------- |
| `--output=stdout`                   | Standard output (default) |
| `--output=file_text=<name>`         | Text file                 |
| `--output=file_xml_analysis=<name>` | XML file                  |

### Help

```bash
./detach_cli --help
```

## Requests

### Main requests

| Type                                  | Description                |
| ------------------------------------- | -------------------------- |
| `simulation`                          | Time scheduling simulation |
| `feasibility`                         | Feasibility tests          |
| `scheduling_simulation_response_time` | Response time analysis     |

### Specialized requests

| Type                                                        | Description         |
| ----------------------------------------------------------- | ------------------- |
| `scheduling_set_priorities_according_to_rate_monotonic`     | RM priorities       |
| `scheduling_set_priorities_according_to_deadline_monotonic` | DM priorities       |
| `scheduling_feasibility_first_fit`                          | First-Fit algorithm |
| `scheduling_feasibility_best_fit`                           | Best-Fit algorithm  |

## Parameters

### Configuration via `--param=`

| Parameter                        | Type    | Description               | Default |
| -------------------------------- | ------- | ------------------------- | ------- |
| `period=<value>`                 | Integer | Maximum simulation period | 24      |
| `schedule_with_offsets=<0\|1>`   | Boolean | Enable/disable offsets    | 1       |
| `schedule_with_resources=<0\|1>` | Boolean | Enable/disable resources  | 1       |
| `running_task=<0\|1>`            | Boolean | Task events               | 1       |
| `task_activation=<0\|1>`         | Boolean | Activation events         | 1       |

## Examples

### Simple analysis

```bash
./detach_cli --file=examples/exemple.xmlv3 --request=simulation
```

### Save to file

```bash
./detach_cli --file=examples/exemple.xmlv3
  --request=simulation
  --output=file_text=results/my_simulation
```

### Multiple analyses

```bash
./detach_cli --file=examples/exemple.xmlv3
  --request=simulation,feasibility
  --output=file_text=results/complete_analyses
```

**Result:** Creates two files:

- `results/complete_analyses_SCHEDULING_SIMULATION_TIME_LINE.txt`
- `results/complete_analyses_SCHEDULING_FEASIBILITY_BASICS.txt`

### Custom parameters

```bash
./detach_cli --file=examples/exemple.xmlv3 
  --request=simulation 
  --param=period=100 
  --param=schedule_with_resources=0 
  --output=file_text=results/custom_config
```

## Automation

### Parametric analysis script

![DETACH CLI analysis setup](../image/detach_cli_analysis_setup.jpg)

### Use

```bash
chmod +x scripts/detach_script_tool.sh
./scripts/detach_script_tool.sh
```

### Exemples configurations

```bash
# Period variation
PARAM_VALUES=(24 48 72 96 120)

# With/without resources
PARAM_NAME="schedule_with_resources"
PARAM_VALUES=(0 1 0 1 0)
```

## Output

### Text format

```
DETACH CLI v0.1 - Analysis Results
=========================================
Input file: exemple.xmlv3
Request type: SCHEDULING_SIMULATION_TIME_LINE

Simulation Parameters:
- Period: 24
- Schedule with offsets: TRUE
- Schedule with resources: TRUE

Scheduling simulation, Processor cpu1:
- Number of context switches: 10
- Number of preemptions: 3

- Task response time computed from simulation:
  T1 => 2/worst
  T2 => 4/worst
  T3 => 15/worst, missed its deadline
- Some task deadlines will be missed: the task set is not schedulable.
```

### Normal messages

```
START: SCHEDULING_SIMULATION_TIME_LINE
Nb entries:  1
END: SCHEDULING_SIMULATION_TIME_LINE
Results written to: results/my_file.txt
```

## Error handling

### Common messages

```bash
# Missing file
Error: Input file does not exist: exemple.xmlv3
# Solution: use examples/exemple.xmlv3

# Missing request
Error: At least one request must be specified with --request
# Solution: add --request=simulation

# Invalid parameter
Error: Boolean parameter must be 0 or 1
# Solution: use 0 or 1 for boolean values
```

### Exit codes

| Code | Meaning |
| ---- | ------- |
| 0    | Success |
| 1    | Error   |

## Architecture and API Integration

### Technical Architecture

DETACH CLI is built on top of the existing Cheddar Framework API, ensuring full compatibility and identical results with the GUI version.

#### Core Architecture Flow

```
CLI Arguments -> Parser -> Cheddar API -> Analysis Engine -> Results Formatter -> Output
```

1. **INITIALIZE**: `Call_Framework.initialize(False)`
2. **PARSE**: Extract options and parameters from command line
3. **LOAD**: `Systems.Read_From_Xml_File()` - Load system model
4. **BUILD**: Construct `Framework_Request` with parameters
5. **EXECUTE**: `Sequential_Framework_Request()` - Run analysis
6. **EXTRACT**: Get results from `Response_List.entries(i).text`
7. **FORMAT**: Output as text or XML

### Cheddar API Dependencies

#### Core Framework APIs

```ada
with Call_Framework;              use Call_Framework;
with Call_Framework_Interface;    use Call_Framework_Interface;
with Framework;                   use Framework;
```

**Key functions:**

- `Call_Framework.initialize()` - Initialize Cheddar framework
- `Sequential_Framework_Request()` - Execute analysis requests
- `Framework_Request` / `Framework_Response` - Request/response handling

#### System Model APIs

```ada
with Systems;                     use Systems;
with Processors;                  use Processors;
with processor_set;               use processor_set;
```

**Key functions:**

- `Systems.Read_From_Xml_File()` - Load .xmlv3 files
- `Systems.Read_From_v2_Xml_File()` - Load .xml files

#### Analysis APIs

```ada
with scheduling_simulation_util;  use scheduling_simulation_util;
with call_scheduling_framework;   use call_scheduling_framework;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
```

**Key functions:**

- `compute_scheduling_of_tasks_from_ada_sys_model()` - Scheduling simulation
- `compute_simulation_number_of_context_switch()` - Context switch analysis
- `compute_simulation_response_time()` - Response time computation

#### Parameter Management APIs

```ada
with Parameters;                  use Parameters;
use Parameters.Framework_Parameters_Table_Package;
```

**Key functions:**

- `Parameter_Ptr` - Parameter handling
- `Add(A_Request.param, A_Param)` - Parameter injection

### API Advantage

**Same Analysis Engine = Identical Results**

Using the native Cheddar API ensures:

- **Consistency**: Same results as GUI version
- **Reliability**: Proven analysis algorithms
- **Maintainability**: Automatic updates when Cheddar evolves
- **Completeness**: Access to all Cheddar features

### Request Types Mapping

| CLI Request                                             | Cheddar API Constant                                    |
| ------------------------------------------------------- | ------------------------------------------------------- |
| `simulation`                                            | `Scheduling_Simulation_Time_Line`                       |
| `feasibility`                                           | `Scheduling_Feasibility_Basics`                         |
| `scheduling_simulation_response_time`                   | `Scheduling_Simulation_Response_Time`                   |
| `scheduling_set_priorities_according_to_rate_monotonic` | `Scheduling_Set_Priorities_According_To_Rate_Monotonic` |

---

Version 0.1

Author: Alexandre LAISSY 
