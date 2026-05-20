#!/bin/bash

# --------------------------------------------------------
# Usage: 
# >> ./runCheddar $1
#    $1 = directory to get all Cheddar .xmlv3 files 
# 
# Assumed: 
#    the path to the command cheddar buffer_sched_d is set
# --------------------------------------------------------


# TO SET BY USER
CHEDDAR_BUFFER_TRUNK="/home/hntran/Dev/cheddar/trunk"

CHEDDAR_BUFFER_ROOT="${CHEDDAR_BUFFER_TRUNK}/src/framework_examples/buffer_sched/"
CHEDDAR_BUFFER_EXE="${CHEDDAR_BUFFER_TRUNK}/src/framework_examples/buffer_sched/buffer_sched_d"
CHEDDAR_COMPIL_SCRIPT="${CHEDDAR_BUFFER_TRUNK}/src/compilelinux64.bash"


if [ $# -ne 1 -o -z "$1" ]; then
    echo ""
    echo "ERROR, Syntax: $0 <directory to get all Cheddar .xmlv3 files>"
    echo ""
    exit 1
fi

LOG_PATH="cheddar_simulation-$1"

mkdir -p "${LOG_PATH}"

REGEX_FILES='^[\.]?[a-zA-Z1-9_/\-]+(p1s|p2s|p4s|p8s)[a-zA-Z_/\-]+\.xmlv3'
	
#declare -a files=( $(find $1 -name '*.xmlv3' -printf '%p ') )
#declare -a files=( $(find $1 -regextype posix-extended -regex ${REGEX_FILES} -printf '%p ') )

source "${CHEDDAR_COMPIL_SCRIPT}"
cd "${CHEDDAR_BUFFER_ROOT}"
make
cd -

for file in $1/*.xmlv3; do
    if [ -f "${file}" ]; then

	    echo "==> Running: ${file}"

	    ${CHEDDAR_BUFFER_EXE} -t F -f ${file} -n -x 1 -l ${LOG_PATH} 
	    exitStatus=$?
	    if [ ${exitStatus} -ne 0 ]; then
	        echo "Something went wrong with the file: ${file}"
	        echo "which exited with status ${exitStatus}." 
	    fi

    fi
done




