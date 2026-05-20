# Global XML representation of a response 

## Single request for the entire System
```
<responses>
    <response statement="name-of-statement">

        <!-- specific XML Respresentation -->

    <response>
</responses>
```

## Processor specific requests

```
<responses>
    <response statement="name-of-statement">
        <processor name="name-of-processor">
            <!-- specific XML Respresentation -->
        </processor>
    <response>
</responses>
```


# Priority Respresentation

the current assignement text representation of any partitionning request is in the following rule :

task-name => priority

_example :_

```
 ./cheddar_cli --request=scheduling_set_priorities_according_to_rate_monotonic --file=tests/test_rate_monotic/rate_monotic_test_case.xml 
DETACH CLI v0.2 - Analysis Results
=========================================
Input file: tests/test_rate_monotic/rate_monotic_test_case.xml



Set priorities, Processor cpu : 
Set priorities according to Rate Monotonic
- Updated priorities :
    T1 => 1
    T2 => 3
    T3 => 2
```

for priority service we can define an xml representation of the request in XML format in the following rule :

```
<priority task="T1">
1
</priority>
<priority task="T2">
3
</priority>
<priority task="T3">
2
</priority>
```





# Paritionioning Respresentation

the current assignement text representation of any partitionning request is in the following rule :

task-name => cpu-name

_example :_

```
./cheddar_cli --request=scheduling_feasibility_first_fit --file=tests/test_first_fit/first_fit_test_case.xml
DETACH CLI v0.2 - Analysis Results
=========================================
Input file: tests/test_first_fit/first_fit_test_case.xml



Scheduling feasibility, Partition With First Fit : 
- Task assignement after partitioning  (see [9], [10])  : 

    T1 =>cpu1
    T2 =>cpu1
    T3 =>cpu1
    T4 =>cpu2
    T5 =>cpu1
```


for paritioning service we can define an xml representation of the request in XML format in the following rule :




```
<assignment task="T1">
cpu1
</assignment>
<assignment task="T2">
cpu1
</assignment>
<assignment task="T3">
cpu1
</assignment>
<assignment task="T4">
cpu2
</assignment>
<assignment task="T5">
cpu1
</assignment>
```
