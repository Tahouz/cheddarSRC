#!/bin/bash

./../../cheddar_cli --request=scheduling_feasibility_basics --file=feasibility_basics_test_case.xml > output

if diff output output_ref > /dev/null; then
    echo "✅ PASS: scheduling_feasibility_basics"
    exit 0
else
    echo "❌ FAIL: scheduling_feasibility_basics"
    exit 1
fi
