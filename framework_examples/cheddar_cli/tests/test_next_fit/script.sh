#!/bin/bash

./../../cheddar_cli --request=scheduling_feasibility_next_fit --file=next_fit_test_case.xml > output

if diff output output_ref > /dev/null; then
    echo "✅ PASS: scheduling_feasibility_next_fit"
    exit 0
else
    echo "❌ FAIL: scheduling_feasibility_next_fit"
    exit 1
fi
