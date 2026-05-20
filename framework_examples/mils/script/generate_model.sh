#!/bin/bash

for i in {1..524288} 
do
    bc <<< "obase=2;$i"
    echo "$bc"
    #(cd $CHEDDAR_DIR/src ; ./generator_model_v2 -i 0000000000010100010 -c 0000000000010100010 -a bell)
done


