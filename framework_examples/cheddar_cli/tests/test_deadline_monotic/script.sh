#!/bin/bash

./../../cheddar_cli --request=scheduling_set_priorities_according_to_deadline_monotonic --file=deadline_monotic_test_case.xml > output

if diff output output_ref > /dev/null; then
    echo "✅ PASS: deadline_monotic_priority_affectation"
    exit 0
else
    echo "❌ FAIL: deadline_monotic_priority_affectation"
    exit 1
fi
