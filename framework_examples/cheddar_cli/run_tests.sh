#!/bin/bash

BASE_DIR="tests"

total=0
passed=0
failed=0

for dir in "$BASE_DIR"/test_*; do
    if [ -d "$dir" ]; then
        script="$dir/script.sh"

        if [ -f "$script" ]; then
            ((total++))

            (
                cd "$dir" || exit 1
                sh script.sh
            )

            if [ $? -eq 0 ]; then
                ((passed++))
            else
                ((failed++))
            fi
        else
            echo "⚠️ No script.sh in $dir"
        fi
    fi
done

echo "Passed : $passed / $total"
