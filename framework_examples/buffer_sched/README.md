#Summary

- buffer_sched is a program designed to run scheduling simulation and perform buffer analysis of SDF and CSDF applications.

#Compile and run buffer_sched

- Download and compile Cheddar. 
A short instruction is provided below.

- Change the value of Max_Buffers in trunk/src/config/framework_config.ads to 300:
    Max_Buffers : constant Natural := 300;

- Compile buffer_sched
    $ cd $CHEDDAR_DIR/trunk/src/framework_examples/buffer_sched
    $ make 
An executable named buffer_sched_d is created. This program can be invoked with the following options
    + -t : test mode - {1,2,3,4,5,6,F,I)
        - mode F: perform scheduling simulation over 2*Hyperperiod of a given system model (need -f), results are exported to "log/" folder
        - mode I: analyse event table (need -f -e -d)
        - mode 1,2,3,4,5,6: simple case study
    + -f : String   - path to input system model (.xmlv3) 
    + -e : String   - path to input event table
    + -d : Integer  - scheduling duration
    + -x : Boolean  - 1 or 0, export_data. 
        Users can choose to export the event table produced by the simulation. 
    + -l : String   - log directory

Example: 
- run simulation, store and analyse event table of BeamformerSP_MULT_MBSp4, logs are stored in the log folder.
    ./buffer_sched_d -t F -f xml/BeamformerSP_MULT_MBSp4.xmlv3 -x 1 -l log_buffer_sched

- analyse event table of BeamformerSP_MULT_MBSp4, no simulation is run, logs are stored in the log_buffer_sched folder
    ./buffer_sched_d -t I -f xml/BeamformerSP_MULT_MBSp4.xmlv3 -e xml/BeamformerSP_MULT_MBSp4.xmlv3.ev.xml -d 73764 -l log_buffer_sched

#Cheddar GUI

To run the simulation with the GUI of Cheddar, users can invoke cheddar and provide a model of an SDF/CSDF application.
- $ ./cheddar_d framework_examples/buffer_sched_example/xml/{case study name}
- Click scheduling simulation button (Play)

#Compile Cheddar

1. Download and install GNAT 2014 (https://www.adacore.com/download/more)

2. Check out the trunk at http://beru.univ-brest.fr/svn/CHEDDAR/trunk/

3. Modify the paths in trunk/src/compilelinux64.bash
    - CHEDDAR_DIR = "Cheddar directory"
    - GNAT_DIR = "GNAT directory
Users can consider modifying the LIBRARY_PATH.

4. When everything is set, we can compile and run Cheddar
    $ cd {Cheddar directory}/trunk/src
    $ source scripts/compilelinux64.bash
    $ make cheddar
    $ ./cheddar_d

5. There could be an issue related to GNAT 2014 and gcc ABI compatibility problem on Fedora 24 and Mint 18.1 (64 bits)
This can be "fixed" as follows:
    $ cd $GNAT_DIR/libexec/gcc/x86_64-pc-linux-gnu/4.7.4/ld
    $ mv ld ld-orig





