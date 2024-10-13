#!/bin/bash
pushd $(dirname $0)
source script-helpers

SCRIPTS_DIR=$(pwd)
SOURCE_DIR=$(realpath ${SCRIPTS_DIR}/../../../)

pushd ${SOURCE_DIR}/finder-app

make clean
if [ -x "./writer" ]; then
    echo "ERROR: make clean does not clean up the writer executable in ${SOURCE_DIR}/finder-app"
    exit 1
fi

make
if [ -x "./writer" ]; then
    ./writer
    rc=$?
    if [ $rc -ne 1 ]; then
        add_validate_error "writer should have exited with return value 1 if no parameters were specified"
    fi

    ./writer "$filedir"
    rc=$?
    if [ $rc -ne 1 ]; then
        add_validate_error "writer should have exited with return value 1 if write string is not specified"
    fi
    echo "Performing make clean"
    make clean
else
    echo "Makefile Error, Failed to generate writer executable in ${SOURCE_DIR}/finder-app."
    exit 1
fi

./finder-test.sh
rc=$?
# Check if writer executable exists after finder-test.sh
if [ ! -x "./writer" ]; then
    echo "ERROR: ./writer executable does not exist after executing finder-test.sh in ${SOURCE_DIR}/finder-app. Make sure finder-test.sh includes the necessary make step."
    exit 1
fi

if [ $rc -ne 0 ]; then
    add_validate_error "finder-test.sh execution failed with return code $rc"
fi

if [ ! -z "${validate_error}" ]; then
    echo "Validation failed with error list ${validate_error}"
    exit 1
fi

