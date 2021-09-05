#!/bin/bash
pushd $(dirname $0)
source script-helpers

SCRIPTS_DIR=$(pwd)
SOURCE_DIR=$(realpath ${SCRIPTS_DIR}/../../../)

pushd ${SOURCE_DIR}/finder-app

make clean
make

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

./finder-test.sh
rc=$?
if [ $rc -ne 0 ]; then
	add_validate_error "finder-test.sh execution failed with return code $rc"
fi

if [ ! -z "${validate_error}" ]; then
    echo "Validation failed with error list ${validate_error}"
    exit 1
fi
