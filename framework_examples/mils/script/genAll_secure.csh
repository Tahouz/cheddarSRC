#!/bin/csh
echo run this script in exp1/script directory
set mils = ~illham/cheddar/trunk/src/generator_secure_model

cd ~illham/cheddar/trunk/src/


seq 20 | parallel --jobs 35 "$mils -i framework_examples/mils/xml/exp1/models/NS-BL/NS-BL-{}.xmlv3 -a bell"

#seq 1000 | parallel --jobs 35 "$mils -i ../models/NS-BB/NS-BB-{}.xmlv3 -a biba"

              

