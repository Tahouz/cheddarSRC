#SUMMARY
Example of scheduling simulation with CRPD in Cheddar

- Generate a case study
- Run scheduling simulation
- Generate an event table

#INSTRUCTION
- cd (CHEDDAR_DIR)/trunk/src
- source (your_compile_script)
- cd (CHEDDAR_DIR)/trunk/src/framework_examples/(an_example)
- make

#RESULT
See input, output and expected output in the README.md of each examples

#CHEDDAR-GUI
To run the case study with the GUI of Cheddar

- cd (Cheddar Directory)/trunk/src
- source ../compile.bash
- make cheddar
- ./cheddar framework_examples/cache_analysis_examples/xml/case_study.xml
- Open Tools/Scheduling/Scheduling Options.
- Check the check box "CRPD".
- Click the simulation buttion (Play Icon).

