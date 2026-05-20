#!/bin/bash

./../../cheddar_cli --request=scheduling_set_priorities_according_to_rate_monotonic --file=rate_monotic_test_case.xml > output

if diff output output_ref > /dev/null; then
    echo "✅ PASS: rate_monotic_priority_affectation"
    exit 0
else
    echo "❌ FAIL: rate_monotic_priority_affectation"
    exit 1
fi
