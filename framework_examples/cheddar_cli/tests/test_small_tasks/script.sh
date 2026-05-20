#!/bin/bash

./../../cheddar_cli --request=scheduling_feasibility_small_task --file=small_tasks_test_case.xml > output
./../../cheddar_cli --request=scheduling_feasibility_small_task --file=small_tasks_test_case2.xml >> output

if diff output output_ref > /dev/null; then
    echo "✅ PASS: scheduling_feasibility_small_task"
    exit 0
else
    echo "❌ FAIL: scheduling_feasibility_small_task"
    exit 1
fi
