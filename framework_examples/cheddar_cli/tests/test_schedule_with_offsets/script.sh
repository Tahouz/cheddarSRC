#!/bin/bash

./../../cheddar_cli --request=simulation --file=schedule_with_offset_test_case.xml --param=schedule_with_offsets=0 --output=file_xml_eventtable=schedule_without_offset > /dev/null
./../../cheddar_cli --request=simulation --file=schedule_with_offset_test_case.xml --param=schedule_with_offsets=1 --output=file_xml_eventtable=schedule_with_offset > /dev/null

if diff schedule_with_offset.xml schedule_with_offset_ref.xml > /dev/null && \
   diff schedule_without_offset.xml schedule_without_offset_ref.xml > /dev/null; then
    echo "✅ PASS: schedule_with_offset_test_case"
    exit 0
else
    echo "❌ FAIL: schedule_with_offset_test_case"
    exit 1
fi
